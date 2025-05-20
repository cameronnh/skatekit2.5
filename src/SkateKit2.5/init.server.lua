local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local function parentModules(folderOfModules: Folder, parent: any): ()
    for _: number, child: any in folderOfModules:GetChildren() do
        child.Parent = parent

        if child:IsA("Script") or child:IsA("LocalScript") then
            child.Enabled = true
        end
    end
end

print("[SkateKit2.5]: Starting to load modules")

parentModules(script:WaitForChild("ReplicatedStorage"), ReplicatedStorage)
parentModules(script:WaitForChild("ServerScriptService"), ServerScriptService)
parentModules(script:WaitForChild("StarterPlayerScripts"), StarterPlayerScripts)

task.defer(function()
    workspace:SetAttribute("SkateKitInitalized", true)
end)