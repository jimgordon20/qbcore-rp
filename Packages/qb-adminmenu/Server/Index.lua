local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

-- Events

Events.SubscribeRemote('qb-adminmenu:server:toggleInput', function(source, bool)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:SetInputEnabled(bool)
end)

-- Commands

QBCore.Commands.Add('admin', '', {}, false, function(source)
    Events.CallRemote('qb-adminmenu:client:openMenu', source)
end, 'admin')

QBCore.Commands.Add('invisible', '', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local isVisible = ped:GetValue('invisible', false)
    ped:SetVisibility(not isVisible)
    ped:SetValue('invisible', not isVisible, true)
end, 'admin')

QBCore.Commands.Add('godmode', '', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local isGodmode = ped:GetValue('godmode', false)
    ped:SetInvulnerable(not isGodmode)
    ped:SetValue('godmode', not isGodmode, true)
end, 'admin')

QBCore.Commands.Add('noclip', '', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if ped then
        source:UnPossess()
        ped:Destroy()
        source:SetValue('noclip', true, true)
    else
        QBCore.Functions.TriggerClientCallback('qb-adminmenu:client:getCamera', source, function(coords, rotation)
            local newChar = HCharacter(coords, rotation, source)
            local player_dimension = source:GetDimension()
            newChar:SetDimension(player_dimension)
            source:Possess(newChar)
            source:SetValue('noclip', false, true)
        end)
    end
end, 'admin')

QBCore.Commands.Add('heal', 'Heal yourself', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    Player.Functions.SetMetaData('hunger', 100)
    Player.Functions.SetMetaData('thirst', 100)
    Player.Functions.SetMetaData('stress', 0)
    local max_health = ped:GetMaxHealth()
    ped:SetHealth(max_health)
end, 'admin')

QBCore.Commands.Add('kill', 'Kill yourself', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:SetHealth(0)
end, 'admin')

QBCore.Commands.Add('revive', 'Revive yourself', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    Player.Functions.SetMetaData('hunger', 100)
    Player.Functions.SetMetaData('thirst', 100)
    Player.Functions.SetMetaData('stress', 0)
    ped:Respawn(ped:GetLocation(), ped:GetRotation())
end, 'admin')

QBCore.Commands.Add('reviveall', 'Revive all', {}, false, function()
    local players = HCharacter.GetAll()
    for i = 1, #players do
        local ped = players[i]
        ped:SetHealth(ped:GetMaxHealth())
        ped:Respawn(ped:GetLocation(), ped:GetRotation())
    end
end, 'admin')

QBCore.Commands.Add('tp', Lang:t('command.tp.help'), { { name = Lang:t('command.tp.params.x.name'), help = Lang:t('command.tp.params.x.help') }, { name = Lang:t('command.tp.params.y.name'), help = Lang:t('command.tp.params.y.help') }, { name = Lang:t('command.tp.params.z.name'), help = Lang:t('command.tp.params.z.help') } }, false, function(source, args)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    if args[1] and not args[2] and not args[3] then
        local target_id = tonumber(args[1])
        if target_id then
            local target_source = QBCore.Functions.GetPlayer(target_id).PlayerData.source
            local target = target_source:GetControlledCharacter()
            if target then
                local coords = target:GetLocation()
                ped:SetLocation(coords)
            end
        end
    elseif args[1] and args[2] and args[3] then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            ped:SetLocation(Vector(x, y, z))
        end
    end
end, 'admin')

QBCore.Commands.Add('coords', 'Copy Coords', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local coords = ped:GetLocation()
    local text = 'Vector(' .. coords.X .. ', ' .. coords.Y .. ', ' .. coords.Z .. ')'
    Events.CallRemote('QBCore:Client:CopyToClipboard', source, text)
end, 'admin')

QBCore.Commands.Add('rotation', 'Copy Rotation', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local rotation = ped:GetRotation()
    local text = 'Rotator(' .. rotation.Pitch .. ', ' .. rotation.Yaw .. ', ' .. rotation.Roll .. ')'
    Events.CallRemote('QBCore:Client:CopyToClipboard', source, text)
end, 'admin')

QBCore.Commands.Add('heading', 'Copy Heading', {}, false, function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local heading = ped:GetRotation().Yaw
    Events.CallRemote('QBCore:Client:CopyToClipboard', source, tostring(heading))
end, 'admin')

QBCore.Commands.Add('showcoords', 'Show Coords', {}, false, function(source)
    Events.CallRemote('qb-adminmenu:client:showCoords', source)
end, 'admin')

QBCore.Commands.Add('names', 'Show Names', {}, false, function(source)
    Events.CallRemote('qb-adminmenu:client:showNames', source)
end, 'admin')

QBCore.Commands.Add('laser', 'Debug Laser', {}, false, function(source)
    Events.CallRemote('qb-adminmenu:client:entitylaser', source)
end, 'admin')
