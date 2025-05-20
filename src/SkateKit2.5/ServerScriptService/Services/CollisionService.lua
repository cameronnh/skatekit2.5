--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

--DEPENDENCIES-----------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit) ---@module Knit

--FIELDS-----------------------------------------------------------------------------

local CollisionService = Knit.CreateService{
    Name = "CollisionService",
}

local PlayerNCharService

--KNIT LIFETIME METHODS--------------------------------------------------------------

function CollisionService:KnitInit()
    PlayerNCharService = Knit.GetService("PlayerNCharService")
end

function CollisionService:KnitStart()
    self:_setCollisionPlayers()
end

--PUBLIC METHODS---------------------------------------------------------------------

function CollisionService:MakeCollisionGroup(groupName: string, canCollide: boolean, collideWithPlayers: boolean)
    PhysicsService:RegisterCollisionGroup(groupName)

    PhysicsService:CollisionGroupSetCollidable(groupName, groupName, canCollide)
    PhysicsService:CollisionGroupSetCollidable(groupName, "Players", collideWithPlayers)
end

--PRIVATE METHODS--------------------------------------------------------------------

function CollisionService:_setCollisionPlayers(): ()
    PhysicsService:RegisterCollisionGroup("Players")
    PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

    PlayerNCharService.CharacterAdded:Connect(function(_: Player, char: Model, charDumpster)
        charDumpster:Add(char.DescendantAdded:Connect(function(descendant: any?): ()
            if descendant:IsA("BasePart") then
                descendant.CollisionGroup = "Players"
            end
        end))

        for _: number, des: BasePart? in char:GetDescendants() do
            if des:IsA("BasePart") then
                des.CollisionGroup = "Players"
            end
        end
    end)
end

return CollisionService
