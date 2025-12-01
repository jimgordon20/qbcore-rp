local Lang = require('locales/en')
local my_webui = WebUI('qb-taxijob', 'qb-taxijob/html/index.html')
local meterOpen = false
local meterActive = false
local inPickupZone = false
local inDropoffZone = false
local currentPickupBenchIndex = nil
local currentDropoffBenchIndex = nil
local pickupZone = nil
local dropoffZone = nil

-- UI Events

my_webui:RegisterEventHandler('enableMeter', function()

end)

-- Functions

function onShutdown()
    if my_webui then
        my_webui:Destroy()
        my_webui = nil
    end
end

-- Events

local function setupPeds()
    TriggerCallback('getPeds', function(jobPeds)
        for i = 1, #jobPeds do
            local ped = jobPeds[i].npc
            local distance = 1000
            local options = {
                {
                    type = 'server',
                    event = 'QBCore:ToggleDuty',
                    label = Lang:t('target.toggle_duty'),
                    icon = 'fas fa-clipboard',
                    job = 'taxi'
                },
                {
                    type = 'server',
                    event = 'qb-taxijob:server:takeVehicle',
                    label = Lang:t('target.take_vehicle'),
                    icon = 'fas fa-truck-field',
                    job = 'taxi',
                    depot = jobPeds[i].depot
                },
                {
                    type = 'server',
                    event = 'qb-taxijob:server:finishWork',
                    label = Lang:t('target.finish_work'),
                    icon = 'fas fa-circle-check',
                    job = 'taxi'
                }
            }
            exports['qb-target']:AddTargetEntity(ped, { options = options, distance = distance })
        end
    end)
end

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    setupPeds()
end)

RegisterClientEvent('qb-taxijob:client:toggleMeter', function()
    local vehicle = GetVehiclePedIsIn(GetPlayerPawn())
    if not vehicle then return end
    if not meterOpen then
        my_webui:SendEvent('openMeter', { toggle = true, meterData = Config.Meter })
        meterOpen = true
    else
        my_webui:SendEvent('openMeter', { toggle = false })
        meterOpen = false
    end
end)

RegisterClientEvent('qb-taxijob:client:enableMeter', function()
    local vehicle = GetVehiclePedIsIn(GetPlayerPawn())
    if not vehicle then return end
    if meterOpen then
        my_webui:SendEvent('toggleMeter')
    end
end)

RegisterClientEvent('qb-taxijob:client:pickupSpot', function(coords, benchIndex)
    coords.X = coords.X + 300
    if pickupZone then
        DeleteEntity(pickupZone)
    end

    pickupZone = Trigger(coords, Rotator(), Vector(100), TriggerType.Sphere, true, function()
        inPickupZone = true
        currentPickupBenchIndex = benchIndex
        exports['qb-core']:DrawText('[E] - Pickup NPC', 'left')
    end)

    local Shape = pickupZone:GetComponentByClass(UE.UShapeComponent)
    Shape.OnComponentEndOverlap:Add(HWorld, function(_)
        inPickupZone = false
        currentPickupBenchIndex = nil
        exports['qb-core']:HideText()
    end)
end)

RegisterClientEvent('qb-taxijob:client:dropoffSpot', function(coords, benchIndex)
    if pickupZone then
        DeleteEntity(pickupZone)
        pickupZone = nil
    end
    inPickupZone = false
    currentPickupBenchIndex = nil
    exports['qb-core']:HideText()
    dropoffZone = Trigger(coords, Rotator(), Vector(100), TriggerType.Sphere, true, function()
        inDropoffZone = true
        currentDropoffBenchIndex = benchIndex
        exports['qb-core']:DrawText('[E] - Drop Off NPC', 'left')
    end)

    local Shape = dropoffZone:GetComponentByClass(UE.UShapeComponent)
    Shape.OnComponentEndOverlap:Add(HWorld, function(_)
        inDropoffZone = false
        currentDropoffBenchIndex = nil
        exports['qb-core']:HideText()
    end)
end)

RegisterClientEvent('qb-taxijob:client:jobComplete', function()
    if dropoffZone then
        DeleteEntity(dropoffZone)
        dropoffZone = nil
    end
    inDropoffZone = false
    currentDropoffBenchIndex = nil
    exports['qb-core']:HideText()

    exports['qb-core']:Notify('Job complete! Great work!', 'success')
end)

-- Input

Input.BindKey('E', function()
    if inPickupZone and currentPickupBenchIndex then
        my_webui:SendEvent('toggleMeter')
        TriggerServerEvent('qb-taxijob:server:pickupNPC', currentPickupBenchIndex)
    elseif inDropoffZone and currentDropoffBenchIndex then
        my_webui:SendEvent('resetMeter')
        TriggerServerEvent('qb-taxijob:server:dropoffNPC', currentDropoffBenchIndex)
    end
end)
