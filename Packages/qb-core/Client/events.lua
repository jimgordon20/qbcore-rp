-- Handlers

Events.Subscribe('QBCore:Client:OnPlayerLoaded', function()
    Client.SetValue('isLoggedIn', true)
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    Client.SetValue('isLoggedIn', true)
end)

Events.Subscribe('QBCore:Client:OnPlayerUnload', function()
    Client.SetValue('isLoggedIn', false)
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
    Client.SetValue('isLoggedIn', false)
end)

-- Events

Events.SubscribeRemote('QBCore:Player:SetPlayerData', function(val)
    QBCore.PlayerData = val
end)

Events.SubscribeRemote('QBCore:Player:UpdatePlayerData', function()
    Events.CallRemote('QBCore:UpdatePlayer')
end)

Events.Subscribe('QBCore:Notify', function(text, type, length, icon)
    QBCore.Functions.Notify(text, type, length, icon)
end)

Events.SubscribeRemote('QBCore:Notify', function(text, type, length, icon)
    QBCore.Functions.Notify(text, type, length, icon)
end)

local isVisible = true
Input.Register('toggle_chat', 'L', 'Toggle Chat')
Input.Bind('toggle_chat', InputEvent.Pressed, function()
    isVisible = not isVisible
    Chat.SetVisibility(isVisible)
end)

Events.SubscribeRemote('QBCore:Client:ClearChat', function()
    Chat.Clear()
end)

Events.SubscribeRemote('QBCore:Client:CopyToClipboard', function(text)
    Client.CopyToClipboard(text)
    QBCore.Functions.Notify('Copied to clipboard', 'success')
end)

Events.SubscribeRemote('QBCore:Client:SetChatLayout', function(layout)
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
Events.SubscribeRemote('QBCore:Client:TriggerClientCallback', function(name, ...)
    QBCore.Functions.TriggerClientCallback(name, function(...)
        Events.CallRemote('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
Events.SubscribeRemote('QBCore:Client:TriggerCallback', function(name, ...)
    if QBCore.ServerCallbacks[name] then
        QBCore.ServerCallbacks[name](...)
        QBCore.ServerCallbacks[name] = nil
    end
end)

-- Commands

Events.SubscribeRemote('QBCore:Console:RegisterCommand', function(name, help, paramList)
    Console.RegisterCommand(name, function(...)
        local args = {...}
        local argsString = ''
        if #args > 0 then
            for _, argument in pairs(args) do
                argsString = argsString == '' and argument or argsString .. ' ' .. argument
            end
        end
        Events.CallRemote('QBCore:Console:CallCommand', name, argsString)
    end, help, paramList)
end)

-- Listen to Shared being updated

Events.SubscribeRemote('QBCore:Client:OnSharedUpdate', function(tableName, key, value)
    QBShared[tableName][key] = value
    Events.Call('QBCore:Client:UpdateObject')
end)

Events.SubscribeRemote('QBCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QBShared[tableName][key] = value
    end
    Events.Call('QBCore:Client:UpdateObject')
end)

Events.SubscribeRemote('QBCore:Client:SharedUpdate', function(table)
    QBShared = table
end)
