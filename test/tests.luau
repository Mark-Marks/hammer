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

FINISH()
-- stylua: ignore end
