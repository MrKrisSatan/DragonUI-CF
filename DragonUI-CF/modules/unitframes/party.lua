-- ===============================================================
-- DRAGONUI PARTY FRAMES MODULE
-- ===============================================================
local addon = select(2, ...)
local UF = addon.UF
local L = addon.L

-- ===============================================================
-- EARLY EXIT CHECK
-- ===============================================================
-- Simplified: Only check if addon.db exists, not specifically unitframe.party
if not addon or not addon.db then
    return -- Exit early if database not ready
end

-- ===============================================================
-- IMPORTS AND GLOBALS
-- ===============================================================

-- Cache globals and APIs
local _G = _G
local unpack = unpack
local select = select
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitName, UnitClass = UnitName, UnitClass
local UnitExists, UnitIsConnected = UnitExists, UnitIsConnected
local UnitInRange, UnitIsDeadOrGhost = UnitInRange, UnitIsDeadOrGhost
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4

-- ===============================================================
-- MODULE NAMESPACE AND STORAGE
-- ===============================================================

-- Module namespace
local PartyFrames = {}
addon.PartyFrames = PartyFrames

PartyFrames.textElements = {}
PartyFrames.anchor = nil
PartyFrames.initialized = false

-- ===============================================================
-- CONSTANTS AND CONFIGURATION
-- ===============================================================

-- Texture paths from shared core (single source of truth)
local TEXTURES = UF.TEXTURES.party
local SIMPLE_RESOURCE_BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

-- ===============================================================
-- CENTRALIZED SYSTEM INTEGRATION
-- ===============================================================

-- Create auxiliary frame for anchoring (similar to target.lua)
local function CreatePartyAnchorFrame()
    if PartyFrames.anchor then
        return PartyFrames.anchor
    end

    -- Use centralized function from core.lua
    -- Initial size - will be updated dynamically based on orientation
    PartyFrames.anchor = addon.CreateUIFrame(130, 300, "PartyFrames")

    return PartyFrames.anchor
end

-- Update anchor size based on orientation
local IsCompactPartyFramesEnabled
local ReanchorCompactPartyFrame
local RefreshRaidStylePartyFrames
local IsRaidStylePartyFramesEnabled
local ShouldAnyPartyFramesBeVisible
local RAID_STYLE_COLUMNS = 2
local RAID_STYLE_ROWS = 2
local RAID_STYLE_FRAME_WIDTH = 142
local RAID_STYLE_FRAME_HEIGHT = 42
local RAID_STYLE_COLUMN_SPACING = 6
local RAID_STYLE_ROW_SPACING = 6

local function UpdatePartyAnchorSize()
    if not PartyFrames.anchor then return end

    if IsCompactPartyFramesEnabled() then
        local frameWidth = GetRaidStyleVariant() == "classic" and 128 or RAID_STYLE_FRAME_WIDTH
        local frameHeight = GetRaidStyleVariant() == "classic" and 49 or RAID_STYLE_FRAME_HEIGHT
        local totalWidth = RAID_STYLE_COLUMNS * frameWidth + (RAID_STYLE_COLUMNS - 1) * RAID_STYLE_COLUMN_SPACING
        local totalHeight = RAID_STYLE_ROWS * frameHeight + (RAID_STYLE_ROWS - 1) * RAID_STYLE_ROW_SPACING
        PartyFrames.anchor:SetSize(totalWidth, totalHeight)
        if PartyFrames.raidStyleFrames then
            RefreshRaidStylePartyFrames(addon.EditorMode and addon.EditorMode:IsActive())
        end
        return
    end
    
    local settings = addon.db and addon.db.profile and addon.db.profile.unitframe and addon.db.profile.unitframe.party
    local orientation = settings and settings.orientation or 'vertical'
    local numMembers = MAX_PARTY_MEMBERS -- 4
    
    if orientation == 'horizontal' then
        local padding = (settings and tonumber(settings.padding_horizontal)) or 50
        local frameWidth = 120
        local frameHeight = 50
        local totalWidth = numMembers * frameWidth + (numMembers - 1) * padding
        PartyFrames.anchor:SetSize(totalWidth, frameHeight)
    else
        local padding = (settings and tonumber(settings.padding_vertical)) or 30
        local frameWidth = 130
        local frameHeight = 50
        local totalHeight = numMembers * frameHeight + (numMembers - 1) * padding
        PartyFrames.anchor:SetSize(frameWidth, totalHeight)
    end
end

local function IsCompactRaidFrameAddonLoaded()
    -- Runtime signal first: if compact raid/party frames already exist,
    -- we should treat compact mode as active regardless of addon ID.
    if _G.CompactRaidFrameManager or _G.CompactRaidFrame1 or _G.CompactPartyFrame then
        return true
    end

    -- Prefer CUF_CVar API when present (matches CompactRaidFrame reference).
    local useCompact = nil
    if CUF_CVar and CUF_CVar.GetCVarBool then
        useCompact = CUF_CVar:GetCVarBool("useCompactPartyFrames") and true or false
    elseif GetCVar then
        useCompact = (GetCVar("useCompactPartyFrames") == "1")
    end

    if useCompact then
        return true
    end

    if IsAddOnLoaded then
        -- Canonical addon folder name in this client branch.
        if IsAddOnLoaded("CompactRaidFrame") then
            return true
        end
    end

    return false
end

local function GetDefaultPartyPosX()
    return 10
end

local function GetCompactRaidPartyOffsetX()
    -- Runtime-only offset: avoids persisting shifted positions in the profile.
    if IsCompactRaidFrameAddonLoaded() then
        return 9
    end
    return 0
end

local function NormalizeCompactRaidPartyPosX(posX)
    local basePosX = posX or GetDefaultPartyPosX()

    -- Backward compatibility: old migrated defaults should fall back to base when
    -- CompactRaidFrames is not active.
    if not IsCompactRaidFrameAddonLoaded() then
        if basePosX == 19 or basePosX == 25 or basePosX == 30 then
            return GetDefaultPartyPosX()
        end
        return basePosX
    end

    -- Apply offset only for default-like positions, keep custom positions intact.
    if basePosX == 10 or basePosX == 19 or basePosX == 25 or basePosX == 30 then
        return GetDefaultPartyPosX() + GetCompactRaidPartyOffsetX()
    end

    return basePosX
end

-- Function to apply position from widgets (similar to target.lua)
local function ApplyWidgetPosition()
    if not PartyFrames.anchor then
        return
    end

    -- CRITICAL: Set BACKGROUND strata to stay behind Compact Raid Frames (which use LOW/MEDIUM)
    -- But skip strata reset during editor mode (overlay needs FULLSCREEN strata)
    if not InCombatLockdown() and not (addon.EditorMode and addon.EditorMode:IsActive()) then
        PartyFrames.anchor:SetFrameStrata('BACKGROUND')
        PartyFrames.anchor:SetFrameLevel(1)
    end

    -- Ensure configuration exists
    if not addon.db or not addon.db.profile or not addon.db.profile.widgets then
        return
    end

    local widgetConfig = addon.db.profile.widgets.party

    if widgetConfig and widgetConfig.posX and widgetConfig.posY then
        local normalizedPosX = NormalizeCompactRaidPartyPosX(widgetConfig.posX)
        if normalizedPosX ~= widgetConfig.posX then
            widgetConfig.posX = normalizedPosX
        end

        -- Use saved anchor, not always TOPLEFT
        local anchor = widgetConfig.anchor or "TOPLEFT"
        PartyFrames.anchor:ClearAllPoints()
        PartyFrames.anchor:SetPoint(anchor, UIParent, anchor, normalizedPosX, widgetConfig.posY)
    else
        -- Create default configuration if it doesn't exist
        if not addon.db.profile.widgets.party then
            addon.db.profile.widgets.party = {
                anchor = "TOPLEFT",
                posX = GetDefaultPartyPosX(),
                posY = -200
            }
        end
        PartyFrames.anchor:ClearAllPoints()
        PartyFrames.anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", GetDefaultPartyPosX(), -200)
    end
end

-- Functions required by the centralized system
function PartyFrames:LoadDefaultSettings()
    -- Ensure configuration exists in widgets
    if not addon.db.profile.widgets then
        addon.db.profile.widgets = {}
    end

    if not addon.db.profile.widgets.party then
        addon.db.profile.widgets.party = {
            anchor = "TOPLEFT",
            posX = GetDefaultPartyPosX(),
            posY = -200
        }
    end

    -- Ensure configuration exists in unitframe
    if not addon.db.profile.unitframe then
        addon.db.profile.unitframe = {}
    end

    if not addon.db.profile.unitframe.party then
        addon.db.profile.unitframe.party = {
            enabled = true,
            useRaidStyle = false,
            raidStyleVariant = 'new',
            portraitless = false,
            classcolor = false,
            textFormat = 'both',
            breakUpLargeNumbers = true,
            showHealthTextAlways = false,
            showManaTextAlways = false,
            orientation = 'vertical',
            padding_vertical = 30,
            padding_horizontal = 50,
            scale = 1.0,
            override = false,
            anchor = 'TOPLEFT',
            anchorParent = 'TOPLEFT',
            x = GetDefaultPartyPosX(),
            y = -200
        }
    end
end

function PartyFrames:UpdateWidgets()
    ApplyWidgetPosition()
    UpdatePartyAnchorSize() -- Update anchor size based on orientation
    if not InCombatLockdown() then
        local step = GetPartyStep()
        local orientation = GetOrientation()
        for i = 1, MAX_PARTY_MEMBERS do
            local frame = _G['PartyMemberFrame' .. i]
            if frame and PartyFrames.anchor then
                frame:ClearAllPoints()
                if orientation == 'horizontal' then
                    local xOffset = (i - 1) * step
                    frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", xOffset, 0)
                else
                    local yOffset = (i - 1) * -step
                    frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", 0, yOffset)
                end
            end
        end
    end
end

-- Function to check if party frames should be visible
IsCompactPartyFramesEnabled = function()
    return IsRaidStylePartyFramesEnabled()
end

IsRaidStylePartyFramesEnabled = function()
    local settings = addon.db and addon.db.profile and addon.db.profile.unitframe and addon.db.profile.unitframe.party
    if settings and settings.useRaidStyle ~= nil then
        return settings.useRaidStyle and true or false
    end
    return false
end

ShouldAnyPartyFramesBeVisible = function()
    local inRaid = GetNumRaidMembers and GetNumRaidMembers() > 0
    local hidePartyInRaid = false

    if inRaid then
        if CUF_CVar and CUF_CVar.GetCVarBool then
            hidePartyInRaid = CUF_CVar:GetCVarBool("hidePartyInRaid") and true or false
        elseif GetCVarBool then
            hidePartyInRaid = GetCVarBool("hidePartyInRaid") and true or false
        else
            hidePartyInRaid = GetCVar and GetCVar("hidePartyInRaid") == "1"
        end
    end

    return (GetNumPartyMembers and GetNumPartyMembers() > 0) and not hidePartyInRaid
end

local function SetConfigCVar(name, enabled)
    local value = enabled and "1" or "0"
    if SetCVar then
        pcall(SetCVar, name, value)
    end
    if CUF_CVar and CUF_CVar.SetCVar then
        pcall(CUF_CVar.SetCVar, CUF_CVar, name, value)
    end
end

local function EnsureCompactPartyFramesLoaded()
    if _G.CompactPartyFrame or _G.CompactRaidFrameContainer or _G.CompactRaidFrame1 then
        if _G.CompactPartyFrame_Generate and not _G.CompactPartyFrame then
            pcall(_G.CompactPartyFrame_Generate)
        end
        return true
    end

    local addonNames = {
        "Blizzard_CompactRaidFrame",
        "Blizzard_CompactRaidFrames",
        "CompactRaidFrame",
        "CompactRaidFrames",
    }

    for _, addonName in ipairs(addonNames) do
        if IsAddOnLoaded and IsAddOnLoaded(addonName) then
            return true
        end

        if UIParentLoadAddOn then
            pcall(UIParentLoadAddOn, addonName)
        elseif LoadAddOn then
            pcall(LoadAddOn, addonName)
        end

        if _G.CompactPartyFrame or _G.CompactRaidFrameContainer or _G.CompactRaidFrame1 then
            if _G.CompactPartyFrame_Generate and not _G.CompactPartyFrame then
                pcall(_G.CompactPartyFrame_Generate)
            end
            return true
        end
    end

    return false
end

local function GetCompactPartyPrimaryFrame()
    if _G.CompactPartyFrame_Generate and not _G.CompactPartyFrame then
        local ok = pcall(_G.CompactPartyFrame_Generate)
        if not ok then
            -- Fall through to other compact frame variants.
        end
    end

    if _G.CompactPartyFrame and _G.CompactPartyFrame.GetObjectType then
        return _G.CompactPartyFrame
    end

    if _G.CompactRaidFrameContainer and _G.CompactRaidFrameContainer.GetObjectType then
        return _G.CompactRaidFrameContainer
    end

    if _G.CompactRaidFrame1 and _G.CompactRaidFrame1.GetParent then
        local parent = _G.CompactRaidFrame1:GetParent()
        if parent and parent.GetObjectType then
            return parent
        end
    end

    return nil
end

local function RefreshCompactPartyFrameDisplay()
    -- DragonUI-CF owns the raid-style party view directly.
end

local function ApplyCompactPartyFramesMode()
    SetConfigCVar("useCompactPartyFrames", false)
    if _G.CompactPartyFrame and _G.CompactPartyFrame.Hide then
        _G.CompactPartyFrame:Hide()
    end
    if _G.CompactRaidFrameContainer and _G.CompactRaidFrameContainer.Hide then
        _G.CompactRaidFrameContainer:Hide()
    end
    if _G.CompactRaidFrameManager and _G.CompactRaidFrameManager.Hide then
        _G.CompactRaidFrameManager:Hide()
    end
    RefreshCompactPartyFrameDisplay()
end

local function ParseHexColor(hex)
    if type(hex) ~= "string" then
        return nil
    end

    hex = hex:gsub("#", "")
    if #hex == 8 then
        hex = hex:sub(3)
    end
    if #hex ~= 6 then
        return nil
    end

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return nil
    end

    return r / 255, g / 255, b / 255
end

local function GetRaidStyleMemberColor(unit)
    if unit
        and type(ClassForge) == "table"
        and type(ClassForge.GetDataForUnit) == "function"
        and type(ClassForge.IsGroupFrameColoringEnabled) == "function"
        and (not addon.IsEmbeddedClassForgeEnabled or addon:IsEmbeddedClassForgeEnabled())
        and ClassForge:IsGroupFrameColoringEnabled()
    then
        local data = ClassForge:GetDataForUnit(unit)
        local r, g, b = ParseHexColor(data and data.color)
        if r and g and b then
            return r, g, b
        end
    end

    return GetClassColor(unit)
end

local function GetRaidStyleHealthColor(unit)
    if unit and UnitIsDeadOrGhost(unit) then
        return 0.35, 0.35, 0.35
    end
    return 0.15, 0.85, 0.2
end

local function GetRaidStylePowerColor(unit)
    local powerType = unit and UnitPowerType(unit) or 0
    if PowerBarColor and PowerBarColor[powerType] then
        local color = PowerBarColor[powerType]
        return color.r or 0.2, color.g or 0.4, color.b or 0.95
    end
    return 0.2, 0.4, 0.95
end

