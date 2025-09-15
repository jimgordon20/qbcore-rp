local Lang = require('Shared/locales/en')
local my_webui = WebUI('Spawn', 'qb-spawn/Client/html/index.html')
local Houses = {}

-- Functions

local function SetDisplay(bool)
	local translations = {}
	for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
		if k:sub(0, #'ui.') then
			translations[k:sub(#'ui.' + 1)] = Lang:t(k)
		end
	end
	-- if not Input.IsMouseEnabled() then
	-- 	Input.SetMouseEnabled(true)
	-- end
	-- my_webui:BringToFront()
	my_webui:CallFunction('showUi', bool, translations)
end

local function PreSpawnPlayer(value)
	SetDisplay(value)
	-- Input.SetMouseEnabled(false)
	-- Input.SetInputEnabled(true)
end

-- local function SetCam(campos)
-- 	HPlayer:TranslateCameraTo(Vector(campos[1], campos[2], campos[3]), 1.0, 0)
-- end

-- Events

RegisterClientEvent('qb-houses:client:setHouseConfig', function(houseConfig)
	Houses = houseConfig
end)

RegisterClientEvent('qb-spawn:client:openUI', function(value)
	SetDisplay(value)
end)

RegisterClientEvent('qb-spawn:client:setupSpawns', function(cData, new, apps)
	if not new then
		exports['qb-core']:TriggerCallback('qb-houses:server:getOwnedHouses', function(houses)
			local myHouses = {}
			if houses then
				for i = 1, #houses do
					myHouses[#myHouses + 1] = {
						house = houses[i].house,
						label = houses[i].address,
					}
				end
			end
			my_webui:CallFunction('setupLocations', Config.Spawns, myHouses, new)
		end, cData.citizenid)
	elseif new then
		my_webui:CallFunction('setupApartments', apps, new)
	end
end)

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
	TriggerServerEvent('qb-apartments:server:CreateApartment', appaYeet, Apartments.Locations[appaYeet].label, true)
	TriggerClientEvent('QBCore:Client:OnPlayerLoaded')
end)

my_webui:RegisterEventHandler('qb-spawn:spawnplayer', function(data)
	local location = tostring(data.spawnloc)
	local type = tostring(data.typeLoc)
	local PlayerData = QBCore.Functions.GetPlayerData()
	local insideMeta = PlayerData.metadata['inside']
	if type == 'current' then
		PreSpawnPlayer(false)
		if insideMeta.house ~= nil then
			local houseId = insideMeta.house
			TriggerClientEvent('qb-houses:client:LastLocationHouse', houseId)
		elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
			local apartmentType = insideMeta.apartment.apartmentType
			local apartmentId = insideMeta.apartment.apartmentId
			TriggerClientEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
		end
		TriggerClientEvent('QBCore:Client:OnPlayerLoaded')
		TriggerServerEvent('qb-spawn:server:spawnPlayer')
	elseif type == 'house' then
		PreSpawnPlayer(false)
		TriggerClientEvent('qb-houses:client:enterOwnedHouse', location)
		TriggerClientEvent('QBCore:Client:OnPlayerLoaded')
		TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
		TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
	elseif type == 'normal' then
		local pos = Config.Spawns[location].coords
		local coords = Vector(pos[1], pos[2], pos[3])
		PreSpawnPlayer(false)
		TriggerClientEvent('QBCore:Client:OnPlayerLoaded')
		TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
		TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
		TriggerServerEvent('qb-spawn:server:spawnPlayer', coords)
	end
end)
