local Lang = require('Shared/locales/en')
local isLoggedIn = false
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

-- Local Callback System
local CallbackRequests = {}
local CallbackRequestId = 0

local function TriggerCallback(name, cb, ...)
	CallbackRequestId = CallbackRequestId + 1
	CallbackRequests[CallbackRequestId] = cb
	TriggerServerEvent('apartments:server:TriggerCallback', name, CallbackRequestId, ...)
end

RegisterClientEvent('apartments:client:CallbackResponse', function(requestId, ...)
	if CallbackRequests[requestId] then
		CallbackRequests[requestId](...)
		CallbackRequests[requestId] = nil
	end
end)

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

	exports['qb-target']:AddBoxZone(boxName, coords, boxData.length, boxData.width, {
		name = boxName,
		heading = boxData.heading,
		debug = boxData.debug,
		distance = boxData.distance,
	}, options)

	boxData.created = true
end

local function RegisterInApartmentTarget(targetKey, coords, heading, options)
	if not InApartment then return end
	if InApartmentTargets[targetKey] and InApartmentTargets[targetKey].created then return end

	local boxName = 'inApartmentTarget_' .. targetKey
	exports['qb-target']:AddBoxZone(boxName, coords, 100, 100, {
		name = boxName,
		heading = heading,
		distance = 500,
		debug = true
	}, options)

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
	if not POIOffsets then return end
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
			exports['qb-target']:RemoveZone('apartmentEntrance_' .. id)
			local boxData = info.polyzoneBoxData
			boxData.created = false
		end
	end
end

local function DeleteInApartmentTargets()
	if InApartmentTargets and next(InApartmentTargets) then
		for id in pairs(InApartmentTargets) do
			exports['qb-target']:RemoveZone('inApartmentTarget_' .. id)
		end
	end
	InApartmentTargets = {}
end

local function EnterApartment(house, apartmentId, new)
	TriggerCallback('qb-apartments:GetApartmentOffset', function(offset)
		if offset == nil or offset == 0 then
			TriggerCallback('qb-apartments:GetApartmentOffsetNewOffset', function(newoffset)
				if newoffset > Apartments.MaxOffset then
					newoffset = Apartments.SpawnOffset
				end
				CurrentOffset = newoffset
				TriggerServerEvent('qb-apartments:server:AddObject', apartmentId, house, CurrentOffset)
				local coords = Vector(
					Apartments.Locations[house].coords[1],
					Apartments.Locations[house].coords[2],
					Apartments.Locations[house].coords[3] - CurrentOffset
				)
				local data = exports['qb-interior']:CreateApartmentFurnished(coords)
				HouseObj = data[1]
				POIOffsets = data[2]
				InApartment = true
				CurrentApartment = apartmentId
				ClosestHouse = house
				RangDoorbell = nil
				TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, false)
				TriggerServerEvent('qb-apartments:server:setCurrentApartment', CurrentApartment)
			end, house)
		else
			if offset > Apartments.MaxOffset then
				offset = Apartments.SpawnOffset
			end
			CurrentOffset = offset
			TriggerServerEvent('qb-apartments:server:AddObject', apartmentId, house, CurrentOffset)
			local coords = Vector(
				Apartments.Locations[ClosestHouse].coords[1],
				Apartments.Locations[ClosestHouse].coords[2],
				Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset
			)
			local data = exports['qb-interior']:CreateApartmentFurnished(coords)
			HouseObj = data[1]
			POIOffsets = data[2]
			InApartment = true
			CurrentApartment = apartmentId
			TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, true)
			TriggerServerEvent('qb-apartments:server:setCurrentApartment', CurrentApartment)
		end

		if new then
			TriggerLocalClientEvent('qb-interior:client:SetNewState', true)
		else
			TriggerLocalClientEvent('qb-interior:client:SetNewState', false)
		end
	end, apartmentId)
end

local function LeaveApartment(house)
	exports['qb-interior']:DespawnInterior(HouseObj, function()
		TriggerServerEvent('qb-interior:server:teleportPlayer', Apartments.Locations[house].coords[1], Apartments.Locations[house].coords[2], Apartments.Locations[house].coords[3], 0)
		TriggerServerEvent('qb-apartments:server:RemoveObject', CurrentApartment, house)
		TriggerServerEvent('qb-apartments:server:SetInsideMeta', CurrentApartment, false)
		CurrentApartment = nil
		InApartment = false
		CurrentOffset = 0
		TriggerServerEvent('qb-apartments:server:setCurrentApartment', nil)
		DeleteInApartmentTargets()
		DeleteApartmentsEntranceTargets()
	end)
end

local function SetClosestApartment()
	local ped = HPlayer:K2_GetPawn()
	if not ped then return end
	local pos = ped:K2_GetActorLocation()
	local current = nil
	local dist = 1000
	for id in pairs(Apartments.Locations) do
		local apartmentPos = Vector(
			Apartments.Locations[id].coords[1],
			Apartments.Locations[id].coords[2],
			Apartments.Locations[id].coords[3]
		)
		local distcheck = UE.FVector.Dist(pos, apartmentPos)
		if distcheck < dist then
			current = id
		end
	end
	if current ~= ClosestHouse and isLoggedIn and not InApartment then
		ClosestHouse = current
		TriggerCallback('qb-apartments:IsOwner', function(result)
			IsOwned = result
			DeleteApartmentsEntranceTargets()
			DeleteInApartmentTargets()
		end, ClosestHouse)
	end
end

