local prevPos = nil
local onPainKillers = false
local painkillerAmount = 0

-- Functions

local function DoBleedAlert()
    if not isDead and tonumber(isBleeding) > 0 then
        QBCore.Functions.Notify(Lang:t('info.bleed_alert', { bleedstate = Config.BleedingStates[tonumber(isBleeding)].label }), 'error', 5000)
    end
end

local function RemoveBleed(level)
    if isBleeding ~= 0 then
        if isBleeding - level < 0 then
            isBleeding = 0
        else
            isBleeding = isBleeding - level
        end
        DoBleedAlert()
    end
end

local function ApplyBleed(level)
    if isBleeding ~= 4 then
        if isBleeding + level > 4 then
            isBleeding = 4
        else
            isBleeding = isBleeding + level
        end
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

-- Handler

HCharacter.Subscribe('TakeDamage', function(self, damage, bone, type, from_direction, instigator, causer)
    print('TakeDamage was called')
    print(self, damage, bone, type, from_direction, instigator, causer)
end)

-- Events

Events.SubscribeRemote('hospital:client:useIfaks', function()
    if painkillerAmount < 3 then painkillerAmount = painkillerAmount + 1 end
    PainKillerLoop()
    if math.random(1, 100) < 50 then RemoveBleed(1) end
end)

Events.SubscribeRemote('hospital:client:useBandage', function()
    if math.random(1, 100) < 50 then RemoveBleed(1) end
    if math.random(1, 100) < 7 then ResetPartial() end
end)

Events.SubscribeRemote('hospital:client:usePainkillers', function()
    if painkillerAmount < 3 then painkillerAmount = painkillerAmount + 1 end
    PainKillerLoop()
end)
