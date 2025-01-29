local Translations = {
    success = {
        new_route = 'Route started, you have %{stops} stop(s)',
        reward = 'Route completed, you earned $%{amount}',
    },

    info = {
        bags_remaining = 'Bags Left: %{bags}',
        stops_remaining = 'Stops Remaining: %{stops}',
        load_bag = 'Press F to load bag into truck',
    },

    error = {
        route_busy = 'You are already on a route, cancel the route to start a new one',
        no_route = 'You are not on a route',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true,
})

return Lang