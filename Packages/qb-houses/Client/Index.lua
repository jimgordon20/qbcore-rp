local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local is_owned = false
local is_inside = false
local current_house = nil
local closest_house = nil
local has_key = false
local data = nil
local houseObj = {}
local POIOffsets = nil
local viewing_camera = false
local current_location

-- Functions

local function PlaySound(sound)
    Sound(Vector(), sound, true)
end

local function CheckDistance(target, distance)
    local player = Client.GetLocalPlayer()
    local ped = player:GetControlledCharacter()
    if not ped then return end
    local pos = ped:GetLocation()
    return pos:Distance(target) <= distance
end

local function setClosestHouse()
    local player = Client.GetLocalPlayer()
    local ped = player:GetControlledCharacter()
    if not ped then return end
    local pos = ped:GetLocation()
    local closestDistance = 800
    local closest = nil
    if not is_inside then
        for id, house in pairs(Config.Houses) do
            local housePos = Vector(house.coords.enter.x, house.coords.enter.y, house.coords.enter.z)
            local distance = pos:Distance(housePos)
            if distance < closestDistance then
                closestDistance = distance
                closest = id
            end
        end
        if closest then
            closest_house = closest
            QBCore.Functions.TriggerCallback('qb-houses:server:ownership', function(key, owned)
                has_key = key
                is_owned = owned
            end, closest_house)
        end
    end
    if closest_house and next(Config.Houses[closest_house].garage) == nil then return end
    Events.Call('qb-garages:client:setHouseGarage', closest_house, has_key)
end

local function createEntrance(id, house)
    local coords = Vector(house.coords['enter'].x, house.coords['enter'].y, house.coords['enter'].z)
    local boxName = 'houseEntrance_' .. id
    local boxData = Config.Targets[boxName] or {}
    if boxData and boxData.created then return end

    local options = {
        {
            icon = 'fas fa-eye',
            label = Lang:t('menu.view_house'),
            canInteract = function()
                return not is_owned
            end,
            action = function()
                Events.CallRemote('qb-houses:server:view', closest_house)
            end
        },
        {
            type = 'client',
            event = 'qb-houses:client:enter',
            icon = 'fas fa-door-open',
            label = Lang:t('menu.enter_house'),
            canInteract = function()
                return is_owned and has_key
            end
        },
        {
            type = 'client',
            event = 'qb-houses:client:keys',
            icon = 'fas fa-key',
            label = Lang:t('menu.manage_keys'),
            canInteract = function()
                return is_owned and has_key
            end,
        },
        {
            type = 'server',
            event = 'qb-houses:server:lock',
            icon = 'fas fa-lock',
            label = Lang:t('menu.doorlock'),
            house = id,
            canInteract = function()
                return is_owned and has_key
            end
        },
        {
            type = 'server',
            event = 'qb-houses:server:sell',
            icon = 'fas fa-dollar-sign',
            label = Lang:t('menu.sell_house'),
            house = id,
            canInteract = function()
                return is_owned and has_key
            end
        },
        {
            icon = 'fas fa-bell',
            label = Lang:t('menu.ring_door'),
            canInteract = function()
                return is_owned and not has_key
            end,
            action = function()
                Events.CallRemote('qb-houses:server:ring', closest_house)
            end
        },
        {
            type = 'client',
            event = 'qb-houses:client:enter',
            icon = 'fas fa-door-open',
            label = Lang:t('menu.enter_unlocked_house'),
            canInteract = function()
                return is_owned and not has_key
            end
        },
        {
            type = 'client',
            event = 'qb-houses:client:reset',
            icon = 'fas fa-lock-open',
            label = Lang:t('menu.lock_door_police'),
            jobType = 'leo'
        },
    }

    AddBoxZone(boxName, coords, 2.0, 1.0, {
        name = boxName,
        heading = house.coords['enter'].h,
    }, {
        options = options,
        distance = 500,
    })

    Config.Targets[boxName] = { created = true }
end

local function registerEntrance()
    if Config.Houses and next(Config.Houses) then
        for id, house in pairs(Config.Houses) do
            if house and house.coords and house.coords['enter'] then
                createEntrance(id, house)
            end
        end
    end
end

