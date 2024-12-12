local my_webui = WebUI('Input', 'file://html/index.html')
local callback = nil

local function ShowInput(data, cb)
    if not data then return end
    if callback then return end
    callback = cb
    Input.SetMouseEnabled(true)
    my_webui:BringToFront()
    my_webui:CallEvent('OPEN_INPUT', { data = data })
end

Package.Export('ShowInput', ShowInput)

my_webui:Subscribe('buttonSumbit', function(data)
    if not callback then return end
    Input.SetMouseEnabled(false)
    callback(data.data)
    callback = nil
end)

my_webui:Subscribe('closeMenu', function()
    if not callback then return end
    Input.SetMouseEnabled(false)
    callback(nil)
    callback = nil
end)
