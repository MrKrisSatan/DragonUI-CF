local addon = select(2, ...)

local Additions = {
    initialized = false,
    xtolevelHooksInstalled = false,
    classforgeHooksInstalled = false,
    editorRegistered = false,
    frames = {},
}

local function GetAdditionsConfig()
    if not (addon.db and addon.db.profile) then
        return {}
    end

    addon.db.profile.mrkrissatan_additions = addon.db.profile.mrkrissatan_additions or {}
    return addon.db.profile.mrkrissatan_additions
end

local function GetXToLevelWidgetConfig()
    if not (addon.db and addon.db.profile and addon.db.profile.widgets) then
        return nil
    end

    addon.db.profile.widgets.xtolevel = addon.db.profile.widgets.xtolevel or {
        anchor = "TOPLEFT",
        posX = 25,
        posY = -100,
    }

    return addon.db.profile.widgets.xtolevel
end

local function IsXToLevelAvailable()
    return type(XToLevel) == "table"
        and type(XToLevel.Average) == "table"
        and type(XToLevel.Average.Update) == "function"
        and type(XToLevel.AverageFrameAPI) == "table"
end

local function IsCromulentAvailable()
    return type(Cromulent) == "table"
end

local function IsRound3DPortraitsAvailable()
    return type(Round3DPortraits) == "table"
end

local function GetRound3DPortraitConfig()
    local cfg = GetAdditionsConfig()
    cfg.round3d_portraits = type(cfg.round3d_portraits) == "table" and cfg.round3d_portraits or {}

    if cfg.round3d_portraits.enabled == nil then
        cfg.round3d_portraits.enabled = true
    end
    if type(cfg.round3d_portraits.model_scale) ~= "number" then
        cfg.round3d_portraits.model_scale = 2.15
    end
    if type(cfg.round3d_portraits.offset_y) ~= "number" then
        cfg.round3d_portraits.offset_y = -7
    end

    return cfg.round3d_portraits
end

local function GetClassForgeMeterWidgetConfig()
    if not (addon.db and addon.db.profile and addon.db.profile.widgets) then
        return nil
    end

    addon.db.profile.widgets.classforge_meter = addon.db.profile.widgets.classforge_meter or {
        anchor = "CENTER",
        posX = 320,
        posY = 40,
    }

    return addon.db.profile.widgets.classforge_meter
end

local function GetRaidPulloutWidgetConfig()
    if not (addon.db and addon.db.profile and addon.db.profile.widgets) then
        return nil
    end

    addon.db.profile.widgets.raid_pullout = addon.db.profile.widgets.raid_pullout or {
        anchor = "TOPRIGHT",
        posX = -350,
        posY = -250,
    }

    return addon.db.profile.widgets.raid_pullout
end

local function GetCompactRaidPulloutRoot()
    return _G.CompactRaidFrameManager
        or _G.CompactRaidFrameManagerDisplayFrame
        or _G.CompactRaidFrameContainer
end

local function GetCompactRaidPulloutToggle()
    return _G.CompactRaidFrameManagerToggleButton
end

local function IsClassForgeAvailable()
    return type(ClassForge) == "table"
        and type(ClassForge.CreateMeterPanel) == "function"
        and type(ClassForge.UpdateMeterPanel) == "function"
end

local SuppressStandaloneRound3DPortraits

local function RefreshAnimatedPortraitSystems()
    if addon.RefreshPlayerFrame then addon:RefreshPlayerFrame() end
    if addon.RefreshTargetFrame then addon:RefreshTargetFrame() end
    if addon.RefreshFocusFrame then addon:RefreshFocusFrame() end
    if addon.RefreshToTFrame then addon:RefreshToTFrame() end
    if addon.RefreshToFFrame then addon:RefreshToFFrame() end
end

local function RedrawAnimatedPortraitTexture(unit, texture)
    if not texture
        or not addon.UF
        or type(addon.UF.UpdateAnimatedPortrait) ~= "function"
        or type(addon.UF.HideAnimatedPortrait) ~= "function"
    then
        return
    end

    if addon:IsEmbeddedRound3DPortraitsEnabled() then
        addon.UF.UpdateAnimatedPortrait(unit, texture)
    else
        addon.UF.HideAnimatedPortrait(texture, true)
    end
end

local function ForceAnimatedPortraitRedraw()
    if not addon.UF then
        return
    end

    RedrawAnimatedPortraitTexture("player", _G.PlayerPortrait)
    RedrawAnimatedPortraitTexture("target", _G.TargetFramePortrait)
    RedrawAnimatedPortraitTexture("focus", _G.FocusFramePortrait)
    RedrawAnimatedPortraitTexture("targettarget", _G.TargetFrameToTPortrait)
    RedrawAnimatedPortraitTexture("focustarget", _G.FocusFrameToTPortrait)

    local dragonPlayerFrame = _G.DragonUIUnitframeFrame
    if dragonPlayerFrame
        and dragonPlayerFrame.PortraitOverlay
        and dragonPlayerFrame.PortraitOverlay:IsShown()
    then
        RedrawAnimatedPortraitTexture("player", dragonPlayerFrame.PortraitOverlayTexture)
    end
end

local function RefreshAnimatedPortraitSystemsImmediately()
    SuppressStandaloneRound3DPortraits()
    ForceAnimatedPortraitRedraw()
    RefreshAnimatedPortraitSystems()
    ForceAnimatedPortraitRedraw()

    if addon.After then
        addon:After(0, ForceAnimatedPortraitRedraw)
        addon:After(0.05, ForceAnimatedPortraitRedraw)
    end
end

local function SuppressStandaloneRound3DFrame(frame)
    if not frame then
        return
    end

    if frame.EnableMouse then
        frame:EnableMouse(false)
    end

    if not frame.DragonUICFRound3DSuppressed and frame.HookScript then
        frame:HookScript("OnShow", function(self)
            if self.DragonUICFRound3DSuppressing then
                return
            end
            self.DragonUICFRound3DSuppressing = true
            self:Hide()
            self.DragonUICFRound3DSuppressing = nil
        end)
        frame.DragonUICFRound3DSuppressed = true
    end

    frame:Hide()
end

SuppressStandaloneRound3DPortraits = function()
    if not IsRound3DPortraitsAvailable() then
        return
    end

    if Round3DPortraits.db and Round3DPortraits.db.profile then
        Round3DPortraits.db.profile.show = false
    end

    if type(Round3DPortraits.Refresh) == "function" then
        pcall(function()
            Round3DPortraits:Refresh()
        end)
    end

    SuppressStandaloneRound3DFrame(Round3DPortraits.PlayerBaseFrame)
    SuppressStandaloneRound3DFrame(Round3DPortraits.TargetBaseFrame)
    SuppressStandaloneRound3DFrame(Round3DPortraits.PlayerInteractionFrame)
    SuppressStandaloneRound3DFrame(Round3DPortraits.TargetInteractionFrame)
    SuppressStandaloneRound3DFrame(_G.PlayerRound3DPortrait)
    SuppressStandaloneRound3DFrame(_G.TargetRound3DPortrait)
    SuppressStandaloneRound3DFrame(_G.PlayerR3DInteractionFrame)
    SuppressStandaloneRound3DFrame(_G.TargetR3DInteractionFrame)
