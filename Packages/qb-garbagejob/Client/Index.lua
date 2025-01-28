local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-garbagejob:server:getPeds', function(jobPeds)
        for ped, data in pairs(jobPeds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end

-- Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        setupPeds()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    setupPeds()
end)

Events.SubscribeRemote('qb-garbagejob:client:addTargets', function(vehicle, nextStop)
    AddTargetEntity(vehicle, {
        options = {
            {
                label = 'Load Bag', -- Locale
                icon = 'fas fa-truck-loading',
                type = 'server',
                event = 'qb-garbagejob:server:loadBag',
                canInteract = function()
                    return isHoldingBag
                end,
            },
        },
        distance = 5,
    })

    local dumpsterData = Config.Locations.Dumpsters[nextStop]
    local dumpster = Prop(dumpsterData.coords, Rotator(0, dumpsterData.heading, 0), 'abcca-qbcore::SM_Dumpster')
    AddTargetEntity(dumpster, {
        options = {
            {
                label = 'Pickup Bag', -- Locale
                icon = 'fas fa-trash-alt',
                type = 'server',
                event = 'qb-garbage:server:pickupBag',
            },
        },
        distance = 400,
    })
end)