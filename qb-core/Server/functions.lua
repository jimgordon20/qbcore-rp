QBCore.Functions = {}
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}

-- Getter Functions

function QBCore.Functions.GetIdentifier(source)
	local PlayerState = source:GetLyraPlayerState()
	return PlayerState:GetHelixUserId()
end

function QBCore.Functions.GetSource(identifier)
	for src in pairs(QBCore.Players) do
		if QBCore.Players[src].PlayerData.license == identifier then
			return src
		end
	end
	return 0
end

function QBCore.Functions.AddPermission(source, permission)
	local PlayerState = source:GetLyraPlayerState()
	local accountId = PlayerState:GetPlayerId()
	local allPermissions = QBCore.Config.Server.Permissions
	local level_check = allPermissions[permission]
	if not level_check then return end
	if not QBCore.Functions.HasPermission(source, permission) then
		allPermissions[permission][accountId] = true
		QBCore.Commands.Refresh(source)
	end
end

function QBCore.Functions.RemovePermission(source, permission)
	local PlayerState = source:GetLyraPlayerState()
	local accountId = PlayerState:GetPlayerId()
	local allPermissions = QBCore.Config.Server.Permissions
	local level_check = allPermissions[permission]
	if not level_check then return end
	if permission then
		if QBCore.Functions.HasPermission(source, permission) then
			allPermissions[permission][accountId] = nil
			QBCore.Commands.Refresh(source)
		end
	else
		for _, accounts in pairs(allPermissions) do
			if accounts[accountId] then
				accounts[accountId] = nil
				QBCore.Commands.Refresh(source)
			end
		end
	end
end

function QBCore.Functions.HasPermission(source, permissionLevel)
	local PlayerState = source:GetLyraPlayerState()
	local accountId = PlayerState:GetPlayerId()
	local allPermissions = QBCore.Config.Server.Permissions
	if permissionLevel == 'user' then
		return true
	end
	if not allPermissions[permissionLevel] then
		return false
	end

	if allPermissions['god'][accountId] then
		return true
	elseif permissionLevel ~= 'god' and allPermissions['admin'][accountId] then
		return true
	elseif permissionLevel == 'mod' or permissionLevel == 'user' then
		if allPermissions['mod'][accountId] then
			return true
		end
	end

	return allPermissions[permissionLevel][accountId] or false
end

function QBCore.Functions.GetPlayer(source)
	if not source then return end
	return QBCore.Players[source]
end

function QBCore.Functions.GetPlayerName(source)
	local PlayerState = source:GetLyraPlayerState()
	return PlayerState:GetPlayerName()
end

function QBCore.Functions.GetPlayerByCitizenId(citizenid)
	for src in pairs(QBCore.Players) do
		if QBCore.Players[src].PlayerData.citizenid == citizenid then
			return QBCore.Players[src]
		end
	end
	return nil
end

function QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
	return QBCore.Player.GetOfflinePlayer(citizenid)
end

function QBCore.Functions.GetPlayerByLicense(license)
	return QBCore.Player.GetPlayerByLicense(license)
end

function QBCore.Functions.GetPlayerByPhone(number)
	for src in pairs(QBCore.Players) do
		if QBCore.Players[src].PlayerData.charinfo.phone == number then
			return QBCore.Players[src]
		end
	end
	return nil
end

function QBCore.Functions.GetPlayerByAccount(account)
	for src in pairs(QBCore.Players) do
		if QBCore.Players[src].PlayerData.charinfo.account == account then
			return QBCore.Players[src]
		end
	end
	return nil
end

function QBCore.Functions.GetPlayerByCharInfo(property, value)
	for src in pairs(QBCore.Players) do
		local charinfo = QBCore.Players[src].PlayerData.charinfo
		if charinfo[property] ~= nil and charinfo[property] == value then
			return QBCore.Players[src]
		end
	end
	return nil
end

