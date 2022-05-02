local simplex = dofile(minetest.get_modpath("the_caves") .. "/simplex_noise.lua")

minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.register_alias_force("mapgen_singlenode", "air")

local vmanip_data

local function noise(x, y, z)
    return simplex.Simplex3D(x * 0.005, y * 0.01, z * 0.005) / 2 + 0.5
end

minetest.register_on_generated(function()
    local vmanip, pos_min, pos_max = minetest.get_mapgen_object("voxelmanip")
    vmanip_data = vmanip:get_data(vmanip_data)
    local data = vmanip_data
    local area = VoxelArea:new{MinEdge = pos_min, MaxEdge = pos_max}

    local air = minetest.get_content_id("air")
    local stone = minetest.get_content_id("basenodes:stone")

    for x = pos_min.x, pos_max.x do
        for y = pos_min.y, pos_max.y do
            for z = pos_min.z, pos_max.z do
                local noise_1 = noise(x, y, z)
                if noise_1 > 0.45 and noise_1 < 0.55 then
                    local noise_2 = noise(-x, -y, -z)
                    if noise_2 > 0.45 and noise_2 < 0.55 then
                        data[area:index(x, y, z)] = air
                    else
                        data[area:index(x, y, z)] = stone
                    end
                else
                    data[area:index(x, y, z)] = stone
                end
            end
        end
    end

    vmanip:set_data(data)
    vmanip:write_to_map()
end)
