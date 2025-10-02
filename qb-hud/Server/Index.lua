-- QBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source)
--     local Player = exports['qb-core']:GetPlayer(source)
--     if not Player then return end
--     local cashamount = Player.PlayerData.money.cash
--     TriggerClientEvent('qb-hud:client:ShowAccounts', source, 'cash', cashamount)
-- end, 'user')

-- QBCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source)
--     local Player = exports['qb-core']:GetPlayer(source)
--     if not Player then return end
--     local bankamount = Player.PlayerData.money.bank
--     TriggerClientEvent('qb-hud:client:ShowAccounts', source, 'bank', bankamount)
-- end, 'user')

-- QBCore.Commands.Add('fix', 'Fix Vehicle', {}, false, function(source)
--     TriggerClientEvent('qb-hud:client:fixVehicle', source)
-- end, 'admin')

-- Player.Subscribe('Ready', function(self)
--     self:AddVOIPChannel(1)
-- end)

-- HCharacter.Subscribe('EnterVehicle', function(self, vehicle, seat_index)
--     self:SetValue('in_vehicle', true, true)
--     self:SetValue('current_vehicle', vehicle, true)
--     self:SetValue('current_seat', seat_index, true)
--     vehicle:SetValue('seat_taken_' .. seat_index, true, true)
-- end)

-- HCharacter.Subscribe('LeaveVehicle', function(self, vehicle)
--     local seat_index = self:GetValue('current_seat')
--     self:SetValue('in_vehicle', false, true)
--     self:SetValue('current_vehicle', nil, true)
--     self:SetValue('current_seat', nil, true)
--     vehicle:SetValue('seat_taken_' .. seat_index, false, true)
-- end)

-- Events

-- local function closestSeat(ped, vehicle)
--     local closest_door = nil
--     local closest_distance = math.huge
--     local ped_coords = ped:GetLocation()
--     local vehicle_coords = vehicle:GetLocation()
--     local door_data = vehicle:GetDoors()
--     for door_index, door_info in pairs(door_data) do
--         local door_offset = vehicle_coords + door_info.offset_location
--         local door_distance = math.abs(ped_coords:Distance(door_offset))
--         if (not closest_door or door_distance < closest_distance) and door_distance <= door_info.sphere_radius * 3 then
--             closest_door = door_index
--             closest_distance = door_distance
--         end
--     end
--     if closest_door then
--         return door_data[closest_door].seat_index
--     end
--     return nil
-- end

-- RegisterServerEvent('qb-hud:server:enterVehicle', function(source, vehicle)
--     local ped = source:K2_GetPawn()
--     if not ped then return end
--     local seat_index = closestSeat(ped, vehicle)
--     print('seat index', seat_index)
--     if not seat_index then return end
--     if vehicle:GetValue('seat_taken_' .. seat_index, false) then return end
--     ped:EnterVehicle(vehicle, seat_index)
-- end)

-- RegisterServerEvent('qb-hud:server:leaveVehicle', function(source, vehicle)
--     local ped = source:K2_GetPawn()
--     if not ped then return end
--     if not vehicle then return end
--     ped:LeaveVehicle()
-- end)

-- RegisterServerEvent('qb-hud:server:fixVehicle', function(_, vehicle)
--     vehicle:SetHealth(vehicle:GetMaxHealth())
--     vehicle:SetVehicleHealthState(0)
--     vehicle:SetTrunkState(0)
--     vehicle:SetHoodState(0)
--     for i = 0, vehicle:NumOfAllowedPassanger() do
--         vehicle:SetDoorState(i, 0)
--     end
--     for i = 1, 4 do
--         vehicle:SetWheelState(i, 0)
--     end
-- end)

RegisterServerEvent('qb-hud:server:GainStress', function(source, amount)
    if Config.DisableStress then return end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Job = Player.PlayerData.job.name
    local JobType = Player.PlayerData.job.type
    local newStress
    if not Player or Config.WhitelistedJobs[JobType] or Config.WhitelistedJobs[Job] then return end
    if not ResetStress then
        if not Player.PlayerData.metadata['stress'] then
            Player.PlayerData.metadata['stress'] = 0
        end
        newStress = Player.PlayerData.metadata['stress'] + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    exports['qb-core']:Player(source, 'SetMetaData', 'stress', newStress)
    TriggerClientEvent(source, 'qb-hud:client:UpdateStress', newStress)
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('notify.stress_gain'), 'error', 1500)
end)

RegisterServerEvent('qb-hud:server:RelieveStress', function(source, amount)
    if Config.DisableStress then return end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local newStress
    if not ResetStress then
        if not Player.PlayerData.metadata['stress'] then
            Player.PlayerData.metadata['stress'] = 0
        end
        newStress = Player.PlayerData.metadata['stress'] - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    exports['qb-core']:Player(source, 'SetMetaData', 'stress', newStress)
    TriggerClientEvent(source, 'qb-hud:client:UpdateStress', newStress)
    TriggerClientEvent(source, 'QBCore:Notify', Lang:t('notify.stress_removed'))
end)
