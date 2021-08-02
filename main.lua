----------------------------------------------------------------
-----------------------Registering-Variables--------------------

require("scripts.playerTables")

local del = RegisterMod("delierio", 1)
local SaveState = {}

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
	"gfx/characters/costumes/character_jacob.png"
}

----------------------------------------------------------------
--------------------------Default-Settings----------------------

local modSettings = {
	
}


----------------------------------------------------------------
-------------------------------Init-----------------------------

local delClickerID = Isaac.GetItemIdByName("Delierio Clicker")

--[[
function del:delInit()

end
]]--

----------------------------------------------------------------
------------------------------Start-----------------------------

--[[
function del:onGameStart()
	local player  = Isaac.GetPlayer(0)
	if player:GetName() == "Delierio" then
		del:delInit()
	end
end
del:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, del.onGameStart)
]]--

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


function del:clicker(_type, rng, player)
	
	--current and target playerTypes: int
	local currentPlayer = player:GetPlayerType()
	local targetPlayer = validPlayerTypes[del:returnPlayer(currentPlayer, rng)]
	
	player:ChangePlayerType(targetPlayer) --Call clicker function with target
	player:AddCollectible(delClickerID, 0, false, ActiveSlot.SLOT_POCKET)

	print("                                 Player: "..player:GetName()) -- Print who the player transformed into
	
	local playerSprite = player:GetSprite()
	playerSprite:Load("001.000_player.anm2", true) --Load custom spritesheet
	
	for i = 0, 15 do
		playerSprite:ReplaceSpritesheet(i, spriteSheetLocations[targetPlayer]) --Replace spritesheets
	end

	playerSprite:LoadGraphics() --Reload sprites

	return true --Play clicker animation
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.clicker, delClickerID)

--Return random character, excluding 
--Uwi, this is magic, but can touchy
function del:returnPlayer(exclude, rng)
	if rng:RandomInt(#validPlayerTypes) + 1 == exclude then
		return del:returnPlayer(exclude, rng)
	end
	return rng:RandomInt(#validPlayerTypes) + 1
end


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

----------------------------------------------------------------
---------------------------Functions----------------------------

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