end

local function GetAllRaidPulloutFrames()
    local frames = {}
    local compactRoot = GetCompactRaidPulloutRoot()
    if compactRoot then
        table.insert(frames, compactRoot)
    end

    local compactToggle = GetCompactRaidPulloutToggle()
    if compactToggle then
        table.insert(frames, compactToggle)
    end

    for index = 1, 8 do
        local frame = _G["RaidPullout" .. index]
        if frame then
            table.insert(frames, frame)
        end
    end
    return frames
end

local function IsRaidPulloutFrame(frame)
    if not frame or not frame.GetName then
        return false
    end

    local name = frame:GetName()
    return type(name) == "string"
        and (
            string.match(name, "^RaidPullout%d+$") ~= nil
            or name == "CompactRaidFrameManagerDisplayFrame"
            or name == "CompactRaidFrameManagerToggleButton"
            or name == "CompactRaidFrameManager"
        )
end

local function GetActiveRaidPulloutFrame()
    if _G.CompactRaidFrameManager and _G.CompactRaidFrameManager:IsShown() then
        return _G.CompactRaidFrameManager
    end

    if _G.CompactRaidFrameManagerDisplayFrame and _G.CompactRaidFrameManagerDisplayFrame:IsShown() then
        return _G.CompactRaidFrameManagerDisplayFrame
    end

    local compactRoot = GetCompactRaidPulloutRoot()
    if compactRoot then
        return compactRoot
    end

    local bestFrame, bestArea

    for _, frame in ipairs(GetAllRaidPulloutFrames()) do
        if frame:IsShown() then
            local width = frame:GetWidth() or 0
            local height = frame:GetHeight() or 0
            local area = width * height
            if not bestFrame or area > bestArea then
                bestFrame = frame
                bestArea = area
            end
        end
    end

    if bestFrame then
        return bestFrame
    end

    local frames = GetAllRaidPulloutFrames()
    return frames[1]
end

local function ForEachDescendantFrame(root, callback)
    if not root or not callback then
        return
    end

    callback(root)

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        if child and child.GetObjectType then
            ForEachDescendantFrame(child, callback)
        end
    end
end

local function FrameHasVisibleContent(frame)
    if not frame or not frame.IsShown or not frame:IsShown() then
        return false
    end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        if child
            and child.IsShown and child:IsShown()
            and child.GetAlpha and (child:GetAlpha() or 0) > 0.05
            and child.GetWidth and (child:GetWidth() or 0) > 8
            and child.GetHeight and (child:GetHeight() or 0) > 8
        then
            return true
        end
    end

    return false
end

local function SetRaidPulloutMouseEnabled(enabled)
    for _, frame in ipairs(GetAllRaidPulloutFrames()) do
        ForEachDescendantFrame(frame, function(child)
            if child.EnableMouse then
                child:EnableMouse(enabled)
            end
        end)
    end
end

local function IsCompactRaidPulloutCollapsed()
    local manager = _G.CompactRaidFrameManager
    local display = _G.CompactRaidFrameManagerDisplayFrame
    if not manager then
        return false
    end

    if display and display.IsShown then
        return not display:IsShown()
    end

    return manager.collapsed and true or false
end

local function UpdateCompactRaidPulloutBounds()
    local manager = _G.CompactRaidFrameManager
    if not manager then
        return
    end

    -- Blizzard owns the collapsed/expanded geometry and the toggle anchoring.
    -- We intentionally do nothing here beyond making sure the root exists.
end

local function ApplyRaidPulloutAnchorFromDB()
    local config = GetRaidPulloutWidgetConfig()
    if not config then
        return
    end

    local compactRoot = GetCompactRaidPulloutRoot()
    if compactRoot then
        local anchor = config.anchor or "TOPRIGHT"
        local posX = config.posX or -350
        local posY = config.posY or -250

        compactRoot.DragonUIApplyingAnchor = true
        compactRoot:ClearAllPoints()
        compactRoot:SetPoint(anchor, UIParent, anchor, posX, posY)
        compactRoot.DragonUIApplyingAnchor = nil
        UpdateCompactRaidPulloutBounds()
        return
    end

    for _, frame in ipairs(GetAllRaidPulloutFrames()) do
        if frame and frame.GetName and string.match(frame:GetName() or "", "^RaidPullout%d+$") then
            frame.DragonUIApplyingAnchor = true
            frame:ClearAllPoints()
            frame:SetPoint(config.anchor or "TOPRIGHT", UIParent, config.anchor or "TOPRIGHT", config.posX or -350, config.posY or -250)
            frame.DragonUIApplyingAnchor = nil
        end
    end
end

local function SaveRaidPulloutAnchorFromOverlay()
    local editorOverlay = Additions.frames.raidPulloutEditor
    local config = GetRaidPulloutWidgetConfig()
    if not editorOverlay or not config then
        return
    end

    local centerX, centerY = editorOverlay:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not centerX or not centerY or not parentX or not parentY then
        return
    end

    config.anchor = "CENTER"
    config.posX = math.floor((centerX - parentX) + 0.5)
    config.posY = math.floor((centerY - parentY) + 0.5)
end

local function RefreshRaidPulloutMoverBounds()
    local editorOverlay = Additions.frames.raidPulloutEditor
    if not editorOverlay then
        return
    end

    local frame = GetActiveRaidPulloutFrame()
    if not frame then
        local cfg = GetRaidPulloutWidgetConfig()
        editorOverlay:SetSize(180, 120)
        editorOverlay:ClearAllPoints()
        editorOverlay:SetPoint(cfg.anchor or "TOPRIGHT", UIParent, cfg.anchor or "TOPRIGHT", cfg.posX or -350, cfg.posY or -250)
        return
    end

    local manager = _G.CompactRaidFrameManager
    UpdateCompactRaidPulloutBounds()
    if manager and IsCompactRaidPulloutCollapsed() then
        local toggle = GetCompactRaidPulloutToggle()
        local left, right, bottom, top
        if toggle and toggle:IsShown() then
            left, right, bottom, top = toggle:GetLeft(), toggle:GetRight(), toggle:GetBottom(), toggle:GetTop()
        else
            left, right, bottom, top = manager:GetLeft(), manager:GetRight(), manager:GetBottom(), manager:GetTop()
        end

        if left and right and bottom and top then
            editorOverlay:SetSize(math.max(40, right - left), math.max(24, top - bottom))
            editorOverlay:ClearAllPoints()
            editorOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left - (UIParent:GetLeft() or 0), top - (UIParent:GetTop() or 0))
            return
        end
    end

    local left, right, bottom, top = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()
    local display = _G.CompactRaidFrameManagerDisplayFrame
    local includeDisplay = display
        and (not manager or not IsCompactRaidPulloutCollapsed())
        and FrameHasVisibleContent(display)
    if includeDisplay then
        local dLeft, dRight, dBottom, dTop = display:GetLeft(), display:GetRight(), display:GetBottom(), display:GetTop()
        if dLeft and dRight and dBottom and dTop then
            left = math.min(left or dLeft, dLeft)
            right = math.max(right or dRight, dRight)
            bottom = math.min(bottom or dBottom, dBottom)
            top = math.max(top or dTop, dTop)
        end
    end
    local toggle = GetCompactRaidPulloutToggle()
    if toggle and toggle:IsShown() then
        local tLeft, tRight, tBottom, tTop = toggle:GetLeft(), toggle:GetRight(), toggle:GetBottom(), toggle:GetTop()
        if tLeft and tRight and tBottom and tTop then
            left = math.min(left or tLeft, tLeft)
            right = math.max(right or tRight, tRight)
            bottom = math.min(bottom or tBottom, tBottom)
            top = math.max(top or tTop, tTop)
        end
    end
    if not left or not right or not bottom or not top then
        return
    end

    editorOverlay:SetSize(math.max(40, right - left), math.max(24, top - bottom))
    editorOverlay:ClearAllPoints()
    editorOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left - (UIParent:GetLeft() or 0), top - (UIParent:GetTop() or 0))
