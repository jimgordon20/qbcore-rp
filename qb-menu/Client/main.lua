local headerShown = false
local sendData = nil
local my_webui = nil

-- Functions

local function setupUI()
    if my_webui then return end
    my_webui = WebUI('qb-menu', 'qb-menu/Client/html/index.html', true)
    my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
        my_webui:RegisterEventHandler('clickedButton', function(option)
            if headerShown then headerShown = false end
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
                        elseif data.params.isCommand then
                            ExecuteCommand(data.params.event)
                        elseif data.params.isQBCommand then
                            TriggerServerEvent('QBCore:CallCommand', data.params.event, data.params.args)
                        elseif data.params.isAction then
                            data.params.event(data.params.args)
                        else
                            TriggerLocalClientEvent(data.params.event, data.params.args)
                        end
                    end
                end
            end
        end)

        my_webui:RegisterEventHandler('closeMenu', function()
            headerShown = false
            sendData = nil
            TriggerLocalClientEvent('qb-menu:client:menuClosed')
        end)
    end)
end

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
    if not my_webui then setupUI() end
    if sort then data = sortData(data, skipFirst) end
    -- for _,v in pairs(data) do
    -- 	if v["icon"] then
    -- 		if QBCore.Shared.Items[tostring(v["icon"])] then
    -- 			if not string.find(QBCore.Shared.Items[tostring(v["icon"])].image, "//") and not string.find(v["icon"], "//") then
    --                 v["icon"] = "nui://qb-inventory/html/images/"..QBCore.Shared.Items[tostring(v["icon"])].image
    -- 			end
    -- 		end
    -- 	end
    -- end
    headerShown = false
    sendData = data
    if my_webui then
        my_webui:CallFunction('openMenu', data.buttons)
    end
end

local function closeMenu()
    sendData = nil
    headerShown = false
    if not my_webui then return end
    my_webui:CallFunction('closeMenu')
end

local function showHeader(data)
    if not data or not next(data) then return end
    if not my_webui then setupUI() end
    headerShown = true
    sendData = data
    if my_webui then
        my_webui:CallFunction('openMenu', table.clone(data.buttons))
    end
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
exports('qb-menu', 'showHeader', showHeader)
