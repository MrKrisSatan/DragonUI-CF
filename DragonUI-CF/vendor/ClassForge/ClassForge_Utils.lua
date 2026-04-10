function ClassForge:CopyDefaults(source, destination)
    if type(source) ~= "table" then
        return destination
    end

    if type(destination) ~= "table" then
        destination = {}
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            destination[key] = self:CopyDefaults(value, destination[key])
        elseif destination[key] == nil then
            destination[key] = value
        end
    end

    return destination
end

function ClassForge:Trim(value)
    if not value then
        return ""
    end

    return (tostring(value):gsub("^%s*(.-)%s*$", "%1"))
end

function ClassForge:IsRealmAwareEnabled()
    local profile = self:GetProfile()
    local names = profile and profile.names or nil

    if names and names.realmAware ~= nil then
        return names.realmAware and true or false
    end

    return self.defaults.profile.names.realmAware and true or false
end

function ClassForge:GetNormalizedRealmName(name)
    local trimmed = self:Trim(name)
    if trimmed == "" then
        return nil
    end

    return trimmed:gsub("%s+", ""):gsub("[^%a%d]", "")
end

function ClassForge:NormalizePlayerName(name)
    name = self:Trim(name)
    if name == "" then
        return nil
    end

    local baseName, realmName = name:match("^([^%-]+)%-(.+)$")
    if not baseName or baseName == "" then
        baseName = name
        realmName = nil
    end

    if baseName == "" then
        return nil
    end

    local normalized = baseName:sub(1, 1):upper() .. baseName:sub(2):lower()
    if not self:IsRealmAwareEnabled() then
        return normalized
    end

    realmName = self:GetNormalizedRealmName(realmName)
    if not realmName or realmName == "" then
        return normalized
    end

    return normalized .. "-" .. realmName
end

