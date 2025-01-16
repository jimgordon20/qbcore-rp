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
    BleedTickDamage = 4,           -- The base damage that is multiplied by bleed level everytime a bleed tick occurs
    FadeOutTimer = 30,             -- How many bleed ticks occur before fadeout happens
    BlackoutTimer = 10,            -- How many bleed ticks occur before blacking out
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
        ['beds'] = { -- Redundant, can be cleaned?
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
                ['name'] = Lang:t('info.ws_hospital'),
                ['location'] = Vector(-252606.4, 41048.8, 220.0), -- Redundant? Unused currently, same data as stations
                ['beds'] = {
                    { coords = Vector(-252014.6, 39821.7, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-251843.6, 39690.0, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-251540.2, 40023.4, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-251731.7, 40179.6, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-251547.5, 40441.7, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-251354.9, 40310.3, 121.5), heading = 53.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                },
            },
            {
                ['name'] = Lang:t('info.dt_hospital'),
                ['location'] = Vector(-33552.0, 134193.9, 225.2), -- Redundant? Unused currently, same data as stations
                ['beds'] = {
                    { coords = Vector(-33144.3, 133058.6, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-32944.9, 132881.2, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-32730.4, 133104.2, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-32904.1, 133274.4, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-32672.5, 133533.9, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(-32494.3, 133380.6, 126.7), heading = 50.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                },
            },
            {
                ['name'] = Lang:t('info.es_hospital'),
                ['location'] = Vector(108301.3, 236084.8, 233.4), -- Redundant? Unused currently, same data as stations
                ['beds'] = {
                    { coords = Vector(107123.4, 236424.3, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(106902.1, 236350.1, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(107017.0, 236043.7, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(107245.6, 236112.7, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(107329.7, 235788.3, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                    { coords = Vector(107072.5, 235713.1, 134.8), heading = -70.0, taken = false, model = 'abcca-qbcore::SM_HospitalBed' },
                },
            }
            -- add more locations here
        },
        ['stations'] = {
            { label = Lang:t('info.ws_hospital'), coords = Vector(-252606.4, 41048.8, 220.0) },
            { label = Lang:t('info.dt_hospital'), coords = Vector(-33552.0, 134193.9, 225.2) },
            { label = Lang:t('info.es_hospital'), coords = Vector(108301.3, 236084.8, 233.4) },
        }
    },

    AuthorizedVehicles = { -- Grade is key, don't add same vehicle in multiple grades. Higher rank can see lower
        [0] = {
            ['qbcore-vehicles-mm::BP_Ambulance'] = 'Ambulance'
        }
    },

    MinorInjury = 25, -- 25 or less damage is minor, more is major

    -- armored = whether to bleed if wearing armor. major = chance of stagger during major weapon: integer | nil (don't stagger)
    Bones = {
        head = { label = Lang:t('body.head'), causeLimp = false, isDamaged = false, severity = 0 },
        neck_02 = { label = Lang:t('body.neck_02'), causeLimp = false, isDamaged = false, severity = 0 },
        neck_01 = { label = Lang:t('body.neck_01'), causeLimp = false, isDamaged = false, severity = 0 },
        clavicle_l = { label = Lang:t('body.clavicle_l'), causeLimp = false, isDamaged = false, severity = 0 },
        clavicle_r = { label = Lang:t('body.clavicle_r'), causeLimp = false, isDamaged = false, severity = 0 },
        upperarm_l = { label = Lang:t('body.upperarm_l'), causeLimp = false, isDamaged = false, severity = 0 },
        upperarm_r = { label = Lang:t('body.upperarm_r'), causeLimp = false, isDamaged = false, severity = 0 },
        lowerarm_l = { label = Lang:t('body.lowerarm_l'), causeLimp = false, isDamaged = false, severity = 0 },
        lowerarm_r = { label = Lang:t('body.lowerarm_r'), causeLimp = false, isDamaged = false, severity = 0 },
        hand_l = { label = Lang:t('body.hand_l'), causeLimp = false, isDamaged = false, severity = 0 },
        hand_r = { label = Lang:t('body.hand_r'), causeLimp = false, isDamaged = false, severity = 0 },
        spine_05 = { label = Lang:t('body.spine_05'), causeLimp = false, isDamaged = false, severity = 0, armored = false, major = 60, minor = 30 }, -- 60% chance, 30% chance of stagger
        spine_04 = { label = Lang:t('body.spine_04'), causeLimp = false, isDamaged = false, severity = 0, armored = false, major = 60, minor = 30 },
        spine_03 = { label = Lang:t('body.spine_03'), causeLimp = false, isDamaged = false, severity = 0, armored = false, major = 60, minor = 30 },
        spine_02 = { label = Lang:t('body.spine_02'), causeLimp = false, isDamaged = false, severity = 0, armored = false, major = 60, minor = 30 }, -- Couldn't see a spine_01 during testing
        pelvis = { label = Lang:t('body.pelvis'), causeLimp = false, isDamaged = false, severity = 0 },
        thigh_l = { label = Lang:t('body.thigh_l'), causeLimp = false, isDamaged = false, severity = 0,  major = 100, minor = 85 },
        thigh_r = { label = Lang:t('body.thigh_r'), causeLimp = false, isDamaged = false, severity = 0,  major = 100, minor = 85 },
        calf_l = { label = Lang:t('body.calf_l'), causeLimp = false, isDamaged = false, severity = 0, major = 100, minor = 85 },
        calf_r = { label = Lang:t('body.calf_r'), causeLimp = false, isDamaged = false, severity = 0, major = 100, minor = 85 },
        foot_l = { label = Lang:t('body.foot_l'), causeLimp = false, isDamaged = false, severity = 0, major = 100, minor = 100 },
        foot_r = { label = Lang:t('body.foot_r'), causeLimp = false, isDamaged = false, severity = 0, major = 100, minor = 100 },
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
}

return Config
