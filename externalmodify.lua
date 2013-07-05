--Handle node drops to be compatible with the Technic node drops
local itemDrop = minetest.get_modpath("item_drop")

if itemDrop then
	local code = "local tool = digger:get_wielded_item():get_name()\n"..
			"if(tool:find('superheat') ~= nil)then\n"..
			"output = minetest.get_craft_result({method='cooking', items={name}})\n"..
			"if(not output.item:is_empty())then name = output.item:get_name()end\n"..
			"end\n"
	local readfile = io.open(itemDrop.."/init.lua", "r")
	local newfile = ""
	local numlines = 9
	for line in readfile:lines() do
		newfile = newfile..line.."\n"
		if(line:find("minetest.handle_node_drops") ~= nil) then
			while(numlines > 0) do
				line = readfile:read("*l")
				newfile = newfile..line.."\n"
				numlines = numlines - 1
			end
			if(line:find("end") ~= nil) then
				line = readfile:read("*l")
				if(line:find("digger:get_wielded_item()") == nil) then
					newfile = newfile..code
				end
				newfile = newfile..line.."\n"
			end
		end
		
	end
	io.close()
	local file = io.open(itemDrop.."/init.lua", "w")
	file:write(newfile)
	io.flush()
	io.close()
	
else
if enable_item_pickup then
--Credit to Pilzadam Minitest Game mode for item pickup and drop
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.setting_getbool("enable_damage") then
			local pos = player:getpos()
			pos.y = pos.y+0.7
			local inv = player:get_inventory()
			
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 0.7)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
						inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
						if object:get_luaentity().itemstring ~= "" then
							minetest.sound_play("item_drop_pickup", {
								to_player = player:get_player_name(),
								gain = 0.4,
							})
						end
						object:get_luaentity().itemstring = ""
						object:remove()
					end
				end
			end
			
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1.5)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if object:get_luaentity().collect then
						if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
							local pos1 = pos
							pos1.y = pos1.y+0.2
							local pos2 = object:getpos()
							local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
							vec.x = vec.x*2
							vec.y = vec.y*2
							vec.z = vec.z*2
							object:setvelocity(vec)
							object:get_luaentity().physical_state = false
							object:get_luaentity().flying = false
							object:get_luaentity().object:set_properties({
								physical = false,
								collisionbox = {0,0,0, 0,0,0},
							})
							
							minetest.after(1, function(args)
								local lua = object:get_luaentity()
								if object == nil or lua == nil or lua.itemstring == nil then
									return
								end
								if inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
									inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
									if object:get_luaentity().itemstring ~= "" then
										minetest.sound_play("item_drop_pickup", {
											to_player = player:get_player_name(),
											gain = 0.4,
										})
									end
									object:get_luaentity().itemstring = ""
									object:remove()
								else
									object:setvelocity({x=0,y=0,z=0})
									object:get_luaentity().physical_state = true
									object:get_luaentity().object:set_properties({
										physical = true,
										collisionbox = {-0.17,-0.17,-0.17, 0.17,0.17,0.17},
									})
								end
							end, {player, object})
							
						end
					end
				end
			end
		end
	end
end)
end
local function drop_items(pos, itemcount, itemname)
	for i=1,itemcount do
		local obj = minetest.add_item(pos, itemname)
		if obj ~= nil then
			obj:get_luaentity().collect = true
			local x = math.random(1, 5)
			if math.random(1,2) == 1 then
				x = -x
			end
			local z = math.random(1, 5)
			if math.random(1,2) == 1 then
				z = -z
			end
			obj:setvelocity({x=1/x, y=obj:getvelocity().y, z=1/z})
			
			-- FIXME this doesnt work for deactiveted objects
			if minetest.setting_get("remove_items") and tonumber(minetest.setting_get("remove_items")) then
				minetest.after(tonumber(minetest.setting_get("remove_items")), function(obj)
					obj:remove()
				end, obj)
			end
		end
	end
end
function minetest.handle_node_drops(pos, drops, digger)
	local itemcount = 0
	local itemname = ""
	for _,item in ipairs(drops) do
		if type(item) == "string" then
			itemcount = 1
			itemname = item
		else
			itemcount = item:get_count()
			itemname = item:get_name()
		end
		local tool = digger:get_wielded_item():get_name()
		if(tool:find('superheat') ~= nil)then
			output = minetest.get_craft_result({method='cooking', items={itemname}})
			if(not output.item:is_empty())then itemname = output.item:get_name() end
		end
		if(enable_item_drop) then
			drop_items(pos, itemcount, itemname)
		else
			if(digger:get_player_name() ~= nil and digger:get_player_name() ~= "") then
				if(digger:get_inventory():room_for_item("main", itemname.." "..itemcount) == true) then
					digger:get_inventory():add_item("main", itemname.." "..itemcount)
				else
					drop_items(pos, itemcount, itemname)
				end
			else
				drop_items(pos, itemcount, itemname)
			end
		end
	end
end
end