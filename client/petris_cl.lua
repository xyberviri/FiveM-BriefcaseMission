local API_ProgressBar = exports[GetCurrentResourceName()]:GetAPI()
local Data = {
    MissionInProgress = false,
    State = "none",
    CurrentBlip = nil,
    RadiusBlip = nil,
    ActiveObject = nil,
    HolderPed = nil,
    HoldingEntity = nil,
    MartinPed = nil,
    MissionTextActive = false,
    Trading = false,
    Carrying = false,
    ModelsLoaded = false,
    CurrentTimerBar = nil
}

local BriefcaseMissionFunctions = {}

Citizen.CreateThread(function()
    RequestModel(Petris_ClientConfig["BriefcaseProp"])
    RequestModel(Petris_ClientConfig["DropOff"]["Ped"])
    while not HasModelLoaded(Petris_ClientConfig["BriefcaseProp"]) or not HasModelLoaded(Petris_ClientConfig["DropOff"]["Ped"]) do
        Citizen.Wait(100)
    end
    Data.ModelsLoaded = true
    BriefcaseMissionFunctions:LoadAnimDict(Petris_ClientConfig["Animation"].Dictionary)
    BriefcaseMissionFunctions:LoadAnimDict("mp_common")
end)

RegisterNetEvent(Petris_ClientConfig["Events"].PlayerLoaded)
AddEventHandler(Petris_ClientConfig["Events"].PlayerLoaded, function()
    while not HasModelLoaded(Petris_ClientConfig["BriefcaseProp"]) or not HasModelLoaded(Petris_ClientConfig["DropOff"]["Ped"]) do
        Citizen.Wait(100)
    end
    TriggerServerEvent('petris-briefcasemission:RequestState')
end)

RegisterNetEvent('petris-briefcasemission:ShowTimerBar')
AddEventHandler('petris-briefcasemission:ShowTimerBar', function(mins, secs)
    Data.CurrentTimerBar = API_ProgressBar.add("TextTimerBar", "TIME REMAINING", "N/A")
    BriefcaseMissionFunctions:StartClientTimer(mins, 0)
end)

RegisterNetEvent('petris-briefcasemission:MissionStarted')
AddEventHandler('petris-briefcasemission:MissionStarted', function(location, object, ped)
    if Data.ModelsLoaded then
        Data.MissionInProgress = true
        Data.State = "Area"
        local blip = AddBlipForCoord(location["Blip"].x, location["Blip"].y, location["Blip"].z)
        SetBlipSprite(blip, Petris_ClientConfig["BlipSettings"][Data.State].Sprite)
        SetBlipColour(blip, Petris_ClientConfig["BlipSettings"][Data.State].Color)
        SetBlipScale(blip, Petris_ClientConfig["BlipSettings"][Data.State].Scale)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Petris_ClientConfig["BlipSettings"][Data.State].Name)
        EndTextCommandSetBlipName(blip)
        local radius = AddBlipForRadius(location["Blip"].x, location["Blip"].y, location["Blip"].z, location["Blip"].radius)
        SetBlipAlpha(radius, Petris_ClientConfig["BlipSettings"][Data.State].RadiusAlpha)
        SetBlipColour(radius, Petris_ClientConfig["BlipSettings"][Data.State].Color)
        Data.RadiusBlip = radius
        Data.CurrentBlip = blip
        Data.ActiveObject = NetworkGetEntityFromNetworkId(object)
        Data.MartinPed = NetworkGetEntityFromNetworkId(ped)
        SetEntityInvincible(Data.MartinPed, true)
        SetBlockingOfNonTemporaryEvents(Data.MartinPed, true)
        Wait(1500)
        BriefcaseMissionFunctions:ShowAdvancedNotification(Petris_ClientConfig["Messages"]["StartMessage"]) 
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", true)
    else
        BriefcaseMissionFunctions:ShowNotification(BriefcaseMissionFunctions:ShowAdvancedNotification(Petris_ClientConfig["Notifications"]["EventFailure"]))
    end
end)

