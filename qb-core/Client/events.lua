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

RegisterClientEvent('qb-core:client:DrawText', function(text, position)
    QBCore.Functions.DrawText(text, position)
end)

RegisterClientEvent('qb-core:client:ChangeText', function(text, position)
    QBCore.Functions.ChangeText(text, position)
end)

RegisterClientEvent('qb-core:client:HideText', function()
    QBCore.Functions.HideText()
end)

RegisterClientEvent('qb-core:client:KeyPressed', function()
    QBCore.Functions.KeyPressed()
end)

-- Commands

RegisterClientEvent('QBCore:Console:RegisterCommand', function(name, help)
    RegisterConsoleCommand(name, function(...)
        local args = { ... }
        local argsString = ''
        if #args > 0 then
            for _, argument in pairs(args) do
                argsString = argsString == '' and argument or argsString .. ' ' .. argument
            end
        end
        TriggerServerEvent('QBCore:Console:CallCommand', name, argsString)
    end, help)
end)
