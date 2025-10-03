local properties = nil
local my_webui = nil

local function setupUI()
    if my_webui then return end
    my_webui = WebUI('qb-input', 'qb-input/Client/html/index.html', true)
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
end

local function ShowInput(data)
    if not data then return end
    if properties then return end
    if not my_webui then setupUI() end
    properties = promise.new()
    my_webui:CallFunction('OpenMenu', data)
    return properties:await()
end

exports('qb-input', 'ShowInput', ShowInput)
