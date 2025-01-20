-- Discord

if Config.Discord.enable then
    Discord.Initialize(Config.Discord.application_id)
    Discord.SetActivity(Config.Discord.server_name, Config.Discord.details, Config.Discord.large_image, Config.Discord.large_text)
end

-- Point

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'B' then
        Events.CallRemote('qb-smallresources:server:point')
    end
end)

-- Weather

Events.SubscribeRemote('qb-smallresources:client:spawnSky', function(current_weather, hours, minutes)
    if not Sky.IsSpawned(false) then Sky.Spawn(true) end
    Sky.ChangeWeather(current_weather, 0)
    Sky.SetTimeOfDay(hours, minutes)
    if Config.Time.synced then Sky.SetAnimateTimeOfDay(false) end
end)

Events.SubscribeRemote('qb-smallresources:client:changeTime', function(hours, minutes)
    Sky.SetTimeOfDay(hours, minutes)
end)

Events.SubscribeRemote('qb-smallresources:client:changeWeather', function(weather)
    Sky.ChangeWeather(weather, 25.0)
end)

-- Time

Events.SubscribeRemote('qb-smallresources:client:changeTime', function(hour, minute)
    Sky.SetTimeOfDay(hour, minute)
end)

-- AFK Timer

if Config.AFK.enable then
    local last_location = nil
    local warning_count = 0
    Timer.SetInterval(function()
        local ped = Client.GetLocalPlayer():GetControlledCharacter()
        if not ped then return end
        local location = ped:GetLocation()
        if not last_location then
            last_location = location
            return
        end
        local distance = #(location - last_location)
        if distance > 20 then
            last_location = location
        else
            warning_count = warning_count + 1
            if warning_count < Config.AFK.warnings_to_kick then
                QBCore.Functions.Notify('You are AFK, you will be kicked soon', 'error')
            elseif warning_count >= Config.AFK.warnings_to_kick then
                Events.CallRemote('qb-smallresources:server:afk')
            end
        end
    end, Config.AFK.timer * 1000 * 60)
end

-- Out of Map TP

Timer.SetInterval(function()
    local ped = Client.GetLocalPlayer():GetControlledCharacter()
    if not ped then return end
    
    local pedLocation = ped:GetLocation()
    local zIndex = 1000
    local traceFinal = Vector(pedLocation.X, pedLocation.Y, pedLocation.Z + zIndex)
    local trace = Trace.LineSingle(pedLocation, traceFinal, CollisionChannel.WorldStatic)
    
    while not trace.Success do
        zIndex = zIndex + 1000
        trace = Trace.LineSingle(pedLocation, Vector(pedLocation.X, pedLocation.Y, pedLocation.Z + zIndex), CollisionChannel.WorldStatic)
        if trace.Success then
            break
        end

        if zIndex == 200000 then
            break
        end
    end

    if trace.Success then Events.CallRemote('qb-smallresources:server:mapTp', zIndex) end
end, 8000)