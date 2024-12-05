local isEscorting = false

-- Functions

Package.Export('IsHandcuffed', function()
    return isHandcuffed
end)

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
    end
end

local function IsTargetDead(playerId)
    local retval = false
    QBCore.Functions.TriggerCallback('police:server:isPlayerDead', function(result)
        retval = result
    end, playerId)
    return retval
end

local function HandCuffAnimation()
    local ped = PlayerPedId()
    if isHandcuffed == true then
        Events.CallRemote('InteractSound_SV:PlayOnSource', 'Cuff', 0.2)
    else
        Events.CallRemote('InteractSound_SV:PlayOnSource', 'Uncuff', 0.2)
    end
    loadAnimDict('mp_arrest_paired')
    TaskPlayAnim(ped, 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    Events.CallRemote('InteractSound_SV:PlayOnSource', 'Cuff', 0.2)
    TaskPlayAnim(ped, 'mp_arrest_paired', 'exit', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
end

local function GetCuffedAnimation(playerId)
    local ped = PlayerPedId()
    local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
    local heading = GetEntityHeading(cuffer)
    Events.CallRemote('InteractSound_SV:PlayOnSource', 'Cuff', 0.2)
    loadAnimDict('mp_arrest_paired')
    SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))
    SetEntityHeading(ped, heading)
    TaskPlayAnim(ped, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, 0, 0, 0, true, true, true)
end

-- Events

Events.SubscribeRemote('police:client:SetOutVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        TaskLeaveVehicle(ped, vehicle, 16)
    end
end)

Events.SubscribeRemote('police:client:PutInVehicle', function()
    local ped = PlayerPedId()
    if isHandcuffed or isEscorted then
        local vehicle = QBCore.Functions.GetClosestVehicle()
        if DoesEntityExist(vehicle) then
            for i = GetVehicleMaxNumberOfPassengers(vehicle), 0, -1 do
                if IsVehicleSeatFree(vehicle, i) then
                    isEscorted = false
                    TriggerEvent('hospital:client:isEscorted', isEscorted)
                    ClearPedTasks(ped)
                    DetachEntity(ped, true, false)
                    SetPedIntoVehicle(ped, vehicle, i)
                    return
                end
            end
        end
    end
end)

Events.SubscribeRemote('police:client:SeizeCash', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        Events.CallRemote('police:server:SeizeCash', playerId)
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:SeizeDriverLicense', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        Events.CallRemote('police:server:SeizeDriverLicense', playerId)
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:RobPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    local ped = PlayerPedId()
    if player ~= -1 and distance < 2.5 then
        local playerPed = GetPlayerPed(player)
        local playerId = GetPlayerServerId(player)
        if IsEntityPlayingAnim(playerPed, 'missminuteman_1ig_2', 'handsup_base', 3) or IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) or IsTargetDead(playerId) then
            QBCore.Functions.Progressbar('robbing_player', Lang:t('progressbar.robbing'), math.random(5000, 7000), false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'random@shop_robbery',
                anim = 'robbery_action_b',
                flags = 16,
            }, {}, {}, function()
                local plyCoords = GetEntityCoords(playerPed)
                local pos = GetEntityCoords(ped)
                if #(pos - plyCoords) < 2.5 then
                    Events.CallRemote('police:server:RobPlayer', playerId)
                else
                    QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
                end
            end)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:JailPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        local dialog = ShowInput({
            header = Lang:t('info.jail_time_input'),
            submitText = Lang:t('info.submit'),
            inputs = {
                {
                    text = Lang:t('info.time_months'),
                    name = 'jailtime',
                    type = 'number',
                    isRequired = true
                }
            }
        })
        if tonumber(dialog['jailtime']) > 0 then
            Events.CallRemote('police:server:JailPlayer', playerId, tonumber(dialog['jailtime']))
        else
            QBCore.Functions.Notify(Lang:t('error.time_higher'), 'error')
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:BillPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        local dialog = ShowInput({
            header = Lang:t('info.bill'),
            submitText = Lang:t('info.submit'),
            inputs = {
                {
                    text = Lang:t('info.amount'),
                    name = 'bill',
                    type = 'number',
                    isRequired = true
                }
            }
        })
        if tonumber(dialog['bill']) > 0 then
            Events.CallRemote('police:server:BillPlayer', playerId, tonumber(dialog['bill']))
        else
            QBCore.Functions.Notify(Lang:t('error.amount_higher'), 'error')
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:PutPlayerInVehicle', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not isHandcuffed and not isEscorted then
            Events.CallRemote('police:server:PutPlayerInVehicle', playerId)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:SetPlayerOutVehicle', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not isHandcuffed and not isEscorted then
            Events.CallRemote('police:server:SetPlayerOutVehicle', playerId)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:EscortPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not isHandcuffed and not isEscorted then
            Events.CallRemote('police:server:EscortPlayer', playerId)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:KidnapPlayer', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not IsPedInAnyVehicle(GetPlayerPed(player)) then
            if not isHandcuffed and not isEscorted then
                Events.CallRemote('police:server:KidnapPlayer', playerId)
            end
        end
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

