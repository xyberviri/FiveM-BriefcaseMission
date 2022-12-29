local Data = {
    InProgress = false,
    ActiveObject = nil,
    MartinPed = nil,
    AlreadyCollecting = 0,
    Holder = 0,
    State = "none",
    Location = nil,
    AwaitingPlayers = false,
    CurrentTime = {
        minutes = 0,
        seconds = 0
    },
}

local BriefcaseMissionFunctions = {}
local PlayersLoaded = {}

RegisterServerEvent('petris-briefcasemission:RequestState')
AddEventHandler('petris-briefcasemission:RequestState', function()
    local src = source
    if not PlayersLoaded[src] then
        if Data.InProgress then
            TriggerClientEvent('petris-briefcasemission:MissionStarted', src, Data.Location, NetworkGetNetworkIdFromEntity(Data.ActiveObject), NetworkGetNetworkIdFromEntity(Data.MartinPed))
            TriggerClientEvent('petris-briefcasemission:ShowTimerBar', src, Data.CurrentTime.minutes, Data.CurrentTime.seconds)
            if Data.AwaitingPlayers == false then 
                if Data.State == "Holder" then
                    TriggerClientEvent('petris-briefcasemission:UpdateMissionState', src, Data.State, Data.Holder)
                else
                    TriggerClientEvent('petris-briefcasemission:UpdateMissionState', src, Data.State)
                end
            end
        end
        PlayersLoaded[src] = true
    end
end)

RegisterServerEvent('petris-briefcasemission:ToggleCollecting')
AddEventHandler('petris-briefcasemission:ToggleCollecting', function()
    if Data.InProgress then
        if Data.AlreadyCollecting == 0 then
            TriggerClientEvent('petris-briefcasemission:CollectBriefcase', source)
            Data.AlreadyCollecting = source
        else
            TriggerClientEvent('petris-briefcasemission:SendNotification', source, Petris_ServerConfig["Notifications"]["AlreadyCollecting"])
        end
    else
        Petris_ServerConfig.ExploitBlocked(source)
    end
end)

RegisterServerEvent('petris-briefcasemission:BriefcaseSeen')
AddEventHandler('petris-briefcasemission:BriefcaseSeen', function()
    if (Data.State == "none") and (Data.InProgress) then
        Data.State = "Briefcase"
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State)
    else
        Petris_ServerConfig.ExploitBlocked(source)
    end
end)

RegisterServerEvent('petris-briefcasemission:BriefcaseCollected')
AddEventHandler('petris-briefcasemission:BriefcaseCollected', function()
    if (Data.State == "Briefcase") and (Data.InProgress) and (Data.AlreadyCollecting == source) then
        Data.AlreadyCollecting = 0
        Data.Holder = source
        SetCurrentPedWeapon(GetPlayerPed(source), GetHashKey("WEAPON_UNARMED"), true)
        Data.State = "Holder"
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State, source)
        TriggerClientEvent('petris-briefcasemission:SendNotification', -1, Petris_ServerConfig["Notifications"]["Collected"])
    else
        Petris_ServerConfig.ExploitBlocked(source)
    end
end)

RegisterServerEvent('petris-briefcasemission:DeliverBriefcase')
AddEventHandler('petris-briefcasemission:DeliverBriefcase', function()
    if (Data.State == "Holder") and (Data.InProgress) and (Data.Holder == source) then
        DeleteEntity(Data.ActiveObject)
        Petris_ServerConfig.GiveReward(Data.Holder)
        Data.State = "none"
        Data.InProgress = false
        Data.Holder = 0
        Data.AlreadyCollecting = 0
        Data.Location = nil
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State, source)
        Wait(5000)
        DeleteEntity(Data.MartinPed)
        Data.MartinPed = nil
    else
        Petris_ServerConfig.ExploitBlocked(source)
    end
end)

