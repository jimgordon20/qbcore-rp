-- Functions

local function sendToJail(player_id, time)

end

-- Events

Events.SubscribeRemote('qb-prison:server:jail', function(source, data, time)
    print(data, time)
    -- local Player = QBCore.Functions.GetPlayer(source)
    -- if not Player then return end
    -- if Player.PlayerData.job.type ~= 'leo' and not Player.PlayerData.job.onduty then return end
    -- local target_ped = data.entity
    -- if not target_ped then return end
    -- local target_player = target_ped:GetPlayer()
    -- if not target_player then return end
    -- local OtherPlayer = QBCore.Functions.GetPlayer(target_player)
    -- if not OtherPlayer then return end
    -- local player_ped = source:GetControlledCharacter()
    -- if not player_ped then return end
    -- if player_ped:GetPosition():Distance(target_ped:GetPosition()) > 500 then return end
    -- local currentDate = os.date('*t')
    -- if currentDate.day == 31 then currentDate.day = 30 end
    -- OtherPlayer.Functions.SetMetaData('injail', time)
    -- OtherPlayer.Functions.SetMetaData('criminalrecord', {
    --     ['hasRecord'] = true,
    --     ['date'] = currentDate
    -- })
    -- sendToJail(OtherPlayer.PlayerData.source, time)
    -- Events.CallRemote('QBCore:Notify', source, Lang:t('info.sent_jail_for', { time = time }))
end)
