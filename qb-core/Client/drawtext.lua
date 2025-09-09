local my_webui = WebUI('DrawText', 'qb-core/Client/html/index.html')

local function hideText()
    my_webui:CallEvent('HIDE_TEXT')
end

local function drawText(text, position)
    if type(position) ~= 'string' then position = 'left' end
    my_webui:CallEvent('DRAW_TEXT', text, position)
end

local function changeText(text, position)
    if type(position) ~= 'string' then position = 'left' end
    my_webui:CallEvent('CHANGE_TEXT', text, position)
end

local function keyPressed()
    my_webui:CallEvent('KEY_PRESSED')
    hideText()
end

RegisterClientEvent('qb-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

RegisterClientEvent('qb-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

RegisterClientEvent('qb-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

RegisterClientEvent('qb-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

RegisterClientEvent('qb-core:client:HideText', function()
    hideText()
end)

RegisterClientEvent('qb-core:client:HideText', function()
    hideText()
end)

RegisterClientEvent('qb-core:client:KeyPressed', function()
    keyPressed()
end)

RegisterClientEvent('qb-core:client:KeyPressed', function()
    keyPressed()
end)

-- Package.Export('DrawText', drawText)
-- Package.Export('ChangeText', changeText)
-- Package.Export('HideText', hideText)
-- Package.Export('KeyPressed', keyPressed)
