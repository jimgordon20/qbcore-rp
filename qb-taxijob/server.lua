local Lang = require('locales/en')
local playerVehicles = {}
local benches = {}
local jobPeds = {}
local pickupNPCs = {}

function OnShutdown()
    for _, v in pairs(benches) do
        if v and v:IsValid() then
            DeleteEntity(v)
        end
    end
    benches = {}

    for i = 1, #jobPeds do
        local ped = jobPeds[i].npc
        if ped and ped:IsValid() then
            DeleteEntity(ped)
        end
    end
    jobPeds = {}
end

for i = 1, #Config.Locations['Benches'] do
    local bench = StaticMesh(
        Config.Locations['Benches'][i].coords,
        Rotator(0, Config.Locations['Benches'][i].heading, 0),
        '/Game/QBCore/Meshes/SM_BusStop.SM_BusStop'
    )
    benches[bench.Object] = bench.Object
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

-- Events

RegisterServerEvent('qb-taxijob:server:takeVehicle', function(source, args)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'taxi' then
        print('qb-taxijob:server:takeVehicle - Player job is not taxi')
        return
    end
    local depot = Config.Locations.Depots[args.depot]
    if not depot then return end
    local vehicle = HVehicle(depot.vehicleSpawn.coords, Rotator(0, depot.vehicleSpawn.heading, 0), Config.Vehicle)
    playerVehicles[GetPlayerId(source)] = vehicle
end)

RegisterServerEvent('qb-taxijob:server:finishWork', function(source)
    local playerId = GetPlayerId(source)
    local vehicle = playerVehicles[playerId]
    if vehicle and vehicle:IsValid() then
        DeleteVehicle(vehicle)
        playerVehicles[playerId] = nil
    end
end)

RegisterServerEvent('qb-taxijob:server:startWork', function(source)
    local vehicle = GetVehiclePedIsIn(GetPlayerPawn(source))
    local model = vehicle.Object
    local modelName = model:GetName()
    print(modelName)

    for i = 1, #Config.Locations['Benches'] do
        if not Config.Locations['Benches'][i].npc then
            local coords = Config.Locations['Benches'][i].coords
            coords.X = coords.X + 100
            HPawn(coords, Rotator(0, 0, 0), function(npc)
                pickupNPCs[#pickupNPCs + 1] = npc
                Config.Locations['Benches'][i].npc = npc
            end)
            TriggerClientEvent(source, 'qb-taxijob:client:pickupSpot', coords, i)
        end
    end
end)

RegisterServerEvent('qb-taxijob:server:pickupNPC', function(source, benchIndex)
    if Config.Locations['Benches'][benchIndex] and Config.Locations['Benches'][benchIndex].npc then
        local npc = Config.Locations['Benches'][benchIndex].npc
        if npc and npc:IsValid() then
            DeleteEntity(npc)
            Config.Locations['Benches'][benchIndex].npc = nil
        end
    end
end)
