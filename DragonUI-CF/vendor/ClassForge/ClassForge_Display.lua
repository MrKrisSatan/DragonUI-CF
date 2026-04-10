function ClassForge:InitDisplay()
    self:HookTooltips()
    self:HookFriendsTooltip()
    self:HookWhoFrame()
    self:HookGuildFrame()
    self:HookFriendsFrame()
    self:HookRaidBrowser()
    self:HookPartyFrames()
    self:SetupMapMarkerTooltips()
    self:CreateMinimapButton()
    self:CreateCharacterPanel()
    self:CreateCharacterDetailTab()
    self:CreateTargetClassTag()
    self:CreateTargetProfile()
    self:CreateMeterPanel()
    self:SetupInspectHooks()
    self:SetupMapColorHooks()
    self:SetupChatDecorators()
end

function ClassForge:GetMeterPosition()
    local profile = self:GetProfile()
    local position = profile and profile.meterPosition or nil
    local defaults = self.defaults.profile.meterPosition

    return {
        point = position and position.point or defaults.point,
        relativePoint = position and position.relativePoint or defaults.relativePoint,
        x = position and position.x or defaults.x,
        y = position and position.y or defaults.y,
    }
end

function ClassForge:ApplyMeterPosition()
    if not self.meterPanel or not UIParent then
        return
    end

    local position = self:GetMeterPosition()
    self.meterPanel:ClearAllPoints()
    self.meterPanel:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
end

function ClassForge:SaveMeterPosition()
    if not self.meterPanel then
        return
    end

    local point, _, relativePoint, x, y = self.meterPanel:GetPoint(1)
    if not point or not relativePoint then
        return
    end

    local function round(value)
        if not value then
            return 0
        end
        if value >= 0 then
            return math.floor(value + 0.5)
        end

        return math.ceil(value - 0.5)
    end

    ClassForgeDB.profile.meterPosition = {
        point = point,
        relativePoint = relativePoint,
        x = round(x),
        y = round(y),
    }
end

function ClassForge:ResetMeterPosition()
    ClassForgeDB.profile.meterPosition = {
        point = self.defaults.profile.meterPosition.point,
        relativePoint = self.defaults.profile.meterPosition.relativePoint,
        x = self.defaults.profile.meterPosition.x,
        y = self.defaults.profile.meterPosition.y,
    }
    self:ApplyMeterPosition()
end

function ClassForge:GetMeterSize()
    local profile = self:GetProfile()
    local size = profile and profile.meterSize or nil
    local defaults = self.defaults.profile.meterSize
    local width = tonumber(size and size.width) or defaults.width
    local height = tonumber(size and size.height) or defaults.height

    if width < 420 then
        width = 420
    elseif width > 1800 then
        width = 1800
    end

    if height < 140 then
        height = 140
    elseif height > 1200 then
        height = 1200
    end

    return {
        width = math.floor(width + 0.5),
        height = math.floor(height + 0.5),
    }
end

function ClassForge:ApplyMeterSize()
    if not self.meterPanel then
        return
    end

    local size = self:GetMeterSize()
    self.meterPanel:SetWidth(size.width)
    self.meterPanel:SetHeight(size.height)
end

function ClassForge:SaveMeterSize()
    if not self.meterPanel then
        return
    end

    ClassForgeDB.profile.meterSize = {
        width = math.floor(self.meterPanel:GetWidth() + 0.5),
        height = math.floor(self.meterPanel:GetHeight() + 0.5),
    }
end

function ClassForge:SetMeterSizeDimensions(width, height)
    ClassForgeDB.profile.meterSize = ClassForgeDB.profile.meterSize or {}

    local current = self:GetMeterSize()
    local newWidth = tonumber(width) or current.width
    local newHeight = tonumber(height) or current.height

    if newWidth < 420 then
        newWidth = 420
    elseif newWidth > 1800 then
        newWidth = 1800
    end

    if newHeight < 140 then
        newHeight = 140
    elseif newHeight > 1200 then
        newHeight = 1200
    end

    ClassForgeDB.profile.meterSize.width = math.floor(newWidth + 0.5)
    ClassForgeDB.profile.meterSize.height = math.floor(newHeight + 0.5)
    self:ApplyMeterSize()
    self:UpdateMeterPanel()
end

