function list_table(v, values)
	local output = {""}
	local i = 1
	local max_num = values and 5 or 10
	local num = max_num
	for k,v in pairs(v) do
		if num <= 0 then
			i = i +1
			num = max_num
			output[i] = ""
		end
		num = num -1
		if values then
			output[i] = output[i] ..k .."=" ..tostring(v) ..","
		else
			output[i] = output[i] ..k ..","
		end
	end
	
	print("---")
	for k,v in pairs(output) do
		print(v)
	end
end

local VERSION = "0.1.0"
local LEVEL_MAX = 10
local MIN_LEVEL_PICK_FIREFLY = 5

local CHANCE_ATTACK_THUNDER = 0.5
local CHANCE_FERTILIZE_BONUS = 0.5
local CHANCE_HARVEST_BONUS = 0.5
local CHANCE_ATTACKED_BEE = 0.5

local RECIPE_DISTANCE = 5
--bait moles
--change charakter

--TODO move this stuff to global
local DSMMO_ACTIONS = {
	["BUILD"] = 100,
	["CHOP"] = 60,
	["MINE"] = 50,
	["DIG"] = 40,
	["REPAIR"] = 25,
	["ATTACKED"] = 15,
	["ATTACK"] = 30,
	["PLANT"] = 30,
	["FERTILIZE"] = 25,
	["EAT"] = 40,
	["PICK"] = 80
}
local COLOR_GOLD = {1, 0.8, 0, 1}
local COLOR_RED = {1, 0, 0, 1}

local _touchstone_index = nil

local PRESETS = {
	["CHOP"] = {2,5,10,12,2,9,14,16}, -- from scripts/stategraphs/SGwilson.lua:1707 to :1778
	["MINE"] = {7,9,14} -- from scripts/stategraphs/SGwilson.lua:1828 to :1846
}

--TODO move this stuff to global
local RECIPES = {
	["deerclops_eyeball"] = {
		name="A new life",
		num=4,
		recipe={goose_feather=2, bearger_fur=2},
		min_level={EAT=5},
		chance={"EAT",2},
		fu=function(player, center)
			player.components.inventory:DropEverything(false, false)
			player.components.DsMMO._player_original_position = player:GetPosition()
			player.components.DsMMO:penalty()
			player.components.DsMMO._player_backup[player.userid] = {
				map = player.player_classified.MapExplorer:RecordMap(),
				dsmmo = player.components.DsMMO:OnSave()
			}
				
			
			TheWorld:PushEvent("ms_playerdespawnanddelete", player)
			
		end
	},
	["molehill"] = {
		name="Secret of moles",
		num=3,
		recipe={rocks=1, flint=1, nitre=1, goldnugget=1, marble=1, moonrocknugget=1, bluegem=1, redgem=1, yellowgem=1, orangegem=1, purplegem=1},
		min_level={DIG=1},
		chance={"DIG",1},
		fu=function(player, center)
			spawn_to_target("mole", center)
			if get_success(player, "DIG", 0.05) then
				spawn_to_target("mole", center)
				spawn_to_target("mole", center)
				spawn_to_target("mole", center)
				alert(player, "That was lucky", COLOR_GOLD)
			end
		end
	},
	["skeleton_player"] = {
		name="Rerevival",
		num=4,
		recipe={nightmarefuel=1, marble=2, amulet=1},
		min_level={BUILD=8},
		chance={"BUILD",0.8},
		fu=function(player, center)
			local k
			local v
			for local_k,local_v in pairs(player.components.touchstonetracker.used) do
				k = local_k -- I dont like lua... Syntax seems to me that you cant use non-locals in for..in
				v = local_v
				if math.random() < 0.2 then --this is a very cheaty randomisation - but it also saves performance
					break
				end
			end
			
			local touchstone = _touchstone_index[k]
			
			if touchstone then
				center:Remove()
				player.components.touchstonetracker.used[k] = nil
				local used = {}
				for k, v in pairs(player.components.touchstonetracker.used) do
					table.insert(used, k)
				end
				player.player_classified:SetUsedTouchStones(used)
				
				touchstone._enablelights:set(true)
				touchstone:PushEvent("enablelightsdirty", true) -- needed on singleplayer
				
				local player_pos = player:GetPosition()
				player.components.DsMMO._player_original_position = player_pos
				player:DoTaskInTime(1, function(player)
					player.Physics:Teleport(touchstone.Transform:GetWorldPosition())
					player.components.health:SetInvincible(true)
					
					player.entity:Hide()
					touchstone.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_raise")
					
					player:PushEvent("ghostvision", true) -- needed on singleplayer
					player.player_classified.isghostmode:set(true)
				end)
				
				player:DoTaskInTime(4, function()
					player.components.health:SetInvincible(false)
					print("taskintime")
					player.Transform:SetPosition(player_pos.x, player_pos.y, player_pos.z)
					player.entity:Show()
					player.player_classified.isghostmode:set(false)
					player:PushEvent("ghostvision", false)
					player.components.DsMMO._player_original_position = nil
				end)
			end
		end
	},
	["twigs"] = {
		name="Get the longest Twig",
		num=4,
		recipe={bluegem=1, redgem=1, log=2},
		min_level={BUILD=3},
		chance={"BUILD",1.2},
		fu=function(player, center)
			spawn_to_target("sapling", center)
			center:Remove()
		end
	},
	["cutgrass"] = {
		name="Green Grass",
		num=4,
		recipe={bluegem=1, redgem=1, spoiled_food=2},
		min_level={BUILD=4},
		chance={"BUILD",1.2},
		fu=function(player, center)
			spawn_to_target("grass", center)
			center:Remove()
		end
	},
	["berries"] = {
		name="Red",
		num=4,
		recipe={bluegem=1, redgem=1, spoiled_food=2},
		min_level={PICK=3},
		chance={"PLANT",1.2},
		fu=function(player, center)
			spawn_to_target("berrybush", center)
			center:Remove()
		end
	},
	["berries_juicy"] = {
		name="Red and juicy",
		num=4,
		recipe={bluegem=1, redgem=1, spoiled_food=2},
		min_level={PICK=4},
		chance={"PLANT",1.2},
		fu=function(player, center)
			spawn_to_target("berrybush2", center)
			center:Remove()
		end
	}
}

