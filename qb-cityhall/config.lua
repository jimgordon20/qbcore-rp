Config = {

    AvailableJobs = {
        'trucker',
        'taxi',
        'tow',
        'reporter',
        'garbage',
        'bus',
        'hotdog',
        'police',
        'ambulance',
        'realestate',
        'cardealer',
        'mechanic'
    },

    Cityhalls = {
        {
            coords = Vector(-6532.901346, 3573.678064, -299.849361),
            -- showBlip = true,
            -- blipData = {
            --     sprite = 487,
            --     display = 4,
            --     scale = 0.65,
            --     colour = 0,
            --     title = 'City Services'
            -- },
            licenses = {
                id_card = {
                    label = 'ID Card',
                    cost = 50,
                },
                driver_license = {
                    label = 'Driver License',
                    cost = 50,
                    metadata = 'driver'
                },
                weaponlicense = {
                    label = 'Weapon License',
                    cost = 50,
                    metadata = 'weapon'
                },
            }
        },
    }
}
