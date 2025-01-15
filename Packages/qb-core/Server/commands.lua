local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
QBCore.Commands = {}
QBCore.Commands.List = {}

-- Chat Listener

Chat.Subscribe('PlayerSubmit', function(message, player)
	if message:sub(1, 1) == '/' then
		local cmd, argsString = message:match('^/([^%s]+)%s*(.*)')
		if not argsString then
			argsString = ''
		end
		Events.Call('QBCore:Console:CallCommand', player, cmd, argsString)
		return false
	end
end)

-- Register & Refresh Commands

Events.Subscribe('QBCore:Console:CallCommand', function(source, name, argsString)
	local command = QBCore.Commands.List[name]
	if not command then
		return
	end
	local permission = command.permission

	if not QBCore.Functions.HasPermission(source, permission) then
		print(source:GetAccountName() .. ' tried to execute command ' .. name .. ' without permission.')
		return
	end

	local args = {}
	local argsrequired = command.argsrequired

	if argsString then
		if argsString:find(',') then
			for arg in argsString:gmatch('[^,]+') do
				table.insert(args, arg)
			end
		else
			for arg in argsString:gmatch('%S+') do
				table.insert(args, arg)
			end
		end
	end

	local arguments = command.arguments

	if argsrequired and #args < #arguments then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.missing_args'), 'error')
		return
	end

	print('Command ' .. name .. ' executed by ' .. source:GetAccountName())

	command.callback(source, args)
end)

Events.SubscribeRemote('QBCore:Console:CallCommand', function(source, name, argsString)
	local command = QBCore.Commands.List[name]
	if not command then
		return
	end
	local permission = command.permission

	if not QBCore.Functions.HasPermission(source, permission) then
		print(source:GetAccountName() .. ' tried to execute command ' .. name .. ' without permission.')
		return
	end

	local args = {}
	local argsrequired = command.argsrequired

	if argsString then
		if argsString:find(',') then
			for arg in argsString:gmatch('[^,]+') do
				table.insert(args, arg)
			end
		else
			for arg in argsString:gmatch('%S+') do
				table.insert(args, arg)
			end
		end
	end

	local arguments = command.arguments

	if argsrequired and #args < #arguments then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.missing_args'), 'error')
		return
	end

	print('Command ' .. name .. ' executed by ' .. source:GetAccountName())

	command.callback(source, args)
end)

function QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
	local lowerName = name:lower()

	local argStrings = {}
	for _, arg in ipairs(arguments) do
		if type(arg) == 'table' and arg.name and arg.help then
			local argString = arg.name .. ': ' .. arg.help
			table.insert(argStrings, argString)
		else
			print('Invalid argument format:', arg)
		end
	end

	QBCore.Commands.List[lowerName] = {
		name = lowerName,
		help = help,
		arguments = argStrings,
		argsrequired = argsrequired,
		callback = callback,
		permission = permission,
	}

	-- routeQbCommandsToCmdr(lowerName, help, callback)
end

function QBCore.Commands.Refresh(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	for commandName, commandData in pairs(QBCore.Commands.List) do
		local description = commandData.help or 'No description available'
		Events.CallRemote('QBCore:Console:RegisterCommand', source, commandName, description, commandData.arguments)
	end
end

-- Commands

QBCore.Commands.Add('movechat', 'Move Chat', { { name = 'layout', help = 'bottom_left | center_left | top_left | bottom_center | center | top_center | bottom_right | center_right | top_right', }, }, true, function(source, args)
	local layout = args[1]
	Events.CallRemote('QBCore:Client:SetChatLayout', source, layout)
end, 'user')

QBCore.Commands.Add('clear', 'Clear chat', {}, false, function(source)
	Events.CallRemote('QBCore:Client:ClearChat', source)
end, 'user')

QBCore.Commands.Add('clearall', 'Clear global chat', {}, false, function()
	Events.BroadcastRemote('QBCore:Client:ClearChat')
end, 'admin')

QBCore.Commands.Add('announce', 'Make an announcement', { { name = 'message', help = 'Message to send' } }, true, function(_, args)
	local message = table.concat(args, ' ')
	Chat.BroadcastMessage('Announcement: ' .. message)
end, 'admin')

QBCore.Commands.Add('clearprops', '', {}, false, function(source)
	local ped = source:GetControlledCharacter()
	if not ped then
		return
	end
	local attached = ped:GetAttachedEntities()
	for i = 1, #attached do
		attached[i]:Detach()
		attached[i]:Destroy()
	end
end, 'user')

QBCore.Commands.Add('dm', 'DM Player', { { name = 'id', help = 'Player ID' }, { name = 'message', help = 'Message to send' } }, true, function(source, args)
	local targetId = tonumber(args[1])
	local message = table.concat(args, ' ', 2)
	local target = QBCore.Functions.GetPlayer(targetId)
	if not target then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	local sourcePlayer = QBCore.Functions.GetPlayer(source)
	if not sourcePlayer then
		return
	end
	local targetPlayer = target.PlayerData.source
	local prefix = sourcePlayer.PlayerData.charinfo.firstname .. ' ' .. sourcePlayer.PlayerData.charinfo.lastname
	Chat.SendMessage(targetPlayer, '(' .. source:GetID() .. ') ' .. prefix .. ': ' .. message)
end, 'user')

QBCore.Commands.Add('id', 'Check ID', {}, false, function(source)
	local player_id = source:GetID()
	Events.CallRemote('QBCore:Notify', source, 'Your ID is: ' .. player_id)
end, 'user')

-- Permissions

QBCore.Commands.Add('addpermission', Lang:t('command.addpermission.help'), { { name = Lang:t('command.addpermission.params.id.name'), help = Lang:t('command.addpermission.params.id.help'), }, { name = Lang:t('command.addpermission.params.permission.name'), help = Lang:t('command.addpermission.params.permission.help'), }, }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	local permission = tostring(args[2]):lower()
	QBCore.Functions.AddPermission(Player.PlayerData.source, permission)
end, 'god')

QBCore.Commands.Add('removepermission', Lang:t('command.removepermission.help'), { { name = Lang:t('command.removepermission.params.id.name'), help = Lang:t('command.removepermission.params.id.help'), }, { name = Lang:t('command.removepermission.params.permission.name'), help = Lang:t('command.removepermission.params.permission.help'), }, }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	local permission = tostring(args[2]):lower()
	QBCore.Functions.RemovePermission(Player.PlayerData.source, permission)
end, 'god')

-- Vehicle

QBCore.Commands.Add('car', Lang:t('command.car.help'), { { name = Lang:t('command.car.params.model.name'), help = Lang:t('command.car.params.model.help') } }, true, function(source, args)
	local vehicle_name = args[1] and args[1]:lower()
	local vehicle = QBCore.Functions.CreateVehicle(source, vehicle_name)
	if not vehicle then return end
	local ped = source:GetControlledCharacter()
	if not ped then return end
	ped:EnterVehicle(vehicle)
end, 'admin')

QBCore.Commands.Add('weapon', Lang:t('command.weapon.help'), { { name = Lang:t('command.weapon.params.model.name'), help = Lang:t('command.weapon.params.model.help') } }, true, function(source, args)
	local weapon_name = args[1] and args[1]:lower()
	local weapon = QBCore.Functions.CreateWeapon(source, weapon_name)
	if weapon then
		local ped = source:GetControlledCharacter()
		if ped then
			ped:PickUp(weapon)
		end
	end
end, 'admin')

QBCore.Commands.Add('maxammo', 'Max Ammo', {}, false, function(source)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	local holding_item = ped:GetPicked()
	if not holding_item then return end
	local is_weapon = holding_item:IsA(Weapon)
	if not is_weapon then return end
	local clip_capacity = holding_item:GetClipCapacity()
	holding_item:SetAmmoClip(clip_capacity)
end, 'admin')

-- Delete

QBCore.Commands.Add('dv', Lang:t('command.dv.help'), {}, false, function(source)
	local vehicle = QBCore.Functions.GetClosestHVehicle(source)
	if not vehicle then
		return
	end
	vehicle:Destroy()
end, 'admin')

QBCore.Commands.Add('dvall', Lang:t('command.dvall.help'), {}, false, function()
	local vehicles = HSimpleVehicle.GetAll()
	for _, vehicle in ipairs(vehicles) do
		vehicle:Destroy()
	end
end, 'admin')

QBCore.Commands.Add('dvp', Lang:t('command.dvp.help'), {}, false, function()
	local peds = CharacterSimple.GetAll()
	for _, ped in ipairs(peds) do
		ped:Destroy()
	end
end, 'admin')

QBCore.Commands.Add('dvo', Lang:t('command.dvo.help'), {}, false, function()
	local objects = Prop.GetAll()
	for _, object in ipairs(objects) do
		object:Destroy()
	end
end, 'admin')

QBCore.Commands.Add('dvw', Lang:t('command.dvo.help'), {}, false, function()
	local weapons = Weapon.GetAll()
	for _, weapon in ipairs(weapons) do
		weapon:Destroy()
	end
end, 'admin')

-- Money

QBCore.Commands.Add('givemoney', Lang:t('command.givemoney.help'), { { name = Lang:t('command.givemoney.params.id.name'), help = Lang:t('command.givemoney.params.id.help') }, { name = Lang:t('command.givemoney.params.moneytype.name'), help = Lang:t('command.givemoney.params.moneytype.help'), }, { name = Lang:t('command.givemoney.params.amount.name'), help = Lang:t('command.givemoney.params.amount.help') } }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]), 'Admin give money')
end, 'admin')

