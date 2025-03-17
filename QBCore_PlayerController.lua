---@type QBCore_PlayerController_C
local M = UnLua.Class()

function M:ReceiveBeginPlay()
    if self:HasAuthority() then
        local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
        local DB = DatabaseSubsystem:GetDatabase()
        local result = DB:Select('SELECT * FROM players WHERE license = "license:qwerty" ORDER BY cid', {})
        if not result then return error('[QBCore] Couldn\'t load PlayerData for ' .. citizenid) end
        self:ShowMulticharacter_Client(result)
    end
end

function M:ShowMulticharacter_Client_RPC(playerData)
    print('ShowMulticharacter')
    -- if self:HasAuthority() then print('server') end
    -- if not self:HasAuthority() then
    --     print('client')
    --     local WidgetClass = UE.UClass.Load('/QBCore/Multicharacter/multicharacter.multicharacter_C')
    --     local Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass, self)
    --     Widget:AddToViewport(0)
    -- end
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

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

return M
