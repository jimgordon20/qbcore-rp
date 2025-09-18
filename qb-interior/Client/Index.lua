-- Functions

exports('qb-interior', 'DespawnInterior', function(objects, cb)
	for _, v in pairs(objects) do
		if v:IsValid(v) then
			v:Destroy()
		end
	end
	cb()
end)

local function CreateShell(spawn, exitXYZH, model)
	local objects = {}
	local POIOffsets = {}
	POIOffsets.exit = exitXYZH
	--local Player = Client.GetLocalPlayer()
	--local dimension = Player:GetDimension()
	HPlayer:StartCameraFade(0, 1, 0.1, Color(0.0, 0.0, 0.0, 1), true, true)
	local house = StaticMesh(Vector(spawn.X, spawn.Y, spawn.Z), Rotator(), model, CollisionType.Normal)
	--house:SetDimension(dimension)
	objects[#objects + 1] = house
	Timer.SetTimeout(function()
		TriggerServerEvent(
			'qb-interior:server:teleportPlayer',
			spawn.X - POIOffsets.exit.x,
			spawn.Y - POIOffsets.exit.y,
			spawn.Z + POIOffsets.exit.z,
			POIOffsets.exit.h
		)
	end, 5000)
	return { objects, POIOffsets }
end

-- Shells

exports('qb-interior', 'CreateApartmentFurnished', function(spawn)
	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
	local model = '/Game/Shells/modernhotel_shell/SM_modernhotel_shell.SM_modernhotel_shell'
	local obj = CreateShell(spawn, exit, model)
	if obj and obj[2] then
		obj[2].clothes = JSON.parse('{"x": 247.8, "y": -296.9, "z": 110.0, "h": 2.263}')
		obj[2].stash = JSON.parse('{"x": -237.7, "y": -296.9, "z": 110.0, "h": 2.263}')
		obj[2].logout = JSON.parse('{"x": -458.3, "y": 134.6, "z": 93.0, "h": 2.263}')
	end
	return { obj[1], obj[2] }
end)

exports('qb-interior', 'CreateContainer', function(spawn)
	local exit = JSON.parse('{"x": 10.0, "y": 458.0, "z": 93.0, "h": 100.51}')
	local model = '/Game/Shells/container_shell/SM_container_shell.SM_container_shell'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateFurniMid', function(spawn)
	local exit = JSON.parse('{"x": 118.0, "y": 830.0, "z": 93.0, "h": 82.04}')
	local model = '/Game/Shells/furnitured_midapart/SM_furnitured_midapart.SM_furnitured_midapart'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateFranklinAunt', function(spawn)
	local exit = JSON.parse('{"x": -21.0, "y": 466.50, "z": 93.0, "h": 82.55}')
	local model = '/Game/Shells/shell_frankaunt/SM_shell_frankaunt.SM_shell_frankaunt'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateGarageMed', function(spawn)
	local exit = JSON.parse('{"x": 1153.0, "y": -129.0, "z": 93.0, "h": -6.23}')
	local model = '/Game/Shells/shell_garagem/SM_shell_garagem.SM_shell_garagem'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateLesterShell', function(spawn)
	local exit = JSON.parse('{"x": -134.30, "y": 480.0, "z": 93.0, "h": 72.58}')
	local model = '/Game/Shells/shell_lester/SM_shell_lester.SM_shell_lester'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateOffice1', function(spawn)
	local exit = JSON.parse('{"x": 105.0, "y": -402.0, "z": 93.0, "h": -84.68}')
	local model = '/Game/Shells/shell_office1/SM_shell_office1.SM_shell_office1'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateStore1', function(spawn)
	local exit = JSON.parse('{"x": -223.0, "y": 358.0, "z": 93.0, "h": 86.02}')
	local model = '/Game/Shells/shell_store1/SM_shell_store1.SM_shell_store1'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateTrailer', function(spawn)
	local exit = JSON.parse('{"x": -107.0, "y": 164.0, "z": 93.0, "h": 93.35}')
	local model = '/Game/Shells/shell_trailer/SM_shell_trailer.SM_shell_trailer'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateWarehouse1', function(spawn)
	local exit = JSON.parse('{"x": -730.0, "y": -18.0, "z": 93.0, "h": 169.90}')
	local model = '/Game/Shells/shell_warehouse1/SM_shell_warehouse1.SM_shell_warehouse1'
	return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateStandardMotel', function(spawn)
	local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
	local model = '/Game/Shells/standardmotel_shell/SM_standardmotel_shell.SM_standardmotel_shell'
	return CreateShell(spawn, exit, model)
end)
