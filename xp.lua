--File Manipulating
specialties.writeXP = function(name)
	local file = io.open(minetest.get_worldpath().."/"..name.."_XP", "w")
	for skill,num in pairs(specialties.players[name].skills) do
		file:write(skill.." "..tostring(num).."\n")
	end
	file:close()
end
specialties.readXP = function(name, specialty)
	local file = io.open(minetest.get_worldpath().."/"..name.."_XP", "r")
	if file == nil then
		specialties.writeXP(name)
		local empty = {}
		for skill,_ in pairs(specialties.skills) do
			empty[skill] = 0
		end
		return empty
	end
	local xp = {}
	local line = file:read("*l")
	while line ~= nil do
		local params = line:split(" ")
		xp[params[1]] = tonumber(params[2])
		line = file:read("*l")
	end
	file:close()
	return xp
end

--Table Modification
specialties.changeXP = function(name, specialty, amount)
	local newAmount = specialties.players[name].skills[specialty]+amount
	if newAmount >= 0 then
		specialties.players[name].skills[specialty] = newAmount
		local player = minetest.get_player_by_name(name)
		local id = specialties.players[name].menu[specialty]
		local hudItem = player:hud_get(id)
		hudItem.text = tostring(newAmount)
		hudItem.offset = {x=100, y=0}
		hudItem.alignment = {x=1, y=0}
		player:hud_remove(id)
		specialties.players[name].menu[specialty] = player:hud_add(hudItem)
		return true
	else
		return false
	end
end