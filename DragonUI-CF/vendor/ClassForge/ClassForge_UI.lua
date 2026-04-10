local function createEditBox(parent, width, height, labelText, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(labelText)

    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetAutoFocus(false)
    box:SetWidth(width)
    box:SetHeight(height)
    box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
    box.label = label

    return box
end

function ClassForge:SetupSlashCommands()
    SLASH_CLASSFORGE1 = "/cf"
    SLASH_CLASSFORGE2 = "/classforge"

    SlashCmdList.CLASSFORGE = function(message)
        ClassForge:HandleSlash(message)
    end
end

function ClassForge:HandleSlash(message)
    local trimmed = self:Trim(message)
    local command, rest = trimmed:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        self:Print("/cf help")
        self:Print("/cf setclass <name>")
        self:Print("/cf setcolor <hex>")
        self:Print("/cf setrole <role>")
        self:Print("/cf realmaware on|off")
        self:Print("/cf autodebug on|off")
        self:Print("/cf autoapply")
        self:Print("/cf show")
        self:Print("/cf sync")
        self:Print("/cf showminimap")
        self:Print("/cf hideminimap")
        self:Print("/cf resetminimap")
        self:Print("/cf chattags on|off")
        self:Print("/cf showpanel")
        self:Print("/cf hidepanel")
        self:Print("/cf lockpanel")
        self:Print("/cf unlockpanel")
        self:Print("/cf resetpanel")
        self:Print("/cf reset")
        self:Print("/cf options")
        return
    end

    if command == "setclass" then
        if rest == "" then
            self:Print("Usage: /cf setclass <name>")
            return
        end

        local characterProfile = self:GetCharacterProfile()
        characterProfile.className = rest
        characterProfile.icon = self:GetResolvedIconTexture(nil, rest, true)
        characterProfile.autoClassManualOverride = true
        self:RefreshAutoClassWatcher()
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Class set to " .. rest .. ".")
        return
    end

    if command == "setcolor" then
        local color = self:SanitizeHex(rest)
        if not color then
            self:Print("Usage: /cf setcolor <hex>")
            return
        end

        local characterProfile = self:GetCharacterProfile()
        characterProfile.color = color
        characterProfile.autoClassManualOverride = true
        self:RefreshAutoClassWatcher()
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Color set to #" .. color .. ".")
        return
    end

    if command == "setrole" then
        local role = self:NormalizeRole(rest)
        if not role then
            self:Print("Role must be Heal, Tank, or DPS.")
            return
        end

        if self.SetCurrentRole then
            local _, normalized = self:SetCurrentRole(role)
            self:Print("Role set to " .. (normalized or role) .. ".")
        else
            self:GetCharacterProfile().role = role
            self:RefreshPlayerCache()
            self:BroadcastStartup()
            self:RefreshAllDisplays()
            self:Print("Role set to " .. role .. ".")
        end
        return
    end

    if command == "show" then
        local data = self:BuildProfileData()
        self:Print(self:L("class_label") .. ": " .. data.className)
        self:Print(self:L("color_label") .. ": #" .. data.color)
        self:Print(self:L("role_label") .. ": " .. self:GetRoleDisplayText(data.role))
        self:Print(self:L("faction_label") .. ": " .. self:GetFactionText(data))
        self:Print(self:L("source_label") .. ": " .. self:GetSourceLabel(data))
        self:Print(self:L("realm_aware_names") .. ": " .. (self:IsRealmAwareEnabled() and self:L("on") or self:L("off")))
        self:Print(self:L("version_label") .. ": " .. (self.version or "3.0.0"))
        self:Print(self:L("downloads_label") .. ": " .. (self.releasesPage or self.homepage))
        return
    end

    if command == "autodebug" then
        local lowerRest = string.lower(self:Trim(rest))
        if lowerRest == "on" then
            self:SetAutoClassDebugEnabled(true)
            self:Print("Auto-class debug enabled.")
            return
        end
        if lowerRest == "off" then
            self:SetAutoClassDebugEnabled(false)
            self:Print("Auto-class debug disabled.")
            return
        end

        self:Print("Usage: /cf autodebug on|off")
        return
    end

    if command == "autoapply" then
        local known = self:GetKnownSpellSet()
        local signature = self:GetKnownSpellSignature(known)
        local preset = self:GetAutoClassPresetForKnownSpells(known)
        self:Print("Auto-class known spells: " .. (signature ~= "" and signature or "none"))
        self:Print("Auto-class preset: " .. (preset and preset.name or "none"))
        if self:ApplyAutoClassFromKnownSpells(true) then
            self:Print("Auto-class applied.")
        else
            self:Print("Auto-class did not apply. Check level, toggle, or matching spells.")
        end
        return
    end

    if command == "sync" then
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RequestSyncFromFriends()
        if self:PerformWhoSync() then
            self:Print(self:L("sync") .. ".")
        else
            self:Print(self:L("sync") .. " throttled. Try again in a moment.")
        end
        return
    end

    if command == "showminimap" then
        self:SetMinimapButtonHidden(false)
        self:Print("Minimap button shown.")
        return
    end

    if command == "hideminimap" then
        self:SetMinimapButtonHidden(true)
        self:Print("Minimap button hidden.")
        return
    end

    if command == "resetminimap" then
        self:ResetMinimapButtonPosition()
        self:Print("Minimap button reset.")
        return
    end

    if command == "chattags" then
        local lowerRest = string.lower(self:Trim(rest))
        if lowerRest == "on" then
            self:SetChatDecorationEnabled(true)
            self:Print("Chat tags enabled.")
            return
        end
        if lowerRest == "off" then
            self:SetChatDecorationEnabled(false)
            self:Print("Chat tags disabled.")
            return
        end

        self:Print("Usage: /cf chattags on|off")
        return
    end

    if command == "realmaware" then
        local lowerRest = string.lower(self:Trim(rest))
        if lowerRest == "on" then
            ClassForgeDB.profile.names.realmAware = true
            self:MigrateDatabase()
            self:RefreshPlayerCache()
            self:RefreshAllDisplays()
            self:Print("Realm-aware names enabled.")
            return
        end
        if lowerRest == "off" then
            ClassForgeDB.profile.names.realmAware = false
            self:MigrateDatabase()
            self:RefreshPlayerCache()
            self:RefreshAllDisplays()
            self:Print("Realm-aware names disabled.")
            return
        end

        self:Print("Usage: /cf realmaware on|off")
        return
    end

    if command == "showpanel" then
        self:SetTargetProfileHidden(false)
        self:Print("Target profile shown.")
        return
    end

    if command == "hidepanel" then
        self:SetTargetProfileHidden(true)
        self:Print("Target profile hidden.")
        return
    end

    if command == "lockpanel" then
        self:SetTargetProfileLocked(true)
        self:Print("Target profile locked.")
        return
    end

    if command == "unlockpanel" then
        self:SetTargetProfileLocked(false)
        self:Print("Target profile unlocked.")
        return
    end

    if command == "resetpanel" then
        if self.ResetTargetProfilePosition then
            self:ResetTargetProfilePosition()
            self:Print("Target profile panel reset.")
        end
        return
    end

    if command == "reset" then
        local characterProfile = self:GetCharacterProfile()
        characterProfile.className = self.defaults.character.className
        characterProfile.color = self.defaults.character.color
        characterProfile.role = self.defaults.character.role
        characterProfile.description = self.defaults.character.description or ""
        characterProfile.autoClassManualOverride = false
        characterProfile.autoClassSignature = ""
        self:RefreshAutoClassWatcher()
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Profile reset to defaults.")
        return
    end

    if command == "options" then
        if self.optionsPanel then
            InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
            InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        end
        return
    end

    self:Print("Unknown command. Type /cf help.")
end

function ClassForge:CreateOptionsPanel()
    if self.optionsPanel then
        return
    end

    local panel = CreateFrame("Frame", "ClassForgeOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "ClassForge"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("ClassForge")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText(ClassForge:L("options_subtitle"))

    local tabs = {}
    local tabFrames = {}

    local function selectTab(name)
        for tabName, frame in pairs(tabFrames) do
            if tabName == name then
                frame:Show()
            else
                frame:Hide()
            end
        end

        for tabName, button in pairs(tabs) do
            if tabName == name then
                button:Disable()
            else
                button:Enable()
            end
        end
    end

    local function createTab(name, label, xOffset)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetWidth(110)
        button:SetHeight(22)
        button:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", xOffset, -14)
        button:SetText(label)
        tabs[name] = button

        local frame = CreateFrame("Frame", nil, panel)
        frame:SetPoint("TOPLEFT", 16, -96)
        frame:SetPoint("BOTTOMRIGHT", -36, 16)
        frame:Hide()
        tabFrames[name] = frame

        button:SetScript("OnClick", function()
            selectTab(name)
        end)

        return frame
    end

    local overview = createTab("overview", ClassForge:L("profile_tab"), 0)
    local display = createTab("display", ClassForge:L("display_tab"), 116)
    local cache = createTab("cache", ClassForge:L("cache_tab"), 232)
    local meter = createTab("meter", ClassForge:L("meter_tab"), 348)
    local description = createTab("description", ClassForge:L("description_tab"), 464)

    local classBox = createEditBox(overview, 220, 30, ClassForge:L("custom_class_name"), 0, 0)
    local classPresets = {
        { name = "Death Knight", color = "C41E3A" },
        { name = "Demon Hunter", color = "A330C9" },
        { name = "Druid", color = "FF7C0A" },
        { name = "Evoker", color = "33937F" },
        { name = "Hunter", color = "AAD372" },
        { name = "Mage", color = "3FC7EB" },
        { name = "Monk", color = "00FF98" },
        { name = "Paladin", color = "F48CBA" },
        { name = "Priest", color = "FFFFFF" },
        { name = "Rogue", color = "FFF468" },
        { name = "Shaman", color = "0070DD" },
        { name = "Warlock", color = "8788EE" },
        { name = "Warrior", color = "C69B6D" },
        { name = "Spell Breaker", color = "7DF9FF" },
        { name = "Abyss Walker", color = "1A1A2E" },
        { name = "Bloodbinder", color = "8B0000" },
        { name = "Chronomancer", color = "FFD700" },
        { name = "Grave Warden", color = "4B5320" },
        { name = "Storm Herald", color = "00BFFF" },
        { name = "Runesmith", color = "B87333" },
        { name = "Soul Weaver", color = "6A0DAD" },
        { name = "Beast Warden", color = "556B2F" },
        { name = "Voidcaller", color = "2F4F4F" },
        { name = "Sun Cleric", color = "FFDE59" },
        { name = "Frostbinder", color = "AFEEEE" },
        { name = "Ashbringer", color = "A9A9A9" },
        { name = "Hexblade", color = "3B0A45" },
        { name = "Spirit Dancer", color = "7FFFD4" },
        { name = "Iron Vanguard", color = "708090" },
        { name = "Plaguebringer", color = "556B2F" },
        { name = "Starcaller", color = "4169E1" },
        { name = "Shadow Duelist", color = "2B2B2B" },
        { name = "Ember Knight", color = "FF4500" },
        { name = "Tide Sage", color = "20B2AA" },
        { name = "Bone Oracle", color = "F5F5DC" },
        { name = "Thunder Reaver", color = "1E90FF" },
        { name = "Nether Alchemist", color = "9932CC" },
        { name = "Wildheart", color = "228B22" },
        { name = "Doom Harbinger", color = "800000" },
    }
    local presetDescriptions = {
        ["Death Knight"] = [[A grim champion bound to death and vengeance, the Death Knight strides into battle wrapped in frost, blood, and shadow. They wear the memory of the grave like armor, crushing enemies with cursed steel while drawing strength from suffering and ruin. To face a Death Knight is to meet a warrior who has already crossed the threshold of death and returned with purpose.]],
        ["Demon Hunter"] = [[A relentless hunter scarred by the powers they chose to wield, the Demon Hunter turns fel fury into a weapon of precision and wrath. They strike with blinding speed, burning through enemies with spectral sight, corrupted magic, and blades that never seem to rest. To face a Demon Hunter is to be hunted by someone who became the monster's nightmare.]],
        ["Druid"] = [[A guardian of the wild and keeper of ancient balance, the Druid shifts between claw, spell, fang, and root as the battlefield demands. They call upon moonlight, storm, and living earth, answering violence with the patient fury of nature itself. To face a Druid is to stand against the wilderness wearing a mortal face.]],
        ["Evoker"] = [[A draconic spellcaster shaped by ancient magic, the Evoker channels the primal force of dragonkind through breath, claw, and living flame. They bend preservation and devastation into flowing forms, striking from the sky with power that feels older than kingdoms. To face an Evoker is to feel the sky open and the dragonflights answer.]],
        ["Hunter"] = [[A patient stalker of wild places, the Hunter reads the world by track, wind, and heartbeat. With bow, beast, trap, and instinct, they turn every battlefield into chosen ground and every mistake into prey's folly. To face a Hunter is to realize too late that the chase began long before the first arrow flew.]],
        ["Mage"] = [[A master of disciplined destruction, the Mage bends frost, fire, and arcane law into weapons of impossible precision. They reshape distance, time, and pressure with a scholar's mind and a storm's appetite. To face a Mage is to stand inside a theorem that ends in flame, ice, or annihilation.]],
        ["Monk"] = [[A living current of discipline and motion, the Monk turns breath, balance, and focused chi into fluid violence. They strike where the body is weakest, mend where the spirit is frayed, and move with the certainty of water finding stone. To face a Monk is to fight calm itself as it becomes a storm.]],
        ["Paladin"] = [[A sanctified defender wrapped in conviction, the Paladin carries the Light as shield, hammer, and judgment. They hold the line with unwavering faith, mending allies and breaking foes beneath radiant purpose. To face a Paladin is to stand before a vow made flesh and sharpened into war.]],
        ["Priest"] = [[A vessel of faith and forbidden insight, the Priest walks the fragile line between salvation and shadow. They soothe the wounded, fortify the spirit, and call down powers that can either redeem the soul or unravel it. To face a Priest is to learn that mercy and terror may speak with the same voice.]],
        ["Rogue"] = [[A blade in the blind spot, the Rogue thrives where rules collapse and shadows gather. They strike with poison, timing, and ruthless precision, turning confusion into an opening and an opening into a corpse. To face a Rogue is to discover the fight was decided before you knew it began.]],
        ["Shaman"] = [[A stormspeaker and bargain-maker of the elements, the Shaman calls fire, earth, water, and air into brutal harmony. They fight as a living conduit, mending allies with river-songs and shattering enemies with thunderous command. To face a Shaman is to hear the world itself choose a side.]],
        ["Warlock"] = [[A scholar of ruin and master of forbidden bargains, the Warlock turns corruption, flame, and fear into obedient tools. They draw power from places wisdom avoids, binding demons and curses into a patient engine of collapse. To face a Warlock is to feel your doom negotiated before the first spell lands.]],
        ["Warrior"] = [[A relentless engine of steel and will, the Warrior meets chaos with muscle, rage, and hard-earned mastery. They break formations, weather punishment, and turn every wound into fuel for the next decisive strike. To face a Warrior is to stand in the path of momentum given a name.]],
        ["Spell Breaker"] = [[A crystalline duelist forged to silence sorcery, the Spell Breaker cuts through enchantments as cleanly as flesh. They turn hostile magic aside, shatter wards, and punish casters with precise bursts of electric-blue force. To face a Spell Breaker is to watch your strongest spell become the opening they were waiting for.]],
        ["Abyss Walker"] = [[A wanderer of the void between worlds, the Abyss Walker moves as if gravity and fear are only suggestions. They draw power from lightless depths, slipping through shadowed angles and dragging enemies toward the silence beneath reality. To face an Abyss Walker is to feel the ground become a doorway into nothing.]],
        ["Bloodbinder"] = [[A crimson occultist who writes power through pulse and pain, the Bloodbinder turns lifeblood into chain, blade, and pact. They bleed enemies dry, stitch strength from sacrifice, and bind survival to violence with terrifying elegance. To face a Bloodbinder is to learn that every heartbeat can be claimed.]],
        ["Chronomancer"] = [[A keeper of fractured seconds, the Chronomancer fights from the edge of moments that have not fully happened yet. They hasten allies, delay disaster, and strike through brief openings in time's golden machinery. To face a Chronomancer is to lose not only the battle, but the instant when victory was possible.]],
        ["Grave Warden"] = [[A solemn sentinel of rot and remembrance, the Grave Warden stands where the living fear to linger. They draw strength from old soil, bone, and decay, turning graveyard stillness into stubborn protection and punishing inevitability. To face a Grave Warden is to feel the earth remember that all things return to it.]],
        ["Storm Herald"] = [[A herald of black clouds and roaring skies, the Storm Herald carries thunder in their blood and lightning in their hands. They tear across battlefields with sudden force, calling wind and rain into a chorus of violent prophecy. To face a Storm Herald is to stand beneath a storm that has learned your name.]],
        ["Runesmith"] = [[A patient artisan of war-magic, the Runesmith hammers ancient signs into steel, stone, and flesh. They prepare power with deliberate craft, turning each mark into a stored verdict waiting to ignite. To face a Runesmith is to fight a battlefield that has already been engraved against you.]],
        ["Soul Weaver"] = [[A deep-violet mystic of threads unseen, the Soul Weaver knots spirit, memory, and pain into living patterns. They mend allies by stitching what was torn and unravel enemies by pulling at the seams of the self. To face a Soul Weaver is to feel your own soul become part of their loom.]],
        ["Beast Warden"] = [[A wild guardian bonded to tooth, talon, and ancient instinct, the Beast Warden fights as the voice of the untamed world. They command pack fury, patient endurance, and the brutal wisdom of survival. To face a Beast Warden is to find that the forest has chosen a champion and given it claws.]],
        ["Voidcaller"] = [[A summoner of abyssal whispers, the Voidcaller reaches into the dark between stars and brings something back that should not answer. They wield pressure, silence, and unraveling shadow as tools of slow catastrophe. To face a Voidcaller is to hear the emptiness speak in your direction.]],
        ["Sun Cleric"] = [[A radiant minister of flame and renewal, the Sun Cleric bears warmth as both mercy and judgment. They heal with golden light, sear corruption from the field, and stand as a living dawn against despair. To face a Sun Cleric is to be weighed beneath a sunrise that does not forgive.]],
        ["Frostbinder"] = [[A glacial caster of stillness and control, the Frostbinder chains motion itself in pale blue cold. They slow the charge, quiet the wound, and shape frozen force into spears, prisons, and patient execution. To face a Frostbinder is to feel the battle narrow into one final breath of winter.]],
        ["Ashbringer"] = [[A grey-clad omen of endings, the Ashbringer walks where flame has already devoured hope. They scatter cinders, break resolve, and turn the remains of destruction into a weapon of mournful certainty. To face an Ashbringer is to fight the aftermath before the fire has even begun.]],
        ["Hexblade"] = [[A cursed duelist with magic in the edge of every strike, the Hexblade binds malice, omen, and steel into a single killing art. They carve misfortune into enemies with each blow, letting fate fray around the wound. To face a Hexblade is to realize the blade is only the most obvious curse.]],
        ["Spirit Dancer"] = [[An ethereal warrior moving between breath and afterimage, the Spirit Dancer fights to rhythms heard by the living and the dead. They weave grace, trance, and spectral force into flowing strikes that guide allies and bewilder foes. To face a Spirit Dancer is to chase a ghost that hits back.]],
        ["Iron Vanguard"] = [[A steel-grey bulwark of discipline and resolve, the Iron Vanguard advances where others would break. They anchor the line, absorb punishment, and answer chaos with methodical force. To face an Iron Vanguard is to throw yourself against a fortress that has learned to march.]],
        ["Plaguebringer"] = [[A bearer of blight and patient ruin, the Plaguebringer turns sickness into strategy and decay into dominion. They spread rot through armor, blood, and breath, letting time become another weapon in their hand. To face a Plaguebringer is to lose ground to an enemy you cannot simply cut down.]],
        ["Starcaller"] = [[A cosmic invoker crowned by distant light, the Starcaller draws upon constellations, omens, and celestial fire. They guide power from the heavens into precise and terrible impact, making the battlefield feel small beneath the sky. To face a Starcaller is to learn that the stars can fall with intent.]],
        ["Shadow Duelist"] = [[A midnight fencer of silence and misdirection, the Shadow Duelist turns absence into angle and darkness into blade. They isolate enemies, punish hesitation, and finish fights in the space between one breath and the next. To face a Shadow Duelist is to duel the part of the room the light forgot.]],
        ["Ember Knight"] = [[A burning champion wrapped in oath and flame, the Ember Knight carries the last heat of a dying fire into every charge. They blend martial discipline with explosive ignition, building pressure until the battlefield catches. To face an Ember Knight is to stand before armor that burns hotter with every blow.]],
        ["Tide Sage"] = [[A seafoam oracle of currents and hidden depths, the Tide Sage reads battle like water reads stone. They mend, erode, and overwhelm in patient surges, drawing strength from rhythm rather than haste. To face a Tide Sage is to discover that the tide was rising long before you noticed.]],
        ["Bone Oracle"] = [[A pale seer of marrow and omen, the Bone Oracle listens to the dead for truths the living refuse to hear. They cast fate through relic, rib, and whispered memory, turning prophecy into brittle violence. To face a Bone Oracle is to feel your ending spoken by something already buried.]],
        ["Thunder Reaver"] = [[A blue-white executioner of storm and speed, the Thunder Reaver splits the field with crackling force. They strike in sudden bursts, severing defenses with electric momentum and roaring impact. To face a Thunder Reaver is to be caught where lightning decides to become a weapon.]],
        ["Nether Alchemist"] = [[An arcane experimenter of volatile genius, the Nether Alchemist distills forbidden energy into tinctures, bombs, and unstable miracles. They transmute risk into advantage, letting every failed rule become a new reaction. To face a Nether Alchemist is to fight someone delighted by the explosion you hoped to avoid.]],
        ["Wildheart"] = [[A forest-born champion led by instinct and green fury, the Wildheart fights with the stubborn vitality of root and fang. They endure, recover, and strike with the unpolished savagery of life refusing to yield. To face a Wildheart is to battle the part of nature that survives every axe.]],
        ["Doom Harbinger"] = [[A red-cloaked herald of final hours, the Doom Harbinger carries prophecy like a weapon and despair like a banner. They build toward catastrophic moments, each strike and spell announcing an ending already in motion. To face a Doom Harbinger is to hear the future arrive with a blade in its hand.]],
    }
    local manualClassPresets = classPresets
    local manualPresetNames = {}
    local autoPresetNames = {}
    local autoPresetNameCounts = {}
    classPresets = {}

    for _, preset in ipairs(manualClassPresets) do
        preset.description = presetDescriptions[preset.name] or ""
        manualPresetNames[preset.name] = preset
    end

    for _, preset in ipairs(ClassForge.autoClassPresets or {}) do
        if preset.name then
            autoPresetNameCounts[preset.name] = (autoPresetNameCounts[preset.name] or 0) + 1
        end
    end

    local autoPresetNameIndexes = {}
    for _, preset in ipairs(ClassForge.autoClassPresets or {}) do
        if preset.name then
            local manualPreset = manualPresetNames[preset.name]
            autoPresetNames[preset.name] = true
            autoPresetNameIndexes[preset.name] = (autoPresetNameIndexes[preset.name] or 0) + 1
            classPresets[#classPresets + 1] = {
                name = preset.name,
                color = preset.color or (manualPreset and manualPreset.color) or "FFFFFF",
                description = presetDescriptions[preset.name] or preset.description or "",
                roleFocus = preset.roleFocus,
                displayName = preset.name
                    .. (
                        autoPresetNameCounts[preset.name] and autoPresetNameCounts[preset.name] > 1
                        and string.format(" [%s %d]", preset.roleFocus or "preset", autoPresetNameIndexes[preset.name])
                        or ""
                    ),
            }
        end
    end

    for _, preset in ipairs(manualClassPresets) do
        if preset.name and not autoPresetNames[preset.name] then
            classPresets[#classPresets + 1] = preset
        end
    end

    table.sort(classPresets, function(left, right)
        return tostring(left.displayName or left.name or "") < tostring(right.displayName or right.name or "")
    end)

    for _, preset in ipairs(classPresets) do
        preset.icon = ClassForge:GetResolvedIconTexture(preset.icon, preset.name, true)
    end

    local updatePreview
    local refreshSelectedIcon
    local selectedClassIcon

    local presetButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    presetButton:SetWidth(64)
    presetButton:SetHeight(22)
    presetButton:SetPoint("LEFT", classBox, "RIGHT", 10, 0)
    presetButton:SetText(ClassForge:L("presets"))

    local presetHint = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    presetHint:SetPoint("TOPLEFT", presetButton, "BOTTOMLEFT", 0, -4)
    presetHint:SetWidth(330)
    presetHint:SetJustifyH("LEFT")
    presetHint:SetText(ClassForge:L("presets_hint"))

    local presetPopup = CreateFrame("Frame", "ClassForgePresetPopup", overview)
    presetPopup:SetWidth(390)
    presetPopup:SetHeight(220)
    presetPopup:SetPoint("TOPLEFT", presetButton, "BOTTOMLEFT", 0, -4)
    presetPopup:SetFrameStrata("DIALOG")
    presetPopup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    presetPopup:SetBackdropColor(0, 0, 0, 0.95)
    presetPopup:Hide()

    local presetScrollFrame = CreateFrame("ScrollFrame", "ClassForgePresetScrollFrame", presetPopup, "UIPanelScrollFrameTemplate")
    presetScrollFrame:SetPoint("TOPLEFT", 8, -8)
    presetScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local presetContent = CreateFrame("Frame", nil, presetScrollFrame)
    presetContent:SetWidth(354)
    presetContent:SetHeight(#classPresets * 22)
    presetScrollFrame:SetScrollChild(presetContent)
    local colorBox = createEditBox(overview, 220, 30, ClassForge:L("class_color_hex"), 0, -82)

    local roleLabel = overview:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    roleLabel:SetPoint("TOPLEFT", 0, -144)
    roleLabel:SetText(ClassForge:L("role_label"))

    local roleValue = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    roleValue:SetPoint("TOPLEFT", roleLabel, "BOTTOMLEFT", 0, -8)
    roleValue:SetWidth(220)
    roleValue:SetJustifyH("LEFT")

    local roleHint = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    roleHint:SetPoint("TOPLEFT", roleValue, "BOTTOMLEFT", 0, -4)
    roleHint:SetWidth(260)
    roleHint:SetJustifyH("LEFT")
    roleHint:SetText(ClassForge:L("role_auto_hint"))

    local function refreshRoleValue()
        roleValue:SetText(ClassForge:GetRoleDisplayText(ClassForge:GetCurrentRole()))
    end

    local factionLabel = overview:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    factionLabel:SetPoint("TOPLEFT", roleHint, "BOTTOMLEFT", 0, -12)
    factionLabel:SetText(ClassForge:L("faction_label"))

    local factionValue = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    factionValue:SetPoint("TOPLEFT", factionLabel, "BOTTOMLEFT", 0, -8)
    factionValue:SetWidth(220)
    factionValue:SetJustifyH("LEFT")

    local descriptionLabel = description:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    descriptionLabel:SetPoint("TOPLEFT", 0, -8)
    descriptionLabel:SetText(ClassForge:L("class_description"))

    local descriptionScroll = CreateFrame("ScrollFrame", "ClassForgeDescriptionScroll", description, "UIPanelScrollFrameTemplate")
    descriptionScroll:SetPoint("TOPLEFT", descriptionLabel, "BOTTOMLEFT", 0, -6)
    descriptionScroll:SetWidth(560)
    descriptionScroll:SetHeight(300)
    descriptionScroll:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    descriptionScroll:SetBackdropColor(0, 0, 0, 0.45)

    local descriptionBox = CreateFrame("EditBox", "ClassForgeDescriptionEditBox", descriptionScroll)
    descriptionBox:SetMultiLine(true)
    descriptionBox:SetFontObject(ChatFontNormal)
    descriptionBox:SetAutoFocus(false)
    descriptionBox:SetWidth(536)
    descriptionBox:SetHeight(292)
    descriptionBox:SetTextInsets(4, 4, 4, 4)
    descriptionBox:SetScript("OnTextChanged", function()
        descriptionScroll:UpdateScrollChildRect()
        updatePreview()
    end)
    descriptionScroll:SetScrollChild(descriptionBox)

    local descriptionSaveButton = CreateFrame("Button", nil, description, "UIPanelButtonTemplate")
    descriptionSaveButton:SetWidth(140)
    descriptionSaveButton:SetHeight(24)
    descriptionSaveButton:SetPoint("TOPLEFT", descriptionScroll, "BOTTOMLEFT", 0, -12)
    descriptionSaveButton:SetText(ClassForge:L("save"))
    descriptionSaveButton:SetScript("OnClick", function()
        local characterProfile = ClassForge:GetCharacterProfile()
        characterProfile.description = ClassForge:Trim(descriptionBox:GetText())
        characterProfile.autoClassManualOverride = true
        ClassForge:RefreshAutoClassWatcher()
        ClassForge:RefreshPlayerCache()
        ClassForge:BroadcastStartup()
        ClassForge:RefreshAllDisplays()
        updatePreview()
        ClassForge:Print(ClassForge:L("profile_saved"))
    end)

    local lastDescriptionBeforePreset
    local descriptionUndoButton

    local descriptionClearButton = CreateFrame("Button", nil, description, "UIPanelButtonTemplate")
    descriptionClearButton:SetWidth(140)
    descriptionClearButton:SetHeight(24)
    descriptionClearButton:SetPoint("LEFT", descriptionSaveButton, "RIGHT", 8, 0)
    descriptionClearButton:SetText(ClassForge:L("clear_description"))
    descriptionClearButton:SetScript("OnClick", function()
        local currentDescription = descriptionBox:GetText()
        if ClassForge:Trim(currentDescription) ~= "" then
            lastDescriptionBeforePreset = currentDescription
            if descriptionUndoButton then
                descriptionUndoButton:Enable()
            end
        end
        descriptionBox:SetText("")
        updatePreview()
    end)

    descriptionUndoButton = CreateFrame("Button", nil, description, "UIPanelButtonTemplate")
    descriptionUndoButton:SetWidth(140)
    descriptionUndoButton:SetHeight(24)
    descriptionUndoButton:SetPoint("LEFT", descriptionClearButton, "RIGHT", 8, 0)
    descriptionUndoButton:SetText(ClassForge:L("undo_description"))
    descriptionUndoButton:Disable()
    descriptionUndoButton:SetScript("OnClick", function()
        if lastDescriptionBeforePreset then
            descriptionBox:SetText(lastDescriptionBeforePreset)
            lastDescriptionBeforePreset = nil
            descriptionUndoButton:Disable()
            updatePreview()
        end
    end)

    local preview = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    preview:SetPoint("TOPLEFT", 360, -28)
    preview:SetWidth(260)
    preview:SetJustifyH("LEFT")

    local iconLabel = overview:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    iconLabel:SetPoint("TOPLEFT", 360, -146)
    iconLabel:SetText("Class Icon")

    local iconPreviewButton = CreateFrame("Button", nil, overview)
    iconPreviewButton:SetWidth(36)
    iconPreviewButton:SetHeight(36)
    iconPreviewButton:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -8)
    iconPreviewButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    iconPreviewButton:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    local iconPreviewTexture = iconPreviewButton:CreateTexture(nil, "ARTWORK")
    iconPreviewTexture:SetPoint("TOPLEFT", 4, -4)
    iconPreviewTexture:SetPoint("BOTTOMRIGHT", -4, 4)
    iconPreviewTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local iconPickerButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    iconPickerButton:SetWidth(90)
    iconPickerButton:SetHeight(22)
    iconPickerButton:SetPoint("LEFT", iconPreviewButton, "RIGHT", 10, 0)
    iconPickerButton:SetText("Icons")

    local iconPopup = CreateFrame("Frame", "ClassForgeIconPopup", overview)
    iconPopup:SetWidth(390)
    iconPopup:SetHeight(260)
    iconPopup:SetPoint("TOPLEFT", iconPreviewButton, "BOTTOMLEFT", 0, -6)
    iconPopup:SetFrameStrata("DIALOG")
    iconPopup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    iconPopup:SetBackdropColor(0, 0, 0, 0.95)
    iconPopup:Hide()

    local iconScrollFrame = CreateFrame("ScrollFrame", "ClassForgeIconScrollFrame", iconPopup, "UIPanelScrollFrameTemplate")
    iconScrollFrame:SetPoint("TOPLEFT", 8, -8)
    iconScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local iconContent = CreateFrame("Frame", nil, iconScrollFrame)
    iconContent:SetWidth(354)
    iconContent:SetHeight(#classPresets * 22)
    iconScrollFrame:SetScrollChild(iconContent)

    refreshSelectedIcon = function(iconTexture)
        selectedClassIcon = ClassForge:GetResolvedIconTexture(iconTexture, classBox and classBox:GetText(), true)
        iconPreviewTexture:SetTexture(selectedClassIcon)
    end

    local colorPickerButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    colorPickerButton:SetWidth(52)
    colorPickerButton:SetHeight(22)
    colorPickerButton:SetPoint("LEFT", colorBox, "RIGHT", 10, 0)
    colorPickerButton:SetText(ClassForge:L("pick"))

    updatePreview = function()
        local role = ClassForge:GetCurrentRole()
        local data = {
            className = ClassForge:Trim(classBox:GetText()) ~= "" and ClassForge:Trim(classBox:GetText()) or ClassForge.defaults.character.className,
            color = ClassForge:SanitizeHex(colorBox:GetText()) or ClassForge.defaults.character.color,
            role = role,
            faction = ClassForge:GetUnitFaction("player"),
            description = ClassForge:Trim(descriptionBox:GetText()),
        }

        preview:SetText(
            ClassForge:L("preview_label")
            .. "\n"
            .. ClassForge:GetColoredClassText(data)
            .. "\n"
            .. ClassForge:L("role_label") .. ": " .. ClassForge:GetRoleDisplayText(data.role)
            .. "\n"
            .. ClassForge:L("faction_label") .. ": " .. ClassForge:GetFactionText(data)
            .. "\n"
            .. (data.description ~= "" and data.description or "")
        )
    end

    for index, preset in ipairs(classPresets) do
        local row = CreateFrame("Button", nil, presetContent)
        row:SetWidth(354)
        row:SetHeight(20)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 22))

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetWidth(16)
        row.icon:SetHeight(16)
        row.icon:SetPoint("LEFT", 4, 0)
        row.icon:SetTexture(preset.icon)
        row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetText(string.format("%s  (#%s)", preset.displayName or preset.name, preset.color))

        row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
        row.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.highlight:SetBlendMode("ADD")
        row.highlight:SetAllPoints(row)

        row:SetScript("OnClick", function()
            classBox:SetText(preset.name)
            colorBox:SetText(preset.color)
            refreshSelectedIcon(preset.icon)
            local currentDescription = ClassForge:Trim(descriptionBox:GetText())
            local presetDescription = preset.description or ""
            if currentDescription ~= "" and currentDescription ~= presetDescription then
                lastDescriptionBeforePreset = descriptionBox:GetText()
                descriptionUndoButton:Enable()
            end
            descriptionBox:SetText(presetDescription)
            presetPopup:Hide()
            updatePreview()
        end)
    end

    for index, preset in ipairs(classPresets) do
        local row = CreateFrame("Button", nil, iconContent)
        row:SetWidth(354)
        row:SetHeight(20)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 22))

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetWidth(16)
        row.icon:SetHeight(16)
        row.icon:SetPoint("LEFT", 4, 0)
        row.icon:SetTexture(preset.icon)
        row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetText(tostring(preset.displayName or preset.name))

        row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
        row.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.highlight:SetBlendMode("ADD")
        row.highlight:SetAllPoints(row)

        row:SetScript("OnClick", function()
            refreshSelectedIcon(preset.icon)
            iconPopup:Hide()
            updatePreview()
        end)
    end

    presetButton:SetScript("OnClick", function()
        if presetPopup:IsShown() then
            presetPopup:Hide()
        else
            presetPopup:Show()
        end
    end)

    iconPickerButton:SetScript("OnClick", function()
        if iconPopup:IsShown() then
            iconPopup:Hide()
        else
            iconPopup:Show()
        end
    end)

    iconPreviewButton:SetScript("OnClick", function()
        iconPickerButton:Click()
    end)

    local function applyPickedColor(red, green, blue)
        local hex = ClassForge:RGBToHex(red, green, blue)
        colorBox:SetText(hex)
        updatePreview()
    end

    colorPickerButton:SetScript("OnClick", function()
        if not ColorPickerFrame then
            return
        end

        local initialHex = ClassForge:SanitizeHex(colorBox:GetText()) or ClassForge.defaults.character.color
        local red, green, blue = ClassForge:HexToRGB(initialHex)

        ColorPickerFrame.hasOpacity = nil
        ColorPickerFrame.opacity = 0
        ColorPickerFrame.previousValues = { red, green, blue }
        ColorPickerFrame.func = function()
            local currentRed, currentGreen, currentBlue = ColorPickerFrame:GetColorRGB()
            applyPickedColor(currentRed, currentGreen, currentBlue)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            if previousValues then
                applyPickedColor(previousValues[1], previousValues[2], previousValues[3])
            end
        end
        ColorPickerFrame:SetColorRGB(red, green, blue)
        ColorPickerFrame:Show()
    end)

    local saveButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    saveButton:SetWidth(100)
    saveButton:SetHeight(24)
    saveButton:SetPoint("TOPLEFT", factionValue, "BOTTOMLEFT", 0, -16)
    saveButton:SetText(ClassForge:L("save"))
    saveButton:SetScript("OnClick", function()
        local className = ClassForge:Trim(classBox:GetText())
        local color = ClassForge:SanitizeHex(colorBox:GetText())

        local characterProfile = ClassForge:GetCharacterProfile()
        characterProfile.className = className ~= "" and className or ClassForge.defaults.character.className
        characterProfile.icon = ClassForge:GetResolvedIconTexture(selectedClassIcon, characterProfile.className, true)
        characterProfile.color = color or ClassForge.defaults.character.color
        characterProfile.description = ClassForge:Trim(descriptionBox:GetText())
        characterProfile.autoClassManualOverride = true
        ClassForge:RefreshAutoClassWatcher()

        ClassForge:RefreshPlayerCache()
        ClassForge:BroadcastStartup()
        ClassForge:RefreshAllDisplays()
        updatePreview()
        ClassForge:Print(ClassForge:L("profile_saved"))
    end)

    local syncButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    syncButton:SetWidth(100)
    syncButton:SetHeight(24)
    syncButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
    syncButton:SetText(ClassForge:L("sync"))
    syncButton:SetScript("OnClick", function()
        ClassForge:HandleSlash("sync")
    end)

    local resetButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    resetButton:SetWidth(100)
    resetButton:SetHeight(24)
    resetButton:SetPoint("LEFT", syncButton, "RIGHT", 8, 0)
    resetButton:SetText(ClassForge:L("reset"))
    resetButton:SetScript("OnClick", function()
        classBox:SetText(ClassForge.defaults.character.className)
        refreshSelectedIcon(ClassForge.defaults.character.icon)
        colorBox:SetText(ClassForge.defaults.character.color)
        descriptionBox:SetText(ClassForge.defaults.character.description or "")
        refreshRoleValue()
        factionValue:SetText(ClassForge:GetFactionText(ClassForge:BuildProfileData()))
        updatePreview()
    end)

    local statusText = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", saveButton, "BOTTOMLEFT", 0, -12)
    statusText:SetWidth(520)
    statusText:SetJustifyH("LEFT")

    local languageLabel = display:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    languageLabel:SetPoint("TOPLEFT", 0, -10)
    languageLabel:SetText(ClassForge:L("language"))

    local languageDropdown = CreateFrame("Frame", "ClassForgeLanguageDropdown", display, "UIDropDownMenuTemplate")
    languageDropdown:SetPoint("TOPLEFT", languageLabel, "BOTTOMLEFT", -16, -2)

    local languageOptions = {
        { textKey = "english", value = "en" },
        { textKey = "spanish", value = "es" },
        { textKey = "russian", value = "ru" },
    }

    local function setSelectedLanguage(value, silent)
        local locale = ClassForge.translations[value] and value or "en"
        languageDropdown.selectedValue = locale
        for _, option in ipairs(languageOptions) do
            if option.value == locale then
                UIDropDownMenu_SetText(languageDropdown, ClassForge:L(option.textKey))
                break
            end
        end

        if not silent then
            ClassForge:SetLanguage(locale)
        end
    end

    UIDropDownMenu_SetWidth(languageDropdown, 190)
    UIDropDownMenu_Initialize(languageDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(languageOptions) do
            info.text = ClassForge:L(option.textKey)
            info.value = option.value
            info.func = function()
                setSelectedLanguage(option.value)
                ClassForge:RefreshAllDisplays()
                updatePreview()
                ClassForge:Print(ClassForge:L("language_updated"))
                if panel.RefreshLocalizedText then
                    panel:RefreshLocalizedText()
                end
            end
            info.checked = (languageDropdown.selectedValue == option.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local minimapToggle = CreateFrame("CheckButton", "ClassForgeOptionsMinimapToggle", display, "UICheckButtonTemplate")
    minimapToggle:SetPoint("TOPLEFT", languageDropdown, "BOTTOMLEFT", 16, -10)
    _G[minimapToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_minimap_button"))
    minimapToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMinimapButtonHidden(not selfButton:GetChecked())
    end)

    local minimapResetButton = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
    minimapResetButton:SetWidth(140)
    minimapResetButton:SetHeight(24)
    minimapResetButton:SetPoint("LEFT", minimapToggle, "RIGHT", 150, 0)
    minimapResetButton:SetText(ClassForge:L("reset_minimap"))
    minimapResetButton:SetScript("OnClick", function()
        ClassForge:ResetMinimapButtonPosition()
        minimapToggle:SetChecked(true)
        ClassForge:Print(ClassForge:L("reset_minimap") .. ".")
    end)

    local chatToggle = CreateFrame("CheckButton", "ClassForgeOptionsChatToggle", display, "UICheckButtonTemplate")
    chatToggle:SetPoint("TOPLEFT", minimapToggle, "BOTTOMLEFT", 0, -10)
    _G[chatToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_chat_tags"))
    chatToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetChatDecorationEnabled(selfButton:GetChecked())
    end)

    local realmToggle = CreateFrame("CheckButton", "ClassForgeOptionsRealmToggle", display, "UICheckButtonTemplate")
    realmToggle:SetPoint("TOPLEFT", chatToggle, "BOTTOMLEFT", 0, -10)
    _G[realmToggle:GetName() .. "Text"]:SetText(ClassForge:L("use_realm_aware"))
    realmToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.names.realmAware = selfButton:GetChecked() and true or false
        ClassForge:MigrateDatabase()
        ClassForge:RefreshPlayerCache()
        ClassForge:RefreshAllDisplays()
    end)

    local autoWhoLoginToggle = CreateFrame("CheckButton", "ClassForgeOptionsAutoWhoLoginToggle", display, "UICheckButtonTemplate")
    autoWhoLoginToggle:SetPoint("TOPLEFT", realmToggle, "BOTTOMLEFT", 0, -10)
    _G[autoWhoLoginToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_who_login"))
    autoWhoLoginToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.sync.autoWhoOnLogin = selfButton:GetChecked() and true or false
    end)

    local autoWhoGroupToggle = CreateFrame("CheckButton", "ClassForgeOptionsAutoWhoGroupToggle", display, "UICheckButtonTemplate")
    autoWhoGroupToggle:SetPoint("TOPLEFT", autoWhoLoginToggle, "BOTTOMLEFT", 0, -10)
    _G[autoWhoGroupToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_who_group"))
    autoWhoGroupToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.sync.autoWhoOnGroup = selfButton:GetChecked() and true or false
    end)

    local autoClassToggle = CreateFrame("CheckButton", "ClassForgeOptionsAutoClassToggle", display, "UICheckButtonTemplate")
    autoClassToggle:SetPoint("TOPLEFT", autoWhoGroupToggle, "BOTTOMLEFT", 0, -10)
    _G[autoClassToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_class_low_level"))
    autoClassToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetAutoClassEnabled(selfButton:GetChecked())
        if selfButton:GetChecked() then
            local characterProfile = ClassForge:GetCharacterProfile()
            characterProfile.autoClassManualOverride = false
            ClassForge:CaptureAutoClassSpellSnapshot()
            ClassForge:ApplyAutoClassFromDetectedSpells(true)
        end
        ClassForge:RefreshAutoClassWatcher()
        ClassForge:RefreshPlayerCache()
        ClassForge:RefreshAllDisplays()
    end)

    local panelVisibleToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelVisibleToggle", display, "UICheckButtonTemplate")
    panelVisibleToggle:SetPoint("TOPLEFT", autoClassToggle, "BOTTOMLEFT", 0, -10)
    _G[panelVisibleToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_target_panel"))
    panelVisibleToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileHidden(not selfButton:GetChecked())
    end)

    local panelLockToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelLockToggle", display, "UICheckButtonTemplate")
    panelLockToggle:SetPoint("TOPLEFT", panelVisibleToggle, "BOTTOMLEFT", 0, -10)
    _G[panelLockToggle:GetName() .. "Text"]:SetText(ClassForge:L("lock_target_panel"))
    panelLockToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileLocked(selfButton:GetChecked())
    end)

    local panelCompactToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelCompactToggle", display, "UICheckButtonTemplate")
    panelCompactToggle:SetPoint("TOPLEFT", panelLockToggle, "BOTTOMLEFT", 0, -10)
    _G[panelCompactToggle:GetName() .. "Text"]:SetText(ClassForge:L("compact_target_panel"))
    panelCompactToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileCompact(selfButton:GetChecked())
    end)

    local groupFrameColorsToggle = CreateFrame("CheckButton", "ClassForgeOptionsGroupColorsToggle", display, "UICheckButtonTemplate")
    groupFrameColorsToggle:SetPoint("TOPLEFT", panelCompactToggle, "BOTTOMLEFT", 0, -10)
    _G[groupFrameColorsToggle:GetName() .. "Text"]:SetText(ClassForge:L("color_group_frames"))
    groupFrameColorsToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.colors = ClassForgeDB.profile.colors or {}
        ClassForgeDB.profile.colors.groupFrames = selfButton:GetChecked() and true or false
        ClassForge:RefreshAllDisplays()
    end)

    local panelResetButton = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
    panelResetButton:SetWidth(140)
    panelResetButton:SetHeight(24)
    panelResetButton:SetPoint("TOPLEFT", groupFrameColorsToggle, "BOTTOMLEFT", 4, -14)
    panelResetButton:SetText(ClassForge:L("reset_panel"))
    panelResetButton:SetScript("OnClick", function()
        ClassForge:ResetTargetProfilePosition()
        ClassForge:Print(ClassForge:L("reset_panel") .. ".")
    end)

    local panelHint = display:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panelHint:SetPoint("LEFT", panelResetButton, "RIGHT", 12, 0)
    panelHint:SetText(ClassForge:L("panel_hint"))

    local displayStatus = display:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    displayStatus:SetPoint("TOPLEFT", panelResetButton, "BOTTOMLEFT", 0, -14)
    displayStatus:SetWidth(520)
    displayStatus:SetJustifyH("LEFT")

    local meterSectionLabel = meter:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    meterSectionLabel:SetPoint("TOPLEFT", 0, -10)
    meterSectionLabel:SetText("Meter")

    local meterEnableToggle = CreateFrame("CheckButton", "ClassForgeOptionsMeterEnableToggle", meter, "UICheckButtonTemplate")
    meterEnableToggle:SetPoint("TOPLEFT", meterSectionLabel, "BOTTOMLEFT", 0, -8)
    _G[meterEnableToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_box"))
    meterEnableToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMeterEnabled(selfButton:GetChecked())
    end)

    local meterLockToggle = CreateFrame("CheckButton", "ClassForgeOptionsMeterLockToggle", meter, "UICheckButtonTemplate")
    meterLockToggle:SetPoint("TOPLEFT", meterEnableToggle, "BOTTOMLEFT", 0, -8)
    _G[meterLockToggle:GetName() .. "Text"]:SetText(ClassForge:L("lock_meter"))
    meterLockToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMeterLocked(selfButton:GetChecked())
    end)

    local meterPersistentToggle = CreateFrame("CheckButton", "ClassForgeOptionsMeterPersistentToggle", meter, "UICheckButtonTemplate")
    meterPersistentToggle:SetPoint("TOPLEFT", meterEnableToggle, "TOPRIGHT", 230, 0)
    _G[meterPersistentToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_persistent"))
    meterPersistentToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMeterPersistent(selfButton:GetChecked())
        panel:RefreshLocalizedText()
    end)

    local meterPetsToggle = CreateFrame("CheckButton", "ClassForgeOptionsMeterPetsToggle", meter, "UICheckButtonTemplate")
    meterPetsToggle:SetPoint("TOPLEFT", meterPersistentToggle, "BOTTOMLEFT", 0, -8)
    _G[meterPetsToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_include_pets"))
    meterPetsToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMeterIncludePets(selfButton:GetChecked())
        panel:RefreshLocalizedText()
    end)

    local meterDebugToggle = CreateFrame("CheckButton", "ClassForgeOptionsMeterDebugToggle", meter, "UICheckButtonTemplate")
    meterDebugToggle:SetPoint("TOPLEFT", meterLockToggle, "BOTTOMLEFT", 0, -8)
    _G[meterDebugToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_debug"))
    meterDebugToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMeterDebug(selfButton:GetChecked())
        panel:RefreshLocalizedText()
    end)

    local meterSizeLabel = meter:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    meterSizeLabel:SetPoint("TOPLEFT", meterDebugToggle, "BOTTOMLEFT", 0, -18)
    meterSizeLabel:SetText(ClassForge:L("meter_size"))

    local meterWidthBox = createEditBox(meter, 70, 24, "Width", 0, -122)
    local meterHeightBox = createEditBox(meter, 70, 24, "Height", 100, -122)
    local meterRowsBox = createEditBox(meter, 90, 24, "Export Rows", 200, -122)

    local function applyMeterSizeFromOptions()
        ClassForge:SetMeterSizeDimensions(meterWidthBox:GetText(), meterHeightBox:GetText())
        meterWidthBox:SetText(tostring(ClassForge:GetMeterSize().width))
        meterHeightBox:SetText(tostring(ClassForge:GetMeterSize().height))
    end

    meterWidthBox:SetScript("OnEnterPressed", function(selfBox)
        applyMeterSizeFromOptions()
        selfBox:ClearFocus()
    end)
    meterWidthBox:SetScript("OnEditFocusLost", applyMeterSizeFromOptions)

    meterHeightBox:SetScript("OnEnterPressed", function(selfBox)
        applyMeterSizeFromOptions()
        selfBox:ClearFocus()
    end)
    meterHeightBox:SetScript("OnEditFocusLost", applyMeterSizeFromOptions)

    meterRowsBox:SetScript("OnEnterPressed", function(selfBox)
        ClassForge:SetMeterMaxRows(selfBox:GetText())
        selfBox:ClearFocus()
    end)
    meterRowsBox:SetScript("OnEditFocusLost", function(selfBox)
        ClassForge:SetMeterMaxRows(selfBox:GetText())
    end)

    local meterExportLabel = meter:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    meterExportLabel:SetPoint("TOPLEFT", meterRowsBox, "BOTTOMLEFT", 0, -18)
    meterExportLabel:SetText(ClassForge:L("meter_export_target"))

    local meterExportDropdown = CreateFrame("Frame", "ClassForgeMeterExportDropdown", meter, "UIDropDownMenuTemplate")
    meterExportDropdown:SetPoint("TOPLEFT", meterExportLabel, "BOTTOMLEFT", -16, -2)
    local meterExportChannelBox

    local meterExportOptions = {
        { key = "export_party", value = "PARTY" },
        { key = "export_raid", value = "RAID" },
        { key = "export_guild", value = "GUILD" },
        { key = "export_officer", value = "OFFICER" },
        { key = "export_say", value = "SAY" },
        { key = "export_yell", value = "YELL" },
        { key = "export_channel", value = "CHANNEL" },
    }

    local function setSelectedMeterExport(value)
        local exportType = value or ClassForge.defaults.profile.meter.exportType
        meterExportDropdown.selectedValue = exportType
        for _, option in ipairs(meterExportOptions) do
            if option.value == exportType then
                UIDropDownMenu_SetText(meterExportDropdown, ClassForge:L(option.key))
                break
            end
        end
        ClassForge:SetMeterExportTarget(exportType)
        if exportType == "CHANNEL" then
            meterExportChannelBox:Show()
            meterExportChannelBox.label:Show()
        else
            meterExportChannelBox:Hide()
            meterExportChannelBox.label:Hide()
        end
    end

    UIDropDownMenu_SetWidth(meterExportDropdown, 170)
    UIDropDownMenu_Initialize(meterExportDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(meterExportOptions) do
            info.text = ClassForge:L(option.key)
            info.value = option.value
            info.func = function()
                setSelectedMeterExport(option.value)
            end
            info.checked = (meterExportDropdown.selectedValue == option.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    meterExportChannelBox = createEditBox(meter, 140, 24, ClassForge:L("meter_export_channel"), 250, -170)
    meterExportChannelBox:SetScript("OnEnterPressed", function(selfBox)
        ClassForge:SetMeterExportChannel(selfBox:GetText())
        selfBox:ClearFocus()
    end)

    local meterResetButton = CreateFrame("Button", nil, meter, "UIPanelButtonTemplate")
    meterResetButton:SetWidth(140)
    meterResetButton:SetHeight(24)
    meterResetButton:SetPoint("TOPLEFT", meterExportDropdown, "BOTTOMLEFT", 16, -16)
    meterResetButton:SetText(ClassForge:L("reset_meter"))
    meterResetButton:SetScript("OnClick", function()
        ClassForge:ResetMeterPosition()
        ClassForge:Print(ClassForge:L("reset_meter") .. ".")
    end)

    local meterResetDataButton = CreateFrame("Button", nil, meter, "UIPanelButtonTemplate")
    meterResetDataButton:SetWidth(140)
    meterResetDataButton:SetHeight(24)
    meterResetDataButton:SetPoint("LEFT", meterResetButton, "RIGHT", 8, 0)
    meterResetDataButton:SetText(ClassForge:L("reset_meter_data"))
    meterResetDataButton:SetScript("OnClick", function()
        ClassForge:ResetMeterData()
    end)

    local meterExportButton = CreateFrame("Button", nil, meter, "UIPanelButtonTemplate")
    meterExportButton:SetWidth(140)
    meterExportButton:SetHeight(24)
    meterExportButton:SetPoint("LEFT", meterResetDataButton, "RIGHT", 8, 0)
    meterExportButton:SetText(ClassForge:L("meter_export"))
    meterExportButton:SetScript("OnClick", function()
        ClassForge:SetMeterExportChannel(meterExportChannelBox:GetText())
        ClassForge:ExportMeterToChat()
    end)

    local meterHint = meter:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    meterHint:SetPoint("TOPLEFT", meterResetButton, "BOTTOMLEFT", 0, -12)
    meterHint:SetWidth(460)
    meterHint:SetJustifyH("LEFT")
    meterHint:SetText(ClassForge:L("meter_hint"))

    local meterStatus = meter:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    meterStatus:SetPoint("TOPLEFT", meterHint, "BOTTOMLEFT", 0, -12)
    meterStatus:SetWidth(520)
    meterStatus:SetJustifyH("LEFT")

    local cacheStatus = cache:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cacheStatus:SetPoint("TOPLEFT", 0, -10)
    cacheStatus:SetWidth(340)
    cacheStatus:SetJustifyH("LEFT")

    local cacheList = cache:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cacheList:SetPoint("TOPLEFT", cacheStatus, "BOTTOMLEFT", 0, -8)
    cacheList:SetWidth(520)
    cacheList:SetJustifyH("LEFT")
    cacheList:SetJustifyV("TOP")

    local function updateCacheDisplay()
        local lines = {}
        local entries = {}

        if ClassForgeCache then
            for _, data in pairs(ClassForgeCache) do
                entries[#entries + 1] = data
            end
        end

        table.sort(entries, function(left, right)
            return (tonumber(left.updated) or 0) > (tonumber(right.updated) or 0)
        end)

        cacheStatus:SetText(ClassForge:L("cached_players") .. ": " .. ClassForge:GetCacheEntryCount() .. "\n" .. ClassForge:L("database_schema") .. ": " .. tostring(ClassForgeDB.dbVersion or ClassForge.dbVersion))

        local limit = math.min(#entries, 8)
        for index = 1, limit do
            local data = entries[index]
            lines[#lines + 1] = string.format("%s - %s - %s", data.name or "Unknown", ClassForge:GetSourceLabel(data), ClassForge:FormatUpdatedTime(data.updated))
        end

        if #lines == 0 then
            cacheList:SetText(ClassForge:L("no_cached_players"))
        else
            cacheList:SetText(ClassForge:L("recent_entries") .. ":\n" .. table.concat(lines, "\n"))
        end
    end

    local clearStaleButton = CreateFrame("Button", nil, cache, "UIPanelButtonTemplate")
    clearStaleButton:SetWidth(100)
    clearStaleButton:SetHeight(24)
    clearStaleButton:SetPoint("TOPLEFT", cacheList, "BOTTOMLEFT", 0, -12)
    clearStaleButton:SetText(ClassForge:L("clear_stale"))

    local clearAllButton = CreateFrame("Button", nil, cache, "UIPanelButtonTemplate")
    clearAllButton:SetWidth(100)
    clearAllButton:SetHeight(24)
    clearAllButton:SetPoint("LEFT", clearStaleButton, "RIGHT", 8, 0)
    clearAllButton:SetText(ClassForge:L("clear_all"))

    local browserTitle = cache:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    browserTitle:SetPoint("TOPLEFT", clearStaleButton, "BOTTOMLEFT", 0, -22)
    browserTitle:SetText(ClassForge:L("known_players"))

    local updateKnownPlayersBrowser

    local browserSearchBox = CreateFrame("EditBox", nil, cache, "InputBoxTemplate")
    browserSearchBox:SetAutoFocus(false)
    browserSearchBox:SetWidth(220)
    browserSearchBox:SetHeight(20)
    browserSearchBox:SetPoint("LEFT", browserTitle, "RIGHT", 12, 0)
    browserSearchBox:SetScript("OnTextChanged", function()
        updateKnownPlayersBrowser()
    end)

    local browserFrame = CreateFrame("ScrollFrame", "ClassForgeKnownPlayersScrollFrame", cache, "UIPanelScrollFrameTemplate")
    browserFrame:SetPoint("TOPLEFT", browserTitle, "BOTTOMLEFT", 0, -8)
    browserFrame:SetWidth(530)
    browserFrame:SetHeight(170)

    local browserContent = CreateFrame("Frame", nil, browserFrame)
    browserContent:SetWidth(510)
    browserContent:SetHeight(170)
    browserFrame:SetScrollChild(browserContent)

    local browserText = browserContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    browserText:SetPoint("TOPLEFT", 0, 0)
    browserText:SetWidth(500)
    browserText:SetJustifyH("LEFT")
    browserText:SetJustifyV("TOP")

    updateKnownPlayersBrowser = function()
        local entries = {}
        local lines = { "Name | Class | Role | Source | Version | Updated" }
        local filter = string.lower(ClassForge:Trim(browserSearchBox:GetText()))

        if ClassForgeCache then
            for _, data in pairs(ClassForgeCache) do
                entries[#entries + 1] = data
            end
        end

        table.sort(entries, function(left, right)
            return string.lower(left.name or "") < string.lower(right.name or "")
        end)

        if #entries == 0 then
            browserText:SetText(ClassForge:L("no_known_players"))
            browserContent:SetHeight(170)
            return
        end

        for _, data in ipairs(entries) do
            local nameText = data.name or "Unknown"
            local classText = data.className or "Unknown"
            if filter == ""
                or string.find(string.lower(nameText), filter, 1, true)
                or string.find(string.lower(classText), filter, 1, true) then
                lines[#lines + 1] = string.format(
                    "%s | %s | %s | %s | %s | %s",
                    nameText,
                    classText,
                    data.role or "-",
                    ClassForge:GetSourceLabel(data),
                    (data.addonVersion and data.addonVersion ~= "") and data.addonVersion or "-",
                    ClassForge:FormatUpdatedTime(data.updated)
                )
            end
        end

        if #lines == 1 then
            browserText:SetText(ClassForge:L("no_matching_players"))
        else
            browserText:SetText(table.concat(lines, "\n"))
        end
        browserContent:SetHeight(math.max(170, browserText:GetStringHeight() + 10))
    end

    clearStaleButton:SetScript("OnClick", function()
        local removed = ClassForge:ClearStaleCacheEntries(30 * 24 * 60 * 60)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Removed " .. removed .. " stale cache entr" .. (removed == 1 and "y." or "ies."))
    end)

    clearAllButton:SetScript("OnClick", function()
        ClassForge:ClearCache(true)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Cache cleared.")
    end)

    local function refreshStatusText()
        local syncState = ClassForge.syncState or {}
        local whoState = syncState.who or {}
        statusText:SetText(
            ClassForge:L("addon_version") .. ": " .. (ClassForge.version or "3.0.0")
            .. "\n" .. ClassForge:L("sync_protocol") .. ": CF3"
            .. "\n" .. ClassForge:L("last_sync") .. ": " .. ClassForge:FormatUpdatedTime(syncState.lastSync)
            .. " |cff808080-|r " .. ClassForge:L("last_who") .. ": " .. ClassForge:FormatUpdatedTime(whoState.lastComplete)
            .. " |cff808080-|r " .. ClassForge:L("addon_users") .. ": " .. ClassForge:GetConfirmedAddonUserCount()
            .. "\n" .. ClassForge:L("use_sync_hint")
        )
        displayStatus:SetText(ClassForge:L("minimap_button") .. ": " .. (ClassForge:IsMinimapButtonHidden() and ClassForge:L("hidden") or ClassForge:L("shown"))
            .. " |cff808080-|r " .. ClassForge:L("target_profile") .. ": " .. (ClassForge:IsTargetProfileHidden() and ClassForge:L("hidden") or ClassForge:L("shown"))
            .. " |cff808080-|r " .. ClassForge:L("locked") .. ": " .. (ClassForge:IsTargetProfileLocked() and ClassForge:L("yes") or ClassForge:L("no"))
            .. " |cff808080-|r " .. ClassForge:L("compact") .. ": " .. (ClassForge:IsTargetProfileCompact() and ClassForge:L("yes") or ClassForge:L("no"))
            .. " |cff808080-|r " .. ClassForge:L("group_colors") .. ": " .. (ClassForge:IsGroupFrameColoringEnabled() and ClassForge:L("on") or ClassForge:L("off"))
            .. " |cff808080-|r " .. ClassForge:L("auto_class_low_level") .. ": " .. (ClassForge:IsAutoClassEnabled() and ClassForge:L("on") or ClassForge:L("off"))
            .. " |cff808080-|r " .. ClassForge:L("realm_aware_names") .. ": " .. (ClassForge:IsRealmAwareEnabled() and ClassForge:L("on") or ClassForge:L("off")))
        meterStatus:SetText(
            ClassForge:L("meter_box") .. ": " .. (ClassForge:IsMeterEnabled() and ClassForge:L("shown") or ClassForge:L("hidden"))
            .. " |cff808080-|r " .. ClassForge:L("locked") .. ": " .. (ClassForge:IsMeterLocked() and ClassForge:L("yes") or ClassForge:L("no"))
            .. " |cff808080-|r " .. ClassForge:L("meter_mode_toggle") .. ": " .. ClassForge:L(ClassForge:IsMeterPersistent() and "meter_mode_session" or "meter_mode_segment")
            .. " |cff808080-|r " .. ClassForge:L("meter_include_pets") .. ": " .. (ClassForge:IsMeterPetEnabled() and ClassForge:L("yes") or ClassForge:L("no"))
            .. " |cff808080-|r " .. ClassForge:L("meter_debug") .. ": " .. (ClassForge:IsMeterDebugEnabled() and ClassForge:L("yes") or ClassForge:L("no"))
            .. " |cff808080-|r " .. ClassForge:L("meter_max_rows") .. ": " .. tostring(ClassForge:GetMeterMaxRows())
            .. " |cff808080-|r " .. ClassForge:L("meter_size") .. ": " .. math.floor((ClassForge:GetMeterSize().width or 0) + 0.5) .. "x" .. math.floor((ClassForge:GetMeterSize().height or 0) + 0.5)
        )
    end

    function panel:RefreshLocalizedText()
        subtitle:SetText(ClassForge:L("options_subtitle"))
        tabs.overview:SetText(ClassForge:L("profile_tab"))
        tabs.display:SetText(ClassForge:L("display_tab"))
        tabs.cache:SetText(ClassForge:L("cache_tab"))
        tabs.meter:SetText(ClassForge:L("meter_tab"))
        tabs.description:SetText(ClassForge:L("description_tab"))
        classBox.label:SetText(ClassForge:L("custom_class_name"))
        descriptionLabel:SetText(ClassForge:L("class_description"))
        colorBox.label:SetText(ClassForge:L("class_color_hex"))
        meterSizeLabel:SetText(ClassForge:L("meter_size"))
        meterWidthBox.label:SetText("Width")
        meterHeightBox.label:SetText("Height")
        meterRowsBox.label:SetText("Export Rows")
        meterExportLabel:SetText(ClassForge:L("meter_export_target"))
        meterExportChannelBox.label:SetText(ClassForge:L("meter_export_channel"))
        roleLabel:SetText(ClassForge:L("role_label"))
        roleHint:SetText(ClassForge:L("role_auto_hint"))
        factionLabel:SetText(ClassForge:L("faction_label"))
        presetButton:SetText(ClassForge:L("presets"))
        presetHint:SetText(ClassForge:L("presets_hint"))
        colorPickerButton:SetText(ClassForge:L("pick"))
        saveButton:SetText(ClassForge:L("save"))
        descriptionSaveButton:SetText(ClassForge:L("save"))
        descriptionClearButton:SetText(ClassForge:L("clear_description"))
        descriptionUndoButton:SetText(ClassForge:L("undo_description"))
        syncButton:SetText(ClassForge:L("sync"))
        resetButton:SetText(ClassForge:L("reset"))
        languageLabel:SetText(ClassForge:L("language"))
        minimapResetButton:SetText(ClassForge:L("reset_minimap"))
        panelResetButton:SetText(ClassForge:L("reset_panel"))
        meterResetButton:SetText(ClassForge:L("reset_meter"))
        meterResetDataButton:SetText(ClassForge:L("reset_meter_data"))
        meterExportButton:SetText(ClassForge:L("meter_export"))
        panelHint:SetText(ClassForge:L("panel_hint"))
        meterHint:SetText(ClassForge:L("meter_hint"))
        clearStaleButton:SetText(ClassForge:L("clear_stale"))
        clearAllButton:SetText(ClassForge:L("clear_all"))
        browserTitle:SetText(ClassForge:L("known_players"))
        _G[minimapToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_minimap_button"))
        _G[chatToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_chat_tags"))
        _G[realmToggle:GetName() .. "Text"]:SetText(ClassForge:L("use_realm_aware"))
        _G[autoWhoLoginToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_who_login"))
        _G[autoWhoGroupToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_who_group"))
        _G[autoClassToggle:GetName() .. "Text"]:SetText(ClassForge:L("auto_class_low_level"))
        _G[panelVisibleToggle:GetName() .. "Text"]:SetText(ClassForge:L("show_target_panel"))
        _G[panelLockToggle:GetName() .. "Text"]:SetText(ClassForge:L("lock_target_panel"))
        _G[panelCompactToggle:GetName() .. "Text"]:SetText(ClassForge:L("compact_target_panel"))
        _G[groupFrameColorsToggle:GetName() .. "Text"]:SetText(ClassForge:L("color_group_frames"))
        _G[meterEnableToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_box"))
        _G[meterLockToggle:GetName() .. "Text"]:SetText(ClassForge:L("lock_meter"))
        _G[meterPersistentToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_persistent"))
        _G[meterPetsToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_include_pets"))
        _G[meterDebugToggle:GetName() .. "Text"]:SetText(ClassForge:L("meter_debug"))
        setSelectedMeterExport(meterExportDropdown.selectedValue or ClassForge:GetMeterExportType())
        factionValue:SetText(ClassForge:GetFactionText(ClassForge:BuildProfileData()))
        if ClassForge.targetProfile then
            if ClassForge.targetProfile.refreshButton then
                ClassForge.targetProfile.refreshButton:SetText(ClassForge:L("refresh"))
            end
            if ClassForge.targetProfile.hintText then
                ClassForge.targetProfile.hintText:SetText(ClassForge:IsTargetProfileLocked() and ClassForge:L("locked") or ClassForge:L("shift_drag"))
            end
        end
        refreshRoleValue()
        setSelectedLanguage(languageDropdown.selectedValue or ClassForge:GetLanguage(), true)
        updatePreview()
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        refreshStatusText()
    end

    panel:SetScript("OnShow", function()
        local profile = ClassForge:GetProfile()
        local characterProfile = ClassForge:GetCharacterProfile()
        classBox:SetText(characterProfile.className or ClassForge.defaults.character.className)
        refreshSelectedIcon(characterProfile.icon or ClassForge:GetResolvedIconTexture(nil, characterProfile.className, true))
        colorBox:SetText(characterProfile.color or ClassForge.defaults.character.color)
        descriptionBox:SetText(characterProfile.description or "")
        refreshRoleValue()
        setSelectedLanguage(profile.locale or ClassForge:GetLanguage(), true)
        factionValue:SetText(ClassForge:GetFactionText(ClassForge:BuildProfileData()))
        minimapToggle:SetChecked(not ClassForge:IsMinimapButtonHidden())
        chatToggle:SetChecked(ClassForge:IsChatDecorationEnabled())
        realmToggle:SetChecked(ClassForge:IsRealmAwareEnabled())
        autoWhoLoginToggle:SetChecked(ClassForge:IsAutoWhoOnLoginEnabled())
        autoWhoGroupToggle:SetChecked(ClassForge:IsAutoWhoOnGroupEnabled())
        autoClassToggle:SetChecked(ClassForge:IsAutoClassEnabled())
        panelVisibleToggle:SetChecked(not ClassForge:IsTargetProfileHidden())
        panelLockToggle:SetChecked(ClassForge:IsTargetProfileLocked())
        panelCompactToggle:SetChecked(ClassForge:IsTargetProfileCompact())
        groupFrameColorsToggle:SetChecked(ClassForge:IsGroupFrameColoringEnabled())
        meterEnableToggle:SetChecked(ClassForge:IsMeterEnabled())
        meterLockToggle:SetChecked(ClassForge:IsMeterLocked())
        meterPersistentToggle:SetChecked(ClassForge:IsMeterPersistent())
        meterPetsToggle:SetChecked(ClassForge:IsMeterPetEnabled())
        meterDebugToggle:SetChecked(ClassForge:IsMeterDebugEnabled())
        meterWidthBox:SetText(tostring(ClassForge:GetMeterSize().width))
        meterHeightBox:SetText(tostring(ClassForge:GetMeterSize().height))
        meterRowsBox:SetText(tostring(ClassForge:GetMeterMaxRows()))
        meterExportChannelBox:SetText(ClassForge:GetMeterExportChannel())
        setSelectedMeterExport(ClassForge:GetMeterExportType())
        panel:RefreshLocalizedText()
        selectTab("overview")
    end)

    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