Events.SubscribeRemote('police:client:CuffPlayerSoft', function()
    if not IsPedRagdoll(PlayerPedId()) then
        local player, distance = QBCore.Functions.GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            local playerId = GetPlayerServerId(player)
            if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(PlayerPedId()) then
                Events.CallRemote('police:server:CuffPlayer', playerId, true)
                HandCuffAnimation()
            else
                QBCore.Functions.Notify(Lang:t('error.vehicle_cuff'), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
        end
    end
end)

Events.SubscribeRemote('police:client:CuffPlayer', function()
    if not IsPedRagdoll(PlayerPedId()) then
        local player, distance = QBCore.Functions.GetClosestPlayer()
        if player ~= -1 and distance < 1.5 then
            local result = QBCore.Functions.HasItem(Config.HandCuffItem)
            if result then
                local playerId = GetPlayerServerId(player)
                if not IsPedInAnyVehicle(GetPlayerPed(player)) and not IsPedInAnyVehicle(PlayerPedId()) then
                    Events.CallRemote('police:server:CuffPlayer', playerId, false)
                    HandCuffAnimation()
                else
                    QBCore.Functions.Notify(Lang:t('error.vehicle_cuff'), 'error')
                end
            else
                QBCore.Functions.Notify(Lang:t('error.no_cuff'), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
        end
    end
end)

Events.SubscribeRemote('police:client:GetEscorted', function(playerId)
    local ped = PlayerPedId()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata['isdead'] or isHandcuffed or PlayerData.metadata['inlaststand'] then
            if not isEscorted then
                isEscorted = true
                local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
                SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(dragger, 0.0, 0.45, 0.0))
                AttachEntityToEntity(ped, dragger, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                isEscorted = false
                DetachEntity(ped, true, false)
            end
            TriggerEvent('hospital:client:isEscorted', isEscorted)
        end
    end)
end)

Events.SubscribeRemote('police:client:DeEscort', function()
    isEscorted = false
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    DetachEntity(PlayerPedId(), true, false)
end)

Events.SubscribeRemote('police:client:GetKidnappedTarget', function(playerId)
    local ped = PlayerPedId()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] or isHandcuffed then
            if not isEscorted then
                isEscorted = true
                local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
                AttachEntityToEntity(ped, dragger, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
                TaskPlayAnim(ped, 'nm', 'firemans_carry', 8.0, -8.0, 100000, 33, 0, false, false, false)
            else
                isEscorted = false
                DetachEntity(ped, true, false)
                ClearPedTasksImmediately(ped)
            end
            TriggerEvent('hospital:client:isEscorted', isEscorted)
        end
    end)
end)

Events.SubscribeRemote('police:client:GetKidnappedDragger', function()
    QBCore.Functions.GetPlayerData(function(_)
        if not isEscorting then
            local dragger = PlayerPedId()
            TaskPlayAnim(dragger, 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, 100000, 49, 0, false, false, false)
            isEscorting = true
        else
            local dragger = PlayerPedId()
            ClearPedSecondaryTask(dragger)
            ClearPedTasksImmediately(dragger)
            isEscorting = false
        end
        TriggerEvent('hospital:client:SetEscortingState', isEscorting)
        TriggerEvent('qb-kidnapping:client:SetKidnapping', isEscorting)
    end)
end)

Events.SubscribeRemote('police:client:GetCuffed', function(playerId, isSoftcuff)
    local ped = PlayerPedId()
    if not isHandcuffed then
        isHandcuffed = true
        Events.CallRemote('police:server:SetHandcuffStatus', true)
        ClearPedTasksImmediately(ped)
        if GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        end
        if not isSoftcuff then
            cuffType = 16
            GetCuffedAnimation(playerId)
            QBCore.Functions.Notify(Lang:t('info.cuff'), 'primary')
        else
            cuffType = 49
            GetCuffedAnimation(playerId)
            QBCore.Functions.Notify(Lang:t('info.cuffed_walk'), 'primary')
        end
    else
        isHandcuffed = false
        isEscorted = false
        TriggerEvent('hospital:client:isEscorted', isEscorted)
        DetachEntity(ped, true, false)
        Events.CallRemote('police:server:SetHandcuffStatus', false)
        ClearPedTasksImmediately(ped)
        Events.CallRemote('InteractSound_SV:PlayOnSource', 'Uncuff', 0.2)
        QBCore.Functions.Notify(Lang:t('success.uncuffed'), 'success')
    end
end)

-- Threads

Timer.SetInterval(function()
    if isEscorted or isHandcuffed then
        Input.SetInputEnabled(false)
    end
end, 100)
