local Lang = require('Shared/locales/en')
local ApartmentObjects = {}

-- Local Callback System
local RegisteredCallbacks = {}

local function RegisterCallback(name, cb)
	RegisteredCallbacks[name] = cb
end

RegisterServerEvent('apartments:server:TriggerCallback', function(source, cbName, requestId, ...)
	if RegisteredCallbacks[cbName] then
		local result = RegisteredCallbacks[cbName](source, ...)
		TriggerClientEvent(source, 'apartments:client:CallbackResponse', requestId, result)
	end
end)

-- Functions

local function CreateApartmentId(t)
	local MAX_ATTEMPTS = 50
	local attempts = 0
	local id, name, result
	repeat
		attempts = attempts + 1
		id = tostring(math.random(100000, 999999))
		name = tostring(t .. id)
		result = exports['qb-core']:DatabaseAction('Select', 'SELECT COUNT(*) as count FROM apartments WHERE name = ?', { name })
		if attempts >= MAX_ATTEMPTS then
			error(('[apartments] could not find unique id after %d attempts'):format(MAX_ATTEMPTS))
		end
	until (result and result[1] and tonumber(result[1].count) == 0)
	return id
end

local function GetApartmentInfo(apartmentId)
	local retval = nil
	local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM apartments WHERE name = ?', { apartmentId })
	if result and result[1] ~= nil then
		retval = result[1]
	end
	return retval
end

-- Events

RegisterServerEvent('qb-apartments:server:SetInsideMeta', function(source, house, insideId, bool, isVisiting)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	local insideMeta = Player.PlayerData.metadata['inside']
	if bool then
		--local routeId = insideId:gsub('[^%-%d]', '')
		if not isVisiting then
			insideMeta.apartment.apartmentType = house
			insideMeta.apartment.apartmentId = insideId
			insideMeta.house = nil
			--Player.Functions.SetMetaData('inside', insideMeta)
			exports['qb-core']:Player(source, 'SetMetaData', 'inside', insideMeta)
		end
		--exports['qb-core']:SetPlayerBucket(source, tonumber(routeId))
	else
		insideMeta.apartment.apartmentType = nil
		insideMeta.apartment.apartmentId = nil
		insideMeta.house = nil
		--Player.Functions.SetMetaData('inside', insideMeta)
		exports['qb-core']:Player(source, 'SetMetaData', 'inside', insideMeta)
		--exports['qb-core']:SetPlayerBucket(source, 1)
	end
end)

RegisterServerEvent('qb-apartments:server:LogoutLocation', function(source)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	exports['qb-core']:Logout(source)
	TriggerClientEvent(source, 'qb-multicharacter:client:chooseChar')
end)

RegisterServerEvent('qb-apartments:server:openStash', function(source, CurrentApartment)
	exports['qb-inventory']:OpenInventory(source, CurrentApartment)
end)

RegisterServerEvent('qb-apartments:server:CreateApartment', function(source, type, firstSpawn)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	local num = CreateApartmentId(type)
	local apartmentId = tostring(type .. num)
	local label = tostring(Apartments.Locations[type].label .. ' ' .. num)
	exports['qb-core']:DatabaseAction('Execute', 'INSERT INTO apartments (name, type, label, citizenid) VALUES (?, ?, ?, ?)', {
		apartmentId,
		type,
		label,
		Player.PlayerData.citizenid,
	})
	TriggerClientEvent(source, 'QBCore:Notify', Lang:t('success.receive_apart') .. ' (' .. label .. ')')
	if firstSpawn then
		TriggerClientEvent(source, 'qb-apartments:client:SpawnInApartment', apartmentId, type)
	end
	--TriggerClientEvent(source, 'qb-apartments:client:SetHomeBlip', type)
end)

RegisterServerEvent('qb-apartments:server:UpdateApartment', function(source, type, label)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	exports['qb-core']:DatabaseAction('Execute', 'UPDATE apartments SET type = ?, label = ? WHERE citizenid = ?', {
		type,
		label,
		Player.PlayerData.citizenid
	})
	TriggerClientEvent(source, 'QBCore:Notify', Lang:t('success.changed_apart'))
end)

RegisterServerEvent('qb-apartments:server:RingDoor', function(source, apartmentId, apartment)
	if ApartmentObjects[apartment].apartments[apartmentId] ~= nil and next(ApartmentObjects[apartment].apartments[apartmentId].players) ~= nil then
		for k in pairs(ApartmentObjects[apartment].apartments[apartmentId].players) do
			TriggerClientEvent(k, 'qb-apartments:client:RingDoor', source)
		end
	end
end)

