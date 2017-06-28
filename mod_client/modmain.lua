--GLOBAL.CHEATS_ENABLED = true
--GLOBAL.require( 'debugkeys' )
Assets = {
	Asset("ANIM", "anim/ATTACK_level_meter.zip"),
	Asset("ANIM", "anim/BUILD_level_meter.zip"),
	Asset("ANIM", "anim/CHOP_level_meter.zip"),
	Asset("ANIM", "anim/DIG_level_meter.zip"),
	Asset("ANIM", "anim/EAT_level_meter.zip"),
	Asset("ANIM", "anim/MINE_level_meter.zip"),
	Asset("ANIM", "anim/PICK_level_meter.zip"),
	Asset("ANIM", "anim/PLANT_level_meter.zip"),
	
	Asset("ATLAS", "images/dsmmo_recipes.xml"),
	Asset("ATLAS", "images/dsmmo_ui.xml")
}

local ui_elements = {}


--if not GLOBAL.TheNet or not GLOBAL.TheNet:GetIsServer() then
if not GLOBAL.TheNet or not GLOBAL.TheNet:IsDedicated() then
	AddClassPostConstruct("widgets/statusdisplays", function(self) ui_elements.statusdisplays = self end)
	AddClassPostConstruct("widgets/controls", function(self) ui_elements.right_root = self.right_root end)
	
	AddPlayerPostInit(function(player)
		--if not GLOBAL.TheWorld.ismastersim and not MOD_RPC["DsMMO"] then
		if not MOD_RPC["DsMMO"] then
			AddModRPCHandler("DsMMO", "client_enabled", function() print("local RPC2??????") end)
			AddModRPCHandler("DsMMO", "client_is_setup", function() print("local RPC1??????") end)
			AddModRPCHandler("DsMMO", "use_cannibalism_skill", function() print("local RPC1??????") end)
		end
		player:DoTaskInTime(1, function(player) --we have to wait for the RPCHandler and also want to initialize after DsMMO
			player:AddComponent("DsMMO_client")
			player.components.DsMMO_client:add_display(ui_elements)
		end)
	end)
end