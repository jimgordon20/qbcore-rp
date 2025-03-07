local rapidjson = require('rapidjson')
local json = { encode = rapidjson.encode, decode = rapidjson.decode }
local resourceName = 'qb-core'

local function CreatePlayer(source, PlayerData)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData or {}

    self.PlayerData.source = source
    self.PlayerData.license = self.PlayerData.license or QBCore.Functions.GetIdentifier(self.PlayerData.source, 'license') -- Needs changing to Helix ID
    self.PlayerData.name = self.PlayerData.name or GetPlayerName(self.PlayerData.source) -- Can get PlayerState:GetPlayerName() currently

    if GetResourceState('qb-inventory') ~= 'missing' then
        self.PlayerData.items = exports['qb-inventory']:LoadInventory(self.PlayerData.source, self.PlayerData.citizenid) -- Custom inventory handler
    else
        self.PlayerData.items = {}
    end

    function self.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Player:SetPlayerData', self.PlayerData) -- Events don't exist in this way
        TriggerClientEvent('QBCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = tonumber(grade) or 1

        local jobInfo = QBCore.Shared.Jobs[job]
        if not jobInfo then return false end

        local jobGradeInfo = jobInfo.grades[grade] or jobInfo.grades[1]

        self.PlayerData.job = {
            name = job,
            label = jobInfo.label,
            type = jobInfo.type or 'none',
            onduty = jobInfo.defaultDuty,
            grade = {
                name = jobGradeInfo.name,
                level = grade,
                payment = jobGradeInfo.payment,
                isboss = jobGradeInfo.isboss or false
            }
        }

        self.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job) -- Events don't exist in this way
        TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = tonumber(grade) or 1

        local gangInfo = QBCore.Shared.Gangs[gang]
        if not gangInfo then return false end

        local gangGradeInfo = gangInfo.grades[grade] or gangInfo.grades[1]

        self.PlayerData.gang = {
            name = gang,
            label = gangInfo.label,
            grade = {
                name = gangGradeInfo.name,
                level = grade,
                isboss = gangGradeInfo.isboss or false
            }
        }

        self.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang) -- Events don't exist in this way
        TriggerClientEvent('QBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 or not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount
        self.Functions.UpdatePlayerData()
        TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)  -- Events don't exist in this way
        TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        return true
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 or not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount
        self.Functions.UpdatePlayerData()
        TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)  -- Events don't exist in this way
        TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        return true
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = math.min(val, 100)
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.GetMoney(moneytype)
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    function self.Functions.Logout()
        QBCore.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.Save()
        QBCore.Player.Save(self.PlayerData.source)
    end

    QBCore.Players[self.PlayerData.source] = self
    QBCore.Player.Save(self.PlayerData.source)
    TriggerEvent('QBCore:Server:PlayerLoaded', self)  -- Events don't exist in this way
    self.Functions.UpdatePlayerData()

    return self
end

local DynamicDefaults = {
    ['citizenid'] = QBCore.Functions.CreateCitizenId,
    ['charinfo.phone'] = QBCore.Functions.CreatePhoneNumber,
    ['charinfo.account'] = QBCore.Functions.CreateAccountNumber,
    ['metadata.bloodtype'] = function() return QBCore.Shared.GetRandomElement(QBCore.Config.Player.Bloodtypes) end,
    ['metadata.fingerprint'] = QBCore.Functions.CreateFingerId,
    ['metadata.walletid'] = QBCore.Functions.CreateWalletId
}

