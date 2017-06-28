local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/templates"


local Action_levels = Class(Widget, function(self, owner, tab)
	Widget._ctor(self, "Action_levels")
    self.owner = owner
    
    
	self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(335, 0)
	
    --self.root:SetVAnchor(ANCHOR_MIDDLE)
    --self.root:SetHAnchor(ANCHOR_MIDDLE)
    --self.root:SetPosition(0,0,0)
    --self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	
    --self.center_panel = self.root:AddChild(TEMPLATES.CenterPanel(.6, nil, nil, 130, nil, nil, nil, .51, nil))
    --self.center_panel.bg:SetSize(130, 540)
    
    --self.center_panel:SetPosition(-70)
    --frame_x_scale, frame_y_scale, skipPos, x_size, y_size, topCrownOffset, bottomCrownOffset, bg_x_scale, bg_y_scale, bg_x_pos, bg_y_pos
    
    
    
	self.frame = self.root:AddChild(TEMPLATES.CurlyWindow(130, 540, .6, .6, 39, -25))
    self.frame:SetPosition(0, 20)
	self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
	
    self.frame_bg:SetScale(.51, .74)
    self.frame_bg:SetPosition(5, 7)
    
	
	self.nav_bar = self.root:AddChild(TEMPLATES.NavBarWithScreenTitle(nil, "tall"))
	local nav_pos = self.nav_bar:GetPosition()
	local nav_w, nav_h = self.nav_bar.bg:GetSize()
    self.nav_bar:SetPosition(- nav_w, nav_pos.y)
    
	--local nav_scaleX, nav_scaleY = self.nav_bar.bg:GetScale()
    --self.nav_bar.bg:SetScale(nav_scaleX, 10)
	local nav_bg_w, nav_bg_h = self.nav_bar.bg:GetSize()
    self.nav_bar.bg:SetSize(nav_bg_w, 950)
    self.nav_bar.bg:SetPosition(0, -180)
	
	
	self.buttons = {}
	self.content = {}
	
	local xp = owner.exp
	local max_exp = owner.storage.max_exp
	local colors = owner.colors
	local recipes_index = owner.recipes_index
	local skills_index = owner.skills_index
	local self_cannibalism = owner.skills.self_cannibalism
	local self_cannibalism_enabled = owner.storage.level.EAT >= self_cannibalism.min_level
	
	
	local vpos = 0
	
	
	local img_index = {
		CHOP = "axe",
		MINE = "pickaxe",
		ATTACK = "spear",
		PLANT = "carrot",
		BUILD = "hammer",
		DIG = "shovel",
		EAT = "meatballs",
		PICK = "berries"
	}
	
	for action,v in pairs(owner.storage.level) do
		local nav_btn = TEMPLATES.NavBarButton(vpos, action, function() self:setTab(action) end)

		local nav_img = nav_btn:AddChild(Image("images/inventoryimages.xml", img_index[action] ..".tex"))
		nav_img:SetScale(.5, .5)
		nav_img:SetPosition(-60,0)
		nav_btn.text:SetPosition(30,0)
		self.buttons[action] = self.nav_bar:AddChild(nav_btn)
		vpos = vpos -50

		self.content[action] = self.root:AddChild(Widget("root" ..action))
		local content = self.content[action]
		content:Hide()
		content:SetPosition(0, 270)


		local header = content:AddChild(Text(BODYTEXTFONT, 40))
		header:SetString(action)
		--header:SetColour(colors[action][1], colors[action][2], colors[action][3], 1)
		header:SetColour(unpack(colors[action]))

		local horizontal_line1 = content:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
		horizontal_line1:SetScale(1, .25)
		horizontal_line1:SetPosition(7, -30)

		local level = content:AddChild(Text(BODYTEXTFONT, 25))
		level:SetString("Level: " ..v .."\nExp: " ..xp[action] .." / " ..max_exp[action])
		level:SetHAlign(ANCHOR_LEFT)
		level:SetRegionSize(200, 80)
		level:SetPosition(-50, -60)
		
		if self_cannibalism_enabled then
			local self_cannibalism_btn = content:AddChild(ImageButton("images/inventoryimages.xml", "meatballs.tex"))
			self_cannibalism_btn:SetPosition(-170, -70)
			self_cannibalism_btn:SetScale(.5, .5)
			self_cannibalism_btn:SetTooltip("Use your " ..self_cannibalism.name .."-skill.\n Some of your " ..action .."-exp will be used to fill your health / sanity / hunger.")
			self_cannibalism_btn:SetOnClick(function()
				if self_cannibalism_btn._opened then
					self_cannibalism_btn._opened = false
					self_cannibalism_btn.image:SetTexture("images/inventoryimages.xml", "meatballs.tex")
					self_cannibalism_btn.image:SetRotation(0)
					self_cannibalism_btn.atlas = "images/inventoryimages.xml"
					self_cannibalism_btn.image_focus = "meatballs.tex"
					self_cannibalism_btn.image_normal = "meatballs.tex"
					
					self_cannibalism_btn.sanity_btn:Kill()
					self_cannibalism_btn.health_btn:Kill()
					self_cannibalism_btn.hunger_btn:Kill()
				else
					self_cannibalism_btn._opened = true
					
					self_cannibalism_btn.image:SetTexture(HUD_ATLAS, "turnarrow_icon.tex")
					self_cannibalism_btn.image:SetRotation(90)
					self_cannibalism_btn.atlas = HUD_ATLAS
					self_cannibalism_btn.image_focus = "turnarrow_icon.tex"
					self_cannibalism_btn.image_normal = "turnarrow_icon.tex"
					
					
					self_cannibalism_btn.sanity_btn = content:AddChild(ImageButton("images/inventoryimages.xml", "half_sanity.tex"))
					self_cannibalism_btn.sanity_btn:SetPosition(-170, -35)
					self_cannibalism_btn.sanity_btn:SetScale(.5, .5)
					self_cannibalism_btn.sanity_btn:SetTooltip("Sacrifice " ..action .."-exp to gain sanity")
					self_cannibalism_btn.sanity_btn:SetOnClick(function()
						SendModRPCToServer(GetModRPC("DsMMO", "use_eat_skill"), action, "sanity")
						self:close()
					end)
					
					self_cannibalism_btn.health_btn = content:AddChild(ImageButton("images/inventoryimages.xml", "half_health.tex"))
					self_cannibalism_btn.health_btn:SetPosition(-170, 0)
					self_cannibalism_btn.health_btn:SetScale(.5, .5)
					self_cannibalism_btn.health_btn:SetTooltip("Sacrifice " ..action .."-exp to gain health")
					self_cannibalism_btn.health_btn:SetOnClick(function()
						SendModRPCToServer(GetModRPC("DsMMO", "use_eat_skill"), action, "health")
						self:close()
					end)
					
					self_cannibalism_btn.hunger_btn = content:AddChild(ImageButton("images/inventoryimages.xml", "half_hunger.tex"))
					self_cannibalism_btn.hunger_btn:SetPosition(-170, 35)
					self_cannibalism_btn.hunger_btn:SetScale(.5, .5)
					self_cannibalism_btn.hunger_btn:SetTooltip("Sacrifice " ..action .."-exp to gain hunger")
					self_cannibalism_btn.hunger_btn:SetOnClick(function()
						SendModRPCToServer(GetModRPC("DsMMO", "use_cannibalism_skill"), action, "hunger")
						self:close()
					end)
				end
			end)
		end

		local horizontal_line2 = content:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
		horizontal_line2:SetScale(1, .25)
		horizontal_line2:SetPosition(7, -90)

		--local level = content:AddChild(Text(BODYTEXTFONT, 30))
		--level:SetString("Learned rituals")
		--level:SetPosition(0, -110)

		local header_rituals = Text(BODYTEXTFONT, 30)
		header_rituals:SetString("Learned rituals:")



		local elements = {header_rituals}
		local not_learned = {}
		self:fill_list(recipes_index[action], elements, not_learned, v)

		local header_skills = Text(BODYTEXTFONT, 30)
		header_skills:SetString("Learned skills:")
		table.insert(elements, header_skills)

		self:fill_list(skills_index[action], elements, not_learned, v)
		
		if table.getn(not_learned) then
			print("qwe" ..table.getn(not_learned))
			local header_not_learned = Text(BODYTEXTFONT, 30)
			header_not_learned:SetString("Not learned yet:")
			table.insert(elements, header_not_learned)
			
			table.sort(not_learned, function(a,b)
				print(a[1].min_level .." < " ..b[1].min_level)
				return a[1].min_level < b[1].min_level
			end)
			
			
			for i,el in ipairs(not_learned) do
				table.insert(elements, el[2])
			end
		end
		
		local list = content:AddChild(ScrollableList(elements, 200, 370, 40, 3, nil, nil, nil, nil, nil, 0))
		list:SetPosition(70, -280)
	end
	
	
	local w, h = self.frame_bg:GetSize()
	
	self.out_pos = Vector3(.5 * w, 0, 0)
	self.in_pos = Vector3(-.95 * w, 0, 0)

	self:MoveTo(self.out_pos, self.in_pos, .33, function() self.settled = true end)
	
	
    if not TheInput:ControllerAttached() then
        self.close_button = self.root:AddChild(TEMPLATES.SmallButton(STRINGS.UI.PLAYER_AVATAR.CLOSE, 26, .5, function() self:close() end))
        self.close_button:SetPosition(0, -269)
    end
	
	if tab then
		self:setTab(tab)
	end
	
	self.start_pos = owner.player:GetPosition()
	self:StartUpdating()
end)


function Action_levels:fill_list(array, elements, not_learned, player_lvl)
	if array then
		for lvl,recipes in pairs(array) do
			for k,recipe in pairs(recipes) do
				local btn = TEMPLATES.TextMenuItem("Lvl " ..lvl..": " ..recipe.name, recipe.description and nil or function()
					self.owner:show_recipe(recipe.key)
					self:close()
				end)
				
				if recipe.description then
					btn:SetTooltip(recipe.description)
				else
					btn.text:SetColour(unpack(GOLD))
					btn.OnGainFocus = function(self)
						self.text:SetColour(unpack(WHITE))
					end
					btn.OnLoseFocus = function(self)
						self.text:SetColour(unpack(GOLD))
					end
				end
				
				if player_lvl >= lvl then
					table.insert(elements, btn)
				else
					table.insert(not_learned, {recipe, btn})
				end
			end
		end
	end
end

function Action_levels:setTab(tab)
	if self.lasttab then
		self.buttons[self.lasttab]:Unselect()
		self.content[self.lasttab]:Hide()
	end
	self.lasttab = tab
	
	self.buttons[tab]:Select()
	self.content[tab]:Show()
	
	self.owner:show_badge(tab, true)
end

function Action_levels:OnUpdate(dt)
	local pos = self.owner.player:GetPosition()
	local start_pos = self.start_pos
	
	if math.abs(pos.x - start_pos.x) + math.abs(pos.y - start_pos.y) + math.abs(pos.z - start_pos.z) > 6 then
		self:close()
	end
end

function Action_levels:close()
	self:StopUpdating()
	self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

return Action_levels