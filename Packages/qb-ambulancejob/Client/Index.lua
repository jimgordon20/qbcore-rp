Package.Require('death.lua')
Package.Require('wounding.lua')

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-ambulancejob:server:getPeds', function(peds)
        for ped, data in pairs(peds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end)

QBCore.Functions.TriggerCallback('qb-ambulancejob:server:getPeds', function(peds)
    for ped, data in pairs(peds) do
        AddTargetEntity(ped, { options = data.options, distance = data.distance })
    end
end)
