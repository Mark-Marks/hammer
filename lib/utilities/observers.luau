-- https://github.com/Ukendio/jecs/blob/main/addons/observers.luau
--[[
    MIT License

    Copyright (c) 2024 jecs authors

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]
local jecs = require("../../jecs")

export type PatchedWorld = jecs.World & {
    added: <T>(PatchedWorld, jecs.Id<T>, (e: jecs.Entity, id: jecs.Id, value: T) -> ()) -> () -> (),
    removed: <T>(PatchedWorld, jecs.Id<T>, (e: jecs.Entity, id: jecs.Id) -> ()) -> () -> (),
    changed: <T>(PatchedWorld, jecs.Id<T>, (e: jecs.Entity, id: jecs.Id, value: T) -> ()) -> () -> (),
    observer: (PatchedWorld, any, (jecs.Entity) -> ()) -> (),
    monitor: (PatchedWorld, any, (jecs.Entity, jecs.Id) -> ()) -> (),
}

local function observers_new(world, query, callback)
    local terms = query.filter_with :: { jecs.Id }
    if not terms then
        local ids = query.ids
        query.filter_with = ids
        terms = ids
    end

    local entity_index = world.entity_index :: any
    local function emplaced(entity)
        local r = jecs.entity_index_try_get_fast(entity_index, entity :: any)

        if not r then
            return
        end

        local archetype = r.archetype

        if jecs.query_match(query, archetype) then
            callback(entity)
        end
    end

    for _, term in terms do
        world:added(term, emplaced)
        world:changed(term, emplaced)
    end
end

local function monitors_new(world, query, callback)
    local terms = query.filter_with :: { jecs.Id }
    if not terms then
        local ids = query.ids
        query.filter_with = ids
        terms = ids
    end

    local entity_index = world.entity_index :: any
    local function emplaced(entity: jecs.Entity)
        local r = jecs.entity_index_try_get_fast(entity_index, entity :: any)

        if not r then
            return
        end

        local archetype = r.archetype

        if jecs.query_match(query, archetype) then
            callback(entity, jecs.OnAdd)
        end
    end

    local function removed(entity: jecs.Entity)
        local r = jecs.entity_index_try_get_fast(entity_index, entity :: any)

        if not r then
            return
        end

        local archetype = r.archetype

        if jecs.query_match(query, archetype) then
            local EcsOnRemove = jecs.OnRemove :: jecs.Id
            callback(entity, EcsOnRemove)
        end
    end

    for _, term in terms do
        world:added(term, emplaced)
        world:removed(term, removed)
    end
end

local function observers_add(world: jecs.World): PatchedWorld
    type Signal = { [jecs.Entity]: { (...any) -> () } }

    local world_mut = world :: jecs.World & { [string]: any }

    local signals = {
        added = {} :: Signal,
        emplaced = {} :: Signal,
        removed = {} :: Signal,
    }

    world_mut.added = function<T>(_: jecs.World, component: jecs.Id<T>, fn: (e: jecs.Entity, id: jecs.Id, value: T) -> ())
        local listeners = signals.added[component]
        if not listeners then
            listeners = {}
            signals.added[component] = listeners

            local function on_add(entity, id, value)
                for _, listener in listeners :: any do
                    listener(entity, id, value)
                end
            end
            local existing_hook = world:get(component, jecs.OnAdd)
            if existing_hook then
                table.insert(listeners, existing_hook)
            end

            local idr = world.component_index[component]
            if idr then
                idr.hooks.on_add = on_add
            else
                world:set(component, jecs.OnAdd, on_add)
            end
        end
        table.insert(listeners, fn)
        return function()
            local n = #listeners
            local i = table.find(listeners, fn)
            listeners[i] = listeners[n]
            listeners[n] = nil
        end
    end

    world_mut.changed = function<T>(
        _: jecs.World,
        component: jecs.Id<T>,
        fn: (e: jecs.Entity, id: jecs.Id, value: T) -> ()
    )
        local listeners = signals.emplaced[component]
        if not listeners then
            listeners = {}
            signals.emplaced[component] = listeners
            local function on_change(entity, id, value: any)
                for _, listener in listeners :: any do
                    listener(entity, id, value)
                end
            end
            local existing_hook = world:get(component, jecs.OnChange)
            if existing_hook then
                table.insert(listeners, existing_hook)
            end
            local idr = world.component_index[component]
            if idr then
                idr.hooks.on_change = on_change
            else
                world:set(component, jecs.OnChange, on_change)
            end
        end
        table.insert(listeners, fn)
        return function()
            local n = #listeners
            local i = table.find(listeners, fn)
            listeners[i] = listeners[n]
            listeners[n] = nil
        end
    end

    world_mut.removed = function<T>(_: jecs.World, component: jecs.Id<T>, fn: (e: jecs.Entity, id: jecs.Id) -> ())
        local listeners = signals.removed[component]
        if not listeners then
            listeners = {}
            signals.removed[component] = listeners
            local function on_remove(entity, id)
                for _, listener in listeners :: any do
                    listener(entity, id)
                end
            end
            local existing_hook = world:get(component, jecs.OnRemove)
            if existing_hook then
                table.insert(listeners, existing_hook)
            end

            local idr = world.component_index[component]
            if idr then
                idr.hooks.on_remove = on_remove
            else
                world:set(component, jecs.OnRemove, on_remove)
            end
        end

        table.insert(listeners, fn)

        return function()
            local n = #listeners
            local i = table.find(listeners, fn)
            listeners[i] = listeners[n]
            listeners[n] = nil
        end
    end

    world_mut.signals = signals

    world_mut.observer = observers_new

    world_mut.monitor = monitors_new

    world_mut.trackers = {}

    return world_mut :: PatchedWorld
end

return observers_add
