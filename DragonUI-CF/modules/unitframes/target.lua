--[[
  DragonUI - Target Frame Module (target.lua)

  Target-specific configuration and hooks passed to the
  UF.TargetStyle closure factory defined in target_style.lua.
]]

local addon = select(2, ...)
local UF = addon.UF

-- ============================================================================
-- BLIZZARD FRAME CACHE
-- ============================================================================

local TargetFrame                      = _G.TargetFrame
local TargetFrameHealthBar             = _G.TargetFrameHealthBar
local TargetFrameManaBar               = _G.TargetFrameManaBar
local TargetFramePortrait              = _G.TargetFramePortrait
local TargetFrameTextureFrameName      = _G.TargetFrameTextureFrameName
local TargetFrameTextureFrameLevelText = _G.TargetFrameTextureFrameLevelText
local TargetFrameNameBackground        = _G.TargetFrameNameBackground

local FocusFrame = _G.FocusFrame

-- Detached ToT/FoT aura layout hook (safe: post-hook only, no ToT/FoT Hide/Show)
local MAX_TARGET_BUFFS = _G.MAX_TARGET_BUFFS or 32
local MAX_TARGET_DEBUFFS = _G.MAX_TARGET_DEBUFFS or 16
local AURA_OFFSET_Y = _G.AURA_OFFSET_Y or 3
local AURA_START_X = _G.AURA_START_X or 5
local AURA_START_Y = _G.AURA_START_Y or 32
local SMALL_AURA_SIZE = _G.SMALL_AURA_SIZE or 17
local LARGE_AURA_SIZE = _G.LARGE_AURA_SIZE or 21
local DEFAULT_AURA_ROW_WIDTH = 122
local POWER_MAP = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [6] = "RunicPower",
}

local CLASSLESS_RESOURCE_OFFSET_X = 0
local CLASSLESS_RESOURCE_OFFSET_Y = -7
local TARGET_AURA_OFFSET_X = 105
local TARGET_AURA_OFFSET_Y = -52
local CLASSLESS_RUNE_OFFSET_Y = -28
local EXTRA_POWER_BAR_OFFSET_X = 10
local EXTRA_POWER_BAR_OFFSET_Y = -4
local EXTRA_POWER_BAR_SPACING = 8
local EXTRA_POWER_BAR_WIDTH = 125
local EXTRA_POWER_BAR_HEIGHT = 8

local RUNE_COORDS = {
    [1] = {0 / 128, 34 / 128, 0 / 128, 34 / 128},
    [2] = {0 / 128, 34 / 128, 68 / 128, 102 / 128},
    [3] = {34 / 128, 68 / 128, 0 / 128, 34 / 128},
    [4] = {68 / 128, 102 / 128, 0 / 128, 34 / 128},
}

local TARGET_RUNE_LAYOUT = {1, 1, 3, 3, 2, 2}
local TARGET_RUNE_SLOTS = {1, 2, 5, 6, 3, 4}

local frameElements = {
    classlessResources = nil,
}

local function SafeUnitPower(unit, powerType)
    if not UnitPower then
        return 0
    end

    local ok, value = pcall(UnitPower, unit, powerType)
    if ok and value then
        return value
    end

    return 0
end

local function SafeUnitPowerMax(unit, powerType)
    if not UnitPowerMax then
        return 0
    end

    local ok, value = pcall(UnitPowerMax, unit, powerType)
    if ok and value then
        return value
    end

    return 0
end

local function SafeRuneCooldown(index)
    if not GetRuneCooldown then
        return nil, nil, true
    end

    local ok, start, duration, ready = pcall(GetRuneCooldown, index)
    if ok then
        return start, duration, ready
    end

    return nil, nil, true
end

local isUpdatingTargetMainPowerBar = false