RegisterServerEvent('qb-apartments:server:OpenDoor', function(target, apartmentId, apartment)
	local OtherPlayer = exports['qb-core']:GetPlayer(target)
	if not OtherPlayer then return end
	TriggerClientEvent(OtherPlayer.PlayerData.source, 'qb-apartments:client:SpawnInApartment', apartmentId, apartment)
end)

RegisterServerEvent('qb-apartments:server:AddObject', function(source, apartmentId, apartment, offset)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil and ApartmentObjects[apartment].apartments[apartmentId] ~= nil then
		ApartmentObjects[apartment].apartments[apartmentId].players[source] = Player.PlayerData.citizenid
	else
		if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
			ApartmentObjects[apartment].apartments[apartmentId] = {}
			ApartmentObjects[apartment].apartments[apartmentId].offset = offset
			ApartmentObjects[apartment].apartments[apartmentId].players = {}
			ApartmentObjects[apartment].apartments[apartmentId].players[source] = Player.PlayerData.citizenid
		else
			ApartmentObjects[apartment] = {}
			ApartmentObjects[apartment].apartments = {}
			ApartmentObjects[apartment].apartments[apartmentId] = {}
			ApartmentObjects[apartment].apartments[apartmentId].offset = offset
			ApartmentObjects[apartment].apartments[apartmentId].players = {}
			ApartmentObjects[apartment].apartments[apartmentId].players[source] = Player.PlayerData.citizenid
		end
	end
end)

RegisterServerEvent('qb-apartments:server:RemoveObject', function(source, apartmentId, apartment)
	if ApartmentObjects[apartment].apartments[apartmentId].players ~= nil then
		ApartmentObjects[apartment].apartments[apartmentId].players[source] = nil
		if next(ApartmentObjects[apartment].apartments[apartmentId].players) == nil then
			ApartmentObjects[apartment].apartments[apartmentId] = nil
		end
	end
end)

RegisterServerEvent('qb-apartments:server:setCurrentApartment', function(ap)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return end
	Player.Functions.SetMetaData('currentapartment', ap)
end)

-- Callbacks

RegisterCallback('apartments:GetAvailableApartments', function(source, apartment)
	local apartments = {}
	if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
		for k, _ in pairs(ApartmentObjects[apartment].apartments) do
			if (ApartmentObjects[apartment].apartments[k] ~= nil and next(ApartmentObjects[apartment].apartments[k].players) ~= nil) then
				local apartmentInfo = GetApartmentInfo(k)
				apartments[k] = apartmentInfo.label
			end
		end
	end
	return apartments
end)

RegisterCallback('qb-apartments:GetApartmentOffset', function(source, apartmentId)
	local retval = 0
	if ApartmentObjects ~= nil then
		for k, _ in pairs(ApartmentObjects) do
			if (ApartmentObjects[k].apartments[apartmentId] ~= nil and tonumber(ApartmentObjects[k].apartments[apartmentId].offset) ~= 0) then
				retval = tonumber(ApartmentObjects[k].apartments[apartmentId].offset)
			end
		end
	end
	return retval
end)

RegisterCallback('qb-apartments:GetApartmentOffsetNewOffset', function(source, apartment)
	local retval = Apartments.SpawnOffset
	if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
		for k, _ in pairs(ApartmentObjects[apartment].apartments) do
			if (ApartmentObjects[apartment].apartments[k] ~= nil) then
				retval = ApartmentObjects[apartment].apartments[k].offset + Apartments.SpawnOffset
			end
		end
	end
	return retval
end)

RegisterCallback('qb-apartments:GetOwnedApartment', function(source, cid)
	if cid then
		local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM apartments WHERE citizenid = ?', { cid })
		if result[1] ~= nil then
			return result[1]
		end
		return nil
	else
		local Player = exports['qb-core']:GetPlayer(source)
		if not Player then return nil end
		local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM apartments WHERE citizenid = ?', { Player.PlayerData.citizenid })
		if result[1] ~= nil then
			return result[1]
		end
		return nil
	end
end)

RegisterCallback('qb-apartments:IsOwner', function(source, apartment)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return nil end
	local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM apartments WHERE citizenid = ?', { Player.PlayerData.citizenid })
	if result[1] then
		if result[1].type == apartment then
			return true
		else
			return false
		end
	else
		return false
	end
end)

RegisterCallback('qb-apartments:GetOutfits', function(source)
	local Player = exports['qb-core']:GetPlayer(source)
	if not Player then return nil end
	local result = exports['qb-core']:DatabaseAction('Select', 'SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
	if result[1] then
		return result
	else
		return nil
	end
end)
