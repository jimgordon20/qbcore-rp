---@type QBCore_GameState_C
local M = UnLua.Class()

function M:ReceiveBeginPlay()
    local QBCore = require '/QBCore/qb-core/core':GetCoreObject()
    UE.UGameplayStatics.GetGameState(self).QBCore = QBCore
    _G['QBCore'] = QBCore
end

-- function M:ReceiveEndPlay()
-- end

return M