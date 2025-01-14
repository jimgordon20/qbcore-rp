local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local IsInside = false
local ClosestHouse = nil
local HasHouseKey = false
local isOwned = false
local cam = nil
local viewCam = false
local FrontCam = false
local stashLocation = nil
local outfitLocation = nil
local logoutLocation = nil
local OwnedHouseBlips = {}
local UnownedHouseBlips = {}
local CurrentDoorBell = 0
local rangDoorbell = nil
local houseObj = {}
local POIOffsets = nil
local data = nil
local CurrentHouse = nil
local keyholderMenu = {}
local keyholderOptions = {}
local stashTargetBoxID = 'stashTarget'
local outfitsTargetBoxID = 'outfitsTarget'
local charactersTargetBoxID = 'charactersTarget'

local function PlaySound(sound)
	Sound(Vector(), sound, true)
end

local function CheckDistance(target, distance)
	local player = Client.GetLocalPlayer()
	local ped = player:GetControlledCharacter()
	local pos = ped:GetLocation()
	return pos:Distance(target) <= distance
end

function CloseMenuFull()
	closeMenu()
end

-- Camera

-- local function setViewCam(coords, h, yaw)
-- 	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, yaw, 0.00, h, 80.00, false, 0)
-- 	SetCamActive(cam, true)
-- 	RenderScriptCams(true, true, 500, true, true)
-- 	viewCam = true
-- end

-- local function disableViewCam()
-- 	if viewCam then
-- 		RenderScriptCams(false, true, 500, true, true)
-- 		SetCamActive(cam, false)
-- 		DestroyCam(cam, true)
-- 		viewCam = false
-- 	end
-- end

