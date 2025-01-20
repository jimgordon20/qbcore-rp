local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

-- Callbacks

QBCore.Functions.CreateCallback('qb-management:server:getEmployees', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not Player.PlayerData.job.isboss then return end
    local citizen_id = Player.PlayerData.citizenid
    local employees = {}
    local job_name = Player.PlayerData.job.name
    local players = MySQL.query.await('SELECT * FROM players WHERE job LIKE ?', { '%' .. job_name .. '%' })
    if players and players[1] then
        for _, value in pairs(players) do
            if value.citizenid ~= citizen_id then
                local Target = QBCore.Functions.GetPlayerByCitizenId(value.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(value.citizenid)
                if Target and Target.PlayerData.job.name == job_name then
                    local isOnline = Target.PlayerData.source
                    employees[#employees + 1] = {
                        citizenid = Target.PlayerData.citizenid,
                        job_info = Target.PlayerData.job,
                        name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
                    }
                end
            end
        end
        table.sort(employees, function(a, b)
            return a.grade.level > b.grade.level
        end)
    end
    cb(employees)
end)

QBCore.Functions.CreateCallback('qb-management:server:getMembers', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not Player.PlayerData.gang.isboss then return end
    local citizen_id = Player.PlayerData.citizenid
    local members = {}
    local gang_name = Player.PlayerData.gang.name
    local players = MySQL.query.await('SELECT * FROM players WHERE gang LIKE ?', { '%' .. gang_name .. '%' })
    if players and players[1] then
        for _, value in pairs(players) do
            if value.citizenid ~= citizen_id then
                local Target = QBCore.Functions.GetPlayerByCitizenId(value.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(value.citizenid)
                if Target and Target.PlayerData.gang.name == gang_name then
                    local isOnline = Target.PlayerData.source
                    members[#members + 1] = {
                        citizenid = Target.PlayerData.citizenid,
                        gang_info = Target.PlayerData.gang,
                        name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
                    }
                end
            end
        end
        table.sort(members, function(a, b)
            return a.grade.level > b.grade.level
        end)
    end
    cb(members)
end)

QBCore.Functions.CreateCallback('qb-management:server:closestPlayers', function(source, cb)
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local player_coords = ped:GetLocation()
    local players = QBCore.Functions.GetQBPlayers()
    local closestPlayers = {}
    for _, v in pairs(players) do
        if v.PlayerData.source ~= source then
            local targetPed = v.PlayerData.source:GetControlledCharacter()
            if targetPed then
                local targetLocation = targetPed:GetLocation()
                local distance = player_coords:Distance(targetLocation)
                if distance < 400 then
                    table.insert(closestPlayers, v.PlayerData)
                end
            end
        end
    end
    cb(closestPlayers)
end)

-- Job Events

Events.SubscribeRemote('qb-management:server:hireEmployee', function(source, target)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_job = Player.PlayerData.job
    if not player_job.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(target)
    if not Target then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unavailable'), 'error')
        return
    end
    if Target.Functions.SetJob(player_job.name) then
        Target.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.e_hired'), 'success')
        Events.CallRemote('QBCore:Notify', Target.PlayerData.source, Lang:t('success.e_hiredt'), 'success')
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:fireEmployee', function(source, target)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_job = Player.PlayerData.job
    if not player_job.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(target)
    if not Target then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unavailable'), 'error')
        return
    end
    if Target.Functions.SetJob('unemployed') then
        Target.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.e_fired'), 'success')
        Events.CallRemote('QBCore:Notify', Target.PlayerData.source, Lang:t('error.e_fired'), 'error')
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:updateEmployee', function(source, target, grade)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_job = Player.PlayerData.job
    if not player_job.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    if grade > player_job.grade.level then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
    if not Employee then return end
    local employee_rank = Employee.PlayerData.job.grade.level
    if Employee.Functions.SetJob(player_job.name, grade) then
        Employee.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.e_updated'), 'success')
        if employee_rank > grade then
            Events.CallRemote('QBCore:Notify', Employee.PlayerData.source, Lang:t('error.demoted'), 'error')
        else
            Events.CallRemote('QBCore:Notify', Employee.PlayerData.source, Lang:t('success.e_updatedt'), 'success')
        end
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:jobStash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_job = Player.PlayerData.job
    if not player_job.isboss then return end
    if not Config.BossMenus[player_job.name] then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local player_coords = ped:GetLocation()
    local bossCoords = Config.BossMenus[player_job.name]
    for i = 1, #bossCoords do
        local coords = bossCoords[i]
        if #(player_coords - coords) < 400 then
            local stashName = 'boss_' .. player_job.name
            OpenInventory(source, stashName, {
                maxweight = 4000000,
                slots = 25,
            })
            return
        end
    end
end)

-- Gang Events

Events.SubscribeRemote('qb-management:server:recruitMember', function(source, target)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_gang = Player.PlayerData.gang
    if not player_gang.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(target)
    if not Target then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unavailable'), 'error')
        return
    end
    if Target.Functions.SetGang(player_job.name, 0) then
        Target.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.recruited'), 'success')
        Events.CallRemote('QBCore:Notify', Target.PlayerData.source, Lang:t('success.recruitedt'), 'success')
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:removeMember', function(source, target)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_gang = Player.PlayerData.gang
    if not player_gang.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(target)
    if not Target then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unavailable'), 'error')
        return
    end
    if Target.Functions.SetGang('none', 0) then
        Target.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.removed'), 'success')
        Events.CallRemote('QBCore:Notify', Target.PlayerData.source, Lang:t('error.removed'), 'success')
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:updateMember', function(source, target, grade)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_gang = Player.PlayerData.gang
    if not player_gang.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    if grade > player_gang.grade.level then
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.unauthorized'), 'error')
        return
    end
    local Member = QBCore.Functions.GetPlayerByCitizenId(target)
    if not Member then return end
    local gang_rank = Member.PlayerData.gang.grade.level
    if Member.Functions.SetGang(player_gang.name, grade) then
        Member.Functions.Save()
        Events.CallRemote('QBCore:Notify', source, Lang:t('success.updated'), 'success')
        if gang_rank > grade then
            Events.CallRemote('QBCore:Notify', Member.PlayerData.source, Lang:t('error.demoted'), 'error')
        else
            Events.CallRemote('QBCore:Notify', Member.PlayerData.source, Lang:t('success.e_updatedt'), 'success')
        end
    else
        Events.CallRemote('QBCore:Notify', source, Lang:t('error.failed'), 'error')
    end
end)

Events.SubscribeRemote('qb-management:server:gangStash', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local player_gang = Player.PlayerData.gang
    if not player_gang.isboss then
        Events.CallRemote('QBCore:Notify', source, Lang:t('bodygang.fire'), 'error')
        return
    end
    if not Config.GangMenus[player_gang.name] then return end
    local ped = source:GetControlledCharacter()
    if not ped then return end
    local player_coords = ped:GetLocation()
    local bossCoords = Config.GangMenus[player_gang.name]
    for i = 1, #bossCoords do
        local coords = bossCoords[i]
        if #(player_coords - coords) < 400 then
            local stashName = 'gang_' .. player_gang.name
            OpenInventory(source, stashName, {
                maxweight = 4000000,
                slots = 25,
            })
            return
        end
    end
end)
