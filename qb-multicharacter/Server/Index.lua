local Lang = require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local hasDonePreloading = {}

-- Handling Player Load

-- Package.Subscribe('Load', function()
-- 	Events.BroadcastRemote('qb-multicharacter:client:chooseChar')
-- end)

Player.Subscribe('Spawn', function(source)
	TriggerClientEvent('qb-multicharacter:client:chooseChar', source)
end)

-- Functions

local function GiveStarterItems(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then return end
	for _, v in pairs(QBShared.StarterItems) do
		local info = {}
		if v.item == 'id_card' then
			info.citizenid = Player.PlayerData.citizenid
			info.firstname = Player.PlayerData.charinfo.firstname
			info.lastname = Player.PlayerData.charinfo.lastname
			info.birthdate = Player.PlayerData.charinfo.birthdate
			info.gender = Player.PlayerData.charinfo.gender
			info.nationality = Player.PlayerData.charinfo.nationality
		elseif v.item == 'driver_license' then
			info.firstname = Player.PlayerData.charinfo.firstname
			info.lastname = Player.PlayerData.charinfo.lastname
			info.birthdate = Player.PlayerData.charinfo.birthdate
			info.type = 'Class C Driver License'
		end
		AddItem(source, v.item, v.amount, false, info)
	end
end

-- Commands

QBCore.Commands.Add('logout', Lang:t('commands.logout_description'), {}, false, function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then return end
	local inside_meta = Player.PlayerData.metadata.inside
	if inside_meta.apartment.apartmentId then
		TriggerClientEvent('qb-apartments:client:leaveApartment', source)
	end
	QBCore.Player.Logout(source)
	TriggerClientEvent('qb-multicharacter:client:chooseChar', source)
end, 'admin')

-- Events

RegisterServerEvent('QBCore:Server:PlayerLoaded', function(Player)
	hasDonePreloading[Player.PlayerData.source] = true
end)

RegisterServerEvent('QBCore:Server:OnPlayerUnload', function(source)
	hasDonePreloading[source] = false
end)

RegisterServerEvent('qb-multicharacter:server:disconnect', function(source)
	source:Kick(source, Lang:t('commands.droppedplayer'))
end)

RegisterServerEvent('qb-multicharacter:server:loadUserData', function(source, cData) -- TO DO ADD APARTMENTS SUPPORT
	if QBCore.Player.Login(source, cData.citizenid) then
		CheckUserInterval = Timer.SetInterval(function()
			if hasDonePreloading[source] then
				print('[qb-core] ' .. source:GetAccountName() .. ' (Citizen ID: ' .. cData.citizenid .. ') has successfully loaded!')
				QBCore.Commands.Refresh(source)
				--loadHouseData(source)
				if Config.SkipSelection then
					local coords = JSON.parse(cData.position)
					local new_char = HCharacter(coords, Rotator(0, 0, 0), source)
					local source_dimension = source:GetDimension()
					new_char:SetDimension(source_dimension)
					source:Possess(new_char)
					TriggerClientEvent('QBCore:Client:OnPlayerLoaded', source)
					TriggerClientEvent('qb-multicharacter:client:spawnLastLocation', source, coords, cData)
				else
					if Apartments.Starting then
						TriggerClientEvent('qb-apartments:client:setupSpawnUI', source, cData)
					else
						TriggerClientEvent('qb-spawn:client:setupSpawns', source, cData, false, nil)
						TriggerClientEvent('qb-spawn:client:openUI', source, true)
					end
				end
				--Events.Call('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**' .. source:GetAccountName() .. '** (<@' .. (QBCore.Functions.GetIdentifier(source, 'discord'):gsub('discord:', '') or 'unknown') .. '> |  ||' .. (QBCore.Functions.GetIdentifier(source, 'ip') or 'undefined') .. '|| | ' .. (QBCore.Functions.GetIdentifier(source, 'license') or 'undefined') .. ' | ' .. cData.citizenid .. ' | ' .. source .. ') loaded..')
				Timer.ClearInterval(CheckUserInterval)
			end
		end, 10)
	end
end)

RegisterServerEvent('qb-multicharacter:server:createCharacter', function(source, data)
	local newData = {}
	newData.cid = data.cid
	newData.charinfo = data
	if QBCore.Player.Login(source, false, newData) then
		CheckInterval = Timer.SetInterval(function()
			if hasDonePreloading[source] then
				if Apartments.Starting then
					local randbucket = (math.random(1, 999))
					QBCore.Functions.SetPlayerBucket(source, randbucket)
					print('^2[qb-core]^7 ' .. source:GetAccountName() .. ' has successfully loaded!')
					QBCore.Commands.Refresh(source)
					--loadHouseData(source)
					TriggerClientEvent('qb-multicharacter:client:closeNUI', source)
					TriggerClientEvent('qb-apartments:client:setupSpawnUI', source, newData)
					GiveStarterItems(source)
					Timer.ClearInterval(CheckInterval)
				else
					print('^2[qb-core]^7 ' .. source:GetAccountName() .. ' has successfully loaded!')
					QBCore.Commands.Refresh(source)
					--loadHouseData(source)
					local new_char = HCharacter(QBConfig.DefaultSpawn, Rotator(0, 0, 0), source)
					local source_dimension = source:GetDimension()
					new_char:SetDimension(source_dimension)
					source:Possess(new_char)
					TriggerClientEvent('QBCore:Client:OnPlayerLoaded', source)
					TriggerClientEvent('qb-multicharacter:client:closeNUIdefault', source)
					GiveStarterItems(source)
					Timer.ClearInterval(CheckInterval)
				end
			end
		end, 10)
	end
end)

RegisterServerEvent('qb-multicharacter:server:deleteCharacter', function(source, citizenid)
	QBCore.Player.DeleteCharacter(source, citizenid)
	TriggerClientEvent('QBCore:Notify', source, Lang:t('notifications.char_deleted'), 'success')
	TriggerClientEvent('qb-multicharacter:client:chooseChar', source)
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-multicharacter:server:GetNumberOfCharacters', function(source, cb)
	local license = source:GetAccountID()
	local numOfChars = 0
	if next(Config.PlayersNumberOfCharacters) then
		for _, v in pairs(Config.PlayersNumberOfCharacters) do
			if v.license == license then
				numOfChars = v.numberOfChars
				break
			else
				numOfChars = Config.DefaultNumberOfCharacters
			end
		end
	else
		numOfChars = Config.DefaultNumberOfCharacters
	end
	cb(numOfChars)
end)

QBCore.Functions.CreateCallback('qb-multicharacter:server:setupCharacters', function(source, cb)
	local license = source:GetAccountID()
	local plyChars = {}
	MySQL.query('SELECT * FROM players WHERE license = ?', { license }, function(result)
		for i = 1, #result, 1 do
			result[i].charinfo = JSON.parse(result[i].charinfo)
			result[i].money = JSON.parse(result[i].money)
			result[i].job = JSON.parse(result[i].job)
			plyChars[#plyChars + 1] = result[i]
		end
		cb(plyChars)
	end)
end)
