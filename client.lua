local ESX = exports["es_extended"]:getSharedObject()
local originalClothes = nil
local playerVehicle = nil
local currentBlip = nil
local spawnedDog = nil
local hasDog = false
local jobBlip = nil
local clockZone = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(100)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
end)

-- Job blip and target management
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Check every 5 seconds
        local job = ESX.GetPlayerData().job
        if job and job.name == Config.JobName then
            if not jobBlip then
                jobBlip = AddBlipForCoord(Config.ClockOnLocation.x, Config.ClockOnLocation.y, Config.ClockOnLocation.z)
                SetBlipSprite(jobBlip, Config.Blip.Sprite)
                SetBlipDisplay(jobBlip, 4)
                SetBlipScale(jobBlip, Config.Blip.Scale)
                SetBlipColour(jobBlip, Config.Blip.Color)
                SetBlipAsShortRange(jobBlip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Blip.Name)
                EndTextCommandSetBlipName(jobBlip)
            end
            if not clockZone then
                clockZone = exports.ox_target:addSphereZone({
                    coords = Config.ClockOnLocation,
                    radius = 1.5,
                    debug = false,
                    options = {
                        {
                            name = 'animalcontrol:toggleDuty',
                            label = 'Toggle Duty',
                            icon = 'fa-solid fa-clock',
                            onSelect = function()
                                TriggerServerEvent('animalcontrol:toggleDuty')
                            end
                        }
                    }
                })
            end
        else
            if jobBlip then
                RemoveBlip(jobBlip)
                jobBlip = nil
            end
            if clockZone then
                exports.ox_target:removeZone(clockZone)
                clockZone = nil
            end
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('animalcontrol:clockOn')
AddEventHandler('animalcontrol:clockOn', function()
    -- Change clothes
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        originalClothes = skin
        local uniform = (skin.sex == 0) and Config.Clothes.male or Config.Clothes.female
        uniform.sex = skin.sex  
        TriggerEvent('skinchanger:loadSkin', uniform)
    end)

    -- Spawn vehicle
    local model = GetHashKey(Config.VehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(500)
    end
    playerVehicle = CreateVehicle(model, Config.VehicleSpawn.x, Config.VehicleSpawn.y, Config.VehicleSpawn.z, Config.VehicleSpawn.w, true, false)
    SetEntityAsMissionEntity(playerVehicle, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), playerVehicle, -1)

    -- Add ox_target for vehicle
    exports.ox_target:addLocalEntity(playerVehicle, {
        {
            name = 'animalcontrol:putdog',
            label = 'Put Dog in Vehicle',
            icon = 'fa-solid fa-paw',
            distance = 2.5,
            canInteract = function(entity, distance, data)
                return hasDog
            end,
            onSelect = function(data)
                if hasDog and spawnedDog then
                    DetachEntity(spawnedDog, true, true)
                    DeleteEntity(spawnedDog)
                    spawnedDog = nil
                    hasDog = false
                    TriggerServerEvent('animalcontrol:caughtDog')
                    ESX.ShowNotification('Dog placed in vehicle.')
                end
            end
        }
    })
end)

RegisterNetEvent('animalcontrol:clockOff')
AddEventHandler('animalcontrol:clockOff', function()
    if originalClothes then
        TriggerEvent('skinchanger:loadSkin', originalClothes)
        originalClothes = nil
    end
    if playerVehicle then
        DeleteVehicle(playerVehicle)
        playerVehicle = nil
    end
    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end
    if spawnedDog then
        DeleteEntity(spawnedDog)
        spawnedDog = nil
    end
    hasDog = false
end)

RegisterNetEvent('animalcontrol:dispatchCall')
AddEventHandler('animalcontrol:dispatchCall', function(loc)
    ESX.ShowNotification('Dispatch: Aggressive dog reported!')
    if currentBlip then
        RemoveBlip(currentBlip)
    end
    currentBlip = AddBlipForCoord(loc.x, loc.y, loc.z)
    SetBlipSprite(currentBlip, 141) -- Dog icon
    SetBlipColour(currentBlip, 1)
    SetBlipRoute(currentBlip, true)
    SetBlipRouteColour(currentBlip, 1)
end)

-- Main job loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if currentBlip and not spawnedDog then
            local blipCoords = GetBlipInfoIdCoord(currentBlip)
            if GetDistanceBetweenCoords(coords, blipCoords, true) < 30.0 then
                local heading = math.random(0, 359) + 0.0
                local dogIndex = math.random(1, #Config.DogModels)
                local dogModel = Config.DogModels[dogIndex]
                local model = GetHashKey(dogModel)
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end
                spawnedDog = CreatePed("PED_TYPE_ANIMAL", model, blipCoords.x, blipCoords.y, blipCoords.z, heading, true, true)
                SetEntityAsMissionEntity(spawnedDog, true, true)
                SetPedFleeAttributes(spawnedDog, 0, false)
                SetPedCombatAttributes(spawnedDog, 46, true)
                SetPedCombatAbility(spawnedDog, 2)
                SetPedCombatMovement(spawnedDog, 3)
                TaskCombatPed(spawnedDog, playerPed, 0, 16)
            end
        end

        if spawnedDog and DoesEntityExist(spawnedDog) and not hasDog then
            if GetDistanceBetweenCoords(coords, GetEntityCoords(spawnedDog), true) < 3.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to catch the dog')
                if IsControlJustReleased(0, 38) then
                    local success = Minigame()
                    if success then
                        ClearPedTasks(spawnedDog)
                        SetBlockingOfNonTemporaryEvents(spawnedDog, true)
                        AttachEntityToEntity(spawnedDog, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0.0, -0.3, 0.0, 0.0, -90.0, false, false, false, false, 2, true) -- Attach to right hand
                        hasDog = true
                        RemoveBlip(currentBlip)
                        currentBlip = nil
                        ESX.ShowNotification('Dog caught! Take it to your vehicle.')
                    else
                        ESX.ShowNotification('Failed to catch the dog!')
                        
                    end
                end
            end
        end
    end
end)

function Minigame()
    ESX.ShowNotification('Mash E to catch the dog!')
    local count = 0
    local timer = GetGameTimer() + 5000 -- 5 seconds to mash
    while GetGameTimer() < timer do
        Citizen.Wait(0)
        ESX.ShowHelpNotification('Mash ~INPUT_CONTEXT~ (' .. count .. '/25)')
        if IsControlJustReleased(0, 38) then
            count = count + 1
        end
    end
    return count >= 25 -- Number of times e needs to be mashed to catch the dog, adjust difficulty by changing the required count
end