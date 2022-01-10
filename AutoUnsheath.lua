local autoUnsheathFrame = CreateFrame("Frame")

autoUnsheathFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
autoUnsheathFrame:RegisterEvent("UNIT_AURA")
autoUnsheathFrame:RegisterEvent("LOOT_CLOSED")
autoUnsheathFrame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
autoUnsheathFrame:RegisterEvent("ADDON_LOADED")
autoUnsheathFrame:RegisterEvent("PLAYER_LOGIN")
autoUnsheathFrame:RegisterEvent("PLAYER_LOGOUT")

local rangedClasses = {"HUNTER", "ROGUE", "WARRIOR", "MAGE", "PRIEST", "WARLOCK"}

SheathState = {
    NONE = 1,
    MELEE = 2,
    RANGED = 3,
}

local function initTable()
    if type(_G["AUTOUNSHEATH_CHAR"]) ~= "table" then
        _G["AUTOUNSHEATH_CHAR"] = {}
    end
    AutoUnsheath = _G["AUTOUNSHEATH_CHAR"]
    if type(_G["AUTOUNSHEATH"]) ~= "table" then
        _G["AUTOUNSHEATH"] = {}
    end
    GAutoUnsheath = _G["AUTOUNSHEATH"]
    if type(AutoUnsheath.RANGED) ~= "boolean" then
        AutoUnsheath.RANGED = false
    end
    if type(GAutoUnsheath.MUTE) ~= "boolean" then
        AutoUnsheath.MUTE = false
    end
end

local function saveState()
    _G["AUTOUNSHEATH_CHAR"] = AutoUnsheath
    _G["AUTOUNSHEATH"] = GAutoUnsheath
end

local function delay(tick)
    local th = coroutine.running()
    C_Timer.After(tick, function() coroutine.resume(th) end)
    coroutine.yield()
end

local function determineUnsheathId()
    local function classIsRanged(class)
        for _, rangedClass in ipairs(rangedClasses) do
            if rangedClass == class then
                return true
            end
        end
        return false
    end

    local _, playerClass, _ = UnitClass("player");
    if (AutoUnsheath.RANGED and classIsRanged(playerClass)) then
        return SheathState.RANGED
    end

    return SheathState.MELEE
end

local function unsheathWeapons(targetState)
    while GetSheathState() ~= targetState do
        ToggleSheath()
        delay(0.5)
    end
end


local function unsheathUpdate()
    if InCombatLockdown() then
        return
    end

    local _, playerClass, _ = UnitClass("player");
    if playerClass == "SHAMAN" or playerClass == "DRUID" then
        if GetShapeshiftForm() ~= 0 then
            return
        end
    end

    local unsheathId = determineUnsheathId()

    if (not UnitAffectingCombat('player')) then
        unsheathWeapons(unsheathId)
    end
    unsheathWeapons(unsheathId)
end

local function delayedUpdate()
    C_Timer.After(3, unsheathUpdate)
end

local function start(_, event)
    if ((event == "PLAYER_LOGIN") or (event == "ADDON_LOADED")) then
        initTable()
        autoUnsheathFrame:UnregisterEvent("PLAYER_LOGIN")
        autoUnsheathFrame:UnregisterEvent("ADDON_LOADED")
    elseif (event == "PLAYER_LOGOUT") then
        saveState()
        autoUnsheathFrame:UnregisterEvent("PLAYER_LOGOUT")
    end
    delayedUpdate()
end

autoUnsheathFrame:SetScript("OnEvent", start);