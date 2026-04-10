--[[
  DragonUI - Unit Frame Shared Core (uf_core.lua)
  Shared constants, utilities, and factory helpers for all unit frame modules.
  Loaded first via unitframes.xml; other UF modules reference addon.UF.
]]
local _, addon = ...

-- Create the shared UF namespace
addon.UF = addon.UF or {}
local UF = addon.UF

-- ============================================================================
-- TEXTURE PATH REGISTRY
-- ============================================================================
UF.TEXTURES = {
    -- Target-style frames (TargetFrame, FocusFrame)
    targetStyle = {
        BACKGROUND = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-Target-PortraitOn-BACKGROUND",
        BACKGROUND_FAT = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-Target-PortraitOn-BACKGROUND-Fat",
        BORDER = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-Target-PortraitOn-BORDER",
        BORDER_FAT = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-Target-PortraitOn-BORDER-Fat",
        BAR_PREFIX = "Interface\\AddOns\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Target-PortraitOn-Bar-",
        NAME_BACKGROUND = "Interface\\AddOns\\DragonUI\\Textures\\TargetFrame\\NameBackground",
        BOSS = "Interface\\AddOns\\DragonUI\\Textures\\uiunitframeboss2x",
        THREAT = "Interface\\AddOns\\DragonUI\\Textures\\Unitframe2x\\ui-hud-unitframe-target-portraiton-incombat-2x",
        THREAT_NUMERIC = "Interface\\AddOns\\DragonUI\\Textures\\uiunitframe",
    },
    -- Small-style frames (ToT, FoT, Pet)
    smallStyle = {
        BACKGROUND = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-BACKGROUND",
        BORDER = "Interface\\AddOns\\DragonUI\\Textures\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-BORDER",
        BAR_PREFIX = "Interface\\AddOns\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-",
        BOSS = "Interface\\AddOns\\DragonUI\\Textures\\uiunitframeboss2x",
    },
    -- Player frame (unique textures)
    player = {
        BASE = "Interface\\Addons\\DragonUI\\Textures\\uiunitframe",
        BASE_FAT = "Interface\\Addons\\DragonUI\\Textures\\uiunitframe-fat",
        HEALTH_BAR = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health",
        HEALTH_STATUS = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status",
        BORDER = "Interface\\Addons\\DragonUI\\Textures\\UI-HUD-UnitFrame-Player-PortraitOn-BORDER",
        BORDER_FAT = "Interface\\Addons\\DragonUI\\Textures\\UI-HUD-UnitFrame-Player-PortraitOn-BORDER-Fat",
        REST_ICON = "Interface\\AddOns\\DragonUI\\Textures\\PlayerFrame\\PlayerRestFlipbook",
        RUNE_TEXTURE = "Interface\\AddOns\\DragonUI\\Textures\\PlayerFrame\\ClassOverlayDeathKnightRunes",
        LFG_ICONS = "Interface\\AddOns\\DragonUI\\Textures\\PlayerFrame\\LFGRoleIcons",
        POWER_BARS = {
            MANA = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana",
            RAGE = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Rage",
            FOCUS = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Focus",
            ENERGY = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-Energy",
            RUNIC_POWER = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-RunicPower",
        },
    },
    -- Party frames (unique textures)
    party = {
        healthBarStatus = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health-Status",
        frame = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\uipartyframe",
        border = "Interface\\Addons\\DragonUI\\Textures\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-BORDER",
        healthBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health",
        manaBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Mana",
        focusBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Focus",
        rageBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Rage",
        energyBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-Energy",
        runicPowerBar = "Interface\\Addons\\DragonUI\\Textures\\Partyframe\\UI-HUD-UnitFrame-Party-PortraitOn-Bar-RunicPower",
    },
    -- Pet frame (constructs paths from prefix)
    pet = {
        TEXTURE_PATH = "Interface\\Addons\\DragonUI\\Textures\\",
        UNITFRAME_PATH = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\",
        ATLAS_TEXTURE = "Interface\\Addons\\DragonUI\\Textures\\uiunitframe",
        TOT_BASE = "UI-HUD-UnitFrame-TargetofTarget-PortraitOn-",
        POWER_TEXTURES = {
            MANA = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Mana",
            FOCUS = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Focus",
            RAGE = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Rage",
            ENERGY = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Energy",
            RUNIC_POWER = "Interface\\Addons\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-RunicPower",
        },
        COMBAT_TEX_COORDS = {0.3095703125, 0.4208984375, 0.3125, 0.404296875},
    },
    -- Shared class icon texture
    CLASS_ICON_ALTERNATIVE_PREFIX = "Interface\\AddOns\\DragonUI\\Textures\\ClassIcons\\",
    CLASS_ICON_ALTERNATIVE_SUFFIX = ".blp",
    CLASS_ICON = "Interface\\TargetingFrame\\UI-Classes-Circles",
}

