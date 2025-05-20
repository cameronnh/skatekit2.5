--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--DEPENDENCIES-----------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)

--CONSTANTS--------------------------------------------------------------------------

--FIELDS-----------------------------------------------------------------------------

local TestController = Knit.CreateController {Name = "TestController"}

--LOCAL FUNCTIONS--------------------------------------------------------------------

--KNIT LIFETIME METHODS--------------------------------------------------------------

function TestController:KnitInit()

end

function TestController:KnitStart()
    warn("Im Here Client")
end

--PUBLIC METHODS---------------------------------------------------------------------

--PRIVATE METHODS--------------------------------------------------------------------

return TestController
