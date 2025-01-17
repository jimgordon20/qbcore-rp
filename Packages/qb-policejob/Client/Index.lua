Package.Require('cctv.lua')
local my_webui = WebUI('Fingerprint', 'file://html/index.html')
local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local player_data = {}

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-policejob:server:getPeds', function(peds)
        for ped, data in pairs(peds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end

for _, v in pairs(Config.Locations.stations) do
    local coords = v.coords
    Events.Call('Map:AddBlip', {
        name = v.label,
        coords = { x = coords.X, y = coords.Y, z = coords.Z },
        imgUrl = './media/map-icons/Police-icon.svg',
        group = 'police'
    })
end

AddGlobalPlayer({
    options = {
        {
            type = 'client',
            event = 'qb-prison:client:jail',
            label = 'Jail',
            icon = 'fas fa-user-lock',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:info',
            label = 'View Info',
            icon = 'fas fa-question',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:search',
            label = 'Search',
            icon = 'fas fa-magnifying-glass',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:escort',
            label = 'Escort',
            icon = 'fas fa-user-group',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:putvehicle',
            label = 'Put In Vehicle',
            icon = 'fas fa-car',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer() and entity:GetValue('escorted', false)
            end
        },
        -- {
        --     type = 'server',
        --     event = 'qb-policejob:server:takevehicle',
        --     label = 'Take Out Vehicle',
        --     icon = 'fas fa-car',
        --     jobType = 'leo',
        --     canInteract = function(entity)
        --         return entity:GetPlayer()
        --     end
        -- },
        -- {
        --     type = 'server',
        --     event = 'qb-policejob:server:handcuff',
        --     label = 'Handcuff',
        --     icon = 'fas fa-hand',
        --     jobType = 'leo',
        --     canInteract = function(entity)
        --         return entity:GetPlayer()
        --     end
        -- }
    },
    distance = 500
})

-- Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        player_data = QBCore.Functions.GetPlayerData()
        setupPeds()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    player_data = QBCore.Functions.GetPlayerData()
    setupPeds()
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
    player_data = {}
end)

Events.SubscribeRemote('QBCore:Client:OnJobUpdate', function(JobInfo)
    player_data.job = JobInfo
end)

-- Events

local fingerprint = false
Input.Subscribe('KeyPress', function(key_name)
    if key_name == 'BackSpace' and fingerprint then
        my_webui:CallEvent('qb-policejob:client:closeFingerprint')
        if Input.IsMouseEnabled() then Input.SetMouseEnabled(false) end
        my_webui:SetVisibility(WidgetVisibility.Hidden)
        fingerprint = false
        Events.CallRemote('qb-adminmenu:server:toggleInput', true)
    end
end)

my_webui:Subscribe('qb-policejob:client:scanFinger', function()
    Events.CallRemote('qb-policejob:server:scanFinger')
end)

Events.SubscribeRemote('qb-policejob:client:fingerprint', function()
    Input.SetMouseEnabled(true)
    my_webui:CallEvent('qb-policejob:client:openFingerprint')
    my_webui:BringToFront()
    my_webui:SetVisibility(WidgetVisibility.Visible)
    Events.CallRemote('qb-adminmenu:server:toggleInput', false)
    fingerprint = true
end)

Events.Subscribe('qb-policejob:client:evidence', function()
    local player = Client.GetLocalPlayer()
    local player_ped = player:GetControlledCharacter()
    if not player_ped then return end
    local player_coords = player_ped:GetLocation()
    for i = 1, #Config.Locations.evidence do
        local coords = Config.Locations.evidence[i].coords
        local distance = player_coords:Distance(coords)
        if distance < 500 then
            Events.CallRemote('qb-policejob:server:evidence', i)
        end
    end
end)

local police_alert = 0
Events.SubscribeRemote('qb-policejob:client:policeAlert', function(coords, text)
    police_alert = police_alert + 1
    QBCore.Functions.Notify('Police Alert: ' .. text)
    Events.Call('Map:AddBlip', {
        id = 'police_alert_' .. police_alert,
        name = 'Police Alert',
        coords = { x = coords.X, y = coords.Y, z = coords.Z },
        imgUrl = './media/map-icons/Police-icon.svg',
        group = 'dispatch'
    })
    Timer.SetTimeout(function()
        Events.Call('Map:RemoveBlip', 'police_alert_' .. police_alert)
    end, 30000)
end)

Events.SubscribeRemote('qb-policejob:client:tracker', function(coords, citizenid)
    QBCore.Functions.Notify('Tracker location shown for 30 seconds')
    Events.Call('Map:AddBlip', {
        id = 'tracker_' .. citizenid,
        name = 'Anklet Tracker',
        coords = { x = coords.X, y = coords.Y, z = coords.Z },
        imgUrl = './media/map-icons/Police-icon.svg',
        group = 'anklet'
    })
    Timer.SetTimeout(function()
        Events.Call('Map:RemoveBlip', 'tracker_' .. citizenid)
    end, 30000)
end)

Events.SubscribeRemote('qb-policejob:client:info', function(data)
    local char_info = data.charinfo
    local job_info = data.job
    local char_metadata = data.metadata
    local info_menu = ContextMenu.new()

    -- Character Information
    local citizen_id = data.citizenid
    local birthdate = char_info.birthdate
    local nationality = char_info.nationality
    local phone_number = char_info.phone
    local gender = char_info.gender == 0 and 'Male' or 'Female'
    info_menu:addDropdown('char-info', 'Documentation', {
        { id = '1', label = 'Citizen ID: ' .. citizen_id,     type = 'button', callback = function() end },
        { id = '2', label = 'Birthdate: ' .. birthdate,       type = 'button', callback = function() end },
        { id = '3', label = 'Gender: ' .. gender,             type = 'button', callback = function() end },
        { id = '4', label = 'Nationality: ' .. nationality,   type = 'button', callback = function() end },
        { id = '5', label = 'Phone Number: ' .. phone_number, type = 'button', callback = function() end },
    })

    -- Job Information
    local job = job_info.label
    local rank = job_info.grade.name
    info_menu:addDropdown('job', 'Job Information', {
        { id = '1', label = 'Job: ' .. job,   type = 'button', callback = function() end },
        { id = '2', label = 'Rank: ' .. rank, type = 'button', callback = function() end }
    })

    -- Licenses
    local licenses = char_metadata.licences
    local license_table = {}
    for license, obtained in pairs(licenses) do
        license_table[#license_table + 1] = { id = tostring(license), label = license:gsub('^%l', string.upper), type = 'checkbox', checked = obtained, callback = function() end }
    end
    info_menu:addDropdown('licenses', 'Licenses', license_table)

    -- Criminal
    local criminal_record = char_metadata.criminalrecord.hasRecord
    local has_tracker = char_metadata.tracker
    info_menu:addDropdown('criminal', 'Criminal Record', {
        { id = '1', label = 'Criminal Record', type = 'checkbox', checked = criminal_record, callback = function() end },
        {
            id = '2',
            label = 'Manage Tracker',
            type = 'checkbox',
            checked = has_tracker,
            callback = function()
                Events.CallRemote('qb-policejob:server:tracker', data.source)
            end
        }
    })

    info_menu:SetHeader(char_info.firstname .. ' ' .. char_info.lastname)
    info_menu:setMenuInfo('Citizen Information')
    info_menu:Open(false, true)
end)
