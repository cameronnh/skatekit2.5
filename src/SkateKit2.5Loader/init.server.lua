local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local function parentModules(folderOfModules: Folder, parent: any): ()
    for _: number, child: any in folderOfModules:GetChildren() do
        child.Parent = parent
    end
end

print("Starting To Load Modules...")

parentModules(script:WaitForChild("ReplicatedStorage"), ReplicatedStorage)
parentModules(script:WaitForChild("ServerScriptService"), ServerScriptService)
parentModules(script:WaitForChild("StarterPlayerScripts"), StarterPlayerScripts)