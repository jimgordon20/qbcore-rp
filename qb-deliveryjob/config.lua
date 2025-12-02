Config = {
    Job = 'delivery',
    Stops  = { Minimum = 3, Maximum = 5 },

    Depots = {
        {
            label = 'Test',
            pedSpawn = { coords = Vector(-355239.42, -132407.13, -2882.44), heading = 176, },
            vehicleSpawn = { coords = Vector(-355929.31, -132383.51, -2897.84), heading = 180, },
        }
    },

    -- Key of vehicle in qb-core/Shared Vehicles table
    Vehicles = {
        'bp_deliverytruck'
    },

    Prop = {
        Mesh = '/Engine/BasicShapes/Cube.Cube',
        HoldingAnimation = '/Game/Characters/Heroes/Unified/Animations/Package_Deliveryman/Carrying/A_Carrying_BothArms_LargeBox_Holding_Idle.A_Carrying_BothArms_LargeBox_Holding_Idle'
    },

    Payout = { Minimum = 500, Maximum = 1000 },

    Locations = {
        Vector(-316430.68, -130243.49, -3391.50),
        Vector(-314462.63, -120730.97, -3358.08),
        Vector(-314610.22, -119405.93, -3356.28),
        Vector(-315755.85, -112270.68, -3346.73),
        Vector(-343143.34, -145299.86, -2882.38)
    }
}