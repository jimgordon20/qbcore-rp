local my_webui = WebUI('Target', 'file://html/index.html')
local Config = Package.Require('config.lua')
local player_data = QBCore.Functions.GetPlayerData()
local target_active, target_entity, raycast_timer, player_ped, target_sprite = false, nil, nil, nil, nil
local nui_data, send_data, Entities, Types, Zones = {}, {}, {}, {}, {}

-- Handlers

Package.Subscribe('Load', function()
	player_data = QBCore.Functions.GetPlayerData()
	local player = Client.GetLocalPlayer()
	if player then
		player_ped = player:GetControlledCharacter()
	end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
	player_data = QBCore.Functions.GetPlayerData()
	player_ped = Client.GetLocalPlayer():GetControlledCharacter()
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
	player_data = {}
	player_ped = nil
end)

Events.SubscribeRemote('QBCore:Client:OnJobUpdate', function(JobInfo)
	player_data.job = JobInfo
end)

Events.SubscribeRemote('QBCore:Client:OnGangUpdate', function(GangInfo)
	player_data.gang = GangInfo
end)

Events.SubscribeRemote('QBCore:Player:SetPlayerData', function(val)
	player_data = val
end)

-- Functions

local function JobCheck(job)
	if not player_data.job then
		return false
	end
	return player_data.job.name == job
end

local function JobTypeCheck(jobType)
	if not player_data.job then
		return false
	end
	return player_data.job.type == jobType
end

local function GangCheck(gang)
	if not player_data.gang then
		return false
	end
	return player_data.gang.name == gang
end

local function ItemCheck(item)
	return HasItem(item)
end

local function CitizenCheck(citizenid)
	return player_data.citizenid == citizenid
end

local function checkOptions(data, entity, distance)
	if distance and data.distance and distance > data.distance then
		return false
	end
	if data.job and not JobCheck(data.job) then
		return false
	end
	if data.jobType and not JobTypeCheck(data.jobType) then
		return false
	end
	if data.gang and not GangCheck(data.gang) then
		return false
	end
	if data.item and not ItemCheck(data.item) then
		return false
	end
	if data.citizenid and not CitizenCheck(data.citizenid) then
		return false
	end
	if data.canInteract and not data.canInteract(entity, distance, data) then
		return false
	end
	return true
end

