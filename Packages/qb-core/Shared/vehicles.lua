QBShared = QBShared or {}

QBShared.Vehicles = {
	bp_police = {
		asset_name = 'helix::BP_PoliceCar',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
		doors = {
			[0] = {
				offset_location = Vector(50, -75, 105),
				seat_location = Vector(8, -32.5, 95),
				seat_rotation = Rotator(0, 0, 10),
				trigger_radius = 70,
				leave_lateral_offset = -150
			}
		}
	},
	bp_simcade = {
		asset_name = 'helix::BP_Simcade',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_ambulance = {
		asset_name = 'qbcore-vehicles-mm::BP_Ambulance',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_armoredtruck = {
		asset_name = 'qbcore-vehicles-mm::BP_Armored_Truck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_bus = {
		asset_name = 'qbcore-vehicles-mm::BP_Bus',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_garbagetruck = {
		asset_name = 'qbcore-vehicles-mm::BP_Garbage_Truck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_semitruck = {
		asset_name = 'qbcore-vehicles-mm::BP_Semi_Truck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_taxi = {
		asset_name = 'qbcore-vehicles-mm::BP_Taxi',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
}
