--[[
	poolcw soft shutdown
    --After https://gist.github.com/EvercyanRBX/fb28958820be36c35102695872f1f663
]]

local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- CONFIG
local RESERVER_CHAR_POS: boolean = true

--------------------------------------------------------------------------------

local function CFrameToArray(CoordinateFrame: CFrame)
	return {CoordinateFrame:GetComponents()}
end

local function ArrayToCFrame(a: {number})
	return CFrame.new(table.unpack(a))
end

local function OnPlayerAdded(Player: Player)
	local teleportData = Player:GetJoinData().TeleportData

    if not teleportData then
        return
    end

    if not teleportData.isSoftShutdown then
        return
    end

    if not RESERVER_CHAR_POS then
        return
    end

    local cf: CFrame = teleportData.CharacterCFrames[tostring(Player.UserId)]

    if not cf then
        return
    end

    --teleport player
    local character: Model = Player.Character or Player.CharacterAdded:Wait()
    local hrp: Part = character:WaitForChild("HumanoidRootPart") :: BasePart

    if not Player:HasAppearanceLoaded() then
        Player.CharacterAppearanceLoaded:Wait()
    end

    task.wait(0.1) -- Roblox race conditions
    hrp:PivotTo(ArrayToCFrame(cf))
end

for _: number, player: Player in Players:GetPlayers() do
	OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

-- Code here runs when a server is closing
game:BindToClose(function()
	if RunService:IsStudio() then
		return
	end

	local players: {Player} = Players:GetPlayers()

	if not players[1] then
		return
	end

	local charCFs: {[number]: CFrame} = {}
	if RESERVER_CHAR_POS then
		for _: number, player: Player in players do
			local char: Model = player.Character
			local hrp: Part = char and char:FindFirstChild("HumanoidRootPart")

			if not hrp then
                continue
			end

            charCFs[tostring(player.UserId)] = CFrameToArray(hrp.CFrame)
		end
	end

	-- Teleport the player(s)
	local teleportOptions: TeleportOptions = Instance.new("TeleportOptions")
	teleportOptions:SetTeleportData({
		isSoftShutdown = true,
		CharacterCFrames = charCFs
	})

	xpcall(function()
		TeleportService:TeleportAsync(
			game.PlaceId,
			Players:GetPlayers(),
			teleportOptions
		)
	end, warn)

	-- Keep the server alive until all of the player(s) have been teleported.
	while Players:GetPlayers()[1] do
		task.wait(5)
	end
end)