-- ============================================================================
-- DragonUI - Multicast (Totem/Possess) Bar Module
-- Handles Shaman totem bar and possession bar positioning and styling.
-- ============================================================================

local addon = select(2,...);
local L = addon.L
local InCombatLockdown = InCombatLockdown;
local UnitAffectingCombat = UnitAffectingCombat;
local hooksecurefunc = hooksecurefunc;
local UIParent = UIParent;
local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS or 10;
local NUM_MULTI_CAST_BUTTONS_PER_PAGE = NUM_MULTI_CAST_BUTTONS_PER_PAGE or 4;

-- Get player class dynamically (addon._class may not be set yet at load time)
local function GetPlayerClass()
    return addon._class or select(2, UnitClass('player'))
end

-- noop function for protecting frames
local noop = addon._noop

-- =============================================================================
-- MODULE STATE TRACKING
-- =============================================================================
local MulticastModule = {
    initialized = false,
    applied = false,
    originalStates = {},
    styledButtons = {},
    frames = {},
    hooks = {},
    stateDrivers = {},
    registeredEvents = {}
}
addon.MulticastModule = MulticastModule

if addon.RegisterModule then
    addon:RegisterModule("multicast", MulticastModule,
        (L and L["Multicast"]) or "Multicast",
        (L and L["Shaman totem bar positioning and styling"]) or "Shaman totem bar positioning and styling", {
        refresh = "RefreshMulticast",
        loadOnce = true,
    })
end

-- Module frames (created only when enabled)
local anchor, totembar

-- Timer helper: delegates to centralized addon:After()
local function DelayedCall(delay, func)
    addon:After(delay, func)
end

-- Forward declaration for PositionTotemButtons (defined later)
local PositionTotemButtons

-- Combat deferral uses centralized addon.CombatQueue (core/api.lua)

-- =============================================================================
-- CONFIG HELPER FUNCTIONS
-- =============================================================================
local function GetModuleConfig()
    return addon:GetModuleConfig("multicast")
end

local function IsModuleEnabled()
    return addon:IsModuleEnabled("multicast")
end

local function GetTotemConfig()
    if not (addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.totem) then
        return {}
    end
    return addon.db.profile.additional.totem
end

local function GetTotemBarGeometry()
    local totemConfig = GetTotemConfig()
    local buttonWidth = totemConfig.button_size or 34
    local spacing = totemConfig.button_spacing or 4
    local totalWidth = math.max(6 * buttonWidth + 5 * spacing, 100)
    return totalWidth, buttonWidth
end

local function SyncTotemAnchorGeometry()
    if not anchor then return end
    local totalWidth, buttonWidth = GetTotemBarGeometry()
    anchor:SetSize(totalWidth, buttonWidth)
    if totembar then
        totembar:SetAllPoints(anchor)
    end
end

local TotemSpellList = {
    8071, 2484, 5730, 8075, 8143, 2062,
    3599, 8190, 8227, 8181, 30706, 2894,
    5394, 5675, 8184, 16190, 8170, 8187,
    8512, 8177, 10595, 6495, 3738, 25908
}

local function PlayerKnowsAnyTotem()
    local knowsSpell = IsSpellKnown or IsPlayerSpell

    if knowsSpell then
        for _, spellID in ipairs(TotemSpellList) do
            if GetSpellInfo(spellID) and knowsSpell(spellID) then
                return true
            end
        end
    end

    if GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemName then
        for tab = 1, GetNumSpellTabs() do
            local _, _, offset, numSpells = GetSpellTabInfo(tab)
            for index = (offset or 0) + 1, (offset or 0) + (numSpells or 0) do
                local spellName = GetSpellBookItemName(index, BOOKTYPE_SPELL)
                if spellName and string.find(string.lower(spellName), "totem", 1, true) then
                    return true
                end
            end
        end
    end

    return false
end

local function ShouldShowTotemBar()
    return IsModuleEnabled() and PlayerKnowsAnyTotem()
end

