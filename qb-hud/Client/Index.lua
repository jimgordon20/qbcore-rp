local isLoggedIn = false
local my_webui = nil
local player_data = {}
local round = math.floor

-- Timer.SetTimeout(function()
--     my_webui = WebUI('HUD', 'qb-inventory/Client/html/index.html')
-- end, 2000)
-- local player_data = exports['qb-core']:GetPlayerData()
-- local in_vehicle, current_vehicle = false, nil
-- local has_weapon, current_weapon = false, nil
-- local round = math.floor
-- local voice_level = 2
-- local voiceLevels = {
--     { level = 'whisper', radius = 1.0 },
--     { level = 'normal',  radius = 2.5 },
--     { level = 'shout',   radius = 5.0 }
-- }

-- -- Function

-- local function updateVoiceLevel()
--     local player = Client.GetLocalPlayer()
--     if not player then return end
--     player:SetVOIPSetting(VOIPSetting.Global)
--     local voiceSetting = voiceLevels[voice_level]
--     player:SetVOIPVolume(voiceSetting.radius)
--     my_webui:CallFunction('UpdateVoiceVolume', voiceSetting.radius)
-- end

-- local function GetWeaponAmmo(weapon)
--     local ammo_clip = weapon:GetAmmoClip()
--     local ammo_bag = weapon:GetAmmoBag()
--     return ammo_clip, ammo_bag
-- end

-- -- Event Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    player_data = exports['qb-core']:GetPlayerData()
    --updateVoiceLevel()
    my_webui = WebUI('qb-hud', 'qb-hud/Client/html/index.html', 2)
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    player_data = {}
end)

RegisterClientEvent('QBCore:Player:SetPlayerData', function(val)
    player_data = val
end)

-- -- Money HUD

RegisterClientEvent('qb-hud:client:ShowAccounts', function(type, amount)
    if not my_webui then return end
    if type == 'cash' then
        my_webui:CallFunction('ShowCashAmount', round(amount))
    else
        my_webui:CallFunction('ShowBankAmount', round(amount))
    end
end)

RegisterClientEvent('qb-hud:client:OnMoneyChange', function(type, amount, isMinus)
    if not my_webui then return end
    local cashAmount = player_data.money['cash']
    local bankAmount = player_data.money['bank']
    my_webui:CallFunction('UpdateMoney', round(cashAmount), round(bankAmount), round(amount), isMinus, type)
end)

-- -- Voice

-- -- Player.Subscribe('VOIP', function(self, is_talking)
-- --     if self ~= Client.GetLocalPlayer() then return end
-- --     print('VOIP', is_talking)
-- --     my_webui:CallFunction('IsTalking', is_talking)
-- -- end)

-- -- Input.Register('Voice Level', 'Q')
-- -- Input.Bind('Voice Level', InputEvent.Pressed, function() -- whisper, normal, shout
-- --     if Input.IsMouseEnabled() then return end
-- --     voice_level = voice_level % #voiceLevels + 1
-- --     updateVoiceLevel()
-- -- end)

-- HUD Thread

Timer.SetInterval(function()
    if not isLoggedIn then return end
    local ped = HPlayer:K2_GetPawn()
    if not ped then return end
    local health     = ped.HealthComponent:GetHealth()
    local armor      = player_data.metadata['armor']
    local hunger     = player_data.metadata['hunger']
    local thirst     = player_data.metadata['thirst']
    local stress     = player_data.metadata['stress']
    local playerDead = player_data.metadata['inlaststand'] or player_data.metadata['isdead'] or false

    if my_webui then
        my_webui:CallFunction('UpdateHUD', health, armor, hunger, thirst, stress, playerDead)
    end
end, 1000)

