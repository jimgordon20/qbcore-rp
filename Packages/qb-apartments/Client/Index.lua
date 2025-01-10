local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local InApartment = false
local ClosestHouse = nil
local CurrentApartment = nil
local IsOwned = false
local CurrentDoorBell = 0
local CurrentOffset = 0
local HouseObj = {}
local POIOffsets = nil
local RangDoorbell = nil
local InApartmentTargets = {}

local function RegisterApartmentEntranceTarget(apartmentID, apartmentData)
	local coords = Vector(apartmentData.coords[1], apartmentData.coords[2], apartmentData.coords[3])
	local boxName = 'apartmentEntrance_' .. apartmentID
	local boxData = apartmentData.polyzoneBoxData
	if boxData.created then return end
	local options = {}

	if apartmentID == ClosestHouse and IsOwned then
		options = {
			{
				type = 'client',
				event = 'qb-apartments:client:EnterApartment',
				icon = 'fas fa-door-open',
				label = Lang:t('text.enter'),
			},
		}
	else
		options = {
			{
				type = 'client',
				event = 'qb-apartments:client:UpdateApartment',
				icon = 'fas fa-hotel',
				label = Lang:t('text.move_here'),
			},
		}
	end

	options[#options + 1] = {
		type = 'client',
		event = 'qb-apartments:client:DoorbellMenu',
		icon = 'fas fa-concierge-bell',
		label = Lang:t('text.ring_doorbell'),
	}

	AddBoxZone(boxName, coords, boxData.length, boxData.width, {
		name = boxName,
		heading = boxData.heading,
	}, {
		options = options,
		distance = boxData.distance,
	})

	boxData.created = true
end

local function RegisterInApartmentTarget(targetKey, coords, heading, options)
	if not InApartment then
		return
	end

	if InApartmentTargets[targetKey] and InApartmentTargets[targetKey].created then
		return
	end

	local boxName = 'inApartmentTarget_' .. targetKey
	AddBoxZone(boxName, coords, 0.5, 0.5, {
		name = boxName,
		heading = heading,
	}, {
		options = options,
		distance = 200,
	})

	InApartmentTargets[targetKey] = InApartmentTargets[targetKey] or {}
	InApartmentTargets[targetKey].created = true
end

local function SetApartmentsEntranceTargets()
	if Apartments.Locations and next(Apartments.Locations) then
		for id, apartment in pairs(Apartments.Locations) do
			if apartment and apartment.coords then
				RegisterApartmentEntranceTarget(id, apartment)
			end
		end
	end
end

local function SetInApartmentTargets()
	if not POIOffsets then
		return
	end
	local entrancePos = Vector(
		Apartments.Locations[ClosestHouse].coords[1] - POIOffsets.exit.x,
		Apartments.Locations[ClosestHouse].coords[2] - POIOffsets.exit.y,
		Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset + POIOffsets.exit.z
	)
	local stashPos = Vector(
		Apartments.Locations[ClosestHouse].coords[1] - POIOffsets.stash.x,
		Apartments.Locations[ClosestHouse].coords[2] - POIOffsets.stash.y,
		Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset + POIOffsets.stash.z
	)
	local outfitsPos = Vector(
		Apartments.Locations[ClosestHouse].coords[1] - POIOffsets.clothes.x,
		Apartments.Locations[ClosestHouse].coords[2] - POIOffsets.clothes.y,
		Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset + POIOffsets.clothes.z
	)
	local logoutPos = Vector(
		Apartments.Locations[ClosestHouse].coords[1] - POIOffsets.logout.x,
		Apartments.Locations[ClosestHouse].coords[2] - POIOffsets.logout.y,
		Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset + POIOffsets.logout.z
	)
	RegisterInApartmentTarget('entrancePos', entrancePos, 0, {
		{
			type = 'client',
			event = 'qb-apartments:client:OpenDoor',
			icon = 'fas fa-door-open',
			label = Lang:t('text.open_door'),
		},
		{
			type = 'client',
			event = 'qb-apartments:client:LeaveApartment',
			icon = 'fas fa-door-open',
			label = Lang:t('text.leave'),
		},
	})
	RegisterInApartmentTarget('stashPos', stashPos, 0, {
		{
			type = 'client',
			event = 'qb-apartments:client:OpenStash',
			icon = 'fas fa-box-open',
			label = Lang:t('text.open_stash'),
		},
	})
	RegisterInApartmentTarget('outfitsPos', outfitsPos, 0, {
		{
			type = 'client',
			event = 'qb-apartments:client:ChangeOutfit',
			icon = 'fas fa-tshirt',
			label = Lang:t('text.change_outfit'),
		},
	})
	RegisterInApartmentTarget('logoutPos', logoutPos, 0, {
		{
			type = 'client',
			event = 'qb-apartments:client:Logout',
			icon = 'fas fa-sign-out-alt',
			label = Lang:t('text.logout'),
		},
	})
