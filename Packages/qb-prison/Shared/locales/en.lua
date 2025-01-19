local Translations = {
    error = {
        injail = "You're in jail for %{Time} months",
        escaped = 'You escaped.. Get the hell out of here!',
    },
    success = {
        freedom = 'Your time is up!',
    },
    info = {
        time_left = 'You still have to... %{JAILTIME} months',
        time_months = 'Time in months',
        jail_time_input = 'Jail time',
        sent_jail_for = 'You sent the person to prison for %{time} months',
        received_property = 'Your porperty has been returned',
        seized_property = 'Your property has been seized',
        freedom = 'Check Time',
        prison_break = 'Prison Break',
        player_id = 'ID of Player',
    },
    commands = {
        unjail_player = 'Unjail a player',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
