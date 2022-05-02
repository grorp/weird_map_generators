minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.register_alias_force("mapgen_singlenode", "air")

local vmanip_data

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
                if y == -2 then
                    data[area:index(x, y, z)] = stone
                else
                    data[area:index(x, y, z)] = (x % 2 == 0 and z % 2 == 0) and stone or air
                end
            end
        end
    end

    vmanip:set_data(data)
    vmanip:write_to_map()
end)
