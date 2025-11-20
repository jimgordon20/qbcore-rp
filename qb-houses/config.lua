Config = Config or {}

Config.MinZOffset = 30
Config.RamsNeeded = 2
Config.UnownedBlips = false

Config.Houses = {}
Config.Targets = {}
Config.StashWeights = { -- Please follow by tiers!
    [1] = {
        maxweight = 1000000,
        slots = 50,
    }
}

Config.Furniture = {
    sofas = {
        label = 'Sofas',
        items = {
            { object = '/Engine/BasicShapes/Cube.Cube',         price = 0, label = 'Cube' },
            { object = '/Engine/BasicShapes/Cone.Cone',         price = 0, label = 'Cone' },
            { object = '/Engine/BasicShapes/Cylinder.Cylinder', price = 0, label = 'Cylinder' },
            { object = '/Engine/BasicShapes/Sphere.Sphere',     price = 0, label = 'Sphere' },
        }
    }
}

Config.Shells = {
    ['container'] = {
        label = 'Container',
        export = 'CreateContainer',
        price = 1000,
    },
    ['furnitured_midapart'] = {
        label = 'Furnished Mid-Apartment',
        export = 'CreateMidApart',
        price = 5000,
    },
    ['modern_hotel'] = {
        label = 'Modern Hotel',
        export = 'CreateApartmentFurnished',
        price = 3000,
    },
    ['druglab'] = {
        label = 'Drug Lab',
        export = 'CreateDrugLab',
        price = 8000,
    },
    ['franklin_aunt'] = {
        label = "Franklin's Aunt",
        export = 'CreateFranklinAunt',
        price = 7000,
    },
    ['garage_med'] = {
        label = 'Medium Garage',
        export = 'CreateGarageMed',
        price = 4000,
    },
    ['lester'] = {
        label = 'Lester',
        export = 'CreateLesterShell',
        price = 6000,
    },
    ['office'] = {
        label = 'Office 1',
        export = 'CreateOffice1',
        price = 9000,
    },
    ['store'] = {
        label = 'Store 1',
        export = 'CreateStore1',
        price = 8500,
    },
    ['trailer'] = {
        label = 'Trailer',
        export = 'CreateTrailer',
        price = 2000,
    },
    ['warehouse'] = {
        label = 'Warehouse',
        export = 'CreateWarehouse',
        price = 7500,
    },
    ['standard_motel'] = {
        label = 'Standard Motel',
        export = 'CreateMotelStandard',
        price = 2500,
    },
}