end

local function DeleteApartmentsEntranceTargets()
	if Apartments.Locations and next(Apartments.Locations) then
		for id, info in pairs(Apartments.Locations) do
			RemoveZone('apartmentEntrance_' .. id)
			local boxData = info.polyzoneBoxData
			boxData.created = false
		end
	end
end

local function DeleteInApartmentTargets()
	if InApartmentTargets and next(InApartmentTargets) then
		for id in pairs(InApartmentTargets) do
			RemoveZone('inApartmentTarget_' .. id)
		end
	end
	InApartmentTargets = {}
end

-- utility functions

local function EnterApartment(house, apartmentId, new)
	QBCore.Functions.TriggerCallback('qb-apartments:GetApartmentOffset', function(offset)
		if offset == nil or offset == 0 then
			QBCore.Functions.TriggerCallback('qb-apartments:GetApartmentOffsetNewOffset', function(newoffset)
				if newoffset > 730 then
					newoffset = 710
				end
				CurrentOffset = newoffset
				Events.CallRemote('qb-apartments:server:AddObject', apartmentId, house, CurrentOffset)
				local coords = Vector(
					Apartments.Locations[house].coords[1],
					Apartments.Locations[house].coords[2],
					Apartments.Locations[house].coords[3] - CurrentOffset
				)
				local data = CreateApartmentFurnished(coords)
				HouseObj = data[1]
				POIOffsets = data[2]
				InApartment = true
				CurrentApartment = apartmentId
				ClosestHouse = house
				RangDoorbell = nil
				Events.Call('qb-weathersync:client:DisableSync')
				Events.CallRemote('qb-apartments:server:SetInsideMeta', house, apartmentId, true, false)
				Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
				Events.CallRemote('qb-apartments:server:setCurrentApartment', CurrentApartment)
				if Input.IsMouseEnabled() then Input.SetMouseEnabled(false) end
			end, house)
		else
			if offset > 730 then
				offset = 710
			end
			CurrentOffset = offset
			Events.CallRemote('qb-apartments:server:AddObject', apartmentId, house, CurrentOffset)
			local coords = Vector(
				Apartments.Locations[house].coords[1],
				Apartments.Locations[house].coords[2],
				Apartments.Locations[house].coords[3] - CurrentOffset
			)
			local data = CreateApartmentFurnished(coords)
			HouseObj = data[1]
			POIOffsets = data[2]
			InApartment = true
			CurrentApartment = apartmentId
			Events.Call('qb-weathersync:client:DisableSync')
			Events.CallRemote('qb-apartments:server:SetInsideMeta', house, apartmentId, true, true)
			Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
			Events.CallRemote('qb-apartments:server:setCurrentApartment', CurrentApartment)
			if Input.IsMouseEnabled() then Input.SetMouseEnabled(false) end
		end

		if new ~= nil then
			if new then
				Events.Call('qb-interior:client:SetNewState', true)
			else
				Events.Call('qb-interior:client:SetNewState', false)
			end
		else
			Events.Call('qb-interior:client:SetNewState', false)
		end
	end, apartmentId)
end

