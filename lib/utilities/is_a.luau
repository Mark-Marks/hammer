--!strict
--!optimize 2
--https://gist.github.com/Ukendio/0d839428324bd10b7e4a16568cb856c8
local jecs = require("../../jecs")

local cache = {}

--- Allows for transitive inheritance relationships. In essence, this means that you can express an entity as being equivalent to another, without the reverse needing to be true.
--- Read more at https://www.flecs.dev/flecs/md_docs_2Relationships.html#the-isa-relationship
local function construct(world: jecs.World): jecs.Id
    local hit = cache[world]
    if hit then
        return hit
    end

    local IsA = world:entity()
    cache[world] = IsA

    world:added(IsA, @native function(component: any, pair: any)
        local is = jecs.pair_second(world, pair)
        assert(component ~= is, "Circular IsA inheritance")

        local is_tag = jecs.is_tag(world, is)
        local added
        if is_tag then
            function added(entity)
                world:add(entity, is)
            end
        else
            function added(entity, _, value)
                world:set(entity, is, value)
            end
        end
        world:added(component, added)

        if not is_tag then
            world:changed(component, function(entity, _, value)
                world:set(entity, is, value)
            end)
        end

        local source_record = jecs.record(world, is) :: jecs.Record
        local source_archetype = source_record.archetype
        if not source_archetype then
            return
        end
        local source_types = source_archetype.types
        local source_columns = source_archetype.columns_map
        local source_row = source_record.row

        local target_record = jecs.record(world, component) :: jecs.Record
        local target_archetype = target_record.archetype
        if not target_archetype then
            return
        end
        local target_columns = target_archetype.columns_map

        local n_types = #source_types
        local tags = table.create(n_types)
        local components_idx = 0
        local components = table.create(n_types)
        local values = table.create(n_types)

        for _, id in source_types do
            if jecs.is_tag(world, id) then
                table.insert(tags, id)
            else
                local metadata = source_columns[id][source_row]
                if not target_columns[id] then
                    components_idx += 1
                    components[components_idx], values[components_idx] =
                        id, metadata
                end
            end
        end

        if components_idx > 0 then
            table.move(tags, 1, #tags, components_idx + 1, components)
        end
        jecs.bulk_insert(world, component, components :: any, values)
    end)

    return IsA
end

return construct
