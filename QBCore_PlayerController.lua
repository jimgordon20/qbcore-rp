---@type QBCore_PlayerController_C
local M = UnLua.Class()

local function FetchCharacters(self)
    local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
    local DB = DatabaseSubsystem:GetDatabase()
    local result = DB:Select('SELECT * FROM players WHERE license = "license:qwerty" ORDER BY cid DESC', {})
    if not result then print('[QBCore] Error: Couldn\'t load PlayerData for ' .. citizenid) return '[]' end

    return result
end

function M:ReceiveBeginPlay()
    if self:HasAuthority() then
        local Characters = FetchCharacters(self)

        coroutine.resume(coroutine.create(function(PC, Duration)
            UE.UKismetSystemLibrary.Delay(PC, Duration)
            self:ShowMulticharacter_Client(Characters)
        end), self, 1.0)
    end
end

function M:ShowMulticharacter_Server_RPC()
    local Characters = FetchCharacters(self)
    self:ShowMulticharacter_Client(Characters)
end

function M:ShowMulticharacter_Client_RPC(playerData)
    -- Refresh data if widget exists
    local WidgetClass = UE.UClass.Load('/QBCore/Multicharacter/multicharacter.multicharacter_C')
    local Widget = UE.UWidgetBlueprintLibrary.GetAllWidgetsOfClass(self, nil, WidgetClass, false):ToTable()[1]
    if Widget then
        Widget.CharContainer:ClearChildren()
        Widget:PopulateCharData(playerData)
        return
    end

    Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass, self)
    Widget:PopulateCharData(playerData)
    Widget:AddToViewport(0)
end

function M:Login_Server_RPC(CitizenID)
    if CitizenID then
        QBCore.Player.Login(self, CitizenID)
    end
end

function M:NewCharacter_Server_RPC(CharInfoStruct, CID)
    local Data = {
        CID = CID,
        CharInfo = CharInfoStruct
    }
    QBCore.Player.Login(self, false, Data)
end

function M:DeleteCharacter_Server_RPC(CitizenID)
    if CitizenID then
        QBCore.Player.DeleteCharacter(self, CitizenID)
    end
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

return M