local function ApplyRaidStyleFrameLayout(frame)
    local variant = GetRaidStyleVariant()
    local isClassic = variant == "classic"

    if isClassic then
        frame:SetSize(128, 57)
        frame:SetBackdropColor(0, 0, 0, 0)
        frame:SetBackdropBorderColor(0, 0, 0, 0)
        frame.classTint:SetVertexColor(1, 1, 1, 0)

        if frame.backgroundTex then frame.backgroundTex:Show() end
        if frame.borderTex then frame.borderTex:Show() end
        if frame.portrait then
            frame.portrait:SetSize(28, 28)
            frame.portrait:ClearAllPoints()
            frame.portrait:SetPoint("TOPLEFT", 7, -6)
            frame.portrait:Show()
        end

        frame.name:ClearAllPoints()
        frame.name:SetPoint("TOPLEFT", 40, -5)
        frame.name:SetPoint("TOPRIGHT", -24, -5)

        frame.classIcon:SetPoint("TOPRIGHT", -6, -6)
        frame.healthBg:SetPoint("TOPLEFT", 38, -18)
        frame.healthBg:SetPoint("TOPRIGHT", -6, -18)
        frame.healthBg:SetHeight(10)
        frame.powerBg:SetPoint("TOPLEFT", 38, -29)
        frame.powerBg:SetPoint("TOPRIGHT", -6, -29)
        frame.powerBg:SetHeight(6)
        if frame.energyBox then
            frame.energyBox:SetPoint("TOPLEFT", frame.powerBg, "BOTTOMLEFT", 0, -2)
            frame.energyBox:SetPoint("TOPRIGHT", frame.powerBg, "BOTTOMRIGHT", 0, -2)
            frame.energyBox:SetHeight(6)
        end
        if frame.energyBg then
            frame.energyBg:SetPoint("TOPLEFT", frame.energyBox, "TOPLEFT", 1, -1)
            frame.energyBg:SetPoint("BOTTOMRIGHT", frame.energyBox, "BOTTOMRIGHT", -1, 1)
        end
        if frame.rageBox then
            frame.rageBox:SetPoint("TOPLEFT", frame.energyBox, "BOTTOMLEFT", 0, -2)
            frame.rageBox:SetPoint("TOPRIGHT", frame.energyBox, "BOTTOMRIGHT", 0, -2)
            frame.rageBox:SetHeight(6)
        end
        if frame.rageBg then
            frame.rageBg:SetPoint("TOPLEFT", frame.rageBox, "TOPLEFT", 1, -1)
            frame.rageBg:SetPoint("BOTTOMRIGHT", frame.rageBox, "BOTTOMRIGHT", -1, 1)
        end
    else
        frame:SetSize(RAID_STYLE_FRAME_WIDTH, 50)
        frame:SetBackdropColor(0.03, 0.03, 0.04, 0.92)
        frame:SetBackdropBorderColor(0.16, 0.14, 0.12, 0.9)

        if frame.backgroundTex then frame.backgroundTex:Hide() end
        if frame.borderTex then frame.borderTex:Hide() end
        if frame.portrait then frame.portrait:Hide() end

        frame.name:ClearAllPoints()
        frame.name:SetPoint("TOPLEFT", 8, -6)
        frame.name:SetPoint("TOPRIGHT", -24, -6)

        frame.classIcon:SetPoint("TOPRIGHT", -6, -6)
        frame.healthBg:SetPoint("TOPLEFT", 5, -20)
        frame.healthBg:SetPoint("TOPRIGHT", -5, -20)
        frame.healthBg:SetHeight(12)
        frame.powerBg:SetPoint("TOPLEFT", frame.healthBg, "BOTTOMLEFT", 0, -4)
        frame.powerBg:SetPoint("TOPRIGHT", frame.healthBg, "BOTTOMRIGHT", 0, -4)
        frame.powerBg:SetHeight(6)
        if frame.energyBox then
            frame.energyBox:SetPoint("TOPLEFT", frame.powerBg, "BOTTOMLEFT", 0, -2)
            frame.energyBox:SetPoint("TOPRIGHT", frame.powerBg, "BOTTOMRIGHT", 0, -2)
            frame.energyBox:SetHeight(6)
        end
        if frame.energyBg then
            frame.energyBg:SetPoint("TOPLEFT", frame.energyBox, "TOPLEFT", 1, -1)
            frame.energyBg:SetPoint("BOTTOMRIGHT", frame.energyBox, "BOTTOMRIGHT", -1, 1)
        end
        if frame.rageBox then
            frame.rageBox:SetPoint("TOPLEFT", frame.energyBox, "BOTTOMLEFT", 0, -2)
            frame.rageBox:SetPoint("TOPRIGHT", frame.energyBox, "BOTTOMRIGHT", 0, -2)
            frame.rageBox:SetHeight(6)
        end
        if frame.rageBg then
            frame.rageBg:SetPoint("TOPLEFT", frame.rageBox, "TOPLEFT", 1, -1)
            frame.rageBg:SetPoint("BOTTOMRIGHT", frame.rageBox, "BOTTOMRIGHT", -1, 1)
        end
    end

    if frame.energyBar and frame.energyBg then
        frame.energyBar:ClearAllPoints()
        frame.energyBar:SetPoint("TOPLEFT", frame.energyBg, "TOPLEFT", 0, 0)
        frame.energyBar:SetPoint("BOTTOMRIGHT", frame.energyBg, "BOTTOMRIGHT", 0, 0)
    end
    if frame.rageBar and frame.rageBg then
        frame.rageBar:ClearAllPoints()
        frame.rageBar:SetPoint("TOPLEFT", frame.rageBg, "TOPLEFT", 0, 0)
        frame.rageBar:SetPoint("BOTTOMRIGHT", frame.rageBg, "BOTTOMRIGHT", 0, 0)
    end
end

local function EnsureRaidStylePartyFrames()
    if PartyFrames.raidStyleFrames then
        return
    end

    PartyFrames.raidStyleFrames = {}

    for i = 1, MAX_PARTY_MEMBERS do
        local frame = CreateFrame("Button", "DragonUIRaidStylePartyFrame" .. i, PartyFrames.anchor, "SecureUnitButtonTemplate")
        frame:SetSize(RAID_STYLE_FRAME_WIDTH, RAID_STYLE_FRAME_HEIGHT)
        frame:RegisterForClicks("AnyUp")
        frame:SetAttribute("unit", "party" .. i)
        frame:SetAttribute("type1", "target")
        frame.unit = "party" .. i
        frame.index = i
        frame:Hide()

        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        frame:SetBackdropColor(0.03, 0.03, 0.04, 0.92)
        frame:SetBackdropBorderColor(0.16, 0.14, 0.12, 0.9)

        frame.classTint = frame:CreateTexture(nil, "BACKGROUND")
        frame.classTint:SetPoint("TOPLEFT", 2, -2)
        frame.classTint:SetPoint("BOTTOMRIGHT", -2, 2)
        frame.classTint:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")

        frame.backgroundTex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
        frame.backgroundTex:SetTexture(TEXTURES.frame)
        frame.backgroundTex:SetTexCoord(GetPartyCoords("background"))
        frame.backgroundTex:SetSize(120, 49)
        frame.backgroundTex:SetPoint("TOPLEFT", 1, -2)

        frame.borderTex = frame:CreateTexture(nil, "BORDER", nil, 1)
        frame.borderTex:SetTexture(TEXTURES.border)
        frame.borderTex:SetSize(128, 64)
        frame.borderTex:SetPoint("TOPLEFT", 1, -2)
        frame.borderTex:Hide()

        frame.name = frame:CreateFontString(nil, "OVERLAY")
        frame.name:SetFont(UF.DEFAULT_FONT, 10, "OUTLINE")
        frame.name:SetShadowOffset(1, -1)
        frame.name:SetShadowColor(0, 0, 0, 1)
        frame.name:SetPoint("TOPLEFT", 8, -6)
        frame.name:SetPoint("TOPRIGHT", -24, -6)
        frame.name:SetJustifyH("LEFT")

        frame.classIcon = frame:CreateTexture(nil, "OVERLAY")
        frame.classIcon:SetSize(14, 14)
        frame.classIcon:SetPoint("TOPRIGHT", -6, -6)
        frame.classIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        frame.classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

        frame.portrait = frame:CreateTexture(nil, "ARTWORK", nil, 1)
        frame.portrait:SetTexCoord(0, 1, 0, 1)
        frame.portrait:Hide()

        frame.status = frame:CreateFontString(nil, "OVERLAY")
        frame.status:SetFont(UF.DEFAULT_FONT, 12, "OUTLINE")
        frame.status:SetShadowOffset(1, -1)
        frame.status:SetShadowColor(0, 0, 0, 1)
        frame.status:SetPoint("CENTER", 0, 1)
        frame.status:SetJustifyH("CENTER")

        frame.healthBg = frame:CreateTexture(nil, "ARTWORK")
        frame.healthBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.healthBg:SetVertexColor(0, 0, 0, 0.55)
        frame.healthBg:SetPoint("TOPLEFT", 5, -20)
        frame.healthBg:SetPoint("TOPRIGHT", -5, -20)
        frame.healthBg:SetHeight(12)

        frame.healthBar = CreateFrame("StatusBar", nil, frame)
        frame.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        frame.healthBar:SetPoint("TOPLEFT", frame.healthBg, "TOPLEFT", 0, 0)
        frame.healthBar:SetPoint("BOTTOMRIGHT", frame.healthBg, "BOTTOMRIGHT", 0, 0)

        frame.powerBg = frame:CreateTexture(nil, "ARTWORK")
        frame.powerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.powerBg:SetVertexColor(0, 0, 0, 0.55)
        frame.powerBg:SetPoint("TOPLEFT", frame.healthBg, "BOTTOMLEFT", 0, -4)
        frame.powerBg:SetPoint("TOPRIGHT", frame.healthBg, "BOTTOMRIGHT", 0, -4)
        frame.powerBg:SetHeight(5)

        frame.powerBar = CreateFrame("StatusBar", nil, frame)
        frame.powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        frame.powerBar:SetPoint("TOPLEFT", frame.powerBg, "TOPLEFT", 0, 0)
        frame.powerBar:SetPoint("BOTTOMRIGHT", frame.powerBg, "BOTTOMRIGHT", 0, 0)

        EnsureRaidStyleAdditionalResourceBars(frame)

        ApplyRaidStyleFrameLayout(frame)
        PartyFrames.raidStyleFrames[i] = frame
    end
end

local function LayoutRaidStylePartyFrames()
    if not PartyFrames.anchor then
        return
    end

    EnsureRaidStylePartyFrames()

    local frameWidth = GetRaidStyleVariant() == "classic" and 128 or RAID_STYLE_FRAME_WIDTH
    local frameHeight = GetRaidStyleVariant() == "classic" and 57 or 50
    local totalWidth = RAID_STYLE_COLUMNS * frameWidth + (RAID_STYLE_COLUMNS - 1) * RAID_STYLE_COLUMN_SPACING
    local totalHeight = RAID_STYLE_ROWS * frameHeight + (RAID_STYLE_ROWS - 1) * RAID_STYLE_ROW_SPACING
    PartyFrames.anchor:SetSize(totalWidth, totalHeight)

    for i, frame in ipairs(PartyFrames.raidStyleFrames) do
        ApplyRaidStyleFrameLayout(frame)
        local col = (i - 1) % RAID_STYLE_COLUMNS
        local row = math.floor((i - 1) / RAID_STYLE_COLUMNS)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", col * (frameWidth + RAID_STYLE_COLUMN_SPACING), -row * (frameHeight + RAID_STYLE_ROW_SPACING))
    end
end

local function UpdateRaidStyleAdditionalResourceBars(frame, unit)
    if not frame or not unit then
        return
    end

    if frame.energyBar then
        local current, maximum = GetUnitResourceValues(unit, 3)
        ApplyAdditionalResourceBarVisual(frame.energyBar, frame.energyBg, current, maximum, 0.93, 0.78, 0.12)
        if frame.energyBox then frame.energyBox:Show() end
    end

    if frame.rageBar then
        local current, maximum = GetUnitResourceValues(unit, 1)
        ApplyAdditionalResourceBarVisual(frame.rageBar, frame.rageBg, current, maximum, 0.86, 0.10, 0.10)
        if frame.rageBox then frame.rageBox:Show() end
    end
end

local function UpdateSingleRaidStylePartyFrame(index, preview)
    EnsureRaidStylePartyFrames()

    local frame = PartyFrames.raidStyleFrames and PartyFrames.raidStyleFrames[index]
    if not frame then
        return
    end

    local unit = frame.unit or ("party" .. index)
    local isPreview = preview or (addon.EditorMode and addon.EditorMode:IsActive())
    local shouldShow = isPreview or (IsRaidStylePartyFramesEnabled() and ShouldAnyPartyFramesBeVisible() and UnitExists(unit))

    if not IsRaidStylePartyFramesEnabled() and not isPreview then
        frame:Hide()
        return
    end

    if not shouldShow then
        frame:Hide()
        return
    end

    local classR, classG, classB = 0.4, 0.3, 0.2
    local name = "Party " .. index
    local health, healthMax = 75, 100
    local mana, manaMax = 40, 100
    local statusText = ""
    local iconTexture = "Interface\\Icons\\INV_Misc_QuestionMark"

    if not isPreview and UnitExists(unit) then
        name = UnitName(unit) or name
        classR, classG, classB = GetRaidStyleMemberColor(unit)
        health = UnitHealth(unit) or 0
        healthMax = math.max(UnitHealthMax(unit) or 1, 1)
        mana, manaMax = GetUnitResourceValues(unit, 0)

        if UnitIsDeadOrGhost(unit) then
            statusText = DEAD or "Dead"
        elseif not UnitIsConnected(unit) then
            statusText = PLAYER_OFFLINE or "Offline"
        end

        if type(ClassForge) == "table" and type(ClassForge.GetDataForUnit) == "function" then
            local data = ClassForge:GetDataForUnit(unit)
            if data and data.icon and data.icon ~= "" then
                iconTexture = data.icon
            end
        end
    else
        classR = math.min(0.25 + index * 0.12, 1)
        classG = 0.18 + index * 0.04
        classB = 0.28 + index * 0.02
    end

    frame.classTint:SetVertexColor(classR, classG, classB, GetRaidStyleVariant() == "classic" and 0.18 or 0.40)
    frame.name:SetText(name)
    frame.name:SetTextColor(1, 0.93, 0.75, 1)

    if statusText ~= "" then
        frame.status:SetText(statusText)
        frame.status:SetTextColor(0.75, 0.75, 0.75, 1)
        frame.status:Show()
    else
        frame.status:Hide()
    end

    frame.healthBar:SetMinMaxValues(0, healthMax)
    frame.healthBar:SetValue(health)
    frame.healthBar:SetStatusBarColor(GetRaidStyleHealthColor(unit))

    frame.powerBar:SetMinMaxValues(0, manaMax)
    frame.powerBar:SetValue(mana)
    frame.powerBar:SetStatusBarTexture(TEXTURES.manaBar)
    frame.powerBar:SetStatusBarColor(1, 1, 1, 1)
    UpdateRaidStyleAdditionalResourceBars(frame, unit)

    if frame.portrait then
        if GetRaidStyleVariant() == "classic" then
            if not isPreview and UnitExists(unit) then
                SetPortraitTexture(frame.portrait, unit)
            else
                frame.portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            frame.portrait:Show()
        else
            frame.portrait:Hide()
        end
    end

    frame.classIcon:SetTexture(iconTexture)
    frame:Show()
end

local function UpdateRaidStylePartyFrameMouseState()
    if not PartyFrames.raidStyleFrames then
        return
    end

    local editorActive = addon.EditorMode and addon.EditorMode:IsActive()
    for _, frame in ipairs(PartyFrames.raidStyleFrames) do
        if frame then
            frame:EnableMouse(not editorActive)
        end
    end
end

RefreshRaidStylePartyFrames = function(preview)
    if not IsRaidStylePartyFramesEnabled() and not preview then
        if PartyFrames.raidStyleFrames then
            for _, frame in ipairs(PartyFrames.raidStyleFrames) do
                frame:Hide()
            end
        end
        return
    end

    LayoutRaidStylePartyFrames()
    for i = 1, MAX_PARTY_MEMBERS do
        UpdateSingleRaidStylePartyFrame(i, preview)
    end
    UpdateRaidStylePartyFrameMouseState()
end

ReanchorCompactPartyFrame = function()
    if not PartyFrames.anchor or InCombatLockdown() or not IsCompactPartyFramesEnabled() then
        return
    end

    RefreshRaidStylePartyFrames(false)
end

local function IsHidePartyInRaidEnabled()
    if CUF_CVar and CUF_CVar.GetCVarBool then
        return CUF_CVar:GetCVarBool("hidePartyInRaid") and true or false
    end

    if GetCVarBool then
        return GetCVarBool("hidePartyInRaid") and true or false
    end

    return GetCVar and GetCVar("hidePartyInRaid") == "1"
end

local function ShouldHidePartyFramesInRaid()
    return (GetNumRaidMembers and GetNumRaidMembers() > 0) and IsHidePartyInRaidEnabled()
end

local function ShouldPartyFramesBeVisible()
    return ShouldAnyPartyFramesBeVisible() and not IsCompactPartyFramesEnabled()
end

