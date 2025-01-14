local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

Config = {
    MinimalDoctors = 2,            -- How many players with the ambulance job to prevent the hospital check-in system from being used
    DocCooldown = 1,               -- Cooldown between doctor calls allowed, in minutes
    WipeInventoryOnRespawn = true, -- Enable or disable removing all the players items when they respawn at the hospital
    BillCost = 2000,               -- Price that players are charged for using the hospital check-in system
    DeathTime = 5,                 -- How long the timer is for players to bleed out completely and respawn at the hospital
    ReviveInterval = 360,          -- How long the timer is for players to revive a player in laststand
    MinimumRevive = 300,           -- How long the timer is for players to revive a player in laststand
    PainkillerInterval = 60,       -- Set the length of time painkillers last (per one)
    HealthDamage = 5,              -- Minumum damage done to health before checking for injuries
    ArmorDamage = 5,               -- Minumum damage done to armor before checking for injuries
    ForceInjury = 35,              -- Maximum amount of damage a player can take before limb damage & effects are forced to occur
    AlwaysBleedChance = 70,        -- Set the chance out of 100 that if a player is hit with a weapon, that also has a random chance, it will cause bleeding
    MessageTimer = 12,             -- How long it will take to display limb/bleed message
    AIHealTimer = 20,              -- How long it will take to be healed after checking in, in seconds
    BleedTickRate = 30,            -- How much time, in seconds, between bleed ticks
    BleedMovementTick = 10,        -- How many seconds is taken away from the bleed tick rate if the player is walking, jogging, or sprinting
    BleedMovementAdvance = 3,      -- How much time moving while bleeding adds
    BleedTickDamage = 8,           -- The base damage that is multiplied by bleed level everytime a bleed tick occurs
    FadeOutTimer = 2,              -- How many bleed ticks occur before fadeout happens
    BlackoutTimer = 10,            -- How many bleed ticks occur before blacking out
    AdvanceBleedTimer = 10,        -- How many bleed ticks occur before bleed level increases
    HeadInjuryTimer = 30,          -- How much time, in seconds, do head injury effects chance occur
    ArmInjuryTimer = 30,           -- How much time, in seconds, do arm injury effects chance occur
    LegInjuryTimer = 15,           -- How much time, in seconds, do leg injury effects chance occur
    HeadInjuryChance = 25,         -- The chance, in percent, that head injury side-effects get applied
    LegInjuryChance = {            -- The chance, in percent, that leg injury side-effects get applied
        Running = 50,
        Walking = 15
    },
    MajorArmoredBleedChance = 45, -- The chance, in percent, that a player will get a bleed effect when taking heavy damage while wearing armor
    MaxInjuryChanceMulti = 3,     -- How many times the HealthDamage value above can divide into damage taken before damage is forced to be applied
    DamageMinorToMajor = 35,      -- How much damage would have to be applied for a minor weapon to be considered a major damage event. Put this at 100 if you want to disable it
    AlertShowInfo = 2,            -- How many injuries a player must have before being alerted about them

    Locations = {                 -- Edit the various interaction points for players or create new ones
        ['checking'] = {
            Vector(6912.9, -4918.4, -299.8),
        },
        ['duty'] = {
            Vector(7213.0, -4640.5, -33.9),
        },
        ['stash'] = {
            Vector(7195.6, -4366.1, -33.9),
        },
        ['beds'] = {
            -- { coords = Vector(353.1, -584.6, 43.11),   taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(356.79, -585.86, 43.11), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(354.12, -593.12, 43.1),  taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(350.79, -591.8, 43.1),   taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(346.99, -590.48, 43.1),  taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(360.32, -587.19, 43.02), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(349.82, -583.33, 43.02), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(326.98, -576.17, 43.02), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
        },
        ['jailbeds'] = {
            -- { coords = Vector(1761.96, 2597.74, 45.66), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(1761.96, 2591.51, 45.66), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(1771.8, 2598.02, 45.66),  taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
            -- { coords = Vector(1771.85, 2591.85, 45.66), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
        },
        ['hospital'] = {
            {
                ['name'] = Lang:t('info.pb_hospital'),
                ['location'] = Vector(6919.1, -4563.8, -299.8),
                ['beds'] = {
                    { coords = Vector(7387.9, -4108.0, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(7166.7, -4095.9, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(6911.6, -4082.0, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(6654.2, -4101.7, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(7411.2, -4348.6, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(7415.1, -4609.3, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(7395.2, -4808.7, -390), taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                },
            },
            -- add more locations here
        },
        ['stations'] = {
            { label = Lang:t('info.pb_hospital'), coords = Vector(7102.0, -4431.2, -299.8) }
        }
    },

    AuthorizedVehicles = { -- Grade is key, don't add same vehicle in multiple grades. Higher rank can see lower
        [0] = {
            ['qbcore-vehicles-mm::BP_Ambulance'] = 'Ambulance'
        }
    },

    WeaponClasses = { -- Define gta weapon classe numbers
        ['SMALL_CALIBER'] = 1,
        ['MEDIUM_CALIBER'] = 2,
        ['HIGH_CALIBER'] = 3,
        ['SHOTGUN'] = 4,
        ['CUTTING'] = 5,
        ['LIGHT_IMPACT'] = 6,
        ['HEAVY_IMPACT'] = 7,
        ['EXPLOSIVE'] = 8,
        ['FIRE'] = 9,
        ['SUFFOCATING'] = 10,
        ['OTHER'] = 11,
        ['WILDLIFE'] = 12,
        ['NOTHING'] = 13
    },

    MinorInjurWeapons = { -- Define which weapons cause small injuries
        --[WeaponClasses['SMALL_CALIBER']] = true,
        --[WeaponClasses['MEDIUM_CALIBER']] = true,
        --[WeaponClasses['CUTTING']] = true,
        --[WeaponClasses['WILDLIFE']] = true,
        --[WeaponClasses['OTHER']] = true,
        --[WeaponClasses['LIGHT_IMPACT']] = true,
    },

    MajorInjurWeapons = { -- Define which weapons cause large injuries
        --[WeaponClasses['HIGH_CALIBER']] = true,
        --[WeaponClasses['HEAVY_IMPACT']] = true,
        --[WeaponClasses['SHOTGUN']] = true,
        --[WeaponClasses['EXPLOSIVE']] = true,
    },

    AlwaysBleedChanceWeapons = { -- Define which weapons will always cause bleeding
        --[WeaponClasses['SMALL_CALIBER']] = true,
        --[WeaponClasses['MEDIUM_CALIBER']] = true,
        --[WeaponClasses['CUTTING']] = true,
        --[WeaponClasses['WILDLIFE']] = false,
    },

    ForceInjuryWeapons = { -- Define which weapons will always cause injuries
        --[WeaponClasses['HIGH_CALIBER']] = true,
        --[WeaponClasses['HEAVY_IMPACT']] = true,
        --[WeaponClasses['EXPLOSIVE']] = true,
    },

    CriticalAreas = { -- Define body areas that will always cause bleeding if wearing armor or not
        ['UPPER_BODY'] = { armored = false },
        ['LOWER_BODY'] = { armored = true },
        ['SPINE'] = { armored = true },
    },

    StaggerAreas = { -- Define body areas that will always cause staggering if wearing armor or not
        ['SPINE'] = { armored = true, major = 60, minor = 30 },
        ['UPPER_BODY'] = { armored = false, major = 60, minor = 30 },
        ['LLEG'] = { armored = true, major = 100, minor = 85 },
        ['RLEG'] = { armored = true, major = 100, minor = 85 },
        ['LFOOT'] = { armored = true, major = 100, minor = 100 },
        ['RFOOT'] = { armored = true, major = 100, minor = 100 },
    },

    WoundStates = { -- Translate wound alerts
        Lang:t('states.irritated'),
        Lang:t('states.quite_painful'),
        Lang:t('states.painful'),
        Lang:t('states.really_painful'),
    },

    BleedingStates = { -- Translate bleeding alerts
        { label = Lang:t('states.little_bleed') },
        { label = Lang:t('states.bleed') },
        { label = Lang:t('states.lot_bleed') },
        { label = Lang:t('states.big_bleed') },
    },

    MovementRate = { -- Set the player movement rate based on the level of damage they have
        0.98,
        0.96,
        0.94,
        0.92,
    },

    Bones = { -- Correspond bone hash numbers to their label
        [0] = 'NONE',
    },

    BoneIndexes = { -- Correspond bone labels to their hash number
        ['NONE'] = 0,
    },

    Weapons = { -- Correspond weapon names to their class number
        -- [`WEAPON_STUNGUN`] = WeaponClasses['NONE'],
        -- [`WEAPON_STUNGUN_MP`] = WeaponClasses['NONE'],
        -- --[[ Small Caliber ]] --
        -- [`WEAPON_PISTOL`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_COMBATPISTOL`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_APPISTOL`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_COMBATPDW`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_MACHINEPISTOL`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_MICROSMG`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_MINISMG`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_PISTOL_MK2`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_SNSPISTOL`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_SNSPISTOL_MK2`] = WeaponClasses['SMALL_CALIBER'],
        -- [`WEAPON_VINTAGEPISTOL`] = WeaponClasses['SMALL_CALIBER'],

        -- --[[ Medium Caliber ]] --
        -- [`WEAPON_ADVANCEDRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_ASSAULTSMG`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_BULLPUPRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_BULLPUPRIFLE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_CARBINERIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_CARBINERIFLE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_COMPACTRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_DOUBLEACTION`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_GUSENBERG`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_HEAVYPISTOL`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_MARKSMANPISTOL`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_PISTOL50`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_REVOLVER`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_REVOLVER_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_SMG`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_SMG_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_SPECIALCARBINE`] = WeaponClasses['MEDIUM_CALIBER'],
        -- [`WEAPON_SPECIALCARBINE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],

        -- --[[ High Caliber ]] --
        -- [`WEAPON_ASSAULTRIFLE`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_ASSAULTRIFLE_MK2`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_COMBATMG`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_COMBATMG_MK2`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_HEAVYSNIPER`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_HEAVYSNIPER_MK2`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_MARKSMANRIFLE`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_MARKSMANRIFLE_MK2`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_MG`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_MINIGUN`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_MUSKET`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_RAILGUN`] = WeaponClasses['HIGH_CALIBER'],
        -- [`WEAPON_HEAVYRIFLE`] = WeaponClasses['HIGH_CALIBER'],

        -- --[[ Shotguns ]] --
        -- [`WEAPON_ASSAULTSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_BULLUPSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_DBSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_HEAVYSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_PUMPSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_PUMPSHOTGUN_MK2`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_SAWNOFFSHOTGUN`] = WeaponClasses['SHOTGUN'],
        -- [`WEAPON_SWEEPERSHOTGUN`] = WeaponClasses['SHOTGUN'],

        -- --[[ Animals ]]                                            --
        -- [`WEAPON_ANIMAL`] = WeaponClasses['WILDLIFE'],      -- Animal
        -- [`WEAPON_COUGAR`] = WeaponClasses['WILDLIFE'],      -- Cougar
        -- [`WEAPON_BARBED_WIRE`] = WeaponClasses['WILDLIFE'], -- Barbed Wire

        -- --[[ Cutting Weapons ]]                                    --
        -- [`WEAPON_BATTLEAXE`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_BOTTLE`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_DAGGER`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_HATCHET`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_KNIFE`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_MACHETE`] = WeaponClasses['CUTTING'],
        -- [`WEAPON_SWITCHBLADE`] = WeaponClasses['CUTTING'],

        -- --[[ Light Impact ]] --
        -- [`WEAPON_KNUCKLE`] = WeaponClasses['LIGHT_IMPACT'],

        -- --[[ Heavy Impact ]] --
        -- [`WEAPON_BAT`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_CROWBAR`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_FIREEXTINGUISHER`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_FIRWORK`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_GOLFLCUB`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_HAMMER`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_PETROLCAN`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_POOLCUE`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_WRENCH`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_RAMMED_BY_CAR`] = WeaponClasses['HEAVY_IMPACT'],
        -- [`WEAPON_RUN_OVER_BY_CAR`] = WeaponClasses['HEAVY_IMPACT'],

        -- --[[ Explosives ]] --
        -- [`WEAPON_EXPLOSION`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_GRENADE`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_COMPACTLAUNCHER`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_HOMINGLAUNCHER`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_PIPEBOMB`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_PROXMINE`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_RPG`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_STICKYBOMB`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_HELI_CRASH`] = WeaponClasses['EXPLOSIVE'],
        -- [`WEAPON_EMPLAUNCHER`] = WeaponClasses['EXPLOSIVE'],

        -- --[[ Other ]]                                                   --
        -- [`WEAPON_FALL`] = WeaponClasses['OTHER'],                -- Fall
        -- [`WEAPON_HIT_BY_WATER_CANNON`] = WeaponClasses['OTHER'], -- Water Cannon

        -- --[[ Fire ]]                                                    --
        -- [`WEAPON_ELECTRIC_FENCE`] = WeaponClasses['FIRE'],
        -- [`WEAPON_FIRE`] = WeaponClasses['FIRE'],
        -- [`WEAPON_MOLOTOV`] = WeaponClasses['FIRE'],
        -- [`WEAPON_FLARE`] = WeaponClasses['FIRE'],
        -- [`WEAPON_FLAREGUN`] = WeaponClasses['FIRE'],

        -- --[[ Suffocate ]]                                                     --
        -- [`WEAPON_DROWNING`] = WeaponClasses['SUFFOCATING'],            -- Drowning
        -- [`WEAPON_DROWNING_IN_VEHICLE`] = WeaponClasses['SUFFOCATING'], -- Drowning Veh
        -- [`WEAPON_EXHAUSTION`] = WeaponClasses['SUFFOCATING'],          -- Exhaust
        -- [`WEAPON_BZGAS`] = WeaponClasses['SUFFOCATING'],
        -- [`WEAPON_SMOKEGRENADE`] = WeaponClasses['SUFFOCATING'],
    },

    VehicleSettings = {        -- Enable or disable vehicle extras when pulling them from the ambulance job vehicle spawner
        ['car1'] = {           -- Model name
            ['extras'] = {
                ['1'] = false, -- on/off
                ['2'] = true,
                ['3'] = true,
                ['4'] = true,
                ['5'] = true,
                ['6'] = true,
                ['7'] = true,
                ['8'] = true,
                ['9'] = true,
                ['10'] = true,
                ['11'] = true,
                ['12'] = true,
            }
        },
        ['car2'] = {
            ['extras'] = {
                ['1'] = false,
                ['2'] = true,
                ['3'] = true,
                ['4'] = true,
                ['5'] = true,
                ['6'] = true,
                ['7'] = true,
                ['8'] = true,
                ['9'] = true,
                ['10'] = true,
                ['11'] = true,
                ['12'] = true,
            }
        }
    }
}

return Config
