-- Functions

local function TeleportToInterior(player, x, y, z, h)
	local ped = player:K2_GetPawn()
	if not ped then return end
	ped:K2_SetActorLocationAndRotation(Vector(x, y, z), Rotator(0, h, 0), false, _, true)
	--player:StopCameraFade()
end

RegisterServerEvent('qb-interior:server:teleportPlayer', function(player, x, y, z, h)
	TeleportToInterior(player, x, y, z, h)
end)

-- exports('qb-interior', 'DespawnInterior', function(objects)
-- 	for _, v in pairs(objects) do
-- 		if v:IsValid(v) then
-- 			v:Destroy()
-- 		end
-- 	end
-- end)

-- local function CreateShell(player, spawn, exitXYZH, model)
-- 	local objects = {}
-- 	local POIOffsets = {}
-- 	POIOffsets.exit = exitXYZH
-- 	--player:StartCameraFade(0, 1, 0.1, Color(0.0, 0.0, 0.0, 1), true, true)
-- 	local house = StaticMesh(Vector(spawn.X, spawn.Y, spawn.Z - 1000), Rotator(), model)
-- 	--house:SetGravityEnabled(false)
-- 	objects[#objects + 1] = house
-- 	TeleportToInterior(
-- 		player,
-- 		spawn.X - POIOffsets.exit.x,
-- 		spawn.Y - POIOffsets.exit.y,
-- 		spawn.Z + POIOffsets.exit.z,
-- 		POIOffsets.exit.h
-- 	)
-- 	return { objects, POIOffsets }
-- end

-- -- -- Shells

-- exports('qb-interior', 'CreateApartmentFurnished', function(player, spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/modernhotel_shell/SM_modernhotel_shell.SM_modernhotel_shell'
-- 	local obj = CreateShell(player, spawn, exit, model)
-- 	if obj and obj[2] then
-- 		obj[2].clothes = JSON.parse('{"x": 247.8, "y": -296.9, "z": 110.0, "h": 2.263}')
-- 		obj[2].stash = JSON.parse('{"x": -237.7, "y": -296.9, "z": 110.0, "h": 2.263}')
-- 		obj[2].logout = JSON.parse('{"x": -458.3, "y": 134.6, "z": 93.0, "h": 2.263}')
-- 	end
-- 	-- if IsNew then
-- 	-- 	Timer.SetTimeout(function()
-- 	-- 		TriggerClientEvent(player, 'qb-clothes:client:CreateFirstCharacter')
-- 	-- 		IsNew = false
-- 	-- 	end, 1000)
-- 	-- end
-- 	return { obj[1], obj[2] }
-- end)

-- exports('qb-interior', 'CreateContainer', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/container_shell/SM_container_shell.SM_container_shell'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateFurniMid', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/furnitured_midapart/SM_furnitured_midapart.SM_furnitured_midapart'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateFranklinAunt', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_frankaunt/SM_shell_frankaunt.SM_shell_frankaunt'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateGarageMed', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/garage_med/SM_shell_garagem.SM_shell_garagem'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateLesterShell', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_lester/SM_shell_lester.SM_shell_lester'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateOffice1', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_office1/SM_shell_office1.SM_shell_office1'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateStore1', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_store1/SM_shell_store1.SM_shell_store1'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateTrailer', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_trailer/SM_shell_trailer.SM_shell_trailer'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateWarehouse1', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/shell_warehouse1/SM_shell_warehouse1.SM_shell_warehouse1'
-- 	return CreateShell(spawn, exit, model)
-- end)

-- exports('qb-interior', 'CreateStandardMotel', function(spawn)
-- 	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
-- 	local model = '/Game/Shells/standardmotel_shell/SM_standardmotel_shell.SM_standardmotel_shell'
-- 	return CreateShell(spawn, exit, model)
-- end)
