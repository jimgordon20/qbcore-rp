-- NotificationServer.lua
-- Server-side notification management

NotificationServer = {}
NotificationServer.__index = NotificationServer

-- Store notifications per player:
-- Key: accountId, Value: array of notifications {id, type, title, text, timestamp, read = false}
local playerNotifications = {}
local notificationCounter = 0

-- Adds a persistent notification to a player's backlog and sends a popup event to the client
function NotificationServer.AddForPlayer(player, type, title, text)
    local accountId = player:GetAccountID()
    playerNotifications[accountId] = playerNotifications[accountId] or {}
    notificationCounter = notificationCounter + 1

    local notif = {
        id = notificationCounter,
        type = type,
        title = title,
        text = text,
        timestamp = os.time(),
        read = true
    }

    table.insert(playerNotifications[accountId], notif)
end

-- Retrieves a player's notification history
local function GetPlayerNotifications(accountId)
    return playerNotifications[accountId] or {}
end

-- Marks a specific notification as read for a player
local function MarkNotificationAsRead(accountId, notificationId)
    local notifications = playerNotifications[accountId]
    if not notifications then return false end
    for _, notif in ipairs(notifications) do
        if notif.id == notificationId then
            notif.read = true
            return true
        end
    end
    return false
end

Events.SubscribeRemote("SaveNotification", function(player, type, title, text)
    -- verify all args exists and are not nil
    if not type or not title or not text then
        print("SaveNotification: Missing arguments")
        return
    end
    NotificationServer.AddForPlayer(player, type, title, text)
end)

-- Player requests notification history
Events.SubscribeRemote("Notification:GetHistory", function(player)
    local accountId = player:GetAccountID()
    local history = GetPlayerNotifications(accountId)
    Events.CallRemote("Notification:UpdateHistory", player, history) -- Template event for recieveing history on client side
end)

-- Player marks a notification as read
Events.SubscribeRemote("Notification:MarkAsRead", function(player, notificationId)
    local accountId = player:GetAccountID()
    local success = MarkNotificationAsRead(accountId, notificationId)
    if success then
        local history = GetPlayerNotifications(accountId)
        Events.CallRemote("Notification:UpdateHistory", player, history) -- Template event for recieveing history on client side
    else
        print("Notification:MarkAsRead: Notification not found.")
    end
end)

-- Utility functions to get faction or player names could be placed here as well

-- Export the NotificationServer
Package.Export("NotificationServer", NotificationServer)

-- debbug
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "get" then
        local history = GetPlayerNotifications(player:GetAccountID())
        print(HELIXTable.Dump(history))
    end
end)