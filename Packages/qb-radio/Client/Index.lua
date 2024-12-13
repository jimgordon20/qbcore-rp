local my_webui = WebUI('radio', 'file://html/index.html')
local radio_open = false
local radio_volume = 50

-- Functions

local function connectToChannel(channel)
    if channel > 0 then
        Events.CallRemote('qb-radio:server:connectToChannel', channel)
    end
end

local function disconnectRadio()
    if radio_connected then
        Events.CallRemote('qb-radio:server:disconnectRadio', radio_channel)
        Input.SetMouseEnabled(true)
        my_webui:CallEvent('CONNECT_RADIO', false)
    end
end

local function openRadio()
    radio_open = true
    my_webui:BringToFront()
    Input.SetMouseEnabled(true)
    my_webui:CallEvent('OPEN_RADIO')
end

local function closeRadio()
    radio_open = false
    my_webui:CallEvent('CLOSE_RADIO')
    Input.SetMouseEnabled(false)
end

local function useRadio()
    if not radio_open then
        openRadio()
    else
        closeRadio()
    end
end

-- Events

Events.SubscribeRemote('qb-radio:client:useRadio', useRadio)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'BackSpace' and radio_open then
        disconnectRadio()
    end
end)

-- NUI

my_webui:Subscribe('JOIN_RADIO', function(channel)
    if not radio_open then return end
    connectToChannel(channel)
end)

my_webui:Subscribe('LEAVE_RADIO', function()
    if not radio_open then return end
    Events.CallRemote('qb-radio:server:disconnectRadio')
end)

my_webui:Subscribe('POWERED_OFF', function()
    if not radio_open then return end
    closeRadio()
    Events.CallRemote('qb-radio:server:disconnectRadio')
end)

my_webui:Subscribe('VOLUME_UP', function()
    if not radio_open then return end
    if radio_volume <= 95 then
        radio_volume = radio_volume + 5
        Client.GetLocalPlayer():SetVOIPVolume(radio_volume)
    end
end)

my_webui:Subscribe('VOLUME_DOWN', function()
    if not radio_open then return end
    if radio_volume >= 10 then
        radio_volume = radio_volume - 5
        Client.GetLocalPlayer():SetVOIPVolume(radio_volume)
    end
end)

my_webui:Subscribe('INCREASE_RADIO_CHANNEL', function()
    if not radio_open then return end
    Events.CallRemote('qb-radio:server:increaseChannel')
end)

my_webui:Subscribe('DECREASE_RADIO_CHANNEL', function()
    if not radio_open then return end
    Events.CallRemote('qb-radio:server:decreaseChannel')
end)