QBCore.Commands.Add('setmoney', Lang:t('command.setmoney.help'), { { name = Lang:t('command.setmoney.params.id.name'), help = Lang:t('command.setmoney.params.id.help') }, { name = Lang:t('command.setmoney.params.moneytype.name'), help = Lang:t('command.setmoney.params.moneytype.help'), }, { name = Lang:t('command.setmoney.params.amount.name'), help = Lang:t('command.setmoney.params.amount.help') }, }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
end, 'admin')

-- Job

QBCore.Commands.Add('job', Lang:t('command.job.help'), {}, false, function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local PlayerJob = Player.PlayerData.job
	Events.CallRemote(
		'QBCore:Notify',
		source,
		Lang:t('info.job_info', { value = PlayerJob.label, value2 = PlayerJob.grade.name, value3 = PlayerJob.onduty })
	)
end, 'user')

QBCore.Commands.Add('setjob', Lang:t('command.setjob.help'), { { name = Lang:t('command.setjob.params.id.name'), help = Lang:t('command.setjob.params.id.help') }, { name = Lang:t('command.setjob.params.job.name'), help = Lang:t('command.setjob.params.job.help') }, { name = Lang:t('command.setjob.params.grade.name'), help = Lang:t('command.setjob.params.grade.help') }, }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
end, 'admin')

-- Gang

QBCore.Commands.Add('gang', Lang:t('command.gang.help'), {}, false, function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local PlayerGang = Player.PlayerData.gang
	Events.CallRemote(
		'QBCore:Notify',
		source,
		Lang:t('info.gang_info', { value = PlayerGang.label, value2 = PlayerGang.grade.name })
	)
end, 'user')

QBCore.Commands.Add('setgang', Lang:t('command.setgang.help'), { { name = Lang:t('command.setgang.params.id.name'), help = Lang:t('command.setgang.params.id.help') }, { name = Lang:t('command.setgang.params.gang.name'), help = Lang:t('command.setgang.params.gang.help') }, { name = Lang:t('command.setgang.params.grade.name'), help = Lang:t('command.setgang.params.grade.help') }, }, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if not Player then
		Events.CallRemote('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
		return
	end
	Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
end, 'admin')
