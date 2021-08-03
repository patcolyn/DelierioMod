--[[
TODO: Remove all player starting items from all pools
TODO: Health tracker
TODO: Fix item acquisition on change
TODO: translate player position to forgotten's body, currently at soul
TODO: Keeper spawning flies from red removal
TODO: Extra Esau bug
]]--
----------------------------------------------------------------
-----------------------Registering-Variables--------------------

_debug = true

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

COLLECTIBLE_DYSMORPHIA = Isaac.GetItemIdByName("Dysmorphia")

--[[
function del:delInit()

end
]]--


----------------------------------------------------------------
------------------------------Start-----------------------------

function del:onGameStart()
	lazAlive = true
end
del:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, del.onGameStart)


----------------------------------------------------------------
-----------------------------Clicker----------------------------

function del:dysmorphia(_type, rng, player)
	
	local currentPlayer = player:GetPlayerType()
	local currentPlayerName = player:GetName()
	
	--Lazarus' Rags check
	lazExcludeID = PlayerType.PLAYER_LAZARUS
	if lazAlive then
		lazExcludeID = PlayerType.PLAYER_LAZARUS2
	end
	
	if currentPlayer ~= PlayerType.PLAYER_ESAU then --Esau is rolled for too for SOME REASON
		local targetPlayer = table.random(validPlayerTypes, {currentPlayer, lazExcludeID}, rng)
		
		player:ChangePlayerType(targetPlayer) --Call clicker function with target
		--player:AddCollectible(COLLECTIBLE_DYSMORPHIA, 0, false, ActiveSlot.SLOT_POCKET)
		
		
		targetPlayerName = player:GetName()
		print("From: " .. currentPlayerName .. " To: " .. targetPlayerName)
		if currentPlayer == targetPlayer then print("AGHHHHHHHHHHHHHHH") end
		
		--[[
		local playerSprite = player:GetSprite()
		playerSprite:Load("001.000_player.anm2", true) --Load custom spritesheet
		
		for i = 0, 15 do
			playerSprite:ReplaceSpritesheet(i, spriteSheetLocations[targetPlayer]) --Replace spritesheets
		end

		playerSprite:LoadGraphics() --Reload sprites
		]]--

		return true --Play pick up animation
	end
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.dysmorphia, COLLECTIBLE_DYSMORPHIA)


lazAlive = true
function del:lazarusCheck(player, dmg)
	player = player:ToPlayer() --cast Entity to EntityPlayer
	hp = player:GetHearts() + player:GetSoulHearts() --health reduction applied after MC_ENTITY_TAKE_DMG
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and hp - dmg == 0 then 
		lazAlive = false
	end
end
del:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, del.lazarusCheck, EntityType.ENTITY_PLAYER)


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

--Returns if an element is in a table
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

--Returns a random element in a table
function table.random(randTable, exclude, rng)
	roll = rng:RandomInt(#randTable) + 1
	
	if table.contains(exclude, randTable[roll]) then
		return table.random(randTable, exclude, rng)
	else
		return randTable[roll]
	end
end