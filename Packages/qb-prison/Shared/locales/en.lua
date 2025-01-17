local Translations = {
    error = {
        ['injail'] = "You're in jail for %{Time} months..",
        ['escaped'] = 'You escaped... Get the hell out of here!',
        ['security_activated'] = 'Highest security level is active, stay with the cell blocks!'
    },
    success = {
        ['free_'] = "You're free! Enjoy it! :)",
        ['timesup'] = 'Your time is up! Check yourself out at the visitors center',
    },
    info = {
        ['timeleft'] = 'You still have to... %{JAILTIME} months',
        ['time_months'] = 'Time in months',
        ['jail_time_input'] = 'Jail time',
        ['sent_jail_for'] = 'You sent the person to prison for %{time} months',
        ['received_property'] = 'You got your property back..',
        ['seized_property'] = "Your property has been seized, you'll get everything back when your time is up..",
        ['cells_blip'] = 'Cells',
        ['freedom_blip'] = 'Jail Front Desk',
        ['canteen_blip'] = 'Canteen',
        ['target_freedom_option'] = 'Check Time',
        ['target_canteen_option'] = 'Get Food',
        ['police_alert_title'] = 'New Call',
        ['police_alert_description'] = 'Prison Outbreak',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
