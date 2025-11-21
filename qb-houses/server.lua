local Lang = require('locales/en')
local houseowneridentifier = {}
local houseownercid = {}
local housekeyholders = {}
local housesLoaded = false

Timer.CreateThread(function()
    local HouseGarages = {}
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM houselocations', {})
    if result[1] then
        for _, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = json.decode(v.garage) or {}
            Config.Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {}
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage
            }
        end
    end
    BroadcastEvent('qb-garages:client:houseGarageConfig', HouseGarages)
    BroadcastEvent('qb-houses:client:setHouseConfig', Config.Houses)
end)

-- Timer.CreateThread(function()
--     if not housesLoaded then
--         exports['qb-core']:DatabaseAction('SelectAsync', 'SELECT * FROM player_houses', {}, function(houses)
--             if houses then
--                 for _, house in pairs(houses) do
--                     houseowneridentifier[house.house] = house.identifier
--                     houseownercid[house.house] = house.citizenid
--                     housekeyholders[house.house] = json.decode(house.keyholders)
--                 end
--             end
--         end)
--         housesLoaded = true
--     end
-- end)

-- Item

-- QBCore.Functions.CreateUseableItem('police_stormram', function(source, _)
--     local Player = exports['qb-core']:GetPlayer(source)
--     if (Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty) then
--         TriggerClientEvent('qb-houses:client:HomeInvasion', source)
--     else
--         TriggerClientEvent('QBCore:Notify', source, Lang:t('error.emergency_services'), 'error')
--     end
-- end)

-- Functions

local function isHouseOwner(identifier, cid, house)
    if houseowneridentifier[house] and houseownercid[house] then
        if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
            return true
        end
    end
    return false
end

local function hasKey(identifier, cid, house)
    if houseowneridentifier[house] and houseownercid[house] then
        if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
            return true
        else
            if housekeyholders[house] then
                for i = 1, #housekeyholders[house], 1 do
                    if housekeyholders[house][i] == cid then
                        return true
                    end
                end
            end
        end
    end
    return false
end
exports('qb-houses', 'hasKey', hasKey)

local function GetHouseStreetCount(street)
    local count = 0
    local query = '%' .. street .. '%'
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM houselocations WHERE name LIKE ? ORDER BY LENGTH(`name`) desc, `name` DESC', { query })
    if result then
        local houseAddress = result.name
        count = tonumber(string.match(houseAddress, '%d[%d.,]*'))
    end
    return (count + 1)
end

local function isHouseOwned(house)
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT owned FROM houselocations WHERE name = ?', { house })
    if result[1] then
        if result[1].owned == 1 then
            return true
        end
    end
    return false
end

local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

-- Events

RegisterServerEvent('qb-houses:server:createHouse', function(source, data)
    local ped = GetPlayerPawn(source)
    local coords = GetEntityCoords(ped)
    local shell = data.shell
    local price = tonumber(data.price)
    local export = data.export

    local apartmentId = exports['qb-core']:CreateApartmentId()
    local aptCoords = {
        enter = {
            X = coords.X,
            Y = coords.Y,
            Z = coords.Z
        }
    }

    exports['qb-core']:DatabaseAction('Execute', 'INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)', { apartmentId, apartmentId, JSON.stringify(aptCoords), 0, price, export })

    Config.Houses[apartmentId] = {
        coords = aptCoords,
        owned = false,
        price = price,
        locked = true,
        adress = apartmentId,
        tier = export,
        shell = shell,
        garage = {},
        decorations = {}
    }

    BroadcastEvent('qb-houses:client:setHouseConfig', Config.Houses)
end)


RegisterServerEvent('qb-houses:server:setHouses', function(source)
    TriggerClientEvent(source, 'qb-houses:client:setHouseConfig', Config.Houses)
end)

RegisterServerEvent('qb-houses:server:createBlip', function(source)
    local ped = GetPlayerPawn(source)
    local coords = GetEntityCoords(ped)
    BroadcastEvent('qb-houses:client:createBlip', coords)
end)

