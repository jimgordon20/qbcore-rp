local is_working = false
local current_marker = nil
local location = nil
local hasPassenger = false

for k, blip in pairs(Config.JobLocations) do
    Events.Call('Map:AddBlip', {
        id = 'start_taxi_' .. k,
        name = 'Start Taxi',
        coords = { x = blip.coords.X, y = blip.coords.Y, z = blip.coords.Z},
        imgUrl = './media/map-icons/Marker.svg',
        group = 'Start Taxi Job',
    })
end

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-taxijob:server:getPeds', function(jobPeds)
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
    Events.Call('Map:RemoveBlip', 'taxi_job')
    QBCore.Functions.TriggerCallback('qb-taxijob:server:getJob', function(jobLocation, isPickingUp)
        hasPassenger = not isPickingUp -- if new job, hasPassenger is false
        location = jobLocation -- Could be pickup, or dropoff (tracked server-side per source)
        QBCore.Functions.Notify(hasPassenger and 'Go to dropoff' or 'Pick up passenger')
        Events.Call('Map:AddBlip', {
            id = 'taxi_job',
            name = 'Taxi Job',
            coords = { x = jobLocation.X, y = jobLocation.Y, z = jobLocation.Z},
            imgUrl = './media/map-icons/Marker.svg',
            group = newPassenger and 'Taxi Pickup' or 'Taxi Dropoff',
        })
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
    getNextLocation()
    Events.CallRemote('qb-taxijob:server:spawnTaxi')
end)

Input.Subscribe('KeyDown', function(key_name)
    if not is_working then return end
    if key_name == 'F' then
        local playerPed = Client.GetLocalPlayer():GetControlledCharacter()
        if not playerPed then return end
        if playerPed:GetLocation():Distance(location) > 1000 then return end
        if not hasPassenger then -- If passenger isn't in vehicle
            Events.CallRemote('qb-taxijob:server:pickupPassenger')
            QBCore.Functions.Notify('You have picked up your passenger, head to the location marked.', 'success')
            hasPassenger = true -- Passenger is in vehicle
        else
            Events.CallRemote('qb-taxijob:server:dropoff')
        end
        getNextLocation()
    end
end)
