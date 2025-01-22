local peds = {}
local activeJobs = {}
for i = 1, #Config.JobLocations do
    local location_info = Config.JobLocations[i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')

    peds[ped] = {
        options = {
            {
                type = 'client',
                event = 'qb-taxijob:client:start',
                label = 'Start/Stop Working',
                icon = 'fas fa-taxi',
                job = 'taxi'
            },
        },
        distance = 400,
    }
end

local function CancelJob(source)
    local job = activeJobs[source:GetID()]
    if not job then return end
    
    if job.passenger and job.passenger:IsValid() then job.passenger:Destroy() end
    activeJobs[source:GetID()] = nil
    Events.Call('Map:RemoveBlip', source, 'taxi_job')
end

local function GetRandomLocation(currentCoords)
    local location = Config.NPCLocations[math.random(#Config.NPCLocations)]
    if location:Distance(currentCoords) < 1000 then return GetRandomLocation(currentCoords) end
    return location
end

QBCore.Functions.CreateCallback('qb-taxijob:server:getPeds', function(_, cb)
    cb(peds) -- Returns null/destroyed peds sometimes due to networking
end)

QBCore.Functions.CreateCallback('qb-taxijob:server:getLocation', function(source, cb)
    local location = GetRandomLocation(source:GetControlledCharacter():GetLocation())
    -- Need to figure a way for rotations
    if not activeJobs[source:GetID()] then
        local ped = HCharacter(location, Rotator(0, 0, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
        ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
        ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
        ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
        ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')
        activeJobs[source:GetID()] = { passenger = ped }
        return cb(location, true) -- location, isPickingUp
    end
    activeJobs[source:GetID()].distance = source:GetControlledCharacter():GetLocation():Distance(location) -- Pre-calculate distance, used for calculating reward rather than listening to client for reward
    cb(location, false) -- location, isPickingUp
end)

Events.Subscribe('QBCore:Server:OnPlayerUnload', function(source)
    CancelJob(source) -- Cancel job if player unloads
end)

Events.SubscribeRemote('qb-taxijob:server:spawnTaxi', function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local vehicle = QBCore.Functions.CreateVehicle(source, 'bp_police', Vector(-192792.4, 81737.2, 187.9), Rotator(0, 173, 0))
    ped:EnterVehicle(vehicle)
end)

Events.SubscribeRemote('qb-taxijob:server:pickupPassenger', function(source)
    local job = activeJobs[source:GetID()]
    if not job.passenger or not job.passenger:IsValid() then return end
    activeJobs[source:GetID()].passenger:Destroy() -- Remove ped, simulate getting into vehicle
end)

Events.SubscribeRemote('qb-taxijob:server:dropoff', function(source)
    if not activeJobs[source:GetID()] then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local amount = math.floor(activeJobs[source:GetID()].distance * Config.Meter.Rate + Config.Meter.StartingPrice)
    activeJobs[source:GetID()] = nil
    Player.Functions.AddMoney('cash', amount, 'qb-taxijob:server:dropoff')
    Events.CallRemote('QBCore:Notify', source, 'You were paid $'.. amount, 'success')
end)

Events.SubscribeRemote('qb-taxijob:server:cancelJob', function(source)
    CancelJob(source)
    Events.CallRemote('QBCore:Notify', source 'You cancelled your current job', 'error')
end)