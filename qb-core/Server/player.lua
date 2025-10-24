QBCore.Players = {}
QBCore.Player = {}

-- Logout

function QBCore.Player.Logout(source)
    local PlayerState = source:GetLyraPlayerState()
    local playerId = PlayerState:GetPlayerId()
    if not QBCore.Players[source] then return end
    local Player = QBCore.Players[source]
    Player.Functions.Save()
    TriggerClientEvent(source, 'QBCore:Client:OnPlayerUnload')
    QBCore.Player_Buckets[Player.PlayerData.license] = nil
    QBCore.Players[source] = nil
end

-- Functions

local function formatItems(inventory)
    local formattedItems = {}
    for _, item in pairs(inventory) do
        if item then
            local itemInfo = QBCore.Shared.Items[item.name:lower()]
            if itemInfo then
                formattedItems[item.slot] = {
                    name = itemInfo['name'],
                    amount = item.amount,
                    info = item.info or {},
                    label = itemInfo['label'],
                    description = itemInfo['description'] or '',
                    weight = itemInfo['weight'],
                    type = itemInfo['type'],
                    unique = itemInfo['unique'],
                    useable = itemInfo['useable'],
                    image = itemInfo['image'],
                    shouldClose = itemInfo['shouldClose'],
                    slot = item.slot,
                    combinable = itemInfo['combinable']
                }
            end
        end
    end
    return formattedItems
end

-- Login

function QBCore.Player.Login(source, citizenid, newData)
    if not source then return false end
    if citizenid then
        local PlayerState = source:GetLyraPlayerState()
        local license = PlayerState:GetHelixUserId()
        local result = Database.Select('SELECT * FROM players where citizenid = ?', { citizenid })
        local PlayerData = result[1] and result[1].Columns:ToTable()
        if PlayerData and license == PlayerData.license then
            PlayerData.money = JSON.parse(PlayerData.money)
            PlayerData.job = JSON.parse(PlayerData.job)
            PlayerData.gang = JSON.parse(PlayerData.gang)
            PlayerData.position = JSON.parse(PlayerData.position)
            PlayerData.metadata = JSON.parse(PlayerData.metadata)
            PlayerData.charinfo = JSON.parse(PlayerData.charinfo)
            PlayerData.items = formatItems(JSON.parse(PlayerData.inventory))
            QBCore.Player.CheckPlayerData(source, PlayerData)
        end
    else
        QBCore.Player.CheckPlayerData(source, newData)
    end
    TriggerClientEvent(source, 'QBCore:Client:OnPlayerLoaded')
    return true
end

function QBCore.Player.GetPlayerByLicense(license)
    if license then
        local source = QBCore.Functions.GetSource(license)
        if source > 0 then
            return QBCore.Players[source]
        end
    end
    return nil
end

local function applyDefaults(playerData, defaults)
    for key, value in pairs(defaults) do
        if type(value) == 'function' then
            playerData[key] = playerData[key] or value()
        elseif type(value) == 'table' then
            playerData[key] = playerData[key] or {}
            applyDefaults(playerData[key], value)
        else
            playerData[key] = playerData[key] or value
        end
    end
end

function QBCore.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = not source
    if source then
        PlayerData.source = source
        local PlayerState = source:GetLyraPlayerState()
        PlayerData.netId = PlayerState:GetPlayerId()
        PlayerData.license = PlayerState:GetHelixUserId()
        PlayerData.name = PlayerState:GetPlayerName()
    end
    applyDefaults(PlayerData, QBCore.Config.Player.PlayerDefaults)
    return QBCore.Player.CreatePlayer(PlayerData, Offline)
end

