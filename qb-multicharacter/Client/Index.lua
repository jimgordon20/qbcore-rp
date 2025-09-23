local Lang = require('Shared/locales/en')
-- Functions

-- local function openCharMenu(bool)
--player:SetCameraLocation(Config.CamCoords)
--player:SetCameraRotation(Config.CamRotation)
--QBCore.Functions.TriggerCallback('qb-multicharacter:server:GetNumberOfCharacters', function(result)
-- local translations = {}
-- for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
--     if k:sub(0, ('ui.'):len()) then
--         translations[k:sub(('ui.'):len() + 1)] = Lang:t(k)
--     end
-- end
--my_webui:BringToFront() -- Unused
--Input.SetMouseEnabled(bool)
--Input.SetInputEnabled(false)
--my_webui:CallFunction('openUI', Config.customNationality, bool, result, Config.EnableDeleteButton, translations)
-- my_webui:CallFunction('openUI', Config.customNationality, true, 5, Config.EnableDeleteButton, translations)
--end)
-- end

local function setupCharMenuUI(numOfChars)
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('ui.'):len()) then
            translations[k:sub(('ui.'):len() + 1)] = Lang:t(k)
        end
    end
    my_webui = WebUI('Multicharacter', 'qb-multicharacter/Client/html/index.html', true)
    -- NUI Events
    my_webui:RegisterEventHandler('selectCharacter', function(data)
        local cData = data.cData
        TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
        my_webui:CallFunction('openUI', Config.customNationality, false, 0, false, translations)
    end)

    my_webui:RegisterEventHandler('setupCharacters', function()
        TriggerServerEvent('qb-multicharacter:server:setupCharacters')
    end)

    my_webui:RegisterEventHandler('RemoveBlur', function()
        SetTimecycleModifier('default')
    end)

    my_webui:RegisterEventHandler('createNewCharacter', function(data)
        local cData = data
        if cData.gender == Lang:t('ui.male') then
            cData.gender = 0
        elseif cData.gender == Lang:t('ui.female') then
            cData.gender = 1
        end
        TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    end)

    my_webui:RegisterEventHandler('removeCharacter', function(data)
        TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
    end)
    Timer.SetTimeout(function()
        my_webui:CallFunction('openUI', Config.customNationality, true, numOfChars, Config.EnableDeleteButton, translations)
    end, 1000)
end

-- Events

RegisterClientEvent('qb-multicharacter:client:ReceiveNumberOfCharacters', function(numOfChars)
    setupCharMenuUI(numOfChars)
end)

RegisterClientEvent('qb-multicharacter:client:ReceiveCharacters', function(characters)
    my_webui:CallFunction('setupCharacters', characters)
end)

RegisterClientEvent('qb-multicharacter:client:closeNUI', function()
    my_webui:Destroy()
    --Input.SetMouseEnabled(false)
end)

RegisterClientEvent('qb-multicharacter:client:chooseChar', function()
    Timer.SetTimeout(function()
        --openCharMenu(true)
        TriggerServerEvent('qb-multicharacter:server:GetNumberOfCharacters')
    end, 4000)
end)

RegisterClientEvent('qb-multicharacter:client:closeNUIdefault', function()
    --Input.SetMouseEnabled(false)
    --Input.SetInputEnabled(true)
    my_webui:Destroy()
    TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    --Events.Call('qb-clothes:client:CreateFirstCharacter')
end)

RegisterClientEvent('qb-multicharacter:client:spawnLastLocation', function(coords, cData)
    exports['qb-core']:TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
        if result then
            --TriggerClientEvent('qb-apartments:client:SetHomeBlip', result.type)
            local PlayerData = exports['qb-core']:GetPlayerData()
            local insideMeta = PlayerData.metadata['inside']
            if insideMeta.house then
                TriggerLocalClientEvent('qb-houses:client:LastLocationHouse', insideMeta.house)
            elseif insideMeta.apartment.apartmentType and insideMeta.apartment.apartmentId then
                TriggerLocalClientEvent('qb-apartments:client:LastLocationHouse', insideMeta.apartment.apartmentType, insideMeta.apartment.apartmentId)
            end
            TriggerLocalClientEvent('QBCore:Client:OnPlayerLoaded')
        end
    end, cData.citizenid)
end)