--TODO move this stuff to global
RECIP_LEVEL_INDEX = {}
print("creating level up string")
for k,v in pairs(RECIPES) do
	for k2,v2 in pairs(v.min_level) do
		if not RECIP_LEVEL_INDEX[k2] then
			RECIP_LEVEL_INDEX[k2] = {}
		end
		if not RECIP_LEVEL_INDEX[k2][v2] then
			RECIP_LEVEL_INDEX[k2][v2] = {}
		end
		table.insert(RECIP_LEVEL_INDEX[k2][v2], v)
	end
end

function spawn_to_target(n, target)
	SpawnPrefab(n).Transform:SetPosition(target.Transform:GetWorldPosition())
end
function is_fullMoon()
	return TheWorld.state.moonphase == "full" --GetClock():GetMoonPhase()
end
function get_chance(base_r, lvl)
	local chance = base_r * (lvl / LEVEL_MAX)
	
	return is_fullMoon() and chance + 0.5 or chance
end
function get_success(player, action, base_r)
	local chance = get_chance(base_r, player.components.DsMMO.level[action])
	return math.random() < chance
end
function alert(player, msg, color)
	player.components.talker:Say(msg, 10, nil, nil, nil, color)
	--self.player.components.talker:Say(output, 20, nil, nil, nil, {1,1,1,1})
end
function get_level(xp)
	return math.floor(math.log(xp) / math.log(2))
end
function get_max_exp(action, lvl)
	return DSMMO_ACTIONS[action] * math.pow(2, lvl)
end

