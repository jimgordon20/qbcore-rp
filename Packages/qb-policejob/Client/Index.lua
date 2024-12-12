Events.Subscribe('qb-policejob:client:SendPoliceEmergencyAlert', function()
    local Player = QBCore.Functions.GetPlayerData()
    Events.CallRemote('police:server:policeAlert', Lang:t('info.officer_down', { lastname = Player.charinfo.lastname, callsign = Player.metadata.callsign }))
    Events.CallRemote('hospital:server:ambulanceAlert', Lang:t('info.officer_down', { lastname = Player.charinfo.lastname, callsign = Player.metadata.callsign }))
end)

Events.Subscribe('police:client:SeizeDriverLicense', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        Events.CallRemote('police:server:SeizeDriverLicense', playerId)
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.Subscribe('qb-policejob:client:CheckStatus', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == 'leo' then
            local player, distance = QBCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                QBCore.Functions.TriggerCallback('police:GetPlayerStatus', function(result)
                    if result then
                        for _, v in pairs(result) do
                            QBCore.Functions.Notify('' .. v .. '')
                        end
                    end
                end, playerId)
            else
                QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
            end
        end
    end)
end)

Events.Subscribe('qb-policejob:client:EscortPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not isHandcuffed and not isEscorted then
            Events.CallRemote('police:server:EscortPlayer', playerId)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.Subscribe('qb-policejob:client:JailPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        ShowInput({
            header = Lang:t('info.jail_time_input'),
            submitText = Lang:t('info.submit'),
            inputs = {
                {
                    text = Lang:t('info.time_months'),
                    name = 'jailtime',
                    type = 'number',
                    isRequired = true
                }
            }
        }, function(dialog)
            if dialog and tonumber(dialog['jailtime']) > 0 then
                Events.CallRemote('police:server:JailPlayer', playerId, tonumber(dialog['jailtime']))
            else
                QBCore.Functions.Notify(Lang:t('error.time_higher'), 'error')
            end
        end)
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)