-- =============================================================================
-- DYNAMIC ANCHOR SYSTEM
-- Anchors totem bar based on which action bars are visible:
-- 1. If MultiBarBottomRight is visible -> anchor to it
-- 2. Else if MultiBarBottomLeft is visible -> anchor to it  
-- 3. Else -> anchor to MainMenuBar
-- When user moves with editor, manual_position becomes true and uses x_position/y_offset
-- =============================================================================
local function GetDynamicAnchor()
    -- Check which bars are visible
    -- MultiBarBottomRight = "Bottom Right Action Bar" in Blizzard UI options
    -- MultiBarBottomLeft = "Bottom Left Action Bar" in Blizzard UI options
    
    if MultiBarBottomRight and MultiBarBottomRight:IsShown() then
        return MultiBarBottomRight, 'BOTTOMLEFT', 'TOPLEFT', 0, 2
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
        return MultiBarBottomLeft, 'BOTTOMLEFT', 'TOPLEFT', 0, 2
    else
        -- Anchor above MainMenuBar - offset left to align with action buttons
        -- MainMenuBar has page arrows on the left, so we need negative X offset
        return MainMenuBar, 'BOTTOM', 'TOP', -216, 20
    end
end

-- =============================================================================
-- POSITIONING FUNCTION (with dynamic anchor support)
-- =============================================================================
local pendingPositionUpdate = false
local function UpdateTotemBarPosition()
    if not anchor then return end
    
    -- CRITICAL: Never modify frame points during combat (causes taint)
    if InCombatLockdown() then
        if not pendingPositionUpdate then
            pendingPositionUpdate = true
            addon.CombatQueue:Add("multicast_UpdateTotemBarPosition", function()
                pendingPositionUpdate = false
                UpdateTotemBarPosition()
            end)
        end
        return
    end
    
    -- READ VALUES FROM DATABASE
    local totemConfig = GetTotemConfig()
    local manualPosition = totemConfig.manual_position

    SyncTotemAnchorGeometry()
    
    anchor:ClearAllPoints()
    
    if manualPosition then
        -- Manual positioning: use saved x_position and y_offset
        local x_position = totemConfig.x_position or 0
        local y_offset = totemConfig.y_offset or 0
        local base_y = 200
        local final_y = base_y + y_offset
        
        anchor:SetPoint('BOTTOM', UIParent, 'BOTTOM', x_position, final_y)
    else
        -- Dynamic anchoring: anchor to action bars based on visibility
        local anchorFrame, point, relativePoint, offsetX, offsetY = GetDynamicAnchor()
        anchor:SetPoint(point, anchorFrame, relativePoint, offsetX, offsetY)
    end
end

-- =============================================================================
-- BUTTON POSITIONING WITH SCALE AND SPACING
-- =============================================================================
-- Scale the PARENT frame for size, then reposition buttons for custom spacing
PositionTotemButtons = function()
    if not anchor or not totembar then return end
    if InCombatLockdown() then return end
    if not MultiCastActionBarFrame then return end
    
    -- READ VALUES FROM DATABASE
    local totemConfig = GetTotemConfig()
    local btnsize = totemConfig.button_size or 34
    local spacing = totemConfig.button_spacing or 4
    
    local nativeSize = 30
    local scale = btnsize / nativeSize
    local totalWidth = math.max(6 * btnsize + 5 * spacing, 100)

    SyncTotemAnchorGeometry()
    totembar:SetScale(scale)
    MultiCastActionBarFrame:SetScale(1)
    MultiCastActionBarFrame:SetWidth(0.01)

    -- Mirror the working aTotemBar layout: parent the real controls to our
    -- custom bar and position those exact controls there.
    local summonBtn = MultiCastSummonSpellButton
    local recallBtn = MultiCastRecallSpellButton
    local leftPadding = 0

        if summonBtn then
        if summonBtn:GetParent() ~= totembar then
            summonBtn:SetParent(totembar)
        end
        summonBtn:SetScale(1)
        summonBtn:ClearAllPoints()
        summonBtn:SetPoint('BOTTOMLEFT', totembar, 'BOTTOMLEFT', leftPadding, 0)
    end

    for i = 1, NUM_MULTI_CAST_BUTTONS_PER_PAGE do
        local slotBtn = _G['MultiCastSlotButton' .. i]
        if slotBtn then
            if slotBtn:GetParent() ~= totembar then
                slotBtn:SetParent(totembar)
            end
            slotBtn:SetScale(1)
            slotBtn:ClearAllPoints()
            if i == 1 then
                if summonBtn then
                    slotBtn:SetPoint('LEFT', summonBtn, 'RIGHT', spacing, 0)
                else
                    slotBtn:SetPoint('BOTTOMLEFT', totembar, 'BOTTOMLEFT', leftPadding, 0)
                end
            else
                slotBtn:SetPoint('LEFT', _G['MultiCastSlotButton' .. (i - 1)], 'RIGHT', spacing, 0)
            end
        end
        
        -- Action buttons (each page) anchor to their corresponding slot
        for page = 1, NUM_MULTI_CAST_PAGES do
            local actionBtnIndex = (page - 1) * NUM_MULTI_CAST_BUTTONS_PER_PAGE + i
            local actionBtn = _G['MultiCastActionButton' .. actionBtnIndex]
            if actionBtn and slotBtn then
                if actionBtn:GetParent() ~= slotBtn then
                    actionBtn:SetParent(slotBtn)
                end
                actionBtn:SetScale(1)
                actionBtn:ClearAllPoints()
                actionBtn:SetPoint('CENTER', slotBtn, 'CENTER', 0, 0)
            end
        end
    end

    local lastSlot = _G['MultiCastSlotButton' .. NUM_MULTI_CAST_BUTTONS_PER_PAGE]
    if recallBtn and lastSlot then
        if recallBtn:GetParent() ~= totembar then
            recallBtn:SetParent(totembar)
        end
        recallBtn:SetScale(1)
        recallBtn:ClearAllPoints()
        recallBtn:SetPoint('LEFT', lastSlot, 'RIGHT', spacing, 0)
    end

    anchor:SetWidth(totalWidth)
    anchor:SetHeight(btnsize)
