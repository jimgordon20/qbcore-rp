local M = UnLua.Class()

-- function M:ReceiveBeginPlay()
-- end

function M:HandlePlay(CitizenID)
    self:GetOwningPlayer():Login_Server(CitizenID)
end

function M:HandleNewChar(CharInfoStruct, CID)
    self:GetOwningPlayer():NewCharacter_Server(CharInfoStruct, CID)
end

function M:HandleDeleteChar(CitizenID)
    self:GetOwningPlayer():DeleteCharacter_Server(CitizenID)
    self:RefreshChars()
end

function M:RefreshChars()
    self:GetOwningPlayer():ShowMulticharacter_Server()
end

return M
