-- Drink

Events.Subscribe('qb-smallresources:server:drink', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local ped_location = ped:GetLocation()
    local drink_prop = Prop(ped_location, Rotator(0, 0, 0), 'nanos-world::SM_Bread_Dount_01', CollisionType.Auto)
    drink_prop:AttachTo(ped, AttachmentRule.SnapToTarget, 'middle_02_r', 0)
    ped:PlayAnimation('nanos-world::A_Mannequin_Take_Drink', AnimationSlotType.UpperBody)
    local add_amount = Config.Consumables.drink[item]
    local current_amount = Player.PlayerData.metadata.thirst
    local new_amount = current_amount + add_amount
    if new_amount > 100 then new_amount = 100 end
    Player.Functions.SetMetaData('thirst', new_amount)
    Timer.SetTimeout(function()
        drink_prop:Detach()
        drink_prop:Destroy()
    end, 5000)
end)

-- Eat

Events.Subscribe('qb-smallresources:server:eat', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local ped_location = ped:GetLocation()
    local food_prop = Prop(ped_location, Rotator(0, 0, 0), 'nanos-world::SM_Fruit_Apple_01', CollisionType.Auto)
    food_prop:AttachTo(ped, AttachmentRule.SnapToTarget, 'middle_02_r', 0)
    ped:PlayAnimation('nanos-world::A_Mannequin_Take_Drink', AnimationSlotType.UpperBody)
    local add_amount = Config.Consumables.eat[item]
    local current_amount = Player.PlayerData.metadata.hunger
    local new_amount = current_amount + add_amount
    if new_amount > 100 then new_amount = 100 end
    Player.Functions.SetMetaData('hunger', new_amount)
    Timer.SetTimeout(function()
        food_prop:Detach()
        food_prop:Destroy()
    end, 5000)
end)

-- Alcohol

Events.Subscribe('qb-smallresources:server:alcohol', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local ped_location = ped:GetLocation()
    local alcohol_prop = Prop(ped_location, Rotator(0, 0, 0), 'nanos-world::SM_Bread_Dount_01', CollisionType.Auto)
    alcohol_prop:AttachTo(ped, AttachmentRule.SnapToTarget, 'middle_02_r', 0)
    ped:PlayAnimation('nanos-world::A_Mannequin_Take_Drink', AnimationSlotType.UpperBody)
    local add_amount = Config.Consumables.alcohol[item]
    local current_amount = Player.PlayerData.metadata.thirst
    local new_amount = current_amount + add_amount
    if new_amount > 100 then new_amount = 100 end
    Player.Functions.SetMetaData('thirst', new_amount)
    Timer.SetTimeout(function()
        alcohol_prop:Detach()
        alcohol_prop:Destroy()
    end, 5000)
end)

-- Point

Events.SubscribeRemote('qb-smallresources:server:point', function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    ped:PlayAnimation('nanos-world::A_Mannequin_Taunt_Point', AnimationSlotType.UpperBody)
end)

-- Items

for k in pairs(Config.Consumables.eat) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not RemoveItem(source, item.name, 1, item.slot, 'qb-smallresources:consumables:eat') then return end
        Events.Call('qb-smallresources:server:eat', source, item.name)
        Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item.name], 'remove')
    end)
end

for k in pairs(Config.Consumables.drink) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not RemoveItem(source, item.name, 1, item.slot, 'qb-smallresources:consumables:drink') then return end
        Events.Call('qb-smallresources:server:drink', source, item.name)
        Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item.name], 'remove')
    end)
end

for k, _ in pairs(Config.Consumables.alcohol) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not RemoveItem(source, item.name, 1, item.slot, 'qb-smallresources:consumables:alcohol') then return end
        Events.Call('qb-smallresources:server:alcohol', source, item.name)
        Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item.name], 'remove')
    end)
end

QBCore.Functions.CreateUseableItem('armor', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not RemoveItem(source, 'armor', 1, false, 'consumables:server:useArmor') then return end
    local armor = Player.PlayerData.metadata.armor
    if armor + 50 > 100 then armor = 100 else armor = armor + 50 end
    Player.Functions.SetMetaData('armor', armor)
end)