end

local function HookRaidPulloutFrames()
    local hookedAny = false
    for _, frame in ipairs(GetAllRaidPulloutFrames()) do
        if frame and not frame.DragonUIRaidPulloutHooked then
            hooksecurefunc(frame, "SetPoint", function(self)
                if self.DragonUIApplyingAnchor or InCombatLockdown() then
                    return
                end
                ApplyRaidPulloutAnchorFromDB()
                RefreshRaidPulloutMoverBounds()
            end)
            frame:HookScript("OnShow", function()
                ApplyRaidPulloutAnchorFromDB()
                RefreshRaidPulloutMoverBounds()
            end)
            frame:HookScript("OnHide", function()
                if Additions.frames.raidPulloutEditor then
                    RefreshRaidPulloutMoverBounds()
                end
            end)
            frame.DragonUIRaidPulloutHooked = true
        end
        if frame then
            hookedAny = true
        end
    end

    Additions.raidPulloutHooksInstalled = hookedAny

    if not Additions.raidPulloutValidateHooked and type(ValidateFramePosition) == "function" then
        hooksecurefunc("ValidateFramePosition", function(frame)
            if not frame or not IsRaidPulloutFrame(frame) or InCombatLockdown() then
                return
            end
            ApplyRaidPulloutAnchorFromDB()
            RefreshRaidPulloutMoverBounds()
        end)
        Additions.raidPulloutValidateHooked = true
    end

    if not Additions.raidPulloutSaveHooked and type(RaidPullout_SaveFrames) == "function" then
        hooksecurefunc("RaidPullout_SaveFrames", function()
            if InCombatLockdown() then
                return
            end
            ApplyRaidPulloutAnchorFromDB()
            RefreshRaidPulloutMoverBounds()
        end)
        Additions.raidPulloutSaveHooked = true
    end
end

function addon:IsEmbeddedClassForgeEnabled()
    local cfg = GetAdditionsConfig()
    return cfg.classforge_enabled ~= false
end

function addon:IsEmbeddedClassForgeBrowserEnabled()
    local cfg = GetAdditionsConfig()
    return cfg.classforge_browser_enabled ~= false
end

local function IsClassForgeBrowserActive()
    return addon:IsEmbeddedClassForgeEnabled() and addon:IsEmbeddedClassForgeBrowserEnabled()
end

local function GetXToLevelMode()
    if type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" then
        return tonumber(sConfig.averageDisplay.mode) or 1
    end
    return 1
end

local function RestoreClassForgeMapColors()
    if not (IsClassForgeAvailable() and type(ClassForge.GetMapObjectTexture) == "function") then
        return
    end

    local function resetObject(object)
        local texture = ClassForge:GetMapObjectTexture(object)
        if texture and texture.SetVertexColor then
            texture:SetVertexColor(1, 1, 1)
        end
    end

    for index = 1, MAX_PARTY_MEMBERS do
        resetObject(_G["WorldMapParty" .. index])
        resetObject(_G["MiniMapParty" .. index])
        resetObject(_G["MinimapParty" .. index])
    end

    for index = 1, MAX_RAID_MEMBERS do
        resetObject(_G["WorldMapRaid" .. index])
        resetObject(_G["MiniMapRaid" .. index])
        resetObject(_G["MinimapRaid" .. index])
    end
end

local function HideClassForgeFrames()
    if IsClassForgeAvailable() and ClassForge.meterPanel then
        ClassForge.meterPanel:Hide()
    end

    if Additions.frames.classForgeMeterEditor then
        Additions.frames.classForgeMeterEditor:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.spellBreakdownFrame then
        ClassForge.spellBreakdownFrame:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.minimapButton then
        ClassForge.minimapButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.targetProfile then
        ClassForge.targetProfile:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.targetTag then
        ClassForge.targetTag:SetText("")
        if ClassForge.targetTag.Hide then
            ClassForge.targetTag:Hide()
        end
    end

    if PaperDollFrame and PaperDollFrame.ClassForgeInfo then
        PaperDollFrame.ClassForgeInfo:SetText("")
        PaperDollFrame.ClassForgeInfo:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.characterDetailTabButton then
        ClassForge.characterDetailTabButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.characterDetailPanel then
        ClassForge.characterDetailPanel:Hide()
    end

    if InspectPaperDollFrame and InspectPaperDollFrame.ClassForgeInfo then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        InspectPaperDollFrame.ClassForgeInfo:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.inspectTabButton then
        ClassForge.inspectTabButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.inspectDetailPanel then
        ClassForge.inspectDetailPanel:Hide()
    end
end

local function HideClassForgeBrowserFrames()
    if IsClassForgeAvailable() and ClassForge.minimapButton then
        ClassForge.minimapButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.targetProfile then
        ClassForge.targetProfile:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.targetTag then
        ClassForge.targetTag:SetText("")
        if ClassForge.targetTag.Hide then
            ClassForge.targetTag:Hide()
        end
    end

    if PaperDollFrame and PaperDollFrame.ClassForgeInfo then
        PaperDollFrame.ClassForgeInfo:SetText("")
        PaperDollFrame.ClassForgeInfo:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.characterDetailTabButton then
        ClassForge.characterDetailTabButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.characterDetailPanel then
        ClassForge.characterDetailPanel:Hide()
    end

    if InspectPaperDollFrame and InspectPaperDollFrame.ClassForgeInfo then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        InspectPaperDollFrame.ClassForgeInfo:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.inspectTabButton then
        ClassForge.inspectTabButton:Hide()
    end

    if IsClassForgeAvailable() and ClassForge.inspectDetailPanel then
        ClassForge.inspectDetailPanel:Hide()
    end
end

local function GetActiveXToLevelAPI()
    if not IsXToLevelAvailable() then
        return nil
    end

    return XToLevel.AverageFrameAPI[XToLevel.Average.activeAPI or XToLevel.Average.knownAPIs[GetXToLevelMode()] or "Blocky"]
