local deli = RegisterMod("Delierio", 1)
local rng = RNG() --RNG is non-inclusive
local SaveState = {}

----------------------------------------------------------------
--------------------------Default-Settings----------------------

local modSettings = {

}


----------------------------------------------------------------
----------------------------Savedata----------------------------

local json = require("json")

function deli:SaveGame()
	SaveState.Settings = {}
	
	for i, v in pairs(deliSettings) do
		SaveState.Settings[tostring(i)] = deliSettings[i]
	end
    deli:SaveData(json.encode(SaveState))
end
deli:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, deli.SaveGame)

function deli:OnGameStart(isSave)
	deli:SaveGame()
	
    if deli:HasData() then	
		SaveState = json.decode(deli:LoadData())	
		
        for i, v in pairs(SaveState.Settings) do
			deliSettings[tostring(i)] = SaveState.Settings[i]
		end
    end
end
deli:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, deli.OnGameStart)