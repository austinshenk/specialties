--File Manipulating
specialties.writeXP = function(player, specialty, amount)
	local file = io.open(minetest.get_worldpath().."/"..player.."_"..specialty, "w")
	file:write(tostring(amount))
	file:close()
end
specialties.readXP = function(player, specialty)
	local file = io.open(minetest.get_worldpath().."/"..player.."_"..specialty, "r")
	if file == nil then
		specialties.writeXP(player, specialty, 0)
		return 0
	end
	local xp = file:read("*number")
	file:close()
	return xp
end

--Table Modification
specialties.changeXP = function(player, specialty, amount)
	local current = specialties.players[player][specialty]
	if current+amount >= 0 then
		specialties.players[player][specialty] = current+amount
		print(specialties.players[player][specialty])
		return true
	else
		return false
	end
end

--XP Updates
specialties.updateXP = function(player)--Called every 10 seconds
	for skill,_ in pairs(specialties.skills) do
		specialties.writeXP(player, skill, specialties.players[player][skill])
	end
end