RegisterServerEvent('petris-briefcasemission:onPlayerDeath')
AddEventHandler('petris-briefcasemission:onPlayerDeath', function(deathdata)
    deathdata.victim = source
    local ped = GetPlayerPed(deathdata.victim)
    local DropCoords = GetEntityCoords(ped)
    if Data.InProgress and (deathdata.victim == Data.Holder) then
        Data.State = "Briefcase"
        Data.Holder = 0
        BriefcaseMissionFunctions:UpdateObjectCoords(DropCoords)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local ped = GetPlayerPed(src)
    local DropCoords = GetEntityCoords(ped)
    if Data.InProgress and (src == Data.Holder) then
        Data.State = "Briefcase"
        Data.Holder = 0
        BriefcaseMissionFunctions:UpdateObjectCoords(DropCoords)
    elseif Data.InProgress and (src == Data.AlreadyCollecting) then
        Data.AlreadyCollecting = 0
    end
end)

function BriefcaseMissionFunctions:UpdateObjectCoords(coords)
    local newcoords = {x = coords.x + 0.5, y = coords.y + 0.5, z = coords.z + 1.0}
    local newVec = vec3(newcoords.x, newcoords.y, newcoords.z)
    SetEntityCoords(Data.ActiveObject, newcoords.x, newcoords.y, newcoords.z)
    local attempts = 0
    while true do
        Citizen.Wait(500)
        currentCoords = GetEntityCoords(Data.ActiveObject)
        if (#(currentCoords - newVec) < 3.0) then
            break
        else
            SetEntityCoords(Data.ActiveObject, newcoords.x, newcoords.y, newcoords.z)
            if attempts == 3 then
                Data.AwaitingPlayers = true
            else
                attempts = attempts + 1
            end
        end
    end
    if Data.AwaitingPlayers then
        Wait(2500)
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State)
        TriggerClientEvent('petris-briefcasemission:SendNotification', -1, Petris_ServerConfig["Notifications"]["Dropped"])
        Data.AwaitingPlayers = false
    else
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State)
        TriggerClientEvent('petris-briefcasemission:SendNotification', -1, Petris_ServerConfig["Notifications"]["Dropped"])
    end
end

