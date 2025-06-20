--!strict
-- stylua: ignore start
local hammer = require("../lib")
local jecs = require("@pkg/jecs")
local testkit = require("./testkit")

type Entity<T = unknown> = jecs.Entity<T>

local collect = hammer.collect
local make_tracker = hammer.tracker
local make_ref = hammer.ref
local make_command_buffer = hammer.command_buffer
local add_observers = hammer.add_observers

local signal = require("./signal")

local BENCH, START = testkit.benchmark()

local TEST, CASE, CHECK, FINISH, SKIP, FOCUS = testkit.test()

TEST("hammer.collect()", function()
    do CASE "collects"
        local sig: signal.Signal<number> = signal()
        local flush = collect(sig)
        local should = {}

        for idx = 100, 1, -1 do
            local n = math.random()
            should[idx] = n
            sig:fire(n)
        end

        for idx, n in flush do
            CHECK(should[idx] == n)
        end
    end
end)

TEST("hammer.ref()", function()
    do CASE "set_ref"
        local world = jecs.world()
        local ref = make_ref(world, true)

        local a = ref(1234)
        local b = ref(1234)
        CHECK(a == b)
    end

    do CASE "find"
        local world = jecs.world()
        local ref = make_ref(world, true)

        local a = ref(1234)
        local b = ref.find(1234)
        CHECK(a == b)
    end

    do CASE "cleaner"
        local world = jecs.world()
        local ref = make_ref(world, true)

        local a, clean = ref(1234)
        clean()
        local b = ref(1234)
        CHECK(b ~= a)
    end

    do CASE "caching"
        local world = jecs.world()
        local ref_a = make_ref(world)
        local ref_b = make_ref(world)
        CHECK(ref_a == ref_b)
        local ref_c = make_ref(world, true)
        CHECK(ref_c ~= ref_a and ref_c ~= ref_b)
    end
end)

-- TODO! write extensive tests for state operation cleaning
TEST("hammer.tracker()", function()
    do CASE "snapshot"
        local world = jecs.world()
        local tag = world:entity()
        local component = world:component() :: Entity<number>

        local entity1 = world:entity()
        local entity2 = world:entity()

        local tracker = make_tracker(world, component, tag)

        world:add(entity1, tag)
        world:set(entity2, component, 50)

        local snapshot = tracker.snapshot()
        CHECK(snapshot ~= nil)
        assert(snapshot) -- Refinements

        local world2 = jecs.world()
        local component2 = world2:component() :: Entity<number>
        local tag2 = world2:entity()

        local tracker2 = make_tracker(world2, component2, tag2)

        tracker2.apply(snapshot)

        CHECK(world:has(entity1, tag2))
        CHECK(world:get(entity2, component2) == 50)
    end

    do CASE "state"
        local world = jecs.world()
        local tag = world:entity()
        local component = world:component() :: Entity<number>

        local entity1 = world:entity()
        local entity2 = world:entity()

        local tracker = make_tracker(world, component, tag)

        world:add(entity1, tag)
        world:set(entity2, component, 50)

        local state = tracker.state()
        CHECK(state ~= nil)

        local world2 = jecs.world()
        local component2 = world2:component() :: Entity<number>
        local tag2 = world2:entity()

        local tracker2 = make_tracker(world2, component2, tag2)

        tracker2.apply(state)

        CHECK(world:has(entity1, tag2))
        CHECK(world:get(entity2, component2) == 50)
    end

    do CASE "simplifying"
        local world = jecs.world()
        local component = world:component() :: Entity<number>

        local entity = world:entity()
        local tracker = make_tracker(world, component)

        world:add(entity, component)
        do
            local state = tracker.state()
            CHECK(table.find(state.added[component :: any], entity))
        end
        world:set(entity, component, 50)
        do
            local state = tracker.state()
            CHECK(not table.find(state.added[component :: any], entity))
            CHECK(state.set[component :: any][entity :: any] == 50)
        end
        world:remove(entity, component)
        do
            local state = tracker.state()
            CHECK(state.set[component :: any][entity :: any] == nil)
            CHECK(table.find(state.removed[component :: any], entity))
        end
        world:add(entity, component)
        do
            local state = tracker.state()
            CHECK(not table.find(state.removed[component :: any], entity))
        end
        world:remove(entity, component)
        do
            local state = tracker.state()
            CHECK(state.set[component :: any][entity :: any] == nil)
            CHECK(table.find(state.removed[component :: any], entity))
        end
        world:set(entity, component, 50)
        do
            local state = tracker.state()
            CHECK(not table.find(state.removed[component :: any], entity))
            CHECK(state.set[component :: any][entity :: any] == 50)
        end
    end
end)

