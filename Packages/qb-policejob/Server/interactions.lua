Events.SubscribeRemote('qb-policejob:server:SearchPlayer', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local PlayerData = Player.PlayerData
    if PlayerData.job.type ~= 'leo' then return end
    local player, distance = QBCore.Functions.GetClosestPlayer(source)
    if player ~= -1 and distance < 2.5 then
        local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(player))
        if not SearchedPlayer then return end
        OpenInventoryById(source, tonumber(player))
        Events.CallRemote('QBCore:Notify', source, Lang:t('info.cash_found', { cash = SearchedPlayer.PlayerData.money['cash'] }))
        Events.CallRemote('QBCore:Notify', player, Lang:t('info.being_searched'))
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:CuffPlayer', function(source, playerId, isSoftcuff)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not CuffedPlayer or (not Player.Functions.GetItemByName('handcuffs') and Player.PlayerData.job.type ~= 'leo') then return end
    Events.CallRemote('qb-policejob:client:GetCuffed', CuffedPlayer.PlayerData.source, Player.PlayerData.source, isSoftcuff)
end)

Events.SubscribeRemote('qb-policejob:server:EscortPlayer', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not EscortPlayer then return end
    if (Player.PlayerData.job.type == 'leo' or Player.PlayerData.job.name == 'ambulance') or (EscortPlayer.PlayerData.metadata['ishandcuffed'] or EscortPlayer.PlayerData.metadata['isdead'] or EscortPlayer.PlayerData.metadata['inlaststand']) then
        Events.CallRemote('qb-policejob:client:GetEscorted', EscortPlayer.PlayerData.source, Player.PlayerData.source)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_cuffed_dead'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:KidnapPlayer', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not EscortPlayer then return end
    if EscortPlayer.PlayerData.metadata['ishandcuffed'] or EscortPlayer.PlayerData.metadata['isdead'] or EscortPlayer.PlayerData.metadata['inlaststand'] then
        Events.CallRemote('qb-policejob:client:GetKidnappedTarget', EscortPlayer.PlayerData.source, Player.PlayerData.source)
        Events.CallRemote('qb-policejob:client:GetKidnappedDragger', Player.PlayerData.source, EscortPlayer.PlayerData.source)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_cuffed_dead'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:SetPlayerOutVehicle', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(source) or not EscortPlayer then return end
    if EscortPlayer.PlayerData.metadata['ishandcuffed'] or EscortPlayer.PlayerData.metadata['isdead'] then
        Events.CallRemote('qb-policejob:client:SetOutVehicle', EscortPlayer.PlayerData.source)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_cuffed_dead'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:PutPlayerInVehicle', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(source) or not EscortPlayer then return end
    if EscortPlayer.PlayerData.metadata['ishandcuffed'] or EscortPlayer.PlayerData.metadata['isdead'] then
        Events.CallRemote('qb-policejob:client:PutInVehicle', EscortPlayer.PlayerData.source)
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_cuffed_dead'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:BillPlayer', function(source, playerId, price)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not OtherPlayer or Player.PlayerData.job.type ~= 'leo' then return end
    OtherPlayer.Functions.RemoveMoney('bank', price, 'paid-bills')
    exports['qb-banking']:AddMoney('police', price, 'Fine paid')
    Events.CallRemote('QBCore:Notify', OtherPlayer.PlayerData.source, Lang:t('info.fine_received', { fine = price }))
end)

Events.SubscribeRemote('qb-policejob:server:JailPlayer', function(source, playerId, time)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not OtherPlayer or Player.PlayerData.job.type ~= 'leo' then return end
    local currentDate = os.date('*t')
    if currentDate.day == 31 then
        currentDate.day = 30
    end
    OtherPlayer.Functions.SetMetaData('injail', time)
    OtherPlayer.Functions.SetMetaData('criminalrecord', {
        ['hasRecord'] = true,
        ['date'] = currentDate
    })
    Events.CallRemote('qb-policejob:client:SendToJail', OtherPlayer.PlayerData.source, time)
    Events.CallRemote('QBCore:Notify', source, Lang:t('info.sent_jail_for', { time = time }))
end)

Events.SubscribeRemote('qb-policejob:server:SetHandcuffStatus', function(source, isHandcuffed)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('ishandcuffed', isHandcuffed)
end)

