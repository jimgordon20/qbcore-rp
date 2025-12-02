--[[ local current_camera = 0
local viewing_camera = false
local current_location

-- Handler

local blocked_keys = {
    ['W'] = true,
    ['A'] = true,
    ['S'] = true,
    ['D'] = true,
    ['SpaceBar'] = true,
    ['LeftControl'] = true
}
Input.Subscribe('KeyPress', function(key_name)
    if viewing_camera and blocked_keys[key_name] then
        return false
    end
end)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'Left' and viewing_camera and current_camera ~= 0 then
        if current_camera == 1 then return end
        current_camera = current_camera - 1
        local camera_info = Config.SecurityCameras.cameras[current_camera]
        if not camera_info then return end
        local player = Client.GetLocalPlayer()
        player:SetCameraLocation(camera_info.coords)
        player:SetCameraRotation(camera_info.rotation)
    end
end)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'Right' and viewing_camera and current_camera ~= 0 then
        current_camera = current_camera + 1
        local camera_info = Config.SecurityCameras.cameras[current_camera]
        local player = Client.GetLocalPlayer()
        if not camera_info then
            player:SetCameraLocation(Config.SecurityCameras.cameras[1].coords)
            player:SetCameraRotation(Config.SecurityCameras.cameras[1].rotation)
            current_camera = 1
        else
            player:SetCameraLocation(camera_info.coords)
            player:SetCameraRotation(camera_info.rotation)
        end
    end
end)

Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'BackSpace' and viewing_camera then
        current_camera = 0
        viewing_camera = false
        Events.CallRemote('qb-policejob:server:leaveCamera', current_location)
        current_location = nil
    end
end)

-- Events

Events.SubscribeRemote('qb-policejob:client:viewCamera', function(camera_id)
    current_camera = camera_id
    viewing_camera = true
    local camera_info = Config.SecurityCameras.cameras[camera_id]
    local player = Client.GetLocalPlayer()
    current_location = player:GetCameraLocation()
    player:SetCameraLocation(camera_info.coords)
    player:SetCameraRotation(camera_info.rotation)
end)
 ]]