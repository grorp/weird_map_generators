minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.register_alias_force("mapgen_singlenode", "air")

local vm_data

minetest.register_on_generated(function(pos_min, pos_max)
    local vm, vm_pos_min, vm_pos_max = minetest.get_mapgen_object("voxelmanip")
    local vm_area = VoxelArea:new{MinEdge = vm_pos_min, MaxEdge = vm_pos_max}
    vm_data = vm:get_data(vm_data)

    local air = minetest.get_content_id("air")
    local stone = minetest.get_content_id("mapgen_stone")

    for x = pos_min.x, pos_max.x do
        for y = pos_min.y, pos_max.y do
            for z = pos_min.z, pos_max.z do
                local index = vm_area:index(x, y, z)

                if y == -2 then
                    vm_data[index] = stone
                elseif x % 2 == 0 and z % 2 == 0 then
                    vm_data[index] = stone
                else
                    vm_data[index] = air
                end
            end
        end
    end

    vm:set_data(vm_data)
    vm:write_to_map()
end)
