function check_player(playerN)
	for k,v in pairs(GLOBAL.AllPlayers) do
		if v.name == playerN and v.components and v.components.DsMMO then
			return v
		end
	end
	print("player not found")
	return nil
end




local _touchstones_index = {} --will be filled in AddGamePostInit
local _player_backup = {}


if GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer() then
	GLOBAL.global("dsmmo_reset")
	GLOBAL.dsmmo_reset = function(playerN)
		local player = check_player(playerN)
		if player ~= nil then
			player.components.DsMMO:create_array()
			print("Levels from " ..player.name .." have been reset")
		end
	end

	GLOBAL.global("dsmmo_set")
	GLOBAL.dsmmo_set = function(playerN, action, lvl)
		action = string.upper(action)
		local player = check_player(playerN)
		if player ~= nil then
			if player.components.DsMMO:set_level(action, lvl) then
				print(action .."-level from " ..player.name .." has been set to " ..lvl)
			else
				print("A DsMMO-skill named " ..action .." does not exist")
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
		
		if GetModConfigData("start_message", GLOBAL.KnownModIndex:GetModActualName("DsMMO")) then
			inst:DoTaskInTime(5, function(player)
				GLOBAL.Networking_SystemMessage("----- Running DsMMO " ..GLOBAL.KnownModIndex:GetModInfo(GLOBAL.KnownModIndex:GetModActualName("DsMMO")).version .." -----")
				GLOBAL.Networking_SystemMessage("For more graphical features you can download the client-version:")
				GLOBAL.Networking_SystemMessage("http://bit.ly/dsmmo_client")
			end)
		end
	end)
	
	AddGamePostInit(function()
		-- I dont like doing a huge loop like this. But I dont see any other way of getting a touchstone by ID
		local t = _touchstones_index -- dont know if that actually speeds anything up in lua
		print("[DsMMO] indexing touchstones")
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
				player.components.DsMMO:run_command(GLOBAL.unpack(cmd))
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



function prepare_client_communication(player)
	local self = player.components.DsMMO
	
	if self then
		self:prepare_client()
	end
end
function init_client_communication(player)
	local self = player.components.DsMMO
	
	if self then
		self:init_client()
	end
end

function use_cannibalism_skill(player, action, heal)
	local self = player.components.DsMMO
	
	if self then
		self:use_cannibalism_skill(action, heal)
	end
end

AddModRPCHandler("DsMMO", "client_enabled", prepare_client_communication)
AddModRPCHandler("DsMMO", "client_is_setup", init_client_communication)
AddModRPCHandler("DsMMO", "use_cannibalism_skill", use_cannibalism_skill)
