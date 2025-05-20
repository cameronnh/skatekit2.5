--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--PACKAGES---------------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)
local Signal = require(ReplicatedStorage.Utils.Signal)
local Dumpster = require(ReplicatedStorage.Utils.Dumpster)

--FIELDS-----------------------------------------------------------------------------

local PlayerNCharService = Knit.CreateService{
    Name = "PlayerNCharService",
    Client = {},
    PlayerAdded = Signal.new(),
    CharacterAdded = Signal.new()
}

local PlayerDumpsters: {[Player]: {any}} = {}
local CharacterDumpsters: {[Player]: {any}} = {}

--LOCAL FUNCTIONS--------------------------------------------------------------------

local function characterAdded(player: Player, character: Model, characterDumpster): ()
    characterDumpster:Destroy()

    PlayerNCharService.CharacterAdded:Fire(player, character, characterDumpster)
end

local function playerAdded(player: Player): ()
    local playerDump = Dumpster.new()
    playerDump:AttachTo(player)
    PlayerDumpsters[player] = playerDump

    playerDump:Add(function()
        PlayerDumpsters[player] = nil
        CharacterDumpsters[player] = nil
    end)

    PlayerNCharService.PlayerAdded:Fire(player, playerDump)

    --get players character
    local characterDumpster = playerDump:Extend()
    CharacterDumpsters[player] = characterDumpster

    if player.Character then
        characterAdded(player, player.Character, characterDumpster)
    end

    playerDump:Add(player.CharacterAdded:Connect(function(): ()
        characterAdded(player, player.Character, characterDumpster)
    end))
end

--KNIT LIFETIME METHODS--------------------------------------------------------------

function PlayerNCharService:KnitStart(): ()
    for _: number, player: Player in Players:GetPlayers() do
        playerAdded(player)
    end

    Players.PlayerAdded:Connect(playerAdded)
end

--PUBLIC FUNCTIONS--------------------------------------------------------------

function PlayerNCharService:GetPlayerDumpster(player: Player): {any}?
    return PlayerDumpsters[player]
end

function PlayerNCharService:GetCharacterDumpster(player: Player): {any}?
    return CharacterDumpsters[player]
end

return PlayerNCharService
