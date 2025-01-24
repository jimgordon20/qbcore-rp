QBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local cashamount = Player.PlayerData.money.cash
    Events.CallRemote('qb-hud:client:ShowAccounts', source, 'cash', cashamount)
end, 'user')

QBCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local bankamount = Player.PlayerData.money.bank
    Events.CallRemote('qb-hud:client:ShowAccounts', source, 'bank', bankamount)
end, 'user')

QBCore.Commands.Add('fix', 'Fix Vehicle', {}, false, function(source)
    Events.CallRemote('qb-hud:client:fixVehicle', source)
end, 'admin')

Player.Subscribe('Ready', function(self)
    self:AddVOIPChannel(1)
end)

-- Events

Events.SubscribeRemote('qb-hud:server:enterVehicle', function(source, vehicle)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local seatIndex = -1
    for i = 0, vehicle:NumOfAllowedPassanger() do
        if not vehicle:GetValue('seat_taken_' .. i) then
            seatIndex = i
            break
        end
    end
    ped:EnterVehicle(vehicle, seatIndex)
    vehicle:SetValue('seat_taken_' .. seatIndex, true)
    ped:SetValue('current_seat', seatIndex)
end)

Events.SubscribeRemote('qb-hud:server:leaveVehicle', function(source, vehicle)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    if not vehicle then return end
    local seatIndex = ped:GetValue('current_seat')
    if seatIndex then
        vehicle:SetValue('seat_taken_' .. seatIndex, false)
        ped:SetValue('current_seat', nil)
    end
    ped:LeaveVehicle()
end)

Events.SubscribeRemote('qb-hud:server:fixVehicle', function(_, vehicle)
    vehicle:SetHealth(vehicle:GetMaxHealth())
    vehicle:SetVehicleHealthState(0)
    vehicle:SetTrunkState(0)
    vehicle:SetHoodState(0)
    for i = 0, vehicle:NumOfAllowedPassanger() do
        vehicle:SetDoorState(i, 0)
    end
    for i = 1, 4 do
        vehicle:SetWheelState(i, 0)
    end
end)

Events.Subscribe('qb-hud:server:GainStress', function(source, amount)
    if Config.DisableStress then return end
    local Player = QBCore.Functions.GetPlayer(source)
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
    Player.Functions.SetMetaData('stress', newStress)
    Events.CallRemote('qb-hud:client:UpdateStress', source, newStress)
    Events.CallRemote('QBCore:Notify', source, Lang:t('notify.stress_gain'), 'error', 1500)
end)

Events.Subscribe('qb-hud:server:RelieveStress', function(source, amount)
    if Config.DisableStress then return end
    local Player = QBCore.Functions.GetPlayer(source)
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
    Player.Functions.SetMetaData('stress', newStress)
    Events.CallRemote('qb-hud:client:UpdateStress', source, newStress)
    Events.CallRemote('QBCore:Notify', source, Lang:t('notify.stress_removed'))
end)
