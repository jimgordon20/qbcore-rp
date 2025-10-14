local properties = nil
local my_webui = WebUI('qb-input', 'qb-input/html/index.html', 0)

my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
    my_webui:RegisterEventHandler('buttonSubmit', function()
        if not properties then return end
        properties:resolve(data.data)
        properties = nil
    end)
    my_webui:RegisterEventHandler('closeMenu', function()
        if not properties then return end
        properties:resolve(nil)
        properties = nil
    end)
end)

function onShutdown()
    if my_webui then
        my_webui:Destroy()
        my_webui = nil
    end
end

local function ShowInput(data)
    if not data then return end
    if properties then return end
    if not my_webui then setupUI() end
    properties = promise.new()
    my_webui:CallFunction('OpenMenu', data)
    my_webui:SetLayer(5)
    return properties:await()
end

local function CloseMenu()
    if not my_webui then return end
    if properties then
        properties:resolve(nil)
        properties = nil
    end
    my_webui:CallFunction('CloseMenu')
    my_webui:SetLayer(0)
end

-- Events

RegisterClientEvent('qb-input:client:ShowMenu', function(data)
    ShowInput(data)
end)

RegisterClientEvent('qb-input:client:CloseMenu', function()
    CloseMenu()
end)

exports('qb-input', 'ShowInput', ShowInput)
exports('qb-input', 'CloseMenu', CloseMenu)
