-- Callback Events --

-- Client Callback
Events.SubscribeRemote('QBCore:Server:TriggerClientCallback', function(_, name, ...)
    if QBCore.ClientCallbacks[name] then
        QBCore.ClientCallbacks[name](...)
        QBCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
Events.SubscribeRemote('QBCore:Server:TriggerCallback', function(source, name, ...)
    QBCore.Functions.TriggerCallback(name, source, function(...)
        Events.CallRemote('QBCore:Client:TriggerCallback', source, name, ...)
    end, ...)
end)

-- Events

Events.SubscribeRemote('QBCore:UpdatePlayer', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - QBConfig.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - QBConfig.Player.ThirstRate
    if newHunger <= 0 then newHunger = 0 end
    if newThirst <= 0 then newThirst = 0 end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    Events.CallRemote('hud:client:UpdateNeeds', source, newHunger, newThirst)
    Player.Functions.Save()
end)

Events.SubscribeRemote('QBCore:ToggleDuty', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        Events.CallRemote('QBCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        Events.CallRemote('QBCore:Notify', src, Lang:t('info.on_duty'))
    end
    Events.Call('QBCore:Server:SetDuty', src, Player.PlayerData.job.onduty)
    Events.CallRemote('QBCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- Callbacks

QBCore.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords)
    local vehicle = QBCore.Functions.CreateVehicle(source, model, coords)
    cb(vehicle)
end)
