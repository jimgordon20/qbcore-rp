-- Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    Client.SetValue('isLoggedIn', true)
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
    Client.SetValue('isLoggedIn', false)
end)

-- Events

RegisterClientEvent('QBCore:Player:SetPlayerData', function(val)
    QBCore.PlayerData = val
end)

RegisterClientEvent('QBCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('QBCore:UpdatePlayer')
end)

RegisterClientEvent('QBCore:Notify', function(text, type, length, icon)
    QBCore.Functions.Notify(text, type, length, icon)
end)

local isVisible = true
-- Input.Register('Toggle Chat', 'L')
-- Input.Bind('Toggle Chat', InputEvent.Pressed, function()
--     if Input.IsMouseEnabled() then return end
--     isVisible = not isVisible
--     Chat.SetVisibility(isVisible)
-- end)

RegisterClientEvent('QBCore:Client:ClearChat', function()
    Chat.Clear()
end)

RegisterClientEvent('QBCore:Client:CopyToClipboard', function(text)
    Client.CopyToClipboard(text)
    QBCore.Functions.Notify('Copied to clipboard', 'success')
end)

RegisterClientEvent('QBCore:Client:SetChatLayout', function(layout)
    local screen_size = Viewport.GetViewportSize()
    local chatConfigurations = {
        bottom_left = Vector2D(0, 0),
        center_left = screen_size * Vector2D(0, -0.28),      -- Vector2D(0, -400)
        top_left = screen_size * Vector2D(0, -0.55),         -- Vector2D(0, -800)
        bottom_center = screen_size * Vector2D(0.28, 0),     -- Vector2D(720, 0)
        center = screen_size * Vector2D(0.28, -0.28),        -- Vector2D(720, -400)
        top_center = screen_size * Vector2D(0.28, -0.55),    -- Vector2D(720, -800)
        bottom_right = screen_size * Vector2D(0.515, 0),     -- Vector2D(1320, 0)
        center_right = screen_size * Vector2D(0.515, -0.28), -- Vector2D(1320, -400)
        top_right = screen_size * Vector2D(0.515, -0.55),    -- Vector2D(1320, -800)
    }
    local layout_config = chatConfigurations[layout]
    if not layout_config then return end
    Chat.SetConfiguration(layout_config)
end)

-- Callback Events --

-- Client Callback
RegisterClientEvent('QBCore:Client:TriggerClientCallback', function(name, ...)
    QBCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
RegisterClientEvent('QBCore:Client:TriggerCallback', function(name, ...)
    if QBCore.ServerCallbacks[name] then
        QBCore.ServerCallbacks[name](...)
        QBCore.ServerCallbacks[name] = nil
    end
end)

-- Commands

RegisterClientEvent('QBCore:Console:RegisterCommand', function(name, help, paramList)
    Console.RegisterCommand(name, function(...)
        local args = { ... }
        local argsString = ''
        if #args > 0 then
            for _, argument in pairs(args) do
                argsString = argsString == '' and argument or argsString .. ' ' .. argument
            end
        end
        TriggerServerEvent('QBCore:Console:CallCommand', name, argsString)
    end, help, paramList)
end)

-- Listen to Shared being updated

RegisterClientEvent('QBCore:Client:OnSharedUpdate', function(tableName, key, value)
    QBShared[tableName][key] = value
    Events.Call('QBCore:Client:UpdateObject')
end)

RegisterClientEvent('QBCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QBShared[tableName][key] = value
    end
    Events.Call('QBCore:Client:UpdateObject')
end)

RegisterClientEvent('QBCore:Client:SharedUpdate', function(table)
    QBShared = table
end)
