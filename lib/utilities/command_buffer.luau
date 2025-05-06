--!strict
--!optimize 2
local jecs = require("../../jecs")
type Entity<T = unknown> = jecs.Entity<T>
type Id<T = unknown> = jecs.Id<T>
type World = jecs.World

export type Identity = {
    --- Execute all commands and clear the buffer
    flush: () -> (),
    --- Peeks into the commands currently stored by the buffer
    peek: () -> Commands,

    --- Adds a component to the entity with no value
    add: <T>(entity: Entity, component: Id<T>) -> (),
    --- Assigns a value to a component on the given entity
    set: <T>(entity: Entity, component: Id<T>, data: T) -> (),
    --- Removes a component from the given entity
    remove: <T>(entity: Entity, component: Id<T>) -> (),
    --- Deletes an entity and all it's related components and relationships
    delete: (entity: Entity) -> (),
}

export type Commands = {
    add: { [Id]: { Entity } },
    set: { [Id]: { [Entity]: unknown } },
    remove: { [Id]: { Entity } },
    delete: { Entity },

    deletion_lookup: { [Entity]: true },
}

local function construct(world: World): Identity
    local add_commands: { [Id]: { Entity } } = {}
    local set_commands: { [Id]: { [Entity]: unknown } } = {}
    local remove_commands: { [Id]: { Entity } } = {}
    local delete_commands: { Entity } = {}
    -- Double memory usage for deletions but preserve order while keeping O(1) performance for lookups
    local deletion_lookup: { [Entity]: true } = {}

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

    local function peek()
        return {
            add = add_commands,
            set = set_commands,
            remove = remove_commands,
            delete = delete_commands,

            deletion_lookup = deletion_lookup,
        }
    end

    local function add<T>(entity: Entity, component: Id<T>)
        local cmds = add_commands[component]
        if not cmds then
            cmds = {}
            add_commands[component] = cmds
        end

        table.insert(cmds, entity)
    end

    local function set<T>(entity: Entity, component: Id<T>, data: T)
        local cmds = set_commands[component]
        if not cmds then
            cmds = {}
            set_commands[component] = cmds
        end

        cmds[entity] = data
    end

    local function remove<T>(entity: Entity, component: Id<T>)
        local cmds = remove_commands[component]
        if not cmds then
            cmds = {}
            remove_commands[component] = cmds
        end

        table.insert(cmds, entity)
    end

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
