-- Get the directory of the current script
local function getScriptDir()
    local str = debug.getinfo(2, 'S').source:sub(2)
    return str:match('(.*/)')
end

-- Get current script's directory and build path to qb-core
local currentDir = getScriptDir() -- Should be: .../scripts/qb-multicharacter/Shared/locales/
local qbCorePath = currentDir .. '../../qb-core/Shared/locale.lua'

-- Normalize the path
qbCorePath = qbCorePath:gsub('\\', '/') -- Convert backslashes to forward slashes

local Locale = dofile(qbCorePath)

local Translations = {
    ['not_on_radio'] = "You're not connected to a signal",
    ['joined_to_radio'] = "You're connected to: %{channel}",
    ['restricted_channel_error'] = 'You can not connect to this signal!',
    ['invalid_radio'] = 'This frequency is not available.',
    ['you_on_radio'] = "You're already connected to this channel",
    ['you_leave'] = 'You left the channel.',
    ['volume_radio'] = 'New volume %{value}',
    ['decrease_radio_volume'] = 'The radio is already set to maximum volume',
    ['increase_radio_volume'] = 'The radio is already set to the lowest volume',
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