-- RegisterServerEvent('qb-houses:server:addNewHouse', function(source, street, coords, price, tier)
--     street = street:gsub("%'", '')
--     price = tonumber(price)
--     tier = tonumber(tier)
--     local houseCount = GetHouseStreetCount(street)
--     local name = street:lower() .. tostring(houseCount)
--     local label = street .. ' ' .. tostring(houseCount)
--     exports['qb-core']:DatabaseAction('Execute', 'INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)', { name, label, json.encode(coords), 0, price, tier })
--     Config.Houses[name] = {
--         coords = coords,
--         owned = false,
--         price = price,
--         locked = true,
--         adress = label,
--         tier = tier,
--         garage = {},
--         decorations = {}
--     }
--     BroadcastEvent('qb-houses:client:setHouseConfig', Config.Houses)
--     TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.added_house', { value = label }))
--     TriggerLocalServerEvent('qb-log:server:CreateLog', 'house', Lang:t('log.house_created'), 'green', Lang:t('log.house_address', { label = label, price = price, tier = tier, agent = GetPlayerName(source) }))
-- end)

RegisterServerEvent('qb-houses:server:addGarage', function(source, house, coords)
    exports['qb-core']:DatabaseAction('Execute', 'UPDATE houselocations SET garage = ? WHERE name = ?', { json.encode(coords), house })
    local garageInfo = {
        label = Config.Houses[house].adress,
        takeVehicle = coords
    }
    BroadcastEvent('qb-garages:client:addHouseGarage', house, garageInfo)
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.added_garage', { value = garageInfo.label }))
end)

RegisterServerEvent('qb-houses:server:viewHouse', function(source, house)
    local pData = exports['qb-core']:GetPlayer(source)
    local houseprice = Config.Houses[house].price
    local brokerfee = (houseprice / 100 * 5)
    local bankfee = (houseprice / 100 * 10)
    local taxes = (houseprice / 100 * 6)
    TriggerClientEvent(source, 'qb-houses:client:viewHouse', houseprice, brokerfee, bankfee, taxes, pData.PlayerData.charinfo.firstname, pData.PlayerData.charinfo.lastname)
end)

RegisterServerEvent('qb-houses:server:openStash', function(source, CurrentHouse)
    local houseData = Config.Houses[CurrentHouse]
    if not houseData then return end
    local houseTier = houseData.tier
    local stashSlots = Config.StashWeights[houseTier].slots
    local stashWeight = Config.StashWeights[houseTier].maxweight
    if stashSlots and stashWeight then
        exports['qb-inventory']:OpenInventory(src, CurrentHouse, {
            maxweight = stashWeight,
            slots = stashSlots,
            label = houseData.adress
        })
    else
        exports['qb-inventory']:OpenInventory(src, CurrentHouse)
    end
end)

RegisterServerEvent('qb-houses:server:buyHouse', function(source, house)
    local pData = exports['qb-core']:GetPlayer(source)
    local price = Config.Houses[house].price
    local HousePrice = math.ceil(price * 1.21)
    local bankBalance = pData.PlayerData.money['bank']

    local isOwned = isHouseOwned(house)
    if isOwned then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.already_owned'), 'error')
        --CancelEvent()
        return
    end

    if (bankBalance >= HousePrice) then
        houseowneridentifier[house] = pData.PlayerData.license
        houseownercid[house] = pData.PlayerData.citizenid
        housekeyholders[house] = {
            [1] = pData.PlayerData.citizenid
        }
        exports['qb-core']:DatabaseAction('Execute', 'INSERT INTO player_houses (house, identifier, citizenid, keyholders) VALUES (?, ?, ?, ?)', { house, pData.PlayerData.license, pData.PlayerData.citizenid, json.encode(housekeyholders[house]) })
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE houselocations SET owned = ? WHERE name = ?', { 1, house })
        TriggerClientEvent(source, 'qb-houses:client:SetClosestHouse')
        TriggerClientEvent(source, 'qb-house:client:RefreshHouseTargets')
        exports['qb-core']:Player(source, 'RemoveMoney', 'bank', HousePrice, 'bought-house') -- 21% Extra house costs
        exports['qb-banking']:AddMoney('realestate', (HousePrice / 100) * math.random(18, 25), 'House purchase')
        TriggerLocalServerEvent('qb-log:server:CreateLog', 'house', Lang:t('log.house_purchased'), 'green', Lang:t('log.house_purchased_by', { house = house:upper(), price = HousePrice, firstname = pData.PlayerData.charinfo.firstname, lastname = pData.PlayerData.charinfo.lastname }))
        TriggerClientEvent(source, 'QBCore:Notify', src, Lang:t('success.house_purchased'), 'success', 5000)
    else
        TriggerClientEvent(source, 'QBCore:Notify', src, Lang:t('error.not_enough_money'), 'error')
    end
end)