end

-- =============================================================================
-- FRAME CREATION FUNCTIONS
-- =============================================================================
local function CreateMulticastFrames()
    if MulticastModule.frames.anchor then return end
    
    -- Create simple anchor frame
    anchor = CreateFrame('Frame', 'DragonUI_TotemAnchor', UIParent)
    anchor:SetSize(200, 37)
    MulticastModule.frames.anchor = anchor
    
    -- Create totem bar frame
    totembar = CreateFrame('Frame', 'DragonUI_TotemBar', anchor, 'SecureHandlerStateTemplate')
    totembar:SetAllPoints(anchor)
    MulticastModule.frames.totembar = totembar
    
    -- Create editor overlay using centralized CreateUIFrame (with nineslice support)
    local editorOverlay = addon.CreateUIFrame(200, 37, 'TotemBarOverlay')
    editorOverlay:SetFrameStrata('FULLSCREEN')
    editorOverlay:SetFrameLevel(100)
    editorOverlay:Hide()
    MulticastModule.frames.editorOverlay = editorOverlay
    
    -- Update the editor text
    if editorOverlay.editorText then
        editorOverlay.editorText:SetText((L and (L["TotemBarOverlay"] or L["Totem Bar"])) or "Totem Bar")
    end
    
    -- Variables to track drag movement (custom drag like stance.lua)
    local dragStartX, dragStartY = 0, 0
    local configStartX, configStartY = 0, 0
    local isDragging = false

    function editorOverlay:SyncManualOverlayDeltaToTotemConfig()
        if not anchor then
            return
        end

        if not (addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.totem) then
            return
        end

        local overlayX, overlayY = self:GetCenter()
        local anchorX, anchorY = anchor:GetCenter()
        if not overlayX or not overlayY or not anchorX or not anchorY then
            return
        end

        local deltaX = overlayX - anchorX
        local deltaY = overlayY - anchorY
        if math.abs(deltaX) < 0.5 and math.abs(deltaY) < 0.5 then
            return
        end

        local totemCfg = addon.db.profile.additional.totem
        totemCfg.manual_position = true
        totemCfg.x_position = math.floor((totemCfg.x_position or 0) + deltaX + 0.5)
        totemCfg.y_offset = math.floor((totemCfg.y_offset or 2) + deltaY + 0.5)

        UpdateTotemBarPosition()
        PositionTotemButtons()

        self:ClearAllPoints()
        self:SetPoint('CENTER', anchor, 'CENTER', 0, 0)
    end
    
    -- Make draggable with custom behavior
    editorOverlay:SetMovable(false)
    editorOverlay:EnableMouse(true)
    editorOverlay:RegisterForDrag("LeftButton")
    
    editorOverlay:SetScript("OnDragStart", function(self)
        isDragging = true
        
        -- Show selected state
        if self.NineSlice and addon.SetNinesliceState then
            addon.SetNinesliceState(self, true)
        end
        
        -- Store mouse position when drag starts
        local scale = self:GetEffectiveScale()
        dragStartX = GetCursorPosition() / scale
        dragStartY = select(2, GetCursorPosition()) / scale
        
        -- When dragging starts, switch to manual positioning mode
        -- and calculate current position relative to UIParent BOTTOM
        if addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.totem then
            local totemConfig = addon.db.profile.additional.totem
            
            -- If we were in auto-anchor mode, convert current position to manual coordinates
            if not totemConfig.manual_position then
                -- Get current anchor position relative to screen
                local anchorCenterX, anchorCenterY = anchor:GetCenter()
                local screenWidth = UIParent:GetWidth()
                local screenHeight = UIParent:GetHeight()
                
                -- Calculate position relative to BOTTOM center of UIParent
                local base_y = 200  -- Base Y for manual positioning
                configStartX = math.floor((anchorCenterX - screenWidth/2) + 0.5)
                configStartY = math.floor((anchorCenterY - base_y) + 0.5)
                
                -- Update config to reflect current position in manual mode
                totemConfig.x_position = configStartX
                totemConfig.y_offset = configStartY
            else
                -- Already in manual mode, use stored values
                configStartX = totemConfig.x_position or 0
                configStartY = totemConfig.y_offset or 0
            end
            
            -- Enable manual positioning mode (loses dynamic anchor)
            totemConfig.manual_position = true
        end
    end)
    
    -- Real-time update during drag
    editorOverlay:SetScript("OnUpdate", function(self, elapsed)
        if not isDragging then
            if self.DragonUI_WasAdjustedByEditor or self.DragonUI_WasDragged then
                self:SyncManualOverlayDeltaToTotemConfig()
                self.DragonUI_WasAdjustedByEditor = nil
                self.DragonUI_WasDragged = nil
            end
            return
        end
        
        -- Calculate current delta from mouse movement
        local scale = self:GetEffectiveScale()
        local currentX = GetCursorPosition() / scale
        local currentY = select(2, GetCursorPosition()) / scale
        
        local deltaX = currentX - dragStartX
        local deltaY = currentY - dragStartY
        
        -- Update config values in real-time
        if addon.db and addon.db.profile and addon.db.profile.additional and addon.db.profile.additional.totem then
            addon.db.profile.additional.totem.x_position = math.floor(configStartX + deltaX + 0.5)
            addon.db.profile.additional.totem.y_offset = math.floor(configStartY + deltaY + 0.5)
            
            -- Update anchor position in real-time
            UpdateTotemBarPosition()
            PositionTotemButtons()

            -- Keep overlay centered on the full-width anchor
            self:ClearAllPoints()
            self:SetPoint('CENTER', anchor, 'CENTER', 0, 0)
        end
    end)
    
    editorOverlay:SetScript("OnDragStop", function(self)
        isDragging = false
        
        -- Return to highlight state
        if self.NineSlice and addon.SetNinesliceState then
            addon.SetNinesliceState(self, false)
        end
    end)
    
    -- Apply static positioning immediately
    UpdateTotemBarPosition()