-- Test functions for the editor
local function ShowPartyFramesTest()
    -- Update anchor size for editor mode
    UpdatePartyAnchorSize()
    -- Raise overlay strata so it appears ABOVE fake party frames
    if PartyFrames.anchor then
        PartyFrames.anchor:SetFrameStrata('FULLSCREEN')
        PartyFrames.anchor:SetFrameLevel(200)
    end

    if IsCompactPartyFramesEnabled() then
        RefreshRaidStylePartyFrames(true)
        return
    end

    -- Display party frames even if not in a group, keep strata below overlay
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame then
            frame:SetFrameStrata('BACKGROUND')
            frame:SetFrameLevel(1)
            frame:Show()
        end
    end
end

local function HidePartyFramesTest()
    -- Restore normal strata
    if PartyFrames.anchor then
        PartyFrames.anchor:SetFrameStrata('MEDIUM')
        PartyFrames.anchor:SetFrameLevel(1)
    end

    if IsCompactPartyFramesEnabled() then
        RefreshRaidStylePartyFrames(false)
        return
    end

    -- Hide empty frames when not in a party
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame and not UnitExists("party" .. i) then
            frame:Hide()
        end
    end
end

-- ===============================================================
-- HELPER FUNCTIONS
-- ===============================================================

-- Get settings helper
local function GetSettings()
    -- Perform a robust check with default values
    if not addon.db or not addon.db.profile then
        return {
            scale = 1.0,
            classcolor = false,
            breakUpLargeNumbers = true
        }
    end

    local settings = addon.db.profile.unitframe and addon.db.profile.unitframe.party

    -- If configuration doesn't exist, create it with defaults
    if not settings then
        if not addon.db.profile.unitframe then
            addon.db.profile.unitframe = {}
        end

        addon.db.profile.unitframe.party = {
            enabled = true,
            classcolor = false,
            useRaidStyle = false,
            raidStyleVariant = 'new',
            portraitless = false,
            textFormat = 'both',
            breakUpLargeNumbers = true,
            showHealthTextAlways = false,
            showManaTextAlways = false,
            orientation = 'vertical',
            padding_vertical = 30,
            padding_horizontal = 50,
            scale = 1.0,
            override = false,
            anchor = 'TOPLEFT',
            anchorParent = 'TOPLEFT',
            x = GetDefaultPartyPosX(),
            y = -200
        }
        settings = addon.db.profile.unitframe.party
    end
    
    return settings
end

-- Format numbers helper — delegates to shared TextSystem
local function FormatNumber(value)
    if not value or value == 0 then return "0" end
    return addon.TextSystem.AbbreviateLargeNumbers(value) or tostring(value)
end

-- Text formatting — delegates to shared TextSystem
local function GetFormattedText(current, max, textFormat, breakUpLargeNumbers)
    return addon.TextSystem.FormatStatusText(current, max, textFormat, breakUpLargeNumbers)
end

-- Calculate step based on orientation
local function GetPartyStep()
    local settings = GetSettings()
    local orientation = settings and settings.orientation or 'vertical'
    
    if orientation == 'horizontal' then
        local pad = (settings and tonumber(settings.padding_horizontal)) or 50
        local base = 120  -- width of party frame
        return base + pad
    else
        local pad = (settings and tonumber(settings.padding_vertical)) or 30
        local base = 49   -- height of party frame
        return base + pad
    end
end

-- Get orientation from settings
local function GetOrientation()
    local settings = GetSettings()
    return settings and settings.orientation or 'vertical'
end

local function IsPartyPortraitlessEnabled()
    local settings = GetSettings()
    return settings and settings.portraitless and true or false
end

local function GetRaidStyleVariant()
    local settings = GetSettings()
    return (settings and settings.raidStyleVariant) or "new"
end


-- Get class color helper
local function GetClassColor(unit)
    if not unit or not UnitExists(unit) then
        return 1, 1, 1
    end

    if type(ClassForge) == "table"
        and type(ClassForge.GetDataForUnit) == "function"
        and type(ClassForge.IsGroupFrameColoringEnabled) == "function"
        and (not addon.IsEmbeddedClassForgeEnabled or addon:IsEmbeddedClassForgeEnabled())
        and ClassForge:IsGroupFrameColoringEnabled()
    then
        local data = ClassForge:GetDataForUnit(unit)
        local r, g, b = ParseHexColor(data and data.color)
        if r and g and b then
            return r, g, b
        end
    end

    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS[class] then
        local color = RAID_CLASS_COLORS[class]
        return color.r, color.g, color.b
    end

    return 1, 1, 1
end

-- Get texture coordinates for party frame elements
local function GetPartyCoords(type)
    if type == "background" then
        return 0.480469, 0.949219, 0.222656, 0.414062
    elseif type == "flash" then
        return 0.480469, 0.925781, 0.453125, 0.636719
    elseif type == "status" then
        return 0.00390625, 0.472656, 0.453125, 0.644531
    end
    return 0, 1, 0, 1
end

-- Power bar texture resolver (delegates to shared core)
local function GetPowerBarTexture(unit)
    return UF.GetPartyPowerBarTexture(unit)
end

local function GetSpecificPartyPowerTexture(powerType)
    if powerType == 1 then
        return TEXTURES.rageBar
    elseif powerType == 2 then
        return TEXTURES.focusBar
    elseif powerType == 3 then
        return TEXTURES.energyBar
    elseif powerType == 6 then
        return TEXTURES.runicPowerBar
    end
    return TEXTURES.manaBar
end

local function GetUnitResourceValues(unit, powerType)
    local current = UnitPower(unit, powerType) or 0
    local maximum = UnitPowerMax(unit, powerType) or 0

    if maximum <= 0 then
        if powerType == 1 or powerType == 3 then
            maximum = 100
        else
            maximum = 1
        end
    end

    return current, maximum
end

local function ShouldShowUnitResourceBar(unit, powerType, current)
    if not unit or not UnitExists(unit) then
        return false
    end

    local activePowerType = UnitPowerType(unit)
    if activePowerType == powerType then
        return true
    end

    return (current or 0) > 0
end

local function AttachResourceBarTooltip(bar, unitProvider, powerType, label)
    if not bar or bar.DragonUIResourceTooltipHooked then
        return
    end

    if bar.EnableMouse then
        bar:EnableMouse(true)
    end

    bar:SetScript("OnEnter", function(self)
        local unit = type(unitProvider) == "function" and unitProvider(self) or unitProvider
        if not unit or not UnitExists(unit) then
            return
        end

        local current, maximum = GetUnitResourceValues(unit, powerType)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(label or POWER_TYPE_TOKEN_ENERGY or "Resource", 1, 0.82, 0)
        GameTooltip:AddLine(string.format("%d / %d", current or 0, maximum or 0), 1, 1, 1)
        GameTooltip:Show()
    end)

    bar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    bar.DragonUIResourceTooltipHooked = true
end

local function HideDragonUIPartyResourceBars(frame)
    if not frame then
        return
    end

    local fields = {
        "DragonUI_EnergyBox", "DragonUI_EnergyBg", "DragonUI_EnergyBar",
        "DragonUI_RageBox", "DragonUI_RageBg", "DragonUI_RageBar",
        "energyBox", "energyBg", "energyBar",
        "rageBox", "rageBg", "rageBar",
    }

    for _, key in ipairs(fields) do
        local region = frame[key]
        if region and region.Hide then
            region:Hide()
        end
    end
end

local function IsIgnoredPartyStatusBar(frame)
    if not frame then
        return true
    end

    local name = frame.GetName and frame:GetName()
    if name and (name:find("Health") or name:find("Mana") or name:find("Cast") or name:find("Spell")) then
        return true
    end

    return false
end

local function CollectPartyStatusBars(parent, bars, depth)
    if not parent or depth > 4 or not parent.GetChildren then
        return
    end

    for _, child in ipairs({ parent:GetChildren() }) do
        if child and child.GetObjectType and child:GetObjectType() == "StatusBar" and not IsIgnoredPartyStatusBar(child) then
            table.insert(bars, child)
        end
        CollectPartyStatusBars(child, bars, depth + 1)
    end
end

local function CollectNearbyPartyStatusBars(frame, bars)
    if not frame or not UIParent or not UIParent.GetChildren then
        return
    end

    local frameLeft = frame:GetLeft()
    local frameTop = frame:GetTop()
    if not frameLeft or not frameTop then
        return
    end

    for _, child in ipairs({ UIParent:GetChildren() }) do
        if child and child ~= frame
            and child.GetObjectType and child:GetObjectType() == "StatusBar"
            and not IsIgnoredPartyStatusBar(child) then
            local width, height = child:GetWidth() or 0, child:GetHeight() or 0
            local childLeft, childTop = child:GetLeft(), child:GetTop()
            if childLeft and childTop
                and math.abs(childLeft - frameLeft) < 60
                and math.abs(childTop - frameTop) < 60
                and width > 20 and width < 180
                and height > 2 and height < 18 then
                table.insert(bars, child)
            end
        end
    end
end

local function MovePartyBarTextRegions(bar)
    if not bar or not bar.GetRegions then
        return
    end

    for _, region in ipairs({ bar:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:ClearAllPoints()
            region:SetPoint("CENTER", bar, "CENTER", 0, 0)
            if region.SetDrawLayer then
                region:SetDrawLayer("OVERLAY", 7)
            end
        end
    end

    local textFields = { "TextString", "LeftText", "RightText", "text", "valueText" }
    for _, key in ipairs(textFields) do
        local text = bar[key]
        if text and text.ClearAllPoints and text.SetPoint then
            text:ClearAllPoints()
            text:SetPoint("CENTER", bar, "CENTER", 0, 0)
            if text.SetDrawLayer then
                text:SetDrawLayer("OVERLAY", 7)
            end
        end
    end
end

local function MovePartyClasslessResourceBars(frame)
    if not frame then
        return 0
    end

    local healthBar = _G[frame:GetName() .. "HealthBar"]
    if not healthBar then
        return 0
    end

    local bars = {}
    local index = frame.GetID and frame:GetID() or nil
    local explicitBars = {
        _G[frame:GetName() .. "EnergyBar"],
        _G[frame:GetName() .. "RageBar"],
        index and _G["PartyMemberFrame" .. index .. "EnergyBar"] or nil,
        index and _G["PartyMemberFrame" .. index .. "RageBar"] or nil,
    }

    for _, bar in ipairs(explicitBars) do
        if bar then
            table.insert(bars, bar)
        end
    end

    CollectPartyStatusBars(frame, bars, 0)
    CollectNearbyPartyStatusBars(frame, bars)

    table.sort(bars, function(a, b)
        return (a:GetTop() or 0) > (b:GetTop() or 0)
    end)

    local moved = 0
    local seen = {}
    for _, bar in ipairs(bars) do
        if bar and bar:IsShown() and not seen[bar] then
            seen[bar] = true
            moved = moved + 1
            local yOffset = -2 - ((moved - 1) * 5)

            bar:ClearAllPoints()
            bar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, yOffset)
            bar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, yOffset)
            bar:SetHeight(4)
            bar:SetFrameLevel(healthBar:GetFrameLevel() + 2)

            if bar.GetStatusBarTexture then
                local texture = bar:GetStatusBarTexture()
                if texture then
                    texture:ClearAllPoints()
                    texture:SetAllPoints(bar)
                end
            end

            MovePartyBarTextRegions(bar)

            if moved >= 2 then
                break
            end
        end
    end

    return moved
end

local function ApplyAdditionalResourceBarVisual(bar, bg, current, maximum, r, g, b)
    if not bar then
        return
    end

    maximum = math.max(maximum or 0, 100)
    current = math.max(math.min(current or 0, maximum), 0)

    -- Sensei-style plain statusbar logic: stable dark track, simple clipped fill.
    bar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
    bar:SetMinMaxValues(0, maximum)
    bar:SetValue(current)
    bar:SetStatusBarColor(r, g, b, 1)

    if bg then
        bg:SetVertexColor(0, 0, 0, 0.82)
        bg:Show()
    end

    bar:Show()
    bar:SetAlpha(1)

    local texture = bar:GetStatusBarTexture()
    if texture then
        texture:SetTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        texture:SetVertexColor(r, g, b, 1)
        texture:SetAlpha(current > 0 and 1 or 0)
        texture:SetTexCoord(0, 1, 0, 1)
        texture:Show()
    end
end

local function EnsureStandardAdditionalResourceBars(frame)
    if not frame then
        return
    end

    if not frame.DragonUI_EnergyBox then
        frame.DragonUI_EnergyBox = CreateFrame("Frame", nil, frame)
        frame.DragonUI_EnergyBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.DragonUI_EnergyBox:SetBackdropColor(0, 0, 0, 0)
        frame.DragonUI_EnergyBox:SetBackdropBorderColor(0.78, 0.62, 0.16, 0.95)
    end

    if not frame.DragonUI_EnergyBg then
        frame.DragonUI_EnergyBg = frame.DragonUI_EnergyBox:CreateTexture(nil, "ARTWORK")
        frame.DragonUI_EnergyBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.DragonUI_EnergyBg:SetVertexColor(0.35, 0.24, 0.03, 0.95)

        frame.DragonUI_EnergyBar = CreateFrame("StatusBar", nil, frame.DragonUI_EnergyBox)
        frame.DragonUI_EnergyBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.DragonUI_EnergyBar:SetMinMaxValues(0, 100)
    end

    if not frame.DragonUI_RageBox then
        frame.DragonUI_RageBox = CreateFrame("Frame", nil, frame)
        frame.DragonUI_RageBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.DragonUI_RageBox:SetBackdropColor(0, 0, 0, 0)
        frame.DragonUI_RageBox:SetBackdropBorderColor(0.78, 0.62, 0.16, 0.95)
    end

    if not frame.DragonUI_RageBg then
        frame.DragonUI_RageBg = frame.DragonUI_RageBox:CreateTexture(nil, "ARTWORK")
        frame.DragonUI_RageBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.DragonUI_RageBg:SetVertexColor(0.38, 0.04, 0.04, 0.95)

        frame.DragonUI_RageBar = CreateFrame("StatusBar", nil, frame.DragonUI_RageBox)
        frame.DragonUI_RageBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.DragonUI_RageBar:SetMinMaxValues(0, 100)
    end

    frame.DragonUI_EnergyBox:SetFrameStrata(frame:GetFrameStrata())
    frame.DragonUI_RageBox:SetFrameStrata(frame:GetFrameStrata())
    frame.DragonUI_EnergyBox:SetFrameLevel(frame:GetFrameLevel() + 24)
    frame.DragonUI_RageBox:SetFrameLevel(frame:GetFrameLevel() + 24)
    frame.DragonUI_EnergyBg:SetDrawLayer("OVERLAY", 4)
    frame.DragonUI_RageBg:SetDrawLayer("OVERLAY", 4)
    frame.DragonUI_EnergyBg:SetVertexColor(0, 0, 0, 0.82)
    frame.DragonUI_RageBg:SetVertexColor(0, 0, 0, 0.82)
    frame.DragonUI_EnergyBar:SetFrameStrata(frame.DragonUI_EnergyBox:GetFrameStrata())
    frame.DragonUI_RageBar:SetFrameStrata(frame.DragonUI_RageBox:GetFrameStrata())
    frame.DragonUI_EnergyBar:SetFrameLevel(frame.DragonUI_EnergyBox:GetFrameLevel() + 1)
    frame.DragonUI_RageBar:SetFrameLevel(frame.DragonUI_RageBox:GetFrameLevel() + 1)

    AttachResourceBarTooltip(frame.DragonUI_EnergyBox, function(self)
        local parent = self and self:GetParent()
        local id = parent and parent.GetID and parent:GetID()
        return id and ("party" .. id) or nil
    end, 3, "Energy")
    AttachResourceBarTooltip(frame.DragonUI_RageBox, function(self)
        local parent = self and self:GetParent()
        local id = parent and parent.GetID and parent:GetID()
        return id and ("party" .. id) or nil
    end, 1, "Rage")
end