RegisterServerEvent('qb-houses:server:lockHouse', function(source, bool, house)
    BroadcastEvent('qb-houses:client:lockHouse', bool, house)
end)

RegisterServerEvent('qb-houses:server:SetRamState', function(source, bool, house)
    Config.Houses[house].IsRaming = bool
    BroadcastEvent('qb-houses:server:SetRamState', bool, house)
end)

RegisterServerEvent('qb-houses:server:giveKey', function(source, house, target)
    local Player = exports['qb-core']:GetPlayer(source)
    local pData = exports['qb-core']:GetPlayer(target)
    if not Player or not pData then return end
    if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.not_owner'), 'error')
        return
    end
    housekeyholders[house][#housekeyholders[house] + 1] = pData.PlayerData.citizenid
    exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET keyholders = ? WHERE house = ?', { json.encode(housekeyholders[house]), house })
end)

RegisterServerEvent('qb-houses:server:removeHouseKey', function(source, house, citizenData)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.not_owner'), 'error')
        return
    end
    local newHolders = {}
    if housekeyholders[house] then
        for k, _ in pairs(housekeyholders[house]) do
            if housekeyholders[house][k] ~= citizenData.citizenid then
                newHolders[#newHolders + 1] = housekeyholders[house][k]
            end
        end
    end
    housekeyholders[house] = newHolders
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.remove_key_from', { firstname = citizenData.firstname, lastname = citizenData.lastname }), 'error')
    exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET keyholders = ? WHERE house = ?', { json.encode(housekeyholders[house]), house })
end)

RegisterServerEvent('qb-houses:server:OpenDoor', function(source, target, house)
    local OtherPlayer = exports['qb-core']:GetPlayer(target)
    if OtherPlayer then
        TriggerClientEvent(OtherPlayer.PlayerData.source, 'qb-houses:client:SpawnInApartment', house)
    end
end)

RegisterServerEvent('qb-houses:server:RingDoor', function(source, house)
    BroadcastEvent('qb-houses:client:RingDoor', source, house)
end)

RegisterServerEvent('qb-houses:server:savedecorations', function(source, house, decorations)
    exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET decorations = ? WHERE house = ?', { json.encode(decorations), house })
    BroadcastEvent('qb-houses:server:sethousedecorations', house, decorations)
end)

RegisterServerEvent('qb-houses:server:LogoutLocation', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    local MyItems = Player.PlayerData.items
    exports['qb-core']:DatabaseAction('Execute', 'UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode(MyItems), Player.PlayerData.citizenid })
    exports['qb-core']:Logout(source)
    TriggerClientEvent(source, 'qb-multicharacter:client:chooseChar')
end)

RegisterServerEvent('qb-houses:server:giveHouseKey', function(source, target, house)
    local Player = exports['qb-core']:GetPlayer(source)
    local tPlayer = exports['qb-core']:GetPlayer(target)
    if not tPlayer or not Player then return end
    if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_owner'), 'error')
        return
    end
    if housekeyholders[house] then
        for _, cid in pairs(housekeyholders[house]) do
            if cid == tPlayer.PlayerData.citizenid then
                TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.already_keys'), 'error', 3500)
                return
            end
        end
        housekeyholders[house][#housekeyholders[house] + 1] = tPlayer.PlayerData.citizenid
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET keyholders = ? WHERE house = ?', { json.encode(housekeyholders[house]), house })
        TriggerClientEvent(tPlayer.PlayerData.source, 'qb-houses:client:refreshHouse')
        TriggerClientEvent(tPlayer.PlayerData.source, 'QBCore:Notify', Lang:t('success.recieved_key', { value = Config.Houses[house].adress }), 'success', 2500)
    else
        local sourceTarget = exports['qb-core']:GetPlayer(source)
        housekeyholders[house] = {
            [1] = sourceTarget.PlayerData.citizenid
        }
        housekeyholders[house][#housekeyholders[house] + 1] = tPlayer.PlayerData.citizenid
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET keyholders = ? WHERE house = ?', { json.encode(housekeyholders[house]), house })
        TriggerClientEvent(tPlayer.PlayerData.source, 'qb-houses:client:refreshHouse')
        TriggerClientEvent(tPlayer.PlayerData.source, 'QBCore:Notify', Lang:t('success.recieved_key', { value = Config.Houses[house].adress }), 'success', 2500)
    end
end)

RegisterServerEvent('qb-houses:server:setLocation', function(source, coords, house, type)
    if type == 1 then
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET stash = ? WHERE house = ?', { json.encode(coords), house })
    elseif type == 2 then
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET outfit = ? WHERE house = ?', { json.encode(coords), house })
    elseif type == 3 then
        exports['qb-core']:DatabaseAction('Execute', 'UPDATE player_houses SET logout = ? WHERE house = ?', { json.encode(coords), house })
    end
    BroadcastEvent('qb-houses:client:refreshLocations', house, JSON.parse(coords), type)
end)

RegisterServerEvent('qb-houses:server:SetHouseRammed', function(source, bool, house)
    Config.Houses[house].IsRammed = bool
    BroadcastEvent('qb-houses:client:SetHouseRammed', bool, house)
end)

RegisterServerEvent('qb-houses:server:SetInsideMeta', function(source, insideId, bool)
    local Player = exports['qb-core']:GetPlayer(source)
    local insideMeta = Player.PlayerData.metadata['inside']
    if bool then
        insideMeta.apartment.apartmentType = nil
        insideMeta.apartment.apartmentId = nil
        insideMeta.house = insideId
        exports['qb-core']:Player(source, 'SetMetaData', 'inside', insideMeta)
    else
        insideMeta.apartment.apartmentType = nil
        insideMeta.apartment.apartmentId = nil
        insideMeta.house = nil
        exports['qb-core']:Player(source, 'SetMetaData', 'inside', insideMeta)
    end
end)

-- Callbacks

RegisterCallback('buyFurniture', function(source, cb, price)
    local pData = exports['qb-core']:GetPlayer(source)
    local bankBalance = pData.PlayerData.money['bank']

    if bankBalance >= price then
        exports['qb-core']:Player(source, 'RemoveMoney', 'bank', price, 'bought-furniture')
        cb(true)
    else
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('error.not_enough_money'), 'error')
        cb(false)
    end
end)

RegisterCallback('ProximityKO', function(source, cb, house)
    local Player = exports['qb-core']:GetPlayer(source)
    local retvalK = false
    local retvalO

    if Player then
        local identifier = Player.PlayerData.license
        local CharId = Player.PlayerData.citizenid
        if hasKey(identifier, CharId, house) then
            retvalK = true
        elseif Player.PlayerData.job.name == 'realestate' then
            retvalK = true
        else
            retvalK = false
        end
    end

    if houseowneridentifier[house] and houseownercid[house] then
        retvalO = true
    else
        retvalO = false
    end

    cb(retvalK, retvalO)
end)

RegisterCallback('hasKey', function(source, cb, house)
    local Player = exports['qb-core']:GetPlayer(source)
    local retval = false
    if Player then
        local identifier = Player.PlayerData.license
        local CharId = Player.PlayerData.citizenid
        if hasKey(identifier, CharId, house) then
            retval = true
        elseif Player.PlayerData.job.name == 'realestate' then
            retval = true
        else
            retval = false
        end
    end

    cb(retval)
end)

RegisterCallback('isOwned', function(source, cb, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name == 'realestate' then
        cb(true)
    elseif houseowneridentifier[house] and houseownercid[house] then
        cb(true)
    else
        cb(false)
    end
end)

RegisterCallback('getHouseOwner', function(_, cb, house)
    cb(houseownercid[house])
end)

RegisterCallback('getHouseKeyHolders', function(source, cb, house)
    local retval = {}
    local Player = exports['qb-core']:GetPlayer(source)
    if housekeyholders[house] then
        for i = 1, #housekeyholders[house], 1 do
            if Player.PlayerData.citizenid ~= housekeyholders[house][i] then
                local result = exports['qb-core']:DatabaseAction('Select', 'SELECT charinfo FROM players WHERE citizenid = ?', { housekeyholders[house][i] })
                if result[1] then
                    local charinfo = json.decode(result[1].charinfo)
                    retval[#retval + 1] = {
                        firstname = charinfo.firstname,
                        lastname = charinfo.lastname,
                        citizenid = housekeyholders[house][i]
                    }
                end
            end
        end
        cb(retval)
    else
        cb(nil)
    end
end)

RegisterCallback('getHouseDecorations', function(_, cb, house)
    local retval = nil
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM player_houses WHERE house = ?', { house })
    if result[1] then
        if result[1].decorations then
            retval = json.decode(result[1].decorations)
        end
    end
    cb(retval)
end)

RegisterCallback('getHouseLocations', function(_, cb, house)
    local retval = nil
    local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM player_houses WHERE house = ?', { house })
    if result[1] then
        retval = result[1]
    end
    cb(retval)
end)

RegisterCallback('getOwnedHouses', function(source, cb)
    local pData = exports['qb-core']:GetPlayer(source)
    if pData then
        exports['qb-core']:DatabaseAction('SelectAsync', 'SELECT * FROM player_houses WHERE identifier = ? AND citizenid = ?', { pData.PlayerData.license, pData.PlayerData.citizenid }, function(houses)
            local ownedHouses = {}
            for i = 1, #houses, 1 do
                ownedHouses[#ownedHouses + 1] = houses[i].house
            end
            if houses then
                cb(ownedHouses)
            else
                cb(nil)
            end
        end)
    end
end)

RegisterCallback('getSavedOutfits', function(source, cb)
    local pData = exports['qb-core']:GetPlayer(source)
    if pData then
        exports['qb-core']:DatabaseAction('SelectAsync', 'SELECT * FROM player_outfits WHERE citizenid = ?', { pData.PlayerData.citizenid }, function(result)
            if result[1] then
                cb(result)
            else
                cb(nil)
            end
        end)
    end
end)

-- RegisterCallback('qb-phone:server:TransferCid', function(_, cb, NewCid, house)
--     local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM players WHERE citizenid = ?', { NewCid })
--     if result[1] then
--         local HouseName = house.name
--         housekeyholders[HouseName] = {}
--         housekeyholders[HouseName][1] = NewCid
--         houseownercid[HouseName] = NewCid
--         houseowneridentifier[HouseName] = result[1].license
--         MySQL.update(
--             'UPDATE player_houses SET citizenid = ?, keyholders = ?, identifier = ? WHERE house = ?',
--             { NewCid, json.encode(housekeyholders[HouseName]), result[1].license, HouseName })
--         cb(true)
--     else
--         cb(false)
--     end
-- end)

-- RegisterCallback('qb-phone:server:GetPlayerHouses', function(source, cb)
--     local Player = exports['qb-core']:GetPlayer(source)
--     local MyHouses = {}
--     local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM player_houses WHERE citizenid = ?', { Player.PlayerData.citizenid })
--     if result and result[1] then
--         for k, v in pairs(result) do
--             MyHouses[#MyHouses + 1] = {
--                 name = v.house,
--                 keyholders = {},
--                 owner = Player.PlayerData.citizenid,
--                 price = Config.Houses[v.house].price,
--                 label = Config.Houses[v.house].adress,
--                 tier = Config.Houses[v.house].tier,
--                 garage = Config.Houses[v.house].garage
--             }

--             if v.keyholders ~= 'null' then
--                 v.keyholders = json.decode(v.keyholders)
--                 if v.keyholders then
--                     for _, data in pairs(v.keyholders) do
--                         local keyholderdata = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM players WHERE citizenid = ?', { data })
--                         if keyholderdata[1] then
--                             keyholderdata[1].charinfo = json.decode(keyholderdata[1].charinfo)
--                             local userKeyHolderData = {
--                                 charinfo = {
--                                     firstname = keyholderdata[1].charinfo.firstname,
--                                     lastname = keyholderdata[1].charinfo.lastname
--                                 },
--                                 citizenid = keyholderdata[1].citizenid,
--                                 name = keyholderdata[1].name
--                             }
--                             MyHouses[k].keyholders[#MyHouses[k].keyholders + 1] = userKeyHolderData
--                         end
--                     end
--                 else
--                     MyHouses[k].keyholders[1] = {
--                         charinfo = {
--                             firstname = Player.PlayerData.charinfo.firstname,
--                             lastname = Player.PlayerData.charinfo.lastname
--                         },
--                         citizenid = Player.PlayerData.citizenid,
--                         name = Player.PlayerData.name
--                     }
--                 end
--             else
--                 MyHouses[k].keyholders[1] = {
--                     charinfo = {
--                         firstname = Player.PlayerData.charinfo.firstname,
--                         lastname = Player.PlayerData.charinfo.lastname
--                     },
--                     citizenid = Player.PlayerData.citizenid,
--                     name = Player.PlayerData.name
--                 }
--             end
--         end

--         Timer.SetTimeout(100, function()
--             cb(MyHouses)
--         end)
--     else
--         cb({})
--     end
-- end)

-- RegisterCallback('qb-phone:server:GetHouseKeys', function(source, cb)
--     local Player = exports['qb-core']:GetPlayer(source)
--     local MyKeys = {}
--     local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM player_houses', {})
--     for _, v in pairs(result) do
--         if v.keyholders ~= 'null' then
--             v.keyholders = json.decode(v.keyholders)
--             for _, p in pairs(v.keyholders) do
--                 if p == Player.PlayerData.citizenid and (v.citizenid ~= Player.PlayerData.citizenid) then
--                     MyKeys[#MyKeys + 1] = {
--                         HouseData = Config.Houses[v.house]
--                     }
--                 end
--             end
--         end
--         if v.citizenid == Player.PlayerData.citizenid then
--             MyKeys[#MyKeys + 1] = {
--                 HouseData = Config.Houses[v.house]
--             }
--         end
--     end
--     cb(MyKeys)
-- end)

-- RegisterCallback('qb-phone:server:MeosGetPlayerHouses', function(_, cb, input)
--     if input then
--         local search = escape_sqli(input)
--         local searchData = {}
--         local query = '%' .. search .. '%'
--         local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? OR charinfo LIKE ?',
--             { search, query })
--         if result[1] then
--             local houses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?',
--                 { result[1].citizenid })
--             if houses[1] then
--                 for _, v in pairs(houses) do
--                     searchData[#searchData + 1] = {
--                         name = v.house,
--                         keyholders = v.keyholders,
--                         owner = v.citizenid,
--                         price = Config.Houses[v.house].price,
--                         label = Config.Houses[v.house].adress,
--                         tier = Config.Houses[v.house].tier,
--                         garage = Config.Houses[v.house].garage,
--                         charinfo = json.decode(result[1].charinfo),
--                         coords = {
--                             x = Config.Houses[v.house].coords.enter.x,
--                             y = Config.Houses[v.house].coords.enter.y,
--                             z = Config.Houses[v.house].coords.enter.z
--                         }
--                     }
--                 end
--                 cb(searchData)
--             end
--         else
--             cb(nil)
--         end
--     else
--         cb(nil)
--     end
-- end)

local function getKeyHolderData()
    return housekeyholders
end

exports('qb-houses', 'getKeyHolderData', getKeyHolderData)