function ClassForge:ResetMeterSize()
    ClassForgeDB.profile.meterSize = {
        width = self.defaults.profile.meterSize.width,
        height = self.defaults.profile.meterSize.height,
    }
    self:ApplyMeterSize()
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterEnabled(enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.enabled = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterView(view)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    local normalized = string.lower(self:Trim(view))
    if normalized ~= "dps" and normalized ~= "threat" and normalized ~= "healing_done" and normalized ~= "healing_received" then
        normalized = self.defaults.profile.meter.view or "dps"
    end

    ClassForgeDB.profile.meter.sortBy = normalized
    ClassForgeDB.profile.meter.view = normalized
    self:UpdateMeterPanel()
end

function ClassForge:GetMeterSortMode()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local selected = meter and meter.sortBy or nil

    if type(selected) ~= "string" or selected == "" then
        selected = meter and meter.view or nil
    end

    selected = type(selected) == "string" and string.lower(self:Trim(selected)) or ""
    if selected ~= "dps" and selected ~= "threat" and selected ~= "healing_done" and selected ~= "healing_received" then
        selected = self.defaults.profile.meter.view or "dps"
    end

    return selected
end

function ClassForge:SetMeterPersistent(enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.persistent = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterLocked(locked)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.locked = locked and true or false

    if self.meterPanel and self.meterPanel.hintText then
        self.meterPanel.hintText:SetText(locked and self:L("locked") or self:L("meter_hint"))
    end
end

function ClassForge:SetMeterSectionEnabled(key, enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter[key] = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterMaxRows(value)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    local numeric = tonumber(value) or self.defaults.profile.meter.maxRows
    if numeric < 3 then
        numeric = 3
    elseif numeric > 50 then
        numeric = 50
    end
    ClassForgeDB.profile.meter.maxRows = math.floor(numeric + 0.5)
    self:UpdateMeterPanel()
end

function ClassForge:GetMeterSortValue(row, view, duration)
    local selectedView = view or self:GetMeterSortMode()
    if selectedView == "threat" then
        return row.threat or 0
    elseif selectedView == "healing_done" then
        return row.healing or 0
    elseif selectedView == "healing_received" then
        return row.received or 0
    end

    return row.damage or 0
end

function ClassForge:GetMeterColumnDefinitions()
    return {
        { key = "name", label = "Player", weight = 0.30, justify = "LEFT" },
        { key = "damage", label = "Damage", weight = 0.12, justify = "RIGHT" },
        { key = "dps", label = "DPS", weight = 0.08, justify = "RIGHT" },
        { key = "threat", label = "Threat", weight = 0.10, justify = "RIGHT" },
        { key = "healing", label = "Healing", weight = 0.12, justify = "RIGHT" },
        { key = "received", label = "Received", weight = 0.12, justify = "RIGHT" },
        { key = "topSpell", label = self:L("top_spell"), weight = 0.10, justify = "LEFT" },
    }
end

function ClassForge:SanitizeMeterInlineText(text)
    local clean = tostring(text or "")
    clean = clean:gsub("[\r\n]+", " ")
    clean = clean:gsub("%s+", " ")
    clean = clean:gsub("^%s+", "")
    clean = clean:gsub("%s+$", "")
    return clean
end

function ClassForge:GetTableMeterIdentityText(name)
    local displayName = self:NormalizePlayerName(name) or name or self:L("unknown")
    return self:SanitizeMeterInlineText(displayName)
end

function ClassForge:GetMeterSortColumnKey(view)
    local selectedView = view or self:GetMeterSortMode()
    if selectedView == "threat" then
        return "threat"
    elseif selectedView == "healing_done" then
        return "healing"
    elseif selectedView == "healing_received" then
        return "received"
    end

    return "damage"
end

function ClassForge:GetMeterViewTooltip(view)
    if view == "threat" then
        return "Sort by Threat"
    elseif view == "healing_done" then
        return "Sort by Healing Done"
    elseif view == "healing_received" then
        return "Sort by Healing Received"
    end

    return "Sort by Damage"
end

function ClassForge:FormatMeterCellValue(columnKey, row, duration, plain)
    if columnKey == "name" then
        if plain then
            return self:GetPlainMeterIdentityText(row.name)
        end
        return self:GetTableMeterIdentityText(row.name)
    elseif columnKey == "damage" then
        return tostring(row.damage or 0)
    elseif columnKey == "dps" then
        return tostring(math.floor((((row.damage or 0) / math.max(duration or 1, 1)) + 0.5)))
    elseif columnKey == "threat" then
        return row.threat and string.format("%.0f%%", row.threat) or "-"
    elseif columnKey == "healing" then
        return tostring(row.healing or 0)
    elseif columnKey == "received" then
        return tostring(row.received or 0)
    elseif columnKey == "topSpell" then
        return self:SanitizeMeterInlineText(self:GetMeterTopSpellForName(row.name, plain))
    end

    return ""
end

function ClassForge:UpdateMeterTableLayout()
    local frame = self.meterPanel
    if not frame or not frame.header or not frame.scrollChild then
        return
    end

    local contentWidth = math.max(420, frame:GetWidth() - 44)
    local columns = self:GetMeterColumnDefinitions()
    local usableWidth = math.max(360, contentWidth - 12)
    local currentLeft = 0
    local allocated = 0

    frame.header:SetWidth(contentWidth)
    frame.scrollChild:SetWidth(contentWidth)
    if frame.emptyText then
        frame.emptyText:SetWidth(math.max(360, contentWidth - 12))
    end

    for index, column in ipairs(columns) do
        local width = math.floor((usableWidth * column.weight) + 0.5)
        if index == #columns then
            width = math.max(60, usableWidth - allocated)
        else
            allocated = allocated + width
        end
        column.width = width
        column.left = currentLeft
        currentLeft = currentLeft + width + 6
    end

    for _, fontString in ipairs(frame.header.columns or {}) do
        local column = columns[fontString.columnIndex]
        fontString:ClearAllPoints()
        fontString:SetWidth(column.width)
        fontString:SetJustifyH(column.justify or "LEFT")
        fontString:SetPoint("TOPLEFT", frame.header, "TOPLEFT", column.left, 0)
    end

    for _, rowFrame in ipairs(frame.rows or {}) do
        rowFrame:SetWidth(contentWidth)
        for _, fontString in ipairs(rowFrame.columns or {}) do
            local column = columns[fontString.columnIndex]
            fontString:ClearAllPoints()
            fontString:SetWidth(column.width)
            fontString:SetJustifyH(column.justify or "LEFT")
            fontString:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", column.left, -2)
        end
    end
end

function ClassForge:AcquireMeterRow(index)
    local frame = self.meterPanel
    frame.rows = frame.rows or {}
    if frame.rows[index] then
        return frame.rows[index]
    end

    local row = CreateFrame("Frame", nil, frame.scrollChild)
    row:SetHeight(18)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.background:SetVertexColor(1, 1, 1, 0.03)
    row.columns = {}

    local columns = self:GetMeterColumnDefinitions()
    for columnIndex, column in ipairs(columns) do
        local fontObject = ((column.key == "name") or (column.key == "topSpell")) and "GameFontHighlightSmall" or "GameFontNormalSmall"
        local text = row:CreateFontString(nil, "OVERLAY", fontObject)
        text:SetJustifyV("MIDDLE")
        if text.SetWordWrap then
            text:SetWordWrap(false)
        end
        if text.SetNonSpaceWrap then
            text:SetNonSpaceWrap(false)
        end
        if text.SetMaxLines then
            text:SetMaxLines(1)
        end
        text.columnIndex = columnIndex
        row.columns[#row.columns + 1] = text
    end

    frame.rows[index] = row
    self:UpdateMeterTableLayout()
    return row
end

function ClassForge:SetMeterExportTarget(exportType)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.exportType = self:Trim(exportType) ~= "" and exportType or self.defaults.profile.meter.exportType
end

function ClassForge:SetMeterExportChannel(channelName)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.exportChannel = self:Trim(channelName) ~= "" and self:Trim(channelName) or self.defaults.profile.meter.exportChannel
end

function ClassForge:SetMeterIncludePets(enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.includePets = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterDebug(enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.debug = enabled and true or false
    self:Print(self:L(enabled and "meter_debug_on" or "meter_debug_off"))
    self:UpdateMeterPanel()
end

function ClassForge:IsTrackedGroupPlayer(name)
    local normalized = self:NormalizePlayerName(name)
    local playerName = self:NormalizePlayerName(UnitName("player"))
    if not normalized then
        return false
    end

    if normalized == playerName then
        return true
    end

    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            local unit = "raid" .. index
            if UnitExists(unit) and UnitIsPlayer(unit) then
                if self:NormalizePlayerName(UnitName(unit)) == normalized then
                    return true
                end
            end
        end
        return false
    end

    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        if UnitExists(unit) and UnitIsPlayer(unit) then
            if self:NormalizePlayerName(UnitName(unit)) == normalized then
                return true
            end
        end
    end

    return false
end

function ClassForge:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID)
    local playerGUID = UnitGUID and UnitGUID("player") or nil
    if playerGUID and sourceGUID and playerGUID == sourceGUID then
        return true
    end

    local trimmedSourceName = self:Trim(sourceName)
    local playerName = UnitName("player")
    if trimmedSourceName ~= "" then
        if trimmedSourceName == "You" or trimmedSourceName == self:L("you") then
            return true
        end

        if playerName and self:NormalizePlayerName(trimmedSourceName) == self:NormalizePlayerName(playerName) then
            return true
        end
    end

    if self:IsMeterPetEnabled() then
        local function unitMatches(unit)
            if not UnitExists(unit) then
                return false
            end

            if sourceGUID and UnitGUID and UnitGUID(unit) == sourceGUID then
                return true
            end

            if trimmedSourceName ~= "" and UnitName(unit) and self:NormalizePlayerName(UnitName(unit)) == self:NormalizePlayerName(trimmedSourceName) then
                return true
            end

            return false
        end

        if unitMatches("pet") then
            return true
        end

        for index = 1, MAX_PARTY_MEMBERS do
            if unitMatches("partypet" .. index) then
                return true
            end
        end

        for index = 1, MAX_RAID_MEMBERS do
            if unitMatches("raidpet" .. index) then
                return true
            end
        end
    end

    return self:IsTrackedGroupPlayer(sourceName)
end

function ClassForge:ResetMeterCombat()
    self.meterState = self.meterState or {}
    self.meterState.breakdown = self.meterState.breakdown or {
        damageSpells = {},
        healingSpells = {},
    }

    self.meterState.combat = {
        active = false,
        started = 0,
        ended = 0,
        damage = {},
        healing = {},
        healingReceived = {},
        damageSpells = {},
        healingSpells = {},
    }
    self.pendingSpellDamage = {}
    self:UpdateMeterPanel()
end

function ClassForge:ResetMeterData()
    self.meterState = self.meterState or {}
    self.meterState.breakdown = {
        damageSpells = {},
        healingSpells = {},
    }
    local characterProfile = self.GetCharacterProfile and self:GetCharacterProfile() or nil
    if characterProfile then
        characterProfile.spellHistory = {}
    end
    if self.RefreshPlayerCache then
        self:RefreshPlayerCache()
    end
    self:ResetMeterCombat()
end

function ClassForge:RecordPersistentSpellUsage(spellName, amount)
    local cleanSpell = self:Trim(spellName)
    local numericAmount = tonumber(amount) or 0
    if cleanSpell == "" or numericAmount <= 0 then
        return
    end

    local characterProfile = self.GetCharacterProfile and self:GetCharacterProfile() or nil
    if not characterProfile then
        return
    end

    characterProfile.spellHistory = type(characterProfile.spellHistory) == "table" and characterProfile.spellHistory or {}
    characterProfile.spellHistory[cleanSpell] = (tonumber(characterProfile.spellHistory[cleanSpell]) or 0) + numericAmount
end

function ClassForge:GetPersistentTopSpellsSummary(limit)
    local characterProfile = self.GetCharacterProfile and self:GetCharacterProfile() or nil
    local history = characterProfile and characterProfile.spellHistory or nil
    if type(history) ~= "table" then
        return ""
    end

    local rows = {}
    for spellName, amount in pairs(history) do
        local numeric = tonumber(amount) or 0
        if numeric > 0 then
            rows[#rows + 1] = {
                spell = spellName,
                amount = numeric,
            }
        end
    end

    if #rows == 0 then
        return ""
    end

    table.sort(rows, function(left, right)
        if left.amount == right.amount then
            return string.lower(left.spell or "") < string.lower(right.spell or "")
        end
        return left.amount > right.amount
    end)

    local parts = {}
    local maxCount = math.min(limit or 5, #rows)
    for index = 1, maxCount do
        parts[#parts + 1] = string.format("%s (%d)", rows[index].spell, rows[index].amount)
    end

    return table.concat(parts, ", ")
end

function ClassForge:EnsureMeterCombatActive()
    if not self:IsMeterEnabled() then
        return nil
    end

    self.meterState = self.meterState or {}
    self.meterState.breakdown = self.meterState.breakdown or {
        damageSpells = {},
        healingSpells = {},
    }
    self.meterState.combat = self.meterState.combat or {
        active = false,
        started = 0,
        ended = 0,
        damage = {},
        healing = {},
        healingReceived = {},
        damageSpells = {},
        healingSpells = {},
    }

    local combat = self.meterState.combat
    local breakdown = self.meterState.breakdown
    combat.healingReceived = combat.healingReceived or {}
    combat.damageSpells = combat.damageSpells or {}
    combat.healingSpells = combat.healingSpells or {}
    breakdown.damageSpells = breakdown.damageSpells or {}
    breakdown.healingSpells = breakdown.healingSpells or {}
    if not combat.started or combat.started == 0 then
        combat.started = (GetTime and GetTime()) or time()
    end
    combat.active = true

    return combat
end

function ClassForge:GetMeterCombatDuration()
    local combat = self.meterState and self.meterState.combat or nil
    if not combat or not combat.started or combat.started <= 0 then
        return 1
    end

    local now = (GetTime and GetTime()) or time()
    local finish = combat.active and now or (combat.ended or now)
    local duration = finish - combat.started
    if duration < 1 then
        duration = 1
    end

    return duration
end

function ClassForge:GetMeterEntry(container, name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized then
        return nil
    end

    container[normalized] = container[normalized] or {
        name = normalized,
        total = 0,
        spells = {},
    }

    return container[normalized]
end

function ClassForge:GetMeterSpellAmount(spellEntry)
    if type(spellEntry) == "table" then
        return tonumber(spellEntry.amount) or 0
    end

    return tonumber(spellEntry) or 0
end

function ClassForge:GetOrCreateMeterSpellEntry(container, spellKey)
    local current = container[spellKey]
    if type(current) == "table" then
        current.amount = tonumber(current.amount) or 0
        current.totalhits = tonumber(current.totalhits) or 0
        return current
    end

    local entry = {
        amount = tonumber(current) or 0,
        totalhits = 0,
        hit = 0,
        hitamount = 0,
        critical = 0,
        criticalamount = 0,
        overkill = 0,
    }
    container[spellKey] = entry
    return entry
end

function ClassForge:SeedMeterParticipants()
    if not self:IsMeterEnabled() then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    if not combat then
        return
    end

    local function addUnit(unit)
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name = UnitName(unit)
            if name then
                self:GetMeterEntry(combat.damage, name)
                self:GetMeterEntry(combat.healing, name)
                self:GetMeterEntry(combat.healingReceived, name)
            end
        end
    end

    addUnit("player")

    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            addUnit("raid" .. index)
        end
    else
        for index = 1, MAX_PARTY_MEMBERS do
            addUnit("party" .. index)
        end
    end
end

function ClassForge:RecordMeterDamage(sourceName, spellName, amount, sourceFlags, sourceGUID, details)
    if not self:IsMeterEnabled() then
        return
    end

    if (not sourceName and not sourceGUID) or not amount or amount <= 0 or not self:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID) then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    if not combat then
        return
    end
    combat.damage = combat.damage or {}
    combat.damageSpells = combat.damageSpells or {}
    local entry = self:GetMeterEntry(combat.damage, sourceName or UnitName("player"))
    if not entry then
        return
    end

    local spellKey = self:Trim(spellName) ~= "" and spellName or "Melee"
    entry.total = (entry.total or 0) + amount
    local entrySpell = self:GetOrCreateMeterSpellEntry(entry.spells, spellKey)
    local combatSpell = self:GetOrCreateMeterSpellEntry(combat.damageSpells, spellKey)
    local breakdownSpell = self:GetOrCreateMeterSpellEntry(self.meterState.breakdown.damageSpells, spellKey)
    local spellID = details and details.spellID or nil
    local school = details and details.school or nil
    local overkill = details and tonumber(details.overkill) or 0
    local missed = details and details.missed or nil
    local critical = details and details.critical or nil
    local glancing = details and details.glancing or nil
    local crushing = details and details.crushing or nil

    local function applySpellStats(spellEntry)
        spellEntry.amount = (spellEntry.amount or 0) + amount
        spellEntry.totalhits = (spellEntry.totalhits or 0) + 1
        if spellID and not spellEntry.id then
            spellEntry.id = spellID
        end
        if school and not spellEntry.school then
            spellEntry.school = school
        end
        if overkill and overkill > 0 then
            spellEntry.overkill = (spellEntry.overkill or 0) + overkill
        end
        if critical then
            spellEntry.critical = (spellEntry.critical or 0) + 1
            spellEntry.criticalamount = (spellEntry.criticalamount or 0) + amount
            spellEntry.criticalmax = not spellEntry.criticalmax and amount or math.max(spellEntry.criticalmax, amount)
            spellEntry.criticalmin = not spellEntry.criticalmin and amount or math.min(spellEntry.criticalmin, amount)
        elseif glancing then
            spellEntry.glancing = (spellEntry.glancing or 0) + 1
        elseif crushing then
            spellEntry.crushing = (spellEntry.crushing or 0) + 1
        elseif missed then
            spellEntry[missed] = (spellEntry[missed] or 0) + 1
        else
            spellEntry.hit = (spellEntry.hit or 0) + 1
            spellEntry.hitamount = (spellEntry.hitamount or 0) + amount
            spellEntry.hitmax = not spellEntry.hitmax and amount or math.max(spellEntry.hitmax, amount)
            spellEntry.hitmin = not spellEntry.hitmin and amount or math.min(spellEntry.hitmin, amount)
        end
        spellEntry.max = not spellEntry.max and amount or math.max(spellEntry.max, amount)
        spellEntry.min = not spellEntry.min and amount or math.min(spellEntry.min, amount)
    end

    applySpellStats(entrySpell)
    applySpellStats(combatSpell)
    applySpellStats(breakdownSpell)
    self:RecordPersistentSpellUsage(spellKey, amount)

    local pending = self.pendingSpellDamage
    local playerGUID = UnitGUID and UnitGUID("player") or nil
    local playerName = UnitName("player")
    if type(pending) == "table" and spellKey ~= "Melee" then
        local sameSource = false
        if playerGUID and sourceGUID and sourceGUID == playerGUID then
            sameSource = true
        elseif playerName and sourceName and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(playerName) then
            sameSource = true
        end

        if sameSource then
            local normalizedSpell = self:NormalizePlayerName(spellKey)
            for index = #pending, 1, -1 do
                local item = pending[index]
                if item and self:NormalizePlayerName(item.spell) == normalizedSpell then
                    table.remove(pending, index)
                    break
                end
            end
        end
    end

    if playerName and ((playerGUID and sourceGUID and sourceGUID == playerGUID) or (sourceName and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(playerName))) then
        local selfData = self:GetDataForName(playerName) or self:BuildProfileData()
        if selfData then
            selfData.topSpells = self:GetPersistentTopSpellsSummary(5)
            self:SetDataForName(playerName, selfData)
        end
    end
end

function ClassForge:RecordMeterHealing(sourceName, amount, sourceFlags, sourceGUID, destName, spellName, details)
    if not self:IsMeterEnabled() then
        return
    end

    if (not sourceName and not sourceGUID) or not amount or amount <= 0 or not self:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID) then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    if not combat then
        return
    end
    combat.healing = combat.healing or {}
    combat.healingReceived = combat.healingReceived or {}
    combat.healingSpells = combat.healingSpells or {}
    local entry = self:GetMeterEntry(combat.healing, sourceName or UnitName("player"))
    if not entry then
        return
    end

    entry.total = (entry.total or 0) + amount
    local spellKey = self:Trim(spellName) ~= "" and spellName or "Heal"
    local entrySpell = self:GetOrCreateMeterSpellEntry(entry.spells, spellKey)
    local combatSpell = self:GetOrCreateMeterSpellEntry(combat.healingSpells, spellKey)
    local breakdownSpell = self:GetOrCreateMeterSpellEntry(self.meterState.breakdown.healingSpells, spellKey)
    local spellID = details and details.spellID or nil
    local school = details and details.school or nil
    local critical = details and details.critical or nil

    local function applyHealingStats(spellEntry)
        spellEntry.amount = (spellEntry.amount or 0) + amount
        spellEntry.totalhits = (spellEntry.totalhits or 0) + 1
        if spellID and not spellEntry.id then
            spellEntry.id = spellID
        end
        if school and not spellEntry.school then
            spellEntry.school = school
        end
        if critical then
            spellEntry.critical = (spellEntry.critical or 0) + 1
            spellEntry.criticalamount = (spellEntry.criticalamount or 0) + amount
        else
            spellEntry.hit = (spellEntry.hit or 0) + 1
            spellEntry.hitamount = (spellEntry.hitamount or 0) + amount
        end
        spellEntry.max = not spellEntry.max and amount or math.max(spellEntry.max, amount)
        spellEntry.min = not spellEntry.min and amount or math.min(spellEntry.min, amount)
    end

    applyHealingStats(entrySpell)
    applyHealingStats(combatSpell)
    applyHealingStats(breakdownSpell)
    self:RecordPersistentSpellUsage(spellKey, amount)

    local resolvedDestName = destName
    if type(resolvedDestName) == "string" then
        local trimmedDest = self:Trim(resolvedDestName)
        if trimmedDest ~= "" and UnitExists and UnitExists(trimmedDest) and UnitName then
            resolvedDestName = UnitName(trimmedDest)
        elseif trimmedDest == "player" and UnitName then
            resolvedDestName = UnitName("player")
        end
    end

    if resolvedDestName then
        local receivedEntry = self:GetMeterEntry(combat.healingReceived, resolvedDestName)
        if receivedEntry then
            receivedEntry.total = (receivedEntry.total or 0) + amount
        end
    end

    local playerGUID = UnitGUID and UnitGUID("player") or nil
    local playerName = UnitName("player")
    if playerName and ((playerGUID and sourceGUID and sourceGUID == playerGUID) or (sourceName and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(playerName))) then
        local selfData = self:GetDataForName(playerName) or self:BuildProfileData()
        if selfData then
            selfData.topSpells = self:GetPersistentTopSpellsSummary(5)
            self:SetDataForName(playerName, selfData)
        end
    end
end

function ClassForge:RecordMeterMiss(sourceName, spellName, sourceFlags, sourceGUID, details)
    if not self:IsMeterEnabled() then
        return
    end

    if (not sourceName and not sourceGUID) or not self:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID) then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    if not combat then
        return
    end

    combat.damage = combat.damage or {}
    combat.damageSpells = combat.damageSpells or {}
    local entry = self:GetMeterEntry(combat.damage, sourceName or UnitName("player"))
    if not entry then
        return
    end

    local spellKey = self:Trim(spellName) ~= "" and spellName or "Melee"
    local missed = details and details.missed or "MISS"
    local spellID = details and details.spellID or nil
    local school = details and details.school or nil
    local function applyMiss(spellEntry)
        spellEntry.totalhits = (spellEntry.totalhits or 0) + 1
        spellEntry[missed] = (spellEntry[missed] or 0) + 1
        if spellID and not spellEntry.id then
            spellEntry.id = spellID
        end
        if school and not spellEntry.school then
            spellEntry.school = school
        end
    end

    applyMiss(self:GetOrCreateMeterSpellEntry(entry.spells, spellKey))
    applyMiss(self:GetOrCreateMeterSpellEntry(combat.damageSpells, spellKey))
    applyMiss(self:GetOrCreateMeterSpellEntry(self.meterState.breakdown.damageSpells, spellKey))
end

function ClassForge:GetMeterIdentityText(name)
    local data = self:GetDataForName(name)
    local displayName = self:NormalizePlayerName(name) or name or self:L("unknown")
    if data and data.className then
        return displayName .. " (" .. self:GetColoredClassText(data) .. ")"
    end

    return displayName
end

function ClassForge:GetPlainMeterIdentityText(name)
    local data = self:GetDataForName(name)
    local displayName = self:NormalizePlayerName(name) or name or self:L("unknown")
    if data and data.className then
        return displayName .. " (" .. (data.className or self:L("unknown")) .. ")"
    end

    return displayName
end

function ClassForge:GetSpellIconMarkup(spellName, size)
    local cleanSpell = self:Trim(spellName)
    if cleanSpell == "" then
        return ""
    end

    local icon
    if cleanSpell == "Melee" or cleanSpell == "melee swing" then
        icon = "Interface\\Icons\\Ability_MeleeDamage"
    elseif GetSpellInfo then
        local _, _, spellIcon = GetSpellInfo(cleanSpell)
        icon = spellIcon
    end

    if not icon then
        return ""
    end

    local iconSize = tonumber(size) or 14
    return string.format("|T%s:%d:%d:0:0|t ", icon, iconSize, iconSize)
end

function ClassForge:GetIconizedSpellText(spellName, amount, size)
    local cleanSpell = self:Trim(spellName)
    if cleanSpell == "" then
        return ""
    end

    local suffix = amount and string.format(" (%d)", tonumber(amount) or 0) or ""
    return self:GetSpellIconMarkup(cleanSpell, size) .. cleanSpell .. suffix
end

function ClassForge:GetMeterTopSpellText()
    local combat = self.meterState and self.meterState.combat or nil
    local playerName = UnitName("player")
    local entry = nil
    if combat and combat.damage and playerName then
        entry = combat.damage[self:NormalizePlayerName(playerName)]
    end
    if not entry or not entry.spells then
        return self:L("none")
    end

    local bestSpell, bestAmount
    for spellName, amount in pairs(entry.spells) do
        amount = self:GetMeterSpellAmount(amount)
        if not bestAmount or amount > bestAmount then
            bestSpell = spellName
            bestAmount = amount
        end
    end

    if not bestSpell then
        return self:L("none")
    end

    return self:GetIconizedSpellText(bestSpell, bestAmount or 0, 14)
end

function ClassForge:GetMeterTopSpellForName(name, plain)
    local combat = self.meterState and self.meterState.combat or nil
    local normalized = self:NormalizePlayerName(name)
    local entry = combat and combat.damage and normalized and combat.damage[normalized] or nil
    if not entry or not entry.spells then
        return self:L("none")
    end

    local bestSpell, bestAmount
    for spellName, amount in pairs(entry.spells) do
        amount = self:GetMeterSpellAmount(amount)
        if not bestAmount or amount > bestAmount then
            bestSpell = spellName
            bestAmount = amount
        end
    end

    if not bestSpell then
        return self:L("none")
    end

    if plain then
        return string.format("%s (%d)", bestSpell, bestAmount or 0)
    end

    return self:GetIconizedSpellText(bestSpell, bestAmount or 0, 14)
end

function ClassForge:GetMeterLeaderText(containerName, perSecond)
    local combat = self.meterState and self.meterState.combat or nil
    local container = combat and combat[containerName] or nil
    if not container then
        return self:L("none")
    end

    local duration = self:GetMeterCombatDuration()
    local bestEntry
    for _, entry in pairs(container) do
        if not bestEntry or (entry.total or 0) > (bestEntry.total or 0) then
            bestEntry = entry
        end
    end

    if not bestEntry then
        return self:L("none")
    end

    local value = bestEntry.total or 0
    if perSecond then
        value = math.floor((value / duration) + 0.5)
    end

    return string.format("%s (%d)", self:GetMeterIdentityText(bestEntry.name), value)
end

function ClassForge:GetThreatLeaderText()
    if not UnitDetailedThreatSituation or not UnitExists("target") or not UnitCanAttack("player", "target") then
        return self:L("none")
    end

    local bestName
    local bestThreat = -1
    local function checkUnit(unit)
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local _, _, percent = UnitDetailedThreatSituation(unit, "target")
            percent = tonumber(percent) or 0
            if percent > bestThreat then
                bestThreat = percent
                bestName = UnitName(unit)
            end
        end
    end

    checkUnit("player")
    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            checkUnit("raid" .. index)
        end
    else
        for index = 1, MAX_PARTY_MEMBERS do
            checkUnit("party" .. index)
        end
    end

    if not bestName then
        return self:L("none")
    end

    return string.format("%s (%.0f%%)", self:GetMeterIdentityText(bestName), bestThreat)
end

function ClassForge:GetThreatTable()
    local threats = {}
    if not UnitDetailedThreatSituation or not UnitExists("target") or not UnitCanAttack("player", "target") then
        return threats
    end

    local function addUnit(unit)
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name = UnitName(unit)
            local _, _, percent = UnitDetailedThreatSituation(unit, "target")
            if name and percent then
                threats[self:NormalizePlayerName(name)] = tonumber(percent) or 0
            end
        end
    end

    addUnit("player")
    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            addUnit("raid" .. index)
        end
    else
        for index = 1, MAX_PARTY_MEMBERS do
            addUnit("party" .. index)
        end
    end

    return threats
end

function ClassForge:GetMeterRows(view)
    local combat = self.meterState and self.meterState.combat or nil
    local selectedView = view or self:GetMeterSortMode()
    if not combat then
        return nil, self:GetMeterCombatDuration()
    end

    local entriesByName = {}
    local order = {}
    local threatByName = self:GetThreatTable()

    local function ensureEntry(name)
        local normalized = self:NormalizePlayerName(name)
        if not normalized then
            return nil
        end
        if not entriesByName[normalized] then
            entriesByName[normalized] = {
                name = normalized,
                damage = 0,
                healing = 0,
                received = 0,
                threat = 0,
            }
            order[#order + 1] = entriesByName[normalized]
        end

        return entriesByName[normalized]
    end

    for _, entry in pairs(combat.damage or {}) do
        local row = ensureEntry(entry.name)
        if row then
            row.damage = entry.total or 0
        end
    end

    for _, entry in pairs(combat.healing or {}) do
        local row = ensureEntry(entry.name)
        if row then
            row.healing = entry.total or 0
        end
    end

    for _, entry in pairs(combat.healingReceived or {}) do
        local row = ensureEntry(entry.name)
        if row then
            row.received = entry.total or 0
        end
    end

    for normalized, percent in pairs(threatByName) do
        local row = ensureEntry(normalized)
        if row then
            row.threat = percent
        end
    end

    if #order == 0 and combat.active then
        self:SeedMeterParticipants()

        for _, entry in pairs(combat.damage or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.damage = entry.total or 0
            end
        end

        for _, entry in pairs(combat.healing or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.healing = entry.total or 0
            end
        end

        for _, entry in pairs(combat.healingReceived or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.received = entry.total or 0
            end
        end

        for normalized, percent in pairs(threatByName) do
            local row = ensureEntry(normalized)
            if row then
                row.threat = percent
            end
        end
    end

    if #order == 0 then
        return nil, self:GetMeterCombatDuration()
    end

    table.sort(order, function(left, right)
        local leftValue = self:GetMeterSortValue(left, selectedView)
        local rightValue = self:GetMeterSortValue(right, selectedView)

        if leftValue == rightValue then
            return string.lower(left.name or "") < string.lower(right.name or "")
        end

        return leftValue > rightValue
    end)

    return order, self:GetMeterCombatDuration()
end

function ClassForge:GetMeterRowColor(index, total)
    local progress = 0

    if total and total > 1 then
        progress = (index - 1) / (total - 1)
    end

    local stops = {
        { at = 0.0, color = "CE2029" },
        { at = 0.33, color = "FFD54A" },
        { at = 0.66, color = "76C66B" },
        { at = 1.0, color = "2E8B57" },
    }

    local fromStop = stops[1]
    local toStop = stops[#stops]
    for stopIndex = 1, (#stops - 1) do
        local current = stops[stopIndex]
        local nextStop = stops[stopIndex + 1]
        if progress >= current.at and progress <= nextStop.at then
            fromStop = current
            toStop = nextStop
            break
        end
    end

    local range = toStop.at - fromStop.at
    local segmentProgress = range > 0 and ((progress - fromStop.at) / range) or 0
    local fromRed, fromGreen, fromBlue = self:HexToRGB(fromStop.color)
    local toRed, toGreen, toBlue = self:HexToRGB(toStop.color)

    local red = fromRed + ((toRed - fromRed) * segmentProgress)
    local green = fromGreen + ((toGreen - fromGreen) * segmentProgress)
    local blue = fromBlue + ((toBlue - fromBlue) * segmentProgress)

    return string.format("%02x%02x%02x", math.floor(red * 255 + 0.5), math.floor(green * 255 + 0.5), math.floor(blue * 255 + 0.5))
end

function ClassForge:BuildMeterText()
    local selectedView = self:GetMeterSortMode()
    local rows, duration = self:GetMeterRows(selectedView)
    if not rows or #rows == 0 then
        return self:L("meter_waiting")
    end

    local lines = {
        "Player | Damage | DPS | Threat | Healing | Received | " .. self:L("top_spell")
    }
    for index = 1, #rows do
        local row = rows[index]
        local parts = {
            self:GetMeterIdentityText(row.name),
            tostring(row.damage or 0),
            tostring(math.floor((((row.damage or 0) / math.max(duration or 1, 1)) + 0.5))),
            row.threat and string.format("%.0f%%", row.threat) or "-",
            tostring(row.healing or 0),
            tostring(row.received or 0),
            self:GetMeterTopSpellForName(row.name),
        }
        lines[#lines + 1] = string.format("|cff%s%s|r", self:GetMeterRowColor(index, #rows), table.concat(parts, " | "))
    end

    return table.concat(lines, "\n")
end

function ClassForge:BuildMeterExportLines()
    local selectedView = self:GetMeterSortMode()
    local rows, duration = self:GetMeterRows(selectedView)
    if not rows or #rows == 0 then
        return nil
    end

    local maxRows = self:GetMeterMaxRows()
    local lines = { "[ClassForge Meter]", "Player | Damage | DPS | Threat | Healing | Received | " .. self:L("top_spell") }
    for index = 1, math.min(#rows, maxRows) do
        local row = rows[index]
        local parts = {
            self:GetPlainMeterIdentityText(row.name),
            tostring(row.damage or 0),
            tostring(math.floor((((row.damage or 0) / math.max(duration or 1, 1)) + 0.5))),
            row.threat and string.format("%.0f%%", row.threat) or "-",
            tostring(row.healing or 0),
            tostring(row.received or 0),
            self:GetMeterTopSpellForName(row.name, true),
        }
        lines[#lines + 1] = table.concat(parts, " | ")
    end

    return lines
end

function ClassForge:GetSpellBreakdownData(mode, scope, playerName)
    local selectedMode = mode or "damage"
    if selectedMode == "threat" then
        return self:GetThreatBreakdownRows()
    end

    local selectedScope = scope or "personal"
    if playerName and self:Trim(playerName) ~= "" then
        return self:GetSpellBreakdownRowsForName(selectedMode, playerName)
    end

    local breakdown = self.meterState and self.meterState.breakdown or nil
    local source = nil
    local total = 0
    local rows = {}

    if selectedScope == "group" then
        if breakdown then
            if selectedMode == "healing" then
                source = breakdown.healingSpells
            else
                source = breakdown.damageSpells
            end
        end
    else
        return self:GetSpellBreakdownRowsForName(selectedMode, UnitName("player"))
    end

    for spellName, amount in pairs(source or {}) do
        local numeric = self:GetMeterSpellAmount(amount)
        if numeric > 0 then
            total = total + numeric
            rows[#rows + 1] = {
                spell = spellName,
                amount = numeric,
                hits = type(amount) == "table" and (tonumber(amount.totalhits) or 0) or 0,
                crits = type(amount) == "table" and (tonumber(amount.critical) or 0) or 0,
                min = type(amount) == "table" and tonumber(amount.min) or nil,
                max = type(amount) == "table" and tonumber(amount.max) or nil,
                overkill = type(amount) == "table" and (tonumber(amount.overkill) or 0) or 0,
                hit = type(amount) == "table" and (tonumber(amount.hit) or 0) or 0,
                hitamount = type(amount) == "table" and (tonumber(amount.hitamount) or 0) or 0,
                critical = type(amount) == "table" and (tonumber(amount.critical) or 0) or 0,
                criticalamount = type(amount) == "table" and (tonumber(amount.criticalamount) or 0) or 0,
            }
        end
    end

    table.sort(rows, function(left, right)
        if left.amount == right.amount then
            return string.lower(left.spell or "") < string.lower(right.spell or "")
        end
        return left.amount > right.amount
    end)

    return rows, total
end

function ClassForge:GetSpellBreakdownRowsForName(mode, playerName)
    local combat = self.meterState and self.meterState.combat or nil
    local normalized = self:NormalizePlayerName(playerName)
    if not combat or not normalized then
        return {}, 0
    end

    local entry
    if mode == "healing" then
        entry = combat.healing and combat.healing[normalized] or nil
    else
        entry = combat.damage and combat.damage[normalized] or nil
    end

    local total = 0
    local rows = {}
    for spellName, amount in pairs((entry and entry.spells) or {}) do
        local numeric = self:GetMeterSpellAmount(amount)
        if numeric > 0 then
            total = total + numeric
            rows[#rows + 1] = {
                spell = spellName,
                amount = numeric,
                hits = type(amount) == "table" and (tonumber(amount.totalhits) or 0) or 0,
                crits = type(amount) == "table" and (tonumber(amount.critical) or 0) or 0,
                min = type(amount) == "table" and tonumber(amount.min) or nil,
                max = type(amount) == "table" and tonumber(amount.max) or nil,
                overkill = type(amount) == "table" and (tonumber(amount.overkill) or 0) or 0,
                hit = type(amount) == "table" and (tonumber(amount.hit) or 0) or 0,
                hitamount = type(amount) == "table" and (tonumber(amount.hitamount) or 0) or 0,
                critical = type(amount) == "table" and (tonumber(amount.critical) or 0) or 0,
                criticalamount = type(amount) == "table" and (tonumber(amount.criticalamount) or 0) or 0,
                hitmin = type(amount) == "table" and tonumber(amount.hitmin) or nil,
                hitmax = type(amount) == "table" and tonumber(amount.hitmax) or nil,
                criticalmin = type(amount) == "table" and tonumber(amount.criticalmin) or nil,
                criticalmax = type(amount) == "table" and tonumber(amount.criticalmax) or nil,
            }
        end
    end

    table.sort(rows, function(left, right)
        if left.amount == right.amount then
            return string.lower(left.spell or "") < string.lower(right.spell or "")
        end
        return left.amount > right.amount
    end)

    return rows, total
end

function ClassForge:GetThreatBreakdownRows()
    local rows = {}
    local total = 0
    local threatByName = self:GetThreatTable()
    for normalized, percent in pairs(threatByName or {}) do
        local numeric = tonumber(percent) or 0
        if numeric > 0 then
            total = total + numeric
            rows[#rows + 1] = {
                spell = normalized,
                amount = numeric,
                isThreatRow = true,
            }
        end
    end

    table.sort(rows, function(left, right)
        if left.amount == right.amount then
            return string.lower(left.spell or "") < string.lower(right.spell or "")
        end
        return left.amount > right.amount
    end)

    return rows, total
end

function ClassForge:GetSpellBreakdownSummaryRows(mode, playerName)
    if mode == "threat" then
        local rows, total = self:GetThreatBreakdownRows()
        local summary = {}
        for index = 1, math.min(#rows, 8) do
            local row = rows[index]
            summary[#summary + 1] = {
                type = self:GetPlainMeterIdentityText(row.spell),
                min = "-",
                avg = "-",
                max = string.format("%.0f%%", row.amount or 0),
                count = tostring(index),
                percent = total > 0 and string.format("%.1f%%", ((row.amount or 0) / total) * 100) or "0.0%",
            }
        end
        return summary
    end

    local combat = self.meterState and self.meterState.combat or nil
    local normalized = self:NormalizePlayerName(playerName)
    local entry
    if mode == "healing" then
        entry = combat and combat.healing and normalized and combat.healing[normalized] or nil
    else
        entry = combat and combat.damage and normalized and combat.damage[normalized] or nil
    end

    local summary = {}
    local total = 0
    local buckets = {
        { key = "hit", label = "Hit", count = 0, amount = 0, min = nil, max = nil },
        { key = "critical", label = "Crit", count = 0, amount = 0, min = nil, max = nil },
    }

    for _, spellEntry in pairs((entry and entry.spells) or {}) do
        if type(spellEntry) == "table" then
            total = total + (tonumber(spellEntry.amount) or 0)
            local hitCount = tonumber(spellEntry.hit) or 0
            local critCount = tonumber(spellEntry.critical) or 0
            if hitCount > 0 then
                buckets[1].count = buckets[1].count + hitCount
                buckets[1].amount = buckets[1].amount + (tonumber(spellEntry.hitamount) or 0)
                local minValue = tonumber(spellEntry.hitmin) or tonumber(spellEntry.min) or nil
                local maxValue = tonumber(spellEntry.hitmax) or tonumber(spellEntry.max) or nil
                if minValue then
                    buckets[1].min = buckets[1].min and math.min(buckets[1].min, minValue) or minValue
                end
                if maxValue then
                    buckets[1].max = buckets[1].max and math.max(buckets[1].max, maxValue) or maxValue
                end
            end
            if critCount > 0 then
                buckets[2].count = buckets[2].count + critCount
                buckets[2].amount = buckets[2].amount + (tonumber(spellEntry.criticalamount) or 0)
                local minValue = tonumber(spellEntry.criticalmin) or tonumber(spellEntry.min) or nil
                local maxValue = tonumber(spellEntry.criticalmax) or tonumber(spellEntry.max) or nil
                if minValue then
                    buckets[2].min = buckets[2].min and math.min(buckets[2].min, minValue) or minValue
                end
                if maxValue then
                    buckets[2].max = buckets[2].max and math.max(buckets[2].max, maxValue) or maxValue
                end
            end
        end
    end

    for _, bucket in ipairs(buckets) do
        if bucket.count > 0 then
            summary[#summary + 1] = {
                type = bucket.label,
                min = bucket.min and tostring(math.floor(bucket.min + 0.5)) or "-",
                avg = bucket.count > 0 and tostring(math.floor((bucket.amount / bucket.count) + 0.5)) or "-",
                max = bucket.max and tostring(math.floor(bucket.max + 0.5)) or "-",
                count = tostring(bucket.count),
                percent = total > 0 and string.format("%.1f%%", (bucket.amount / total) * 100) or "0.0%",
            }
        end
    end

    return summary
end

function ClassForge:GetBreakdownPalette(index)
    local palette = {
        "ff6b6b",
        "ffd166",
        "7bd389",
        "4ecdc4",
        "5dade2",
        "a29bfe",
        "f78fb3",
        "95a5a6",
    }

    return palette[((index - 1) % #palette) + 1]
end

function ClassForge:GetBreakdownAngle(dx, dy)
    local angle = nil
    if math.atan2 then
        angle = math.deg(math.atan2(dy, dx))
    else
        if dx == 0 then
            angle = (dy >= 0) and 90 or 270
        else
            angle = math.deg(math.atan(dy / dx))
            if dx < 0 then
                angle = angle + 180
            elseif dy < 0 then
                angle = angle + 360
            end
        end
    end

    if angle < 0 then
        angle = angle + 360
    end

    return angle
end

function ClassForge:GetBreakdownSegmentAtAngle(frame, angle)
    local segments = frame and frame.chartSegments or nil
    if not segments then
        return nil
    end

    for _, segment in ipairs(segments) do
        if angle >= segment.startAngle and angle < segment.endAngle then
            return segment
        end
    end

    return segments[#segments]
end

function ClassForge:UpdateSpellBreakdownTooltip(frame)
    if not frame or not frame:IsShown() or not frame.chartSegments or #frame.chartSegments == 0 then
        GameTooltip:Hide()
        return
    end

    local cursorX, cursorY = GetCursorPosition()
    local scale = frame.chartBackdrop:GetEffectiveScale() or 1
    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local left = frame.chartBackdrop:GetLeft()
    local bottom = frame.chartBackdrop:GetBottom()
    local width = frame.chartBackdrop:GetWidth()
    local height = frame.chartBackdrop:GetHeight()
    if not left or not bottom or not width or not height then
        GameTooltip:Hide()
        return
    end

    local centerX = left + (width / 2)
    local centerY = bottom + (height / 2)
    local dx = cursorX - centerX
    local dy = cursorY - centerY
    local distance = math.sqrt((dx * dx) + (dy * dy))
    local radius = math.min(width, height) / 2
    if distance > radius then
        GameTooltip:Hide()
        return
    end

    local angle = self:GetBreakdownAngle(dx, dy)
    local segment = self:GetBreakdownSegmentAtAngle(frame, angle)
    if not segment then
        GameTooltip:Hide()
        return
    end

    GameTooltip:SetOwner(frame.chartBackdrop, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(segment.spell or self:L("unknown"))
    GameTooltip:AddDoubleLine(self:L("meter_contribution"), string.format("%d (%.1f%%)", segment.amount or 0, segment.percent or 0), 1, 1, 1, 1, 1, 1)
    if segment.hits and segment.hits > 0 then
        GameTooltip:AddDoubleLine(self:L("hits"), tostring(segment.hits), 0.85, 0.85, 0.85, 1, 1, 1)
    end
    if segment.crits and segment.crits > 0 then
        GameTooltip:AddDoubleLine(self:L("crits"), tostring(segment.crits), 0.85, 0.85, 0.85, 1, 1, 1)
    end
    if segment.min then
        GameTooltip:AddDoubleLine(self:L("min"), tostring(segment.min), 0.85, 0.85, 0.85, 1, 1, 1)
    end
    if segment.max then
        GameTooltip:AddDoubleLine(self:L("max"), tostring(segment.max), 0.85, 0.85, 0.85, 1, 1, 1)
    end
    if frame.selectedSpell and frame.selectedSpell == segment.spell then
        GameTooltip:AddLine(self:L("meter_filter_clear"), 0.6, 0.85, 1)
    else
        GameTooltip:AddLine(self:L("meter_click_segment"), 0.6, 0.85, 1)
    end
    GameTooltip:Show()
end

function ClassForge:AcquireSpellBreakdownRow(index)
    local frame = self.spellBreakdownFrame
    frame.spellRows = frame.spellRows or {}
    if frame.spellRows[index] then
        return frame.spellRows[index]
    end

    local row = CreateFrame("Button", nil, frame.listContent)
    row:SetHeight(18)
    row.columns = {}
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.background:SetVertexColor(1, 1, 1, 0.03)

    local left = 0
    for columnIndex, column in ipairs(frame.spellColumns or {}) do
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", row, "TOPLEFT", left, -1)
        text:SetWidth(column.width)
        text:SetJustifyH(column.justify or "LEFT")
        text:SetJustifyV("MIDDLE")
        if text.SetWordWrap then text:SetWordWrap(false) end
        if text.SetMaxLines then text:SetMaxLines(1) end
        row.columns[columnIndex] = text
        left = left + column.width + 8
    end

    row:SetScript("OnClick", function(selfRow)
        local spell = selfRow.spellName
        if not spell then
            return
        end
        if frame.selectedSpell == spell then
            frame.selectedSpell = nil
        else
            frame.selectedSpell = spell
        end
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.spellRows[index] = row
    return row
end

function ClassForge:AcquireSpellBreakdownSummaryRow(index)
    local frame = self.spellBreakdownFrame
    frame.summaryRows = frame.summaryRows or {}
    if frame.summaryRows[index] then
        return frame.summaryRows[index]
    end

    local row = CreateFrame("Frame", nil, frame.summaryContent)
    row:SetHeight(18)
    row.columns = {}
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.background:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.background:SetVertexColor(1, 1, 1, 0.02)

    local left = 0
    for columnIndex, column in ipairs(frame.summaryColumns or {}) do
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", row, "TOPLEFT", left, -1)
        text:SetWidth(column.width)
        text:SetJustifyH(column.justify or "LEFT")
        text:SetJustifyV("MIDDLE")
        if text.SetWordWrap then text:SetWordWrap(false) end
        if text.SetMaxLines then text:SetMaxLines(1) end
        row.columns[columnIndex] = text
        left = left + column.width + 8
    end

    frame.summaryRows[index] = row
    return row
end

function ClassForge:CreateSpellBreakdownWindow()
    if self.spellBreakdownFrame then
        return
    end

    local frame = CreateFrame("Frame", "ClassForgeSpellBreakdownFrame", UIParent)
    frame:SetWidth(620)
    frame:SetHeight(420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(20)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.92)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetScript("OnDragStart", function(selfFrame)
        if IsShiftKeyDown() then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
    end)
    frame:Hide()
    frame.mode = "damage"
    frame.scope = "personal"
    frame.selectedName = UnitName("player")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 12, -10)

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -4)
    frame.subtitle:SetWidth(400)
    frame.subtitle:SetJustifyH("LEFT")

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", -4, -4)

    frame.damageButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.damageButton:SetWidth(90)
    frame.damageButton:SetHeight(20)
    frame.damageButton:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
    frame.damageButton:SetScript("OnClick", function()
        frame.mode = "damage"
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.healingButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.healingButton:SetWidth(90)
    frame.healingButton:SetHeight(20)
    frame.healingButton:SetPoint("LEFT", frame.damageButton, "RIGHT", 6, 0)
    frame.healingButton:SetScript("OnClick", function()
        frame.mode = "healing"
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.threatButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.threatButton:SetWidth(90)
    frame.threatButton:SetHeight(20)
    frame.threatButton:SetPoint("LEFT", frame.healingButton, "RIGHT", 6, 0)
    frame.threatButton:SetScript("OnClick", function()
        frame.mode = "threat"
        frame.selectedSpell = nil
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.personalButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.personalButton:SetWidth(70)
    frame.personalButton:SetHeight(20)
    frame.personalButton:SetPoint("LEFT", frame.threatButton, "RIGHT", 12, 0)
    frame.personalButton:SetScript("OnClick", function()
        frame.scope = "personal"
        frame.selectedSpell = nil
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.groupButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.groupButton:SetWidth(70)
    frame.groupButton:SetHeight(20)
    frame.groupButton:SetPoint("LEFT", frame.personalButton, "RIGHT", 6, 0)
    frame.groupButton:SetScript("OnClick", function()
        frame.scope = "group"
        frame.selectedSpell = nil
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.chartBackdrop = CreateFrame("Frame", nil, frame)
    frame.chartBackdrop:SetWidth(190)
    frame.chartBackdrop:SetHeight(190)
    frame.chartBackdrop:SetPoint("TOPLEFT", frame.damageButton, "BOTTOMLEFT", 0, -16)
    frame.chartBackdrop:EnableMouse(true)
    frame.chartBackdrop:SetScript("OnEnter", function()
        ClassForge:UpdateSpellBreakdownTooltip(frame)
    end)
    frame.chartBackdrop:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frame.chartBackdrop:SetScript("OnUpdate", function()
        ClassForge:UpdateSpellBreakdownTooltip(frame)
    end)
    frame.chartBackdrop:SetScript("OnMouseDown", function()
        local cursorX, cursorY = GetCursorPosition()
        local scale = frame.chartBackdrop:GetEffectiveScale() or 1
        cursorX = cursorX / scale
        cursorY = cursorY / scale
        local left = frame.chartBackdrop:GetLeft()
        local bottom = frame.chartBackdrop:GetBottom()
        local width = frame.chartBackdrop:GetWidth()
        local height = frame.chartBackdrop:GetHeight()
        if not left or not bottom or not width or not height then
            return
        end

        local centerX = left + (width / 2)
        local centerY = bottom + (height / 2)
        local angle = ClassForge:GetBreakdownAngle(cursorX - centerX, cursorY - centerY)
        local segment = ClassForge:GetBreakdownSegmentAtAngle(frame, angle)
        if not segment then
            return
        end

        if frame.selectedSpell == segment.spell then
            frame.selectedSpell = nil
        else
            frame.selectedSpell = segment.spell
        end
        ClassForge:UpdateSpellBreakdownWindow()
    end)

    frame.chartRing = frame.chartBackdrop:CreateTexture(nil, "BACKGROUND")
    frame.chartRing:SetTexture("Interface\\Buttons\\WHITE8X8")
    frame.chartRing:SetVertexColor(0.08, 0.08, 0.08, 0.9)
    frame.chartRing:SetAllPoints(frame.chartBackdrop)

    frame.chartPixels = {}
    for index = 1, 2500 do
        local pixel = frame.chartBackdrop:CreateTexture(nil, "ARTWORK")
        pixel:SetTexture("Interface\\Buttons\\WHITE8X8")
        pixel:SetWidth(4)
        pixel:SetHeight(4)
        pixel:Hide()
        frame.chartPixels[#frame.chartPixels + 1] = pixel
    end
    frame.chartSegments = {}

    frame.totalText = frame.chartBackdrop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.totalText:SetPoint("CENTER", frame.chartBackdrop, "CENTER", 0, 0)
    frame.totalText:SetWidth(120)
    frame.totalText:SetJustifyH("CENTER")

    frame.spellHeader = CreateFrame("Frame", nil, frame)
    frame.spellHeader:SetHeight(18)
    frame.spellHeader:SetPoint("TOPLEFT", frame.chartBackdrop, "TOPRIGHT", 18, 0)
    frame.spellHeader:SetPoint("TOPRIGHT", -30, 0)
    frame.spellHeader.columns = {}

    local spellColumns = {
        { key = "rank", label = "#", width = 18, justify = "LEFT" },
        { key = "spell", label = "Spell", width = 170, justify = "LEFT" },
        { key = "amount", label = "Total", width = 62, justify = "RIGHT" },
        { key = "percent", label = "%", width = 48, justify = "RIGHT" },
    }
    frame.spellColumns = spellColumns
    local left = 0
    for index, column in ipairs(spellColumns) do
        local header = frame.spellHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", frame.spellHeader, "TOPLEFT", left, 0)
        header:SetWidth(column.width)
        header:SetJustifyH(column.justify)
        header:SetText(column.label)
        header.columnIndex = index
        frame.spellHeader.columns[#frame.spellHeader.columns + 1] = header
        left = left + column.width + 8
    end

    frame.listScroll = CreateFrame("ScrollFrame", "ClassForgeSpellBreakdownScroll", frame, "UIPanelScrollFrameTemplate")
    frame.listScroll:SetPoint("TOPLEFT", frame.spellHeader, "BOTTOMLEFT", 0, -6)
    frame.listScroll:SetPoint("BOTTOMRIGHT", -28, 150)

    frame.listContent = CreateFrame("Frame", nil, frame.listScroll)
    frame.listContent:SetWidth(320)
    frame.listContent:SetHeight(220)
    frame.listScroll:SetScrollChild(frame.listContent)
    frame.spellRows = {}

    frame.summaryTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.summaryTitle:SetPoint("TOPLEFT", frame.chartBackdrop, "BOTTOMLEFT", 0, -14)
    frame.summaryTitle:SetText("Type")

    frame.summaryHeader = CreateFrame("Frame", nil, frame)
    frame.summaryHeader:SetHeight(18)
    frame.summaryHeader:SetPoint("TOPLEFT", frame.summaryTitle, "BOTTOMLEFT", 0, -4)
    frame.summaryHeader:SetPoint("TOPRIGHT", -30, -1)
    frame.summaryHeader.columns = {}
    local summaryColumns = {
        { key = "type", label = "Type", width = 80, justify = "LEFT" },
        { key = "min", label = "Min", width = 60, justify = "RIGHT" },
        { key = "avg", label = "Avg", width = 60, justify = "RIGHT" },
        { key = "max", label = "Max", width = 60, justify = "RIGHT" },
        { key = "count", label = "Count", width = 60, justify = "RIGHT" },
        { key = "percent", label = "%", width = 48, justify = "RIGHT" },
    }
    frame.summaryColumns = summaryColumns
    left = 0
    for index, column in ipairs(summaryColumns) do
        local header = frame.summaryHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", frame.summaryHeader, "TOPLEFT", left, 0)
        header:SetWidth(column.width)
        header:SetJustifyH(column.justify)
        header:SetText(column.label)
        header.columnIndex = index
        frame.summaryHeader.columns[#frame.summaryHeader.columns + 1] = header
        left = left + column.width + 8
    end

    frame.summaryContent = CreateFrame("Frame", nil, frame)
    frame.summaryContent:SetPoint("TOPLEFT", frame.summaryHeader, "BOTTOMLEFT", 0, -6)
    frame.summaryContent:SetPoint("BOTTOMRIGHT", -30, 16)
    frame.summaryRows = {}

    self.spellBreakdownFrame = frame
end

function ClassForge:ToggleSpellBreakdownWindow()
    self:CreateSpellBreakdownWindow()
    if not self.spellBreakdownFrame then
        return
    end

    if self.spellBreakdownFrame:IsShown() then
        self.spellBreakdownFrame:Hide()
    else
        self.spellBreakdownFrame:Show()
        self:UpdateSpellBreakdownWindow()
    end
end

function ClassForge:UpdateSpellBreakdownWindow()
    local frame = self.spellBreakdownFrame
    if not frame or not frame:IsShown() then
        return
    end

    local mode = frame.mode or "damage"
    local scope = frame.scope or "personal"
    local selectedName = self:NormalizePlayerName(frame.selectedName or UnitName("player")) or UnitName("player")
    local useNamedBreakdown = (mode ~= "threat") and scope ~= "group" and selectedName and selectedName ~= ""
    local spells, total = self:GetSpellBreakdownData(mode, scope, useNamedBreakdown and selectedName or nil)
    local summaryRows = self:GetSpellBreakdownSummaryRows(mode, selectedName)
    frame.title:SetText(self:L("meter_breakdown"))
    frame.subtitle:SetText(useNamedBreakdown and ("Player: " .. self:GetPlainMeterIdentityText(selectedName)) or (mode == "threat" and "Target Threat Table" or self:L("meter_group")))
    frame.damageButton:SetText(self:L("meter_damage_spells"))
    frame.healingButton:SetText(self:L("meter_healing_spells"))
    frame.threatButton:SetText(self:L("threat_leader"))
    frame.personalButton:SetText(self:L("meter_personal"))
    frame.groupButton:SetText(self:L("meter_group"))
    frame.damageButton:SetEnabled(mode ~= "damage")
    frame.healingButton:SetEnabled(mode ~= "healing")
    frame.threatButton:SetEnabled(mode ~= "threat")
    frame.personalButton:SetEnabled(scope ~= "personal")
    frame.groupButton:SetEnabled(scope ~= "group")
    frame.totalText:SetText(string.format("%s\n%s", self:L(mode == "healing" and "meter_healing_spells" or (mode == "threat" and "threat_leader" or "meter_damage_spells")), mode == "threat" and string.format("%.0f%%", total or 0) or tostring(total or 0)))

    frame.chartSegments = {}
    if not spells or #spells == 0 or total <= 0 then
        for _, pixel in ipairs(frame.chartPixels) do
            pixel:Hide()
        end
        GameTooltip:Hide()
        if frame.listScroll then
            frame.listScroll:Hide()
        end
        for _, row in ipairs(frame.spellRows or {}) do
            row:Hide()
        end
        for _, row in ipairs(frame.summaryRows or {}) do
            row:Hide()
        end
    else
        if frame.listScroll then
            frame.listScroll:Show()
        end
        local selectedSpell = frame.selectedSpell
        if selectedSpell and selectedSpell ~= "" then
            local filtered = {}
            for _, entry in ipairs(spells) do
                if entry.spell == selectedSpell then
                    filtered[#filtered + 1] = entry
                    break
                end
            end
            if #filtered == 0 then
                frame.selectedSpell = nil
            end
        end

        local currentAngle = 0
        local visibleSpellRows = 0
        for index, entry in ipairs(spells) do
            local percent = (entry.amount / total) * 100
            local colorHex = self:GetBreakdownPalette(index)
            if not frame.selectedSpell or frame.selectedSpell == entry.spell then
                visibleSpellRows = visibleSpellRows + 1
                local row = self:AcquireSpellBreakdownRow(visibleSpellRows)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", frame.listContent, "TOPLEFT", 0, -((visibleSpellRows - 1) * 18))
                row:SetPoint("TOPRIGHT", frame.listContent, "TOPRIGHT", 0, -((visibleSpellRows - 1) * 18))
                row.spellName = entry.spell
                row.background:SetVertexColor(1, 1, 1, (visibleSpellRows % 2 == 0) and 0.035 or 0.015)
                row.columns[1]:SetText(tostring(index))
                row.columns[2]:SetText(string.format("%s|cff%s%s|r", self:GetSpellIconMarkup(entry.spell, 12), colorHex, self:SanitizeMeterInlineText(mode == "threat" and self:GetPlainMeterIdentityText(entry.spell) or entry.spell)))
                row.columns[3]:SetText(mode == "threat" and string.format("%.0f%%", entry.amount or 0) or tostring(entry.amount or 0))
                row.columns[4]:SetText(string.format("%.1f%%", percent))
                row:Show()
            end

            local startAngle = currentAngle
            local spanAngle = (entry.amount / total) * 360
            local endAngle = startAngle + spanAngle
            frame.chartSegments[#frame.chartSegments + 1] = {
                spell = entry.spell,
                amount = entry.amount,
                percent = percent,
                hits = entry.hits,
                crits = entry.crits,
                min = entry.min,
                max = entry.max,
                colorHex = colorHex,
                startAngle = startAngle,
                endAngle = endAngle,
            }
            currentAngle = endAngle
        end

        for rowIndex = visibleSpellRows + 1, #(frame.spellRows or {}) do
            frame.spellRows[rowIndex]:Hide()
        end
        frame.listContent:SetHeight(math.max(220, (visibleSpellRows * 18) + 4))

        local radius = math.floor((math.min(frame.chartBackdrop:GetWidth(), frame.chartBackdrop:GetHeight()) / 2) - 2)
        local step = 4
        local usedPixels = 0
        for x = -radius, radius, step do
            for y = -radius, radius, step do
                if ((x * x) + (y * y)) <= (radius * radius) then
                    usedPixels = usedPixels + 1
                    local pixel = frame.chartPixels[usedPixels]
                    if not pixel then
                        break
                    end

                    local angle = self:GetBreakdownAngle(x, y)
                    local segment = self:GetBreakdownSegmentAtAngle(frame, angle)
                    if segment then
                        local colorHex = segment.colorHex or "808080"
                        local red, green, blue = self:HexToRGB(colorHex)
                        pixel:ClearAllPoints()
                        pixel:SetPoint("CENTER", frame.chartBackdrop, "CENTER", x, y)
                        pixel:SetVertexColor(red, green, blue)
                        pixel:Show()
                    else
                        pixel:Hide()
                    end
                end
            end
        end

        for pixelIndex = usedPixels + 1, #frame.chartPixels do
            frame.chartPixels[pixelIndex]:Hide()
        end
    end

    local visibleSummaryRows = 0
    frame.summaryTitle:SetText(mode == "threat" and "Threat Breakdown" or "Hit Breakdown")
    for index, rowData in ipairs(summaryRows or {}) do
        visibleSummaryRows = visibleSummaryRows + 1
        local row = self:AcquireSpellBreakdownSummaryRow(visibleSummaryRows)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.summaryContent, "TOPLEFT", 0, -((visibleSummaryRows - 1) * 18))
        row:SetPoint("TOPRIGHT", frame.summaryContent, "TOPRIGHT", 0, -((visibleSummaryRows - 1) * 18))
        row.background:SetVertexColor(1, 1, 1, (visibleSummaryRows % 2 == 0) and 0.03 or 0.015)
        row.columns[1]:SetText(rowData.type or "-")
        row.columns[2]:SetText(rowData.min or "-")
        row.columns[3]:SetText(rowData.avg or "-")
        row.columns[4]:SetText(rowData.max or "-")
        row.columns[5]:SetText(rowData.count or "-")
        row.columns[6]:SetText(rowData.percent or "-")
        row:Show()
    end
    for rowIndex = visibleSummaryRows + 1, #(frame.summaryRows or {}) do
        frame.summaryRows[rowIndex]:Hide()
    end
end

function ClassForge:ExportMeterToChat()
    if not SendChatMessage then
        return
    end

    local lines = self:BuildMeterExportLines()
    if not lines then
        self:Print(self:L("meter_waiting"))
        return
    end

    local exportType = self:GetMeterExportType()
    local channelName = self:GetMeterExportChannel()

    if exportType == "CHANNEL" then
        local channelId = GetChannelName and GetChannelName(channelName) or 0
        if not channelId or channelId == 0 then
            self:Print("Channel not found: " .. channelName)
            return
        end
        for _, line in ipairs(lines) do
            SendChatMessage(line, "CHANNEL", nil, channelId)
        end
        return
    end

    for _, line in ipairs(lines) do
        SendChatMessage(line, exportType)
    end
end

function ClassForge:CreateMeterPanel()
    if self.meterPanel then
        return
    end

    local function setButtonTooltip(button, text)
        button.tooltipText = text
        button:SetScript("OnEnter", function(selfButton)
            if not selfButton.tooltipText then
                return
            end
            GameTooltip:SetOwner(selfButton, "ANCHOR_RIGHT")
            GameTooltip:SetText(selfButton.tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    local function applyIcon(button, texturePath)
        button.icon = button.icon or button:CreateTexture(nil, "ARTWORK")
        button.icon:SetAllPoints(button)
        button.icon:SetTexture(texturePath)
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    local frame = CreateFrame("Frame", "ClassForgeMeterPanel", UIParent)
    frame:SetMinResize(420, 140)
    frame:SetMaxResize(1800, 1200)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:EnableMouse(true)
    frame:RegisterForDrag()
    frame:SetMovable(false)
    frame:SetResizable(true)
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame, width, height)
        ClassForge:UpdateMeterTableLayout()
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 10, -10)
    frame.title:SetText("ClassForge")

    frame.viewButtons = {}
    local viewOrder = {
        { key = "dps", label = "meter_view_dps", icon = "Interface\\Icons\\Ability_Rogue_SliceDice" },
        { key = "threat", label = "meter_view_threat", icon = "Interface\\Icons\\Ability_Defend" },
        { key = "healing_done", label = "meter_view_healing_done", icon = "Interface\\Icons\\Spell_Holy_HolyBolt" },
        { key = "healing_received", label = "meter_view_healing_received", icon = "Interface\\Icons\\INV_Misc_Bandage_15" },
    }
    local previousButton
    for _, viewData in ipairs(viewOrder) do
        local button = CreateFrame("Button", nil, frame)
        button:SetWidth(20)
        button:SetHeight(20)
        button.viewKey = viewData.key
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 3, 0)
        else
            button:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
        end
        applyIcon(button, viewData.icon)
        button:SetScript("OnClick", function(selfButton)
            ClassForge:SetMeterView(selfButton.viewKey)
        end)
        button.labelKey = viewData.label
        setButtonTooltip(button, self:L(viewData.label))
        frame.viewButtons[#frame.viewButtons + 1] = button
        previousButton = button
    end

    frame.resetButton = CreateFrame("Button", nil, frame)
    frame.resetButton:SetWidth(20)
    frame.resetButton:SetHeight(20)
    frame.resetButton:SetPoint("TOPRIGHT", -8, -8)
    applyIcon(frame.resetButton, "Interface\\Buttons\\UI-RotationLeft-Button-Up")
    frame.resetButton:SetScript("OnClick", function()
        ClassForge:ResetMeterData()
    end)
    setButtonTooltip(frame.resetButton, self:L("reset_meter_data"))

    frame.exportButton = CreateFrame("Button", nil, frame)
    frame.exportButton:SetWidth(20)
    frame.exportButton:SetHeight(20)
    frame.exportButton:SetPoint("RIGHT", frame.resetButton, "LEFT", -6, 0)
    applyIcon(frame.exportButton, "Interface\\Buttons\\UI-GuildButton-MOTD-Up")
    frame.exportButton:SetScript("OnClick", function()
        ClassForge:ExportMeterToChat()
    end)
    setButtonTooltip(frame.exportButton, self:L("meter_export"))

    frame.breakdownButton = CreateFrame("Button", nil, frame)
    frame.breakdownButton:SetWidth(20)
    frame.breakdownButton:SetHeight(20)
    frame.breakdownButton:SetPoint("RIGHT", frame.exportButton, "LEFT", -6, 0)
    applyIcon(frame.breakdownButton, "Interface\\Icons\\INV_Misc_Note_05")
    frame.breakdownButton:SetScript("OnClick", function()
        ClassForge:ToggleSpellBreakdownWindow()
    end)
    setButtonTooltip(frame.breakdownButton, self:L("meter_breakdown"))

    frame.modeButton = CreateFrame("Button", nil, frame)
    frame.modeButton:SetWidth(20)
    frame.modeButton:SetHeight(20)
    frame.modeButton:SetPoint("RIGHT", frame.breakdownButton, "LEFT", -6, 0)
    applyIcon(frame.modeButton, self:IsMeterPersistent() and "Interface\\Icons\\INV_Misc_PocketWatch_01" or "Interface\\Icons\\Ability_Rogue_Sprint")
    frame.modeButton:SetScript("OnClick", function()
        ClassForge:SetMeterPersistent(not ClassForge:IsMeterPersistent())
    end)
    setButtonTooltip(frame.modeButton, self:L("meter_mode_toggle"))

    frame.hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hintText:SetPoint("RIGHT", frame.modeButton, "LEFT", -8, 0)
    frame.hintText:SetText(self:IsMeterLocked() and self:L("locked") or self:L("meter_hint"))

    frame.header = CreateFrame("Frame", nil, frame)
    frame.header:SetHeight(18)
    frame.header:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -34)
    frame.header.columns = {}

    for columnIndex, column in ipairs(self:GetMeterColumnDefinitions()) do
        local text = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetText(column.label)
        text.columnIndex = columnIndex
        frame.header.columns[#frame.header.columns + 1] = text
    end

    frame.emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.emptyText:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
    frame.emptyText:SetWidth(476)
    frame.emptyText:SetJustifyH("LEFT")
    frame.emptyText:SetJustifyV("TOP")

    frame.scrollFrame = CreateFrame("ScrollFrame", "ClassForgeMeterScrollFrame", frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -8)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetWidth(482)
    frame.scrollChild:SetHeight(120)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)
    frame.rows = {}

    frame.resizeHandle = CreateFrame("Button", nil, frame)
    frame.resizeHandle:SetWidth(18)
    frame.resizeHandle:SetHeight(18)
    frame.resizeHandle:SetPoint("BOTTOMRIGHT", -6, 6)
    frame.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.resizeHandle:SetScript("OnMouseDown", function()
        if not ClassForge:IsMeterLocked() then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.resizeHandle:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        ClassForge:SaveMeterSize()
        ClassForge:UpdateMeterPanel()
    end)

    if not self.meterTicker then
        self.meterTicker = CreateFrame("Frame", nil, UIParent)
        self.meterTicker.elapsed = 0
        self.meterTicker:SetScript("OnUpdate", function(_, elapsed)
            if not ClassForge:IsMeterEnabled() then
                return
            end

            local combat = ClassForge.meterState and ClassForge.meterState.combat or nil
            if not combat or not combat.active then
                return
            end

            ClassForge.meterTicker.elapsed = ClassForge.meterTicker.elapsed + elapsed
            if ClassForge.meterTicker.elapsed >= 0.1 then
                ClassForge.meterTicker.elapsed = 0
                if ClassForge.ProcessPendingSpellDamage then
                    ClassForge:ProcessPendingSpellDamage("target")
                end
                ClassForge:UpdateMeterPanel()
            end
        end)
    end

    self.meterPanel = frame
    self:ApplyMeterPosition()
    self:ApplyMeterSize()
    self:UpdateMeterTableLayout()
    self:UpdateMeterPanel()
end

function ClassForge:UpdateMeterPanel()
    if not self.meterPanel then
        return
    end

    if not self:IsMeterEnabled() then
        self.meterPanel:Hide()
        return
    end

    self.meterPanel.title:SetText("DragonUI-CF Meter")
    if self.meterPanel.viewButtons then
        local activeView = self:GetMeterSortMode()
        for _, button in ipairs(self.meterPanel.viewButtons) do
            button.tooltipText = self:GetMeterViewTooltip(button.viewKey)
            if button.viewKey == activeView then
                button:SetAlpha(1)
            else
                button:SetAlpha(0.6)
            end
        end
    end
    if self.meterPanel.exportButton then
        self.meterPanel.exportButton.tooltipText = self:L("meter_export")
    end
    if self.meterPanel.breakdownButton then
        self.meterPanel.breakdownButton.tooltipText = self:L("meter_breakdown")
    end
    if self.meterPanel.modeButton then
        self.meterPanel.modeButton.tooltipText = self:L("meter_mode_toggle") .. ": " .. self:L(self:IsMeterPersistent() and "meter_mode_session" or "meter_mode_segment")
        self.meterPanel.modeButton.icon:SetTexture(self:IsMeterPersistent() and "Interface\\Icons\\INV_Misc_PocketWatch_01" or "Interface\\Icons\\Ability_Rogue_Sprint")
    end
    if self.meterPanel.resetButton then
        self.meterPanel.resetButton.tooltipText = self:L("reset_meter_data")
    end
    self.meterPanel.hintText:SetText(self:IsMeterLocked() and self:L("locked") or self:L("meter_hint"))

    local rows, duration = self:GetMeterRows(self:GetMeterSortMode())
    self:UpdateMeterTableLayout()
    local activeColumnKey = self:GetMeterSortColumnKey(self:GetMeterSortMode())
    local headerColumns = self:GetMeterColumnDefinitions()
    for index, fontString in ipairs(self.meterPanel.header.columns or {}) do
        local column = headerColumns[index]
        if column and column.key == activeColumnKey then
            fontString:SetTextColor(1.0, 0.82, 0.2)
        else
            fontString:SetTextColor(1, 1, 1)
        end
    end

    if not rows or #rows == 0 then
        self.meterPanel.emptyText:SetText(self:L("meter_waiting"))
        self.meterPanel.emptyText:Show()
        self.meterPanel.scrollFrame:Hide()
        for _, rowFrame in ipairs(self.meterPanel.rows or {}) do
            rowFrame:Hide()
        end
    else
        local rowHeight = 18
        self.meterPanel.emptyText:Hide()
        self.meterPanel.scrollFrame:Show()

        for index, row in ipairs(rows) do
            local rowFrame = self:AcquireMeterRow(index)
            rowFrame:ClearAllPoints()
            rowFrame:SetPoint("TOPLEFT", self.meterPanel.scrollChild, "TOPLEFT", 0, -((index - 1) * rowHeight))
            rowFrame:SetPoint("TOPRIGHT", self.meterPanel.scrollChild, "TOPRIGHT", 0, -((index - 1) * rowHeight))
            rowFrame:Show()
            rowFrame.rowName = row.name
            rowFrame.background:SetVertexColor(1, 1, 1, (index % 2 == 0) and 0.04 or 0.015)
            rowFrame:SetScript("OnMouseUp", function(selfRow)
                ClassForge:CreateSpellBreakdownWindow()
                if not ClassForge.spellBreakdownFrame then
                    return
                end
                ClassForge.spellBreakdownFrame.selectedName = selfRow.rowName
                local currentView = ClassForge:GetMeterSortMode()
                if currentView == "healing_done" then
                    ClassForge.spellBreakdownFrame.mode = "healing"
                elseif currentView == "threat" then
                    ClassForge.spellBreakdownFrame.mode = "threat"
                else
                    ClassForge.spellBreakdownFrame.mode = "damage"
                end
                ClassForge.spellBreakdownFrame.scope = "personal"
                ClassForge.spellBreakdownFrame.selectedSpell = nil
                ClassForge.spellBreakdownFrame:Show()
                ClassForge:UpdateSpellBreakdownWindow()
            end)

            local colorHex = self:GetMeterRowColor(index, #rows)
            for columnIndex, fontString in ipairs(rowFrame.columns) do
                local column = self:GetMeterColumnDefinitions()[columnIndex]
                local value = self:FormatMeterCellValue(column.key, row, duration, false)
                if column.key == "name" then
                    fontString:SetText(value)
                else
                    fontString:SetText(string.format("|cff%s%s|r", colorHex, value))
                end
            end
        end

        for index = #rows + 1, #(self.meterPanel.rows or {}) do
            self.meterPanel.rows[index]:Hide()
        end

        if self.meterPanel.scrollChild and self.meterPanel.scrollFrame then
            local visibleHeight = math.max(20, self.meterPanel.scrollFrame:GetHeight() - 4)
            local contentHeight = (#rows * rowHeight) + 4
            self.meterPanel.scrollChild:SetHeight(math.max(visibleHeight, contentHeight))
        end
    end
    self.meterPanel:Show()
    self:UpdateSpellBreakdownWindow()
end

function ClassForge:IsChatDecorationEnabled()
    local profile = self:GetProfile()
    local chat = profile and profile.chat or nil

    if chat and chat.enabled ~= nil then
        return chat.enabled and true or false
    end

    return self.defaults.profile.chat.enabled and true or false
end

function ClassForge:IsTargetProfileHidden()
    local profile = self:GetProfile()
    local targetProfile = profile and profile.targetProfile or nil

    if targetProfile and targetProfile.hidden ~= nil then
        return targetProfile.hidden and true or false
    end

    return self.defaults.profile.targetProfile.hidden and true or false
end

function ClassForge:IsTargetProfileLocked()
    local profile = self:GetProfile()
    local targetProfile = profile and profile.targetProfile or nil

    if targetProfile and targetProfile.locked ~= nil then
        return targetProfile.locked and true or false
    end

    return self.defaults.profile.targetProfile.locked and true or false
end

function ClassForge:SetTargetProfileHidden(hidden)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.hidden = hidden and true or false

    if hidden and self.targetProfile then
        self.targetProfile:Hide()
    else
        self:UpdateTargetProfile()
    end
end

function ClassForge:SetTargetProfileLocked(locked)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.locked = locked and true or false

    if self.targetProfile and self.targetProfile.hintText then
        self.targetProfile.hintText:SetText(locked and self:L("locked") or self:L("shift_drag"))
    end
end

function ClassForge:SetTargetProfileCompact(compact)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.compact = compact and true or false

    if self.targetProfile then
        self:UpdateTargetProfileLayout()
        self:UpdateTargetProfile()
    end
end

function ClassForge:SetChatDecorationEnabled(enabled)
    ClassForgeDB.profile.chat = ClassForgeDB.profile.chat or {}
    ClassForgeDB.profile.chat.enabled = enabled and true or false
end

function ClassForge:DecorateChatMessage(_, _, message, sender, ...)
    if not ClassForge:IsChatDecorationEnabled() or not sender or not message then
        return false, message, sender, ...
    end

    local data = ClassForge:GetDataForName(sender)
    if not ClassForge:IsConfirmedAddonUser(data) then
        return false, message, sender, ...
    end

    if string.find(message, "|Hplayer:") and string.find(message, "%[|cff") then
        return false, message, sender, ...
    end

    local prefix = "[" .. ClassForge:GetColoredClassText(data) .. "] "
    return false, prefix .. message, sender, ...
end

function ClassForge:SetupChatDecorators()
    if self.chatDecoratorsHooked or not ChatFrame_AddMessageEventFilter then
        return
    end

    self.chatDecoratorsHooked = true

    local events = {
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_WHISPER",
    }

    for _, eventName in ipairs(events) do
        ChatFrame_AddMessageEventFilter(eventName, function(...)
            return ClassForge:DecorateChatMessage(...)
        end)
    end
end

function ClassForge:GetDataStatusText(data)
    if not data then
        return self:L("unknown")
    end

    local parts = {
        self:L("source_label") .. ": |cffffffff" .. self:GetSourceLabel(data) .. "|r",
        self:L("updated_label") .. ": " .. self:FormatUpdatedTimeColored(data.updated),
    }

    if data.addonVersion and data.addonVersion ~= "" then
        parts[#parts + 1] = self:L("version_label") .. ": |cffffffff" .. data.addonVersion .. "|r"
    end

    return table.concat(parts, " |cff808080-|r ")
end

function ClassForge:GetMinimapButtonAngle()
    local profile = self:GetProfile()
    local minimapButton = profile and profile.minimapButton or nil
    local defaults = self.defaults.profile.minimapButton

    return tonumber(minimapButton and minimapButton.angle) or defaults.angle
end

function ClassForge:IsMinimapButtonHidden()
    local profile = self:GetProfile()
    local minimapButton = profile and profile.minimapButton or nil
    local defaults = self.defaults.profile.minimapButton

    if minimapButton and minimapButton.hidden ~= nil then
        return minimapButton.hidden and true or false
    end

    return defaults.hidden and true or false
end

function ClassForge:SetMinimapButtonAngle(angle)
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.angle = angle
end

function ClassForge:SetMinimapButtonHidden(hidden)
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.hidden = hidden and true or false

    if not self.minimapButton then
        return
    end

    if hidden then
        self.minimapButton:Hide()
    else
        self.minimapButton:Show()
        self:UpdateMinimapButtonPosition()
    end
end

function ClassForge:ResetMinimapButtonPosition()
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.angle = self.defaults.profile.minimapButton.angle
    self:SetMinimapButtonHidden(false)
    self:UpdateMinimapButtonPosition()
end

function ClassForge:UpdateMinimapButtonPosition()
    if not self.minimapButton or not Minimap or self:IsMinimapButtonHidden() then
        return
    end

    local angle = self:GetMinimapButtonAngle()
    local radians = math.rad(angle)
    local radius = (Minimap:GetWidth() / 2) + 5
    local x = math.cos(radians) * radius
    local y = math.sin(radians) * radius

    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function ClassForge:OpenOptionsPanel()
    if not self.optionsPanel then
        return
    end

    InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
end

function ClassForge:CreateMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    local button = CreateFrame("Button", "ClassForgeMinimapButton", Minimap)
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(false)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    background:SetWidth(54)
    background:SetHeight(54)
    background:SetPoint("TOPLEFT")
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\DragonUI\\vendor\\ClassForge\\Media\\ClassForge-Minimap")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", 0, 1)
    button.icon = icon

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(button)

    button.isDragging = nil
    button.dragStopTime = 0
    button:SetScript("OnDragStart", function(selfButton)
        selfButton.isDragging = true
        selfButton:SetScript("OnUpdate", function(_, elapsed)
            local scale = Minimap:GetEffectiveScale()
            local cursorX, cursorY = GetCursorPosition()
            local centerX, centerY = Minimap:GetCenter()
            if not centerX or not centerY then
                return
            end

            local x = cursorX / scale - centerX
            local y = cursorY / scale - centerY
            local targetAngle = math.deg(atan2(y, x))
            local currentAngle = ClassForge:GetMinimapButtonAngle()
            local delta = targetAngle - currentAngle

            while delta > 180 do
                delta = delta - 360
            end
            while delta < -180 do
                delta = delta + 360
            end

            local smoothing = math.min(1, (elapsed or 0.016) * 8)
            local nextAngle = currentAngle + (delta * smoothing)
            ClassForge:SetMinimapButtonAngle(nextAngle)
            ClassForge:UpdateMinimapButtonPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(selfButton)
        selfButton.isDragging = nil
        selfButton.dragStopTime = GetTime()
        selfButton:SetScript("OnUpdate", nil)
    end)

    button:SetScript("OnClick", function(selfButton)
        if selfButton.isDragging or (GetTime() - (selfButton.dragStopTime or 0)) < 0.2 then
            return
        end

        ClassForge:OpenOptionsPanel()
    end)

    button:SetScript("OnEnter", function(selfButton)
        GameTooltip:SetOwner(selfButton, "ANCHOR_LEFT")
        GameTooltip:SetText(ClassForge.name or "ClassForge")
        GameTooltip:AddLine(ClassForge:L("left_click_open"), 1, 1, 1)
        GameTooltip:AddLine(ClassForge:L("drag_move_button"), 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.minimapButton = button
    if self:IsMinimapButtonHidden() then
        button:Hide()
    else
        self:UpdateMinimapButtonPosition()
    end
end

function ClassForge:GetMapMemberColor(unit)
    local data = unit and self:GetDataForUnit(unit) or nil
    if not data then
        return 1, 1, 1
    end

    return self:HexToRGB(data.color)
end

function ClassForge:ApplyColorToMapTexture(texture, unit)
    if not texture or not texture.SetVertexColor then
        return
    end

    texture:SetVertexColor(self:GetMapMemberColor(unit))
end

function ClassForge:GetMapObjectTexture(object)
    if not object then
        return nil
    end

    if object.icon and object.icon.SetVertexColor then
        return object.icon
    end

    if object.texture and object.texture.SetVertexColor then
        return object.texture
    end

    if object.Icon and object.Icon.SetVertexColor then
        return object.Icon
    end

    if object.Texture and object.Texture.SetVertexColor then
        return object.Texture
    end

    if object.SetVertexColor then
        return object
    end

    if object.GetName then
        local objectName = object:GetName()
        if objectName then
            local namedTexture = _G[objectName .. "Icon"]
                or _G[objectName .. "Texture"]
                or _G[objectName .. "IconTexture"]

            if namedTexture and namedTexture.SetVertexColor then
                return namedTexture
            end
        end
    end

    return nil
end

function ClassForge:ApplyColorToMapObject(object, unit)
    self:ApplyColorToMapTexture(self:GetMapObjectTexture(object), unit)
end

function ClassForge:UpdateWorldMapMemberColors()
    for index = 1, MAX_PARTY_MEMBERS do
        self:ApplyColorToMapObject(_G["WorldMapParty" .. index], "party" .. index)
    end

    for index = 1, MAX_RAID_MEMBERS do
        self:ApplyColorToMapObject(_G["WorldMapRaid" .. index], "raid" .. index)
    end
end

function ClassForge:UpdateMinimapMemberColors()
    local partyPrefixes = { "MiniMapParty", "MinimapParty" }
    local raidPrefixes = { "MiniMapRaid", "MinimapRaid" }

    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        for _, prefix in ipairs(partyPrefixes) do
            self:ApplyColorToMapObject(_G[prefix .. index], unit)
        end
    end

    for index = 1, MAX_RAID_MEMBERS do
        local unit = "raid" .. index
        for _, prefix in ipairs(raidPrefixes) do
            self:ApplyColorToMapObject(_G[prefix .. index], unit)
        end
    end
end

function ClassForge:UpdateMapMemberColors()
    self:UpdateWorldMapMemberColors()
    self:UpdateMinimapMemberColors()
end

function ClassForge:ScheduleMapMemberUpdate(delay)
    self.mapColorState = self.mapColorState or {}
    self.mapColorState.pending = true
    self.mapColorState.delay = tonumber(delay) or 0
    self.mapColorState.elapsed = 0
end

function ClassForge:SetupMapColorHooks()
    if self.mapColorHooked then
        return
    end

    self.mapColorHooked = true

    if WorldMapUnit_Update then
        hooksecurefunc("WorldMapUnit_Update", function(frame)
            if not frame then
                return
            end

            local unit = frame.unit
            if unit and (string.find(unit, "^party%d+$") or string.find(unit, "^raid%d+$")) then
                ClassForge:ApplyColorToMapObject(frame, unit)
            end
        end)
    end

    if WorldMapFrame_UpdateUnits then
        hooksecurefunc("WorldMapFrame_UpdateUnits", function()
            ClassForge:UpdateWorldMapMemberColors()
        end)
    end

    if not self.mapColorTicker then
        self.mapColorState = { pending = true, delay = 0, elapsed = 0, fallbackElapsed = 0 }
        local ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(_, elapsed)
            local state = ClassForge.mapColorState
            state.elapsed = state.elapsed + elapsed
            state.fallbackElapsed = state.fallbackElapsed + elapsed

            if state.pending and state.elapsed >= state.delay then
                state.pending = nil
                state.delay = 0
                state.elapsed = 0
                ClassForge:UpdateMapMemberColors()
            end

            if not GetNumPartyMembers and not GetNumRaidMembers then
                return
            end

            if state.fallbackElapsed < 1.0 then
                return
            end

            state.fallbackElapsed = 0

            local hasParty = (GetNumPartyMembers() or 0) > 0
            local hasRaid = (GetNumRaidMembers() or 0) > 0
            if hasParty or hasRaid then
                ClassForge:UpdateMapMemberColors()
            end
        end)
        self.mapColorTicker = ticker
    end
end

function ClassForge:UpdatePartyFrameColors()
    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        local nameFontString = _G["PartyMemberFrame" .. index .. "Name"]

        if nameFontString and UnitExists(unit) and UnitIsPlayer(unit) then
            local data = self:GetDataForUnit(unit)
            if self:IsGroupFrameColoringEnabled() and data and data.color then
                nameFontString:SetTextColor(self:HexToRGB(data.color))
            else
                nameFontString:SetTextColor(1, 0.82, 0)
            end
        end
    end
end

function ClassForge:GetTargetProfilePosition()
    local profile = self:GetProfile()
    local position = profile and profile.targetProfilePosition or nil
    local defaults = self.defaults.profile.targetProfilePosition

    return {
        point = position and position.point or defaults.point,
        relativePoint = position and position.relativePoint or defaults.relativePoint,
        x = position and position.x or defaults.x,
        y = position and position.y or defaults.y,
    }
end

function ClassForge:ApplyTargetProfilePosition()
    if not self.targetProfile or not TargetFrame then
        return
    end

    local position = self:GetTargetProfilePosition()
    self.targetProfile:ClearAllPoints()
    self.targetProfile:SetPoint(position.point, TargetFrame, position.relativePoint, position.x, position.y)
end

function ClassForge:SaveTargetProfilePosition()
    if not self.targetProfile then
        return
    end

    local function round(value)
        if not value then
            return 0
        end

        if value >= 0 then
            return math.floor(value + 0.5)
        end

        return math.ceil(value - 0.5)
    end

    local point, _, relativePoint, x, y = self.targetProfile:GetPoint(1)
    if not point or not relativePoint then
        return
    end

    ClassForgeDB.profile.targetProfilePosition = {
        point = point,
        relativePoint = relativePoint,
        x = round(x),
        y = round(y),
    }
end

function ClassForge:ResetTargetProfilePosition()
    ClassForgeDB.profile.targetProfilePosition = {
        point = self.defaults.profile.targetProfilePosition.point,
        relativePoint = self.defaults.profile.targetProfilePosition.relativePoint,
        x = self.defaults.profile.targetProfilePosition.x,
        y = self.defaults.profile.targetProfilePosition.y,
    }
    self:ApplyTargetProfilePosition()
end

function ClassForge:AppendTooltipData(tooltip, data)
    if not tooltip or tooltip.classForgeTooltipApplied or not data then
        return
    end

    tooltip.classForgeTooltipApplied = true
    tooltip:AddLine(" ")
    tooltip:AddLine(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
    tooltip:AddLine(self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r")
    tooltip:AddLine(self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r")
    tooltip:AddLine(self:GetDataStatusText(data))
    tooltip:Show()
end

function ClassForge:AppendMapTooltipData(tooltip, unit)
    if not tooltip or not unit then
        return
    end

    local data = self:GetDataForUnit(unit)
    if not data then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddLine((self.name or "ClassForge") .. ": " .. self:GetColoredClassText(data))
    tooltip:AddLine(self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r")
    tooltip:AddLine(self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r")
    tooltip:AddLine(self:GetDataStatusText(data))
    tooltip:Show()
end

function ClassForge:GetTooltipOwnedUnit(tooltip)
    if not tooltip or not tooltip.GetOwner then
        return nil
    end

    local owner = tooltip:GetOwner()
    local depth = 0

    while owner and depth < 5 do
        if owner.unit and UnitExists(owner.unit) then
            return owner.unit
        end

        if not owner.GetParent then
            break
        end

        owner = owner:GetParent()
        depth = depth + 1
    end

    return nil
end

function ClassForge:AppendTooltipDataForUnit(tooltip, unit)
    if not tooltip or not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return
    end

    local data = self:GetDataForUnit(unit)
    if not data then
        return
    end

    self:AppendTooltipData(tooltip, data)
end

function ClassForge:HookMapTooltipFrame(frame, tooltipObject, unit)
    if not frame or frame.classForgeMapTooltipHooked then
        return
    end

    frame.classForgeMapTooltipHooked = true
    frame:HookScript("OnEnter", function()
        ClassForge:AppendMapTooltipData(tooltipObject, unit or frame.unit)
    end)
end

function ClassForge:SetupMapMarkerTooltips()
    if self.mapMarkerTooltipTicker then
        return
    end

    local ticker = CreateFrame("Frame")
    ticker.elapsed = 0
    ticker:SetScript("OnUpdate", function(_, elapsed)
        ticker.elapsed = ticker.elapsed + elapsed
        if ticker.elapsed < 0.5 then
            return
        end

        ticker.elapsed = 0

        for index = 1, MAX_PARTY_MEMBERS do
            ClassForge:HookMapTooltipFrame(_G["WorldMapParty" .. index], WorldMapTooltip, "party" .. index)
            ClassForge:HookMapTooltipFrame(_G["MiniMapParty" .. index] or _G["MinimapParty" .. index], GameTooltip, "party" .. index)
        end

        for index = 1, MAX_RAID_MEMBERS do
            ClassForge:HookMapTooltipFrame(_G["WorldMapRaid" .. index], WorldMapTooltip, "raid" .. index)
            ClassForge:HookMapTooltipFrame(_G["MiniMapRaid" .. index] or _G["MinimapRaid" .. index], GameTooltip, "raid" .. index)
        end
    end)
    self.mapMarkerTooltipTicker = ticker
end

function ClassForge:HookTooltips()
    if self.tooltipHooked then
        return
    end

    self.tooltipHooked = true

    GameTooltip:HookScript("OnHide", function(tooltip)
        tooltip.classForgeTooltipApplied = nil
    end)

    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitIsPlayer(unit) then
            return
        end

        local ownerUnit = ClassForge:GetTooltipOwnedUnit(tooltip)
        if ownerUnit and UnitIsUnit(unit, ownerUnit) then
            ClassForge:AppendTooltipDataForUnit(tooltip, ownerUnit)
            return
        end

        if UnitExists("mouseover") and UnitIsUnit(unit, "mouseover") then
            ClassForge:AppendTooltipDataForUnit(tooltip, "mouseover")
        end
    end)
end

function ClassForge:GetRaidBrowserClassColor(data, fileName, online, isDead)
    if not online then
        return GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
    end

    if isDead then
        return RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b
    end

    if data and data.color then
        return self:HexToRGB(data.color)
    end

    local color = fileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[fileName]
    if color then
        return color.r, color.g, color.b
    end

    return 1, 1, 1
end

function ClassForge:UpdateRaidBrowser()
    if not RaidGroupFrame_Update then
        return
    end

    for index = 1, MAX_RAID_MEMBERS do
        local button = _G["RaidGroupButton" .. index]
        local classFontString = _G["RaidGroupButton" .. index .. "Class"]
        if button and classFontString and button:IsShown() and button.unit and UnitExists(button.unit) and UnitIsPlayer(button.unit) then
            local _, _, _, _, className, fileName, _, online, isDead = GetRaidRosterInfo(index)
            local data = self:GetDataForUnit(button.unit)
            local nameFontString = _G["RaidGroupButton" .. index .. "Name"]

            if data and data.className and data.className ~= "" then
                classFontString:SetText(data.className)
            else
                classFontString:SetText(className or "")
            end

            local r, g, b = self:GetRaidBrowserClassColor(data, fileName, online, isDead)
            classFontString:SetTextColor(r, g, b)
            if nameFontString then
                if self:IsGroupFrameColoringEnabled() and online and not isDead and data and data.color then
                    nameFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    nameFontString:SetTextColor(r, g, b)
                end
            end
        end
    end
end

function ClassForge:HookRaidBrowser()
    if self.raidFrameLoadHooked == nil and RaidFrame_LoadUI then
        self.raidFrameLoadHooked = true
        hooksecurefunc("RaidFrame_LoadUI", function()
            ClassForge:HookRaidBrowser()
        end)
    end

    if self.raidBrowserHooked or not RaidGroupFrame_Update then
        return
    end

    self.raidBrowserHooked = true

    hooksecurefunc("RaidGroupFrame_Update", function()
        ClassForge:UpdateRaidBrowser()
    end)

    if RaidGroupFrame_UpdateHealth then
        hooksecurefunc("RaidGroupFrame_UpdateHealth", function()
            ClassForge:UpdateRaidBrowser()
        end)
    end

    self:UpdateRaidBrowser()
end

function ClassForge:HookPartyFrames()
    if self.partyFrameHooked then
        return
    end

    self.partyFrameHooked = true

    if PartyMemberFrame_UpdateMember then
        hooksecurefunc("PartyMemberFrame_UpdateMember", function()
            ClassForge:UpdatePartyFrameColors()
        end)
    end
end

function ClassForge:EnsureFriendsTooltipExtras()
    if self.friendsTooltipExtras or not FriendsTooltip then
        return
    end

    local classText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    classText:SetJustifyH("LEFT")
    classText:SetWidth(188)

    local roleText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    roleText:SetJustifyH("LEFT")
    roleText:SetWidth(188)

    local orderText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    orderText:SetJustifyH("LEFT")
    orderText:SetWidth(188)

    local updatedText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    updatedText:SetJustifyH("LEFT")
    updatedText:SetWidth(188)

    self.friendsTooltipExtras = {
        classText = classText,
        roleText = roleText,
        orderText = orderText,
        updatedText = updatedText,
    }
end

function ClassForge:GetFriendsTooltipBottomAnchor()
    local candidates = {
        FriendsTooltipToonMany,
        FriendsTooltipToon5Info,
        FriendsTooltipToon5Name,
        FriendsTooltipToon4Info,
        FriendsTooltipToon4Name,
        FriendsTooltipToon3Info,
        FriendsTooltipToon3Name,
        FriendsTooltipToon2Info,
        FriendsTooltipToon2Name,
        FriendsTooltipOtherToons,
        FriendsTooltipBroadcastText,
        FriendsTooltipNoteText,
        FriendsTooltipLastOnline,
        FriendsTooltipToon1Info,
        FriendsTooltipToon1Name,
        FriendsTooltipHeader,
    }

    for _, region in ipairs(candidates) do
        if region and region:IsShown() then
            return region
        end
    end

    return FriendsTooltipHeader
end

function ClassForge:HideFriendsTooltipExtras()
    if not self.friendsTooltipExtras then
        return
    end

    self.friendsTooltipExtras.classText:Hide()
    self.friendsTooltipExtras.roleText:Hide()
    self.friendsTooltipExtras.orderText:Hide()
    self.friendsTooltipExtras.updatedText:Hide()
end

function ClassForge:UpdateFriendsTooltip(button)
    if not FriendsTooltip or not button or button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW or not button.id then
        self:HideFriendsTooltipExtras()
        return
    end

    local name = GetFriendInfo(button.id)
    local data = name and self:GetDataForName(name) or nil
    if not data then
        self:HideFriendsTooltipExtras()
        return
    end

    self:EnsureFriendsTooltipExtras()

    local anchor = self:GetFriendsTooltipBottomAnchor()
    local classText = self.friendsTooltipExtras.classText
    local roleText = self.friendsTooltipExtras.roleText
    local orderText = self.friendsTooltipExtras.orderText
    local updatedText = self.friendsTooltipExtras.updatedText

    FriendsFrameTooltip_SetLine(classText, anchor, self:L("class_label") .. ": " .. self:GetColoredClassText(data), -8)
    FriendsFrameTooltip_SetLine(roleText, classText, self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r", -2)
    FriendsFrameTooltip_SetLine(orderText, roleText, self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r", -2)
    FriendsFrameTooltip_SetLine(updatedText, orderText, self:L("source_label") .. ": |cffffffff" .. self:GetSourceLabel(data) .. "|r |cff808080-|r " .. self:L("updated_label") .. ": " .. self:FormatUpdatedTimeColored(data.updated), -2)

    FriendsTooltip:SetHeight(FriendsTooltip.height + FRIENDS_TOOLTIP_MARGIN_WIDTH)
    FriendsTooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, FriendsTooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH))
end

function ClassForge:HookFriendsTooltip()
    if self.friendsTooltipHooked or not FriendsTooltip then
        return
    end

    self.friendsTooltipHooked = true

    FriendsTooltip:HookScript("OnShow", function(tooltip)
        if not tooltip.button then
            ClassForge:HideFriendsTooltipExtras()
            return
        end

        ClassForge:UpdateFriendsTooltip(tooltip.button)
    end)

    FriendsTooltip:HookScript("OnHide", function()
        ClassForge:HideFriendsTooltipExtras()
    end)
end

function ClassForge:GetVisibleFriendButtons()
    local buttons = {}
    local row = 1

    while true do
        local button = _G["FriendsFrameFriendsScrollFrameButton" .. row]
        if not button then
            break
        end

        buttons[#buttons + 1] = button
        row = row + 1
    end

    return buttons
end

function ClassForge:GetFriendButtonNameFontString(button)
    if not button or not button.GetName then
        return nil
    end

    return button.name
        or button.text
        or _G[button:GetName() .. "Name"]
        or _G[button:GetName() .. "Text"]
end

function ClassForge:HookWhoFrame()
    if self.whoHooked then
        return
    end

    self.whoHooked = true
    hooksecurefunc("WhoList_Update", function()
        ClassForge:UpdateWhoList()
    end)
end

function ClassForge:UpdateWhoList()
    if not WhoFrame or not WhoFrame:IsShown() or not WhoListScrollFrame then
        return
    end

    local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
    local total = GetNumWhoResults() or 0

    for row = 1, WHOS_TO_DISPLAY do
        local index = offset + row
        if index <= total then
            local name, _, _, _, className = GetWhoInfo(index)
            local data = self:GetDataForName(name)
            local classFontString = _G["WhoFrameButton" .. row .. "Class"]

            if classFontString then
                if data then
                    classFontString:SetText(data.className or className or "")
                    classFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    classFontString:SetText(className or "")
                    classFontString:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

function ClassForge:HookGuildFrame()
    if self.guildHooked then
        return
    end

    self.guildHooked = true

    hooksecurefunc("GuildStatus_Update", function()
        ClassForge:UpdateGuildRoster()
    end)

    hooksecurefunc("GuildRoster", function()
        ClassForge:UpdateGuildRoster()
    end)
end

function ClassForge:UpdateGuildRoster()
    if not GuildFrame or not GuildFrame:IsShown() or not GuildListScrollFrame then
        return
    end

    local total = GetNumGuildMembers(true) or 0
    local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)

    for row = 1, GUILDMEMBERS_TO_DISPLAY do
        local index = offset + row
        if index <= total then
            local fullName, _, _, _, className = GetGuildRosterInfo(index)
            local data = self:GetDataForName(fullName)
            local classFontString = _G["GuildFrameButton" .. row .. "Class"]

            if classFontString then
                if data then
                    classFontString:SetText(data.className or className or "")
                    classFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    classFontString:SetText(className or "")
                    classFontString:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

function ClassForge:HookFriendsFrame()
    if self.friendsHooked then
        return
    end

    self.friendsHooked = true

    hooksecurefunc("FriendsFrame_Update", function()
        ClassForge:UpdateFriendsList()
    end)

    if FriendsList_Update then
        hooksecurefunc("FriendsList_Update", function()
            ClassForge:UpdateFriendsList()
        end)
    end

    if FriendsFrame then
        FriendsFrame:HookScript("OnShow", function()
            ClassForge:UpdateFriendsList()
        end)
    end
end

function ClassForge:UpdateFriendsList()
    if not FriendsFrame or not FriendsFrame:IsShown() or FriendsFrame.selectedTab ~= 1 then
        return
    end

    local buttons = self:GetVisibleFriendButtons()

    for _, button in ipairs(buttons) do
        local nameFontString = self:GetFriendButtonNameFontString(button)
        if button and button:IsShown() and nameFontString and button.buttonType == FRIENDS_BUTTON_TYPE_WOW and button.id then
            local name, _, _, _, _, _, noteText = GetFriendInfo(button.id)
            if name then
                local data = self:GetDataForName(name)
                local baseName = self:NormalizePlayerName(name) or name

                if noteText and noteText ~= "" then
                    baseName = baseName .. " |cff808080(" .. noteText .. ")|r"
                end

                if data then
                    nameFontString:SetText(baseName .. " |cff808080-|r " .. self:GetColoredClassText(data))
                else
                    nameFontString:SetText(baseName)
                end
            end
        end
    end
end

function ClassForge:CreateCharacterPanel()
    if not PaperDollFrame or PaperDollFrame.ClassForgeInfo then
        return
    end

    local info = PaperDollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    info:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -4)
    info:SetJustifyH("CENTER")
    info:SetWidth(220)
    PaperDollFrame.ClassForgeInfo = info

    hooksecurefunc("PaperDollFrame_SetLevel", function()
        ClassForge:UpdateCharacterPanel()
    end)
end

function ClassForge:UpdateCharacterPanel()
    if not PaperDollFrame or not PaperDollFrame.ClassForgeInfo then
        return
    end

    local data = self:BuildProfileData()
    local roleText = self:GetRoleDisplayText(data.role)
    local factionText = self:GetFactionText(data)

    PaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. roleText .. " |cff808080-|r " .. factionText .. "|cff808080)|r")
    self:UpdateCharacterDetailTabVisibility()
    self:UpdateCharacterDetailPanel()
end

function ClassForge:SetCharacterTabSelected(selected)
    if not self.characterDetailTabButton or not self.characterDetailPanel then
        return
    end

    self.characterTabSelected = selected and true or false

    if self.characterTabSelected then
        if PaperDollFrame and PaperDollFrame.ClassForgeInfo then
            PaperDollFrame.ClassForgeInfo:Hide()
        end
        self.characterDetailPanel:Show()
    else
        self.characterDetailPanel:Hide()
        if PaperDollFrame and PaperDollFrame.ClassForgeInfo then
            PaperDollFrame.ClassForgeInfo:Show()
        end
    end

    self.characterDetailTabButton:SetButtonState(self.characterTabSelected and "PUSHED" or "NORMAL")
    self.characterDetailTabButton:SetText(self:L("class_info_tab"))
end

function ClassForge:UpdateCharacterDetailTabVisibility()
    if not self.characterDetailTabButton then
        return
    end

    self.characterDetailTabButton:ClearAllPoints()
    if CharacterFrame then
        self.characterDetailTabButton:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -48, -42)
        self.characterDetailTabButton:SetWidth(96)
        self.characterDetailTabButton:SetHeight(24)
    end

    local showingCharacter = CharacterFrame and CharacterFrame:IsShown()
    if showingCharacter then
        self.characterDetailTabButton:Show()
        if self.characterTabSelected then
            self.characterDetailPanel:Show()
        end
    else
        self.characterDetailTabButton:Hide()
        if self.characterDetailPanel then
            self.characterDetailPanel:Hide()
        end
    end
end

function ClassForge:CreateCharacterDetailTab()
    if self.characterDetailPanel then
        return
    end

    if not CharacterFrame or not PaperDollFrame then
        return
    end

    local tab = CreateFrame("Button", "ClassForgeCharacterTabButton", CharacterFrame, "UIPanelButtonTemplate")
    tab:SetWidth(96)
    tab:SetHeight(24)
    tab:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -48, -42)
    tab:SetText(self:L("class_info_tab"))
    tab:SetScript("OnClick", function()
        ClassForge:SetCharacterTabSelected(not ClassForge.characterTabSelected)
        ClassForge:UpdateCharacterDetailPanel()
    end)

    local panel = CreateFrame("Frame", "ClassForgeCharacterDetailPanel", CharacterFrame)
    panel:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 30, -74)
    panel:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -32, 36)
    panel:SetFrameStrata(CharacterFrame:GetFrameStrata())
    panel:SetFrameLevel(CharacterFrame:GetFrameLevel() + 20)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    panel:SetBackdropColor(0.05, 0.05, 0.05, 1)
    panel:Hide()
    panel:EnableMouse(true)

    panel.background = panel:CreateTexture(nil, "BACKGROUND")
    panel.background:SetAllPoints(panel)
    panel.background:SetTexture(0.08, 0.08, 0.08, 1)
    panel.background:SetVertexColor(0.18, 0.18, 0.18, 1)

    local scroll = CreateFrame("ScrollFrame", "ClassForgeCharacterDetailScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -12)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(255)
    content:SetHeight(320)
    scroll:SetScrollChild(content)

    content.iconFrame = CreateFrame("Frame", nil, content)
    content.iconFrame:SetWidth(42)
    content.iconFrame:SetHeight(42)
    content.iconFrame:SetPoint("TOPLEFT", 0, 0)
    content.iconFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    content.iconFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    content.iconTexture = content.iconFrame:CreateTexture(nil, "ARTWORK")
    content.iconTexture:SetPoint("TOPLEFT", 4, -4)
    content.iconTexture:SetPoint("BOTTOMRIGHT", -4, 4)
    content.iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    content.classText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.classText:SetPoint("TOPLEFT", content.iconFrame, "TOPRIGHT", 10, -2)
    content.classText:SetWidth(198)
    content.classText:SetJustifyH("LEFT")

    content.roleText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    content.roleText:SetPoint("TOPLEFT", content.classText, "BOTTOMLEFT", 0, -10)
    content.roleText:SetWidth(198)
    content.roleText:SetJustifyH("LEFT")

    content.descriptionLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    content.descriptionLabel:SetPoint("TOPLEFT", content.roleText, "BOTTOMLEFT", 0, -14)
    content.descriptionLabel:SetWidth(250)
    content.descriptionLabel:SetJustifyH("LEFT")

    content.descriptionText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    content.descriptionText:SetPoint("TOPLEFT", content.descriptionLabel, "BOTTOMLEFT", 0, -6)
    content.descriptionText:SetWidth(250)
    content.descriptionText:SetJustifyH("LEFT")
    content.descriptionText:SetJustifyV("TOP")

    content.spellsLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    content.spellsLabel:SetWidth(250)
    content.spellsLabel:SetJustifyH("LEFT")

    content.spellsText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    content.spellsText:SetWidth(250)
    content.spellsText:SetJustifyH("LEFT")
    content.spellsText:SetJustifyV("TOP")

    panel.scroll = scroll
    panel.content = content
    self.characterDetailTabButton = tab
    self.characterDetailPanel = panel
    self.characterTabSelected = false

    if CharacterFrame then
        CharacterFrame:HookScript("OnShow", function()
            ClassForge:UpdateCharacterDetailTabVisibility()
            ClassForge:UpdateCharacterDetailPanel()
        end)
        CharacterFrame:HookScript("OnHide", function()
            ClassForge:SetCharacterTabSelected(false)
        end)
    end

    if CharacterFrame_ShowSubFrame then
        hooksecurefunc("CharacterFrame_ShowSubFrame", function(frameName)
            ClassForge:UpdateCharacterDetailTabVisibility()
            if not ClassForge.characterDetailPanel then
                return
            end
            if frameName ~= ClassForge.characterDetailPanel:GetName() then
                ClassForge:SetCharacterTabSelected(false)
            end
        end)
    end

    self:UpdateCharacterDetailTabVisibility()
end

function ClassForge:UpdateCharacterDetailPanel()
    if not self.characterDetailPanel then
        return
    end

    if not CharacterFrame or not CharacterFrame:IsShown() then
        self.characterDetailPanel:Hide()
        return
    end

    if self.characterDetailTabButton then
        self.characterDetailTabButton:SetText(self:L("class_info_tab"))
    end

    local data = self:BuildProfileData()
    if not self.characterTabSelected then
        self.characterDetailPanel:Hide()
        return
    end

    local content = self.characterDetailPanel.content
    local description = self:Trim(data.description)
    local factionText = self:GetFactionText(data)
    local iconTexture = self:GetResolvedIconTexture(data.icon, data.className, true)
    content.iconTexture:SetTexture(iconTexture)
    content.classText:SetText(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
    content.roleText:SetText(self:L("role_label") .. ": " .. self:GetRoleDisplayText(data.role) .. " |cff808080-|r " .. self:L("faction_label") .. ": " .. factionText)
    content.descriptionLabel:SetText(self:L("inspect_description"))
    content.descriptionText:SetText(description ~= "" and description or self:L("none"))
    content.spellsLabel:SetPoint("TOPLEFT", content.descriptionText, "BOTTOMLEFT", 0, -14)
    content.spellsLabel:SetText(self:L("inspect_spells"))
    content.spellsText:SetPoint("TOPLEFT", content.spellsLabel, "BOTTOMLEFT", 0, -6)
    content.spellsText:SetText(self:GetInspectSpellText(data))
    local descriptionBottom = content.descriptionText:GetStringHeight() or 0
    local spellsBottom = content.spellsText:GetStringHeight() or 0
    content:SetHeight(math.max(260, 72 + descriptionBottom + 34 + spellsBottom))
    self.characterDetailPanel:Show()
end

function ClassForge:CreateTargetClassTag()
    if self.targetTag or not TargetFrameTextureFrame then
        return
    end

    local tag = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tag:SetPoint("TOP", TargetFrameTextureFrame, "BOTTOM", 0, 18)
    self.targetTag = tag
end

function ClassForge:UpdateTargetClassTag()
    if not self.targetTag then
        return
    end

    local data = self:GetDataForUnit("target")
    if not data then
        self.targetTag:SetText("")
        return
    end

    self.targetTag:SetText(self:GetColoredClassText(data))
end

function ClassForge:CreateTargetProfile()
    if self.targetProfile then
        return
    end

    if not TargetFrame then
        return
    end

    local frame = CreateFrame("Frame", "ClassForgeTargetProfile", TargetFrame)
    frame:SetWidth(220)
    frame:SetHeight(92)
    frame:SetFrameStrata(TargetFrame:GetFrameStrata())
    frame:SetFrameLevel(TargetFrame:GetFrameLevel() + 5)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:Hide()
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetScript("OnDragStart", function(selfFrame)
        if IsShiftKeyDown() and not ClassForge:IsTargetProfileLocked() then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        ClassForge:SaveTargetProfilePosition()
    end)

    frame.classText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.classText:SetPoint("TOPLEFT", 10, -10)
    frame.classText:SetJustifyH("LEFT")

    frame.roleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.roleText:SetPoint("TOPLEFT", frame.classText, "BOTTOMLEFT", 0, -8)
    frame.roleText:SetJustifyH("LEFT")

    frame.orderText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.orderText:SetPoint("TOPLEFT", frame.roleText, "BOTTOMLEFT", 0, -6)
    frame.orderText:SetJustifyH("LEFT")

    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.statusText:SetPoint("TOPLEFT", frame.orderText, "BOTTOMLEFT", 0, -6)
    frame.statusText:SetJustifyH("LEFT")
    frame.statusText:SetWidth(190)

    frame.refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.refreshButton:SetWidth(52)
    frame.refreshButton:SetHeight(18)
    frame.refreshButton:SetText(self:L("refresh"))
    frame.refreshButton:SetScript("OnClick", function()
        if UnitExists("target") and UnitIsPlayer("target") then
            local targetName = UnitName("target")
            if targetName then
                ClassForge:RequestSyncFromName(targetName)
            end
            ClassForge:PerformWhoSync()
        end
    end)

    frame.hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hintText:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.hintText:SetText(self:IsTargetProfileLocked() and self:L("locked") or self:L("shift_drag"))

    self.targetProfile = frame
    self:UpdateTargetProfileLayout()
    self:ApplyTargetProfilePosition()
end

function ClassForge:UpdateTargetProfileLayout()
    if not self.targetProfile then
        return
    end

    if self:IsTargetProfileCompact() then
        self.targetProfile:SetWidth(190)
        self.targetProfile:SetHeight(62)
        self.targetProfile.orderText:Hide()
        self.targetProfile.statusText:Hide()
    else
        self.targetProfile:SetWidth(220)
        self.targetProfile:SetHeight(92)
        self.targetProfile.orderText:Show()
        self.targetProfile.statusText:Show()
    end

    self.targetProfile.refreshButton:ClearAllPoints()
    self.targetProfile.refreshButton:SetPoint("TOPRIGHT", -8, -8)
end

function ClassForge:UpdateTargetProfile()
    if not self.targetProfile then
        return
    end

    if self:IsTargetProfileHidden() then
        self.targetProfile:Hide()
        return
    end

    local data = self:GetDataForUnit("target")
    if not data then
        self.targetProfile:Hide()
        return
    end

    self.targetProfile.classText:SetText(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
    self.targetProfile.roleText:SetText(self:L("role_label") .. ": " .. self:GetRoleDisplayText(data.role))
    self.targetProfile.orderText:SetText(self:L("faction_label") .. ": " .. self:GetFactionText(data))
    self.targetProfile.statusText:SetText(self:GetSourceLabel(data) .. " |cff808080-|r " .. self:FormatUpdatedTimeColored(data.updated))
    self:UpdateTargetProfileLayout()
    self.targetProfile:Show()
end

function ClassForge:GetInspectUnit()
    if InspectFrame and InspectFrame.unit and UnitExists(InspectFrame.unit) then
        return InspectFrame.unit
    end

    if UnitExists("target") and UnitIsPlayer("target") then
        return "target"
    end

    return nil
end

function ClassForge:GetInspectData()
    local unit = self:GetInspectUnit()
    local name = unit and UnitName(unit) or nil
    local data = name and self:GetDataForName(name) or nil
    return data, unit, name
end

function ClassForge:GetInspectSpellText(data)
    local topSpells = data and self:Trim(data.topSpells) or ""
    if topSpells == "" then
        return self:L("meter_no_spells")
    end

    local lines = {}
    for entry in string.gmatch(topSpells, "([^,]+)") do
        local cleanEntry = self:Trim(entry)
        local spellName, amount = string.match(cleanEntry, "^(.-)%s*%((%d+)%)$")
        spellName = self:Trim(spellName or cleanEntry)
        amount = tonumber(amount)
        if spellName ~= "" then
            lines[#lines + 1] = self:GetIconizedSpellText(spellName, amount, 14)
        end
    end

    if #lines == 0 then
        return self:L("meter_no_spells")
    end

    return table.concat(lines, "\n")
end

function ClassForge:SetInspectTabSelected(selected)
    if not self.inspectTabButton or not self.inspectDetailPanel then
        return
    end

    self.inspectTabSelected = selected and true or false
    if self.inspectTabSelected then
        self.inspectDetailPanel:Show()
    else
        self.inspectDetailPanel:Hide()
    end

    if InspectPaperDollItemsFrame then
        if self.inspectTabSelected then
            InspectPaperDollItemsFrame:Hide()
        else
            InspectPaperDollItemsFrame:Show()
        end
    end

    if InspectPaperDollFrame and InspectPaperDollFrame.ClassForgeInfo then
        if self.inspectTabSelected then
            InspectPaperDollFrame.ClassForgeInfo:Hide()
        else
            InspectPaperDollFrame.ClassForgeInfo:Show()
        end
    end

    self.inspectTabButton:SetAlpha(self.inspectTabSelected and 1 or 0.8)
    self.inspectTabButton:SetText(self:L("class_info_tab"))
end

function ClassForge:CreateInspectDetailPanel()
    if self.inspectDetailPanel or not InspectPaperDollFrame then
        return
    end

    local tabParent = InspectFrame or InspectPaperDollFrame
    local tab = CreateFrame("Button", "ClassForgeInspectTabButton", tabParent, "UIPanelButtonTemplate")
    tab:SetWidth(96)
    tab:SetHeight(24)
    if InspectFrame then
        tab:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", -48, -42)
    else
        tab:SetPoint("TOPLEFT", InspectPaperDollFrame, "TOPRIGHT", -48, -42)
    end
    tab:SetText(self:L("class_info_tab"))
    tab:SetScript("OnClick", function()
        ClassForge:SetInspectTabSelected(not ClassForge.inspectTabSelected)
        ClassForge:UpdateInspectFrame()
    end)

    local panel = CreateFrame("Frame", "ClassForgeInspectDetailPanel", InspectPaperDollFrame)
    panel:SetPoint("TOPLEFT", 12, -58)
    panel:SetPoint("BOTTOMRIGHT", -28, 12)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    panel:SetBackdropColor(0, 0, 0, 0.85)
    panel:Hide()

    local scroll = CreateFrame("ScrollFrame", "ClassForgeInspectDetailScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -10)
    scroll:SetPoint("BOTTOMRIGHT", -28, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(255)
    content:SetHeight(320)
    scroll:SetScrollChild(content)

    content.iconFrame = CreateFrame("Frame", nil, content)
    content.iconFrame:SetWidth(42)
    content.iconFrame:SetHeight(42)
    content.iconFrame:SetPoint("TOPLEFT", 0, 0)
    content.iconFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    content.iconFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    content.iconTexture = content.iconFrame:CreateTexture(nil, "ARTWORK")
    content.iconTexture:SetPoint("TOPLEFT", 4, -4)
    content.iconTexture:SetPoint("BOTTOMRIGHT", -4, 4)
    content.iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    content.classText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.classText:SetPoint("TOPLEFT", content.iconFrame, "TOPRIGHT", 10, -2)
    content.classText:SetWidth(198)
    content.classText:SetJustifyH("LEFT")

    content.roleText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    content.roleText:SetPoint("TOPLEFT", content.classText, "BOTTOMLEFT", 0, -10)
    content.roleText:SetWidth(198)
    content.roleText:SetJustifyH("LEFT")

    content.descriptionLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    content.descriptionLabel:SetPoint("TOPLEFT", content.roleText, "BOTTOMLEFT", 0, -14)
    content.descriptionLabel:SetWidth(250)
    content.descriptionLabel:SetJustifyH("LEFT")

    content.descriptionText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    content.descriptionText:SetPoint("TOPLEFT", content.descriptionLabel, "BOTTOMLEFT", 0, -6)
    content.descriptionText:SetWidth(250)
    content.descriptionText:SetJustifyH("LEFT")
    content.descriptionText:SetJustifyV("TOP")

    content.spellsLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    content.spellsLabel:SetWidth(250)
    content.spellsLabel:SetJustifyH("LEFT")

    content.spellsText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    content.spellsText:SetWidth(250)
    content.spellsText:SetJustifyH("LEFT")
    content.spellsText:SetJustifyV("TOP")

    panel.scroll = scroll
    panel.content = content
    self.inspectTabButton = tab
    self.inspectDetailPanel = panel
    self.inspectTabSelected = false
end

function ClassForge:SetupInspectHooks()
    if self.inspectHooked then
        return
    end

    if not IsAddOnLoaded("Blizzard_InspectUI") then
        LoadAddOn("Blizzard_InspectUI")
    end

    if not InspectPaperDollFrame then
        return
    end

    self.inspectHooked = true

    local anchor = InspectLevelText or InspectNameText or InspectPaperDollFrame
    local text = InspectPaperDollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    text:SetPoint("TOP", anchor, "BOTTOM", 0, -4)
    text:SetJustifyH("CENTER")
    text:SetWidth(220)
    InspectPaperDollFrame.ClassForgeInfo = text
    self:CreateInspectDetailPanel()

    hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
        ClassForge:UpdateInspectFrame()
    end)

    if InspectFrame then
        InspectFrame:HookScript("OnShow", function()
            ClassForge:UpdateInspectFrame()
        end)
        InspectFrame:HookScript("OnHide", function()
            ClassForge:SetInspectTabSelected(false)
        end)
    end
end

function ClassForge:UpdateInspectFrame()
    if not InspectPaperDollFrame or not InspectPaperDollFrame.ClassForgeInfo then
        return
    end

    if not InspectFrame or not InspectFrame:IsShown() then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        if self.inspectDetailPanel then
            self.inspectDetailPanel:Hide()
        end
        return
    end

    if self.inspectTabButton then
        self.inspectTabButton:SetText(self:L("class_info_tab"))
    end

    local data = self:GetInspectData()

    if not data then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        if self.inspectDetailPanel and self.inspectTabSelected then
            self.inspectDetailPanel:Show()
            local content = self.inspectDetailPanel.content
            content.iconTexture:SetTexture(self:GetResolvedIconTexture(nil, "Hero", true))
            content.classText:SetText(self:L("class_label") .. ": " .. self:GetColoredClassText({
                className = "Hero",
                color = self.defaults.character.color,
            }))
            content.roleText:SetText("")
            content.descriptionLabel:SetText(self:L("inspect_description"))
            content.descriptionText:SetText("The Hero is a rare anomaly whispered of across Azeroth, from the war-torn fields of Eastern Kingdoms to the shattered wilds of Kalimdor.")
            content.spellsLabel:SetPoint("TOPLEFT", content.descriptionText, "BOTTOMLEFT", 0, -14)
            content.spellsLabel:SetText("")
            content.spellsText:SetPoint("TOPLEFT", content.spellsLabel, "BOTTOMLEFT", 0, -6)
            content.spellsText:SetText("")
            content:SetHeight(260)
        end
        return
    end

    local factionText = self:GetFactionText(data)
    InspectPaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. self:GetRoleDisplayText(data.role) .. " |cff808080-|r " .. factionText .. " |cff808080-|r " .. self:GetSourceLabel(data) .. " |cff808080-|r " .. self:FormatUpdatedTimeColored(data.updated) .. "|cff808080)|r")

    if self.inspectDetailPanel and self.inspectTabSelected then
        local content = self.inspectDetailPanel.content
        local description = self:Trim(data.description)
        content.iconTexture:SetTexture(self:GetResolvedIconTexture(data.icon, data.className, true))
        content.classText:SetText(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
        content.roleText:SetText(self:L("role_label") .. ": " .. self:GetRoleDisplayText(data.role) .. " |cff808080-|r " .. self:L("faction_label") .. ": " .. factionText)
        content.descriptionLabel:SetText(self:L("inspect_description"))
        content.descriptionText:SetText(description ~= "" and description or self:L("none"))
        content.spellsLabel:SetPoint("TOPLEFT", content.descriptionText, "BOTTOMLEFT", 0, -14)
        content.spellsLabel:SetText(self:L("inspect_spells"))
        content.spellsText:SetPoint("TOPLEFT", content.spellsLabel, "BOTTOMLEFT", 0, -6)
        content.spellsText:SetText(self:GetInspectSpellText(data))
        local descriptionBottom = content.descriptionText:GetStringHeight() or 0
        local spellsBottom = content.spellsText:GetStringHeight() or 0
        content:SetHeight(math.max(260, 72 + descriptionBottom + 34 + spellsBottom))
        self.inspectDetailPanel:Show()
    elseif self.inspectDetailPanel then
        self.inspectDetailPanel:Hide()
    end
end