local function LeaveApartment(house)
	Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
	Events.CallRemote('qb-apartments:returnBucket')
	Client.GetLocalPlayer():StartCameraFade(0, 1, 0.1, Color(0, 0, 0, 1), true, true)
	DespawnInterior(HouseObj, function()
		Events.Call('qb-weathersync:client:EnableSync')
		Events.CallRemote(
			'qb-interior:server:teleportPlayer',
			Apartments.Locations[house].coords[1],
			Apartments.Locations[house].coords[2],
			Apartments.Locations[house].coords[3],
			0
		)
		Events.CallRemote('qb-apartments:server:RemoveObject', CurrentApartment, house)
		Events.CallRemote('qb-apartments:server:SetInsideMeta', CurrentApartment, false)
		CurrentApartment = nil
		InApartment = false
		CurrentOffset = 0
		Sound(Vector(), 'package://qb-apartments/Client/houses_door_close.ogg', true)
		Events.CallRemote('qb-apartments:server:setCurrentApartment', nil)
		DeleteInApartmentTargets()
		DeleteApartmentsEntranceTargets()
	end)
end

local function SetClosestApartment()
	local ped = Client.GetLocalPlayer():GetControlledCharacter()
	if not ped then
		return
	end
	local pos = ped:GetLocation()
	local current = nil
	local dist = 500
	for id in pairs(Apartments.Locations) do
		local distcheck = pos:Distance(
			Vector(
				Apartments.Locations[id].coords[1],
				Apartments.Locations[id].coords[2],
				Apartments.Locations[id].coords[3]
			)
		)
		if distcheck < dist then
			current = id
			SetApartmentsEntranceTargets()
		end
	end
	if current ~= ClosestHouse and not InApartment then
		ClosestHouse = current
		QBCore.Functions.TriggerCallback('qb-apartments:IsOwner', function(result)
			IsOwned = result
			DeleteApartmentsEntranceTargets()
			DeleteInApartmentTargets()
		end, ClosestHouse)
	end
end

function MenuOwners()
	QBCore.Functions.TriggerCallback('qb-apartments:GetAvailableApartments', function(apartments)
		if next(apartments) == nil then
			QBCore.Functions.Notify(Lang:t('error.nobody_home'), 'error')
		else
			local apartment_menu = ContextMenu.new()
			apartment_menu:addButton('header-id', Lang:t('text.tennants'), function() end)
			for k, v in pairs(apartments) do
				apartment_menu:addButton('apartment-' .. k, v, function()
					Events.Call('qb-apartments:client:RingMenu', { apartmentId = k })
				end)
			end
			apartmentMenu:addButton('close-menu', Lang:t('text.close_menu'), function() apartment_menu:Close() end)
			apartment_menu:Open(false, true)
		end
	end, ClosestHouse)
end

-- Events

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
	if not InApartment then
		SetClosestApartment()
		SetApartmentsEntranceTargets()
	elseif InApartment then
		SetInApartmentTargets()
	end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
	CurrentApartment = nil
	InApartment = false
	CurrentOffset = 0
	DeleteApartmentsEntranceTargets()
	DeleteInApartmentTargets()
end)

Events.SubscribeRemote('qb-apartments:client:setupSpawnUI', function(cData)
	QBCore.Functions.TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result then
			Events.Call('qb-spawn:client:setupSpawns', cData, false, nil)
			Events.Call('qb-spawn:client:openUI', true)
			Events.Call('qb-apartments:client:SetHomeBlip', result.type)
		else
			if Apartments.Starting then
				Events.Call('qb-spawn:client:setupSpawns', cData, true, Apartments.Locations)
				Events.Call('qb-spawn:client:openUI', true)
			else
				Events.Call('qb-spawn:client:setupSpawns', cData, false, nil)
				Events.Call('qb-spawn:client:openUI', true)
				Events.Call('qb-apartments:client:SetHomeBlip', nil)
			end
		end
	end, cData.citizenid)
end)

Events.SubscribeRemote('qb-apartments:client:SpawnInApartment', function(apartmentId, apartment)
	if RangDoorbell ~= nil then
		local ped = Client.GetLocalPlayer():GetControlledCharacter()
		if not ped then return end
		local pos = ped:GetLocation()
		local doorbelldist = pos:Distance(
			Vector(
				Apartments.Locations[RangDoorbell].coords[1],
				Apartments.Locations[RangDoorbell].coords[2],
				Apartments.Locations[RangDoorbell].coords[3]
			)
		)
		if doorbelldist > 500 then
			QBCore.Functions.Notify(Lang:t('error.to_far_from_door'))
			return
		end
	end
	ClosestHouse = apartment
	EnterApartment(apartment, apartmentId, true)
	IsOwned = true
end)