function QBCore.Functions.GetPlayers()
	local sources = {}
	for k in pairs(QBCore.Players) do
		sources[#sources + 1] = k
	end
	return sources
end

function QBCore.Functions.GetQBPlayers()
	return QBCore.Players
end

function QBCore.Functions.GetPlayersOnDuty(job)
	local players = {}
	local count = 0
	for src, Player in pairs(QBCore.Players) do
		if Player.PlayerData.job.name == job then
			if Player.PlayerData.job.onduty then
				players[#players + 1] = src
				count = count + 1
			end
		end
	end
	return players, count
end

function QBCore.Functions.GetDutyCount(job)
	local count = 0
	for _, Player in pairs(QBCore.Players) do
		if Player.PlayerData.job.name == job then
			if Player.PlayerData.job.onduty then
				count = count + 1
			end
		end
	end
	return count
end

function QBCore.Functions.CreateUseableItem(item, data)
	QBCore.UsableItems[item] = data
end

function QBCore.Functions.CanUseItem(item)
	return QBCore.UsableItems[item]
end

function QBCore.Functions.Debug(tbl)
	print(HELIXTable.Dump(tbl))
end

function QBCore.Functions.Notify(source, message, type, length, icon)
	TriggerClientEvent('QBCore:Notify', source, message, type, length, icon)
end

function QBCore.Functions.CreateCitizenId()
	return tostring(QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(5)):upper()
end

function QBCore.Functions.CreateAccountNumber()
	return 'US0'
		.. math.random(1, 9)
		.. 'QBCore'
		.. math.random(1111, 9999)
		.. math.random(1111, 9999)
		.. math.random(11, 99)
end

function QBCore.Functions.CreatePhoneNumber()
	return math.random(100, 999) .. math.random(1000000, 9999999)
end

function QBCore.Functions.CreateFingerId()
	return tostring(
		QBCore.Shared.RandomStr(2)
		.. QBCore.Shared.RandomInt(3)
		.. QBCore.Shared.RandomStr(1)
		.. QBCore.Shared.RandomInt(2)
		.. QBCore.Shared.RandomStr(3)
		.. QBCore.Shared.RandomInt(4)
	)
end

function QBCore.Functions.CreateWalletId()
	return 'QB-' .. math.random(11111111, 99999999)
end

function QBCore.Functions.CreateSerialNumber()
	return math.random(11111111, 99999999)
end

-- World Getters

function QBCore.Functions.GetClosestPlayer(source, coords)
	local player_ped = source:K2_GetPawn()
	if not player_ped then return end
	local player_coords = coords or player_ped:K2_GetActorLocation()
	local hits = Trace:SphereMulti(player_coords, player_coords, 1000)

	local closest_player, closest_distance = nil, -1
	for k, v in pairs(hits) do
		local distance = hit.Distance
		if closest_distance == -1 or distance < closest_distance then
			local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
			if hitActor:IsA(UE.AHCharacter) then
				if hitActor:IsPlayerControlled() then
					closest_player = hitActor:GetController() -- On client?
					closest_distance = distance
				end
			end
		end
	end
	return closest_player, closest_distance
end

function QBCore.Functions.GetClosestNPC(source, coords)

end

function QBCore.Functions.GetClosestVehicle(source, coords)
	local player_ped = source:K2_GetPawn()
	if not player_ped then return end
	local player_coords = coords or player_ped:K2_GetActorLocation()
	local hits = Trace:SphereMulti(player_coords, player_coords, 1000)

	local closest_vehicle, closest_distance = nil, -1
	for k, v in pairs(hits) do
		local distance = hit.Distance
		if closest_distance == -1 or distance < closest_distance then
			local _, _, _, _, _, _, _, _, _, hitActor = UE.UGameplayStatics.BreakHitResult(hit, _, _, _, _, _, _, _, _, _, hitActor, _, _, _, _, _, _, _, _)
			if hitActor:IsA(UE.AMMVehiclePawn) then
				if hitActor then
					closest_vehicle = hitActor
					closest_distance = distance
				end
			end
		end
	end
	return closest_vehicle, closest_distance
end

function QBCore.Functions.GetClosestWeapon(source, coords)

end

function QBCore.Functions.GetClosestObject(source, coords)

end

-- Spawn Vehicle

function QBCore.Functions.GeneratePlate(vehicle)
	if not vehicle then
		return
	end
	local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	local numbers = '0123456789'
	local plate = ''

	for i = 1, 3 do
		local randIndex = math.random(1, #letters)
		plate = plate .. letters:sub(randIndex, randIndex)
	end

	for i = 1, 5 do
		local randIndex = math.random(1, #numbers)
		plate = plate .. numbers:sub(randIndex, randIndex)
	end

	return plate
end

function QBCore.Functions.CreateWeapon(source, weapon_name, coords, rotation, itemInfo)

end

function QBCore.Functions.CreateVehicle(source, vehicle_name, coords, rotation, plate, fuel)

end

-- Shared Update Functions

function QBCore.Functions.SetMethod(methodName, handler)
	if type(methodName) ~= 'string' then
		return false, 'invalid_method_name'
	end
	QBCore.Functions[methodName] = handler
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.SetField(fieldName, data)
	if type(fieldName) ~= 'string' then
		return false, 'invalid_field_name'
	end
	QBCore[fieldName] = data
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddJob(jobName, job)
	if type(jobName) ~= 'string' then
		return false, 'invalid_job_name'
	end
	if QBCore.Shared.Jobs[jobName] then
		return false, 'job_exists'
	end
	QBCore.Shared.Jobs[jobName] = job
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddJobs(jobs)
	local shouldContinue = true
	local message = 'success'
	local errorItem = nil
	for key, value in pairs(jobs) do
		if type(key) ~= 'string' then
			message = 'invalid_job_name'
			shouldContinue = false
			errorItem = jobs[key]
			break
		end
		if QBCore.Shared.Jobs[key] then
			message = 'job_exists'
			shouldContinue = false
			errorItem = jobs[key]
			break
		end
		QBCore.Shared.Jobs[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveJob(jobName)
	if type(jobName) ~= 'string' then
		return false, 'invalid_job_name'
	end
	if not QBCore.Shared.Jobs[jobName] then
		return false, 'job_not_exists'
	end
	QBCore.Shared.Jobs[jobName] = nil
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateJob(jobName, job)
	if type(jobName) ~= 'string' then
		return false, 'invalid_job_name'
	end
	if not QBCore.Shared.Jobs[jobName] then
		return false, 'job_not_exists'
	end
	QBCore.Shared.Jobs[jobName] = job
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddItem(itemName, item)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if QBCore.Shared.Items[itemName] then
		return false, 'item_exists'
	end
	QBCore.Shared.Items[itemName] = item
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateItem(itemName, item)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if not QBCore.Shared.Items[itemName] then
		return false, 'item_not_exists'
	end
	QBCore.Shared.Items[itemName] = item
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddItems(items)
	local shouldContinue = true
	local message = 'success'
	local errorItem = nil
	for key, value in pairs(items) do
		if type(key) ~= 'string' then
			message = 'invalid_item_name'
			shouldContinue = false
			errorItem = items[key]
			break
		end
		if QBCore.Shared.Items[key] then
			message = 'item_exists'
			shouldContinue = false
			errorItem = items[key]
			break
		end
		QBCore.Shared.Items[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveItem(itemName)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if not QBCore.Shared.Items[itemName] then
		return false, 'item_not_exists'
	end
	QBCore.Shared.Items[itemName] = nil
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddGang(gangName, gang)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if QBCore.Shared.Gangs[gangName] then
		return false, 'gang_exists'
	end
	QBCore.Shared.Gangs[gangName] = gang
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddGangs(gangs)
	local shouldContinue = true
	local message = 'success'
	local errorItem = nil
	for key, value in pairs(gangs) do
		if type(key) ~= 'string' then
			message = 'invalid_gang_name'
			shouldContinue = false
			errorItem = gangs[key]
			break
		end
		if QBCore.Shared.Gangs[key] then
			message = 'gang_exists'
			shouldContinue = false
			errorItem = gangs[key]
			break
		end
		QBCore.Shared.Gangs[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveGang(gangName)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if not QBCore.Shared.Gangs[gangName] then
		return false, 'gang_not_exists'
	end
	QBCore.Shared.Gangs[gangName] = nil
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateGang(gangName, gang)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if not QBCore.Shared.Gangs[gangName] then
		return false, 'gang_not_exists'
	end
	QBCore.Shared.Gangs[gangName] = gang
	TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

-- Player Functions

function QBCore.Functions.SetPlayerBucket(source, bucket)
	if source and bucket then
		local plicense = QBCore.Functions.GetIdentifier(source)
		source:SetValue('instance', bucket, true)
		source:SetDimension(bucket)
		QBCore.Player_Buckets[plicense] = { id = source, bucket = bucket }
		return true
	else
		return false
	end
end

function QBCore.Functions.AddPlayerMethod(ids, methodName, handler)
	local idType = type(ids)
	if idType == 'number' then
		if ids == -1 then
			for _, v in pairs(QBCore.Players) do
				v.Functions.AddMethod(methodName, handler)
			end
		else
			if not QBCore.Players[ids] then
				return
			end

			QBCore.Players[ids].Functions.AddMethod(methodName, handler)
		end
	elseif idType == 'table' and table.type(ids) == 'array' then
		for i = 1, #ids do
			QBCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
		end
	end
end

function QBCore.Functions.AddPlayerField(ids, fieldName, data)
	local idType = type(ids)
	if idType == 'number' then
		if ids == -1 then
			for _, v in pairs(QBCore.Players) do
				v.Functions.AddField(fieldName, data)
			end
		else
			if not QBCore.Players[ids] then
				return
			end

			QBCore.Players[ids].Functions.AddField(fieldName, data)
		end
	elseif idType == 'table' and table.type(ids) == 'array' then
		for i = 1, #ids do
			QBCore.Functions.AddPlayerField(ids[i], fieldName, data)
		end
	end
end

for functionName, func in pairs(QBCore.Functions) do
	if type(func) == 'function' then
		exports('qb-core', functionName, func)
	end
end
