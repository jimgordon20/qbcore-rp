-- Events

RegisterServerEvent('qb-spawn:server:spawnPlayer', function(source, coords)
    if not coords then
        local Player = exports['qb-core']:GetPlayer(source)
        if not Player then return end
        local position = Player.PlayerData.position
        coords = Vector(position.x, position.y, position.z)
    end
    local ped = source:K2_GetPawn()
    if not ped then return end
    ped:K2_SetActorLocationAndRotation(Vector(coords.X, coords.Y, coords.Z), Rotator(0, 0, 0), false, _, true)
end)