QBCore.Functions.CreateUseableItem('heavyarmor', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not RemoveItem(source, 'heavyarmor', 1, false, 'consumables:server:useHeavyArmor') then return end
    Player.Functions.SetMetaData('armor', 100)
end)

-- AFK

Events.SubscribeRemote('qb-smallresources:server:afk', function(source)
    source:Kick('AFK')
end)

-- Crouching

-- HCharacter.Subscribe('StanceModeChange', function(self, old_state, new_state)
--     print('StanceModeChange', old_state, new_state)
--     if new_state == StanceMode.Crouching then
--         self:SetFootstepVolumeMultiplier(0.5)
--     else
--         self:SetFootstepVolumeMultiplier(1)
--     end
-- end)

-- Dynamic Weather/Time

local timeFrozen = false
local current_hour, current_minute = math.random(0, 23), math.random(0, 59)
local current_weather = Config.Weather.default_weather

Events.Subscribe('QBCore:Server:PlayerLoaded', function(Player)
    Events.CallRemote('qb-smallresources:client:spawnSky', Player.PlayerData.source, current_weather, current_hour, current_minute)
end)

local function changeWeather()
    local weather_types = Config.Weather.available_types
    local weather = {}
    for weather_type in pairs(weather_types) do table.insert(weather, weather_type) end
    local index = math.random(#weather)
    local weather_value = weather[index]
    local selected_weather = weather_types[weather_value]
    current_weather = selected_weather
    Events.BroadcastRemote('qb-smallresources:client:changeWeather', selected_weather)
end

if Config.Weather.dynamic then
    Timer.SetInterval(changeWeather, Config.Weather.update_interval * 60000)
end

local function syncTime()
    if timeFrozen then return end
    local totalMinutes = current_hour * 60 + current_minute
    totalMinutes = (totalMinutes + Config.Time.multiplier) % (24 * 60)
    current_hour = math.floor(totalMinutes / 60) % 24
    current_minute = totalMinutes % 60
    Events.BroadcastRemote('qb-smallresources:client:changeTime', current_hour, current_minute)
end

if Config.Time.synced then
    Timer.SetInterval(syncTime, 60000)
end

QBCore.Commands.Add('weather', 'Change weather', { { name = 'weather', help = 'Weather type' } }, true, function(source, args)
    local weather = args[1]
    local weather_type = Config.Weather.available_types[weather]
    if not weather_type then return end
    current_weather = weather_type
    Events.BroadcastRemote('qb-smallresources:client:changeWeather', weather_type)
    Events.CallRemote('QBCore:Notify', source, 'Weather changed to: ' .. weather)
end, 'admin')

QBCore.Commands.Add('time', 'Change time', { { name = 'weather', help = 'Weather type' } }, true, function(source, args)
    local time1 = tonumber(args[1])
    local time2 = tonumber(args[2]) or 0
    if time1 > 23 or time1 < 0 or time2 > 59 or time2 < 0 then return end
    current_hour, current_minute = time1, time2
    Events.BroadcastRemote('qb-smallresources:client:changeTime', time1, time2)
    Events.CallRemote('QBCore:Notify', source, 'Time changed to: ' .. time1 .. ':' .. time2)
end, 'admin')

QBCore.Commands.Add('freezetime', 'Freeze or unfreeze time', {}, false, function(source)
    timeFrozen = not timeFrozen
    local status = timeFrozen and 'frozen' or 'unfrozen'
    Events.CallRemote('QBCore:Notify', source, 'Time has been ' .. status)
end, 'admin')

-- Out of Map TP

Events.SubscribeRemote('qb-smallresources:server:mapTp', function(source, zIndex)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local pedCoords = ped:GetLocation()
    if pedCoords.Z > -10000 then return end

    ped:SetLocation(Vector(pedCoords.X, pedCoords.Y, pedCoords.Z + zIndex + 1000))
end)

-- Vehicle Cleanup

Player.Subscribe('Destroy', function()
    if Player.GetCount() - 1 > 0 then return end

    for _, vehicle in pairs(HSimpleVehicle.GetAll()) do
        if vehicle:IsValid() then
            vehicle:Destroy()
        end
    end
end)