# Core-UI: Simplifying In-Game UI Creation for HELIX Game Creators
<br>
<br>
Core-UI is a package for HELIX Game, designed to empower creators with the ability to effortlessly generate and manage in-game user interfaces. This package combines HTML, CSS, JS, and Lua using the HELIX Game Scripting API, offering a streamlined approach to UI development within the HELIX gaming environment.

## Package installation:

1 - Download and extract this repository.
<br>
2 - Drag and drop core-ui folder to your Packages folder.
<br>
3 - Add core-ui to your Config.toml (inside your Server folder) on `[packages]` section.
<br>
<br>
![image](https://github.com/helix-game/core-ui/assets/67294331/ac69692f-e3dd-4779-b68a-32166a7ad12a)
<br>
## Calling core-ui classes from other packages.

1 - Add core-ui on `packages_requirements` inside your Package.toml file.
<br>
<br>
![image](https://github.com/helix-game/core-ui/assets/67294331/a6f8a114-6fe7-4dc3-91c7-5756d353007c)
## Usage:

First take a look at: <a href="https://add-core-ui.docs-9aw.pages.dev/docs/scripting-reference/static-classes/chat#event-playersubmit" target="_blank">PlayerSubmit Event</a>

### Example of how to use ContextMenu class:
```lua
-- Example of how to use the context menu
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "/menu" then
        local myMenu = ContextMenu.new()
        myMenu:addButton("button-id", "Buton - Function", function()
            Chat.AddMessage("I pressed addbutton")
        end)
        myMenu:addCheckbox("checkbox-id", "Checkbox", true, function()
            Chat.AddMessage('I pressed a checbkox')
        end)
        myMenu:addDropdown("set-user", "Change Map",
            { { id = "1", label = "Option 1", type = "checkbox", checked = false }, { id = "2", label = "Option 2", type = "checkbox", checked = false } },
            function(option)
                Chat.AddMessage('Selected option: ' .. option)
            end)
        myMenu:addDropdown("dropdown-id", "Set Player money",
            { { id = "1", label = "Bank", type = "text-input" }, { id = "2", label = "Cash", type = "text-input" } },
            function(option)
                Chat.AddMessage('selected option: ' .. option)
            end)
        myMenu:addRange("quantity", "Quantity", 0, 100, 50, function(value)
            Chat.AddMessage('range value: ' .. value)
        end)
        myMenu:addTextInput("text-input", "Text input", function(text)
            Chat.AddMessage('text input: ' .. text)
        end)

        myMenu:Open(false, true) -- Enable input, Enable mouse
    end
end)
```
![image](https://github.com/helix-game/core-ui/assets/67294331/4433107a-c69b-4c15-a19f-4d5323d81466)

### Example of how to use SelectMenu class:
```lua
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
```
![image](https://github.com/helix-game/core-ui/assets/67294331/c18606fe-9408-4869-9fee-2e9ff4718141)

### Example of how to use Interaction class:
```lua
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Command 'int' to show interaction
    if message == "int" then
        local interaction = Interaction.new()

        interaction:show("my-interaction", "Your UI text here", function()
            Chat.AddMessage("Interaction: my-interaction completed!!")
        end)
    end
end)
```
![image](https://github.com/helix-game/core-ui/assets/67294331/f038df82-18e0-4f95-b005-7539fb85703b)
### Example of how to use Notification class:
```lua
-- Subscribes to a chat event to listen for specific player messages
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Checks if the received message is 'not'
    if message == 'not' then
        -- Sends a notification when the 'not' message is received
        Notification.Send('success', 'Title', 'Notification Content')
        -- Parameters are type, title and message
        -- types: success - error - info
    end
end)
```
![image](https://github.com/helix-game/core-ui/assets/67294331/82e174a1-91eb-4292-88eb-776ec2e03d54)

### Example of how to use QuickMenus class:

The QuickMenus allow you to quickly gather player input or ask for confirmation without building a full context menu. You can show simple input dialogs or confirmation boxes and handle the results easily.

```lua
-- Showing an input menu example:
Chat.Subscribe("PlayerSubmit", function(message)
    if message == "testinput" then
        local qm = QuickMenus.new()
        qm:ShowInput("Enter your name:", "Type name here...", function(value)
            Chat.AddMessage("User entered: " .. value)
        end, function()
            Chat.AddMessage("Input canceled")
        end)
    end
end)

-- Showing a confirmation menu example:
Chat.Subscribe("PlayerSubmit", function(message)
    if message == "testconfirm" then
        local qm = QuickMenus.new()
        qm:ShowConfirm("Are you sure?", "Do you really want to continue?", function()
            Chat.AddMessage("Confirmed: Yes")
        end, function()
            Chat.AddMessage("Confirmed: No")
        end)
    end
end)
```

## License


This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

```markdown
MIT License

Copyright (c) 2024 Hypersonic Laboratories

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
