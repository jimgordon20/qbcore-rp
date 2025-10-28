local interiors = {}
local nextId = 1

-- Functions

exports('qb-interior', 'DespawnInterior', function(id)
    if interiors[id] and interiors[id].object then
        interiors[id].object:K2_DestroyActor()
        interiors[id] = nil
    end
end)

local function CreateShell(spawn, exitXYZH, model, teleport)
    local id = nextId
    nextId = nextId + 1

    local POIOffsets = {}
    POIOffsets.exit = exitXYZH
    local house = StaticMesh(Vector(spawn.X, spawn.Y, spawn.Z), Rotator(), model)

    interiors[id] = {
        object = house,
        POIOffsets = POIOffsets
    }

    if teleport or teleport == nil then
        Timer.SetTimeout(function()
            TriggerServerEvent(
                'qb-interior:server:teleportPlayer',
                spawn.X - POIOffsets.exit.x,
                spawn.Y - POIOffsets.exit.y,
                spawn.Z + POIOffsets.exit.z,
                POIOffsets.exit.h
            )
        end, 1000)
    end

    return id, POIOffsets
end

-- Shells

exports('qb-interior', 'CreateApartmentFurnished_C', function(spawn, teleport)
    local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
    local model = '/Game/Shells/modernhotel_shell/SM_modernhotel_shell.SM_modernhotel_shell'
    local id, POIOffsets = CreateShell(spawn, exit, model, teleport)

    if POIOffsets then
        POIOffsets.clothes = JSON.parse('{"x": 247.8, "y": -296.9, "z": 110.0, "h": 2.263}')
        POIOffsets.stash = JSON.parse('{"x": -237.7, "y": -296.9, "z": 110.0, "h": 2.263}')
        POIOffsets.logout = JSON.parse('{"x": -458.3, "y": 134.6, "z": 93.0, "h": 2.263}')
        interiors[id].POIOffsets = POIOffsets
    end

    return { id, POIOffsets }
end)

exports('qb-interior', 'CreateContainer_C', function(spawn)
    local exit = JSON.parse('{"x": 10.0, "y": 458.0, "z": 93.0, "h": 100.51}')
    local model = '/Game/Shells/container_shell/SM_container_shell.SM_container_shell'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateFurniMid_C', function(spawn)
    local exit = JSON.parse('{"x": 118.0, "y": 830.0, "z": 93.0, "h": 82.04}')
    local model = '/Game/Shells/furnitured_midapart/SM_furnitured_midapart.SM_furnitured_midapart'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateFranklinAunt_C', function(spawn)
    local exit = JSON.parse('{"x": -21.0, "y": 466.50, "z": 93.0, "h": 82.55}')
    local model = '/Game/Shells/shell_frankaunt/SM_shell_frankaunt.SM_shell_frankaunt'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateGarageMed_C', function(spawn)
    local exit = JSON.parse('{"x": 1153.0, "y": -129.0, "z": 93.0, "h": -6.23}')
    local model = '/Game/Shells/shell_garagem/SM_shell_garagem.SM_shell_garagem'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateLesterShell_C', function(spawn)
    local exit = JSON.parse('{"x": -134.30, "y": 480.0, "z": 93.0, "h": 72.58}')
    local model = '/Game/Shells/shell_lester/SM_shell_lester.SM_shell_lester'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateOffice1_C', function(spawn)
    local exit = JSON.parse('{"x": 105.0, "y": -402.0, "z": 93.0, "h": -84.68}')
    local model = '/Game/Shells/shell_office1/SM_shell_office1.SM_shell_office1'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateStore1_C', function(spawn)
    local exit = JSON.parse('{"x": -223.0, "y": 358.0, "z": 93.0, "h": 86.02}')
    local model = '/Game/Shells/shell_store1/SM_shell_store1.SM_shell_store1'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateTrailer_C', function(spawn)
    local exit = JSON.parse('{"x": -107.0, "y": 164.0, "z": 93.0, "h": 93.35}')
    local model = '/Game/Shells/shell_trailer/SM_shell_trailer.SM_shell_trailer'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateWarehouse1_C', function(spawn)
    local exit = JSON.parse('{"x": -730.0, "y": -18.0, "z": 93.0, "h": 169.90}')
    local model = '/Game/Shells/shell_warehouse1/SM_shell_warehouse1.SM_shell_warehouse1'
    return CreateShell(spawn, exit, model)
end)

exports('qb-interior', 'CreateStandardMotel_C', function(spawn)
    local exit = JSON.parse('{"x": 430.0, "y": 347.0, "z": 93.0, "h": 90.81}')
    local model = '/Game/Shells/standardmotel_shell/SM_standardmotel_shell.SM_standardmotel_shell'
    return CreateShell(spawn, exit, model)
end)