-- local function FrontDoorCam(coords)
-- 	DoScreenFadeOut(150)
-- 	Wait(500)
-- 	cam = CreateCamWithParams(
-- 		"DEFAULT_SCRIPTED_CAMERA",
-- 		coords.x,
-- 		coords.y,
-- 		coords.z + 0.5,
-- 		0.0,
-- 		0.00,
-- 		coords.h - 180,
-- 		80.00,
-- 		false,
-- 		0
-- 	)
-- 	SetCamActive(cam, true)
-- 	RenderScriptCams(true, true, 500, true, true)
-- 	TriggerEvent("qb-weathersync:client:EnableSync")
-- 	FrontCam = true
-- 	FreezeEntityPosition(PlayerPedId(), true)
-- 	Wait(500)
-- 	DoScreenFadeIn(150)
-- 	SendNUIMessage({
-- 		type = "frontcam",
-- 		toggle = true,
-- 		label = Config.Houses[ClosestHouse].adress,
-- 	})
-- 	CreateThread(function()
-- 		while FrontCam do
-- 			local instructions = CreateInstuctionScaleform("instructional_buttons")
-- 			DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
-- 			SetTimecycleModifier("scanline_cam_cheap")
-- 			SetTimecycleModifierStrength(1.0)
-- 			if IsControlJustPressed(1, 194) then -- Backspace
-- 				DoScreenFadeOut(150)
-- 				SendNUIMessage({
-- 					type = "frontcam",
-- 					toggle = false,
-- 				})
-- 				Wait(500)
-- 				RenderScriptCams(false, true, 500, true, true)
-- 				FreezeEntityPosition(PlayerPedId(), false)
-- 				SetCamActive(cam, false)
-- 				DestroyCam(cam, true)
-- 				ClearTimecycleModifier("scanline_cam_cheap")
-- 				cam = nil
-- 				FrontCam = false
-- 				Wait(500)
-- 				DoScreenFadeIn(150)
-- 			end

-- 			local getCameraRot = GetCamRot(cam, 2)

-- 			-- ROTATE UP
-- 			if IsControlPressed(0, 32) then -- W
-- 				if getCameraRot.x <= 0.0 then
-- 					SetCamRot(cam, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
-- 				end
-- 			end

-- 			-- ROTATE DOWN
-- 			if IsControlPressed(0, 33) then -- S
-- 				if getCameraRot.x >= -50.0 then
-- 					SetCamRot(cam, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
-- 				end
-- 			end

-- 			-- ROTATE LEFT
-- 			if IsControlPressed(0, 34) then -- A
-- 				SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
-- 			end

-- 			-- ROTATE RIGHT
-- 			if IsControlPressed(0, 35) then -- D
-- 				SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
-- 			end

-- 			Wait(1)
-- 		end
-- 	end)
-- end

-- Keys

function HouseKeysMenu()
	QBCore.Functions.TriggerCallback('qb-houses:server:getHouseKeyHolders', function(holders)
		if holders == nil or next(holders) == nil then
			QBCore.Functions.Notify(Lang:t('error.no_key_holders'), 'error', 3500)
			CloseMenuFull()
		else
			keyholderMenu = {}

			for k, _ in pairs(holders) do
				keyholderMenu[#keyholderMenu + 1] = {
					header = holders[k].firstname .. ' ' .. holders[k].lastname,
					params = {
						event = 'qb-houses:client:OpenClientOptions',
						args = {
							citizenData = holders[k],
						},
					},
				}
			end
			openMenu(keyholderMenu)
		end
	end, ClosestHouse)
end

local function optionMenu(citizenData)
	keyholderOptions = {
		{
			header = Lang:t('menu.remove_key'),
			params = {
				event = 'qb-houses:client:RevokeKey',
				args = {
					citizenData = citizenData,
				},
			},
		},
		{
			header = Lang:t('menu.back'),
			params = {
				event = 'qb-houses:client:removeHouseKey',
				args = {},
			},
		},
	}

	openMenu(keyholderOptions)
end

-- Entrance

local function showEntranceHeaderMenu()
	local headerMenu = {}

	if QBCore.Functions.GetPlayerData().job and QBCore.Functions.GetPlayerData().job.name == 'realestate' then
		isOwned = true
	end

	if not isOwned then
		headerMenu[#headerMenu + 1] = {
			header = Lang:t('menu.view_house'),
			params = {
				isServer = true,
				event = 'qb-houses:server:viewHouse',
				args = { house = ClosestHouse },
			},
		}
	else
		if isOwned and HasHouseKey then
			headerMenu[#headerMenu + 1] = {
				header = Lang:t('menu.enter_house'),
				params = {
					event = 'qb-houses:client:EnterHouse',
					args = {},
				},
			}
			headerMenu[#headerMenu + 1] = {
				header = Lang:t('menu.give_house_key'),
				params = {
					event = 'qb-houses:client:giveHouseKey',
					args = {},
				},
			}
		elseif isOwned and not HasHouseKey then
			headerMenu[#headerMenu + 1] = {
				header = Lang:t('menu.ring_door'),
				params = {
					event = 'qb-houses:client:RequestRing',
					args = {},
				},
			}
			headerMenu[#headerMenu + 1] = {
				header = Lang:t('menu.enter_unlocked_house'),
				params = {
					event = 'qb-houses:client:EnterHouse',
					args = {},
				},
			}
			if QBCore.Functions.GetPlayerData().job and QBCore.Functions.GetPlayerData().job.name == 'police' then
				headerMenu[#headerMenu + 1] = {
					header = Lang:t('menu.lock_door_police'),
					params = {
						event = 'qb-houses:client:ResetHouse',
						args = {},
					},
				}
			end
		else
			headerMenu = {}
		end
	end

	headerMenu[#headerMenu + 1] = {
		header = Lang:t('menu.close_menu'),
		params = {
			event = 'qb-menu:client:closeMenu',
		},
	}

	if headerMenu and next(headerMenu) then
		openMenu(headerMenu)
	end
end

local function RegisterHouseEntranceZone(id, house)
	local coords = Vector(house.coords['enter'].x, house.coords['enter'].y, house.coords['enter'].z)
	local boxName = 'houseEntrance_' .. id
	local boxData = Config.Targets[boxName] or {}

	if boxData and boxData.created then
		return
	end

	local options = {
		{
			icon = 'fas fa-box-open',
			label = 'House Menu',
			action = function()
				showEntranceHeaderMenu()
			end,
		},
	}

	AddBoxZone(boxName, coords, 2.0, 1.0, {
		name = boxName,
		heading = house.coords['enter'].h,
	}, {
		options = options,
		distance = 500,
	})

	Config.Targets[boxName] = { created = true, zone = zone }
end

-- local function DeleteHousesTargets()
-- 	if Config.Targets and next(Config.Targets) then
-- 		for id in pairs(Config.Targets) do
-- 			if not string.find(id, "Exit") then
-- 				RemoveZone(id)
-- 				Config.Targets[id] = nil
-- 			end
-- 		end
-- 	end
-- end

local function SetHousesEntranceTargets()
	if Config.Houses and next(Config.Houses) then
		for id, house in pairs(Config.Houses) do
			if house and house.coords and house.coords['enter'] then
				RegisterHouseEntranceZone(id, house)
			end
		end
	end
end

-- Exit

local function showExitHeaderMenu()
	local headerMenu = {}
	headerMenu[#headerMenu + 1] = {
		header = Lang:t('menu.exit_property'),
		params = {
			event = 'qb-houses:client:ExitOwnedHouse',
			args = {},
		},
	}
	if isOwned then
		headerMenu[#headerMenu + 1] = {
			header = Lang:t('menu.front_camera'),
			params = {
				event = 'qb-houses:client:FrontDoorCam',
				args = {},
			},
		}
		headerMenu[#headerMenu + 1] = {
			header = Lang:t('menu.open_door'),
			params = {
				event = 'qb-houses:client:AnswerDoorbell',
				args = {},
			},
		}
	end

	headerMenu[#headerMenu + 1] = {
		header = Lang:t('menu.close_menu'),
		params = {
			event = 'qb-menu:client:closeMenu',
		},
	}

	if headerMenu and next(headerMenu) then
		openMenu(headerMenu)
	end
end

local function RegisterHouseExitZone(id)
	if not Config.Houses[id] then
		return
	end

	local boxName = 'houseExit_' .. id
	local boxData = Config.Targets[boxName] or {}
	if boxData and boxData.created then
		return
	end

	if not POIOffsets then
		return
	end

	local house = Config.Houses[id]
	local coords = Vector(
		house.coords['enter'].x - POIOffsets.exit.x,
		house.coords['enter'].y - POIOffsets.exit.y,
		house.coords['enter'].z - Config.MinZOffset + POIOffsets.exit.z
	)

	local options = {
		{
			icon = 'fas fa-box-open',
			label = 'House Menu',
			action = function()
				showExitHeaderMenu()
			end,
		},
	}

	AddBoxZone(boxName, coords, 2.0, 1.0, {
		name = boxName,
		heading = 0,
	}, {
		options = options,
		distance = 500,
	})

	Config.Targets[boxName] = { created = true, zone = zone }
end

-- Stash

local function openHouseStash()
	if not CurrentHouse then
		return
	end
	local stashLoc = Vector(stashLocation.x, stashLocation.y, stashLocation.z)
	if CheckDistance(stashLoc, 500) then
		PlaySound('package://qb-houses/Client/sounds/StashOpen.ogg')
		Events.CallRemote('qb-houses:server:openStash', CurrentHouse)
	end
end

local function RegisterStashTarget()
	if not stashLocation then
		return
	end

	local options = {
		{
			icon = 'fas fa-box-open',
			label = Lang:t('target.open_stash'),
			action = function()
				openHouseStash()
			end,
		},
	}

	AddBoxZone(stashTargetBoxID, Vector(stashLocation.x, stashLocation.y, stashLocation.z), 1.5, 1.5, {
		name = stashTargetBoxID,
		heading = 0,
	}, {
		options = options,
		distance = 500,
	})
end

-- Outfit

local function openOutfitMenu()
	if not CurrentHouse then
		return
	end
	local outfitLoc = Vector(outfitLocation.x, outfitLocation.y, outfitLocation.z)
	if CheckDistance(outfitLoc, 500) then
		PlaySound('package://qb-houses/Client/sounds/Clothes1.ogg')
		Events.Call('qb-clothing:client:openOutfitMenu')
	end
end

local function RegisterOutfitsTarget()
	if not outfitLocation then
		return
	end

	local options = {
		{
			icon = 'fas fa-box-open',
			label = Lang:t('target.outfits'),
			action = function()
				openOutfitMenu()
			end,
		},
	}

	AddBoxZone(outfitsTargetBoxID, Vector(outfitLocation.x, outfitLocation.y, outfitLocation.z), 1.5, 1.5, {
		name = outfitsTargetBoxID,
		heading = 0,
	}, {
		options = options,
		distance = 500,
	})
end

-- Logout

local function changeCharacter()
	if not CurrentHouse then
		return
	end
	local logoutLoc = Vector(logoutLocation.x, logoutLocation.y, logoutLocation.z)
	if CheckDistance(logoutLoc, 500) then
		DespawnInterior(houseObj, function()
			Events.Call('qb-weathersync:client:EnableSync')
			InOwnedHouse = false
			IsInside = false
			Events.CallRemote('qb-houses:server:LogoutLocation')
		end)
	end
end

local function RegisterCharactersTarget()
	if not logoutLocation then
		return
	end

	local options = {
		{
			icon = 'fas fa-box-open',
			label = Lang:t('target.change_character'),
			action = function()
				changeCharacter()
			end,
		},
	}

	AddBoxZone(charactersTargetBoxID, Vector(logoutLocation.x, logoutLocation.y, logoutLocation.z), 1.5, 1.5, {
		name = charactersTargetBoxID,
		heading = 0,
	}, {
		options = options,
		distance = 500,
	})
end

local function DeleteBoxTarget(box)
	if not box then
		return
	end
	RemoveZone(box)
end

local function setHouseLocations()
	if ClosestHouse then
		QBCore.Functions.TriggerCallback('qb-houses:server:getHouseLocations', function(result)
			if result then
				if result.stash then
					stashLocation = JSON.parse(result.stash)
					RegisterStashTarget()
				end
				if result.outfit then
					outfitLocation = JSON.parse(result.outfit)
					RegisterOutfitsTarget()
				end
				if result.logout then
					logoutLocation = JSON.parse(result.logout)
					RegisterCharactersTarget()
				end
			end
		end, ClosestHouse)
	end
end

local function getDataForHouseTier(house, coords)
	if Config.Houses[house].tier == 1 then
		return CreateApartmentFurnished(coords)
	elseif Config.Houses[house].tier == 2 then
		return CreateContainer(coords)
	elseif Config.Houses[house].tier == 3 then
		return CreateFurniMid(coords)
	elseif Config.Houses[house].tier == 4 then
		return CreateFranklinAunt(coords)
	elseif Config.Houses[house].tier == 5 then
		return CreateGarageMed(coords)
	elseif Config.Houses[house].tier == 6 then
		return CreateLesterShell(coords)
	elseif Config.Houses[house].tier == 7 then
		return CreateOffice1(coords)
	elseif Config.Houses[house].tier == 8 then
		return CreateStore1(coords)
	elseif Config.Houses[house].tier == 9 then
		return CreateTrailer(coords)
	elseif Config.Houses[house].tier == 10 then
		return CreateWarehouse1(coords)
	elseif Config.Houses[house].tier == 11 then
		return CreateStandardMotel(coords)
	else
		QBCore.Functions.Notify(Lang:t('error.invalid_tier'), 'error')
	end
end

local function enterOwnedHouse(house)
	CurrentHouse = house
	ClosestHouse = house
	PlaySound('package://qb-houses/Client/sounds/houses_door_open.ogg')
	--openHouseAnim()
	IsInside = true
	local coords = Vector(
		Config.Houses[house].coords.enter.x,
		Config.Houses[house].coords.enter.y,
		Config.Houses[house].coords.enter.z - Config.MinZOffset
	)
	--LoadDecorations(house)
	data = getDataForHouseTier(house, coords)
	houseObj = data[1]
	POIOffsets = data[2]
	Events.CallRemote('qb-houses:server:SetInsideMeta', house, true)
	Events.Call('qb-weathersync:client:DisableSync')
	setHouseLocations()
	CloseMenuFull()
	RegisterHouseExitZone(house)
end

local function enterNonOwnedHouse(house)
	CurrentHouse = house
	ClosestHouse = house
	PlaySound('package://qb-houses/Client/sounds/houses_door_open.ogg')
	--openHouseAnim()
	IsInside = true
	local coords = Vector(
		Config.Houses[ClosestHouse].coords.enter.x,
		Config.Houses[ClosestHouse].coords.enter.y,
		Config.Houses[ClosestHouse].coords.enter.z - Config.MinZOffset
	)
	--LoadDecorations(house)
	data = getDataForHouseTier(house, coords)
	houseObj = data[1]
	POIOffsets = data[2]
	Events.CallRemote('qb-houses:server:SetInsideMeta', house, true)
	Events.Call('qb-weathersync:client:DisableSync')
	InOwnedHouse = true
	setHouseLocations()
	CloseMenuFull()
	RegisterHouseExitZone(house)
end

local function LeaveHouse(house)
	if not FrontCam then
		IsInside = false
		PlaySound('package://qb-houses/Client/sounds/houses_door_close.ogg')
		--openHouseAnim()
		DespawnInterior(houseObj, function()
			--UnloadDecorations()
			Events.Call('qb-weathersync:client:EnableSync')
			Events.CallRemote(
				'qb-interior:server:teleportPlayer',
				Config.Houses[CurrentHouse].coords.enter.x,
				Config.Houses[CurrentHouse].coords.enter.y,
				Config.Houses[CurrentHouse].coords.enter.z,
				0
			)
			Events.CallRemote('qb-houses:server:SetInsideMeta', house, false)
			CurrentHouse = nil
			DeleteBoxTarget(stashTargetBoxID)
			DeleteBoxTarget(outfitsTargetBoxID)
			DeleteBoxTarget(charactersTargetBoxID)
			DeleteBoxTarget(Config.Targets['houseExit_' .. house].zone)
			Config.Targets['houseExit_' .. house] = nil
		end)
	end
end

local function SetClosestHouse()
	local player = Client.GetLocalPlayer()
	local ped = player:GetControlledCharacter()
	if not ped then
		return
	end
	local pos = ped:GetLocation()
	local current = nil
	local dist = nil
	if not IsInside then
		for id, _ in pairs(Config.Houses) do
			local distcheck = pos:Distance(
				Vector(
					Config.Houses[id].coords.enter.x,
					Config.Houses[id].coords.enter.y,
					Config.Houses[id].coords.enter.z
				)
			)
			if current then
				if distcheck < dist then
					current = id
					dist = distcheck
				end
			else
				dist = distcheck
				current = id
			end
		end
		ClosestHouse = current
		if ClosestHouse and tonumber(dist) < 100 then
			QBCore.Functions.TriggerCallback('qb-houses:server:ProximityKO', function(key, owned)
				HasHouseKey = key
				isOwned = owned
			end, ClosestHouse)
		end
	end

	if ClosestHouse and next(Config.Houses[ClosestHouse].garage) == nil then
		return
	end
	Events.Call('qb-garages:client:setHouseGarage', ClosestHouse, HasHouseKey)
end

-- Events

Package.Subscribe('Load', function()
	Events.CallRemote('qb-houses:server:setHouses')
	Events.Call('qb-houses:client:setupHouseBlips')
	if Config.UnownedBlips then
		Events.Call('qb-houses:client:setupHouseBlips2')
	end
	if ClosestHouse and next(Config.Houses[ClosestHouse].garage) == nil then
		return
	end
	Events.Call('qb-garages:client:setHouseGarage', ClosestHouse, HasHouseKey)
end)

Events.Subscribe('QBCore:Client:OnPlayerLoaded', function()
	Events.CallRemote('qb-houses:server:setHouses')
	Events.Call('qb-houses:client:setupHouseBlips')
	if Config.UnownedBlips then
		Events.Call('qb-houses:client:setupHouseBlips2')
	end
	if ClosestHouse and next(Config.Houses[ClosestHouse].garage) == nil then
		return
	end
	Events.Call('qb-garages:client:setHouseGarage', ClosestHouse, HasHouseKey)
end)

Events.Subscribe('QBCore:Client:OnPlayerUnload', function()
	IsInside = false
	ClosestHouse = nil
	HasHouseKey = false
	isOwned = false
	-- for _, v in pairs(OwnedHouseBlips) do
	--     RemoveBlip(v)
	-- end
	-- if Config.UnownedBlips then
	--     for _, v in pairs(UnownedHouseBlips) do
	--         RemoveBlip(v)
	--     end
	-- end
	--DeleteHousesTargets()
end)

Events.SubscribeRemote('qb-houses:client:setHouseConfig', function(houseConfig)
	Config.Houses = houseConfig
	--DeleteHousesTargets()
	SetHousesEntranceTargets()
end)

Events.SubscribeRemote('qb-houses:client:viewHouse', function(house, houseprice, brokerfee, bankfee, taxes)
	local house_label = Config.Houses[house].adress
	local house_cost = {
		{
			disabled = true,
			header = 'House: ' .. house_label,
			params = {},
		},
		{
			disabled = true,
			header = 'Broker Fee $' .. brokerfee,
			params = {},
		},
		{
			disabled = true,
			header = 'Bank Fee $' .. bankfee,
			params = {},
		},
		{
			disabled = true,
			header = 'Taxes $' .. taxes,
			params = {},
		},
		{
			header = 'Purchase $' .. houseprice,
			params = {
				event = 'qb-houses:client:buyHouse',
				args = { house = house },
			},
		},
		{
			header = Lang:t('menu.close_menu'),
			params = {
				event = 'qb-menu:client:closeMenu',
			},
		},
	}
	openMenu(house_cost)
end)

Events.Subscribe('qb-houses:client:buyHouse', function(houseData)
	local house = houseData.house
	Events.CallRemote('qb-houses:server:buyHouse', house)
end)

Events.Subscribe('qb-houses:client:ExitOwnedHouse', function()
	if not POIOffsets then
		return
	end
	local door = Vector(
		Config.Houses[CurrentHouse].coords.enter.x - POIOffsets.exit.x,
		Config.Houses[CurrentHouse].coords.enter.y - POIOffsets.exit.y,
		Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z
	)
	if CheckDistance(door, 500) then
		LeaveHouse(CurrentHouse)
	end
end)

Events.Subscribe('qb-houses:client:FrontDoorCam', function()
	if not POIOffsets then
		return
	end
	local door = Vector(
		Config.Houses[CurrentHouse].coords.enter.x - POIOffsets.exit.x,
		Config.Houses[CurrentHouse].coords.enter.y - POIOffsets.exit.y,
		Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z
	)
	if CheckDistance(door, 500) then
		FrontDoorCam(Config.Houses[CurrentHouse].coords.enter)
	end
end)

Events.SubscribeRemote('qb-houses:server:sethousedecorations', function(house, decorations)
	Config.Houses[house].decorations = decorations
	if IsInside and ClosestHouse == house then
		LoadDecorations(house)
	end
end)

Events.SubscribeRemote('qb-houses:client:sellHouse', function()
	if ClosestHouse and HasHouseKey then
		Events.CallRemote('qb-houses:server:viewHouse', ClosestHouse)
	end
end)

Events.Subscribe('qb-houses:client:EnterHouse', function()
	if not ClosestHouse then
		return
	end

	if
		CheckDistance(
			Vector(
				Config.Houses[ClosestHouse].coords.enter.x,
				Config.Houses[ClosestHouse].coords.enter.y,
				Config.Houses[ClosestHouse].coords.enter.z
			),
			500
		)
	then
		if HasHouseKey then
			enterOwnedHouse(ClosestHouse)
		else
			if not Config.Houses[ClosestHouse].locked then
				enterNonOwnedHouse(ClosestHouse)
			end
		end
	end
end)

Events.Subscribe('qb-houses:client:RequestRing', function()
	if not ClosestHouse then
		return
	end
	Events.CallRemote('qb-houses:server:RingDoor', ClosestHouse)
end)

Events.Subscribe('qb-houses:client:removeHouseKey', function()
	if not ClosestHouse then
		return
	end
	if
		CheckDistance(
			Vector(
				Config.Houses[ClosestHouse].coords.enter.x,
				Config.Houses[ClosestHouse].coords.enter.y,
				Config.Houses[ClosestHouse].coords.enter.z
			),
			500
		)
	then
		QBCore.Functions.TriggerCallback('qb-houses:server:getHouseOwner', function(result)
			if QBCore.Functions.GetPlayerData().citizenid == result then
				HouseKeysMenu()
			else
				QBCore.Functions.Notify(Lang:t('error.not_owner'), 'error')
			end
		end, ClosestHouse)
	else
		QBCore.Functions.Notify(Lang:t('error.no_door'), 'error')
	end
end)

Events.Subscribe('qb-houses:client:RevokeKey', function(cData)
	RemoveHouseKey(cData.citizenData)
end)

Events.SubscribeRemote('qb-houses:client:refreshHouse', function()
	SetClosestHouse()
end)

Events.SubscribeRemote('qb-houses:client:SetClosestHouse', function()
	SetClosestHouse()
end)

Events.SubscribeRemote('qb-houses:client:SpawnInApartment', function(house)
	local player = Client.GetLocalPlayer()
	local ped = player:GetControlledCharacter()
	local pos = ped:GetLocation()
	if rangDoorbell then
		if
			#(
				pos
				- Vector(
					Config.Houses[house].coords.enter.x,
					Config.Houses[house].coords.enter.y,
					Config.Houses[house].coords.enter.z
				)
			) > 500
		then
			return
		end
	end
	ClosestHouse = house
	enterNonOwnedHouse(house)
end)

Events.SubscribeRemote('qb-houses:client:enterOwnedHouse', function(house)
	QBCore.Functions.GetPlayerData(function(PlayerData)
		if PlayerData.metadata['injail'] == 0 then
			enterOwnedHouse(house)
		end
	end)
end)

Events.SubscribeRemote('qb-houses:client:LastLocationHouse', function(houseId)
	QBCore.Functions.GetPlayerData(function(PlayerData)
		if PlayerData.metadata['injail'] == 0 then
			enterOwnedHouse(houseId)
		end
	end)
end)

Events.Subscribe('qb-houses:client:setLocation', function(cData)
	local client = Client.GetLocalPlayer()
	local ped = client:GetControlledCharacter()
	local pos = ped:GetLocation()
	local coords = { x = pos.X, y = pos.Y, z = pos.Z }
	if IsInside then
		if HasHouseKey then
			if cData.id == 'setstash' then
				Events.CallRemote('qb-houses:server:setLocation', coords, ClosestHouse, 1)
			elseif cData.id == 'setoutift' then
				Events.CallRemote('qb-houses:server:setLocation', coords, ClosestHouse, 2)
			elseif cData.id == 'setlogout' then
				Events.CallRemote('qb-houses:server:setLocation', coords, ClosestHouse, 3)
			end
		else
			QBCore.Functions.Notify(Lang:t('error.not_owner'), 'error')
		end
	else
		QBCore.Functions.Notify(Lang:t('error.not_in_house'), 'error')
	end
end)

Events.SubscribeRemote('qb-houses:client:refreshLocations', function(house, location, type)
	if ClosestHouse == house then
		if IsInside then
			if type == 1 then
				stashLocation = JSON.parse(location)
				DeleteBoxTarget(stashTargetBoxID)
				RegisterStashTarget()
			elseif type == 2 then
				outfitLocation = JSON.parse(location)
				DeleteBoxTarget(outfitsTargetBoxID)
				RegisterOutfitsTarget()
			elseif type == 3 then
				logoutLocation = JSON.parse(location)
				DeleteBoxTarget(charactersTargetBoxID)
				RegisterCharactersTarget()
			end
		end
	end
end)

Events.Subscribe('qb-houses:client:AnswerDoorbell', function()
	if not POIOffsets then
		return
	end
	if not CurrentDoorBell or CurrentDoorBell == 0 then
		QBCore.Functions.Notify(Lang:t('error.nobody_at_door'))
		return
	end
	local door = Vector(
		Config.Houses[CurrentHouse].coords.enter.x - POIOffsets.exit.x,
		Config.Houses[CurrentHouse].coords.enter.y - POIOffsets.exit.y,
		Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z
	)
	if CheckDistance(door, 500) and CurrentDoorBell ~= 0 then
		Events.CallRemote('qb-houses:server:OpenDoor', CurrentDoorBell, ClosestHouse)
		CurrentDoorBell = 0
	end
end)

Events.SubscribeRemote('qb-house:client:RefreshHouseTargets', function()
	--DeleteHousesTargets()
	SetHousesEntranceTargets()
end)

Events.SubscribeRemote('qb-houses:client:lockHouse', function(bool, house)
	Config.Houses[house].locked = bool
end)

Events.SubscribeRemote('qb-houses:client:RingDoor', function(player, house)
	if ClosestHouse == house and IsInside then
		CurrentDoorBell = player
		PlaySound('package://qb-houses/Client/sounds/doorbell.ogg')
		QBCore.Functions.Notify(Lang:t('info.door_ringing'))
	end
end)

Events.Subscribe('qb-houses:client:giveHouseKey', function()
	local client = Client.GetLocalPlayer()
	local ped = client:GetControlledCharacter()
	local coords = ped:GetLocation()
	local player, distance = QBCore.Functions.GetClosestPlayer()
	if player ~= -1 and distance < 2.5 and ClosestHouse then
		local playerId = player:GetID()
		local housedist = #(coords - Vector(
			Config.Houses[ClosestHouse].coords.enter.x,
			Config.Houses[ClosestHouse].coords.enter.y,
			Config.Houses[ClosestHouse].coords.enter.z
		)
		)
		if housedist < 500 then
			Events.CallRemote('qb-houses:server:giveHouseKey', playerId, ClosestHouse)
		else
			QBCore.Functions.Notify(Lang:t('error.no_door'), 'error')
		end
	elseif ClosestHouse == nil then
		QBCore.Functions.Notify(Lang:t('error.no_house'), 'error')
	else
		QBCore.Functions.Notify(Lang:t('error.no_one_near'), 'error')
	end