-- ============================================================================
-- CLASSIFICATION COORDINATES
-- ============================================================================
UF.BOSS_COORDS = {
    targetStyle = {
        elite = {0.001953125, 0.314453125, 0.322265625, 0.630859375, 80, 79, 4, 1},
        rare = {0.00390625, 0.31640625, 0.64453125, 0.953125, 80, 79, 4, 1},
        rareelite = {0.001953125, 0.388671875, 0.001953125, 0.31835937, 99, 81, 13, 1},
    },
    smallStyle = {
        elite = {0.001953125, 0.314453125, 0.322265625, 0.630859375, 60, 59, 3, 1},
        rare = {0.00390625, 0.31640625, 0.64453125, 0.953125, 60, 59, 3, 1},
        rareelite = {0.001953125, 0.388671875, 0.001953125, 0.31835937, 74, 61, 10, 1},
    },
}

-- ============================================================================
-- POWER TYPE MAP
-- ============================================================================
UF.POWER_MAP = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [6] = "RunicPower",
}

-- ============================================================================
-- THREAT COLORS
-- ============================================================================
UF.THREAT_COLORS = {
    {1.0, 1.0, 0.47}, -- Low
    {1.0, 0.6, 0.0},  -- Medium
    {1.0, 0.0, 0.0},  -- High
}

-- ============================================================================
-- FAMOUS NPCs
-- ============================================================================
UF.FAMOUS_NPCS = {
    ["Patufet"] = true,
}

-- Legacy alias
addon.unitframe = addon.unitframe or {}
addon.unitframe.famous = UF.FAMOUS_NPCS

-- ============================================================================
-- LOCALE-AWARE DEFAULT FONT
-- ============================================================================
UF.DEFAULT_FONT = addon.Fonts and addon.Fonts.PRIMARY or "Fonts\\FRIZQT__.TTF"
UF.CLASSIC_CLASS_ICON_INSET = 0.012

-- ============================================================================
-- CONFIG ACCESS
-- ============================================================================
function UF.GetConfig(unitKey)
    local config = {}
    if addon.GetConfigValue then
        config = addon:GetConfigValue("unitframe", unitKey) or {}
    elseif addon.db and addon.db.profile and addon.db.profile.unitframe then
        config = addon.db.profile.unitframe[unitKey] or {}
    end

    local defaults = addon.defaults
        and addon.defaults.profile
        and addon.defaults.profile.unitframe
        and addon.defaults.profile.unitframe[unitKey] or {}

    return setmetatable(config, { __index = defaults })
end

function UF.IsEnabled(unitKey)
    local config = UF.GetConfig(unitKey)
    return config.enabled ~= false
end

-- ============================================================================
-- CLASSIFICATION HELPERS
-- ============================================================================
function UF.GetClassification(unit, famousNpcs)
    if not UnitExists(unit) then return nil end

    local classification = UnitClassification(unit)

    -- Famous NPC override
    if famousNpcs then
        local name = UnitName(unit)
        if name and famousNpcs[name] then
            local override = famousNpcs[name]
            if type(override) == "string" then
                classification = override
            end
        end
    end

    -- Vehicle override
    if UnitInVehicle and UnitInVehicle(unit) then
        classification = "normal"
    end

    -- Level -1 = boss
    if UnitLevel(unit) == -1 and classification ~= "worldboss" then
        if classification == "rare" then
            classification = "rareelite"
        elseif classification ~= "rareelite" then
            classification = "elite"
        end
    end

    return classification
end

function UF.GetBossCoords(classification, bossCoords)
    if not classification then return nil end
    return bossCoords[classification]
end

-- ============================================================================
-- CLASS PORTRAIT
-- ============================================================================
function UF.UseAlternativeClassIcons(unitKey)
    local config = UF.GetConfig(unitKey)
    return config and config.classPortrait and config.alternativeClassIcons or false
end