local function EnsureRaidStyleAdditionalResourceBars(frame)
    if not frame then
        return
    end

    if not frame.energyBox then
        frame.energyBox = CreateFrame("Frame", nil, frame)
        frame.energyBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.energyBox:SetBackdropColor(0, 0, 0, 0)
        frame.energyBox:SetBackdropBorderColor(0.78, 0.62, 0.16, 0.95)
    end

    if not frame.energyBg then
        frame.energyBg = frame.energyBox:CreateTexture(nil, "ARTWORK")
        frame.energyBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.energyBg:SetVertexColor(0.35, 0.24, 0.03, 0.95)

        frame.energyBar = CreateFrame("StatusBar", nil, frame.energyBox)
        frame.energyBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.energyBar:SetMinMaxValues(0, 100)
    end

    if not frame.rageBox then
        frame.rageBox = CreateFrame("Frame", nil, frame)
        frame.rageBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.rageBox:SetBackdropColor(0, 0, 0, 0)
        frame.rageBox:SetBackdropBorderColor(0.78, 0.62, 0.16, 0.95)
    end

    if not frame.rageBg then
        frame.rageBg = frame.rageBox:CreateTexture(nil, "ARTWORK")
        frame.rageBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        frame.rageBg:SetVertexColor(0.38, 0.04, 0.04, 0.95)

        frame.rageBar = CreateFrame("StatusBar", nil, frame.rageBox)
        frame.rageBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.rageBar:SetMinMaxValues(0, 100)
    end

    frame.energyBox:SetFrameStrata(frame:GetFrameStrata())
    frame.rageBox:SetFrameStrata(frame:GetFrameStrata())
    frame.energyBox:SetFrameLevel(frame:GetFrameLevel() + 24)
    frame.rageBox:SetFrameLevel(frame:GetFrameLevel() + 24)
    frame.energyBg:SetDrawLayer("OVERLAY", 4)
    frame.rageBg:SetDrawLayer("OVERLAY", 4)
    frame.energyBg:SetVertexColor(0, 0, 0, 0.82)
    frame.rageBg:SetVertexColor(0, 0, 0, 0.82)
    frame.energyBar:SetFrameStrata(frame.energyBox:GetFrameStrata())
    frame.rageBar:SetFrameStrata(frame.rageBox:GetFrameStrata())
    frame.energyBar:SetFrameLevel(frame.energyBox:GetFrameLevel() + 1)
    frame.rageBar:SetFrameLevel(frame.rageBox:GetFrameLevel() + 1)

    AttachResourceBarTooltip(frame.energyBox, function(self)
        local parent = self and self:GetParent()
        return parent and parent.unit or nil
    end, 3, "Energy")
    AttachResourceBarTooltip(frame.rageBox, function(self)
        local parent = self and self:GetParent()
        return parent and parent.unit or nil
    end, 1, "Rage")
end

local function UpdateStandardAdditionalResourceBars(frame)
    if not frame then
        return
    end

    local index = frame.GetID and frame:GetID() or nil
    if not index then
        return
    end

    local unit = "party" .. index
    if not UnitExists(unit) then
        HideDragonUIPartyResourceBars(frame)
        return
    end

    local portraitless = IsPartyPortraitlessEnabled()
    local manabar = _G[frame:GetName() .. 'ManaBar']

    if manabar then
        if frame.DragonUI_EnergyBox then
            frame.DragonUI_EnergyBox:ClearAllPoints()
            frame.DragonUI_EnergyBox:SetPoint("TOPLEFT", manabar, "BOTTOMLEFT", 0, -2)
            frame.DragonUI_EnergyBox:SetSize(portraitless and 106 or 71, 6)
            frame.DragonUI_EnergyBox:SetAlpha(1)
            frame.DragonUI_EnergyBox:Show()
        end
        if frame.DragonUI_EnergyBg then
            frame.DragonUI_EnergyBg:ClearAllPoints()
            frame.DragonUI_EnergyBg:SetPoint("TOPLEFT", frame.DragonUI_EnergyBox, "TOPLEFT", 1, -1)
            frame.DragonUI_EnergyBg:SetPoint("BOTTOMRIGHT", frame.DragonUI_EnergyBox, "BOTTOMRIGHT", -1, 1)
            frame.DragonUI_EnergyBg:SetAlpha(1)
            frame.DragonUI_EnergyBg:Show()
        end
        if frame.DragonUI_EnergyBar then
            frame.DragonUI_EnergyBar:ClearAllPoints()
            frame.DragonUI_EnergyBar:SetPoint("TOPLEFT", frame.DragonUI_EnergyBg, "TOPLEFT", 0, 0)
            frame.DragonUI_EnergyBar:SetPoint("BOTTOMRIGHT", frame.DragonUI_EnergyBg, "BOTTOMRIGHT", 0, 0)
            frame.DragonUI_EnergyBar:SetAlpha(1)
            frame.DragonUI_EnergyBar:Show()
        end

        if frame.DragonUI_RageBox then
            frame.DragonUI_RageBox:ClearAllPoints()
            frame.DragonUI_RageBox:SetPoint("TOPLEFT", frame.DragonUI_EnergyBox, "BOTTOMLEFT", 0, -2)
            frame.DragonUI_RageBox:SetSize(portraitless and 106 or 71, 6)
            frame.DragonUI_RageBox:SetAlpha(1)
            frame.DragonUI_RageBox:Show()
        end
        if frame.DragonUI_RageBg then
            frame.DragonUI_RageBg:ClearAllPoints()
            frame.DragonUI_RageBg:SetPoint("TOPLEFT", frame.DragonUI_RageBox, "TOPLEFT", 1, -1)
            frame.DragonUI_RageBg:SetPoint("BOTTOMRIGHT", frame.DragonUI_RageBox, "BOTTOMRIGHT", -1, 1)
            frame.DragonUI_RageBg:SetAlpha(1)
            frame.DragonUI_RageBg:Show()
        end
        if frame.DragonUI_RageBar then
            frame.DragonUI_RageBar:ClearAllPoints()
            frame.DragonUI_RageBar:SetPoint("TOPLEFT", frame.DragonUI_RageBg, "TOPLEFT", 0, 0)
            frame.DragonUI_RageBar:SetPoint("BOTTOMRIGHT", frame.DragonUI_RageBg, "BOTTOMRIGHT", 0, 0)
            frame.DragonUI_RageBar:SetAlpha(1)
            frame.DragonUI_RageBar:Show()
        end
    end

    if frame.DragonUI_EnergyBar then
        local current, maximum = GetUnitResourceValues(unit, 3)
        ApplyAdditionalResourceBarVisual(frame.DragonUI_EnergyBar, frame.DragonUI_EnergyBg, current, maximum, 0.93, 0.78, 0.12)
        if frame.DragonUI_EnergyBox then
            frame.DragonUI_EnergyBox:Show()
        end
    end

    if frame.DragonUI_RageBar then
        local current, maximum = GetUnitResourceValues(unit, 1)
        ApplyAdditionalResourceBarVisual(frame.DragonUI_RageBar, frame.DragonUI_RageBg, current, maximum, 0.86, 0.10, 0.10)
        if frame.DragonUI_RageBox then
            frame.DragonUI_RageBox:Show()
        end
    end
end

local function ApplyStandardPartyFrameLayout(frame)
    if not frame then
        return
    end

    local portraitless = IsPartyPortraitlessEnabled()
    local portrait = _G[frame:GetName() .. 'Portrait']
    local healthbar = _G[frame:GetName() .. 'HealthBar']
    local manabar = _G[frame:GetName() .. 'ManaBar']
    local name = _G[frame:GetName() .. 'Name']
    local flash = _G[frame:GetName() .. 'Flash']

    EnsureStandardAdditionalResourceBars(frame)

    if frame.DragonUI_BackgroundTexture then
        if portraitless then
            frame.DragonUI_BackgroundTexture:Hide()
        else
            frame.DragonUI_BackgroundTexture:Show()
        end
    end

    if frame.DragonUI_BorderFrame and frame.DragonUI_BorderFrame.texture then
        if portraitless then
            frame.DragonUI_BorderFrame.texture:Hide()
            frame.DragonUI_BorderFrame:Hide()
        else
            frame.DragonUI_BorderFrame:Show()
            frame.DragonUI_BorderFrame.texture:Show()
        end
    end

    if frame.DragonUI_PortraitlessBackground then
        if portraitless then
            frame.DragonUI_PortraitlessBackground:Show()
        else
            frame.DragonUI_PortraitlessBackground:Hide()
        end
    end

    if flash then
        if portraitless then
            flash:Hide()
        else
            flash:Show()
        end
    end

    if frame.DragonUI_PortraitlessBorder then
        frame.DragonUI_PortraitlessBorder:Hide()
    end

    if portrait then
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPLEFT", 7, -6)
        if portraitless then
            portrait:Hide()
        else
            portrait:Show()
        end
    end

    if healthbar and not InCombatLockdown() then
        healthbar:SetStatusBarTexture(TEXTURES.healthBar)
        healthbar:ClearAllPoints()
        healthbar:SetFrameLevel(1)
        healthbar:SetStatusBarColor(1, 1, 1, 1)
        if portraitless then
            healthbar:SetSize(106, 10)
            healthbar:SetPoint('TOPLEFT', 8, -16)
        else
            healthbar:SetSize(71, 10)
            healthbar:SetPoint('TOPLEFT', 44, -19)
        end
    end

    if manabar and not InCombatLockdown() then
        manabar:SetStatusBarTexture(TEXTURES.manaBar)
        manabar:ClearAllPoints()
        manabar:SetFrameLevel(1)
        manabar:SetStatusBarColor(1, 1, 1, 1)
        if portraitless then
            manabar:SetSize(106, 6)
            manabar:SetPoint('TOPLEFT', 8, -29)
        else
            manabar:SetSize(71, 6)
            manabar:SetPoint('TOPLEFT', 44, -30)
        end
    end

    if frame.DragonUI_EnergyBg and frame.DragonUI_EnergyBar and not InCombatLockdown() then
        frame.DragonUI_EnergyBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.DragonUI_EnergyBar:SetStatusBarColor(0.93, 0.78, 0.12, 1)
        frame.DragonUI_EnergyBar:ClearAllPoints()
        frame.DragonUI_EnergyBg:ClearAllPoints()
        if frame.DragonUI_EnergyBox then
            frame.DragonUI_EnergyBox:ClearAllPoints()
        end
        if portraitless then
            if frame.DragonUI_EnergyBox then
                frame.DragonUI_EnergyBox:SetPoint('TOPLEFT', manabar, 'BOTTOMLEFT', 0, -2)
                frame.DragonUI_EnergyBox:SetSize(106, 6)
            end
        else
            if frame.DragonUI_EnergyBox then
                frame.DragonUI_EnergyBox:SetPoint('TOPLEFT', manabar, 'BOTTOMLEFT', 0, -2)
                frame.DragonUI_EnergyBox:SetSize(71, 6)
            end
        end
        frame.DragonUI_EnergyBg:SetPoint("TOPLEFT", frame.DragonUI_EnergyBox, "TOPLEFT", 1, -1)
        frame.DragonUI_EnergyBg:SetPoint("BOTTOMRIGHT", frame.DragonUI_EnergyBox, "BOTTOMRIGHT", -1, 1)
        frame.DragonUI_EnergyBar:SetPoint("TOPLEFT", frame.DragonUI_EnergyBg, "TOPLEFT", 0, 0)
        frame.DragonUI_EnergyBar:SetPoint("BOTTOMRIGHT", frame.DragonUI_EnergyBg, "BOTTOMRIGHT", 0, 0)
    end

    if frame.DragonUI_RageBg and frame.DragonUI_RageBar and not InCombatLockdown() then
        frame.DragonUI_RageBar:SetStatusBarTexture(SIMPLE_RESOURCE_BAR_TEXTURE)
        frame.DragonUI_RageBar:SetStatusBarColor(0.86, 0.10, 0.10, 1)
        frame.DragonUI_RageBar:ClearAllPoints()
        frame.DragonUI_RageBg:ClearAllPoints()
        if frame.DragonUI_RageBox then
            frame.DragonUI_RageBox:ClearAllPoints()
        end
        if portraitless then
            if frame.DragonUI_RageBox then
                frame.DragonUI_RageBox:SetPoint('TOPLEFT', frame.DragonUI_EnergyBox, 'BOTTOMLEFT', 0, -2)
                frame.DragonUI_RageBox:SetSize(106, 6)
            end
        else
            if frame.DragonUI_RageBox then
                frame.DragonUI_RageBox:SetPoint('TOPLEFT', frame.DragonUI_EnergyBox, 'BOTTOMLEFT', 0, -2)
                frame.DragonUI_RageBox:SetSize(71, 6)
            end
        end
        frame.DragonUI_RageBg:SetPoint("TOPLEFT", frame.DragonUI_RageBox, "TOPLEFT", 1, -1)
        frame.DragonUI_RageBg:SetPoint("BOTTOMRIGHT", frame.DragonUI_RageBox, "BOTTOMRIGHT", -1, 1)
        frame.DragonUI_RageBar:SetPoint("TOPLEFT", frame.DragonUI_RageBg, "TOPLEFT", 0, 0)
        frame.DragonUI_RageBar:SetPoint("BOTTOMRIGHT", frame.DragonUI_RageBg, "BOTTOMRIGHT", 0, 0)
    end

    if name then
        name:SetFont(UF.DEFAULT_FONT, 10)
        name:SetShadowOffset(1, -1)
        name:SetTextColor(1, 0.82, 0, 1)
        if not InCombatLockdown() then
            name:ClearAllPoints()
            if portraitless then
                name:SetPoint('TOPLEFT', 10, -4)
                name:SetSize(94, 12)
            else
                name:SetPoint('TOPLEFT', 46, -5)
                name:SetSize(57, 12)
            end
        end
    end

    UpdateStandardAdditionalResourceBars(frame)
end

-- ===============================================================
-- CLASS COLORS
-- ===============================================================

-- New function: Get class color for party member
local function GetPartyClassColor(partyIndex)
    local unit = "party" .. partyIndex
    if not UnitExists(unit) or not UnitIsPlayer(unit) then
        return 1, 1, 1 -- White if not a player
    end
    return GetClassColor(unit)
end

-- New function: Update party health bar with class color
local function UpdatePartyHealthBarColor(partyIndex)
    if not partyIndex or partyIndex < 1 or partyIndex > 4 then
        return
    end

    local unit = "party" .. partyIndex
    if not UnitExists(unit) then
        return
    end

    local healthbar = _G['PartyMemberFrame' .. partyIndex .. 'HealthBar']
    if not healthbar then
        return
    end

    local settings = GetSettings()
    if not settings then
        return
    end

    local texture = healthbar:GetStatusBarTexture()
    if not texture then
        return
    end

    if settings.classcolor and UnitIsPlayer(unit) then
        -- Use constant instead of hardcoded string
        local statusTexturePath = TEXTURES.healthBarStatus
        if texture:GetTexture() ~= statusTexturePath then
            texture:SetTexture(statusTexturePath)
        end

        -- Apply class color
        local r, g, b = GetPartyClassColor(partyIndex)
        healthbar:SetStatusBarColor(r, g, b, 1)
    else
        -- Use constant instead of hardcoded string
        local normalTexturePath = TEXTURES.healthBar
        if texture:GetTexture() ~= normalTexturePath then
            texture:SetTexture(normalTexturePath)
        end

        -- White color (texture already has color)
        healthbar:SetStatusBarColor(1, 1, 1, 1)
    end
end
-- ===============================================================
-- SIMPLE BLIZZARD BUFF/DEBUFF REPOSITIONING
-- ===============================================================
local function RepositionBlizzardBuffs()
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame then
            -- Position auras fully outside frame right edge
            -- Buff row at top, debuff row below (no vertical overlap between members)
            for auraIndex = 1, 4 do
                local buff = _G['PartyMemberFrame' .. i .. 'Buff' .. auraIndex]
                local debuff = _G['PartyMemberFrame' .. i .. 'Debuff' .. auraIndex]

                if buff then
                    buff:ClearAllPoints()
                    buff:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 2 + (auraIndex - 1) * 17, -2)
                    buff:SetSize(15, 15)
                end

                if debuff then
                    debuff:ClearAllPoints()
                    debuff:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 2 + (auraIndex - 1) * 17, -19)
                    debuff:SetSize(15, 15)
                end
            end
        end
    end
end


-- ===============================================================
-- DYNAMIC CLIPPING SYSTEM
-- ===============================================================