end

local function GetVisibleXToLevelFrames()
    local frames = {}
    local mode = GetXToLevelMode()

    if mode == 1 then
        local playerFrame = _G.XToLevel_AverageFrame_Blocky_PlayerFrame
        local petFrame = _G.XToLevel_AverageFrame_Blocky_PetFrame
        if playerFrame and playerFrame:IsShown() then
            table.insert(frames, playerFrame)
        end
        if petFrame and petFrame:IsShown() then
            table.insert(frames, petFrame)
        end
    elseif mode == 2 then
        local classicFrame = _G.XToLevel_AverageFrame_Classic
        if classicFrame and classicFrame:IsShown() then
            table.insert(frames, classicFrame)
        end
    end

    return frames
end

local function ApplyXToLevelAnchorFromDB()
    if not IsXToLevelAvailable() then
        return
    end

    local config = GetXToLevelWidgetConfig()
    local api = GetActiveXToLevelAPI()
    if not config or not api or type(api.SetAnchor) ~= "function" then
        return
    end

    api:SetAnchor(config.anchor or "TOPLEFT", UIParent, config.anchor or "TOPLEFT", config.posX or 25, config.posY or -100)
end

local function SaveXToLevelAnchorFromOverlay()
    local editorOverlay = Additions.frames.xtolevelEditor
    local config = GetXToLevelWidgetConfig()
    if not editorOverlay or not config then
        return
    end

    local left = editorOverlay:GetLeft()
    local top = editorOverlay:GetTop()
    local uiLeft = UIParent:GetLeft()
    local uiTop = UIParent:GetTop()
    if not left or not top or not uiTop then
        return
    end

    config.anchor = "TOPLEFT"
    config.posX = left - (uiLeft or 0)
    config.posY = top - uiTop
end

local function RefreshXToLevelMoverBounds()
    local editorOverlay = Additions.frames.xtolevelEditor
    local frames = GetVisibleXToLevelFrames()

    if not editorOverlay then
        return
    end

    if #frames == 0 then
        editorOverlay:SetSize(220, 40)
        editorOverlay:ClearAllPoints()
        local cfg = GetXToLevelWidgetConfig()
        editorOverlay:SetPoint(cfg.anchor or "TOPLEFT", UIParent, cfg.anchor or "TOPLEFT", cfg.posX or 25, cfg.posY or -100)
        return
    end

    local minLeft, maxRight, minBottom, maxTop
    for _, frame in ipairs(frames) do
        local left, right, bottom, top = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()
        if left and right and bottom and top then
            minLeft = minLeft and math.min(minLeft, left) or left
            maxRight = maxRight and math.max(maxRight, right) or right
            minBottom = minBottom and math.min(minBottom, bottom) or bottom
            maxTop = maxTop and math.max(maxTop, top) or top
        end
    end

    if not minLeft or not maxRight or not minBottom or not maxTop then
        return
    end

    editorOverlay:SetSize(math.max(40, maxRight - minLeft), math.max(24, maxTop - minBottom))
    editorOverlay:ClearAllPoints()
    editorOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", minLeft - (UIParent:GetLeft() or 0), maxTop - (UIParent:GetTop() or 0))
end

local function SetXToLevelMouseEnabled(enabled)
    if _G.XToLevel_AverageFrame_Blocky_PlayerFrame and _G.XToLevel_AverageFrame_Blocky_PlayerFrame.EnableMouse then
        _G.XToLevel_AverageFrame_Blocky_PlayerFrame:EnableMouse(enabled)
    end
    if _G.XToLevel_AverageFrame_Blocky_PetFrame and _G.XToLevel_AverageFrame_Blocky_PetFrame.EnableMouse then
        _G.XToLevel_AverageFrame_Blocky_PetFrame:EnableMouse(enabled)
    end
    if _G.XToLevel_AverageFrame_Classic and _G.XToLevel_AverageFrame_Classic.EnableMouse then
        _G.XToLevel_AverageFrame_Classic:EnableMouse(enabled)
    end
end

local function EnsureXToLevelConfigSafety()
    if type(sConfig) ~= "table" then
        return
    end

    sConfig.general = sConfig.general or {}
    sConfig.averageDisplay = sConfig.averageDisplay or {}

    sConfig.general.allowDrag = false
    sConfig.general.allowSettingsClick = false
end

function addon:IsEmbeddedXToLevelEnabled()
    local cfg = GetAdditionsConfig()
    return cfg.xtolevel_enabled ~= false
end

function addon:SetEmbeddedXToLevelEnabled(enabled)
    if not IsXToLevelAvailable() then
        return
    end

    local cfg = GetAdditionsConfig()
    enabled = not not enabled
    cfg.xtolevel_enabled = enabled

    if enabled then
        local mode = tonumber(cfg.xtolevel_last_mode) or 1
        if mode ~= 1 and mode ~= 2 then
            mode = 1
        end
        sConfig.averageDisplay.mode = mode
        EnsureXToLevelConfigSafety()
        XToLevel.Average:Update()
        ApplyXToLevelAnchorFromDB()
    else
        cfg.xtolevel_last_mode = GetXToLevelMode()
        sConfig.averageDisplay.mode = 0
        if _G.XToLevel_AverageFrame_Blocky_PlayerFrame then _G.XToLevel_AverageFrame_Blocky_PlayerFrame:Hide() end
        if _G.XToLevel_AverageFrame_Blocky_PetFrame then _G.XToLevel_AverageFrame_Blocky_PetFrame:Hide() end
        if _G.XToLevel_AverageFrame_Classic then _G.XToLevel_AverageFrame_Classic:Hide() end
    end

    RefreshXToLevelMoverBounds()
end

function addon:SetEmbeddedXToLevelMode(mode)
    if not IsXToLevelAvailable() then
        return
    end

    mode = tonumber(mode) or 1
    if mode ~= 1 and mode ~= 2 then
        mode = 1
    end

    local cfg = GetAdditionsConfig()
    cfg.xtolevel_last_mode = mode
    sConfig.averageDisplay.mode = mode
    EnsureXToLevelConfigSafety()
    XToLevel.Average:Update()
    ApplyXToLevelAnchorFromDB()
    RefreshXToLevelMoverBounds()
end

function addon:SetEmbeddedXToLevelOption(optionKey, value)
    if not (type(sConfig) == "table" and type(sConfig.averageDisplay) == "table") then
        return
    end

    sConfig.averageDisplay[optionKey] = value
    EnsureXToLevelConfigSafety()
    if IsXToLevelAvailable() then
        XToLevel.Average:Update()
        ApplyXToLevelAnchorFromDB()
        RefreshXToLevelMoverBounds()
    end
end

function addon:SetEmbeddedCromulentEnabled(enabled)
    local cfg = GetAdditionsConfig()
    cfg.cromulent_enabled = not not enabled

    if not IsCromulentAvailable() then
        return
    end

    if enabled then
        if Cromulent.Enable then
            Cromulent:Enable()
        elseif Cromulent.OnEnable then
            Cromulent:OnEnable()
        end
    else
        if Cromulent.Disable then
            Cromulent:Disable()
        elseif Cromulent.OnDisable then
            Cromulent:OnDisable()
        end
    end
