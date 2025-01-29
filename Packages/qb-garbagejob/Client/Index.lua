local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local isHoldingBag = false
local dumpster = nil
local garbageTruck = nil

for k, depot in pairs(Config.Locations.Depots) do
    Events.Call('Map:RemoveBlip', 'garbage_depot_' .. k) -- Cleanup blips on startup
    Events.Call('Map:AddBlip', {
        id = 'garbage_depot_' .. k,
        name = depot.label,
        coords = { x = depot.pedSpawn.coords.X, y = depot.pedSpawn.coords.Y, z = depot.pedSpawn.coords.Z },
        imgUrl = './media/map-icons/Marker.svg',
        group = 'Garbage Job',
    })
end

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

    if key ~= 'holdingBag' then return end
    isHoldingBag = value
end)

Events.SubscribeRemote('qb-garbagejob:client:addTargets', function(vehicle, nextStop)
    if vehicle then
        -- AddTargetEntity(vehicle, {
        --     options = {
        --         {
        --             label = 'Load Bag', -- Locale
        --             icon = 'fas fa-truck-loading',
        --             type = 'server',
        --             event = 'qb-garbagejob:server:loadBag',
        --             canInteract = function()
        --                 return isHoldingBag
        --             end,
        --         },
        --     },
        --     distance = 400,
        -- })
        garbageTruck = vehicle
    end

    if dumpster then
        dumpster:Destroy()
        Events.Call('Map:RemoveBlip', 'garbage_dumpster')
    end

    if not nextStop then return end

    local dumpsterData = Config.Locations.Dumpsters[nextStop]
    dumpster = Prop(dumpsterData.coords, Rotator(0, dumpsterData.heading, 0), 'abcca-qbcore::SM_Dumpster',  CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Disabled)
    AddTargetEntity(dumpster, {
        options = {
            {
                label = 'Pickup Bag', -- Locale
                icon = 'fas fa-trash-alt',
                type = 'server',
                event = 'qb-garbagejob:server:grabBag',
                canInteract = function()
                    return not isHoldingBag
                end,
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

Events.Subscribe('qb-garbagejob:client:cancelJob', function()
    if dumpster then
        dumpster:Destroy()
        dumpster = nil
        Events.Call('Map:RemoveBlip', 'garbage_dumpster')
    end
    Events.CallRemote('qb-garbagejob:server:cancelJob', garbageTruck)
    if garbageTruck then
        garbageTruck = nil
    end
end)

Input.Subscribe('KeyDown', function(key_name)
    if key_name == 'F' then
        local playerPed = Client.GetLocalPlayer():GetControlledCharacter()
        if not playerPed then return end
        if not garbageTruck or not garbageTruck:IsValid() then return end
        if not isHoldingBag then return end
        if playerPed:GetLocation():Distance(garbageTruck:GetLocation()) < 500 then
            Events.CallRemote('qb-garbagejob:server:loadBag')
        end
    end
end)