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
	11,
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
	"gfx/characters/costumes/character_lazarus2.png",
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


function del:onGameStart()
	lazAlive = true
end
del:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, del.onGameStart)


----------------------------------------------------------------
-----------------------------Clicker----------------------------

function del:clicker(_type, rng, player)
	
	--current and target playerTypes: int
	local currentPlayer = player:GetPlayerType()

	lazExcludeID = PlayerType.PLAYER_LAZARUS2 and lazAlive or PlayerType.PLAYER_LAZARUS --Return inactive lazarus ID
	print(lazExcludeID)
	local targetPlayer = validPlayerTypes[del:returnPlayer({currentPlayer, lazExcludeID}, rng)]
	
	player:ChangePlayerType(targetPlayer) --Call clicker function with target
	player:AddCollectible(delClickerID, 0, false, ActiveSlot.SLOT_POCKET)

	print("Player: "..player:GetName()) -- Print who the player transformed into
	
	--[[
	local playerSprite = player:GetSprite()
	playerSprite:Load("001.000_player.anm2", true) --Load custom spritesheet
	
	for i = 0, 15 do
		playerSprite:ReplaceSpritesheet(i, spriteSheetLocations[targetPlayer]) --Replace spritesheets
	end

	playerSprite:LoadGraphics() --Reload sprites
	]]--

	return true --Play clicker animation
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.clicker, delClickerID)

--Return random character, excluding
--RNG is non-inclusive 
--Uwi, this is magic, but can touchy
function del:returnPlayer(exclude, rng)
	roll = rng:RandomInt(#validPlayerTypes) + 1
	if table.contains(exclude, roll) then
		return del:returnPlayer(exclude, rng)
	else
		return roll
	end
end


local lazAlive = true
function del:lazarusCheck(player)
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS then 
		lazAlive = false
	end
end
del:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, del.lazarusCheck, EntityType.ENTITY_PLAYER)


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
