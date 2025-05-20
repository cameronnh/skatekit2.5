--[[
    File: Debouncer.lua
    Author(s): poolcw
    Created: 05/17/2024 @ 03:49:43
    Version: 1.0.0

    Description:
        Pretty simple function to handle debounces easier.

    Documentation:
        ````lua
        if Debouncer("SomeKey", .5, player?) then
            --.5 seconds has exlapsed since the the last call passed debounce
        end
        ```
]]--

--=> Roblox Services <=--

local Players = game:GetService("Players")

--=> Variables <=--

local Debounces: {[string]: number} = {}
local PlayerDebounces: {[Player]: {[string]: number}} = {}

--=> Local Functions <=--

Players.PlayerRemoving:Connect(function(player: Player)
    if not PlayerDebounces[player] then
        return
    end

    table.clear(PlayerDebounces[player])
    PlayerDebounces[player] = nil
end)

--=> Variables <=--

local tableToCheck: {[string]: number} | {[Player]: {[string]: number}}

--=> Function <=--

return function (key: string, debounce: number, player: Player?)
    assert(debounce > 0, "[Debouncer] Debounce must be greater than 0.")
    assert(typeof(key) == "string", "[Debouncer] Key must be a string")

    tableToCheck = Debounces

    if player then
        if not PlayerDebounces[player] then
            PlayerDebounces[player] = {}
        end

        tableToCheck = PlayerDebounces[player]
    end

    if not tableToCheck[key] then
        tableToCheck[key] = os.clock()
        return true
    end

    if tableToCheck[key] > os.clock() then
        return false
    end

    tableToCheck[key] = os.clock() + debounce
    return true
end
