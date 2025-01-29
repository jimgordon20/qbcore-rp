local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local peds = {}
local routes = {}

for i = 1, #Config.Locations.Depots do
    local location_info = Config.Locations.Depots[i]
    local coords = location_info.pedSpawn.coords
    local heading = location_info.pedSpawn.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')

    peds[ped] = {
        options = {
            {
                type = 'client',
                event = 'qb-busjob:client:start',
                label = Lang:t('text.start_working'),
                icon = 'fas fa-bus',
                job = 'bus',
                depot = i,
            },
            {
                type = 'client',
                event = 'qb-busjob:client:cancelJob',
                label = Lang:t('text.stop_working'),
                icon = 'fas fa-xmark',
                job = 'bus',
            }
        },
        distance = 400,
    }
end

-- Functions

local function CreateVehicle(source, depot)
    local depotData = Config.Locations.Depots[depot]
    return QBCore.Functions.CreateVehicle(source, Config.Vehicle, depotData.vehicleSpawn.coords, Rotator(0, depotData.vehicleSpawn.heading, 0))
end

local function SetNextLocation(source)
    local route = routes[source:GetID()] or {}
    local nextStop = route.currentStop and route.currentStop + 1 or 1
    routes[source:GetID()] = {currentStop = nextStop, maxStops = route.maxStops or math.random(#Config.NPCLocations)}
    return nextStop
end

local function PayPlayer(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'bus' then return end
    local route = routes[source:GetID()]
    if route.vehicle and route.vehicle:IsValid() then route.vehicle:Destroy() end

    local payment = route.currentStop * math.random(200, 400) -- Could be configurable
    Player.Functions.AddMoney('bank', payment, 'qb-busjob:completedJob')
    Events.CallRemote('QBCore:Notify', source,  Lang:t('success.reward', { amount = payment }), 'success')
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-busjob:server:getPeds', function(_, cb)
    cb(peds)
end)

QBCore.Functions.CreateCallback('qb-busjob:server:getLocation', function(source, cb, depot)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'bus' then return end

    local route = routes[source:GetID()]
    if route then
        if route.ped:IsValid() then route.ped:Destroy() end -- Destroy last ped for pickup
        
        if route.currentStop >= route.maxStops then
            Events.CallRemote('QBCore:Notify', source, Lang:t('success.completed_route'), 'success')
            PayPlayer(source)
            return cb(false) -- Reset location on client
        else
            Events.CallRemote('QBCore:Notify', source, Lang:t('info.stops_left', { stops = route.maxStops - route.currentStop }, 'info'))
        end
    end

    local stop = SetNextLocation(source)
    if stop == 1 then
        Events.CallRemote('QBCore:Notify', source, Lang:t('info.stops_total', { stops = routes[source:GetID()].maxStops }, 'info'))
        if depot then -- if depot was passed, it's valid to spawn a vehicle at depot
            local vehicle = CreateVehicle(source, depot)
            if vehicle then routes[source:GetID()].vehicle = vehicle end
        end
    end

    -- Need to figure a way for rotations
    local ped = HCharacter(Config.NPCLocations[stop], Rotator(0, 0, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')
    routes[source:GetID()].ped = ped

    cb(stop)
end)

-- Handlers

Package.Subscribe('unload', function()
    for _, route in ipairs(routes) do
        if route.ped and route.ped:IsValid() then
            route.ped:Destroy()
        end
        if route.vehicle and route.vehicle:IsValid() then
            route.vehicle:Destroy()
        end
    end
end)

Events.SubscribeRemote('qb-busjob:server:cancelJob', function(source)
    local route = routes[source:GetID()]
    if route then
        if route.ped and route.ped:IsValid() then route.ped:Destroy() end
        if route.vehicle and route.vehicle:IsValid() then route.vehicle:Destroy() end
        routes[source:GetID()] = nil
    end
end)