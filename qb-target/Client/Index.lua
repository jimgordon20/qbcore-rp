local player_data = {}
local isLoggedIn = false
local player_ped
local target_active, target_entity, raycast_timer, my_webui = false, nil, nil, nil
local nui_data, send_data, Entities, Types, Zones = {}, {}, {}, {}, {}

-- Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	player_data = exports['qb-core']:GetPlayerData()
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
	player_data = {}
	isLoggedIn = false
end)

RegisterClientEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
	player_data.job = JobInfo
end)

RegisterClientEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
	player_data.gang = GangInfo
end)

RegisterClientEvent('QBCore:Player:SetPlayerData', function(val)
	player_data = val
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
	return exports['qb-inventory']:HasItem(item)
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

local function setupHandlers()
	my_webui:RegisterEventHandler('selectTarget', function(option)
		option = tonumber(option) or option
		target_active = false
		if not next(send_data) then return end
		local data = send_data[option]
		if not data then return end
		send_data = {}
		if data.action then
			data.action(data.entity)
		elseif data.event then
			if data.type == 'client' then
				TriggerLocalClientEvent(data.event, data)
			elseif data.type == 'server' then
				if data.canInteract then data.canInteract = nil end
				if data.action then data.action = nil end
				local networked_entity = data.entity.bReplicates
				if not networked_entity then data.entity = nil end
				TriggerServerEvent(data.event, data)
			elseif data.type == 'command' then
				TriggerServerEvent('QBCore:CallCommand', data.event, data)
			else
				TriggerLocalClientEvent(data.event, data)
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
end

-- Exports

local function AddTargetEntity(entity, parameters)
	if not entity or not parameters then return end
	if type(parameters) ~= 'table' then return end
	if not parameters.options or type(parameters.options) ~= 'table' then return end
	local distance = parameters.distance or Config.MaxDistance
	local options  = parameters.options
	if not options or #options == 0 then return end
	if not Entities[entity] then Entities[entity] = {} end
	SetOptions(Entities[entity], distance, options)
end
exports('qb-target', 'AddTargetEntity', AddTargetEntity)

local function RemoveTargetEntity(entity)
	if not entity then return end
	Entities[entity] = nil
end
exports('qb-target', 'RemoveTargetEntity', RemoveTargetEntity)

local function RemoveZone(name)
	local actor = Zones[name]
	if not actor then return end
	if Entities[actor] then Entities[actor] = nil end
	actor:Destroy()
	Zones[name] = nil
end
exports('qb-target', 'RemoveZone', RemoveZone)

local function AddBoxZone(name, center, length, width, zoneOptions, targetoptions)
	if not name or not center or not length or not width or not zoneOptions or not targetoptions then return end
	if Zones[name] then return end
	if not Zones[name] then Zones[name] = {} end

	-- Spawn Box
	local yaw_degrees = zoneOptions.heading or zoneOptions.yaw or 0.0
	local minZ, maxZ = zoneOptions.minZ, zoneOptions.maxZ
	local height = (minZ and maxZ) and math.abs(maxZ - minZ) or (zoneOptions.height or zoneOptions.fullHeight or 200.0)
	local spawnCenter = UE.FVector(center.X, center.Y, center.Z)
	if minZ and maxZ then spawnCenter.Z = (minZ + maxZ) * 0.5 end
	local xform       = UE.FTransform()
	xform.Translation = spawnCenter
	xform.Rotation    = UE.FQuat(0, 0, math.sin(math.rad(yaw_degrees) * 0.5), math.cos(math.rad(yaw_degrees) * 0.5))
	local actor       = HWorld:SpawnActor(UE.AActor, xform, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
	if not actor then return nil end
	local box = actor:AddComponentByClass(UE.UBoxComponent, false, xform, false)
	if not box then return nil end
	local full = UE.FVector(length, width, height)
	local half = UE.FVector(full.X * 0.5, full.Y * 0.5, full.Z * 0.5)
	box:SetBoxExtent(half, true)
	local debug = (zoneOptions.debug ~= nil) and zoneOptions.debug or false
	box:SetHiddenInGame(not debug, true)
	box:SetVisibility(debug, true)
	box:SetCastShadow(false)
	box:SetMobility(UE.EComponentMobility.Stationary)
	box:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
	box:SetCollisionObjectType(UE.ECollisionChannel.ECC_WorldDynamic)
	box:SetGenerateOverlapEvents(false)
	box:SetCollisionResponseToAllChannels(UE.ECollisionResponse.ECR_Ignore)
	box:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Visibility, UE.ECollisionResponse.ECR_Block)

	Zones[name] = actor
	AddTargetEntity(actor, {
		distance = zoneOptions.distance or Config.MaxDistance,
		options  = targetoptions
	})
end
exports('qb-target', 'AddBoxZone', AddBoxZone)

local function AddSphereZone(name, center, radius, zoneOptions, targetoptions)
	if not name or not center or not radius or not zoneOptions or not targetoptions then return end
	if Zones[name] then return end
	if not Zones[name] then Zones[name] = {} end

	-- Spawn Sphere
	local spawnCenter = UE.FVector(center.X, center.Y, center.Z)
	local xform       = UE.FTransform()
	xform.Translation = spawnCenter
	xform.Rotation    = UE.FQuat(0, 0, 0, 1)
	local actor       = HWorld:SpawnActor(UE.AActor, xform, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
	if not actor then return nil end
	local sphere = actor:AddComponentByClass(UE.USphereComponent, false, xform, false)
	if not sphere then return nil end
	sphere:SetSphereRadius(radius, true)
	local debug = (zoneOptions.debug ~= nil) and zoneOptions.debug or false
	sphere:SetHiddenInGame(not debug, true)
	sphere:SetVisibility(debug, true)
	sphere:SetCastShadow(false)
	sphere:SetMobility(UE.EComponentMobility.Stationary)
	sphere:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
	sphere:SetCollisionObjectType(UE.ECollisionChannel.ECC_WorldDynamic)
	sphere:SetGenerateOverlapEvents(false)
	sphere:SetCollisionResponseToAllChannels(UE.ECollisionResponse.ECR_Ignore)
	sphere:SetCollisionResponseToChannel(UE.ECollisionChannel.ECC_Visibility, UE.ECollisionResponse.ECR_Block)

	Zones[name] = actor
	AddTargetEntity(actor, {
		distance = zoneOptions.distance or Config.MaxDistance,
		options  = targetoptions
	})
end
exports('qb-target', 'AddSphereZone', AddSphereZone)

-- Casting

local function clearTarget()
	if not target_entity then return end
	target_entity = nil
	nui_data = {}
	if my_webui then
		my_webui:CallFunction('leftTarget')
	end
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
			local index = #nui_data + 1
			nui_data[index] = new_option
			send_data[index] = data
			send_data[index].entity = entity
			local target_icon = nui_data[1] and nui_data[1].targeticon or ''
			if my_webui then
				my_webui:CallFunction('foundTarget', { data = target_icon, options = nui_data })
			end
		end
	end
end

local function handleEntity(trace_result)
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
		nui_data = {}
		local distance = trace_result.Distance
		local entity_options = Entities[target_entity]
		local type_options = Types[tostring(trace_result.ActorName)]
		if entity_options then setupOptions(entity_options, target_entity, distance) end
		if type_options then setupOptions(type_options, target_entity, distance) end
	end
end

local function handleRaycast()
	if not target_active then return end
	if not HPlayer then return end
	local w, h     = HPlayer:GetViewportSize()
	local sp       = UE.FVector2D(w * 0.5, h * 0.5)
	local pos, dir = UE.FVector(), UE.FVector()
	if not UE.UGameplayStatics.DeprojectScreenToWorld(HPlayer, sp, pos, dir) then return end
	local start        = pos + dir * 25.0
	local stop         = start + dir * Config.MaxDistance
	local hit          = Trace:LineSingle(start, stop, UE.ETraceTypeQuery.Visibility, UE.EDrawDebugTrace.None)
	local trace_result = nil
	if hit then
		local _, _, _, distance, location, _, _, _, _, hitActor, hitComp = UE.UGameplayStatics.BreakHitResult(hit)
		local actor = hitActor
		if not actor and hitComp then
			actor = hitComp:GetOwner()
		end
		if actor then
			trace_result = {}
			trace_result.Entity = hitActor
			trace_result.ComponentName = hitComp
			trace_result.Location = location
			trace_result.Distance = distance
			trace_result.Success = true
			trace_result.ActorName = hitActor:GetName()
		end
	end
	return trace_result
end

function enableTarget()
	if target_active then return end
	target_active = true
	my_webui = WebUI('Target', 'qb-target/Client/html/index.html', false)
	my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
		setupHandlers()
		my_webui:CallFunction('openTarget')
		raycast_timer = Timer.SetInterval(function()
			local trace_result = handleRaycast()
			handleEntity(trace_result)
		end, 100)
	end)
end

function disableTarget()
	if not target_active then return end
	target_active, target_entity = false, nil
	nui_data, send_data = {}, {}
	if my_webui then
		my_webui:CallFunction('closeTarget')
		my_webui:Destroy()
		my_webui = nil
	end
	if raycast_timer then
		Timer.ClearInterval(raycast_timer)
		raycast_timer = nil
	end
end

-- Inputs

Timer.CreateThread(function()
	while true do
		if not HPlayer then return end
		do
			local key = UE.FKey()
			key.KeyName = Config.OpenKey
			if HPlayer:WasInputKeyJustPressed(key) then
				if HPlayer:GetInputMode() ~= 1 then
					enableTarget()
				end
			end
			if HPlayer:WasInputKeyJustReleased(key) then
				if target_active then
					disableTarget()
				end
			end
		end

		do
			local menuControl = UE.FKey()
			menuControl.KeyName = Config.MenuControlKey
			if target_active and target_entity and nui_data and nui_data[1] then
				if HPlayer:WasInputKeyJustPressed(menuControl) then
					print('Menu control pressed')
					my_webui:SetConsumeInput(true)
				end
			end
		end
		Timer.Wait(1)
	end
end)

-- Setup config options

-- local function configureType(typeKey, configOption)
-- 	if not Types[typeKey] then Types[typeKey] = {} end
-- 	if not configOption.distance or not configOption.options then return end
-- 	SetOptions(Types[typeKey], configOption.distance, configOption.options)
-- end

-- configureType('WorldVehicleWheeled', Config.GlobalWorldVehicleWheeledOptions)
-- configureType('WorldProp', Config.GlobalWorldPropOptions)
-- configureType('WorldWeapon', Config.GlobalWorldWeaponOptions)
-- configureType('WorldStaticMesh', Config.GlobalWorldStaticMeshOptions)
-- configureType('ALS_WorldCharacterBP_C', Config.ALS_WorldCharacterBP_C)
-- configureType('WorldVehicleDoorComponent', Config.GlobalWorldVehicleDoorOptions)

-- Timer.SetTimeout(function()
-- 	-- Test Box Zone 1 - Simple interaction
-- 	AddBoxZone('test_box_1', {
-- 		X = -249.54, -- Adjust these coordinates to where your player spawns
-- 		Y = 1358.93, -- or a location you can easily reach
-- 		Z = 91.697
-- 	}, 5.0, 5.0, {
-- 		heading = 0,
-- 		minZ = -2.0,
-- 		maxZ = 3.0,
-- 		debug = true -- This will show the box visually
-- 	}, {
-- 		{
-- 			icon = 'fas fa-hand',
-- 			label = 'Test Interaction',
-- 			action = function()
-- 				print('Test zone 1 clicked!')
-- 			end
-- 		}
-- 	})

-- 	-- Example sphere zone
-- 	AddSphereZone('test_sphere_1', {
-- 		X = -249.54,
-- 		Y = 1358.93,
-- 		Z = 91.697
-- 	}, 3.0, { -- radius of 3.0 units
-- 		debug = true,
-- 		distance = 5.0
-- 	}, {
-- 		{
-- 			icon = 'fas fa-hand',
-- 			label = 'Sphere Test Interaction',
-- 			action = function()
-- 				print('Sphere zone clicked!')
-- 			end
-- 		}
-- 	})
-- end, 2000)