-- Setup dynamic texture clipping for health bars
local function SetupHealthBarClipping(frame)
    if not frame then
        return
    end

    local healthbar = _G[frame:GetName() .. 'HealthBar']
    if not healthbar or healthbar.DragonUI_ClippingSetup then
        return
    end

    -- Hook SetValue for dynamic clipping and class color
    hooksecurefunc(healthbar, "SetValue", function(self, value)
        local frameIndex = frame:GetID()
        local unit = "party" .. frameIndex
        -- NOTE: Do NOT early return on !UnitExists — during ghost/spirit release
        -- UnitExists can briefly return false, leaving texture stuck invisible

        local texture = self:GetStatusBarTexture()
        if not texture then
            return
        end

        -- If disconnected, show full bar in gray (Blizzard native behavior)
        if frame.DragonUI_Disconnected then
            texture:SetTexCoord(0, 1, 0, 1)
            self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
            return
        end

        -- Apply class color first (safe if unit doesn't exist — checks internally)
        UpdatePartyHealthBarColor(frameIndex)

        -- Dynamic clipping: Only show the filled part of the texture
        local min, max = self:GetMinMaxValues()
        local current = value or self:GetValue()

        if max > 0 and current then
            -- Clamp to [0.001, 1] — max=1 can happen during BG loading/phasing
            -- while current holds the real health value, producing TexCoord out of range
            local percentage = math.min(math.max(current / max, 0.001), 1)
            texture:SetTexCoord(0, percentage, 0, 1)
        else
            texture:SetTexCoord(0, 1, 0, 1)
        end
    end)

    healthbar.DragonUI_ClippingSetup = true
end

-- Setup dynamic texture clipping for mana bars
local function SetupManaBarClipping(frame)
    if not frame then
        return
    end

    local manabar = _G[frame:GetName() .. 'ManaBar']
    if not manabar or manabar.DragonUI_ClippingSetup then
        return
    end

    -- Hook SetValue for dynamic clipping
    hooksecurefunc(manabar, "SetValue", function(self, value)
        local unit = "party" .. frame:GetID()
        -- NOTE: Do NOT early return on !UnitExists — see health bar comment

        local texture = self:GetStatusBarTexture()
        if not texture then
            return
        end

        -- If disconnected, mana bar is hidden (alpha=0), skip all processing
        if frame.DragonUI_Disconnected then
            return
        end

        local min, max = self:GetMinMaxValues()
        local current = value or self:GetValue()

        if max > 0 and current then
            -- Clamp to [0.001, 1] — max=1 can happen during BG loading/phasing
            -- while current holds the real mana value, producing TexCoord out of range
            local percentage = math.min(math.max(current / max, 0.001), 1)
            texture:SetTexCoord(0, percentage, 0, 1)
        else
            texture:SetTexCoord(0, 1, 0, 1)
        end

        -- Update texture based on power type
        local powerTexture = GetPowerBarTexture(unit)
        texture:SetTexture(powerTexture)
        texture:SetVertexColor(1, 1, 1, 1)
    end)

    manabar.DragonUI_ClippingSetup = true
end

-- ===============================================================
-- TEXT MANAGEMENT SYSTEM (TAINT-FREE)
-- ===============================================================

-- Hide Blizzard texts permanently with alpha 0 (no taint)
local function HideBlizzardTexts(frame)
    if not frame then return end
    
    local healthText = _G[frame:GetName() .. 'HealthBarText']
    local manaText = _G[frame:GetName() .. 'ManaBarText']
    
    -- Set alpha to 0 instead of hiding to avoid taint
    -- Use hooksecurefunc to re-force alpha=0 after any Blizzard SetAlpha call
    -- A recursion guard flag prevents infinite loop since our SetAlpha(0) also triggers the hook
    if healthText then
        healthText:SetAlpha(0)
        if not healthText.DragonUI_AlphaHooked then
            hooksecurefunc(healthText, "SetAlpha", function(self, alpha)
                if not self.DragonUI_AlphaGuard and alpha ~= 0 then
                    self.DragonUI_AlphaGuard = true
                    self:SetAlpha(0)
                    self.DragonUI_AlphaGuard = nil
                end
            end)
            healthText.DragonUI_AlphaHooked = true
        end
    end
    
    if manaText then
        manaText:SetAlpha(0)
        if not manaText.DragonUI_AlphaHooked then
            hooksecurefunc(manaText, "SetAlpha", function(self, alpha)
                if not self.DragonUI_AlphaGuard and alpha ~= 0 then
                    self.DragonUI_AlphaGuard = true
                    self:SetAlpha(0)
                    self.DragonUI_AlphaGuard = nil
                end
            end)
            manaText.DragonUI_AlphaHooked = true
        end
    end
end

-- Tracking hover state to prevent text disappearing during updates
local hoverStates = {}

-- Forward declaration for CreateCustomTexts (used in update functions)
local CreateCustomTexts
local UpdateHealthText
local UpdateManaText

local PARTY_TEXT_SIZE = 11
local PARTY_TEXT_FLAGS = "OUTLINE"

local function ApplyPartyTextVisualStyle(fontString)
    if not fontString then
        return
    end

    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
end

local function GetPartyTextFontPath()
    return (UF and UF.DEFAULT_FONT) or (addon.Fonts and addon.Fonts.PRIMARY) or "Fonts\\FRIZQT__.TTF"
end

local function EnsurePartyTextFont(fontString)
    if not fontString then
        return false
    end

    if fontString:GetFont() then
        return true
    end

    if GameFontNormalSmall then
        fontString:SetFontObject(TextStatusBarText or GameFontNormalSmall)
    end

    local fontPath = GetPartyTextFontPath()
    if fontPath and fontString:SetFont(fontPath, PARTY_TEXT_SIZE, PARTY_TEXT_FLAGS) then
        return true
    end

    local fallbackPath, _, fallbackFlags = fontString:GetFont()
    if fallbackPath then
        return fontString:SetFont(fallbackPath, PARTY_TEXT_SIZE, fallbackFlags or PARTY_TEXT_FLAGS) and true or false
    end

    return false
end

-- ===============================================================
-- TEXT AND COLOR UPDATE FUNCTIONS
-- ===============================================================

-- Health text update function (taint-free)
UpdateHealthText = function(statusBar, forceShow)
    if not statusBar then return end
    
    local frame = statusBar:GetParent()
    local frameIndex = frame:GetName():match("PartyMemberFrame(%d+)")
    if not frameIndex then return end
    
    local partyUnit = "party" .. frameIndex
    if not UnitExists(partyUnit) then return end
    
    -- Don't show health numbers when player is disconnected
    if not UnitIsConnected(partyUnit) then
        if frame.DragonUI_HealthText then frame.DragonUI_HealthText:Hide() end
        if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
        if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end
        return
    end
    
    -- Ensure our custom text exists
    CreateCustomTexts(frame)
    
    local healthText = frame.DragonUI_HealthText
    if not healthText then return end
    
    local settings = GetSettings()
    
    -- Check visibility logic with hover state (new structure)
    local frameIndexNum = tonumber(frameIndex)
    local hoverState = hoverStates[frameIndexNum]
    local isHovering = false
    
    if hoverState then
        isHovering = hoverState.portrait or hoverState.health
    end
    
    local shouldShow = false
    
    if forceShow or isHovering then
        shouldShow = true -- Force show during hover or explicit force
    elseif settings and settings.showHealthTextAlways then
        shouldShow = true -- Always show if enabled
    end
    
    if not shouldShow then
        -- Hide ALL text elements (including both format)
        if healthText then healthText:Hide() end
        if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
        if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end
        return
    end
    
    local current = UnitHealth(partyUnit)
    local max = UnitHealthMax(partyUnit)
    
    if current and max and max > 0 then
        local textFormat = settings and settings.textFormat or "formatted"
        local breakUp = settings and settings.breakUpLargeNumbers
        local finalText = GetFormattedText(current, max, textFormat, breakUp)
        
        -- Dual system: table for "both", string for other formats
        if textFormat == "both" and type(finalText) == "table" then
            -- Dual format: use left and right, hide center
            if frame.DragonUI_HealthText then frame.DragonUI_HealthText:Hide() end
            if EnsurePartyTextFont(frame.DragonUI_HealthTextLeft) then
                frame.DragonUI_HealthTextLeft:SetText(finalText.left or "")
                frame.DragonUI_HealthTextLeft:Show()
            end
            if EnsurePartyTextFont(frame.DragonUI_HealthTextRight) then
                frame.DragonUI_HealthTextRight:SetText(finalText.right or "")
                frame.DragonUI_HealthTextRight:Show()
            end
        else
            -- Simple format: use center, hide left and right
            if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
            if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end
            if EnsurePartyTextFont(healthText) then
                healthText:SetText(finalText or "")
                healthText:Show()
            end
        end
    else
        -- Hide all texts if no valid data
        if healthText then healthText:Hide() end
        if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
        if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end
    end
end

-- Mana text update function (taint-free)
UpdateManaText = function(statusBar, forceShow)
    if not statusBar then return end
    
    local frameName = statusBar:GetParent():GetName()
    local frameIndex = frameName:match("PartyMemberFrame(%d+)")
    if not frameIndex then return end
    
    local partyUnit = "party" .. frameIndex
    if not UnitExists(partyUnit) then return end
    
    -- Don't show mana numbers when player is disconnected
    local frame = statusBar:GetParent()
    if not UnitIsConnected(partyUnit) then
        if frame.DragonUI_ManaText then frame.DragonUI_ManaText:Hide() end
        if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
        if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end
        return
    end
    
    -- Create custom text if it doesn't exist - look in the frame, not statusbar!
    CreateCustomTexts(frame)
    local customText = frame.DragonUI_ManaText
    
    if not customText then return end
    
    local settings = GetSettings()
    
    -- Check visibility logic with hover state (new structure)
    local frameIndexNum = tonumber(frameIndex)
    local hoverState = hoverStates[frameIndexNum]
    local isHovering = false
    
    if hoverState then
        isHovering = hoverState.portrait or hoverState.mana
    end
    
    local shouldShow = false
    
    if forceShow or isHovering then
        shouldShow = true -- Force show during hover or explicit force
    elseif settings and settings.showManaTextAlways then
        shouldShow = true -- Always show if enabled
    end
    
    if not shouldShow then
        -- Hide ALL text elements (including both format)
        if customText then customText:Hide() end
        if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
        if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end
        return
    end
    
    local current = UnitPower(partyUnit, 0)
    local max = UnitPowerMax(partyUnit, 0)
    
    if current and max and max > 0 then
        local textFormat = settings and settings.textFormat or "formatted"
        local breakUp = settings and settings.breakUpLargeNumbers
        local finalText = GetFormattedText(current, max, textFormat, breakUp)
        
        -- Dual system: table for "both", string for other formats
        if textFormat == "both" and type(finalText) == "table" then
            -- Dual format: use left and right, hide center
            if customText then customText:Hide() end
            if EnsurePartyTextFont(frame.DragonUI_ManaTextLeft) then
                frame.DragonUI_ManaTextLeft:SetText(finalText.left or "")
                frame.DragonUI_ManaTextLeft:Show()
            end
            if EnsurePartyTextFont(frame.DragonUI_ManaTextRight) then
                frame.DragonUI_ManaTextRight:SetText(finalText.right or "")
                frame.DragonUI_ManaTextRight:Show()
            end
        else
            -- Simple format: use center, hide left and right
            if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
            if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end
            if EnsurePartyTextFont(customText) then
                customText:SetText(finalText or "")
                customText:Show()
            end
        end
    else
        -- Hide all texts if no valid data
        if customText then customText:Hide() end
        if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
        if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end
    end
end

-- Create invisible hover frames for independent health/mana text display
local function CreateHoverFrames(frame, frameIndex)
    if not frame or frame.DragonUI_HoverFrames then return end
    
    local healthBar = _G[frame:GetName() .. 'HealthBar']
    local manaBar = _G[frame:GetName() .. 'ManaBar']
    
    -- Create hover frame for health bar
    if healthBar and not frame.DragonUI_HealthHover then
        frame.DragonUI_HealthHover = CreateFrame("Frame", nil, frame.DragonUI_TextFrame)
        frame.DragonUI_HealthHover:SetFrameLevel(frame.DragonUI_TextFrame:GetFrameLevel() + 1)
        frame.DragonUI_HealthHover:SetAllPoints(healthBar)
        frame.DragonUI_HealthHover:EnableMouse(true)
        frame.DragonUI_HealthHover:SetScript("OnEnter", function()
            hoverStates[frameIndex].health = true
            HideBlizzardTexts(frame)
            UpdateHealthText(healthBar, true) -- Only show health text
            -- Only hide mana text if it's NOT set to always show
            local settings = GetSettings()
            if not (settings and settings.showManaTextAlways) then
                if frame.DragonUI_ManaText then frame.DragonUI_ManaText:Hide() end
                if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
                if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end
            end
        end)
        frame.DragonUI_HealthHover:SetScript("OnLeave", function()
            hoverStates[frameIndex].health = false
            HideBlizzardTexts(frame)
            -- Return to normal visibility for both texts
            UpdateHealthText(healthBar, false)
            if manaBar then UpdateManaText(manaBar, false) end
        end)
    end
    
    -- Create hover frame for mana bar
    if manaBar and not frame.DragonUI_ManaHover then
        frame.DragonUI_ManaHover = CreateFrame("Frame", nil, frame.DragonUI_TextFrame)
        frame.DragonUI_ManaHover:SetFrameLevel(frame.DragonUI_TextFrame:GetFrameLevel() + 1)
        frame.DragonUI_ManaHover:SetAllPoints(manaBar)
        frame.DragonUI_ManaHover:EnableMouse(true)
        frame.DragonUI_ManaHover:SetScript("OnEnter", function()
            hoverStates[frameIndex].mana = true
            HideBlizzardTexts(frame)
            UpdateManaText(manaBar, true) -- Only show mana text
            -- Only hide health text if it's NOT set to always show
            local settings = GetSettings()
            if not (settings and settings.showHealthTextAlways) then
                if frame.DragonUI_HealthText then frame.DragonUI_HealthText:Hide() end
                if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
                if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end
            end
        end)
        frame.DragonUI_ManaHover:SetScript("OnLeave", function()
            hoverStates[frameIndex].mana = false
            HideBlizzardTexts(frame)
            -- Return to normal visibility for both texts
            if healthBar then UpdateHealthText(healthBar, false) end
            UpdateManaText(manaBar, false)
        end)
    end
    
    frame.DragonUI_HoverFrames = true
end

-- Create our own text elements for party frames
CreateCustomTexts = function(frame)
    if not frame then return end

    if frame.DragonUI_CustomTexts then
        EnsurePartyTextFont(frame.DragonUI_HealthText)
        EnsurePartyTextFont(frame.DragonUI_HealthTextLeft)
        EnsurePartyTextFont(frame.DragonUI_HealthTextRight)
        EnsurePartyTextFont(frame.DragonUI_ManaText)
        EnsurePartyTextFont(frame.DragonUI_ManaTextLeft)
        EnsurePartyTextFont(frame.DragonUI_ManaTextRight)
        return
    end

    if InCombatLockdown() then
        return
    end
    
    local frameIndex = frame:GetID()
    if not frameIndex or frameIndex < 1 or frameIndex > 4 then return end
    
    -- Initialize hover states (separate for health and mana)
    if not hoverStates[frameIndex] then
        hoverStates[frameIndex] = {
            portrait = false,
            health = false,
            mana = false
        }
    end
    
    -- Create text frame with proper layering (above border)
    if not frame.DragonUI_TextFrame then
        frame.DragonUI_TextFrame = CreateFrame("Frame", nil, frame)
        frame.DragonUI_TextFrame:SetFrameLevel(frame:GetFrameLevel() + 4) -- Above border and bars
        frame.DragonUI_TextFrame:SetAllPoints(frame)
    end

    -- Create custom health text elements (dual system for "both" format)
    local healthBar = _G[frame:GetName() .. 'HealthBar']
    if healthBar then
        -- Center text for simple formats (numeric, percentage, formatted)
        if not frame.DragonUI_HealthText then
            frame.DragonUI_HealthText = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_HealthText:SetPoint("CENTER", healthBar, "CENTER", 2, 0)
            frame.DragonUI_HealthText:SetJustifyH("CENTER")
            frame.DragonUI_HealthText:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_HealthText)
        EnsurePartyTextFont(frame.DragonUI_HealthText)
        -- Left text for "both" format (percentage)
        if not frame.DragonUI_HealthTextLeft then
            frame.DragonUI_HealthTextLeft = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_HealthTextLeft:SetPoint("RIGHT", healthBar, "RIGHT", -37, 0)
            frame.DragonUI_HealthTextLeft:SetJustifyH("LEFT")
            frame.DragonUI_HealthTextLeft:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_HealthTextLeft)
        EnsurePartyTextFont(frame.DragonUI_HealthTextLeft)
        -- Right text for "both" format (numbers)
        if not frame.DragonUI_HealthTextRight then
            frame.DragonUI_HealthTextRight = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_HealthTextRight:SetPoint("RIGHT", healthBar, "RIGHT", -1, 0)
            frame.DragonUI_HealthTextRight:SetJustifyH("RIGHT")
            frame.DragonUI_HealthTextRight:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_HealthTextRight)
        EnsurePartyTextFont(frame.DragonUI_HealthTextRight)
    end

    -- Create custom mana text elements (dual system for "both" format)
    local manaBar = _G[frame:GetName() .. 'ManaBar']
    if manaBar then
        -- Center text for simple formats
        if not frame.DragonUI_ManaText then
            frame.DragonUI_ManaText = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_ManaText:SetPoint("CENTER", manaBar, "CENTER", 3.5, 0)
            frame.DragonUI_ManaText:SetJustifyH("CENTER")
            frame.DragonUI_ManaText:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_ManaText)
        EnsurePartyTextFont(frame.DragonUI_ManaText)
        -- Left text for "both" format (percentage)
        if not frame.DragonUI_ManaTextLeft then
            frame.DragonUI_ManaTextLeft = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_ManaTextLeft:SetPoint("RIGHT", manaBar, "RIGHT", -37, 0)
            frame.DragonUI_ManaTextLeft:SetJustifyH("LEFT")
            frame.DragonUI_ManaTextLeft:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_ManaTextLeft)
        EnsurePartyTextFont(frame.DragonUI_ManaTextLeft)
        -- Right text for "both" format (numbers)
        if not frame.DragonUI_ManaTextRight then
            frame.DragonUI_ManaTextRight = frame.DragonUI_TextFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
            frame.DragonUI_ManaTextRight:SetPoint("RIGHT", manaBar, "RIGHT", -1, 0)
            frame.DragonUI_ManaTextRight:SetJustifyH("RIGHT")
            frame.DragonUI_ManaTextRight:SetDrawLayer("OVERLAY", 1) -- Above everything
        end
        ApplyPartyTextVisualStyle(frame.DragonUI_ManaTextRight)
        EnsurePartyTextFont(frame.DragonUI_ManaTextRight)
    end
    
    -- Create invisible dummy frames for independent hover (taint-free)
    CreateHoverFrames(frame, frameIndex)
    
    frame.DragonUI_CustomTexts = true
