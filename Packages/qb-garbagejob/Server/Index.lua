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
                type = 'client',
                event = 'qb-garbagejob:client:cancelJob',
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
    local route = routes[source:GetID()] or {}
    local nextStop = route.currentStop and route.currentStop + 1 or 1
    routes[source:GetID()] = {currentStop = nextStop, bagAmount = math.random(Config.MinBagsPerStop, Config.MaxBagsPerStop), bagsDone = route.bagsDone or 0, maxStops = route.maxStops or math.random(Config.MinStops, #Config.Locations.Dumpsters), pay = route.pay or 0 }
    return nextStop
end

local function CompleteJob(source)
    local route = routes[source:GetID()]
    if not route then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    Events.CallRemote('qb-garbagejob:client:addTargets', source, nil, nil)
    Events.CallRemote('QBCore:Notify', source, Lang:t('success.reward', { amount = route.pay }), 'success') -- Locale
    Player.Functions.AddMoney('bank', route.pay, 'qb-garbagejob:completedJob')
    routes[source:GetID()] = nil
end

-- Events

Events.SubscribeRemote('qb-garbagejob:server:startJob', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end
    local ped = source:GetControlledCharacter()
    if routes[source:GetID()] then
        if ped:GetValue('holdingBag', nil) then ped:SetValue('holdingBag', nil, true) end
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.route_busy'), 'error')
        return
    end -- Locale
    local depot = Config.Locations.Depots[args.depot]
    if not depot then return end
    
    local vehicle = QBCore.Functions.CreateVehicle(source, Config.Vehicle, depot.vehicleSpawn.coords, Rotator(0, depot.vehicleSpawn.heading, 0))
    local nextStop = SetNextLocation(source)
    Events.CallRemote('QBCore:Notify', source, Lang:t('success.new_route', { stops = routes[source:GetID()].maxStops }), 'success') -- Locale
    
    Events.CallRemote('qb-garbagejob:client:addTargets', source, vehicle, nextStop)
end)

Events.SubscribeRemote('qb-garbagejob:server:cancelJob', function(source, vehicle)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end

    if vehicle and vehicle:IsValid() then vehicle:Destroy() end

    local route = routes[source:GetID()]
    if not route then return Events.CallRemote('QBCore:Notify', source, Lang:t('error.no_route'), 'error') end -- Locale

    CompleteJob(source)
end)

Events.SubscribeRemote('qb-garbagejob:server:grabBag', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local garbageBag = Prop(ped:GetLocation(), ped:GetRotation(), 'abcca-qbcore::SM_Trash', CollisionType.NoCollision)
    -- Rotate bag to be more realistic
    garbageBag:AttachTo(ped, AttachmentRule.KeepRelative, 'hand_r')
    ped:SetValue('holdingBag', garbageBag, true)

    Events.CallRemote('QBCore:Notify', source, Lang:t('info.load_bag'), 'info')
end)

Events.SubscribeRemote('qb-garbagejob:server:loadBag', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'garbage' then return end

    local route = routes[source:GetID()]
    if not route then return end

    local ped = source:GetControlledCharacter()
    if not ped or not ped:GetValue('holdingBag', nil) then return end
    if not ped:GetValue('holdingBag', nil):IsValid() then ped:SetValue('holdingBag', nil, true) return end -- bag is invalid prop

    ped:GetValue('holdingBag', nil):Destroy()
    ped:SetValue('holdingBag', nil, true)
    routes[source:GetID()].bagsDone = route.bagsDone + 1
    routes[source:GetID()].pay = route.pay + math.random(Config.BagLowerWorth, Config.BagUpperWorth)
    if routes[source:GetID()].bagsDone < routes[source:GetID()].bagAmount then return Events.CallRemote('QBCore:Notify', source, Lang:t('info.bags_remaining', { bags = route.bagAmount - route.bagsDone }), 'info') end -- if more bags, keep going

    if routes[source:GetID()].currentStop >= routes[source:GetID()].maxStops then -- if no more bags, and at last stop, complete
        CompleteJob(source)
        return
    end

    -- set next location
    local nextStop = SetNextLocation(source)
    Events.CallRemote('QBCore:Notify', source, Lang:t('info.stops_remaining', { stops = route.maxStops - route.currentStop }), 'info') -- Locale
    Events.CallRemote('qb-garbagejob:client:addTargets', source, nil, nextStop)
end)