local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local is_working = false
local current_marker = nil
Location = nil

for k, depot in pairs(Config.Locations.Depots) do
    Events.Call('Map:RemoveBlip', 'bus_depot' .. k) -- Cleanup blips on startup
    Events.Call('Map:AddBlip', {
        id = 'bus_depot' .. k,
        name = depot.label,
        coords = { x = depot.pedSpawn.coords.X, y = depot.pedSpawn.coords.Y, z = depot.pedSpawn.coords.Z },
        imgUrl = './media/map-icons/Marker.svg',
        group = 'Bus Job',
    })
end

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-busjob:server:getPeds', function(jobPeds)
        for ped, data in pairs(jobPeds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end

local function getNextLocation(depot)
    if current_marker then
        current_marker:Destroy()
        current_marker = nil
    end
    Events.Call('Map:RemoveBlip', 'bus_job')
    QBCore.Functions.TriggerCallback('qb-busjob:server:getLocation', function(stop)
        if not stop then 
            Location = nil 
            is_working = false -- Route finished
            return
        end
        Location = Config.NPCLocations[stop]
        QBCore.Functions.Notify(Lang:t('info.goto_busstop'), 'info')
        Events.Call('Map:AddBlip', {
            id = 'bus_job',
            name = Lang:t('text.blip_bus_stop'),
            coords = { x = Location.X, y = Location.Y, z = Location.Z},
            imgUrl = './media/map-icons/Marker.svg',
            group = 'Bus Job',
        })
    end, depot)
end

-- Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        setupPeds()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    setupPeds()
end)

Events.Subscribe('qb-busjob:client:start', function(args)
    if is_working then return QBCore.Functions.Notify(Lang:t('error.one_bus_active'), 'error') end
    is_working = true
    getNextLocation(args.depot)
    -- current_marker = Prop(dropoff_location, Rotator(0, 0, 0), 'pco-markers::SM_MarkerArrow')
    -- current_marker:SetMaterialColorParameter('Color', Color(255, 0, 0, 1))
    -- current_marker:SetScale(Vector(100, 100, 100))
end)

Events.Subscribe('qb-busjob:client:cancelJob', function()
    is_working = false
    Events.CallRemote('qb-busjob:server:cancelJob')
end)

Input.Subscribe('KeyDown', function(key_name)
    if not is_working or not Location then return end
    if key_name == 'F' then
        local player_ped = Client.GetLocalPlayer():GetControlledCharacter()
        if not player_ped then return end
        local vehicle = QBCore.Functions.GetClosestHVehicle()
        if not vehicle or vehicle:GetVehicleSpeed() > 10 then return end -- if going too fast, don't allow pickup
        local player_location = player_ped:GetLocation()
        if player_location:Distance(Location) > 1000 then return end -- might need to up distance for bus vehicle
        getNextLocation()
    end
end)