TEST("hammer.command_buffer()", function()
    do CASE "add"
        local world = jecs.world()
        local command_buffer = make_command_buffer(world)

        local tag = world:entity()
        local entity = world:entity()
        command_buffer.add(entity, tag)

        CHECK(not world:has(entity, tag))

        command_buffer.flush()

        CHECK(world:has(entity, tag))
    end

    do CASE "set"
        local world = jecs.world()
        local command_buffer = make_command_buffer(world)

        local component = world:component()
        local entity = world:entity()
        command_buffer.set(entity, component, 50)

        CHECK(not world:has(entity, component))

        command_buffer.flush()

        CHECK(world:get(entity, component) == 50)
    end

    do CASE "remove"
        local world = jecs.world()
        local command_buffer = make_command_buffer(world)

        local component = world:component()
        local entity = world:entity()
        world:set(entity, component, 50)
        command_buffer.remove(entity, component)

        CHECK(world:has(entity, component))

        command_buffer.flush()

        CHECK(not world:has(entity, component))
    end

    do CASE "delete"
        local world = jecs.world()
        local command_buffer = make_command_buffer(world)

        local entity = world:entity()
        command_buffer.delete(entity)

        command_buffer.flush()

        CHECK(not world:contains(entity))
    end

    do CASE "peek"
        local world = jecs.world()
        local command_buffer = make_command_buffer(world)

        local tag1 = world:entity()
        local entity1 = world:entity()
        command_buffer.add(entity1, tag1)

        local component1 = world:component()
        local entity2 = world:entity()
        command_buffer.set(entity2, component1, 50)

        local tag2 = world:component()
        local entity3 = world:entity()
        command_buffer.remove(entity3, tag2)

        local entity4 = world:component()
        command_buffer.delete(entity4)

        local commands = command_buffer.peek()
        CHECK(table.find(commands.add[tag1], entity1))
        CHECK(commands.set[component1][entity2] == 50)
        CHECK(table.find(commands.remove[tag2], entity3))
        CHECK(table.find(commands.delete, entity4))
        CHECK(commands.deletion_lookup[entity4] == true)
    end
end)

-- https://github.com/Ukendio/jecs/blob/main/test/addons/observers.luau
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
TEST("hammer.add_observers()", function()
    local world = add_observers(jecs.world())

	do CASE "Should work even if set after the component has been used"
		local A = world:component()

		world:set(world:entity(), A, 2)
		local ran = false
		world:added(A, function()
			ran = true
		end)

		local entity = world:entity()
		world:set(entity, A, 3)

		CHECK(ran)
	end

	do CASE "Should not override hook"
		local A = world:component()

		local count = 1
		local function counter()
			count += 1
		end

		world:set(A, jecs.OnAdd, counter)
		world:added(A, counter)
		world:set(world:entity(), A, false)
		CHECK(count == (1 + 2))
		world:set(world:entity(), A, false)

		CHECK(count == (1 + (2 * 2)))
	end

	do CASE "Ensure ordering between signals and observers"
		local A = world:component()
		local B = world:component()

		local count = 1
		local function counter()
			count += 1
		end

		world:observer(world:query(A, B), counter)

		world:added(A, counter)
		world:added(A, counter)

		local e = world:entity()
		world:add(e, A)
		CHECK(count == 3)

		world:add(e, B)
		CHECK(count == 4)
	end

	do CASE "Rematch entities in observers"
		local A = world:component()

		local count = 1
		local function counter()
			count += 1
		end

		world:observer(world:query(A), counter)

		local e = world:entity()
		world:set(e, A, false)
		CHECK(count == 2)
		world:remove(e, A)
		CHECK(count == 2)
		world:set(e, A, false)
		CHECK(count == 3)
		world:set(e, A, false)
		CHECK(count == 4)
	end

	do CASE "Don't report changed components in monitor"
		local A = world:component()
		local count = 1
		local function counter()
			count += 1
		end

		world:monitor(world:query(A), counter)

		local e = world:entity()
		world:set(e, A, false)
		CHECK(count == 2)
		world:remove(e, A)
		CHECK(count == 3)
		world:set(e, A, false)
		CHECK(count == 4)
		world:set(e, A, false)
		CHECK(count == 4)
	end

	do CASE "Call off pairs"
		local A = world:component()

		local callcount = 1
		world:added(A, function(entity)
			callcount += 1
		end)
		world:added(A, function(entity)
			callcount += 1
		end)

		local e = world:entity()
		local e2 = world:entity()

		world:add(e2, jecs.pair(A, e))
		world:add(e, jecs.pair(A, e2))
		CHECK(callcount == 1 + 2 * 2)
	end
end)

FINISH()
-- stylua: ignore end
