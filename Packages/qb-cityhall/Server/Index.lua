local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local availableJobs = Config.Jobs
local peds = {}

-- Peds

for _, locations in pairs(Config.Locations) do
    local coords = locations.coords
    local ped_coords = coords[1]
    local ped_heading = coords[2]
    local ped = HCharacter(ped_coords, ped_heading, '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')
    --ped:SetInvulnerable(true)
    --ped:SetImpactDamageTaken(0)
    peds[ped] = {
        options = {
            {
                type = 'client',
                event = 'qb-cityhall:client:open',
                label = 'City Hall',
                icon = 'fas fa-university',
            },
        },
        distance = 400,
    }
end

-- Functions

local function getClosestLocation(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local pedCoords = ped:GetLocation()
    local closest = nil
    local closestDist = 9999
    for index, locations in pairs(Config.Locations) do
        local coords = locations.coords
        local hallCoords = coords[1]
        local dist = #(pedCoords - hallCoords)
        if dist < closestDist then
            closest = index
            closestDist = dist
        end
    end
    return closest, closestDist
end

-- Exports

local function AddCityJob(jobName, toCH)
    if availableJobs[jobName] then return false, 'already added' end
    availableJobs[jobName] = {
        ['label'] = toCH.label,
        ['isManaged'] = toCH.isManaged
    }
    return true, 'success'
end

Package.Export('AddCityJob', AddCityJob)

-- Callbacks

QBCore.Functions.CreateCallback('qb-cityhall:server:getPeds', function(_, cb)
    cb(peds)
end)

QBCore.Functions.CreateCallback('qb-cityhall:server:receiveJobs', function(_, cb)
    cb(availableJobs)
end)

-- Events

Events.SubscribeRemote('qb-cityhall:server:requestId', function(source, item)
    local hall, distance = getClosestLocation(source)
    if not hall or distance > 500 then return end
    local itemInfo = Config.Locations[hall].licenses[item]
    if not itemInfo then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if itemInfo.cost > Player.PlayerData.money.cash then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_enough'), 'error')
        return
    end
    local info = {}
    if item == 'id_card' then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif item == 'driver_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = 'Class C Driver License'
    elseif item == 'weapon_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
    else
        return false
    end
    if not AddItem(source, item, 1, false, info, 'qb-cityhall:server:requestId') then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.item_failed', { value = item }), 'error')
    else
        Player.Functions.RemoveMoney('cash', itemInfo.cost, 'cityhall id')
        Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item], 'add')
    end
end)

Events.SubscribeRemote('qb-cityhall:server:applyJob', function(source, job)
    local hall, distance = getClosestLocation(source)
    if not hall or distance > 500 then return end
    if not availableJobs[job] then return end
    local JobInfo = QBShared.Jobs[job]
    if not JobInfo then return end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.SetJob(job, 0) then
        Events.CallRemote('QBCore:Notify', source, Lang:t('info.new_job', { value = JobInfo.label }))
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.job_failed', { value = JobInfo.label }))
    end
end)
