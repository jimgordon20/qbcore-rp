local function connectToChannel(source, channel)
    if channel > 0 and channel < Config.MaxFrequency then
        source:SetVOIPChannel(channel)
    end
end

Events.SubscribeRemote('qb-radio:server:connectToChannel', function(source, channel)
    if channel > Config.MaxFrequency then return end
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local player_job = player.PlayerData.job.name
    local rounded_channel = math.floor(channel)
    if Config.RestrictedChannels[rounded_channel] then
        if Config.RestrictedChannels[rounded_channel][player_job] then
            Events.CallRemote('qb-radio:client:setChannel', source, channel)
        else
            Events.CallRemote('qb-radio:client:setChannel', source, channel, { no_access = true })
        end
    else
        Events.CallRemote('qb-radio:client:setChannel', source, channel)
    end
end)

Events.SubscribeRemote('qb-radio:server:increaseChannel', function(source)
    local voip_channel = source:GetVOIPChannel()
    if voip_channel == Config.MaxFrequency then
        source:AddVOIPChannel(1)
        return
    end
    source:AddVOIPChannel(voip_channel + 1)
end)

Events.SubscribeRemote('qb-radio:server:decreaseChannel', function(source)
    local voip_channel = source:GetVOIPChannel()
    if voip_channel == 1 then
        source:AddVOIPChannel(Config.MaxFrequency)
        return
    end
    source:AddVOIPChannel(voip_channel - 1)
end)

Events.SubscribeRemote('qb-radio:server:disconnectRadio', function(source)
    source:AddVOIPChannel(1)
end)

Events.SubscribeRemote('qb-radio:server:setVolume', function(source, volume)
    source:SetVOIPVolume(volume)
end)

QBCore.Commands.Add('radio', 'Join radio channel', {}, true, function(source, args)
    local channel = tonumber(args[1])
    if not channel then return end
    connectToChannel(source, channel)
end, 'user')

QBCore.Functions.CreateUseableItem('radio', function(source)
    Events.CallRemote('qb-radio:client:useRadio', source)
end)

-- IsInVOIPChannel(channel) -- both -- old function (GetVOIPChannel())
-- AddVOIPChannel(channel) -- server -- old function (SetVOIPChannel(channel))
-- RemoveVOIPChannel(channel) -- server
-- SetVOIPVolume(volume) -- both
-- SetVOIPSetting(setting) -- both
-- GetVOIPSetting() -- both
