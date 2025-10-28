local sendData = nil
local my_webui = WebUI('qb-menu', 'qb-menu/html/index.html')

my_webui:RegisterEventHandler('clickedButton', function(option)
    my_webui:SetInputMode(0)
    if sendData then
        local data = sendData[tonumber(option)]
        sendData = nil
        if data.action ~= nil then
            data.action()
            return
        end
        if data then
            if data.params.event then
                if data.params.isServer then
                    TriggerServerEvent(data.params.event, data.params.args)
                else
                    TriggerLocalClientEvent(data.params.event, data.params.args)
                end
            end
        end
    end
end)

my_webui:RegisterEventHandler('closeMenu', function()
    sendData = nil
    my_webui:SetInputMode(0)
end)

function onShutdown()
    if my_webui then
        my_webui:Destroy()
        my_webui = nil
    end
end

-- Functions

local function sortData(data, skipfirst)
    local header = data[1]
    local tempData = data
    if skipfirst then table.remove(tempData, 1) end
    table.sort(tempData, function(a, b) return a.header < b.header end)
    if skipfirst then table.insert(tempData, 1, header) end
    return tempData
end

local function openMenu(data, sort, skipFirst)
    if not data or not next(data) then return end
    if not my_webui then return end
    if sort then data = sortData(data, skipFirst) end
    sendData = data
    my_webui:BringToFront()
    my_webui:SetInputMode(1)
    my_webui:SendEvent('openMenu', data)
end

local function closeMenu()
    sendData = nil
    if not my_webui then return end
    my_webui:SetInputMode(0)
    my_webui:SendEvent('closeMenu')
end

-- Events

RegisterClientEvent('qb-menu:client:openMenu', function(data, sort, skipFirst)
    openMenu(data, sort, skipFirst)
end)

RegisterClientEvent('qb-menu:client:closeMenu', function()
    closeMenu()
end)

-- Exports

exports('qb-menu', 'openMenu', openMenu)
exports('qb-menu', 'closeMenu', closeMenu)
