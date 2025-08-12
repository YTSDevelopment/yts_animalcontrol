local ESX = exports["es_extended"]:getSharedObject()
local onDuty = {}

RegisterServerEvent('animalcontrol:toggleDuty')
AddEventHandler('animalcontrol:toggleDuty', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.getJob().name ~= Config.JobName then
        TriggerClientEvent('esx:showNotification', src, 'You are not authorized for this job.')
        return
    end

    if not onDuty[src] then
        onDuty[src] = {caught = 0}
        TriggerClientEvent('animalcontrol:clockOn', src)
        TriggerClientEvent('esx:showNotification', src, 'You have clocked on as Animal Control.')
    else
        local payout = onDuty[src].caught * Config.PayoutPerDog
        xPlayer.addMoney(payout)
        TriggerClientEvent('esx:showNotification', src, 'You have clocked off. Earned: $' .. payout)
        TriggerClientEvent('animalcontrol:clockOff', src)
        onDuty[src] = nil
    end
end)

RegisterServerEvent('animalcontrol:caughtDog')
AddEventHandler('animalcontrol:caughtDog', function()
    local src = source
    if onDuty[src] then
        onDuty[src].caught = onDuty[src].caught + 1
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.DispatchInterval)
        for src, _ in pairs(onDuty) do
            local locIndex = math.random(1, #Config.CallLocations)
            local loc = Config.CallLocations[locIndex]
            TriggerClientEvent('animalcontrol:dispatchCall', src, loc)
        end
    end
end)