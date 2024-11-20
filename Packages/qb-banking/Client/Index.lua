local my_webui = WebUI('HUD', 'file://html/index.html')

local function OpenATM()
	QBCore.Functions.TriggerCallback('qb-banking:server:openATM', function(accounts, playerData, acceptablePins)
		my_webui:CallEvent('openATM', accounts, acceptablePins, playerData)
		my_webui:BringToFront()
		Input.SetMouseEnabled(true)
	end)
end

-- local function NearATM()
--     local playerCoords = GetEntityCoords(PlayerPedId())
--     for _, v in pairs(Config.atmModels) do
--         local hash = joaat(v)
--         local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
--         if atm then
--             return true
--         end
--     end
-- end

-- NUI Callback

my_webui:Subscribe('closeApp', function()
	Input.SetMouseEnabled(false)
end)

my_webui:Subscribe('withdraw', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:withdraw', function(status)
		my_webui:CallEvent('withdrawResponse', status)
	end, data)
end)

my_webui:Subscribe('deposit', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:deposit', function(status)
		my_webui:CallEvent('depositResponse', status)
	end, data)
end)

my_webui:Subscribe('internalTransfer', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:internalTransfer', function(status)
		my_webui:CallEvent('internalTransferResponse', status)
	end, data)
end)

my_webui:Subscribe('externalTransfer', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:externalTransfer', function(status)
		my_webui:CallEvent('externalTransferResponse', status)
	end, data)
end)

my_webui:Subscribe('orderCard', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:orderCard', function(status)
		my_webui:CallEvent('orderCardResponse', status)
	end, data)
end)

my_webui:Subscribe('openAccount', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:openAccount', function(status)
		my_webui:CallEvent('openAccountResponse', status)
	end, data)
end)

my_webui:Subscribe('renameAccount', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:renameAccount', function(status)
		my_webui:CallEvent('renameAccountResponse', status)
	end, data)
end)

my_webui:Subscribe('deleteAccount', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:deleteAccount', function(status)
		my_webui:CallEvent('deleteAccountResponse', status)
	end, data)
end)

my_webui:Subscribe('addUser', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:addUser', function(status)
		my_webui:CallEvent('addUserResponse', status)
	end, data)
end)

my_webui:Subscribe('removeUser', function(data)
	QBCore.Functions.TriggerCallback('qb-banking:server:removeUser', function(status)
		my_webui:CallEvent('removeUserResponse', status)
	end, data)
end)

-- Events

Events.SubscribeRemote('qb-banking:client:useCard', function()
	if NearATM() then
		OpenATM()
	end
end)

Events.SubscribeRemote('qb-banking:client:openBank', function(accounts, statements, playerData)
	my_webui:CallEvent('openBank', accounts, statements, playerData)
	my_webui:BringToFront()
	Input.SetMouseEnabled(true)
end)

-- Create Peds

QBCore.Functions.TriggerCallback('qb-banking:server:getPeds', function(peds)
	for ped, data in pairs(peds) do
		AddTargetEntity(ped, { options = data.options, distance = data.distance })
	end
end)

-- Create ATM

local atm = StaticMesh(
	Vector(-1537.5, 15208.4, -400),
	Rotator(0.0, 85.308410644531, 0.0),
	Config.atmModel,
	CollisionType.Normal
)

AddTargetEntity(atm, {
	options = {
		{
			label = 'Open ATM',
			icon = 'fas fa-university',
			action = function()
				OpenATM()
			end,
		},
	},
	distance = 400,
})
