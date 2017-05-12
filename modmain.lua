local TUNING = GLOBAL.TUNING

GLOBAL.CHEATS_ENABLED = true

GLOBAL.require( 'debugkeys' )


local _touchstones_index = {} --will be filled in AddGamePostInit
AddPlayerPostInit(function(player)
	player:AddComponent("DsMMO")
	player.components.DsMMO:add_touchstoneIndex(_touchstones_index)
	--GLOBAL.AddUserCommand("test", {
		--prettyname = function(command) return "Test" end,
		--desc = function() return "Test" end,
		--permission = "USER",
		--params = {},
		--emote = true,
		--slash = true,
		--usermenu = false,
		--servermenu = false,
		--vote = false,
		--serverfn = function(params, caller)
			--local player = GLOBAL.UserToPlayer(caller.userid)
			--if player ~= nil then
				--player.components.talker:Say("chat", nil, nil, nil, nil, {1,1,1,1})
			--end
		--end
	--})
end)

function check_player(player)
	if player and player.components and player.components.DsMMO then
		return true
	else
		print("player not found")
		return false
	end
end

GLOBAL.global("dsmmo_reset")
GLOBAL.dsmmo_reset = function(player)
	if check_player(player) then
		player.components.DsMMO:create_array()
		print(player.name .." levels have been reset")
	end
end

GLOBAL.global("dsmmo_set")
GLOBAL.dsmmo_set = function(player, action, lvl)
	if check_player(player) then
		if player.components.DsMMO:set_level(action, lvl) then
			print(player.name .." " ..action .."-level have been set to " ..lvl)
		else
			print("This action-skill does not seem to exist")
		end
	end
end



AddGamePostInit(function()
--AddPrefabPostInit("world", function(world)
--AddPrefabPostInit("forest_network", function(world)
	if GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer() then
		-- I dont like doing a huge loop like this. But I dont see any other way of getting a touchstone by ID
		local t = _touchstones_index -- dont know if that actually speeds anything up in lua
		print("(DsMMO) indexing touchstones")
		for k,v in pairs(GLOBAL.Ents) do
			if v.GetTouchStoneID then
				t[v:GetTouchStoneID()] = v
			end
		end
		
		
		local Old_Networking_Say = GLOBAL.Networking_Say
		GLOBAL.Networking_Say = function(guid, userid, name, prefab, msg, colour, whisper, isemote, ...)
			local player = GLOBAL.Ents[guid]
			
			if player == nil then
				return
			end
			
			local cmd = string.split(string.lower(msg), " ")
		
			if cmd[1] == "#dsmmo" then
				player.components.DsMMO:run_command(cmd[1], cmd[2])
			else
				Old_Networking_Say(guid, userid, name, prefab, msg, colour, whisper, isemote, ...)
			end
		end
	end

end)
