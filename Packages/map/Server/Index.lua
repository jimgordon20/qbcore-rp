Package.Require('../Shared/Index.lua')

local function GenerateBlipId()
    local id = math.random(1, 1000)
    for _, blip in ipairs(Config.MapBlips) do
        if blip.id == id then
            return GenerateBlipId()
        end
    end
    return id
end

Events.SubscribeRemote('Map:Server:TeleportPlayer', function(source, x, y)
    if not source then return end
    local character = source:GetControlledCharacter()
    if not character then return end
    character:SetLocation(Vector(x, y, 0))
end)

Events.SubscribeRemote('Map:Server:AddBlip', function(source, blipData)
    if not blipData then return end
    if not blipData.id then
        blipData.id = GenerateBlipId()
    end
    table.insert(Config.MapBlips, blipData)
    Events.BroadcastRemote('Map:UpdateAllBlips', Config.MapBlips)
    return blipData.id
end)

Events.SubscribeRemote('Map:Server:RemoveBlip', function(source, blipId)
    for i, b in ipairs(Config.MapBlips) do
        if b.id == blipId then
            table.remove(Config.MapBlips, i)
            break
        end
    end
    Events.BroadcastRemote('Map:UpdateAllBlips', Config.MapBlips)
end)

Server.Subscribe('Tick', function(delta_time)
    local playerBlips = {}
    for _, p in pairs(Player.GetAll()) do
        local character = p:GetControlledCharacter()

        if character then
            local loc = character:GetLocation()
            table.insert(playerBlips, { id = p:GetAccountID(), x = loc.X, y = loc.Y })
        end
    end
    Events.BroadcastRemote('Map:UpdatePlayersPos', playerBlips)
end)
