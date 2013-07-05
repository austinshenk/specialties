local function updateCondenser(meta)
	local inv = meta:get_inventory()
	local needed = specialties.transferAmount[inv:get_stack("slot", 1):get_name()]
	if needed == nil then needed = 0 end
	local energy = meta:get_int("energy")
	local barX = energy/needed
	if barX > 1 then barX = 1 end
	local formspec = "size[8,9.5]"..
		"list[current_player;main;0,5.5;8,4;]"..
		"list[context;main;0,1;8,4;]"..
		"list[context;slot;0,0;1,1;]"..
		"label[7.5,0;"..needed.."]"..
		"label[1.1,0;"..energy.."]"..
		"image[1.5,0;"..(barX*6)..",1;specialties_condenser_meter.png]"
	return formspec
end
local function Condense(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local slot = inv:get_stack("slot", 1)
	local slotName = slot:get_name()
	if slot:is_empty() or specialties.transferAmount[slotName] == nil then return end
	local index = 0
	for i=1,32,1 do
		local name = inv:get_stack("main", i):get_name()
		if name ~= "" and name ~= slotName and specialties.transferAmount[name] ~= nil then
			index = i
			i = 33
		end
	end
	local oldEnergy = meta:get_int("energy")
	local newEnergy = oldEnergy
	local needed = specialties.transferAmount[slotName]
	if index ~= 0 then
		local stack = inv:get_stack("main", index)
		newEnergy = newEnergy+specialties.transferAmount[stack:get_name()]
		inv:set_stack("main", index, stack:get_name().." "..stack:get_count()-1)
	end
	if newEnergy >= needed then
		local count = math.floor(newEnergy/needed)
		local stackMax = slot:get_stack_max()
		local numStacks = math.floor(count/stackMax)
		local leftoverStack = count - (stackMax*numStacks)
		for i=1,numStacks,1 do
			if inv:room_for_item("main", slotName.." "..stackMax) then
				inv:add_item("main", slotName.." "..stackMax)
				newEnergy = newEnergy - (needed*stackMax)
			end
		end
		if leftoverStack > 0 then
			if inv:room_for_item("main", slotName.." "..leftoverStack) then
				inv:add_item("main", slotName.." "..leftoverStack)
				newEnergy = newEnergy - (needed*leftoverStack)
			end
		end
	end
	if oldEnergy ~= newEnergy then
		meta:set_int("energy", newEnergy)
		meta:set_string("formspec", updateCondenser(meta))
	end
end

minetest.register_abm({
	nodenames = "specialties:condenser",
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		Condense(pos)
	end,
})

minetest.register_craft({
	output = "specialties:condenser",
	recipe = {
	{"default:obsidian","default:obsidian","default:obsidian"},
	{"default:mese_crystal","default:diamondblock","default:mese_crystal"},
	{"default:obsidian","default:obsidian","default:obsidian"}
	}
})

minetest.register_node("specialties:condenser", {
	description = "Condenser",
	tiles = {"specialties_condenser_top.png","specialties_condenser_bottom.png",
			"specialties_condenser_side.png","specialties_condenser_side.png",
			"specialties_condenser_front.png","specialties_condenser_back.png"},
	is_ground_content = true,
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("formspec", updateCondenser(meta))
		inv:set_size("main", 32)
		inv:set_size("slot", 1)
		meta:set_int("energy", 0)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "slot" then 
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", updateCondenser(meta))
		end
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "slot" then 
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", updateCondenser(meta))
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "slot" or from_list == "slot" then 
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", updateCondenser(meta))
		end
	end,
})