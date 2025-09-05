local properties = nil
local my_webui = WebUI('Input', 'qb-input/Client/html/index.html')

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    Wait(1000)
    my_webui:CallFunction('SetStyle', Config.Style)
end)

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    my_webui:CallFunction('SetStyle', Config.Style)
end)

my_webui:RegisterEventHandler('buttonSubmit', function()
    --SetNuiFocus(false)
    properties:resolve(data.data)
    properties = nil
    --cb('ok')
end)

my_webui:RegisterEventHandler('closeMenu', function()
    --SetNuiFocus(false)
    properties:resolve(nil)
    properties = nil
    --cb('ok')
end)

local function ShowInput(data)
    Wait(150)
    if not data then return end
    if properties then return end

    properties = promise.new()

    --SetNuiFocus(true, true)
    my_webui:CallFunction('OpenMenu', data)

    return Citizen.Await(properties)
end

exports('ShowInput', ShowInput)
