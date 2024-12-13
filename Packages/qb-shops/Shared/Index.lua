Config = {}
Config.defaultTargetIcon = 'fas fa-shopping-basket'
Config.defaultTargetLabel = 'Open Shop'

-- Deliveries
Config.ShopsInvJsonFile = 'shops-inventory.json'
Config.TruckDeposit = 125
Config.MaxDeliveries = 20
Config.DeliveryPrice = 500
Config.RewardItem = 'cryptostick'
Config.Fuel = 'LegacyFuel'

Config.DeliveryLocations = {
	['main'] = { label = 'GO Postal', coords = Vector(69.0862, 127.6753, 79.2123) },
	['vehicleWithdraw'] = Vector(71.9318, 120.8389, 79.0823),
	['vehicleDeposit'] = Vector(62.7282, 124.9846, 79.0926),
	['stores'] = {}, -- auto generated
}

Config.Vehicles = {
	['boxville2'] = { ['label'] = 'Boxville StepVan', ['cargodoors'] = { [0] = 2, [1] = 3 }, ['trunkpos'] = 1.5 },
}

Config.Products = {
	['normal'] = {
		{ name = 'tosti',         price = 2,   amount = 50 },
		{ name = 'water_bottle',  price = 2,   amount = 50 },
		{ name = 'kurkakola',     price = 2,   amount = 50 },
		{ name = 'twerks_candy',  price = 2,   amount = 50 },
		{ name = 'snikkel_candy', price = 2,   amount = 50 },
		{ name = 'sandwich',      price = 2,   amount = 50 },
		{ name = 'beer',          price = 7,   amount = 50 },
		{ name = 'whiskey',       price = 10,  amount = 50 },
		{ name = 'vodka',         price = 12,  amount = 50 },
		{ name = 'bandage',       price = 100, amount = 50 },
		{ name = 'lighter',       price = 2,   amount = 50 },
		{ name = 'rolling_paper', price = 2,   amount = 5000 },
	},
	['liquor'] = {
		{ name = 'beer',    price = 7,  amount = 50 },
		{ name = 'whiskey', price = 10, amount = 50 },
		{ name = 'vodka',   price = 12, amount = 50 },
	},
	['hardware'] = {
		{ name = 'lockpick',          price = 200, amount = 50 },
		--{ name = 'weapon_wrench',     price = 250, amount = 250, },
		--{ name = 'weapon_hammer',     price = 250, amount = 250, },
		{ name = 'repairkit',         price = 250, amount = 50, requiredJob = { 'mechanic', 'police' } },
		{ name = 'screwdriverset',    price = 350, amount = 50 },
		{ name = 'phone',             price = 850, amount = 50 },
		{ name = 'radio',             price = 250, amount = 50 },
		{ name = 'binoculars',        price = 50,  amount = 50 },
		{ name = 'firework1',         price = 50,  amount = 50 },
		{ name = 'firework2',         price = 50,  amount = 50 },
		{ name = 'firework3',         price = 50,  amount = 50 },
		{ name = 'firework4',         price = 50,  amount = 50 },
		{ name = 'cleaningkit',       price = 150, amount = 150 },
		{ name = 'advancedrepairkit', price = 500, amount = 50, requiredJob = 'mechanic' },
	},
	['weedshop'] = {
		{ name = 'joint',          price = 10, amount = 50 },
		{ name = 'weed_nutrition', price = 20, amount = 50 },
		{ name = 'empty_weed_bag', price = 2,  amount = 1000 },
		{ name = 'rolling_paper',  price = 2,  amount = 1000 },
	},
	['gearshop'] = {
		{ name = 'diving_gear', price = 2500, amount = 10 },
		{ name = 'jerry_can',   price = 200,  amount = 50 },
	},
	['leisureshop'] = {
		{ name = 'parachute',   price = 2500, amount = 10 },
		{ name = 'binoculars',  price = 50,   amount = 50 },
		{ name = 'diving_gear', price = 2500, amount = 10 },
		{ name = 'diving_fill', price = 500,  amount = 10 },
	},
	['weapons'] = {
		{ name = 'weapon_acm',        price = 0, amount = 250 },
		{ name = 'weapon_austro',     price = 0, amount = 250 },
		{ name = 'weapon_banshee',    price = 0, amount = 250 },
		{ name = 'weapon_bison',      price = 0, amount = 250 },
		{ name = 'weapon_cs446',      price = 0, amount = 250 },
		{ name = 'weapon_condor',     price = 0, amount = 250 },
		{ name = 'weapon_convert',    price = 0, amount = 250 },
		{ name = 'weapon_db12',       price = 0, amount = 250 },
		{ name = 'weapon_dnc68',      price = 0, amount = 250 },
		{ name = 'weapon_fang',       price = 0, amount = 250 },
		{ name = 'weapon_fierro',     price = 0, amount = 250 },
		{ name = 'weapon_finisher',   price = 0, amount = 250 },
		{ name = 'weapon_freq',       price = 0, amount = 250 },
		{ name = 'weapon_gaston',     price = 0, amount = 250 },
		{ name = 'weapon_kal',        price = 0, amount = 250 },
		{ name = 'weapon_kfs',        price = 0, amount = 250 },
		{ name = 'weapon_ktk',        price = 0, amount = 250 },
		{ name = 'weapon_krink',      price = 0, amount = 250 },
		{ name = 'weapon_lws32',      price = 0, amount = 250 },
		{ name = 'weapon_n77',        price = 0, amount = 250 },
		{ name = 'weapon_mk4',        price = 0, amount = 250 },
		{ name = 'weapon_mirage',     price = 0, amount = 250 },
		{ name = 'weapon_mouflan',    price = 0, amount = 250 },
		{ name = 'weapon_orion',      price = 0, amount = 250 },
		{ name = 'weapon_pn99',       price = 0, amount = 250 },
		{ name = 'weapon_ppy',        price = 0, amount = 250 },
		{ name = 'weapon_patriot',    price = 0, amount = 250 },
		{ name = 'weapon_pitviper',   price = 0, amount = 250 },
		{ name = 'weapon_queen80',    price = 0, amount = 250 },
		{ name = 'weapon_remi',       price = 0, amount = 250 },
		{ name = 'weapon_roger',      price = 0, amount = 250 },
		{ name = 'weapon_roma12',     price = 0, amount = 250 },
		{ name = 'weapon_ronin777',   price = 0, amount = 250 },
		{ name = 'weapon_sabra',      price = 0, amount = 250 },
		{ name = 'weapon_sovwhisper', price = 0, amount = 250 },
		{ name = 'weapon_vulcan',     price = 0, amount = 250 },
		{ name = 'weapon_flashlight', price = 0, amount = 250 },
	},
	['prison'] = {
		{ name = 'sandwich',     price = 4, amount = 50 },
		{ name = 'water_bottle', price = 4, amount = 50 },
	},
	['police'] = {
		-- { name = 'weapon_pistol',       price = 0, amount = 50, info = { attachments = { { component = 'COMPONENT_AT_PI_FLSH', label = 'Flashlight' } } } },
		-- { name = 'weapon_stungun',      price = 0, amount = 50, info = { attachments = { { component = 'COMPONENT_AT_AR_FLSH', label = 'Flashlight' } } } },
		-- { name = 'weapon_pumpshotgun',  price = 0, amount = 50, info = { attachments = { { component = 'COMPONENT_AT_AR_FLSH', label = 'Flashlight' } } } },
		-- { name = 'weapon_smg',          price = 0, amount = 50, info = { attachments = { { component = 'COMPONENT_AT_SCOPE_MACRO_02', label = '1x Scope' }, { component = 'COMPONENT_AT_AR_FLSH', label = 'Flashlight' } } } },
		-- { name = 'weapon_carbinerifle', price = 0, amount = 50, info = { attachments = { { component = 'COMPONENT_AT_AR_FLSH', label = 'Flashlight' }, { component = 'COMPONENT_AT_SCOPE_MEDIUM', label = '3x Scope' }, } } },
		-- { name = 'weapon_nightstick',   price = 0, amount = 50 },
		-- { name = 'weapon_flashlight',   price = 0, amount = 50 },
		{ name = 'pistol_ammo',        price = 0, amount = 50 },
		{ name = 'smg_ammo',           price = 0, amount = 50 },
		{ name = 'shotgun_ammo',       price = 0, amount = 50 },
		{ name = 'rifle_ammo',         price = 0, amount = 50 },
		{ name = 'handcuffs',          price = 0, amount = 50 },
		{ name = 'empty_evidence_bag', price = 0, amount = 50 },
		{ name = 'police_stormram',    price = 0, amount = 50 },
		{ name = 'armor',              price = 0, amount = 50 },
		{ name = 'radio',              price = 0, amount = 50 },
		{ name = 'heavyarmor',         price = 0, amount = 50 },
	},
	['ambulance'] = {
		{ name = 'radio',       price = 0, amount = 50 },
		{ name = 'bandage',     price = 0, amount = 50 },
		{ name = 'painkillers', price = 0, amount = 50 },
		{ name = 'firstaid',    price = 0, amount = 50 },
		--{ name = 'weapon_flashlight',       price = 0, amount = 50, },
		--{ name = 'weapon_fireextinguisher', price = 0, amount = 50, },
	},
	['mechanic'] = {
		{ name = 'veh_toolbox',       price = 0, amount = 50 },
		{ name = 'veh_armor',         price = 0, amount = 50 },
		{ name = 'veh_brakes',        price = 0, amount = 50 },
		{ name = 'veh_engine',        price = 0, amount = 50 },
		{ name = 'veh_suspension',    price = 0, amount = 50 },
		{ name = 'veh_transmission',  price = 0, amount = 50 },
		{ name = 'veh_turbo',         price = 0, amount = 50 },
		{ name = 'veh_interior',      price = 0, amount = 50 },
		{ name = 'veh_exterior',      price = 0, amount = 50 },
		{ name = 'veh_wheels',        price = 0, amount = 50 },
		{ name = 'veh_neons',         price = 0, amount = 50 },
		{ name = 'veh_xenons',        price = 0, amount = 50 },
		{ name = 'veh_tint',          price = 0, amount = 50 },
		{ name = 'veh_plates',        price = 0, amount = 50 },
		{ name = 'nitrous',           price = 0, amount = 50 },
		{ name = 'tunerlaptop',       price = 0, amount = 50 },
		{ name = 'repairkit',         price = 0, amount = 50 },
		{ name = 'advancedrepairkit', price = 0, amount = 50 },
		{ name = 'tirerepairkit',     price = 0, amount = 50 },
	},
}