end

function addon:IsEmbeddedCromulentEnabled()
    local cfg = GetAdditionsConfig()
    return cfg.cromulent_enabled ~= false
end

function addon:IsEmbeddedRound3DPortraitsEnabled()
    return GetRound3DPortraitConfig().enabled ~= false
end

function addon:SetEmbeddedRound3DPortraitsEnabled(enabled)
    local cfg = GetRound3DPortraitConfig()
    cfg.enabled = not not enabled
    RefreshAnimatedPortraitSystemsImmediately()
end

function addon:SetEmbeddedRound3DPortraitOption(optionKey, value)
    local cfg = GetRound3DPortraitConfig()
    cfg[optionKey] = value
    RefreshAnimatedPortraitSystemsImmediately()
end

local function EnsureXToLevelEditorFrame()
    if Additions.frames.xtolevelEditor then
        return
    end

    local editorOverlay = addon.CreateUIFrame(220, 40, "XToLevel")
    editorOverlay:Hide()
    Additions.frames.xtolevelEditor = editorOverlay

    addon:RegisterEditableFrame({
        name = "xtolevel",
        frame = editorOverlay,
        onEditorMoved = function()
            SaveXToLevelAnchorFromOverlay()
            ApplyXToLevelAnchorFromDB()
            RefreshXToLevelMoverBounds()
        end,
        showTest = function()
            RefreshXToLevelMoverBounds()
            editorOverlay:Show()
            SetXToLevelMouseEnabled(false)
            if addon.ShowNineslice then
                addon.SetNinesliceState(editorOverlay, false)
                addon.ShowNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Show()
            end
        end,
        hideTest = function()
            SetXToLevelMouseEnabled(true)
            ApplyXToLevelAnchorFromDB()
            editorOverlay:Hide()
            if addon.HideNineslice then
                addon.HideNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Hide()
            end
        end,
        onHide = function()
            SetXToLevelMouseEnabled(true)
            ApplyXToLevelAnchorFromDB()
        end,
        editorVisible = function()
            return addon:IsEmbeddedXToLevelEnabled() and IsXToLevelAvailable()
        end,
        module = Additions,
    })
end

local function HookXToLevel()
    if Additions.xtolevelHooksInstalled or not IsXToLevelAvailable() then
        return
    end

    hooksecurefunc(XToLevel.Average, "Update", function()
        EnsureXToLevelConfigSafety()
        if addon:IsEmbeddedXToLevelEnabled() then
            ApplyXToLevelAnchorFromDB()
        end
        RefreshXToLevelMoverBounds()
    end)

    Additions.xtolevelHooksInstalled = true
end

local function ApplyClassForgeMeterStyle()
    if not (IsClassForgeAvailable() and ClassForge.meterPanel) then
        return
    end

    local frame = ClassForge.meterPanel

    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0.06, 0.06, 0.08, 0.92)
    frame:SetBackdropBorderColor(0.20, 0.20, 0.22, 1)

    if not frame._dragonUICFAccent then
        local accent = frame:CreateTexture(nil, "OVERLAY")
        accent:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
        accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -24)
        accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -24)
        accent:SetHeight(2)
        accent:SetVertexColor(0.09, 0.52, 0.82, 1)
        frame._dragonUICFAccent = accent
    end

    if frame.title then
        frame.title:ClearAllPoints()
        frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -8)
        frame.title:SetWidth(170)
        frame.title:SetJustifyH("LEFT")
        frame.title:SetText("DragonUI-CF Meter")
        frame.title:SetTextColor(1, 0.82, 0.2)
    end

    if frame.viewButtons and frame.viewButtons[1] then
        local previousButton
        for _, button in ipairs(frame.viewButtons) do
            button:ClearAllPoints()
            if previousButton then
                button:SetPoint("LEFT", previousButton, "RIGHT", 4, 0)
            else
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -30)
            end
            previousButton = button
        end
    end

    if frame.resetButton then
        frame.resetButton:ClearAllPoints()
        frame.resetButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    end

    if frame.exportButton and frame.resetButton then
        frame.exportButton:ClearAllPoints()
        frame.exportButton:SetPoint("RIGHT", frame.resetButton, "LEFT", -6, 0)
    end

    if frame.breakdownButton and frame.exportButton then
        frame.breakdownButton:ClearAllPoints()
        frame.breakdownButton:SetPoint("RIGHT", frame.exportButton, "LEFT", -6, 0)
    end

    if frame.modeButton and frame.breakdownButton then
        frame.modeButton:ClearAllPoints()
        frame.modeButton:SetPoint("RIGHT", frame.breakdownButton, "LEFT", -6, 0)
    end

    if frame.hintText then
        frame.hintText:ClearAllPoints()
        frame.hintText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -34)
        frame.hintText:SetWidth(240)
        frame.hintText:SetJustifyH("RIGHT")
        frame.hintText:SetText("Filter by top stat. Resize bottom-right.")
        frame.hintText:SetTextColor(0.75, 0.75, 0.78)
    end

    if frame.header then
        frame.header:ClearAllPoints()
        frame.header:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -58)
        frame.header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -32, -58)
        frame.header:SetHeight(18)
    end

    if frame.emptyText and frame.header then
        frame.emptyText:ClearAllPoints()
        frame.emptyText:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
        frame.emptyText:SetWidth(math.max(360, frame:GetWidth() - 44))
    end

    if frame.header then
        if not frame.header.background then
            local headerBg = frame.header:CreateTexture(nil, "BACKGROUND")
            headerBg:SetAllPoints(frame.header)
            headerBg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
            frame.header.background = headerBg
        end
        frame.header.background:SetVertexColor(0.10, 0.10, 0.12, 0.95)
    end

    if frame.chartBackdrop then
        frame.chartBackdrop:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.chartBackdrop:SetBackdropColor(0.08, 0.08, 0.10, 0.88)
        frame.chartBackdrop:SetBackdropBorderColor(0.16, 0.16, 0.18, 1)
    end

    if frame.scrollFrame then
        frame.scrollFrame:ClearAllPoints()
        frame.scrollFrame:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
        frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 12)
        frame.scrollFrame:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        frame.scrollFrame:SetBackdropColor(0.05, 0.05, 0.07, 0.70)
        frame.scrollFrame:SetBackdropBorderColor(0.16, 0.16, 0.18, 1)
    end

    local function skinButton(button)
        if not button or button._dragonUICFSkinned then
            return
        end
        button:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        button:SetBackdropColor(0.10, 0.10, 0.12, 0.95)
        button:SetBackdropBorderColor(0.20, 0.20, 0.22, 1)
        button._dragonUICFSkinned = true
    end

    if frame.viewButtons then
        for _, button in ipairs(frame.viewButtons) do
            skinButton(button)
        end
    end
    skinButton(frame.exportButton)
    skinButton(frame.breakdownButton)
    skinButton(frame.modeButton)
    skinButton(frame.resetButton)
end

local function ApplyClassForgeMeterAnchorFromDB()
    if not IsClassForgeAvailable() then
        return
    end

    local config = GetClassForgeMeterWidgetConfig()
    if not config then
        return
    end

    if not ClassForge.meterPanel and ClassForge.CreateMeterPanel then
        ClassForge:CreateMeterPanel()
    end

    if not ClassForge.meterPanel then
        return
    end

    ClassForgeDB = ClassForgeDB or {}
    ClassForgeDB.profile = ClassForgeDB.profile or {}
    ClassForgeDB.profile.meterPosition = {
        point = config.anchor or "CENTER",
        relativePoint = config.anchor or "CENTER",
        x = config.posX or 320,
        y = config.posY or 40,
    }

    ClassForge:ApplyMeterPosition()
    ApplyClassForgeMeterStyle()
end

local function SaveClassForgeMeterAnchorFromOverlay()
    local editorOverlay = Additions.frames.classForgeMeterEditor
    local config = GetClassForgeMeterWidgetConfig()
    if not editorOverlay or not config then
        return
    end

    local centerX, centerY = editorOverlay:GetCenter()
    local uiCenterX, uiCenterY = UIParent:GetCenter()
    if not centerX or not centerY or not uiCenterX or not uiCenterY then
        return
    end

    config.anchor = "CENTER"
    config.posX = math.floor((centerX - uiCenterX) + 0.5)
    config.posY = math.floor((centerY - uiCenterY) + 0.5)
end

local function RefreshClassForgeMeterMoverBounds()
    local editorOverlay = Additions.frames.classForgeMeterEditor
    if not editorOverlay then
        return
    end

    if not (IsClassForgeAvailable() and ClassForge.meterPanel) then
        local cfg = GetClassForgeMeterWidgetConfig()
        editorOverlay:SetSize(520, 180)
        editorOverlay:ClearAllPoints()
        editorOverlay:SetPoint(cfg.anchor or "CENTER", UIParent, cfg.anchor or "CENTER", cfg.posX or 320, cfg.posY or 40)
        return
    end

    local frame = ClassForge.meterPanel
    local left, right, bottom, top = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()
    if not left or not right or not bottom or not top then
        return
    end

    editorOverlay:SetSize(math.max(40, right - left), math.max(24, top - bottom))
    editorOverlay:ClearAllPoints()
    editorOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left - (UIParent:GetLeft() or 0), top - (UIParent:GetTop() or 0))
end

local function SetClassForgeMeterMouseEnabled(enabled)
    if IsClassForgeAvailable() and ClassForge.meterPanel and ClassForge.meterPanel.EnableMouse then
        ClassForge.meterPanel:EnableMouse(enabled)
    end
end

local function EnsureClassForgeMeterEditorFrame()
    if Additions.frames.classForgeMeterEditor then
        return
    end

    local editorOverlay = addon.CreateUIFrame(520, 180, "ClassForgeMeter")
    editorOverlay:Hide()
    Additions.frames.classForgeMeterEditor = editorOverlay

    addon:RegisterEditableFrame({
        name = "classforge_meter",
        frame = editorOverlay,
        onEditorMoved = function()
            SaveClassForgeMeterAnchorFromOverlay()
            ApplyClassForgeMeterAnchorFromDB()
            RefreshClassForgeMeterMoverBounds()
        end,
        showTest = function()
            RefreshClassForgeMeterMoverBounds()
            editorOverlay:Show()
            SetClassForgeMeterMouseEnabled(false)
            if addon.ShowNineslice then
                addon.SetNinesliceState(editorOverlay, false)
                addon.ShowNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Show()
            end
        end,
        hideTest = function()
            SetClassForgeMeterMouseEnabled(true)
            ApplyClassForgeMeterAnchorFromDB()
            editorOverlay:Hide()
            if addon.HideNineslice then
                addon.HideNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Hide()
            end
        end,
        onHide = function()
            SetClassForgeMeterMouseEnabled(true)
            ApplyClassForgeMeterAnchorFromDB()
        end,
        editorVisible = function()
            return addon:IsEmbeddedClassForgeEnabled()
                and IsClassForgeAvailable()
                and ClassForge.meterPanel
                and ClassForge:IsMeterEnabled()
        end,
        module = Additions,
    })
end

local function EnsureRaidPulloutEditorFrame()
    if Additions.frames.raidPulloutEditor then
        return
    end

    local editorOverlay = addon.CreateUIFrame(180, 120, "Raid Pullout")
    editorOverlay:Hide()
    Additions.frames.raidPulloutEditor = editorOverlay

    addon:RegisterEditableFrame({
        name = "raid_pullout",
        frame = editorOverlay,
        onEditorMoved = function()
            SaveRaidPulloutAnchorFromOverlay()
            ApplyRaidPulloutAnchorFromDB()
            RefreshRaidPulloutMoverBounds()
        end,
        showTest = function()
            RefreshRaidPulloutMoverBounds()
            editorOverlay:Show()
            SetRaidPulloutMouseEnabled(false)
            if addon.ShowNineslice then
                addon.SetNinesliceState(editorOverlay, false)
                addon.ShowNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Show()
            end
        end,
        hideTest = function()
            SetRaidPulloutMouseEnabled(true)
            ApplyRaidPulloutAnchorFromDB()
            editorOverlay:Hide()
            if addon.HideNineslice then
                addon.HideNineslice(editorOverlay)
            end
            if editorOverlay.editorText then
                editorOverlay.editorText:Hide()
            end
        end,
        onHide = function()
            SetRaidPulloutMouseEnabled(true)
            ApplyRaidPulloutAnchorFromDB()
        end,
        editorVisible = function()
            local frame = GetActiveRaidPulloutFrame()
            return frame and frame:IsShown()
        end,
        module = Additions,
    })
end

