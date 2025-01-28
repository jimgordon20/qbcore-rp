-- Phone UI initialization
local PhoneUI = WebUI('phone', 'file://phone/Client/ui/phone.html')

-- Phone state
local phoneOpened = false
local phoneData = nil
local phoneApps = nil
local currentlyPlayingAnimation = ''

-- Function to handle key input
local function handleKeyDown(key_name, delta)
	if key_name == 'P' then
		if not phoneOpened then
			OpenPhone()
		else
			ClosePhone()
		end
	elseif key_name == 'BackSpace' then
		if phoneOpened then
			ClosePhone()
		end
	elseif key_name == 'N' then
		PhoneUI:CallEvent('DialPhoneCall', 90022, 1)
		Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_taking_phone_call', true, false)
		currentlyPlayingAnimation = 'ffcce-phone-anims::ply_taking_phone_call'
		Timer.SetTimeout(function()
			Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_call_idle', true, true)
			Events.CallRemote('pcrp-phone:StopAnimation', currentlyPlayingAnimation)
			currentlyPlayingAnimation = 'ffcce-phone-anims::ply_call_idle'
		end, 750)
	end
end

Input.Subscribe('KeyDown', handleKeyDown)

PhoneUI:Subscribe('StopCall', function()
	if currentlyPlayingAnimation ~= '' then
		Events.CallRemote('pcrp-phone:StopAnimation', currentlyPlayingAnimation)
	end
	Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_holding_phone', true, true)
	currentlyPlayingAnimation = 'ffcce-phone-anims::ply_holding_phone'
end)

-- Function to open phone
function OpenPhone()
	Events.CallRemote('SpawnPhone')
	Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_take_phone_out', true, false)
	currentlyPlayingAnimation = 'ffcce-phone-anims::ply_take_phone_out'
	Timer.SetTimeout(function()
		PhoneUI:CallEvent('OpenPhone')
		PhoneUI:BringToFront()
		Input.SetMouseEnabled(true)
		Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_holding_phone', true, true)
		currentlyPlayingAnimation = 'ffcce-phone-anims::ply_holding_phone'
		phoneOpened = true
	end, 750)
end

-- Function to close phone
function ClosePhone()
	PhoneUI:CallEvent('ClosePhone')
	Input.SetMouseEnabled(false)
	if currentlyPlayingAnimation ~= '' then
		Events.CallRemote('pcrp-phone:StopAnimation', currentlyPlayingAnimation)
		currentlyPlayingAnimation = ''
	end
	Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_putting_phone_away', true, false)
	currentlyPlayingAnimation = 'ffcce-phone-anims::ply_putting_phone_away'
	Timer.SetTimeout(function()
		-- if currentlyPlayingAnimation ~= "" then
		-- 	Events.CallRemote("pcrp-phone:StopAnimation", currentlyPlayingAnimation)
		-- 	currentlyPlayingAnimation = ""
		-- end
		Events.CallRemote('pcrp-phone:StopAnimation', 'ffcce-phone-anims::ply_putting_phone_away')
	end, 1700)
	Timer.SetTimeout(function()
		Events.CallRemote('pcrp-phone:DeletePhone')
		phoneOpened = false
	end, 1700) -- Make sure this wait covers the total animation duration
end

-- Handle remote subscription for adding contacts
Events.SubscribeRemote('pcrp-phone:AddContact', function(callNumber, data)
	if not phoneData then
		return
	end
	phoneData.contacts[callNumber] = data
	PhoneUI:CallEvent('SendAppData', 'contacts', { action = 'CONTACT_ADDED', contacts = phoneData.contacts })
end)

-- Set up phone when received from server
Events.SubscribeRemote('pcrp-phone:SetupPhone', function(_phoneData, _phoneApps)
	print('Setting up phone')
	phoneData = _phoneData
	phoneApps = _phoneApps
	PhoneUI:CallEvent('SetupApps', phoneApps)
end)

-- Handle call from UI
PhoneUI:Subscribe('CallNumber', function(number)
	PhoneUI:CallEvent('DialPhoneCall', 90022, 1)
	Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_taking_phone_call', true, false)
	if currentlyPlayingAnimation ~= '' then
		Events.CallRemote('pcrp-phone:StopAnimation', currentlyPlayingAnimation)
	end
	Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_taking_phone_call', true, false)
	currentlyPlayingAnimation = 'ffcce-phone-anims::ply_taking_phone_call'
	Timer.SetTimeout(function()
		Events.CallRemote('pcrp-phone:ExecuteAnimation', 'ffcce-phone-anims::ply_call_idle', true, true)
		Events.CallRemote('pcrp-phone:StopAnimation', 'ffcce-phone-anims::ply_taking_phone_call')
		currentlyPlayingAnimation = 'ffcce-phone-anims::ply_call_idle'
	end, 750)
end)