Config.Locations = {
	-- 24/7 Locations
	['247supermarket'] = {
		['label'] = '24/7 Supermarket',
		['coords'] = Vector(-2487.0, 4828.4, -299.8),
		['heading'] = Rotator(0.0, -90.258636474609, 0.0),
		['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
		['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
		['radius'] = 1.5,
		['targetIcon'] = 'fas fa-shopping-basket',
		['targetLabel'] = 'Open Shop',
		['products'] = Config.Products['normal'],
		['showblip'] = true,
		['blipsprite'] = 52,
		['blipscale'] = 0.6,
		['blipcolor'] = 0,
		['delivery'] = Vector(26.45, -1315.51, 29.62),
	},
	-- LTD Gasoline Locations
	['ltdgasoline'] = {
		['label'] = 'LTD Gasoline',
		['coords'] = Vector(-2119.4, 1628.6, -299.8),
		['heading'] = Rotator(0.0, 172.61625671387, 0.0),
		['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
		['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
		['radius'] = 1.5,
		['targetIcon'] = 'fas fa-shopping-basket',
		['targetLabel'] = 'Open Shop',
		['products'] = Config.Products['normal'],
		['showblip'] = true,
		['blipsprite'] = 52,
		['blipscale'] = 0.6,
		['blipcolor'] = 0,
		['delivery'] = Vector(-40.51, -1747.45, 29.29),
	},
	-- Rob's Liquor Locations
	['robsliquor'] = {
		['label'] = "Rob's Liqour",
		['coords'] = Vector(-2203.4, 3166.1, -299.8),
		['heading'] = Rotator(0.0, -172.9496307373, 0.0),
		['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
		['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
		['radius'] = 1.5,
		['targetIcon'] = 'fas fa-shopping-basket',
		['targetLabel'] = 'Open Shop',
		['products'] = Config.Products['liquor'],
		['showblip'] = true,
		['blipsprite'] = 52,
		['blipscale'] = 0.6,
		['blipcolor'] = 0,
		['delivery'] = Vector(-1226.92, -901.82, 12.28),
	},
	-- Ammunation Locations
	['ammunation'] = {
		['label'] = 'Ammunation',
		['coords'] = Vector(-3574.4, 1584.8, -306.1),
		['heading'] = Rotator(0.0, 89.867713928223, 0.0),
		['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
		['scenario'] = 'WORLD_HUMAN_COP_IDLES',
		['radius'] = 1.5,
		['targetIcon'] = 'fas fa-gun',
		['targetLabel'] = 'Open Ammunation',
		['products'] = Config.Products['weapons'],
		['showblip'] = true,
		['blipsprite'] = 110,
		['blipscale'] = 0.6,
		['blipcolor'] = 0,
		['delivery'] = Vector(-660.61, -938.14, 21.83),
	},
	-- -- Weedshop Locations
	-- ['weedshop'] = {
	--     ['label'] = 'Smoke On The Water',
	--     ['coords'] = Vector(-1168.26, -1573.2, 4.66),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_AA_SMOKE',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-cannabis',
	--     ['targetLabel'] = 'Open Weed Shop',
	--     ['products'] = Config.Products['weedshop'],
	--     ['showblip'] = true,
	--     ['blipsprite'] = 140,
	--     ['blipscale'] = 0.8,
	--     ['blipcolor'] = 0,
	--     ['delivery'] = Vector(-1162.13, -1568.57, 4.39)
	-- },

	-- -- Sea Word Locations
	-- ['seaword'] = {
	--     ['label'] = 'Sea Word',
	--     ['coords'] = Vector(-1687.03, -1072.18, 13.15),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_STAND_IMPATIENT',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-fish',
	--     ['targetLabel'] = 'Sea Word',
	--     ['products'] = Config.Products['gearshop'],
	--     ['showblip'] = true,
	--     ['blipsprite'] = 52,
	--     ['blipscale'] = 0.8,
	--     ['blipcolor'] = 0,
	--     ['delivery'] = Vector(-1674.18, -1073.7, 13.15)
	-- },

	-- -- Leisure Shop Locations
	-- ['leisureshop'] = {
	--     ['label'] = 'Leisure Shop',
	--     ['coords'] = Vector(-1505.91, 1511.95, 115.29),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_STAND_MOBILE_CLUBHOUSE',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-leaf',
	--     ['targetLabel'] = 'Open Leisure Shop',
	--     ['products'] = Config.Products['leisureshop'],
	--     ['showblip'] = true,
	--     ['blipsprite'] = 52,
	--     ['blipscale'] = 0.8,
	--     ['blipcolor'] = 0,
	--     ['delivery'] = Vector(-1507.64, 1505.52, 115.29)
	-- },

	-- ['police'] = {
	--     ['label'] = 'Police Shop',
	--     ['coords'] = Vector(461.8498, -981.0677, 30.6896),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_COP_IDLES',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-gun',
	--     ['targetLabel'] = 'Open Armory',
	--     ['products'] = Config.Products['police'],
	--     ['delivery'] = Vector(459.0441, -1008.0366, 28.2627),
	--     ['requiredJob'] = 'police',
	-- },

	-- ['ambulance'] = {
	--     ['label'] = 'Ambulance Shop',
	--     ['coords'] = Vector(309.93, -602.94, 43.29),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-hand',
	--     ['targetLabel'] = 'Open Armory',
	--     ['products'] = Config.Products['ambulance'],
	--     ['delivery'] = Vector(283.5821, -614.8570, 43.3792),
	--     ['requiredJob'] = 'ambulance'
	-- },

	-- ['mechanic'] = {
	--     ['label'] = 'Mechanic Shop',
	--     ['coords'] = Vector(-343.66, -140.78, 39.02),
	--     ['products'] = Config.Products['mechanic'],
	--     ['delivery'] = Vector(-354.3936, -128.2882, 39.4307),
	--     ['requiredJob'] = 'mechanic',
	-- },

	-- ['mechanic2'] = {
	--     ['label'] = 'Mechanic Shop',
	--     ['coords'] = Vector(1189.36, 2641.00, 38.44),
	--     ['products'] = Config.Products['mechanic'],
	--     ['delivery'] = Vector(1189.9852, 2651.1873, 37.8351),
	--     ['requiredJob'] = 'mechanic2'
	-- },

	-- ['mechanic3'] = {
	--     ['label'] = 'Mechanic Shop',
	--     ['coords'] = Vector(-1156.56, -1999.85, 13.19),
	--     ['products'] = Config.Products['mechanic'],
	--     ['delivery'] = Vector(-1131.9661, -1972.0144, 13.1603),
	--     ['requiredJob'] = 'mechanic3'
	-- },

	-- ['bennys'] = {
	--     ['label'] = 'Mechanic Shop',
	--     ['coords'] = Vector(-195.80, -1318.24, 31.08),
	--     ['products'] = Config.Products['mechanic'],
	--     ['delivery'] = Vector(-232.5028, -1311.7202, 31.2960),
	--     ['requiredJob'] = 'bennys'
	-- },

	-- ['beeker'] = {
	--     ['label'] = 'Mechanic Shop',
	--     ['coords'] = Vector(100.92, 6616.00, 32.47),
	--     ['products'] = Config.Products['mechanic'],
	--     ['delivery'] = Vector(119.3033, 6626.7358, 31.9558),
	--     ['requiredJob'] = 'beeker'
	-- },

	-- ['prison'] = {
	--     ['label'] = 'Canteen Shop',
	--     ['coords'] = Vector(1777.59, 2560.52, 44.62),
	--     ['heading'] = Rotator(0, 0, 0),
	--     ['ped'] = '/CharacterCreator/CharacterAssets/Avatar_FBX/Body/Male/Mesh/Male_Full_Body',
	--     ['scenario'] = 'WORLD_HUMAN_COP_IDLES',
	--     ['radius'] = 1.5,
	--     ['targetIcon'] = 'fas fa-clipboard',
	--     ['targetLabel'] = 'Open Shop',
	--     ['products'] = Config.Products['prison'],
	--     ['showblip'] = true,
	--     ['blipsprite'] = 52,
	--     ['blipscale'] = 0.8,
	--     ['blipcolor'] = 0,
	--     ['delivery'] = Vector(1845.8175, 2585.9312, 45.6721)
	-- },
}

return Config