local function UpdateTargetMainPowerBar(unit)
    unit = unit or "target"
    if isUpdatingTargetMainPowerBar or not TargetFrameManaBar or not UnitExists(unit) then
        return
    end

    isUpdatingTargetMainPowerBar = true

    local powerType = UnitIsPlayer(unit) and 0 or UnitPowerType(unit)
    local powerName = POWER_MAP[powerType] or "Mana"
    local current = SafeUnitPower(unit, powerType)
    local maximum = SafeUnitPowerMax(unit, powerType)
    local texture = TargetFrameManaBar:GetStatusBarTexture()

    TargetFrameManaBar:SetMinMaxValues(0, maximum > 0 and maximum or 1)
    TargetFrameManaBar:SetValue(current or 0)
    TargetFrameManaBar:SetStatusBarColor(1, 1, 1, 1)

    if texture then
        texture:SetTexture("Interface\\AddOns\\DragonUI\\Textures\\Unitframe\\UI-HUD-UnitFrame-Player-PortraitOn-Bar-" .. powerName)
        texture:SetDrawLayer("ARTWORK", 1)
        texture:SetVertexColor(1, 1, 1, 1)
        if maximum > 0 and current then
            texture:SetTexCoord(0, current / maximum, 0, 1)
        else
            texture:SetTexCoord(0, 0.001, 0, 1)
        end
    end

    isUpdatingTargetMainPowerBar = false
end

local function CreateClasslessResources()
    if frameElements.classlessResources then
        return frameElements.classlessResources
    end

    local holder = CreateFrame("Frame", "DragonUI_TargetClasslessResources", TargetFrame)
    holder:SetSize(140, 40)
    holder:SetPoint("TOPLEFT", TargetFrameManaBar, "BOTTOMLEFT", CLASSLESS_RESOURCE_OFFSET_X, CLASSLESS_RESOURCE_OFFSET_Y)
    holder:Hide()
    holder.runes = {}

    for index = 1, 6 do
        local rune = CreateFrame("Frame", nil, holder)
        rune:SetSize(19, 19)
        if index == 1 then
            rune:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, CLASSLESS_RUNE_OFFSET_Y)
        else
            rune:SetPoint("LEFT", holder.runes[index - 1], "RIGHT", 4, 0)
        end

        local icon = rune:CreateTexture(nil, "OVERLAY")
        icon:SetAllPoints(rune)
        icon:SetTexture("Interface\\AddOns\\DragonUI\\Textures\\PlayerFrame\\ClassOverlayDeathKnightRunes")
        icon:SetTexCoord(unpack(RUNE_COORDS[TARGET_RUNE_LAYOUT[index]] or RUNE_COORDS[1]))

        local cooldown = CreateFrame("Cooldown", nil, rune, "CooldownFrameTemplate")
        cooldown:SetAllPoints(rune)
        cooldown:Hide()

        rune.icon = icon
        rune.cooldown = cooldown
        holder.runes[index] = rune
    end

    frameElements.classlessResources = holder
    return holder
end

local function IsIgnoredTargetStatusBar(frame)
    if frame == TargetFrameHealthBar or frame == TargetFrameManaBar then
        return true
    end

    local name = frame.GetName and frame:GetName()
    if name and (name:find("Health") or name:find("Mana") or name:find("Cast") or name:find("Spell")) then
        return true
    end

    return false
end

local function CollectTargetStatusBars(parent, bars, depth)
    if not parent or depth > 4 or not parent.GetChildren then
        return
    end

    local children = {parent:GetChildren()}
    for _, child in ipairs(children) do
        if child and child.GetObjectType and child:GetObjectType() == "StatusBar" and not IsIgnoredTargetStatusBar(child) then
            table.insert(bars, child)
        end
        CollectTargetStatusBars(child, bars, depth + 1)
    end
end

local function MoveBarTextRegions(bar)
    if not bar or not bar.GetRegions then
        return
    end

    for _, region in ipairs({bar:GetRegions()}) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:ClearAllPoints()
            region:SetPoint("CENTER", bar, "CENTER", 0, 0)
            if region.SetDrawLayer then
                region:SetDrawLayer("OVERLAY", 7)
            end
        end
    end

    local textFields = {"TextString", "LeftText", "RightText", "text", "valueText"}
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

local function MoveNearbyMouseOverlay(bar, oldLeft, oldTop)
    if not bar or not TargetFrame or not TargetFrame.GetChildren or not oldLeft or not oldTop then
        return
    end

    for _, child in ipairs({TargetFrame:GetChildren()}) do
        if child and child ~= bar and child.IsMouseEnabled and child:IsMouseEnabled()
            and child.GetObjectType and child:GetObjectType() ~= "StatusBar" then
            local width, height = child:GetWidth() or 0, child:GetHeight() or 0
            local childLeft, childTop = child:GetLeft(), child:GetTop()
            if childLeft and childTop
                and math.abs(childLeft - oldLeft) < 8
                and math.abs(childTop - oldTop) < 8
                and width > 30 and width < 150
                and height > 2 and height < 18 then
                child:ClearAllPoints()
                child:SetAllPoints(bar)
                child:SetFrameLevel(bar:GetFrameLevel() + 1)
            end
        end
    end
