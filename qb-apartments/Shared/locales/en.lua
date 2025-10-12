-- Get the directory of the current script
local function getScriptDir()
    local str = debug.getinfo(2, 'S').source:sub(2)
    return str:match('(.*/)')
end

-- Get current script's directory and build path to qb-core
local currentDir = getScriptDir() -- Should be: .../scripts/qb-multicharacter/Shared/locales/
local qbCorePath = currentDir .. '../../../qb-core/Shared/locale.lua'

-- Normalize the path
qbCorePath = qbCorePath:gsub('\\', '/') -- Convert backslashes to forward slashes

local Locale = dofile(qbCorePath)

local Translations = {
    error = {
        to_far_from_door = 'You are too far away from the doorbell',
        nobody_home = 'There is nobody home..',
        nobody_at_door = 'There is nobody at the door..'
    },
    success = {
        receive_apart = 'You got an apartment',
        changed_apart = 'You moved apartments',
    },
    info = {
        at_the_door = 'Someone is at the door!',
    },
    text = {
        options = '[E] Apartment Options',
        enter = 'Enter Apartment',
        ring_doorbell = 'Ring Doorbell',
        logout = 'Logout Character',
        change_outfit = 'Change Outfit',
        open_stash = 'Open Stash',
        move_here = 'Move Here',
        open_door = 'Open Door',
        leave = 'Leave Apartment',
        close_menu = '⬅ Close Menu',
        tennants = 'Tennants',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang
