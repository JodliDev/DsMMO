local TUNING = GLOBAL.TUNING

GLOBAL.CHEATS_ENABLED = true

GLOBAL.require( 'debugkeys' )

--~ TUNING.EVERGREEN_CHOPS_SMALL = 10
--~ TUNING.EVERGREEN_CHOPS_NORMAL = 10
--~ TUNING.EVERGREEN_CHOPS_TALL = 10
--~ TUNING.MUSHTREE_CHOPS_SMALL = GetModConfigData("EVERGREEN_CHOPS_SMALL")
--~ TUNING.MUSHTREE_CHOPS_MEDIUM = GetModConfigData("EVERGREEN_CHOPS_NORMAL")
--~ TUNING.MUSHTREE_CHOPS_TALL = GetModConfigData("EVERGREEN_CHOPS_TALL")
--~ TUNING.DECIDUOUS_CHOPS_SMALL = GetModConfigData("EVERGREEN_CHOPS_SMALL")
--~ TUNING.DECIDUOUS_CHOPS_NORMAL = GetModConfigData("EVERGREEN_CHOPS_NORMAL")
--~ TUNING.DECIDUOUS_CHOPS_TALL = GetModConfigData("EVERGREEN_CHOPS_TALL")



local LEVEL_MAX = 10

local RECIPE_DISTANCE = 5
local RECIPE_MOLE = {3,{["rocks"]=1, ["flint"]=1, ["nitre"]=1, ["goldnugget"]=1, ["marble"]=1, ["moonrocknugget"]=1}}
local RECIPE_TOUCHSTONE = {1,{["amulet"]=1}}

local DSMMO_ACTIONS = {
	["CHOP"] = 60,
	["MINE"] = 50,
	["DIG"] = 40,
	["REPAIR"] = 25,
	["ATTACKED"] = 15,
	["ATTACK"] = 30,
	["PLANT"] = 30,
	["FERTILIZE"] = 25,
	["EAT"] = 40
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
	["EAT"] = {1, 1, 1}
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
			GLOBAL.SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
			if get_success(player, "DIG", 0.05) then
				GLOBAL.SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
				GLOBAL.SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
				GLOBAL.SpawnPrefab("mole").Transform:SetPosition(center.Transform:GetWorldPosition())
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
		v._enablelights:set(true)
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
	end}
}

function list_table(v)
	local output = ""
	local output2 = ""
	local output3 = ""
	local output4 = ""
	local output5 = ""
	local i = 0
	for k,v in pairs(v) do
		if i < 10 then
			output = output ..k ..","
		elseif i < 20 then
			output2 = output2 ..k .. ","
		elseif i < 30 then
			output3 = output3 ..k .. ","
		elseif i < 40 then
			output4 = output4 ..k .. ","
		else
			output5 = output5 ..k .. ","
		end
		i = i+1
	end
	print(i)
	print(output)
	
	print(output2)
	print(output3)
	print(output4)
	print(output5)
end


function is_fullMoon()
	return GLOBAL.TheWorld.state.moonphase == "full" --GetClock():GetMoonPhase()
end

function get_success(player, action, base_r)
	local r = math.random() + (1-base_r)
	if is_fullMoon() then
		r = r - 0.5
	end
	
	return r < player.dsmmo_level[action] / LEVEL_MAX and true or false
end
function get_experience(action, player, target)
	local lvl = player.dsmmo_level[action]
	if lvl < LEVEL_MAX then
		local xp = player.dsmmo_exp[action] + 1
		player.dsmmo_exp[action] = xp;
		
		if xp > DSMMO_ACTIONS[action] * (math.pow(2, lvl)-1) then
			lvl = lvl+1
			player.dsmmo_level[action] = lvl
	
			player.components.talker:Say(action .."-level: " ..lvl)
			player.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
			
			
			if PRESETS[action] then
				update_actionSpeed(player, action)
			end
		end
		
		createIndicator(target, lvl ..": " ..(DSMMO_ACTIONS[action]*(math.pow(2, lvl)-1) - player.dsmmo_exp[action]), COLOR_ACTIONS[action])
	end
end


