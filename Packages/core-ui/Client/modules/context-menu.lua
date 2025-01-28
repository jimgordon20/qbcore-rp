-- Define the ContextMenu class
local ContextMenu = {}
ContextMenu.__index = ContextMenu
ContextMenu.currentInstance = nil
ContextMenu.focusIndex = 1

-- Create a new WebUI instance for the context menu
ContextMenu.UI = WebUI("ContextMenu", "file:///ui/context-menu/index.html")

-- Constructor to create a new ContextMenu instance
function ContextMenu.new()
    local self = setmetatable({}, ContextMenu)
    self.items = {}                    -- Stores menu items
    ContextMenu.currentInstance = self -- Keeps track of current instance

    return self
end

-- Add a button to the menu
function ContextMenu:addButton(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "button",
        text = text,
        callback = callback
    })
end

-- Add a checkbox to the menu
function ContextMenu:addCheckbox(id, label, checked, callback)
    checked = checked or false
    table.insert(self.items, {
        id = id,
        type = "checkbox",
        label = label,
        checked = checked,
        callback = callback
    })
end

-- Add a dropdown to the menu (with nested dropdown support)
function ContextMenu:addDropdown(id, label, options, callback)
    local dropdownOptions = {}
    for _, item in ipairs(options) do
        local newItem = {}
        for k, v in pairs(item) do
            newItem[k] = v
        end

        if newItem.type == "dropdown" and newItem.options then
            newItem.options = {}
            for _, subItem in ipairs(item.options) do
                local newSubItem = {}
                for k, v in pairs(subItem) do
                    newSubItem[k] = v
                end
                table.insert(newItem.options, newSubItem)
            end
        end

        table.insert(dropdownOptions, newItem)
    end

    table.insert(self.items, {
        id       = id,
        label    = label,
        type     = "dropdown",
        options  = dropdownOptions,
        callback = callback
    })
end


-- Add a range slider to the menu
function ContextMenu:addRange(id, label, min, max, value, callback)
    min = min or 0
    max = max or 100
    value = value or min
    table.insert(self.items, {
        id = id,
        type = "range",
        label = label,
        min = min,
        max = max,
        value = value,
        callback = callback
    })
end

-- Add a text input field to the menu
function ContextMenu:addTextInput(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "text-input",
        label = text,
        callback = callback
    })
end

-- Add a password input
function ContextMenu:addPassword(id, label, placeholder, callback)
    placeholder = placeholder or ""
    table.insert(self.items, {
        id = id,
        type = "password",
        label = label,
        placeholder = placeholder,
        callback = callback
    })
end

-- Add a radio group
function ContextMenu:addRadio(id, label, radioOptions, callback)
    -- radioOptions = { { value = "cash", text = "Cash", checked = true }, ... }
    table.insert(self.items, {
        id = id,
        type = "radio",
        label = label,
        options = radioOptions,
        callback = callback
    })
end

-- Add a number input
function ContextMenu:addNumber(id, label, defaultValue, callback)
    defaultValue = defaultValue or 0
    table.insert(self.items, {
        id = id,
        type = "number",
        label = label,
        value = defaultValue,
        callback = callback
    })
end

-- Add a select (dropdown) input
function ContextMenu:addSelect(id, label, selectOptions, callback)
    -- selectOptions = { { value = "none", text = "None", selected = true }, ... }
    table.insert(self.items, {
        id = id,
        type = "select",
        label = label,
        options = selectOptions,
        callback = callback
    })
end

-- Add a text display (or list) to the menu
function ContextMenu:addText(id, data)
    local is_list = false
    if type(data) == "table" then
        is_list = true
    end

    table.insert(self.items, {
        id = id,
        type = "text-display",
        data = data,
        is_list = is_list
    })
end

-- Get current menu items
function ContextMenu:getItems()
    return self.items
end

-- Send notification to WebUI
function ContextMenu:SendNotification(title, text, time, position, color)
    self.UI:CallEvent("ShowNotification", {
        title = title,
        message = text,
        duration = time,
        pos = position,
        color = color
    })
end

