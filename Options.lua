Config = {
    Panel = CreateFrame("Frame")
}
local panel = Config.Panel
local soundFileIds = {567395, 567430, 567456, 567473, 567498, 567506, 569839, 569842}

panel.name = "AutoUnsheath"
panel:Hide()


local function unsheathBowAction(_, checked)
    AutoUnsheath.RANGED = checked
end

local function muteSoundAction(_, checked)
    GAutoUnsheath.MUTE = checked
    local apicall = nil
    if checked then
        apicall = MuteSoundFile
    else
        apicall = UnmuteSoundFile
    end

    for _, id in ipairs(soundFileIds) do
        apicall(id)
    end
end

local function CreateCheckbox(id, label, description, onclick)
    local checkbox = CreateFrame(
        "CheckButton",
        "AutoUnsheath" .. id,
        panel,
        "InterfaceOptionsCheckButtonTemplate"
    )
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        onclick(self, checked and true or false)
    end)
    checkbox.label = _G[checkbox:GetName() .. "Text"]
    checkbox.label:SetText(label)
    checkbox.tooltipText = label
    checkbox.tooltipRequirement = description
    return checkbox
end

function Config:Open()
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
end

function Config:Show()
    AutoUnsheath = _G["AUTOUNSHEATH_CHAR"]
    GAutoUnsheath = _G["AUTOUNSHEATH"]

    local configHeader = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    configHeader:SetPoint("TOP", 0, -25)
    configHeader:SetText("AutoUnsheath")

    local unsheathBow = CreateCheckbox(
        1,
        "Unsheath ranged weapon.",
        "If this is checked, ranged weapons will be automatically unsheathed instead of melee weapons",
        unsheathBowAction
    )
    unsheathBow:SetPoint("TOPLEFT", configHeader, "BOTTOMLEFT", -200, -30)

    local muteSound = CreateCheckbox(
        2,
        "Mute sheath/unsheath sounds",
        "If this is checked, no sound will be played when sheathing/unsheathing weapons",
        muteSoundAction
    )
    muteSound:SetPoint("TOPLEFT", unsheathBow, "BOTTOMLEFT", 0, -10)

    local function init()
        unsheathBow:SetChecked(AutoUnsheath.RANGED)
        muteSound:SetChecked(GAutoUnsheath.MUTE)
    end

    init()

    self:SetScript("OnShow", init)
end

panel:SetScript("OnShow", function(self) Config.Show(self) end)

InterfaceOptions_AddCategory(panel)