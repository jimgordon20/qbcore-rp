Config = {
    Vehicle = '/abcca-qbcore-veh/QBCoreVehicles/BP_Taxi.BP_Taxi_C',
    Meter = {
        defaultPrice = 125.0, -- price per mile
        startingPrice = 0     -- static starting price
    },
    Locations = {
        Depots = {
            {
                label = 'Taxi Depot',
                pedSpawn = { coords = Vector(-355290, -131250, -2880), heading = 165 },
                vehicleSpawn = { coords = Vector(-355917, -130990, -2977), heading = 180 },
            },
        },

        Benches = {
            { coords = Vector(-357440, -132210, -2970), heading = -90, npc = nil },
            { coords = Vector(-357440, -122370, -2970), heading = -90, npc = nil },
            { coords = Vector(-357440, -111940, -2970), heading = -90, npc = nil },
        },
    },
}
