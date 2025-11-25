local Lang = require('locales/en')
local jobPeds = {}
local dumpsters = {}
local routes = {}

RegisterServerEvent('HEvent:PlayerUnloaded', function(source)
    local route = routes[GetPlayerId(source)]
    if route then
        if route.vehicle and route.vehicle:IsValid() then
            DestroyVehicle(route.vehicle)
        end
        if route.holdingBag and route.holdingBag:IsValid() then
            DestroyEntity(route.holdingBag)
        end
        routes[GetPlayerId(source)] = nil
    end
end)

function OnShutdown()
    for i = 1, #dumpsters do
        DestroyEntity(dumpsters[i])
    end
    dumpsters = {}

    for i = 1, #jobPeds do
        DestroyEntity(jobPeds[i].npc)
    end
    jobPeds = {}
end

for i = 1, #Config.Locations['Dumpsters'] do
    local dumpster = StaticMesh(
        Config.Locations['Dumpsters'][i].coords,
        Rotator(0, Config.Locations['Dumpsters'][i].heading, 0),
        '/Game/QBCore/Meshes/SM_Dumpster.SM_Dumpster'
    )
    dumpsters[#dumpsters + 1] = dumpster
end

for i = 1, #Config.Locations['Depots'] do
    HPawn(Config.Locations['Depots'][i].pedSpawn.coords, Rotator(0, Config.Locations['Depots'][i].pedSpawn.heading, 0), function(npc)
        jobPeds[#jobPeds + 1] = { npc = npc, depot = i }
    end)
end

-- Callbacks

RegisterCallback('getPeds', function()
    return jobPeds
end)

-- Functions

local function SetupRoute(source)
    local route = routes[GetPlayerId(source)] or {}
    routes[GetPlayerId(source)] = {
        stopsCompleted = route.stopsCompleted or 0,
        maxStops = route.maxStops or math.random(Config.MinStops, Config.MaxStops),
        pay = route.pay or 0,
        holdingBag = route.holdingBag or nil,
        vehicle = route.vehicle or nil,
        collectedDumpsters = route.collectedDumpsters or {},
    }
end

local function CompleteJob(source, returnedTruck)
    local route = routes[GetPlayerId(source)]
    if not route then return end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end

    if not returnedTruck and route.vehicle and route.vehicle:IsValid() then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.truck_not_returned'), 'error')
        return
    end

    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('success.reward', { amount = route.pay }), 'success')
    exports['qb-core']:Player(source, 'AddMoney', 'bank', route.pay, 'qb-garbagejob:completedJob')

    if route.vehicle and route.vehicle:IsValid() then
        TriggerClientEvent(source, 'qb-garbagejob:client:removeTargets', route.vehicle)
        DestroyVehicle(route.vehicle)
    end

    if route.holdingBag and route.holdingBag:IsValid() then
        DestroyEntity(route.holdingBag)
    end

    routes[GetPlayerId(source)] = nil
end

-- Events

RegisterServerEvent('qb-garbagejob:server:startJob', function(source, args)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end
    if routes[GetPlayerId(source)] then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.route_busy'), 'error')
        return
    end
    SetupRoute(source)
    local depot = Config.Locations.Depots[args.depot]
    if not depot then return end
    local vehicle = HVehicle(depot.vehicleSpawn.coords, Rotator(0, depot.vehicleSpawn.heading, 0), Config.Vehicle)
    routes[GetPlayerId(source)].vehicle = vehicle
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('success.new_route', { stops = routes[GetPlayerId(source)].maxStops }), 'success')
    TriggerClientEvent(source, 'qb-garbagejob:client:addTargets', vehicle)
end)

RegisterServerEvent('qb-garbagejob:server:completeJob', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'garbage' then return end
    local route = routes[GetPlayerId(source)]
    if not route then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.no_route'), 'error')
        return
    end

    if not route.vehicle or not route.vehicle:IsValid() then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.no_vehicle'), 'error')
        return
    end

    local ped = GetPlayerPawn(source)
    if not ped then return end
    local pedCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(route.vehicle)
    local distance = GetDistanceBetweenCoords(pedCoords, vehicleCoords)

    if distance > 2500 then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.truck_too_far'), 'error')
        return
    end

    CompleteJob(source, true)
end)

RegisterServerEvent('qb-garbagejob:server:grabBag', function(source, data)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end

    local route = routes[GetPlayerId(source)]
    if not route then return end

    if not data.entity or not dumpsters[data.entity] then
        print('qb-garbagejob:server:grabBag - Invalid dumpster entity')
        return
    end

    if route.holdingBag and route.holdingBag:IsValid() then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.already_holding_bag'), 'error')
        return
    end

    if route.collectedDumpsters[data.entity] then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.already_collected'), 'error')
        return
    end

    local ped = GetPlayerPawn(source)
    if not ped then return end
    local mesh = ped:GetCharacterBaseMesh()
    local coords = GetEntityCoords(ped)
    local rotation = GetEntityRotation(ped)
    local garbageBag = StaticMesh(coords, rotation, '/Game/QBCore/Meshes/SM_Trash.SM_Trash', CollisionType.NoCollision)
    AttachActorToComponent(garbageBag, mesh, Vector(-35, 0, 10), Rotator(-95, 0, 0), 'hand_r', nil, true)

    routes[GetPlayerId(source)].holdingBag = garbageBag
    routes[GetPlayerId(source)].collectedDumpsters[data.entity] = true

    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.load_bag'))
end)

RegisterServerEvent('qb-garbagejob:server:loadBag', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end
    local route = routes[GetPlayerId(source)]
    if not route then return end

    if not route.holdingBag or not route.holdingBag:IsValid() then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.no_bag'), 'error')
        return
    end

    DetachActor(route.holdingBag)
    DestroyEntity(route.holdingBag)
    routes[GetPlayerId(source)].holdingBag = nil

    routes[GetPlayerId(source)].stopsCompleted = route.stopsCompleted + 1
    routes[GetPlayerId(source)].pay = route.pay + math.random(Config.BagLowerWorth, Config.BagUpperWorth)

    if routes[GetPlayerId(source)].stopsCompleted >= routes[GetPlayerId(source)].maxStops then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('success.route_complete'), 'success')
        return
    end

    local remaining = routes[GetPlayerId(source)].maxStops - routes[GetPlayerId(source)].stopsCompleted
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.stops_remaining', { stops = remaining }))
end)
