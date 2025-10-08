local Lang = require('Shared/locales/en')
local houseowneridentifier = {}
local houseownercid = {}
local housekeyholders = {}
local HouseGarages = {}

-- Setup

local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM houselocations', {})
if result and result[1] then
    for _, v in pairs(result) do
        local owned = false
        if tonumber(v.owned) == 1 then
            owned = true
        end
        local garage = v.garage and JSON.parse(v.garage) or {}
        Config.Houses[v.name] = {
            coords = JSON.parse(v.coords),
            owned = owned,
            price = v.price,
            locked = true,
            address = v.label,
            tier = v.tier,
            garage = garage,
            decorations = {},
            stash = nil,
            outfit = nil,
            logout = nil,
        }
        HouseGarages[v.name] = {
            label = v.label,
            takeVehicle = garage,
        }
    end
end

exports['qb-core']:DatabaseAction('SelectAsync', 'SELECT * FROM player_houses', {}, function(houses)
    print('--- ASYNC DB ACTION RUNNING')
    if houses then
        for _, house in pairs(houses) do
            houseowneridentifier[house.house] = house.identifier
            houseownercid[house.house] = house.citizenid
            housekeyholders[house.house] = JSON.parse(house.keyholders)
            Config.Houses[house.house].owned = true
            Config.Houses[house.house].decorations = house.decorations and JSON.parse(house.decorations) or {}
            Config.Houses[house.house].stash = house.stash and JSON.parse(house.stash) or nil
            Config.Houses[house.house].outfit = house.outfit and JSON.parse(house.outfit) or nil
            Config.Houses[house.house].logout = house.logout and JSON.parse(house.logout) or nil
        end
    end
end)

-- Functions

local function isHouseOwner(identifier, cid, house)
    if houseowneridentifier[house] and houseownercid[house] then
        if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
            return true
        end
    end
    return false
end

local function isHouseOwned(house)
    if houseowneridentifier[house] and houseownercid[house] then
        return true
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

-- Callbacks

