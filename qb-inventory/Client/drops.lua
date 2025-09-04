local Lang = Package.Require("../Shared/locales/" .. QBConfig.Language .. ".lua")
local holdingDrop = false
local bagObject = nil
local heldDrop = nil
CurrentDrop = nil

-- Functions

function GetDrops()
	QBCore.Functions.TriggerCallback("qb-inventory:server:GetCurrentDrops", function(drops)
		if drops then
			for k, v in pairs(drops) do
				local bag = v.entityId
				AddTargetEntity(bag, {
					options = {
						{
							icon = "fas fa-backpack",
							label = Lang:t("menu.o_bag"),
							action = function()
								Events.CallRemote("qb-inventory:server:openDrop", k)
								CurrentDrop = dropId
							end,
						},
					},
					distance = 2.5,
				})
			end
		end
	end)
end

-- Events

Events.SubscribeRemote("qb-inventory:client:setupDropTarget", function(bag)
	local dropId = bag:GetID()
	local newDropId = "drop-" .. dropId
	AddTargetEntity(bag, {
		options = {
			{
				icon = "fas fa-backpack",
				label = Lang:t("menu.o_bag"),
				action = function()
					Events.CallRemote("qb-inventory:server:openDrop", newDropId)
					CurrentDrop = newDropId
				end,
			},
			{
				icon = "fas fa-hand-pointer",
				label = "Pick up bag",
				action = function()
					Events.CallRemote("qb-inventory:server:pickUpDrop", bag)
					bagObject = bag
					holdingDrop = true
					heldDrop = newDropId
					DrawText("Press [G] to drop the bag", "left")
				end,
			},
		},
		distance = 2.5,
	})
end)

-- KeyPress

Input.Subscribe("KeyPress", function(key_name)
	if key_name == "G" and holdingDrop then
		HideText()
		Events.CallRemote("qb-inventory:server:updateDrop", bagObject, heldDrop)
		holdingDrop = false
		bagObject = nil
		heldDrop = nil
	end
end)