local function HookClassForge()
    if Additions.classforgeHooksInstalled or not IsClassForgeAvailable() then
        return
    end

    local originalRefreshAllDisplays = ClassForge.RefreshAllDisplays
    if type(originalRefreshAllDisplays) == "function" then
        ClassForge.RefreshAllDisplays = function(self, ...)
            if not addon:IsEmbeddedClassForgeEnabled() then
                HideClassForgeFrames()
                RestoreClassForgeMapColors()
                return
            end
            return originalRefreshAllDisplays(self, ...)
        end
    end

    local originalDecorateChatMessage = ClassForge.DecorateChatMessage
    if type(originalDecorateChatMessage) == "function" then
        ClassForge.DecorateChatMessage = function(self, _, _, message, sender, ...)
            if not IsClassForgeBrowserActive() then
                return false, message, sender, ...
            end
            return originalDecorateChatMessage(self, _, _, message, sender, ...)
        end
    end

    local originalUpdateTargetProfile = ClassForge.UpdateTargetProfile
    if type(originalUpdateTargetProfile) == "function" then
        ClassForge.UpdateTargetProfile = function(self, ...)
            if self.targetProfile then
                self.targetProfile:Hide()
            end
            return
        end
    end

    local originalUpdateMeterPanel = ClassForge.UpdateMeterPanel
    if type(originalUpdateMeterPanel) == "function" then
        ClassForge.UpdateMeterPanel = function(self, ...)
            if not addon:IsEmbeddedClassForgeEnabled() then
                if self.meterPanel then
                    self.meterPanel:Hide()
                end
                return
            end
            return originalUpdateMeterPanel(self, ...)
        end
    end

    local originalUpdateTargetClassTag = ClassForge.UpdateTargetClassTag
    if type(originalUpdateTargetClassTag) == "function" then
        ClassForge.UpdateTargetClassTag = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if self.targetTag then
                    self.targetTag:SetText("")
                    if self.targetTag.Hide then
                        self.targetTag:Hide()
                    end
                end
                return
            end
            if self.targetTag and self.targetTag.Show then
                self.targetTag:Show()
            end
            return originalUpdateTargetClassTag(self, ...)
        end
    end

    local originalUpdateCharacterPanel = ClassForge.UpdateCharacterPanel
    if type(originalUpdateCharacterPanel) == "function" then
        ClassForge.UpdateCharacterPanel = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if PaperDollFrame and PaperDollFrame.ClassForgeInfo then
                    PaperDollFrame.ClassForgeInfo:SetText("")
                    PaperDollFrame.ClassForgeInfo:Hide()
                end
                if self.characterDetailTabButton then
                    self.characterDetailTabButton:Hide()
                end
                if self.characterDetailPanel then
                    self.characterDetailPanel:Hide()
                end
                return
            end
            return originalUpdateCharacterPanel(self, ...)
        end
    end

    local originalUpdateCharacterDetailTabVisibility = ClassForge.UpdateCharacterDetailTabVisibility
    if type(originalUpdateCharacterDetailTabVisibility) == "function" then
        ClassForge.UpdateCharacterDetailTabVisibility = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if self.characterDetailTabButton then
                    self.characterDetailTabButton:Hide()
                end
                if self.characterDetailPanel then
                    self.characterDetailPanel:Hide()
                end
                return
            end
            return originalUpdateCharacterDetailTabVisibility(self, ...)
        end
    end

    local originalUpdateCharacterDetailPanel = ClassForge.UpdateCharacterDetailPanel
    if type(originalUpdateCharacterDetailPanel) == "function" then
        ClassForge.UpdateCharacterDetailPanel = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if self.characterDetailPanel then
                    self.characterDetailPanel:Hide()
                end
                return
            end
            return originalUpdateCharacterDetailPanel(self, ...)
        end
    end

    local originalUpdateInspectFrame = ClassForge.UpdateInspectFrame
    if type(originalUpdateInspectFrame) == "function" then
        ClassForge.UpdateInspectFrame = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if InspectPaperDollFrame and InspectPaperDollFrame.ClassForgeInfo then
                    InspectPaperDollFrame.ClassForgeInfo:SetText("")
                    InspectPaperDollFrame.ClassForgeInfo:Hide()
                end
                if self.inspectTabButton then
                    self.inspectTabButton:Hide()
                end
                if self.inspectDetailPanel then
                    self.inspectDetailPanel:Hide()
                end
                return
            end
            return originalUpdateInspectFrame(self, ...)
        end
    end

    local originalUpdateMapMemberColors = ClassForge.UpdateMapMemberColors
    if type(originalUpdateMapMemberColors) == "function" then
        ClassForge.UpdateMapMemberColors = function(self, ...)
            if not IsClassForgeBrowserActive() then
                RestoreClassForgeMapColors()
                return
            end
            return originalUpdateMapMemberColors(self, ...)
        end
    end

    local originalUpdateMinimapButtonPosition = ClassForge.UpdateMinimapButtonPosition
    if type(originalUpdateMinimapButtonPosition) == "function" then
        ClassForge.UpdateMinimapButtonPosition = function(self, ...)
            if not IsClassForgeBrowserActive() then
                if self.minimapButton then
                    self.minimapButton:Hide()
                end
                return
            end
            return originalUpdateMinimapButtonPosition(self, ...)
        end
    end

    hooksecurefunc(ClassForge, "CreateMeterPanel", function()
        ApplyClassForgeMeterStyle()
        ApplyClassForgeMeterAnchorFromDB()
        RefreshClassForgeMeterMoverBounds()
        if ClassForge.meterPanel then
            ClassForge.meterPanel:SetScript("OnDragStart", function() end)
            ClassForge.meterPanel:SetScript("OnDragStop", function(selfFrame)
                selfFrame:StopMovingOrSizing()
            end)
        end
    end)

    hooksecurefunc(ClassForge, "UpdateMeterPanel", function()
        ApplyClassForgeMeterStyle()
        ApplyClassForgeMeterAnchorFromDB()
        RefreshClassForgeMeterMoverBounds()
        if ClassForge.meterPanel and ClassForge.meterPanel.hintText then
            ClassForge.meterPanel.hintText:SetText("Filter by top stat. Resize bottom-right.")
        end
    end)

    hooksecurefunc(ClassForge, "ApplyMeterSize", function()
        ApplyClassForgeMeterStyle()
        RefreshClassForgeMeterMoverBounds()
    end)

    Additions.classforgeHooksInstalled = true
end

local function ApplyClassForgeFeatureState()
    if not IsClassForgeAvailable() then
        return
    end

    if not addon:IsEmbeddedClassForgeEnabled() then
        HideClassForgeFrames()
        RestoreClassForgeMapColors()
        return
    end

    if not addon:IsEmbeddedClassForgeBrowserEnabled() then
        HideClassForgeBrowserFrames()
        RestoreClassForgeMapColors()
    end

    if ClassForge.meterPanel then
        ApplyClassForgeMeterStyle()
        ApplyClassForgeMeterAnchorFromDB()
        RefreshClassForgeMeterMoverBounds()
    end

    if ClassForge.minimapButton then
        if ClassForge.IsMinimapButtonHidden and not ClassForge:IsMinimapButtonHidden() then
            if addon:IsEmbeddedClassForgeBrowserEnabled() then
                ClassForge.minimapButton:Show()
            else
                ClassForge.minimapButton:Hide()
            end
            if addon:IsEmbeddedClassForgeBrowserEnabled() and ClassForge.UpdateMinimapButtonPosition then
                ClassForge:UpdateMinimapButtonPosition()
            end
        else
            ClassForge.minimapButton:Hide()
        end
    end

    if ClassForge.RefreshAllDisplays then
        ClassForge:RefreshAllDisplays()
    end
end

function addon:SetEmbeddedClassForgeEnabled(enabled)
    local cfg = GetAdditionsConfig()
    cfg.classforge_enabled = enabled and true or false
    ApplyClassForgeFeatureState()
end

function addon:SetEmbeddedClassForgeBrowserEnabled(enabled)
    local cfg = GetAdditionsConfig()
    cfg.classforge_browser_enabled = enabled and true or false
    ApplyClassForgeFeatureState()
