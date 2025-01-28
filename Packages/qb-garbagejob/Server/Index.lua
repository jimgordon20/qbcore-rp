local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local peds = {}
local routes = {}

for k, depot in pairs(Config.Locations.Depots) do
    local pedData = depot.pedSpawn
    local ped = HCharacter(pedData.coords, Rotator(0, pedData.heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'QBCore:ToggleDuty',
                label = 'Toggle Duty',
                icon = 'fas fa-clipboard',
                job = 'garbage',
            },
            {
                type = 'server',
                event = 'qb-garbagejob:server:startJob',
                label = 'Start Job',
                icon = 'fas fa-truck-field',
                job = 'garbage',
                depot = k,
            },
            {
                type = 'server',
                event = 'qb-garbagejob:server:cancelJob',
                label = 'Cancel Route',
                icon = 'fas fa-xmark',
                job = 'garbage',
            }
        },
        distance = 400,
    }
end

QBCore.Functions.CreateCallback('qb-garbagejob:server:getPeds', function(_, cb)
    cb(peds) -- Returns null/destroyed peds sometimes due to networking
end)

local function SetNextLocation(source)
    local route = routes[source:GetID()]
    local nextStop = route.currentStop and route.currentStop + 1 or 1
    routes[source:GetID()] = {currentStop = nextStop, bagAmount = math.random(Config.MinBagsPerStop, Config.MaxBagsPerStop), bagsDone = 0, pay = route.pay or 0 }
    return nextStop
end

-- Events

Events.SubscribeRemote('qb-garbagejob:server:startJob', function(source, depotLocation)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end
    if Routes[source:GetID()] then return Events.CallRemote('QBCore:Notify', source, 'You are already on a route, cancel the route to start a new one', 'error') end

    local depot = Config.Locations.Depots[depotLocation]
    if not depot then return end
    
    local vehicle = HSimpleVehicle(depot.vehicleSpawn.coords, Rotator(0, depot.vehicleSpawn.heading, 0), Config.Vehicle)
    local nextStop = SetNextLocation(source)
    routes[source:GetID()].maxStops = math.random(Config.MinStops, #Config.Locations.Dumpsters)
    
    Events.CallRemote('qb-garbagejob:client:addTargets', source, vehicle, nextStop)
end)

Events.SubscribeRemote('qb-garbagejob:server:cancelJob', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end

    local route = routes[source:GetID()]
    if not route then return Events.CallRemote('QBCore:Notify', source, 'You are not on a route', 'error') end

    -- Pay the player for the bags they've collected
end)

Events.SubscribeRemote('qb-garbagejob:server:loadBag', function()
    local route = routes[source:GetID()]
    if not route then return end

    local dumpsterCoords = Config.Locations.Dumpsters[route.currentStop].coords
    if dumpsterCoords:Distance(source:GetControlledCharacter():GetLocation()) > 2000 then return end
end)