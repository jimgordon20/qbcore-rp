-- Events

Events.SubscribeRemote('qb-spawn:server:spawnPlayer', function(source, coords)
    if not coords then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        local position = Player.PlayerData.position
        coords = Vector(position.X, position.Y, position.Z)
    end
    local new_char = HCharacter(coords, Rotator(0, 0, 0), source)
    local source_dimension = source:GetDimension()
    new_char:SetDimension(source_dimension)
    source:Possess(new_char)
    Events.CallRemote('QBCore:Client:OnPlayerLoaded', source)
end)