end

local function MoveDefaultClasslessResourceBars()
    if not TargetFrame or not TargetFrameManaBar or not UnitExists("target") or not UnitIsPlayer("target") then
        return
    end

    local bars = {}
    CollectTargetStatusBars(TargetFrame, bars, 0)
    table.sort(bars, function(a, b)
        return (a:GetTop() or 0) > (b:GetTop() or 0)
    end)

    local moved = 0
    for _, bar in ipairs(bars) do
        if bar and bar:IsShown() then
            moved = moved + 1
            local oldLeft, oldTop = bar:GetLeft(), bar:GetTop()
            bar:ClearAllPoints()
            bar:SetSize(EXTRA_POWER_BAR_WIDTH, EXTRA_POWER_BAR_HEIGHT)
            bar:SetPoint("TOPLEFT", TargetFrameManaBar, "BOTTOMLEFT",
                EXTRA_POWER_BAR_OFFSET_X,
                EXTRA_POWER_BAR_OFFSET_Y - ((moved - 1) * EXTRA_POWER_BAR_SPACING))
            bar:SetFrameLevel(TargetFrame:GetFrameLevel() + 1)
            MoveBarTextRegions(bar)
            MoveNearbyMouseOverlay(bar, oldLeft, oldTop)
            bar:Show()

            if moved >= 2 then
                break
            end
        end
    end
end

local function UpdateClasslessResources(unit)
    unit = unit or "target"

    local holder = frameElements.classlessResources or CreateClasslessResources()
    if not holder then
        return
    end

    if not UnitExists(unit) or not UnitIsPlayer(unit) then
        holder:Hide()
        return
    end

    holder:Show()
    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT", TargetFrameManaBar, "BOTTOMLEFT", CLASSLESS_RESOURCE_OFFSET_X, CLASSLESS_RESOURCE_OFFSET_Y)
    MoveDefaultClasslessResourceBars()

    local canTrackCooldowns = UnitIsUnit and UnitIsUnit(unit, "player")
    for index, rune in ipairs(holder.runes) do
        local runeType = TARGET_RUNE_LAYOUT[index] or 1
        local runeSlot = TARGET_RUNE_SLOTS[index] or index
        if rune.icon then
            rune.icon:SetTexCoord(unpack(RUNE_COORDS[runeType] or RUNE_COORDS[1]))
        end

        if canTrackCooldowns then
            local start, duration, ready = SafeRuneCooldown(runeSlot)
            local onCooldown = start and duration and duration > 0 and not ready
            if onCooldown then
                if rune.cooldown and CooldownFrame_SetTimer then
                    CooldownFrame_SetTimer(rune.cooldown, start, duration, 1)
                    rune.cooldown:Show()
                elseif rune.cooldown then
                    rune.cooldown:Hide()
                end
                if rune.icon then
                    rune.icon:SetVertexColor(0.35, 0.35, 0.35, 1)
                end
                rune:SetAlpha(0.65)
            else
                if rune.cooldown then
                    rune.cooldown:Hide()
                end
                if rune.icon then
                    rune.icon:SetVertexColor(1, 1, 1, 1)
                end
                rune:SetAlpha(1)
            end
        else
            if rune.cooldown then
                rune.cooldown:Hide()
            end
            if rune.icon then
                rune.icon:SetVertexColor(1, 1, 1, 1)
            end
            rune:SetAlpha(1)
        end
        rune:Show()
    end
end

local function RepositionTargetAuras()
    if not TargetFrameManaBar then
        return
    end

    local yOffset = frameElements.classlessResources and frameElements.classlessResources:IsShown() and TARGET_AURA_OFFSET_Y or -14
    local firstBuff = _G.TargetFrameBuff1
    if firstBuff and firstBuff:IsShown() then
        firstBuff:ClearAllPoints()
        firstBuff:SetPoint("TOPLEFT", TargetFrameManaBar, "BOTTOMLEFT", TARGET_AURA_OFFSET_X, yOffset)
    end

    local firstDebuff = _G.TargetFrameDebuff1
    if firstDebuff and firstDebuff:IsShown() and not (firstBuff and firstBuff:IsShown()) then
        firstDebuff:ClearAllPoints()
        firstDebuff:SetPoint("TOPLEFT", TargetFrameManaBar, "BOTTOMLEFT", TARGET_AURA_OFFSET_X, yOffset)
    end
