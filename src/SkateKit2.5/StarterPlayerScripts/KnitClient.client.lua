repeat
    task.wait(.01)
until workspace:GetAttribute("SkateKitInitalized")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Knit = require(ReplicatedStorage.Knit)

for _: number, v: ModuleScript? in StarterPlayerScripts.Controllers:GetChildren() do
    if not v:IsA("ModuleScript") then
        continue
    end

    require(v)
end

Knit.Start():catch(warn)