local function createFlashlight(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local ped_location = ped:GetLocation()
    local flashlight = Prop(ped_location, Rotator(90, 0, 0), 'nanos-world::SM_Flashlight', CollisionType.Auto)
    flashlight:AttachTo(ped, AttachmentRule.KeepWorld, 'middle_02_r', 0)
    ped:SetValue('holding_flashlight', true, true)
    ped:SetValue('flashlight', flashlight, true)
    local light = Light(Vector(), Rotator(), Color(0, 0, 0), 1, 10, 1000, 35)
    light:AttachTo(flashlight)
    light:SetRelativeLocation(Vector(100, 0, 0))
    flashlight:SetValue('light', light, true)
end

Events.SubscribeRemote('qb-weapons:client:toggleFlashlight', function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local flashlight = ped:GetValue('flashlight')
    if not flashlight then return end
    local light = flashlight:GetValue('light')
    if not light then return end
    local light_active = light:GetValue('light_active', false)
    if light_active then
        light:SetColor(Color(0, 0, 0))
        light:SetValue('light_active', false, true)
    else
        light:SetColor(Color(0.73, 0.67, 0.42))
        light:SetValue('light_active', true, true)
    end
end)

Events.Subscribe('qb-weapons:server:equipWeapon', function(source, item_data)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local holding_item = ped:GetPicked()
    if holding_item then
        local is_weapon = holding_item:IsA(Weapon)
        if is_weapon then
            local animation = holding_item:GetAnimationCharacterHolster()
            if animation then
                ped:PlayAnimation(animation)
                Timer.SetTimeout(function()
                    holding_item:Destroy()
                end, 500)
            else
                holding_item:Destroy()
            end
            return
        end
    end
    if item_data.name == 'weapon_flashlight' then
        if not ped:GetValue('flashlight') then
            createFlashlight(source)
        else
            local flashlight = ped:GetValue('flashlight')
            local light = flashlight:GetValue('light')
            light:Detach()
            flashlight:Detach()
            light:Destroy()
            flashlight:Destroy()
            ped:SetValue('holding_flashlight', false, true)
        end
        return
    end
    local weapon = QBCore.Functions.CreateWeapon(source, item_data.name, false, false, item_data)
    if not weapon then return end
    ped:PickUp(weapon)
end)

-- AMMO

local ammo_types = {
    pistol_ammo = 30,
    rifle_ammo = 30,
    smg_ammo = 30,
    mg_ammo = 30,
    shotgun_ammo = 10,
    snp_ammo = 10
}

for ammo_item, amount in pairs(ammo_types) do
    QBCore.Functions.CreateUseableItem(ammo_item, function(source, item)
        local ped = source:GetControlledCharacter()
        if not ped then return end

        local holding_item = ped:GetPicked()
        if not holding_item then return end

        local is_weapon = ped:GetPicked():IsA(Weapon)
        if not is_weapon then return end

        local weapon_info = QBShared.Weapons[holding_item:GetValue('name')]
        if not weapon_info then return end
        local weapon_ammo_type = weapon_info.ammo_type
        if weapon_ammo_type ~= item.name then return end

        local current_ammo = holding_item:GetAmmoClip()
        local bag_capacity = holding_item:GetAmmoBag()
        local max_clip = holding_item:GetClipCapacity()
        local ammo_needed = max_clip - current_ammo
        local ammo_available = GetItemCount(source, ammo_item)

        if ammo_available >= ammo_needed then
            holding_item:SetAmmoClip(max_clip)
            RemoveItem(source, item.name, ammo_needed)
            Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item.name], 'remove', ammo_needed)
        else
            holding_item:SetAmmoClip(current_ammo + ammo_available)
            RemoveItem(source, item.name, ammo_available)
            Events.CallRemote('qb-inventory:client:ItemBox', source, QBShared.Items[item.name], 'remove', ammo_available)
        end
    end)
end

HCharacter.Subscribe('AttemptReload', function(self, weapon)
    local player = self:GetPlayer()
    local weapon_info = QBShared.Weapons[weapon:GetValue('name')]
    if not weapon_info then return end
    local ammo_type = weapon:GetValue('ammo_type')
    if not ammo_type then return end
    local current_ammo = weapon:GetAmmoClip()
    local max_clip = weapon:GetClipCapacity()
    local ammo_available = GetItemCount(player, ammo_type)
    if ammo_available == 0 then return false end
    local ammo_needed = max_clip - current_ammo
    if ammo_available >= ammo_needed then
        weapon:SetAmmoClip(max_clip)
        RemoveItem(player, ammo_type, ammo_needed)
        Events.CallRemote('qb-inventory:client:ItemBox', player, QBShared.Items[ammo_type], 'remove', ammo_needed)
    else
        weapon:SetAmmoClip(current_ammo + ammo_available)
        RemoveItem(player, ammo_type, ammo_available)
        Events.CallRemote('qb-inventory:client:ItemBox', player, QBShared.Items[ammo_type], 'remove', ammo_available)
    end
end)
