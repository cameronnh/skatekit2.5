--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--DEPENDENCIES-----------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)
local Instancer = require(ReplicatedStorage.Utils.Instancer) ---@module Instancer

--FIELDS-----------------------------------------------------------------------------

local AssetsService = Knit.CreateService{
    Name = "AssetsService",
}

--KNIT LIFETIME METHODS--------------------------------------------------------------

function AssetsService:KnitStart()
    local Assets = Instance.new("Folder")
    Assets.Name = "Assets"
    Assets.Parent = ReplicatedStorage

    for _: number, data: {any} in ReplicatedStorage.Instances:GetChildren() do
        if not data:IsA("ModuleScript") then
            continue
        end

        local instance: any = Instancer:Create(require(data))
        instance.Parent = Assets
    end
end

return AssetsService