function createIndicator(parent, msg, color)
	if parent == nil then
		print("dsmmo-error: parent was nil!!")
		parent = GLOBAL.ThePlayer
	end
	local label_font_size = 30
	
	local indicator = GLOBAL.CreateEntity()
	indicator.persists = true
	indicator.entity:AddTransform()
	indicator.Transform:SetPosition(parent.Transform:GetWorldPosition())

	local label = indicator.entity:AddLabel()
	label:SetFont(GLOBAL.NUMBERFONT)
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
			GLOBAL.Sleep(0.02)
		end

		indicator:Remove()
	end)
end


function alert(player, msg, color)
	player.components.talker:Say(msg, nil, nil, nil, nil, color)
end


function init_recipe(player, target)
	local recipe_data = RECIPE_CENTER_PLACES[target.prefab]
	if recipe_data then
		if not recipe_data[3] or recipe_data[3](player, target) then
			check_recipe(player, target, recipe_data[1], recipe_data[2])
			return true
		end
	else
		print(target.prefab)
	end
	return false
end
function check_recipe(player, center, recipe, fn)
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
					v2:Remove()
				end
				--player:StartThread(function()
					--GLOBAL.Sleep(1)
					--GLOBAL.TheWorld:PushEvent("ms_sendlightningstrike", center:GetPosition())
					GLOBAL.SpawnPrefab("lightning").Transform:SetPosition(center.Transform:GetWorldPosition())
					
					fn(player, center)
				--end)
				return
			end
		end
	end
	
	alert(player, "What am I missing..?", COLOR_RED)
end




--function onequip(inst, data)
	--print("onequip")
	
	--for k,v in pairs(mmo_actions) do
		--if data.item.components.tool:CanDoAction(k) then
			--data.item.components.tool:SetAction(k, 3)
			--print("increase")
		--end
	--end
--end


function create_array(player)
	player.dsmmo_exp = {}
	player.dsmmo_level = {}
	for k,v in pairs(DSMMO_ACTIONS) do
		player.dsmmo_exp[k] = 0
		player.dsmmo_level[k] = 0
	end
end
function reset_mcmmo(player)
	for k,v in pairs(DSMMO_ACTIONS) do
		local xp = math.floor(player.dsmmo_exp[k] / 2)
		player.dsmmo_exp[k] = xp
		if xp > 0 then
			player.dsmmo_level[k] = math.floor(math.log(xp) / math.log(2))
			createIndicator(player, -xp, COLOR_ACTIONS[k])
		end
	end
end


function update_actionSpeed(player, action_key)
	--Unfortunately, there is no real way to increase the Action-animation-speed
	-- So we override the timetables as gracefully as we can and hope that
	-- the source code wont get any major change
	local lvl = player.dsmmo_level[action_key]/LEVEL_MAX
	local action = player.sg.sg.states[string.lower(action_key)]
	local t = PRESETS[action_key]
	
	for k,v in pairs(action.timeline) do
		action.timeline[k] = GLOBAL.TimeEvent((t[k] - ((t[k]-1)*lvl)) * GLOBAL.FRAMES, v.fn)
	end
end





function onPerformaction(player, data)
	local action = player.bufferedaction or data.action
	
	if action then
		local actionId = action.action.id
		
		
		if actionId == "EAT" then
			if player.components.hunger.current <player.components.hunger.max then
				get_experience(actionId, player, player)
			end
		elseif player.dsmmo_level[actionId] then
			get_experience(actionId, player, player)
			
			if actionId == "ATTACK" then
				if get_success(player, "ATTACK", 0.8) then
					GLOBAL.SpawnPrefab("lightning").Transform:SetPosition(action.target.Transform:GetWorldPosition())
					target.components.combat:GetAttacked(action.target, TUNING.SPEAR_DAMAGE)
				end
			elseif actionId == "FERTILIZE" then
				local crop = action.target.components.crop
				if crop and not crop:IsReadyForHarvest() and get_success(player, "FERTILIZE", 0.5) then
					local fert = GLOBAL.SpawnPrefab("guano")
					crop:Fertilize(fert, player)
					createIndicator(player, "Lucky Fertilization!", COLOR_GOLD)
				end
			end
		elseif actionId == "HARVEST" then
			local crop = action.target.components.crop
			if crop ~= nil then
				if get_success(player, "PLANT", 0.5) then
					local item = GLOBAL.SpawnPrefab(crop.product_prefab)
					player.components.inventory:GiveItem(item)
					
					createIndicator(player, "Lucky Harvest!", COLOR_GOLD)
				end
			end
		else
			print(actionId)
		end
		
		
	end
