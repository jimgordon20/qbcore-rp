local player_data = {}
local in_shop = false

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('getShopPeds', function(shopPeds)
        for ped, data in pairs(shopPeds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end

-- Event Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        player_data = QBCore.Functions.GetPlayerData()
        if QBConfig.UseTarget then setupPeds() end
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    player_data = QBCore.Functions.GetPlayerData()
    if QBConfig.UseTarget then setupPeds() end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
    player_data = {}
end)

Events.SubscribeRemote('qb-shops:client:enteredShop', function(shop)
    in_shop = shop
    DrawText('[E] Open Shop', 'left')
end)

Events.SubscribeRemote('qb-shops:client:leftShop', function()
    in_shop = false
    HideText()
end)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'E' and in_shop then
        Events.CallRemote('qb-shops:server:openShop', { shop = in_shop })
    end
end)
