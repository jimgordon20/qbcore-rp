-- local lastRadar = nil
-- local HasAlreadyEnteredMarker = false

-- local function IsInMarker(playerPos, speedCam)
--     return playerPos:Distance(Vector(speedCam.x, speedCam.y, speedCam.z)) < 20.0
-- end

-- local function HandleSpeedCam(speedCam, radarID)
--     local player = Client.GetLocalPlayer()
--     local playerPed = player:GetControlledCharacter()
--     if not playerPed then return end
--     local playerPos = playerPed:GetLocation()
--     local isInMarker = IsInMarker(playerPos, speedCam)

--     if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
--         HasAlreadyEnteredMarker = true
--         lastRadar = radarID

--         local vehicle = GetPlayersLastVehicle()
--         if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed and GetVehicleClass(vehicle) ~= 18 then
--             local plate = QBCore.Functions.GetPlate(vehicle)
--             QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(isFlagged)
--                 if isFlagged then
--                     local coords = playerPed:GetLocation()
--                     local blipsettings = {
--                         x = coords.X,
--                         y = coords.Y,
--                         z = coords.Z,
--                         sprite = 488,
--                         color = 1,
--                         scale = 0.9,
--                         text = Lang:t('info.camera_speed', { radarid = radarID })
--                     }
--                     --local street1, street2 = table.unpack(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
--                     Events.CallRemote('police:server:FlaggedPlateTriggered', radarID, plate, street1, street2, blipsettings)
--                 end
--             end, plate)
--         end
--     end

--     if not isInMarker and HasAlreadyEnteredMarker and lastRadar == radarID then
--         HasAlreadyEnteredMarker = false
--         lastRadar = nil
--     end
-- end

-- Timer.SetInterval(function()
--     if IsPedInAnyVehicle(PlayerPedId(), false) then
--         for i = 1, #Config.Radars do
--             local value = Config.Radars[i]
--             HandleSpeedCam(value, i)
--         end
--     end
-- end, 2500)
