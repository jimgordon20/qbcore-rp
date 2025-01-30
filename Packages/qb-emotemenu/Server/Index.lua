local currently_playing = {}

Events.SubscribeRemote('qb-emotemenu:server:playAnimation', function(source, category, animation)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local account_id = source:GetAccountID()
    local available_emotes = Config.Emotes[category]
    local emote = available_emotes[animation]
    if not emote then return end
    local currently_playing_animation = currently_playing[account_id]
    if currently_playing_animation then
        if currently_playing_animation == animation then
            local current_emote = available_emotes[currently_playing_animation]
            local current_animation_path = current_emote.animation_path
            ped:StopAnimation(current_animation_path)
            currently_playing[account_id] = nil
            return
        else
            local current_emote = available_emotes[currently_playing_animation]
            local current_animation_path = current_emote.animation_path
            ped:StopAnimation(current_animation_path)
        end
    end
    local animation_path = emote.animation_path
    local slot_type = emote.slot_type
    local loop_indefinitely = emote.loop
    ped:PlayAnimation(animation_path, slot_type, loop_indefinitely)
    currently_playing[account_id] = animation
end)

Events.SubscribeRemote('qb-emotemenu:server:stopAnimation', function(source)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local account_id = source:GetAccountID()
    if not currently_playing[account_id] then return end
    local animation = currently_playing[account_id]
    local available_emotes = Config.Emotes
    local emote = available_emotes[animation]
    if not emote then return end
    local animation_path = emote.animation_path
    ped:StopAnimation(animation_path)
    currently_playing[account_id] = nil
end)
