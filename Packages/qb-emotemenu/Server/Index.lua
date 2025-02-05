local currently_playing = {}
local flattened_emotes = {}

local function flattenEmotes()
    for category, emotes in pairs(Config.Emotes) do
        for animation, data in pairs(emotes) do
            flattened_emotes[category .. ':' .. animation] = data
        end
    end
end
flattenEmotes()

Events.SubscribeRemote('qb-emotemenu:server:playAnimation', function(source, category, animation)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local account_id = source:GetAccountID()

    local emote_key = category .. ':' .. animation
    local emote = flattened_emotes[emote_key]
    if not emote then return end

    if currently_playing[account_id] == emote_key then
        ped:StopAnimation(emote.animation_path)
        currently_playing[account_id] = nil
        return
    end

    local currently_playing_key = currently_playing[account_id]
    if currently_playing_key then
        local current_emote = flattened_emotes[currently_playing_key]
        if current_emote then
            ped:StopAnimation(current_emote.animation_path)
        end
    end

    ped:PlayAnimation(
        emote.animation_path,
        emote.slot_type or AnimationSlotType.FullBody,
        emote.loop or false,
        0.5, -- blend_in_time
        0.5, -- blend_out_time
        1.0  -- play_rate
    )
    currently_playing[account_id] = emote_key
end)

Events.SubscribeRemote('qb-emotemenu:server:spawnWeapon', function(source) -- for gameplay vid
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local coords = ped:GetLocation()
    local rotation = ped:GetRotation()
    local itemInfo = {
        info = {
            ammo = 1000
        }
    }
    local weapon = QBCore.Functions.CreateWeapon(source, 'weapon_mk4', coords, rotation, itemInfo)
    if not weapon then return end
    ped:PickUp(weapon)
end)