local Objects = {}

local function CreateObjectId()
    if Objects then
        local objectId = math.random(10000, 99999)
        while Objects[objectId] do
            objectId = math.random(10000, 99999)
        end
        return objectId
    else
        local objectId = math.random(10000, 99999)
        return objectId
    end
end

Events.SubscribeRemote('qb-policejob:server:spawnObject', function(source, type)
    local objectId = CreateObjectId()
    Objects[objectId] = type
    Events.CallRemote('qb-policejob:client:spawnObject', source, objectId, type, source)
end)

Events.SubscribeRemote('qb-policejob:server:deleteObject', function(objectId)
    Events.BroadcastRemote('qb-policejob:client:removeObject', objectId)
end)

Events.SubscribeRemote('qb-policejob:server:SyncSpikes', function(source, table)
    Events.BroadcastRemote('qb-policejob:client:SyncSpikes', table)
end)
