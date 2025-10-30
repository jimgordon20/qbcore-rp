local function dumpChannels(source)
    for k, v in pairs(source:GetVoiceChannels()) do
        print('In Channel', v)
    end
end

RegisterServerEvent('qb-radio:server:JoinVoiceChannel', function(source, channel)
    if source:IsInVoiceChannel(channel) then return end
    dumpChannels(source)
    print('--- BEFORE JOIN ----')
    source:JoinVoiceChannel(channel)
    print('--- AFTER JOIN ----')
    dumpChannels(source)
end)

RegisterServerEvent('qb-radio:server:LeaveVoiceChannel', function(source, channel)
    if not source:IsInVoiceChannel(channel) then return end
    dumpChannels(source)
    print('--- BEFORE LEAVE ----')
    source:LeaveVoiceChannel(channel)
    print('--- AFTER LEAVE ----')
    dumpChannels(source)
end)

RegisterCallback('JoinVoiceChannel', function(source, channel)
    if source:IsInVoiceChannel(channel) then return false end
    dumpChannels(source)
    print('--- BEFORE JOIN ----')
    source:JoinVoiceChannel(channel)
    print('--- AFTER JOIN ----')
    dumpChannels(source)
    return true
end)

RegisterCallback('LeaveVoiceChannel', function(source, channel)
    if not source:IsInVoiceChannel(channel) then return false end
    dumpChannels(source)
    print('--- BEFORE LEAVE ----')
    source:LeaveVoiceChannel(channel)
    print('--- AFTER LEAVE ----')
    dumpChannels(source)
    return true
end)