end

function onAttacked(player, data)
	get_experience("ATTACKED", player, data.attacker)
	
	if get_success(player, "ATTACKED", 0.25) then
		local bee = GLOBAL.SpawnPrefab("bee")
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
	local new_damagemultiplier = player.dsmmo_level["EAT"]
	
	if new_damagemultiplier > player.default_damagemultiplier then
		player.components.combat.damagemultiplier = player.dsmmo_level["EAT"]
		createIndicator(player, "I feel mighty", COLOR_GOLD)
	end
end
function onStopStarving(player)
	if player.default_damagemultiplier and player.components.combat and player.components.combat.damagemultiplier then
		player.components.combat.damagemultiplier = player.default_damagemultiplier
	end
end

function onbecameghost(player)
	reset_mcmmo(player)
end

function OnSave(player, data)
	data.dsmmo_exp = player.dsmmo_exp
	data.dsmmo_level = player.dsmmo_level
end
function OnLoad(player, data)
	if data.dsmmo_level then
		for k,v in pairs(DSMMO_ACTIONS) do
			--we transfer each variable seperately to make sure future version will be compatible too
			if data.dsmmo_level[k] then
				player.dsmmo_exp[k] = data.dsmmo_exp[k]
				player.dsmmo_level[k] = data.dsmmo_level[k]
			end
			
			if PRESETS[k] then
				update_actionSpeed(player, k)
			end
		end
	end
end


function playerPostInit(player)
	if not GLOBAL.TheWorld.ismastersim then
		print("I am a client")
		return
	end
	
	
	local main_lookat = GLOBAL.ACTIONS.LOOKAT.fn
	local last_act = nil
	GLOBAL.ACTIONS.LOOKAT.fn = function(act)
		if not init_recipe(act.doer, act.target) then
			main_lookat(act)
		end
	end
	print("init")
	create_array(player) --this is a waste of performance - But I havent found a way to detect a newly created character
	player.OnSave = OnSave
	player.OnLoad = OnLoad
	player:ListenForEvent("ms_becameghost", onbecameghost)
	--player:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	
	--player:ListenForEvent("working", onWorked)
	player:ListenForEvent("attacked", onAttacked)
	--player:ListenForEvent("onattackother", onAttack)
	
	--player:ListenForEvent("equip", onequip)
	--player:ListenForEvent("onPickSomething", onPickSomething) --bushes
	--player:ListenForEvent("onpickupitem", onpickupitem) --items
	
	player:ListenForEvent("performaction", onPerformaction)
	--player:ListenForEvent("repair", test)
	--player:ListenForEvent("pickdiseasing", test)
	--player:ListenForEvent("digdiseasing", test)
	--player:ListenForEvent("gotnewitem", test)
	--player:ListenForEvent("itemget", test)
	--player:ListenForEvent("stacksizechange", test)
	--player:ListenForEvent("eat", test)
	player:ListenForEvent("startstarving", onStartStarving)
	player:ListenForEvent("stopstarving", onStopStarving)
	--player:ListenForEvent("startfreezing", test)
	--player:ListenForEvent("startoverheating", test)
	--player:ListenForEvent("buildsuccess", test)
	--player:ListenForEvent("armorbroke", test)
	--player:ListenForEvent("harvestsomething", test)
	--player:ListenForEvent("addfuel", test)
	--player:ListenForEvent("spentfuel", test)
	--player:ListenForEvent("gotosleep", test)
	--player:ListenForEvent("onwakeup", test)
	--player:ListenForEvent("gosane", test)
	--player:ListenForEvent("goinsane", test)
	--moonphasechanged
	--RemoveEventCallback
	--TheWorld.components.frograin
	
	--SpawnPrefab("resurrectionstone").Transform:SetPosition(inst.Transform:GetWorldPosition())
	--inst:Remove()
	
end

AddPlayerPostInit(playerPostInit)