end

-- (UpdateHealthText and UpdateManaText functions moved above before CreateHoverFrames)

-- Update party colors function
local function UpdatePartyColors(frame)
    if not frame then
        return
    end

    local settings = GetSettings()
    if not settings then
        return
    end

    local unit = "party" .. frame:GetID()
    if not UnitExists(unit) then
        return
    end

    local healthbar = _G[frame:GetName() .. 'HealthBar']
    if healthbar and settings.classcolor then
        local r, g, b = GetClassColor(unit)
        healthbar:SetStatusBarColor(r, g, b)
    end
end

-- New function: Update mana bar texture
local function UpdateManaBarTexture(frame)
    if not frame then
        return
    end

    local unit = "party" .. frame:GetID()
    if not UnitExists(unit) then
        return
    end

    local manabar = _G[frame:GetName() .. 'ManaBar']
    if manabar then
        local current, maximum = GetUnitResourceValues(unit, 0)
        manabar:SetStatusBarTexture(TEXTURES.manaBar)
        manabar:SetMinMaxValues(0, maximum)
        manabar:SetValue(current)
        manabar:SetStatusBarColor(1, 1, 1, 1) -- Keep white
    end
end

local function UpdateAdditionalPartyResourceBars(frame)
    if not frame then
        return
    end

    UpdateStandardAdditionalResourceBars(frame)
end
-- ===============================================================
-- FRAME STYLING FUNCTIONS
-- ===============================================================

