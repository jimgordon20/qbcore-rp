-- Get the directory of the current script
local function getScriptDir()
    local str = debug.getinfo(2, 'S').source:sub(2)
    return str:match('(.*/)')
end

-- Get current script's directory and build path to qb-core
local currentDir = getScriptDir()
local qbCorePath = currentDir .. '../../qb-core/Shared/locale.lua'

-- Normalize the path
qbCorePath = qbCorePath:gsub('\\', '/')

local Locale = dofile(qbCorePath)

local Translations = {
    target = {
        ['toggle_duty'] = 'Toggle Duty',
        ['take_vehicle'] = 'Retrieve Taxi',
        ['finish_work'] = 'Finish Working',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