-- Open the context menu
function ContextMenu:Open(disable_game_input, enable_mouse)
    local items = self:getItems()
    self.UI:CallEvent("buildContextMenu", items)
    self.UI:BringToFront()
    self.UI:SetFocus()

    Input.SetInputEnabled(not disable_game_input)
    Input.SetMouseEnabled(enable_mouse)

    self:setInitialFocus()

    self.UI:CallEvent("ForceFocusOnUI")
end

-- Set menu information
function ContextMenu:setMenuInfo(title, description)
    self.UI:CallEvent("setMenuInfo", title, description)
end

-- Set menu header
function ContextMenu:SetHeader(title)
    self.Header = title
    self.UI:CallEvent("setHeader", title)
end

-- Returns a flat list of all top-level items plus sub-items if dropdowns are expanded
function ContextMenu:getFlattenedItems()
    local results = {}
    local function traverse(items)
        for _, item in ipairs(items) do
            table.insert(results, item)

            -- Solo recorre sub-items si es dropdown y está expandido
            if item.type == "dropdown" and item.expanded and item.options then
                traverse(item.options)
            end
        end
    end
    traverse(self.items)
    return results
end

-- Moves focus to the next item
function ContextMenu:focusNext()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    self.focusIndex = self.focusIndex + 1
    if self.focusIndex > #flattened then
        self.focusIndex = #flattened
    end
    self:focusItem(flattened[self.focusIndex])
end

-- Moves focus to the previous item
function ContextMenu:focusPrevious()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    self.focusIndex = self.focusIndex - 1
    if self.focusIndex < 1 then
        self.focusIndex = 1
    end
    self:focusItem(flattened[self.focusIndex])
end

-- Expands the currently focused dropdown
function ContextMenu:expandFocused()
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current or current.type ~= "dropdown" then return end
    current.expanded = true
    -- Rebuild the menu to reflect changes
    self:refreshMenu()
end

-- Collapses the currently focused dropdown
function ContextMenu:collapseFocused()
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current or current.type ~= "dropdown" or not current.expanded then return end
    current.expanded = false
    self:refreshMenu()
end

-- Focus a specific item by table reference
function ContextMenu:focusItem(item)
    if not item then return end
    -- Tell the JS side to highlight the item by ID
    self.UI:CallEvent("FocusOptionById", item.id)
end

-- Called to rebuild/refresh menu UI while preserving the current focus if possible
function ContextMenu:refreshMenu()
    self.UI:CallEvent("buildContextMenu", self.items)
    self:UIBringToFront()
    local flattened = self:getFlattenedItems()
    if self.focusIndex > #flattened then
        self.focusIndex = #flattened
    end
    if flattened[self.focusIndex] then
        self:focusItem(flattened[self.focusIndex])
    end
end

-- Call this after building the menu initially
function ContextMenu:setInitialFocus()
    self.focusIndex = 1
    local flattened = self:getFlattenedItems()
    if #flattened > 0 then
        self:focusItem(flattened[self.focusIndex])
    end

    -- self.UI:CallEvent("SimulateClickOnFirstOption")
    self.UI:BringToFront()
    self.UI:SetFocus()
end

-- Force UI to front
function ContextMenu:UIBringToFront()
    self.UI:BringToFront()
end

-- Close the context menu
function ContextMenu:Close()
    self.UI:CallEvent("closeContextMenu")
    Input.SetInputEnabled(true)
    Input.SetMouseEnabled(false)
end

-- Execute callback for a specific menu item
function ContextMenu:executeCallback(id, params)
    for _, item in ipairs(self.items) do
        if item.id == id then
            local is_valid, err_msg = self:validateInput(item, params)
            if not is_valid then
                self:ShowError(err_msg)
                return
            end
            if item.callback then
                item.callback(params)
            end
            return
        end

        if item.options then
            for _, option in ipairs(item.options) do
                if option.id == id then
                    local is_valid, err_msg = self:validateInput(option, params)
                    if not is_valid then
                        self:ShowError(err_msg)
                        return
                    end
                    if option.callback then
                        option.callback(params)
                    end
                    return
                end
            end
        end
    end
end

