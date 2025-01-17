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

local minimapUI = WebUI('Minimap', 'file:///UI/Minimap/index.html')

-- Add a blip to the Minimap
local function Minimap_UpdateBlips()
    minimapUI:CallEvent('SetBlips', Config.MapBlips)
end

-- Remove a blip from the Minimap
local function Minimap_RemoveBlip(blipId)
    minimapUI:CallEvent('RemoveBlip', blipId)
end

-- Update player position on the Minimap (each Tick)
Client.Subscribe('Tick', function(delta_time)
    local player = Client.GetLocalPlayer()
    if not player then return end
    local camCoords  = player:GetCameraLocation()
    local camRotator = player:GetCameraRotation()
    minimapUI:CallEvent('UpdatePlayerPos',
        camCoords.X,    -- player X
        camCoords.Y,    -- player Y
        camRotator.Yaw, -- heading
        camRotator.Yaw
    )
end)

-- Console command to toggle shape (circle or square)
Console.RegisterCommand('ToggleMinimapShape', function(args)
    if Config.Shape == 'circle' then
        Config.Shape = 'square'
    else
        Config.Shape = 'circle'
    end
    minimapUI:CallEvent('SetMinimapShape', Config.Shape)
end)

-- Initial Minimap config on package load
Package.Subscribe('Load', function()
    minimapUI:CallEvent(
        'InitMinimapData',
        Config.KnownGameCoords,
        Config.KnownImageCoords,
        Config.MaxMinimapBlipsCount
    )
    minimapUI:CallEvent('SetMinimapShape', Config.Shape)
    minimapUI:CallEvent('SetBlips', Config.MapBlips)
    minimapUI:CallEvent('SetPosition', Config.ScreenPosition)
end)

-- BIGMAP

local mapUI = WebUI('Bigmap', 'file://UI/Bigmap/index.html', WidgetVisibility.Hidden)

-- Show / Hide the big map
local function Bigmap_ToggleVisibility()
    local visibility = mapUI:GetVisibility()
    if visibility == WidgetVisibility.Hidden then
        mapUI:SetVisibility(WidgetVisibility.Visible)
        mapUI:BringToFront()
        mapUI:SetFocus()
        Input.SetInputEnabled(false)
        Input.SetMouseEnabled(true)
        mapUI:CallEvent('Map:UpdateView')
    else
        mapUI:SetVisibility(WidgetVisibility.Hidden)
        Input.SetInputEnabled(true)
        Input.SetMouseEnabled(false)
    end
end

-- Add a blip to the Bigmap (and sync with the Minimap)
local function Bigmap_AddBlip(blipData)
    if not blipData.id then
        blipData.id = GenerateBlipId()
    end

    table.insert(Config.MapBlips, blipData)
    mapUI:CallEvent('SetBlips', Config.MapBlips)

    Minimap_UpdateBlips(blipData)

    return blipData.id
end

-- Remove a blip from the Bigmap (and the Minimap)
local function Bigmap_RemoveBlip(blipId)
    mapUI:CallEvent('Map:RemoveBlip', blipId)
    Minimap_RemoveBlip(blipId)

    for i, b in ipairs(Config.MapBlips) do
        if b.id == blipId then
            table.remove(Config.MapBlips, i)
            break
        end
    end
end


-- Send coords & blips to the Bigmap UI on load
Package.Subscribe('Load', function()
    mapUI:CallEvent('Map:SetKnownCoords', Config.KnownGameCoords, Config.KnownImageCoords)
    mapUI:CallEvent('SetBlips', Config.MapBlips)
end)

-- Update player location on the Bigmap
Client.Subscribe('Tick', function(delta_time)
    local player = Client.GetLocalPlayer()
    if not player then return end
    local loc = player:GetCameraLocation()
    local heading = player:GetCameraRotation().Yaw
    mapUI:CallEvent('Map:UpdatePlayerPos', loc.X, loc.Y, heading)
end)

-- Bigmap UI subscriptions
mapUI:Subscribe('Map:AddWaypointBlip', function(x, y)
    for i = #Config.MapBlips, 1, -1 do
        local blip = Config.MapBlips[i]
        if blip.name == 'Waypoint' then
            Bigmap_RemoveBlip(blip.id)
        end
    end

    local waypointBlip = {
        id     = GenerateBlipId(),
        name   = 'Waypoint',
        coords = { x = x, y = y },
        imgUrl = './media/map-icons/marker.svg',
    }
    Bigmap_AddBlip(waypointBlip)
end)

-- Close the Bigmap
mapUI:Subscribe('Map:ExitMap', function()
    isMapVisible = false
    Bigmap_ToggleVisibility()
end)

mapUI:Subscribe('Map:TeleportToBlip', function(x, y)
    Events.CallRemote('Map:Server:TeleportPlayer', x, y)
end)

mapUI:Subscribe('Map:TogglePlayers', function(state)
    minimapUI:CallEvent('Map:TogglePlayers', state)
end)

-- Press M to toggle the Bigmap
Input.Subscribe('KeyDown', function(key_name)
    if key_name == 'M' then
        Bigmap_ToggleVisibility()
    end
end)

-- Unified remote event for adding blips

Events.Subscribe('Map:AddBlip', function(blipData)
    return Bigmap_AddBlip(blipData)
end)

Events.SubscribeRemote('Map:AddBlip', function(blipData)
    return Bigmap_AddBlip(blipData)
end)

-- Unified remote event for removing blips

Events.Subscribe('Map:RemoveBlip', function(blipId)
    Bigmap_RemoveBlip(blipId)
end)

Events.SubscribeRemote('Map:RemoveBlip', function(blipId)
    Bigmap_RemoveBlip(blipId)
end)

Events.SubscribeRemote('Map:UpdatePlayersPos', function(playerBlips)
    for i, blip in ipairs(playerBlips) do
        if blip.id == Client.GetLocalPlayer():GetAccountID() then
            table.remove(playerBlips, i)
            break
        end
    end

    mapUI:CallEvent('Map:UpdatePlayersPos', playerBlips)
    minimapUI:CallEvent('Map:UpdatePlayersPos', playerBlips)
end)

Events.SubscribeRemote('Map:UpdateAllBlips', function(blips)
    Config.MapBlips = blips
    mapUI:CallEvent('SetBlips', Config.MapBlips)
    minimapUI:CallEvent('SetBlips', Config.MapBlips)
end)


Package.Subscribe('Load', function()
    for _, blip in ipairs(Config.MapBlips) do
        if not blip.id then
            blip.id = GenerateBlipId()
        end
    end

    -- Now you have unique IDs for every blip,
    -- so the rest of the code won't re-generate or overwrite them.

    -- Then proceed to set them on the UI...
    minimapUI:CallEvent('SetBlips', Config.MapBlips)
    mapUI:CallEvent('SetBlips', Config.MapBlips)
end)