-- -- Timer.SetInterval(function()
-- --     if Client.GetValue('isLoggedIn', false) then
-- --         local player = Client.GetLocalPlayer()
-- --         local ped = player:GetControlledCharacter()
-- --         if not ped then return end
-- --         local health     = ped:GetHealth()
-- --         local armor      = player_data.metadata['armor']
-- --         local hunger     = player_data.metadata['hunger']
-- --         local thirst     = player_data.metadata['thirst']
-- --         local stress     = player_data.metadata['stress']
-- --         local playerDead = player_data.metadata['inlaststand'] or player_data.metadata['isdead'] or false
-- --         if in_vehicle and current_vehicle and current_vehicle:IsValid() then
-- --             local vehicle_health = current_vehicle:GetHealth()
-- --             local vehicle_max_health = current_vehicle:GetMaxHealth()
-- --             local vehicle_speed = current_vehicle:GetVehicleSpeed()
-- --             local vehicle_acceleration = current_vehicle:GetVehicleAcceleration()
-- --             local vehicle_rpm = current_vehicle:GetVehicleRPM()
-- --             local vehicle_gear = current_vehicle:GetVehicleGear()
-- --             if Config.UseMPH then vehicle_speed = vehicle_speed * 0.621371 end
-- --             if vehicle_speed < 0 then
-- --                 vehicle_speed = 0
-- --                 vehicle_gear = 'R'
-- --             end
-- --             local vehicle_fuel = current_vehicle:GetValue('fuel', 100)
-- --             my_webui:CallFunction('UpdateVehicleStats', vehicle_speed, vehicle_fuel, vehicle_health, vehicle_max_health, vehicle_acceleration, vehicle_rpm, vehicle_gear)
-- --         end
-- --         if has_weapon and current_weapon then
-- --             local ammo_clip, ammo_bag = GetWeaponAmmo(current_weapon)
-- --             my_webui:CallFunction('UpdateWeaponAmmo', ammo_clip, ammo_bag)
-- --         end
-- --         my_webui:CallFunction('UpdateHUD', health, armor, hunger, thirst, stress, playerDead)
-- --     end
-- -- end, 100)

-- -- Weapons

-- -- HCharacter.Subscribe('Reload', function(self, weapon)
-- --     local player = Client.GetLocalPlayer()
-- --     local ped = player:GetControlledCharacter()
-- --     if ped ~= self then return end
-- --     local ammo_clip, ammo_bag = GetWeaponAmmo(weapon)
-- --     my_webui:CallFunction('UpdateWeaponAmmo', ammo_clip, ammo_bag)
-- -- end)

-- -- HCharacter.Subscribe('PickUp', function(self, object)
-- --     local player = Client.GetLocalPlayer()
-- --     local ped = player:GetControlledCharacter()
-- --     if ped ~= self then return end
-- --     if object:IsA(Weapon) then
-- --         has_weapon = true
-- --         current_weapon = object
-- --         my_webui:CallFunction('ShowWeapon', true)
-- --         local ammo_clip, ammo_bag = GetWeaponAmmo(object)
-- --         my_webui:CallFunction('UpdateWeaponAmmo', ammo_clip, ammo_bag)
-- --     end
-- -- end)

-- -- HCharacter.Subscribe('Drop', function(self, object)
-- --     local player = Client.GetLocalPlayer()
-- --     local ped = player:GetControlledCharacter()
-- --     if ped ~= self then return end
-- --     if object:IsA(Weapon) then
-- --         has_weapon = false
-- --         current_weapon = nil
-- --         my_webui:CallFunction('ShowWeapon', false)
-- --     end
-- -- end)

-- -- HCharacter.Subscribe('Fire', function(self, weapon)
-- --     local player = Client.GetLocalPlayer()
-- --     local ped = player:GetControlledCharacter()
-- --     if ped ~= self then return end
-- --     local ammo_clip, ammo_bag = GetWeaponAmmo(weapon)
-- --     my_webui:CallFunction('UpdateWeaponAmmo', ammo_clip, ammo_bag)
-- -- end)

-- -- Vehicles

-- -- HCharacter.Subscribe('ValueChange', function(self, state, value)
-- --     local player = Client.GetLocalPlayer()
-- --     local ped = player:GetControlledCharacter()
-- --     if ped ~= self then return end
-- --     if state == 'in_vehicle' then
-- --         in_vehicle = value
-- --         if value then
-- --             my_webui:CallFunction('ShowSpeedometer', true)
-- --         else
-- --             my_webui:CallFunction('ShowSpeedometer', false)
-- --         end
-- --     end
-- --     if state == 'current_vehicle' then
-- --         current_vehicle = value
-- --     end
-- -- end)

-- RegisterClientEvent('qb-hud:client:fixVehicle', function()
--     if in_vehicle and current_vehicle then
--         TriggerServerEvent('qb-hud:server:fixVehicle', current_vehicle)
--     end
-- end)

-- -- Input.Subscribe('KeyPress', function(key_name)
-- --     if key_name == 'E' then
-- --         if not in_vehicle then
-- --             local vehicle, distance = exports['qb-core']:GetClosestHVehicle()
-- --             if vehicle and distance < 300 then
-- --                 local current_passengers = vehicle:NumOfCurrentPassanger()
-- --                 local allowed_passengers = vehicle:NumOfAllowedPassanger()
-- --                 if current_passengers >= allowed_passengers then return end
-- --                 TriggerServerEvent('qb-hud:server:enterVehicle', vehicle)
-- --             end
-- --         else
-- --             if current_vehicle and current_vehicle:IsValid() then
-- --                 TriggerServerEvent('qb-hud:server:leaveVehicle', current_vehicle)
-- --             end
-- --         end
-- --     end
-- -- end)
