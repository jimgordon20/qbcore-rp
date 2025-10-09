local Lang = require('locales/en')
local QBPlayers = exports['qb-core']:GetCoreObject().Players

-- Functions

local function distCheck(coords1, coords2)
    return UE.FVector.Dist(coords1, coords2)
end

-- Events

RegisterServerEvent('qb-management:server:jobStash', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local playerJob = Player.PlayerData.job
    if not playerJob.isboss then return end
    local ped = source:K2_GetPawn()
    if not ped then return end
    local playerCoords = ped:K2_GetActorLocation()
    if not Config.BossMenus[playerJob.name] then return end
    local bossCoords = Config.BossMenus[playerJob.name]
    for i = 1, #bossCoords do
        local coords = bossCoords[i]
        if distCheck(playerCoords, coords) < 1000 then
            local stashName = 'boss_' .. playerJob.name
            exports['qb-inventory']:OpenInventory(source, stashName, {
                maxweight = 4000000,
                slots = 25,
            })
            return
        end
    end
end)

RegisterServerEvent('qb-management:server:gangStash', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local playerGang = Player.PlayerData.gang
    if not playerGang.isboss then return end
    local ped = source:K2_GetPawn()
    if not ped then return end
    local playerCoords = ped:K2_GetActorLocation()
    if not Config.GangMenus[playerGang.name] then return end
    local bossCoords = Config.GangMenus[playerGang.name]
    for i = 1, #bossCoords do
        local coords = bossCoords[i]
        if distCheck(playerCoords, coords) < 1000 then
            local stashName = 'gang_' .. playerGang.name
            exports['qb-inventory']:OpenInventory(source, stashName, {
                maxweight = 4000000,
                slots = 25,
            })
            return
        end
    end
end)

-- Gangs

RegisterServerEvent('qb-management:server:GradeUpdateGang', function(source, data)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Member = exports['qb-core']:GetPlayerByCitizenId(data.cid) or exports['qb-core']:GetOfflinePlayerByCitizenId(data.cid)
    if not Member then return end

    if not Player.PlayerData.gang.isboss then
        ExploitBan(source, 'GradeUpdateGang Exploiting')
        return
    end

    if data.grade > Player.PlayerData.gang.grade.level then
        TriggerClientEvent(source, 'QBCore:Notify', 'You cannot promote to this rank!', 'error')
        return
    end

    if Member then
        if exports['qb-core']:Player(Member, 'SetGang', Player.PlayerData.gang.name, data.grade) then
            TriggerClientEvent(source, 'QBCore:Notify', 'Sucessfully promoted!', 'success')
            exports['qb-core']:Player(Member, 'Save')
            if Member.PlayerData.source then
                TriggerClientEvent(Member.PlayerData.source, 'QBCore:Notify', 'You have been promoted to ' .. data.gradename .. '.', 'success')
            end
        else
            TriggerClientEvent(source, 'QBCore:Notify', 'Promotion grade does not exist.', 'error')
        end
    end
    TriggerClientEvent(source, 'qb-management:client:OpenGangMenu')
end)

RegisterServerEvent('qb-management:server:FireMember', function(source, target)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Member = exports['qb-core']:GetPlayerByCitizenId(target) or exports['qb-core']:GetOfflinePlayerByCitizenId(target)

    if not Player.PlayerData.gang.isboss then
        ExploitBan(source, 'FireMember Exploiting')
        return
    end

    if Member then
        if target == Player.PlayerData.citizenid then
            TriggerClientEvent(source, 'QBCore:Notify', 'You can\'t fire yourself', 'error')
            return
        elseif Member.PlayerData.gang.grade.level > Player.PlayerData.gang.grade.level then
            TriggerClientEvent(source, 'QBCore:Notify', 'You cannot fire this citizen!', 'error')
            return
        end
        if exports['qb-core']:Player(Member, 'SetGang', 'none', '0') then
            exports['qb-core']:Player(Member, 'Save')
            TriggerClientEvent(source, 'QBCore:Notify', 'Gang member fired!', 'success')

            if Member.PlayerData.source then
                TriggerClientEvent(Member.PlayerData.source, 'QBCore:Notify', 'You have been fired from the gang! Good luck.', 'error')
            end
        else
            TriggerClientEvent(source, 'QBCore:Notify', 'Error..', 'error')
        end
    end
    TriggerClientEvent(source, 'qb-management:client:OpenGangMenu')
end)

