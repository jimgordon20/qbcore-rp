local my_webui = WebUI('Menu', 'file://html/index.html')
local headerShown = false
local sendData = nil

local function cloneTable(org)
	return { table.unpack(org) }
end

local function sortData(data, skipfirst)
	local header = data[1]
	local tempData = data
	if skipfirst then
		table.remove(tempData, 1)
	end
	table.sort(tempData, function(a, b)
		return a.header < b.header
	end)
	if skipfirst then
		table.insert(tempData, 1, header)
	end
	return tempData
end

local function openMenu(data, sort, skipFirst)
	if not data or not next(data) then
		return
	end
	if sort then
		data = sortData(data, skipFirst)
	end
	sendData = data
	Input.SetMouseEnabled(true)
	my_webui:BringToFront()
	headerShown = false
	my_webui:CallEvent('OPEN_MENU', cloneTable(data))
end
Package.Export('openMenu', openMenu)

local function closeMenu()
	sendData = nil
	headerShown = false
	Input.SetMouseEnabled(false)
	my_webui:CallEvent('CLOSE_MENU')
end
Package.Export('closeMenu', closeMenu)

local function showHeader(data)
	if not data or not next(data) then
		return
	end
	headerShown = true
	sendData = data
	my_webui:CallEvent('SHOW_HEADER', cloneTable(data))
end
Package.Export('showHeader', showHeader)

-- Events
Events.Subscribe('qb-menu:client:openMenu', function()
	openMenu(data, sort, skipFirst)
end)

Events.Subscribe('qb-menu:client:closeMenu', function()
	closeMenu()
end)

-- NUI Listeners

my_webui:Subscribe('closeMenu', function()
	headerShown = false
	sendData = nil
	Input.SetMouseEnabled(false)
end)

my_webui:Subscribe('clickedButton', function(option)
	if headerShown then
		headerShown = false
	end
	Input.SetMouseEnabled(false)
	if sendData then
		local data = sendData[tonumber(option)]
		sendData = nil
		if data then
			if data.params.event then
				if data.params.isServer then
					Events.CallRemote(data.params.event, data.params.args)
				elseif data.params.isCommand then
					-- to do
					--ExecuteCommand(data.params.event)
				elseif data.params.isQBCommand then
					Events.CallRemote('QBCore:CallCommand', data.params.event, data.params.args)
				elseif data.params.isAction then
					-- to do
					-- data.params.event(data.params.args)
				else
					Events.Call(data.params.event, data.params.args)
				end
			end
		end
	end
end)
