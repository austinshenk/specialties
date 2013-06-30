--File Manipulating
specialties.writeXP = function(name)
	local file = io.open(minetest.get_worldpath().."/"..name.."_XP", "w")
	for skill,_ in pairs(specialties.players[name]) do
		file:write(skill.." "..tostring(specialties.players[name][skill]).."\n")
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
	local current = specialties.players[name][specialty]
	if current+amount >= 0 then
		specialties.players[name][specialty] = current+amount
		return true
	else
		return false
	end
end