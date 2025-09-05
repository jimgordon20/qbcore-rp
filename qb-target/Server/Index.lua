Events.SubscribeRemote('qb-target:server:pickupWeapon', function(source, entity)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	ped:PickUp(entity)
end)

Events.SubscribeRemote('qb-target:server:pickupProp', function(source, entity)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	ped:GrabProp(entity)
end)

Events.SubscribeRemote('qb-target:server:startEngine', function(source, entity)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	entity:SetEngineStarted(true)
end)

Events.SubscribeRemote('qb-target:server:wave', function(source)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	ped:PlayAnimation('nanos-world::A_Mannequin_Taunt_Wave', AnimationSlotType.UpperBody)
end)

Events.SubscribeRemote('qb-target:server:enterVehicle', function(source, entity)
	local ped = source:GetControlledCharacter()
	if not ped then return end
	entity:EnterVehicle(entity)
end)
