--[[
TODO: Remove all player starting items from all pools
TODO: Health tracker
TODO: Fix item acquisition on change
TODO: Keeper spawning flies from red heart removal
TODO: Dysmorphia dmg type similar to Breath of Life
TODO: settings save across runs
TODO: Fix all non-Delierio characters
TODO: Player grid trapped check
TODO: Ramping clicker damage
]]--
----------------------------------------------------------------
------------------------------Init------------------------------

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

local defaultCooldown = 5*30
local dysmorphiaCooldown = defaultCooldown --Delay in seconds for damage
local dysmorphiaTimer = defaultCooldown

local lazAlive = true

----------------------------------------------------------------
--------------------------Default-Settings----------------------

local defaultSettings = {
	["lazAlive"] = true,
	["dysmorphiaCooldown"] = defaultCooldown,
	["dysmorphiaTimer"] = defaultCooldown
}

local runVariables = defaultSettings

----------------------------------------------------------------
------------------------------Start-----------------------------

function del:onGameStart()
	
	lazAlive = true
	dysmorphiaTimer = defaultCooldown
end
del:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, del.onGameStart)


----------------------------------------------------------------
-----------------------------Clicker----------------------------

local COLLECTIBLE_DYSMORPHIA = Isaac.GetItemIdByName("Dysmorphia")

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
		
		targetPlayerName = player:GetName()
		print("From: " .. currentPlayerName .. " To: " .. targetPlayerName)
		if currentPlayer == targetPlayer then print("AGHHHHHHHHHHHHHHH") end --Please never trigger, I am going mad
		
		--[[
		local playerSprite = player:GetSprite()
		playerSprite:Load("001.000_player.anm2", true) --Load custom spritesheet
		
		for i = 0, 15 do
			playerSprite:ReplaceSpritesheet(i, spriteSheetLocations[targetPlayer]) --Replace spritesheets
		end

		playerSprite:LoadGraphics() --Reload sprites
		]]--
		
		dysmorphiaTimer = defaultCooldown
		
		return true --Play pick up animation
	end
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.dysmorphia, COLLECTIBLE_DYSMORPHIA)


function del:dysmorphiaDamage()
	local player = Isaac.GetPlayer(0)
	
	--Start damage countdown at full charge
	if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == Isaac.GetItemConfig():GetCollectible(COLLECTIBLE_DYSMORPHIA).MaxCharges then
		
		dysmorphiaTimer = (dysmorphiaTimer - 1) % (dysmorphiaCooldown) --increment, wrap on damage
		print(dysmorphiaTimer)
		
		
		
		local sound = SoundEffect.SOUND_HUSH_GROWL
		local volume = 0.3
		--TODO: Ugly if chain, FIX
		if dysmorphiaTimer == 80 then
			SFXManager():Play(sound, volume, 0, false, 1.5, 0)
		elseif dysmorphiaTimer == 55 then 
			SFXManager():Play(sound, volume, 0, false, 2, 0)
		
		elseif dysmorphiaTimer == 35 then
			SFXManager():Play(sound, volume, 0, false, 3, 0)
		
		elseif dysmorphiaTimer == 20 then
			SFXManager():Play(sound, volume, 0, false, 4, 0)
			
		elseif dysmorphiaTimer == 10 then
			SFXManager():Play(sound, volume, 0, false, 5, 0)

		elseif dysmorphiaTimer == 0 then
			player:TakeDamage(1.0, 0, EntityRef(player), 0) --Take damage from self
		end
	end
end
del:AddCallback(ModCallbacks.MC_POST_UPDATE, del.dysmorphiaDamage) --30/second


function del:lazarusCheck(entity, dmgAmount, flags, source)
	local player = entity:ToPlayer() --cast Entity to EntityPlayer
	local hp = player:GetHearts() + player:GetSoulHearts() --health reduction applied after MC_ENTITY_TAKE_DMG

	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and hp - dmgAmount == 0 then 
		lazAlive = false
	end
end
del:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, del.lazarusCheck, EntityType.ENTITY_PLAYER)


----------------------------------------------------------------
----------------------------Savedata----------------------------

local json = require("json")

--Saves gamedata to /The Binding of Isaac Rebirth/data/delerio
function del:SaveGame()
	SaveState.Settings = {}
	
	for i, v in pairs(runVariables) do
		SaveState.Settings[tostring(i)] = runVariables[i]
	end
	
    del:SaveData(json.encode(SaveState))
end

del:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, del.SaveGame)


--Loads gamedata from /The Binding of Isaac Rebirth/data/delerio
function del:loadData(isSave)
    if del:HasData() then	
		SaveState = json.decode(del:LoadData())	
		
        for i, v in pairs(SaveState.Settings) do
			runVariables[tostring(i)] = SaveState.Settings[i]
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
