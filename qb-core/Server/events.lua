-- Events

RegisterServerEvent('QBCore:UpdatePlayer', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - QBCore.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - QBCore.Config.Player.ThirstRate
    if newHunger <= 0 then newHunger = 0 end
    if newThirst <= 0 then newThirst = 0 end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent(source, 'qb-hud:client:UpdateNeeds', newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterServerEvent('QBCore:ToggleDuty', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent(source, 'QBCore:Notify', Lang:t('info.on_duty'))
    end
    TriggerLocalServerEvent('QBCore:Server:SetDuty', source, Player.PlayerData.job.onduty)
    TriggerClientEvent(source, 'QBCore:Client:SetDuty', Player.PlayerData.job.onduty)
end)
