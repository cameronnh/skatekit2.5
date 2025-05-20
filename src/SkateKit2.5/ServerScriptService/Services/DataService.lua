--ROBLOX SERVICES--------------------------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

--PACKAGES---------------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)
local Promise = require(ReplicatedStorage.Utils.Promise)
local Signal = require(ReplicatedStorage.Utils.Signal)

--PROFILE/REPLICA SERVICE------------------------------------------------------------

local ProfileService = require(ReplicatedStorage.MadworksModules.ProfileService)
local ReplicaService = require(ReplicatedStorage.MadworksModules.ReplicaService)
local SaveStructure: {[string]: any} = require(ReplicatedStorage.Data.SaveStructure)
local DataStoreNames = require(ReplicatedStorage.Data.DataStoreNames)

--CONSTANTS--------------------------------------------------------------------------

local TELEPORT_LOCK_ATTR: string = "IS_TELEPORTING"

local OFFLINE_CACHED_KEYS: {string} = {
}

--FIELDS-----------------------------------------------------------------------------

local DataService = Knit.CreateService{
	Name = "DataService",
    Client = {},
	DataLoaded = Signal.new()
}

local PlayerNCharService

local Profiles = {}
local Replicas = {}
local ProfileStore

local OfflineCache: {[string]: {[number]: any}} = {} --TODO: Maybe add periodic clean-ups

--KNIT LIFETIME METHODS--------------------------------------------------------------

function DataService:KnitInit(): ()
	table.freeze(SaveStructure)

	PlayerNCharService = Knit.GetService("PlayerNCharService")

	for _: number, key: string in OFFLINE_CACHED_KEYS do
		OfflineCache[key] = {}
	end
end

function DataService:KnitStart(): ()
	ProfileStore = ProfileService.GetProfileStore(
		RunService:IsStudio() and DataStoreNames.PlayerData_Studio or DataStoreNames.PlayerData_Live,
		SaveStructure
	)

	PlayerNCharService.PlayerAdded:Connect(function(player: Player, playerDumpster)
		self:_playerAdded(player, playerDumpster)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		for _: number, key: string in OFFLINE_CACHED_KEYS do
			OfflineCache[key][player.UserId] = nil
		end
	end)
end

--PUBLIC FUNCTIONS-------------------------------------------------------------------

function DataService:GetProfile(player: Player)
	return Profiles[player]
end

--Gets data at a specific key
function DataService:GetValueFromKey(player: Player, dataToGet: string): any?
	assert(typeof(player) == "Instance" and player:IsDescendantOf(Players), "Value passed is not a valid player")
	assert(typeof(dataToGet) == "string", "Not a valid data key sent")

	local Profile = Profiles[player]

	if not Profile then
		warn("Couldnt find the players profile")
		return
	end

	if not Profile.Data[dataToGet] then
		warn(`Wrong data passed or data not found for key: {dataToGet}`)
		return
	end

	return Profile.Data[dataToGet]
end

--Gets the whole table of players data
function DataService:GetAllPlayersData(player: Player): {[string]: any}
    if Profiles[player] then
        return Profiles[player].Data
    end
end

--Sets player data
function DataService:SetData(player: Player, dataToSet: string, newDataValue: any): ()
	assert(typeof(player) == "Instance" and player:IsDescendantOf(Players), "Value passed is not a valid player")
	assert(typeof(dataToSet) == "string", "Not a valid data key sent")

	local Profile = Profiles[player]
    local Replica = Replicas[player]

	if not Profile then
		return
	end

	if not Profile.Data[dataToSet] then
		warn("Wrong data string passed or field is not in data")
		return
	end

	local oldDataValueType: any = typeof(Profile.Data[dataToSet])

	if oldDataValueType ~= typeof(newDataValue) then
		warn("Wrong data type passed")
		return
	end

	Profile.Data[dataToSet] = newDataValue

	if not Replica then
		return
	end

	Replica:SetValue({dataToSet}, newDataValue)
end

function DataService:AddGlobalActiveUpdate(userId: number, update): ()
	if (not userId) or (not update) then
        return Promise.reject()
    end

    return Promise.new(function(resolve)
        return resolve(ProfileStore:GlobalUpdateProfileAsync(`Player_{userId}`, function(global_updates)
            global_updates:AddActiveUpdate(update)
        end))
    end)
end

--Handles releasing data then teleporting the player
function DataService:TeleportWithData(player: Player, teleportOptions: TeleportOptions?, placeId: number?)
	local profile = Profiles[player]

	if not profile then
		return
	end

	--set default teleport options
	if not teleportOptions then
		teleportOptions = Instance.new("TeleportOptions")
	end

	if not placeId then
		placeId = game.PlaceId
	end

	--attribute so they dont get kicked
	player:SetAttribute(TELEPORT_LOCK_ATTR, true)

	--this basically calls release
	self:_playerRemoved(player)

	--when ready this will fire
	profile:ListenToHopReady(function()
		Promise.retryWithDelay(function()
			TeleportService:TeleportAsync(
				placeId,
				{player},
				teleportOptions
			)
		end, 10, 1)
	end)
end