local function ApplyDynamicDefaults(target)
    for field, func in pairs(DynamicDefaults) do
        local ref = target
        local keys = {}
        for key in field:gmatch('[^.]+') do table.insert(keys, key) end

        for i = 1, #keys - 1 do
            ref[keys[i]] = ref[keys[i]] or {}
            ref = ref[keys[i]]
        end

        ref[keys[#keys]] = ref[keys[#keys]] or func()
    end
end

local function LoadPlayerDefaults()
    local defaults = json.decode(LoadResourceFile(resourceName, 'shared/player_defaults.json')) or {}
    if not next(defaults) then
        print('^1[ERROR]^0 Could not load player_defaults.json or it is empty.')
        return {}
    end
    ApplyDynamicDefaults(defaults)
    return defaults
end

local function MergePlayerData(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == 'table' then
            target[key] = target[key] or {}
            MergePlayerData(target[key], value)
        else
            target[key] = target[key] or value
        end
    end
end

local function CleanupInvalidKeys(target, defaults)
    for key in pairs(target) do
        if type(target[key]) == 'table' and type(defaults[key]) == 'table' then
            CleanupInvalidKeys(target[key], defaults[key])
        elseif defaults[key] == nil then
            target[key] = nil
        end
    end
end

local function RestorePlayerDefaults(PlayerData)
    local defaultData = LoadPlayerDefaults()
    MergePlayerData(PlayerData, defaultData)
    CleanupInvalidKeys(PlayerData, defaultData)
    return PlayerData
end

function QBCore.Player.Login(source, citizenid, newData)
    if not source or source == '' then  -- Source is now APlayerController
        QBCore.ShowError(resourceName, 'ERROR QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end

    if citizenid then
        --local license = QBCore.Functions.GetIdentifier(source, 'license')
        --local PlayerData = MySQL.prepare.await('SELECT * FROM players WHERE citizenid = ?', { citizenid })
        local World = self:GetWorld()
        local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(World, UE.UClass.Load("/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C"))
        local DB = DatabaseSubsystem:GetQBDatabase() -- Database solution will be changing
        local PlayerData

        if not DB:Open(UE.UKismetSystemLibrary.GetProjectContentDirectory() .. 'Script/Database/qbcore.db') then return error('[QBCore] Couldn\'t load PlayerData for ' .. citizenid) end
        PlayerData = DB:Select('SELECT * FROM players WHERE citizenid = ?', { citizenid })

        --if PlayerData and license == PlayerData.license then
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            PlayerData = RestorePlayerDefaults(PlayerData)
            return CreatePlayer(source, PlayerData)
        else
            DropPlayer(source, Lang:t('info.exploit_dropped')) -- Will need to be changed for UnLua kicking
            TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false) -- Events don't exist in this way
        end
    else
        newData = RestorePlayerDefaults(newData)
        return CreatePlayer(source, newData)
    end
    return true
end

function QBCore.Player.Logout(source)
    TriggerClientEvent('QBCore:Client:OnPlayerUnload', source)  -- Events don't exist in this way
    TriggerEvent('QBCore:Server:OnPlayerUnload', source)
    TriggerClientEvent('QBCore:Player:UpdatePlayerData', source)
    Wait(200)
    QBCore.Players[source] = nil
end

function QBCore.Player.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped) -- Will be changed for something like K2_GetPawn():GetActorLocation()
    local PlayerData = QBCore.Players[source].PlayerData
    if PlayerData then
        MySQL.update('UPDATE players SET money = ?, charinfo = ?, job = ?, gang = ?, position = ?, metadata = ? WHERE citizenid = ?', { -- Database solution is changing
            json.encode(PlayerData.money),
            json.encode(PlayerData.charinfo),
            json.encode(PlayerData.job),
            json.encode(PlayerData.gang),
            json.encode(pcoords),
            json.encode(PlayerData.metadata),
            PlayerData.citizenid
        })
        if GetResourceState('qb-inventory') ~= 'missing' then
            exports['qb-inventory']:SaveInventory(source)
        end
        QBCore.Shared.ShowSuccess(resourceName, PlayerData.name .. ' PLAYER SAVED!')
    else
        QBCore.Shared.ShowError(resourceName, 'ERROR QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

function QBCore.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.update('UPDATE players SET money = ?, charinfo = ?, job = ?, gang = ?, position = ?, metadata = ? WHERE citizenid = ?', { -- Database solution is changing
            json.encode(PlayerData.money),
            json.encode(PlayerData.charinfo),
            json.encode(PlayerData.job),
            json.encode(PlayerData.gang),
            json.encode(PlayerData.position),
            json.encode(PlayerData.metadata),
            PlayerData.citizenid
        })
        if GetResourceState('qb-inventory') ~= 'missing' then -- Cant check if a module has loaded, maybe a Lua alternative, or a table of loaded modules
            exports['qb-inventory']:SaveInventory(PlayerData, true)
        end
        QBCore.Shared.ShowSuccess(resourceName, PlayerData.name .. ' OFFLINE PLAYER SAVED!')
    else
        QBCore.Shared.ShowError(resourceName, 'ERROR QBCORE.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
    end
end

local function GetPlayerTables()
    local result = MySQL.query.await([[
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'citizenid'
        AND TABLE_SCHEMA = DATABASE()
    ]]) -- Database solution is changing

    local tables = {}
    for _, row in ipairs(result) do
        tables[#tables + 1] = row.TABLE_NAME
    end

    return tables
end

function QBCore.Player.DeleteCharacter(source, citizenid)
    local license = QBCore.Functions.GetIdentifier(source, 'license') -- Needs changing to Helix ID
    local result = MySQL.scalar.await('SELECT license FROM players WHERE citizenid = ?', { citizenid }) -- Database solution is changing
    if license == result then
        local tables = GetPlayerTables()
        local queries = {}

        for _, tableName in ipairs(tables) do
            table.insert(queries, { query = ('DELETE FROM `%s` WHERE citizenid = ?'):format(tableName), values = { citizenid } })
        end

        MySQL.transaction(queries, function(success)
            if success then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**.')
            end
        end)
    else
        DropPlayer(source, Lang:t('info.exploit_dropped')) -- Will need to change to an UnLua kick method
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

function QBCore.Player.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await('SELECT license FROM players WHERE citizenid = ?', { citizenid }) -- Database solution is changing
    if result then
        local tables = GetPlayerTables()
        local queries = {}
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.PlayerData.source, 'An admin deleted the character you were using')
        end

        for _, tableName in ipairs(tables) do
            table.insert(queries, { query = ('DELETE FROM `%s` WHERE citizenid = ?'):format(tableName), values = { citizenid } })
        end

        MySQL.transaction(queries, function(success) -- Database solution is changing
            if success then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** was deleted by admin.')
            end
        end)
    end
end
