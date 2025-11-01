-- Events

RegisterServerEvent('qb-spawn:server:spawnPlayer', function(source, coords)
    if not coords then
        local Player = exports['qb-core']:GetPlayer(source)
        if not Player then return end
        local position = Player.PlayerData.position
        coords = Vector(position.x, position.y, position.z)
    end
    local ped = GetPlayerPawn(source)
    if not ped then return end
    SetEntityCoords(ped, Vector(coords.X, coords.Y, coords.Z))
end)
