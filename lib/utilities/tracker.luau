--!strict
--!optimize 2
local add_observers = require("./observers")
local command_buffer = require("./command_buffer")
local jecs = require("../../jecs")
type Entity<T = unknown> = jecs.Entity<T>
type Id<T = unknown> = jecs.Id<T>
type i53 = number

local construct_ref = require("./ref")

-- The external type differs for better DX
export type Commands = {
    added: { [i53]: { i53 } },
    set: { [i53]: { [i53]: unknown } },
    removed: { [i53]: { i53 } },
}

type Added = { [Id]: { Entity } }
type Set = { [Id]: { [Entity]: unknown } }
type Removed = { [Id]: { Entity } }
type Lookup = { [Id]: { [Entity]: number } }
type InternalCommands = {
    added: Added,
    set: Set,
    removed: Removed,
}

--- Tracks operations on entities for the provided world.
export type Identity = {
    --- Gets the current state.
    --- A state is a representation of the minimum of commands necessary to produce the current world from a clean slate.
    state: () -> Commands,
    --- Gets the currently tracked snapshot.
    --- A snapshot is a representation of the minimum of commands necessary to produce the current world back from when the last snapshot was taken.
    snapshot: () -> Commands?,
    --- Applies a set of commands to the tracked world, optionally doing it through a command buffer.
    apply: (snapshot: Commands, buf: command_buffer.Identity?) -> (),
}

local function get_non_nilable<T, K>(container: {} & T, index: K): index<T, K>
    local data = container[index]
    if not data then
        data = {}
        container[index] = data
    end
    return data
end

local function insert_unique<T, V>(container: T, value: V, lookup: { [V]: number }?)
    if lookup then
        if lookup[value] then
            return
        end

        local idx = #lookup + 1
        lookup[value] = idx;
        (container :: any)[idx] = value
        return
    end

    if table.find(container, value) then
        return
    end
    table.insert(container, value)
end

--- This function modifies the world to use observers.
local function construct(world: jecs.World, ...: Entity<any>): Identity
    local components = { ... }
    local ref = construct_ref(world, true)

    local state_added: Added = {}
    local state_added_lookup: Lookup = {}
    local state_set: Set = {}
    local state_removed: Removed = {}
    local state_removed_lookup: Lookup = {}

    local snapshot_added: Added = {}
    local snapshot_set: Set = {}
    local snapshot_removed: Removed = {}

    world = add_observers(world) :: add_observers.PatchedWorld

    for _, component in components do
        world:added(component, function(entity, _, value)
            if (value :: any) == nil then
                local snapshot = get_non_nilable(snapshot_added, component)
                insert_unique(snapshot, entity)

                local state = get_non_nilable(state_added, component)
                local lookup = get_non_nilable(state_added_lookup, component)
                insert_unique(state, entity, lookup)

                -- Clean up previous operations
                local set_state = state_set[component]
                if set_state and set_state[entity] then
                    set_state[entity] = nil
                end
            else
                local set_snapshot = get_non_nilable(snapshot_set, component)
                set_snapshot[entity] = value

                local set_state = get_non_nilable(state_set, component)
                set_state[entity] = value

                -- Clean up previous operations
                local added_lookup = state_added_lookup[component]
                if added_lookup then
                    local idx = added_lookup[entity]
                    if idx then
                        added_lookup[entity] = nil
                        local added_state = state_added[component]
                        if added_state then
                            -- Shifting around the array could get expensive, prefer `array[idx] = nil`
                            added_state[idx] = nil
                        end
                    end
                end
            end

            local removed_lookup = state_removed_lookup[component]
            if removed_lookup then
                local idx = removed_lookup[entity]
                if idx then
                    removed_lookup[entity] = nil
                    local removed_state = state_removed[component]
                    if removed_state then
                        -- Shifting around the array could be expensive, prefer `tbl[idx] = nil`
                        removed_state[idx] = nil
                    end
                end
            end
        end)

        world:changed(component, function(entity, _, value)
            local snapshot = get_non_nilable(snapshot_set, component)
            snapshot[entity] = value

            local state = get_non_nilable(state_set, component)
            state[entity] = value

            -- Clean up previous operations
            local added_lookup = state_added_lookup[component]
            if added_lookup then
                local idx = added_lookup[entity]
                if idx then
                    added_lookup[entity] = nil
                    local added_state = state_added[component]
                    if added_state then
                        -- Shifting around the array could get expensive, prefer `array[idx] = nil`
                        added_state[idx] = nil
                    end
                end
            end

            local removed_lookup = state_removed_lookup[component]
            if removed_lookup then
                local idx = removed_lookup[entity]
                if idx then
                    removed_lookup[entity] = nil
                    local removed_state = state_removed[component]
                    if removed_state then
                        -- Shifting around the array could get expensive, prefer `array[idx] = nil`
                        removed_state[idx] = nil
                    end
                end
            end
        end)

        world:removed(component, function(entity: Entity)
            local snapshot = get_non_nilable(snapshot_removed, component)
            insert_unique(snapshot, entity)

            local state = get_non_nilable(state_removed, component)
            local lookup = get_non_nilable(state_removed_lookup, component)

            -- Clean up previous operations
            local added_lookup = state_added_lookup[component]
            if added_lookup then
                local idx = added_lookup[entity]
                if idx then
                    added_lookup[entity] = nil
                    local added_state = state_added[component]
                    if added_state then
                        -- Shifting around the array could get expensive, prefer `array[idx] = nil`
                        added_state[idx] = nil
                    end
                end
            end

            local set_state = state_set[component]
            if set_state and set_state[entity] then
                set_state[entity] = nil
            end

            insert_unique(state, entity, lookup)
        end)
    end

    -- We cast anything exposing `Commands` as `any` to improve the types for the end user
    local function get_state(): InternalCommands
        return {
            added = state_added,
            set = state_set,
            removed = state_removed,
        }
    end

    local function get_snapshot(): InternalCommands?
        local diff_added = snapshot_added
        local diff_set = snapshot_set
        local diff_removed = snapshot_removed
        snapshot_added = {}
        snapshot_set = {}
        snapshot_removed = {}

        if next(diff_added) == nil and next(diff_set) == nil and next(diff_removed) == nil then
            return nil
        end

        return {
            added = diff_added,
            set = diff_set,
            removed = diff_removed,
        }
    end

    local function apply_snapshot(snapshot: InternalCommands, buf: command_buffer.Identity?)
        local add
        local set
        local remove
        do
            if buf then
                add = buf.add
                set = buf.set
                remove = buf.remove
            else
                function add<T>(entity: Entity, component: Id<T>)
                    world:add(entity, component)
                end

                function set<T>(entity: Entity, component: Id<T>, data: T)
                    world:set(entity, component, data)
                end

                function remove<T>(entity: Entity, component: Id<T>)
                    world:remove(entity, component)
                end
            end
        end

        for component, entities in snapshot.added do
            for _, id in entities do
                local entity = ref(`foreign-{id}`)

                if world:has(entity, component) then
                    continue
                end
                add(entity, component)
            end
        end

        for component, entities in snapshot.set do
            for id, data in entities do
                local entity = ref(`foreign-{id}`)

                if world:get(entity, component) == data then
                    continue
                end
                set(entity, component, data)
            end
        end

        for component, entities in snapshot.removed do
            for _, id in entities do
                local entity = ref(`foreign-{id}`)

                if world:has(entity, component) then
                    continue
                end
                remove(entity, component)
            end
        end
    end

    -- Public types differ for better DX
    return {
        state = get_state,
        snapshot = get_snapshot,
        apply = apply_snapshot,
    } :: any
end

return construct