function onPerformaction(player, data)
	local action = player.bufferedaction or data.action
	local self = player.components.DsMMO
		--spawn_to_target("ground_chunks_breaking", player)
		--spawn_to_target("campfirefire", player)
		--spawn_to_target("collapse_small", player)
		--player:DoTaskInTime(1, function(inst) spawn_to_target("ground_chunks_breaking", player) end)
		--player:DoTaskInTime(2, function(inst) spawn_to_target("campfirefire", player) end)
		--player:DoTaskInTime(3, function(inst) spawn_to_target("collapse_small", player) end)
		--player:DoTaskInTime(4, function(inst) spawn_to_target("impact", player) end)
		--player:DoTaskInTime(3, function(inst) spawn_to_target("shadow_bishop_fx", player) end)
	if action then
		local actionId = action.action.id
		
		if actionId == "EAT" then
			if player.components.hunger.current <player.components.hunger.max then
				player.components.DsMMO:get_experience(actionId)
			end
		elseif self.level[actionId] then
			player.components.DsMMO:get_experience(actionId)
			
			if actionId == "ATTACK" then
				if get_success(player, "ATTACK", CHANCE_ATTACK_THUNDER) then
					spawn_to_target("lightning", action.target)
					target.components.combat:GetAttacked(action.target, TUNING.SPEAR_DAMAGE)
				end
			elseif actionId == "FERTILIZE" then
				local crop = action.target.components.crop
				if crop and not crop:IsReadyForHarvest() and get_success(player, "FERTILIZE", CHANCE_FERTILIZE_BONUS) then
					crop:Fertilize(SpawnPrefab("guano"), player)
					spawn_to_target("collapse_small", player)
				end
			end
		elseif actionId == "HARVEST" then
			local crop = action.target.components.crop
			if crop ~= nil then
				if get_success(player, "PLANT", CHANCE_HARVEST_BONUS) then
					player.components.inventory:GiveItem(SpawnPrefab(crop.product_prefab))
					spawn_to_target("collapse_small", player)
				end
			end
		elseif actionId == "HAUNT" then
			if self.level["PICK"] >= MIN_LEVEL_PICK_FIREFLY then
				local targetN = action.target.prefab
				if targetN == "flower_evil" then
					spawn_to_target("collapse_small", player)
					spawn_to_target("fireflies", action.target)
					action.target:Remove()
				end
			end
		else
			print(actionId)
		end
		
		
	end
end
function onAttacked(player, data)
	player.components.DsMMO:get_experience("ATTACKED")
	
	if get_success(player, "ATTACKED", CHANCE_ATTACKED_BEE) then
		local bee = SpawnPrefab("bee")
		bee.persists = false
		bee.Transform:SetPosition(player.Transform:GetWorldPosition())
		bee.components.combat:SetTarget(data.attacker)
	end
end
function onStartStarving(player)
	if player.components.combat ~= nil and player.components.combat.damagemultiplier ~= nil then
		player.default_damagemultiplier = player.components.combat.damagemultiplier
	else
		player.default_damagemultiplier = 1
	end
	local self = player.components.DsMMO
	local new_damagemultiplier = self.level["EAT"]
	
	if new_damagemultiplier > player.default_damagemultiplier then
		player.components.combat.damagemultiplier = self.level["EAT"]
		alert(player, "I feel mighty", COLOR_GOLD)
	end
end
function onStopStarving(player)
	if player.default_damagemultiplier and player.components.combat and player.components.combat.damagemultiplier then
		player.components.combat.damagemultiplier = player.default_damagemultiplier
	end
end
function onbecameghost(player)
	player.components.DsMMO:penalty()
end


function onExp_update(player, action)
	local xp = player.components.DsMMO.exp[action]
	
	if(player.components.DsMMO.level ~= get_level(xp)) then
		alert(player, action .." was not in sync with server (" ..player.components.DsMMO.level[action] .."/=" ..get_level(xp) ..")", COLOR_RED)
	end
	player.components.DsMMO.level = get_level(xp)
end

local _DsMMO = nil
local DsMMO = Class(function(self, player)
	_DsMMO = self
	self.player = player
	self._player_original_position = nil --if not nil, this will be saved when the player logs out unexpectedly
	self:log_msg("init")
	--print(TheNet:IsDedicated())
	--print(TheNet:GetIsServer())
	
	if not TheWorld.ismastersim then
		self:log_msg("is client - stop")
		--self.last_state = nil
		--self:create_array();
		--player:ListenForEvent("performaction", onPerformactionDirty)
		--player:ListenForEvent("newstate", function(player, state)
				--if state.statename ~= "idle" then
					--player.components.DsMMO.last_state = state.statename
				--end
			--end)
		return
	end

	
	local main_lookat = ACTIONS.LOOKAT.fn
	ACTIONS.LOOKAT.fn = function(act)
		if not act.target or not act.doer.components.DsMMO:init_recipe(act.target) then
			main_lookat(act)
		end
	end
	--OnNewSpawn
	self:create_array() --this is a waste of performance - But I havent found a way to detect a newly created character
	player:ListenForEvent("ms_becameghost", onbecameghost)
	player:ListenForEvent("attacked", onAttacked)
	player:ListenForEvent("performaction", onPerformaction)
	player:ListenForEvent("startstarving", onStartStarving)
	player:ListenForEvent("stopstarving", onStopStarving)
end)


