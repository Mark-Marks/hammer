--!strict
--!optimize 2
local jecs = require("../../jecs")
type Entity<T = any> = jecs.Entity<T>
type Id<T = any> = jecs.Id<T>
type World = jecs.World

export type Identity = {
    --- Execute all commands and clear the buffer.
    read flush: () -> (),
    --- Peeks into the commands currently stored by the buffer.
    read peek: () -> Commands,

    --- Adds a component to the entity with no value.
    read add: <T>(entity: Entity, component: Id<T>) -> (),
    --- Assigns a value to a component on the given entity.
    read set: <T>(entity: Entity, component: Id<T>, data: T) -> (),
    --- Removes a component from the given entity.
    read remove: <T>(entity: Entity, component: Id<T>) -> (),
    --- Deletes an entity and all it's related components and relationships.
    read delete: (entity: Entity) -> (),
}

export type Commands = {
    read add: { [Id]: { Entity } },
    read set: { [Id]: { [Entity]: unknown } },
    read remove: { [Id]: { Entity } },
    read delete: { Entity },

    read deletion_lookup: { [Entity]: true },
}

local function construct(world: World): Identity
    local add_commands: { [Id]: { Entity } } = {}
    local set_commands: { [Id]: { [Entity]: unknown } } = {}
    local remove_commands: { [Id]: { Entity } } = {}
    local delete_commands: { Entity } = {}
    -- Double memory usage for deletions but preserve order while keeping constant time lookups
    local deletion_lookup: { [Entity]: true } = {}

    @native
    local function flush()
        for _, entity in delete_commands do
            world:delete(entity)
        end

        for component, entities in add_commands do
            for _, entity in entities do
                if deletion_lookup[entity] then
                    continue
                end

                world:add(entity, component)
            end
        end
        table.clear(add_commands)

        for component, entities in set_commands do
            for entity, value in entities do
                if deletion_lookup[entity] then
                    continue
                end

                world:set(entity, component, value)
            end
        end
        table.clear(set_commands)

        for component, entities in remove_commands do
            for _, entity in entities do
                if deletion_lookup[entity] then
                    continue
                end

                world:remove(entity, component)
            end
        end
        table.clear(remove_commands)

        table.clear(delete_commands)
        table.clear(deletion_lookup)
    end

    @native
    local function peek(): Commands
        return {
            add = add_commands,
            set = set_commands,
            remove = remove_commands,
            delete = delete_commands,

            deletion_lookup = deletion_lookup,
        }
    end

    @native
    local function add<T>(entity: Entity, component: Id<T>)
        local commands = add_commands[component]
        if not commands then
            commands = {}
            add_commands[component] = commands
        end

        table.insert(commands, entity)
    end

    @native
    local function set<T>(entity: Entity, component: Id<T>, data: T)
        local commands = set_commands[component]
        if not commands then
            commands = {}
            set_commands[component] = commands
        end

        commands[entity] = data
    end

    @native
    local function remove<T>(entity: Entity, component: Id<T>)
        local commands = remove_commands[component]
        if not commands then
            commands = {}
            remove_commands[component] = commands
        end

        table.insert(commands, entity)
    end

    @native
    local function delete(entity: Entity)
        table.insert(delete_commands, entity)
        deletion_lookup[entity] = true
    end

    return {
        flush = flush,
        peek = peek,

        add = add,
        set = set,
        remove = remove,
        delete = delete,
    }
end

return construct
