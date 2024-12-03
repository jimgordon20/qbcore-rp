Package.Require('commands.lua')
Package.Require('evidence.lua')
Package.Require('interactions.lua')
Package.Require('objects.lua')
Package.Require('vehicle.lua')

-- Job Blips

local function UpdateBlips()
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for i = 1, #players do
        local v = players[i]
        if v and (v.PlayerData.job.type == 'leo' or v.PlayerData.job.type == 'ems') and v.PlayerData.job.onduty then
            local coords = GetEntityCoords(GetPlayerPed(v.PlayerData.source))
            local heading = GetEntityHeading(GetPlayerPed(v.PlayerData.source))
            dutyPlayers[#dutyPlayers + 1] = {
                source = v.PlayerData.source,
                label = v.PlayerData.metadata['callsign'],
                job = v.PlayerData.job.name,
                location = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }
            }
        end
    end
    Events.BroadcastRemote('qb-policejob:client:UpdateBlips', dutyPlayers)
end

Timer.SetInterval(5000, UpdateBlips)

-- Update Cop Count

local function GetCurrentCops()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            amount += 1
        end
    end
    --return amount
    Events.BroadcastRemote('qb-policejob:client:SetCopCount', amount)
end

Timer.SetInterval(5000, GetCurrentCops)

local updatingCops = false

Events.SubscribeRemote('qb-policejob:server:UpdateCurrentCops', function()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    if updatingCops then return end
    updatingCops = true
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            amount += 1
        end
    end
    Events.BroadcastRemote('qb-policejob:client:SetCopCount', amount)
    updatingCops = false
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-policejob:server:GetCops', function(_, cb)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)

QBCore.Functions.CreateCallback('qb-policejob:server:IsPoliceForcePresent', function(_, cb)
    local retval = false
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.grade.level >= 2 then
            retval = true
            break
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('qb-policejob:GetDutyPlayers', function(_, cb)
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            dutyPlayers[#dutyPlayers + 1] = {
                source = v.PlayerData.source,
                label = v.PlayerData.metadata['callsign'],
                job = v.PlayerData.job.name
            }
        end
    end
    cb(dutyPlayers)
end)

-- Events

Events.SubscribeRemote('qb-policejob:server:policeAlert', function(source, text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            local alertData = { title = Lang:t('info.new_call'), coords = { x = coords.x, y = coords.y, z = coords.z }, description = text }
            Events.CallRemote('qb-phone:client:addPoliceAlert', v.PlayerData.source, alertData)
            Events.CallRemote('qb-policejob:client:policeAlert', v.PlayerData.source, coords, text)
        end
    end
end)

Events.SubscribeRemote('qb-policejob:server:stash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local citizenId = Player.PlayerData.citizenid
    local stashName = 'policestash_' .. citizenId
    OpenInventory(source, stashName)
end)

Events.SubscribeRemote('qb-policejob:server:trash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    OpenInventory(source, 'policetrash', {
        maxweight = 4000000,
        slots = 300,
    })
end)

Events.SubscribeRemote('qb-policejob:server:evidence', function(source, currentEvidence)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    OpenInventory(source, currentEvidence, {
        maxweight = 4000000,
        slots = 500,
    })
end)

-- Items

QBCore.Functions.CreateUseableItem('handcuffs', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not Player.Functions.GetItemByName('handcuffs') then return end
    Events.CallRemote('qb-policejob:client:CuffPlayerSoft', source)
end)

QBCore.Functions.CreateUseableItem('moneybag', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not Player.Functions.GetItemByName('moneybag') or not item.info or item.info == '' then return end
    if not Player.PlayerData.job.type == 'leo' then return end
    if not RemoveItem(source, 'moneybag', 1, item.slot, 'qb-policejob:moneybag') then return end
    Player.Functions.AddMoney('cash', tonumber(item.info.cash), 'qb-policejob:moneybag')
end)
