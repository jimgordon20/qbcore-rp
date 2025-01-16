Input.Register('EmoteMenu', Config.Keybind)

Input.Bind('EmoteMenu', InputEvent.Pressed, function()
    local emote_menu = ContextMenu.new()
    for emote, data in pairs(Config.Emotes) do
        emote_menu:addDropdown(data.name, data.name, {
            {
                id = 'play-' .. emote,
                label = 'Play',
                type = 'button',
                emote = emote,
                callback = function()
                    Events.CallRemote('qb-emotemenu:server:playAnimation', emote)
                end
            },
            {
                id = 'stop-' .. emote,
                label = 'Stop',
                type = 'button',
                emote = emote,
                callback = function()
                    Events.CallRemote('qb-emotemenu:server:stopAnimation', emote)
                end
            }
        })
    end
    emote_menu:setMenuInfo('Emote Menu', '')
    emote_menu:Open(false, true)
end)
