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
                label = 'Start Working',
                icon = 'fas fa-taxi',
                job = 'taxi'
            },
        },
        distance = 400,
    }
end

QBCore.Functions.CreateCallback('qb-taxijob:server:getPeds', function(_, cb)
    cb(peds)
end)

QBCore.Functions.CreateCallback('qb-taxijob:server:getJob', function(source, cb, currentPassenger)
    local location = Config.NPCLocations[math.random(#Config.NPCLocations)]
    -- Need to figure a way for rotations

    if not currentPassenger then
        local ped = HCharacter(location, Rotator(0, 0, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
        ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
        ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
        ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
        ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')
        activeJobs[source:GetID()] = source:GetControlledCharacter():GetLocation():Distance(location) -- Pre-calculate distance, used for calculating reward rather than listening to client for reward
        return cb(location, ped)
    end

    cb(location)
end)

Events.SubscribeRemote('qb-taxijob:server:spawnTaxi', function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local vehicle = QBCore.Functions.CreateVehicle(source, 'bp_police', Vector(-192792.4, 81737.2, 187.9), Rotator(0, 173, 0))
    ped:EnterVehicle(vehicle)
end)

Events.SubscribeRemote('qb-taxijob:server:pickupPassenger', function(source, ped)
    local playerPed = source:GetControlledCharacter()
    if not playerPed or not ped then return end
    ped:Destroy()
end)

Events.SubscribeRemote('qb-taxijob:server:dropoff', function(source)
    if not activeJobs[source:GetID()] then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local jobDistance = activeJobs[source:GetID()]
    Player.Functions.AddMoney('cash', jobDistance * Config.Meter.Rate + Config.Meter.StartingPrice)
end)