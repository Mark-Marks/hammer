--!strict
--!optimize 2
local jecs = require("../../jecs")
type Entity<T = any> = jecs.Entity<T>

export type Identity = setmetatable<{}, {
    __call: <T>(any, key: unknown) -> Entity<T>,
    __index: {
        reference: <T>(key: unknown) -> Entity<T>,
        find: <T>(key: unknown) -> Entity<T>?,
        delete: <T>(key: unknown) -> Entity<T>?,
    },
}>

type Cleaner = () -> ()

local ref_cache: { [jecs.World]: Identity } = {}

local function construct(world: jecs.World, skip_cache: boolean?): Identity
    if not skip_cache then
        local hit = ref_cache[world]
        if hit then
            return hit
        end
    end

    local lookup: { [unknown]: Entity } = {}

    local function ref<T>(key: unknown): Entity<T>
        local entity = lookup[key]
        if not entity then
            entity = world:entity()
            lookup[key] = entity
        end

        return entity
    end

    local function find<T>(key: unknown): Entity<T>?
        local entity = lookup[key]
        if not entity then
            return nil
        end

        return entity
    end

    local function delete<T>(key: unknown): Entity<T>?
        local entity = lookup[key]
        lookup[key] = nil
        return entity
    end

    local function call<T>(_, key: unknown): Entity<T>
        return ref(key)
    end

    local self = setmetatable({}, {
        __call = call,
        __index = {
            reference = ref,
            find = find,
            delete = delete,
        },
    })

    if not skip_cache then
        ref_cache[world] = self
    end

    return self
end

return construct
