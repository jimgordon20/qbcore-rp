QBCore = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared

exports('qb-core', 'GetSharedItems', function()
    return QBShared.Items
end)

exports('qb-core', 'GetSharedJobs', function()
    return QBShared.Jobs
end)

exports('qb-core', 'GetSharedGangs', function()
    return QBShared.Gangs
end)

exports('qb-core', 'GetCoreObject', function()
    return QBCore
end)
