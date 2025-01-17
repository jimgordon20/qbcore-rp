local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local peds = {}

for i = 1, #Config.Locations['duty'], 1 do
    local location_info = Config.Locations['duty'][i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
    ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'QBCore:ToggleDuty',
                label = 'Toggle Duty',
                icon = 'fas fa-clipboard',
                jobType = 'leo'
            },
        },
        distance = 400,
    }
end

for i = 1, #Config.Locations['vehicle'], 1 do
    local location_info = Config.Locations['vehicle'][i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
    ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'qb-policejob:server:vehicle',
                label = 'Vehicles',
                icon = 'fas fa-car',
                jobType = 'leo'
            },
        },
        distance = 400,
    }
end

for i = 1, #Config.Locations['stash'], 1 do
    local location_info = Config.Locations['stash'][i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
    ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'qb-policejob:server:stash',
                label = 'Open Stash',
                icon = 'fas fa-box',
                jobType = 'leo'
            },
        },
        distance = 400,
    }
end

for i = 1, #Config.Locations['evidence'], 1 do
    local location_info = Config.Locations['evidence'][i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
    ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

    peds[ped] = {
        options = {
            {
                type = 'client',
                event = 'qb-policejob:client:evidence',
                label = 'Evidence Lockers',
                icon = 'fas fa-dungeon',
                jobType = 'leo'
            },
        },
        distance = 400,
    }
end

for i = 1, #Config.Locations['fingerprint'], 1 do
    local location_info = Config.Locations['fingerprint'][i]
    local coords = location_info.coords
    local heading = location_info.heading
    local ped = HCharacter(coords, Rotator(0, heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
    ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
    ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
    ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
    ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
    ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

    peds[ped] = {
        options = {
            {
                type = 'server',
                event = 'qb-policejob:server:fingerprint',
                label = 'Fingerprint',
                icon = 'fas fa-fingerprint',
                jobType = 'leo'
            },
        },
        distance = 400,
    }
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-policejob:server:getPeds', function(_, cb)
    cb(peds)
end)

-- Events

Events.SubscribeRemote('qb-policejob:server:vehicle', function(source)

end)

Events.SubscribeRemote('qb-policejob:server:stash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local citizenId = Player.PlayerData.citizenid
    local stashName = 'policestash_' .. citizenId
    OpenInventory(source, stashName)
end)

Events.SubscribeRemote('qb-policejob:server:fingerprint', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local closest_player, distance = QBCore.Functions.GetClosestPlayer(source)
    if not closest_player or distance > 500 then return end
    local target_player = closest_player:GetPlayer()
    Events.CallRemote('qb-policejob:client:fingerprint', target_player)
end)

Events.SubscribeRemote('qb-policejob:server:evidence', function(source, drawer)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    OpenInventory(source, drawer, {
        maxweight = 4000000,
        slots = 500,
    })
end)

Events.SubscribeRemote('qb-policejob:server:search', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end

    local target_ped = data.entity
    if not target_ped then return end
    local target_coords = target_ped:GetLocation()
    local player_coords = source:GetControlledCharacter():GetLocation()
    local distance = player_coords:Distance(target_coords)
    if distance > 500 then return end
    local target_player = target_ped:GetPlayer()
    OpenInventoryById(source, target_player)
end)

Events.SubscribeRemote('qb-policejob:server:escort', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local target_ped = data.entity
    if not target_ped then return end
    local target_coords = target_ped:GetLocation()
    local player_ped = source:GetControlledCharacter()
    local player_coords = player_ped:GetLocation()
    local distance = player_coords:Distance(target_coords)
    if distance > 500 then return end
    local player_rotation = player_ped:GetRotation()
    local placing_position = player_rotation:GetForwardVector() * 100
    if target_ped:GetValue('escorted', false) then
        target_ped:SetInputEnabled(false)
        target_ped:SetGravityEnabled(false)
        target_ped:AttachTo(player_ped)
        target_ped:SetRelativeLocation(placing_position)
        target_ped:SetCollision(CollisionType.NoCollision)
        target_ped:SetValue('escorted', true, true)
    else
        target_ped:Detach()
        target_ped:SetInputEnabled(true)
        target_ped:SetLocation(placing_position + player_coords)
        target_ped:SetCollision(CollisionType.Normal)
        target_ped:SetGravityEnabled(true)
        target_ped:SetValue('escorted', false, true)
    end
end)

Events.SubscribeRemote('qb-policejob:server:handcuff', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local closest_player, distance = QBCore.Functions.GetClosestPlayer(source)
    if not closest_player or distance > 500 then return end
    Events.CallRemote('qb-policejob:client:handcuff', closest_player)
end)

Events.SubscribeRemote('qb-policejob:server:putvehicle', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local closest_vehicle, distance = QBCore.Functions.GetClosestHVehicle(source)
    print(closest_vehicle, distance)
end)

Events.SubscribeRemote('qb-policejob:server:takeoutvehicle', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local closest_vehicle, distance = QBCore.Functions.GetClosestHVehicle(source)
    print(closest_vehicle, distance)
end)

Events.SubscribeRemote('qb-policejob:server:tracker', function(source, player_id)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local target_ped = player_id:GetControlledCharacter()
    if not target_ped then return end
    local target_coords = target_ped:GetLocation()
    local player_ped = source:GetControlledCharacter()
    local player_coords = player_ped:GetLocation()
    local distance = player_coords:Distance(target_coords)
    if distance > 500 then return end
    local OtherPlayer = QBCore.Functions.GetPlayer(player_id)
    if not OtherPlayer then return end
    local tracker_active = OtherPlayer.PlayerData.metadata.tracker
    if tracker_active then
        OtherPlayer.Functions.SetMetaData('tracker', false)
        Events.CallRemote('QBCore:Notify', player_id, Lang:t('success.anklet_taken_off'), 'success')
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.took_anklet_from', { firstname = Target.PlayerData.charinfo.firstname, lastname = Target.PlayerData.charinfo.lastname }), 'success')
    else
        OtherPlayer.Functions.SetMetaData('tracker', true)
        Events.CallRemote('QBCore:Notify', player_id, Lang:t('success.put_anklet'), 'success')
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.put_anklet_on', { firstname = Target.PlayerData.charinfo.firstname, lastname = Target.PlayerData.charinfo.lastname }), 'success')
    end
end)

Events.SubscribeRemote('qb-policejob:server:leaveCamera', function(source, coords)
    source:SetCameraLocation(coords)
    local newChar = HCharacter(coords, Rotator(), source)
    local player_dimension = source:GetDimension()
    newChar:SetDimension(player_dimension)
    source:Possess(newChar)
end)

Events.SubscribeRemote('qb-policejob:server:info', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local OtherPlayer = QBCore.Functions.GetPlayer(target_player)
    if not OtherPlayer then return end
    Events.CallRemote('qb-policejob:client:info', source, OtherPlayer.PlayerData)
end)

Events.SubscribeRemote('qb-policejob:server:policeAlert', function(source, text)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local ped_coords = ped:GetLocation()
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            Events.CallRemote('qb-policejob:client:policeAlert', v.PlayerData.source, ped_coords, text)
        end
    end
end)

Events.SubscribeRemote('qb-policejob:server:panicButton', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.on_duty_police_only'), 'error')
        return
    end
    local ped = source:GetControlledCharacter()
    local ped_coords = ped:GetLocation()
    local players = QBCore.Functions.GetQBPlayers()
    local text = Lang:t('info.officer_down', { lastname = Player.PlayerData.charinfo.lastname, callsign = Player.PlayerData.metadata.callsign })
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            Events.CallRemote('qb-policejob:client:policeAlert', v.PlayerData.source, ped_coords, text)
        end
    end
end)

-- Items

QBCore.Functions.CreateUseableItem('handcuffs', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not Player.Functions.GetItemByName('handcuffs') then return end
    Events.CallRemote('police:client:CuffPlayerSoft', source)
end)

-- Commands

QBCore.Commands.Add('cam', Lang:t('commands.camera'), { { name = 'camid', help = Lang:t('info.camera_id') } }, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.on_duty_police_only'), 'error')
        return
    end
    local camera_id = tonumber(args[1])
    if not Config.SecurityCameras.cameras[camera_id] then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.no_camera'), 'error')
        return
    end
    local ped = source:GetControlledCharacter()
    if ped then
        source:UnPossess()
        ped:Destroy()
    end
    Events.CallRemote('qb-policejob:client:viewCamera', source, camera_id)
end, 'user')

QBCore.Commands.Add('911p', Lang:t('commands.police_report'), { { name = 'message', help = Lang:t('commands.message_sent') } }, false, function(source, args)
    local message
    if args[1] then message = table.concat(args, ' ') else message = Lang:t('commands.civilian_call') end
    local ped = source:GetControlledCharacter()
    local coords = ped:GetLocation()
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            Events.CallRemote('qb-policejob:client:policeAlert', v.PlayerData.source, coords, message)
        end
    end
end, 'user')

QBCore.Commands.Add('tracker', Lang:t('commands.ankletlocation'), { { name = 'cid', help = Lang:t('info.citizen_id') } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.on_duty_police_only'), 'error')
        return
    end
    local citizenid = args[1]
    local OtherPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if not OtherPlayer then return end
    if OtherPlayer.PlayerData.metadata['tracker'] then
        local target_ped = OtherPlayer.PlayerData.source:GetControlledCharacter()
        if not target_ped then return end
        local target_coords = target_ped:GetLocation()
        Events.CallRemote('qb-policejob:client:tracker', source, target_coords, citizenid)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.no_anklet'), 'error')
    end
end)
