local PlayerStatus = {}
local Casings = {}
local BloodDrops = {}
local FingerDrops = {}

local function CreateBloodId()
    if BloodDrops then
        local bloodId = math.random(10000, 99999)
        while BloodDrops[bloodId] do
            bloodId = math.random(10000, 99999)
        end
        return bloodId
    else
        local bloodId = math.random(10000, 99999)
        return bloodId
    end
end

local function CreateFingerId()
    if FingerDrops then
        local fingerId = math.random(10000, 99999)
        while FingerDrops[fingerId] do
            fingerId = math.random(10000, 99999)
        end
        return fingerId
    else
        local fingerId = math.random(10000, 99999)
        return fingerId
    end
end

local function CreateCasingId()
    if Casings then
        local caseId = math.random(10000, 99999)
        while Casings[caseId] do
            caseId = math.random(10000, 99999)
        end
        return caseId
    else
        local caseId = math.random(10000, 99999)
        return caseId
    end
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-policejob:server:isPlayerDead', function(_, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return cb(false) end
    cb(Player.PlayerData.metadata['isdead'])
end)

QBCore.Functions.CreateCallback('qb-policejob:GetPlayerStatus', function(_, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    local statList = {}
    if Player then
        if PlayerStatus[Player.PlayerData.source] and next(PlayerStatus[Player.PlayerData.source]) then
            for k in pairs(PlayerStatus[Player.PlayerData.source]) do
                statList[#statList + 1] = PlayerStatus[Player.PlayerData.source][k].text
            end
        end
    end
    cb(statList)
end)

QBCore.Functions.CreateCallback('qb-policejob:IsSilencedWeapon', function(source, cb, weapon)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    local itemInfo = Player.Functions.GetItemByName(QBCore.Shared.Weapons[weapon]['name'])
    local retval = false
    if itemInfo then
        if itemInfo.info and itemInfo.info.attachments then
            for k in pairs(itemInfo.info.attachments) do
                if itemInfo.info.attachments[k].component == 'COMPONENT_AT_AR_SUPP_02' or
                    itemInfo.info.attachments[k].component == 'COMPONENT_AT_AR_SUPP' or
                    itemInfo.info.attachments[k].component == 'COMPONENT_AT_PI_SUPP_02' or
                    itemInfo.info.attachments[k].component == 'COMPONENT_AT_PI_SUPP' then
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)

-- Events

Events.SubscribeRemote('evidence:server:UpdateStatus', function(source, data)
    PlayerStatus[source] = data
end)

Events.SubscribeRemote('evidence:server:CreateBloodDrop', function(source, citizenid, bloodtype, coords)
    local bloodId = CreateBloodId()
    BloodDrops[bloodId] = {
        dna = citizenid,
        bloodtype = bloodtype
    }
    Events.BroadcastRemote('evidence:client:AddBlooddrop', bloodId, citizenid, bloodtype, coords)
end)

Events.SubscribeRemote('evidence:server:CreateFingerDrop', function(source, coords)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local fingerId = CreateFingerId()
    FingerDrops[fingerId] = Player.PlayerData.metadata['fingerprint']
    Events.BroadcastRemote('evidence:client:AddFingerPrint', fingerId, Player.PlayerData.metadata['fingerprint'], coords)
end)

Events.SubscribeRemote('evidence:server:ClearBlooddrops', function(source, blooddropList)
    if blooddropList and next(blooddropList) then
        for _, v in pairs(blooddropList) do
            Events.BroadcastRemote('evidence:client:RemoveBlooddrop', v)
            BloodDrops[v] = nil
        end
    end
end)

Events.SubscribeRemote('evidence:server:AddBlooddropToInventory', function(source, bloodId, bloodInfo)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if RemoveItem(source, 'empty_evidence_bag', 1, false, 'evidence:server:AddBlooddropToInventory') then
        if AddItem(source, 'filled_evidence_bag', 1, false, bloodInfo, 'evidence:server:AddBlooddropToInventory') then
            Events.CallRemote('qb-inventory:client:ItemBox', source, QBCore.Shared.Items['filled_evidence_bag'], 'add')
            Events.BroadcastRemote('evidence:client:RemoveBlooddrop', bloodId)
            BloodDrops[bloodId] = nil
        end
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.have_evidence_bag'), 'error')
    end
end)

Events.SubscribeRemote('evidence:server:AddFingerprintToInventory', function(source, fingerId, fingerInfo)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if RemoveItem(source, 'empty_evidence_bag', 1, false, 'evidence:server:AddFingerprintToInventory') then
        if AddItem(source, 'filled_evidence_bag', 1, false, fingerInfo, 'evidence:server:AddFingerprintToInventory') then
            Events.CallRemote('qb-inventory:client:ItemBox', source, QBCore.Shared.Items['filled_evidence_bag'], 'add')
            Events.BroadcastRemote('evidence:client:RemoveFingerprint', fingerId)
            FingerDrops[fingerId] = nil
        end
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.have_evidence_bag'), 'error')
    end
end)

Events.SubscribeRemote('evidence:server:CreateCasing', function(source, weapon, coords)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local casingId = CreateCasingId()
    local weaponInfo = QBCore.Shared.Weapons[weapon]
    local serieNumber = nil
    if weaponInfo then
        local weaponItem = Player.Functions.GetItemByName(weaponInfo['name'])
        if weaponItem then
            if weaponItem.info and weaponItem.info ~= '' then
                serieNumber = weaponItem.info.serie
            end
        end
    end
    Events.CallRemote('evidence:client:AddCasing', -1, casingId, weapon, coords, serieNumber)
end)

Events.SubscribeRemote('evidence:server:ClearCasings', function(source, casingList)
    if casingList and next(casingList) then
        for _, v in pairs(casingList) do
            Events.BroadcastRemote('evidence:client:RemoveCasing', v)
            Casings[v] = nil
        end
    end
end)

Events.SubscribeRemote('evidence:server:AddCasingToInventory', function(source, casingId, casingInfo)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if exports['qb-inventory']:RemoveItem(source, 'empty_evidence_bag', 1, false, 'evidence:server:AddCasingToInventory') then
        if exports['qb-inventory']:AddItem(source, 'filled_evidence_bag', 1, false, casingInfo, 'evidence:server:AddCasingToInventory') then
            Events.CallRemote('qb-inventory:client:ItemBox', source, QBCore.Shared.Items['filled_evidence_bag'], 'add')
            Events.BroadcastRemote('evidence:client:RemoveCasing', casingId)
            Casings[casingId] = nil
        end
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.have_evidence_bag'), 'error')
    end
end)
