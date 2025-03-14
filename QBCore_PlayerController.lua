---@type QBCore_PlayerController_C
local M = UnLua.Class()

-- function M:ReceiveBeginPlay()
--     if self:HasAuthority() then
--         --QBCore.Player.Login(self)
--         print("call what we need to from server")
--         return
--     end
-- end

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