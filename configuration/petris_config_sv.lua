--[[
    -- ## ESX EXAMPLE - In case you install an ESX Check, please uncomment this, too ## --
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
--]]

Petris_ServerConfig = {
    ["DropOff"] = {
        ["Ped"] = "cs_martinmadrazo",
        ["Coords"] = {x = 1392.69, y = 1141.62, z = 114.44, heading = 93.0}
    },
    ["BriefcaseProp"] = "prop_security_case_01", -- Must be same with client-sided in order to load.
    ["Duration"] = 25, -- Minutes
    ["TimesPerDay"] = 2, -- Make sure this number is higher than the lenght of PossibleTimes list otherwise the script won't work.
    ["PossibleTimes"] = {
        {hour = 14, minute = 45},
        {hour = 16, minute = 0},
        {hour = 18, minute = 30},
        {hour = 22, minute = 0}
    },
    ["PossibleLocations"] = {
        {
            ["Briefcase"] = {x = 656.70, y = 1282.43, z = 360.29},
            ["Blip"] = {x = 740.96, y = 1283.88, z = 360.29, radius = 100.0}
        },
    },
    ["Notifications"] = {
        ["Dropped"] = "~g~<C>Briefcase Mission:</C> ~w~The ~g~~h~Briefcase~h~ ~s~~w~has been ~o~dropped.",
        ["Collected"] = "~g~<C>Briefcase Mission:</C> ~w~The ~g~~h~Briefcase~h~ ~s~~w~has been ~y~collected.",
        ["AlreadyCollecting"] = "~g~<C>Briefcase Mission:</C> ~w~Someone else is already collecting the ~g~briefcase."
    },
    GiveReward = function(playerId)
        -- ## ESX EXAMPLE - You can give reward to player ## --
        --[[
            local xPlayer = ESX.GetPlayerFromId(playerId)
            xPlayer.addMoney(5000)
        --]]
    end,
    ExploitBlocked = function(playerId)
        -- ## ANTICHEAT RECOMMENDATION -- You can try using an event or an export function to ban the player trying to exploit the events with an executor ## --
    end
}