RegisterNetEvent('petris-briefcasemission:SendNotification')
AddEventHandler('petris-briefcasemission:SendNotification', function(text)
    BriefcaseMissionFunctions:ShowNotification(text)
end)

RegisterNetEvent('petris-briefcasemission:UpdateMissionState')
AddEventHandler('petris-briefcasemission:UpdateMissionState', function(state, extra)
    if Data.ModelsLoaded then
        Data.State = state
        if Data.State == "Briefcase" then
            if Data.MissionTextActive then
                ClearPrints()
                Data.MissionTextActive = false
            end
            if Data.HoldingEntity then
                DeleteEntity(Data.HoldingEntity)
                Data.HoldingEntity = nil
            end
            if Data.HolderPed then
                Data.HolderPed = nil
            end
            if Data.Carrying then
                Data.Carrying = false
            end
            PlaceObjectOnGroundProperly(Data.ActiveObject)
            SetEntityVisible(Data.ActiveObject, true, 0)
            PlaceObjectOnGroundProperly_2(Data.ActiveObject)
            RemoveBlip(Data.CurrentBlip)
            if Data.RadiusBlip then
                RemoveBlip(Data.RadiusBlip)
            end
            local blip = AddBlipForEntity(Data.ActiveObject)
            SetBlipSprite(blip, Petris_ClientConfig["BlipSettings"][Data.State].Sprite)
            SetBlipColour(blip, Petris_ClientConfig["BlipSettings"][Data.State].Color)
            SetBlipScale(blip, Petris_ClientConfig["BlipSettings"][Data.State].Scale)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Petris_ClientConfig["BlipSettings"][Data.State].Name)
            EndTextCommandSetBlipName(blip)
            Data.CurrentBlip = blip
        elseif Data.State == "Holder" then
            local playerIdx = GetPlayerFromServerId(extra)
            local ped = GetPlayerPed(playerIdx)
            Data.HolderPed = ped
            SetEntityVisible(Data.ActiveObject, false, 0)
            RemoveBlip(Data.CurrentBlip)
            if playerIdx ~= PlayerId() then
                local blip = AddBlipForCoord(GetEntityCoords(Data.HolderPed))
                SetBlipSprite(blip, Petris_ClientConfig["BlipSettings"][Data.State].Sprite)
                SetBlipColour(blip, Petris_ClientConfig["BlipSettings"][Data.State].Color)
                SetBlipScale(blip, Petris_ClientConfig["BlipSettings"][Data.State].Scale)
                SetBlipFlashes(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Petris_ClientConfig["BlipSettings"][Data.State].Name)
                EndTextCommandSetBlipName(blip)
                Data.CurrentBlip = blip
                while true do
                    Citizen.Wait(750)
                    local HolderCoords = GetEntityCoords(Data.HolderPed)
                    if DoesBlipExist(blip) then
                        if GetBlipCoords(Data.CurrentBlip) ~= HolderCoords then
                            SetBlipCoords(Data.CurrentBlip, HolderCoords)
                        end
                    else
                        break
                    end
                end
            else
                local blip = AddBlipForCoord(Petris_ClientConfig["DropOff"]["MarkerCoords"].x, Petris_ClientConfig["DropOff"]["MarkerCoords"].y, Petris_ClientConfig["DropOff"]["MarkerCoords"].z)
                SetBlipScale(blip, Petris_ClientConfig["BlipSettings"]["DropOff"].Scale)
                SetBlipRoute(blip, true)
                SetBlipRouteColour(blip, 5)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Petris_ClientConfig["BlipSettings"]["DropOff"].Name)
                EndTextCommandSetBlipName(blip)
                Data.CurrentBlip = blip
                BriefcaseMissionFunctions:DrawMissionText(Petris_ClientConfig["MissionText"])
                Data.MissionTextActive = true
            end
        elseif Data.State == "none" then
            if GetPlayerFromServerId(extra) == PlayerId() then
                PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
                BriefcaseMissionFunctions:ShowWinnerScaleform()
                ClearPrints()
            elseif extra == 0 then
                BriefcaseMissionFunctions:ShowAdvancedNotification(Petris_ClientConfig["Messages"]["Expired"])
            else
                BriefcaseMissionFunctions:ShowAdvancedNotification(Petris_ClientConfig["Messages"]["FailureMessage"])
            end
            Data.MissionInProgress = false
            Data.ActiveObject = nil
            Data.HolderPed = nil
            Data.MartinPed = nil
            Data.MissionTextActive = false
            Data.Trading = false
            Data.Carrying = false
            if Data.CurrentBlip then
                RemoveBlip(Data.CurrentBlip)
                Data.CurrentBlip = nil
            end
            if Data.RadiusBlip then
                RemoveBlip(Data.RadiusBlip)
                Data.RadiusBlip = nil
            end
            if Data.HoldingEntity then
                DeleteEntity(Data.HoldingEntity)
                Data.HoldingEntity = nil
            end
            API_ProgressBar.remove(Data.CurrentTimerBar._id)
            Data.CurrentTimerBar = nil
        end
    end
