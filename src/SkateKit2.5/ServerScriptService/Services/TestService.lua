--ROBLOX SERVICES--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--DEPENDENCIES-----------------------------------------------------------------------

local Knit = require(ReplicatedStorage.Knit)

--CONSTANTS--------------------------------------------------------------------------

--FIELDS-----------------------------------------------------------------------------

local TestService = Knit.CreateService{
    Name = "TestService",
    Client = {},
}

--LOCAL FUNCTIONS--------------------------------------------------------------------

--KNIT LIFETIME METHODS--------------------------------------------------------------

function TestService:KnitInit()

end

function TestService:KnitStart()
    warn("Im Here Server")
end

--CLIENT FACING METHODS--------------------------------------------------------------

--PUBLIC METHODS---------------------------------------------------------------------

--PRIVATE METHODS--------------------------------------------------------------------

return TestService
