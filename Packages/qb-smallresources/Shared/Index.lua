Config = {

    AFK = {
        enable = false,
        ignoredGroups = {
            ['mod'] = true,
            ['admin'] = true,
            ['god'] = true
        },
        timer = 5, -- in minutes
        warnings_to_kick = 3,
    },

    Discord = {
        enable = false,
        application_id = '',
        server_name = '',
        details = '',
        large_image = '',
        large_text = '',
    },

    Time = {
        synced = true,
        multiplier = 5, -- every irl minute is 5 in-game minutes
    },

    Weather = {
        dynamic = true,
        update_interval = 30, -- in minutes
        default_weather = 1,
        available_types = {
            ['clear'] = 1,
            ['cloudy'] = 2,
            ['foggy'] = 3,
            ['overcast'] = 4,
            ['partlycloudy'] = 5,
            ['rain'] = 6,
            ['lightrain'] = 7,
            ['thunderstorm'] = 8,
            ['dust'] = 9,
            ['duststorm'] = 10,
            ['snow'] = 11,
            ['blizzard'] = 12,
            ['lightsnow'] = 13,
        }
    },

    Consumables = {
        eat = { -- default food items
            ['sandwich'] = math.random(35, 54),
            ['tosti'] = math.random(40, 50),
            ['twerks_candy'] = math.random(35, 54),
            ['snikkel_candy'] = math.random(40, 50)
        },
        drink = { -- default drink items
            ['water_bottle'] = math.random(35, 54),
            ['kurkakola'] = math.random(35, 54),
            ['coffee'] = math.random(40, 50)
        },
        alcohol = { -- default alcohol items
            ['whiskey'] = math.random(20, 30),
            ['beer'] = math.random(30, 40),
            ['vodka'] = math.random(20, 40),
        },
    }
}

return Config