local function MenuOwners()
	TriggerCallback('qb-apartments:GetAvailableApartments', function(apartments)
		if next(apartments) == nil then
			exports['qb-core']:Notify(Lang:t('error.nobody_home'), 'error')
			exports['qb-menu']:closeMenu()
		else
			local apartmentMenu = {
				{
					header = Lang:t('text.tennants'),
					isMenuHeader = true
				}
			}

			for k, v in pairs(apartments) do
				apartmentMenu[#apartmentMenu + 1] = {
					header = v,
					txt = '',
					params = {
						event = 'apartments:client:RingMenu',
						args = {
							apartmentId = k
						}
					}

				}
			end

			apartmentMenu[#apartmentMenu + 1] = {
				header = Lang:t('text.close_menu'),
				txt = '',
				params = {
					event = 'qb-menu:client:closeMenu'
				}

			}
			exports['qb-menu']:openMenu(apartmentMenu)
		end
	end, ClosestHouse)
end

-- Events

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
	isLoggedIn = false
	CurrentApartment = nil
	InApartment = false
	CurrentOffset = 0
	DeleteApartmentsEntranceTargets()
	DeleteInApartmentTargets()
end)

RegisterClientEvent('qb-apartments:client:setupSpawnUI', function(cData)
	TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result then
			TriggerLocalClientEvent('qb-spawn:client:openUI', true, cData, false, nil)
			--TriggerLocalClientEvent('apartments:client:SetHomeBlip', result.type)
		else
			if Apartments.Starting then
				TriggerLocalClientEvent('qb-spawn:client:openUI', true, cData, true, Apartments.Locations)
			else
				TriggerLocalClientEvent('qb-spawn:client:openUI', true, cData, false, nil)
				--TriggerLocalClientEvent('apartments:client:SetHomeBlip', nil)
			end
		end
	end, cData.citizenid)
end)

RegisterClientEvent('qb-apartments:client:SpawnInApartment', function(apartmentId, apartment)
	if RangDoorbell then
		local ped = HPlayer:K2_GetPawn()
		if not ped then return end
		local pos = ped:K2_GetActorLocation()
		local doorbellPos = Vector(
			Apartments.Locations[RangDoorbell].coords[1],
			Apartments.Locations[RangDoorbell].coords[2],
			Apartments.Locations[RangDoorbell].coords[3]
		)
		local doorbelldist = UE.FVector.Dist(pos, doorbellPos)
		if doorbelldist > 500 then
			exports['qb-core']:Notify(Lang:t('error.to_far_from_door'))
			return
		end
	end
	ClosestHouse = apartment
	EnterApartment(apartment, apartmentId, true)
	IsOwned = true
end)

RegisterClientEvent('qb-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
	ClosestHouse = apartmentType
	EnterApartment(apartmentType, apartmentId, false)
end)

RegisterClientEvent('qb-apartments:client:RingMenu', function(data)
	RangDoorbell = ClosestHouse
	TriggerServerEvent('qb-apartments:server:RingDoor', data.apartmentId, ClosestHouse)
end)

RegisterClientEvent('qb-apartments:client:RingDoor', function(player)
	CurrentDoorBell = player
	exports['qb-core']:Notify(Lang:t('info.at_the_door'))
end)

RegisterClientEvent('qb-apartments:client:DoorbellMenu', function()
	MenuOwners()
end)

RegisterClientEvent('qb-apartments:client:EnterApartment', function()
	TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result ~= nil then
			EnterApartment(ClosestHouse, result.name)
		end
	end)
end)

RegisterClientEvent('qb-apartments:client:UpdateApartment', function()
	local apartmentType = ClosestHouse
	local apartmentLabel = Apartments.Locations[ClosestHouse].label
	TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
		if result == nil then
			TriggerServerEvent('qb-apartments:server:CreateApartment', apartmentType, apartmentLabel, false)
		else
			TriggerServerEvent('qb-apartments:server:UpdateApartment', apartmentType, apartmentLabel)
		end
	end)

	IsOwned = true
	DeleteApartmentsEntranceTargets()
	DeleteInApartmentTargets()
end)

RegisterClientEvent('qb-apartments:client:OpenDoor', function()
	if CurrentDoorBell == 0 then
		exports['qb-core']:Notify(Lang:t('error.nobody_at_door'), 'error')
		return
	end
	TriggerServerEvent('qb-apartments:server:OpenDoor', CurrentDoorBell, CurrentApartment, ClosestHouse)
	CurrentDoorBell = 0
end)

RegisterClientEvent('qb-apartments:client:LeaveApartment', function()
	LeaveApartment(ClosestHouse)
end)

RegisterClientEvent('qb-apartments:client:OpenStash', function()
	if CurrentApartment then
		TriggerServerEvent('InteractSound_SV:PlayOnSource', 'StashOpen', 0.4)
		TriggerServerEvent('qb-apartments:server:openStash', CurrentApartment)
	end
end)

RegisterClientEvent('qb-apartments:client:ChangeOutfit', function()
	TriggerServerEvent('qb-apartments:server:GetOutfits')
end)

RegisterClientEvent('qb-apartments:client:Logout', function()
	LeaveApartment(ClosestHouse)
	TriggerServerEvent('qb-apartments:server:LogoutLocation')
end)

RegisterClientEvent('qb-apartments:client:GetOutfits', function(outfits)
	if outfits then
		-- TODO: Implement outfit menu with the outfits data
		print('Outfits received:', json.encode(outfits))
	else
		exports['qb-core']:Notify(Lang:t('error.no_outfits'), 'error')
	end
end)

-- Loop

Timer.SetInterval(function()
	if isLoggedIn then
		if not InApartment then
			SetClosestApartment()
			SetApartmentsEntranceTargets()
		elseif InApartment then
			SetInApartmentTargets()
		end
	end
end, 1000)
