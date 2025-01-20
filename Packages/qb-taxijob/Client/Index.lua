local is_working = false
local current_marker = nil
local dropoff_Location = Vector(0, 0, 0)

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-taxijob:server:getPeds', function(jobPeds)
        for ped, data in pairs(jobPeds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
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

Events.Subscribe('qb-taxijob:client:start', function()
    if is_working then return end
    is_working = true
    Events.CallRemote('qb-taxijob:server:spawnTaxi')
    dropoff_Location = Config.NPCLocations[math.random(#Config.NPCLocations)]
    print(dropoff_Location)
    current_marker = Prop(dropoff_Location, Rotator(0, 0, 0), 'pco-markers::SM_MarkerArrow')
    current_marker:SetMaterialColorParameter('Color', Color(255, 0, 0, 1))
    current_marker:SetScale(Vector(100, 100, 100))
    Events.Call('Map:AddBlip', {
        id = 'taxi_job',
        name = 'Taxi Job',
        coords = { x = dropoff_Location.X, y = dropoff_Location.Y, z = dropoff_Location.Z},
        imgUrl = './media/map-icons/Marker.svg',
    })
end)

local function getNextLocation()
    if current_marker then
        current_marker:Destroy()
        current_marker = nil
        Events.Call('Map:RemoveBlip', 'taxi_job')
    end
    dropoff_Location = Config.NPCLocations[math.random(#Config.NPCLocations)]
    print(dropoff_Location)
    current_marker = Prop(dropoff_Location, Rotator(0, 0, 0), 'pco-markers::SM_MarkerArrow')
    current_marker:SetMaterialColorParameter('Color', Color(255, 0, 0, 1))
    current_marker:SetScale(Vector(100, 100, 100))
    Events.Call('Map:AddBlip', {
        id = 'taxi_job',
        name = 'Taxi Job',
        coords = { x = dropoff_Location.X, y = dropoff_Location.Y, z = dropoff_Location.Z},
        imgUrl = './media/map-icons/Marker.svg',
    })
end

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
        Events.CallRemote('qb-taxijob:server:dropoff', dropoff_Location)
        getNextLocation()
    end
end)
