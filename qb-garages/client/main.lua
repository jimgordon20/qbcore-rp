local SharedVehicles = exports['qb-core']:GetShared('Vehicles')
local my_webui = WebUI('Garages', 'qb-garages/html/index.html')
local PlayerData = {}
local PlayerGang = {}
local PlayerJob = {}
local garageZones = {}
local inZone = false
local zone = {}
require('locales/en')

-- Functions

local function CheckPlayers(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
    Wait(1500)
    QBCore.Functions.DeleteVehicle(vehicle)
end

local function OpenGarageMenu()
    TriggerCallback('server.GetGarageVehicles', function(result)
        if result == nil then return exports['qb-core']:Notify(Lang:t('error.no_vehicles'), 'error', 5000) end
        local formattedVehicles = {}
        for _, v in pairs(result) do
            local enginePercent = math.floor(v.engine + 0.5)
            local bodyPercent = math.floor(v.body + 0.5)
            local vname = nil
            pcall(function()
                vname = SharedVehicles[v.vehicle].name
            end)
            formattedVehicles[#formattedVehicles + 1] = {
                vehicle = v.vehicle,
                vehicleLabel = vname or v.vehicle,
                plate = v.plate,
                state = v.state,
                fuel = v.fuel,
                engine = enginePercent,
                body = bodyPercent,
                distance = v.drivingdistance or 0,
                garage = Config.Garages[zone.indexgarage],
                type = zone.type,
                index = zone.indexgarage,
                depotPrice = v.depotprice or 0,
                balance = v.balance or 0
            }
        end

        my_webui:SetInputMode(1)
        my_webui:SendEvent('VehicleList', {
            garageLabel = Config.Garages[zone.indexgarage].label,
            vehicles = formattedVehicles,
        })
    end, zone.indexgarage)
end

local function DepositVehicle(vehicle)
    TriggerServerEvent('qb-garages:server:DepositVehicle', vehicle.Plate, zone.indexgarage, 1)
end

local function IsVehicleAllowed(class, vehicle)
    if not Config.ClassSystem then return true end
    if vehicle.VehicleType == class then
        return true
    end
    return false
end

--[[ local function CreateBlips(setloc)
    local Garage = AddBlipForCoord(setloc.takeVehicle.x, setloc.takeVehicle.y, setloc.takeVehicle.z)
    SetBlipSprite(Garage, setloc.blipNumber)
    SetBlipDisplay(Garage, 4)
    SetBlipScale(Garage, 0.60)
    SetBlipAsShortRange(Garage, true)
    SetBlipColour(Garage, setloc.blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(setloc.blipName)
    EndTextCommandSetBlipName(Garage)
end ]]

local function CreateZone(index, garage, zoneType)
    local ZoneData = {
        indexgarage = index,
        type = garage.type,
        category = garage.category
    }
    local CurrentZone = Trigger(garage.takeVehicle, Rotator(), Vector(100), TriggerType.Sphere, true, function()
        zone = ZoneData
        inZone = true

        local displayText = Lang:t('info.car_e')
        if zone.vehicle == 'sea' then
            displayText = Lang:t('info.sea_e')
        elseif zone.vehicle == 'air' then
            displayText = Lang:t('info.air_e')
        elseif zone.vehicle == 'rig' then
            displayText = Lang:t('info.rig_e')
        elseif zone.type == 'depot' then
            displayText = Lang:t('info.depot_e')
        end
        exports['qb-core']:DrawText(displayText, 'left')
    end, Color(255, 0, 0), {})

    local Shapes = CurrentZone:K2_GetComponentsByClass(UE.UShapeComponent)
    if Shapes[1] then
        Shapes[1].OnComponentEndOverlap:Add(HWorld, function(_)
            inZone = false
            zone = {}
            exports['qb-core']:HideText()
        end)
    end

    return zone
end

local function CreateBlipsZones()
    PlayerData = exports['qb-core']:GetPlayerData()
    PlayerGang = PlayerData.gang
    PlayerJob = PlayerData.job

    for index, garage in pairs(Config.Garages) do
        local zone
--[[         if garage.showBlip then
            CreateBlips(garage)
        end ]]
        if garage.type == 'job' and (PlayerJob.name == garage.job or PlayerJob.type == garage.jobType) then
            zone = CreateZone(index, garage, 'job')
        elseif garage.type == 'gang' and PlayerGang.name == garage.job then
            zone = CreateZone(index, garage, 'gang')
        elseif garage.type == 'depot' then
            zone = CreateZone(index, garage, 'depot')
        elseif garage.type == 'public' then
            zone = CreateZone(index, garage, 'public')
        end

        if zone then
            garageZones[#garageZones + 1] = zone
        end
    end
end

Input.BindKey('E', function()
    if not inZone then return end
    if HPlayer:GetInputMode() == 1 then return end
    if not next(zone) then return end

    local Vehicle = GetVehiclePedIsIn(HPlayer:K2_GetPawn())
    if Vehicle then
        if zone.type == 'depot' then return end
        if not IsVehicleAllowed(zone.category, Vehicle) then
            QBCore.Functions.Notify(Lang:t('error.not_correct_type'), 'error', 3500)
            return
        end

        DepositVehicle(Vehicle)
    else
        OpenGarageMenu()
    end
end)

--[[ local function doCarDamage(currentVehicle, stats, props)
    local engine = stats.engine + 0.0
    local body = stats.body + 0.0
    SetVehicleEngineHealth(currentVehicle, engine)
    SetVehicleBodyHealth(currentVehicle, body)
    if not next(props) then return end
    if props.doorStatus then
        for k, v in pairs(props.doorStatus) do
            if v then SetVehicleDoorBroken(currentVehicle, tonumber(k), true) end
        end
    end
    if props.tireBurstState then
        for k, v in pairs(props.tireBurstState) do
            if v then SetVehicleTyreBurst(currentVehicle, tonumber(k), true) end
        end
    end
    if props.windowStatus then
        for k, v in pairs(props.windowStatus) do
            if not v then SmashVehicleWindow(currentVehicle, tonumber(k)) end
        end
    end
end ]]

-- NUI Callbacks

my_webui:RegisterEventHandler('closeGarage', function(_, cb)
    my_webui:SetInputMode(0)
    cb('ok')
end)

my_webui:RegisterEventHandler('takeOutVehicle', function(data, cb)
    TriggerServerEvent('qb-garages:server:SpawnVehicle', data.plate, data.index, data.vehicle, data.stats.fuel)
    cb('ok')
end)
--[[ 
RegisterNUICallback('trackVehicle', function(plate, cb)
    TriggerServerEvent('qb-garages:server:trackVehicle', plate)
    cb('ok')
end)

RegisterNUICallback('takeOutDepo', function(data, cb)
    local depotPrice = data.depotPrice
    if depotPrice ~= 0 then
        TriggerServerEvent('qb-garages:server:PayDepotPrice', data)
    else
        TriggerEvent('qb-garages:client:takeOutGarage', data)
    end
    cb('ok')
end) ]]

-- Events

--[[ RegisterNetEvent('qb-garages:client:trackVehicle', function(coords)
    SetNewWaypoint(coords.x, coords.y)
end) ]]

local function CheckPlate(vehicle, plateToSet)
    local vehiclePlate = promise.new()
    CreateThread(function()
        while true do
            Wait(500)
            if GetVehicleNumberPlateText(vehicle) == plateToSet then
                vehiclePlate:resolve(true)
                return
            else
                SetVehicleNumberPlateText(vehicle, plateToSet)
            end
        end
    end)
    return vehiclePlate
end

-- Housing calls

--[[ local houseGarageZones = {}
local listenForKeyHouse = false
local houseComboZones = nil

local function CreateHouseZone(index, garage, zoneType)
    local houseZone = CircleZone:Create(garage.takeVehicle, 5.0, {
        name = zoneType .. '_' .. index,
        debugPoly = false,
        useZ = true,
        data = {
            indexgarage = index,
            type = zoneType,
            category = garage.category
        }
    })

    if houseZone then
        houseGarageZones[#houseGarageZones + 1] = houseZone

        if not houseComboZones then
            houseComboZones = ComboZone:Create(houseGarageZones, { name = 'houseComboZones', debugPoly = false })
        else
            houseComboZones:AddZone(houseZone)
        end
    end

    houseComboZones:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            listenForKeyHouse = true
            CreateThread(function()
                while listenForKeyHouse do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
                            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
                            DepositVehicle(currentVehicle, zone.data)
                        else
                            OpenGarageMenu(zone.data)
                        end
                    end
                end
            end)
            exports['qb-core']:DrawText(Lang:t('info.house_garage'), 'left')
        else
            listenForKeyHouse = false
            exports['qb-core']:HideText()
        end
    end)
end

local function ZoneExists(zoneName)
    for _, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            return true
        end
    end
    return false
end

local function RemoveHouseZone(zoneName)
    local removedZone = houseComboZones:RemoveZone(zoneName)
    if removedZone then
        removedZone:destroy()
    end
    for index, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            table.remove(houseGarageZones, index)
            break
        end
    end
end

RegisterNetEvent('qb-garages:client:setHouseGarage', function(house, hasKey) -- event sent periodically from housing
    if not house then return end
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[formattedHouseName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateHouseZone(formattedHouseName, Config.Garages[formattedHouseName], 'house')
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    else
        QBCore.Functions.TriggerCallback('qb-garages:server:getHouseGarage', function(garageInfo) -- create garage if not exist
            if not garageInfo.garage then return end
            local garageCoords = json.decode(garageInfo.garage)
            Config.Garages[formattedHouseName] = {
                houseName = house,
                takeVehicle = vector3(garageCoords.x, garageCoords.y, garageCoords.z),
                spawnPoint = {
                    vector4(garageCoords.x, garageCoords.y, garageCoords.z, garageCoords.w or garageCoords.h)
                },
                label = garageInfo.label,
                type = 'house',
                category = Config.VehicleClass['all']
            }
            TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
        end, house)
    end
end)

RegisterNetEvent('qb-garages:client:houseGarageConfig', function(houseGarages)
    for houseName, garageConfig in pairs(houseGarages) do
        local formattedHouseName = string.gsub(string.lower(garageConfig.label), ' ', '')
        if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
            Config.Garages[formattedHouseName] = {
                houseName = houseName,
                takeVehicle = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                spawnPoint = {
                    vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                },
                label = garageConfig.label,
                type = 'house',
                category = Config.VehicleClass['all']
            }
        end
    end
    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('qb-garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    Config.Garages[formattedHouseName] = {
        houseName = house,
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
        },
        label = garageInfo.label,
        type = 'house',
        category = Config.VehicleClass['all']
    }
    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
end) ]]

-- Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    CreateBlipsZones()
end)

RegisterClientEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
end)

RegisterClientEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)
