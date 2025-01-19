local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local freedom_ped

-- Ped

freedom_ped = HCharacter(Config.Locations.freedom.coords, Rotator(0, Config.Locations.freedom.heading, 0), '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body')
freedom_ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
freedom_ped:AddSkeletalMeshAttached('chest', 'helix::SK_Police_Top')
freedom_ped:AddSkeletalMeshAttached('legs', 'helix::SK_Police_Lower')
freedom_ped:AddSkeletalMeshAttached('feet', 'helix::SK_Police_Shoes')
freedom_ped:AddSkeletalMeshAttached('hat', 'helix::SK_Police_Hat')

QBCore.Functions.CreateCallback('qb-prison:server:getPeds', function(source, cb)
    cb(freedom_ped)
end)

-- Functions

local function sendToJail(player_id, time)
    local target_ped = player_id:GetControlledCharacter()
    if not target_ped then return end
    local random_cell = Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]
    target_ped:SetLocation(random_cell.coords)
    target_ped:SetRotation(Rotator(0, random_cell.heading, 0))
    Events.CallRemote('qb-prison:client:jailTime', player_id, time)
end

-- Events

Events.SubscribeRemote('qb-prison:server:jail', function(source, data, time)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then return end
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local OtherPlayer = QBCore.Functions.GetPlayer(target_player)
    if not OtherPlayer then return end
    local player_ped = source:GetControlledCharacter()
    if not player_ped then return end
    if player_ped:GetPosition():Distance(target_ped:GetPosition()) > 500 then return end
    local currentDate = os.date('*t')
    if currentDate.day == 31 then currentDate.day = 30 end
    OtherPlayer.Functions.SetMetaData('injail', time)
    OtherPlayer.Functions.SetMetaData('criminalrecord', {
        ['hasRecord'] = true,
        ['date'] = currentDate
    })
    if not OtherPlayer.PlayerData.metadata['jailitems'] then
        OtherPlayer.Functions.SetMetaData('jailitems', OtherPlayer.PlayerData.items)
        OtherPlayer.Functions.ClearInventory()
        Events.CallRemote('QBCore:Notify', target_player, Lang:t('info.seized_property'))
    end
    sendToJail(OtherPlayer.PlayerData.source, time)
    Events.CallRemote('QBCore:Notify', source, Lang:t('info.sent_jail_for', { time = time }))
end)

Events.SubscribeRemote('qb-prison:server:freedom', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('injail', 0)
    local player_ped = source:GetControlledCharacter()
    if not player_ped then return end
    player_ped:SetLocation(Config.Locations.outside)
    for _, v in pairs(Player.PlayerData.metadata['jailitems']) do
        AddItem(src, v.name, v.amount, false, v.info, 'qb-prison:server:freedom')
    end
    Events.CallRemote('QBCore:Notify', source, Lang:t('info.received_property'))
    Player.Functions.SetMetaData('jailitems', {})
end)

-- Commands

QBCore.Commands.Add('unjail', Lang:t('commands.unjail_player'), { { name = 'id', help = Lang:t('info.player_id') } }, true, function(source, args)
    local target_id = tonumber(args[1])
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.on_duty_police_only'), 'error')
        return
    end
    local OtherPlayer = QBCore.Functions.GetPlayer(target_id)
    if not OtherPlayer then return end
    Events.CallRemote('qb-prison:client:unjail', target_id)
end, 'user')