local function registerExit(id)
    if not Config.Houses[id] then return end
    if not POIOffsets then return end
    local house = Config.Houses[id]
    local coords = Vector(house.coords['enter'].x - POIOffsets.exit.x, house.coords['enter'].y - POIOffsets.exit.y, house.coords['enter'].z - Config.MinZOffset + POIOffsets.exit.z)
    local options = {
        {
            type = 'client',
            event = 'qb-houses:client:exit',
            icon = 'fas fa-door-open',
            label = Lang:t('menu.exit_property'),
        },
        {
            type = 'server',
            event = 'qb-houses:server:camera',
            icon = 'fas fa-camera',
            label = Lang:t('menu.front_camera'),
            house = id,
            canInteract = function()
                return is_owned
            end
        },
        {
            type = 'client',
            event = 'qb-houses:client:keys',
            icon = 'fas fa-key',
            label = Lang:t('menu.manage_keys'),
            canInteract = function()
                return is_owned and has_key
            end
        },
        {
            type = 'server',
            event = 'qb-houses:server:lock',
            icon = 'fas fa-lock',
            label = Lang:t('menu.doorlock'),
            house = id,
            canInteract = function()
                return is_owned and has_key
            end,
        },
        {
            type = 'client',
            event = 'qb-houses:client:invite',
            icon = 'fas fa-bell',
            label = Lang:t('menu.open_door'),
            canInteract = function()
                return is_owned
            end
        },
    }
    AddBoxZone(boxName, coords, 2.0, 1.0, {
        name = boxName,
        heading = 0,
    }, {
        options = options,
        distance = 500,
    })
end

local function getDataForHouseTier(house, coords)
    if Config.Houses[house].tier == 1 then
        return CreateApartmentFurnished(coords)
    elseif Config.Houses[house].tier == 2 then
        return CreateContainer(coords)
    elseif Config.Houses[house].tier == 3 then
        return CreateFurniMid(coords)
    elseif Config.Houses[house].tier == 4 then
        return CreateFranklinAunt(coords)
    elseif Config.Houses[house].tier == 5 then
        return CreateGarageMed(coords)
    elseif Config.Houses[house].tier == 6 then
        return CreateLesterShell(coords)
    elseif Config.Houses[house].tier == 7 then
        return CreateOffice1(coords)
    elseif Config.Houses[house].tier == 8 then
        return CreateStore1(coords)
    elseif Config.Houses[house].tier == 9 then
        return CreateTrailer(coords)
    elseif Config.Houses[house].tier == 10 then
        return CreateWarehouse1(coords)
    elseif Config.Houses[house].tier == 11 then
        return CreateStandardMotel(coords)
    else
        QBCore.Functions.Notify(Lang:t('error.invalid_tier'), 'error')
    end
end

local function stashTarget(stashLocation)
    local coords = Vector(stashLocation.x, stashLocation.y, stashLocation.z)
    local options = {
        {
            type = 'client',
            event = 'qb-houses:client:stash',
            icon = 'fas fa-box-open',
            label = Lang:t('target.open_stash'),
        }
    }
    AddBoxZone('house-stash', coords, 1.5, 1.5, {
        name = 'house-stash',
        heading = 0,
    }, {
        options = options,
        distance = 500,
    })
end

local function outfitTarget(outfitLocation)
    local coords = Vector(outfitLocation.x, outfitLocation.y, outfitLocation.z)
    local options = {
        {
            type = 'client',
            event = 'qb-houses:client:outfit',
            icon = 'fas fa-box-open',
            label = Lang:t('target.outfits'),
        },
    }
    AddBoxZone('house-outfit', coords, 1.5, 1.5, {
        name = 'house-outfit',
        heading = 0,
    }, {
        options = options,
        distance = 500,
    })
end

local function logoutTarget(logoutLocation)
    local coords = Vector(logoutLocation.x, logoutLocation.y, logoutLocation.z)
    local options = {
        {
            type = 'client',
            event = 'qb-houses:client:logout',
            icon = 'fas fa-box-open',
            label = Lang:t('target.change_character'),
        },
    }
    AddBoxZone('house-logout', coords, 1.5, 1.5, {
        name = 'house-logout',
        heading = 0,
    }, {
        options = options,
        distance = 500,
    })
end

local function setHouseLocations()
    if not current_house then return end
    local house_data = Config.Houses[current_house]
    if not house_data then return end
    if house_data.stash then
        stashTarget(JSON.parse(house_data.stash))
    end
    if house_data.outfit then
        outfitTarget(JSON.parse(house_data.outfit))
    end
    if house_data.logout then
        logoutTarget(JSON.parse(house_data.logout))
    end
end

local function enterHouse(house)
    current_house = house
    closest_house = house
    is_inside = true
    PlaySound('package://qb-houses/Client/sounds/houses_door_open.ogg')
    local coords = Vector(
        Config.Houses[house].coords.enter.x,
        Config.Houses[house].coords.enter.y,
        Config.Houses[house].coords.enter.z - Config.MinZOffset
    )
    --LoadDecorations(house)
    data = getDataForHouseTier(house, coords)
    houseObj = data[1]
    POIOffsets = data[2]
    Events.CallRemote('qb-houses:server:SetInsideMeta', house, true)
    Events.Call('qb-weathersync:client:DisableSync')
    setHouseLocations()
    registerExit(house)
