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
            Vector(-2958.5, 910.1, -301.9)
        },
        vehicle = {
            Vector(-3343.0, 583.3, -301.8)
        },
        stash = {
            Vector(-3776.0, -389.3, -277.9)
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
            Vector(0, 0, 0)
        },
        evidence = {
            Vector(-4984.9, -107.5, -285.8)
        },
        stations = {
            { label = 'Police Station', coords = Vector(0, 0, 0) },
        },
    },

    Radars = {
        Vector(-623.44421386719, -823.08361816406, 25.25704574585),
        Vector(-652.44421386719, -854.08361816406, 24.55704574585),
        Vector(1623.0114746094, 1068.9924316406, 80.903594970703),
        Vector(-2604.8994140625, 2996.3391113281, 27.528566360474),
        Vector(2136.65234375, -591.81469726563, 94.272926330566),
        Vector(2117.5764160156, -558.51013183594, 95.683128356934),
        Vector(406.89505004883, -969.06286621094, 29.436267852783),
        Vector(657.315, -218.819, 44.06),
        Vector(2118.287, 6040.027, 50.928),
        Vector(-106.304, -1127.5530, 30.778),
        Vector(-823.3688, -1146.980, 8.0),
    },

    SecurityCameras = {
        hideradar = false,
        cameras = {
            { label = 'Pacific Bank CAM#1',                    coords = Vector(257.45, 210.07, 109.08),      rotation = Rotator(-25.0, 0.0, 28.05),     canRotate = false, isOnline = true },
            { label = 'Pacific Bank CAM#2',                    coords = Vector(232.86, 221.46, 107.83),      rotation = Rotator(-25.0, 0.0, -140.91),   canRotate = false, isOnline = true },
            { label = 'Pacific Bank CAM#3',                    coords = Vector(252.27, 225.52, 103.99),      rotation = Rotator(-35.0, 0.0, -74.87),    canRotate = false, isOnline = true },
            { label = 'Limited Ltd Grove St. CAM#1',           coords = Vector(-53.1433, -1746.714, 31.546), rotation = Rotator(-35.0, 0.0, -168.9182), canRotate = false, isOnline = true },
            { label = "Rob's Liqour Prosperity St. CAM#1",     coords = Vector(-1482.9, -380.463, 42.363),   rotation = Rotator(-35.0, 0.0, 79.53281),  canRotate = false, isOnline = true },
            { label = "Rob's Liqour San Andreas Ave. CAM#1",   coords = Vector(-1224.874, -911.094, 14.401), rotation = Rotator(-35.0, 0.0, -6.778894), canRotate = false, isOnline = true },
            { label = 'Limited Ltd Ginger St. CAM#1',          coords = Vector(-718.153, -909.211, 21.49),   rotation = Rotator(-35.0, 0.0, -137.1431), canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Innocence Blvd. CAM#1', coords = Vector(23.885, -1342.441, 31.672),   rotation = Rotator(-35.0, 0.0, -142.9191), canRotate = false, isOnline = true },
            { label = "Rob's Liqour El Rancho Blvd. CAM#1",    coords = Vector(1133.024, -978.712, 48.515),  rotation = Rotator(-35.0, 0.0, -137.302),  canRotate = false, isOnline = true },
            { label = 'Limited Ltd West Mirror Drive CAM#1',   coords = Vector(1151.93, -320.389, 71.33),    rotation = Rotator(-35.0, 0.0, -119.4468), canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Clinton Ave CAM#1',     coords = Vector(383.402, 328.915, 105.541),   rotation = Rotator(-35.0, 0.0, 118.585),   canRotate = false, isOnline = true },
            { label = 'Limited Ltd Banham Canyon Dr CAM#1',    coords = Vector(-1832.057, 789.389, 140.436), rotation = Rotator(-35.0, 0.0, -91.481),   canRotate = false, isOnline = true },
            { label = "Rob's Liqour Great Ocean Hwy CAM#1",    coords = Vector(-2966.15, 387.067, 17.393),   rotation = Rotator(-35.0, 0.0, 32.92229),  canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Ineseno Road CAM#1',    coords = Vector(-3046.749, 592.491, 9.808),   rotation = Rotator(-35.0, 0.0, -116.673),  canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Barbareno Rd. CAM#1',   coords = Vector(-3246.489, 1010.408, 14.705), rotation = Rotator(-35.0, 0.0, -135.2151), canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Route 68 CAM#1',        coords = Vector(539.773, 2664.904, 44.056),   rotation = Rotator(-35.0, 0.0, -42.947),   canRotate = false, isOnline = true },
            { label = "Rob's Liqour Route 68 CAM#1",           coords = Vector(1169.855, 2711.493, 40.432),  rotation = Rotator(-35.0, 0.0, 127.17),    canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Senora Fwy CAM#1',      coords = Vector(2673.579, 3281.265, 57.541),  rotation = Rotator(-35.0, 0.0, -80.242),   canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Alhambra Dr. CAM#1',    coords = Vector(1966.24, 3749.545, 34.143),   rotation = Rotator(-35.0, 0.0, 163.065),   canRotate = false, isOnline = true },
            { label = '24/7 Supermarkt Senora Fwy CAM#2',      coords = Vector(1729.522, 6419.87, 37.262),   rotation = Rotator(-35.0, 0.0, -160.089),  canRotate = false, isOnline = true },
            { label = 'Fleeca Bank Hawick Ave CAM#1',          coords = Vector(309.341, -281.439, 55.88),    rotation = Rotator(-35.0, 0.0, -146.1595), canRotate = false, isOnline = true },
            { label = 'Fleeca Bank Legion Square CAM#1',       coords = Vector(144.871, -1043.044, 31.017),  rotation = Rotator(-35.0, 0.0, -143.9796), canRotate = false, isOnline = true },
            { label = 'Fleeca Bank Hawick Ave CAM#2',          coords = Vector(-355.7643, -52.506, 50.746),  rotation = Rotator(-35.0, 0.0, -143.8711), canRotate = false, isOnline = true },
            { label = 'Fleeca Bank Del Perro Blvd CAM#1',      coords = Vector(-1214.226, -335.86, 39.515),  rotation = Rotator(-35.0, 0.0, -97.862),   canRotate = false, isOnline = true },
            { label = 'Fleeca Bank Great Ocean Hwy CAM#1',     coords = Vector(-2958.885, 478.983, 17.406),  rotation = Rotator(-35.0, 0.0, -34.69595), canRotate = false, isOnline = true },
            { label = 'Paleto Bank CAM#1',                     coords = Vector(-102.939, 6467.668, 33.424),  rotation = Rotator(-35.0, 0.0, 24.66),     canRotate = false, isOnline = true },
            { label = 'Del Vecchio Liquor Paleto Bay',         coords = Vector(-163.75, 6323.45, 33.424),    rotation = Rotator(-35.0, 0.0, 260.00),    canRotate = false, isOnline = true },
            { label = "Don's Country Store Paleto Bay CAM#1",  coords = Vector(166.42, 6634.4, 33.69),       rotation = Rotator(-35.0, 0.0, 32.00),     canRotate = false, isOnline = true },
            { label = "Don's Country Store Paleto Bay CAM#2",  coords = Vector(163.74, 6644.34, 33.69),      rotation = Rotator(-35.0, 0.0, 168.00),    canRotate = false, isOnline = true },
            { label = "Don's Country Store Paleto Bay CAM#3",  coords = Vector(169.54, 6640.89, 33.69),      rotation = Rotator(-35.0, 0.0, 5.78),      canRotate = false, isOnline = true },
            { label = 'Vangelico Jewelery CAM#1',              coords = Vector(-627.54, -239.74, 40.33),     rotation = Rotator(-35.0, 0.0, 5.78),      canRotate = true,  isOnline = true },
            { label = 'Vangelico Jewelery CAM#2',              coords = Vector(-627.51, -229.51, 40.24),     rotation = Rotator(-35.0, 0.0, -95.78),    canRotate = true,  isOnline = true },
            { label = 'Vangelico Jewelery CAM#3',              coords = Vector(-620.3, -224.31, 40.23),      rotation = Rotator(-35.0, 0.0, 165.78),    canRotate = true,  isOnline = true },
            { label = 'Vangelico Jewelery CAM#4',              coords = Vector(-622.57, -236.3, 40.31),      rotation = Rotator(-35.0, 0.0, 5.78),      canRotate = true,  isOnline = true },
        },
    }
}

return Config
