local MultiCharacter = UnLua.Class()

-- function MultiCharacter:ReceiveBeginPlay()
--     if not self:HasAuthority() then return end
-- end

function MultiCharacter:HandlePlay(CitizenID)
    self:GetOwningPlayer():Login_Server(CitizenID)
end

function MultiCharacter:HandleNewChar(CharInfoStruct, CID)
    self:GetOwningPlayer():NewCharacter_Server(CharInfoStruct, CID)
end

return MultiCharacter