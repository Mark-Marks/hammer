--!strict
--!optimize 2
local jecs = require("../../jecs")
type Entity<T = any> = jecs.Entity<T>

export type Identity = setmetatable<{}, {
    __call: <T>(any, key: unknown, is_a: jecs.Id<any>?) -> Entity<T>,
    __index: {
        reference: <T>(key: unknown, is_a: jecs.Id<any>?) -> Entity<T>,
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

    @native
    local function ref<T>(key: unknown, is_a: jecs.Id<any>?): Entity<T>
        local entity = lookup[key]
        if not entity then
            entity = world:entity()
            if is_a ~= nil then
                world:add(entity, is_a)
            end
            lookup[key] = entity
        end

        return entity
    end

    @native
    local function find<T>(key: unknown): Entity<T>?
        local entity = lookup[key]
        if not entity then
            return nil
        end

        return entity
    end

    @native
    local function delete<T>(key: unknown): Entity<T>?
        local entity = lookup[key]
        lookup[key] = nil
        return entity
    end

    @native
    local function call<T>(_, key: unknown, is_a: jecs.Id<any>?): Entity<T>
        return ref(key, is_a)
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
