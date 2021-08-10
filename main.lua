--[[ Ordered in priority
TODO: Health tracker
TODO: Fix item acquisition on change
TODO: Remove all player starting items from all pools
TODO: Fix all non-Delierio characters

TODO: Lazarus2 Anemic effect persistent across switching

TODO: Settings save across runs

TODO: Keeper spawning flies from red heart removal

TODO: Prevent vanilla completion marks
TODO: Dysmorphia dmg type similar to Breath of Life
TODO: Player grid trapped check
]]--
----------------------------------------------------------------
------------------------------Init------------------------------

require("scripts.playerTables")

local del = RegisterMod("delierio", 1)
local SaveState = {}

local playerTypeWhitelist = {
	PlayerType.PLAYER_ISAAC,
	PlayerType.PLAYER_MAGDALENA,
	PlayerType.PLAYER_CAIN,
	PlayerType.PLAYER_JUDAS,
	PlayerType.PLAYER_XXX,
	PlayerType.PLAYER_EVE,
	PlayerType.PLAYER_SAMSON,
	PlayerType.PLAYER_AZAZEL,
	PlayerType.PLAYER_LAZARUS,
	PlayerType.PLAYER_EDEN,
	PlayerType.PLAYER_THELOST,
	PlayerType.PLAYER_LAZARUS2,
	PlayerType.PLAYER_LILITH,
	PlayerType.PLAYER_KEEPER,
	PlayerType.PLAYER_APOLLYON,
	PlayerType.PLAYER_THEFORGOTTEN,
	PlayerType.PLAYER_BETHANY,
	PlayerType.PLAYER_JACOB
}

backDropList = {}
for i = 1, 60 do
	backDropList[i] = i
end

--Backdrops crash the game or are not compatible with a 1x1 room
backDropBlacklist = {
	BackdropType.BACKDROP_NULL,
	BackdropType.MEGA_SATAN,
	BackdropType.ERROR_ROOM,
	BackdropType.DUNGEON,
	BackdropType.PLANETARIUM,
	BackdropType.CLOSET,
	BackdropType.CLOSET_B,
	BackdropType.DOGMA,
	BackdropType.DUNGEON_GIDEON,
	BackdropType.DUNGEON_ROTGUT,
	BackdropType.DUNGEON_BEAST,
	BackdropType.MINES_SHAFT,
	BackdropType.ASHPIT_SHAFT
}

--TODO: redo as for-loop
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

--Blacklist for Dysmorphia charging
local chargeEntityBlacklist = {
	EntityType.ENTITY_FIREPLACE,
	EntityType.ENTITY_SHOPKEEPER
}

local startingItems = {
	PLAYER_ISAAC = {
		CollectibleType.COLLECTIBLE_D6
	},
	PLAYER_MAGDALENA = {
		CollectibleType.COLLECTIBLE_YUM_HEART
	},
	PLAYER_CAIN = {
		CollectibleType.COLLECTIBLE_LUCKY_FOOT,
		TrinketType.TRINKET_PAPER_CLIP
	},
	PLAYER_JUDAS = {
		CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL
	},
	PLAYER_XXX = {
		CollectibleType.COLLECTIBLE_POOP
	},
	PLAYER_EVE = {
		CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON,
		CollectibleType.COLLECTIBLE_DEAD_BIRD,
		CollectibleType.COLLECTIBLE_RAZOR_BLADE
	},
	PLAYER_SAMSON = {
		CollectibleType.COLLECTIBLE_BLOODY_LUST,
		TrinketType.TRINKET_CHILDS_HEART
	},
	PLAYER_AZAZEL = {},
	PLAYER_LAZARUS = {
		CollectibleType.COLLECTIBLE_ANEMIC
	},
	PLAYER_EDEN = {"AGGGHHHH"},
	PLAYER_THELOST = {
		CollectibleType.COLLECTIBLE_ETERNAL_D6
	},
	PLAYER_LAZARUS2 = {},
	PLAYER_LILITH = {
		CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION,
		CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS
	},
	PLAYER_KEEPER = {},
	PLAYER_APOLLYON = {},
	PLAYER_THEFORGOTTEN = {},
	PLAYER_BETHANY = {
		CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
	},
	PLAYER_JACOB = {}
}

local COLLECTIBLE_DYSMORPHIA = Isaac.GetItemIdByName("Dysmorphia")
local defaultCooldown = 5*30
local dysmorphiaCooldown = defaultCooldown --Delay in seconds for damage
local dysmorphiaTimer = defaultCooldown
local dysmorphiaMaxCharges = Isaac.GetItemConfig():GetCollectible(COLLECTIBLE_DYSMORPHIA).MaxCharges

local lazAlive = true


----------------------------------------------------------------
--------------------------Default-Settings----------------------

local defaultSettings = {
	["lazAlive"] = true,
	["dysmorphiaCooldown"] = defaultCooldown,
	["dysmorphiaTimer"] = defaultCooldown
}

local healthHistory = {}

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