Events.Subscribe('qb-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
	ClosestHouse = apartmentType
	EnterApartment(apartmentType, apartmentId, false)
end)

Events.SubscribeRemote('qb-apartments:client:SetHomeBlip', function(home)
	SetClosestApartment()
	for name, _ in pairs(Apartments.Locations) do
		local coords = {
			x = Apartments.Locations[name].coords[1],
			y = Apartments.Locations[name].coords[2],
			z = Apartments.Locations[name].coords[3],
		}
		Map:RemoveBlip(Apartments.Locations[name].blip)
		Apartments.Locations[name].blip = Map:AddBlip({
			id = name,
			name = Apartments.Locations[name].label,
			imgUrl = './media/map-icons/Hotel-icon.svg',
			coords = coords,
		})
	end
end)

Events.Subscribe('qb-apartments:client:RingMenu', function(data)
	RangDoorbell = ClosestHouse
	--Events.CallRemote("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
	Events.CallRemote('qb-apartments:server:RingDoor', data.apartmentId, ClosestHouse)
end)

Events.SubscribeRemote('qb-apartments:client:RingDoor', function(player, _)
	CurrentDoorBell = player
	--Events.CallRemote("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
	QBCore.Functions.Notify(Lang:t('info.at_the_door'))
end)

Events.Subscribe('qb-apartments:client:DoorbellMenu', function()
	MenuOwners()
end)

Events.Subscribe('qb-apartments:client:EnterApartment', function()
	QBCore.Functions.TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result then
			EnterApartment(ClosestHouse, result.name)
		end
	end, QBCore.Functions.GetPlayerData().citizenid)
end)

Events.Subscribe('qb-apartments:client:UpdateApartment', function()
	local apartmentType = ClosestHouse
	local apartmentLabel = Apartments.Locations[ClosestHouse].label
	QBCore.Functions.TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result == nil then
			Events.CallRemote('qb-apartments:server:CreateApartment', apartmentType, apartmentLabel, false)
		else
			Events.CallRemote('qb-apartments:server:UpdateApartment', apartmentType, apartmentLabel)
		end
	end)
	IsOwned = true
	DeleteApartmentsEntranceTargets()
	DeleteInApartmentTargets()
end)

Events.SubscribeRemote('qb-apartments:client:OpenDoor', function()
	if CurrentDoorBell == 0 then
		QBCore.Functions.Notify(Lang:t('error.nobody_at_door'), 'error')
		return
	end
	Events.CallRemote('qb-apartments:server:OpenDoor', CurrentDoorBell, CurrentApartment, ClosestHouse)
	CurrentDoorBell = 0
end)

Events.Subscribe('qb-apartments:client:LeaveApartment', function()
	LeaveApartment(ClosestHouse)
end)

Events.SubscribeRemote('qb-apartments:client:LeaveApartment', function()
	LeaveApartment(ClosestHouse)
end)

Events.Subscribe('qb-apartments:client:OpenStash', function()
	if CurrentApartment then
		Events.CallRemote('InteractSound_SV:PlayOnSource', 'StashOpen', 0.4)
		Events.CallRemote('qb-apartments:server:openStash', CurrentApartment)
	end
end)

Events.SubscribeRemote('qb-apartments:client:ChangeOutfit', function()
	--Events.CallRemote("InteractSound_SV:PlayOnSource", "Clothes1", 0.4)
	--Events.Call("qb-clothing:client:openOutfitMenu")
end)

Events.Subscribe('qb-apartments:client:Logout', function()
	LeaveApartment(ClosestHouse)
	Events.CallRemote('qb-apartments:server:LogoutLocation')
end)

-- Loop

Timer.SetInterval(function()
	if Client.GetValue('isLoggedIn', false) then
		if not InApartment then
			SetClosestApartment()
			SetApartmentsEntranceTargets()
		elseif InApartment then
			SetInApartmentTargets()
		end
	end
end, 1000)
