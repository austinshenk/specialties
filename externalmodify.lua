--Handle node drops to be compatible with the Technic node drops
local technic = minetest.get_modpath("technic")
local code = "local tool = digger:get_wielded_item():get_name()\n"..
			"if(tool:find('superheat') ~= nil)then\n"..
			"output = minetest.get_craft_result({method='cooking', items={name}})\n"..
			"if(output.item ~= nil)then name = output.item:get_name()end\n"..
			"end\n"
if(technic ~= "" and technic ~= nil) then
	local readfile = io.open(technic.."/item_drop.lua", "r")
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
	local file = io.open(technic.."/item_drop.lua", "w")
	file:write(newfile)
	io.flush()
	io.close()
	
else
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
			if(output.item ~= nil)then itemname = output.item:get_name()end
		end
		if(enable_item_drop) then
			for i=1,itemcount do
				local obj = minetest.env:add_item(pos, itemname)
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
		else
			if(digger:get_player_name() ~= nil and digger:get_player_name() ~= "") then
				digger:get_inventory():add_item("main", itemname.." "..itemcount)
			end
		end
	end
end
end

local function create_soil(pos, inv, p)
	if pos == nil then
		return false
	end
	local node = minetest.env:get_node(pos)
	local name = node.name
	local above = minetest.env:get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if name == "default:dirt" or name == "default:dirt_with_grass" then
		if above.name == "air" then
			node.name = "farming:soil"
			minetest.env:set_node(pos, node)
			if inv and p and name == "default:dirt_with_grass" then
				for name,rarity in pairs(farming.seeds) do
					if math.random(1, rarity-p) == 1 then
						inv:add_item("main", ItemStack(name))
					end
				end
			end
			return true
		end
	end
	return false
end

local function nodeIsValid(node)
	local nums = {"1","2","3","4","5","6","7","8","9"}
	local lastChar = node.name:sub(#node.name)
	local isNum = false
	for _,num in pairs(nums) do
		if(lastChar == num) then isNum = true end
	end
	return (node.name:find("farming") ~= nil) and (node.name:find("soil") == nil) and (not isNum)
end

--Create and store the tools with new additions
for name, def in pairs(minetest.registered_tools) do
	local colonpos = name:find(":")
	local modname = name:sub(0,colonpos-1)
	for skill, _ in pairs(specialties.skills) do
		for _,special in pairs(specialties.skills[skill].specials) do
			if(specialties.skills[skill].tool ~= "") then
				if(name:find(specialties.skills[skill].tool) ~= nil and special ~= {}) then
					local toolname = "specialties"..name:sub(colonpos).."_"..special.name
					local newdef = def
					newdef.description = def.description.." "..special.description
					newdef.inventory_image = def.inventory_image.."^specialties_"..special.name..".png"
					if(name:find(":hoe") ~= nil) then
						newdef.on_use = function(itemstack, user, pointed_thing)
							if(pointed_thing.type == "nothing" or pointed_thing.type == "object") then return itemstack end
							if create_soil(pointed_thing.under, user:get_inventory(), 0) then
								itemstack:add_wear(65535/specialties.hoewear[name:sub(name:find("_")+1)])
								return itemstack
							end
							local pos = {}
							pos.x = (pointed_thing.above.x+pointed_thing.under.x)/2
							pos.y = (pointed_thing.above.y+pointed_thing.under.y)/2
							pos.z = (pointed_thing.above.z+pointed_thing.under.z)/2
							pos.y = pos.y-.5
							local node = minetest.env:get_node(pos)
							if(nodeIsValid(node)) then
								minetest.env:dig_node(pos)
								if(not enable_item_drop) then
									minetest.handle_node_drops(user:getpos(), minetest.get_node_drops(node.name, toolname), user)
								end
								if(node.name:find("weed") == nil) then
									minetest.env:set_node(pos, {name = node.name.."_1"})
								end
								itemstack:add_wear(65535/specialties.hoewear[name:sub(name:find("_")+1)])
								return itemstack
							end
						end
					end
					specialties.healAmount[toolname] = specialties.healAmount[name]
					local uptool = specialties.upgradeTree[name]
					if(uptool ~= nil) then
						local upgrade = uptool:sub(uptool:find(":"), #uptool)
						specialties.upgradeTree[toolname] = "specialties"..upgrade.."_"..special.name
					end
					specialties.tools[toolname] = newdef
				end
			end
		end
	end
end
--Register all of the tools
for name, def in pairs(specialties.tools) do
	minetest.register_tool(name, def)
end