local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local inJail = false
local jailTime = 0
local prison_break

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-prison:server:getPeds', function(freedom_ped)
        AddTargetEntity(freedom_ped,
            {
                options = {
                    {
                        type = 'client',
                        event = 'qb-prison:client:freedom',
                        icon = 'fas fa-clipboard',
                        label = Lang:t('info.freedom'),
                        canInteract = function()
                            return inJail
                        end
                    }
                },
                distance = 2.5
            })
    end)
end

-- Event Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        setupPeds()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    setupPeds()
end)

-- Events

Events.SubscribeRemote('qb-prison:client:jailTime', function(time)
    inJail = true
    jailTime = time
    Sound(Vector(), 'package://qb-prison/Client/jail.ogg', true)
    PrisonBreak()
end)

Events.Subscribe('qb-prison:client:jail', function(data)
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local jail_menu = ContextMenu.new()
    jail_menu:addNumber('number-1', Lang:t('info.jail_time_input'), 1, function(val)
        Events.CallRemote('qb-prison:server:jail', data, val)
    end)
    jail_menu:SetHeader('Jail Menu')
    jail_menu:setMenuInfo(Lang:t('info.time_months'), '')
    jail_menu:Open(false, true)
end)

Events.Subscribe('qb-prison:client:freedom', function()
    if jailTime > 0 then
        QBCore.Functions.Notify(Lang:t('info.time_left', { JAILTIME = jailTime }))
        return
    end
    jailTime = 0
    inJail = false
    QBCore.Functions.Notify(Lang:t('success.freedom'))
    Events.CallRemote('qb-prison:server:freedom')
end)

Events.SubscribeRemote('qb-prison:client:unjail', function()
    if not inJail then return end
    jailTime = 0
    inJail = false
    QBCore.Functions.Notify(Lang:t('success.freedom'))
    Events.CallRemote('qb-prison:server:freedom')
end)

-- Timers

local function prisonAlarm()
    QBCore.Functions.Notify(Lang:t('error.escaped'), 'error')
    local prison_alarm = Sound(Config.Locations.middle, 'package://my-package/Client/prison_breakout.ogg', false, false, SoundType.SFX, 1, 1, 400, 25000)
    Events.CallRemote('qb-policejob:server:policeAlert', Lang:t('info.prison_break'))
    Timer.SetTimeout(function()
        prison_alarm:Stop()
    end, 30000)
end

function PrisonBreak()
    prison_break = Timer.SetInterval(function()
        if inJail then
            local player = Client.GetLocalPlayer()
            local player_ped = player:GetControlledCharacter()
            if player_ped then
                local coords = player_ped:GetLocation()
                if coords:Distance(Config.Locations.middle) > 12000 then
                    prisonAlarm()
                    Timer.ClearInterval(prison_break)
                    prison_break = nil
                    inJail = false
                    jailTime = 0
                end
            end
        end
    end, 2000)
end
