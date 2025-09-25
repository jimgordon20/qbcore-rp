Timer.SetInterval(function()
	TriggerServerEvent('QBCore:UpdatePlayer')
end, (1000 * 60) * QBConfig.UpdateInterval)

-- Timer.SetInterval(function()
-- 	if Client.GetValue('isLoggedIn', false) then
-- 		if not QBCore.PlayerData.metadata then return end
-- 		if
-- 			(QBCore.PlayerData.metadata['hunger'] <= 0 or QBCore.PlayerData.metadata['thirst'] <= 0)
-- 			and not (QBCore.PlayerData.metadata['isdead'] or QBCore.PlayerData.metadata['inlaststand'])
-- 		then
-- 			local player = Client.GetLocalPlayer()
-- 			local ped = player:GetControlledCharacter()
-- 			if not ped then return end
-- 			local decreaseThreshold = math.random(5, 10)
-- 			TriggerServerEvent('qb-ambulancejob:server:decreaseHealth', decreaseThreshold)
-- 		end
-- 	end
-- end, QBConfig.StatusInterval)
