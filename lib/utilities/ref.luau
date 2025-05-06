--!strict
--!optimize 2
local jecs = require("../../jecs")
type Entity<T = unknown> = jecs.Entity<T>

export type Identity = typeof(setmetatable(
    {},
    {} :: {
        __call: <T>(any, key: unknown) -> (Entity<T>, Cleaner),
        __index: {
            reference: <T>(key: unknown) -> (Entity<T>, Cleaner),
            find: <T>(key: unknown) -> (Entity<T>?, Cleaner?),
        },
    }
))

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
    local cleaner_cache: { [unknown]: Cleaner } = {}

    local function serve_cleaner(key: unknown): () -> ()
        local hit = cleaner_cache[key]
        if hit then
            return hit
        end

        local function cleaner()
            lookup[key] = nil
            cleaner_cache[key] = nil
        end
        cleaner_cache[key] = cleaner

        return cleaner
    end

    local function ref<T>(key: unknown): (Entity<T>, Cleaner)
        local entity = lookup[key]
        if not entity then
            entity = world:entity()
            lookup[key] = entity
        end

        return entity, serve_cleaner(key)
    end

    local function find<T>(key: unknown): (Entity<T>?, Cleaner?)
        local entity = lookup[key]
        if not entity then
            return nil, nil
        end

        return entity, serve_cleaner(key)
    end

    local function call<T>(_, key: unknown): (Entity<T>, Cleaner)
        return ref(key)
    end

    local self = setmetatable({}, {
        __call = call,
        __index = {
            reference = ref,
            find = find,
        },
    })

    if not skip_cache then
        ref_cache[world] = self
    end

    return self
end

return construct
