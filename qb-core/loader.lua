local rapidjson = require('rapidjson')
local directory = UE.UKismetSystemLibrary.GetProjectContentDirectory()

-- Load Config
local configData = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/config.json')
if not configData then
    print('[QBCore] Failed to Load Config JSON File')
    return
end
QBCore.Config = configData

-- Load Jobs
local Jobs = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/jobs.json')
if not Jobs then
    print('[QBCore] Failed to Load Jobs JSON File')
    return
end
QBCore.Shared.Jobs = Jobs

-- Load Gangs
local Gangs = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/gangs.json')
if not Gangs then
    print('[QBCore] Failed to Load Gangs JSON File')
    return
end
QBCore.Shared.Gangs = Gangs

-- Load Items
local Items = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/items.json')
if not Items then
    print('[QBCore] Failed to Load Items JSON File')
    return
end
QBCore.Shared.Items = Items

-- Load Vehicles
local Vehicles = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/vehicles.json')
if not Vehicles then
    print('[QBCore] Failed to Load Vehicles JSON File')
    return
end

for i = 1, #Vehicles do
    local hash = UE.StringHash(Vehicles[i].model) -- placeholder function for hash
    QBCore.Shared.Vehicles[Vehicles[i].model] = {
        spawncode = Vehicles[i].model,
        name = Vehicles[i].name,
        brand = Vehicles[i].brand,
        model = Vehicles[i].model,
        price = Vehicles[i].price,
        category = Vehicles[i].category,
        hash = hash,
        type = Vehicles[i].type,
        shop = Vehicles[i].shop
    }
    QBCore.Shared.VehicleHashes[hash] = QBCore.Shared.Vehicles[Vehicles[i].model]
end

-- Load Weapons
local Weapons = rapidjson.load(directory .. '/Script/QBCore/qb-core/shared/weapons.json')
if not Weapons then
    print('[QBCore] Failed to Load Weapons JSON File')
    return
end
for i = 1, #Weapons do
    local weaponHash = UE.StringHash(Weapons[i].name) -- placeholder function for hash
    QBCore.Shared.Weapons[weaponHash] = {
        name = Weapons[i].name,
        label = Weapons[i].label,
        weapontype = Weapons[i].weapontype,
        ammotype = Weapons[i].ammotype,
        damagereason = Weapons[i].damagereason
    }
end

return {success = true}