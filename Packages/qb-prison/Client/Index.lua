local Lang = Package.Require('../Shared/locales/' .. QBConfig.Language .. '.lua')

Events.Subscribe('qb-prison:client:jail', function(data)
    local target_ped = data.entity
    if not target_ped then return end
    local target_player = target_ped:GetPlayer()
    if not target_player then return end
    local jail_menu = ContextMenu.new()
    jail_menu:addNumber('number-1', Lang:t('info.jail_time_input'), 1, function(val)
        Events.CallRemote('qb-prison:server:jail', data, val)
    end)
    jail_menu:SetHeader('Jail Menu')
    jail_menu:setMenuInfo(Lang:t('info.time_months'), '')
    jail_menu:Open(false, true)
end)
