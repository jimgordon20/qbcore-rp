local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local player_data = {}

-- Functions

local function setupPeds()
    QBCore.Functions.TriggerCallback('qb-cityhall:server:getPeds', function(peds)
        for ped, data in pairs(peds) do
            AddTargetEntity(ped, { options = data.options, distance = data.distance })
        end
    end)
end

local function jobMenu()
    local job_menu = ContextMenu.new()
    for job, info in pairs(Config.Jobs) do
        job_menu:addButton('job-' .. job, info.label, function()
            Events.CallRemote('qb-cityhall:server:applyJob', job)
        end)
    end
    job_menu:SetHeader('Jobs')
    job_menu:Open(false, true)
end

local function licenseMenu()
    local license_menu = ContextMenu.new()
    for license, info in pairs(Config.Locations[1].licenses) do
        license_menu:addButton('license-' .. license, info.label, function()
            Events.CallRemote('qb-cityhall:server:requestId', license)
        end)
    end
    license_menu:SetHeader('Licenses')
    license_menu:Open(false, true)
end

local function openCityHall()
    local city_hall = ContextMenu.new()
    city_hall:addButton('cityhall-jobs', 'Jobs', function()
        jobMenu()
    end)
    city_hall:addButton('cityhall-licenses', 'Licenses', function()
        licenseMenu()
    end)
    city_hall:SetHeader('City Hall')
    city_hall:Open(false, true)
end

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

Events.Subscribe('qb-cityhall:client:open', function()
    openCityHall()
end)
