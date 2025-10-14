local player_data = {}

-- Functions

-- Event Handlers

Timer.CreateThread(function()
    player_data = exports['qb-core']:GetPlayerData()
    setupPeds()
end)

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    player_data = exports['qb-core']:GetPlayerData()
    setupPeds()
end)

RegisterClientEvent('qb-shops:client:openShop', function(data)
    -- wait for target UI cleanup
    Timer.SetTimeout(function()
        TriggerServerEvent('qb-shops:server:openShop', { shop = data.shop })
    end, 600)
end)

-- Target

Timer.SetTimeout(function()
    for shop, shopData in pairs(Config.Locations) do
        exports['qb-target']:AddSphereZone(shop, {
            X = shopData.coords.X,
            Y = shopData.coords.Y,
            Z = shopData.coords.Z
        }, 100.0, {
            debug = true,
            distance = 1000
        }, {
            {
                icon = shopData.targetIcon or Config.DefaultTargetIcon,
                label = shopData.targetLabel or Config.DefaultTargetLabel,
                event = 'qb-shops:client:openShop',
                shop = shop,
                item = shopData.requiredItem,
                job = shopData.requiredJob,
                gang = shopData.requiredGang,
            }
        })
    end
end, 3000)