RegisterServerEvent('qb-management:server:HireMember', function(source, recruit)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Target = exports['qb-core']:GetPlayer(recruit)
    if not Target then return end

    if not Player.PlayerData.gang.isboss then
        ExploitBan(source, 'HireMember Exploiting')
        return
    end

    if Target and exports['qb-core']:Player(Target, 'SetGang', Player.PlayerData.gang.name, 0) then
        TriggerClientEvent(source, 'QBCore:Notify', 'You recruited ' .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' come ' .. Player.PlayerData.gang.label .. '', 'success')
        TriggerClientEvent(Target.PlayerData.source, 'QBCore:Notify', 'You were recruited into ' .. Player.PlayerData.gang.label .. '', 'success')
    end
    TriggerClientEvent(source, 'qb-management:client:OpenGangMenu')
end)

-- Jobs

RegisterServerEvent('qb-management:server:GradeUpdate', function(source, data)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Employee = exports['qb-core']:GetPlayerByCitizenId(data.cid) or exports['qb-core']:GetOfflinePlayerByCitizenId(data.cid)
    if not Employee then return end

    if not Player.PlayerData.job.isboss then
        ExploitBan(source, 'GradeUpdate Exploiting')
        return
    end

    if data.grade > Player.PlayerData.job.grade.level then
        TriggerClientEvent(source, 'QBCore:Notify', 'You cannot promote to this rank!', 'error')
        return
    end

    if Employee then
        if exports['qb-core']:Player(Employee, 'SetJob', Player.PlayerData.job.name, data.grade) then
            TriggerClientEvent(source, 'QBCore:Notify', 'Sucessfully promoted!', 'success')
            exports['qb-core']:Player(Employee, 'Save')
            if Employee.PlayerData.source then
                TriggerClientEvent(Employee.PlayerData.source, 'QBCore:Notify', 'You have been promoted to ' .. data.gradename .. '.', 'success')
            end
        else
            TriggerClientEvent(source, 'QBCore:Notify', 'Promotion grade does not exist.', 'error')
        end
    end
    TriggerClientEvent(source, 'qb-management:client:OpenMenu')
end)

RegisterServerEvent('qb-management:server:FireEmployee', function(source, target)
    local Player = exports['qb-core']:GetPlayer(src)
    local Employee = exports['qb-core']:GetPlayerByCitizenId(target) or exports['qb-core']:GetOfflinePlayerByCitizenId(target)

    if not Player.PlayerData.job.isboss then
        ExploitBan(source, 'FireEmployee Exploiting')
        return
    end

    if Employee then
        if target == Player.PlayerData.citizenid then
            TriggerClientEvent(source, 'QBCore:Notify', 'You can\'t fire yourself', 'error')
            return
        elseif Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then
            TriggerClientEvent(source, 'QBCore:Notify', 'You cannot fire this citizen!', 'error')
            return
        end
        if exports['qb-core']:Player(Employee, 'SetJob', 'unemployed', '0') then
            exports['qb-core']:Player(Employee, 'Save')
            TriggerClientEvent(source, 'QBCore:Notify', 'Employee fired!', 'success')

            if Employee.PlayerData.source then
                TriggerClientEvent(Employee.PlayerData.source, 'QBCore:Notify', 'You have been fired! Good luck.', 'error')
            end
        else
            TriggerClientEvent(source, 'QBCore:Notify', 'Error..', 'error')
        end
    end
    TriggerClientEvent(source, 'qb-management:client:OpenMenu')
end)