function UF.ApplyClassPortraitIcon(icon, classFileName, useAlternative)
    if not icon or not classFileName then return false end

    local function ClampInset(value)
        local inset = tonumber(value) or 0
        if inset < 0 then return 0 end
        if inset > 0.03 then return 0.03 end
        return inset
    end

    if useAlternative then
        icon:SetTexture(UF.TEXTURES.CLASS_ICON_ALTERNATIVE_PREFIX .. classFileName .. UF.TEXTURES.CLASS_ICON_ALTERNATIVE_SUFFIX)
        icon:SetTexCoord(0, 1, 0, 1)
        return true
    end

    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classFileName]
    if not coords then return false end

    local inset = ClampInset(UF.CLASSIC_CLASS_ICON_INSET)
    icon:SetTexture(UF.TEXTURES.CLASS_ICON)
    icon:SetTexCoord(coords[1] + inset, coords[2] - inset, coords[3] + inset, coords[4] - inset)
    return true
end

function UF.ApplyClassPortraitToTexture(unit, portraitTexture, useAlternative)
    if not portraitTexture or not unit then return false end
    if not UnitExists(unit) or not UnitIsPlayer(unit) then return false end

    -- ClassForge support
    local classForge = _G.ClassForge
    if classForge and classForge.GetDataForUnit and classForge.GetResolvedIconTexture then
        local data = classForge:GetDataForUnit(unit)
        local iconTexture = data and classForge:GetResolvedIconTexture(data.icon, data.className)
        if iconTexture and iconTexture ~= "" then
            portraitTexture:SetTexture(iconTexture)
            portraitTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            portraitTexture:SetAlpha(1)
            return true
        end
    end

    local _, classFileName = UnitClass(unit)
    if not classFileName then return false end

    if UF.ApplyClassPortraitIcon(portraitTexture, classFileName, useAlternative) then
        portraitTexture:SetAlpha(1)
        return true
    end
    return false
end

function UF.UpdateClassPortrait(unit, portrait, parentFrame, elements, enabled, useAlternative)
    if elements then
        if elements.classPortraitFrame then elements.classPortraitFrame:Hide() end
        if elements.classPortraitBg then elements.classPortraitBg:Hide() end
        if elements.classPortraitIcon then elements.classPortraitIcon:Hide() end
    end

    if not enabled then return false end

    if useAlternative == nil and parentFrame and parentFrame.unitKey then
        useAlternative = UF.UseAlternativeClassIcons(parentFrame.unitKey)
    end

    return UF.ApplyClassPortraitToTexture(unit, portrait, useAlternative)
end

-- ============================================================================
-- ANIMATED PORTRAITS (Final left-facing attempt for WotLK)
-- ============================================================================
local ANIMATED_PORTRAIT_MIN_SIZE = 30
local ANIMATED_PORTRAIT_CLIP_INSET = 2
local ANIMATED_PORTRAIT_RING_CLIP_RATIO = 0.92

local ANIMATED_PORTRAIT_DEFAULTS = {
    enabled = true,
    model_scale = 3.0,
    offset_x = 0,
    offset_y = 2,
    backdrop_alpha = 0.18,
}

-- Units that should face LEFT
local TARGET_LEFT_FACING_UNITS = {
    target       = true,
    focus        = true,
    targettarget = true,
    focustarget  = true,
}

local function GetAnimatedPortraitConfig()
    local cfg = addon.db
        and addon.db.profile
        and addon.db.profile.mrkrissatan_additions
        and addon.db.profile.mrkrissatan_additions.round3d_portraits

    if type(cfg) ~= "table" then
        return ANIMATED_PORTRAIT_DEFAULTS
    end
    return setmetatable(cfg, { __index = ANIMATED_PORTRAIT_DEFAULTS })
end

