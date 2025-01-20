Config = {
    adminOptions = {
        { name = 'NoClip',     command = 'noclip' },
        { name = 'Heal',       command = 'heal' },
        { name = 'Kill',       command = 'kill' },
        { name = 'Revive',     command = 'revive' },
        { name = 'Revive All', command = 'reviveall' },
        { name = 'Invisible',  command = 'invisible' },
        { name = 'Godmode',    command = 'godmode' },
        { name = 'Names',      command = 'names' },
        { name = 'Blips',      command = 'blips' },
    },
    devOptions = {
        { name = 'Copy Vector',   command = 'coords' },
        { name = 'Copy Rotation', command = 'rotation' },
        { name = 'Copy Heading',  command = 'heading' },
        { name = 'Show Coords',   command = 'showcoords' },
        --{ name = 'Teleport',      command = 'tp' },
        { name = 'Laser',         command = 'laser' },
    },
    weaponOptions = {
        { name = 'Fix',      command = 'fixweapon' },
        { name = 'Max Ammo', command = 'maxammo' },
    },
    vehicleOptions = {
        { name = 'Fix',    command = 'fix' },
        --{ name = 'Buy',      command = 'admincar' },
        { name = 'Delete', command = 'dv' },
        --{ name = 'Max Mods', command = 'maxmods' },
    },
    weatherOptions = {
        { name = 'clear',        command = 'weather' },
        { name = 'cloudy',       command = 'weather' },
        { name = 'foggy',        command = 'weather' },
        { name = 'overcast',     command = 'weather' },
        { name = 'partlycloudy', command = 'weather' },
        { name = 'rain',         command = 'weather' },
        { name = 'lightrain',    command = 'weather' },
        { name = 'thunderstorm', command = 'weather' },
        { name = 'dust',         command = 'weather' },
        { name = 'duststorm',    command = 'weather' },
        { name = 'snow',         command = 'weather' },
        { name = 'blizzard',     command = 'weather' },
        { name = 'lightsnow',    command = 'weather' },
    }
}

return Config
