local M = UnLua.Class()

-- function M:ReceiveBeginPlay()
-- end

function M:HandlePlay(CitizenID)
    TriggerServerEvent('qb-multicharacter:server:Login', CitizenID)
end

function M:HandleNewChar(CharInfoStruct, CID)
    TriggerServerEvent('qb-multicharacter:server:NewCharacter', CharInfoStruct, CID)
end

function M:HandleDeleteChar(CitizenID)
    TriggerServerEvent('qb-multicharacter:server:DeleteCharacter', CitizenID)
end

return M