end

function addon:SetEmbeddedClassForgeProfileOption(path, value)
    if not (IsClassForgeAvailable() and ClassForgeDB and ClassForgeDB.profile) then
        return
    end

    local root, key = path and path:match("^([^%.]+)%.(.+)$")
    if not root or not key then
        return
    end

    ClassForgeDB.profile[root] = type(ClassForgeDB.profile[root]) == "table" and ClassForgeDB.profile[root] or {}
    ClassForgeDB.profile[root][key] = value
    ApplyClassForgeFeatureState()
end

function addon:GetEmbeddedClassForgeCurrentRole()
    if IsClassForgeAvailable() and type(ClassForge.GetCurrentRole) == "function" then
        return ClassForge:GetCurrentRole()
    end

    return "DPS"
end

function addon:SetEmbeddedClassForgeCurrentRole(role)
    if not IsClassForgeAvailable() then
        return
    end

    if type(ClassForge.SetCurrentRole) == "function" then
        ClassForge:SetCurrentRole(role)
    else
        local normalized = type(ClassForge.NormalizeRole) == "function" and ClassForge:NormalizeRole(role) or nil
        if not normalized then
            return
        end

        local characterProfile = type(ClassForge.GetCharacterProfile) == "function" and ClassForge:GetCharacterProfile() or nil
        if type(characterProfile) ~= "table" then
            return
        end

        characterProfile.role = normalized
        if ClassForge.RefreshPlayerCache then
            ClassForge:RefreshPlayerCache()
        end
        if ClassForge.BroadcastStartup then
            ClassForge:BroadcastStartup()
        end
        if ClassForge.RefreshAllDisplays then
            ClassForge:RefreshAllDisplays()
        end
    end

    ApplyClassForgeFeatureState()
end

function addon:OpenEmbeddedClassForgeBrowser()
    if not IsClassForgeAvailable() then
        return
    end

    if not ClassForge.optionsPanel and type(ClassForge.CreateOptionsPanel) == "function" then
        ClassForge:CreateOptionsPanel()
    end

    if Additions.originalClassForgeOpenOptionsPanel then
        Additions.originalClassForgeOpenOptionsPanel(ClassForge)
        return
    end

    if type(ClassForge.OpenOptionsPanel) == "function" then
        ClassForge:OpenOptionsPanel()
    end
end

local function InitializeEmbeddedClassForge()
    if not IsClassForgeAvailable() then
        return
    end

    EnsureClassForgeMeterEditorFrame()
    HookClassForge()

    if not ClassForge.meterPanel and ClassForge.CreateMeterPanel then
        ClassForge:CreateMeterPanel()
    end

    if ClassForge.meterPanel then
        ClassForge.meterPanel:SetScript("OnDragStart", function() end)
        ClassForge.meterPanel:SetScript("OnDragStop", function(selfFrame)
            selfFrame:StopMovingOrSizing()
        end)
        ApplyClassForgeMeterStyle()
        ApplyClassForgeMeterAnchorFromDB()
        RefreshClassForgeMeterMoverBounds()
    end

    Additions.originalClassForgeOpenOptionsPanel = Additions.originalClassForgeOpenOptionsPanel or ClassForge.OpenOptionsPanel

    ClassForge.OpenOptionsPanel = function()
        if not addon.OptionsPanel and LoadAddOn then
            pcall(LoadAddOn, "DragonUI_Options")
        end
        if addon.OptionsPanel and addon.OptionsPanel.Open then
            addon.OptionsPanel:Open("mrkrissatan")
        end
    end

    if SlashCmdList and SlashCmdList["CLASSFORGE"] then
        SlashCmdList["CLASSFORGE"] = function(message)
            local trimmed = type(ClassForge.Trim) == "function" and ClassForge:Trim(message or "") or (message or "")
            local command = string.lower((trimmed:match("^(%S+)") or ""))
            if command == "" or command == "options" then
                if not addon.OptionsPanel and LoadAddOn then
                    pcall(LoadAddOn, "DragonUI_Options")
                end
                if addon.OptionsPanel and addon.OptionsPanel.Open then
                    addon.OptionsPanel:Open("mrkrissatan")
                end
                return
            end

            if ClassForge.HandleSlash then
                ClassForge:HandleSlash(message)
            end
        end
    end

    ApplyClassForgeFeatureState()
end

local function InitializeEmbeddedXToLevel()
    if not IsXToLevelAvailable() then
        return
    end

    EnsureXToLevelConfigSafety()
    HookXToLevel()
    EnsureXToLevelEditorFrame()

    local cfg = GetAdditionsConfig()
    if cfg.xtolevel_last_mode ~= 1 and cfg.xtolevel_last_mode ~= 2 then
        local currentMode = GetXToLevelMode()
        cfg.xtolevel_last_mode = (currentMode == 1 or currentMode == 2) and currentMode or 1
    end

    if cfg.xtolevel_enabled == false then
        addon:SetEmbeddedXToLevelEnabled(false)
    else
        if GetXToLevelMode() ~= 1 and GetXToLevelMode() ~= 2 then
            sConfig.averageDisplay.mode = cfg.xtolevel_last_mode or 1
        end
        ApplyXToLevelAnchorFromDB()
        RefreshXToLevelMoverBounds()
    end

    if SlashCmdList and SlashCmdList["XTOLEVEL"] then
        SlashCmdList["XTOLEVEL"] = function()
            if not addon.OptionsPanel and LoadAddOn then
                pcall(LoadAddOn, "DragonUI_Options")
            end
            if addon.OptionsPanel and addon.OptionsPanel.Open then
                addon.OptionsPanel:Open("mrkrissatan")
            end
        end
    end
end

local function InitializeEmbeddedCromulent()
    if not IsCromulentAvailable() then
        return
    end

    if addon:IsEmbeddedCromulentEnabled() then
        if Cromulent.Enable then
            Cromulent:Enable()
        end
    else
        if Cromulent.Disable then
            Cromulent:Disable()
        end
    end
end

local function InitializeEmbeddedRound3DPortraits()
    RefreshAnimatedPortraitSystemsImmediately()
end

local function InitializeRaidPulloutMover()
    EnsureRaidPulloutEditorFrame()
    HookRaidPulloutFrames()
    ApplyRaidPulloutAnchorFromDB()
    RefreshRaidPulloutMoverBounds()
end

function addon:RefreshEmbeddedAdditions()
    InitializeRaidPulloutMover()
    InitializeEmbeddedXToLevel()
    InitializeEmbeddedCromulent()
    InitializeEmbeddedRound3DPortraits()
    InitializeEmbeddedClassForge()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
initFrame:RegisterEvent("RAID_ROSTER_UPDATE")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if addon.After then
            addon:After(0.25, function()
                addon:RefreshEmbeddedAdditions()
            end)
        else
            addon:RefreshEmbeddedAdditions()
        end
    elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
        if addon.After then
            addon:After(0.05, function()
                InitializeRaidPulloutMover()
            end)
        else
            InitializeRaidPulloutMover()
        end
    end
end)

