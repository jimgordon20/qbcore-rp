local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local my_webui = WebUI('HUD', 'file://html/index.html')
PlayerData = QBCore.Functions.GetPlayerData()
local inRadialMenu = false
local jobIndex = nil
local vehicleIndex = nil
local DynamicMenuItems = {}
local FinalMenuItems = {}

-- Functions

local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if not orig.canOpen or orig.canOpen() then
			local toRemove = {}
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				if type(orig_value) == 'table' then
					if not orig_value.canOpen or orig_value.canOpen() then
						copy[deepcopy(orig_key)] = deepcopy(orig_value)
					else
						toRemove[orig_key] = true
					end
				else
					copy[deepcopy(orig_key)] = deepcopy(orig_value)
				end
			end
			for i = 1, #toRemove do
				table.remove(copy, i)
			end
			if copy and next(copy) then
				setmetatable(copy, deepcopy(getmetatable(orig)))
			end
		end
	elseif orig_type ~= 'function' then
		copy = orig
	end
	return copy
end

local function AddOption(data, id)
	local menuID = id ~= nil and id or (#DynamicMenuItems + 1)
	DynamicMenuItems[menuID] = deepcopy(data)
	DynamicMenuItems[menuID].res = ''
	return menuID
end

local function RemoveOption(id)
	DynamicMenuItems[id] = nil
end

local function SetupJobMenu()
	local JobInteractionCheck = PlayerData.job.name
	if PlayerData.job.type == 'leo' then
		JobInteractionCheck = 'police'
	end
	local JobMenu = {
		id = 'jobinteractions',
		title = 'Work',
		icon = 'briefcase',
		items = {},
	}
	if
		Config.JobInteractions[JobInteractionCheck]
		and next(Config.JobInteractions[JobInteractionCheck])
		and PlayerData.job.onduty
	then
		JobMenu.items = Config.JobInteractions[JobInteractionCheck]
	end

	if #JobMenu.items == 0 then
		if jobIndex then
			RemoveOption(jobIndex)
			jobIndex = nil
		end
	else
		jobIndex = AddOption(JobMenu, jobIndex)
	end
end

local in_vehicle = false
local current_vehicle = nil

HCharacter.Subscribe('EnterVehicle', function(self, vehicle, seat_index)
	in_vehicle = true
	current_vehicle = vehicle
end)

HCharacter.Subscribe('LeaveVehicle', function(self, vehicle)
	in_vehicle = false
	current_vehicle = nil
end)

local function SetupVehicleMenu()
	local VehicleMenu = {
		id = 'vehicle',
		title = 'Vehicle',
		icon = 'car',
		items = {},
	}

	local ped = Client.GetLocalPlayer():GetControlledCharacter()

	if in_vehicle then
		VehicleMenu.items[#VehicleMenu.items + 1] = Config.VehicleDoors
		if Config.EnableExtraMenu then
			VehicleMenu.items[#VehicleMenu.items + 1] = Config.VehicleExtras
		end

		-- if not IsVehicleOnAllWheels(Vehicle) then
		-- 	VehicleMenu.items[#VehicleMenu.items + 1] = {
		-- 		id = "vehicle-flip",
		-- 		title = "Flip Vehicle",
		-- 		icon = "car-burst",
		-- 		type = "client",
		-- 		event = "qb-radialmenu:flipVehicle",
		-- 		shouldClose = true,
		-- 	}
		-- end

		if current_vehicle then
			local seatIndex = #VehicleMenu.items + 1
			VehicleMenu.items[seatIndex] = deepcopy(Config.VehicleSeats)

			local seatTable = {
				[1] = Lang:t('options.driver_seat'),
				[2] = Lang:t('options.passenger_seat'),
				[3] = Lang:t('options.rear_left_seat'),
				[4] = Lang:t('options.rear_right_seat'),
			}

			local AmountOfSeats = current_vehicle:NumOfAllowedPassanger()
			for i = 1, AmountOfSeats do
				local newIndex = #VehicleMenu.items[seatIndex].items + 1
				VehicleMenu.items[seatIndex].items[newIndex] = {
					id = i - 2,
					title = seatTable[i] or Lang:t('options.other_seats'),
					icon = 'caret-up',
					type = 'client',
					event = 'qb-radialmenu:client:ChangeSeat',
					shouldClose = false,
				}
			end
		end
	end

	if #VehicleMenu.items == 0 then
		if vehicleIndex then
			RemoveOption(vehicleIndex)
			vehicleIndex = nil
		end
	else
		vehicleIndex = AddOption(VehicleMenu, vehicleIndex)
	end
end

local function SetupSubItems()
	SetupJobMenu()
	SetupVehicleMenu()
end

local function selectOption(t, t2)
	for _, v in pairs(t) do
		if v.items then
			local found, hasAction, val = selectOption(v.items, t2)
			if found then
				return true, hasAction, val
			end
		else
			if v.id == t2.id and ((v.event and v.event == t2.event) or v.action) and (not v.canOpen or v.canOpen()) then
				return true, v.action, v
			end
		end
	end
	return false
end

local function IsPoliceOrEMS()
	return (PlayerData.job.name == 'police' or PlayerData.job.type == 'leo' or PlayerData.job.name == 'ambulance')
end

local function IsDowned()
	return (PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'])
end

local function SetupRadialMenu()
	FinalMenuItems = {}
	if IsDowned() and IsPoliceOrEMS() then
		FinalMenuItems = {
			[1] = {
				id = 'emergencybutton2',
				title = Lang:t('options.emergency_button'),
				icon = 'circle-exclamation',
				type = 'client',
				event = 'police:client:SendPoliceEmergencyAlert',
				shouldClose = true,
			},
		}
	else
		SetupSubItems()
		FinalMenuItems = deepcopy(Config.MenuItems)
		for _, v in pairs(DynamicMenuItems) do
			FinalMenuItems[#FinalMenuItems + 1] = v
		end
	end
end

local function setRadialState(bool, sendMessage, delay)
	if bool then
		Events.Call('qb-radialmenu:client:onRadialmenuOpen')
		SetupRadialMenu()
	else
		Events.Call('qb-radialmenu:client:onRadialmenuClose')
	end
	my_webui:BringToFront()
	Input.SetMouseEnabled(bool)
	if sendMessage then
		my_webui:CallEvent('ui', bool, FinalMenuItems, Config.Toggle, Config.Keybind)
	end
	if delay then
		Wait(500)
	end
	inRadialMenu = bool
end

-- Command

Input.Register('RadialMenu', Config.Keybind)

Input.Bind('RadialMenu', InputEvent.Pressed, function()
	if
		((IsDowned() and IsPoliceOrEMS()) or not IsDowned())
		and not PlayerData.metadata['ishandcuffed']
		and not inRadialMenu
	then
		setRadialState(true, true)
	end
end)

-- Subscribes for Releasing the key
Input.Bind('RadialMenu', InputEvent.Released, function()
	setRadialState(false, true)
end)

-- Events

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
	PlayerData = {}
end)

Events.SubscribeRemote('QBCore:Player:SetPlayerData', function(val)
	PlayerData = val
end)

Events.SubscribeRemote('qb-radialmenu:client:noPlayers', function()
	QBCore.Functions.Notify(Lang:t('error.no_people_nearby'), 'error', 2500)
end)

-- NUI Callbacks

my_webui:Subscribe('selectItem', function(itemData)
	local found, action, data = selectOption(FinalMenuItems, itemData)
	if data and found then
		if action then
			action(data)
		elseif data.type == 'client' then
			Events.Call(data.event, data)
		elseif data.type == 'server' then
			Events.CallRemote(data.event, data)
		elseif data.type == 'command' then
			ExecuteCommand(data.event)
		elseif data.type == 'qbcommand' then
			Events.CallRemote('QBCore:CallCommand', data.event, data)
		end
	end
end)

Package.Export('AddRadialOption', AddOption)
Package.Export('RemoveRadialOption', RemoveOption)
