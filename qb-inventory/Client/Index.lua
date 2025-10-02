local Lang = require('Shared/locales/en')
Player_data = exports['qb-core']:GetPlayerData()
local hotbarShown = false
local inv_open = false
local my_webui = nil

require('Client/drops')
require('Client/vehicles')

-- Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
	--LocalPlayer.state:set('inv_busy', false, true)
	Player_data = exports['qb-core']:GetPlayerData()
--[[ 	exports['qb-core']:TriggerCallback('qb-inventory:server:GetCurrentDrops', function(theDrops)
		Drops = theDrops
	end) ]]
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
	if my_webui == nil then return end
	my_webui:CallFunction('requiredItem', { items = itemTable, toggle = bool })
end)

RegisterClientEvent('qb-inventory:client:hotbar', function(items)
	hotbarShown = not hotbarShown
	if my_webui == nil then return end
	my_webui:CallFunction('toggleHotbar', { open = hotbarShown, items = items })
end)

RegisterClientEvent('qb-inventory:client:closeInv', function()
	if my_webui == nil then return end
	my_webui:CallFunction('closeInventory')
end)

RegisterClientEvent('qb-inventory:client:updateInventory', function(items)
	if my_webui == nil then return end
	my_webui:CallFunction('updateInventory', { inventory = items })
end)

RegisterClientEvent('qb-inventory:client:ItemBox', function(itemData, type, amount)
	if my_webui == nil then return end
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

RegisterClientEvent('qb-inventory:client:ItemBox', function(itemData, type, amount)
	if my_webui == nil then return end
	my_webui:CallFunction('itemBox', { item = itemData, type = type, amount = amount })
end)

--[[ RegisterClientEvent('qb-inventory:client:useItem', function(bool, itemData)
	if my_webui == nil then return end
	my_webui:CallFunction('UseItemResponse', bool, itemData)
end) ]]

RegisterClientEvent('qb-inventory:client:openInventory', function(items, other)
	if not my_webui then 
		my_webui = WebUI('Inventory', 'qb-inventory/Client/html/index.html', true) 
	else
		inv_open = true
		my_webui:SetConsumeInput(true) 
		my_webui:CallFunction('openInventory', { inventory = items, slots = Config.MaxSlots, maxweight = Config.MaxWeight, other = other })
		return
	end
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

	my_webui:RegisterEventHandler('CloseInventory', function(data)
		local name = data.name
		inv_open = false
		my_webui:SetConsumeInput(false)
		--my_webui = nil
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

	my_webui:RegisterEventHandler('DropItem', function(item, cb)
		local PlayerPed = HPlayer:K2_GetPawn()
		local PawnPosition = PlayerPed:K2_GetActorLocation()
		local PawnRotation = PlayerPed:K2_GetActorRotation()

		local ForwardVec = PlayerPed:GetActorForwardVector()
		local SpawnPosition = PawnPosition + (ForwardVec * 200)
		PawnRotation.Yaw = PawnRotation.Yaw

		local bag = StaticMesh(SpawnPosition, PawnRotation, Config.ItemDropObject, CollisionType.StaticOnly)
		local actorId = bag.ActorGuid
		local newDropId = string.format('drop-%s-%s-%s-%s', actorId.A, actorId.B, actorId.C, actorId.D)
		TriggerCallback('server.createDrop', function(success)
			if success then
				SetupDropTarget(bag)
				cb(newDropId)
			end
		end, item, newDropId)
	end)

	my_webui:RegisterEventHandler('AttemptPurchase', function(data, cb)
		TriggerCallback('server.attemptPurchase', function(canPurchase)
			cb(canPurchase)
		end, data)
	end)

	my_webui:RegisterEventHandler('GiveItem', function(data, cb)
		local player, distance = exports['qb-core']:GetClosestPlayer()
		if player and distance < 500 then
			local playerId = player:GetID()
			TriggerCallback('server.giveItem', function(success)
				cb(success)
			end, playerId, data.item.name, data.amount)
		else
			exports['qb-core']:Notify(Lang:t('notify.nonb'), 'error')
		end
	end)

	-- qb-weapons

	my_webui:RegisterEventHandler('GetWeaponData', function(cData, cb)
		local data = {
			WeaponData = QBShared.Items[cData.weapon],
			AttachmentData = FormatWeaponAttachments(cData.ItemData),
		}
		cb(data)
	end)

	my_webui:RegisterEventHandler('RemoveAttachment', function(data, cb)
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
				cb(DJATA)
			else
				RemoveWeaponComponentFromPed(ped, joaat(WeaponData.name), joaat(Attachment))
			end
		end, data.AttachmentData, WeaponData)
	end)

	my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
		inv_open = true
		my_webui:CallFunction('openInventory', { inventory = items, slots = Config.MaxSlots, maxweight = Config.MaxWeight, other = other })
	end)
end)

-- Open UI

local invKey = UE.FKey()
invKey.KeyName = Config.Keybinds.Open

Timer.CreateThread(function()
	while true do
		if not HPlayer then return end
		if HPlayer:WasInputKeyJustPressed(invKey) then
			if HPlayer:GetInputMode() ~= 1 then
				if inv_open then
					if my_webui == nil then return end
					my_webui:CallFunction('closeInventory')
				else
					TriggerServerEvent('qb-inventory:server:openInventory')
				end
			end
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