local function setupOptions(datatable, entity, distance)
	if not datatable then
		return
	end
	for _, data in pairs(datatable) do
		if checkOptions(data, entity, distance) then
			local new_option = {
				icon = data.icon,
				targeticon = data.targetIcon,
				label = data.label,
			}
			table.insert(nui_data, new_option)
			send_data[#nui_data] = data
			send_data[#nui_data].entity = entity
		end
	end
end

local function drawSprite(entity)
	if not Config.DrawSprite then
		return
	end
	if target_sprite then
		return
	end
	local coords = entity:GetLocation()
	target_sprite = Billboard(coords, '', Vector2D(0.02, 0.02), true)
	target_sprite:SetMaterialTextureParameter('Texture', 'package://qb-target/Client/html/circle.png')
	target_sprite:SetMaterialColorParameter('Texture', Color(255, 255, 255, 255))
end

local function removeSprite()
	if target_sprite then
		target_sprite:Destroy()
		target_sprite = nil
	end
end

local function updateEntityHighlight(entity, enable)
	if Config.EnableOutline then
		entity:SetHighlightEnabled(enable, Config.OutlineColor)
		entity:SetOutlineEnabled(enable, Config.OutlineColor)
	end
end

local function handleEntity(trace_result, start_location)
	if not trace_result or not trace_result.Entity then
		if target_entity then
			updateEntityHighlight(target_entity, false)
			target_entity = nil
			nui_data = {}
			my_webui:CallEvent('leftTarget')
		end
		return
	end
	if trace_result.Success then
		if target_entity ~= trace_result.Entity then
			if target_entity then
				updateEntityHighlight(target_entity, false)
				if Config.DrawSprite then removeSprite() end
				my_webui:CallEvent('leftTarget')
			end
			target_entity = trace_result.Entity
			updateEntityHighlight(target_entity, true)
			if Config.DrawSprite then drawSprite(target_entity) end

			nui_data = {}
			local distance = start_location:Distance(trace_result.Location)
			if Entities[target_entity] then
				setupOptions(Entities[target_entity], target_entity, distance)
			end
			if Types[tostring(trace_result.ActorName)] then
				setupOptions(Types[tostring(trace_result.ActorName)], target_entity, distance)
			end
			my_webui:CallEvent('foundTarget', { data = nui_data[1] and nui_data[1].targeticon or '', options = nui_data })
		end
	else
		if target_entity then
			updateEntityHighlight(target_entity, false)
			target_entity = nil
			nui_data = {}
			my_webui:CallEvent('leftTarget')
		end
	end
end

local function handleRaycast()
	if not target_active then
		return
	end
	local viewport_2d_center = Viewport.GetViewportSize() / 2
	local viewport_3d = Viewport.DeprojectScreenToWorld(viewport_2d_center)
	local trace_max_distance = Config.MaxDistance
	local start_location = viewport_3d.Position
	local end_location = viewport_3d.Position + viewport_3d.Direction * trace_max_distance
	local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn
	local trace_mode = TraceMode.ReturnEntity | TraceMode.ReturnNames
	local trace_result = Trace.LineSingle(start_location, end_location, collision_trace, trace_mode, { Client.GetLocalPlayer():GetControlledCharacter() })
	if Config.Debug then print(HELIXTable.Dump(trace_result)) end
	return trace_result, start_location
end

local function enableTarget()
	if Input.IsMouseEnabled() then
		return
	end
	if target_active then
		return
	end
	target_active = true
	my_webui:CallEvent('openTarget')
	raycast_timer = Timer.SetInterval(function()
		local trace_result, start_location = handleRaycast()
		handleEntity(trace_result, start_location)
	end, 100)
end

local function disableTarget()
	if not target_active then
		return
	end
	if target_entity and Config.EnableOutline then
		target_entity:SetOutlineEnabled(false)
	end
	if target_sprite then
		target_sprite:Destroy()
		target_sprite = nil
	end
	target_active, target_entity = false, nil
	nui_data, send_data = {}, {}
	my_webui:CallEvent('closeTarget')
	if raycast_timer then
		Timer.ClearInterval(raycast_timer)
		raycast_timer = nil
	end
	Input.SetMouseEnabled(false)
end

local function enableMouse()
	Input.SetMouseEnabled(true)
	local viewport_size = Viewport.GetViewportSize()
	local center_position = Vector2D(viewport_size.X / 2, viewport_size.Y / 2)
	Viewport.SetMousePosition(center_position)
	my_webui:BringToFront()
end

local function SetOptions(tbl, distance, options)
	for i = 1, #options do
		local v = options[i]
		if v.required_item then
			v.item = v.required_item
			v.required_item = nil
		end
		if not v.distance or v.distance > distance then
			v.distance = distance
		end
		tbl[v.label] = v
	end
end

-- Exports

local function AddTargetEntity(entities, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	if not Entities[entities] then
		Entities[entities] = {}
	end
	SetOptions(Entities[entities], distance, options)
end
Package.Export('AddTargetEntity', AddTargetEntity)

local function RemoveTargetEntity(entities)
	Entities[entities] = nil
end
Package.Export('RemoveTargetEntity', RemoveTargetEntity)

local function AddBoxZone(name, center, length, width, zoneOptions, targetoptions)
	if not name or not center or not length or not width or not targetoptions then return end
	if Zones[name] then return end
	if not Zones[name] then Zones[name] = {} end
	local box_entity = StaticMesh(center, Rotator(0.0, zoneOptions.heading, 0.0), 'ecdbd-h::Invisible', CollisionType.NoCollision)
	box_entity:SetScale(Vector(length, width, 5.0))
	Zones[name] = box_entity
	AddTargetEntity(box_entity, targetoptions)
end
Package.Export('AddBoxZone', AddBoxZone)

local function RemoveZone(name)
	if not Zones[name] then
		return
	end
	Zones[name]:Destroy()
	if Entities[Zones[name]] then
		Entities[Zones[name]] = nil
	end
	Zones[name] = nil
end
Package.Export('RemoveZone', RemoveZone)

-- Events

my_webui:Subscribe('selectTarget', function(option)
	option = tonumber(option) or option
	Input.SetMouseEnabled(false)
	target_active = false
	if not next(send_data) then
		return
	end
	local data = send_data[option]
	if not data then
		return
	end
	send_data = {}
	if data.action then
		data.action(data.entity)
	elseif data.event then
		if data.type == 'client' then
			Events.Call(data.event, data)
		elseif data.type == 'server' then
			Events.CallRemote(data.event, data)
		elseif data.type == 'command' then
			Events.CallRemote('QBCore:CallCommand', data.event, data)
		else
			Events.Call(data.event, data)
		end
	end
	my_webui:CallEvent('closeTarget')
end)

my_webui:Subscribe('leftTarget', function()
	target_entity = nil
end)

my_webui:Subscribe('closeTarget', function()
	disableTarget()
end)

-- Keybinds

Input.Register('Target', Config.OpenKey, 'Open Target')
Input.Bind('Target', InputEvent.Pressed, enableTarget)
Input.Bind('Target', InputEvent.Released, disableTarget)

Input.Subscribe('MouseDown', function(key_name)
	if target_active and key_name == Config.MenuControlKey and next(nui_data) then
		enableMouse()
		my_webui:CallEvent('validTarget', { data = nui_data })
	end
end)

-- Setup config options

if not Types['WorldVehicleWheeled'] then
	Types['WorldVehicleWheeled'] = {}
end
SetOptions(
	Types['WorldVehicleWheeled'],
	Config.GlobalWorldVehicleWheeledOptions.distance,
	Config.GlobalWorldVehicleWheeledOptions.options
)

if not Types['WorldCharacterSimple'] then
	Types['WorldCharacterSimple'] = {}
end
SetOptions(
	Types['WorldCharacterSimple'],
	Config.GlobalWorldCharacterSimpleOptions.distance,
	Config.GlobalWorldCharacterSimpleOptions.options
)

if not Types['WorldProp'] then
	Types['WorldProp'] = {}
end
SetOptions(Types['WorldProp'], Config.GlobalWorldPropOptions.distance, Config.GlobalWorldPropOptions.options)

if not Types['WorldWeapon'] then
	Types['WorldWeapon'] = {}
end
SetOptions(Types['WorldWeapon'], Config.GlobalWorldWeaponOptions.distance, Config.GlobalWorldWeaponOptions.options)

if not Types['WorldStaticMesh'] then
	Types['WorldStaticMesh'] = {}
end
SetOptions(
	Types['WorldStaticMesh'],
	Config.GlobalWorldStaticMeshOptions.distance,
	Config.GlobalWorldStaticMeshOptions.options
)
