Apartments = {}
Apartments.Starting = true
Apartments.SpawnOffset = -20000
Apartments.Locations = {
	apartment1 = {
		name = 'apartment1',
		label = 'Southside Apartments',
		coords = { 73609.1, 148294.8, 197.2 },
		polyzoneBoxData = {
			heading = 180,
			length = 0.01,
			width = 1.0,
			distance = 200.0,
			created = false,
		},
	},
	apartment2 = {
		name = 'apartment2',
		label = 'West End Apartments',
		coords = { -122818.1, -72758.2, 202.5 },
		polyzoneBoxData = {
			heading = 90,
			length = 0.01,
			width = 1.0,
			distance = 200.0,
			created = false,
		},
	},
}

Package.Export('Apartments', Apartments)
