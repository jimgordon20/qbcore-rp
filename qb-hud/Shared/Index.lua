Config = {
    UseMPH = true,         -- If true speed math will be done as MPH, if false KPH will be used (YOU HAVE TO CHANGE CONTENT IN STYLES.CSS TO DISPLAY THE CORRECT TEXT)
    DisableStress = false, -- If true will disable stress completely for all players
    WhitelistedJobs = {    -- Disable stress completely for players with matching job or job type
        ['leo'] = true,
        ['ambulance'] = true
    }
}

return Config
