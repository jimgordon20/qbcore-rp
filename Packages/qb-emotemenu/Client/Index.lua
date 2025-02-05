local function displayEmotes(category)
    local emote_menu = ContextMenu.new()
    for emote, data in pairs(Config.Emotes[category]) do
        emote_menu:addButton(data.name, data.name, function()
            Events.CallRemote('qb-emotemenu:server:playAnimation', category, emote)
        end)
    end
    emote_menu:SetHeader('Emote Menu', '')
    emote_menu:Open(false, true)
end

local function displayCategories()
    local emote_categories = ContextMenu.new()
    for category in pairs(Config.Emotes) do
        emote_categories:addButton(category, category, function()
            displayEmotes(category)
        end)
    end
    emote_categories:SetHeader('Emote Menu', '')
    emote_categories:Open(false, true)
end

Input.Register('Emote Menu', Config.Keybind)
Input.Bind('Emote Menu', InputEvent.Pressed, function()
    if Input.IsMouseEnabled() then return end
    displayCategories()
end)

local hands_up = false
Input.Register('Hands Up', 'X')
Input.Bind('Hands Up', InputEvent.Pressed, function()
    if Input.IsMouseEnabled() then return end
    if not hands_up then
        Events.CallRemote('qb-emotemenu:server:playAnimation', 'Roleplay', 'HandUp_Idle_01')
        hands_up = true
    end
end)

Input.Bind('Hands Up', InputEvent.Released, function()
    if hands_up then
        hands_up = false
        Events.CallRemote('qb-emotemenu:server:playAnimation', 'Roleplay', 'HandUp_Idle_01')
    end
end)

Input.Subscribe('KeyPress', function(key_name) -- for gameplay vid
    if key_name == 'Six' then
        Events.CallRemote('qb-emotemenu:server:playAnimation', 'Roleplay', 'A_StuffMoney_01')
    end
end)

Input.Subscribe('KeyPress', function(key_name) -- for gameplay vid
    if key_name == 'Seven' then
        Events.CallRemote('qb-emotemenu:server:spawnWeapon')
    end
end)

Input.Subscribe('KeyPress', function(key_name) -- for gameplay vid
    if key_name == 'Eight' then
        Events.CallRemote('qb-emotemenu:server:playAnimation', 'FearNFrights', 'Hostage2')
    end
end)