RegisterServerEvent('qb-management:server:HireEmployee', function(source, recruit)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local Target = exports['qb-core']:GetPlayer(recruit)
    if not Target then return end

    if not Player.PlayerData.job.isboss then
        ExploitBan(source, 'HireEmployee Exploiting')
        return
    end

    if Target and exports['qb-core']:Player(Target, 'SetJob', Player.PlayerData.job.name, 0) then
        TriggerClientEvent(source, 'QBCore:Notify', 'You hired ' .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' come ' .. Player.PlayerData.job.label .. '', 'success')
        TriggerClientEvent(Target.PlayerData.source, 'QBCore:Notify', 'You were hired as ' .. Player.PlayerData.job.label .. '', 'success')
    end
    TriggerClientEvent(source, 'qb-management:client:OpenMenu')
end)

-- Callbacks

RegisterCallback('GetEmployees', function(source, jobname)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end

    if not Player.PlayerData.job.isboss then
        ExploitBan(source, 'GetEmployees Exploiting')
        return
    end

    local employees = {}
    local players = exports['qb-core']:DatabaseAction('Select', "SELECT * FROM `players` WHERE `job` LIKE '%" .. jobname .. "%'", {})
    if players[1] then
        for _, value in pairs(players) do
            local Target = exports['qb-core']:GetPlayerByCitizenId(value.citizenid) or exports['qb-core']:GetOfflinePlayerByCitizenId(value.citizenid)
            if Target and Target.PlayerData.job.name == jobname then
                local isOnline = Target.PlayerData.source
                employees[#employees + 1] = {
                    empSource = Target.PlayerData.citizenid,
                    grade = Target.PlayerData.job.grade,
                    isboss = Target.PlayerData.job.isboss,
                    name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
                }
            end
        end
        table.sort(employees, function(a, b)
            return a.grade.level > b.grade.level
        end)
    end
    return employees
end)

RegisterCallback('GetMembers', function(source, gangname)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end

    if not Player.PlayerData.gang.isboss then
        ExploitBan(source, 'GetMembers Exploiting')
        return
    end

    local members = {}
    local players = exports['qb-core']:DatabaseAction('Select', "SELECT * FROM `players` WHERE `gang` LIKE '%" .. gangname .. "%'", {})
    if players[1] then
        for _, value in pairs(players) do
            local Target = exports['qb-core']:GetPlayerByCitizenId(value.citizenid) or exports['qb-core']:GetOfflinePlayerByCitizenId(value.citizenid)
            if Target and Target.PlayerData.gang.name == gangname then
                local isOnline = Target.PlayerData.source
                members[#members + 1] = {
                    empSource = Target.PlayerData.citizenid,
                    grade = Target.PlayerData.gang.grade,
                    isboss = Target.PlayerData.gang.isboss,
                    name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
                }
            end
        end
        table.sort(members, function(a, b)
            return a.grade.level > b.grade.level
        end)
    end
    return members
end)

RegisterCallback('GetPlayers', function(source)
    local players = {}
    local PlayerPed = source:K2_GetPawn()
    if not PlayerPed then return end
    local pCoords = PlayerPed:K2_GetActorLocation()
    for _, v in pairs(QBPlayers) do
        local targetped = v:K2_GetPawn()
        local tCoords = targetped:K2_GetActorLocation()
        local dist = distCheck(pCoords, tCoords)
        if PlayerPed ~= targetped and dist < 1000 then
            local ped = exports['qb-core']:GetPlayer(v)
            players[#players + 1] = {
                id = v,
                coords = GetEntityCoords(targetped),
                name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
                citizenid = ped.PlayerData.citizenid,
                sources = GetPlayerPed(ped.PlayerData.source),
                sourceplayer = ped.PlayerData.source
            }
        end
    end
    table.sort(players, function(a, b)
        return a.name < b.name
    end)
    return players
end)
