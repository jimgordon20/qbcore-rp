QBCore.Functions = {}
local my_webui = WebUI('qb-core', 'qb-core/Client/html/index.html', 0)

-- Getter Functions

function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

-- Functions

function QBCore.Functions.Debug(tbl)
    print(HELIXTable.Dump(tbl))
end

-- UI

function QBCore.Functions.HideText()
    if not my_webui then return end
    my_webui:CallFunction('hideText')
    my_webui:SetLayer(0)
end

function QBCore.Functions.DrawText(text, position)
    if not my_webui then return end
    if type(position) ~= 'string' then position = 'left' end
    my_webui:SetLayer(3)
    my_webui:CallFunction('drawText', text, position)
end

function QBCore.Functions.ChangeText(text, position)
    if not my_webui then return end
    if type(position) ~= 'string' then position = 'left' end
    my_webui:CallFunction('changeText', text, position)
end

function QBCore.Functions.KeyPressed()
    if not my_webui then return end
    my_webui:CallFunction('keyPressed')
    QBCore.Functions.HideText()
end

function QBCore.Functions.Notify(text, texttype, length, icon)
    if not my_webui then return end
    local noti_type = texttype or 'primary'
    my_webui:SetLayer(3)
    if type(text) == 'table' then
        my_webui:CallFunction('showNotif', {
            text = text.text,
            length = length or 5000,
            type = noti_type,
            caption = text.caption or '',
            icon = icon or nil
        })
    else
        my_webui:CallFunction('showNotif', {
            text = text,
            length = length or 5000,
            type = noti_type,
            caption = '',
            icon = icon or nil
        })
    end

    Timer.SetTimeout(function()
        my_webui:SetLayer(0)
    end, length or 5000)
end

for functionName, func in pairs(QBCore.Functions) do
    if type(func) == 'function' then
        exports('qb-core', functionName, func)
    end
end
