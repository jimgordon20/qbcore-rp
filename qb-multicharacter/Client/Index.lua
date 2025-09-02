local Lang = require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local my_webui = WebUI('Multicharacter', 'file://html/index.html')

-- Functions

local function openCharMenu(bool)
    local player = Client.GetLocalPlayer()
    player:SetCameraLocation(Config.CamCoords)
    player:SetCameraRotation(Config.CamRotation)
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:GetNumberOfCharacters', function(result)
        local translations = {}
        for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
            if k:sub(0, ('ui.'):len()) then
                translations[k:sub(('ui.'):len() + 1)] = Lang:t(k)
            end
        end
        my_webui:BringToFront()
        Input.SetMouseEnabled(bool)
        Input.SetInputEnabled(false)
        my_webui:CallEvent('qb-multicharacter:ui', Config.customNationality, bool, result, Config.EnableDeleteButton, translations)
    end)
end

-- Events

RegisterClientEvent('qb-multicharacter:client:closeNUI', function()
    Input.SetMouseEnabled(false)
end)

RegisterClientEvent('qb-multicharacter:client:chooseChar', function()
    openCharMenu(true)
end)

RegisterClientEvent('qb-multicharacter:client:closeNUIdefault', function()
    Input.SetMouseEnabled(false)
    Input.SetInputEnabled(true)
    Events.Call('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    --Events.Call('qb-clothes:client:CreateFirstCharacter')
end)

RegisterClientEvent('qb-multicharacter:client:spawnLastLocation', function(coords, cData)
    QBCore.Functions.TriggerCallback('qb-apartments:GetOwnedApartment', function(result)
        if result then
            --Events.Call('qb-apartments:client:SetHomeBlip', result.type)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local insideMeta = PlayerData.metadata['inside']
            if insideMeta.house then
                Events.Call('qb-houses:client:LastLocationHouse', insideMeta.house)
            elseif insideMeta.apartment.apartmentType and insideMeta.apartment.apartmentId then
                Events.Call('qb-apartments:client:LastLocationHouse', insideMeta.apartment.apartmentType, insideMeta.apartment.apartmentId)
            end
            Events.Call('QBCore:Client:OnPlayerLoaded')
        end
    end, cData.citizenid)
end)

-- NUI Events

my_webui:Subscribe('selectCharacter', function(data)
    local cData = data.cData
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
end)

my_webui:Subscribe('setupCharacters', function()
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:setupCharacters', function(result)
        my_webui:CallEvent('qb-multicharacter:setupCharacters', result)
    end)
end)

my_webui:Subscribe('RemoveBlur', function()
    SetTimecycleModifier('default')
end)

my_webui:Subscribe('createNewCharacter', function(data)
    local cData = data
    if cData.gender == Lang:t('ui.male') then
        cData.gender = 0
    elseif cData.gender == Lang:t('ui.female') then
        cData.gender = 1
    end
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
end)

my_webui:Subscribe('removeCharacter', function(data)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
end)
