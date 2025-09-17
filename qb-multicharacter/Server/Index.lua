local Lang = require('Shared/locales/en')
local hasDonePreloading = {}

-- Handling Player Load

RegisterServerEvent('PlayerJoined', function(source)
    print('[QBCore] Player Joined:', source)
    TriggerClientEvent(source, 'qb-multicharacter:client:chooseChar')
end)

-- Functions

local function GiveStarterItems(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    for _, v in pairs(QBShared.StarterItems) do
        local info = {}
        if v.item == 'id_card' then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == 'driver_license' then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = 'Class C Driver License'
        end
        AddItem(source, v.item, v.amount, false, info)
    end
end

-- Commands

-- QBCore.Commands.Add('logout', Lang:t('commands.logout_description'), {}, false, function(source)
--     local Player = exports['qb-core']:GetPlayer(source)
--     if not Player then return end
--     local inside_meta = Player.PlayerData.metadata.inside
--     if inside_meta.apartment.apartmentId then
--         TriggerClientEvent('qb-apartments:client:leaveApartment', source)
--     end
--     QBCore.Player.Logout(source)
--     TriggerClientEvent('qb-multicharacter:client:chooseChar', source)
-- end, 'admin')

-- Events

--[[ RegisterServerEvent('QBCore:Server:PlayerLoaded', function(Player)
    hasDonePreloading[Player.PlayerData.source] = true
end) ]]
exports('qb-multicharacter', 'SetPlayerLoaded', function(Player)
    hasDonePreloading[Player.PlayerData.netId] = true
end)

RegisterServerEvent('QBCore:Server:OnPlayerUnload', function(source)
    hasDonePreloading[source] = false
end)

RegisterServerEvent('qb-multicharacter:server:disconnect', function(source)
    source:Kick(source, Lang:t('commands.droppedplayer'))
end)

RegisterServerEvent('qb-multicharacter:server:loadUserData', function(source, cData) -- TO DO ADD APARTMENTS SUPPORT
    local ObjectRef = UE.FSoftObjectPtr(source)
    ObjectRef:Set(source)
    if exports['qb-core']:Login(tostring(ObjectRef), cData.citizenid) then
        local PlayerState = source:GetLyraPlayerState()
        local netId = PlayerState:GetPlayerId()
        CheckUserInterval = Timer.SetInterval(function()
            if hasDonePreloading[netId] then
                print('[qb-core] ' .. PlayerState:GetPlayerName() .. ' (Citizen ID: ' .. cData.citizenid .. ') has successfully loaded!')
                --QBCore.Commands.Refresh(source)
                --loadHouseData(source)
                if Config.SkipSelection then
                    local coords = JSON.parse(cData.position)
                    local pawn = source:K2_GetPawn()
                    if pawn then pawn:K2_SetActorLocation(Vector(coords.x, coords.y, coords.z), false, nil, true) end
                    --local new_char = HCharacter(coords, Rotator(0, 0, 0), source)
                    --local source_dimension = source:GetDimension()
                    --new_char:SetDimension(source_dimension)
                    --source:Possess(new_char)
                    TriggerClientEvent(source, 'QBCore:Client:OnPlayerLoaded')
                    TriggerClientEvent(source, 'qb-multicharacter:client:spawnLastLocation', coords, cData)
                else
                    local Apartments = exports['qb-apartments']:Apartments()
                    if Apartments.Starting then
                        TriggerClientEvent(source, 'qb-apartments:client:setupSpawnUI', cData)
                    else
                        TriggerClientEvent(source, 'qb-spawn:client:openUI', true, cData, false, nil)
                    end
                end
                --Events.Call('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**' .. source:GetAccountName() .. '** (<@' .. (exports['qb-core']:GetIdentifier(source, 'discord'):gsub('discord:', '') or 'unknown') .. '> |  ||' .. (exports['qb-core']:GetIdentifier(source, 'ip') or 'undefined') .. '|| | ' .. (exports['qb-core']:GetIdentifier(source, 'license') or 'undefined') .. ' | ' .. cData.citizenid .. ' | ' .. source .. ') loaded..')
                Timer.ClearInterval(CheckUserInterval)
            end
        end, 10)
    end
end)

RegisterServerEvent('qb-multicharacter:server:createCharacter', function(source, data)
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    local ObjectRef = UE.FSoftObjectPtr(source)
    ObjectRef:Set(source)
    if exports['qb-core']:Login(tostring(ObjectRef), false, newData) then
        local PlayerState = source:GetLyraPlayerState()
        local netId = PlayerState:GetPlayerId()
        CheckInterval = Timer.SetInterval(function()
            if hasDonePreloading[netId] then
                local PlayerState = source:GetLyraPlayerState()
                local Apartments = exports['qb-apartments']:Apartments()
                if Apartments.Starting then
                    --local randbucket = (math.random(1, 999))
                    --exports['qb-core']:SetPlayerBucket(source, randbucket)
                    print('^2[qb-core]^7 ' .. PlayerState:GetPlayerName() .. ' has successfully loaded!')
                    --QBCore.Commands.Refresh(source)
                    --loadHouseData(source)
                    TriggerClientEvent(source, 'qb-multicharacter:client:closeNUI')
                    TriggerClientEvent(source, 'qb-apartments:client:setupSpawnUI', newData)
                    --GiveStarterItems(source)
                    Timer.ClearInterval(CheckInterval)
                else
                    print('^2[qb-core]^7 ' .. PlayerState:GetPlayerName() .. ' has successfully loaded!')
                    --QBCore.Commands.Refresh(source)
                    --loadHouseData(source)
                    --local new_char = HCharacter(QBConfig.DefaultSpawn, Rotator(0, 0, 0), source)
                    --local source_dimension = source:GetDimension()
                    --new_char:SetDimension(source_dimension)
                    --source:Possess(new_char)
                    TriggerClientEvent(source, 'QBCore:Client:OnPlayerLoaded')
                    TriggerClientEvent(source, 'qb-multicharacter:client:closeNUIdefault')
                    --GiveStarterItems(source)
                    Timer.ClearInterval(CheckInterval)
                end
            end
        end, 10)
    end
end)

RegisterServerEvent('qb-multicharacter:server:deleteCharacter', function(source, citizenid)
    local ObjectRef = UE.FSoftObjectPtr(source)
    ObjectRef:Set(source)
    local Success = exports['qb-core']:DeleteCharacter(ObjectRef, citizenid)
    if not Success then return end
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('notifications.char_deleted'), 'success')
    TriggerClientEvent(source, 'qb-multicharacter:client:chooseChar')
end)

-- Callbacks

RegisterServerEvent('qb-multicharacter:server:GetNumberOfCharacters', function(source)
    local playerState = source:GetLyraPlayerState()
    local license = playerState:GetHelixUserId()

    local numOfChars = 0
    if next(Config.PlayersNumberOfCharacters) then
        for _, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = Config.DefaultNumberOfCharacters
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    TriggerClientEvent(source, 'qb-multicharacter:client:ReceiveNumberOfCharacters', numOfChars)
end)

RegisterServerEvent('qb-multicharacter:server:setupCharacters', function(source)
    local playerState = source:GetLyraPlayerState()
    local license = playerState:GetHelixUserId()
    local plyChars = {}
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM players WHERE license = ?', { license })
    if not result then return end

    for i = 1, #result, 1 do
        local row = {}
        for CName, CValue in pairs(result[i]) do
            row[CName] = CValue
        end
        -- Parse JSON fields
        row.charinfo = JSON.parse(row.charinfo)
        row.money = JSON.parse(row.money)
        row.job = JSON.parse(row.job)
        plyChars[#plyChars + 1] = row
    end
    TriggerClientEvent(source, 'qb-multicharacter:client:ReceiveCharacters', plyChars)
end)
