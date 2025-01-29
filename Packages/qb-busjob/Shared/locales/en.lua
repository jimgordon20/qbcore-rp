local Translations = {
    error = {
        one_bus_active = 'You can only have one active bus at a time',
    },
    success = {
        clocked_off = 'You are no longer working',
        completed_route = 'You have reached the end of your route, return to the depot',
        reward = 'You were paid $%{amount}',
    },
    info = {
        stops_left = 'You have %{stops} stop(s) left on your route',
        stops_total = 'You have %{stops} stop(s) on your route',
        goto_busstop = 'Drive to the bus stop marked on the map',
    },
    text = {
        start_working = 'Start working',
        stop_working = 'Stop working',
        blip_bus_stop = 'Bus Stop',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang