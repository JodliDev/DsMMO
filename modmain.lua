GLOBAL.CHEATS_ENABLED = true

GLOBAL.require( 'debugkeys' )


function check_player(player)
	if player and player.components and player.components.DsMMO then
		return true
	else
		print("player not found")
		return false
	end
end




local _touchstones_index = {} --will be filled in AddGamePostInit
local _player_backup = {}


if GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer() then
	GLOBAL.global("dsmmo_reset")
	GLOBAL.dsmmo_reset = function(player)
	if check_player(player) then
			player.components.DsMMO:create_array()
			print("Levels from " ..player.name .." have been reset")
		end
	end

	GLOBAL.global("dsmmo_set")
	GLOBAL.dsmmo_set = function(player, action, lvl)
		action = string.upper(action)
		if check_player(player) then
			if player.components.DsMMO:set_level(action, lvl) then
				print(player.name .." " ..action .."-level has been set to " ..lvl)
			else
				print("This action-skill does not seem to exist")
			end
		end
	end
	
	
	AddPlayerPostInit(function(player)--we need this to make sure OnLoad is called
		player:AddComponent("DsMMO")
		player.components.DsMMO:add_indexVars(_touchstones_index, _player_backup)
	end)
	AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
		inst:ListenForEvent("ms_playerjoined", function(self, player)
			local backup = _player_backup[player.userid]
			if backup then
				player:DoTaskInTime(1, function(player)
					player.components.DsMMO:OnLoad(backup.dsmmo)
					player.player_classified.MapExplorer:LearnRecordedMap(backup.map)
					_player_backup[player.userid] = nil
				end)
			end
		end)
	end)
	
	AddGamePostInit(function()
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
				if not whisper then
					player.components.talker:Say("DsMMO-commands have to be whispered!")
					return
				end
				player.components.DsMMO:run_command(cmd[1], cmd[2])
			else
				Old_Networking_Say(guid, userid, name, prefab, msg, colour, whisper, isemote, ...)
			end
		end
		
		local main_lookat = GLOBAL.ACTIONS.LOOKAT.fn
		GLOBAL.ACTIONS.LOOKAT.fn = function(act)
			if not act.target or not act.doer.components.DsMMO:init_recipe(act.target) then
				main_lookat(act)
			end
		end
	end)
end


--AddPrefabPostInit("forest_network", init_server)
--AddPrefabPostInit("cave_network", init_server)