local function GetAnimatedPortraitState(texture)
    if not texture or not texture.GetParent then return nil end

    local state = texture.__DragonUIAnimatedPortrait
    if state then return state end

    local parent = texture:GetParent()
    if not parent then return nil end

    state = {
        texture = texture,
        parent = parent,
    }

    local drawLayer, subLevel = texture:GetDrawLayer()
    drawLayer = drawLayer or "ARTWORK"
    subLevel = tonumber(subLevel) or 0

    state.clipFrame = CreateFrame("Frame", nil, parent)
    state.clipFrame:Hide()
    state.clipFrame:EnableMouse(false)
    if state.clipFrame.SetClipsChildren then
        state.clipFrame:SetClipsChildren(true)
    end
    state.clipFrame:SetFrameStrata(parent:GetFrameStrata())
    state.clipFrame:SetFrameLevel(math.max(1, parent:GetFrameLevel() + subLevel))

    state.backLayer = state.clipFrame:CreateTexture(nil, drawLayer, nil, subLevel - 1)
    state.backLayer:Hide()

    state.modelLayer = CreateFrame("PlayerModel", nil, state.clipFrame)
    state.modelLayer:Hide()
    state.modelLayer:EnableMouse(false)
    state.modelLayer.parentTexture = texture

    texture.__DragonUIAnimatedPortrait = state
    return state
end

local function ShapeAnimatedPortrait(state, texture)
    if not state or not texture then return end

    local cfg = GetAnimatedPortraitConfig()
    local width  = texture:GetWidth() or 0
    local height = texture:GetHeight() or 0

    if width <= 0 or height <= 0 then
        local p = texture:GetParent()
        width  = p and p:GetWidth() or width
        height = p and p:GetHeight() or height
    end

    state.clipFrame:ClearAllPoints()
    local clipDiameter = math.min(width, height) - (ANIMATED_PORTRAIT_CLIP_INSET * 2)
    local clipSize = math.max(8, clipDiameter * ANIMATED_PORTRAIT_RING_CLIP_RATIO)

    state.clipFrame:SetSize(clipSize, clipSize)
    state.clipFrame:SetPoint("CENTER", texture, "CENTER", 0, 0)

    state.backLayer:ClearAllPoints()
    state.backLayer:SetAllPoints(state.clipFrame)

    state.modelLayer:ClearAllPoints()
    state.modelLayer:SetSize(clipSize, clipSize)
    state.modelLayer:SetPoint("CENTER", state.clipFrame, "CENTER", cfg.offset_x or 0, cfg.offset_y or 0)
end

local function ApplyAnimatedPortraitCamera(state, unit, cfg)
    if not state or not state.modelLayer then return end

    local model = state.modelLayer
    local isTargetStyle = TARGET_LEFT_FACING_UNITS[unit or ""]

    if unit and model.SetUnit then
        model:SetUnit(unit)
    end

    model:SetCamera(0)

    local modelScale = cfg.model_scale or ANIMATED_PORTRAIT_DEFAULTS.model_scale
    if isTargetStyle then
        modelScale = modelScale * 0.88   -- tighter for better rotation visibility
    end

    if model.SetPortraitZoom then
        local portraitZoom = ((modelScale - 1.2) / (5.0 - 1.2)) * 1.2
        portraitZoom = math.max(0, math.min(1, portraitZoom))
        model:SetPortraitZoom(portraitZoom)
    end

    if model.SetCamDistanceScale then
        local camScale = 1 / math.max(0.25, modelScale)
        camScale = camScale * 0.78
        model:SetCamDistanceScale(math.max(0.08, math.min(1, camScale)))
    end

    -- Position nudge - this is often more effective than facing alone in WotLK
    if model.SetPosition then
        if isTargetStyle then
            model:SetPosition(-0.35, 0, -0.02)   -- negative X often flips direction
        else
            model:SetPosition(0, 0, 0)
        end
    end

    -- Try both SetFacing and SetRotation
    local facing = isTargetStyle and math.pi or 0

    if model.SetFacing then
        model:SetFacing(facing)
    end
    if model.SetRotation then
        model:SetRotation(facing)
    end
end

function UF.HideAnimatedPortrait(texture, restoreTexture)
    local state = texture and texture.__DragonUIAnimatedPortrait or nil
    if not state then
        if texture and restoreTexture then
            texture:Show()
            texture:SetAlpha(1)
        end
        return
    end

    if state.clipFrame then state.clipFrame:Hide() end
    state.backLayer:Hide()
    state.modelLayer:Hide()

    if restoreTexture then
        texture:Show()
        texture:SetAlpha(1)
    end
end

