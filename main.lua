local del = RegisterMod("delierio", 1)
local rng = RNG() --RNG is non-inclusive
local SaveState = {}


----------------------------------------------------------------
--------------------------Default-Settings----------------------

local modSettings = {
	
}


----------------------------------------------------------------
-------------------------------Init-----------------------------

delClickerID = Isaac.GetItemIdByName("Delierio Clicker")

function del:delInit()

end


----------------------------------------------------------------
------------------------------Start-----------------------------

function del:onGameStart()
	local player  = Isaac.GetPlayer(0)
	if player:GetName() == "Delierio" then
		del:delInit()
	end
end
del:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, del.onGameStart)


----------------------------------------------------------------
-----------------------------Clicker----------------------------

validPlayerTypes = {}

function del:clicker(_item, _rng, player)
	--print(_item, _rng, player)
	
	player:ChangePlayerType(rng:RandomInt(17))
	player:AddCollectible (delClickerID, 0, false, ActiveSlot.SLOT_POCKET)
	
	print("                                 Player: "..player:GetName())
	
	playersprite = player:GetSprite()
	playersprite:Load("001.000_player.anm2", true)
	for i = 0, 15 do
		playersprite:ReplaceSpritesheet(i, "gfx/characters/costumes/character_delierio.png")
	end
	playersprite:LoadGraphics()
	
	
	return true --Play clicker animation
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.clicker, delClickerID, rng:RandomInt(18))

 
----------------------------------------------------------------
----------------------------Savedata----------------------------

local json = require("json")

function del:SaveGame()
--Saves gamedata to /The Binding of Isaac Rebirth/data/delerio

	SaveState.Settings = {}
	
	for i, v in pairs(modSettings) do
		SaveState.Settings[tostring(i)] = modSettings[i]
	end
    del:SaveData(json.encode(SaveState))
end

del:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, del.SaveGame)


function del:loadData(isSave)
--Loads gamedata from /The Binding of Isaac Rebirth/data/delerio
	
    if del:HasData() then	
		SaveState = json.decode(del:LoadData())	
		
        for i, v in pairs(SaveState.Settings) do
			modSettings[tostring(i)] = SaveState.Settings[i]
		end
    end
end
del:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, del.loadData)