function ClassForge:GetPlayerKey(name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized then
        return nil
    end

    return string.lower(normalized)
end

function ClassForge:SanitizeHex(hex)
    hex = self:Trim(hex):upper():gsub("#", ""):gsub("^0X", "")
    if hex == "" then
        return nil
    end

    if hex:match("^%x%x%x$") then
        return hex:sub(1, 1) .. hex:sub(1, 1) .. hex:sub(2, 2) .. hex:sub(2, 2) .. hex:sub(3, 3) .. hex:sub(3, 3)
    end

    if hex:match("^%x%x%x%x%x%x$") then
        return hex
    end

    if hex:match("^%x%x%x%x%x%x%x%x$") then
        return hex:sub(3)
    end

    return nil
end

function ClassForge:NormalizeRole(role)
    role = self:Trim(role)
    if role == "" then
        return nil
    end

    local lower = string.lower(role)
    if lower == "heal" or lower == "healer" then
        return "Heal"
    end
    if lower == "tank" then
        return "Tank"
    end
    if lower == "dps" or lower == "damage" then
        return "DPS"
    end

    return nil
end

function ClassForge:GetAssignedGroupRole(unit)
    unit = unit or "player"
    if not UnitExists or not UnitExists(unit) then
        return nil
    end

    if not UnitGroupRolesAssigned then
        return nil
    end

    local assigned = UnitGroupRolesAssigned(unit)
    assigned = self:Trim(assigned)
    if assigned == "" or assigned == "NONE" then
        return nil
    end

    if assigned == "TANK" then
        return "Tank"
    end
    if assigned == "HEALER" then
        return "Heal"
    end
    if assigned == "DAMAGER" then
        return "DPS"
    end

    return self:NormalizeRole(assigned)
end

function ClassForge:GetStoredCharacterRole()
    if type(self.GetCharacterProfile) ~= "function" then
        return nil
    end

    local characterProfile = self:GetCharacterProfile()
    if type(characterProfile) ~= "table" then
        return nil
    end

    return self:NormalizeRole(characterProfile.role)
end

function ClassForge:GetCurrentRole()
    return self:GetStoredCharacterRole()
        or self:GetAssignedGroupRole("player")
        or self.defaults.character.role
end

function ClassForge:NormalizeFaction(value)
    value = self:Trim(value)
    if value == "" then
        return ""
    end

    local lower = string.lower(value)
    if lower == "alliance" then
        return "Alliance"
    end
    if lower == "horde" then
        return "Horde"
    end

    return ""
end

function ClassForge:GetUnitFaction(unit)
    if not unit or not UnitExists(unit) then
        return ""
    end

    return self:NormalizeFaction(UnitFactionGroup(unit))
end

function ClassForge:GetFactionText(data)
    local faction = data and self:NormalizeFaction(data.faction) or ""
    if faction == "Alliance" then
        return self:L("alliance")
    end
    if faction == "Horde" then
        return self:L("horde")
    end

    return self:L("unknown")
end

function ClassForge:HexToRGB(hex)
    local clean = self:SanitizeHex(hex) or "FFFFFF"
    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255

    return r / 255, g / 255, b / 255
end

function ClassForge:RGBToHex(red, green, blue)
    local function clampChannel(value)
        local numeric = tonumber(value) or 0
        if numeric < 0 then
            numeric = 0
        elseif numeric > 1 then
            numeric = 1
        end

        return math.floor((numeric * 255) + 0.5)
    end

    return string.format("%02X%02X%02X", clampChannel(red), clampChannel(green), clampChannel(blue))
end

function ClassForge:GetColoredClassText(data)
    if not data or not data.className then
        return "|cffffffff" .. self:L("unknown") .. "|r"
    end

    return string.format("|cff%s%s|r", self:SanitizeHex(data.color) or "FFFFFF", data.className)
end

function ClassForge:FormatUpdatedTime(timestamp)
    local numeric = tonumber(timestamp)
    if not numeric or numeric <= 0 then
        return self:L("unknown")
    end

    local diff = time() - numeric
    if diff <= 0 then
        return "0s"
    end
    if diff < 60 then
        return diff .. "s ago"
    end
    if diff < 3600 then
        return math.floor(diff / 60) .. "m ago"
    end
    if diff < 86400 then
        return math.floor(diff / 3600) .. "h ago"
    end
    if diff < 604800 then
        return math.floor(diff / 86400) .. "d ago"
    end

    return date("%Y-%m-%d %H:%M", numeric)
end

function ClassForge:GetSourceLabel(data)
    local source = data and data.source or nil

    if source == "self" then
        return self:L("you")
    end
    if source == "addon" then
        return self:L("addon")
    end
    if source == "who" then
        return "/who"
    end
    if source == "observed" then
        return self:L("observed")
    end

    return self:L("unknown")
end

function ClassForge:GetSourcePriority(source)
    local priorities = {
        self = 4,
        addon = 3,
        observed = 2,
        who = 1,
    }

    return priorities[source] or 0
end

function ClassForge:ParseVersionParts(version)
    local cleaned = self:Trim(version)
    local major, minor, patch = cleaned:match("^(%d+)%.(%d+)%.(%d+)$")
    if not major then
        return nil
    end

    return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
end

function ClassForge:CompareVersions(leftVersion, rightVersion)
    if leftVersion == rightVersion then
        return 0
    end

    local leftMajor, leftMinor, leftPatch = self:ParseVersionParts(leftVersion or "")
    local rightMajor, rightMinor, rightPatch = self:ParseVersionParts(rightVersion or "")

    if not leftMajor or not rightMajor then
        if tostring(leftVersion or "") == tostring(rightVersion or "") then
            return 0
        end

        return tostring(leftVersion or "") > tostring(rightVersion or "") and 1 or -1
    end

    if leftMajor ~= rightMajor then
        return leftMajor > rightMajor and 1 or -1
    end
    if leftMinor ~= rightMinor then
        return leftMinor > rightMinor and 1 or -1
    end
    if leftPatch ~= rightPatch then
        return leftPatch > rightPatch and 1 or -1
    end

    return 0
end

function ClassForge:IsConfirmedAddonUser(data)
    return data and (data.source == "addon" or data.source == "self")
end

function ClassForge:GetConfirmedAddonUserCount()
    local total = 0

    if not ClassForgeCache then
        return total
    end

    for _, data in pairs(ClassForgeCache) do
        if self:IsConfirmedAddonUser(data) then
            total = total + 1
        end
    end

    return total
end

function ClassForge:GetUpdatedTextColor(timestamp)
    local numeric = tonumber(timestamp)
    if not numeric or numeric <= 0 then
        return "|cffff4040"
    end

    local diff = time() - numeric
    if diff >= 7 * 24 * 60 * 60 then
        return "|cffff4040"
    end
    if diff >= 24 * 60 * 60 then
        return "|cffffcc00"
    end

    return "|cffffffff"
end

function ClassForge:FormatUpdatedTimeColored(timestamp)
    return self:GetUpdatedTextColor(timestamp) .. self:FormatUpdatedTime(timestamp) .. "|r"
end

function ClassForge:IsAutoWhoOnLoginEnabled()
    local profile = self:GetProfile()
    local sync = profile and profile.sync or nil

    if sync and sync.autoWhoOnLogin ~= nil then
        return sync.autoWhoOnLogin and true or false
    end

    return self.defaults.profile.sync.autoWhoOnLogin and true or false
end

function ClassForge:IsAutoWhoOnGroupEnabled()
    local profile = self:GetProfile()
    local sync = profile and profile.sync or nil

    if sync and sync.autoWhoOnGroup ~= nil then
        return sync.autoWhoOnGroup and true or false
    end

    return self.defaults.profile.sync.autoWhoOnGroup and true or false
end

function ClassForge:IsGroupFrameColoringEnabled()
    local profile = self:GetProfile()
    local colors = profile and profile.colors or nil

    if colors and colors.groupFrames ~= nil then
        return colors.groupFrames and true or false
    end

    return self.defaults.profile.colors.groupFrames and true or false
end

function ClassForge:IsTargetProfileCompact()
    local profile = self:GetProfile()
    local targetProfile = profile and profile.targetProfile or nil

    if targetProfile and targetProfile.compact ~= nil then
        return targetProfile.compact and true or false
    end

    return self.defaults.profile.targetProfile.compact and true or false
end

function ClassForge:IsMeterEnabled()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil

    if meter and meter.enabled ~= nil then
        return meter.enabled and true or false
    end

    return self.defaults.profile.meter.enabled and true or false
end

function ClassForge:IsMeterLocked()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil

    if meter and meter.locked ~= nil then
        return meter.locked and true or false
    end

    return self.defaults.profile.meter.locked and true or false
end

function ClassForge:IsMeterPersistent()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil

    if meter and meter.persistent ~= nil then
        return meter.persistent and true or false
    end

    return self.defaults.profile.meter.persistent and true or false
end

function ClassForge:GetMeterView()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local value = string.lower(self:Trim(meter and meter.view or ""))

    if value ~= "dps" and value ~= "threat" and value ~= "healing_done" and value ~= "healing_received" then
        value = string.lower(self.defaults.profile.meter.view or "dps")
    end

    return value ~= "" and value or "dps"
end

function ClassForge:GetMeterMaxRows()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local value = tonumber(meter and meter.maxRows)
    if not value then
        value = tonumber(self.defaults.profile.meter.maxRows) or 5
    end

    if value < 3 then
        value = 3
    elseif value > 50 then
        value = 50
    end

    return math.floor(value + 0.5)
end

function ClassForge:IsMeterSectionEnabled(key)
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local defaults = self.defaults.profile.meter

    if meter and meter[key] ~= nil then
        return meter[key] and true or false
    end

    return defaults[key] and true or false
end

function ClassForge:GetMeterExportType()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local exportType = self:Trim(meter and meter.exportType or "")
    if exportType == "" then
        exportType = self.defaults.profile.meter.exportType
    end

    return exportType
end

function ClassForge:GetMeterExportChannel()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil
    local channel = self:Trim(meter and meter.exportChannel or "")
    if channel == "" then
        channel = self.defaults.profile.meter.exportChannel
    end

    return channel
end

function ClassForge:IsMeterPetEnabled()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil

    if meter and meter.includePets ~= nil then
        return meter.includePets and true or false
    end

    return self.defaults.profile.meter.includePets and true or false
end

function ClassForge:IsMeterDebugEnabled()
    local profile = self:GetProfile()
    local meter = profile and profile.meter or nil

    if meter and meter.debug ~= nil then
        return meter.debug and true or false
    end

    return self.defaults.profile.meter.debug and true or false
end

function ClassForge:MeterDebug(message)
    if not self:IsMeterDebugEnabled() then
        return
    end

    self:Print("[Meter] " .. tostring(message or ""))
end

function ClassForge:GetCacheEntryCount()
    local total = 0

    if not ClassForgeCache then
        return total
    end

    for _ in pairs(ClassForgeCache) do
        total = total + 1
    end

    return total
end

function ClassForge:ClearCache(resetSelf)
    ClassForgeCache = {}

    if resetSelf then
        self:RefreshPlayerCache()
    end

    self:RefreshAllDisplays()
end

function ClassForge:ClearStaleCacheEntries(maxAgeSeconds)
    if not ClassForgeCache then
        return 0
    end

    local cutoff = time() - (tonumber(maxAgeSeconds) or 0)
    local removed = 0

    for key, data in pairs(ClassForgeCache) do
        local updated = tonumber(data and data.updated) or 0
        if updated > 0 and updated < cutoff then
            ClassForgeCache[key] = nil
            removed = removed + 1
        end
    end

    self:RefreshPlayerCache()
    self:RefreshAllDisplays()

    return removed
end

function ClassForge:MigrateDatabase()
    ClassForgeDB = ClassForgeDB or {}
    ClassForgeDB.profile = self:CopyDefaults(self.defaults.profile, ClassForgeDB.profile or {})
    ClassForgeDB.characters = ClassForgeDB.characters or {}
    ClassForgeCache = ClassForgeCache or {}

    local version = tonumber(ClassForgeDB.dbVersion) or 0

    if version < 1 then
        if ClassForgeDB.profile.targetProfileHidden ~= nil then
            ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
            ClassForgeDB.profile.targetProfile.hidden = ClassForgeDB.profile.targetProfileHidden and true or false
            ClassForgeDB.profile.targetProfileHidden = nil
        end
        if ClassForgeDB.profile.targetProfileLocked ~= nil then
            ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
            ClassForgeDB.profile.targetProfile.locked = ClassForgeDB.profile.targetProfileLocked and true or false
            ClassForgeDB.profile.targetProfileLocked = nil
        end
        version = 1
    end

    if version < 2 then
        ClassForgeDB.profile.names = ClassForgeDB.profile.names or {}
        if ClassForgeDB.profile.realmAware ~= nil and ClassForgeDB.profile.names.realmAware == nil then
            ClassForgeDB.profile.names.realmAware = ClassForgeDB.profile.realmAware and true or false
        end
        ClassForgeDB.profile.realmAware = nil
        version = 2
    end

    if version < 3 then
        local characterKey = self:GetCurrentCharacterKey()
        if characterKey and not ClassForgeDB.characters[characterKey] then
            ClassForgeDB.characters[characterKey] = self:CopyDefaults(self.defaults.character, {})
            ClassForgeDB.characters[characterKey].className = self:Trim(ClassForgeDB.profile.className) ~= "" and self:Trim(ClassForgeDB.profile.className) or self.defaults.character.className
            ClassForgeDB.characters[characterKey].color = self:SanitizeHex(ClassForgeDB.profile.color) or self.defaults.character.color
            ClassForgeDB.characters[characterKey].role = self:NormalizeRole(ClassForgeDB.profile.role) or self.defaults.character.role
            ClassForgeDB.characters[characterKey]._migratedFromLegacy = true
        end

        ClassForgeDB.profile.className = nil
        ClassForgeDB.profile.color = nil
        ClassForgeDB.profile.role = nil
        ClassForgeDB.profile.order = nil
        version = 3
    end

    if version < 4 then
        for _, characterData in pairs(ClassForgeDB.characters) do
            if type(characterData) == "table" then
                characterData.order = nil
                characterData.faction = nil
            end
        end

        ClassForgeDB.profile.order = nil
        version = 4
    end

    if version < 5 then
        ClassForgeDB.profile.sync = self:CopyDefaults(self.defaults.profile.sync, ClassForgeDB.profile.sync or {})
        ClassForgeDB.profile.colors = self:CopyDefaults(self.defaults.profile.colors, ClassForgeDB.profile.colors or {})
        ClassForgeDB.profile.targetProfile = self:CopyDefaults(self.defaults.profile.targetProfile, ClassForgeDB.profile.targetProfile or {})
        version = 5
    end

    if version < 8 then
        for _, characterData in pairs(ClassForgeDB.characters) do
            if type(characterData) == "table" then
                if characterData.description == nil then
                    characterData.description = ""
                end
                if type(characterData.spellHistory) ~= "table" then
                    characterData.spellHistory = {}
                end
            end
        end
        version = 8
    end

    if version < 9 then
        ClassForgeDB.profile.autoClass = ClassForgeDB.profile.autoClass or {}
        ClassForgeDB.profile.autoClass.maxLevel = 8
        version = 9
    end

    if version < 10 then
        ClassForgeDB.profile.autoClass = ClassForgeDB.profile.autoClass or {}
        ClassForgeDB.profile.autoClass.maxLevel = 1
        version = 10
    end

    local rebuiltCache = {}

    for key, data in pairs(ClassForgeCache) do
        if type(data) == "table" then
            local normalizedName = self:NormalizePlayerName(data.name or key)
            data.name = normalizedName or data.name or key
            data.color = self:SanitizeHex(data.color) or self.defaults.character.color
            data.role = self:NormalizeRole(data.role) or self.defaults.character.role
            data.className = self:Trim(data.className) ~= "" and self:Trim(data.className) or self.defaults.character.className
            data.description = self:Trim(data.description)
            data.faction = self:NormalizeFaction(data.faction)
            data.order = nil
            data.source = data.source or "observed"
            data.updated = tonumber(data.updated) or time()
            data.addonVersion = self:Trim(data.addonVersion)
            data.topSpells = self:Trim(data.topSpells)
            rebuiltCache[self:GetPlayerKey(data.name or key) or key] = data
        end
    end

    ClassForgeCache = rebuiltCache

    ClassForgeDB.dbVersion = math.max(self.dbVersion, version)
end

function ClassForge:GetDataForName(name)
    local key = self:GetPlayerKey(name)
    if not key or not ClassForgeCache then
        return nil
    end

    return ClassForgeCache[key]
end

function ClassForge:GetDataForUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then
        return nil
    end

    if UnitIsUnit(unit, "player") then
        return self:BuildProfileData()
    end

    local data = self:GetDataForName(UnitName(unit))
    if not data then
        return nil
    end

    local observedFaction = self:GetUnitFaction(unit)
    if observedFaction ~= "" and observedFaction ~= (data.faction or "") then
        local copy = {}
        for key, value in pairs(data) do
            copy[key] = value
        end
        copy.faction = observedFaction
        return copy
    end

    return data
end

function ClassForge:SetDataForName(name, data)
    local key = self:GetPlayerKey(name)
    local normalized = self:NormalizePlayerName(name)
    if not key or not normalized or not data then
        return nil
    end

    local existing = ClassForgeCache[key] or {}
    local incomingUpdated = tonumber(data.updated) or time()
    local existingUpdated = tonumber(existing.updated) or 0
    local incomingPriority = self:GetSourcePriority(data.source)
    local existingPriority = self:GetSourcePriority(existing.source)

    if UnitName("player") and key == self:GetPlayerKey(UnitName("player")) and data.source ~= "self" then
        return existing
    end

    if existingUpdated > incomingUpdated then
        return existing
    end

    if existingUpdated == incomingUpdated and existingPriority > incomingPriority then
        return existing
    end

    if existing.source == "addon" and data.source ~= "addon" and existingPriority > incomingPriority then
        return existing
    end

    ClassForgeCache[key] = {
        name = normalized,
        className = self:Trim(data.className) ~= "" and self:Trim(data.className) or existing.className or self.defaults.character.className,
        icon = self:GetResolvedIconTexture(data.icon, data.className, false) or existing.icon or "",
        description = self:Trim(data.description) ~= "" and self:Trim(data.description) or existing.description or "",
        color = self:SanitizeHex(data.color) or existing.color or self.defaults.character.color,
        role = self:NormalizeRole(data.role) or existing.role or self.defaults.character.role,
        faction = self:NormalizeFaction(data.faction) ~= "" and self:NormalizeFaction(data.faction) or existing.faction or "",
        topSpells = self:Trim(data.topSpells) ~= "" and self:Trim(data.topSpells) or existing.topSpells or "",
        addonVersion = self:Trim(data.addonVersion) ~= "" and self:Trim(data.addonVersion) or existing.addonVersion or "",
        updated = incomingUpdated,
        source = data.source or "observed",
    }

    return ClassForgeCache[key]
end

function ClassForge:GuessClassToken(className)
    local name = self:Trim(className)
    if name == "" then
        return nil
    end

    if RAID_CLASS_COLORS[name] then
        return name
    end

    local lowerName = string.lower(name)

    if LOCALIZED_CLASS_NAMES_MALE then
        for token, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
            if string.lower(localized) == lowerName then
                return token
            end
        end
    end

    if LOCALIZED_CLASS_NAMES_FEMALE then
        for token, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
            if string.lower(localized) == lowerName then
                return token
            end
        end
    end

    return nil
end

function ClassForge:GuessRoleFromClass(className)
    return self.defaults.character.role or "DPS"
end

function ClassForge:GuessColorFromClass(className)
    local token = self:GuessClassToken(className)
    local color = token and RAID_CLASS_COLORS[token] or nil

    if color then
        return string.format("%02X%02X%02X", color.r * 255, color.g * 255, color.b * 255)
    end

    return self.defaults.character.color
end