end)

RegisterNetEvent('petris-briefcasemission:CollectBriefcase')
AddEventHandler('petris-briefcasemission:CollectBriefcase', function()
    TaskPlayAnim(PlayerPedId(), Petris_ClientConfig["Animation"].Dictionary, Petris_ClientConfig["Animation"].Name, 3.0, -1, 1300, 14, 0, false, false, false)
    local prop = CreateObject(GetHashKey(Petris_ClientConfig["BriefcaseProp"]), GetEntityCoords(PlayerPedId()), true, true, true)
    AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.10, 0.0, 0.0, 0.0, 280.0, 53.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(prop)
    Data.HoldingEntity = prop
    Data.Carrying = true
    TriggerServerEvent('petris-briefcasemission:BriefcaseCollected')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    if Data.ActiveObject then
        DeleteEntity(Data.ActiveObject)
    end
    if Data.HoldingEntity then
        DeleteEntity(Data.HoldingEntity)
    end
    if Data.MartinPed then
        DeleteEntity(Data.MartinPed)
    end
    ClearPrints()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Data.MissionInProgress then
            if (Data.State == "Holder") then
                if Data.MissionTextActive and not Data.Trading then
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Petris_ClientConfig["DropOff"]["MarkerCoords"].x, Petris_ClientConfig["DropOff"]["MarkerCoords"].y, Petris_ClientConfig["DropOff"]["MarkerCoords"].z, true)
                    if distance < 15.0 then
                        DrawMarker(1, Petris_ClientConfig["DropOff"]["MarkerCoords"].x, Petris_ClientConfig["DropOff"]["MarkerCoords"].y, Petris_ClientConfig["DropOff"]["MarkerCoords"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, 0.75, 0.75, 255, 204, 0, 255, false, false, 2, false)
                        if distance < 1.5 and not IsPedInAnyVehicle(PlayerPedId(), true) then
                            BriefcaseMissionFunctions:ShowHelpNotification(Petris_ClientConfig["Notifications"].DropoffHelpNotification)
                            if IsControlJustPressed(0, 38) then
                                Data.Trading = true
                                TaskGoStraightToCoord(PlayerPedId(), Petris_ClientConfig["DropOff"]["MarkerCoords"].x, Petris_ClientConfig["DropOff"]["MarkerCoords"].y, Petris_ClientConfig["DropOff"]["MarkerCoords"].z, 1.0, 2.0, Petris_ClientConfig["DropOff"]["MarkerCoords"].heading, 1.0)
                                Wait(2000)
                                TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', 1.0, -1.0, 1000, 49, 1, false, false, false)
                                Wait(1000)
                                if not IsEntityDead(PlayerPedId()) then
                                    TriggerServerEvent('petris-briefcasemission:DeliverBriefcase')
                                end
                            end
                        end
                    else
                        Citizen.Wait(1000)
                    end
                end
            else 
                Citizen.Wait(2500)
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if Data.MissionInProgress then
            if Data.State == "Area" then
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(Data.ActiveObject), true)
                if IsEntityOnScreen(Data.ActiveObject) and distance < 10.0 then
                    TriggerServerEvent('petris-briefcasemission:BriefcaseSeen')
                else
                    Citizen.Wait(500)
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Data.MissionInProgress then
            if Data.State == "Holder" and Data.HoldingEntity then
                DisableControlAction(2, 37, Data.Carrying)
                DisablePlayerFiring(PlayerId(), Data.Carrying)
                DisableControlAction(0, 106, Data.Carrying)
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(750)
        if Data.MissionInProgress then
            if Data.State == "Holder" and Data.HoldingEntity then
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    SetEntityVisible(Data.HoldingEntity, false, 0)
                    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                    Data.Carrying = false
                else
                    SetEntityVisible(Data.HoldingEntity, true, 0)
                    Data.Carrying = true
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(2000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Data.MissionInProgress then
            if Data.State == "Briefcase" then
                local objectCoords = GetEntityCoords(Data.ActiveObject)
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), objectCoords, true)
                local distance2 = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), objectCoords, false)
                if IsEntityOnScreen(Data.ActiveObject) and distance < 10.0 then
                    if IsEntityInAir(Data.ActiveObject) then PlaceObjectOnGroundProperly(Data.ActiveObject) end
                    DrawMarker(2, objectCoords.x, objectCoords.y, objectCoords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 0, 200, 0, 255, true, true, 2, false)
                    if distance2 < 0.5 then
                        BriefcaseMissionFunctions:ShowHelpNotification(Petris_ClientConfig["Notifications"].HelpNotification)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('petris-briefcasemission:ToggleCollecting')
                        end
                    end
                else
                    Citizen.Wait(250)
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

