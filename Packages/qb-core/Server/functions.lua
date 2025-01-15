QBCore.Functions = {}
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}

-- Callback Functions --

-- Create Server Callback
function QBCore.Functions.CreateCallback(name, cb)
	QBCore.ServerCallbacks[name] = cb
end

-- Trigger Server Callback
function QBCore.Functions.TriggerCallback(name, source, cb, ...)
	if not QBCore.ServerCallbacks[name] then
		return
	end
	QBCore.ServerCallbacks[name](source, cb, ...)
end

-- Trigger Client Callback
function QBCore.Functions.TriggerClientCallback(name, source, cb, ...)
	QBCore.ClientCallbacks[name] = cb
	Events.CallRemote('QBCore:Client:TriggerClientCallback', source, name, ...)
end

-- Getter Functions

function QBCore.Functions.GetIdentifier(source)
	return source:GetAccountID()
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
	local accountId = source:GetAccountID()
	local allPermissions = QBConfig.Server.Permissions
	local level_check = allPermissions[permission]
	if not level_check then return end
	if not QBCore.Functions.HasPermission(source, permission) then
		allPermissions[permission][accountId] = true
		QBCore.Commands.Refresh(source)
	end
end

function QBCore.Functions.RemovePermission(source, permission)
	local accountId = source:GetAccountID()
	local allPermissions = QBConfig.Server.Permissions
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
	local accountId = source:GetAccountID()
	local allPermissions = QBConfig.Server.Permissions
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
	if not source then
		return
	end
	if type(source) == 'number' then
		return QBCore.Players[source]
	else
		local playerId = source:GetID()
		return QBCore.Players[playerId]
	end
end

function QBCore.Functions.GetPlayerName(source)
	return source:GetAccountName()
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
	Console.Log(HELIXTable.Dump(tbl))
end

function QBCore.Functions.Notify(source, message, type, length, icon)
	Events.CallRemote('QBCore:Notify', source, message, type, length, icon)
end

function QBCore.Functions.CreateCitizenId()
	return tostring(QBShared.RandomStr(3) .. QBShared.RandomInt(5)):upper()
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
		QBShared.RandomStr(2)
		.. QBShared.RandomInt(3)
		.. QBShared.RandomStr(1)
		.. QBShared.RandomInt(2)
		.. QBShared.RandomStr(3)
		.. QBShared.RandomInt(4)
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
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local players = HCharacter.GetAll()
	local closest_player, closest_distance = nil, -1
	for i = 1, #players do
		local ped = players[i]
		if ped ~= player_ped then
			local ped_coords = ped:GetLocation()
			local distance = player_coords:Distance(ped_coords)
			if closest_distance == -1 or distance < closest_distance then
				closest_player = ped
				closest_distance = distance
			end
		end
	end
	return closest_player, closest_distance
end

