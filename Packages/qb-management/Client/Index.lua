local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')
local player_data = {}
local DynamicMenuItems = {}

-- Functions

local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

local function AddBossMenuItem(data, id)
    local menuID = id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = deepcopy(data)
    return menuID
end

Package.Export('AddBossMenuItem', AddBossMenuItem)

local function RemoveBossMenuItem(id)
    DynamicMenuItems[id] = nil
end

Package.Export('RemoveBossMenuItem', RemoveBossMenuItem)

local function AddGangMenuItem(data, id)
    local menuID = id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = deepcopy(data)
    return menuID
end

Package.Export('AddGangMenuItem', AddGangMenuItem)

local function RemoveGangMenuItem(id)
    DynamicMenuItems[id] = nil
end

Package.Export('RemoveGangMenuItem', RemoveGangMenuItem)

-- Handlers

Package.Subscribe('Load', function()
    if Client.GetValue('isLoggedIn', false) then
        player_data = QBCore.Functions.GetPlayerData()
    end
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerLoaded', function()
    player_data = QBCore.Functions.GetPlayerData()
end)

Events.SubscribeRemote('QBCore:Client:OnPlayerUnload', function()
    player_data = {}
end)

Events.SubscribeRemote('QBCore:Client:OnJobUpdate', function(JobInfo)
    player_data.job = JobInfo
end)

Events.SubscribeRemote('QBCore:Client:OnGangUpdate', function(GangInfo)
    player_data.gang = GangInfo
end)

-- Job Events

local BossMenuOptions = {
    { id = 'boss-employees', label = Lang:t('job_options.employees'), event = 'qb-management:client:employeeList' },
    { id = 'boss-hire',      label = Lang:t('job_options.hire'),      event = 'qb-management:client:hireMenu' },
    { id = 'boss-stash',     label = Lang:t('job_options.stash'),     remoteEvent = 'qb-management:server:jobStash' },
    { id = 'boss-wardrobe',  label = Lang:t('job_options.wardrobe'),  event = 'qb-management:client:wardrobe' },
}

Events.Subscribe('qb-management:client:openJobMenu', function()
    local boss_menu = ContextMenu.new()
    for _, option in ipairs(BossMenuOptions) do
        if option.remoteEvent then
            boss_menu:addButton(option.id, option.label, function()
                Events.CallRemote(option.remoteEvent)
            end)
        else
            boss_menu:addButton(option.id, option.label, function()
                Events.Call(option.event)
            end)
        end
    end
    if DynamicMenuItems and type(DynamicMenuItems) == 'table' and next(DynamicMenuItems) then
        for _, item in pairs(DynamicMenuItems) do
            if item.id and item.label and item.callback then
                boss_menu:addButton(item.id, item.label, item.callback)
            else
                print('Invalid DynamicMenuItem:', item)
            end
        end
    end
    boss_menu:SetHeader('Manage Business', '')
    boss_menu:Open(false, true)
end)

Events.Subscribe('qb-management:client:employeeList', function()
    local employee_list = ContextMenu.new()
    QBCore.Functions.TriggerCallback('qb-management:server:getEmployees', function(employees)
        if not employees or #employees == 0 then
            employee_list:addButton('no-employees', Lang:t('job_options.no_employees'), function()
                Events.Call('qb-management:client:openJobMenu')
            end)
        else
            for _, employee in pairs(employees) do
                employee_list:addButton('employee-' .. employee.citizenid, employee.name .. ' (' .. employee.job_info.grade.name .. ')', function()
                    Events.Call('qb-management:client:manageEmployee', employee)
                end)
            end
        end
        employee_list:addButton('return-button', Lang:t('job_options.return'), function()
            Events.Call('qb-management:client:openJobMenu')
        end)
        employee_list:SetHeader('Employees', '')
        employee_list:Open(false, true)
    end, player_data.job.name)
end)

Events.Subscribe('qb-management:client:manageEmployee', function(employee)
    local employee_options = ContextMenu.new()
    local job_name = employee.job_info.name
    local job_data = QBShared.Jobs[job_name]
    if not job_data then return end
    for gradeId, gradeData in pairs(job_data.grades) do
        employee_options:addButton('grade-' .. gradeId, gradeData.name .. ' (' .. Lang:t('job_options.grade') .. gradeId .. ')', function()
            Events.CallRemote('qb-management:server:updateEmployee', employee.citizenid, tonumber(gradeId))
        end)
    end
    employee_options:addButton('fire-employee', Lang:t('job_options.fire'), function()
        Events.CallRemote('qb-management:server:fireEmployee', employee.citizenid)
    end)
    employee_options:addButton('return-button', Lang:t('job_options.return'), function()
        Events.Call('qb-management:client:employeeList')
    end)
    employee_options:SetHeader('Manage Employee', '')
    employee_options:Open(false, true)
end)

Events.Subscribe('qb-management:client:hireMenu', function()
    local hire_menu = ContextMenu.new()
    QBCore.Functions.TriggerCallback('qb-management:server:closestPlayers', function(players)
        if not players or #players == 0 then
            QBCore.Functions.Notify(Lang:t('job_options.no_nearby'), 'error')
            return
        else
            for _, player in pairs(players) do
                if player then
                    hire_menu:addButton('hire-' .. player.netId, player.charinfo.firstname .. ' ' .. player.charinfo.lastname, function()
                        Events.CallRemote('qb-management:server:hireEmployee', player.source)
                    end)
                end
            end
        end
        hire_menu:addButton('return-button', Lang:t('job_options.return'), function()
            Events.Call('qb-management:client:openJobMenu')
        end)
        hire_menu:SetHeader('Hiring Menu', '')
        hire_menu:Open(false, true)
    end)
end)