-- Validates input before executing the callback
function ContextMenu:validateInput(item, params)
    -- Text input validation
    if item.type == "text-input" then
        if type(params) ~= "string" or params == "" then
            return false, "Input cannot be empty."
        end
        -- Example: Check max length (e.g., 50 chars)
        if #params > 50 then
            return false, "Input is too long."
        end
    end

    -- Number input validation
    if item.type == "number" then
        local val = tonumber(params)
        if not val then
            return false, "Value must be a number."
        end
        if (item.min and val < item.min) or (item.max and val > item.max) then
            return false, "Value is out of the allowed range."
        end
    end

    -- Password input validation
    if item.type == "password" then
        if type(params) ~= "string" or #params < 4 then
            return false, "Password is too short."
        end
        -- Example: Check for at least one digit
        if not string.match(params, "%d") then
            return false, "Password must contain at least one digit."
        end
    end

    -- Checkbox validation
    if item.type == "checkbox" then
        -- Expect params as boolean
        if type(params) ~= "boolean" then
            return false, "Invalid checkbox state."
        end
    end

    -- Radio validation
    if item.type == "radio" and item.options then
        -- Ensure the selected value exists in item.options
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.value == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid radio selection."
        end
    end

    -- Select input validation
    if item.type == "select" and item.options then
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.value == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid selection."
        end
    end

    -- Dropdown input validation
    if item.type == "dropdown" and item.options then
        -- Expect params to match one of the dropdown's sub-options
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.id == params or opt.label == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid dropdown choice."
        end
    end

    -- Range validation
    if item.type == "range" then
        local val = tonumber(params)
        if not val then
            return false, "Value must be a number."
        end
        if (item.min and val < item.min) or (item.max and val > item.max) then
            return false, "Value is out of range."
        end
    end

    return true
end

function ContextMenu:ShowError(message)
    -- Using the Notification system already in place
    Notification.Send("error", "Invalid Input", message)
end

function ContextMenu:enterOrEdit()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    local current = flattened[self.focusIndex]
    if not current then return end

    if current.type == "range" or current.type == "number" or current.type == "text-input" then
        self.editMode = true
    elseif current.type == "dropdown" then
        if not current.expanded then
            current.expanded = true
            self:refreshMenu()
        else
            self.UI:CallEvent("SelectFocusedOption")
        end
    else
        self.UI:CallEvent("SelectFocusedOption")
    end
end

function ContextMenu:adjustCurrentOptionValue(keyName)
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current then return end

    if current.type == "range" or current.type == "number" then
        local step = 1
        if keyName == "ArrowLeft" then
            current.value = math.max(current.min or 0, current.value - step)
        else
            current.value = math.min(current.max or 100, current.value + step)
        end
        -- Reenvía callback
        if current.callback then
            current.callback(current.value)
        end
        -- O refresca la UI
        self:refreshMenu()
    end
end

-- Add a color picker
function ContextMenu:addColorPicker(id, label, defaultColor, callback)
    defaultColor = defaultColor or "#ffffff"
    table.insert(self.items, {
        id = id,
        type = "color",
        label = label,
        value = defaultColor,
        callback = callback
    })
end

-- Add a date picker
function ContextMenu:addDatePicker(id, label, defaultDate, callback)
    defaultDate = defaultDate or "2024-01-01"
    table.insert(self.items, {
        id = id,
        type = "date",
        label = label,
        value = defaultDate,
        callback = callback
    })
end

function ContextMenu:addListPicker(id, label, items, callback)
    -- items = { {id="weapon_sniper", label="Sniper Rifle"}, {id="weapon_ak47", label="AK-47"}, ... }
    table.insert(self.items, {
        id = id,
        type = "list-picker",
        label = label,
        list = items, -- array con varios {id, label}
        callback = callback
    })
end

-- Subscribe to CloseMenu event from WebUI
ContextMenu.UI:Subscribe("CloseMenu", function()
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:Close()
    end
end)

-- Subscribe to ExecuteCallback event from WebUI
ContextMenu.UI:Subscribe("ExecuteCallback", function(id, params)
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:executeCallback(id, params)
    end
end)

