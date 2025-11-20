Apartments = {}
Apartments.Starting = true
Apartments.InitialOffset = 21000
Apartments.SpawnOffset = 1500
Apartments.Locations = {
	apartment1 = {
		name = 'apartment1',
		label = 'Apartment',
		coords = { -359625, -118057, -2465 },
		polyzoneBoxData = {
			heading = 180,
			length = 100,
			width = 100,
			distance = 1000,
			debug = true,
			created = false,
		},
	},
	apartment2 = {
		name = 'apartment2',
		label = 'House',
		coords = { -358542, -121694, -2883 },
		polyzoneBoxData = {
			heading = 90,
			length = 100,
			width = 100,
			distance = 1000,
			debug = true,
			created = false,
		},
	},
}

exports('qb-apartments', 'Apartments', function()
	return Apartments
end)