function UF.UpdateAnimatedPortrait(unit, texture, opts)
    if not texture or not unit then return false end

    opts = opts or {}
    local cfg = GetAnimatedPortraitConfig()

    if cfg.enabled == false then
        UF.HideAnimatedPortrait(texture, true)
        return false
    end

    if not UnitExists(unit)
        or not UnitIsVisible(unit)
        or unit == "vehicle"
        or (texture.GetWidth and texture:GetWidth() < ANIMATED_PORTRAIT_MIN_SIZE)
        or (texture.GetHeight and texture:GetHeight() < ANIMATED_PORTRAIT_MIN_SIZE) then
        UF.HideAnimatedPortrait(texture, true)
        return false
    end

    local state = GetAnimatedPortraitState(texture)
    if not state then return false end

    ShapeAnimatedPortrait(state, texture)

    if state.modelLayer.ClearModel then
        state.modelLayer:ClearModel()
    end

    state.modelLayer:SetUnit(unit)
    ApplyAnimatedPortraitCamera(state, unit, cfg)

    -- Very aggressive refresh schedule (this helps a lot in WotLK)
    local cameraApplyToken = (state.cameraApplyToken or 0) + 1
    state.cameraApplyToken = cameraApplyToken

    if addon.After then
        for _, delay in ipairs({0, 0.02, 0.06, 0.12, 0.25, 0.5, 0.9, 1.5}) do
            addon:After(delay, function()
                if texture.__DragonUIAnimatedPortrait ~= state or state.cameraApplyToken ~= cameraApplyToken then
                    return
                end
                ApplyAnimatedPortraitCamera(state, unit, cfg)
            end)
        end
    end

    -- Backdrop coloring
    local backdropAlpha = opts.backdropAlpha ~= nil and opts.backdropAlpha or cfg.backdrop_alpha

    if opts.backdropColor then
        local c = opts.backdropColor
        state.backLayer:SetTexture(c.r or 0.5, c.g or 0.5, c.b or 0.5, c.a or backdropAlpha)
    elseif UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if color then
            state.backLayer:SetTexture(color.r * 0.55, color.g * 0.55, color.b * 0.55, backdropAlpha)
        else
            state.backLayer:SetTexture(0.5, 0.5, 0.5, backdropAlpha)
        end
    else
        state.backLayer:SetTexture(0.5, 0.5, 0.5, backdropAlpha)
    end

    if state.clipFrame then state.clipFrame:Show() end
    state.backLayer:Show()
    state.modelLayer:Show()
    texture:Hide()

    return true
end

-- ============================================================================
-- BAR HOOK HELPERS
-- ============================================================================
function UF.SetupHealthBarHook(healthBar, statusTexture, useClassColor)
    if not healthBar then return end

    hooksecurefunc(healthBar, "SetValue", function(self)
        local min, max = self:GetMinMaxValues()
        local val = self:GetValue()
        if max > 0 and val > 0 then
            local pct = val / max

            if statusTexture then
                statusTexture:SetTexCoord(0, pct, 0, 1)
                statusTexture:SetWidth(self:GetWidth() * pct)
            end

            if useClassColor then
                local unit = self.unit or (self:GetParent() and self:GetParent().unit)
                if unit and UnitExists(unit) and UnitIsPlayer(unit) then
                    local _, class = UnitClass(unit)
                    if class then
                        local color = RAID_CLASS_COLORS[class]
                        if color and statusTexture then
                            statusTexture:SetVertexColor(color.r, color.g, color.b)
                        end
                    end
                end
            end
        end
    end)
end

function UF.GetPowerBarTextureSuffix(powerType)
    return UF.POWER_MAP[powerType] or "Mana"
end

function UF.GetPartyPowerBarTexture(unit)
    if not unit or not UnitExists(unit) then
        return UF.TEXTURES.party.manaBar
    end

    local powerType = UnitPowerType(unit)
    if powerType == 1 then
        return UF.TEXTURES.party.rageBar
    elseif powerType == 2 then
        return UF.TEXTURES.party.focusBar
    elseif powerType == 3 then
        return UF.TEXTURES.party.energyBar
    elseif powerType == 6 then
        return UF.TEXTURES.party.runicPowerBar
    else
        return UF.TEXTURES.party.manaBar
    end
end

function UF.GetPetPowerTexture(powerTypeString)
    return UF.TEXTURES.pet.POWER_TEXTURES[powerTypeString]
        or UF.TEXTURES.pet.POWER_TEXTURES.MANA
end

-- ============================================================================
-- MODULE TEMPLATE
-- ============================================================================
function UF.CreateModule(name)
    return {
        name = name,
        overlay = nil,
        textSystem = nil,
        initialized = false,
        configured = false,
        eventsFrame = nil,
        elements = {},
    }
end