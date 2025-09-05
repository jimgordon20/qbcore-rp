local my_webui = WebUI('Target', 'qb-target/Client/html/index.html')
local player_data = {}
local player_ped
local target_active, target_entity, raycast_timer = false, nil, nil
local active_sprites, nui_data, send_data, Entities, Types, Zones = {}, {}, {}, {}, {}, {}

-- Handlers

Package.Subscribe('Load', function()
	player_data = QBCore.Functions.GetPlayerData()
	local player = Client.GetLocalPlayer()
	if player then player_ped = player:GetControlledCharacter() end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
	player_data = QBCore.Functions.GetPlayerData()
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
	player_data = {}
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

Player.Subscribe('Possess', function(self, character)
	local player = Client.GetLocalPlayer()
	if self == player then
		player_ped = character
	end
end)

-- Functions

local function JobCheck(job)
	if not player_data.job then return false end
	return player_data.job.name == job
end

local function JobTypeCheck(jobType)
	if not player_data.job then return false end
	return player_data.job.type == jobType
end

local function GangCheck(gang)
	if not player_data.gang then return false end
	return player_data.gang.name == gang
end

local function ItemCheck(item)
	return HasItem(item)
end

local function CitizenCheck(citizenid)
	return player_data.citizenid == citizenid
end

local function checkOptions(data, entity, distance)
	return not (distance and data.distance and distance > data.distance)
		and (not data.job or JobCheck(data.job))
		and (not data.jobType or JobTypeCheck(data.jobType))
		and (not data.gang or GangCheck(data.gang))
		and (not data.item or ItemCheck(data.item))
		and (not data.citizenid or CitizenCheck(data.citizenid))
		and (not data.canInteract or data.canInteract(entity, distance, data))
end

local function setupOptions(datatable, entity, distance)
	if not datatable then return end
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
			local target_icon = nui_data[1] and nui_data[1].targeticon or ''
			my_webui:CallFunction('foundTarget', { data = target_icon, options = nui_data })
		end
	end
end

local function removeSprite(entity)
	if entity and active_sprites[entity] then
		active_sprites[entity]:Destroy()
		active_sprites[entity] = nil
	elseif not entity then
		for _, sprite in pairs(active_sprites) do
			sprite:Destroy()
		end
		active_sprites = {}
	end
end

local function updateEntityHighlight(entity, enable)
	if not entity or not entity:IsValid() then return end
	if Config.EnableOutline then
		entity:SetHighlightEnabled(enable, Config.OutlineColor)
		entity:SetOutlineEnabled(enable, Config.OutlineColor)
	end
end

local function clearTarget()
	if not target_entity then return end
	updateEntityHighlight(target_entity, false)
	target_entity = nil
	nui_data = {}
	my_webui:CallFunction('leftTarget')
end

local function handleEntity(trace_result, start_location)
	if not trace_result or not trace_result.Entity or not trace_result.Success then
		clearTarget()
		return
	end
	local entity_has_options = Entities[trace_result.Entity]
	local type_has_options = Types[tostring(trace_result.ActorName)]
	if not entity_has_options and not type_has_options then
		clearTarget()
		return
	end
	if target_entity ~= trace_result.Entity then
		clearTarget()
		target_entity = trace_result.Entity
		updateEntityHighlight(target_entity, true)
		nui_data = {}
		local distance = start_location:Distance(trace_result.Location)
		local entity_options = Entities[target_entity]
		local type_options = Types[tostring(trace_result.ActorName)]
		if entity_options then setupOptions(entity_options, target_entity, distance) end
		if type_options then setupOptions(type_options, target_entity, distance) end
	end
end

local function handleRaycast()
	if not target_active then return end
	local viewport_2d_center = Viewport.GetViewportSize() / 2
	local viewport_3d = Viewport.DeprojectScreenToWorld(viewport_2d_center)
	local trace_max_distance = Config.MaxDistance
	local start_location = viewport_3d.Position
	local end_location = viewport_3d.Position + viewport_3d.Direction * trace_max_distance
	local trace_result = Trace.LineSingle(start_location, end_location, Config.CollisionTrace, Config.TraceMode, { player_ped })
	if Config.Debug then print(HELIXTable.Dump(trace_result)) end
	return trace_result, start_location
end

local function drawSprite(entity)
	if not Config.DrawSprite or active_sprites[entity] then return end
	if not entity or not entity:IsValid() then return end
	local coords = entity:GetLocation()
	if not coords then return end
	local sprite = Billboard(coords, '', Vector2D(0.02, 0.02), true)
	sprite:SetMaterialTextureParameter('Texture', 'package://qb-target/Client/html/circle.png')
	active_sprites[entity] = sprite
end

local function enableTarget()
	if not player_ped then return end
	if Input.IsMouseEnabled() then return end
	if target_active then return end
	target_active = true
	my_webui:CallFunction('openTarget')
	local player_coords = player_ped:GetLocation()
	if not player_coords then return end
	for entity, _ in pairs(Entities) do
		if entity and entity:IsValid() then
			local entity_coords = entity:GetLocation()
			local distance = player_coords:Distance(entity_coords)
			if distance <= Config.MaxDistance then
				drawSprite(entity)
			end
		end
	end
	raycast_timer = Timer.SetInterval(function()
		local trace_result, start_location = handleRaycast()
		handleEntity(trace_result, start_location)
	end, 100)
end

local function disableTarget()
	if not target_active then return end
	if target_entity and Config.EnableOutline then
		target_entity:SetOutlineEnabled(false)
	end
	removeSprite()
	target_active, target_entity = false, nil
	nui_data, send_data = {}, {}
	my_webui:CallFunction('closeTarget')
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
	if not Entities[entities] then Entities[entities] = {} end
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
	if not Zones[name] then return end
	Zones[name]:Destroy()
	if Entities[Zones[name]] then Entities[Zones[name]] = nil end
	Zones[name] = nil
end
Package.Export('RemoveZone', RemoveZone)

local function AddGlobalPlayer(parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	SetOptions(Types['ALS_WorldCharacterBP_C'], distance, options)
end
Package.Export('AddGlobalPlayer', AddGlobalPlayer)

-- Events

my_webui:RegisterEventHandler('selectTarget', function(option)
	option = tonumber(option) or option
	Input.SetMouseEnabled(false)
	target_active = false
	if not next(send_data) then return end
	local data = send_data[option]
	if not data then return end
	send_data = {}
	if data.action then
		data.action(data.entity)
	elseif data.event then
		if data.type == 'client' then
			Events.Call(data.event, data)
		elseif data.type == 'server' then
			if data.canInteract then data.canInteract = nil end
			if data.action then data.action = nil end
			local networked_entity = data.entity:IsNetworkDistributed()
			if not networked_entity then data.entity = nil end
			Events.CallRemote(data.event, data)
		elseif data.type == 'command' then
			Events.CallRemote('QBCore:CallCommand', data.event, data)
		else
			Events.Call(data.event, data)
		end
	end
	my_webui:CallFunction('closeTarget')
end)

my_webui:RegisterEventHandler('leftTarget', function()
	target_entity = nil
end)

my_webui:RegisterEventHandler('closeTarget', function()
	disableTarget()
end)

-- Keybinds

Input.Register('Target', Config.OpenKey)
Input.Bind('Target', InputEvent.Pressed, enableTarget)
Input.Bind('Target', InputEvent.Released, disableTarget)

Input.Subscribe('MouseDown', function(key_name)
	if target_active and key_name == Config.MenuControlKey and next(nui_data) then
		enableMouse()
		my_webui:CallFunction('validTarget', { data = nui_data })
	end
end)

-- Setup config options

local function configureType(typeKey, configOption)
	if not Types[typeKey] then Types[typeKey] = {} end
	if not configOption.distance or not configOption.options then return end
	SetOptions(Types[typeKey], configOption.distance, configOption.options)
end

configureType('WorldVehicleWheeled', Config.GlobalWorldVehicleWheeledOptions)
configureType('WorldProp', Config.GlobalWorldPropOptions)
configureType('WorldWeapon', Config.GlobalWorldWeaponOptions)
configureType('WorldStaticMesh', Config.GlobalWorldStaticMeshOptions)
configureType('ALS_WorldCharacterBP_C', Config.ALS_WorldCharacterBP_C)
configureType('WorldVehicleDoorComponent', Config.GlobalWorldVehicleDoorOptions)