-- Example usage of context menu
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "/testmenu" then
        local myMenu = ContextMenu.new()

        -- Botón simple
        myMenu:addButton("button-id", "Button - Function", function()
            Chat.AddMessage("Pressed addbutton")
        end)

        -- Checkbox simple
        myMenu:addCheckbox("checkbox-id", "Checkbox", true, function()
            Chat.AddMessage("Pressed a checkbox")
        end)

        -- Dropdown directo
        myMenu:addDropdown("set-user", "Change Map", {
            {
                id = "opt1",
                label = "Option 1",
                type = "checkbox",
                checked = false,
                callback = function()
                    Chat.AddMessage('Selected: Option 1')
                end
            },
            {
                id = "opt2",
                label = "Option 2",
                type = "checkbox",
                checked = false,
                callback = function()
                    Chat.AddMessage('Selected: Option 2')
                end
            }
        })

        -- Dropdown con text-input
        myMenu:addDropdown("dropdown-id", "Set Player money", {
            {
                id = "1",
                label = "Bank",
                type = "text-input",
                callback = function(val)
                    Chat.AddMessage('Entered bank amount: ' .. val)
                end
            },
            {
                id = "2",
                label = "Cash",
                type = "text-input",
                callback = function(val)
                    Chat.AddMessage('Entered cash amount: ' .. val)
                end
            }
        })

        -- Range / slider
        myMenu:addRange(
            "quantity-example",
            "Quantity",
            1,
            10,
            5,
            function(finalValue)
                Chat.AddMessage("Submitted quantity: " .. tostring(finalValue))
            end
        )

        -- Text input normal
        myMenu:addTextInput("text-input", "Text input", function(text)
            Chat.AddMessage('Text input: ' .. text)
        end)

        -- Password input
        myMenu:addPassword("pwd-1", "Password Input", "Enter Password", function(value)
            Chat.AddMessage("Password entered: " .. value)
        end)

        -- Radio group
        myMenu:addRadio("radio-1", "Payment Method", {
            { value = "bill", text = "Bill", checked = false },
            { value = "cash", text = "Cash", checked = true },
            { value = "bank", text = "Bank", checked = false },
        }, function(selectedValue)
            Chat.AddMessage("Radio selected: " .. selectedValue)
        end)

        -- Number input
        myMenu:addNumber("number-1", "Number Input", 42, function(val)
            Chat.AddMessage("Number input: " .. val)
        end)

        -- Select input
        myMenu:addSelect("select-1", "Select Something", {
            { value = "none", text = "None",      selected = true },
            { value = "one",  text = "Option One" },
            { value = "two",  text = "Option Two" },
        }, function(selected)
            Chat.AddMessage("Selected from dropdown: " .. selected)
        end)

        -- Color Picker
        myMenu:addColorPicker("color-1", "Choose a color", "#ff0000", function(colorHex)
            Chat.AddMessage("Color selected: " .. colorHex)
        end)

        -- Date Picker
        myMenu:addDatePicker("date-1", "Choose a date", "2024-12-31", function(theDate)
            Chat.AddMessage("Date selected: " .. theDate)
        end)

        -- List Picker
        myMenu:addListPicker("list-picker-weapons", "Choose weapon", {
            { id = "weapon_sniper", label = "Sniper Rifle" },
            { id = "weapon_ak47",   label = "AK 47" },
            { id = "weapon_m4",     label = "M4" },
        }, function(selectedItem)
            Chat.AddMessage("Weapon selected: " .. selectedItem.id)
        end)

        -- Single text
        myMenu:addText("static-1", "Hello from a single-line text")

        -- Multi-line text
        myMenu:addText("static-2", {
            "First line of text",
            "Second line of text",
            "Another line here"
        })


        myMenu:addDropdown("my-text-drop", "Dropdown with Text Displays", {
            {
                id = "td-single",
                type = "text-display",
                data = "This is a single line of text"
            },
            {
                id = "td-multi",
                type = "text-display",
                data = { "Line1", "Line2", "Line3" },
                is_list = true
            }
        })



        myMenu:setMenuInfo("Menu Title", "Menu Description")
        myMenu:Open(false, true)
    end
end)


-- Export the ContextMenu class
Package.Export("ContextMenu", ContextMenu)
