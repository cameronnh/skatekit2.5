repeat
    task.wait(.1)
until workspace:GetAttribute("SkateKitInitalized")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Knit = require(ReplicatedStorage.Knit)

for _: number, v: ModuleScript? in StarterPlayerScripts:GetDescendants() do
    if v:IsA("ModuleScript") and v.Name:match("Controller$") then
        require(v)
    end
end

Knit.Start():catch(warn)