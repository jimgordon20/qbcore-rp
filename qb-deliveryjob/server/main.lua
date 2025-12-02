SharedVehicles = exports['qb-core']:GetShared('Vehicles')
local Peds = {}
local Initialised = false
require('locales/en')

-- Cleanup
function onShutdown()
    for i = 1, #Peds do
        local ped = Peds[i].Ped
        if ped and ped:IsValid() then
            DeleteEntity(ped)
        end
    end

    for _, job in pairs(Jobs) do
        job:Cleanup()
    end
end

-- Workaround for late joins seeing invisible mesh
RegisterServerEvent('HEvent:PlayerPossessed', function()
    if Initialised then return end
    for index, depot in pairs(Config.Depots) do
        HPawn(depot.pedSpawn.coords, Rotator(0, depot.pedSpawn.heading, 0), function(Pawn)
            if not Pawn then return end
            Peds[#Peds + 1] = {
                Ped = Pawn,
                Index = index,
            }
        end)
    end
    Initialised = true
end)

RegisterServerEvent('qb-deliveryjob:server:startDelivering', function(source, targetData)
    local depotIndex = targetData.depot
    local depotInfo = Config.Depots[depotIndex]
    if not depotInfo then return end

    local newJob = Job.new(source, depotInfo)
    TriggerClientEvent(source, 'qb-deliveryjob:client:setCurrentLocation', newJob.Route[1], newJob.Vehicle.Object, newJob.CurrentStop, newJob.MaxStops)
end)

RegisterServerEvent('qb-deliveryjob:server:spawnVehicle', function(source, vehicle)
    if not SharedVehicles[vehicle] then return end
    local pawn = GetPlayerPawn(source)
    if not pawn then return end

    local pawnLocation = pawn:K2_GetActorLocation()
    local forwardVec = pawn:GetActorForwardVector()
    local spawnPos = pawnLocation + (forwardVec * 500)
    spawnPos.Z = spawnPos.Z + 50

    local SpawnedVehicle = HVehicle(spawnPos, Rotator(), SharedVehicles[vehicle].asset_name)
    SpawnedVehicle:SetFuel(1.0)
end)

RegisterServerEvent('qb-deliveryjob:server:deliverPackage', function(source, jobId)
    local CurrentJob = Jobs[jobId]
    if not CurrentJob or CurrentJob.Courier ~= source then return end

    local Delivered = CurrentJob:DeliverPackage()
    if not Delivered then return end
    if CurrentJob.CurrentStop == CurrentJob.MaxStops then
        exports['qb-core']:Notify(source, 'That was your last stop. Return the truck for payment', 'success')
        TriggerClientEvent(source, 'qb-deliveryjob:client:setCurrentLocation', nil)
    else
        TriggerClientEvent(source, 'qb-deliveryjob:client:setCurrentLocation', CurrentJob.Route[1], CurrentJob.Vehicle.Object, CurrentJob.CurrentStop, CurrentJob.MaxStops)
    end

    return true
end)

RegisterCallback('finishDelivering', function(source, jobId)
    local CurrentJob = Jobs[jobId]
    if not CurrentJob or CurrentJob.Courier ~= source then return end

    local Paid = CurrentJob:Payout()
    if not Paid then return end
    
    CurrentJob:Cleanup()
    Jobs[CurrentJob.DeliveryId] = nil
end)

RegisterCallback('getJobPeds', function(source)
    return Peds
end)

RegisterCallback('server.pickupBox', function(source, jobId)
    local CurrentJob = Jobs[jobId]
    if not CurrentJob or CurrentJob.Courier ~= source then return end

    CurrentJob:CreateDeliveryProp()

    return true
end)