-- Main styling function for party frames
local function StylePartyFrames()
    -- Skip all restyling during editor mode (prevents texture/layer race conditions on fake frames)
    if addon.EditorMode and addon.EditorMode:IsActive() then return end

    local settings = GetSettings()
    if not settings then return end

    CreatePartyAnchorFrame()
    ApplyWidgetPosition()

    local step = GetPartyStep()
    local orientation = GetOrientation()
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame then
            if not InCombatLockdown() then
                frame:SetScale(settings.scale or 1)
                frame:SetFrameStrata('BACKGROUND')
                frame:SetFrameLevel(1)
                frame:ClearAllPoints()
                if orientation == 'horizontal' then
                    local xOffset = (i - 1) * step
                    frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", xOffset, 0)
                else
                    local yOffset = (i - 1) * -step
                    frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", 0, yOffset)
                end
            end

            -- Hide background (and permanently prevent Blizzard's "Party/Arena Background" CVar from showing it)
            local bg = _G[frame:GetName() .. 'Background']
            if bg then
                bg:Hide()
                if not bg.DragonUI_ShowHooked then
                    hooksecurefunc(bg, "Show", function(self) self:Hide() end)
                    bg.DragonUI_ShowHooked = true
                end
            end

            -- Hide default texture
            local texture = _G[frame:GetName() .. 'Texture']
            if texture then
                texture:SetTexture()
                texture:Hide()
                if not texture.DragonUI_ShowHooked then
                    hooksecurefunc(texture, "Show", function(self) self:Hide() end)
                    texture.DragonUI_ShowHooked = true
                end
            end

            -- Hide vehicle texture (shown when party member is in a vehicle)
            local vehicleTex = _G[frame:GetName() .. 'VehicleTexture']
            if vehicleTex then
                vehicleTex:SetTexture()
                vehicleTex:Hide()
                if not vehicleTex.DragonUI_ShowHooked then
                    hooksecurefunc(vehicleTex, "Show", function(self) self:Hide() end)
                    vehicleTex.DragonUI_ShowHooked = true
                end
            end

            -- Lock portrait position so Blizzard vehicle transitions can't move it
            local portrait = _G[frame:GetName() .. 'Portrait']
            if portrait and not portrait.DragonUI_SetPointHooked then
                local isResetting = false
                hooksecurefunc(portrait, "SetPoint", function(self)
                    if isResetting or InCombatLockdown() then return end
                    isResetting = true
                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", 7, -6)
                    isResetting = false
                end)
                portrait.DragonUI_SetPointHooked = true
            end
            if portrait and not portrait.DragonUI_ShowHooked then
                hooksecurefunc(portrait, "Show", function(self)
                    if IsRaidStylePartyFramesEnabled() or IsPartyPortraitlessEnabled() then
                        self:Hide()
                    end
                end)
                portrait.DragonUI_ShowHooked = true
            end

            ApplyStandardPartyFrameLayout(frame)

            -- Health/power bar setup
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            if healthbar then
                SetupHealthBarClipping(frame)
                UpdatePartyHealthBarColor(i)
            end

            local manabar = _G[frame:GetName() .. 'ManaBar']
            if manabar then
                SetupManaBarClipping(frame)
                UpdateManaBarTexture(frame)
            end
            UpdateAdditionalPartyResourceBars(frame)

            -- LEADER ICON STYLING
            local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
            if leaderIcon then -- Removed and not InCombatLockdown()
                leaderIcon:ClearAllPoints()
                leaderIcon:SetPoint('TOPLEFT', 42, 9) -- Custom position
                leaderIcon:SetSize(16, 16) -- Custom size (optional)
            end

            -- Master looter icon styling
            local masterLooterIcon = _G[frame:GetName() .. 'MasterIcon']
            if masterLooterIcon then -- No combat restriction
                masterLooterIcon:ClearAllPoints()
                masterLooterIcon:SetPoint('TOPLEFT', 58, 11) -- Position next to leader icon
                masterLooterIcon:SetSize(16, 16) -- Custom size

            end

            -- Flash setup
            local flash = _G[frame:GetName() .. 'Flash']
            if flash then
                flash:SetSize(114, 47)
                flash:SetTexture(TEXTURES.frame)
                flash:SetTexCoord(GetPartyCoords("flash"))
                flash:SetPoint('TOPLEFT', 2, -2)
                flash:SetVertexColor(1, 0, 0, 1)
                flash:SetDrawLayer('ARTWORK', 5)
            end

            -- Create background and mark as styled
            if not frame.DragonUIStyled then
                -- Background (behind everything)
                local background = frame:CreateTexture(nil, 'BACKGROUND', nil, 0)
                background:SetTexture(TEXTURES.frame)
                background:SetTexCoord(GetPartyCoords("background"))
                background:SetSize(120, 49)
                background:SetPoint('TOPLEFT', 1, -2)
                frame.DragonUI_BackgroundTexture = background

                -- Create border as a separate FRAME (not texture) to appear above bars
                if not frame.DragonUI_BorderFrame then
                    frame.DragonUI_BorderFrame = CreateFrame("Frame", nil, frame)
                    frame.DragonUI_BorderFrame:SetFrameLevel(frame:GetFrameLevel() + 3) -- Above health/mana bars (level 2)
                    frame.DragonUI_BorderFrame:SetAllPoints(frame)
                    
                    -- Now create border texture inside the border frame
                    local border = frame.DragonUI_BorderFrame:CreateTexture(nil, 'ARTWORK', nil, 1)
                    border:SetTexture(TEXTURES.border)
                    border:SetTexCoord(GetPartyCoords("border"))
                    border:SetSize(128, 64)
                    border:SetPoint('TOPLEFT', 1, -2)
                    border:SetVertexColor(1, 1, 1, 1)
                    frame.DragonUI_BorderFrame.texture = border
                end

                frame.DragonUI_PortraitlessBackground = frame:CreateTexture(nil, 'BACKGROUND', nil, 0)
                frame.DragonUI_PortraitlessBackground:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
                frame.DragonUI_PortraitlessBackground:SetVertexColor(0.03, 0.03, 0.04, 0.92)
                frame.DragonUI_PortraitlessBackground:SetPoint('TOPLEFT', 2, -2)
                frame.DragonUI_PortraitlessBackground:SetPoint('BOTTOMRIGHT', -2, 2)
                frame.DragonUI_PortraitlessBackground:Hide()

                frame.DragonUI_PortraitlessBorder = frame:CreateTexture(nil, 'ARTWORK', nil, 2)
                frame.DragonUI_PortraitlessBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
                frame.DragonUI_PortraitlessBorder:SetPoint('TOPLEFT', 0, 0)
                frame.DragonUI_PortraitlessBorder:SetPoint('BOTTOMRIGHT', 0, 0)
                frame.DragonUI_PortraitlessBorder:SetVertexColor(0.16, 0.14, 0.12, 0.9)
                frame.DragonUI_PortraitlessBorder:Hide()

                -- Create icon container well above border frame
                if not frame.DragonUI_IconContainer then
                    local iconContainer = CreateFrame("Frame", nil, frame)
                    iconContainer:SetFrameStrata("BACKGROUND")  -- Same strata as party frame
                    iconContainer:SetFrameLevel(frame:GetFrameLevel() + 10)  -- Well above border (+3)
                    iconContainer:SetAllPoints(frame)
                    frame.DragonUI_IconContainer = iconContainer
                end

                -- Move icons to HIGH strata container and configure layers
                local name = _G[frame:GetName() .. 'Name']
                local healthText = _G[frame:GetName() .. 'HealthBarText']
                local manaText = _G[frame:GetName() .. 'ManaBarText']
                local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
                local masterLooterIcon = _G[frame:GetName() .. 'MasterIcon']
                local pvpIcon = _G[frame:GetName() .. 'PVPIcon']
                local statusIcon = _G[frame:GetName() .. 'StatusIcon']
                local blizzardRoleIcon = _G[frame:GetName() .. 'RoleIcon']
                local guideIcon = _G[frame:GetName() .. 'GuideIcon']
                
                -- Text elements stay in normal layer
                if name then
                    name:SetDrawLayer('OVERLAY', 1)
                end
                if healthText then
                    healthText:SetDrawLayer('OVERLAY', 1)
                end
                if manaText then
                    manaText:SetDrawLayer('OVERLAY', 1)
                end
                
                -- Move PvP and status icons to icon container (above border)
                if leaderIcon then
                    leaderIcon:SetParent(frame.DragonUI_IconContainer)
                    leaderIcon:SetDrawLayer('OVERLAY', 1)
                end
                if masterLooterIcon then
                    masterLooterIcon:SetParent(frame.DragonUI_IconContainer)
                    masterLooterIcon:SetDrawLayer('OVERLAY', 1)
                end
                if pvpIcon then
                    pvpIcon:SetParent(frame.DragonUI_IconContainer)
                    pvpIcon:SetDrawLayer('OVERLAY', 1)
                end
                if statusIcon then 
                    statusIcon:SetParent(frame.DragonUI_IconContainer)
                    statusIcon:SetDrawLayer('OVERLAY', 1)
                end
                if blizzardRoleIcon then
                    blizzardRoleIcon:SetParent(frame.DragonUI_IconContainer)
                    blizzardRoleIcon:SetDrawLayer('OVERLAY', 1)
                end
                if guideIcon then
                    guideIcon:SetParent(frame.DragonUI_IconContainer)
                    guideIcon:SetDrawLayer('OVERLAY', 1)
                end

                frame.DragonUIStyled = true
            end
            -- Hide Blizzard texts and create our custom ones
            HideBlizzardTexts(frame)
            CreateCustomTexts(frame)
            
            -- Update our custom texts initially
            if healthbar then
                UpdateHealthText(healthbar, false)
            end
            if manabar then
                UpdateManaText(manabar, false)
            end

            frame.DragonUIStyled = true
        end
    end
end

-- ===============================================================
-- DISCONNECTED PLAYERS
-- ===============================================================
local function UpdateDisconnectedState(frame)
    if not frame then
        return
    end

    local unit = "party" .. frame:GetID()
    if not UnitExists(unit) then
        -- Member left or slot is empty: clear stale disconnected state.
        frame.DragonUI_Disconnected = false

        local healthbar = _G[frame:GetName() .. 'HealthBar']
        local manabar = _G[frame:GetName() .. 'ManaBar']
        local portrait = _G[frame:GetName() .. 'Portrait']
        local name = _G[frame:GetName() .. 'Name']

        if healthbar then
            healthbar:SetAlpha(1.0)
        end
        if manabar then
            manabar:SetAlpha(1.0)
        end
        UpdateStandardAdditionalResourceBars(frame)
        if portrait then
            portrait:SetVertexColor(1, 1, 1, 1)
        end
        if name then
            name:SetTextColor(1, 0.82, 0, 1)
        end

        return
    end

    local isConnected = UnitIsConnected(unit)
    local healthbar = _G[frame:GetName() .. 'HealthBar']
    local manabar = _G[frame:GetName() .. 'ManaBar']
    local portrait = _G[frame:GetName() .. 'Portrait']
    local name = _G[frame:GetName() .. 'Name']

    if not isConnected then
        -- Mark frame as disconnected (used by clipping hooks to force gray)
        frame.DragonUI_Disconnected = true

        -- Disconnected member - gray bars at full, no text (Blizzard native behavior)
        if healthbar then
            healthbar:SetAlpha(0.3)
            healthbar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        end

        -- Hide all custom health text elements (numbers should not show when offline)
        if frame.DragonUI_HealthText then frame.DragonUI_HealthText:Hide() end
        if frame.DragonUI_HealthTextLeft then frame.DragonUI_HealthTextLeft:Hide() end
        if frame.DragonUI_HealthTextRight then frame.DragonUI_HealthTextRight:Hide() end

        -- Hide all custom mana text elements
        if frame.DragonUI_ManaText then frame.DragonUI_ManaText:Hide() end
        if frame.DragonUI_ManaTextLeft then frame.DragonUI_ManaTextLeft:Hide() end
        if frame.DragonUI_ManaTextRight then frame.DragonUI_ManaTextRight:Hide() end

        if manabar then
            manabar:SetAlpha(0)  -- Completely hide mana bar when offline (works in combat)
        end
        if frame.DragonUI_EnergyBar then
            frame.DragonUI_EnergyBar:SetAlpha(0)
        end
        if frame.DragonUI_RageBar then
            frame.DragonUI_RageBar:SetAlpha(0)
        end

        if portrait then
            portrait:SetVertexColor(0.5, 0.5, 0.5, 1)
        end

        if name then
            name:SetTextColor(0.6, 0.6, 0.6, 1)
        end

        -- Reposition icons so they don't get lost
        local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
        if leaderIcon then
            leaderIcon:ClearAllPoints()
            leaderIcon:SetPoint('TOPLEFT', 42, 9)
            leaderIcon:SetSize(16, 16)
        end

        local masterLooterIcon = _G[frame:GetName() .. 'MasterIcon']
        if masterLooterIcon then
            masterLooterIcon:ClearAllPoints()
            masterLooterIcon:SetPoint('TOPLEFT', 58, 11)
            masterLooterIcon:SetSize(16, 16)
        end

    else
        -- Connected member - undo exactly what was done when disconnecting
        frame.DragonUI_Disconnected = false

        -- Restore transparencies (without taint)
        if healthbar then
            healthbar:SetAlpha(1.0) -- Normal opacity
            -- Restore correct color (class color or white)
            local frameIndex = frame:GetID()
            UpdatePartyHealthBarColor(frameIndex) -- Only updates color, does not recreate frame
        end

        if manabar then
            manabar:SetAlpha(1.0) -- Restore visibility
            manabar:SetStatusBarColor(1, 1, 1, 1) -- White as it should be
            local manaTexture = manabar:GetStatusBarTexture()
            if manaTexture then
                manaTexture:SetVertexColor(1, 1, 1, 1)
            end
        end
        UpdateStandardAdditionalResourceBars(frame)

        if portrait then
            portrait:SetVertexColor(1, 1, 1, 1) -- Normal color
        end

        if name then
            name:SetTextColor(1, 0.82, 0, 1) -- Normal yellow
        end

        -- Reposition icons (without recreating frames)
        local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
        if leaderIcon then
            leaderIcon:ClearAllPoints()
            leaderIcon:SetPoint('TOPLEFT', 42, 9)
            leaderIcon:SetSize(16, 16)
        end

        local masterLooterIcon = _G[frame:GetName() .. 'MasterIcon']
        if masterLooterIcon then
            masterLooterIcon:ClearAllPoints()
            masterLooterIcon:SetPoint('TOPLEFT', 58, 11)
            masterLooterIcon:SetSize(16, 16)
        end
    end
end

local function ShouldShowDragonUIPartySlot(index)
    if IsRaidStylePartyFramesEnabled() then
        return false
    end
    if not ShouldPartyFramesBeVisible() then
        return false
    end
    return UnitExists("party" .. index)
end

local function RefreshSinglePartyFrameVisibility(index)
    local frame = _G['PartyMemberFrame' .. index]
    if not frame then
        return
    end

    -- Never hide party frames while editor mode is active (test frames are shown intentionally)
    if addon.EditorMode and addon.EditorMode:IsActive() then
        return
    end

    if IsRaidStylePartyFramesEnabled() then
        frame:Hide()
        local portrait = _G[frame:GetName() .. 'Portrait']
        if portrait then
            portrait:Hide()
        end
        local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
        if leaderIcon then
            leaderIcon:Hide()
        end
        local masterLooterIcon = _G[frame:GetName() .. 'MasterIcon']
        if masterLooterIcon then
            masterLooterIcon:Hide()
        end
        local targetIcon = _G[frame:GetName() .. 'ReadyCheck']
        if targetIcon then
            targetIcon:Hide()
        end
        return
    end

    -- Keep disconnect visuals in sync before deciding visibility.
    UpdateDisconnectedState(frame)

    if ShouldShowDragonUIPartySlot(index) then
        frame:Show()
    else
        frame:Hide()
    end
end

local function RefreshAllPartyFrameVisibility()
    for i = 1, MAX_PARTY_MEMBERS do
        RefreshSinglePartyFrameVisibility(i)
    end
    RefreshRaidStylePartyFrames(false)
end




-- ===============================================================
-- HOOK SETUP FUNCTION
-- ===============================================================

-- Setup all necessary hooks for party frames
local function SetupPartyHooks()
    hooksecurefunc("PartyMemberFrame_UpdateMember", function(frame)
        -- Skip restyling during editor mode (fake frames should stay as-is)
        if addon.EditorMode and addon.EditorMode:IsActive() then return end
        if frame and frame:GetName():match("^PartyMemberFrame%d+$") then
            if IsRaidStylePartyFramesEnabled() then
                frame:Hide()
                local portrait = _G[frame:GetName() .. 'Portrait']
                if portrait then
                    portrait:Hide()
                end
                local texture = _G[frame:GetName() .. 'Texture']
                if texture then
                    texture:Hide()
                end
                local bg = _G[frame:GetName() .. 'Background']
                if bg then
                    bg:Hide()
                end
                return
            end
            local frameIndex = frame:GetID()
            local unit = frameIndex and ("party" .. frameIndex)

            if unit and UnitExists(unit) and not frame:IsShown() and not InCombatLockdown()
                and ShouldPartyFramesBeVisible() then
                frame:Show()
            end

            if PartyFrames.anchor and not InCombatLockdown() then
                if frameIndex and frameIndex >= 1 and frameIndex <= 4 then
                    frame:ClearAllPoints()
                    local step = GetPartyStep()
                    local orientation = GetOrientation()
                    if orientation == 'horizontal' then
                        local xOffset = (frameIndex - 1) * step
                        frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", xOffset, 0)
                    else
                        local yOffset = (frameIndex - 1) * -step
                        frame:SetPoint("TOPLEFT", PartyFrames.anchor, "TOPLEFT", 0, yOffset)
                    end
                end
            end

            -- Re-hide textures (always needed)
            local texture = _G[frame:GetName() .. 'Texture']
            if texture then
                texture:SetTexture()
                texture:Hide()
            end

            -- Re-hide vehicle texture
            local vehicleTex = _G[frame:GetName() .. 'VehicleTexture']
            if vehicleTex then
                vehicleTex:SetTexture()
                vehicleTex:Hide()
            end

            local bg = _G[frame:GetName() .. 'Background']
            if bg then
                bg:Hide()
            end

            -- Maintain only clipping configuration (ACE3 handles colors)
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            local manabar = _G[frame:GetName() .. 'ManaBar']

            if healthbar then
                SetupHealthBarClipping(frame)
            end

            if manabar then
                manabar:SetStatusBarColor(1, 1, 1, 1)
                SetupManaBarClipping(frame)
            end

            -- Update power bar texture
            UpdateManaBarTexture(frame)
            -- Disconnected state
            UpdateDisconnectedState(frame)
            
            -- Always hide Blizzard texts and ensure our custom texts exist
            HideBlizzardTexts(frame)
            CreateCustomTexts(frame)
            
            -- Force reparent icons to icon container (for dynamic PvP icons)
            if frame.DragonUI_IconContainer then
                local pvpIcon = _G[frame:GetName() .. 'PVPIcon']
                local leaderIcon = _G[frame:GetName() .. 'LeaderIcon']
                local masterIcon = _G[frame:GetName() .. 'MasterIcon']
                local statusIcon = _G[frame:GetName() .. 'StatusIcon']
                local guideIcon = _G[frame:GetName() .. 'GuideIcon']
                local roleIcon = _G[frame:GetName() .. 'RoleIcon']
                
                if pvpIcon then
                    pvpIcon:SetParent(frame.DragonUI_IconContainer)
                    pvpIcon:SetDrawLayer('OVERLAY', 1)
                end
                if statusIcon then
                    statusIcon:SetParent(frame.DragonUI_IconContainer)
                    statusIcon:SetDrawLayer('OVERLAY', 1)
                end
                if guideIcon then
                    guideIcon:SetParent(frame.DragonUI_IconContainer)
                    guideIcon:SetDrawLayer('OVERLAY', 1)
                end
                if roleIcon then
                    roleIcon:SetParent(frame.DragonUI_IconContainer)
                    roleIcon:SetDrawLayer('OVERLAY', 1)
                end
            end
            
            -- Update custom health/mana text
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            local manabar = _G[frame:GetName() .. 'ManaBar']
            if healthbar then UpdateHealthText(healthbar, false) end
            if manabar then UpdateManaText(manabar, false) end
        end
    end)

    -- Additional hook for party member updates (compatible with 3.3.5a)
    hooksecurefunc("PartyMemberFrame_OnEvent", function(frame, event)
        if frame and frame:GetName() and frame:GetName():match("^PartyMemberFrame%d+$") then
            if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
                local healthbar = _G[frame:GetName() .. 'HealthBar']
                if healthbar then
                    UpdateHealthText(healthbar, false)
                end
            elseif event == "UNIT_POWER" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
                -- Update power bar texture on power type change (e.g. druid shifting)
                UpdateManaBarTexture(frame)
                UpdateAdditionalPartyResourceBars(frame)
                local manabar = _G[frame:GetName() .. 'ManaBar']
                if manabar then
                    UpdateManaText(manabar, false)
                end
            end
        end
    end)

    -- Main hook for class color (simplified)
    hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
        if statusbar and statusbar:GetName() and statusbar:GetName():find('PartyMemberFrame') then
            -- Only maintain dynamic clipping - Ace3 handles color
            local texture = statusbar:GetStatusBarTexture()
            if texture then
                local min, max = statusbar:GetMinMaxValues()
                local current = statusbar:GetValue()
                if max > 0 and current then
                    local percentage = math.min(math.max(current / max, 0.001), 1)
                    texture:SetTexCoord(0, percentage, 0, 1)
                end
            end
            
            -- Update health text with DragonUI formatting
            UpdateHealthText(statusbar, false)
        end
    end)

    -- Hook for mana bar (without touching health)
    hooksecurefunc("UnitFrameManaBar_Update", function(statusbar, unit)
        if statusbar and statusbar:GetName() and statusbar:GetName():find('PartyMemberFrame') then
            statusbar:SetStatusBarColor(1, 1, 1, 1) -- Only mana in white

            local frameName = statusbar:GetParent():GetName()
            local frameIndex = frameName:match("PartyMemberFrame(%d+)")
            if frameIndex then
                local partyUnit = "party" .. frameIndex
                local powerTexture = TEXTURES.manaBar
                statusbar:SetStatusBarTexture(powerTexture)
                local current, maximum = GetUnitResourceValues(partyUnit, 0)
                statusbar:SetMinMaxValues(0, maximum)
                statusbar:SetValue(current)

                -- Maintain dynamic clipping
                local texture = statusbar:GetStatusBarTexture()
                if texture then
                    local min, max = statusbar:GetMinMaxValues()
                    local current = statusbar:GetValue()
                    if max > 0 and current then
                        local percentage = math.min(math.max(current / max, 0.001), 1)
                        texture:SetTexCoord(0, percentage, 0, 1)
                        texture:SetTexture(powerTexture)
                    end
                end
            end
            UpdateAdditionalPartyResourceBars(statusbar:GetParent())
            
            -- Update mana text with DragonUI formatting
            UpdateManaText(statusbar, false)
        end
    end)
    
    -- Handle hover text display with persistent state (portrait hover - shows both texts)
    hooksecurefunc("UnitFrame_OnEnter", function(self)
        if self and self:GetName() and self:GetName():match("^PartyMemberFrame%d+$") then
            local frameIndex = tonumber(self:GetID())
            if frameIndex and hoverStates[frameIndex] then
                hoverStates[frameIndex].portrait = true  -- Mark portrait as hovering
            end
            
            -- Immediately hide Blizzard texts after hover
            HideBlizzardTexts(self)
            
            -- Show both custom texts during portrait hover (even if always show is off)
            local healthbar = _G[self:GetName() .. 'HealthBar']
            local manabar = _G[self:GetName() .. 'ManaBar']
            if healthbar then UpdateHealthText(healthbar, true) end -- forceShow = true
            if manabar then UpdateManaText(manabar, true) end -- forceShow = true
        end
    end)
    
    hooksecurefunc("UnitFrame_OnLeave", function(self)
        if self and self:GetName() and self:GetName():match("^PartyMemberFrame%d+$") then
            local frameIndex = tonumber(self:GetID())
            if frameIndex and hoverStates[frameIndex] then
                hoverStates[frameIndex].portrait = false  -- Clear portrait hover state
            end
            
            -- Ensure Blizzard texts stay hidden after hover ends
            HideBlizzardTexts(self)
            
            -- Return to normal text visibility (respect always show setting)
            local healthbar = _G[self:GetName() .. 'HealthBar']
            local manabar = _G[self:GetName() .. 'ManaBar']
            if healthbar then UpdateHealthText(healthbar, false) end -- forceShow = false
            if manabar then UpdateManaText(manabar, false) end -- forceShow = false
        end
    end)
    
    -- ===============================================================
    -- DISCONNECT VISUAL FIX (mod-playerbots compatibility)
    -- ===============================================================
    -- Hook PartyMemberFrame_UpdateOnlineStatus directly.
    -- This runs AFTER Blizzard has already called UnitFrameHealthBar_Update
    -- (which triggers our SetValue hook that may override gray with class/white
    -- color because DragonUI_Disconnected flag isn't set yet at that point).
    -- By hooking this function, we re-apply disconnect visuals as the LAST step.
    hooksecurefunc("PartyMemberFrame_UpdateOnlineStatus", function(frame)
        if not frame or not frame:GetName() then return end
        if not frame:GetName():match("^PartyMemberFrame%d+$") then return end
        
        local frameIndex = frame:GetID()
        local unit = "party" .. frameIndex
        if not UnitExists(unit) then return end
        
        -- Re-apply disconnect state — this runs after Blizzard AND after our
        -- SetValue/UnitFrameHealthBar_Update hooks have already executed,
        -- ensuring the gray visuals stick.
        UpdateDisconnectedState(frame)
        
        -- Force bars to re-run their SetValue hooks with the flag now set
        local healthbar = _G[frame:GetName() .. 'HealthBar']
        local manabar = _G[frame:GetName() .. 'ManaBar']
        if healthbar then
            local val = healthbar:GetValue()
            healthbar:SetValue(val)
        end
        if manabar then
            local val = manabar:GetValue()
            manabar:SetValue(val)
        end
    end)
end

-- ===============================================================
-- MODULE INTERFACE FUNCTIONS
-- ===============================================================

function PartyFrames:UpdateSettings()
    -- Check initial configuration
    if not addon.db or not addon.db.profile or not addon.db.profile.widgets or not addon.db.profile.widgets.party then
        self:LoadDefaultSettings()
    end

    -- Apply widget position first
    ApplyWidgetPosition()
    ApplyCompactPartyFramesMode()
    
    -- Only apply base styles - ACE3 handles class color
    StylePartyFrames()
    ReanchorCompactPartyFrame()
    
    -- Reposition buffs
    RepositionBlizzardBuffs()
    
    -- Update anchor size for new orientation
    UpdatePartyAnchorSize()
    RefreshRaidStylePartyFrames(false)
    
    -- Refresh all texts and power bar textures with new settings
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame then
            HideBlizzardTexts(frame)
            CreateCustomTexts(frame)
            
            -- Refresh power bar texture (energy, rage, etc.)
            UpdateManaBarTexture(frame)
            
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            local manabar = _G[frame:GetName() .. 'ManaBar']
            
            if healthbar then UpdateHealthText(healthbar, false) end
            if manabar then UpdateManaText(manabar, false) end
            
            -- Re-apply disconnected state AFTER styling (gray name, hidden texts, etc.)
            -- StylePartyFrames resets name color to yellow, so this must come last
            UpdateDisconnectedState(frame)
        end
    end

    -- Single source of truth for Show/Hide decisions.
    RefreshAllPartyFrameVisibility()
end

-- ===============================================================
-- EXPORTS FOR OPTIONS.LUA
-- ===============================================================

-- Export for options.lua refresh functions
addon.RefreshPartyFrames = function()
    if PartyFrames.UpdateSettings then
        PartyFrames:UpdateSettings()
    end
end

-- New function: Refresh called from core.lua
function addon:RefreshPartyFrames()
    if PartyFrames and PartyFrames.UpdateSettings then
        PartyFrames:UpdateSettings()
    end
end

function addon:SetPartyRaidStyleEnabled(enabled)
    if not addon.db or not addon.db.profile then
        return
    end

    addon.db.profile.unitframe = addon.db.profile.unitframe or {}
    addon.db.profile.unitframe.party = addon.db.profile.unitframe.party or {}
    addon.db.profile.unitframe.party.useRaidStyle = enabled and true or false

    ApplyCompactPartyFramesMode()

    if PartyFrames and PartyFrames.UpdateSettings then
        PartyFrames:UpdateSettings()
    end
end

-- ===============================================================
-- CENTRALIZED SYSTEM REGISTRATION AND INITIALIZATION
-- ===============================================================

local function InitializePartyFramesForEditor()
    if PartyFrames.initialized then
        return
    end

    -- Create anchor frame
    CreatePartyAnchorFrame()

    -- Always ensure configuration exists
    PartyFrames:LoadDefaultSettings()

    -- Apply initial position
    ApplyWidgetPosition()

    -- Register with centralized system
    if addon and addon.RegisterEditableFrame then
        addon:RegisterEditableFrame({
            name = "party",
            frame = PartyFrames.anchor,
            configPath = {"widgets", "party"}, -- Add configPath required by core.lua
            showTest = ShowPartyFramesTest,
            hideTest = HidePartyFramesTest,
            hasTarget = ShouldAnyPartyFramesBeVisible -- Use hasTarget instead of shouldShow
        })
    end

    PartyFrames.initialized = true
end

-- ===============================================================
-- INITIALIZATION
-- ===============================================================

-- Initialize everything in correct order
InitializePartyFramesForEditor() -- First: register with centralized system
ApplyCompactPartyFramesMode()
StylePartyFrames() -- Second: visual properties and positioning
SetupPartyHooks() -- Third: safe hooks only

-- Listener for when the addon is fully loaded
local readyFrame = CreateFrame("Frame")
readyFrame:RegisterEvent("ADDON_LOADED")
readyFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "DragonUI" then
        -- Apply position after the addon is fully loaded
        if PartyFrames and PartyFrames.UpdateSettings then
            PartyFrames:UpdateSettings()
        end
        ReanchorCompactPartyFrame()
        RefreshAllPartyFrameVisibility()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

local connectionFrame = CreateFrame("Frame")
connectionFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
connectionFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
connectionFrame:SetScript("OnEvent", function(self, event)
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        if frame then
            -- Set the flag FIRST so hooks respect it
            UpdateDisconnectedState(frame)
            -- Force bars to re-run their SetValue hooks with the new flag
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            local manabar = _G[frame:GetName() .. 'ManaBar']
            if healthbar then
                local val = healthbar:GetValue()
                healthbar:SetValue(val)
            end
            if manabar then
                local val = manabar:GetValue()
                manabar:SetValue(val)
            end
        end
    end
end)

local raidStyleUpdateFrame = CreateFrame("Frame")
raidStyleUpdateFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
raidStyleUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
raidStyleUpdateFrame:RegisterEvent("UNIT_HEALTH")
raidStyleUpdateFrame:RegisterEvent("UNIT_MAXHEALTH")
raidStyleUpdateFrame:RegisterEvent("UNIT_POWER")
raidStyleUpdateFrame:RegisterEvent("UNIT_MAXPOWER")
raidStyleUpdateFrame:RegisterEvent("UNIT_DISPLAYPOWER")
raidStyleUpdateFrame:RegisterEvent("UNIT_NAME_UPDATE")
raidStyleUpdateFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
raidStyleUpdateFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
raidStyleUpdateFrame:SetScript("OnEvent", function(self, event, unit)
    if not IsRaidStylePartyFramesEnabled() then
        return
    end

    if unit and not tostring(unit):match("^party%d$") then
        if event ~= "PARTY_MEMBERS_CHANGED" and event ~= "PLAYER_ENTERING_WORLD" then
            return
        end
    end

    if addon.EditorMode and addon.EditorMode:IsActive() then
        RefreshRaidStylePartyFrames(true)
        return
    end

    RefreshRaidStylePartyFrames(false)
end)

-- ===============================================================
-- DEATH/GHOST RECOVERY SYSTEM
-- ===============================================================
-- After death + spirit release, party frame textures can get stuck invisible
-- because SetValue hooks clip to zero-width and UnitExists may briefly return false.
-- These events force a full texture refresh to recover from that state.

local recoveryFrame = CreateFrame("Frame")
recoveryFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")   -- Party composition changes (join/leave/role swap)
recoveryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")   -- Recovery after reload/zone transitions
recoveryFrame:RegisterEvent("PLAYER_ALIVE")             -- Player resurrects (accept rez or spirit healer)
recoveryFrame:RegisterEvent("PLAYER_UNGHOST")           -- Player returns from ghost form
recoveryFrame:RegisterEvent("UNIT_HEALTH")              -- Any unit health change (catches party member rez too)
recoveryFrame:RegisterEvent("CVAR_UPDATE")              -- React to Blizzard party visibility options changes
recoveryFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        local delayFrame = CreateFrame("Frame")
        local elapsed = 0
        delayFrame:SetScript("OnUpdate", function(delaySelf, dt)
            elapsed = elapsed + dt
            if elapsed >= 0.5 then
                delaySelf:SetScript("OnUpdate", nil)
                -- Skip refresh while editor mode is active (test frames are intentionally shown)
                if addon.EditorMode and addon.EditorMode:IsActive() then
                    return
                end
                if InCombatLockdown() then
                    return
                end
                ApplyCompactPartyFramesMode()
                StylePartyFrames()
                ReanchorCompactPartyFrame()
                RefreshAllPartyFrameVisibility()
            end
        end)
        return
    end

    -- For PARTY_MEMBERS_CHANGED, refresh frame visibility for all party slots.
    -- Uses CombatQueue to defer in combat (Show/Hide on secure frames causes taint).
    if event == "PARTY_MEMBERS_CHANGED" then
        -- Skip refresh while editor mode is active (test frames are intentionally shown)
        if addon.EditorMode and addon.EditorMode:IsActive() then
            return
        end
        local function RefreshPartyFrames()
            ApplyCompactPartyFramesMode()
            ReanchorCompactPartyFrame()
            RefreshAllPartyFrameVisibility()
        end
        
        if InCombatLockdown() then
            -- Queue for after combat ends
            if addon.CombatQueue then
                addon.CombatQueue:Add("party_refresh", RefreshPartyFrames)
            end
        else
            RefreshPartyFrames()
        end
    end

    if event == "CVAR_UPDATE" then
        if unit ~= "useCompactPartyFrames" and unit ~= "hidePartyInRaid" then
            return
        end

        if addon.EditorMode and addon.EditorMode:IsActive() then
            return
        end

        local function RefreshPartyFrames()
            ApplyCompactPartyFramesMode()
            ReanchorCompactPartyFrame()
            RefreshAllPartyFrameVisibility()
        end

        if InCombatLockdown() then
            if addon.CombatQueue then
                addon.CombatQueue:Add("party_refresh", RefreshPartyFrames)
            end
        else
            RefreshPartyFrames()
        end

        return
    end

    -- For UNIT_HEALTH, only process party units
    if event == "UNIT_HEALTH" then
        if not unit or not unit:match("^party%d$") then return end
        local frameIndex = tonumber(unit:match("party(%d)"))
        if frameIndex then
            local frame = _G['PartyMemberFrame' .. frameIndex]
            if frame and UnitExists(unit) then
                -- Skip disconnected frames — their visual state is managed by UpdateDisconnectedState
                if frame.DragonUI_Disconnected then return end
                local healthbar = _G[frame:GetName() .. 'HealthBar']
                local manabar = _G[frame:GetName() .. 'ManaBar']
                if healthbar then
                    -- Force re-clip with current values
                    local texture = healthbar:GetStatusBarTexture()
                    if texture then
                        local _, max = healthbar:GetMinMaxValues()
                        local current = healthbar:GetValue()
                        if max > 0 and current then
                            local percentage = math.min(math.max(current / max, 0.001), 1)
                            texture:SetTexCoord(0, percentage, 0, 1)
                        end
                    end
                    UpdateHealthText(healthbar, false)
                end
                if manabar then
                    local texture = manabar:GetStatusBarTexture()
                    if texture then
                        local _, max = manabar:GetMinMaxValues()
                        local current = manabar:GetValue()
                        if max > 0 and current then
                            local percentage = math.min(math.max(current / max, 0.001), 1)
                            texture:SetTexCoord(0, percentage, 0, 1)
                        end
                    end
                    UpdateManaText(manabar, false)
                end
            end
        end
        return
    end
    
    -- For party-wide events, refresh ALL party frames
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G['PartyMemberFrame' .. i]
        local unit = "party" .. i
        if frame and UnitExists(unit) then
            -- Skip disconnected frames — their visual state is managed by UpdateDisconnectedState
            if not frame.DragonUI_Disconnected then
            local healthbar = _G[frame:GetName() .. 'HealthBar']
            local manabar = _G[frame:GetName() .. 'ManaBar']
            if healthbar then
                local texture = healthbar:GetStatusBarTexture()
                if texture then
                    local _, max = healthbar:GetMinMaxValues()
                    local current = healthbar:GetValue()
                    if max > 0 and current then
                        local percentage = math.min(math.max(current / max, 0.001), 1)
                        texture:SetTexCoord(0, percentage, 0, 1)
                    end
                end
                UpdateHealthText(healthbar, false)
            end
            if manabar then
                local texture = manabar:GetStatusBarTexture()
                if texture then
                    local _, max = manabar:GetMinMaxValues()
                    local current = manabar:GetValue()
                    if max > 0 and current then
                        local percentage = math.min(math.max(current / max, 0.001), 1)
                        texture:SetTexCoord(0, percentage, 0, 1)
                    end
                end
                UpdateManaText(manabar, false)
            end
            end -- if not DragonUI_Disconnected
        end
    end
end)


