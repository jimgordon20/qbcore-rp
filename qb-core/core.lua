QBCore = {
    Config = {},
    Shared = {
        Jobs = {},
        Gangs = {},
        Items = {},
        Vehicles = {},
        Weapons = {},
        VehicleHashes = {},
    },
    Player = {},
    Players = {},
    PlayerData = {},
    Functions = {},
    ClientCallbacks = {},
    ServerCallbacks = {},
    Player_Buckets = {},
    Entity_Buckets = {},
    UsableItems = {},
    Commands = {
        List = {},
        IgnoreList = {
            ['god'] = true,
            ['user'] = true
        }
    }
}

local function GetCoreObject(filters)
    if not filters then return QBCore end
    local results = {}
    for i = 1, #filters do
        local key = filters[i]
        if QBCore[key] then
            results[key] = QBCore[key]
        end
    end
    return results
end

require('QBCore/qb-core/loader')
require('QBCore/qb-core/locale')

print(QBCore.Shared.Jobs.police.label)

return {
    GetCoreObject = GetCoreObject
}
