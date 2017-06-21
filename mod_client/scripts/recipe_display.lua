local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"


local Button = Class(Widget, function(self, parent, tooltip, image, fu)
	Widget._ctor(self, "Button")
	
	self._parent = parent
	self._fu = fu
	
	self._image = self:AddChild(image)
	
	self:SetTooltip(tooltip)
end)
function Button:OnControl(control, down)
	if Button._base.OnControl(self, control, down) then return true end
	
	if not down and control == CONTROL_ACCEPT then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		self._fu(self._parent)
		
		return true
	end
end



local Recipe_display = Class(Widget, function(self)
	Widget._ctor(self, "Recipe_display")
	self.owner = ThePlayer
	
	self.shown = false
	
	self.main_container = self:AddChild(Widget("root"))
	self.main_container:SetPosition(260,0,0)
	
	self.bg1 = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_border.tex"))
	self.bg2 = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_border.tex"))
	self.bg1:SetClickable(false)
	self.bg2:SetClickable(false)
	self.bg2:SetPosition(255,0,0)
	
	self.image_container1 = self.main_container:AddChild(Widget("root"))
	self.image_container2 = self.main_container:AddChild(Widget("root"))
	self.image_container1:SetPosition(0,0,0)
	self.image_container2:SetPosition(255,0,0)
	self.recipe = self.image_container1:AddChild(Image("images/dsmmo_recipes.xml", "none.tex"))
	self.recipe = self.image_container2:AddChild(Image("images/dsmmo_recipes.xml", "none.tex"))
	
	
	self.titlebar = self.main_container:AddChild(Image("images/dsmmo_ui.xml", "recipe_titlebar.tex"))
	self.titlebar:SetPosition(0,110,0)
	self.recipe_title = self.main_container:AddChild(Text(BODYTEXTFONT, 25))
	self.recipe_title:SetPosition(0,110,0)
	
	
	self.hide_btn = self.main_container:AddChild(Button(self,
		"Hide DsMMO",
		Image("images/ui.xml", "checkbox_on.tex"),
		--Image("images/dsmmo_ui.xml", "icon.tex"),
		self.toggle
		))
	self.hide_btn:SetPosition(-110,-110,0)
	self.hide_btn:Hide()
	
	self.show_btn = self.main_container:AddChild(Button(self,
		"Show DsMMO",
		--Image("images/ui.xml", "checkbox_off_disabled.tex"),
		Image("images/dsmmo_ui.xml", "icon.tex"),
		self.toggle
		))
	self.show_btn:SetPosition(-140,-110,0)
	
	
	self.open_btn = self.main_container:AddChild(Button(self,
		"Show outcome",
		Image("images/ui.xml", "crafting_inventory_arrow_l_hl.tex"),
		self.open_outcome
		))
	self.open_btn:SetPosition(115,0,0)
	self.open_btn:SetScale(0.5,0.5,0.5)
	
	self.close_btn = self.main_container:AddChild(Button(self,
		"Hide outcome",
		Image("images/ui.xml", "crafting_inventory_arrow_r_hl.tex"),
		self.close_outcome
		))
	self.close_btn:SetPosition(360,0,0)
	self.close_btn:SetScale(0.5,0.5,0.5)
	
	self.arrow = self.main_container:AddChild(Image("images/ui.xml", "arrow2_right.tex"))
	self.arrow:SetPosition(130,0,0)
	self.arrow:Hide()
end)


function Recipe_display:close_outcome(no_move)
	if not no_move then
		self.main_container:MoveTo(self.main_container:GetPosition(), {x=0,y=0,z=0}, .33)
	end
	self.open_btn:Show()
	self.arrow:Hide()
end
function Recipe_display:open_outcome()
	self.main_container:MoveTo(self.main_container:GetPosition(), {x=-250,y=0,z=0}, .33)
	self.open_btn:Hide()
	self.arrow:Show()
end


function Recipe_display:toggle()
	self.shown = not self.shown
	
	local pos = self.hide_btn:GetPosition()
	if self.shown then
		self.main_container:MoveTo(self.main_container:GetPosition(), {x=0,y=0,z=0}, .33)
		self.hide_btn:MoveTo({x=-140,y=pos.y,z=0}, {x=-110,y=pos.y,z=0}, .33)
		
		self.show_btn:Hide()
		self.hide_btn:Show()
		
		self:close_outcome(true)
	else
		self.main_container:MoveTo(self.main_container:GetPosition(), {x=260,y=0,z=0}, .33)
		self.show_btn:MoveTo({x=-110,y=pos.y,z=0}, {x=-140,y=pos.y,z=0}, .33)
		
		self.show_btn:Show()
		self.hide_btn:Hide()
	end
end


function Recipe_display:show_recipe(recipe, data)
	if self.recipe then
		self.recipe:Kill()
	end
	self.recipe = self.image_container1:AddChild(Image("images/dsmmo_recipes.xml", recipe .."1.tex"))
	self.recipe = self.image_container2:AddChild(Image("images/dsmmo_recipes.xml", recipe .."2.tex"))
	self.recipe_title:SetString(data.name)
	if not self.shown then
		self:toggle()
	end
end


return Recipe_display