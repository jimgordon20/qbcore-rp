-- Interaction class definition
Interaction = {}
Interaction.__index = Interaction
Interaction.currentInstance = nil  -- Static reference to the current instance

-- Constructor for creating a new Interaction instance
function Interaction.new()
    local self = setmetatable({}, Interaction)
    -- Creates a new WebUI instance for interaction
    self.interactUI = WebUI("Interact UI", "file:///UI/interaction/index.html")
    -- State variables
    self.insideZone = false
    self.pressingE = false
    self.triggerData = nil
    self.callback = nil

    -- Subscribe to the 'interact:complete' event from the WebUI
    self.interactUI:Subscribe('interact:complete', function()
        self:complete()
    end)

    -- Bind input keys for interaction
    self:bindInputs()
    Interaction.currentInstance = self  -- Set the current instance

    return self
end

-- Shows the interaction UI with given parameters
function Interaction:show(id, text, callback)
    -- Set interaction data
    self.triggerData = id
    self.text = text
    self.callback = callback
    self.insideZone = true
    -- Call the WebUI event to show the interaction
    self.interactUI:CallEvent("interact:show", true, text)
end

-- Completes the interaction and executes the callback
function Interaction:complete()
    -- Reset interaction state
    self.insideZone = false
    -- Execute the callback if defined
    if self.callback ~= nil then
        self.callback(self.triggerData)
    end
end

-- Bind keyboard inputs for the interaction
function Interaction:bindInputs()
    -- Register 'E' key for interaction
    Input.Register("interact:pressed", "E")

    -- Bind 'E' key pressed event
    Input.Bind("interact:pressed", InputEvent.Pressed, function()
        -- Trigger interaction if inside the interaction zone
        if self.insideZone then
            self.interactUI:CallEvent("interact:pressed", true)
            self.pressingE = true
        end
    end)
    -- Bind 'E' key released event
    Input.Bind("interact:pressed", InputEvent.Released, function()
        -- Stop interaction if 'E' key is released
        if self.pressingE then
            self.interactUI:CallEvent("interact:released", false)
            self.pressingE = false
        end
    end)
end

-- Remote event subscription to handle interaction showing
Events.SubscribeRemote('interact:show', function(state, triggerS)
    -- Use the current instance of Interaction to manage the event
    if Interaction.currentInstance then
        Interaction.currentInstance.interactUI:CallEvent("interact:show", state, "See Description")
        Interaction.currentInstance.insideZone = state
        Interaction.currentInstance.triggerData = triggerS
    end
end)

-- Chat command handling for testing interaction
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Command 'int' to show interaction
    if message == "int" then
        local interaction = Interaction.new()

        interaction:show("my-interaction", "Your UI text here", function()
            Chat.AddMessage("Interaction: my-interaction completed!!")
        end)
    end
end)
