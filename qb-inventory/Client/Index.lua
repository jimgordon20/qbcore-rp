local Lang = require('Shared/locales/en')
Player_data = exports['qb-core']:GetPlayerData()
local hotbarShown = false

require('Client/drops')
require('Client/vehicles')
-- Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
	--LocalPlayer.state:set('inv_busy', false, true)
	Player_data = exports['qb-core']:GetPlayerData()
	exports['qb-core']:TriggerCallback('qb-inventory:server:GetCurrentDrops', function(theDrops)
		Drops = theDrops
	end)
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
	-- LocalPlayer.state:set('inv_busy', true, true)
	Player_data = {}
end)

RegisterClientEvent('QBCore:Player:SetPlayerData', function(val)
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

RegisterClientEvent('qb-inventory:client:requiredItems', function(items, bool)
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

RegisterClientEvent('qb-inventory:client:hotbar', function(items)
	hotbarShown = not hotbarShown
	my_webui:CallFunction('toggleHotbar', { open = hotbarShown, items = items })
end)

RegisterClientEvent('qb-inventory:client:closeInv', function()
	my_webui:CallFunction('closeInventory')
end)

RegisterClientEvent('qb-inventory:client:updateInventory', function(items)
	my_webui:CallFunction('updateInventory', { inventory = items })
end)

RegisterClientEvent('qb-inventory:client:ItemBox', function(itemData, type, amount)
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

RegisterClientEvent('qb-inventory:client:ItemBox', function(itemData, type, amount)
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

RegisterClientEvent('qb-inventory:client:useItem', function(bool, itemData)
	my_webui:CallFunction('UseItemResponse', bool, itemData)
end)

RegisterClientEvent('qb-inventory:client:openInventory', function(items, other)
	my_webui = WebUI('Inventory', 'qb-inventory/Client/html/index.html', true)
	-- NUI Events
	my_webui:RegisterEventHandler('SetInventoryData', function(data)
		TriggerServerEvent(
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
--[[ 		Input.SetMouseEnabled(false)
		Input.SetInputEnabled(true) ]]
		my_webui:Destroy()
		if name then
			TriggerServerEvent('qb-inventory:server:closeInventory', name)
		elseif CurrentDrop then
			TriggerServerEvent('qb-inventory:server:closeInventory', CurrentDrop)
			CurrentDrop = nil
		else
			TriggerServerEvent('qb-inventory:server:closeInventory')
		end
	end)

	my_webui:RegisterEventHandler('PlayDropFail', function()
		--PlaySound(-1, 'Place_Prop_Fail', 'DLC_Dmod_Prop_Editor_Sounds', 0, 0, 1)
	end)

	my_webui:RegisterEventHandler('Notify', function(data)
		exports['qb-core']:Notify(data.message, data.type)
	end)

	my_webui:RegisterEventHandler('UseItem', function(data)
		TriggerServerEvent('qb-inventory:server:useItem', data.item)
	end)

	my_webui:RegisterEventHandler('DropItem', function(item)
		exports['qb-core']:TriggerCallback('qb-inventory:server:createDrop', function(dropId)
			if dropId then
				local newDropId = 'drop-' .. dropId
				my_webui:CallFunction('DropItemResponse', newDropId, item)
			end
		end, item)
	end)

	my_webui:RegisterEventHandler('AttemptPurchase', function(data)
		exports['qb-core']:TriggerCallback('qb-inventory:server:attemptPurchase', function(canPurchase)
			my_webui:CallFunction('AttemptPurchaseResponse', canPurchase, data)
		end, data)
	end)

	my_webui:RegisterEventHandler('GiveItem', function(data)
		local player, distance = exports['qb-core']:GetClosestPlayer()
		if player and distance < 500 then
			local playerId = player:GetID()
			exports['qb-core']:TriggerCallback('qb-inventory:server:giveItem', function(success)
				my_webui:CallFunction('GiveItemResponse', success, data)
			end, playerId, data.item.name)
		else
			exports['qb-core']:Notify(Lang:t('notify.nonb'), 'error')
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
		exports['qb-core']:TriggerCallback('weapons:server:RemoveAttachment', function(NewAttachments)
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

	my_webui.Browser.OnLoadCompleted:Add(my_webui.Host, function()
		my_webui:CallFunction(
			'openInventory',
			{ inventory = items, slots = Config.MaxSlots, maxweight = Config.MaxWeight, other = other }
		)
	end)
end)

-- Open UI
--[[ Timer.CreateThread(function()
    while true do
        local Player = HPlayer
        if not Player then return end
		local key = UE.FKey(Config.Keybinds.Open)
		key.KeyName = Config.Keybinds.Open
        if Player:WasInputKeyJustPressed(key) then
			TriggerServerEvent('qb-inventory:server:openInventory')
		end
        --if Player:IsInputKeyDown(key) then print('Key Down') end
        Timer.Wait(0)
    end
end) ]]

Timer.CreateThread(function()
	while true do
		local Player = HPlayer
		if not Player then return end
		local key = UE.FKey()
		key.KeyName = Config.Keybinds.Open
		if Player:WasInputKeyJustPressed(key) then 
			print('Opening the inventory:')
			TriggerServerEvent('qb-inventory:server:openInventory') 
		end
		Timer.Wait(1)
	end
end)

-- Commands
--[[ 
Input.Register('Inventory', Config.Keybinds.Open)
Input.Register('Hotbar', Config.Keybinds.Hotbar)

Input.Bind('Inventory', InputEvent.Pressed, function()
	TriggerServerEvent('qb-inventory:server:openInventory')
	Input.SetInputEnabled(false)
end)

Input.Bind('Hotbar', InputEvent.Pressed, function()
	if Input.IsMouseEnabled() then return end
	TriggerServerEvent('qb-inventory:server:toggleHotbar')
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
		TriggerServerEvent('qb-inventory:server:useItem', itemData)
	end
end)
 ]]