end

-- =============================================================================
-- SHAMAN MULTICAST (TOTEM) BAR SETUP FUNCTION
-- =============================================================================
local multicastSetupDone = false
local multicastSetupPending = false
local function SetupTotemMulticast()
    if multicastSetupDone then return end
    if not anchor or not totembar then
        CreateMulticastFrames()
    end
    if not anchor or not totembar then return end
    if not MultiCastActionBarFrame then return end
    
    -- CRITICAL: Defer entire setup if in combat
    -- We need to reparent and reposition the frame, which requires combat lockdown check
    if InCombatLockdown() then
        if not multicastSetupPending then
            multicastSetupPending = true
            addon.CombatQueue:Add("multicast_SetupTotemMulticast", function()
                multicastSetupPending = false
                SetupTotemMulticast()
            end)
        end
        return
    end
    
    multicastSetupDone = true
    
    -- Remove default scripts that might interfere with our positioning
    MultiCastActionBarFrame:SetScript('OnUpdate', nil)
    MultiCastActionBarFrame:SetScript('OnShow', nil)
    MultiCastActionBarFrame:SetScript('OnHide', nil)
    
    -- Parent the MultiCastActionBarFrame to our anchor
    -- Once parented, all child buttons stay relative to this parent
    MultiCastActionBarFrame:SetParent(totembar)
    MultiCastActionBarFrame:ClearAllPoints()
    MultiCastActionBarFrame:SetPoint('CENTER', anchor, 'CENTER', 0, 0)
    MultiCastActionBarFrame:SetWidth(0.01)
    MultiCastActionBarFrame:Show()
    
    -- Apply initial scale and spacing to the PARENT frame
    PositionTotemButtons()
    
    -- Hook Blizzard update functions to maintain our custom spacing
    if not MulticastModule.hooks.buttonUpdate then
        MulticastModule.hooks.buttonUpdate = true
        
        -- When Blizzard updates button positions, re-apply our spacing
        hooksecurefunc('MultiCastSummonSpellButton_Update', function()
            if not InCombatLockdown() then
                PositionTotemButtons()
            end
        end)
        
        hooksecurefunc('MultiCastRecallSpellButton_Update', function()
            if not InCombatLockdown() then
                PositionTotemButtons()
            end
        end)
        
        -- Hook slot updates too
        hooksecurefunc('MultiCastSlotButton_Update', function()
            if not InCombatLockdown() then
                PositionTotemButtons()
            end
        end)
    end
    
    -- Hook action bar visibility changes to update dynamic anchoring
    -- Only matters when NOT in manual_position mode
    if not MulticastModule.hooks.actionBarVisibility then
        MulticastModule.hooks.actionBarVisibility = true
        
        -- When MultiBarBottomRight or MultiBarBottomLeft visibility changes, update anchor
        local function OnActionBarVisibilityChange()
            -- CRITICAL: Skip during combat to avoid taint from secure state driver chain
            if InCombatLockdown() then return end
            local totemConfig = GetTotemConfig()
            if not totemConfig.manual_position then
                -- Only update if in auto-anchor mode
                UpdateTotemBarPosition()
            end
        end
        
        if MultiBarBottomRight then
            hooksecurefunc(MultiBarBottomRight, 'Show', OnActionBarVisibilityChange)
            hooksecurefunc(MultiBarBottomRight, 'Hide', OnActionBarVisibilityChange)
        end
        if MultiBarBottomLeft then
            hooksecurefunc(MultiBarBottomLeft, 'Show', OnActionBarVisibilityChange)
            hooksecurefunc(MultiBarBottomLeft, 'Hide', OnActionBarVisibilityChange)
        end
    end
    
    -- Register visibility state driver (hide during vehicle)
    if not MulticastModule.stateDrivers.visibility then
        local visCondition = '[vehicleui] hide; show'
        MulticastModule.stateDrivers.visibility = {frame = totembar, state = 'visibility', condition = visCondition}
        if totembar then
            RegisterStateDriver(totembar, 'visibility', visCondition)
        end
    end
