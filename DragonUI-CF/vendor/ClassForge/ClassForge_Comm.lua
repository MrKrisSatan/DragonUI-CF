local function encodeField(value)
    value = tostring(value or "")
    value = value:gsub("%%", "%%25")
    value = value:gsub("|", "%%7C")
    return value
end

local function decodeField(value)
    value = tostring(value or "")
    value = value:gsub("%%7[Cc]", "|")
    value = value:gsub("%%25", "%%")
    return value
end

function ClassForge:SerializeData(data)
    return table.concat({
        "CF5",
        encodeField(self.version or "1.0.0"),
        encodeField(data.className or ""),
        encodeField(data.description or ""),
        encodeField(self:SanitizeHex(data.color) or self.defaults.character.color),
        encodeField(self:NormalizeRole(data.role) or self.defaults.character.role),
        encodeField(self:NormalizeFaction(data.faction)),
        encodeField(data.topSpells or ""),
        encodeField(self:NormalizeIconPath(data.icon) or ""),
    }, "|")
end

function ClassForge:GetThrottleValue(kind)
    local profile = self:GetProfile()
    local syncThrottle = profile and profile.syncThrottle or nil
    local value = syncThrottle and syncThrottle[kind] or nil

    return tonumber(value) or 0
end

function ClassForge:CanSendBroadcast(channel, target)
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0 } }

    local now = time()
    if channel == "WHISPER" then
        local key = self:GetPlayerKey(target)
        if not key then
            return false
        end

        local interval = self:GetThrottleValue("whisper")
        local lastSent = self.syncState.whispers[key] or 0
        if interval > 0 and (now - lastSent) < interval then
            return false
        end

        self.syncState.whispers[key] = now
        return true
    end

    local interval = self:GetThrottleValue("broadcast")
    local lastSent = self.syncState.broadcasts[channel] or 0
    if interval > 0 and (now - lastSent) < interval then
        return false
    end

    self.syncState.broadcasts[channel] = now
    return true
end

function ClassForge:CanRunWhoSync()
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0 } }

    local interval = self:GetThrottleValue("who")
    local now = time()
    local lastRun = self.syncState.who.lastRun or 0
    if interval > 0 and (now - lastRun) < interval then
        return false
    end

    self.syncState.who.lastRun = now
    return true
end

function ClassForge:DeserializeData(message)
    if type(message) ~= "string" then
        return nil
    end

    local protocol, addonVersion, className, description, color, role, faction, topSpells, icon = strsplit("|", message)

    if protocol == "CF5" then
        return {
            addonVersion = decodeField(addonVersion),
            className = decodeField(className),
            description = decodeField(description),
            color = decodeField(color),
            role = decodeField(role),
            faction = decodeField(faction),
            topSpells = decodeField(topSpells),
            icon = decodeField(icon),
            updated = time(),
            source = "addon",
        }
    end

    if protocol == "CF4" then
        return {
            addonVersion = decodeField(addonVersion),
            className = decodeField(className),
            description = decodeField(description),
            color = decodeField(color),
            role = decodeField(role),
            faction = decodeField(faction),
            topSpells = decodeField(topSpells),
            icon = "",
            updated = time(),
            source = "addon",
        }
    end

    if protocol == "CF3" then
        return {
            addonVersion = decodeField(addonVersion),
            className = decodeField(className),
            description = "",
            color = decodeField(color),
            role = decodeField(role),
            faction = decodeField(faction),
            topSpells = "",
            icon = "",
            updated = time(),
            source = "addon",
        }
    end

    if protocol == "CF2" then
        return {
            addonVersion = decodeField(addonVersion),
            className = decodeField(className),
            description = "",
            color = decodeField(color),
            role = decodeField(role),
            faction = "",
            topSpells = "",
            icon = "",
            updated = time(),
            source = "addon",
        }
    end

    if protocol == "CF1" then
        return {
            addonVersion = "1.0.0",
            className = decodeField(addonVersion),
            description = "",
            color = decodeField(className),
            role = decodeField(color),
            faction = "",
            topSpells = "",
            icon = "",
            updated = time(),
            source = "addon",
        }
    end

    return nil
end

function ClassForge:BroadcastSelf(channel, target)
    local profile = self:GetProfile()
    if not profile.enabled or not channel then
        return
    end

    if not self:CanSendBroadcast(channel, target) then
        return
    end

    local payload = self:SerializeData(self:RefreshPlayerCache())
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0, lastComplete = 0 }, lastSync = 0 }
    self.syncState.lastSync = time()
    SendAddonMessage(self.prefix, payload, channel, target)
end

