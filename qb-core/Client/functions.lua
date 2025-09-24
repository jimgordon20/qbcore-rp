local my_webui = WebUI('Notify', 'file://html/index.html')
QBCore.Functions = {}

-- Callback Functions --

-- Create Client Callback
function QBCore.Functions.CreateClientCallback(name, cb)
    QBCore.ClientCallbacks[name] = cb
end

-- Trigger Client Callback
function QBCore.Functions.TriggerClientCallback(name, cb, ...)
    if not QBCore.ClientCallbacks[name] then return end
    QBCore.ClientCallbacks[name](cb, ...)
end

-- Trigger Server Callback
function QBCore.Functions.TriggerCallback(name, cb, ...)
    QBCore.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

-- Getter Functions

function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

-- Functions

function QBCore.Functions.Debug(tbl)
    print(HELIXTable.Dump(tbl))
end

function QBCore.Functions.Notify(text, texttype, length, icon)
    print('Notify:', text, texttype, length, icon)
    -- local noti_type = texttype or 'info'
    -- if type(text) == 'table' then
    --     Notification.Send(noti_type, text.text, text.caption)
    -- else
    --     Notification.Send(noti_type, text)
    -- end
end

-- World Getters

function QBCore.Functions.GetClosestPlayer(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local players = HCharacter.GetAll()
    local closest_player, closest_distance = nil, -1
    for i = 1, #players do
        local ped = players[i]
        if ped ~= player_ped then
            if ped:GetPlayer() then
                local ped_coords = ped:GetLocation()
                local distance = player_coords:Distance(ped_coords)
                if closest_distance == -1 or distance < closest_distance then
                    closest_player = ped:GetPlayer()
                    closest_distance = distance
                end
            end
        end
    end
    return closest_player, closest_distance
end

function QBCore.Functions.GetClosestPlayers(coords, max_distance)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return {} end
    local player_coords = coords or player_ped:GetLocation()
    local players = HCharacter.GetAll()
    local closest_players = {}
    for i = 1, #players do
        local ped = players[i]
        if ped ~= player_ped then
            if ped:GetPlayer() then
                local ped_coords = ped:GetLocation()
                local distance = player_coords:Distance(ped_coords)
                if distance <= max_distance then
                    table.insert(closest_players, ped:GetPlayer())
                end
            end
        end
    end
    return closest_players
end

function QBCore.Functions.GetClosestHCharacter(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local players = HCharacter.GetAll()
    local closest_hcharacter, closest_distance = nil, -1
    for i = 1, #players do
        local ped = players[i]
        if ped ~= player_ped then
            local ped_coords = ped:GetLocation()
            local distance = player_coords:Distance(ped_coords)
            if closest_distance == -1 or distance < closest_distance then
                closest_hcharacter = ped
                closest_distance = distance
            end
        end
    end
    return closest_hcharacter, closest_distance
end

function QBCore.Functions.GetClosestVehicle(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local vehicles = Vehicle.GetAll()
    local closest_vehicle, closest_distance = nil, -1
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehicle_coords = vehicle:GetLocation()
        local distance = player_coords:Distance(vehicle_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_vehicle = vehicle
            closest_distance = distance
        end
    end
    return closest_vehicle, closest_distance
end

function QBCore.Functions.GetClosestHVehicle(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local vehicles = HSimpleVehicle.GetAll()
    local closest_hvehicle, closest_distance = nil, -1
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehicle_coords = vehicle:GetLocation()
        local distance = player_coords:Distance(vehicle_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_hvehicle = vehicle
            closest_distance = distance
        end
    end
    return closest_hvehicle, closest_distance
end

function QBCore.Functions.GetClosestWeapon(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local weapons = Weapon.GetAll()
    local closest_weapon, closest_distance = nil, -1
    for i = 1, #weapons do
        local weapon = weapons[i]
        local weapon_coords = weapon:GetLocation()
        local distance = player_coords:Distance(weapon_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_weapon = weapon
            closest_distance = distance
        end
    end
    return closest_weapon, closest_distance
end

function QBCore.Functions.GetClosestCharacter(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local characters = Character.GetAll()
    local closest_character, closest_distance = nil, -1
    for i = 1, #characters do
        local ped = characters[i]
        local ped_coords = ped:GetLocation()
        local distance = player_coords:Distance(ped_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_character = ped
            closest_distance = distance
        end
    end
    return closest_character, closest_distance
end

function QBCore.Functions.GetClosestSCharacter(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local characters = CharacterSimple.GetAll()
    local closest_charactersimple, closest_distance = nil, -1
    for i = 1, #characters do
        local ped = characters[i]
        local ped_coords = ped:GetLocation()
        local distance = player_coords:Distance(ped_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_charactersimple = ped
            closest_distance = distance
        end
    end
    return closest_charactersimple, closest_distance
end

function QBCore.Functions.GetClosestPawn(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local characters = HPawn.GetAll()
    local closest_pawn, closest_distance = nil, -1
    for i = 1, #characters do
        local ped = characters[i]
        local ped_coords = ped:GetLocation()
        local distance = player_coords:Distance(ped_coords)
        if closest_distance == -1 or distance < closest_distance then
            closest_pawn = ped
            closest_distance = distance
        end
    end
    return closest_pawn, closest_distance
end

function QBCore.Functions.GetClosestProp(coords)
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = coords or player_ped:GetLocation()
    local props = Prop.GetAll()
    local closest_prop, closest_distance = nil, -1
    for i = 1, #props do
        local prop = props[i]
        local prop_ooords = prop:GetLocation()
        local distance = player_coords:Distance(prop_ooords)
        if closest_distance == -1 or distance < closest_distance then
            closest_prop = prop
            closest_distance = distance
        end
    end
    return closest_prop, closest_distance
end

for functionName, func in pairs(QBCore.Functions) do
    if type(func) == 'function' then
        exports('qb-core', functionName, func)
    end
end
