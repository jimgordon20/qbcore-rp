Apartments = {}
Apartments.Starting = false
Apartments.SpawnOffset = 21000
Apartments.MaxOffset = 23000
Apartments.Locations = {
	apartment1 = {
		name = 'apartment1',
		label = 'Mira Hotel',
		coords = { 116485.589556, 44637.712511, 971.299048 },
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
		label = 'Las Palmas Motel',
		coords = { 117483.544070, 55298.680342, 528.506641 },
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