function QBCore.Functions.GetClosestVehicle(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local vehicles = Vehicle.GetAll()
	local closest_vehicle, closest_distance = nil, -1
	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		local vehicle_coords = vehicle:GetLocation()
		local distance = player_coords:Distance(vehicle_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_vehicle = vehicle
			closest_distance = distance
		end
	end
	return closest_vehicle, closest_distance
end

function QBCore.Functions.GetClosestHVehicle(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local vehicles = HSimpleVehicle.GetAll()
	local closest_vehicle, closest_distance = nil, -1
	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		local vehicle_coords = vehicle:GetLocation()
		local distance = player_coords:Distance(vehicle_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_vehicle = vehicle
			closest_distance = distance
		end
	end
	return closest_vehicle, closest_distance
end

function QBCore.Functions.GetClosestWeapon(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local weapons = Weapon.GetAll()
	local closest_weapon, closest_distance = nil, -1
	for i = 1, #weapons do
		local weapon = weapons[i]
		local weapon_coords = weapon:GetLocation()
		local distance = player_coords:Distance(weapon_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_weapon = weapon
			closest_distance = distance
		end
	end
	return closest_weapon, closest_distance
end

function QBCore.Functions.GetClosestCharacter(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local characters = Character.GetAll()
	local closest_ped, closest_distance = nil, -1
	for i = 1, #characters do
		local ped = characters[i]
		local ped_coords = ped:GetLocation()
		local distance = player_coords:Distance(ped_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_ped = ped
			closest_distance = distance
		end
	end
	return closest_ped, closest_distance
end

function QBCore.Functions.GetClosestSCharacter(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local characters = CharacterSimple.GetAll()
	local closest_ped, closest_distance = nil, -1
	for i = 1, #characters do
		local ped = characters[i]
		local ped_coords = ped:GetLocation()
		local distance = player_coords:Distance(ped_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_ped = ped
			closest_distance = distance
		end
	end
	return closest_ped, closest_distance
end

function QBCore.Functions.GetClosestPawn(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then return end
	local player_coords = coords or player_ped:GetLocation()
	local characters = HPawn.GetAll()
	local closest_pawn, closest_distance = nil, -1
	for i = 1, #characters do
		local ped = characters[i]
		local ped_coords = ped:GetLocation()
		local distance = player_coords:Distance(ped_coords)
		if closest_distance == -1 or distance < closest_distance then
			closest_pawn = ped
			closest_distance = distance
		end
	end
	return closest_pawn, closest_distance
end

function QBCore.Functions.GetClosestProp(source, coords)
	local player_ped = source:GetControlledCharacter()
	if not player_ped then
		return
	end
	local player_coords = coords or player_ped:GetLocation()
	local props = Prop.GetAll()
	local closest_prop, closest_distance = nil, -1
	for i = 1, #props do
		local prop = props[i]
		local prop_ooords = prop:GetLocation()
		local distance = player_coords:Distance(prop_ooords)
		if closest_distance == -1 or distance < closest_distance then
			closest_prop = prop
			closest_distance = distance
		end
	end
	return closest_prop, closest_distance
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
	local weapon_info = QBShared.Weapons[weapon_name]
	if not weapon_info then return false end
	local ped = source:GetControlledCharacter()
	if not ped then return false end
	local location = ped:GetLocation()
	local player_rotation = ped:GetRotation()
	if not coords then coords = location end
	if not rotation then rotation = player_rotation end
	local ammo = itemInfo and itemInfo.info and itemInfo.info.ammo or 0
	local quality = itemInfo and itemInfo.info and itemInfo.info.quality or 100
	local new_weapon = Weapon(coords, rotation, weapon_info.asset_name)
	if not new_weapon then return false end
	-- General
	new_weapon:SetAmmoSettings(ammo, 0)
	new_weapon:SetClipCapacity(weapon_info.ammo_settings.clip_capacity)
	if weapon_info.damage then new_weapon:SetDamage(weapon_info.damage) end
	if weapon_info.spread then new_weapon:SetSpread(weapon_info.spread) end
	if weapon_info.recoil then new_weapon:SetRecoil(weapon_info.recoil) end
	if weapon_info.cadence then new_weapon:SetCadence(weapon_info.cadence) end
	if weapon_info.auto_reload then new_weapon:SetAutoReload(weapon_info.auto_reload) end
	new_weapon:SetBulletSettings(
		weapon_info.bullet_settings.bullet_count,
		weapon_info.bullet_settings.bullet_max_distance,
		weapon_info.bullet_settings.bullet_velocity,
		weapon_info.bullet_settings.bullet_color
	)
	new_weapon:SetWallbangSettings(
		weapon_info.wallbang_settings.max_distance,
		weapon_info.wallbang_settings.damage_multiplier
	)
	-- Handling
	if weapon_info.handlingMode then new_weapon:SetHandlingMode(weapon_info.handlingMode) end
	if weapon_info.right_hand_offset then new_weapon:SetRightHandOffset(weapon_info.right_hand_offset) end
	if weapon_info.left_hand_bone then new_weapon:SetLeftHandBone(weapon_info.left_hand_bone) end
	-- Particles
	if weapon_info.particles.bullet_trail then new_weapon:SetParticlesBulletTrail(weapon_info.particles.bullet_trail) end
	if weapon_info.particles.barrel then new_weapon:SetParticlesBarrel(weapon_info.particles.barrel) end
	if weapon_info.particles.shells then new_weapon:SetParticlesShells(weapon_info.particles.shells) end
	-- Sounds
	if weapon_info.sounds.dry then new_weapon:SetSoundDry(weapon_info.sounds.dry) end
	if weapon_info.sounds.load then new_weapon:SetSoundLoad(weapon_info.sounds.load) end
	if weapon_info.sounds.unload then new_weapon:SetSoundUnload(weapon_info.sounds.unload) end
	if weapon_info.sounds.zooming then new_weapon:SetSoundZooming(weapon_info.sounds.zooming) end
	if weapon_info.sounds.aim then new_weapon:SetSoundAim(weapon_info.sounds.aim) end
	if weapon_info.sounds.fire then new_weapon:SetSoundFire(weapon_info.sounds.fire) end
	if weapon_info.sounds.last_bullets.asset_path and weapon_info.sounds.last_bullets.bullet_count then
		new_weapon:SetSoundFireLastBullets(weapon_info.sounds.last_bullets.asset_path, weapon_info.sounds.last_bullets.bullet_count)
	end
	-- Animations
	if weapon_info.animations.fire then new_weapon:SetAnimationFire(weapon_info.animations.fire) end
	if weapon_info.animations.reload then new_weapon:SetAnimationReload(weapon_info.animations.reload) end
	if weapon_info.animations.character_fire then new_weapon:SetAnimationCharacterFire(weapon_info.animations.character_fire) end
	if weapon_info.animations.character_holster then new_weapon:SetAnimationCharacterHolster(weapon_info.animations.character_holster) end
	if weapon_info.animations.character_equip then new_weapon:SetAnimationCharacterEquip(weapon_info.animations.character_equip) end
	if weapon_info.animations.character_reload then new_weapon:SetAnimationCharacterReload(weapon_info.animations.character_reload) end
	-- Meshes
	if weapon_info.magazine_mesh then new_weapon:SetMagazineMesh(weapon_info.magazine_mesh) end
	if weapon_info.crosshair_material then new_weapon:SetCrosshairMaterial(weapon_info.crosshair_material) end
	-- Values
	new_weapon:SetValue('name', weapon_name, true)
	new_weapon:SetValue('quality', quality, true)
	new_weapon:SetValue('ammo_type', weapon_info.ammo_type, true)
	-- Attachments
	local weapon_attachments = weapon_info.default_attachments
	if weapon_attachments then
		for attachment_name, attachment_data in pairs(weapon_attachments) do
			new_weapon:AddStaticMeshAttached(
				attachment_name,
				attachment_data.asset_name,
				string.upper(QBShared.FirstToUpper(attachment_name)),
				attachment_data.relative_location,
				attachment_data.relative_rotation
			)
		end
	end
	return new_weapon
end

function QBCore.Functions.CreateVehicle(source, vehicle_name, coords, rotation, plate, fuel)
	local vehicle_data = QBShared.Vehicles[vehicle_name]
	if not vehicle_data then return false end
	local ped = source:GetControlledCharacter()
	if not ped then return false end
	local location = ped:GetLocation()
	local control_rotation = ped:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = location + Vector(0, 0, 40) + forward_vector * Vector(200)
	if not coords then coords = spawn_location end
	if not rotation then rotation = Rotator(0, 0, 0) end
	local vehicle = HSimpleVehicle(coords, rotation, vehicle_data.asset_name, vehicle_data.collision_type, vehicle_data.gravity_enabled)
	if not vehicle then return false end
	if vehicle_data.doors then
		for door_index, door_data in pairs(vehicle_data.doors) do
			vehicle:SetDoor(
				door_index,
				door_data.offset_location,
				door_data.seat_location,
				door_data.seat_rotation,
				door_data.trigger_radius,
				door_data.leave_lateral_offset
			)
		end
	end
	local plate_number = plate or QBCore.Functions.GeneratePlate(vehicle)
	vehicle:SetValue('plate', plate_number, true)
	local fuel_value = fuel or 100
	vehicle:SetValue('fuel', fuel_value, true)
	return vehicle
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
	if QBShared.Jobs[jobName] then
		return false, 'job_exists'
	end
	QBShared.Jobs[jobName] = job
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
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
		if QBShared.Jobs[key] then
			message = 'job_exists'
			shouldContinue = false
			errorItem = jobs[key]
			break
		end
		QBShared.Jobs[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	Events.CallRemote('QBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveJob(jobName)
	if type(jobName) ~= 'string' then
		return false, 'invalid_job_name'
	end
	if not QBShared.Jobs[jobName] then
		return false, 'job_not_exists'
	end
	QBShared.Jobs[jobName] = nil
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateJob(jobName, job)
	if type(jobName) ~= 'string' then
		return false, 'invalid_job_name'
	end
	if not QBShared.Jobs[jobName] then
		return false, 'job_not_exists'
	end
	QBShared.Jobs[jobName] = job
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddItem(itemName, item)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if QBShared.Items[itemName] then
		return false, 'item_exists'
	end
	QBShared.Items[itemName] = item
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateItem(itemName, item)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if not QBShared.Items[itemName] then
		return false, 'item_not_exists'
	end
	QBShared.Items[itemName] = item
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
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
		if QBShared.Items[key] then
			message = 'item_exists'
			shouldContinue = false
			errorItem = items[key]
			break
		end
		QBShared.Items[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	Events.CallRemote('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveItem(itemName)
	if type(itemName) ~= 'string' then
		return false, 'invalid_item_name'
	end
	if not QBShared.Items[itemName] then
		return false, 'item_not_exists'
	end
	QBShared.Items[itemName] = nil
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.AddGang(gangName, gang)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if QBShared.Gangs[gangName] then
		return false, 'gang_exists'
	end
	QBShared.Gangs[gangName] = gang
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
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
		if QBShared.Gangs[key] then
			message = 'gang_exists'
			shouldContinue = false
			errorItem = gangs[key]
			break
		end
		QBShared.Gangs[key] = value
	end
	if not shouldContinue then
		return false, message, errorItem
	end
	Events.CallRemote('QBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
	Events.Call('QBCore:Server:UpdateObject')
	return true, message, nil
end

function QBCore.Functions.RemoveGang(gangName)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if not QBShared.Gangs[gangName] then
		return false, 'gang_not_exists'
	end
	QBShared.Gangs[gangName] = nil
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
	Events.Call('QBCore:Server:UpdateObject')
	return true, 'success'
end

function QBCore.Functions.UpdateGang(gangName, gang)
	if type(gangName) ~= 'string' then
		return false, 'invalid_gang_name'
	end
	if not QBShared.Gangs[gangName] then
		return false, 'gang_not_exists'
	end
	QBShared.Gangs[gangName] = gang
	Events.CallRemote('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
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
