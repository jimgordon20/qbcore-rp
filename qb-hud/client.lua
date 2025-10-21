local isLoggedIn = false
local inputTimer = nil
local my_webui = WebUI('qb-hud', 'qb-hud/html/index.html', 0)
local player_data = {}
local playerPawn = nil
local round = math.floor

function onShutdown()
    if inputTimer then
        Timer.ClearInterval(inputTimer)
        inputTimer = nil
    end
    if my_webui then
        my_webui:Destroy()
        my_webui = nil
    end
end

-- Event Handlers

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    player_data = exports['qb-core']:GetPlayerData()
    my_webui:SetStackOrder(0)
    playerPawn = HPlayer:K2_GetPawn()
end)

RegisterClientEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    playerPawn = nil
    player_data = {}
    my_webui:SetStackOrder(0)
end)

RegisterClientEvent('QBCore:Player:SetPlayerData', function(val)
    player_data = val
end)

-- Money HUD

RegisterClientEvent('qb-hud:client:ShowAccounts', function(type, amount)
    if not my_webui then return end
    if type == 'cash' then
        my_webui:SendEvent('ShowCashAmount', round(amount))
    else
        my_webui:SendEvent('ShowBankAmount', round(amount))
    end
end)

RegisterClientEvent('qb-hud:client:OnMoneyChange', function(type, amount, isMinus)
    if not my_webui then return end
    local cashAmount = player_data.money['cash']
    local bankAmount = player_data.money['bank']
    my_webui:SendEvent('UpdateMoney', round(cashAmount), round(bankAmount), round(amount), isMinus, type)
end)

-- HUD Thread

inputTimer = Timer.SetInterval(function()
    if not isLoggedIn then return end
    if not playerPawn then return end
    local health     = playerPawn.HealthComponent:GetHealth()
    local armor      = player_data.metadata['armor']
    local hunger     = player_data.metadata['hunger']
    local thirst     = player_data.metadata['thirst']
    local stress     = player_data.metadata['stress']
    local playerDead = player_data.metadata['inlaststand'] or player_data.metadata['isdead'] or false

    if my_webui then
        my_webui:SendEvent('UpdateHUD', health, armor, hunger, thirst, stress, playerDead)
    end
end, 1000)