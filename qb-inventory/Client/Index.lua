local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local my_webui = WebUI('Inventory', 'qb-inventory/Client/html/index.html')
Player_data = QBCore.Functions.GetPlayerData()
local hotbarShown = false

Package.Require('drops.lua')
Package.Require('vehicles.lua')

-- Handlers

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
	--LocalPlayer.state:set('inv_busy', false, true)
	Player_data = QBCore.Functions.GetPlayerData()
	QBCore.Functions.TriggerCallback('qb-inventory:server:GetCurrentDrops', function(theDrops)
		Drops = theDrops
	end)
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
	-- LocalPlayer.state:set('inv_busy', true, true)
	Player_data = {}
end)

Events.SubscribeRemote('QBCore:Player:SetPlayerData', function(val)
	Player_data = val
end)

-- Functions

local function FormatWeaponAttachments(itemdata)
	if not itemdata.info or not itemdata.info.attachments or #itemdata.info.attachments == 0 then
		return {}
	end
	local attachments = {}
	local weaponName = itemdata.name
	local WeaponAttachments = getConfigWeaponAttachments()
	if not WeaponAttachments then
		return {}
	end
	for attachmentType, weapons in pairs(WeaponAttachments) do
		local componentHash = weapons[weaponName]
		if componentHash then
			for _, attachmentData in pairs(itemdata.info.attachments) do
				if attachmentData.component == componentHash then
					local label = QBShared.Items[attachmentType] and QBShared.Items[attachmentType].label or 'Unknown'
					attachments[#attachments + 1] = {
						attachment = attachmentType,
						label = label,
					}
				end
			end
		end
	end
	return attachments
end

-- Events

Events.Subscribe('qb-inventory:client:requiredItems', function(items, bool)
	local itemTable = {}
	if bool then
		for k in pairs(items) do
			itemTable[#itemTable + 1] = {
				item = items[k].name,
				label = QBShared.Items[items[k].name]['label'],
				image = items[k].image,
			}
		end
	end

	my_webui:CallFunction('requiredItem', { items = itemTable, toggle = bool })
end)

Events.SubscribeRemote('qb-inventory:client:hotbar', function(items)
	hotbarShown = not hotbarShown
	my_webui:CallFunction('toggleHotbar', { open = hotbarShown, items = items })
end)

Events.Subscribe('qb-inventory:client:closeInv', function()
	my_webui:CallFunction('closeInventory')
end)

Events.Subscribe('qb-inventory:client:updateInventory', function(items)
	my_webui:CallFunction('updateInventory', { inventory = items })
end)