--Main dysmorphia functionality
function del:dysmorphia(_type, rng, player)
	--buildGrid(Game():GetRoom())
	
	local currentPlayer = player:GetPlayerType()
	local currentPlayerName = player:GetName()
	
	--Lazarus' Rags check
	lazExcludeID = PlayerType.PLAYER_LAZARUS
	if lazAlive then
		lazExcludeID = PlayerType.PLAYER_LAZARUS2
	end
	
	if currentPlayer ~= PlayerType.PLAYER_ESAU then --Esau is rolled for too for SOME REASON
		local targetPlayer = table.random(playerTypeWhitelist, {currentPlayer, lazExcludeID}, rng)
		
		player:ChangePlayerType(targetPlayer) --Call clicker function with target
		
		--print("From: " .. currentPlayerName .. " To: " .. player:GetName())
		
		--[[
		local playerSprite = player:GetSprite()
		playerSprite:Load("001.000_player.anm2", true) --Load custom spritesheet
		
		for i = 0, 15 do
			playerSprite:ReplaceSpritesheet(i, spriteSheetLocations[targetPlayer]) --Replace spritesheets
		end

		playerSprite:LoadGraphics() --Reload sprites
		]]--
		
		dysmorphiaTimer = defaultCooldown
		
		--Screen effects
		Game():Darken(0.9, 20)
		
		return true --Play pick up animation
	end
end
del:AddCallback(ModCallbacks.MC_USE_ITEM, del.dysmorphia, COLLECTIBLE_DYSMORPHIA)


--------------------------------
----------Damage Effect---------

function del:dysmorphiaDamage()
	local player = Isaac.GetPlayer(0)
	
	--Start damage countdown at full charge
	if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == dysmorphiaMaxCharges then
		
		dysmorphiaTimer = (dysmorphiaTimer - 1) % dysmorphiaCooldown --increment, wrap on damage		
		
		local sound = SoundEffect.SOUND_HUSH_GROWL
		local volume = 0.3

		--TODO: Ugly elif chain, FIX
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


--------------------------------
-------------Lazarus------------

function del:lazarusCheck(hitEntity, dmgAmount)
	local player = hitEntity:ToPlayer() --Cast Entity to EntityPlayer
	local hp = player:GetHearts() + player:GetSoulHearts() 
	
	--Health reduction applied after MC_ENTITY_TAKE_DMG
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS and hp - dmgAmount == 0 then 
		lazAlive = false
	end
end
del:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, del.lazarusCheck, EntityType.ENTITY_PLAYER)


--------------------------------
-------------Charge-------------

function del:dysmorphiaCharge(hitEntity, dmgAmount, _flags, dmgSource)
	local player = Isaac.GetPlayer(0)
	
	if dmgSource.Type < 10 and
		player:GetActiveCharge(ActiveSlot.SLOT_POCKET) ~= dysmorphiaMaxCharges and
		not table.contains(chargeEntityBlacklist, hitEntity.Type) then

		--TODO: Account for overkill dmg
		local newCharge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + math.floor(dmgAmount) + 10 * Game():GetLevel():GetStage() 

		player:SetActiveCharge(math.clamp(newCharge, 0, dysmorphiaMaxCharges), ActiveSlot.SLOT_POCKET)
	end
end
del:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, del.dysmorphiaCharge)


----------------------------------------------------------------
-------------------------Health-Tracker-------------------------

--Return formatted health
function del:returnHealth(player)
	local health = {
		red = player:GetHearts(),
		container = player:GetMaxHearts(),
		eternal = player:GetEternalHearts(),
		soul = player:GetSoulHearts(),
		bone = player:GetBoneHearts(),
		rotten = player:GetRottenHearts(),
		broken = player:GetBrokenHearts(),
		blackBitmask = player:GetBlackHearts()
	}
	
	return health
end

--Stores health history for character conversion (WIP)
function del:storeHealthHistory()
	return history
end


----------------------------------------------------------------
---------------------------Grid-Check---------------------------

--Create a 2D entity grid (WIP)
function del:buildGrid(room)
	local xMax = room:GetGridWidth()
	local yMax = room:GetGridHeight()
	local grid = {}
	
	for x = 0, xMax do
		for y = 0, yMax do
			grid[x][y] = room:GetGridEntity(x+y)
		end
	end
	
	return grid
end


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
	local roll = rng:RandomInt(#randTable) + 1
	
	if table.contains(exclude, randTable[roll]) then
		return table.random(randTable, exclude, rng)
	else
		return randTable[roll]
	end
end

--Clamps a value to given range
function math.clamp(n, low, high)
	return math.min(math.max(n, low), high)
end


--------------------------------
--------------Debug-------------

function del:onPress()
	if Input.IsButtonTriggered(Keyboard.KEY_LEFT_ALT, 0) then
		local str = ""
		for k, v in pairs(del:returnHealth(Isaac.GetPlayer(0))) do
			str = str .. " " .. k .. ":" .. tostring(v)
		end
		print(str)
	end
end
del:AddCallback(ModCallbacks.MC_POST_RENDER, del.onPress)
