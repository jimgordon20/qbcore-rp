local Config = Package.Require('../Shared/config.lua')
local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local my_webui = WebUI('Spawn', 'file://html/index.html')
local Houses = {}

-- Functions

local function SetDisplay(bool)
	local translations = {}
	for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
		if k:sub(0, #'ui.') then
			translations[k:sub(#'ui.' + 1)] = Lang:t(k)
		end
	end
	if not Input.IsMouseEnabled() then
		Input.SetMouseEnabled(true)
	end
	my_webui:BringToFront()
	my_webui:CallEvent('qb-spawn:showUi', bool, translations)
end

local function PreSpawnPlayer(value)
	SetDisplay(value)
	Input.SetMouseEnabled(false)
	Input.SetInputEnabled(true)
end

local function SetCam(campos)
	local player = Client.GetLocalPlayer()
	player:TranslateCameraTo(Vector(campos[1], campos[2], campos[3]), 1.0, 0)
end

-- Events

Events.SubscribeRemote('qb-houses:client:setHouseConfig', function(houseConfig)
	Houses = houseConfig
end)

Events.Subscribe('qb-spawn:client:openUI', function(value)
	SetDisplay(value)
end)

Events.SubscribeRemote('qb-spawn:client:openUI', function(value)
	SetDisplay(value)
end)

Events.SubscribeRemote('qb-spawn:client:setupSpawns', function(cData, new, apps)
	if not new then
		QBCore.Functions.TriggerCallback('qb-spawn:server:getOwnedHouses', function(houses)
			local myHouses = {}
			if houses ~= nil then
				for i = 1, #houses, 1 do
					myHouses[#myHouses + 1] = {
						house = houses[i].house,
						label = Houses[houses[i].house].adress,
					}
				end
			end
			my_webui:CallEvent('qb-spawn:setupLocations', Config.Spawns, myHouses, new)
		end, cData.citizenid)
	elseif new then
		my_webui:CallEvent('qb-spawn:setupApartments', apps, new)
	end
end)

Events.Subscribe('qb-spawn:client:setupSpawns', function(cData, new, apps)
	if not new then
		QBCore.Functions.TriggerCallback('qb-spawn:server:getOwnedHouses', function(houses)
			local myHouses = {}
			if houses ~= nil then
				for i = 1, #houses, 1 do
					myHouses[#myHouses + 1] = {
						house = houses[i].house,
						label = Houses[houses[i].house].adress,
					}
				end
			end
			my_webui:CallEvent('qb-spawn:setupLocations', Config.Spawns, myHouses, new)
		end, cData.citizenid)
	elseif new then
		my_webui:CallEvent('qb-spawn:setupApartments', apps, new)
	end
end)

-- NUI Events

my_webui:Subscribe('qb-spawn:setCam', function(data)
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

my_webui:Subscribe('qb-spawn:chooseAppa', function(data)
	local appaYeet = data.appType
	SetDisplay(false)
	Events.CallRemote('qb-apartments:server:CreateApartment', appaYeet, Apartments.Locations[appaYeet].label, true)
	Events.Call('QBCore:Client:OnPlayerLoaded')
end)

my_webui:Subscribe('qb-spawn:spawnplayer', function(data)
	local location = tostring(data.spawnloc)
	local type = tostring(data.typeLoc)
	local PlayerData = QBCore.Functions.GetPlayerData()
	local insideMeta = PlayerData.metadata['inside']
	if type == 'current' then
		PreSpawnPlayer(false)
		if insideMeta.house ~= nil then
			local houseId = insideMeta.house
			Events.Call('qb-houses:client:LastLocationHouse', houseId)
		elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
			local apartmentType = insideMeta.apartment.apartmentType
			local apartmentId = insideMeta.apartment.apartmentId
			Events.Call('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
		end
		Events.Call('QBCore:Client:OnPlayerLoaded')
		Events.CallRemote('qb-spawn:server:spawnPlayer')
	elseif type == 'house' then
		PreSpawnPlayer(false)
		Events.Call('qb-houses:client:enterOwnedHouse', location)
		Events.Call('QBCore:Client:OnPlayerLoaded')
		Events.CallRemote('qb-houses:server:SetInsideMeta', 0, false)
		Events.CallRemote('qb-apartments:server:SetInsideMeta', 0, 0, false)
	elseif type == 'normal' then
		local pos = Config.Spawns[location].coords
		local coords = Vector(pos[1], pos[2], pos[3])
		PreSpawnPlayer(false)
		Events.Call('QBCore:Client:OnPlayerLoaded')
		Events.CallRemote('qb-houses:server:SetInsideMeta', 0, false)
		Events.CallRemote('qb-apartments:server:SetInsideMeta', 0, 0, false)
		Events.CallRemote('qb-spawn:server:spawnPlayer', coords)
	end
end)
