local is_working = false
local current_marker = nil
local dropoff_Location = Vector(0, 0, 0)

for k, depot in pairs(Config.Locations.Depots) do
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

local function getNextLocation()
    if current_marker then
        current_marker:Destroy()
        current_marker = nil
    end
    dropoff_Location = Config.Locations[math.random(#Config.Locations)]
    -- current_marker = Prop(dropoff_location, Rotator(0, 0, 0), 'pco-markers::SM_MarkerArrow')
    -- current_marker:SetMaterialColorParameter('Color', Color(255, 0, 0, 1))
    -- current_marker:SetScale(Vector(100, 100, 100))
end

-- Event Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        setupPeds()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    setupPeds()
end)

Events.Subscribe('qb-busjob:client:start', function()
    if is_working then return end
    is_working = true
    Events.CallRemote('qb-busjob:server:spawnBus')
    dropoff_Location = Config.NPCLocations[math.random(#Config.NPCLocations)]
    print(dropoff_Location)
    current_marker = Prop(dropoff_location, Rotator(0, 0, 0), 'pco-markers::SM_MarkerArrow')
    current_marker:SetMaterialColorParameter('Color', Color(255, 0, 0, 1))
    current_marker:SetScale(Vector(100, 100, 100))
end)

Input.Subscribe('KeyDown', function(key_name)
    if not is_working or not dropoff_location then return end
    if key_name == 'E' then
        local player = Client.GetLocalPlayer()
        local player_ped = player:GetControlledCharacter()
        if not player_ped then return end
        local player_location = player_ped:GetLocation()
        local distance = player_location:Distance(dropoff_Location)
        print(distance)
        if distance > 1000 then return end
        Events.CallRemote('qb-busjob:server:dropoff', dropoff_Location)
        getNextLocation()
    end
end)
