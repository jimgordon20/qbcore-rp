Package.Require("Notification.lua")

-- Workaround for the input issue
Events.SubscribeRemote("SetInputEnabled", function(player, enabled)
    local hcharacter = player:GetControlledCharacter()
    if hcharacter then
        hcharacter:SetInputEnabled(enabled)
    end
end)

-- Uncomment this to spawn a character for each player (for testing purposes)
-- Package.Subscribe("Load", function()
--     local allPlayers = Player.GetAll()
--     for _, player in ipairs(allPlayers) do
--         my_hcharacter = HCharacter(Vector(0, 0, 0), Rotator(0, 0, 0), player)
--         player:Possess(my_hcharacter)
--     end
-- end)

-- Uncomment this to spawn a character for each player (for testing purposes)
-- Player.Subscribe("Ready", function (self)
--     local my_hcharacter = HCharacter(Vector(0, 0, 0), Rotator(0, 0, 0), self)
--     self:Possess(my_hcharacter)
-- end)