end

-- =============================================================================
-- UNIFIED REFRESH FUNCTION (using SCALE, not SetSize)
-- =============================================================================
function addon.RefreshMulticast(fullRefresh)
    if InCombatLockdown() or UnitAffectingCombat("player") then 
        addon.CombatQueue:Add(fullRefresh and "multicast_RefreshFull" or "multicast_Refresh", function()
            addon.RefreshMulticast(fullRefresh)
        end)
        return 
    end

    if not anchor or not totembar then
        CreateMulticastFrames()
    end
    
    -- Update anchor position
    UpdateTotemBarPosition()
    if ShouldShowTotemBar() then
        if totembar then totembar:Show() end
        if MultiCastActionBarFrame then MultiCastActionBarFrame:Show() end
    else
        if totembar then totembar:Hide() end
        if MultiCastActionBarFrame then MultiCastActionBarFrame:Hide() end
    end
    
    -- Update button scaling if fullRefresh
    if fullRefresh then
        SetupTotemMulticast()
        PositionTotemButtons()
    end
end

-- Full rebuild
function addon.RefreshMulticastFull()
    if InCombatLockdown() or UnitAffectingCombat("player") then return end
    addon.RefreshMulticast(true)
end

-- =============================================================================
-- APPLY SYSTEM FUNCTION
-- =============================================================================
local function ApplyMulticastSystem()
    if MulticastModule.applied then return end
    
    -- Create frames
    CreateMulticastFrames()
    
    -- Setup multicast if available
    SetupTotemMulticast()
    
    -- Initial positioning
    UpdateTotemBarPosition()
    PositionTotemButtons()
    
    MulticastModule.applied = true
    
    -- Register with editor mode system
    if addon.RegisterEditableFrame and MulticastModule.frames.editorOverlay then
        local editorOverlay = MulticastModule.frames.editorOverlay
        
        addon:RegisterEditableFrame({
            name = "totembar",
            frame = editorOverlay,
            configPath = {"additional", "totem"},
            
            editorVisible = function()
                return PlayerKnowsAnyTotem() and MultiCastActionBarFrame ~= nil
            end,
            
            showTest = function()
                if anchor then
                    local totalWidth, buttonWidth = GetTotemBarGeometry()
                    SyncTotemAnchorGeometry()
                    editorOverlay:SetSize(totalWidth, buttonWidth)
                    
                    editorOverlay:ClearAllPoints()
                    editorOverlay:SetPoint('CENTER', anchor, 'CENTER', 0, 0)
                    editorOverlay:Show()
                    
                    -- Show nineslice overlay
                    if addon.ShowNineslice then
                        addon.SetNinesliceState(editorOverlay, false)
                        addon.ShowNineslice(editorOverlay)
                    end
                    if editorOverlay.editorText then
                        editorOverlay.editorText:Show()
                    end
                end
            end,
            
            hideTest = function()
                editorOverlay:Hide()
                if addon.HideNineslice then
                    addon.HideNineslice(editorOverlay)
                end
                if editorOverlay.editorText then
                    editorOverlay.editorText:Hide()
                end
            end,
            
            module = MulticastModule
        })
    end
