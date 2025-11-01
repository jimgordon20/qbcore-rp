local Lang = require('locales/en')
local Vehicles = exports['qb-core']:GetShared('Vehicles')

-- Functions

function onShutdown()
    for _, shopData in pairs(Config.Shops) do
        local vehicles = shopData['ShowroomVehicles']
        for i = 1, #vehicles do
            local vehicleData = vehicles[i]
            local location = vehicleData['coords'].location
            ClearAreaOfVehicles(location)
        end
    end
end

-- Spawn Vehicles

for _, shopData in pairs(Config.Shops) do
    local vehicles = shopData['ShowroomVehicles']
    for i = 1, #vehicles do
        local vehicleData  = vehicles[i]
        local vehicleInfo  = Vehicles[vehicleData['defaultVehicle']]
        local vehicleClass = vehicleInfo['asset_name']
        local location     = vehicleData['coords'].location
        local rotation     = vehicleData['coords'].rotation
        local vehicle      = HVehicle(location, rotation, vehicleClass)
        vehicle:SetSimulationEnabledForHelixEntity(false)
    end
end

-- Events

RegisterServerEvent('qb-vehicleshop:server:testDrive', function(_, data)
    local vehicle = data.vehicle
    local vehicleInfo = Vehicles[vehicle]
    local vehicleClass = vehicleInfo['asset_name']
    local location = data.coords.location
    local rotation = data.coords.rotation
    HVehicle(location, rotation, vehicleClass)
end)

RegisterServerEvent('qb-vehicleshop:server:swapVehicle', function(source, data)
    local vehicleName  = data.vehicle
    local shop         = data.shop
    local index        = data.index
    local vehicleInfo  = Vehicles[vehicleName]
    local vehicleClass = vehicleInfo['asset_name']
    local location     = Config.Shops[shop]['ShowroomVehicles'][index]['coords'].location
    local rotation     = Config.Shops[shop]['ShowroomVehicles'][index]['coords'].rotation

    ClearAreaOfVehicles(location)

    local vehicle = HVehicle(location, rotation, vehicleClass)
    vehicle:SetSimulationEnabledForHelixEntity(false)

    Config.Shops[shop]['ShowroomVehicles'][index]['chosenVehicle'] = vehicleName
    TriggerClientEvent(source, 'qb-vehicleshop:client:updateConfig', vehicleName, shop, index)
end)

-- Callbacks
