Config = {
    HandCuffItem = 'handcuffs',
    LicenseRank = 2,

    AmmoLabels = {
        AMMO_PISTOL = '9x19mm parabellum bullet',
        AMMO_SMG = '9x19mm parabellum bullet',
        AMMO_RIFLE = '7.62x39mm bullet',
        AMMO_MG = '7.92x57mm mauser bullet',
        AMMO_SHOTGUN = '12-gauge bullet',
        AMMO_SNIPER = 'Large caliber bullet',
    },

    Objects = {
        cone = { model = '', freeze = true },
        barrier = { model = '', freeze = true },
        roadsign = { model = '', freeze = true },
        tent = { model = '', freeze = true },
        light = { model = '', freeze = true },
    },

    Locations = {
        duty = {
            { coords = Vector(-340540.36, -147839.66, -2884.60),  heading = 132 },
        },
        vehicle = {
            { coords = Vector(93790.6, -162365.5, 198.6),  heading = 132 },
        },
        stash = {
            { coords = Vector(93471.0, -162573.3, 198.6),  heading = 132 },
        },
        impound = {
            Vector(0, 0, 0)
        },
        helicopter = {
            Vector(0, 0, 0)
        },
        trash = {
            Vector(0, 0, 0)
        },
        fingerprint = {
            { coords = Vector(94619.2, -161676.1, 198.6),  heading = 132 },
        },
        evidence = {
            { coords = Vector(94344.3, -161916.0, 198.6),  heading = 132 },
        },
        stations = {
            { label = 'Police Station', coords = Vector(-340540.36, -147839.66, -2884.60) },
        },
    },

    SpeedCamera = {
        Vector(13438.7, -46440.2, 209.7)
    },

    SecurityCameras = {
        cameras = {
            { label = 'Hansons',         coords = Vector(16386.9, -46857.0, 400),  rotation = Rotator(0.0, 48.991352081299, 0.0),  canRotate = false, isOnline = true },
            { label = 'Eastside Market', coords = Vector(-54437.3, -41350.1, 400), rotation = Rotator(0.0, -139.79696655273, 0.0), canRotate = false, isOnline = true },
        },
    }
}