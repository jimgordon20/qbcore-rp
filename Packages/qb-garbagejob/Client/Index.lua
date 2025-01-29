local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local isHoldingBag = false
local dumpster = nil

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

HCharacter.Subscribe('ValueChange', function(self, key, value)
    if self ~= Client.GetLocalPlayer():GetControlledCharacter() then return end

    if key ~= 'isHoldingBag' then return end
    isHoldingBag = value
end)

Events.SubscribeRemote('qb-garbagejob:client:addTargets', function(vehicle, nextStop)
    if vehicle then
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
    end

    if dumpster then
        dumpster:Destroy()
        Events.Call('Map:RemoveBlip', 'garbage_dumpster')
    end

    local dumpsterData = Config.Locations.Dumpsters[nextStop]
    dumpster = Prop(dumpsterData.coords, Rotator(0, dumpsterData.heading, 0), 'abcca-qbcore::SM_Dumpster')
    AddTargetEntity(dumpster, {
        options = {
            {
                label = 'Pickup Bag', -- Locale
                icon = 'fas fa-trash-alt',
                type = 'server',
                event = 'qb-garbage:server:grabBag',
            },
        },
        distance = 400,
    })

    Events.Call('Map:AddBlip', {
        id = 'garbage_dumpster',
        name = 'Dumpster',
        coords = { x = dumpsterData.coords.X, y = dumpsterData.coords.Y, z = dumpsterData.coords.Z},
        imgUrl = './media/map-icons/Marker.svg',
        group = 'Garbage Job',
    })
end)