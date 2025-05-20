--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--DEPENDENCIES-----------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)

--CONSTANTS--------------------------------------------------------------------------

--FIELDS-----------------------------------------------------------------------------

local SkateService = Knit.CreateService{
    Name = "SkateService",
    Client = {},

    PlayerSkateboards = {} :: {[Player]: Model},
}

local DataService

--KNIT LIFETIME METHODS--------------------------------------------------------------

function SkateService:KnitInit()
    DataService = Knit.GetService("DataService")
end

function SkateService:KnitStart()
    workspace:SetAttribute("RbxLegacyAnimationBlending", true)

    Players.PlayerRemoving:Connect(function(player: Player): ()
        self.PlayerSkateboards[player] = nil
    end)
end

--CLIENT FACING METHODS--------------------------------------------------------------

function SkateService.Client:ChangeId(player: Player, id: number)
    DataService:SetData(player, "SkateboardId", tonumber(id))

    local character: Model = player.Character

    if not character then
        return
    end

    local skateboard: Model = character:FindFirstChild("Skateboard")

    if not skateboard then
        return
    end

    --sets the skateboard
    skateboard.TrickBoard.Mesh.TextureId = ("rbxassetid://" .. id)
    skateboard.SkateboardPlatform.SkateboardMesh.TextureId = ("rbxassetid://" .. id)
end

function SkateService.Client:DestroySkateboard(player: Player)
    local playerBoard: Model = self.Server.PlayerSkateboards[player]

    if not playerBoard then
        return
    end

    if playerBoard:FindFirstChild("SkateboardPlatform") then
        local motor: Motor6D = playerBoard.SkateboardPlatform:FindFirstChild("PlatformMotor6D")

        if motor then
            motor:Destroy()
        end
    end

    if playerBoard.Parent then
        playerBoard.Parent.Humanoid.PlatformStand = false
    end

    playerBoard:Destroy()
end

function SkateService.Client:SpawnSkateboard(player: Player)
    local character: Model = player.Character

    if not character then
        return
    end

    local currentBoardId: number = DataService:GetValueFromKey(player, "SkateboardId") or 11196651546
    local currentStance: string = DataService:GetValueFromKey(player, "StanceType") or "regular"
    local currentLeans: string = DataService:GetValueFromKey(player, "LeanType") or "new"

    --doing this so theres always a skateboard ready
    local skateboard: Model = ReplicatedStorage.Assets.Boards:FindFirstChild("Skateboard")
    local skateboardClone: Model = skateboard:Clone()
    skateboardClone.Parent = ReplicatedStorage.Assets.Boards

    --adds to table
    if self.Server.PlayerSkateboards[player] then
        self.Server.PlayerSkateboards[player]:Destroy()
    end

    skateboard.Parent = character
    self.Server.PlayerSkateboards[player] = skateboard

    --sets the skateboard
    skateboard.TrickBoard.Mesh.TextureId = ("rbxassetid://" .. currentBoardId)
    skateboard.SkateboardPlatform.SkateboardMesh.TextureId = ("rbxassetid://" .. currentBoardId)

    if currentStance ~= "regular" then
        skateboard.Values.InitStance.Value = 2 --goofy
        player:SetAttribute("stance", "goofy")
    else
        skateboard.Values.InitStance.Value = 1 --reg
        player:SetAttribute("stance", "regular")
    end

    if currentLeans == "new" then
        skateboard.Values.InitLeans.Value = 2 --new leans (shoutout to zedmond for dis idea)
    else
        skateboard.Values.InitLeans.Value = 1 --reg
    end

    --enable the scripts
    for _: number, descendant: any in skateboard:GetDescendants() do
        if not descendant:IsA("Script") then
            continue
        end

        descendant.Disabled = false
    end

    --CFrame from drop tool. brings board infront of player
    skateboard:PivotTo(character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0))
end

--PUBLIC METHODS---------------------------------------------------------------------

--PRIVATE METHODS--------------------------------------------------------------------



return SkateService
