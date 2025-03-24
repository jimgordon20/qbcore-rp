local M = UnLua.Class()
local CharacterButtons = {}

function M:OnRep_CurrentChar()
    if self.DeleteConfBorder then
        self.DeleteConfBorder:SetVisibility(UE.ESlateVisibility.Hidden)
    end

    for k, v in pairs(CharacterButtons) do
        if k == self.CurrentChar then
            v.CharacterButton.WidgetStyle.Normal.OutlineSettings.Color.SpecifiedColor = UE.FLinearColor(0.723, 0.610, 0.0, 1.0)
            if v.HasCharacter then
                self.NewCharButton:SetVisibility(UE.ESlateVisibility.Hidden)
                self.PlayButton:SetVisibility(UE.ESlateVisibility.Visible)
                self.DeleteButton:SetVisibility(UE.ESlateVisibility.Visible)
            else
                self.NewCharButton:SetVisibility(UE.ESlateVisibility.Visible)
                self.PlayButton:SetVisibility(UE.ESlateVisibility.Hidden)
                self.DeleteButton:SetVisibility(UE.ESlateVisibility.Hidden)
            end
        else
            v.CharacterButton.WidgetStyle.Normal.OutlineSettings.Color.SpecifiedColor = UE.FLinearColor(0.000304, 0.973446, 0.623961, 1.0)
        end
    end
end

function M:PopulateCharData(CharactersJSON)
    local MyController = GetPlayerController()
    local WidgetClass = UE.UClass.Load('/QBCore/MultiCharacter/multicharacter.multicharacter_C')
    local ExistingWidget = UE.UWidgetBlueprintLibrary.GetAllWidgetsOfClass(MyController, nil, WidgetClass, false):ToTable()[1]
    if ExistingWidget then
        ExistingWidget.CharContainer:ClearChildren()
    end

    local Characters = json.decode(CharactersJSON)
    local CharContainer = self.CharContainer
    for i = 1, 5 do
        local Button = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load('/QBCore/MultiCharacter/WB_CharButton.WB_CharButton_C'), MyController)
        Button.ButtonID = i
        Button.Parent = self
        for _, v in pairs(Characters) do
            if i == tonumber(v.cid) then
                local CharInfo = json.decode(v.charinfo)
                Button.CitizenID = v.citizenid
                Button.CharName:SetText(CharInfo.firstname .. ' ' .. CharInfo.lastname)
                Button.HasCharacter = true
            end
        end

        CharacterButtons[i] = Button
        CharContainer:AddChildToVerticalBox(Button)
    end

    self.CurrentChar = 1
    self:OnRep_CurrentChar() -- Don't think I should have to call this manually, but it doesn't call automatically the first time
end

-- Play Button Handler
M['BndEvt__WBP_qb-multicharacter_PlayButton_K2Node_ComponentBoundEvent_0_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    TriggerServerEvent('qb-multicharacter:server:Login', CharacterButtons[self.CurrentChar].CitizenID)
    self:SetVisibility(UE.ESlateVisibility.Hidden)
    -- UnFocus UI input too
end

-- New Character Button Handler
M['BndEvt__WBP_qb-multicharacter_NewCharButton_K2Node_ComponentBoundEvent_2_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    self.NewCharContainer:SetVisibility(UE.ESlateVisibility.Visible)
end

local function TrimString(Text)
    return string.gsub(Text, "^%s*(.-)%s*$", "%1")
end

-- New Character Modal Handler
M['BndEvt__WBP_qb-multicharacter_CreateChar_K2Node_ComponentBoundEvent_4_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    -- Validate input values
    local Valid = true
    local FirstName = self.FirstNameInput:GetText()
    local LastName = self.LastNameInput:GetText()
    local Age = self.AgeInput:GetText()
    local Nationality = self.NationalityInput:GetText()
    local SexCombo = self.SexCombo:GetSelectedOption()

    local IncorrectBrush = UE.FSlateBrush()
    IncorrectBrush.DrawAs = 1
    local CorrectBrush = UE.FSlateBrush()
    CorrectBrush.DrawAs = 0

    if not FirstName or TrimString(FirstName) == '' then
        self.FNBorder:SetBrush(IncorrectBrush)
        Valid = false
    else
        self.FNBorder:SetBrush(CorrectBrush)
    end

    if not LastName or TrimString(LastName) == '' then
        self.LNBorder:SetBrush(IncorrectBrush)
        Valid = false
    else
        self.LNBorder:SetBrush(CorrectBrush)
    end

    if not Age or TrimString(Age) == '' then
        self.AgeBorder:SetBrush(IncorrectBrush)
        Valid = false
    else
        self.AgeBorder:SetBrush(CorrectBrush)
    end

    if not Nationality or TrimString(Nationality) == '' then
        self.NationalityBorder:SetBrush(IncorrectBrush)
        Valid = false
    else
        self.NationalityBorder:SetBrush(CorrectBrush)
    end

    if not Valid or CharacterButtons[self.CurrentChar].HasCharacter then
        return
    end

    TriggerServerEvent('qb-multicharacter:server:NewCharacter',
        {
            firstname = FirstName,
            lastname = LastName,
            birthdate = Age,
            nationality = Nationality,
            sex = SexCombo,
        }, self.CurrentChar
    )

    self:SetVisibility(UE.ESlateVisibility.Hidden)
end

-- New Character Modal Exit Handler
M['BndEvt__WBP_qb-multicharacter_ExitButton_K2Node_ComponentBoundEvent_3_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    self:SetVisibility(UE.ESlateVisibility.Hidden)
end

-- Delete Character Button Handler
M['BndEvt__WBP_qb-multicharacter_DeleteButton_K2Node_ComponentBoundEvent_1_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    self.DeleteConfBorder:SetVisibility(UE.ESlateVisibility.Visible)
end

-- Cancel Delete Character Handler
M['BndEvt__multicharacter_CancelDeleteChar_K2Node_ComponentBoundEvent_5_OnButtonReleasedEvent__DelegateSignature()'] = function(self)
    self.DeleteConfBorder:SetVisibility(UE.ESlateVisibility.Hidden)
end

-- Delete Character Modal Handler
M['BndEvt__multicharacter_DeleteChar_K2Node_ComponentBoundEvent_6_OnButtonReleasedEvent__DelegateSignature'] = function(self)
    if CharacterButtons[self.CurrentChar].HasCharacter then
        TriggerServerEvent('qb-multicharacter:server:DeleteCharacter', CharacterButtons[self.CurrentChar].CitizenID)
    end
    self.DeleteConfBorder:SetVisibility(UE.ESlateVisibility.Hidden)
    TriggerServerEvent('qb-multicharacter:server:ShowMulticharacter')
end

return M
