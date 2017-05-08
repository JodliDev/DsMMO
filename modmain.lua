local TUNING = GLOBAL.TUNING

GLOBAL.CHEATS_ENABLED = true

GLOBAL.require( 'debugkeys' )




function playerPostInit(player)
	player:AddComponent("DsMMO")
end

AddPlayerPostInit(playerPostInit)
