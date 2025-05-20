repeat
    task.wait(.1)
until workspace:GetAttribute("SkateKitInitalized")

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Knit)

for _: number, script: ModuleScript? in ServerScriptService:GetDescendants() do
    if script:IsA("ModuleScript") and script.Name:match("Service$") then
        require(script)
    end
end

Knit.Start():catch(warn)