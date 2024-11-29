local deathTime = 0
local isDead = false
local death_canvas = nil
local death_timer = nil
local hold_time = 50

local function DeathTimer(bool)
    if bool then
        deathTime = Config.DeathTime
        death_canvas = Canvas(true)
        death_canvas:Subscribe('Update', function(self, width, height)
            if deathTime > 0 then
                self:DrawText(Lang:t('info.respawn_txt', { deathtime = math.ceil(deathTime) }), Vector2D(width / 2, 1000))
            else
                self:DrawText(Lang:t('info.respawn_revive', { holdtime = 5, cost = Config.BillCost }), Vector2D(width / 2, 1000))
            end
        end)
        death_timer = Timer.SetInterval(function()
            deathTime = deathTime - 1
            death_canvas:Repaint()
        end, 2000)
    else
        if death_timer then
            Timer.ClearInterval(death_timer)
            deathTime = 0
        end
        if death_canvas then
            death_canvas:SetVisibility(false)
            death_canvas = nil
        end
    end
end

HCharacter.Subscribe('Death', function()
    isDead = true
    DeathTimer(true)
    Events.CallRemote('hospital:server:SetDeathStatus', true)
    Events.CallRemote('hospital:server:ambulanceAlert', Lang:t('info.civ_died'))
end)

HCharacter.Subscribe('Respawn', function(self)
    isDead = false
    DeathTimer(false)
    Events.CallRemote('hospital:server:SetDeathStatus', false)
end)

Input.Subscribe('KeyDown', function(key_name)
    if isDead and key_name == 'E' and deathTime < 0 then
        hold_time = hold_time - 1
        if hold_time <= 0 then
            --Events.CallRemote('QBCore:Console:CallCommand', 'revive')
            Events.CallRemote('hospital:server:RespawnAtHospital')
            hold_time = 5
            isDead = false
            DeathTimer(false)
        end
    end
end)

Input.Subscribe('KeyUp', function(key_name)
    if isDead and key_name == 'E' and deathTime > 0 then
        hold_time = 50
    end
end)
