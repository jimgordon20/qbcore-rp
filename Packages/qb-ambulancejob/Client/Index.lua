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

for _, v in pairs(Config.Locations.hospital) do
    local location = v.location
    Map:AddBlip({
        name = v.name,
        coords = {x = location.X, y = location.Y, z = location.Z},
        imgUrl = './media/map-icons/Medicine-icon.svg'
    })
end