function ClassForge:BroadcastStartup()
    self:BroadcastSelf("GUILD")
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:RequestSyncFromName(name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized or normalized == self:NormalizePlayerName(UnitName("player")) then
        return
    end

    self:BroadcastSelf("WHISPER", normalized)
end

function ClassForge:RequestSyncFromFriends()
    local total = GetNumFriends() or 0
    for index = 1, total do
        local friendName, _, friendClass = GetFriendInfo(index)
        if friendName and friendClass and not self:GetDataForName(friendName) then
            self:SetDataForName(friendName, {
                className = friendClass,
                color = self:GuessColorFromClass(friendClass),
                role = self:GuessRoleFromClass(friendClass),
                faction = "",
                updated = time(),
                source = "observed",
            })
        end

        if friendName then
            self:RequestSyncFromName(friendName)
        end
    end
end

function ClassForge:RequestSyncFromGuild()
    local total = GetNumGuildMembers and GetNumGuildMembers(true) or 0
    for index = 1, total do
        local fullName, _, _, _, className, _, _, _, online = GetGuildRosterInfo(index)
        if fullName and className and not self:GetDataForName(fullName) then
            self:SetDataForName(fullName, {
                className = className,
                color = self:GuessColorFromClass(className),
                role = self:GuessRoleFromClass(className),
                faction = "",
                updated = time(),
                source = "observed",
            })
        end

        if fullName and online then
            self:RequestSyncFromName(fullName)
        end
    end
end

function ClassForge:RequestSyncFromGroup()
    local hasRaid = (GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0) > 0

    if hasRaid then
        for index = 1, MAX_RAID_MEMBERS do
            local unit = "raid" .. index
            if UnitExists(unit) and UnitIsPlayer(unit) then
                local name = UnitName(unit)
                local className = select(2, UnitClass(unit))
                local localizedClass = select(1, UnitClass(unit))

                if name and localizedClass and not self:GetDataForName(name) then
                    self:SetDataForName(name, {
                        className = localizedClass,
                        color = self:GuessColorFromClass(localizedClass or className),
                        role = self:GuessRoleFromClass(localizedClass or className),
                        faction = self:GetUnitFaction(unit),
                        updated = time(),
                        source = "observed",
                    })
                end

                if name then
                    self:RequestSyncFromName(name)
                end
            end
        end

        return
    end

    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name = UnitName(unit)
            local className = select(2, UnitClass(unit))
            local localizedClass = select(1, UnitClass(unit))

            if name and localizedClass and not self:GetDataForName(name) then
                self:SetDataForName(name, {
                    className = localizedClass,
                    color = self:GuessColorFromClass(localizedClass or className),
                    role = self:GuessRoleFromClass(localizedClass or className),
                    faction = self:GetUnitFaction(unit),
                    updated = time(),
                    source = "observed",
                })
            end

            if name then
                self:RequestSyncFromName(name)
            end
        end
    end
end

function ClassForge:RequestSyncFromWho()
    local total = GetNumWhoResults() or 0
    for index = 1, total do
        local whoName = GetWhoInfo(index)
        if whoName then
            self:RequestSyncFromName(whoName)
        end
    end
end

function ClassForge:ProcessWhoResults()
    local total = GetNumWhoResults() or 0
    local queriedNames = {}

    for index = 1, total do
        local name, _, _, _, className = GetWhoInfo(index)
        if name and className then
            if not self:GetDataForName(name) then
                self:SetDataForName(name, {
                    className = className,
                    color = self:GuessColorFromClass(className),
                    role = self:GuessRoleFromClass(className),
                    faction = "",
                    updated = time(),
                    source = "who",
                })
            end

            if self.pendingWhoSync then
                queriedNames[#queriedNames + 1] = name
            end
        end
    end

    if self.pendingWhoSync then
        self.pendingWhoSync = nil
        for _, name in ipairs(queriedNames) do
            self:RequestSyncFromName(name)
        end
    end
end

function ClassForge:PrepareSilentWhoSync()
    self.silentWhoUIState = {
        friendsShown = FriendsFrame and FriendsFrame:IsShown() or false,
        whoShown = WhoFrame and WhoFrame:IsShown() or false,
    }

    if SetWhoToUI then
        SetWhoToUI(0)
    end
end

function ClassForge:RestoreSilentWhoSync()
    local state = self.silentWhoUIState
    if not state then
        return
    end

    if not state.friendsShown and FriendsFrame and FriendsFrame:IsShown() then
        if HideUIPanel then
            HideUIPanel(FriendsFrame)
        else
            FriendsFrame:Hide()
        end
    end

    if not state.whoShown and WhoFrame and WhoFrame:IsShown() then
        WhoFrame:Hide()
    end

    self.silentWhoUIState = nil
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0, lastComplete = 0 }, lastSync = 0 }
    self.syncState.who.lastComplete = time()
end

function ClassForge:PerformWhoSync()
    if not self:CanRunWhoSync() then
        return false
    end

    self.pendingWhoSync = true
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0, lastComplete = 0 }, lastSync = 0 }
    self.syncState.lastSync = time()
    self:PrepareSilentWhoSync()
    SendWho("")
    return true
end

function ClassForge:CHAT_MSG_ADDON(prefix, message, _, sender)
    if prefix ~= self.prefix or not sender then
        return
    end

    local data = self:DeserializeData(message)
    if not data then
        return
    end

    self:SetDataForName(sender, data)
    if data.addonVersion and data.addonVersion ~= "" and data.addonVersion ~= (self.version or "") then
        self.versionWarnings = self.versionWarnings or {}
        self.versionReminder = self.versionReminder or { lastAlert = 0, newestVersion = "" }
        local key = self:GetPlayerKey(sender)
        if key and not self.versionWarnings[key] then
            self.versionWarnings[key] = true
            local normalizedSender = self:NormalizePlayerName(sender) or sender
            if self:CompareVersions(data.addonVersion, self.version or "") > 0 then
                local now = time()
                if self:CompareVersions(data.addonVersion, self.versionReminder.newestVersion or "") > 0 then
                    self.versionReminder.newestVersion = data.addonVersion
                end

                if (now - (tonumber(self.versionReminder.lastAlert) or 0)) >= (30 * 60) then
                    self.versionReminder.lastAlert = now
                    self:Print(string.format(self:L("out_of_date"), (self.versionReminder.newestVersion or data.addonVersion), (self.version or self:L("unknown"))))
                    self:Print(self:L("downloads_label") .. ": " .. (self.releasesPage or self.homepage or "https://github.com/MrKrisSatan/ClassForge"))
                end
            else
                self:Print(string.format(self:L("newer_user"), normalizedSender, data.addonVersion, (self.version or self:L("unknown"))))
            end
        end
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
    self:RefreshAllDisplays()
end
