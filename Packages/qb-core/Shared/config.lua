QBConfig = {}
QBConfig.Language = 'en'

--QBConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
QBConfig.DefaultSpawn = Vector(6383.6, 3794.5, -315.8)
QBConfig.UpdateInterval = 5    -- how often to update player data in minutes
QBConfig.StatusInterval = 5000 -- how often to check if hunger/thirst is empty in milliseconds

QBConfig.Money = {}
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
QBConfig.Money.DontAllowMinus = { 'cash', 'crypto' }                -- Money that is not allowed going in minus
QBConfig.Money.PayCheckTimeOut = 10                                 -- The time in minutes that it will give the paycheck
QBConfig.Money.PayCheckSociety = false                              -- If true paycheck will come from the society account that the player is employed at, requires qb-management

QBConfig.Player = {}
QBConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
QBConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
QBConfig.Player.Bloodtypes = { 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' }

QBConfig.Server = {}                           -- General server config
QBConfig.Server.Closed = false                 -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
QBConfig.Server.ClosedReason = 'Server Closed' -- Reason message to display when people can't join the server
QBConfig.Server.Uptime = 0                     -- Time the server has been up.
QBConfig.Server.Whitelist = false              -- Enable or disable whitelist on the server
QBConfig.Server.WhitelistPermission = 'admin'  -- Permission that's able to enter the server when the whitelist is on
QBConfig.Server.Discord = ''                   -- Discord invite link
QBConfig.Server.CheckDuplicateLicense = true   -- Check for duplicate account id on join
QBConfig.Server.Permissions = {                -- string for player account id found using GetAccountID()
	god = {
		['11ec67d4-bd1f-4f64-98a3-68e0ffd885d0'] = true,
		['a64b3c45-c026-4a58-b532-f08efb515647'] = true, -- HELIX
		['e53c7eac-2c50-4fcf-95c4-cd3315a60c67'] = true, -- QA Generic Production
		['dc19be29-9981-4a83-af57-4030aa815a3e'] = true, -- QA Production Jen
		['c9525e76-b49d-4987-b547-de41bc37dd1e'] = true, -- QA Staging Jen
		['d35e4f3c-4bf2-41b8-8467-2c1d7248e7d4'] = true, -- QA Production Francisco
		['63128f5b-c760-4865-9675-9c43faa469fa'] = true,
		['b97768de-2848-4495-a52a-99eb1a98c3fe'] = true, -- QA Staging Francisco
		['729bf24b-481d-4894-a954-80c30729936b'] = true,
		['d95e4660-8cc6-4610-bf6d-ac679f9a088d'] = true, -- QA Generic Staging
		['eec65f3f-e5b0-4fb8-922d-75e1ea1575d2'] = true, -- Kakarot
		['d4997d1b-b3ca-499d-9f0b-ffb361a51c4f'] = true,
		['ebc0e470-7c49-477a-85cb-7684f3a40ed4'] = true, -- Maggie
		['b04771ab-3d22-4364-beaa-e0b48e70911c'] = true -- Kravs
	},
	admin = {},
	mod = {},
}

QBConfig.Chat = {
	screen_location = Vector2D(-25, 0),
	size = Vector2D(600, 250),
	anchors_min = Vector2D(1, 0.5),
	anchors_max = Vector2D(1, 0.5),
	alignment = Vector2D(1, 0.5),
	justify = true,
	show_scrollbar = false,
}

-- Configurable player data

QBConfig.Player.PlayerDefaults = {
	citizenid = function()
		return QBCore.Functions.CreateCitizenId()
	end,
	cid = 1,
	money = function()
		local moneyDefaults = {}
		for moneytype, startamount in pairs(QBConfig.Money.MoneyTypes) do
			moneyDefaults[moneytype] = startamount
		end
		return moneyDefaults
	end,
	optin = true,
	charinfo = {
		firstname = 'Firstname',
		lastname = 'Lastname',
		birthdate = '00-00-0000',
		gender = 0,
		nationality = 'USA',
		phone = function()
			return QBCore.Functions.CreatePhoneNumber()
		end,
		account = function()
			return QBCore.Functions.CreateAccountNumber()
		end,
	},
	job = {
		name = 'unemployed',
		label = 'Civilian',
		payment = 10,
		type = 'none',
		onduty = false,
		isboss = false,
		grade = {
			name = 'Freelancer',
			level = 0,
		},
	},
	gang = {
		name = 'none',
		label = 'No Gang Affiliation',
		isboss = false,
		grade = {
			name = 'none',
			level = 0,
		},
	},
	metadata = {
		hunger = 100,
		thirst = 100,
		stress = 0,
		isdead = false,
		inlaststand = false,
		armor = 0,
		ishandcuffed = false,
		tracker = false,
		injail = 0,
		jailitems = {},
		status = {},
		phone = {},
		rep = {},
		currentapartment = nil,
		callsign = 'NO CALLSIGN',
		bloodtype = function()
			return QBConfig.Player.Bloodtypes[math.random(1, #QBConfig.Player.Bloodtypes)]
		end,
		fingerprint = function()
			return QBCore.Functions.CreateFingerId()
		end,
		walletid = function()
			return QBCore.Functions.CreateWalletId()
		end,
		criminalrecord = {
			hasRecord = false,
			date = nil,
		},
		licences = {
			driver = true,
			business = false,
			weapon = false,
		},
		inside = {
			house = nil,
			apartment = {
				apartmentType = nil,
				apartmentId = nil,
			},
		},
		phonedata = {
			SerialNumber = function()
				return QBCore.Functions.CreateSerialNumber()
			end,
			InstalledApps = {},
		},
	},
	position = QBConfig.DefaultSpawn,
	items = {},
}