-- Gang Events

local GangMenuOptions = {
    { id = 'gang-members',  label = Lang:t('gang_options.members'),  event = 'qb-management:client:memberList' },
    { id = 'gang-recruit',  label = Lang:t('gang_options.recruit'),  event = 'qb-management:client:recruitMember' },
    { id = 'gang-stash',    label = Lang:t('gang_options.stash'),    remoteEvent = 'qb-management:server:gangStash' },
    { id = 'gang-wardrobe', label = Lang:t('gang_options.wardrobe'), event = 'qb-management:client:wardrobe' },
}

Events.Subscribe('qb-management:client:openGangMenu', function()
    local gang_menu = ContextMenu.new()
    for _, option in ipairs(GangMenuOptions) do
        if option.remoteEvent then
            gang_menu:addButton(option.id, option.label, function()
                Events.CallRemote(option.remoteEvent)
            end)
        else
            gang_menu:addButton(option.id, option.label, function()
                Events.Call(option.event)
            end)
        end
    end
    if DynamicMenuItems and type(DynamicMenuItems) == 'table' and next(DynamicMenuItems) then
        for _, item in pairs(DynamicMenuItems) do
            if item.id and item.label and item.callback then
                gang_menu:addButton(item.id, item.label, item.callback)
            else
                print('Invalid DynamicMenuItem:', item)
            end
        end
    end
    gang_menu:SetHeader('Manage Gang', '')
    gang_menu:Open(false, true)
end)

Events.Subscribe('qb-management:client:memberList', function()
    local member_list = ContextMenu.new()
    QBCore.Functions.TriggerCallback('qb-management:server:getMembers', function(members)
        if not members or #members == 0 then
            member_list:addButton('no-members', Lang:t('gang_options.no_members'), function()
                Events.Call('qb-management:client:openGangMenu')
            end)
        else
            for _, member in pairs(members) do
                member_list:addButton('member-' .. member.citizenid, member.name .. ' (' .. member.gang_info.name .. ')', function()
                    Events.Call('qb-management:client:manageMember', member)
                end)
            end
        end
        member_list:addButton('return-button', Lang:t('gang_options.return'), function()
            Events.Call('qb-management:client:openGangMenu')
        end)
        member_list:SetHeader('Members', '')
        member_list:Open(false, true)
    end, player_data.gang.name)
end)

Events.Subscribe('qb-management:client:manageMember', function(member)
    local member_options = ContextMenu.new()
    local gang_name = employee.gang_info.name
    local gang_data = QBShared.Gangs[gang_name]
    if not gang_data then return end
    for gradeId, gradeData in pairs(gang_data.grades) do
        member_options:addButton('grade-' .. gradeId, gradeData.name .. ' (' .. Lang:t('gang_options.grade') .. gradeId .. ')', function()
            Events.CallRemote('qb-management:server:updateMember', member.citizenid, tonumber(gradeId))
        end)
    end
    member_options:addButton('fire-member', Lang:t('gang_options.fire'), function()
        Events.CallRemote('qb-management:server:removeMember', member.citizenid)
    end)
    member_options:addButton('return-button', Lang:t('gang_options.return'), function()
        Events.Call('qb-management:client:memberList')
    end)
    member_options:SetHeader('Manage Member', '')
    member_options:Open(false, true)
end)

Events.Subscribe('qb-management:client:recruitMember', function()
    local recruit_menu = ContextMenu.new()
    QBCore.Functions.TriggerCallback('qb-management:server:closestPlayers', function(players)
        if not players or #players == 0 then
            recruit_menu:addButton('no-players', Lang:t('gang_options.no_nearby'), function()
                Events.Call('qb-management:client:openGangMenu')
            end)
        else
            for _, player in pairs(players) do
                if player and player.sourceplayer ~= Client.GetLocalPlayer():GetID() then
                    recruit_menu:addButton('recruit-' .. player.sourceplayer, player.name .. ' (' .. Lang:t('gang_options.cid') .. player.citizenid .. ' - ID: ' .. player.sourceplayer .. ')', function()
                        Events.CallRemote('qb-management:server:recruitMember', player.sourceplayer)
                    end)
                end
            end
        end
        recruit_menu:addButton('return-button', Lang:t('gang_options.return'), function()
            Events.Call('qb-management:client:openGangMenu')
        end)
        recruit_menu:SetHeader('Recruit Menu', '')
        recruit_menu:Open(false, true)
    end)
end)

-- Universal Event

Events.Subscribe('qb-management:client:wardrobe', function()
    -- TODO: Implement clothing menu integration
end)

-- Targets

for job, zones in pairs(Config.BossMenus) do
    for index, coords in ipairs(zones) do
        local zoneName = job .. '_bossmenu_' .. index
        AddBoxZone(zoneName, coords, 0.5, 0.5, {
            name = zoneName,
            heading = 0,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'qb-management:client:openJobMenu',
                    icon = 'fas fa-sign-in-alt',
                    label = Lang:t('target.label'),
                    canInteract = function() return job == player_data.job.name and player_data.job.isboss end
                },
            },
            distance = 250
        })
    end
end

for gang, zones in pairs(Config.GangMenus) do
    for index, coords in ipairs(zones) do
        local zoneName = gang .. '_gangmenu_' .. index
        AddBoxZone(zoneName, coords, 0.5, 0.5, {
            name = zoneName,
            heading = 0,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'qb-management:client:openGangMenu',
                    icon = 'fas fa-sign-in-alt',
                    label = Lang:t('targetgang.label'),
                    canInteract = function() return gang == player_data.gang.name and player_data.gang.isboss end
                },
            },
            distance = 250
        })
    end
end
