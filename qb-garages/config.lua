Config = {}
Config.AutoRespawn = true        -- true == stores cars in garage on restart | false == doesnt modify car states
Config.VisuallyDamageCars = true -- true == damage car on spawn | false == no damage on spawn
Config.SharedGarages = false     -- true == take any car from any garage | false == only take car from garage stored in
Config.ClassSystem = false       -- true == restrict vehicles by class | false == any vehicle class in any garage
Config.Warp = true               -- true == warp player into vehicle | false == vehicle spawns without warping

Config.VehicleClass = UE.EHelixVehicleType

Config.Garages = {
    apartments = {
        label = 'Test Garage',
        takeVehicle = Vector(-1099, 14916, -300),
        spawnPoint = {
            {
                coords = Vector(-127.491244, 14050.276126, -400),
                heading = 179,
            }
        },
        showBlip = true,             -- Unused
        blipName = 'Public Parking', -- Unused
        blipNumber = 357,            -- Unused
        blipColor = 3,               -- Unused
        type = 'public',             -- public, gang, job, depot
        -- job = ''
        -- jobType = ''
        category = Config.VehicleClass.Car
    },
}