--Gets the replica
function DataService:GetReplica(player: Player)--: Promise
	assert(typeof(player) == "Instance" and player:IsDescendantOf(Players), "Value passed is not a valid player")

	return Promise.new(function(Resolve, Reject)

		if not Profiles[player] or not Replicas[player] then
			repeat
				if player then
					task.wait()
				else
					Reject("Player left the game")
				end
			until Profiles[player] and Replicas[player]
		end

		local Profile = Profiles[player]
		local Replica = Replicas[player]

		if Profile:IsActive() and Replica:IsActive() then
			Resolve(Replica)
		end

		Reject("Profile or Replica did not exist or wasn't active")
	end)
end

--get offline data for the player
function DataService:ViewData(userId: number, keys: {string}?, onlyUseCache: boolean?): {any}
	local currentData: {[string]: any} = {}
	userId = tonumber(userId)

	local playerProfile
	local playerInGame: Player = Players:GetPlayerByUserId(userId)

	if playerInGame and Profiles[playerInGame] then
		playerProfile = Profiles[playerInGame]
	end

	--check all the cached keys since we are looking for specifics
	local foundAllCached: boolean = true

	if keys then
		for _: number, key: string in keys do
			if OfflineCache[key] and OfflineCache[key][userId] then
				currentData[key] = OfflineCache[key][userId]
			else
				foundAllCached = false
			end
		end

		if foundAllCached then
			return currentData
		end
	end

	--fill out remainign with default values
	if onlyUseCache then
		if not keys then
			return {}
		end

		for _: number, key: string in keys do
			if OfflineCache[key] and OfflineCache[key][userId] then
				currentData[key] = OfflineCache[key][userId]
				continue
			end

			currentData[key] = SaveStructure[key] or 0
		end

		return currentData
	end

	if not playerProfile then
		playerProfile = ProfileStore:ViewProfileAsync("Player_" .. userId)
	end

	if playerProfile then
		currentData = playerProfile.Data
	end

	if keys then
		if typeof(keys) ~= "table" then
			return
		end

		local returnData: {[string]: any} = {}

		for _: number, key: string in keys do
			if typeof(key) ~= "string" then
				continue
			end

			if currentData[key] then
				returnData[key] = currentData[key]

				if table.find(OFFLINE_CACHED_KEYS, key) then
					if not OfflineCache[key] then
						OfflineCache[key] = {}
					end

					OfflineCache[key][userId] = currentData[key]
				end
			else
				returnData[key] = SaveStructure[key] or 0
 			end
		end

		return returnData
	end

	return currentData
end

function DataService.Client:ViewData(_: Player, userId: number, keys: {string}?, onlyUseCache: boolean?): {any}
	return self.Server:ViewData(userId, keys, onlyUseCache)
end

--PRIVATE FUNCTIONS------------------------------------------------------------------

--player added gets profile and sets replica
function DataService:_playerAdded(player: Player, playerDumpster): ()
	local startTime: number = tick()

	--load profile
	local playerProfile = ProfileStore:LoadProfileAsync(
		"Player_" .. player.UserId,
	function()
		return "Steal" --ForceLoad
	end)

    if not playerProfile then
        player:Kick("Unable to load saved data. Please rejoin.")
		return
    end

    playerProfile:AddUserId(player.UserId)
    playerProfile:Reconcile()

	--release logic
    playerProfile:ListenToRelease(function()
        Profiles[player] = nil

		if Replicas[player] then
			Replicas[player]:Destroy()
			Replicas[player] = nil
		end

		--if they are teleporting dont kick
		if player:GetAttribute(TELEPORT_LOCK_ATTR) == true then
			return
		end

        player:Kick("Profile was released")
    end)

	--check player is in and set of token and repliace
    if player:IsDescendantOf(Players) then
		local PlayerProfileClassToken = ReplicaService.NewClassToken(tostring(player.UserId))

        local playerReplica = ReplicaService.NewReplica({
            ClassToken = PlayerProfileClassToken,
            Tags = {["Player"] = player},
            Data = playerProfile.Data,
            Replication = "All",
        })

        Profiles[player] = playerProfile
        Replicas[player] = playerReplica

		if RunService:IsStudio() then
			print("[DataService]: ".. player.Name .. "'s profile has been loaded. ".."("..string.sub(tostring(tick() - startTime ), 1, 5)..")", playerProfile)
		end

		player:SetAttribute("DataLoaded", true)

		--fires to everywhere else
		DataService.DataLoaded:Fire(player)
    else
		--they never fully joined?
        playerProfile:Release()
    end

	--cleanup logic
	playerDumpster:Add(function(): ()
		self:_playerRemoved(player)
	end)
end

--releases the profile
function DataService:_playerRemoved(player: Player): ()
	self:_releaseFailSafe(player)

	if Replicas[player] then
		Replicas[player]:Destroy()
		Replicas[player] = nil
	end

	--finally release
	if Profiles[player] then
		Profiles[player]:Release()
	end
end

--runs a fail safe on a delay to make sure that the players profile will be releases
function DataService:_releaseFailSafe(player: Player)
	task.delay(3, function() --Can make this shorter for other projects
		if Profiles[player] then
			Profiles[player]:Release()
		end
	end)
end

return DataService