Events.SubscribeRemote('qb-policejob:server:SeizeCash', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not SearchedPlayer then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    local moneyAmount = SearchedPlayer.PlayerData.money['cash']
    local info = { cash = moneyAmount }
    SearchedPlayer.Functions.RemoveMoney('cash', moneyAmount, 'police-cash-seized')
    exports['qb-inventory']:AddItem(source, 'moneybag', 1, false, info, 'qb-policejob:server:SeizeCash')
    Events.CallRemote('qb-inventory:client:ItemBox', source, QBCore.Shared.Items['moneybag'], 'add')
    Events.CallRemote('QBCore:Notify', SearchedPlayer.PlayerData.source, Lang:t('info.cash_confiscated'))
end)

Events.SubscribeRemote('qb-policejob:server:SeizeDriverLicense', function(source, playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(source) or not SearchedPlayer then return end
    local driverLicense = SearchedPlayer.PlayerData.metadata['licences']['driver']
    if driverLicense then
        local licenses = { ['driver'] = false, ['business'] = SearchedPlayer.PlayerData.metadata['licences']['business'] }
        SearchedPlayer.Functions.SetMetaData('licences', licenses)
        Events.CallRemote('QBCore:Notify', SearchedPlayer.PlayerData.source, Lang:t('info.driving_license_confiscated'))
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.no_driver_license'), 'error')
    end
end)

Events.SubscribeRemote('qb-policejob:server:RobPlayer', function(playerId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = playerId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not SearchedPlayer then return end
    local money = SearchedPlayer.PlayerData.money['cash']
    Player.Functions.AddMoney('cash', money, 'police-player-robbed')
    SearchedPlayer.Functions.RemoveMoney('cash', money, 'police-player-robbed')
    exports['qb-inventory']:OpenInventoryById(source, playerId)
    Events.CallRemote('QBCore:Notify', SearchedPlayer.PlayerData.source, Lang:t('info.cash_robbed', { money = money }))
    Events.CallRemote('QBCore:Notify', Player.PlayerData.source, Lang:t('info.stolen_money', { stolen = money }))
end)

Events.SubscribeRemote('qb-policejob:server:showFingerprint', function(source, playerId)
    Events.CallRemote('qb-policejob:client:showFingerprint', playerId, source)
    Events.CallRemote('qb-policejob:client:showFingerprint', source, playerId)
end)

Events.SubscribeRemote('qb-policejob:server:showFingerprintId', function(sessionId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local fid = Player.PlayerData.metadata['fingerprint']
    Events.CallRemote('qb-policejob:client:showFingerprintId', sessionId, fid)
    Events.CallRemote('qb-policejob:client:showFingerprintId', source, fid)
end)

Events.SubscribeRemote('qb-policejob:server:SetTracker', function(source, targetId)
    local playerPed = source:GetControlledCharacter()
    local targetPed = targetId:GetControlledCharacter()
    local playerCoords = playerPed:GetLocation()
    local targetCoords = targetPed:GetLocation()
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(source, 'Attempted exploit abuse') end
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not QBCore.Functions.GetPlayer(source) or not Target then return end
    local TrackerMeta = Target.PlayerData.metadata['tracker']
    if TrackerMeta then
        Target.Functions.SetMetaData('tracker', false)
        Events.CallRemote('QBCore:Notify', targetId, Lang:t('success.anklet_taken_off'), 'success')
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.took_anklet_from', { firstname = Target.PlayerData.charinfo.firstname, lastname = Target.PlayerData.charinfo.lastname }), 'success')
        Events.CallRemote('qb-policejob:client:SetTracker', targetId, false)
    else
        Target.Functions.SetMetaData('tracker', true)
        Events.CallRemote('QBCore:Notify', targetId, Lang:t('success.put_anklet'), 'success')
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.put_anklet_on', { firstname = Target.PlayerData.charinfo.firstname, lastname = Target.PlayerData.charinfo.lastname }), 'success')
        Events.CallRemote('qb-policejob:client:SetTracker', targetId, true)
    end
end)

Events.SubscribeRemote('qb-policejob:server:SendTrackerLocation', function(source, coords, requestId)
    local Target = QBCore.Functions.GetPlayer(source)
    if not Target then return end
    local msg = Lang:t('info.target_location', { firstname = Target.PlayerData.charinfo.firstname, lastname = Target.PlayerData.charinfo.lastname })
    local alertData = {
        title = Lang:t('info.anklet_location'),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    Events.CallRemote('qb-policejob:client:TrackerMessage', requestId, msg, coords)
    Events.CallRemote('qb-phone:client:addPoliceAlert', requestId, alertData)
end)
