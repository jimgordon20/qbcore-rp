local Objects = {}

local function GetPlacePosition(player)
    local character = player:GetControlledCharacter()
    if not character then return end
    local rotation = character:GetRotation()
    if not rotation then return end
    local location = character:GetLocation()
    if not location then return end
    local forward = rotation:GetForwardVector()
    local place_position = location + forward * 200
    place_position.z = location.z
    return place_position
end

Events.SubscribeRemote('qb-policejob:server:spawnCone', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:spawnBarrier', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:spawnRoadSign', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:spawnTent', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:spawnLight', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:SpawnSpikeStrip', function(source)
    local place_position = GetPlacePosition(source)
    local police_object = Prop(place_position, Rotator(), 'abcca-qbcore::SM_Trash', CollisionType.Normal, true, GrabMode.Disabled)
    Objects[#Objects + 1] = police_object
end)

Events.SubscribeRemote('qb-policejob:server:deleteObject', function(source)
    local character = source:GetControlledCharacter()
    if not character then return end
    local location = character:GetLocation()
    if not location then return end
    for i = 1, #Objects do
        local object = Objects[i]
        if object then
            local object_location = object:GetLocation()
            if object_location then
                local distance = object_location:Distance(location)
                if distance < 200 then
                    object:Destroy()
                    Objects[i] = nil
                end
            end
        end
    end
end)

-- Spikes

-- Events.SubscribeRemote('qb-policejob:server:SyncSpikes', function(source, table)
--     Events.BroadcastRemote('qb-policejob:client:SyncSpikes', table)
-- end)
