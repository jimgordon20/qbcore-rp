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
		asset_name = 'abcca-qbcore-veh::BP_Ambulance',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_armoredtruck = {
		asset_name = 'abcca-qbcore-veh::BP_Armored_Truck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_bus = {
		asset_name = 'abcca-qbcore-veh::BP_Bus',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_garbagetruck = {
		asset_name = 'abcca-qbcore-veh::BP_Garbage_Truck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_semitruck = {
		asset_name = 'abcca-qbcore-veh::BP_SemiTruck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_taxi = {
		asset_name = 'abcca-qbcore-veh::BP_Taxi',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	-- Dax Pack
	bp_alton = {
		asset_name = 'abcca-dax-veh::BP_AltonLane',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_beloren = {
		asset_name = 'abcca-dax-veh::BP_BeLoren',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_deliverytruck = {
		asset_name = 'abcca-dax-veh::BP_DeliveryTruck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_firetruck = {
		asset_name = 'abcca-dax-veh::BP_FireTruck',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_fortezza485 = {
		asset_name = 'abcca-dax-veh::BP_Fortezza485',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_plusclass = {
		asset_name = 'abcca-dax-veh::BP_PlusClass',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_pongasera = {
		asset_name = 'abcca-dax-veh::BP_PongaseraGtVehicle',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_swatvan = {
		asset_name = 'abcca-dax-veh::BP_SwatVan',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_serenity = {
		asset_name = 'abcca-dax-veh::BP_SerenityVehicle',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_rampart = {
		asset_name = 'abcca-dax-veh::RampartVehicle',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_volt = {
		asset_name = 'abcca-dax-veh::BP_VoltVehicle',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
	bp_siesta = {
		asset_name = 'abcca-dax-veh::BP_SiestaVehicle',
		collision_type = CollisionType.Normal,
		gravity_enabled = true,
	},
}
