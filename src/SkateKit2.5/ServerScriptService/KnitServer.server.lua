repeat
    task.wait(.01)
until workspace:GetAttribute("SkateKitInitalized")

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Knit)

for _: number, script: ModuleScript? in ServerScriptService.Services:GetChildren() do
    if not script:IsA("ModuleScript") then
        continue
    end

    require(script)
end

Knit.Start():catch(warn)