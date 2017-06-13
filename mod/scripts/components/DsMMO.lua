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

local VERSION = 6
local LEVEL_MAX = 10
local LEVEL_UP_RATE = 1.5
local RECIPE_DISTANCE = 5

local DSMMO_ACTIONS = {
	["CHOP"] = 100,
	["MINE"] = 50,
	["ATTACK"] = 70,
	["PLANT"] = 40, --and (partly) DEPLOY
	["BUILD"] = 70, --and REPAIR and HAMMER and (partly) DEPLOY
	["DIG"] = 40,
	["EAT"] = 50,
	["PICK"] = 30
}

local ACTION_SPEED_INCREASE = {
--be aware: Not all action have a simular named state!
	["CHOP"] = "chop", -- scripts/stategraphs/SGwilson.lua:1707 to :1778
	["MINE"] = "mine" -- scripts/stategraphs/SGwilson.lua:1828 to :1846
}

local RECIPES = {
	amulet = {
		name="Ritual of death",
		num=4,
		recipe={mandrake=2, nightmarefuel=2},
		min_level={"EAT",5},
		chance={"EAT",0.5},
		fu=function(player, center)
			local self = player.components.DsMMO
			self.level.EAT = 0
			self.exp.EAT = 0
			self._no_penalty = true
			player:PushEvent('death')
			center:Remove()
		end
	},
	deerclops_eyeball = {
		name="Ritual of a new life",
		num=7,
		recipe={goose_feather=2, bearger_fur=2, dragon_scales=1, fireflies=2},
		min_level={"EAT",8},
		chance={"EAT",2},
		fu=function(player, center)
			local self = player.components.DsMMO
			player.components.inventory:DropEverything(false, false)
			self._player_original_position = player:GetPosition()
			self._player_backup[player.userid] = {
				map = player.player_classified.MapExplorer:RecordMap(),
				dsmmo = player.components.DsMMO:OnSave()
			}
			self.level.EAT = 0
				
			TheWorld:PushEvent("ms_playerdespawnanddelete", player)
			center:Remove()
		end,
		check=function(player, center)
			return not TheWorld:HasTag("cave")
		end
	},
	
	molehill = {
		name="Ritual of mole infestation",
		num=3,
		recipe={rocks=1, flint=1, nitre=1, goldnugget=1, marble=1, moonrocknugget=1, bluegem=1, redgem=1, purplegem=1, yellowgem=1, orangegem=1, greengem=1},
		min_level={"DIG",2},
		chance={"DIG",1},
		fu=function(player, center)
			spawn_to_target("mole", center)
			if get_success(player, "DIG", 0.05) then
				spawn_to_target("mole", center)
				spawn_to_target("mole", center)
				spawn_to_target("mole", center)
				alert(player, "That was lucky")
			end
		end
	},
	shovel = {
		name="Ritual of mole attraction",
		num=4,
		recipe={houndstooth=2, log=2},
		min_level={"DIG",3},
		chance={"DIG",1.5},
		fu=function(player, center)
			local x,y,z = center.Transform:GetWorldPosition() 
			local ents = TheSim:FindEntities(x,y,z, 30, {'mole'}) 
			for i,v in ipairs(ents) do 
				v.Transform:SetPosition(x,y,z)  
			end
		end
	},
	pitchfork = {
		name="Ritual of roman streets",
		num=7,
		recipe={guano=3, rocks=3, boards=3, fireflies=1},
		min_level={"DIG",5},
		chance={"DIG",0.8},
		fu=function(player, center)
			local x, y = TheWorld.Map:GetTileCoordsAtPoint(center.Transform:GetWorldPosition())
			TheWorld.Map:SetTile(x, y, GROUND.ROAD)
			TheWorld.Map:RebuildLayer(GROUND.ROAD, x, y)
			
			TheWorld.Map:SetTile(x+1, y, GROUND.ROAD)
			TheWorld.Map:RebuildLayer(GROUND.ROAD, x+1, y)
			
			TheWorld.Map:SetTile(x-1, y, GROUND.ROAD)
			TheWorld.Map:RebuildLayer(GROUND.ROAD, x-1, y)
			center:Remove()
		end
	},
	
	coontail = {
		name="Ritual of pussy love",
		num=5,
		recipe={fireflies=2, meat=1, houndstooth=2},
		min_level={"BUILD",1},
		chance={"BUILD",0.5},
		fu=function(player, center)
			spawn_to_target("catcoonden", center)
			center:Remove()
		end,
		check=function(player, center)
			return not TheWorld:HasTag("cave")
		end
	},
	fish = {
		name="Ritual of splishy splashy",
		num=4,
		recipe={fireflies=2, froglegs=1, mosquitosack=1},
		min_level={"BUILD",2},
		chance={"BUILD",0.5},
		fu=function(player, center)
			if TheWorld:HasTag("cave") then
				spawn_to_target("pond_cave", center)
			elseif TheWorld.Map:GetTileAtPoint(center.Transform:GetWorldPosition()) == GROUND.MARSH then
				spawn_to_target("pond_mos", center)
			else
				spawn_to_target("pond", center)
			end
			
			center:Remove()
		end
	},
	cave_banana_cooked = {
		name="Ritual of dumb monkeys",
		num=5,
		recipe={fireflies=2, poop=2, purplegem=1},
		min_level={"BUILD",3},
		chance={"BUILD",0.5},
		fu=function(player, center)
			spawn_to_target("monkeybarrel", center)
			center:Remove()
		end,
		check=function(player, center)
			return TheWorld:HasTag("cave")
		end
	},
	walrus_camp = {
		name="Ritual of arctic fishing",
		num=6,
		recipe={cane=2, walrushat=2, fireflies=2},
		min_level={"BUILD",4},
		chance={"BUILD",0.5},
		fu=function(player, center)
			center:Remove()
		end
	},
	walrus_tusk = {
		name="Ritual of whalers feast",
		num=6,
		recipe={cane=2, walrushat=2, fireflies=2},
		min_level={"BUILD",5},
		chance={"BUILD",0.5},
		fu=function(player, center)
			spawn_to_target("walrus_camp", center)
			center:Remove()
		end,
		check=function(player, center)
			return not TheWorld:HasTag("cave")
		end
	},
	tallbirdegg = {
		name="Ritual of Saurons bird",
		num=5,
		recipe={beardhair=2, cutgrass=2, fireflies=1},
		min_level={"BUILD",6},
		chance={"BUILD",0.5},
		fu=function(player, center)
			spawn_to_target("tallbirdnest", center)
			center:Remove()
		end
	},
	firepit = {
		name="Ritual of the pigable flame",
		num=7,
		recipe={pigskin=4, dragon_scales=1, fireflies=2},
		min_level={"BUILD",7},
		chance={"BUILD",0.5},
		fu=function(player, center)
			spawn_to_target("pigtorch", center)
			center:Remove()
		end
	},
	skeleton_player = {
		name="Ritual of rerevival",
		num=4,
		recipe={nightmarefuel=1, marble=2, amulet=1},
		min_level={"BUILD",8},
		chance={"BUILD",0.8},
		check=function(player, center)
			for k, v in pairs(player.components.touchstonetracker.used) do
				return true
			end
			return false
		end,
		fu=function(player, center)
			local used = {}
			for k, v in pairs(player.components.touchstonetracker.used) do
				table.insert(used, k)
			end
			
			local removed_index = used[math.random(1, #used)]
			local touchstone = player.components.DsMMO._touchstone_index[removed_index]
			
			if touchstone then
				center:Remove()
				player.components.touchstonetracker.used[removed_index] = nil
				used[removed_index] = nil
				
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
					player.Transform:SetPosition(player_pos.x, player_pos.y, player_pos.z)
					player.entity:Show()
					player.player_classified.isghostmode:set(false)
					player:PushEvent("ghostvision", false)
					player.components.DsMMO._player_original_position = nil
				end)
			end
		end
	},
	campfire = {
		name="Ritual of homing flame",
		num=8,
		recipe={cutgrass=2, log=2, twigs=2, pinecone=2},
		min_level={"BUILD",10},
		chance={"BUILD",1},
		fu=function(player, center)
			local self = player.components.DsMMO
			local pos = self._teleport_to
			center.components.fueled:DoDelta(TUNING.LARGE_FUEL)
			player.Physics:Teleport(pos.x, pos.y, pos.z)
			self.level["BUILD"] = 9
			self.exp["BUILD"] = get_max_exp("BUILD", 8)+1
		end,
		check=function(player, center)
			return player.components.DsMMO._teleport_to ~= nil
		end
	},
	
	berries = {
		name="Ritual of redness",
		num=4,
		recipe={fireflies=1, spoiled_food=2},
		min_level={"PLANT",3},
		chance={"PLANT",1},
		fu=function(player, center)
			spawn_to_target("berrybush", center)
			center:Remove()
		end
	},
	berries_juicy = {
		name="Ritual of red juiciness",
		num=4,
		recipe={fireflies=1, spoiled_food=2},
		min_level={"PLANT",4},
		chance={"PLANT",1},
		fu=function(player, center)
			spawn_to_target("berrybush_juicy", center)
			center:Remove()
		end
	},
	cave_banana = {
		name="Ritual of bananana",
		num=3,
		recipe={spoiled_food=2, fireflies=1},
		min_level={"PLANT",6},
		chance={"PLANT",0.9},
		fu=function(player, center)
			spawn_to_target("cave_banana_tree", center)
			center:Remove()
		end,
		check=function(player, center)
			return TheWorld:HasTag("cave")
		end
	},
	livinglog = {
		name="Ritual of magic mushrooms",
		num=4,
		recipe={red_cap=1, blue_cap=1, green_cap=1, fireflies=1},
		min_level={"PLANT",8},
		chance={"PLANT",0.8},
		fu=function(player, center)
			local r = math.random(1,3)
			
			if r == 1 then
				spawn_to_target("blue_mushroom", center)
			elseif r == 2 then
				spawn_to_target("green_mushroom", center)
			else
				spawn_to_target("red_mushroom", center)
			end
			
			center:Remove()
		end
	},
	
	twigs = {
		name="Ritual of the longest Twig",
		num=3,
		recipe={log=2, fireflies=1},
		min_level={"PICK",2},
		chance={"PICK",1},
		fu=function(player, center)
			spawn_to_target("sapling", center)
			center:Remove()
		end
	},
	cutgrass = {
		name="Ritual of reggae dreams",
		num=3,
		recipe={spoiled_food=2, fireflies=1},
		min_level={"PICK",3},
		chance={"PICK",0.9},
		fu=function(player, center)
			spawn_to_target("grass", center)
			center:Remove()
		end
	},
	lightbulb = {
		name="Ritual of shiny balls",
		num=3,
		recipe={twigs=2, fireflies=1},
		min_level={"PICK",5},
		chance={"PICK",0.8},
		fu=function(player, center)
			spawn_to_target("flower_cave", center)
			center:Remove()
		end,
		check=function(player, center)
			return TheWorld:HasTag("cave")
		end
	},
	cutreeds = {
		name="Ritual of Poe",
		num=3,
		recipe={spoiled_food=2, fireflies=5},
		min_level={"PICK",7},
		chance={"PICK",0.7},
		fu=function(player, center)
			spawn_to_target("reeds", center)
			center:Remove()
		end,
		check=function(player, center)
			return TheWorld.Map:GetTileAtPoint(center.Transform:GetWorldPosition()) == GROUND.MARSH
		end
	}
}

local SKILLS = {
	fireflies= {
		name="Ghosty fireflies",
		min_level={"PICK",1},
		chance={"PICK",0.9}
	},
	hungry_attack = {
		name="Hungry fighter",
		min_level={"EAT",1},
		rate={"EAT",1}
	},
	self_cannibalism = {
		name="Self-cannibalism",
		min_level={"EAT",3},
		rate={"EAT",-0.05}
	},
	attack = {
		name="Explosive touch",
		min_level={"ATTACK",1},
		chance={"ATTACK",0.5}
	},
	attacked = {
		name="Beetaliation",
		min_level={"ATTACK",2},
		chance={"ATTACK",0.5}
	},
	fertilize = {
		name="Double the shit",
		min_level={"PLANT",1},
		chance={"PLANT",0.5}
	},
	harvest = {
		name="Plant another day",
		min_level={"PLANT",2},
		chance={"PLANT",0.5}
	},
	dig = {
		name="Treasure hunter",
		min_level={"DIG",1},
		chance={"DIG",0.5},
		items={--keys are their respective chances and should sum up to 1
			[0.5]={"lightbulb", "redgem", "bluegem"},
			[0.3]={"mandrake", "purplegem", "cutreeds", "slurper_pelt", "furtuft"},
			[0.2]={"moonrocknugget", "beardhair", "yellowgem", "orangegem"}
		}
	}
}

local DEPLOY_PLANT_ACTIONS = { --deploying these will give PLANT-exp. Everything else gives BUILD-exp
	pinecone = true,
	twiggy_nut = true,
	acorn = true,
	berrybush = true,
	berrybush2 = true,
	berrybush_juicy = true,
	sapling = true,
	grass = true
}

print("[DsMMO] Implement settings")
for k,v in pairs(RECIPES) do
	if not GetModConfigData(k, KnownModIndex:GetModActualName("DsMMO")) then
		RECIPES[k] = nil
		print("[DsMMO] Disabling " ..k)
	end
end

function add_to_index(array)
	for k,v in pairs(array) do
		local action = v.min_level[1]
		local lvl = v.min_level[2]
		
		if not RECIPE_LEVEL_INDEX[action] then
			RECIPE_LEVEL_INDEX[action] = {}
		end
		if not RECIPE_LEVEL_INDEX[action][lvl] then
			RECIPE_LEVEL_INDEX[action][lvl] = {}
		end
		table.insert(RECIPE_LEVEL_INDEX[action][lvl], v)
	end
end
print("[DsMMO] Creating level up string")
RECIPE_LEVEL_INDEX = {}
add_to_index(SKILLS)
add_to_index(RECIPES)

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
function alert(player, msg, len)
	player.components.talker:Say(msg, len or 10)
end
function get_level(action, xp)
	if xp < DSMMO_ACTIONS[action] then
		return 0
	elseif xp < DSMMO_ACTIONS[action] * LEVEL_UP_RATE then
		return 1
	else
		return math.floor(math.log((xp-DSMMO_ACTIONS[action]) / DSMMO_ACTIONS[action]) / math.log(LEVEL_UP_RATE)) +1
	end
end
function get_max_exp(action, lvl)
	return lvl > 0 and DSMMO_ACTIONS[action] + math.ceil(DSMMO_ACTIONS[action] * math.pow(LEVEL_UP_RATE, lvl)) or DSMMO_ACTIONS[action]
end

function onPerformaction(player, data)
	local action = player.bufferedaction or data.action
	local self = player.components.DsMMO
	--spawn_to_target("impact", player)
	--spawn_to_target("shadow_bishop_fx", player)
	if action then
		local actionId = action.action.id
		
		if actionId == "EAT" then
			if player.components.hunger.current < player.components.hunger.max and action.invobject.components.edible.hungervalue > 0 then
				player.components.DsMMO:get_experience(actionId)
			end
		elseif actionId == "HARVEST" then
			player.components.DsMMO:get_experience("PLANT")
			local crop = action.target.components.crop
			if crop and self:test_skill(SKILLS.harvest) then
				player.components.inventory:GiveItem(SpawnPrefab(crop.product_prefab))
				spawn_to_target("collapse_small", player)
			end
		elseif actionId == "FERTILIZE" then
			player.components.DsMMO:get_experience("PLANT")
			local crop = action.target.components.crop
			if crop and not crop:IsReadyForHarvest() and self:test_skill(SKILLS.harvest) then
				crop:Fertilize(SpawnPrefab("guano"), player)
				spawn_to_target("collapse_small", player)
			end
		elseif actionId == "HAUNT" then
			local targetN = action.target.prefab
			if targetN == "flower_evil" then
				spawn_to_target("ground_chunks_breaking", player)
				if self:test_skill(SKILLS.fireflies) then
					spawn_to_target("collapse_small", action.target)
					
					local fireflies = SpawnPrefab("fireflies")
					fireflies.Transform:SetPosition(action.target.Transform:GetWorldPosition())
					fireflies.components.inventoryitem.ondropfn(fireflies)
					action.target:Remove()
				end
			end
		elseif actionId == "ADDFUEL" then
			if action.target.prefab == "firepit" then
				--self._teleport_to = action.target.Transform:GetWorldPosition()
				self._teleport_to = action.target:GetPosition()
			end
		elseif actionId == "REPAIR" or actionId == "HAMMER" then
			player.components.DsMMO:get_experience("BUILD")
		elseif actionId == "TERRAFORM" then
			player.components.DsMMO:get_experience("DIG")
		elseif actionId == "DEPLOY" then
			player.components.DsMMO:get_experience(DEPLOY_PLANT_ACTIONS[action.invobject.prefab] and "PLANT" or "BUILD")
		elseif self.level[actionId] then
			player.components.DsMMO:get_experience(actionId)
			
			if actionId == "ATTACK" then
				if action.target and self:test_skill(SKILLS.attack) then
					spawn_to_target("explode_small", action.target)
					action.target.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
					action.target.components.combat:GetAttacked(player, TUNING.SPEAR_DAMAGE)
				end
			elseif actionId == "DIG" then
				if not action.target.DsMMO_creation and self:test_skill(SKILLS.dig) then
					local items = SKILLS.dig.items
					local r = math.random()
					for k,v in pairs(items) do
						if r < k then
							spawn_to_target(v[math.random(1,table.getn(v))], player)
							break
						else
							r = r - k
						end
					end
				end
			end
		else
			print(actionId)
		end
	end
end
function onAttacked(player, data)
	player.components.DsMMO:get_experience("ATTACK")
	if player.components.DsMMO:test_skill(SKILLS.attacked) then
		local bee = SpawnPrefab("bee")
		bee.persists = false
		bee.Transform:SetPosition(player.Transform:GetWorldPosition())
		bee.components.combat:SetTarget(data.attacker)
	end
end
function onStartStarving(player)
	--no test_skill() because this one is not decided by luck
	if player.components.combat ~= nil and player.components.combat.damagemultiplier ~= nil then
		player.default_damagemultiplier = player.components.combat.damagemultiplier
	else
		player.default_damagemultiplier = 1
	end
	local self = player.components.DsMMO
	local skill = SKILLS.hungry_attack
	local new_damagemultiplier = self.level[skill.rate[1]] * skill.rate[2]
	
	if self.level[skill.min_level[1]] >= skill.min_level[2] and new_damagemultiplier > player.default_damagemultiplier then
		player.components.combat.damagemultiplier = new_damagemultiplier
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
function onLogout(player)
	local self = player.components.DsMMO
	if self._info_entity then
		self:log_msg("Removing skill-indicator-sign")
		self._info_entity:Remove()
		self._info_entity = nil
	end
end


local DsMMO = Class(function(self, player)
	self.player = player
	self._player_original_position = nil --if not nil, this will be saved when the player logs out unexpectedly
	self._action_states = {}
	self._info_entity = nil
	self.last_action = "EAT"
	self._teleport_to = nil
	
	if not TheWorld.ismastersim then
		--self:log_msg("is client - stop")
		--player:ListenForEvent("performaction", onPerformactionDirty)
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
	
	local origin_updateState = self.player.sg.UpdateState
	player.sg.UpdateState = function(...)
		if not player.sg.currentstate then 
			return
		end
		
		if self._action_states[player.sg.currentstate.name] then
			player.sg.currentstate = self._action_states[player.sg.currentstate.name]
		end
		
		origin_updateState(...)
	end
	
	
	self:create_array() --this is a waste of performance - But I havent found a way to detect a newly created character
	--player:ListenForEvent("ms_becameghost", onbecameghost)
	player:ListenForEvent("death", onbecameghost)
	player:ListenForEvent("onremove", onLogout)
	
	
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
	
			alert(player, self:newLevelString(action, lvl))
			player.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
			
			
			if ACTION_SPEED_INCREASE[action] then
				self:update_actionSpeed(action)
			end
		end
	end
	self:set_last_action(action)
end
function DsMMO:set_last_action(action)
	self.last_action = action
	
	if self._info_entity ~= nil then
		local inst = nil
		if action == "CHOP" then
			inst = SpawnPrefab("axe")
		elseif action == "MINE" then
			inst = SpawnPrefab("pickaxe")
		elseif action == "ATTACK" then
			inst = SpawnPrefab("spear")
		elseif action == "PLANT" then
			inst = SpawnPrefab("carrot")
		elseif action == "BUILD" then
			inst = SpawnPrefab("hammer")
		elseif action == "DIG" then
			inst = SpawnPrefab("shovel")
		elseif action == "EAT" then
			inst = SpawnPrefab("meatballs")
		elseif action == "PICK" then
			inst = SpawnPrefab("berries")
		else
			inst = SpawnPrefab("minisign")
		end
		
		self._info_entity.components.drawable:OnDrawn(inst.prefab, inst)
		inst:Remove()
	end
end
function DsMMO:newLevelString(action, lvl)
	local base = action .."-level: " ..lvl .." !\n"
	
	if lvl < LEVEL_MAX then
		base = base ..self:calc_mssing_xp(action) .." exp until lvl " ..(lvl+1) .."\n"
	end
	
	if RECIPE_LEVEL_INDEX[action] and RECIPE_LEVEL_INDEX[action][lvl] then
		for i,v in ipairs(RECIPE_LEVEL_INDEX[action][lvl]) do
			base = base .."\nYou learned a new skill: " ..v.name
		end
	end
	
	return base
end

function DsMMO:update_actionSpeed(action)
	--Unfortunately, there is no real way to increase the Action-state-speed
	--	So we create our own State and override it if necessary
	--	sources:
	--	scripts/stategraph.lua
	--	scripts/stategraphs/SGwilson.lua
	local lvl = self.level[action]/LEVEL_MAX
	local action_key = ACTION_SPEED_INCREASE[action]
	--local action_key = string.lower(action)
	local origin_state = self.player.sg.sg.states[action_key]
	
	if self._action_states[action_key] then
		local new_state = self._action_states[action_key].timeline
		for k_timeline,v_timeline in pairs(new_state) do
			local t = origin_state.timeline[k_timeline].time
			new_state[k_timeline] = TimeEvent(t - t*lvl, v_timeline.fn)
			--new_state.timeline[k_timeline] = TimeEvent(v_timeline.time - v_timeline.time*lvl, v_timeline.fn)
		end
	else
		self._action_states[action_key] = State{name=origin_state.name, timeline={}}
		local new_state = self._action_states[action_key]
		
		for k,v in pairs(origin_state) do
			if k == "timeline" then
				for k_timeline,v_timeline in pairs(v) do
					new_state.timeline[k_timeline] = TimeEvent(v_timeline.time - v_timeline.time*lvl, v_timeline.fn)
				end
			else
				new_state[k] = v
			end
		end
	end
end

function DsMMO:init_recipe(target)
	local recipe_data = RECIPES[target.prefab]
	if recipe_data then
		if self.level[recipe_data.min_level[1]] < recipe_data.min_level[2] then
			self:log_msg(target.prefab .."-recipe: " ..recipe_data.min_level[1] .."-level(" ..self.level[recipe_data.min_level[1]] .."<" ..recipe_data.min_level[2] ..") is not high enough")
			alert(self.player, "I don't feel prepared...")
		elseif recipe_data.check and not recipe_data.check(self.player, target) then
			alert(self.player, "I just can't...")
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
							alert(player, "It failed...")
						end
					end)
				return
			end
		end
	end
	
	alert(self.player, "What am I missing..?")
end

function DsMMO:test_skill(skill)
	return self.level[skill.min_level[1]] >= skill.min_level[2] and get_success(self.player, skill.chance[1], skill.chance[2])
end

function DsMMO:OnLoad(data)
	print("onLoad")
	if data.dsmmo_version then
		if data.dsmmo_version == VERSION then
			self.exp = data.dsmmo_exp
			self.level = data.dsmmo_level
			
			for k,v in pairs(ACTION_SPEED_INCREASE) do
				self:update_actionSpeed(k)
			end
		else
			self:log_msg("Upgrading from v" ..data.dsmmo_version .." to v" ..VERSION)
			for k,v in pairs(DSMMO_ACTIONS) do
				--we transfer each variable seperately to make sure the different version stays compatible
				if data.dsmmo_level[k] then
					self.exp[k] = data.dsmmo_exp[k]
					self.level[k] = get_level(k, data.dsmmo_exp[k])
					if ACTION_SPEED_INCREASE[k] then
						self:update_actionSpeed(k)
					end
				end
			end
		end
		if data._player_original_position then
			self.player.Physics:Teleport(data._player_original_position.x, data._player_original_position.y, data._player_original_position.z)
		end
		self._teleport_to = data._teleport_to
	end
end
function DsMMO:OnSave()
	print("OnSave")
	local data = {
			dsmmo_exp = self.exp,
			dsmmo_level = self.level,
			_teleport_to = self._teleport_to,
			dsmmo_version = VERSION
		}
	
	if self._player_original_position then
		self:log_msg("saving original player-position")
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
	if self._no_penalty then
		self._no_penalty = nil
		return
	end
	
	for k,v in pairs(DSMMO_ACTIONS) do
		local xp = math.floor(self.exp[k] / 2)
		self.exp[k] = xp
		if xp > 0 then
			self.level[k] = get_level(k, xp)
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

function DsMMO:calc_mssing_xp(action, lvl)
	return get_max_exp(action, self.level[action]) - self.exp[action] +1
end

function add_spaces(str, size)
	local space = ""
	for i = string.len(str)+1, size, 1 do
		space = space .."_"
	end
	
	return space
end
function DsMMO:show_info()
	local action = self.last_action
	local output = ""
	if DSMMO_ACTIONS[action] then
		local lvl = self.level[action]
		local xp = self:calc_mssing_xp(action)
		local level = self.level
		
		output = (lvl < LEVEL_MAX
			and	(action ..": " ..xp .." exp --> lvl " ..(lvl+1))
			or	(action ..": lvl " ..lvl))
			.."\n__________\nI have learned the following " ..action .."-skills:\n"
		
		if RECIPE_LEVEL_INDEX[action] then
			for k_lvl,v_lvl in pairs(RECIPE_LEVEL_INDEX[action]) do
				if lvl >= k_lvl then
					for i,v in ipairs(v_lvl) do
						output = output .."\n" ..v.name .."(" ..(v.chance
							and (get_chance(v.chance[2], level[v.chance[1]])*100) .."%)"
							or (level[v.rate[1]] * v.rate[2]) .."x)"
						)
					end
				end
			end
		end
	else
		output = action .." is not a valid DsMMO-skill"
	end
	
	return output
end
function DsMMO:run_command(cmd, arg1, arg2, arg3)
	local output = ""
	local dur = 5
	
	if arg1 == "help" or arg1 == "?" then
		dur = 20
		output = "______________________ Possible commands: ______________________"
			.."\n#dsmmo ________________________________ Spawns a level info sign"
			.."\n#dsmmo [ skill ] ___________________ level info sign for a specific skill"
			.."\n#dsmmo list _____________________________ List of all DsMMO-levels"
			.."\n#dsmmo help ______________________________________ this help-text"
	elseif arg1 == "list" then
		for k,v in pairs(self.level) do
			output = output ..k ..":" ..add_spaces(k, 10) ..add_spaces(tostring(v), 2) ..v .."\n"
		end
	elseif arg1 == "eat" then
		local skill = SKILLS.self_cannibalism
		if self.level[skill.min_level[1]] < skill.min_level[2] then
			output = "I don't know how..."
		else
			local attr = string.lower(arg3)
			local action = string.upper(arg2)
			if not self.exp[action] then
				output = "I can't eat the skill " ..action
			else
				local comp = nil
				local diff = nil
				
				if attr == "health" then
					comp = self.player.components.health
					diff = math.ceil(comp.maxhealth - comp.currenthealth)
				elseif attr == "sanity" then
					comp = self.player.components.sanity
					diff = math.ceil(comp.max - comp.current)
				elseif attr == "hunger" then
					comp = self.player.components.hunger
					diff = math.ceil(comp.max - comp.current)
				else
					output = attr .." is nothing I can gain by eating myself"
				end
				
				if comp ~= nil then
					diff = diff + math.ceil(diff * (self.level[skill.rate[1]] * skill.rate[2])) --skill.rate is negative
					
					if self.exp[action] < diff then
						output = "I don't have enough exp for that"
					else
						comp:SetPercent(1)
						self.exp[action] = self.exp[action] - diff
						self.level[action] = get_level(action, self.exp[action])
						output = "Lost " ..diff .." " ..action .. "-exp"
					end
				end
			end
		end
	else
		if self._info_entity and self._info_entity.entity:IsValid() then
			self._info_entity.Transform:SetPosition(self.player.Transform:GetWorldPosition())
		else
			local inst = SpawnPrefab("minisign")
			inst.persists = false
			inst.Transform:SetPosition(self.player.Transform:GetWorldPosition())
			inst.DsMMO_creation = true
			inst.components.inspectable.getspecialdescription = function(inst, player)
				return player.components.DsMMO:show_info()
			end
			self._info_entity = inst
			inst:RemoveComponent("burnable")
			
			inst.components.workable:SetOnFinishCallback(function(inst)
				inst:Remove()
			end)
		end
		local action
		if arg1 and DSMMO_ACTIONS[string.upper(arg1)] then
			action = string.upper(arg1)
		else
			action = self.last_action
		end
		
		self:set_last_action(action)
		output = self:show_info()
	end
	
	alert(self.player, output, dur)
end

return DsMMO