local Plates = {}

local function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    return result
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-policejob:GetImpoundedVehicles', function(_, cb)
    local vehicles = {}
    MySQL.query('SELECT * FROM player_vehicles WHERE state = ?', { 2 }, function(result)
        if result[1] then
            vehicles = result
        end
        cb(vehicles)
    end)
end)

QBCore.Functions.CreateCallback('qb-policejob:IsPlateFlagged', function(_, cb, plate)
    local retval = false
    if Plates and Plates[plate] then
        if Plates[plate].isflagged then
            retval = true
        end
    end
    cb(retval)
end)

-- Events

Events.SubscribeRemote('qb-policejob:server:TakeOutImpound', function(source, plate, garage)
    local playerPed = source:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = Config.Locations['impound'][garage]
    if #(playerCoords - targetCoords) > 10.0 then return DropPlayer(source, 'Attempted exploit abuse') end
    MySQL.update('UPDATE player_vehicles SET state = ? WHERE plate = ?', { 0, plate })
    Events.CallRemote('QBCore:Notify', source, Lang:t('success.impound_vehicle_removed'), 'success')
end)

Events.SubscribeRemote('qb-policejob:server:Impound', function(source, plate, fullImpound, price, body, engine, fuel)
    price = price and price or 0
    if IsVehicleOwned(plate) then
        if not fullImpound then
            MySQL.query('UPDATE player_vehicles SET state = ?, depotprice = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?', { 0, price, body, engine, fuel, plate })
            Events.CallRemote('QBCore:Notify', source, Lang:t('info.vehicle_taken_depot', { price = price }))
        else
            MySQL.query('UPDATE player_vehicles SET state = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?', { 2, body, engine, fuel, plate })
            Events.CallRemote('QBCore:Notify', source, Lang:t('info.vehicle_seized'))
        end
    end
end)
