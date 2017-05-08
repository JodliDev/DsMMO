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


local LEVEL_MAX = 10
local MIN_LEVEL_PICK_FIREFLY = 5

local CHANCE_ATTACK_THUNDER = 0.5
local CHANCE_FERTILIZE_BONUS = 0.5
local CHANCE_HARVEST_BONUS = 0.5
local CHANCE_ATTACKED_BEE = 0.5
local CHANCE_DIG_MOLE = 0.5

local RECIPE_DISTANCE = 5
local RECIPE_MOLE = {3,{["rocks"]=1, ["flint"]=1, ["nitre"]=1, ["goldnugget"]=1, ["marble"]=1, ["moonrocknugget"]=1}}
local RECIPE_TOUCHSTONE = {1,{["amulet"]=1}}
local RECIPE_GRASS = {5,{["grass"]=1, ["spoiled_food"]=2, ["bluegem"]=1, ["redgem"]=1}}

local DSMMO_ACTIONS = {
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

local COLOR_ACTIONS = {
	["CHOP"] = {0.6, 0.4, 0},
	["MINE"] = {1, 1, 0.0},
	["DIG"] = {1, 0.5, 0},
	["REPAIR"] = {0, 0, 1},
	["ATTACKED"] = {1, 0, 0},
	["ATTACK"] = {0.7, 0, 0},
	["PLANT"] = {1, 0, 0},
	["FERTILIZE"] = {0.5, 0.3, 0},
	["EAT"] = {1, 1, 1},
	["PICK"] = {1, 1, 1}
}
local COLOR_GOLD = {1, 0.8, 0, 1}
local COLOR_RED = {1, 0, 0, 1}


local PRESETS = {
	["CHOP"] = {2,5,10,12,2,9,14,16}, -- from scripts/stategraphs/SGwilson.lua:1707 to :1778
	["MINE"] = {7,9,14} -- from scripts/stategraphs/SGwilson.lua:1828 to :1846
}
local RECIPE_CENTER_PLACES = {
	["molehill"] = {RECIPE_MOLE, function(player, center)
		if get_success(player, "DIG", 0.5) then
			SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
			if get_success(player, "DIG", 0.05) then
				SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
				SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
				SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
				alert(player, "That was lucky", COLOR_GOLD)
			end
		else
			alert(player, "It failed...", COLOR_RED)
		end
	end},
	--["resurrectionstone"] = {RECIPE_TOUCHSTONE, function(player, touchstone)
	["resurrectionstone"] = {RECIPE_TOUCHSTONE, function(player, touchstone)
		--if table.contains(player.player_classified.touchstonetrackerused:value(), touchstone:GetTouchStoneID()) then
		
		local k
		local v
		for local_k,local_v in pairs(player.components.touchstonetracker.used) do
			k = local_k -- I dont like lua... Syntax seems to me that you cant use non-locals in for..in
			v = local_v
			if math.random() < 0.2 then --this is a very cheaty randomisation - but it also saves performance
				break
			end
		end
		list_table(player.components.touchstonetracker.used)
		print("i1:"..k)
		player.components.touchstonetracker.used[k] = nil
		--v._enablelights:set(true)
		--table.remove(player.components.touchstonetracker.used, i)
		list_table(player.components.touchstonetracker.used)
		--if player.components.touchstonetracker:IsUsed(touchstone) then
			--player.components.touchstonetracker.used[touchstone:GetTouchStoneID()] = nil
		--end
	end, function(player, center)
		local r = false
		for k,v in pairs(player.components.touchstonetracker.used) do
			r = true
			break
		end
		return r
	end},
	["cutgrass"] = {RECIPE_GRASS, function(player, center)
		SpawnPrefab("grass").Transform:SetPosition(center.Transform:GetWorldPosition())
	end}
}


function spawn_to_target(n, target)
	SpawnPrefab(n).Transform:SetPosition(target.Transform:GetWorldPosition())
end
function is_fullMoon()
	return TheWorld.state.moonphase == "full" --GetClock():GetMoonPhase()
end
function get_success(player, action, base_r)
	local r = math.random() + (1-base_r)
	if is_fullMoon() then
		r = r - 0.5
	end
	
	return r < player.components.DsMMO.level[action] / LEVEL_MAX and true or false
end
function alert(player, msg, color)
	player.components.talker:Say(msg, nil, nil, nil, nil, color)
end
function get_level(xp)
	return math.floor(math.log(xp) / math.log(2))
end

function onPerformaction(player, data)
	local action = player.bufferedaction or data.action
	local self = player.components.DsMMO
		--spawn_to_target("ground_chunks_breaking", player)
		--spawn_to_target("campfirefire", player)
		--spawn_to_target("collapse_small", player)
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
			if DSMMO_ACTIONS["PICK"] >= MIN_LEVEL_PICK_FIREFLY then
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
function onPerformactionDirty(player, data)
	--local action = player.bufferedaction or data.action
	print(player.components.DsMMO.last_state)
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
	player.components.DsMMO:reset()
end


function onExp_update(player, action)
	local xp = player.components.DsMMO.exp[action]:value()
	
	if(player.components.DsMMO.level ~= get_level(xp)) then
		alert(player, action .." was not in sync with server (" ..player.components.DsMMO.level[action] .."/=" ..get_level(xp) ..")", COLOR_RED)
	end
	player.components.DsMMO.level = get_level(xp)
end

local _DsMMO = nil
local DsMMO = Class(function(self, player)
	_DsMMO = self
	self.player = player
	
	if not TheWorld.ismastersim then
		print("is client")
		self.last_state = nil
		self:create_array();
		player:ListenForEvent("performaction", onPerformactionDirty)
		player:ListenForEvent("newstate", function(player, state)
				if state.statename ~= "idle" then
					player.components.DsMMO.last_state = state.statename
				end
			end)
		
		return
	end
	
	local main_lookat = ACTIONS.LOOKAT.fn
	ACTIONS.LOOKAT.fn = function(act)
		if not act.doer.components.DsMMO:init_recipe(act.target) then
			main_lookat(act)
		end
	end
	print("init")
	self:create_array() --this is a waste of performance - But I havent found a way to detect a newly created character
	player:ListenForEvent("ms_becameghost", onbecameghost)
	player:ListenForEvent("attacked", onAttacked)
	player:ListenForEvent("performaction", onPerformaction)
	player:ListenForEvent("startstarving", onStartStarving)
	player:ListenForEvent("stopstarving", onStopStarving)
end)

function DsMMO:get_experience(action)
	local player = self.player
	local lvl = self.level[action]
	if lvl < LEVEL_MAX then
		local xp = self.exp[action]:value() + 1
		self.exp[action]:set_local(xp);
		
		if xp > DSMMO_ACTIONS[action] * (math.pow(2, lvl)-1) then
			lvl = lvl+1
			self.level[action] = lvl
	
			player.components.talker:Say(action .."-level: " ..lvl)
			player.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
			
			
			if PRESETS[action] then
				self:update_actionSpeed(action)
			end
		end
		
		self:createIndicator(lvl ..": " ..(DSMMO_ACTIONS[action]*(math.pow(2, lvl)-1) - self.exp[action]:value()), COLOR_ACTIONS[action])
	end
end
function DsMMO:update_actionSpeed(action_key)
	--Unfortunately, there is no real way to increase the Action-animation-speed
	-- So we override the timetables as gracefully as we can and hope that
	-- the source code wont get any major change
	local lvl = self.level[action_key]/LEVEL_MAX
	local action = self.player.sg.sg.states[string.lower(action_key)]
	local t = PRESETS[action_key]
	
	for k,v in pairs(action.timeline) do
		action.timeline[k] = TimeEvent((t[k] - ((t[k]-1)*lvl)) * FRAMES, v.fn)
	end
end

function DsMMO:init_recipe(target)
	local recipe_data = RECIPE_CENTER_PLACES[target.prefab]
	if recipe_data then
		if not recipe_data[3] or recipe_data[3](player, target) then
			self:check_recipe(target, recipe_data[1], recipe_data[2])
			return true
		end
	else
		print(target.prefab)
	end
	return false
end
function DsMMO:check_recipe(center, recipe, fn)
	local collection = {}
	local pos = center:GetPosition()
	local near = TheSim:FindEntities(pos.x, pos.y, pos.z, 5)
	
	local ings_needed_sum = recipe[1]
	local ingredients = {}
	for k,v in pairs(recipe[2]) do
		ingredients[k] = v
	end
	
	for k,v in pairs(near) do
		itemN = v.prefab
		
		ing_num = ingredients[itemN]
		if v.parent == nil and ings_needed_sum > 0 and ing_num and ing_num>0 then
			print("(DsMMO) recipe: Found " ..itemN)
			table.insert(collection, v)
			ingredients[itemN] = ing_num - 1
			ings_needed_sum = ings_needed_sum - 1
			if ings_needed_sum <= 0 then
				for k2,v2 in pairs(collection) do
					--spawn_to_target("campfirefire", v2)
					local fire = SpawnPrefab("campfirefire")
					fire.Transform:SetPosition(v2.Transform:GetWorldPosition())
					fire:DoTaskInTime(1, function(inst) inst:Remove() end)
					v2:Remove()
				end
					spawn_to_target("lightning", center)
					spawn_to_target("collapse_big", center)
					
					fn(player, center)
				return
			end
		end
	end
	
	alert(player, "What am I missing..?", COLOR_RED)
end

function DsMMO:OnLoad(data)
	if data.dsmmo_level then
		for k,v in pairs(DSMMO_ACTIONS) do
			--we transfer each variable seperately to make sure future version will be compatible too
			if data.dsmmo_level[k] then
				--self.exp[k] = data.dsmmo_exp[k]
				self.exp[k]:set(data.dsmmo_exp[k])
				self.level[k] = data.dsmmo_level[k]
				--self.exp_update:set = data.dsmmo_exp[k]
				if PRESETS[k] then
					self:update_actionSpeed(k)
				end
			end
			
		end
	end
end
function DsMMO:OnSave()
	--local data = {
			--["dsmmo_exp"] = self.exp,
			--["dsmmo_level"] = self.level
		--}
	--return data
end
function DsMMO:create_array()
	local player = self.player
	local guid = player.GUID
	self.exp = {}
	self.level = {}
	
	if TheWorld.ismastersim then
		for k,v in pairs(DSMMO_ACTIONS) do
			self.exp[k] = net_ushortint(guid, k .."_exp", k .."_exp")
			self.exp[k]:set_local(0)
			--self.exp[k] = 0
			self.level[k] = 0
		end
	else
		for k,v in pairs(DSMMO_ACTIONS) do
			self.exp[k] = net_ushortint(guid, k .."_exp", k .."_exp")
			self.exp[k]:set_local(0)
			self.level[k] = 0
			player:ListenForEvent(k .."_exp", function(player) onExp_update(player, k) end)
		end
	end
end
function DsMMO:reset()
	local player = self.player
	for k,v in pairs(DSMMO_ACTIONS) do
		local xp = math.floor(self.exp[k]:value() / 2)
		self.exp[k]:set(xp)
		if xp > 0 then
			self.level[k] = get_level(x)
			self:createIndicator(-xp, COLOR_ACTIONS[k])
		end
	end
end

function DsMMO:createIndicator(msg, color)
	local player = self.player
	local label_font_size = 30
	
	local indicator = CreateEntity()
	indicator.persists = true
	indicator.entity:AddTransform()
	indicator.Transform:SetPosition(player.Transform:GetWorldPosition())

	local label = indicator.entity:AddLabel()
	label:SetFont(NUMBERFONT)
	label:SetFontSize(label_font_size)
	label:SetWorldOffset(0, 0, 0)
	label:SetColour(color[1], color[2], color[3])
	label:SetText(msg)
	label:Enable(true)

	indicator:StartThread(function()
		local label = indicator.Label
		local dx
		if math.random() < 0.5 then
			dx = -0.03
		else
			dx = 0.03
		end
		
		local y = 0
		local x = 0
		local dy = 0.1 - math.random()*0.1
		local ddy = 0.003


		local t = 1
		while indicator:IsValid() and t > 0 do
			t = t-0.02

			if dy > -0.2 then
				ddy = ddy *1.1
				dy = dy - ddy
			end
			x = x + dx
			y = y + dy

			label:SetWorldOffset(x, y, 0)
			label:SetFontSize(label_font_size - label_font_size * (1 - t))
			Sleep(0.02)
		end

		indicator:Remove()
	end)
end

return DsMMO