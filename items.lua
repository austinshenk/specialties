--Credit to minetest farming mod
local function create_soil(user, pointed_thing)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return false
	end
	if pt.type ~= "node" then
		return false
	end
	
	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.get_node(p)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return false
	end
	if not minetest.registered_nodes[above.name] then
		return false
	end
	
	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return false
	end
	
	-- check if pointing at dirt
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return false
	end
	
	-- turn the node into soil, wear out item and play sound
	minetest.set_node(pt.under, {name="farming:soil"})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})
	return true
end

local function nodeIsPlant(node)
	local lastChar = node.name:sub(#node.name)
	local isNum = false
	for num=1,9,1 do
		if(lastChar == tostring(num)) then isNum = true end
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
					local newdef = {}
					for k,v in pairs(def) do
						newdef[k] = v
					end
					newdef.description = def.description.." "..special.description
					newdef.inventory_image = def.inventory_image.."^specialties_"..special.name..".png"
					if(name:find(":hoe") ~= nil) then
						newdef.on_use = function(itemstack, user, pointed_thing)
							if pointed_thing.type == "nothing" or pointed_thing.type == "object" or pointed_thing.above == nil then return itemstack end
							if create_soil(user, pointed_thing) then
								itemstack:add_wear(65535/specialties.hoewear[name:sub(name:find("_")+1)])
								return itemstack
							end
							local pos = pointed_thing.under
							pos.y = pos.y+1
							local node = minetest.get_node(pos)
							if(nodeIsPlant(node)) then
								minetest.dig_node(pos)
								if(not enable_item_drop) then
									minetest.handle_node_drops(user:getpos(), minetest.get_node_drops(node.name, toolname), user)
								end
								if(node.name:find("weed") == nil) then
									minetest.set_node(pos, {name = node.name.."_1"})
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
for toolname, def in pairs(specialties.tools) do
	minetest.register_tool(toolname, def)
end