end

local function leaveHouse(house)
    if not viewing_camera then
        PlaySound('package://qb-houses/Client/sounds/houses_door_close.ogg')
        Client.GetLocalPlayer():StartCameraFade(0, 1, 0.1, Color(0, 0, 0, 1), true, true)
        DespawnInterior(houseObj, function()
            --UnloadDecorations()
            Events.Call('qb-weathersync:client:EnableSync')
            Events.CallRemote(
                'qb-interior:server:teleportPlayer',
                Config.Houses[CurrentHouse].coords.enter.x,
                Config.Houses[CurrentHouse].coords.enter.y,
                Config.Houses[CurrentHouse].coords.enter.z,
                0
            )
            is_inside = false
            current_house = nil
            Events.CallRemote('qb-houses:server:SetInsideMeta', house, false)
        end)
    end
end

local function viewCamera()
    viewing_camera = true
    local player = Client.GetLocalPlayer()
    current_location = player:GetCameraLocation()
    local coords = Vector(
        Config.Houses[current_house].coords.enter.x,
        Config.Houses[current_house].coords.enter.y,
        Config.Houses[current_house].coords.enter.z - Config.MinZOffset
    )
    player:SetCameraLocation(coords)
end

local function houseBlips()
    for id, house in pairs(Config.Houses) do
        if house and house.coords and house.coords['enter'] then
            local blipImage = './media/map-icons/house_sale.svg'
            if house.owned then blipImage = './media/map-icons/house_owned.svg' end
            Config.Houses[id].blip = Events.Call('Map:AddBlip', {
                id = id,
                name = house.adress,
                imgUrl = blipImage,
                coords = { x = house.coords.enter.x, y = house.coords.enter.y, z = house.coords.enter.z },
            })
        end
    end
end

-- Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        QBCore.Functions.TriggerCallback('qb-houses:server:getHouses', function(houses)
            Config.Houses = houses
            setClosestHouse()
            registerEntrance()
            houseBlips()
            if closest_house and next(Config.Houses[closest_house].garage) == nil then return end
            Events.Call('qb-garages:client:setHouseGarage', closest_house, has_key)
        end)
    end
end)

Events.Subscribe('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-houses:server:getHouses', function(houses)
        Config.Houses = houses
        setClosestHouse()
        registerEntrance()
        houseBlips()
        if closest_house and next(Config.Houses[closest_house].garage) == nil then return end
        Events.Call('qb-garages:client:setHouseGarage', closest_house, has_key)
    end)
end)

Events.Subscribe('QBCore:Client:OnPlayerUnload', function()
    is_inside = false
    closest_house = nil
    has_key = false
    is_owned = false
end)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'BackSpace' and viewing_camera then
        viewing_camera = false
        Events.CallRemote('qb-houses:server:leaveCamera', current_location)
        current_location = nil
    end
end)

-- Events

Events.SubscribeRemote('qb-houses:client:refresh', function(house_config)
    Config.Houses = house_config
    registerEntrance()
    houseBlips()
    if is_inside then setHouseLocations() end
end)

Events.Subscribe('qb-houses:client:logout', function()
    leaveHouse(closest_house)
    Events.CallRemote('qb-houses:server:logout')
end)

Events.Subscribe('qb-houses:client:stash', function()
    if current_house then
        PlaySound('package://qb-houses/Client/sounds/StashOpen.ogg')
        Events.CallRemote('qb-houses:server:stash', current_house)
    end
end)

Events.Subscribe('qb-houses:client:outfit', function()
    -- TODO: Implement outfit menu
end)

Events.SubscribeRemote('qb-houses:client:ring', function(house)
    if closest_house == house and is_inside then
        PlaySound('package://qb-houses/Client/sounds/doorbell.ogg')
        QBCore.Functions.Notify(Lang:t('info.door_ringing'))
    end
end)

Events.Subscribe('qb-houses:client:enter', function()
    if not closest_house then return end
    local player = Client.GetLocalPlayer()
    local ped = player:GetControlledCharacter()
    if not ped then return end
    local coords = ped:GetLocation()
    if coords:Distance(Vector(Config.Houses[closest_house].coords.enter.x, Config.Houses[closest_house].coords.enter.y, Config.Houses[closest_house].coords.enter.z)) < 800 then
        if not is_owned then return end
        if has_key then
            enterHouse(closest_house)
            return
        end
        if not Config.Houses[closest_house].locked then
            enterHouse(closest_house)
        end
    end
end)

Events.Subscribe('qb-houses:client:exit', function()
    if not POIOffsets then return end
    local door = Vector(
        Config.Houses[current_house].coords.enter.x - POIOffsets.exit.x,
        Config.Houses[current_house].coords.enter.y - POIOffsets.exit.y,
        Config.Houses[current_house].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z
    )
    if CheckDistance(door, 500) then
        leaveHouse(current_house)
    end
end)

