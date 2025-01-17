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

	GlobalWorldStaticMeshOptions = {
		-- options = {
		-- 	{
		-- 		type = 'server',
		-- 		event = 'qb-target:server:wave',
		-- 		label = 'Wave Hello',
		-- 		icon = 'fas fa-hand',
		-- 	},
		-- },
		-- distance = 400,
	},

	GlobalWorldCharacterSimpleOptions = {
		options = {
			{
				type = 'server',
				event = 'qb-target:server:wave',
				label = 'Wave Hello',
				icon = 'fas fa-hand',
			},
		},
		distance = 400,
	},

	ALS_WorldCharacterBP_C = {}, -- HCharacter

	GlobalWorldPropOptions = {
		options = {
			{
				type = 'client',
				label = 'Pickup Prop',
				icon = 'fas fa-hands-holding-circle',
				canInteract = function(entity)
					if not entity:GetGrabMode() then return false end
				end,
				action = function(entity)
					local ped = Client.GetLocalPlayer():GetControlledCharacter()
					if not ped then return end
					Events.CallRemote('qb-target:server:pickupProp', entity)
				end,
			},
		},
		distance = 400,
	},

	GlobalWorldWeaponOptions = {
		options = {
			{
				type = 'client',
				label = 'Pickup Weapon',
				icon = 'fas fa-gun',
				canInteract = function(entity)
					if not entity:GetGrabMode() then return false end
				end,
				action = function(entity)
					local ped = Client.GetLocalPlayer():GetControlledCharacter()
					if not ped then return end
					Events.CallRemote('qb-target:server:pickupWeapon', entity)
				end,
			},
		},
		distance = 400,
	},
}

return Config