function DsMMO:log_msg(msg)
	print("[DsMMO/" ..self.player.name .."] " ..msg)
end
function DsMMO:add_indexVars(touchtstone_index, player_backup)
	self._touchstone_index = touchtstone_index
	self._player_backup = player_backup
end

function DsMMO:get_experience(action)
	local player = self.player
	local lvl = self.level[action]
	if lvl < LEVEL_MAX then
		local xp = self.exp[action] + 1
		self.exp[action] = xp;
		
		if xp > get_max_exp(action,lvl) then
			lvl = lvl+1
			self.level[action] = lvl
	
			alert(player, self:newLevelString(action, lvl), COLOR_RED)
			player.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
			
			
			if PRESETS[action] then
				self:update_actionSpeed(action)
			end
		end
	end
end
function DsMMO:newLevelString(action, lvl)
	local base = action .."-level: " ..lvl .." !\n"
	
	if lvl < LEVEL_MAX then
		base = base ..self:calc_mssing_xp(action) .." exp until lvl " ..(lvl+1) .."\n"
	end
	
	if RECIP_LEVEL_INDEX[action][lvl] then
		for i,v in ipairs(RECIP_LEVEL_INDEX[action][lvl]) do
			base = base .."\nYou are now able to do the ritual: " ..v.name
		end
	end
	
	return base
end
function DsMMO:update_actionSpeed(action)
	--Unfortunately, there is no real way to increase the Action-animation-speed
	-- So we override the timetables as gracefully as we can and hope that
	-- the source code wont get any major change
	local lvl = self.level[action]/LEVEL_MAX
	local action = self.player.sg.sg.states[string.lower(action)]
	local t = PRESETS[action]
	
	for k,v in pairs(action.timeline) do
		action.timeline[k] = TimeEvent((t[k] - ((t[k]-1)*lvl)) * FRAMES, v.fn)
	end
end

function DsMMO:init_recipe(target)
	local recipe_data = RECIPES[target.prefab]
	if recipe_data then
		local min_levels = recipe_data.min_level
		for k,v in pairs(min_levels) do
			if self.level[k] < v then
				self:log_msg(target.prefab .."-recipe: " ..k .."-level(" ..self.level[k] .."<" ..v ..") is not high enough")
				alert(self.player, "I don't feel prepared...", COLOR_RED)
				return true
			end
		end
		if recipe_data.check and recipe_data.check(self.player, target) then
			alert(self.player, "I just can't...", COLOR_RED)
		else
			self:check_recipe(target, recipe_data.recipe, recipe_data.num, recipe_data.chance, recipe_data.fu)
		end
		return true
	else
		print(target.prefab)
	end
	return false
end
function DsMMO:check_recipe(center, recipe, ings_needed_sum, chance, fn)
	local collection = {}
	local pos = center:GetPosition()
	local near = TheSim:FindEntities(pos.x, pos.y, pos.z, 5)
	
	local ingredients = {}
	for k,v in pairs(recipe) do
		ingredients[k] = v
	end
	
	for k,v in pairs(near) do
		local itemN = v.prefab
		
		local ing_num = ingredients[itemN]
		if v.parent == nil and ings_needed_sum > 0 and ing_num and ing_num>0 then
			self:log_msg("Recipe: Found " ..itemN)
			table.insert(collection, v)
			ingredients[itemN] = ing_num - 1
			ings_needed_sum = ings_needed_sum - 1
			if ings_needed_sum <= 0 then
				for k2,v2 in pairs(collection) do
					--spawn_to_target("campfirefire", v2)
					local fire = SpawnPrefab("campfirefire")
					fire.Transform:SetPosition(v2.Transform:GetWorldPosition())
					fire:DoTaskInTime(2, function(inst) inst:Remove() end)
					v2:Remove()
				end
					self.player:DoTaskInTime(2, function(player) 
						spawn_to_target("collapse_big", center)
						
						if get_success(player, chance[1], chance[2]) then
							spawn_to_target("lightning", center)
							fn(player, center)
						else 
							alert(player, "It failed...", COLOR_RED)
						end
					end)
				return
			end
		end
	end
	
	alert(self.player, "What am I missing..?", COLOR_RED)
