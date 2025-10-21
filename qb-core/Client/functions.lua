QBCore.Functions = {}
local my_webui = WebUI('qb-core', 'qb-core/Client/html/index.html', 0)

-- Getter Functions

function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

-- Functions

function QBCore.Functions.Debug(tbl)
    print(HELIXTable.Dump(tbl))
end

-- UI

function QBCore.Functions.HideText()
    if not my_webui then return end
    my_webui:SendEvent('hideText')
    my_webui:SetInputMode(0)
end

function QBCore.Functions.DrawText(text, position)
    if not my_webui then return end
    if type(position) ~= 'string' then position = 'left' end
    my_webui:SendEvent('drawText', text, position)
end

function QBCore.Functions.ChangeText(text, position)
    if not my_webui then return end
    if type(position) ~= 'string' then position = 'left' end
    my_webui:SendEvent('changeText', text, position)
end

function QBCore.Functions.KeyPressed()
    if not my_webui then return end
    my_webui:SendEvent('keyPressed')
    QBCore.Functions.HideText()
end

function QBCore.Functions.Notify(text, texttype, length, icon)
    if not my_webui then return end
    local noti_type = texttype or 'primary'
    if type(text) == 'table' then
        my_webui:SendEvent('showNotif', {
            text = text.text,
            length = length or 5000,
            type = noti_type,
            caption = text.caption or '',
            icon = icon or nil
        })
    else
        my_webui:SendEvent('showNotif', {
            text = text,
            length = length or 5000,
            type = noti_type,
            caption = '',
            icon = icon or nil
        })
    end
end

-- World Getters

function QBCore.Functions.GetClosestPlayer(coords)
    local player_ped = HPlayer:K2_GetPawn()
    if not player_ped then return end
    local player_coords = coords or player_ped:K2_GetActorLocation()
    local hits = Trace:SphereMulti(player_coords, player_coords, 1000) -- Add my pawn to ignore list?
    local closest_player, closest_distance = nil, -1
    for k, v in pairs(hits) do
        local distance = hit.Distance
        if closest_distance == -1 or distance < closest_distance then
            local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
            if hitActor:IsA(UE.AHCharacter) then
                if hitActor:IsPlayerControlled() then
                    closest_player = hitActor:GetController() -- On client?
                    closest_distance = distance
                end
            end
        end
    end
    return closest_player, closest_distance
end

function QBCore.Functions.GetClosestNPC(coords)
    local player_ped = HPlayer:K2_GetPawn()
    if not player_ped then return end
    local player_coords = coords or player_ped:K2_GetActorLocation()
    local hits = Trace:SphereMulti(player_coords, player_coords, 1000)
    local closest_npc, closest_distance = nil, -1
    for k, v in pairs(hits) do
        local distance = hit.Distance
        if closest_distance == -1 or distance < closest_distance then
            local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
            if hitActor:IsA(UE.AHelixAICharacter) then
                closest_npc = hitActor
                closest_distance = distance
            end
        end
    end
    return closest_npc, closest_distance
end

function QBCore.Functions.GetClosestVehicle(coords)
    local player_ped = HPlayer:K2_GetPawn()
    if not player_ped then return end
    local player_coords = coords or player_ped:K2_GetActorLocation()
    local hits = Trace:SphereMulti(player_coords, player_coords, 1000)
    local closest_vehicle, closest_distance = nil, -1
    for k, v in pairs(hits) do
        local distance = hit.Distance
        if closest_distance == -1 or distance < closest_distance then
            local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
            if hitActor:IsA(UE.AMMVehiclePawn) then
                if hitActor then
                    closest_vehicle = hitActor
                    closest_distance = distance
                end
            end
        end
    end
    return closest_vehicle, closest_distance
end

function QBCore.Functions.GetClosestWeapon(coords)
    local player_ped = HPlayer:K2_GetPawn()
    if not player_ped then return end
    local player_coords = coords or player_ped:K2_GetActorLocation()
    local hits = Trace:SphereMulti(player_coords, player_coords, 1000)
    local closest_weapon, closest_distance = nil, -1
    for k, v in pairs(hits) do
        local distance = hit.Distance
        if closest_distance == -1 or distance < closest_distance then
            local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
            if hitActor:IsA(UE.BWeapon) then
                closest_weapon = hitActor
                closest_distance = distance
            end
        end
    end
    return closest_weapon, closest_distance
end

function QBCore.Functions.GetClosestObject(coords)

end

for functionName, func in pairs(QBCore.Functions) do
    if type(func) == 'function' then
        exports('qb-core', functionName, func)
    end
end