Events.Subscribe('qb-inventory:client:ItemBox', function(itemData, type, amount)
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

Events.SubscribeRemote('qb-inventory:client:ItemBox', function(itemData, type, amount)
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

Events.SubscribeRemote('qb-inventory:client:useItem', function(bool, itemData)
	my_webui:CallFunction('UseItemResponse', bool, itemData)
end)

Events.SubscribeRemote('qb-inventory:client:openInventory', function(items, other)
	my_webui:CallFunction(
		'openInventory',
		{ inventory = items, slots = Config.MaxSlots, maxweight = Config.MaxWeight, other = other }
	)
	my_webui:BringToFront() -- Unused
	Input.SetMouseEnabled(true)
end)

-- NUI Calls

my_webui:RegisterEventHandler('SetInventoryData', function(data)
	Events.CallRemote(
		'qb-inventory:server:SetInventoryData',
		data.fromInventory,
		data.toInventory,
		data.fromSlot,
		data.toSlot,
		data.fromAmount,
		data.toAmount
	)
end)

my_webui:RegisterEventHandler('CloseInventory', function(name)
	Input.SetMouseEnabled(false)
	Input.SetInputEnabled(true)
	if name then
		Events.CallRemote('qb-inventory:server:closeInventory', name)
	elseif CurrentDrop then
		Events.CallRemote('qb-inventory:server:closeInventory', CurrentDrop)
		CurrentDrop = nil
	else
		Events.CallRemote('qb-inventory:server:closeInventory')
	end
end)

my_webui:RegisterEventHandler('PlayDropFail', function()
	--PlaySound(-1, 'Place_Prop_Fail', 'DLC_Dmod_Prop_Editor_Sounds', 0, 0, 1)
end)

my_webui:RegisterEventHandler('Notify', function(data)
	QBCore.Functions.Notify(data.message, data.type)
end)

my_webui:RegisterEventHandler('UseItem', function(data)
	Events.CallRemote('qb-inventory:server:useItem', data.item)
end)

my_webui:RegisterEventHandler('DropItem', function(item)
	QBCore.Functions.TriggerCallback('qb-inventory:server:createDrop', function(dropId)
		if dropId then
			local newDropId = 'drop-' .. dropId
			my_webui:CallFunction('DropItemResponse', newDropId, item)
		end
	end, item)
end)

my_webui:RegisterEventHandler('AttemptPurchase', function(data)
	QBCore.Functions.TriggerCallback('qb-inventory:server:attemptPurchase', function(canPurchase)
		my_webui:CallFunction('AttemptPurchaseResponse', canPurchase, data)
	end, data)
end)

my_webui:RegisterEventHandler('GiveItem', function(data)
	local player, distance = QBCore.Functions.GetClosestPlayer()
	if player and distance < 500 then
		local playerId = player:GetID()
		QBCore.Functions.TriggerCallback('qb-inventory:server:giveItem', function(success)
			my_webui:CallFunction('GiveItemResponse', success, data)
		end, playerId, data.item.name)
	else
		QBCore.Functions.Notify(Lang:t('notify.nonb'), 'error')
	end
end)

-- qb-weapons

my_webui:RegisterEventHandler('GetWeaponData', function(cData)
	local data = {
		WeaponData = QBShared.Items[cData.weapon],
		AttachmentData = FormatWeaponAttachments(cData.ItemData),
	}
	my_webui:CallFunction('GetWeaponDataResponse', data)
end)

my_webui:RegisterEventHandler('RemoveAttachment', function(data)
	local ped = PlayerPedId()
	local WeaponData = data.WeaponData
	local allAttachments = getConfigWeaponAttachments()
	local Attachment = allAttachments[data.AttachmentData.attachment][WeaponData.name]
	QBCore.Functions.TriggerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
		if NewAttachments ~= false then
			local Attachies = {}
			RemoveWeaponComponentFromPed(ped, joaat(WeaponData.name), joaat(Attachment))
			for _, v in pairs(NewAttachments) do
				for attachmentType, weapons in pairs(allAttachments) do
					local componentHash = weapons[WeaponData.name]
					if componentHash and v.component == componentHash then
						local label = QBShared.Items[attachmentType] and QBShared.Items[attachmentType].label
							or 'Unknown'
						Attachies[#Attachies + 1] = {
							attachment = attachmentType,
							label = label,
						}
					end
				end
			end
			local DJATA = {
				Attachments = Attachies,
				WeaponData = WeaponData,
			}
			my_webui:CallFunction('GetWeaponDataResponse', DJATA)
		else
			RemoveWeaponComponentFromPed(ped, joaat(WeaponData.name), joaat(Attachment))
		end
	end, data.AttachmentData, WeaponData)
end)

-- Commands

Input.Register('Inventory', Config.Keybinds.Open)
Input.Register('Hotbar', Config.Keybinds.Hotbar)

Input.Bind('Inventory', InputEvent.Pressed, function()
	Events.CallRemote('qb-inventory:server:openInventory')
	Input.SetInputEnabled(false)
end)

Input.Bind('Hotbar', InputEvent.Pressed, function()
	if Input.IsMouseEnabled() then return end
	Events.CallRemote('qb-inventory:server:toggleHotbar')
end)

Input.Subscribe('KeyPress', function(key_name)
	if Input.IsMouseEnabled() then return end
	local index
	if key_name == 'One' then
		index = 1
	elseif key_name == 'Two' then
		index = 2
	elseif key_name == 'Three' then
		index = 3
	elseif key_name == 'Four' then
		index = 4
	elseif key_name == 'Five' then
		index = 5
	end

	if index then
		local itemData = Player_data.items[index]
		if not itemData then
			return false
		end
		Events.Call('qb-inventory:client:closeInv')
		Events.CallRemote('qb-inventory:server:useItem', itemData)
	end
end)
