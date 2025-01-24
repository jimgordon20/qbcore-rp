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

Events.SubscribeRemote('Map:Server:TeleportPlayer', function(source, coords)
    if not source then return end
    local character = source:GetControlledCharacter()
    if not character then return end
    source:UnPossess()
    character:Destroy()
    source:SetCameraLocation(coords)
    Timer.SetTimeout(function()
        local newChar = HCharacter(coords, Rotator(0, 0, 0), source)
        source:Possess(newChar)
    end, 2000)
end)

Events.SubscribeRemote('Map:Server:AddBlip', function(_, blipData)
    if not blipData then return end
    if not blipData.id then
        blipData.id = GenerateBlipId()
    end
    table.insert(Config.MapBlips, blipData)
    Events.BroadcastRemote('Map:UpdateAllBlips', Config.MapBlips)
    return blipData.id
end)

Events.SubscribeRemote('Map:Server:RemoveBlip', function(_, blipId)
    for i, b in ipairs(Config.MapBlips) do
        if b.id == blipId then
            table.remove(Config.MapBlips, i)
            break
        end
    end
    Events.BroadcastRemote('Map:UpdateAllBlips', Config.MapBlips)
end)

Server.Subscribe('Tick', function()
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
