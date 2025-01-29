local Translations = {
    error = {
        not_working = 'You are not working',
        has_passenger = 'You already have a passenger',
        job_cancelled = 'You have cancelled your current job',
    },
    success = {
        clocked_off = 'You are no longer working',
        picked_up = 'You have picked up your passenger',
        payout = 'You were paid $%{amount}',
    },
    info = {
        pickup = 'Drive to the client marked on the map',
        goto_dropoff = 'You have picked up your passenger, drive to the dropoff point marked on your map',
    },
    text = {
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang