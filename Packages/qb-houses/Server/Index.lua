local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local houseowneridentifier = {}
local houseownercid = {}
local housekeyholders = {}
local housesLoaded = false

-- Threads

local HouseGarages = {}
local result = MySQL.query.await('SELECT * FROM houselocations', {})
if result[1] then
	for _, v in pairs(result) do
		local owned = false
		if tonumber(v.owned) == 1 then
			owned = true
		end
		local garage = v.garage and JSON.parse(v.garage) or {}
		Config.Houses[v.name] = {
			coords = JSON.parse(v.coords),
			owned = owned,
			price = v.price,
			locked = true,
			adress = v.label,
			tier = v.tier,
			garage = garage,
			decorations = {},
		}
		HouseGarages[v.name] = {
			label = v.label,
			takeVehicle = garage,
		}
	end
end
Events.BroadcastRemote('qb-garages:client:houseGarageConfig', HouseGarages)
Events.BroadcastRemote('qb-houses:client:setHouseConfig', Config.Houses)

MySQL.query('SELECT * FROM player_houses', {}, function(houses)
	if houses then
		for _, house in pairs(houses) do
			houseowneridentifier[house.house] = house.identifier
			houseownercid[house.house] = house.citizenid
			housekeyholders[house.house] = JSON.parse(house.keyholders)
		end
	end
end)

-- Functions

local function isHouseOwner(identifier, cid, house)
	if houseowneridentifier[house] and houseownercid[house] then
		if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
			return true
		end
	end
	return false
end

local function hasKey(identifier, cid, house)
	if houseowneridentifier[house] and houseownercid[house] then
		if houseowneridentifier[house] == identifier and houseownercid[house] == cid then
			return true
		else
			if housekeyholders[house] then
				for i = 1, #housekeyholders[house], 1 do
					if housekeyholders[house][i] == cid then
						return true
					end
				end
			end
		end
	end
	return false
end

Package.Export('hasKey', hasKey)

local function GetHouseStreetCount(street)
	local count = 0
	local query = '%' .. street .. '%'
	local result = MySQL.query.await(
		'SELECT * FROM houselocations WHERE name LIKE ? ORDER BY LENGTH(name) desc, name DESC',
		{ query }
	)
	if result[1] then
		local houseAddress = result.name
		count = tonumber(string.match(houseAddress, '%d[%d.,]*'))
	end
	return (count + 1)
end

local function isHouseOwned(house)
	local result = MySQL.query.await('SELECT owned FROM houselocations WHERE name = ?', { house })
	if result[1] then
		if result[1].owned == 1 then
			return true
		end
	end
	return false
end

local function escape_sqli(source)
	local replacements = {
		['"'] = '\\"',
		["'"] = "\\'",
	}
	return source:gsub("['\"]", replacements)
end

local function AddNewHouse(source, street, coords, price, tier)
	street = street:gsub("%'", '')
	price = tonumber(price)
	tier = tonumber(tier)
	local houseCount = GetHouseStreetCount(street)
	local name = street:lower() .. tostring(houseCount)
	local label = street .. ' ' .. tostring(houseCount)
	MySQL.insert(
		'INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (?, ?, ?, ?, ?, ?)',
		{ name, label, JSON.stringify(coords), 0, price, tier }
	)
	Config.Houses[name] = {
		coords = coords,
		owned = false,
		price = price,
		locked = true,
		adress = label,
		tier = tier,
		garage = {},
		decorations = {},
	}
	Events.BroadcastRemote('qb-houses:client:setHouseConfig', Config.Houses)
	Events.CallRemote('QBCore:Notify', source, Lang:t('info.added_house', { value = label }))
	--Events.Call('qb-log:server:CreateLog', 'house', Lang:t('log.house_created'), 'green', Lang:t('log.house_address', { label = label, price = price, tier = tier, agent = GetPlayerName(source) }))
end

local function getKeyHolderData()
	return housekeyholders
end

Package.Export('getKeyHolderData', getKeyHolderData)

-- Commands

QBCore.Commands.Add('decorate', Lang:t('info.decorate_interior'), {}, false, function(source)
	Events.CallRemote('qb-houses:client:decorate', source)
end, 'user')

QBCore.Commands.Add('createhouse', Lang:t('info.create_house'), { { name = 'price', help = Lang:t('info.price_of_house') }, { name = 'tier', help = Lang:t('info.tier_number') } }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	if Player.PlayerData.job.name ~= 'realestate' then
		return
	end
	local ped = source:GetControlledCharacter()
	if not ped then
		return
	end
	local pos = ped:GetLocation()
	local heading = ped:GetRotation()
	local price = tonumber(args[1])
	local tier = tonumber(args[2])
	local coords = {
		enter = { x = pos.X, y = pos.Y, z = pos.Z, h = heading.Yaw },
		cam = { x = pos.X, y = pos.Y, z = pos.Z, h = heading.Yaw, yaw = -10.00 },
	}
	local street = 'test_' .. math.random(1, 1000)
	AddNewHouse(source, street, coords, price, tier)
	--if Config.UnownedBlips then Events.Call('qb-houses:server:createBlip') end
end, 'user')

QBCore.Commands.Add('addgarage', Lang:t('info.add_garage'), {}, false, function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	if Player.PlayerData.job.name == 'realestate' then
		Events.CallRemote('qb-houses:client:addGarage', source)
	else
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.realestate_only'), 'error')
	end
end, 'user')

QBCore.Commands.Add('ring', Lang:t('info.ring_doorbell'), {}, false, function(source)
	Events.CallRemote('qb-houses:client:RequestRing', source)
end, 'user')

-- Events

Events.SubscribeRemote('qb-houses:server:setHouses', function(source)
	Events.CallRemote('qb-houses:client:setHouseConfig', source, Config.Houses)
end)

Events.SubscribeRemote('qb-houses:server:createBlip', function(source)
	local ped = source:GetControlledCharacter()
	local coords = ped:GetLocation()
	Events.BroadcastRemote('qb-houses:client:createBlip', coords)
end)

Events.SubscribeRemote('qb-houses:server:addGarage', function(source, house, coords)
	MySQL.update('UPDATE houselocations SET garage = ? WHERE name = ?', { JSON.stringify(coords), house })
	local garageInfo = {
		label = Config.Houses[house].adress,
		takeVehicle = coords,
	}
	Events.BroadcastRemote('qb-garages:client:addHouseGarage', house, garageInfo)
	Events.CallRemote('QBCore:Notify', source, Lang:t('info.added_garage', { value = garageInfo.label }))
end)

Events.SubscribeRemote('qb-houses:server:viewHouse', function(source, data)
	local pData = QBCore.Functions.GetPlayer(source)
	if not pData then
		return
	end
	local house = data.house
	local houseprice = Config.Houses[house].price
	local brokerfee = (houseprice / 100 * 5)
	local bankfee = (houseprice / 100 * 10)
	local taxes = (houseprice / 100 * 6)
	Events.CallRemote('qb-houses:client:viewHouse', source, house, houseprice, brokerfee, bankfee, taxes)
end)

Events.SubscribeRemote('qb-houses:server:openStash', function(source, CurrentHouse)
	local houseData = Config.Houses[CurrentHouse]
	if not houseData then
		return
	end
	local houseTier = houseData.tier
	local stashSlots = Config.StashWeights[houseTier].slots
	local stashWeight = Config.StashWeights[houseTier].maxweight
	if stashSlots and stashWeight then
		OpenInventory(source, CurrentHouse, {
			maxweight = stashWeight,
			slots = stashSlots,
			label = houseData.adress,
		})
	else
		OpenInventory(source, CurrentHouse)
	end
end)