-- ===============================================================
-- VEHICLE & RELOAD RECOVERY SYSTEM
-- ===============================================================
-- PartyMemberFrame_UpdateArt hook catches all vehicle art transitions.
-- PLAYER_ENTERING_WORLD with delay handles reload while in vehicle.

-- Reset portrait to DragonUI's expected position after Blizzard vehicle transitions
local function ResetPartyPortrait(frame)
    if InCombatLockdown() then return end
    local portrait = _G[frame:GetName() .. "Portrait"]
    if portrait then
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPLEFT", 7, -6)
        if IsPartyPortraitlessEnabled() then
            portrait:Hide()
        else
            portrait:Show()
        end
    end
end

-- Hook PartyMemberFrame_UpdateArt — catches both vehicle enter and exit
if type(PartyMemberFrame_UpdateArt) == "function" then
    hooksecurefunc("PartyMemberFrame_UpdateArt", function(frame)
        if not frame or not frame:GetName() then return end
        if not frame:GetName():match("^PartyMemberFrame%d+$") then return end

        local texture = _G[frame:GetName() .. "Texture"]
        if texture then
            texture:SetTexture()
            texture:Hide()
        end

        local bg = _G[frame:GetName() .. "Background"]
        if bg then
            bg:Hide()
        end

        local frameIndex = frame:GetID()
        local healthbar = _G[frame:GetName() .. "HealthBar"]
        if healthbar then
            healthbar:SetStatusBarTexture(TEXTURES.healthBar)
            UpdatePartyHealthBarColor(frameIndex)
        end

        if frame.DragonUI_BorderFrame and frame.DragonUI_BorderFrame.texture then
            if IsPartyPortraitlessEnabled() then
                frame.DragonUI_BorderFrame.texture:Hide()
            else
                frame.DragonUI_BorderFrame.texture:Show()
            end
        end

        UpdateManaBarTexture(frame)
        HideBlizzardTexts(frame)
        CreateCustomTexts(frame)
        UpdateDisconnectedState(frame)
        ApplyStandardPartyFrameLayout(frame)
        ResetPartyPortrait(frame)
    end)
end

-- Hook PartyMemberFrame_ToVehicleArt — hides the vehicle texture Blizzard shows
if type(PartyMemberFrame_ToVehicleArt) == "function" then
    hooksecurefunc("PartyMemberFrame_ToVehicleArt", function(frame)
        if not frame or not frame:GetName() then return end
        if not frame:GetName():match("^PartyMemberFrame%d+$") then return end

        -- Hide Blizzard vehicle texture
        local vehicleTex = _G[frame:GetName() .. "VehicleTexture"]
        if vehicleTex then
            vehicleTex:SetTexture()
            vehicleTex:Hide()
        end

        -- Also re-hide the normal texture (Blizzard may have restored it)
        local texture = _G[frame:GetName() .. "Texture"]
        if texture then
            texture:SetTexture()
            texture:Hide()
        end

        local bg = _G[frame:GetName() .. "Background"]
        if bg then
            bg:Hide()
        end

        -- Re-apply DragonUI styling
        local frameIndex = frame:GetID()
        local healthbar = _G[frame:GetName() .. "HealthBar"]
        if healthbar then
            healthbar:SetStatusBarTexture(TEXTURES.healthBar)
            UpdatePartyHealthBarColor(frameIndex)
        end

        if frame.DragonUI_BorderFrame and frame.DragonUI_BorderFrame.texture then
            if IsPartyPortraitlessEnabled() then
                frame.DragonUI_BorderFrame.texture:Hide()
            else
                frame.DragonUI_BorderFrame.texture:Show()
            end
        end

        UpdateManaBarTexture(frame)
        HideBlizzardTexts(frame)
        CreateCustomTexts(frame)
        UpdateDisconnectedState(frame)
        ResetPartyPortrait(frame)
    end)
end

-- Hook PartyMemberFrame_ToPlayerArt — re-applies DragonUI styling when exiting vehicle
if type(PartyMemberFrame_ToPlayerArt) == "function" then
    hooksecurefunc("PartyMemberFrame_ToPlayerArt", function(frame)
        if not frame or not frame:GetName() then return end
        if not frame:GetName():match("^PartyMemberFrame%d+$") then return end

        -- Hide vehicle texture (may linger)
        local vehicleTex = _G[frame:GetName() .. "VehicleTexture"]
        if vehicleTex then
            vehicleTex:SetTexture()
            vehicleTex:Hide()
        end

        -- Hide normal Blizzard texture
        local texture = _G[frame:GetName() .. "Texture"]
        if texture then
            texture:SetTexture()
            texture:Hide()
        end

        local bg = _G[frame:GetName() .. "Background"]
        if bg then
            bg:Hide()
        end

        -- Re-apply DragonUI styling
        local frameIndex = frame:GetID()
        local healthbar = _G[frame:GetName() .. "HealthBar"]
        if healthbar then
            healthbar:SetStatusBarTexture(TEXTURES.healthBar)
            UpdatePartyHealthBarColor(frameIndex)
        end

        if frame.DragonUI_BorderFrame and frame.DragonUI_BorderFrame.texture then
            if IsPartyPortraitlessEnabled() then
                frame.DragonUI_BorderFrame.texture:Hide()
            else
                frame.DragonUI_BorderFrame.texture:Show()
            end
        end

        UpdateManaBarTexture(frame)
        HideBlizzardTexts(frame)
        CreateCustomTexts(frame)
        UpdateDisconnectedState(frame)
        ResetPartyPortrait(frame)
    end)
end

-- Helper: full party frame refresh (shared by vehicle and reload recovery)
local function RefreshAllPartyFrames()
    StylePartyFrames()
    RepositionBlizzardBuffs()
    for i = 1, MAX_PARTY_MEMBERS do
        local frame = _G["PartyMemberFrame" .. i]
        if frame and UnitExists("party" .. i) then
            HideBlizzardTexts(frame)
            CreateCustomTexts(frame)
            UpdateManaBarTexture(frame)
            UpdateDisconnectedState(frame)
            ResetPartyPortrait(frame)
            local healthbar = _G[frame:GetName() .. "HealthBar"]
            local manabar = _G[frame:GetName() .. "ManaBar"]
            if healthbar then UpdateHealthText(healthbar, false) end
            if manabar then UpdateManaText(manabar, false) end
            UpdateAdditionalPartyResourceBars(frame)
        end
    end
end

-- Reload recovery: Blizzard re-initializes vehicle state after /reload
local vehicleRecoveryFrame = CreateFrame("Frame")
vehicleRecoveryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
vehicleRecoveryFrame:SetScript("OnEvent", function(self, event)
    if addon.core and addon.core.ScheduleTimer then
        addon.core:ScheduleTimer(function()
            -- Skip refresh during editor mode (prevents strata/visibility reset)
            if addon.EditorMode and addon.EditorMode:IsActive() then
                return
            end
            if InCombatLockdown() then
                if addon.CombatQueue then
                    addon.CombatQueue:Add("party_vehicle_recovery", RefreshAllPartyFrames)
                end
                return
            end
            RefreshAllPartyFrames()
        end, 0.8)
    end
end)

-- ===============================================================
-- MODULE LOADED CONFIRMATION
-- ===============================================================
