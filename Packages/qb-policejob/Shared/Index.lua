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
            { coords = Vector(94065.4, -162138.9, 198.6),  heading = 132 },
            { coords = Vector(46927.3, 240690.4, 198.6),   heading = -48 },
            { coords = Vector(117647.1, 87226.2, 168.6),   heading = -98 },
            { coords = Vector(-194893.5, 218828.6, 198.6), heading = 16 },
            { coords = Vector(18921.9, 11126.4, 214.8),    heading = 87 },
        },
        vehicle = {
            { coords = Vector(93790.6, -162365.5, 198.6),  heading = 132 },
            { coords = Vector(46669.3, 240460.3, 198.6),   heading = -48 },
            { coords = Vector(117288.8, 87303.2, 198.6),   heading = -98 },
            { coords = Vector(-194828.0, 218464.1, 198.6), heading = 16 },
            { coords = Vector(19310.0, 11104.6, 214.8),    heading = 87 },
        },
        stash = {
            { coords = Vector(93471.0, -162573.3, 198.6),  heading = 132 },
            { coords = Vector(46391.4, 240198.9, 198.6),   heading = -48 },
            { coords = Vector(116960.4, 87345.2, 198.6),   heading = -98 },
            { coords = Vector(-194684.5, 218136.0, 198.6), heading = 16 },
            { coords = Vector(19651.5, 11085.4, 214.8),    heading = 87 },
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
            { coords = Vector(45885.5, 239700.9, 198.6),   heading = -48 },
            { coords = Vector(116244.7, 87500.5, 198.7),   heading = -98 },
            { coords = Vector(-194589.1, 217415.6, 198.6), heading = 16 },
            { coords = Vector(20377.5, 11091.7, 208.8),    heading = 87 },
        },
        evidence = {
            { coords = Vector(94344.3, -161916.0, 198.6),  heading = 132 },
            { coords = Vector(46137.2, 239955.3, 198.6),   heading = -48 },
            { coords = Vector(116592.5, 87429.1, 198.6),   heading = -98 },
            { coords = Vector(-194660.9, 217773.2, 198.7), heading = 16 },
            { coords = Vector(20004.2, 11073.7, 214.8),    heading = 87 },
        },
        stations = {
            { label = 'Police Station', coords = Vector(93721.3, -161336.4, 198.6) },
            { label = 'Police Station', coords = Vector(46850.7, 239471.1, 198.6) },
            { label = 'Police Station', coords = Vector(116571.7, 86552.7, 198.6) },
            { label = 'Police Station', coords = Vector(-193851.4, 218120.0, 198.6) },
            { label = 'Police Station', coords = Vector(19872.4, 11943.7, 214.8) }
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

return Config
