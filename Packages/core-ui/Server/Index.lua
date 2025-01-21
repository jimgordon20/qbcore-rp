Package.Require('Notification.lua')

-- Workaround for the input issue
Events.SubscribeRemote('SetInputEnabled', function(player, enabled)
    local hcharacter = player:GetControlledCharacter()
    if hcharacter then
        hcharacter:SetInputEnabled(enabled)
    end
end)