function BriefcaseMissionFunctions:ShowWinnerScaleform()
    Citizen.CreateThread(function()
        local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    
        while not HasScaleformMovieLoaded(scaleform) do
            Citizen.Wait(0)
        end
    
        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_CENTERED_TOP_MP_MESSAGE")
        PushScaleformMovieMethodParameterString(Petris_ClientConfig["Scaleform"].WinnerHeader)
        PushScaleformMovieMethodParameterString(Petris_ClientConfig["Scaleform"].WinnerText)
        EndScaleformMovieMethod()
    
        local finishTime = GetGameTimer() + 2500
        while GetGameTimer() < finishTime do
           Citizen.Wait(0)
           DrawScaleformMovieFullscreen(scaleform, 0, 0, 0, 255)
        end
    end)
end

function BriefcaseMissionFunctions:LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
end

function BriefcaseMissionFunctions:ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function BriefcaseMissionFunctions:ShowHelpNotification(msg)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function BriefcaseMissionFunctions:ShowAdvancedNotification(msg) 
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostMessagetext(Petris_ClientConfig["Messages"].Icon, Petris_ClientConfig["Messages"].Icon, true, Petris_ClientConfig["Messages"].IconType, Petris_ClientConfig["Messages"].Title, Petris_ClientConfig["Messages"].Subject)
	EndTextCommandThefeedPostTicker(false, false)
end

function BriefcaseMissionFunctions:DrawMissionText(msg)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    SetTextEntry_2("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(3 * 60 * 60000, true)
end

function BriefcaseMissionFunctions:StartClientTimer(mins, secs)
    Citizen.CreateThread(function()
        seconds = secs
        minutes = mins
        while seconds >= 0 do
            Wait(1000)
            if Data.MissionInProgress then
                if minutes == 0 and seconds == 0 then
                    seconds = -1
                    API_ProgressBar.remove(Data.CurrentTimerBar._id)
                    Data.CurrentTimerBar = nil
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
                    if minutes == 0 then
                        Data.CurrentTimerBar.Func.lib.TextTimerBar.setTextColor({200, 0, 0, 255})
                        PlaySoundFrontend(-1, "HORDE_COOL_DOWN_TIMER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    end
                    Data.CurrentTimerBar.Func.lib.TextTimerBar.setText(string.format("%02d:%02d",minutes,seconds))
                end
            else
                if Data.CurrentTimerBar then
                    API_ProgressBar.remove(Data.CurrentTimerBar._id)
                    Data.CurrentTimerBar = nil
                end
                break
            end 
        end
    end)
end