Events.SubscribeRemote('qb-houses:server:buyHouse', function(source, house)
	local pData = QBCore.Functions.GetPlayer(source)
	if not pData then
		return
	end
	local price = Config.Houses[house].price
	local HousePrice = math.ceil(price * 1.21)
	local bankBalance = pData.PlayerData.money['bank']

	local isOwned = isHouseOwned(house)
	if isOwned then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.already_owned'), 'error')
		return
	end

	if bankBalance >= HousePrice then
		houseowneridentifier[house] = pData.PlayerData.license
		houseownercid[house] = pData.PlayerData.citizenid
		housekeyholders[house] = { [1] = pData.PlayerData.citizenid }
		MySQL.insert(
			'INSERT INTO player_houses (house, identifier, citizenid, keyholders) VALUES (?, ?, ?, ?)',
			{ house, pData.PlayerData.license, pData.PlayerData.citizenid, JSON.stringify(housekeyholders[house]) }
		)
		MySQL.update('UPDATE houselocations SET owned = ? WHERE name = ?', { 1, house })
		Events.CallRemote('qb-houses:client:SetClosestHouse', source)
		Events.CallRemote('qb-house:client:RefreshHouseTargets', source)
		pData.Functions.RemoveMoney('bank', HousePrice, 'bought-house')
		--AddMoney("realestate", (HousePrice / 100) * math.random(18, 25), "House purchase")
		--Events.Call('qb-log:server:CreateLog', 'house', Lang:t('log.house_purchased'), 'green', Lang:t('log.house_purchased_by', { house = house:upper(), price = HousePrice, firstname = pData.PlayerData.charinfo.firstname, lastname = pData.PlayerData.charinfo.lastname }))
		Events.CallRemote('QBCore:Notify', source, Lang:t('success.house_purchased'), 'success', 5000)
	else
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_enough_money'), 'error')
	end
end)

Events.SubscribeRemote('qb-houses:server:lockHouse', function(source, bool, house)
	Events.BroadcastRemote('qb-houses:client:lockHouse', bool, house)
end)

Events.SubscribeRemote('qb-houses:server:SetRamState', function(source, bool, house)
	Config.Houses[house].IsRaming = bool
	Events.BroadcastRemote('qb-houses:server:SetRamState', bool, house)
end)

