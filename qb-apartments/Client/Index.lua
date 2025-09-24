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
		debug = true,
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

-- utility functions

local function EnterApartment(house, apartmentId, new)
	CurrentOffset = 0
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
	--TriggerLocalClientEvent('qb-weathersync:client:DisableSync')
	TriggerServerEvent('qb-apartments:server:SetInsideMeta', ClosestHouse, CurrentApartment, true, true)
	--Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
	TriggerServerEvent('qb-apartments:server:setCurrentApartment', CurrentApartment)
	TriggerLocalClientEvent('qb-interior:client:SetNewState', false)
end

local function LeaveApartment(house)
	--Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
	--TriggerServerEvent('qb-apartments:returnBucket')
	--Client.GetLocalPlayer():StartCameraFade(0, 1, 0.1, Color(0, 0, 0, 1), true, true)
	exports['qb-interior']:DespawnInterior(HouseObj, function()
		--TriggerLocalClientEvent('qb-weathersync:client:EnableSync')
		TriggerServerEvent('qb-interior:server:teleportPlayer', Apartments.Locations[house].coords[1], Apartments.Locations[house].coords[2], Apartments.Locations[house].coords[3], 0)
		TriggerServerEvent('qb-apartments:server:RemoveObject', CurrentApartment, house)
		TriggerServerEvent('qb-apartments:server:SetInsideMeta', CurrentApartment, false)
		CurrentApartment = nil
		InApartment = false
		CurrentOffset = 0
		--Sound(Vector(), 'package://qb-apartments/Client/houses_door_close.ogg', true)
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
			SetApartmentsEntranceTargets()
		end
	end
	if current ~= ClosestHouse and not InApartment then
		ClosestHouse = current
		TriggerServerEvent('qb-apartments:server:IsOwner', ClosestHouse)
	end
end

function MenuOwners()
	TriggerServerEvent('qb-apartments:server:GetAvailableApartments', ClosestHouse)
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
	if cData then -- existing character
		--TriggerServerEvent('qb-apartments:server:GetOwnedApartment', cData.citizenid)
		TriggerLocalClientEvent('qb-spawn:client:openUI', true, nil, false, nil)
	else -- new character
		if Apartments.Starting then
			TriggerLocalClientEvent('qb-spawn:client:openUI', true, nil, true, Apartments.Locations)
		else
			TriggerLocalClientEvent('qb-spawn:client:openUI', true, nil, false, nil)
			--TriggerLocalClientEvent('qb-apartments:client:SetHomeBlip', nil)
		end
	end
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

-- RegisterClientEvent('qb-apartments:client:SetHomeBlip', function(home)
-- 	SetClosestApartment()
-- 	for name, _ in pairs(Apartments.Locations) do
-- 		local coords = {
-- 			x = Apartments.Locations[name].coords[1],
-- 			y = Apartments.Locations[name].coords[2],
-- 			z = Apartments.Locations[name].coords[3],
-- 		}
-- 		TriggerLocalClientEvent('Map:RemoveBlip', Apartments.Locations[name].blip)
-- 		Apartments.Locations[name].blip = TriggerLocalClientEvent('Map:AddBlip', {
-- 			id = name,
-- 			name = Apartments.Locations[name].label,
-- 			imgUrl = './media/map-icons/apt_owned.svg',
-- 			coords = coords,
-- 		})
-- 	end
-- end)

RegisterClientEvent('qb-apartments:client:RingMenu', function(data)
	RangDoorbell = ClosestHouse
	--TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
	TriggerServerEvent('qb-apartments:server:RingDoor', data.apartmentId, ClosestHouse)
end)

RegisterClientEvent('qb-apartments:client:RingDoor', function(player)
	CurrentDoorBell = player
	--TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
	exports['qb-core']:Notify(Lang:t('info.at_the_door'))
end)

RegisterClientEvent('qb-apartments:client:DoorbellMenu', function()
	MenuOwners()
end)

RegisterClientEvent('qb-apartments:client:EnterApartment', function()
	TriggerServerEvent('qb-apartments:server:GetOwnedApartment', exports['qb-core']:GetPlayerData().citizenid)
end)

RegisterClientEvent('qb-apartments:client:UpdateApartment', function()
	local apartmentType = ClosestHouse
	local apartmentLabel = Apartments.Locations[ClosestHouse].label
	TriggerServerEvent('qb-apartments:server:GetOwnedApartment', nil)
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
	print('------------------')
	print('qb-apartments:client:LeaveApartment')
	print('------------------')
	LeaveApartment(ClosestHouse)
end)

RegisterClientEvent('qb-apartments:client:GetApartmentOffset', function(offset)
	print('------------------')
	print('qb-apartments:client:GetApartmentOffset')
	print('------------------')
	--if offset == nil or offset == 0 then
	--	TriggerServerEvent('qb-apartments:server:GetOwnedApartment', ClosestHouse)
	--else
	-- if offset > 730 then
	-- 	offset = 710
	-- end
	-- CurrentOffset = offset
	-- --TriggerServerEvent('qb-apartments:server:AddObject', CurrentApartment, ClosestHouse, CurrentOffset)
	-- local coords = Vector(
	-- 	Apartments.Locations[ClosestHouse].coords[1],
	-- 	Apartments.Locations[ClosestHouse].coords[2],
	-- 	Apartments.Locations[ClosestHouse].coords[3] - CurrentOffset
	-- )
	-- local data = exports['qb-interior']:CreateApartmentFurnished(coords)
	-- HouseObj = data[1]
	-- POIOffsets = data[2]
	-- InApartment = true
	-- --TriggerLocalClientEvent('qb-weathersync:client:DisableSync')
	-- TriggerServerEvent('qb-apartments:server:SetInsideMeta', ClosestHouse, CurrentApartment, true, true)
	-- --Sound(Vector(), 'package://qb-apartments/Client/houses_door_open.ogg', true)
	-- TriggerServerEvent('qb-apartments:server:setCurrentApartment', CurrentApartment)
	-- --if Input.IsMouseEnabled() then Input.SetMouseEnabled(false) end
	-- TriggerLocalClientEvent('qb-interior:client:SetNewState', false)
	--end
end)

-- RegisterClientEvent('qb-apartments:client:GetOwnedApartment', function(result)
-- 	print('------------------')
-- 	print('qb-apartments:client:GetOwnedApartment')
-- 	print('------------------')
-- 	if result then
-- 		TriggerLocalClientEvent('qb-spawn:client:openUI', true, cData, false, nil)
-- 		--TriggerLocalClientEvent('qb-apartments:client:SetHomeBlip', result.type)
-- 	end
-- end)

RegisterClientEvent('qb-apartments:client:IsOwner', function(isOwner)
	IsOwned = isOwner
	DeleteApartmentsEntranceTargets()
	DeleteInApartmentTargets()
end)

RegisterClientEvent('qb-apartments:client:GetAvailableApartments', function(apartments)
	if next(apartments) == nil then
		exports['qb-core']:Notify(Lang:t('error.nobody_home'), 'error')
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
