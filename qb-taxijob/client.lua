local Lang = require('locales/en')
local my_webui = WebUI('qb-taxijob', 'qb-taxijob/html/index.html')

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
    local model = vehicle.Object
    local modelName = model:GetName()
    print(modelName)
end)

RegisterClientEvent('qb-taxijob:client:enableMeter', function()
    local vehicle = GetVehiclePedIsIn(GetPlayerPawn())
    local model = vehicle.Object
    local modelName = model:GetName()
    print(modelName)
end)

local inZone = false
local currentBenchIndex = nil

RegisterClientEvent('qb-taxijob:client:pickupSpot', function(coords, benchIndex)
    currentBenchIndex = benchIndex
    coords.X = coords.X + 300
    local CurrentZone = Trigger(coords, Rotator(), Vector(100), TriggerType.Sphere, true, function()
        inZone = true
        exports['qb-core']:DrawText('[E] - Pickup NPC', 'left')
    end)
    local Shape = CurrentZone:K2_GetComponentByClass(UE.UShapeComponent)
    Shape.OnComponentEndOverlap:Add(HWorld, function(_)
        inZone = false
        exports['qb-core']:HideText()
    end)
end)

-- Input

Input.BindKey('E', function()
    if not inZone then return end
    TriggerServerEvent('qb-taxijob:server:pickupNPC', currentBenchIndex)
end)