function BriefcaseMissionFunctions:GetMissionStartTimes()
    local File = LoadResourceFile(GetCurrentResourceName(), "extra/status.json")
    local Status = json.decode(File)
	local timestamp = os.date("*t") 
    local currentDay = tonumber(table.concat({timestamp.day}, "-"))
    local currentMonth = tonumber(table.concat({timestamp.month}, "-"))
    if File then
        if Status["LastDate"]["Day"] == currentDay and Status["LastDate"]["Month"] == currentMonth and #Status["SelectedTimes"] < 1 then
            return Status["SelectedTimes"]
        else
            local NewFileData = Status
            NewFileData["SelectedTimes"] = {}
            if Petris_ServerConfig["TimesPerDay"] == #Petris_ServerConfig["PossibleTimes"] then
                for k,v in pairs(Petris_ServerConfig["PossibleTimes"]) do
                    table.insert(NewFileData["SelectedTimes"], k)
                end
            elseif Petris_ServerConfig["TimesPerDay"] < #Petris_ServerConfig["PossibleTimes"] then
                local TimesSelected = 0
                repeat
                    local Selection = math.random(#Petris_ServerConfig["PossibleTimes"])
                    local AlreadySelected = false
                    for k,v in pairs(NewFileData["SelectedTimes"]) do
                        if v == Selection then AlreadySelected = true end
                    end
                    if not AlreadySelected then
                        table.insert(NewFileData["SelectedTimes"], Selection)
                        TimesSelected = TimesSelected + 1
                    end
                until (Petris_ServerConfig["TimesPerDay"] == TimesSelected)
            end
            Status["LastDate"]["Month"] = currentMonth
            Status["LastDate"]["Day"] = currentDay
            SaveResourceFile(GetCurrentResourceName(), "extra/status.json", json.encode(NewFileData), -1)
            return NewFileData["SelectedTimes"]
        end
    end
    return {}
end

function BriefcaseMissionFunctions:StartMission()
    local randomLocation = Petris_ServerConfig["PossibleLocations"][math.random(#Petris_ServerConfig["PossibleLocations"])]
    local object = CreateObject(Petris_ServerConfig["BriefcaseProp"], randomLocation["Briefcase"].x, randomLocation["Briefcase"].y, randomLocation["Briefcase"].z - 1.0, true, true)
    local ped = CreatePed(1, GetHashKey(Petris_ServerConfig["DropOff"]["Ped"]), Petris_ServerConfig["DropOff"]["Coords"].x, Petris_ServerConfig["DropOff"]["Coords"].y, Petris_ServerConfig["DropOff"]["Coords"].z, Petris_ServerConfig["DropOff"]["Coords"].heading, true, true)
    while not DoesEntityExist(object) or not DoesEntityExist(ped) do
        Citizen.Wait(500)
    end
    SetEntityDistanceCullingRadius(object, 999999999.0)
    SetEntityDistanceCullingRadius(ped, 999999999.0)
    FreezeEntityPosition(ped, true)
    Wait(5000) 
    Data.ActiveObject = object
    Data.MartinPed = ped
    BriefcaseMissionFunctions:StartTimer()
    TriggerClientEvent('petris-briefcasemission:MissionStarted', -1, randomLocation, NetworkGetNetworkIdFromEntity(object), NetworkGetNetworkIdFromEntity(ped))
    TriggerClientEvent('petris-briefcasemission:ShowTimerBar', -1, Petris_ServerConfig["Duration"], 0)
    Data.Location = randomLocation
    Data.InProgress = true
end

function StartMission_CronTask(d, h, m)
    BriefcaseMissionFunctions:StartMission()
end

for k,v in pairs(BriefcaseMissionFunctions:GetMissionStartTimes()) do
    local timeSelected = Petris_ServerConfig["PossibleTimes"][v]
    TriggerEvent('cron:runAt', timeSelected.hour, timeSelected.minute, StartMission_CronTask)
end

function BriefcaseMissionFunctions:StartTimer()
    Citizen.CreateThread(function()
        seconds = 0
        minutes = Petris_ServerConfig["Duration"]
        while seconds >= 0 do
            Wait(1000)
            if Data.InProgress then
                if minutes == 0 and seconds == 0 then
                    seconds = -1
                    DeleteEntity(Data.ActiveObject)
                    Data.State = "none"
                    Data.InProgress = false
                    Data.Holder = 0
                    Data.AlreadyCollecting = 0
                    Data.Location = nil
                    TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State, 0)
                    DeleteEntity(Data.MartinPed)
                    Data.MartinPed = nil
                    Data.CurrentTime = {}
                    break
                else
                    if seconds == 0 then
                        if minutes == 0 then
                            minutes = 0
                        else
                            minutes = minutes - 1
                        end
                        seconds = 60
                    end
                    if seconds > 0 then
                        seconds = seconds - 1
                    end
                    Data.CurrentTime = {minutes = minutes, seconds = seconds}
                end
            else
                Data.CurrentTime = {}
                break
            end
        end
    end)
end

exports("StartBriefcaseMission", function()
    if not Data.InProgress then
        BriefcaseMissionFunctions:StartMission()
    end
end)

exports("StopBriefcaseMission", function()
    if Data.InProgress then
        DeleteEntity(Data.ActiveObject)
        Data.State = "none"
        Data.InProgress = false
        Data.Holder = 0
        Data.AlreadyCollecting = 0
        Data.Location = nil
        TriggerClientEvent('petris-briefcasemission:UpdateMissionState', -1, Data.State, 0)
        DeleteEntity(Data.MartinPed)
        Data.MartinPed = nil
        Data.CurrentTime = {}
    end
end)