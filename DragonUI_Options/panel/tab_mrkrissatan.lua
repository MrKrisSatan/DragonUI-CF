--[[
================================================================================
DragonUI Options Panel - MrKrisSatan's Additions Tab
================================================================================
Home for custom classless-server additions and utility controls.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

local function RefreshMinimap()
    if addon.RefreshMinimap then
        addon:RefreshMinimap()
    elseif addon.MinimapModule then
        addon.MinimapModule:UpdateSettings()
    end
end

local function GetXToLevelMode()
    return (type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and tonumber(sConfig.averageDisplay.mode)) or 1
end

local function RefreshAdditionsTab()
    if Panel and Panel.SelectTab then
        Panel:SelectTab("mrkrissatan")
    end
end

local function GetClassForgeRoleButtonLabel(role, text)
    local currentRole = addon.GetEmbeddedClassForgeCurrentRole and addon:GetEmbeddedClassForgeCurrentRole() or "DPS"
    if currentRole == role then
        return "[" .. text .. "]"
    end

    return text
end

local function BuildMrKrisTab(scroll)
    local minimap = C:AddSection(scroll, "Minimap Extras")

    C:AddDescription(minimap, "Custom minimap tools for classless-server tweaks and experiments.")

    C:AddButton(minimap, {
        label = (addon.db and addon.db.profile and addon.db.profile.minimap and addon.db.profile.minimap.square)
            and "Switch To Round Minimap" or "Switch To Square Minimap",
        width = 220,
        callback = function()
            if addon.db and addon.db.profile and addon.db.profile.minimap then
                addon.db.profile.minimap.square = not addon.db.profile.minimap.square
                RefreshMinimap()
                if Panel and Panel.SelectTab then
                    Panel:SelectTab("mrkrissatan")
                end
            end
        end,
    })

    C:AddButton(minimap, {
        label = "Grab Minimap Buttons Now",
        width = 220,
        callback = function()
            if addon.GrabMinimapButtons then
                addon:GrabMinimapButtons()
            else
                RefreshMinimap()
            end
        end,
    })

    C:AddDescription(minimap, "Grabbed addon buttons are placed into a movable tray below the minimap and can be moved separately in editor mode.")

    local portraits = C:AddSection(scroll, "Round3D Portraits")
    C:AddDescription(portraits, "Absorbed from Round3DPortraits. Animated 3D portraits render only inside DragonUI-CF's own portrait frames.")

    C:AddToggle(portraits, {
        label = "Enable Round3D Portraits",
        getFunc = function()
            return addon.IsEmbeddedRound3DPortraitsEnabled and addon:IsEmbeddedRound3DPortraitsEnabled()
        end,
        setFunc = function(value)
            if addon.SetEmbeddedRound3DPortraitsEnabled then
                addon:SetEmbeddedRound3DPortraitsEnabled(value)
            end
            RefreshAdditionsTab()
        end,
    })

    C:AddSlider(portraits, {
        label = "Portrait Scale",
        min = 1.2,
        max = 5.0,
        step = 0.05,
        width = 220,
        getFunc = function()
            local cfg = addon.db and addon.db.profile and addon.db.profile.mrkrissatan_additions and addon.db.profile.mrkrissatan_additions.round3d_portraits
            return (cfg and cfg.model_scale) or 3.0
        end,
        setFunc = function(value)
            if addon.SetEmbeddedRound3DPortraitOption then
                addon:SetEmbeddedRound3DPortraitOption("model_scale", value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedRound3DPortraitsEnabled and addon:IsEmbeddedRound3DPortraitsEnabled())
        end,
    })

    C:AddSlider(portraits, {
        label = "Vertical Offset",
        min = -60,
        max = 60,
        step = 1,
        width = 220,
        getFunc = function()
            local cfg = addon.db and addon.db.profile and addon.db.profile.mrkrissatan_additions and addon.db.profile.mrkrissatan_additions.round3d_portraits
            return (cfg and cfg.offset_y) or 2
        end,
        setFunc = function(value)
            if addon.SetEmbeddedRound3DPortraitOption then
                addon:SetEmbeddedRound3DPortraitOption("offset_y", value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedRound3DPortraitsEnabled and addon:IsEmbeddedRound3DPortraitsEnabled())
        end,
    })

    local xtolevel = C:AddSection(scroll, "XToLevel")
    C:AddDescription(xtolevel, "Embedded into DragonUI. The bar is moved with DragonUI editor mode now, not XToLevel's own drag handling.")

    C:AddToggle(xtolevel, {
        label = "Enable XToLevel",
        getFunc = function()
            return addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()
        end,
        setFunc = function(value)
            if addon.SetEmbeddedXToLevelEnabled then
                addon:SetEmbeddedXToLevelEnabled(value)
            end
            RefreshAdditionsTab()
        end,
    })

    C:AddDropdown(xtolevel, {
        label = "Bar Style",
        width = 220,
        values = {
            [1] = "Blocky",
            [2] = "Classic",
        },
        getFunc = function()
            return (type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and tonumber(sConfig.averageDisplay.mode)) or 1
        end,
        setFunc = function(value)
            if addon.SetEmbeddedXToLevelMode then
                addon:SetEmbeddedXToLevelMode(value)
            end
            RefreshAdditionsTab()
        end,
        disabled = function()
            return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
        end,
    })

    C:AddDropdown(xtolevel, {
        label = "Layout",
        width = 220,
        values = {
            v = "Vertical",
            h = "Horizontal",
        },
        getFunc = function()
            return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.orientation or "v"
        end,
        setFunc = function(value)
            if addon.SetEmbeddedXToLevelOption then
                addon:SetEmbeddedXToLevelOption("orientation", value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
        end,
    })

    local mode = GetXToLevelMode()

    C:AddToggle(xtolevel, {
        label = "Show Pet Frame",
        getFunc = function()
            return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.showPetFrame
        end,
        setFunc = function(value)
            if addon.SetEmbeddedXToLevelOption then
                addon:SetEmbeddedXToLevelOption("showPetFrame", value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
        end,
    })

    if mode == 2 then
        C:AddToggle(xtolevel, {
            label = "Show Header",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.header
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("header", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })

        C:AddToggle(xtolevel, {
            label = "Show Backdrop",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.backdrop
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("backdrop", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })

        C:AddToggle(xtolevel, {
            label = "Verbose Text",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.verbose
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("verbose", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })

        C:AddToggle(xtolevel, {
            label = "Colored Text",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.colorText
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("colorText", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })
    else
        C:AddToggle(xtolevel, {
            label = "Progress As Bars",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.progressAsBars
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("progressAsBars", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })

        C:AddToggle(xtolevel, {
            label = "Show Tooltip",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.tooltip
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("tooltip", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })

        C:AddToggle(xtolevel, {
            label = "Combine Tooltip Data",
            getFunc = function()
                return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.combineTooltip
            end,
            setFunc = function(value)
                if addon.SetEmbeddedXToLevelOption then
                    addon:SetEmbeddedXToLevelOption("combineTooltip", value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled())
            end,
        })
    end

    local xtolevelData = C:AddSection(scroll, "XToLevel Data")
    C:AddDescription(xtolevelData, "Choose which XToLevel counters are shown in the embedded bar.")

    C:AddToggle(xtolevelData, {
        label = "Kills",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerKills end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerKills", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Quests",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerQuests end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerQuests", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Dungeons",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerDungeons end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerDungeons", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Battles",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerBGs end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerBGs", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Objectives",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerBGOs end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerBGOs", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Progress",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerProgress end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerProgress", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })
    C:AddToggle(xtolevelData, {
        label = "Timer",
        getFunc = function() return type(sConfig) == "table" and type(sConfig.averageDisplay) == "table" and sConfig.averageDisplay.playerTimer end,
        setFunc = function(value) if addon.SetEmbeddedXToLevelOption then addon:SetEmbeddedXToLevelOption("playerTimer", value) end end,
        disabled = function() return not (addon.IsEmbeddedXToLevelEnabled and addon:IsEmbeddedXToLevelEnabled()) end,
    })

    local cromulent = C:AddSection(scroll, "Cromulent")
    C:AddDescription(cromulent, "Embedded world-map zone info. This one lives inside DragonUI now too.")

    C:AddToggle(cromulent, {
        label = "Enable Cromulent",
        getFunc = function()
            return addon.IsEmbeddedCromulentEnabled and addon:IsEmbeddedCromulentEnabled()
        end,
        setFunc = function(value)
            if addon.SetEmbeddedCromulentEnabled then
                addon:SetEmbeddedCromulentEnabled(value)
            end
        end,
    })

    local classforge = C:AddSection(scroll, "ClassForge")
    C:AddDescription(classforge, "Embedded into DragonUI-CF. You can turn the whole ClassForge feature set on or off here. The meter is moved with DragonUI editor mode now, while the bottom-right corner still resizes it.")

    C:AddToggle(classforge, {
        label = "Enable ClassForge Features",
        getFunc = function()
            return addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled()
        end,
        setFunc = function(value)
            if addon.SetEmbeddedClassForgeEnabled then
                addon:SetEmbeddedClassForgeEnabled(value)
            end
            RefreshAdditionsTab()
        end,
    })

    C:AddToggle(classforge, {
        label = "Enable Class Browser and Player Profiles",
        getFunc = function()
            return addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled()
        end,
        setFunc = function(value)
            if addon.SetEmbeddedClassForgeBrowserEnabled then
                addon:SetEmbeddedClassForgeBrowserEnabled(value)
            end
            RefreshAdditionsTab()
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddToggle(classforge, {
        label = "Show DragonUI-CF Minimap Button",
        getFunc = function()
            return type(ClassForge) == "table" and type(ClassForge.IsMinimapButtonHidden) == "function" and not ClassForge:IsMinimapButtonHidden()
        end,
        setFunc = function(value)
            if type(ClassForge) == "table" and type(ClassForge.SetMinimapButtonHidden) == "function" then
                ClassForge:SetMinimapButtonHidden(not value)
            end
            if RefreshAdditionsTab then
                RefreshAdditionsTab()
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddDescription(classforge, "Selected role: " .. GetClassForgeRoleButtonLabel(addon.GetEmbeddedClassForgeCurrentRole and addon:GetEmbeddedClassForgeCurrentRole() or "DPS", addon.GetEmbeddedClassForgeCurrentRole and addon:GetEmbeddedClassForgeCurrentRole() or "DPS"):gsub("^%[", ""):gsub("%]$", ""))

    C:AddButton(classforge, {
        label = GetClassForgeRoleButtonLabel("Tank", "Tank"),
        width = 100,
        callback = function()
            if addon.SetEmbeddedClassForgeCurrentRole then
                addon:SetEmbeddedClassForgeCurrentRole("Tank")
            end
            RefreshAdditionsTab()
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddButton(classforge, {
        label = GetClassForgeRoleButtonLabel("Heal", "Healer"),
        width = 100,
        callback = function()
            if addon.SetEmbeddedClassForgeCurrentRole then
                addon:SetEmbeddedClassForgeCurrentRole("Heal")
            end
            RefreshAdditionsTab()
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddButton(classforge, {
        label = GetClassForgeRoleButtonLabel("DPS", "Damage"),
        width = 100,
        callback = function()
            if addon.SetEmbeddedClassForgeCurrentRole then
                addon:SetEmbeddedClassForgeCurrentRole("DPS")
            end
            RefreshAdditionsTab()
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    if addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled() then
        C:AddButton(classforge, {
            label = "Open Full Class Browser",
            width = 220,
            callback = function()
                if addon.OpenEmbeddedClassForgeBrowser then
                    addon:OpenEmbeddedClassForgeBrowser()
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Show Chat Tags",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsChatDecorationEnabled) == "function" and ClassForge:IsChatDecorationEnabled()
            end,
            setFunc = function(value)
                if type(ClassForge) == "table" and type(ClassForge.SetChatDecorationEnabled) == "function" then
                    ClassForge:SetChatDecorationEnabled(value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Use Realm-Aware Names",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsRealmAwareEnabled) == "function" and ClassForge:IsRealmAwareEnabled()
            end,
            setFunc = function(value)
                if addon.SetEmbeddedClassForgeProfileOption then
                    addon:SetEmbeddedClassForgeProfileOption("names.realmAware", value and true or false)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Auto /who On Login",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsAutoWhoOnLoginEnabled) == "function" and ClassForge:IsAutoWhoOnLoginEnabled()
            end,
            setFunc = function(value)
                if addon.SetEmbeddedClassForgeProfileOption then
                    addon:SetEmbeddedClassForgeProfileOption("sync.autoWhoOnLogin", value and true or false)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Auto /who In Groups",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsAutoWhoOnGroupEnabled) == "function" and ClassForge:IsAutoWhoOnGroupEnabled()
            end,
            setFunc = function(value)
                if addon.SetEmbeddedClassForgeProfileOption then
                    addon:SetEmbeddedClassForgeProfileOption("sync.autoWhoOnGroup", value and true or false)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Auto Class For Low Level",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsAutoClassEnabled) == "function" and ClassForge:IsAutoClassEnabled()
            end,
            setFunc = function(value)
                if type(ClassForge) == "table" and type(ClassForge.SetAutoClassEnabled) == "function" then
                    ClassForge:SetAutoClassEnabled(value)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })

        C:AddToggle(classforge, {
            label = "Color Group Frames",
            getFunc = function()
                return type(ClassForge) == "table" and type(ClassForge.IsGroupFrameColoringEnabled) == "function" and ClassForge:IsGroupFrameColoringEnabled()
            end,
            setFunc = function(value)
                if addon.SetEmbeddedClassForgeProfileOption then
                    addon:SetEmbeddedClassForgeProfileOption("colors.groupFrames", value and true or false)
                end
            end,
            disabled = function()
                return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
                    or not (addon.IsEmbeddedClassForgeBrowserEnabled and addon:IsEmbeddedClassForgeBrowserEnabled())
            end,
        })
    end

    C:AddToggle(classforge, {
        label = "Enable Meter",
        getFunc = function()
            return type(ClassForge) == "table" and type(ClassForge.IsMeterEnabled) == "function" and ClassForge:IsMeterEnabled()
        end,
        setFunc = function(value)
            if type(ClassForge) == "table" and type(ClassForge.SetMeterEnabled) == "function" then
                ClassForge:SetMeterEnabled(value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddToggle(classforge, {
        label = "Keep Main Meter Until Reset",
        getFunc = function()
            return type(ClassForge) == "table" and type(ClassForge.IsMeterPersistent) == "function" and ClassForge:IsMeterPersistent()
        end,
        setFunc = function(value)
            if type(ClassForge) == "table" and type(ClassForge.SetMeterPersistent) == "function" then
                ClassForge:SetMeterPersistent(value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddToggle(classforge, {
        label = "Include Pet Damage and Healing",
        getFunc = function()
            return type(ClassForge) == "table" and type(ClassForge.IsMeterPetEnabled) == "function" and ClassForge:IsMeterPetEnabled()
        end,
        setFunc = function(value)
            if type(ClassForge) == "table" and type(ClassForge.SetMeterIncludePets) == "function" then
                ClassForge:SetMeterIncludePets(value)
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })

    C:AddButton(classforge, {
        label = "Reset Meter Data",
        width = 220,
        callback = function()
            if type(ClassForge) == "table" and type(ClassForge.ResetMeterData) == "function" then
                ClassForge:ResetMeterData()
            end
        end,
        disabled = function()
            return not (addon.IsEmbeddedClassForgeEnabled and addon:IsEmbeddedClassForgeEnabled())
        end,
    })
end

Panel:RegisterTab("mrkrissatan", "Additions", BuildMrKrisTab, 100, "MrKrisSatan's Additions")
