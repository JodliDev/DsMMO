local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local Action_levels = require "widgets/action_levels"



local LevelBadge = Class(Badge, function(self, t, owner)
	Badge._ctor(self, t, owner)
	
	self._action_levels = nil

	--local t = self:AddChild(ImageButton("images/ui.xml", "crafting_inventory_arrow_l_hl.tex", nil, nil, nil, nil, {0.5,0.5}))
	--self.inspectcontrol = self.root:AddChild(TEMPLATES.IconButton(atlas_name, image_name, STRINGS.UI.HUD.INSPECT_SELF, false, false, function() self.owner.HUD:InspectSelf() end, {size = 40}, "self_inspect_mod.tex"))

	self.btn_openRecipe = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))

	self.btn_openRecipe:SetScale(0.5,0.5,0.5)
	self.btn_openRecipe:SetRotation(90)
	self.btn_openRecipe:SetPosition(0,-41,0)
	self.btn_openRecipe:SetOnClick(function()
		if owner._recipe_display and owner._recipe_display.inst:IsValid() then
			owner._recipe_display:close()
			owner._recipe_display = nil
		else
			owner:show_recipe()
		end
	end)
	
	--self.anim:Hide()
end)

function LevelBadge:update(action, current, max, noPulse, isNegative)
	if self._current ~= action then
		self.anim:GetAnimState():SetBuild(action .."_level_meter")
	end
	self._current = action
	
	local owner = self.owner
	
	self:SetPercent(1 / (max / (current>0 and current or 1)), max-current + 1)
	self:SetTooltip(action .."-level: " ..owner.storage.level[action])
	if not noPulse then
		if isNegative then
			self:PulseRed()
		else
			self:PulseGreen()
		end
	end
end
function LevelBadge:SetPercent(val, missing) --override SetPercent to display missing exp instead
    val = val or self.percent
    missing = missing or 0

    self.anim:GetAnimState():SetPercent("anim", 1 - val)
    self.num:SetString(tostring(missing))

    self.percent = val
end

function LevelBadge:show_recipeOpened()
	self.btn_openRecipe:SetRotation(0)
end

function LevelBadge:show_recipeClosed()
	self.btn_openRecipe:SetRotation(90)
end


function LevelBadge:OnControl(control, down)
	if LevelBadge._base.OnControl(self, control, down) then return true end
	
	if not down and control == CONTROL_ACCEPT then
		if self._action_levels and self._action_levels.inst:IsValid() then
			self._action_levels:close()
			self._action_levels = nil
		else
			self._action_levels = self.owner.ui_elements.right_root:AddChild(Action_levels(self.owner, self._current))
		end
	end
end


return LevelBadge
