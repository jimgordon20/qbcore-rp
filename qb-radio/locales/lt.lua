-- Get the directory of the current script
local function getScriptDir()
    local str = debug.getinfo(2, 'S').source:sub(2)
    return str:match('(.*/)')
end

-- Get current script's directory and build path to qb-core
local currentDir = getScriptDir() -- Should be: .../scripts/qb-multicharacter/Shared/locales/
local qbCorePath = currentDir .. '../../qb-core/Shared/locale.lua'

-- Normalize the path
qbCorePath = qbCorePath:gsub('\\\\', '/') -- Convert backslashes to forward slashes

local Locale = dofile(qbCorePath)

local Translations = {
    ['not_on_radio'] = 'Nesate prisijungę prie kanalo',
    ['joined_to_radio'] = 'Prisijungėte prie: %{channel}',
    ['restricted_channel_error'] = 'Negalite prisijungti prie šio kanalo!',
    ['invalid_radio'] = 'Šis dažnis nepasiekiamas.',
    ['you_on_radio'] = 'Jau esate prisijungę prie šio kanalo',
    ['you_leave'] = 'Palikote kanalą.',
    ['volume_radio'] = 'Naujas garsumas %{value}',
    ['decrease_radio_volume'] = 'Radijas jau nustatytas į maksimalų garsumą',
    ['increase_radio_volume'] = 'Radijas jau nustatytas į minimalų garsumą',
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
