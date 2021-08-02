----------------------------------------------------------------
-----------------------Registering-Variables--------------------

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
--[[
local validPlayerTypes = {
	dIsaac = 0,
	dMagdalene = 1,
	dCain = 2,
	dJudas = 3,
	dBlueBaby = 4,
	dEve = 5,
	dSamson = 6,
	dAzazel = 7,
	dLazarus = 8,
	dEden = 9,
	dTheLost = 10,
	dLillith = 13,
	dKeeper = 14,
	dApollyon = 15,
	dTheForgotten = 16,
	dBethany = 18,
	dJacob = 19
}
--]]

local validPlayerTypes = {
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	13,
	14,
	15,
	16,
	18,
	19
}

local spriteSheetLocations = {
	"gfx/characters/costumes/character_isaac.png",
	"gfx/characters/costumes/character_magdalene.png",
	"gfx/characters/costumes/character_cain.png",
	"gfx/characters/costumes/character_judas.png",
	"gfx/characters/costumes/character_bluebaby.png",
	"gfx/characters/costumes/character_eve.png",
	"gfx/characters/costumes/character_samson.png",
	"gfx/characters/costumes/character_azazel.png",
	"gfx/characters/costumes/character_lazarus.png",
	"gfx/characters/costumes/character_eden.png",
	"gfx/characters/costumes/character_thelost.png",
	"gfx/characters/costumes/character_lillith.png",
	"gfx/characters/costumes/character_keeper.png",
	"gfx/characters/costumes/character_apollyon.png",
	"gfx/characters/costumes/character_theforgotten.png",
	"gfx/characters/costumes/character_bethany.png",
	"gfx/characters/costumes/character_jacob.png",
}

function del:clicker(_item, _rng, player)
	local currentPlayerType = player:GetPlayerType()

	local index = {} -- Making index of validPlayerTypes
	for v, k in pairs(validPlayerTypes) do
		index[k] = v
	end

	for i = 1, 17 do
		if currentPlayerType == validPlayerTypes[i] then
			table.remove(validPlayerTypes, validPlayerTypes[i]) -- Removing currently selected character as a possible transformation
		end
	end

	local randomIntFromTable = rng:RandomInt(#validPlayerTypes) -- Storing randomly chosen position from validPlayerTypes in randomIntFromTable
	local randomPlayerType = validPlayerTypes[randomIntFromTable] -- Storing chosen playerType in randomPlayerType

	player:ChangePlayerType(randomPlayerType) -- Changing PlayerType to a random validPlayerType
	player:AddCollectible (delClickerID, 0, false, ActiveSlot.SLOT_POCKET) -- Adding Delierio Clicker to the transformed-into character as a pocket active

	table.insert(validPlayerTypes, index[currentPlayerType], currentPlayerType) -- Reinserting randomly selected character into the table

	print("                                 Player: "..player:GetName()) -- Print who the player transformed into

	local playerSprite = player:GetSprite() -- Storing GetSprite() as a var for easier use
	playerSprite:Load("001.000_player.anm2", true) -- Loading player animations for changing spritesheet
	
	for i = 1, 17 do
		if randomPlayerType == validPlayerTypes[i] then -- Checking which character the player turned into
			for ii = 0, 15 do -- Repeating 16 times for each player animation
				playerSprite:ReplaceSpritesheet(ii, spriteSheetLocations[i]) -- Replacing spritesheet for every animation
			end
		end
	end

	playerSprite:LoadGraphics() -- Refreshing the graphics to load the new spritesheet
	return true -- Play clicker animation
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