function QBCore.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end
        TriggerClientEvent(self.PlayerData.source, 'QBCore:Player:SetPlayerData', self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = grade or 1
        if not QBCore.Shared.Jobs[job] then return false end
        self.PlayerData.job = {
            name = job,
            label = QBCore.Shared.Jobs[job].label,
            onduty = QBCore.Shared.Jobs[job].defaultDuty,
            type = QBCore.Shared.Jobs[job].type or 'none',
            grade = {
                name = 'No Grades',
                level = 1,
                payment = 30,
                isboss = false
            }
        }
        local jobGradeInfo = QBCore.Shared.Jobs[job].grades[grade]
        if jobGradeInfo then
            self.PlayerData.job.grade.name = jobGradeInfo.name
            self.PlayerData.job.grade.level = grade
            self.PlayerData.job.grade.payment = jobGradeInfo.payment
            self.PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
            self.PlayerData.job.isboss = jobGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = grade or 1
        if not QBCore.Shared.Gangs[gang] then return false end
        self.PlayerData.gang = {
            name = gang,
            label = QBCore.Shared.Gangs[gang].label,
            grade = {
                name = 'No Grades',
                level = 1,
                isboss = false
            }
        }
        local gangGradeInfo = QBCore.Shared.Gangs[gang].grades[grade]
        if gangGradeInfo then
            self.PlayerData.gang.grade.name = gangGradeInfo.name
            self.PlayerData.gang.grade.level = grade
            self.PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
            self.PlayerData.gang.isboss = gangGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    function self.Functions.Notify(text, type, length, icon)
        TriggerClientEvent('QBCore:Notify', self.PlayerData.source, text, type, length, icon)
    end

    function self.Functions.HasItem(items, amount)
        QBCore.Functions.HasItem(self.PlayerData.source, items, amount)
    end

    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty
        TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddJobReputation(amount)
        if not amount then return end
        amount = tonumber(amount)
        self.PlayerData.metadata['jobrep'][self.PlayerData.job.name] = self.PlayerData.metadata['jobrep'][self.PlayerData.job.name] + amount
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        moneytype = moneytype:lower()
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.SetCreditCard(cardNumber)
        self.PlayerData.charinfo.card = cardNumber
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetCardSlot(cardNumber, cardType)
        local item = tostring(cardType):lower()
        local slots = GetSlotsByItem(self.PlayerData.items, item)
        for _, slot in pairs(slots) do
            if slot then
                if self.PlayerData.items[slot].info.cardNumber == cardNumber then
                    return slot
                end
            end
        end
        return nil
    end

    function self.Functions.Save()
        if self.Offline then
            QBCore.Player.SaveOffline(self.PlayerData)
        else
            QBCore.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end
        QBCore.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        QBCore.Players[self.PlayerData.source] = self
        QBCore.Player.Save(self.PlayerData.source)
        exports['qb-multicharacter']:SetPlayerLoaded(self)
        self.Functions.UpdatePlayerData()
    end
end

function QBCore.Player.Save(source)
    local pcoords = QBCore.Config.DefaultSpawn
    local ped = source:K2_GetPawn()
    if ped then pcoords = ped:K2_GetActorLocation() end
    local PlayerState = source:GetLyraPlayerState()
    local PlayerData = QBCore.Players[source].PlayerData
    if not PlayerData then
        print('ERROR QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        return
    end

    local items = PlayerData.items
    local ItemsJson = {}

    if items and next(items) then
        for slot, item in pairs(items) do
            if item then
                ItemsJson[#ItemsJson + 1] = {
                    name = item.name,
                    amount = item.amount,
                    info = item.info,
                    slot = slot,
                }
            end
        end
    end

    local result = Database.Execute([[INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata, inventory)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(citizenid) DO UPDATE SET
            cid = excluded.cid,
            name = excluded.name,
            money = excluded.money,
            charinfo = excluded.charinfo,
            job = excluded.job,
            gang = excluded.gang,
            position = excluded.position,
            metadata = excluded.metadata,
            inventory = excluded.inventory;
        ]],
        {
            PlayerData.citizenid,
            tonumber(PlayerData.cid),
            PlayerData.license,
            PlayerData.name,
            JSON.stringify(PlayerData.money),
            JSON.stringify(PlayerData.charinfo),
            JSON.stringify(PlayerData.job),
            JSON.stringify(PlayerData.gang),
            JSON.stringify({ x = pcoords.X, y = pcoords.Y, z = pcoords.Z }),
            JSON.stringify(PlayerData.metadata),
            JSON.stringify(ItemsJson),
        })

    print(('[QBCORE] Saved player data for %s (Citizen ID: %s)'):format(PlayerData.name, PlayerData.citizenid))
end

local playertables = {
    { table = 'players' },
    { table = 'apartments' },
    { table = 'bank_accounts' },
    { table = 'crypto_transactions' },
    { table = 'phone_invoices' },
    { table = 'phone_messages' },
    { table = 'playerskins' },
    { table = 'player_contacts' },
    { table = 'player_houses' },
    { table = 'player_mails' },
    { table = 'player_outfits' },
    { table = 'player_vehicles' }
}

function QBCore.Player.DeleteCharacter(source, citizenid)
    if not source or not citizenid then print('[Error] qb-core couldn\'t delete character') return end
    local PlayerState = source:GetLyraPlayerState()
    local license = PlayerState:GetHelixUserId()
    local result = Database.Select('SELECT license FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    if license == result[1].Columns:ToTable().license then
        local transactionStarted = Database.Execute('BEGIN TRANSACTION')
        if not transactionStarted then
            print('[Error] qb-core couldn\'t start a transaction when deleting a character.')
            return
        end
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = {}

        local Success = true
        for i = 1, tableCount do
            local v = playertables[i]
            local QuerySuccess = Database.Execute(query:format(v.table), { citizenid })
            if not QuerySuccess then
                Success = false
                break
            end
        end

        if not Success then
            Database.Execute('ROLLBACK')
        else
            Database.Execute('COMMIT')
            return true
        end
    else
        source:Kick(Lang:t('info.exploit_dropped'))
    end
    return false
end

for functionName, func in pairs(QBCore.Player) do
    if type(func) == 'function' then
        exports('qb-core', functionName, func)
    end
end

exports('qb-core', 'Player', function(Player, MethodName, ...)
    if not QBCore.Players[Player] then return end
    if not MethodName then return end

    return QBCore.Players[Player].Functions[MethodName](...)
end)
