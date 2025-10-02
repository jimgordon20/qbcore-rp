Apartments = {}
Apartments.Starting = true
Apartments.SpawnOffset = 21000
Apartments.MaxOffset = 23000
Apartments.Locations = {
	apartment1 = {
		name = 'apartment1',
		label = 'Apartment',
		coords = { -66.599790, 15687.074097, -299.849999 },
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
		coords = { -4657.669942, 15631.930482, -233.886309 },
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
