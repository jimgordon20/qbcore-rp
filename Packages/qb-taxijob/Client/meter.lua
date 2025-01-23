--local meterUI = WebUI('meter', 'file://html/meter.html')
local previousCoord = nil
local meterData = {
    enabled = false,
    currentFare = 0,
    distanceTraveled = 0,
    timer = nil,
}

-- Functions

local function EnableMeter()
    meterData.timer = Timer.SetInterval(function()
        local ped = Client.GetLocalPlayer():GetControlledCharacter()
        if not ped then return end
        
        local pedLocation = ped:GetLocation()
        previousCoord = previousCoord or pedLocation
        meterData.distanceTraveled = meterData.distanceTraveled + previousCoord:Distance(pedLocation)
        meterData.currentFare = math.floor(meterData.distanceTraveled * Config.Meter.Rate + Config.Meter.StartingPrice)
        previousCoord = pedLocation
        meterUI:CallEvent('UPDATE_METER', meterData.currentFare, meterData.distanceTraveled)
    end, 4000)
end

-- Handlers

Events.Subscribe('qb-taxijob:client:toggleMeter', function()
    meterUI:CallEvent('TOGGLE_METER_UI', Config.Meter.StartingPrice)
end)

Events.Subscribe('qb-taxijob:client:enableMeter', function()
    meterData.enabled = not meterData.enabled
    if not meterData.enabled then 
        Timer.ClearInterval(meterData.timer)
        meterData = {
            enabled = false,
            currentFare = 0,
            distanceTraveled = 0,
            timer = nil,
        }
        meterUI:CallEvent('RESET_METER')
        return 
    end
    EnableMeter()
end)

