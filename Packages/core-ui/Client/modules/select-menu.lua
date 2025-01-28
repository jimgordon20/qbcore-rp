-- Define la clase SelectMenu
SelectMenu = {}
SelectMenu.__index = SelectMenu
SelectMenu.currentInstance = nil

SelectMenu.UI = WebUI("ContextMenu", "file:///ui/select-menu/index.html")


-- Constructor 
function SelectMenu.new()
    local self = setmetatable({}, SelectMenu)
    self.options = {} -- Saves the menu options
    SelectMenu.currentInstance = self
    return self
end

-- Adds an option on the menu
function SelectMenu:addOption(id, name, image, description, info, callback)
    table.insert(self.options, {
        id = id,
        name = name,
        image = image,
        description = description,
        info = info,
        callback = callback
    })
end

-- Adds a title 
function SelectMenu:SetTitle(title)
    self.title = title
end

-- Send options to front-end
function SelectMenu:Open()
    if SelectMenu.currentInstance then
        -- Calls the WebUI event to update the options
        local players = Player.GetAll()
        self.UI:CallEvent("OpenSelectMenu", self.options, self.title, #players)
        self.UI:BringToFront()
        Input.SetMouseEnabled(true)
    end
end

function SelectMenu:Close()
    if SelectMenu.currentInstance then
        Input.SetMouseEnabled(false)
        self.UI:CallEvent("CloseSelectMenu")
    end
end

-- Executes a callback for a specific menu item
function SelectMenu:executeCallback(id, params)
    -- Iterates through the items to find the one with the matching ID and executes its callback
    for _, item in ipairs(self.options) do
        if item.id == id and item.callback then
            item.callback(params)
            return
        end
    end
end

-- Subscribes to the ExecuteCallback event from the WebUI
SelectMenu.UI:Subscribe("ExecuteCallback", function(id, params)
    -- Executes the callback for the item with the specified ID
    if SelectMenu.currentInstance then
        SelectMenu.currentInstance:executeCallback(id, params)
    end
end)

Input.Subscribe("KeyUp", function(keyName)
    if keyName == "BackSpace" then
        -- Closes the menu when the BackSpace key is released
        if SelectMenu.currentInstance then
            SelectMenu.currentInstance:Close()
        end
    end
end)

Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "sel" then
        local options = SelectMenu.new()

        options:SetTitle('Select Next game mode')

        options:addOption("magin-option", "Magin Valley", "./media/gm3.png",
            "Step Magin Valley into the boots of a battle-hardened warrior...", {
                { name = "rating",  value = "88%",       icon = "./media/icon1.svg" },
                { name = "creator", value = "Player123", icon = "./media/icon2.svg" },
                { name = "players", value = "4 - 16",    icon = "./media/icon3.svg" }
            },
            function()
                Chat.AddMessage("Option Magin Valley selected")
            end
        )

        options:addOption("casino-option", "Casino Royale", "./media/gm2.png",
            "Step Casino Royale into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes",
            {
                { name = "rating",  value = "22%",       icon = "./media/icon1.svg" },
                { name = "creator", value = "Kravs123", icon = "./media/icon2.svg" },
                { name = "players", value = "1 - 128",    icon = "./media/icon3.svg" }
            },
            function()
                Chat.AddMessage("Option casino royale selected")
            end
        )

        options:Open()
    end
end)
