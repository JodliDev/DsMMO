local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local Recipe_display = Class(Widget, function(self, owner, recipe)
	Widget._ctor(self, "Recipe_display")
	self.owner = owner
	
	self:SetPosition(-130, 0, 0)
	
	self.main_container = self:AddChild(Widget("root"))
	--self.main_container:SetPosition(260,0,0)
	
	self.bg1 = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_border.tex"))
	self.bg2 = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_border.tex"))
	self.bg1:SetClickable(false)
	self.bg2:SetClickable(false)
	self.bg2:SetPosition(255,0,0)
	
	self.image_container1 = self.main_container:AddChild(Widget("root"))
	self.image_container2 = self.main_container:AddChild(Widget("root"))
	self.image_container1:SetPosition(0,0,0)
	self.image_container2:SetPosition(255,0,0)
	
	self.titlebar = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_titlebar.tex"))
	self.titlebar:SetPosition(0,110,0)
	self.recipe_title = self.main_container:AddChild(Text(BODYTEXTFONT, 25))
	self.recipe_title:SetPosition(0,110,0)
	
	self.titlebar = self.main_container:AddChild(Image(HUD_ATLAS, "craft_slot.tex"))
	self.titlebar:SetPosition(-80,-110,0)
	self.titlebar:SetScale(1,0.5,0)
	self.recipe_chance = self.main_container:AddChild(Text(BODYTEXTFONT, 20))
	self.recipe_chance:SetPosition(-80,-110,0)
	
	
	
	--self.btn_open = self.main_container:AddChild(ImageButton("images/ui.xml", "crafting_inventory_arrow_l_hl.tex"))
	self.btn_open = self.main_container:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
	self.btn_open:SetPosition(115,0,0)
	self.btn_open:SetScale(-0.5,0.5,0.5)
	self.btn_open:SetOnClick(function()
		self:open_outcome()
	end)
	--self.btn_close = self.main_container:AddChild(ImageButton("images/ui.xml", "crafting_inventory_arrow_r_hl.tex"))
	self.btn_close = self.main_container:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
	self.btn_close:SetPosition(370,0,0)
	self.btn_close:SetScale(0.5,0.5,0.5)
	self.btn_close:SetOnClick(function()
		self:close_outcome()
	end)
	
	self.arrow = self.main_container:AddChild(Image("images/ui.xml", "arrow2_right.tex"))
	self.arrow:SetPosition(130,0,0)
	self.arrow:Hide()
	
	
	
	self.owner.ui_elements.badge:show_recipeOpened()
	self.main_container:MoveTo({x=260,y=0,z=0}, {x=0,y=0,z=0}, .33)
	
	self:show_recipe(recipe)
	self.start_pos = self.owner.player:GetPosition()
	self:StartUpdating()
end)


function Recipe_display:close_outcome(no_move)
	if not no_move then
		self.main_container:MoveTo(self.main_container:GetPosition(), {x=0,y=0,z=0}, .33)
	end
	self.btn_open:Show()
	self.arrow:Hide()
end
function Recipe_display:open_outcome()
	self.main_container:MoveTo(self.main_container:GetPosition(), {x=-250,y=0,z=0}, .33)
	self.btn_open:Hide()
	self.arrow:Show()
end

function Recipe_display:OnUpdate(dt)
	local pos = self.owner.player:GetPosition()
	local start_pos = self.start_pos
	
	if math.abs(pos.x - start_pos.x) + math.abs(pos.y - start_pos.y) + math.abs(pos.z - start_pos.z) > 6 then
		self:close()
	end
end

function Recipe_display:close()
	self:StopUpdating()
	self.owner.ui_elements.badge:show_recipeClosed()
	self.main_container:MoveTo({x=0,y=0,z=0}, {x=260,y=0,z=0}, .1, function() self:Kill() end)
end


function Recipe_display:show_recipe(recipe)
	if not self.owner.recipes[recipe] then
		self._recipe_el = self.image_container1:AddChild(Image("images/dsmmo_recipes.xml", "none.tex"))
		self._recipe_el = self.image_container2:AddChild(Image("images/dsmmo_recipes.xml", "none.tex"))
		return
	end
	if self._recipe_el then
		self._recipe_el:Kill()
	end
	
	local recipe_a = self.owner.recipes[recipe]
	local lvl = self.owner.storage.level[recipe_a.tree]
	
	if self._min_level_el then
		self._min_level_el:Kill()
	end
	if recipe_a.min_level > lvl then
		self._min_level_el = self.main_container:AddChild(Text(BODYTEXTFONT, 40))
		self._min_level_el:SetPosition(0,10,0)
		self._min_level_el:SetRotation(45)
		self._min_level_el:SetColour({1,0,0,1})
		self._min_level_el:SetString("Min level: " ..recipe_a.min_level)
		
		self.recipe_chance:SetString("0% chance")
	else
		self.recipe_chance:SetString((self.owner:get_chance(recipe_a.chance, lvl)*100) .."% chance")
	end
	
	
	self._recipe_el = self.image_container1:AddChild(Image("images/dsmmo_recipes.xml", recipe .."1.tex"))
	self._recipe_el = self.image_container2:AddChild(Image("images/dsmmo_recipes.xml", recipe .."2.tex"))
	self.recipe_title:SetString(recipe_a.name)
end


return Recipe_display