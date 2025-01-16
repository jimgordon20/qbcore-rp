BleedAmount = 0
local prevPos = nil
local onPainKillers = false
local painkillerAmount = 0
local bleedTickTimer = 0
local fadeOutTimer = 0
local blackoutTimer = 0
local advanceBleedTimer = 0

-- Functions

local function DoBleedAlert()
    if not isDead and tonumber(BleedAmount) > 0 then
        QBCore.Functions.Notify(Lang:t('info.bleed_alert', { bleedstate = Config.BleedingStates[tonumber(BleedAmount)].label }), 'error', 5000)
    end
end

local function RemoveBleed(level)
    if BleedAmount ~= 0 then
        if BleedAmount - level < 0 then
            BleedAmount = 0
        else
            BleedAmount = BleedAmount - level
        end
        DoBleedAlert()

        if BleedAmount == 0 then StopBleedTimer() end
    end
end

local function ApplyBleed(level)
    if BleedAmount ~= 4 then
        if BleedAmount + level > 4 then
            BleedAmount = 4
        else
            BleedAmount = BleedAmount + level
        end
        StartBleedTimer()
        DoBleedAlert()
    end
end

local function PainKillerLoop(pkAmount)
    if not onPainKillers then
        if pkAmount then
            painkillerAmount = pkAmount
        end
        onPainKillers = true
        while onPainKillers do
            Wait(1)
            painkillerAmount = painkillerAmount - 1
            Wait(Config.PainkillerInterval * 1000)
            if painkillerAmount <= 0 then
                painkillerAmount = 0
                onPainKillers = false
            end
        end
    end
end

local function DoLimbAlert()
    if isDead then return end
    local damagedLimbs = {}
    -- Gather damaged limbs
    for _, v in pairs(Config.Bones) do
        if v.isDamaged then damagedLimbs[#damagedLimbs + 1] = v end
    end

    if #damagedLimbs == 0 then return end

    local damageMessage = ''
    if #damagedLimbs <= Config.AlertShowInfo then
        for k, v in pairs(damagedLimbs) do
            damageMessage = Lang:t('info.pain_message', { limb = v.label, severity = Config.WoundStates[v.severity] })
            if k < #damagedLimbs then damageMessage = damageMessage .. ' | ' end
        end
    else
        damageMessage = Lang:t('info.many_places')
    end

    QBCore.Functions.Notify(damageMessage, 'primary')
end

-- Handler

HCharacter.Subscribe('TakeDamage', function(self, damage, bone, type, from_direction, instigator, causer)
    local player = Client.GetLocalPlayer()
    local ped = player:GetControlledCharacter()
    if ped ~= self then return end
    if isDead then return end

    -- TODO: Handle other forms of damage (vehicle, etc)
    local weapon = causer:IsA(Weapon)
    if not weapon then return end -- Punch or other damage? Doesn't need to decrease armor or stagger player

    local playerArmor = QBCore.Functions.GetPlayerData().metadata.armor
    if playerArmor > 0 and not Config.Bones[bone].armored then
        -- Hit armor, decrease armor
        return Events.CallRemote('qb-ambulancejob:server:damageArmor')
    end
    
    -- Bleed & Stagger. Bleed based on weapon damage
    local severity = damage <= Config.MinorInjury and 1 or 2
    local staggerChance = severity == 2 and (Config.Bones[bone].major or 0) or (Config.Bones[bone].minor or 0) -- or no chance of stagger
    if math.random(1, 100) <= staggerChance then -- If major damage weapon, use major stagger chance
        Events.CallRemote('qb-ambulancejob:server:damageRagdoll', 500)
    end

    Config.Bones[bone].isDamaged = true 
    Config.Bones[bone].severity = math.random(1, 4)
    Events.CallRemote('qb-ambulancejob:server:syncInjuries', Config.Bones, BleedAmount > 0 and true or false)

    StartLimbTimer()
    ApplyBleed(severity)
end)

-- Events

Events.SubscribeRemote('qb-ambulancejob:client:useIfaks', function()
    if painkillerAmount < 3 then painkillerAmount = painkillerAmount + 1 end
    PainKillerLoop()
    if math.random(1, 100) < 50 then RemoveBleed(1) end
end)

Events.SubscribeRemote('qb-ambulancejob:client:useBandage', function()
    if math.random(1, 100) < 50 then RemoveBleed(1) end
    if math.random(1, 100) < 7 then ResetPartial() end
end)

Events.SubscribeRemote('qb-ambulancejob:client:usePainkillers', function()
    if painkillerAmount < 3 then painkillerAmount = painkillerAmount + 1 end
    PainKillerLoop()
end)

Events.SubscribeRemote('qb-ambulancejob:client:stopBleed', function()
    if BleedAmount <= 0 then return end
    RemoveBleed(BleedAmount)
end)

-- Bleeding Tick Logic

Player.Subscribe('Possess', function(self, character)
    local Player = Client.GetLocalPlayer()
    if self ~= Player then return end

    PlayerPed = character
end)

function StartBleedTimer()
    if BleedTick then return end
    BleedTick = Timer.SetInterval(function()
        if not PlayerPed then return end -- No ped, nothing to bleed yet, but continue to run interval
        if BleedAmount > 0 then
            prevPos = prevPos or PlayerPed:GetLocation()
            if prevPos:Distance(PlayerPed:GetLocation()) < 200 then return end
            prevPos = PlayerPed:GetLocation() -- Update location if they've moved
            -- Begin fading/blacking out timer
            if not isDead then
                fadeOutTimer = fadeOutTimer + 1
                if fadeOutTimer == Config.FadeOutTimer then -- Every 30 seconds, check if fade out, increase blackoutTimer
                    local Player = Client.GetLocalPlayer() -- Could cache it if it's intensive
                    if blackoutTimer + 1 >= Config.BlackoutTimer and not onPainKillers then
                        -- Black out (ragdoll) after 10 ticks (could be 5 ticks if severe)
                        Events.CallRemote('qb-ambulancejob:server:damageRagdoll', 1500)
                    else
                        blackoutTimer = blackoutTimer + (BleedAmount > 3 and 2 or 1) -- Severe bleeding, increase blackoutTimer by 2
                        
                        Player:StartCameraFade(0.0, 0.8, 5.0, Color(0.0, 0.0, 0.0, 1.0), true, false)
                        -- Damage player for bleeding
                        local bleedDamage = BleedAmount * Config.BleedTickDamage
                        Events.CallRemote('qb-ambulancejob:server:setHealth', nil, bleedDamage)
                    end
                    fadeOutTimer = 0
                end
            end
        end
    end, 1000)
end

function StopBleedTimer()
    if not BleedTick then return end
    Timer.ClearInterval(BleedTick)
    BleedTick = nil
end

-- Limb Damage Tick Logic

function StartLimbTimer()
    LimbTick = Timer.SetInterval(function()
        DoLimbAlert()
    end, Config.MessageTimer * 1000)
end

function StopLimbTimer()
    if not LimbTick then return end
    Timer.ClearInterval(LimbTick)
    LimbTick = nil
end