end

local function IsToTDetached()
    local cfg = addon.db and addon.db.profile and addon.db.profile.unitframe and addon.db.profile.unitframe.tot
    return cfg and cfg.override == true
end

local function IsToFDetached()
    local cfg = addon.db and addon.db.profile and addon.db.profile.unitframe and addon.db.profile.unitframe.fot
    return cfg and cfg.override == true
end

local function ShouldUseDetachedAuraLayout(frame)
    if frame == TargetFrame then
        return IsToTDetached()
    end
    if frame == FocusFrame then
        return IsToFDetached()
    end
    return false
end

local function GetAuraCountsAndSizes(frame)
    local selfName = frame and frame.GetName and frame:GetName()
    if not selfName then
        return 0, 0, {}, {}
    end

    local numBuffs = 0
    local numDebuffs = 0
    local largeBuffList = {}
    local largeDebuffList = {}

    for i = 1, MAX_TARGET_BUFFS do
        local buff = _G[selfName .. "Buff" .. i]
        if not buff or not buff:IsShown() then
            break
        end
        numBuffs = i
        largeBuffList[i] = (buff:GetWidth() or SMALL_AURA_SIZE) > SMALL_AURA_SIZE
    end

    for i = 1, MAX_TARGET_DEBUFFS do
        local debuff = _G[selfName .. "Debuff" .. i]
        if not debuff or not debuff:IsShown() then
            break
        end
        numDebuffs = i
        largeDebuffList[i] = (debuff:GetWidth() or SMALL_AURA_SIZE) > SMALL_AURA_SIZE
    end

    return numBuffs, numDebuffs, largeBuffList, largeDebuffList
end

local function UpdateAuraPositionsDetached(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc,
                                           maxRowWidth, offsetX, mirrorAurasVertically)
    local size
    local offsetY = AURA_OFFSET_Y
    local rowWidth = 0
    local firstAuraOnRow = 1

    for i = 1, numAuras do
        if largeAuraList[i] then
            size = LARGE_AURA_SIZE
            offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y
        else
            size = SMALL_AURA_SIZE
        end

        if i == 1 then
            rowWidth = size
            self.auraRows = self.auraRows + 1
        else
            rowWidth = rowWidth + size + offsetX
        end

        if rowWidth > maxRowWidth then
            updateFunc(self, auraName, i, numOppositeAuras, firstAuraOnRow, size, offsetX, offsetY, mirrorAurasVertically)
            rowWidth = size
            self.auraRows = self.auraRows + 1
            firstAuraOnRow = i
            offsetY = AURA_OFFSET_Y
        else
            updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically)
        end
    end
end

local function UpdateBuffAnchorDetached(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY,
                                        mirrorVertically)
    local point, relativePoint
    local startY, auraOffsetY

    if mirrorVertically then
        point = "BOTTOM"
        relativePoint = "TOP"
        startY = -15
        offsetY = -offsetY
        auraOffsetY = -AURA_OFFSET_Y
    else
        point = "TOP"
        relativePoint = "BOTTOM"
        startY = AURA_START_Y
        auraOffsetY = AURA_OFFSET_Y
    end

    local buff = _G[buffName .. index]
    if not buff then
        return
    end

    if index == 1 then
        if UnitIsFriend("player", self.unit) or numDebuffs == 0 then
            buff:SetPoint(point .. "LEFT", self, relativePoint .. "LEFT", AURA_START_X, startY)
        else
            buff:SetPoint(point .. "LEFT", self.debuffs, relativePoint .. "LEFT", 0, -offsetY)
        end
        self.buffs:SetPoint(point .. "LEFT", buff, point .. "LEFT", 0, 0)
        self.buffs:SetPoint(relativePoint .. "LEFT", buff, relativePoint .. "LEFT", 0, -auraOffsetY)
        self.spellbarAnchor = buff
    elseif anchorIndex ~= (index - 1) then
        buff:SetPoint(point .. "LEFT", _G[buffName .. anchorIndex], relativePoint .. "LEFT", 0, -offsetY)
        self.buffs:SetPoint(relativePoint .. "LEFT", buff, relativePoint .. "LEFT", 0, -auraOffsetY)
        self.spellbarAnchor = buff
    else
        buff:SetPoint(point .. "LEFT", _G[buffName .. anchorIndex], point .. "RIGHT", offsetX, 0)
    end

    buff:SetWidth(size)
    buff:SetHeight(size)
