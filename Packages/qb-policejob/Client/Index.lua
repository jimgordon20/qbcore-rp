Package.Require('cctv.lua')

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
            type = 'server',
            event = 'qb-policejob:server:jail',
            label = 'Jail',
            icon = 'fas fa-user-lock',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:status',
            label = 'Check Status',
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
            -- canInteract = function(entity)
            --     return entity:GetPlayer()
            -- end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:takelicense',
            label = 'Revoke License',
            icon = 'fas fa-id-card',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        },
        {
            type = 'server',
            event = 'qb-policejob:server:handcuff',
            label = 'Handcuff',
            icon = 'fas fa-hand',
            jobType = 'leo',
            canInteract = function(entity)
                return entity:GetPlayer()
            end
        }
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

Events.SubscribeRemote('qb-policejob:client:fingerprint', function()

end)
