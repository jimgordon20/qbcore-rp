local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

local function openAdmin()
	local admin_menu = ContextMenu.new()

	-- Admin Options
	local adminOptions = {}
	for i = 1, #Config.adminOptions do
		adminOptions[i] = {
			id = i,
			label = Config.adminOptions[i].name,
			command = Config.adminOptions[i].command
		}
	end

	admin_menu:addListPicker('admin-options', 'Admin Options', adminOptions, function(id)
		local selectedItem = Config.adminOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', selectedItem.command)
	end)

	-- Dev Options
	local devOptions = {}
	for i = 1, #Config.devOptions do
		devOptions[i] = {
			id = i,
			label = Config.devOptions[i].name,
			command = Config.devOptions[i].command
		}
	end

	admin_menu:addListPicker('dev-options', 'Developer Options', devOptions, function(id)
		local selectedItem = Config.devOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', selectedItem.command)
	end)

	-- Weapon Spawn
	local weapons = QBShared.Weapons
	local availableWeapons = {}
	for weapon_name in pairs(weapons) do
		availableWeapons[#availableWeapons + 1] = {
			id = weapon_name,
			label = weapon_name
		}
	end

	admin_menu:addListPicker('spawn-weapon', 'Spawn Weapon: ', availableWeapons, function(id)
		Events.CallRemote('QBCore:Console:CallCommand', 'weapon', id)
	end)

	-- Weapon Options
	local weaponOptions = {}
	for i = 1, #Config.weaponOptions do
		weaponOptions[i] = {
			id = i,
			label = Config.weaponOptions[i].name,
			command = Config.weaponOptions[i].command
		}
	end

	admin_menu:addListPicker('weapon-options', 'Weapon Options', weaponOptions, function(id)
		local selectedItem = Config.weaponOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', selectedItem.command)
	end)

	-- Vehicle Spawn
	local vehicles = QBShared.Vehicles
	local availableVehicles = {}
	for vehicle_name in pairs(vehicles) do
		availableVehicles[#availableVehicles + 1] = {
			id = vehicle_name,
			label = vehicle_name
		}
	end

	admin_menu:addListPicker('spawn-vehicle', 'Spawn Vehicle: ', availableVehicles, function(id)
		Events.CallRemote('QBCore:Console:CallCommand', 'car', id)
	end)

	-- Vehicle Options
	local vehicleOptions = {}
	for i = 1, #Config.vehicleOptions do
		vehicleOptions[i] = {
			id = i,
			label = Config.vehicleOptions[i].name,
			command = Config.vehicleOptions[i].command
		}
	end

	admin_menu:addListPicker('vehicle-options', 'Vehicle Options', vehicleOptions, function(id)
		local selectedItem = Config.vehicleOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', selectedItem.command)
	end)

	-- Time Options

	local timeOptions = {}
	for i = 1, 24 do
		timeOptions[i] = {
			id = i,
			label = string.format('%02d:00', i),
		}
	end

	admin_menu:addListPicker('time-options', 'Time Options', timeOptions, function(id)
		local selectedItem = timeOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', 'time', tostring(selectedItem.id))
	end)

	-- Weather Options
	local weatherOptions = {}
	for i = 1, #Config.weatherOptions do
		weatherOptions[i] = {
			id = i,
			label = Config.weatherOptions[i].name,
			command = Config.weatherOptions[i].command
		}
	end

	admin_menu:addListPicker('weather-options', 'Weather Options', weatherOptions, function(id)
		local selectedItem = Config.weatherOptions[id]
		Events.CallRemote('QBCore:Console:CallCommand', selectedItem.command, selectedItem.name)
	end)

	admin_menu:SetHeader('Admin Menu', '')
	admin_menu:Open(false, false)
end

Input.Register('AdminMenu', 'F9')
Input.Bind('AdminMenu', InputEvent.Pressed, function()
	openAdmin()
end)

-- Callback

QBCore.Functions.CreateClientCallback('qb-adminmenu:client:getCamera', function(cb)
	local player = Client.GetLocalPlayer()
	local coords = player:GetCameraLocation()
	local rotation = player:GetCameraRotation()
	cb(coords, rotation)
end)

-- Show Coords

local showing_coords = false
local my_timer = nil
local coords_canvas = nil
Events.SubscribeRemote('qb-adminmenu:client:showCoords', function()
	if not showing_coords then
		showing_coords = true
		coords_canvas = Canvas(true, Color.TRANSPARENT, 0, true)
		coords_canvas:SetVisibility(true)
		coords_canvas:Subscribe('Update', function(self, width, height)
			local pos, rot
			local player = Client.GetLocalPlayer()
			local player_ped = player:GetControlledCharacter()
			if player_ped then
				pos = player_ped:GetLocation()
				rot = player_ped:GetRotation()
			else
				pos = player:GetCameraLocation()
				rot = player:GetCameraRotation()
			end
			local coords = 'Vector('
				.. string.format('%.2f', pos.X)
				.. ', '
				.. string.format('%.2f', pos.Y)
				.. ', '
				.. string.format('%.2f', pos.Z)
				.. ')\nRotator('
				.. string.format('%.2f', rot.Pitch)
				.. ', '
				.. string.format('%.2f', rot.Yaw)
				.. ', '
				.. string.format('%.2f', rot.Roll)
				.. ')'
			self:DrawText(coords, Vector2D(width * 0.40, height * 0.9), FontType.OpenSans, 24)
		end)
		my_timer = Timer.SetInterval(function()
			coords_canvas:Repaint()
		end, 100)
	else
		showing_coords = false
		if coords_canvas then
			coords_canvas:SetVisibility(false)
			coords_canvas = nil
		end
		if my_timer then
			Timer.ClearInterval(my_timer)
			my_timer = nil
		end
	end
end)