end

local function UpdateDebuffAnchorDetached(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY,
                                          mirrorVertically)
    local debuff = _G[debuffName .. index]
    local isFriend = UnitIsFriend("player", self.unit)
    local point, relativePoint
    local startY, auraOffsetY

    if mirrorVertically then
        point = "BOTTOM"
        relativePoint = "TOP"
        startY = -15
        offsetY = -offsetY
        auraOffsetY = -AURA_OFFSET_Y
    else
        point = "TOP"
        relativePoint = "BOTTOM"
        startY = AURA_START_Y
        auraOffsetY = AURA_OFFSET_Y
    end

    if not debuff then
        return
    end

    if index == 1 then
        if isFriend and numBuffs > 0 then
            debuff:SetPoint(point .. "LEFT", self.buffs, relativePoint .. "LEFT", 0, -offsetY)
        else
            debuff:SetPoint(point .. "LEFT", self, relativePoint .. "LEFT", AURA_START_X, startY)
        end
        self.debuffs:SetPoint(point .. "LEFT", debuff, point .. "LEFT", 0, 0)
        self.debuffs:SetPoint(relativePoint .. "LEFT", debuff, relativePoint .. "LEFT", 0, -auraOffsetY)
        if isFriend or (not isFriend and numBuffs == 0) then
            self.spellbarAnchor = debuff
        end
    elseif anchorIndex ~= (index - 1) then
        debuff:SetPoint(point .. "LEFT", _G[debuffName .. anchorIndex], relativePoint .. "LEFT", 0, -offsetY)
        self.debuffs:SetPoint(relativePoint .. "LEFT", debuff, relativePoint .. "LEFT", 0, -auraOffsetY)
        if isFriend or (not isFriend and numBuffs == 0) then
            self.spellbarAnchor = debuff
        end
    else
        debuff:SetPoint(point .. "LEFT", _G[debuffName .. (index - 1)], point .. "RIGHT", offsetX, 0)
    end

    debuff:SetWidth(size)
    debuff:SetHeight(size)
    local border = _G[debuffName .. index .. "Border"]
    if border then
        border:SetWidth(size + 2)
        border:SetHeight(size + 2)
    end
end

local function ApplyDetachedAuraLayout(frame)
    if not frame or not frame.unit or not UnitExists(frame.unit) then
        return
    end

    local frameName = frame:GetName()
    if frameName ~= "TargetFrame" and frameName ~= "FocusFrame" then
        return
    end

    local numBuffs, numDebuffs, largeBuffList, largeDebuffList = GetAuraCountsAndSizes(frame)
    if numBuffs == 0 and numDebuffs == 0 then
        return
    end

    frame.auraRows = 0
    local mirrorAurasVertically = frame.buffsOnTop and true or false
    frame.spellbarAnchor = nil

    UpdateAuraPositionsDetached(frame, frameName .. "Buff", numBuffs, numDebuffs, largeBuffList,
        UpdateBuffAnchorDetached, DEFAULT_AURA_ROW_WIDTH, 3, mirrorAurasVertically)
    UpdateAuraPositionsDetached(frame, frameName .. "Debuff", numDebuffs, numBuffs, largeDebuffList,
        UpdateDebuffAnchorDetached, DEFAULT_AURA_ROW_WIDTH, 3, mirrorAurasVertically)

    if frame.spellbar and _G.Target_Spellbar_AdjustPosition then
        _G.Target_Spellbar_AdjustPosition(frame.spellbar)
    end
end

local function InstallDetachedAuraLayoutHook()
    if _G.DragonUI_DetachedAuraLayoutHooked then
        return
    end
    if type(_G.TargetFrame_UpdateAuras) ~= "function" then
        return
    end

    hooksecurefunc("TargetFrame_UpdateAuras", function(frame)
        if ShouldUseDetachedAuraLayout(frame) then
            ApplyDetachedAuraLayout(frame)
        end
    end)

    _G.DragonUI_DetachedAuraLayoutHooked = true
end

-- ============================================================================
-- CREATE VIA FACTORY
-- ============================================================================

