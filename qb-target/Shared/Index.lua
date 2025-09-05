Config = {
	OpenKey = 'LeftControl',          -- enable target
	MenuControlKey = 'RightMouseButton', -- enable mouse control
	MaxDistance = 1000,               -- max distance for raycast
	Debug = false,                    -- prints trace results
	EnableOutline = true,             -- enable outline on target
	OutlineColor = 0,                 -- 0 = green, 1 = red, 2 = blue
	DrawSprite = true,                -- draw sprite on target
	CollisionTrace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn,
	TraceMode = TraceMode.ReturnEntity | TraceMode.ReturnNames,

	GlobalWorldVehicleWheeledOptions = {
		options = {
			{
				type = 'client',
				label = 'Start Vehicle',
				icon = 'fas fa-wrench',
				action = function(entity)
					local ped = Client.GetLocalPlayer():GetControlledCharacter()
					if not ped then return end
					Events.CallRemote('qb-target:server:startEngine', entity)
				end,
			},
		},
		distance = 400,
	},

	GlobalWorldStaticMeshOptions = {},
	ALS_WorldCharacterBP_C = {}, -- HCharacter
	GlobalWorldPropOptions = {},
	GlobalWorldWeaponOptions = {},
	GlobalWorldVehicleDoorOptions = {
		options = {
			{
				label = 'Enter Vehicle',
				icon = 'fas fa-wrench',
				action = function(entity)
					local ped = Client.GetLocalPlayer():GetControlledCharacter()
					if not ped then return end
					Events.CallRemote('qb-target:server:enterVehicle', entity)
				end,
			},
		},
		distance = 400,
	},
}

return Config
