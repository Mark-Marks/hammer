--!strict
local hammer = require("../lib")
local jecs = require("@pkg/jecs")
local signal = require("./signal")
local testing = zune.testing

testing.describe("hammer.collect", function()
    testing.test("Collects values and iterates over them in order", function()
        local sig: signal.Identity<number> = signal()
        local iter = hammer.collect(sig)
        local should = {}

        for idx = 1, 100 do
            local n = math.random(1, 2000)
            should[idx] = n
            sig:fire(n)
        end

        for idx, n in iter do
            testing.expectEqual(should[idx], n)
        end
    end)
end)

testing.describe("hammer.ref", function()
    testing.test("References of two same keys match", function()
        local world = jecs.world()
        local ref = hammer.ref(world, true)

        local a = ref(1234)
        local b = ref(1234)
        testing.expectEqual(a, b)
    end)

    testing.test("Is able to find previously created references", function()
        local world = jecs.world()
        local ref = hammer.ref(world, true)

        local a = ref(1234)
        local b = ref.find(1234)
        testing.expectEqual(a, b)
    end)

    testing.test("Is unable to find not created references", function()
        local world = jecs.world()
        local ref = hammer.ref(world, true)

        local a = ref.find(1234)
        testing.expect(a).toBeNil()
    end)

    testing.test(
        "Is able to delete references and not be able to reference them while keeping the entity alive",
        function()
            local world = jecs.world()
            local ref = hammer.ref(world, true)

            local a = ref(1234)
            local b = ref.delete(1234)
            testing.expectEqual(a, b)
            local c = ref.find(1234)
            testing.expect(c).toBeNil()
        end
    )

    testing.test(
        "Multiple instances of ref for the same world cache",
        function()
            local world = jecs.world()
            local ref_a = hammer.ref(world)
            local ref_b = hammer.ref(world)
            testing.expectEqual(ref_a, ref_b)
        end
    )

    testing.test("Is able to skip ref instance caching", function()
        local world = jecs.world()
        local ref_a = hammer.ref(world)
        local ref_b = hammer.ref(world, true)
        testing.expect(ref_a).never.toBe(ref_b)
    end)

    testing.test("Stress test", function()
        local world = jecs.world()
        local ref = hammer.ref(world)

        local expected = {}
        for i = 1, 1_000_000 do
            local key = (i * math.random(2, 2 ^ 8 - 1)) % 5
            local entity = ref(key)
            if i % math.random(2, 4) == 0 then
                ref.delete(key)
                expected[key] = 0
            else
                expected[key] = entity :: any
            end
        end

        for key, entity in expected do
            if entity == 0 then
                testing.expect(ref.find(key)).never.toBe(entity)
            else
                testing.expect(ref(key)).toBe(entity)
                testing.expect(ref.find(key)).never.toBeNil()
            end
        end
    end)
end)

