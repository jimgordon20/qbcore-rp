---@type QBCore_GameMode_C
local M = UnLua.Class()

function M:K2_PostLogin(NewPlayerController)
    self.Overridden.K2_PostLogin(self, NewPlayerController)
end

function M:ReceiveBeginPlay()
    --print('QBCore_GameMode_C:ReceiveBeginPlay')
end

function M:K2_OnLogout()
    print('QBCore_GameMode_C:K2_OnLogout')
end

function M:ReceiveEndPlay()
    --print('QBCore_GameMode_C:ReceiveEndPlay')
end

return M
