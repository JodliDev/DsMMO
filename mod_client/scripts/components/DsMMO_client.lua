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


local DSMMO_ACTIONS = {
	["CHOP"] = {1, 0.6, 0},
	["MINE"] = {1, 1, 0.0},
	["ATTACK"] = {0.7, 0, 0},
	["PLANT"] = {1, 0, 0},
	["BUILD"] = {0, 0, 1},
	["DIG"] = {0.3, 0.3, 0},
	["EAT"] = {1, 0, 1},
	["PICK"] = {0, 1, 1}
}

local RECIPES = {
	amulet = {
		name="Ritual of death",
		tree="EAT",
		min_level=5
	},
	deerclops_eyeball = {
		name="Ritual of a new life",
		tree="EAT",
		min_level=8
	},
	
	molehill = {
		name="Ritual of mole infestation",
		tree="DIG",
		min_level=2
	},
	shovel = {
		name="Ritual of mole attraction",
		tree="DIG",
		min_level=3
	},
	pitchfork = {
		name="Ritual of roman streets",
		tree="DIG",
		min_level=5
	},
	
	coontail = {
		name="Ritual of pussy love",
		tree="BUILD",
		min_level=1
	},
	cave_banana_cooked = {
		name="Ritual of dumb monkeys",
		tree="BUILD",
		min_level=2
	},
	pond = {
		name="Ritual of the lady without water",
		tree="BUILD",
		min_level=3
	},
	fish = {
		name="Ritual of splishy splashy",
		tree="BUILD",
		min_level=3
	},
	walrus_camp = {
		name="Ritual of arctic fishing",
		tree="BUILD",
		min_level=4
	},
	walrus_tusk = {
		name="Ritual of whalers feast",
		tree="BUILD",
		min_level=4
	},
	houndstooth = {
		name="Ritual of puppy love",
		tree="BUILD",
		min_level=5
	},
	houndstooth = {
		name="Ritual of puppy love",
		tree="BUILD",
		min_level=5
	},
	batwing = {
		name="Ritual of... I am Batman!",
		tree="BUILD",
		min_level=6
	},
	pigskin = {
		name="Ritual of Aquarius",
		tree="BUILD",
		min_level=6
	},
	armorsnurtleshell = {
		name="Ritual of escargot",
		tree="BUILD",
		min_level=6
	},
	tallbirdegg = {
		name="Ritual of Saurons bird",
		tree="BUILD",
		min_level=7
	},
	firepit = {
		name="Ritual of the pigable flame",
		tree="BUILD",
		min_level=8
	},
	skeleton_player = {
		name="Ritual of rerevival",
		tree="BUILD",
		min_level=9
	},
	campfire = {
		name="Ritual of homing flame",
		tree="BUILD",
		min_level=10
	},
	
	berries = {
		name="Ritual of redness",
		tree="PLANT",
		min_level=3
	},
	berries_juicy = {
		name="Ritual of red juiciness",
		tree="PLANT",
		min_level=4
	},
	cave_banana = {
		name="Ritual of bananana",
		tree="PLANT",
		min_level=6
	},
	livinglog = {
		name="Ritual of magic mushrooms",
		tree="PLANT",
		min_level=8
	},
	
	twigs = {
		name="Ritual of the longest Twig",
		tree="PICK",
		min_level=2
	},
	cutgrass = {
		name="Ritual of reggae dreams",
		tree="PICK",
		min_level=3
	},
	lightbulb = {
		name="Ritual of shiny balls",
		tree="PICK",
		min_level=5
	},
	cutreeds = {
		name="Ritual of Poe",
		tree="PICK",
		min_level=7
	}
}
local SKILLS = {
	fireflies= {
		name="Ghosty fireflies",
		tree="PICK",
		min_level=1
	},
	hungry_attack = {
		name="Hungry fighter",
		tree="EAT",
		min_level=1
	},
	self_cannibalism = {
		name="Self-cannibalism",
		tree="EAT",
		min_level=3
	},
	attack = {
		name="Explosive touch",
		tree="ATTACK",
		min_level=1
	},
	attacked = {
		name="Beetaliation",
		tree="ATTACK",
		min_level=2
	},
	fertilize = {
		name="Double the shit",
		tree="PLANT",
		min_level=1
	},
	harvest = {
		name="Plant another day",
		tree="PLANT",
		min_level=2
	},
	dig = {
		name="Treasure hunter",
		tree="DIG",
		min_level=1
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


function onRecipe(player)
	local self = player.components.DsMMO_client
	print("recipe: >" ..self.storage.recipe:value() .."<")
	
	local k = self.storage.recipe:value()
	if RECIPES[k] then
		self._ui_elements.recipe_display:show_recipe(k, RECIPES[k])
	end
end


--function onNewstate(player, state)
	--if player.bufferedaction then
		--local self = player.components.DsMMO_client
		--self.bufferedaction = player.bufferedaction.action.id
	--end
--end

function onPerformaction(player, data)
	local self = player.components.DsMMO_client
	local action = player.bufferedaction or self.bufferedaction
	if action then
		local actionId = action.action.id
		
		if actionId == "EAT" then
			if player.replica.hunger:GetPercent() < 100 and action.invobject then
				--TODO: it doesnt check if the item has hungervalue - but dont know how to do that localy
				self:get_experience("EAT")
			end
		elseif actionId == "FERTILIZE" or actionId == "HARVEST" then
			self:get_experience("PLANT")
		elseif actionId == "REPAIR" or actionId == "HAMMER" then
			self:get_experience("BUILD")
		elseif actionId == "TERRAFORM" then
			self:get_experience("DIG")
		elseif action == "DEPLOY" then
			self:get_experience(DEPLOY_PLANT_ACTIONS[action.invobject.prefab] and "PLANT" or "BUILD")
		elseif DSMMO_ACTIONS[actionId] then
			self:get_experience(actionId)
		end
	end
end

function onAttacked(player)
	local self = player.components.DsMMO_client
	self:get_experience("ATTACK")
end


local DsMMO_client = Class(function(self, player)
	
	self.player = player
	self.bufferedaction = nil
	self._ui_elements = {}
	
	
	local old_ClearBufferedAction = player.ClearBufferedAction
	
	player.ClearBufferedAction = function(...)
		if player.bufferedaction then
			self.bufferedaction = player.bufferedaction
		end
		old_ClearBufferedAction(...)
	end
	
	player:ListenForEvent("performaction", onPerformaction)
	
	
	
	
	--player:ListenForEvent("startstarving", onStartStarving)
	--player:ListenForEvent("stopstarving", onStopStarving)
	
	
	if not player.components.DsMMO then
		print("server")
		player.DsMMO_enabled = net_event(player.GUID, "DsMMO_enabled", "DsMMO_enabled")
	end
	--player:ListenForEvent("DsMMOenabled", onEnable)
	player:ListenForEvent("DsMMO_enabled", function() print("enableListener") end)
	self:create_netListeners()
	SendModRPCToServer(MOD_RPC["DsMMO"]["client_enabled"])
end)


function DsMMO_client:create_netListeners()
	print("Enable client")
	local player = self.player
	--if TheWorld.ismastersim then
	if player.components.DsMMO then
		print("isServer")
		self.storage = player.components.DsMMO
	else
		print("isClient")
		self.storage = {}
		self:create_array()
		self.storage.recipe = net_string(player.GUID, "DsMMO.recipe", "DsMMO.recipe")
	end
	player:ListenForEvent("DsMMO.recipe", onRecipe)
end



function DsMMO_client:create_array()
	local player = self.player
	local guid = player.GUID
	self.storage.exp_left = {}
	self.storage.net_level = {}
	--self.enabled_extras = {}
	
	
	for k,v in pairs(DSMMO_ACTIONS) do
		print("DsMMO.expleft." ..k)
		self.storage.exp_left[k] = net_uint(guid, "DsMMO.expleft." ..k)
		self.storage.net_level[k] = net_ushortint(guid, "DsMMO.level." ..k)
		
		player:ListenForEvent("DsMMO.expleft." ..k, function(player, t)
			print("123" ..k)
		end)
	end
end

function DsMMO_client:add_display(ui)
	print("add_display")
	self._ui_elements = ui
end

function DsMMO_client:get_experience(action)
	local exp_left = self.storage.exp_left[action]:value()
	self:createIndicator(exp_left, DSMMO_ACTIONS[action])
	self.storage.exp_left[action]:set_local(exp_left-1)
end

function DsMMO_client:createIndicator(msg, color)
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

	--indicator:MoveToFront()
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

return DsMMO_client