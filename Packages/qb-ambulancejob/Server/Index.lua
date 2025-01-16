-- Setup

local peds = {}
local hospital_beds = {}
local PlayerInjuries = {}

for _, v in pairs(Config.Locations['hospital']) do
    for i = 1, #v.beds do
        local bed = v.beds[i]
        local coords = bed.coords
        local model = bed.model
        local hospital_bed = Prop(Vector(coords.X, coords.Y, coords.Z), Rotator(0, bed.heading, 0), model, CollisionType.Normal, false)
        hospital_beds[#hospital_beds + 1] = hospital_bed
    end
end

for _, loc in ipairs(Config.Locations['checking']) do
    local ped = HCharacter(loc, Rotator(0.0, 90.755416870117, 0.0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', '/CharacterCreator/CharacterAssets/Avatar_FBX/Head/Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'qb-ambulancejob:server:RespawnAtHospital',
                label = 'Check In',
                icon = 'fas fa-clipboard',
            },
        },
        distance = 400,
    }
end

for _, loc in ipairs(Config.Locations['duty']) do
    local ped = HCharacter(loc, Rotator(0.0, -168.2536315918, 0.0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', '/CharacterCreator/CharacterAssets/Avatar_FBX/Head/Male_Head')
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
            },
        },
        distance = 400,
    }
end

for _, loc in ipairs(Config.Locations['stash']) do
    local ped = HCharacter(loc, Rotator(0.0, -168.2536315918, 0.0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', '/CharacterCreator/CharacterAssets/Avatar_FBX/Head/Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'qb-ambulancejob:server:stash',
                label = 'Open Stash',
                icon = 'fas fa-box',
            },
        },
        distance = 400,
    }
end

-- Handlers

-- HCharacter::ApplyDamage(damage, bone_name?, damage_type?, from_direction?, instigator?, causer?)
-- HCharacter:GetHealth() - both
-- HCharacter:GetMaxHealth() - both
-- HCharacter:Respawn(location?, rotation?)
-- HCharacter:SetHealth(new_health)
-- HCharacter:SetMaxHealth(new_max_health)

-- Functions

-- Events

Events.SubscribeRemote('qb-ambulancejob:server:setHealth', function(source, playerId, amount)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(ped:GetHealth() - amount)
end)

Events.SubscribeRemote('qb-ambulancejob:server:KillPlayer', function(source, playerId)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(0)
end)

Events.SubscribeRemote('qb-ambulancejob:server:HealPlayer', function(source, playerId)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(ped:GetMaxHealth())
end)

Events.SubscribeRemote('qb-ambulancejob:server:RespawnAtHospital', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local coords = ped:GetLocation()
    if not coords then return end
    local closest_bed = nil
    local closest_distance = 999999
    -- Instead of calling GetLocation, we could use the locations we already have in the config table
    for _, bed in pairs(hospital_beds) do
        local distance = bed:GetLocation():Distance(coords)
        if distance < closest_distance then
            closest_bed = bed
            closest_distance = distance
        end
    end
    -- Not checking if beds are taken, could respawn on the same bed as someone else (QOL)
    if not closest_bed then return end
    local bedLocation = closest_bed:GetLocation()
    ped:Respawn(Vector(bedLocation.X, bedLocation.Y, bedLocation.Z + 150.0), closest_bed:GetRotation())
end)

Events.SubscribeRemote('qb-ambulancejob:server:damageRagdoll', function(source, length)
    local ped = source:GetControlledCharacter()
    if not ped then return end

    ped:SetRagdollMode(true) -- Ragdoll player on severe enough damage

    Timer.SetTimeout(function()
        ped:SetRagdollMode(false) -- Wait passed length of time, remove ragdoll
    end, length)
end)

Events.SubscribeRemote('qb-ambulancejob:server:setDeathStatus', function(source, status)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    Player.Functions.SetMetaData('isdead', status)
end)

Events.SubscribeRemote('qb-ambulancejob:server:syncInjuries', function(source, injuries, isBleeding)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if not injuries then 
        -- Reset injuries on player unload
        PlayerInjuries[source:GetID()] = nil 
        return
    end

    PlayerInjuries[source:GetID()] = {
        limbs = injuries,
        isBleeding = isBleeding,
    }
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-ambulancejob:server:getPeds', function(_, cb)
    cb(peds)
end)

QBCore.Functions.CreateCallback('qb-ambulancejob:server:checkStatus', function(source, cb)
    local closestPlayer = QBCore.Functions.GetClosestPlayer(source)
    if not closestPlayer then return end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if Player.PlayerData.job.type ~= 'ems' then return end

    cb(PlayerInjuries[closestPlayer:GetID()])
end)
-- Items

QBCore.Functions.CreateUseableItem('ifaks', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name) then
        Events.CallRemote('qb-ambulancejob:client:UseIfaks', source)
        local ped = source:GetControlledCharacter()
        if not ped then return end
        local health = ped:GetHealth()
        local max_health = ped:GetMaxHealth()
        local heal_amount = 10
        if health + heal_amount > max_health then
            ped:SetHealth(max_health)
        else
            ped:SetHealth(health + heal_amount)
        end
    end
end)

QBCore.Functions.CreateUseableItem('bandage', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name) then
        Events.CallRemote('qb-ambulancejob:client:UseBandage', source)
        local ped = source:GetControlledCharacter()
        if not ped then return end
        local health = ped:GetHealth()
        local max_health = ped:GetMaxHealth()
        local heal_amount = 10
        if health + heal_amount > max_health then
            ped:SetHealth(max_health)
        else
            ped:SetHealth(health + heal_amount)
        end
    end
end)

QBCore.Functions.CreateUseableItem('painkillers', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name) then Events.CallRemote('qb-ambulancejob:client:UsePainkillers', source) end
end)

QBCore.Functions.CreateUseableItem('firstaid', function(source, item)
    if not RemoveItem(source, item.name, 1, item.slot) then return end
    local closestCharacter = QBCore.Functions.GetClosestHCharacter(source)
    if not closestCharacter then return end

    if closestCharacter:GetHealth() > 0 then return Events.CallRemote('QBCore:Notify', source, Lang:t('error.cant_help'), 'error') end

    local ped = source:GetControlledCharacter()
    if not ped then return end

    ped:PlayAnimation('nanos-world::A_Mannequin_Take_From_Floor', AnimationSlotType.UpperBody, true)
    Timer.SetTimeout(function()
        ped:StopAnimation('nanos-world::A_Mannequin_Take_From_Floor')
        closestCharacter:Respawn(closestCharacter:GetLocation(), closestCharacter:GetRotation())
    end, 3000)
end)
