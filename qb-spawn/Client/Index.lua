local Lang = require('Shared/locales/en')
local Houses = {}
local my_webui = nil

-- Functions

local function SetDisplay(bool, cData, new, apps)
	local translations = {}
	for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
		if k:sub(0, #'ui.') then
			translations[k:sub(#'ui.' + 1)] = Lang:t(k)
		end
	end

	if not bool then
		my_webui:Destroy()
		return
	end

	my_webui = WebUI('qb-spawn', 'qb-spawn/Client/html/index.html', true)
	-- NUI Events
	my_webui:RegisterEventHandler('qb-spawn:setCam', function(data)
		local location = tostring(data.posname)
		local type = tostring(data.type)
		if type == 'current' then

		elseif type == 'house' then
			SetCam(Houses[location].coords.enter)
		elseif type == 'normal' then
			SetCam(Config.Spawns[location].coords)
		elseif type == 'appartment' then
			SetCam(Apartments.Locations[location].coords.enter)
		end
	end)

	my_webui:RegisterEventHandler('qb-spawn:chooseAppa', function(data)
		local appaYeet = data.appType
		SetDisplay(false)
		Timer.SetNextTick(function()
			TriggerServerEvent('qb-apartments:server:CreateApartment', appaYeet, true)
			TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
		end)
	end)

	my_webui:RegisterEventHandler('qb-spawn:spawnplayer', function(data)
		local location = tostring(data.spawnloc)
		local type = tostring(data.typeLoc)
		local PlayerData = exports['qb-core']:GetPlayerData()
		local insideMeta = PlayerData.metadata['inside']
		if type == 'current' then
			Timer.SetNextTick(function()
				if insideMeta.house ~= nil then
					local houseId = insideMeta.house
					TriggerLocalClientEvent('qb-houses:client:LastLocationHouse', houseId)
				elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
					local apartmentType = insideMeta.apartment.apartmentType
					local apartmentId = insideMeta.apartment.apartmentId
					TriggerClientEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
				end
				TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
				TriggerServerEvent('qb-spawn:server:spawnPlayer')
			end)
			SetDisplay(false)
		elseif type == 'house' then
			Timer.SetNextTick(function()
				TriggerLocalClientEvent('qb-houses:client:enterOwnedHouse', location)
				TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
				TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
				TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
			end)
			SetDisplay(false)
		elseif type == 'normal' then
			local pos = Config.Spawns[location].coords
			local coords = Vector(pos[1], pos[2], pos[3])
			Timer.SetNextTick(function()
				TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
				TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
				TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
				TriggerServerEvent('qb-spawn:server:spawnPlayer', coords)
			end)
			SetDisplay(false)
		end
	end)

	my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
		my_webui:CallFunction('showUi', bool, translations)
		if not new then
			--exports['qb-core']:TriggerCallback('qb-houses:server:getOwnedHouses', function(houses)
			local myHouses = {}
			-- if houses then
			-- 	for i = 1, #houses do
			-- 		myHouses[#myHouses + 1] = {
			-- 			house = houses[i].house,
			-- 			label = houses[i].address,
			-- 		}
			-- 	end
			-- end
			my_webui:CallFunction('setupLocations', Config.Spawns, myHouses, new)
			--end, cData.citizenid)
		elseif new then
			my_webui:CallFunction('setupApartments', apps, new)
		end
	end)
end

-- local function SetCam(campos)
-- 	HPlayer:TranslateCameraTo(Vector(campos[1], campos[2], campos[3]), 1.0, 0)
-- end

-- Events

RegisterClientEvent('qb-houses:client:setHouseConfig', function(houseConfig)
	Houses = houseConfig
end)

RegisterClientEvent('qb-spawn:client:openUI', function(value, cData, new, apps)
	SetDisplay(value, cData, new, apps)
end)

RegisterClientEvent('qb-spawn:client:setupSpawns', function()

end)
