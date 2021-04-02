local AddonName, AddonTable = ...
local AT = AddonTable
local GUI = {}
local Settings

AT.GUI = {}

AT.GUI.Show = function(NewSettings)
    Settings = NewSettings or Settings
    GUI.Show()
end

AT.GUI.AddMistake = function(Mistake)
    GUI.AddMistake(Mistake)
end

AT.GUI.Clear = function()
    GUI.Clear()
end

local Sizes = {}
Sizes.ButtonHeight = 20
Sizes.ButtonWidth = 50
Sizes.ButtonsInset = 4

GUI.CreateFrame = function(Name, Parent)
    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    f:SetFrameStrata("LOW")

    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        -- bgFile = "Interface/FrameGeneral/UI-Background-Rock",
        -- bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        -- bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
        -- edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
        -- edgeSize = 16,
        -- insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0.3, 0.3, 0.2, 0.5)
    return f
end

GUI.MakeFrameDraggable = function(f)
    f:SetClampedToScreen()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

GUI.Show = function()
    local Mover = GUI.CreateFrame(nil, UIParent)
    GUI.MakeFrameDraggable(Mover)
    Mover:HookScript("OnDragStop", function(self)
        Settings.MainPoint = {self:GetPoint()}
    end)
    Mover:SetPoint(unpack(Settings.MainPoint or {"CENTER", 0, 0}))
    Mover:SetSize(100, 36)

    local Caption = AT.Utils.CreateFontString(Mover, "Encounter\nMistakes", 12)
    Caption:SetAllPoints()
    Caption:SetTextColor(1, 0.82, 0)

    local ButtonsFrame = GUI.CreateFrame(nil, Mover)
    GUI.ButtonsFrame = ButtonsFrame

    ButtonsFrame:SetPoint("TOP", Mover, "BOTTOM", 0, 2)

    GUI.ResizeButtonsFrame()
end

local ButtonsPool = {}
local Buttons = {}
GUI.GetButton = function()
    local B
    if #ButtonsPool > 0 then
        B = table.remove(ButtonsPool)
    else
        B = CreateFrame("Button", nil, GUI.ButtonsFrame, "UIPanelButtonTemplate")
    end

    table.insert(Buttons, B)
    return B
end

local Mistakes = {}
GUI.AddMistake = function(Mistake)
    if Mistakes[Mistake.Name] then return end
    Mistakes[Mistake.Name] = Mistake

    local B = GUI.GetButton()

    if GUI.LastAnchor then
        B:SetPoint("TOP", GUI.LastAnchor, "BOTTOM")
    else
        B:SetPoint("TOP", GUI.ButtonsFrame, "TOP", 0, -Sizes.ButtonsInset)
    end
    GUI.LastAnchor = B

    B:SetSize(Sizes.ButtonWidth, Sizes.ButtonHeight)
    B:SetText(#Buttons)

    B.Mistake = Mistake
    B:SetScript("OnClick", function(self, ...)
        GUI.ShowMistakeDetails(self, self.Mistake)
    end)

    B:Show()

    GUI.ResizeButtonsFrame()
end

GUI.ResizeButtonsFrame = function()
    GUI.ButtonsFrame:SetSize(
        Sizes.ButtonWidth + Sizes.ButtonsInset * 2,
        Sizes.ButtonHeight * #Buttons + Sizes.ButtonsInset * 2
    )
end

GUI.Clear = function()
    GUI.LastAnchor = nil

    while #Buttons > 0 do
        local B = table.remove(Buttons)
        table.insert(ButtonsPool, B)
        B:Hide()
    end

    Mistakes = {}

    GUI.ResizeButtonsFrame()
end

GUI.ShowMistakeDetails = function(Button, Mistake)
    local C = WrapTextInColorCode -- usage: WrapTextInColorCode("Black text", "ff000000")
    local YellowColor = "ffffbf00"
    local GreyColor = "ff4f4f4f"

    local Text = C(Mistake.Name, YellowColor).."\n"..Mistake.Text
    if Mistake.CountByPlayers then
        Text = Text.."\n\n"..C("Players affected:", GreyColor)

        for Player, Count in pairs(Mistake.CountByPlayers) do
            Text = Text.."\n"..C(Player, AT.Utils.GetUnitClassColor(Player)).." - "..Count
        end
    end

    GameTooltip:SetOwner(Button, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(Text, 1, 1, 1, 1, true)
    GameTooltip:Show()
end
