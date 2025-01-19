local stock_file = File(Config.ShopsInvJsonFile)
local peds = {}

-- Functions

local function checkTable(inputValue, requiredValue)
	if type(inputValue) == 'table' and type(requiredValue) == 'table' then
		for _, v in ipairs(requiredValue) do
			if inputValue[v] then
				return true
			end
		end
	elseif type(requiredValue) == 'table' then
		for _, v in ipairs(requiredValue) do
			if v == inputValue then
				return true
			end
		end
	elseif type(inputValue) == 'string' and type(requiredValue) == 'string' then
		return inputValue == requiredValue
	elseif type(inputValue) == 'table' and type(requiredValue) == 'string' then
		return inputValue[requiredValue] == true
	elseif type(inputValue) == 'string' and type(requiredValue) == 'table' then
		for _, v in ipairs(requiredValue) do
			if v == inputValue then
				return true
			end
		end
	end
	return false
end

local function saveShopInv(shop, products)
	local existingData = stock_file:ReadJSON()
	existingData[shop] = { products = products }
	stock_file:Seek(0)
	stock_file:Write(json.encode(existingData))
	stock_file:Flush()
end

local function deliveryPay(source, shop)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local player_ped = source:GetControlledCharacter()
	local player_coords = player_ped:GetLocation()
	local deliverCoords = Config.Locations[shop].delivery
	local distance = #(player_coords - deliverCoords)
	if distance > 10 then
		return
	end
	Player.Functions.AddMoney('bank', Config.DeliveryPrice, 'qb-shops:deliveryPay')
	if math.random(100) <= 10 then
		AddItem(source, Config.RewardItem, 1, false, false, 'qb-shops:deliveryPay')
	end
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-shops:server:getPeds', function(_, cb)
	cb(peds)
end)

-- Events

Events.SubscribeRemote('qb-shops:server:RestockShopItems', function(source, shop)
	if not shop then
		return
	end
	if not Config.Locations[shop] then
		return
	end
	deliveryPay(source, shop)
	if not Config.Locations[shop].useStock then
		return
	end
	local randAmount = math.random(10, 50)
	for k in pairs(Config.Locations[shop].products) do
		Config.Locations[shop].products[k].amount = Config.Locations[shop].products[k].amount + randAmount
	end
	saveShopInv(shop, Config.Locations[shop].products)
	Events.BroadcastRemote('qb-shops:client:SetShopItems', shop, Config.Locations[shop].products)
end)

Events.Subscribe('qb-shops:server:UpdateShopItems', function(shop, itemData, amount) -- called from inventory
	if not shop or not itemData or not amount then
		return
	end
	if not Config.Locations[shop] then
		return
	end
	if not Config.Locations[shop].useStock then
		return
	end
	Config.Locations[shop].products[itemData.slot].amount = Config.Locations[shop].products[itemData.slot].amount
		- amount
	if Config.Locations[shop].products[itemData.slot].amount < 0 then
		Config.Locations[shop].products[itemData.slot].amount = 0
	end
	saveShopInv(shop, Config.Locations[shop].products)
	Events.BroadcastRemote('qb-shops:client:SetShopItems', shop, Config.Locations[shop].products)
end)

Events.SubscribeRemote('qb-shops:server:openShop', function(source, data)
	local shopName = data.shop
	local shopData = Config.Locations[shopName]
	if not shopData then
		return
	end
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then
		return
	end
	local playerData = Player.PlayerData
	local products = shopData.products
	local items = {}

	if shopData.useStock then
		local shopInvJson = stock_file:ReadJSON()
		local shopInventory = shopInvJson[shopName]
		if shopInventory then
			for _, product in pairs(shopInventory.products) do
				local slot = product.slot
				if products[slot] then
					products[slot].amount = product.amount
				end
			end
		end
	end

	for i = 1, #products do
		local curProduct = products[i]
		local addProduct = true

		if curProduct.requiredGrade and playerData.job.grade.level < curProduct.requiredGrade then
			addProduct = false
		end

		if addProduct and curProduct.requiredJob and not checkTable(playerData.job.name, curProduct.requiredJob) then
			addProduct = false
		end

		if addProduct and curProduct.requiredGang and not checkTable(playerData.gang.name, curProduct.requiredGang) then
			addProduct = false
		end

		if
			addProduct
			and curProduct.requiredLicense
			and not checkTable(playerData.metadata['licences'], curProduct.requiredLicense)
		then
			addProduct = false
		end

		if addProduct then
			curProduct.slot = #items + 1
			items[#items + 1] = curProduct
		end
	end

	CreateShop({
		name = shopName,
		label = shopData.label,
		slots = shopData.slots,
		coords = shopData.coords,
		items = items,
	})
	OpenShop(source, shopName)
end)

-- Spawn Peds

for shop, shopData in pairs(Config.Locations) do
	if shopData.ped then
		local coords = shopData.coords
		local heading = Rotator(0, shopData.heading, 0)
		local ped = HCharacter(coords, heading, shopData.ped)
		ped:AddSkeletalMeshAttached('head', 'helix::SK_Male_Head')
		ped:AddSkeletalMeshAttached('chest', 'helix::SK_Man_Outwear_03')
		ped:AddSkeletalMeshAttached('legs', 'helix::SK_Man_Pants_05')
		ped:AddSkeletalMeshAttached('feet', 'helix::SK_Delivery_Shoes')
		peds[ped] = {
			options = {
				{
					type = 'server',
					event = 'qb-shops:server:openShop',
					shop = shop,
					label = shopData.targetLabel or Config.DefaultTargetLabel,
					icon = shopData.targetIcon or Config.DefaultTargetIcon,
					item = shopData.requiredItem,
					job = shopData.requiredJob,
					gang = shopData.requiredGang,
				},
			},
			distance = 400,
		}
	end
end