-- Laser

local laser_active = false
local laser_timer = nil
local laser_canvas = nil
local last_entity = nil
Events.SubscribeRemote('qb-adminmenu:client:entitylaser', function()
	if not laser_active then
		laser_active = true
		laser_canvas = Canvas(true, Color.TRANSPARENT, 0, true)
		laser_canvas:SetVisibility(true)
		laser_canvas:Subscribe('Update', function(self, width, height)
			local viewport_2d_center = Viewport.GetViewportSize() / 2
			local viewport_3d = Viewport.DeprojectScreenToWorld(viewport_2d_center)
			local trace_max_distance = 1000
			local start_location = viewport_3d.Position
			local end_location = viewport_3d.Position + viewport_3d.Direction * trace_max_distance
			local collision_trace = CollisionChannel.WorldStatic
				| CollisionChannel.WorldDynamic
				| CollisionChannel.Pawn
				| CollisionChannel.PhysicsBody
				| CollisionChannel.Mesh
				| CollisionChannel.Water
				| CollisionChannel.Foliage
				| CollisionChannel.Vehicle
			local trace_mode = TraceMode.TraceComplex
				| TraceMode.ReturnPhysicalMaterial
				| TraceMode.ReturnEntity
				| TraceMode.ReturnNames
				| TraceMode.ReturnUV
			local trace_result = Trace.LineSingle(
				start_location,
				end_location,
				collision_trace,
				trace_mode,
				{ Client.GetLocalPlayer():GetControlledCharacter() }
			)
			if trace_result.Success and trace_result.Entity then
				if last_entity and last_entity:IsValid() then
					last_entity:SetOutlineEnabled(false)
				end
				last_entity = trace_result.Entity
				last_entity:SetOutlineEnabled(true, 0)
				local entity_info = 'Entity: '
					.. tostring(trace_result.Entity)
					.. '\nLocation: '
					.. tostring(trace_result.Location)
					.. '\nActor Name: '
					.. tostring(trace_result.ActorName)
					.. '\nComponent Name: '
					.. tostring(trace_result.ComponentName)
					.. '\nBone Name: '
					.. tostring(trace_result.BoneName)
					.. '\nNormal: '
					.. tostring(trace_result.Normal)
					.. '\nSurface Type: '
					.. tostring(trace_result.SurfaceType)
					.. '\nUV: '
					.. tostring(trace_result.UV)
				self:DrawBox(Vector2D(width * 0.3, height * 0.75), Vector2D(1000, 150), 150.0, Color.BLACK)
				self:DrawText(entity_info, Vector2D(width * 0.3, height * 0.7), FontType.OpenSans, 20)
			end
		end)
		laser_timer = Timer.SetInterval(function()
			if laser_canvas then
				laser_canvas:Repaint()
			end
		end, 100)
	else
		laser_active = false
		if laser_canvas then
			laser_canvas:SetVisibility(false)
			laser_canvas = nil
		end
		if laser_timer then
			Timer.ClearInterval(laser_timer)
			laser_timer = nil
		end
	end
end)

-- Names

local showing_names = false
function AddNametag(player, character)
	if not character then
		character = player:GetControlledCharacter()
	end
	if not character then
		return
	end
	local text = '(' .. player:GetID() .. ') ' .. player:GetName()
	local nametag = TextRender(
		Vector(),
		Rotator(),
		text,
		Vector(0.2, 0.2, 0.2),
		Color(1, 1, 1),
		FontType.Roboto,
		TextRenderAlignCamera.Unaligned
	)
	nametag:AttachTo(character)
	nametag:SetRelativeLocation(Vector(0, -30, 100))
	player:SetValue('Nametag', nametag)
end

function RemoveNametag(player, character)
	if not character then
		character = player:GetControlledCharacter()
	end
	if not character then
		return
	end
	local text_render = player:GetValue('Nametag')
	if text_render and text_render:IsValid() then
		text_render:Destroy()
	end
end

Events.SubscribeRemote('qb-adminmenu:client:showNames', function()
	showing_names = not showing_names
	for _, player in ipairs(Player.GetAll()) do
		local character = player:GetControlledCharacter()
		if character then
			if showing_names then
				AddNametag(player, character)
			else
				RemoveNametag(player, character)
			end
		end
	end
end)
