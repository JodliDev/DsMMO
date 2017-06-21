GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )


Assets = {
	Asset("ATLAS", "images/dsmmo_recipes.xml"),
	Asset("ATLAS", "images/dsmmo_ui.xml")
}

local ui_elements = {}


function add_recipeDisplay(self)
	print("add_recipeDisplay")
	local recipe_display_fu = GLOBAL.require "recipe_display"
	--recipe_display = self.top_root:AddChild(recipe_display_fu())
	ui_elements.recipe_display = self.bottomright_root:AddChild(recipe_display_fu())
	--recipe_display = self:AddChild(recipe_display_fu())
	--recipe_display:SetPosition(-50, 100, 0)
	ui_elements.recipe_display:SetPosition(-130, 270, 0)
	--recipe_display:SetPosition(0, -150, 0)
	--recipe_display = self:AddChild(recipe_display_fu())
	--recipe_display:SetPosition(-50, -300, 0)
end

--if not GLOBAL.TheNet or not GLOBAL.TheNet:GetIsServer() then
--if not GLOBAL.TheNet or not GLOBAL.TheNet:IsDedicated() then

	AddClassPostConstruct("widgets/controls", add_recipeDisplay)

	
	print("init")
	AddPlayerPostInit(function(player)
			--player:AddComponent("DsMMO_client")
			--player.components.DsMMO_client:add_display(ui_elements)
		
		if GLOBAL.TheWorld.ismastersim then --means that this is a local world without caves - so we have to wait for DsMMO to initialize first
			print("local world")
			player:DoTaskInTime(0, function(player) 
				player:AddComponent("DsMMO_client")
				player.components.DsMMO_client:add_display(ui_elements)
			
			end)
		else
			player:AddComponent("DsMMO_client")
			player.components.DsMMO_client:add_display(ui_elements)
		end
	end)
--end