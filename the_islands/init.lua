-- https://github.com/minetest/minetest/blob/ec9f1575121e3b064b919bca7efddfa8b0fc4e65/src/mapgen/mg_ore.cpp#L368
-- https://github.com/minetest/minetest/blob/ec9f1575121e3b064b919bca7efddfa8b0fc4e65/doc/lua_api.txt#L3942 (not very informative)

-- https://github.com/minetest/minetest_game/blob/38307da22a6c74b45f021ad627b21b73672dfe14/mods/default/mapgen.lua#L536

-- https://stackoverflow.com/questions/17770555/how-to-check-if-a-point-is-inside-an-ellipsoid

minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.register_alias_force("mapgen_singlenode", "air")

local vm_data

minetest.register_on_generated(function(pos_min, pos_max, block_seed)
    local vm, vm_pos_min, vm_pos_max = minetest.get_mapgen_object("voxelmanip")
    local vm_area = VoxelArea:new{MinEdge = vm_pos_min, MaxEdge = vm_pos_max}
    vm_data = vm:get_data(vm_data)

    local stone = minetest.get_content_id("mapgen_stone")

    local rng = PcgRandom(block_seed + 1913488162)

    local volume = (pos_max.x - pos_min.x + 1) * (pos_max.y - pos_min.y + 1) * (pos_max.z - pos_min.z + 1)
    local island_volume = 32 * 32 * 32
    local island_count = volume / island_volume

    for i = 1, island_count do
        local v = rng:next(8, 16)
        local size = vector.new(v, rng:next(4, 8), v)

        local island_min = vector.new(
            rng:next(pos_min.x, pos_max.x - size.x + 1),
            rng:next(pos_min.y, pos_max.y - size.y + 1),
            rng:next(pos_min.z, pos_max.z - size.z + 1)
        )
        local island_max = island_min + size

        local island_origin = vector.new(
            island_min.x + size.x / 2,
            island_min.y + size.y,
            island_min.z + size.z / 2
        )
        local radius = vector.new(
            size.x / 2,
            size.y,
            size.z / 2
        )

        local noise_map = minetest.get_perlin_map(
            {
                octaves = 1,
                scale = 0.4,
                seed = 2126473205,
                spread = size * 0.5,
            },
            size + vector.new(1, 1, 1)
        )
        local noise_map_data = noise_map:get_3d_map_flat(island_min)
        local noise_map_area = VoxelArea:new{MinEdge = island_min, MaxEdge = island_max}

        for x = island_min.x, island_max.x do
            for y = island_min.y, island_max.y do
                for z = island_min.z, island_max.z do
                    local distance = (
                        ((x - island_origin.x) / radius.x) ^ 2 +
                        ((y - island_origin.y) / radius.y) ^ 2 +
                        ((z - island_origin.z) / radius.z) ^ 2
                    )
                    local noise = noise_map_data[noise_map_area:index(x, y, z)]
                    if distance + noise <= 1 then
                        vm_data[vm_area:index(x, y, z)] = stone
                    end
                end
            end
        end
    end

    vm:set_data(vm_data)
    vm:write_to_map()
end)
