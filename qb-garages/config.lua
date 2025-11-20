Config = {}
Config.AutoRespawn = true        -- true == stores cars in garage on restart | false == doesnt modify car states
Config.VisuallyDamageCars = true -- true == damage car on spawn | false == no damage on spawn
Config.SharedGarages = false     -- true == take any car from any garage | false == only take car from garage stored in
Config.ClassSystem = false       -- true == restrict vehicles by class | false == any vehicle class in any garage
Config.Warp = true               -- true == warp player into vehicle | false == vehicle spawns without warping

Config.VehicleClass = UE.EHelixVehicleType

Config.Garages = {
    apartments = {
        label = 'Apartments',
        takeVehicle = Vector(-355960, -118643, -2897),
        spawnPoint = {
            {
                coords = Vector(-356544, -118992, -2897),
                heading = 268,
            }
        },
        -- showBlip = true,             -- Unused
        -- blipName = 'Public Parking', -- Unused
        -- blipNumber = 357,            -- Unused
        -- blipColor = 3,               -- Unused
        type = 'public', -- public, gang, job, depot
        -- job = ''
        -- jobType = ''
        category = Config.VehicleClass.Car
    },
    cardealer = {
        label = 'Car Dealer',
        takeVehicle = Vector(-301186, -213380, -2882),
        spawnPoint = {
            {
                coords = Vector(-301169, -213000, -2989),
                heading = 180,
            }
        },
        -- showBlip = true,             -- Unused
        -- blipName = 'Public Parking', -- Unused
        -- blipNumber = 357,            -- Unused
        -- blipColor = 3,               -- Unused
        type = 'public', -- public, gang, job, depot
        -- job = ''
        -- jobType = ''
        category = Config.VehicleClass.Car
    },
    hospital = {
        label = 'Hospital',
        takeVehicle = Vector(-345356, -139671, -2883),
        spawnPoint = {
            coords = Vector(-345374, -139326, -2883),
            heading = 358,
        },
        showBlip = false,
        blipName = 'Police',
        blipNumber = 357,
        blipColor = 3,
        type = 'job',
        category = Config.VehicleClass['car'], --car, air, sea, rig
        job = 'ambulance',
        jobType = 'ems'
    },
    police = {
        label = 'Police',
        takeVehicle = Vector(-340755, -145572, -2885),
        spawnPoint = {
            coords = Vector(-340842, -145021, -2885),
            heading = 180,
        },
        showBlip = false,
        blipName = 'Police',
        blipNumber = 357,
        blipColor = 3,
        type = 'job',
        category = Config.VehicleClass['car'], --car, air, sea, rig
        job = 'police',
        jobType = 'leo'
    },
}
