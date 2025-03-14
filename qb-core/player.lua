local rapidjson = require('rapidjson')
local json = { encode = rapidjson.encode, decode = rapidjson.decode }
local resourceName = 'qb-core'

local function CreatePlayer(source, existingData, newData)
    local self = {}
    self.Functions = {}
    local playerState = source.PlayerState

    playerState.source = source
    playerState.license = UE.UKismetGuidLibrary:NewGuid():ToString()
    playerState.name = playerState:GetPlayerName()

    if existingData then
        playerState.money = json.decode(existingData.money)
        playerState.job = json.decode(existingData.job)
        playerState.gang = json.decode(existingData.gang)
        playerState.position = json.decode(existingData.position)
        playerState.metadata = json.decode(existingData.metadata)
        playerState.charinfo = json.decode(existingData.charinfo)
    else
        playerState.cid = newData.CID
        playerState.charinfo = newData.CharInfo
        playerState.citizenid = QBCore.Functions.CreateCitizenId()
        playerState.charinfo.phone = QBCore.Functions.CreatePhoneNumber()
        playerState.charinfo.account = QBCore.Functions.CreateAccountNumber()
        playerState.metadata.bloodtype = QBCore.Functions.GetRandomElement(QBCore.Config.Player.Bloodtypes)
        playerState.metadata.fingerprint = QBCore.Functions.CreateFingerId()
        playerState.metadata.walletid = QBCore.Functions.CreateWalletId()
    end

    function self.Functions.Logout()
        QBCore.Player.Logout(playerState.source)
    end

    function self.Functions.Save()
        QBCore.Player.Save(playerState.source)
    end

    QBCore.Players[playerState.source] = self
    QBCore.Player.Save(playerState.source, newData and true or false)

    return self
end

function QBCore.Player.Login(source, citizenid, newData)
    if not source or source == '' then
        error('[QBCore] ERROR QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        --QBCore.ShowError(resourceName, 'ERROR QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end

    if citizenid then
        local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(source, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
        local DB = DatabaseSubsystem:GetDatabase()
        local result = DB:Select('SELECT * FROM players WHERE citizenid = ?', { citizenid })
        if not result then return error('[QBCore] Couldn\'t load PlayerData for ' .. citizenid) end
        CreatePlayer(source, result) -- existing player
    else
        CreatePlayer(source, false, newData) -- new player
    end
    return true
end

function QBCore.Player.Logout(source)
    QBCore.Players[source] = nil
end

function QBCore.Player.Save(source, new)
    local ped = source:K2_GetPawn()
    if not QBCore.Players[source] then return end
    local playerState = source.PlayerState
    local OutPos = UE.FVector(0, 0, 0) -- Unsure if this works, just how it's documented
    local pcoords = (ped and ped:K2_GetActorLocation()) or source:GetPlayerViewpoint(OutPos)
    if playerState then
        local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(source, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
        local DB = DatabaseSubsystem:GetDatabase()
        if new then
            local Success = DB:Execute(string.format('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (\'%s\', \'%d\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\')',
                playerState.citizenid,
                playerState.cid,
                playerState.license,
                playerState.name,
                json.encode(playerState:GetPlayerData('money')),
                json.encode(playerState:GetPlayerData('charinfo')),
                json.encode(playerState:GetPlayerData('job')),
                json.encode(playerState:GetPlayerData('gang')),
                json.encode({ x = pcoords.X, y = pcoords.Y, z = pcoords.Z }),
                json.encode(playerState:GetPlayerData('metadata'))
            ), {})
            if not Success then error('[QBCore] ERROR QBCORE.PLAYER.SAVE - FAILED TO INSERT NEW PLAYER!') end
        else
            DB:Execute(string.format('UPDATE players SET money = \'%s\', charinfo = \'%s\', job = \'%s\', gang = \'%s\', position = \'%s\', metadata = \'%s\' WHERE citizenid = \'%s\'',
                json.encode(playerState:GetPlayerData('money')),
                json.encode(playerState:GetPlayerData('charinfo')),
                json.encode(playerState:GetPlayerData('job')),
                json.encode(playerState:GetPlayerData('gang')),
                json.encode({ x = pcoords.X, y = pcoords.Y, z = pcoords.Z }),
                json.encode(playerState:GetPlayerData('metadata')),
                playerState.citizenid), -- Needs changing to prepared statements
            {})
        end
        print('[QBCore] ' .. playerState.citizenid .. ' PLAYER SAVED!')
        --QBCore.Shared.ShowSuccess(resourceName, playerState.name .. ' PLAYER SAVED!')
    else
        error('[QBCore] ERROR QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        --QBCore.Shared.ShowError(resourceName, 'ERROR QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

-- local function GetPlayerTables(source)
--     local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(source, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
--     local DB = DatabaseSubsystem:GetQBDatabase() -- Database solution will be changing

--     local tables = {}

--     local MasterTableResults = DB:Select('SELECT name FROM sqlite_master WHERE type = "table"')
--     for _, row in ipairs(MasterTableResults) do
--         local TableInformation = DB:Select('PRAGMA table_info(?)', { row.name })
--         for _, ColumnResult in pairs(TableInformation) do
--             if ColumnResult.name == 'citizenid' then
--                 tables[#tables + 1] = row.name
--                 break
--             end
--         end
--     end

--     return tables
-- end

-- function QBCore.Player.DeleteCharacter(source, citizenid)
--     local license = QBCore.Functions.GetIdentifier(source, 'license')                                   -- Needs changing to Helix ID
--     local result = MySQL.scalar.await('SELECT license FROM players WHERE citizenid = ?', { citizenid }) -- Database solution is changing
--     if license == result then
--         local tables = GetPlayerTables(source)
--         local queries = {}

--         for _, tableName in ipairs(tables) do
--             table.insert(queries, { query = ('DELETE FROM `%s` WHERE citizenid = ?'):format(tableName), values = { citizenid } })
--         end

--         MySQL.transaction(queries, function(success)
--             if success then
--                 TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**.')
--             end
--         end)
--     else
--         DropPlayer(source, Lang:t('info.exploit_dropped')) -- Will need to change to an UnLua kick method
--         TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
--     end
-- end
