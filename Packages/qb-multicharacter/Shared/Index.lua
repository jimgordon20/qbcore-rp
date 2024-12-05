Config = {
	CamCoords = Vector(6383.6, 3794.5, -315.8), -- Camera coordinates for character preview screen
	EnableDeleteButton = true, -- Define if the player can delete the character or not
	customNationality = false, -- Defines if Nationality input is custom of blocked to the list of Countries
	SkipSelection = false, -- Skip the spawn selection and spawns the player at the last location
	DefaultNumberOfCharacters = 5, -- Define maximum amount of default characters (maximum 5 characters defined by default)
	PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
		{ license = "", numberOfChars = 2 },
	},
}

return Config
