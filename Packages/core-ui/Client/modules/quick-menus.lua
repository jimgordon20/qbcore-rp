-- quickmenus.lua
-- This class provides simple "quick menus" for input and confirmation using callbacks rather than global events.
QuickMenus = {}
QuickMenus.__index = QuickMenus

-- WebUI for quick menus
QuickMenus.UI = WebUI("QuickMenus", "file:///UI/quick-menus/index.html")

-- Current singleton instance
QuickMenus.current = nil

-- Constructor
function QuickMenus.new()
	local self = setmetatable({}, QuickMenus)
	QuickMenus.current = self
	return self
end

-- Show an input menu
-- @param title: string - The title of the input dialog.
-- @param placeholder: string - The placeholder text in the input field.
-- @param callback: function(value) - Called when the user confirms with the entered value.
-- @param callback_cancel: function() - Called when user cancels.
function QuickMenus:ShowInput(title, placeholder, callback, callback_cancel)
	self.input_callback = callback
	self.input_cancel_callback = callback_cancel
	self.UI:CallEvent("ShowInputMenu", title, placeholder or "")
	self.UI:BringToFront() -- Ensure the menu is on top
	Input.SetMouseEnabled(true)
end

-- Show a confirmation menu
-- @param title: string - The title of the confirmation dialog.
-- @param message: string - The message displayed in the dialog.
-- @param callback_yes: function() - Called when user confirms (Yes).
-- @param callback_no: function() - Called when user cancels (No).
function QuickMenus:ShowConfirm(title, message, callback_yes, callback_no)
	self.confirm_yes_callback = callback_yes
	self.confirm_no_callback = callback_no
	self.UI:CallEvent("ShowConfirmMenu", title, message)
	self.UI:BringToFront() -- Ensure the menu is on top
	Input.SetMouseEnabled(true)
end

-- Close input menu
function QuickMenus:CloseInput()
	self.UI:CallEvent("HideInputMenu")
	Input.SetMouseEnabled(false)
end

-- Close confirm menu
function QuickMenus:CloseConfirm()
	self.UI:CallEvent("HideConfirmMenu")
	Input.SetMouseEnabled(false)
end

-- Subscriptions from JS
QuickMenus.UI:Subscribe("InputValueConfirmed", function(value)
	if QuickMenus.current and QuickMenus.current.input_callback then
		QuickMenus.current.input_callback(value)
	end
	QuickMenus.current:CloseInput()
end)

QuickMenus.UI:Subscribe("InputValueCanceled", function()
	if QuickMenus.current and QuickMenus.current.input_cancel_callback then
		QuickMenus.current.input_cancel_callback()
	end
	QuickMenus.current:CloseInput()
end)

QuickMenus.UI:Subscribe("ConfirmConfirmed", function()
	if QuickMenus.current and QuickMenus.current.confirm_yes_callback then
		QuickMenus.current.confirm_yes_callback()
	end
	QuickMenus.current:CloseConfirm()
end)

QuickMenus.UI:Subscribe("ConfirmCanceled", function()
	if QuickMenus.current and QuickMenus.current.confirm_no_callback then
		QuickMenus.current.confirm_no_callback()
	end
	QuickMenus.current:CloseConfirm()
end)

-- Example usage via chat command
Chat.Subscribe("PlayerSubmit", function(message)
	if message == "testinput" then
		local qm = QuickMenus.new()
		qm:ShowInput("Enter your name:", "Type name here...", function(value)
			Chat.AddMessage("User entered: " .. value)
		end, function()
			Chat.AddMessage("Input canceled")
		end)
	end

	if message == "testconfirm" then
		local qm = QuickMenus.new()
		qm:ShowConfirm("Are you sure?", "Do you really want to continue?", function()
			Chat.AddMessage("Confirmed: Yes")
		end, function()
			Chat.AddMessage("Confirmed: No")
		end)
	end
end)