local api = UF.TargetStyle.Create({
    -- Identity
    configKey        = "target",
    unitToken        = "target",
    widgetKey        = "target",
    combatQueueKey   = "target_position",

    -- Blizzard frame references
    blizzFrame       = TargetFrame,
    healthBar        = TargetFrameHealthBar,
    manaBar          = TargetFrameManaBar,
    portrait         = TargetFramePortrait,
    nameText         = TargetFrameTextureFrameName,
    levelText        = TargetFrameTextureFrameLevelText,
    nameBackground   = TargetFrameNameBackground,

    -- Naming & layout
    namePrefix       = "Target",
    defaultPos       = { anchor = "TOPLEFT", posX = 250, posY = -4 },
    overlaySize      = { 200, 75 },

    -- Events
    unitChangedEvent = "PLAYER_TARGET_CHANGED",
    extraEvents      = {
        "UNIT_MODEL_CHANGED",
        "UNIT_LEVEL",
        "UNIT_NAME_UPDATE",
        "UNIT_PORTRAIT_UPDATE",
        "UNIT_AURA",
        "UNIT_MANA",
        "UNIT_MAXMANA",
        "UNIT_RAGE",
        "UNIT_MAXRAGE",
        "UNIT_ENERGY",
        "UNIT_MAXENERGY",
        "UNIT_RUNIC_POWER",
        "UNIT_MAXRUNIC_POWER",
        "RUNE_TYPE_UPDATE",
        "RUNE_POWER_UPDATE",
    },

    -- Feature flags
    forceLayoutOnUnitChange = true,   -- ReapplyElementPositions on every change
    hasTapDenied            = true,   -- Grey name bg for tapped-by-other targets

    -- Blizzard elements to hide
    hideListFn = function()
        return {
            _G.TargetFrameTextureFrameTexture,
            _G.TargetFrameBackground,
            _G.TargetFrameFlash,
            _G.TargetFrameNumericalThreat,
            TargetFrame.threatNumericIndicator,
            TargetFrame.threatIndicator,
            -- ToT children (visible as part of TargetFrame even if ToT module is disabled)
            _G.TargetFrameToTBackground,
            _G.TargetFrameToTTextureFrameTexture,
        }
    end,

    -- Famous NPC callback (message throttle)
    onFamousNpc = function(name, cache)
        local now = GetTime()
        if cache.lastFamousTarget ~= name
           or (now - cache.lastFamousMessage) > 5 then
            cache.lastFamousMessage = now
            cache.lastFamousTarget  = name
        end
    end,

    -- ----------------------------------------------------------------
    -- After-init hooks
    -- ----------------------------------------------------------------
    afterInit = function(ctx)
        CreateClasslessResources()

        if not ctx.Module.classlessPowerHooked then
            hooksecurefunc(TargetFrameManaBar, "SetValue", function()
                if UnitExists("target") then
                    UpdateTargetMainPowerBar("target")
                end
            end)

            hooksecurefunc(TargetFrameManaBar, "SetStatusBarTexture", function()
                if UnitExists("target") then
                    UpdateTargetMainPowerBar("target")
                end
            end)

            ctx.Module.classlessPowerHooked = true
        end

        -- Keep Blizzard threat flash suppressed so combat does not draw red portrait lines.
        if not ctx.Module.threatHooked then
            hooksecurefunc("TargetFrame_CheckClassification",
                function()
                    local threatFlash = _G.TargetFrameFlash
                    if threatFlash then
                        threatFlash:SetAlpha(0)
                        threatFlash:Hide()
                    end
                end)

            hooksecurefunc(TargetFrameFlash, "Show", function(self)
                self:SetAlpha(0)
                self:Hide()
            end)
            ctx.Module.threatHooked = true
        end

        -- Classification delay frame + hooks
        if not ctx.Module.classificationHooked then
            local delayFrame = CreateFrame("Frame")
            delayFrame:Hide()
            delayFrame.elapsed = 0
            delayFrame:SetScript("OnUpdate", function(self, dt)
                self.elapsed = self.elapsed + dt
                if self.elapsed >= 0.1 then
                    self:Hide()
                    if UnitExists("target") then
                        ctx.UpdateClassification()
                    end
                end
            end)

            if _G.TargetFrame_CheckClassification then
                hooksecurefunc("TargetFrame_CheckClassification",
                    function()
                        if UnitExists("target") then
                            delayFrame.elapsed = 0
                            delayFrame:Show()
                        end
                    end)
            end

            if _G.TargetFrame_Update then
                hooksecurefunc("TargetFrame_Update", function()
                    if UnitExists("target") then
                        ctx.UpdateClassification()
                    end
                end)
            end

            ctx.Module.classificationHooked = true
        end

        InstallDetachedAuraLayoutHook()
        if UnitExists("target") then
            UpdateTargetMainPowerBar("target")
            UpdateClasslessResources("target")
            RepositionTargetAuras()
        end
     end,

    -- ----------------------------------------------------------------
    -- Class color hooks
    -- ----------------------------------------------------------------
    setupExtraHooks = function(UpdateHealthBarColor, UpdateClassPortrait)
        if not _G.DragonUI_TargetHealthHookSetup then
            hooksecurefunc("UnitFrameHealthBar_Update",
                function(statusbar, unit)
                    if statusbar == TargetFrameHealthBar
                       and unit == "target" then
                        UpdateHealthBarColor()
                    end
                end)

            hooksecurefunc("TargetFrame_Update", function()
                if UnitExists("target") then
                    UpdateHealthBarColor()
                    UpdateClassPortrait()
                    UpdateTargetMainPowerBar("target")
                    UpdateClasslessResources("target")
                    RepositionTargetAuras()
                end
            end)

            -- UnitFramePortrait_Update is already hooked in SetupBarHooks

            _G.DragonUI_TargetHealthHookSetup = true
        end
    end,

    -- ----------------------------------------------------------------
    -- Extra event handler
    -- ----------------------------------------------------------------
    extraEventHandler = function(event, unitToken, UpdateClassification,
                                  UpdateHealthBarColor, ForceUpdatePowerBar,
                                  textSystem, ...)
        local unit = ...

        if event == "RUNE_TYPE_UPDATE" or event == "RUNE_POWER_UPDATE" then
            if UnitExists(unitToken) then
                UpdateClasslessResources(unitToken)
                RepositionTargetAuras()
            end
            return
        end

        if event == "PLAYER_TARGET_CHANGED" then
            if UnitExists(unitToken) then
                UpdateTargetMainPowerBar(unitToken)
                UpdateClasslessResources(unitToken)
                RepositionTargetAuras()
                if textSystem then textSystem.update() end
            elseif frameElements.classlessResources then
                frameElements.classlessResources:Hide()
            end
            return
        end

        if unit ~= unitToken or not UnitExists(unitToken) then return end

        if event == "UNIT_MODEL_CHANGED" then
            UpdateClassification()
            UpdateHealthBarColor()
            UpdateTargetMainPowerBar(unitToken)
            UpdateClasslessResources(unitToken)
            RepositionTargetAuras()
            if textSystem then textSystem.update() end
        elseif event == "UNIT_LEVEL"
            or event == "UNIT_NAME_UPDATE" then
            UpdateClassification()
        elseif event == "UNIT_AURA" then
            RepositionTargetAuras()
        elseif event == "UNIT_MANA"
            or event == "UNIT_MAXMANA"
            or event == "UNIT_RAGE"
            or event == "UNIT_MAXRAGE"
            or event == "UNIT_ENERGY"
            or event == "UNIT_MAXENERGY"
            or event == "UNIT_RUNIC_POWER"
            or event == "UNIT_MAXRUNIC_POWER" then
            UpdateTargetMainPowerBar(unitToken)
            UpdateClasslessResources(unitToken)
            RepositionTargetAuras()
            if textSystem then textSystem.update() end
        end
    end,
})

-- ============================================================================
-- PUBLIC API
-- ============================================================================

addon.TargetFrame = {
    Refresh                  = api.Refresh,
    RefreshTargetFrame       = api.Refresh,
    Reset                    = api.Reset,
    anchor                   = api.anchor,
    ChangeTargetFrame        = api.Refresh,
    UpdateTargetHealthBarColor = function()
        if UnitExists("target") then
            api.UpdateHealthBarColor()
        end
    end,
    UpdateTargetClassPortrait = api.UpdateClassPortrait,
    UpdateTargetMainPowerBar = UpdateTargetMainPowerBar,
    UpdateTargetClasslessResources = UpdateClasslessResources,
}

-- Legacy compatibility
addon.unitframe = addon.unitframe or {}
addon.unitframe.ChangeTargetFrame   = api.Refresh
addon.unitframe.ReApplyTargetFrame  = api.Refresh

function addon:RefreshTargetFrame()
    api.Refresh()
end