end

-- =============================================================================
-- PROFILE CHANGE HANDLER
-- =============================================================================
local function OnProfileChanged()
    DelayedCall(0.2, function()
        if not IsModuleEnabled() and addon:ShouldDeferModuleDisable("multicast", MulticastModule) then
            return
        end

        if InCombatLockdown() or UnitAffectingCombat("player") then
            addon.CombatQueue:Add("multicast_OnProfileChanged", function()
                OnProfileChanged()
            end)
            return
        end
        
        addon.RefreshMulticast(true)
    end)
end

-- =============================================================================
-- CENTRALIZED EVENT HANDLER
-- =============================================================================
local eventFrame = CreateFrame("Frame")
local function RegisterEvents()
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_LOGOUT")
    eventFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")
    eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    eventFrame:RegisterEvent("LEARNED_SPELL")
    eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    eventFrame:RegisterEvent("SPELLS_CHANGED")
    
    eventFrame:SetScript("OnEvent", function(self, event, addonName)
        if event == "ADDON_LOADED" and addonName == "DragonUI" then
            -- Initialize multicast system as early as possible
            if addon.core and addon.core.RegisterMessage then
                addon.core.RegisterMessage(addon, "DRAGONUI_READY", ApplyMulticastSystem)
            end
            
            -- Register profile callbacks
            DelayedCall(0.5, function()
                if addon.db and addon.db.RegisterCallback then
                    addon.db.RegisterCallback(addon, "OnProfileChanged", OnProfileChanged)
                    addon.db.RegisterCallback(addon, "OnProfileCopied", OnProfileChanged)
                    addon.db.RegisterCallback(addon, "OnProfileReset", OnProfileChanged)
                end
            end)
            
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Apply system immediately when entering world (reload or login)
            ApplyMulticastSystem()
            addon.RefreshMulticast(true)
            
        elseif event == "PLAYER_TOTEM_UPDATE" then
            addon.RefreshMulticast(true)
            
        elseif event == "LEARNED_SPELL_IN_TAB" or event == "LEARNED_SPELL" or event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED" then
            multicastSetupDone = false
            addon.RefreshMulticast(true)
            
        elseif event == "PLAYER_LOGOUT" then
            if addon.db and addon.db.UnregisterCallback then
                addon.db.UnregisterCallback(addon, "OnProfileChanged")
                addon.db.UnregisterCallback(addon, "OnProfileCopied") 
                addon.db.UnregisterCallback(addon, "OnProfileReset")
            end
        end
    end)
end

-- Initialize event system
RegisterEvents()