testing.describe("hammer.command_buffer", function()
    testing.test("Add", function()
        local world = jecs.world()
        local command_buffer = hammer.command_buffer(world)

        local tag = world:component()
        local entity = world:entity()

        command_buffer.add(entity, tag)
        testing.expect(world:has(entity, tag)).toBeFalsy()
        command_buffer.flush()
        testing.expect(world:has(entity, tag)).toBeTruthy()
    end)

    testing.test("Set", function()
        local world = jecs.world()
        local command_buffer = hammer.command_buffer(world)

        local component = world:component()
        local entity = world:entity()

        command_buffer.set(entity, component, 50)
        testing.expect(world:has(entity, component)).toBeFalsy()
        command_buffer.flush()
        testing.expect(world:get(entity, component)).toBe(50)
    end)

    testing.test("Remove", function()
        local world = jecs.world()
        local command_buffer = hammer.command_buffer(world)

        local component = world:component()
        local entity = world:entity()

        world:set(entity, component, 50)
        command_buffer.remove(entity, component)
        testing.expect(world:has(entity, component)).toBeTruthy()
        command_buffer.flush()
        testing.expect(world:has(entity, component)).toBeFalsy()
    end)

    testing.test("Delete", function()
        local world = jecs.world()
        local command_buffer = hammer.command_buffer(world)

        local entity = world:entity()
        command_buffer.delete(entity)
        testing.expect(world:contains(entity)).toBeTruthy()
        command_buffer.flush()
        testing.expect(world:contains(entity)).toBeFalsy()
    end)

    testing.test("Peek", function()
        local world = jecs.world()
        local command_buffer = hammer.command_buffer(world)

        local A = world:component()
        local entity_a = world:entity()
        command_buffer.add(entity_a, A)

        local B = world:component()
        local entity_b = world:entity()
        command_buffer.set(entity_b, B, 50)

        local C = world:component()
        local entity_c = world:entity()
        command_buffer.remove(entity_c, C)

        local entity_d = world:entity()
        command_buffer.delete(entity_d)

        local commands = command_buffer.peek()
        testing.expect(table.find(commands.add[A], entity_a)).never.toBeNil()
        testing.expect(commands.set[B][entity_b]).toBe(50)
        testing.expect(table.find(commands.remove[C], entity_c)).never.toBeNil()
        testing.expect(table.find(commands.delete, entity_d)).never.toBeNil()
        testing.expect(commands.deletion_lookup[entity_d]).toBeTruthy()
    end)

    local function make_components(world: jecs.World, n: number): { jecs.Id }
        local components = table.create(n) :: { jecs.Id }
        for i = 1, n do
            components[i] = world:component()
        end
        return components
    end

    local function make_entities(world: jecs.World, n: number): { jecs.Entity }
        local entities = table.create(n) :: { jecs.Entity }
        for i = 1, n do
            entities[i] = world:entity()
        end
        return entities
    end

    -- Trial of Champions
    testing.test("Stress test", function()
        local world = jecs.world()
        local components = make_components(world, 12)
        local entities = make_entities(world, 10_000)
        local commands = hammer.command_buffer(world)

        local deleted = {}
        for _ = 1, 3 do
            local should_add = {}
            local should_set = {}
            local should_remove = {}
            local should_delete = {}

            for _, component in components do
                should_add[component] = {}
                should_set[component] = {}
                should_remove[component] = {}
            end

            for _, entity in entities do
                if deleted[entity] then
                    continue
                end

                for _, component in components do
                    if world:has(entity, component) then
                        local case = math.random(1, 2)
                        if case == 1 then
                            local value = math.random(1, 2 ^ 24 - 1)
                            commands.set(entity, component, value)
                            should_set[component][entity] = value
                        elseif case == 2 then
                            commands.remove(entity, component)
                            should_remove[component][entity] = true
                        end
                        continue
                    end

                    local case = math.random(1, 2)
                    if case == 1 then
                        local value = math.random(1, 2 ^ 24 - 1)
                        commands.set(entity, component, value)
                        should_set[component][entity] = value
                    elseif case == 2 then
                        commands.add(entity, component)
                        should_add[component][entity] = true
                    end
                end

                if math.random(1, 16) == 8 then
                    commands.delete(entity)
                    deleted[entity] = true
                    should_delete[entity] = true
                end
            end

            local stored = commands.peek()

            for component, storage in should_add do
                local buf_storage = stored.add[component]
                for entity in storage do
                    testing
                        .expect(table.find(buf_storage, entity)).never
                        .toBeNil()
                end
            end

            for component, storage in should_set do
                local buf_storage = stored.set[component]
                for entity, value in storage do
                    testing.expect(buf_storage[entity]).toBe(value)
                end
            end

            for component, storage in should_remove do
                local buf_storage = stored.remove[component]
                for entity in storage do
                    testing
                        .expect(table.find(buf_storage, entity)).never
                        .toBeNil()
                end
            end

            local buf_del_lookup = stored.deletion_lookup
            for entity in should_delete do
                testing.expect(buf_del_lookup[entity]).toBeTruthy()
            end

            commands.flush()
        end
    end)
end)

testing.describe("hammer.interval", function()
    testing.test("Throttles correctly", function()
        local task = zune.task
        local interval = hammer.interval(1 / 10)

        local n = 0
        for _ = 1, 1_000 do
            if interval() then
                n += 1
            end
        end

        task.wait(1 / 10)

        if interval() then
            n += 1
        end

        testing.expect(n).toBe(1)
    end)
end)

testing.describe("hammer.is_a", function()
    local pair = jecs.pair

    testing.test("Propagates to nested entities", function()
        local world = jecs.world()
        local IsA = hammer.is_a(world)

        local Weapon = world:component()
        local Sword = world:component()
        world:add(Sword, pair(IsA, Weapon))
        local Longsword = world:component()
        world:add(Longsword, pair(IsA, Sword))

        testing.expect(world:has(Longsword, pair(IsA, Weapon))).toBeTruthy()
    end)

    testing.test("Works as a prefab", function()
        local world = jecs.world()
        local IsA = hammer.is_a(world)

        local Defense = world:component() :: jecs.Id<number>
        local Health = world:component() :: jecs.Id<number>
        local Damage = world:component() :: jecs.Id<number>
        local Spaceship = world:component()
        world:set(Spaceship, Defense, 100)
        world:set(Spaceship, Health, 50)
        world:set(Spaceship, Damage, 10)

        local spaceship = world:entity()
        world:add(spaceship, pair(IsA, Spaceship))

        testing.expect(world:get(spaceship, Defense)).toBe(100)
        testing.expect(world:get(spaceship, Health)).toBe(50)
        testing.expect(world:get(spaceship, Damage)).toBe(10)
    end)

    testing.test("Changes don't propagate", function()
        local world = jecs.world()
        local IsA = hammer.is_a(world)

        local Fruit = world:component()
        local Heals = world:component() :: jecs.Id<number>

        local apple = world:entity()
        world:add(apple, pair(IsA, Fruit))
        world:set(apple, Heals, 10)

        -- 🪶
        local pear = world:entity()
        world:add(pear, pair(IsA, apple))

        testing.expect(world:get(pear, Heals)).toBe(10)

        world:set(apple, Heals, 25)

        testing.expect(world:get(pear, Heals)).never.toBe(25)
    end)
end)
