-- Setup

local peds = {}
local hospital_beds = {}

for _, v in pairs(Config.Locations['hospital']) do
    for i = 1, #v.beds do
        local bed = v.beds[i]
        local coords = bed.coords
        local model = bed.model
        local hospital_bed = Prop(Vector(coords.X, coords.Y, coords.Z), Rotator(), model, CollisionType.Normal, false)
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
                event = 'hospital:server:RespawnAtHospital',
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

HCharacter.Subscribe('Death', function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    print('Death was called')
    print(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
end)

HCharacter.Subscribe('TakeDamage', function(self, damage, bone, type, from_direction, instigator, causer)
    print('TakeDamage was called')
    print(self, damage, bone, type, from_direction, instigator, causer)
end)

HCharacter.Subscribe('Respawn', function(self)
    print('Respawn was called')
    print(self)
end)

HCharacter.Subscribe('HealthChange', function(self, old_health, new_health)
    print('HealthChange was called')
    print(self, old_health, new_health)
end)

-- HCharacter::ApplyDamage(damage, bone_name?, damage_type?, from_direction?, instigator?, causer?)
-- HCharacter:GetHealth() - both
-- HCharacter:GetMaxHealth() - both
-- HCharacter:Respawn(location?, rotation?)
-- HCharacter:SetHealth(new_health)
-- HCharacter:SetMaxHealth(new_max_health)

-- Functions

-- Events

Events.SubscribeRemote('qb-ambulancejob:server:KillPlayer', function(playerId)
    local ped = playerId:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(0)
end)

Events.SubscribeRemote('qb-ambulancejob:server:HealPlayer', function(playerId)
    local ped = playerId:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(ped:GetMaxHealth())
end)

Events.SubscribeRemote('hospital:server:RespawnAtHospital', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local coords = ped:GetLocation()
    if not coords then return end
    local closest_bed = nil
    local closest_distance = 999999
    for _, bed in pairs(hospital_beds) do
        local distance = bed:GetLocation():Distance(coords)
        if distance < closest_distance then
            closest_bed = bed
            closest_distance = distance
        end
    end
    if not closest_bed then return end
    ped:Respawn(closest_bed:GetLocation(), closest_bed:GetRotation())
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-ambulancejob:server:getPeds', function(_, cb)
    cb(peds)
end)

-- Items

QBCore.Functions.CreateUseableItem('ifaks', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name) then
        Events.CallRemote('hospital:client:UseIfaks', source)
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
        Events.CallRemote('hospital:client:UseBandage', source)
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
    if Player.Functions.RemoveItem(item.name) then Events.CallRemote('hospital:client:UsePainkillers', source) end
end)

QBCore.Functions.CreateUseableItem('firstaid', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name) then Events.CallRemote('hospital:client:UseFirstAid', source) end
end)
