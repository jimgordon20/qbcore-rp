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
    error = {
        to_far_from_door = 'Estás demasiado lejos del timbre',
        nobody_home = 'No hay nadie en casa...',
        nobody_at_door = 'No hay nadie en la puerta...'
    },
    success = {
        receive_apart = '¡Has recibido un apartamento!',
        changed_apart = '¡Te has mudado de apartamento!',
    },
    info = {
        at_the_door = '¡Hay alguien en la puerta!',
    },
    text = {
        options = '[E] Opciones del Apartamento',
        enter = 'Entrar al Apartamento',
        ring_doorbell = 'Tocar el Timbre',
        logout = 'Cerrar Sesión del Personaje',
        change_outfit = 'Cambiar Atuendo',
        open_stash = 'Abrir Almacén',
        move_here = 'Mudarte Aquí',
        open_door = 'Abrir Puerta',
        leave = 'Salir del Apartamento',
        close_menu = '⬅ Cerrar Menú',
        tennants = 'Inquilinos',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

return Lang