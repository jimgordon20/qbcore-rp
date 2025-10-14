local zones = {}
local isPlayerInsideBankZone = false
local my_webui = nil

-- Functions

my_webui = WebUI('qb-banking', 'qb-banking/html/index.html', 0)
my_webui.Browser.OnLoadCompleted:Add(my_webui.Browser, function()
    my_webui:RegisterEventHandler('closeApp', function()
        my_webui:SetLayer(0)
    end)

    my_webui:RegisterEventHandler('withdraw', function(data, cb)
        TriggerCallback('withdraw', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('deposit', function(data, cb)
        TriggerCallback('deposit', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('internalTransfer', function(data, cb)
        TriggerCallback('internalTransfer', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('externalTransfer', function(data, cb)
        TriggerCallback('externalTransfer', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('orderCard', function(data, cb)
        TriggerCallback('orderCard', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('openAccount', function(data, cb)
        TriggerCallback('openAccount', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('renameAccount', function(data, cb)
        TriggerCallback('renameAccount', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('deleteAccount', function(data, cb)
        TriggerCallback('deleteAccount', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('addUser', function(data, cb)
        TriggerCallback('addUser', function(status)
            cb(status)
        end, data)
    end)

    my_webui:RegisterEventHandler('removeUser', function(data, cb)
        TriggerCallback('removeUser', function(status)
            cb(status)
        end, data)
    end)
end)

local function OpenBank()
    Timer.SetTimeout(function()
        my_webui:SetLayer(5)
        TriggerCallback('openBank', function(data)
            my_webui:CallFunction('openBank', {
                accounts = data.accounts,
                statements = data.statements,
                playerData = data.playerData
            })
        end)
    end, 500)
end

RegisterClientEvent('qb-banking:client:openBank', function()
    OpenBank()
end)

local function OpenATM()
    Timer.SetTimeout(function()
        my_webui:SetLayer(5)
        TriggerCallback('openATM', function(data)
            my_webui:CallFunction('openATM', {
                accounts = data.accounts,
                pinNumbers = data.acceptablePins,
                playerData = data.playerData
            })
        end)
    end, 500)
end

local function NearATM()
    local ped = HPlayer:K2_GetPawn()
    if not ped then return end
    local playerCoords = ped:K2_GetActorLocation()
    for _, v in pairs(Config.atmModels) do
        local hash = joaat(v)
        local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
        if atm then
            return true
        end
    end
end

-- Events

RegisterClientEvent('qb-banking:client:useCard', function()
    if NearATM() then OpenATM() end
end)

-- Threads

-- CreateThread(function()
--     for i = 1, #Config.locations do
--         local blip = AddBlipForCoord(Config.locations[i])
--         SetBlipSprite(blip, Config.blipInfo.sprite)
--         SetBlipDisplay(blip, 4)
--         SetBlipScale(blip, Config.blipInfo.scale)
--         SetBlipColour(blip, Config.blipInfo.color)
--         SetBlipAsShortRange(blip, true)
--         BeginTextCommandSetBlipName('STRING')
--         AddTextComponentSubstringPlayerName(tostring(Config.blipInfo.name))
--         EndTextCommandSetBlipName(blip)
--     end
-- end)

Timer.SetTimeout(function()
    for i = 1, #Config.locations do
        exports['qb-target']:AddSphereZone('bank_' .. i, Config.locations[i], 100.0, {
            debug = true,
            distance = 1000
        }, {
            {
                icon = 'fas fa-university',
                label = 'Open Bank',
                event = 'qb-banking:client:openBank',
            }
        })
    end

    -- for i = 1, #Config.atmModels do
    --     local atmModel = Config.atmModels[i]
    --     exports['qb-target']:AddTargetModel(atmModel, {
    --         options = {
    --             {
    --                 icon = 'fas fa-university',
    --                 label = 'Open ATM',
    --                 item = 'bank_card',
    --                 action = function()
    --                     OpenATM()
    --                 end,
    --             }
    --         },
    --         distance = 1.5
    --     })
    -- end
end, 2000)