CreateCallback('ownership', function(source, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return false, false end
    local has_key = false
    local is_owned = false
    local license = Player.PlayerData.license
    local citizenid = Player.PlayerData.citizenid
    if hasKey(license, citizenid, house) then
        has_key = true
    elseif Player.PlayerData.job.name == 'realestate' then
        has_key = true
    else
        has_key = false
    end
    if houseowneridentifier[house] and houseownercid[house] then
        is_owned = true
    else
        is_owned = false
    end
    return has_key, is_owned
end)

CreateCallback('qb-houses:server:locations', function(_, house)
    local house_data = Config.Houses[house]
    local retval = {
        stash = house_data.stash,
        outfit = house_data.outfit,
        logout = house_data.logout,
    }
    return retval
end)

CreateCallback('getKeys', function(_, house)
    return housekeyholders[house]
end)

CreateCallback('getHouses', function()
    return Config.Houses
end)

CreateCallback('getOwnedHouses', function(_, citizenid)
    local houses = {}
    for house, cid in pairs(houseownercid) do
        if cid == citizenid then
            houses[#houses + 1] = {
                house = house,
                address = Config.Houses[house].address,
            }
        end
    end
    return houses
end)

-- Events

RegisterServerEvent('qb-houses:server:ring', function(source, data)
    local house = data.house
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local houseowner = houseowneridentifier[house]
    local target_player = exports['qb-core']:GetPlayerByLicense(houseowner)
    if not target_player then return end
    local target_source = target_player.PlayerData.source
    Events.CallRemote('qb-houses:client:ring', target_source, house)
end)

RegisterServerEvent('qb-houses:server:leaveCamera', function(source, coords)
    source:SetCameraLocation(coords)
    local newChar = HCharacter(coords, Rotator(), source)
    local player_dimension = source:GetDimension()
    newChar:SetDimension(player_dimension)
    source:Possess(newChar)
end)

RegisterServerEvent('qb-houses:server:camera', function(source, data)
    local house = data.house
    if not Config.Houses[house] then return end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if ped then
        source:UnPossess()
        ped:Destroy()
    end
    Events.CallRemote('qb-houses:client:camera', source)
end)

RegisterServerEvent('qb-houses:server:lock', function(source, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local house_data = Config.Houses[house]
    if not house_data then return end
    if not hasKey(Player.PlayerData.license, Player.PlayerData.citizenid, house) then return end
    house_data.locked = not house_data.locked
    Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
end)

RegisterServerEvent('qb-houses:server:logout', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    QBCore.Player.Logout(source)
    Events.CallRemote('qb-multicharacter:client:chooseChar', source)
end)

RegisterServerEvent('qb-houses:server:view', function(source, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local houseprice = Config.Houses[house].price
    local brokerfee = (houseprice / 100 * 5)
    local bankfee = (houseprice / 100 * 10)
    local taxes = (houseprice / 100 * 6)
    Events.CallRemote('qb-houses:client:view', source, house, houseprice, brokerfee, bankfee, taxes)
end)

RegisterServerEvent('qb-houses:server:setLocation', function(source, coords, house, type)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local license = Player.PlayerData.license
    local citizenid = Player.PlayerData.citizenid
    if not isHouseOwner(license, citizenid, house) then return end
    if type == 1 then
        MySQL.update('UPDATE player_houses SET stash = ? WHERE house = ?', { JSON.stringify(coords), house })
        Config.Houses[house].stash = coords
        Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
    elseif type == 2 then
        MySQL.update('UPDATE player_houses SET outfit = ? WHERE house = ?', { JSON.stringify(coords), house })
        Config.Houses[house].outfit = coords
        Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
    elseif type == 3 then
        MySQL.update('UPDATE player_houses SET logout = ? WHERE house = ?', { JSON.stringify(coords), house })
        Config.Houses[house].logout = coords
        Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
    end
end)

RegisterServerEvent('qb-houses:server:giveKey', function(source, target, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local license = Player.PlayerData.license
    local citizenid = Player.PlayerData.citizenid
    if not isHouseOwner(license, citizenid, house) then return end
    local TargetPlayer = exports['qb-core']:GetPlayer(target)
    if not TargetPlayer then return end
    housekeyholders[house][#housekeyholders[house] + 1] = TargetPlayer.PlayerData.citizenid
    MySQL.update('UPDATE player_houses SET keyholders = ? WHERE house = ?', { JSON.stringify(housekeyholders[house]), house })
end)

RegisterServerEvent('qb-houses:server:removeKey', function(source, target_cid, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local license = Player.PlayerData.license
    local citizenid = Player.PlayerData.citizenid
    if not isHouseOwner(license, citizenid, house) then return end
    local newHolders = {}
    if housekeyholders[house] then
        for i = 1, #housekeyholders[house], 1 do
            if housekeyholders[house][i] ~= target_cid then
                newHolders[#newHolders + 1] = housekeyholders[house][i]
            end
        end
    end
    housekeyholders[house] = newHolders
    MySQL.update('UPDATE player_houses SET keyholders = ? WHERE house = ?', { JSON.stringify(housekeyholders[house]), house })
end)

RegisterServerEvent('qb-houses:server:sell', function(source, data)
    local house = data.house
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local is_owned = isHouseOwned(house)
    if not is_owned then return end
    local license = Player.PlayerData.license
    local citizenid = Player.PlayerData.citizenid
    if not isHouseOwner(license, citizenid, house) then return end
    local price = Config.Houses[house].price
    Player.Functions.AddMoney('bank', math.ceil(price * 0.75), 'sold-house')
    houseowneridentifier[house] = nil
    houseownercid[house] = nil
    housekeyholders[house] = nil
    Config.Houses[house].owned = false
    MySQL.update('UPDATE houselocations SET owned = ? WHERE name = ?', { false, house })
    MySQL.query('DELETE FROM player_houses WHERE house = ?', { house })
    Events.CallRemote('QBCore:Notify', source, Lang:t('success.house_sold'), 'success')
    Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
end)

RegisterServerEvent('qb-houses:server:buy', function(source, house)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local price = Config.Houses[house].price
    local house_price = math.ceil(price * 1.21)
    local bank_balance = Player.PlayerData.money['bank']
    local is_owned = isHouseOwned(house)
    if is_owned then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.already_owned'), 'error')
        return
    end
    if bank_balance >= house_price then
        houseowneridentifier[house] = Player.PlayerData.license
        houseownercid[house] = Player.PlayerData.citizenid
        housekeyholders[house] = { Player.PlayerData.citizenid }
        Config.Houses[house].owned = true
        MySQL.insert('INSERT INTO player_houses (house, identifier, citizenid, keyholders) VALUES (?, ?, ?, ?)', { house, Player.PlayerData.license, Player.PlayerData.citizenid, JSON.stringify(housekeyholders[house]) })
        MySQL.update('UPDATE houselocations SET owned = ? WHERE name = ?', { 1, house })
        Player.Functions.RemoveMoney('bank', house_price, 'bought-house')
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.house_purchased'), 'success', 5000)
        Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_enough_money'), 'error')
    end
end)

-- Commands

local function GetHouseStreetCount(street)
    local count = 0
    for name, _ in pairs(Config.Houses) do
        if string.find(name, street:lower()) then
            local houseNumber = tonumber(string.match(name, '%d+'))
            if houseNumber and houseNumber > count then
                count = houseNumber
            end
        end
    end
    return (count + 1)
end

local function AddNewHouse(source, street, coords, price, tier)
    street = street:gsub("%'", '')
    price = tonumber(price)
    tier = tonumber(tier)
    local houseCount = GetHouseStreetCount(street)
    local name = street:lower() .. tostring(houseCount)
    local label = street .. ' ' .. tostring(houseCount)
    MySQL.insert('INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)', { name, label, JSON.stringify(coords), 0, price, tier })
    Config.Houses[name] = {
        coords = coords,
        owned = false,
        price = price,
        locked = true,
        address = label,
        tier = tier,
        garage = {},
        decorations = {},
        stash = nil,
        outfit = nil,
        logout = nil,
    }
    Events.CallRemote('QBCore:Notify', source, Lang:t('info.added_house', { value = label }))
    Events.BroadcastRemote('qb-houses:client:refresh', Config.Houses)
end

--[[ QBCore.Commands.Add('createhouse', Lang:t('info.create_house'), { { name = 'price', help = Lang:t('info.price_of_house') }, { name = 'tier', help = Lang:t('info.tier_number') } }, true, function(source, args)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'realestate' then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local pos = ped:GetLocation()
    local heading = ped:GetRotation()
    local price = tonumber(args[1])
    local tier = tonumber(args[2])
    local coords = { enter = { x = pos.X, y = pos.Y, z = pos.Z, h = heading.Yaw } }
    local street = 'helix_' .. math.random(1, 1000)
    AddNewHouse(source, street, coords, price, tier)
end, 'user') ]]