end)

Events.Subscribe('qb-houses:client:KeyholderOptions', function(cData)
	optionMenu(cData.citizenData)
end)

-- Map Blips

-- Events.Subscribe("qb-houses:client:setupHouseBlips", function() -- Setup owned on load
-- 	QBCore.Functions.TriggerCallback("qb-houses:server:getOwnedHouses", function(ownedHouses)
-- 		if ownedHouses then
-- 			for k, _ in pairs(ownedHouses) do
-- 				local house = Config.Houses[ownedHouses[k]]
-- 				local HouseBlip = AddBlipForCoord(house.coords.enter.x, house.coords.enter.y, house.coords.enter.z)
-- 				SetBlipSprite(HouseBlip, 40)
-- 				SetBlipDisplay(HouseBlip, 4)
-- 				SetBlipScale(HouseBlip, 0.65)
-- 				SetBlipAsShortRange(HouseBlip, true)
-- 				SetBlipColour(HouseBlip, 3)
-- 				AddTextEntry("OwnedHouse", house.adress)
-- 				BeginTextCommandSetBlipName("OwnedHouse")
-- 				EndTextCommandSetBlipName(HouseBlip)
-- 				OwnedHouseBlips[#OwnedHouseBlips + 1] = HouseBlip
-- 			end
-- 		end
-- 	end)
-- end)

-- Events.Subscribe("qb-houses:client:setupHouseBlips2", function() -- Setup unowned on load
-- 	for _, v in pairs(Config.Houses) do
-- 		if not v.owned then
-- 			local HouseBlip2 = AddBlipForCoord(v.coords.enter.x, v.coords.enter.y, v.coords.enter.z)
-- 			SetBlipSprite(HouseBlip2, 40)
-- 			SetBlipDisplay(HouseBlip2, 4)
-- 			SetBlipScale(HouseBlip2, 0.65)
-- 			SetBlipAsShortRange(HouseBlip2, true)
-- 			SetBlipColour(HouseBlip2, 3)
-- 			AddTextEntry("UnownedHouse", Lang:t("info.house_for_sale"))
-- 			BeginTextCommandSetBlipName("UnownedHouse")
-- 			EndTextCommandSetBlipName(HouseBlip2)
-- 			UnownedHouseBlips[#UnownedHouseBlips + 1] = HouseBlip2
-- 		end
-- 	end
-- end)

-- Events.SubscribeRemote("qb-houses:client:createBlip", function(coords) -- Create unowned on command
-- 	local NewHouseBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
-- 	SetBlipSprite(NewHouseBlip, 40)
-- 	SetBlipDisplay(NewHouseBlip, 4)
-- 	SetBlipScale(NewHouseBlip, 0.65)
-- 	SetBlipAsShortRange(NewHouseBlip, true)
-- 	SetBlipColour(NewHouseBlip, 3)
-- 	AddTextEntry("NewHouseBlip", Lang:t("info.house_for_sale"))
-- 	BeginTextCommandSetBlipName("NewHouseBlip")
-- 	EndTextCommandSetBlipName(NewHouseBlip)
-- 	UnownedHouseBlips[#UnownedHouseBlips + 1] = NewHouseBlip
-- end)

-- Events.Subscribe("qb-houses:client:refreshBlips", function() -- Refresh unowned on buy
-- 	for _, v in pairs(UnownedHouseBlips) do
-- 		RemoveBlip(v)
-- 	end
-- 	Events.Call("qb-houses:client:setupHouseBlips2")
-- 	DeleteHousesTargets()
-- 	SetHousesEntranceTargets()
-- end)

-- Loops

Timer.SetInterval(function()
	if Client.GetValue('isLoggedIn', false) then
		if not IsInside then
			SetClosestHouse()
		end
	end
end, 500)

-- Command

Console.RegisterCommand('getoffset', function()
	if not CurrentHouse then
		return
	end
	local client = Client.GetLocalPlayer()
	local ped = client:GetControlledCharacter()
	local coords = ped:GetLocation()
	local houseCoords = Vector(
		Config.Houses[CurrentHouse].coords.enter.x,
		Config.Houses[CurrentHouse].coords.enter.y,
		Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset
	)
	if IsInside then
		local xdist = houseCoords.X - coords.X
		local ydist = houseCoords.Y - coords.Y
		local zdist = houseCoords.Z - coords.Z
		print('X: ' .. xdist)
		print('Y: ' .. ydist)
		print('Z: ' .. zdist)
	end
end, '', {})