Events.SubscribeRemote('qb-houses:server:giveKey', function(source, house, target)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local pData = QBCore.Functions.GetPlayer(target)
	if not pData then
		return
	end
	if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_owner'), 'error')
		return
	end
	housekeyholders[house][#housekeyholders[house] + 1] = pData.PlayerData.citizenid
	MySQL.update(
		'UPDATE player_houses SET keyholders = ? WHERE house = ?',
		{ JSON.stringify(housekeyholders[house]), house }
	)
end)

Events.SubscribeRemote('qb-houses:server:removeHouseKey', function(source, house, citizenData)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_owner'), 'error')
		return
	end
	local newHolders = {}
	if housekeyholders[house] then
		for k, _ in pairs(housekeyholders[house]) do
			if housekeyholders[house][k] ~= citizenData.citizenid then
				newHolders[#newHolders + 1] = housekeyholders[house][k]
			end
		end
	end
	housekeyholders[house] = newHolders
	Events.CallRemote(
		'QBCore:Notify',
		source,
		Lang:t('error.remove_key_from', { firstname = citizenData.firstname, lastname = citizenData.lastname }),
		'error'
	)
	MySQL.update(
		'UPDATE player_houses SET keyholders = ? WHERE house = ?',
		{ JSON.stringify(housekeyholders[house]), house }
	)
end)

Events.SubscribeRemote('qb-houses:server:OpenDoor', function(source, target, house)
	local OtherPlayer = QBCore.Functions.GetPlayer(target)
	if not OtherPlayer then
		return
	end
	Events.CallRemote('qb-houses:client:SpawnInApartment', OtherPlayer.PlayerData.source, house)
end)

Events.SubscribeRemote('qb-houses:server:RingDoor', function(source, house)
	Events.BroadcastRemote('qb-houses:client:RingDoor', source, house)
end)

Events.SubscribeRemote('qb-houses:server:savedecorations', function(source, house, decorations)
	MySQL.update('UPDATE player_houses SET decorations = ? WHERE house = ?', { JSON.stringify(decorations), house })
	Events.BroadcastRemote('qb-houses:server:sethousedecorations', house, decorations)
end)

Events.SubscribeRemote('qb-houses:server:LogoutLocation', function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	-- local MyItems = Player.PlayerData.items
	-- MySQL.update(
	-- 	"UPDATE players SET inventory = ? WHERE citizenid = ?",
	-- 	{ JSON.stringify(MyItems), Player.PlayerData.citizenid }
	-- )
	QBCore.Player.Logout(source)
	Events.CallRemote('qb-multicharacter:client:chooseChar', source)
end)

Events.SubscribeRemote('qb-houses:server:giveHouseKey', function(source, target, house)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local tPlayer = QBCore.Functions.GetPlayer(target)
	if not tPlayer then
		return
	end
	if not isHouseOwner(Player.PlayerData.license, Player.PlayerData.citizenid, house) then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_owner'), 'error')
		return
	end
	if housekeyholders[house] then
		for _, cid in pairs(housekeyholders[house]) do
			if cid == tPlayer.PlayerData.citizenid then
				Events.CallRemote('QBCore:Notify', source, Lang:t('error.already_keys'), 'error', 3500)
				return
			end
		end
		housekeyholders[house][#housekeyholders[house] + 1] = tPlayer.PlayerData.citizenid
		MySQL.update(
			'UPDATE player_houses SET keyholders = ? WHERE house = ?',
			{ JSON.stringify(housekeyholders[house]), house }
		)
		Events.CallRemote('qb-houses:client:refreshHouse', tPlayer.PlayerData.source)
		Events.CallRemote(
			'QBCore:Notify',
			tPlayer.PlayerData.source,
			Lang:t('success.recieved_key', { value = Config.Houses[house].adress }),
			'success',
			2500
		)
	else
		local sourceTarget = QBCore.Functions.GetPlayer(source)
		housekeyholders[house] = { [1] = sourceTarget.PlayerData.citizenid }
		housekeyholders[house][#housekeyholders[house] + 1] = tPlayer.PlayerData.citizenid
		MySQL.update(
			'UPDATE player_houses SET keyholders = ? WHERE house = ?',
			{ JSON.stringify(housekeyholders[house]), house }
		)
		Events.CallRemote('qb-houses:client:refreshHouse', tPlayer.PlayerData.source)
		Events.CallRemote(
			'QBCore:Notify',
			tPlayer.PlayerData.source,
			Lang:t('success.recieved_key', { value = Config.Houses[house].adress }),
			'success',
			2500
		)
	end
end)

Events.SubscribeRemote('qb-houses:server:setLocation', function(source, coords, house, type)
	if type == 1 then
		MySQL.update('UPDATE player_houses SET stash = ? WHERE house = ?', { JSON.stringify(coords), house })
	elseif type == 2 then
		MySQL.update('UPDATE player_houses SET outfit = ? WHERE house = ?', { JSON.stringify(coords), house })
	elseif type == 3 then
		MySQL.update('UPDATE player_houses SET logout = ? WHERE house = ?', { JSON.stringify(coords), house })
	end
	Events.BroadcastRemote('qb-houses:client:refreshLocations', house, JSON.stringify(coords), type)
end)

Events.SubscribeRemote('qb-houses:server:SetHouseRammed', function(source, bool, house)
	Config.Houses[house].IsRammed = bool
	Events.BroadcastRemote('qb-houses:client:SetHouseRammed', bool, house)
end)

Events.SubscribeRemote('qb-houses:server:SetInsideMeta', function(source, insideId, bool)
	local Player = QBCore.Functions.GetPlayer(source)
	local insideMeta = Player.PlayerData.metadata['inside']
	if bool then
		insideMeta.apartment.apartmentType = nil
		insideMeta.apartment.apartmentId = nil
		insideMeta.house = insideId
		Player.Functions.SetMetaData('inside', insideMeta)
	else
		insideMeta.apartment.apartmentType = nil
		insideMeta.apartment.apartmentId = nil
		insideMeta.house = nil
		Player.Functions.SetMetaData('inside', insideMeta)
	end
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-houses:server:buyFurniture', function(source, cb, price)
	local pData = QBCore.Functions.GetPlayer(source)
	local bankBalance = pData.PlayerData.money['bank']

	if bankBalance >= price then
		pData.Functions.RemoveMoney('bank', price, 'bought-furniture')
		cb(true)
	else
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_enough_money'), 'error')
		cb(false)
	end
end)

QBCore.Functions.CreateCallback('qb-houses:server:ProximityKO', function(source, cb, house)
	local Player = QBCore.Functions.GetPlayer(source)
	local retvalK = false
	local retvalO

	if Player then
		local identifier = Player.PlayerData.license
		local CharId = Player.PlayerData.citizenid
		if hasKey(identifier, CharId, house) then
			retvalK = true
		elseif Player.PlayerData.job.name == 'realestate' then
			retvalK = true
		else
			retvalK = false
		end
	end

	if houseowneridentifier[house] and houseownercid[house] then
		retvalO = true
	else
		retvalO = false
	end

	cb(retvalK, retvalO)
end)

QBCore.Functions.CreateCallback('qb-houses:server:hasKey', function(source, cb, house)
	local Player = QBCore.Functions.GetPlayer(source)
	local retval = false
	if Player then
		local identifier = Player.PlayerData.license
		local CharId = Player.PlayerData.citizenid
		if hasKey(identifier, CharId, house) then
			retval = true
		elseif Player.PlayerData.job.name == 'realestate' then
			retval = true
		else
			retval = false
		end
	end

	cb(retval)
end)

QBCore.Functions.CreateCallback('qb-houses:server:isOwned', function(source, cb, house)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name == 'realestate' then
		cb(true)
	elseif houseowneridentifier[house] and houseownercid[house] then
		cb(true)
	else
		cb(false)
	end
end)

QBCore.Functions.CreateCallback('qb-houses:server:getHouseOwner', function(_, cb, house)
	cb(houseownercid[house])
end)

QBCore.Functions.CreateCallback('qb-houses:server:getHouseKeyHolders', function(source, cb, house)
	local retval = {}
	local Player = QBCore.Functions.GetPlayer(source)
	if housekeyholders[house] then
		for i = 1, #housekeyholders[house], 1 do
			if Player.PlayerData.citizenid ~= housekeyholders[house][i] then
				local result =
					MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', { housekeyholders[house][i] })
				if result[1] then
					local charinfo = JSON.parse(result[1].charinfo)
					retval[#retval + 1] = {
						firstname = charinfo.firstname,
						lastname = charinfo.lastname,
						citizenid = housekeyholders[house][i],
					}
				end
			end
		end
		cb(retval)
	else
		cb(nil)
	end
end)

QBCore.Functions.CreateCallback('qb-phone:server:TransferCid', function(_, cb, NewCid, house)
	local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', { NewCid })
	if result[1] then
		local HouseName = house.name
		housekeyholders[HouseName] = {}
		housekeyholders[HouseName][1] = NewCid
		houseownercid[HouseName] = NewCid
		houseowneridentifier[HouseName] = result[1].license
		MySQL.update(
			'UPDATE player_houses SET citizenid = ?, keyholders = ?, identifier = ? WHERE house = ?',
			{ NewCid, JSON.stringify(housekeyholders[HouseName]), result[1].license, HouseName }
		)
		cb(true)
	else
		cb(false)
	end
end)

QBCore.Functions.CreateCallback('qb-houses:server:getHouseDecorations', function(_, cb, house)
	local retval = nil
	local result = MySQL.query.await('SELECT * FROM player_houses WHERE house = ?', { house })
	if result[1] then
		if result[1].decorations then
			retval = JSON.parse(result[1].decorations)
		end
	end
	cb(retval)
end)

QBCore.Functions.CreateCallback('qb-houses:server:getHouseLocations', function(_, cb, house)
	local retval = nil
	local result = MySQL.query.await('SELECT * FROM player_houses WHERE house = ?', { house })
	if result[1] then
		retval = result[1]
	end
	cb(retval)
end)

QBCore.Functions.CreateCallback('qb-houses:server:getOwnedHouses', function(source, cb)
	local pData = QBCore.Functions.GetPlayer(source)
	if not pData then
		return
	end
	MySQL.query(
		'SELECT * FROM player_houses WHERE identifier = ? AND citizenid = ?',
		{ pData.PlayerData.license, pData.PlayerData.citizenid },
		function(houses)
			local ownedHouses = {}
			for i = 1, #houses, 1 do
				ownedHouses[#ownedHouses + 1] = houses[i].house
			end
			if houses then
				cb(ownedHouses)
			else
				cb(nil)
			end
		end
	)
end)

QBCore.Functions.CreateCallback('qb-houses:server:getSavedOutfits', function(source, cb)
	local pData = QBCore.Functions.GetPlayer(source)
	if not pData then
		return
	end
	MySQL.query('SELECT * FROM player_outfits WHERE citizenid = ?', { pData.PlayerData.citizenid }, function(result)
		if result[1] then
			cb(result)
		else
			cb(nil)
		end
	end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetPlayerHouses', function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
	local MyHouses = {}
	local result = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', { Player.PlayerData.citizenid })
	if result and result[1] then
		for k, v in pairs(result) do
			MyHouses[#MyHouses + 1] = {
				name = v.house,
				keyholders = {},
				owner = Player.PlayerData.citizenid,
				price = Config.Houses[v.house].price,
				label = Config.Houses[v.house].adress,
				tier = Config.Houses[v.house].tier,
				garage = Config.Houses[v.house].garage,
			}
			if v.keyholders ~= 'null' then
				v.keyholders = JSON.parse(v.keyholders)
				if v.keyholders then
					for _, data in pairs(v.keyholders) do
						local keyholderdata = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', { data })
						if keyholderdata[1] then
							keyholderdata[1].charinfo = JSON.parse(keyholderdata[1].charinfo)

							local userKeyHolderData = {
								charinfo = {
									firstname = keyholderdata[1].charinfo.firstname,
									lastname = keyholderdata[1].charinfo.lastname,
								},
								citizenid = keyholderdata[1].citizenid,
								name = keyholderdata[1].name,
							}
							MyHouses[k].keyholders[#MyHouses[k].keyholders + 1] = userKeyHolderData
						end
					end
				else
					MyHouses[k].keyholders[1] = {
						charinfo = {
							firstname = Player.PlayerData.charinfo.firstname,
							lastname = Player.PlayerData.charinfo.lastname,
						},
						citizenid = Player.PlayerData.citizenid,
						name = Player.PlayerData.name,
					}
				end
			else
				MyHouses[k].keyholders[1] = {
					charinfo = {
						firstname = Player.PlayerData.charinfo.firstname,
						lastname = Player.PlayerData.charinfo.lastname,
					},
					citizenid = Player.PlayerData.citizenid,
					name = Player.PlayerData.name,
				}
			end
		end
		SetTimeout(100, function()
			cb(MyHouses)
		end)
	else
		cb({})
	end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetHouseKeys', function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local MyKeys = {}
	local result = MySQL.query.await('SELECT * FROM player_houses', {})
	for _, v in pairs(result) do
		if v.keyholders ~= 'null' then
			v.keyholders = JSON.parse(v.keyholders)
			for _, p in pairs(v.keyholders) do
				if p == Player.PlayerData.citizenid and (v.citizenid ~= Player.PlayerData.citizenid) then
					MyKeys[#MyKeys + 1] = {
						HouseData = Config.Houses[v.house],
					}
				end
			end
		end
		if v.citizenid == Player.PlayerData.citizenid then
			MyKeys[#MyKeys + 1] = {
				HouseData = Config.Houses[v.house],
			}
		end
	end
	cb(MyKeys)
end)

QBCore.Functions.CreateCallback('qb-phone:server:MeosGetPlayerHouses', function(_, cb, input)
	if not input then
		return cb(nil)
	end
	local search = escape_sqli(input)
	local searchData = {}
	local query = '%' .. search .. '%'
	local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? OR charinfo LIKE ?', { search, query })
	if not result[1] then
		return cb(nil)
	end
	local houses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', { result[1].citizenid })
	if houses[1] then
		for _, v in pairs(houses) do
			searchData[#searchData + 1] = {
				name = v.house,
				keyholders = v.keyholders,
				owner = v.citizenid,
				price = Config.Houses[v.house].price,
				label = Config.Houses[v.house].adress,
				tier = Config.Houses[v.house].tier,
				garage = Config.Houses[v.house].garage,
				charinfo = JSON.parse(result[1].charinfo),
				coords = {
					x = Config.Houses[v.house].coords.enter.x,
					y = Config.Houses[v.house].coords.enter.y,
					z = Config.Houses[v.house].coords.enter.z,
				},
			}
		end
		cb(searchData)
	end
end)

-- Item

QBCore.Functions.CreateUseableItem('police_stormram', function(source, _)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	if Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty then
		Events.CallRemote('qb-houses:client:HomeInvasion', source)
	else
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.emergency_services'), 'error')
	end
end)
