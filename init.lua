--run Files
local modpath=minetest.get_modpath("specialties")
dofile(modpath.."/config.lua")
dofile(modpath.."/tables.lua")
dofile(modpath.."/externalmodify.lua")
dofile(modpath.."/xp.lua")

--variable used for time keeping for updating xp
time = 0

local get_specialInfo = function(player, specialty)
    local formspec = "size[8,8]" -- size of the formspec page
	.."button[0,0;2,0.5;main;Back]" -- back to main inventory
	.."button[2,0;2,0.5;miner;Miner]"
	.."button[2,.75;2,0.5;lumberjack;Lumberjack]"
	.."button[2,1.5;2,0.5;digger;Digger]"
	.."button[2,2.25;2,0.5;farmer;Farmer]"
	.."button[2,3;2,0.5;builder;Builder]"
	.."list[current_player;main;0,4;8,4;]"
	if(specialty ~= "") then
		formspec = formspec.."label[4,0;XP: "..specialties.players[player:get_player_name()][specialty].."]"..specialties.skills[specialty].menu
    end
	return formspec
end

minetest.register_on_leaveplayer(function(player)--Called if on a server, if single player than it isn't called
	specialties.updateXP(player:get_player_name())
end)

--Initial Files Created
minetest.register_on_newplayer(function(player)
	for skill,_ in pairs(specialties.skills) do
		specialties.writeXP(player:get_player_name(), skill, 0)
	end
end)

--Initial XP Extraction
--optimizes the amount of calls to files
minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player,"specialties","Specialties")
	player:get_inventory():set_size("pick", 1)
	player:get_inventory():set_size("axe", 1)
	player:get_inventory():set_size("shovel", 1)
	player:get_inventory():set_size("hoe", 1)
	player:get_inventory():set_size("buildrefill", 1)
	player:get_inventory():set_size("buildtrash", 1)
	name = player:get_player_name()
	specialties.players[name] = {}
	for skill,_ in pairs(specialties.skills) do
		specialties.players[name][skill] = specialties.readXP(name, skill)
	end
end)

--Skill Events
local function healTool(player, list, specialty, cost)
	tool = player:get_inventory():get_list(list)[1]
	if (tool:get_name():find(":"..list) ~= nil and tool:get_wear() ~= 0 and specialties.healAmount[tool:get_name()] ~= nil)then
		if (specialties.changeXP(player:get_player_name(), specialty, -cost)) then
			tool:add_wear(-specialties.healAmount[tool:get_name()])
			player:get_inventory():set_stack(list, 1, tool)
		end
	end
	inventory_plus.set_inventory_formspec(player, get_specialInfo(player, specialty))
end
local function upgradeTool(player, list, specialty, cost)
	tool = player:get_inventory():get_list(list)[1]
	if(tool:get_name():find(":"..list) ~= nil and specialties.upgradeTree[tool:get_name()] ~= nil) then
		if (specialties.changeXP(player:get_player_name(), specialty, -cost)) then
			player:get_inventory():set_stack(list, 1, specialties.upgradeTree[tool:get_name()])
		end
	end
	inventory_plus.set_inventory_formspec(player, get_specialInfo(player, specialty))
end
local function addSpecial2Tool(player, skill, list, specialty, cost)
	local tool = player:get_inventory():get_list(list)[1]
	local toolname = tool:get_name()
	if(toolname:find("_"..skill) ~= nil) then return end
	if (specialties.changeXP(player:get_player_name(), specialty, -cost)) then
		local def = tool:get_definition()
		local colonpos = toolname:find(":")
		local modname = toolname:sub(0,colonpos-1)
		if(modname ~= "specialties") then toolname = "specialties"..toolname:sub(colonpos) end
		local name = toolname.."_"..skill
		player:get_inventory():set_stack(list, 1, name)
	end
	inventory_plus.set_inventory_formspec(player, get_specialInfo(player, specialty))
end
local function doTransfer(player, list, factor)
	
end

--GUI Events
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.specialties then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, ""))
		return
	end

	--MINER
	if fields.miner then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, "miner"))
		return
	end
	if fields.healpick then healTool(player, "pick", "miner", 100) end
	if fields.upgradepick then upgradeTool(player, "pick", "miner", 200) end
	if fields.superheatpick then addSpecial2Tool(player, "superheat", "pick", "miner", 500) end

	--LUMBERJACK
	if fields.lumberjack then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, "lumberjack"))
		return
	end
	if fields.healaxe then healTool(player, "axe", "lumberjack", 100) end
	if fields.upgradeaxe then upgradeTool(player, "axe", "lumberjack", 200) end
	if fields.superheataxe then addSpecial2Tool(player, "superheat", "axe", "lumberjack", 500) end

	--DIGGER
	if fields.digger then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, "digger"))
		return
	end
	if fields.healshovel then healTool(player, "shovel", "digger", 100) end
	if fields.upgradeshovel then upgradeTool(player, "shovel", "digger", 200) end
	if fields.superheatshovel then addSpecial2Tool(player, "superheat", "shovel", "digger", 500) end
	
	--FARMER
	if fields.farmer then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, "farmer"))
		return
	end
	if fields.healhoe then healTool(player, "hoe", "farmer", 100) end
	if fields.upgradehoe then upgradeTool(player, "hoe", "farmer", 200) end
	if fields.greenthumb then addSpecial2Tool(player, "greenthumb", "hoe", "farmer", 500) end
	
	--BUILDER
	if fields.builder then
		inventory_plus.set_inventory_formspec(player, get_specialInfo(player, "builder"))
		return
	end
	if fields.dorefill then doTransfer(player, "refill", 1) end
	if fields.dotrash then doTransfer(player, "trash", -1) end
end)


--XP Events
minetest.register_on_dignode(function(pos, oldnode, digger)
	if(digger == nil) then
		return
	end
	if(digger:get_wielded_item():is_empty())then
		return
	end
	local tool = digger:get_wielded_item():get_name()
	local name = digger:get_player_name()
	if(tool:find("pick") ~= nil)then
		specialties.changeXP(name, "miner", 1)
	end
	if(tool:find("axe") ~= nil)then
		specialties.changeXP(name, "lumberjack", 1)
	end
	if(tool:find("shovel") ~= nil)then
		specialties.changeXP(name, "digger", 1)
	end
	if(oldnode.name:find("farming") ~= nil) then
		specialties.changeXP(name, "farmer", 5)
	end
end)
minetest.register_on_placenode(function(pos, newnode, placer, oldnode)
	specialties.changeXP(placer:get_player_name(), "builder", 1)
end)
minetest.register_globalstep(function(dtime)
	if(time+dtime < 10) then
		time = time+dtime
	else
		time = 0
		for key in pairs(specialties.players)do
			specialties.updateXP(key)
		end
	end
end)