end

function DsMMO:OnLoad(data)
	if data.dsmmo_level then
		if data.dsmmo_version == VERSION then
			self.exp = data.dsmmo_exp
			self.level = data.dsmmo_level
		else
			for k,v in pairs(DSMMO_ACTIONS) do
				--TODO: for now we transfer each variable seperately to make sure future versions will be compatible
				if data.dsmmo_level[k] then
					self.exp[k] = data.dsmmo_exp[k]
					self.level[k] = data.dsmmo_level[k]
					if PRESETS[k] then
						self:update_actionSpeed(k)
					end
				end
			end
		end
		if data._player_original_position then
			self.player.Physics:Teleport(data._player_original_position.x, data._player_original_position.y, data._player_original_position.z)
		end
	end
end
function DsMMO:OnSave()
	local data = {
			["dsmmo_exp"] = self.exp,
			["dsmmo_level"] = self.level,
			["dsmmo_version"] = VERSION
		}
	
	if self._player_original_position then
		self:log_msg("Emergency save of player position - Player left while ritual was in progress")
		data["_player_original_position"] = self._player_original_position
	end
	return data
end
function DsMMO:create_array()
	local player = self.player
	local guid = player.GUID
	self.exp = {}
	self.level = {}
	
	for k,v in pairs(DSMMO_ACTIONS) do
		self.exp[k] = 0
		self.level[k] = 0
	end
end
function DsMMO:penalty()
	local player = self.player
	for k,v in pairs(DSMMO_ACTIONS) do
		local xp = math.floor(self.exp[k] / 2)
		self.exp[k] = xp
		if xp > 0 then
			self.level[k] = get_level(xp)
		end
	end
end
function DsMMO:set_level(action, lvl)
	if DSMMO_ACTIONS[action] then
		self.exp[action] = get_max_exp(action, lvl-1)
		self.level[action] = lvl-1
		self:get_experience(action)
		return true
	else
		return false
	end
end

function add_spaces(str, size)
	local space = ""
	for i = string.len(str)+1, size, 1 do
		space = space .."_"
	end
	
	return space
end

function DsMMO:calc_mssing_xp(action, lvl)
	return get_max_exp(action, self.level[action]) - self.exp[action] +1
end

function DsMMO:run_command(cmd, arg)
	local output = "Something went wrong"
	local dur = 5
	
	if arg == nil then
		dur = 20
		for k,v in pairs(self.level) do
			local xp = self:calc_mssing_xp(k)
			
			output = output ..k ..":" ..add_spaces(k, 10) ..add_spaces(tostring(xp), 4) ..add_spaces(tostring(v+1), 2) ..xp .." exp until lvl " ..(v+1) .."\n"
		end
		
	elseif arg == "rituals" then
		output = "You know about the following rituals:\n"
		dur = 15
		local level = self.level
		for k_action,v_action in pairs(RECIP_LEVEL_INDEX) do
			local lvl = level[k_action]
			for k_lvl,v_lvl in pairs(v_action) do
				if lvl >= k_lvl then
					for i,v in ipairs(v_lvl) do
						output = output .."\n" ..v.name .."(" ..(get_chance(v.chance[2], level[v.chance[1]])*100) .."%)"
					end
				end
			end
		end
	elseif arg == "help" then
		output = "TODO"
	else
		arg = string.upper(arg)
		if DSMMO_ACTIONS[arg] then
			local lvl = self.level[arg]
			local xp = self:calc_mssing_xp(arg)
			
			output = arg ..": " ..xp .." exp --> lvl " ..(lvl+1)
		end
	end
	
	self.player.components.talker:Say(output, dur, nil, nil, nil, COLOR_RED)
end

return DsMMO