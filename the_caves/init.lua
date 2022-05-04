-- https://ephenationopengl.blogspot.com/2012/05/making-caves-from-simplex-noise.html

-- https://github.com/larspensjo/ephenation-server/tree/75e2e84791f446b1e0c38d2d83abaa7c8966bd74
-- (Z, not Y, seems to be up.)

local simplex = dofile(minetest.get_modpath("the_caves") .. "/simplex_noise.lua")

minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.register_alias_force("mapgen_singlenode", "air")

local vmanip_data

local function noise(x, y, z)
    return (
        simplex.Simplex3D(x * 0.0025, y * 0.005, z * 0.0025) +
        simplex.Simplex3D(x * 0.005, y * 0.01, z * 0.005)
    ) / 2
end

minetest.register_on_generated(function(pos_min, pos_max)
    local vmanip, vmanip_pos_min, vmanip_pos_max = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new{MinEdge = vmanip_pos_min, MaxEdge = vmanip_pos_max}
    vmanip_data = vmanip:get_data(vmanip_data)
    local data = vmanip_data

    local air = minetest.get_content_id("air")
    local stone = minetest.get_content_id("basenodes:stone")

    for x = pos_min.x, pos_max.x do
        for y = pos_min.y, pos_max.y do
            for z = pos_min.z, pos_max.z do
                local index = area:index(x, y, z)

                local noise_1 = noise(x, y, z)
                if noise_1 > -0.05 and noise_1 < 0.05 then
                    local noise_2 = noise(-x, -y, -z)
                    if noise_2 > -0.05 and noise_2 < 0.05 then
                        data[index] = air
                    else
                        data[index] = stone
                    end
                else
                    data[index] = stone
                end
            end
        end
    end

    vmanip:set_data(data)
    vmanip:write_to_map()
end)