Events.Subscribe('qb-houses:client:camera', function()
    if not POIOffsets then return end
    local door = Vector(
        Config.Houses[current_house].coords.enter.x - POIOffsets.exit.x,
        Config.Houses[current_house].coords.enter.y - POIOffsets.exit.y,
        Config.Houses[current_house].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z
    )
    if CheckDistance(door, 500) then
        viewCamera()
    end
end)

Events.Subscribe('qb-houses:client:setLocation', function(cData)
    local client = Client.GetLocalPlayer()
    local ped = client:GetControlledCharacter()
    if not ped then return end
    local pos = ped:GetLocation()
    local coords = { x = pos.X, y = pos.Y, z = pos.Z }
    if not is_inside or not has_key then return end
    if cData.id == 'setstash' then
        Events.CallRemote('qb-houses:server:setLocation', coords, closest_house, 1)
    elseif cData.id == 'setoutift' then
        Events.CallRemote('qb-houses:server:setLocation', coords, closest_house, 2)
    elseif cData.id == 'setlogout' then
        Events.CallRemote('qb-houses:server:setLocation', coords, closest_house, 3)
    end
end)

Events.SubscribeRemote('qb-houses:client:view', function(house, houseprice, brokerfee, bankfee, taxes)
    local house_label = Config.Houses[house].adress
    local view_menu = ContextMenu:new()
    view_menu:addText('broker-fee', 'Broker Fee $' .. brokerfee)
    view_menu:addText('bank-fee', 'Bank Fee $' .. bankfee)
    view_menu:addText('taxes', 'Taxes $' .. taxes)
    view_menu:addButton('purchase', 'Purchase $' .. houseprice, function()
        Events.CallRemote('qb-houses:server:buy', house)
    end)
    view_menu:SetHeader(house_label, '')
    view_menu:Open(false, true)
end)

Events.Subscribe('qb-houses:client:keys', function()
    local house = is_inside and current_house or closest_house
    if not house then return end
    local keys_menu = ContextMenu:new()
    local coords = Client.GetLocalPlayer():GetControlledCharacter():GetLocation()

    -- Add Keys
    local closest_players = QBCore.Functions.GetClosestPlayers(coords, 500)
    local dropdown_options = {}
    for i = 1, #closest_players do
        table.insert(dropdown_options, {
            id = 'key_holder_' .. i,
            label = closest_players[i]:GetName(),
            type = 'button',
            callback = function()
                Events.CallRemote('qb-houses:server:giveKey', closest_players[i], house)
            end
        })
    end
    keys_menu:addDropdown('give_keys', 'Give Keys', dropdown_options)

    -- Remove Keys
    QBCore.Functions.TriggerCallback('qb-houses:server:getKeys', function(key_holders)
        local remove_options = {}
        for i = 1, #key_holders do
            table.insert(remove_options, {
                id = 'remove_key_holder_' .. i,
                label = key_holders[i],
                type = 'button',
                callback = function()
                    Events.CallRemote('qb-houses:server:removeKey', key_holders[i], house)
                end
            })
        end
        keys_menu:addDropdown('remove_keys', 'Remove Keys', remove_options)
        keys_menu:SetHeader('Manage Keys', '')
        keys_menu:Open(false, true)
    end, house)
end)

Events.Subscribe('qb-houses:client:createHouse', function()
    local house_menu = ContextMenu:new()
    house_menu:addDropdown('house_tier', 'House Tier', {
        { id = '1',  label = 'Tier 1',  type = 'checkbox', checked = false },
        { id = '2',  label = 'Tier 2',  type = 'checkbox', checked = false },
        { id = '3',  label = 'Tier 3',  type = 'checkbox', checked = false },
        { id = '4',  label = 'Tier 4',  type = 'checkbox', checked = false },
        { id = '5',  label = 'Tier 5',  type = 'checkbox', checked = false },
        { id = '6',  label = 'Tier 6',  type = 'checkbox', checked = false },
        { id = '7',  label = 'Tier 7',  type = 'checkbox', checked = false },
        { id = '8',  label = 'Tier 8',  type = 'checkbox', checked = false },
        { id = '9',  label = 'Tier 9',  type = 'checkbox', checked = false },
        { id = '10', label = 'Tier 10', type = 'checkbox', checked = false },
        { id = '11', label = 'Tier 11', type = 'checkbox', checked = false },
    })
    house_menu:addNumber('house_price', 'House Price')
    house_menu:SetHeader('Create House', '')
    house_menu:Open(false, true)
end)

-- Timers

Timer.SetInterval(function()
    if Client.GetValue('isLoggedIn', false) and not is_inside then
        setClosestHouse()
    end
end, 500)
