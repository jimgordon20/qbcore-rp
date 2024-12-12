Timer.SetInterval(function()
	if Client.GetValue('isLoggedIn', false) then
		Events.CallRemote('QBCore:UpdatePlayer')
	end
end, (1000 * 60) * QBConfig.UpdateInterval)

Timer.SetInterval(function()
	if Client.GetValue('isLoggedIn', false) then
		if not QBCore.PlayerData.metadata then
			return
		end
		if
			(QBCore.PlayerData.metadata['hunger'] <= 0 or QBCore.PlayerData.metadata['thirst'] <= 0)
			and not (QBCore.PlayerData.metadata['isdead'] or QBCore.PlayerData.metadata['inlaststand'])
		then
			local player = Client.GetLocalPlayer()
			local ped = player:GetControlledCharacter()
			if not ped then
				return
			end
			local currentHealth = ped:GetHealth()
			local decreaseThreshold = math.random(5, 10)
			ped:SetHealth(currentHealth - decreaseThreshold)
		end
	end
end, QBConfig.StatusInterval)
