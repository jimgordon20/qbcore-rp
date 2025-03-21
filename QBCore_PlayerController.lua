---@type QBCore_PlayerController_C
local M = UnLua.Class()

local function FetchCharacters(self)
    local DatabaseSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UClass.Load('/QBCore/B_DatabaseSubsystem.B_DatabaseSubsystem_C'))
    local DB = DatabaseSubsystem:GetDatabase()
    local result = DB:Select('SELECT * FROM players WHERE license = "license:qwerty" ORDER BY cid DESC', {})
    if not result then print('[QBCore] Error: Couldn\'t load PlayerData for ') return '[]' end

    return result
end

function M:ReceiveBeginPlay()
    if not self:HasAuthority() then
        RegisterClientEvent('qb-multicharacter:client:ShowMulticharacter', function(Characters)
            local WidgetClass = UE.UClass.Load('/QBCore/MultiCharacter/multicharacter.multicharacter_C')
            local Widget = UE.UWidgetBlueprintLibrary.GetAllWidgetsOfClass(self, nil, WidgetClass, false):ToTable()[1]
            if Widget then
                Widget.CharContainer:ClearChildren()
                Widget:PopulateCharData(Characters)
                return
            end

            UE.UKismetSystemLibrary.Delay(self, 1.0)

            Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load("/QBCore/MultiCharacter/multicharacter.multicharacter_C"), self)
            if not Widget then
                print('[QBCore] Error: Couldn\'t create multicharacter widget')
                return
            end
    
            Widget:PopulateCharData(Characters)
            Widget:AddToViewport(0)
        end)
    else
        -- Server alternative for opening multicharacter
        RegisterServerEvent('qb-multicharacter:server:ShowMulticharacter', function(source) -- source isn't passed yet, WIP
            local Characters = FetchCharacters(self)
            TriggerClientEvent('qb-multicharacter:client:ShowMulticharacter', self, Characters)
        end)

        RegisterServerEvent('qb-multicharacter:server:Login', function(CitizenID)
            if CitizenID then
                QBCore.Player.Login(self, CitizenID)
            end
        end)

        RegisterServerEvent('qb-multicharacter:server:NewCharacter', function(CharInfoStruct, CID)
            local Data = {
                CharInfo = json.decode(CharInfoStruct),
                CID = CID,
            }
            QBCore.Player.Login(self, false, Data)
        end)

        RegisterServerEvent('qb-multicharacter:server:DeleteCharacter', function(CitizenID)
            if CitizenID then
                QBCore.Player.DeleteCharacter(self, CitizenID)
                local Characters = FetchCharacters(self)
                TriggerClientEvent('qb-multicharacter:client:ShowMulticharacter', self, Characters)
            end
        end)

        -- Player controller initialization
        local Characters = FetchCharacters(self)
        coroutine.resume(coroutine.create(function(PC, Duration)
            UE.UKismetSystemLibrary.Delay(PC, Duration)
            TriggerClientEvent('qb-multicharacter:client:ShowMulticharacter', self, Characters)
        end), self, 1.0)
    end
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

return M
