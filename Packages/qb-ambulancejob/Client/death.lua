isDead = false -- Global, used by multiple files
local deathTime = 0
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

HCharacter.Subscribe('Death', function(self)
    local client = Client.GetLocalPlayer()
    if not client then return end
    if client:GetControlledCharacter() == self then
        isDead = true
        BleedAmount = 0
        DeathTimer(true)
        StopBleedTimer()
        StopLimbTimer()
        Events.CallRemote('qb-ambulancejob:server:setDeathStatus', true)
        Events.CallRemote('qb-ambulancejob:server:ambulanceAlert', Lang:t('info.civ_died'))
    end
end)

HCharacter.Subscribe('Respawn', function(self)
    local client = Client.GetLocalPlayer()
    if not client then return end
    if client:GetControlledCharacter() == self then
        isDead = false
        BleedAmount = 0
        DeathTimer(false)
        StopBleedTimer()
        StopLimbTimer()
        Events.CallRemote('qb-ambulancejob:server:syncInjuries', Config.Bones, BleedAmount > 0 and true or false)
        Events.CallRemote('qb-ambulancejob:server:setDeathStatus', false)
    end
end)

Input.Subscribe('KeyDown', function(key_name)
    if isDead and key_name == 'E' and deathTime < 0 then
        hold_time = hold_time - 1
        if hold_time <= 0 then
            --Events.CallRemote('QBCore:Console:CallCommand', 'revive')
            Events.CallRemote('qb-ambulancejob:server:RespawnAtHospital')
            hold_time = 50
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
