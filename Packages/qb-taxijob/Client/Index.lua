local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
IsWorking = false
Location = nil
HasPassenger = false
local current_marker = nil

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
    QBCore.Functions.TriggerCallback('qb-taxijob:server:getLocation', function(jobLocation, isPickingUp)
        HasPassenger = not isPickingUp -- if new job, HasPassenger is false
        Location = jobLocation -- Could be pickup, or dropoff (tracked server-side per source)
        QBCore.Functions.Notify(HasPassenger and Lang:t('info.goto_dropoff') or Lang:t('info.pickup'), 'success')
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

Events.SubscribeRemote('QBCore:Player:SetPlayerData', function(PlayerData)
    if PlayerData.job.name ~= 'taxi' then return end
    IsWorking = PlayerData.job.onduty
end)

Events.Subscribe('qb-taxijob:client:start', function()
    IsWorking = not IsWorking -- Toggleable working state
    if not IsWorking then
        if Location then Events.CallRemote('qb-taxijob:server:cancelJob') end
        Location = nil
        return QBCore.Functions.Notify(Lang:t('success.clocked_off'), 'success') 
    end
    Events.CallRemote('qb-taxijob:server:spawnTaxi')
end)

Events.Subscribe('qb-taxijob:client:startMission', function()
    if not IsWorking then return QBCore.Functions.Notify(Lang:t('error.not_working'), 'error') end -- Could be removed and changed to a vehicle check
    if HasPassenger then return QBCore.Functions.Notify(Lang:t('error.has_passenger'), 'error') end
    if Location then Events.CallRemote('qb-taxijob:server:cancelJob') end
    getNextLocation()
end)

Input.Subscribe('KeyDown', function(key_name)
    if not IsWorking then return end
    if key_name == 'F' then
        local playerPed = Client.GetLocalPlayer():GetControlledCharacter()
        if not playerPed then return end
        local vehicle = QBCore.Functions.GetClosestHVehicle()
        if not vehicle or vehicle:GetVehicleSpeed() > 10 then return end
        if not Location or playerPed:GetLocation():Distance(Location) > 1000 then return end
        if not HasPassenger then -- If passenger isn't in vehicle
            Events.CallRemote('qb-taxijob:server:pickupPassenger')
            HasPassenger = true -- Passenger is in vehicle
            getNextLocation()
        else
            Events.CallRemote('qb-taxijob:server:dropoff')
            HasPassenger = false
            Location = nil
        end
    end
end)
