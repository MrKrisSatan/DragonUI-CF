ClassForge = ClassForge or {}

ClassForge.name = "DragonUI-CF"
ClassForge.prefix = "CLASSFORGE"
ClassForge.version = "3.6.8"
ClassForge.dbVersion = 10
ClassForge.homepage = "https://github.com/MrKrisSatan/DragonUI-CF"
ClassForge.releasesPage = "https://github.com/MrKrisSatan/DragonUI-CF/releases"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

ClassForge.defaults = {
    character = {
        className = "Hero",
        icon = "",
        color = "FFD100",
        role = "DPS",
        description = "",
        spellHistory = {},
        autoClassManualOverride = false,
        autoClassSignature = "",
    },
    profile = {
        enabled = true,
        locale = "en",
        targetProfilePosition = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -20,
        },
        targetProfile = {
            hidden = false,
            locked = false,
            compact = false,
        },
        meterPosition = {
            point = "CENTER",
            relativePoint = "CENTER",
            x = 320,
            y = 40,
        },
        meterSize = {
            width = 520,
            height = 180,
        },
        minimapButton = {
            angle = 225,
            hidden = false,
        },
        meter = {
            enabled = true,
            locked = false,
            view = "dps",
            persistent = false,
            includePets = true,
            debug = false,
            maxRows = 5,
            showDps = true,
            showTopSpell = true,
            showThreat = true,
            showHealing = true,
            exportType = "PARTY",
            exportChannel = "world",
        },
        chat = {
            enabled = false,
        },
        names = {
            realmAware = false,
        },
        syncThrottle = {
            broadcast = 10,
            whisper = 20,
            who = 30,
        },
        sync = {
            autoWhoOnLogin = true,
            autoWhoOnGroup = true,
        },
        colors = {
            groupFrames = true,
        },
        autoClass = {
            enabled = true,
            maxLevel = 1,
            debug = false,
        },
    },
}

local FALLBACK_CLASS_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local NAMED_CLASS_ICON_SPELLS = {
    ["Death Knight"] = "Death Coil",
    ["Druid"] = "Moonfire",
    ["Hunter"] = "Arcane Shot",
    ["Mage"] = "Frostbolt",
    ["Paladin"] = "Holy Light",
    ["Priest"] = "Power Word: Shield",
    ["Rogue"] = "Sinister Strike",
    ["Shaman"] = "Lightning Bolt",
    ["Warlock"] = "Shadow Bolt",
    ["Warrior"] = "Heroic Strike",
    ["Spell Breaker"] = "Counterspell",
    ["Abyss Walker"] = "Shadow Bolt",
    ["Bloodbinder"] = "Death Coil",
    ["Chronomancer"] = "Arcane Missiles",
    ["Grave Warden"] = "Death and Decay",
    ["Storm Herald"] = "Chain Lightning",
    ["Runesmith"] = "Rune Strike",
    ["Soul Weaver"] = "Drain Soul",
    ["Beast Warden"] = "Mongoose Bite",
    ["Voidcaller"] = "Mind Blast",
    ["Sun Cleric"] = "Holy Nova",
    ["Frostbinder"] = "Frostbolt",
    ["Ashbringer"] = "Consecration",
    ["Hexblade"] = "Curse of Agony",
    ["Spirit Dancer"] = "Rip",
    ["Iron Vanguard"] = "Shield Slam",
    ["Plaguebringer"] = "Plague Strike",
    ["Starcaller"] = "Starfall",
    ["Shadow Duelist"] = "Backstab",
    ["Ember Knight"] = "Fire Blast",
    ["Tide Sage"] = "Chain Heal",
    ["Bone Oracle"] = "Raise Dead",
    ["Thunder Reaver"] = "Stormstrike",
    ["Nether Alchemist"] = "Arcane Explosion",
    ["Wildheart"] = "Claw",
    ["Doom Harbinger"] = "Immolate",
}
local KEYWORD_CLASS_ICONS = {
    { keyword = "death knight", icon = "Interface\\Icons\\Spell_DeathKnight_ClassIcon" },
    { keyword = "druid", icon = "Interface\\Icons\\Ability_Druid_Maul" },
    { keyword = "hunter", icon = "Interface\\Icons\\Ability_Hunter_RunningShot" },
    { keyword = "mage", icon = "Interface\\Icons\\Spell_Frost_FrostBolt02" },
    { keyword = "paladin", icon = "Interface\\Icons\\Spell_Holy_HolyBolt" },
    { keyword = "priest", icon = "Interface\\Icons\\Spell_Holy_PowerWordShield" },
    { keyword = "rogue", icon = "Interface\\Icons\\Ability_BackStab" },
    { keyword = "shaman", icon = "Interface\\Icons\\Spell_Nature_Lightning" },
    { keyword = "warlock", icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt" },
    { keyword = "warrior", icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance" },
    { keyword = "spell breaker", icon = "Interface\\Icons\\Spell_Arcane_Blast" },
    { keyword = "abyss", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain" },
    { keyword = "blood", icon = "Interface\\Icons\\Spell_DeathKnight_BloodPresence" },
    { keyword = "chrono", icon = "Interface\\Icons\\Spell_Arcane_Arcane03" },
    { keyword = "grave", icon = "Interface\\Icons\\Spell_Shadow_DeathAndDecay" },
    { keyword = "storm", icon = "Interface\\Icons\\Spell_Nature_ChainLightning" },
    { keyword = "thunder", icon = "Interface\\Icons\\Spell_Nature_ThunderClap" },
    { keyword = "rune", icon = "Interface\\Icons\\INV_Sword_62" },
    { keyword = "soul", icon = "Interface\\Icons\\Spell_Shadow_Haunting" },
    { keyword = "beast", icon = "Interface\\Icons\\Ability_Hunter_BeastTaming" },
    { keyword = "wild", icon = "Interface\\Icons\\Ability_Druid_CatForm" },
    { keyword = "void", icon = "Interface\\Icons\\Spell_Shadow_MindTwisting" },
    { keyword = "sun", icon = "Interface\\Icons\\Spell_Holy_SearingLight" },
    { keyword = "light", icon = "Interface\\Icons\\Spell_Holy_HolyNova" },
    { keyword = "frost", icon = "Interface\\Icons\\Spell_Frost_FrostBolt02" },
    { keyword = "ice", icon = "Interface\\Icons\\Spell_Frost_IceShock" },
    { keyword = "ash", icon = "Interface\\Icons\\Spell_Fire_Fire" },
    { keyword = "ember", icon = "Interface\\Icons\\Spell_Fire_Incinerate" },
    { keyword = "magma", icon = "Interface\\Icons\\Spell_Fire_SelfDestruct" },
    { keyword = "fire", icon = "Interface\\Icons\\Spell_Fire_FlameBolt" },
    { keyword = "hex", icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde" },
    { keyword = "spirit", icon = "Interface\\Icons\\Ability_Rogue_Sprint" },
    { keyword = "iron", icon = "Interface\\Icons\\INV_Shield_06" },
    { keyword = "stone", icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem" },
    { keyword = "plague", icon = "Interface\\Icons\\Ability_Creature_Disease_02" },
    { keyword = "star", icon = "Interface\\Icons\\Ability_Druid_Starfall" },
    { keyword = "shadow", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain" },
    { keyword = "tide", icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental_2" },
    { keyword = "bone", icon = "Interface\\Icons\\INV_Misc_Bone_10" },
    { keyword = "nether", icon = "Interface\\Icons\\Spell_Arcane_ArcaneExplosion" },
    { keyword = "doom", icon = "Interface\\Icons\\Spell_Shadow_AuraOfDarkness" },
    { keyword = "hawk", icon = "Interface\\Icons\\Ability_Hunter_Pet_WindSerpent" },
    { keyword = "moon", icon = "Interface\\Icons\\Spell_Nature_StarFall" },
    { keyword = "venom", icon = "Interface\\Icons\\Ability_Poisons" },
    { keyword = "blight", icon = "Interface\\Icons\\Spell_Shadow_CreepingPlague" },
    { keyword = "root", icon = "Interface\\Icons\\Spell_Nature_StrangleVines" },
    { keyword = "arcane", icon = "Interface\\Icons\\Spell_Arcane_ArcaneMissiles" },
    { keyword = "fel", icon = "Interface\\Icons\\Spell_Fire_FelImmolation" },
    { keyword = "radiant", icon = "Interface\\Icons\\Ability_Paladin_InfusionofLight" },
    { keyword = "battle cleric", icon = "Interface\\Icons\\Spell_Holy_Renew" },
}

function ClassForge:NormalizeIconPath(icon)
    local value = self:Trim(icon)
    if value == "" then
        return nil
    end
    return value
end

function ClassForge:GetAutoClassPresetByName(className)
    local wanted = self:Trim(className)
    if wanted == "" then
        return nil
    end

    for _, preset in ipairs(self.autoClassPresets or {}) do
        if self:Trim(preset.name) == wanted then
            return preset
        end
    end

    return nil
end

function ClassForge:GetPresetRepresentativeSpell(preset)
    if type(preset) ~= "table" then
        return nil
    end

    local bestSpell
    local bestWeight = -math.huge

    local function considerSpell(spell, weight)
        local name = self:Trim(spell)
        if name == "" or not GetSpellInfo then
            return
        end

        local _, _, iconTexture = GetSpellInfo(name)
        if not iconTexture then
            return
        end

        weight = tonumber(weight) or 0
        if weight > bestWeight then
            bestWeight = weight
            bestSpell = name
        end
    end

    if type(preset.weights) == "table" then
        for spellName, weight in pairs(preset.weights) do
            considerSpell(spellName, weight)
        end
    end

    if type(preset.required) == "table" then
        for index, spellName in ipairs(preset.required) do
            considerSpell(spellName, 1000 - index)
        end
    end

    if type(preset.requiredAny) == "table" then
        for index, spellName in ipairs(preset.requiredAny) do
            considerSpell(spellName, 900 - index)
        end
    end

    local fallbackNamedSpell = NAMED_CLASS_ICON_SPELLS[self:Trim(preset.name)]
    if not bestSpell and fallbackNamedSpell then
        considerSpell(fallbackNamedSpell, 1)
    end

    return bestSpell
end

function ClassForge:GetPresetIconTexture(preset)
    if type(preset) ~= "table" then
        return FALLBACK_CLASS_ICON
    end

    local existingIcon = self:NormalizeIconPath(preset.icon)
    if existingIcon then
        return existingIcon
    end

    local representativeSpell = self:GetPresetRepresentativeSpell(preset)
    if representativeSpell and GetSpellInfo then
        local _, _, iconTexture = GetSpellInfo(representativeSpell)
        if iconTexture and iconTexture ~= "" then
            preset.icon = iconTexture
            return iconTexture
        end
    end

    preset.icon = FALLBACK_CLASS_ICON
    return preset.icon
end

function ClassForge:GetKeywordIconTexture(className)
    local normalizedName = string.lower(self:Trim(className))
    if normalizedName == "" then
        return nil
    end

    for _, entry in ipairs(KEYWORD_CLASS_ICONS) do
        if string.find(normalizedName, entry.keyword, 1, true) then
            return entry.icon
        end
    end

    return nil
end

function ClassForge:GetResolvedIconTexture(icon, className, allowFallback)
    local explicitIcon = self:NormalizeIconPath(icon)
    if explicitIcon then
        return explicitIcon
    end

    local preset = self:GetAutoClassPresetByName(className)
    if preset then
        return self:GetPresetIconTexture(preset)
    end

    local fallbackSpell = NAMED_CLASS_ICON_SPELLS[self:Trim(className)]
    if fallbackSpell and GetSpellInfo then
        local _, _, iconTexture = GetSpellInfo(fallbackSpell)
        if iconTexture and iconTexture ~= "" then
            return iconTexture
        end
    end

    local keywordIcon = self:GetKeywordIconTexture(className)
    if keywordIcon then
        return keywordIcon
    end

    if allowFallback then
        return FALLBACK_CLASS_ICON
    end

    return nil
end

function ClassForge:GetCurrentClassIconTexture()
    local profile = self:GetCharacterProfile()
    return self:GetResolvedIconTexture(profile and profile.icon, profile and profile.className, true)
end

local registeredEvents = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_LEVEL_UP",
    "PLAYER_TALENT_UPDATE",
    "PLAYER_ROLES_ASSIGNED",
    "ACTIVE_TALENT_GROUP_CHANGED",
    "SPELLS_CHANGED",
    "LEARNED_SPELL_IN_TAB",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_COMBAT",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_HEALTH",
    "CHAT_MSG_ADDON",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_COMBAT_SELF_HITS",
    "CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
    "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
    "CHAT_MSG_SPELL_SELF_DAMAGE",
    "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
    "GROUP_ROSTER_UPDATE",
    "GUILD_ROSTER_UPDATE",
    "PLAYER_GUILD_UPDATE",
    "PLAYER_TARGET_CHANGED",
    "WHO_LIST_UPDATE",
    "FRIENDLIST_UPDATE",
    "INSPECT_READY",
}

for _, eventName in ipairs(registeredEvents) do
    addon:RegisterEvent(eventName)
end

addon:SetScript("OnEvent", function(_, event, ...)
    local handler = ClassForge[event]
    if handler then
        handler(ClassForge, ...)
    end
end)

addon:SetScript("OnUpdate", function(_, elapsed)
    if ClassForge.UpdateAutoClassWatcher then
        ClassForge:UpdateAutoClassWatcher(elapsed)
    end
end)

ClassForge.translations = {
    en = {
        loaded = "Loaded. Type |cffffff00/cf help|r for commands.",
        class_label = "Class",
        role_label = "Role",
        role_auto_hint = "Uses your Blizzard-selected group role when available.",
        faction_label = "Faction",
        source_label = "Source",
        updated_label = "Updated",
        version_label = "Version",
        color_label = "Color",
        downloads_label = "Downloads",
        preview_label = "Preview",
        profile_tab = "Profile",
        display_tab = "Display",
        cache_tab = "Cache",
        meter_tab = "Meter",
        description_tab = "Description",
        class_info_tab = "Class Info",
        options_subtitle = "Custom class identities for Wrath 3.3.5a with sync, cache, and map support.",
        language = "Language",
        english = "English",
        spanish = "Spanish",
        russian = "Russian",
        custom_class_name = "Custom class name",
        class_description = "Class description",
        class_color_hex = "Class color hex",
        presets = "Presets",
        presets_hint = "Presets fill name, color, description.",
        pick = "Pick",
        save = "Save",
        clear_description = "Clear Description",
        undo_description = "Undo Description",
        sync = "Sync",
        reset = "Reset",
        refresh = "Refresh",
        tank = "Tank",
        healer = "Healer",
        damage = "Damage",
        alliance = "Alliance",
        horde = "Horde",
        you = "You",
        addon = "Addon",
        observed = "Observed",
        unknown = "Unknown",
        yes = "Yes",
        no = "No",
        on = "On",
        off = "Off",
        shown = "Shown",
        hidden = "Hidden",
        locked = "Locked",
        shift_drag = "Shift-drag",
        left_click_open = "Left-click: Open options",
        drag_move_button = "Drag: Move button",
        show_minimap_button = "Show minimap button",
        reset_minimap = "Reset Minimap",
        show_chat_tags = "Show custom class tags in party, raid, guild, and whisper chat",
        use_realm_aware = "Use realm-aware names when a realm suffix is present",
        auto_who_login = "Run background /who sync on login",
        auto_who_group = "Run background /who sync on group changes",
        show_target_panel = "Show target profile panel",
        lock_target_panel = "Lock target profile panel position",
        compact_target_panel = "Use compact target profile panel",
        color_group_frames = "Color party and raid frame names with custom class color",
        auto_class_low_level = "Auto-assign class preset from level 1 rerolled spells",
        reset_panel = "Reset Panel",
        panel_hint = "Hold Shift and drag the target profile when it is unlocked.",
        cached_players = "Cached players",
        database_schema = "Database schema",
        no_cached_players = "No cached players yet.",
        recent_entries = "Recent entries",
        clear_stale = "Clear Stale",
        clear_all = "Clear All",
        known_players = "Known Players",
        no_known_players = "No known players yet.",
        no_matching_players = "No matching players found.",
        addon_version = "Addon version",
        sync_protocol = "Sync protocol",
        last_sync = "Last sync",
        last_who = "Last /who",
        addon_users = "Addon users",
        use_sync_hint = "Use /cf sync to refresh your record and query nearby players.",
        minimap_button = "Minimap button",
        target_profile = "Target profile",
        compact = "Compact",
        group_colors = "Group colors",
        realm_aware_names = "Realm-aware names",
        profile_saved = "Profile saved.",
        language_updated = "Language updated.",
        meter_box = "Meter box",
        meter_persistent = "Keep main meter until reset",
        meter_mode_toggle = "Toggle segment/session mode",
        meter_mode_segment = "Current fight",
        meter_mode_session = "Since reset",
        meter_include_pets = "Include pet damage and healing",
        meter_debug = "Enable meter debug messages",
        meter_debug_on = "Meter debug ON",
        meter_debug_off = "Meter debug OFF",
        meter_filter_clear = "Clear selected spell",
        meter_click_segment = "Click a pie segment to focus that spell.",
        hits = "Hits",
        crits = "Crits",
        min = "Min",
        max = "Max",
        meter_view_dps = "Highest DPS",
        meter_view_threat = "Highest Threat",
        meter_view_healing_done = "Top Healing Done",
        meter_view_healing_received = "Top Healing Received",
        lock_meter = "Lock meter position",
        reset_meter = "Reset Meter",
        reset_meter_data = "Reset Data",
        meter_show_dps = "Show DPS rankings",
        meter_show_top_spell = "Show your top damage spell",
        meter_show_threat = "Show highest threat on target",
        meter_show_healing = "Show healing leader",
        meter_max_rows = "Max DPS rows",
        meter_size = "Size",
        meter_export = "Export Meter",
        meter_breakdown = "Spell Breakdown",
        meter_damage_spells = "Damage Spells",
        meter_healing_spells = "Healing Spells",
        meter_personal = "Personal",
        meter_group = "Group",
        inspect_tab = "DragonUI-CF",
        inspect_description = "Description",
        inspect_spells = "Most used spells",
        meter_contribution = "Contribution",
        meter_no_spells = "No spell data yet.",
        meter_export_target = "Export target",
        meter_export_channel = "Channel name",
        export_say = "Say",
        export_party = "Party",
        export_raid = "Raid",
        export_guild = "Guild",
        export_officer = "Officer",
        export_yell = "Yell",
        export_channel = "Channel",
        meter_hint = "Use DragonUI editor mode to move the meter. Drag the bottom-right corner to resize.",
        meter_waiting = "Waiting for combat data...",
        dps_rankings = "DPS Rankings",
        top_spell = "Top Spell",
        threat_leader = "Threat",
        healing_leader = "Healing",
        none = "None",
        out_of_date = "Your ClassForge version is out of date. Latest seen: %s. You are on %s.",
        newer_user = "%s is using ClassForge %s. Your version is %s.",
    },
    es = {
        loaded = "Cargado. Escribe |cffffff00/cf help|r para ver los comandos.",
        class_label = "Clase",
        role_label = "Rol",
        role_auto_hint = "Usa tu rol de grupo seleccionado en Blizzard cuando exista.",
        faction_label = "Facción",
        source_label = "Fuente",
        updated_label = "Actualizado",
        version_label = "Versión",
        color_label = "Color",
        downloads_label = "Descargas",
        preview_label = "Vista previa",
        profile_tab = "Perfil",
        display_tab = "Pantalla",
        cache_tab = "Caché",
        meter_tab = "Medidor",
        description_tab = "Descripcion",
        class_info_tab = "Info de clase",
        options_subtitle = "Identidades de clase personalizadas para Wrath 3.3.5a con sincronización, caché y soporte de mapa.",
        language = "Idioma",
        english = "Inglés",
        spanish = "Español",
        russian = "Ruso",
        custom_class_name = "Nombre de clase personalizado",
        class_description = "Descripcion de clase",
        class_color_hex = "Hex de color de clase",
        presets = "Predefinidos",
        presets_hint = "Rellenan nombre, color y descripcion.",
        pick = "Elegir",
        save = "Guardar",
        clear_description = "Borrar descripcion",
        undo_description = "Deshacer descripcion",
        sync = "Sincronizar",
        reset = "Restablecer",
        refresh = "Actualizar",
        tank = "Tanque",
        healer = "Sanador",
        damage = "Daño",
        alliance = "Alianza",
        horde = "Horda",
        you = "Tú",
        addon = "Addon",
        observed = "Observado",
        unknown = "Desconocido",
        yes = "Sí",
        no = "No",
        on = "Activado",
        off = "Desactivado",
        shown = "Mostrado",
        hidden = "Oculto",
        locked = "Bloqueado",
        shift_drag = "Mayús-arrastrar",
        left_click_open = "Clic izquierdo: Abrir opciones",
        drag_move_button = "Arrastrar: Mover botón",
        show_minimap_button = "Mostrar botón del minimapa",
        reset_minimap = "Restablecer minimapa",
        show_chat_tags = "Mostrar etiquetas de clase personalizada en chat de grupo, banda, hermandad y susurros",
        use_realm_aware = "Usar nombres con reino cuando haya un sufijo de reino",
        auto_who_login = "Ejecutar sincronización /who en segundo plano al entrar",
        auto_who_group = "Ejecutar sincronización /who en segundo plano al cambiar de grupo",
        show_target_panel = "Mostrar panel del objetivo",
        lock_target_panel = "Bloquear posición del panel del objetivo",
        compact_target_panel = "Usar panel de objetivo compacto",
        color_group_frames = "Colorear nombres de grupo y banda con el color de clase personalizado",
        auto_class_low_level = "Asignar automaticamente un predefinido segun hechizos cambiados de nivel 1",
        reset_panel = "Restablecer panel",
        panel_hint = "Mantén Mayús y arrastra el perfil del objetivo cuando esté desbloqueado.",
        cached_players = "Jugadores en caché",
        database_schema = "Esquema de base de datos",
        no_cached_players = "Todavía no hay jugadores en caché.",
        recent_entries = "Entradas recientes",
        clear_stale = "Limpiar antiguas",
        clear_all = "Limpiar todo",
        known_players = "Jugadores conocidos",
        no_known_players = "Todavía no hay jugadores conocidos.",
        no_matching_players = "No se encontraron jugadores coincidentes.",
        addon_version = "Versión del addon",
        sync_protocol = "Protocolo de sincronización",
        last_sync = "Última sincronización",
        last_who = "Último /who",
        addon_users = "Usuarios del addon",
        use_sync_hint = "Usa /cf sync para actualizar tu registro y consultar jugadores cercanos.",
        minimap_button = "Botón del minimapa",
        target_profile = "Perfil del objetivo",
        compact = "Compacto",
        group_colors = "Colores de grupo",
        realm_aware_names = "Nombres con reino",
        profile_saved = "Perfil guardado.",
        language_updated = "Idioma actualizado.",
        meter_box = "Caja del medidor",
        meter_persistent = "Mantener el medidor principal hasta restablecer",
        meter_mode_toggle = "Cambiar modo segmento/sesion",
        meter_mode_segment = "Combate actual",
        meter_mode_session = "Desde reinicio",
        meter_include_pets = "Incluir dano y sanacion de mascotas",
        meter_debug = "Activar mensajes de depuracion del medidor",
        meter_debug_on = "Depuracion del medidor ACTIVADA",
        meter_debug_off = "Depuracion del medidor DESACTIVADA",
        meter_filter_clear = "Quitar hechizo seleccionado",
        meter_click_segment = "Haz clic en un segmento para enfocar ese hechizo.",
        hits = "Golpes",
        crits = "Criticos",
        min = "Min",
        max = "Max",
        meter_view_dps = "Mayor DPS",
        meter_view_threat = "Mayor amenaza",
        meter_view_healing_done = "Más sanación hecha",
        meter_view_healing_received = "Más sanación recibida",
        lock_meter = "Bloquear posición del medidor",
        reset_meter = "Restablecer medidor",
        reset_meter_data = "Restablecer datos",
        meter_show_dps = "Mostrar clasificaciones de DPS",
        meter_show_top_spell = "Mostrar tu hechizo de mayor daño",
        meter_show_threat = "Mostrar mayor amenaza en el objetivo",
        meter_show_healing = "Mostrar líder de sanación",
        meter_max_rows = "Máx. filas de DPS",
        meter_size = "Tamaño",
        meter_export = "Exportar medidor",
        meter_breakdown = "Desglose de hechizos",
        meter_damage_spells = "Hechizos de daño",
        meter_healing_spells = "Hechizos de sanación",
        meter_personal = "Personal",
        meter_group = "Grupo",
        inspect_tab = "DragonUI-CF",
        inspect_description = "Descripcion",
        inspect_spells = "Hechizos mas usados",
        meter_contribution = "Contribución",
        meter_no_spells = "Aún no hay datos de hechizos.",
        meter_export_target = "Destino de exportación",
        meter_export_channel = "Nombre del canal",
        export_say = "Decir",
        export_party = "Grupo",
        export_raid = "Banda",
        export_guild = "Hermandad",
        export_officer = "Oficial",
        export_yell = "Gritar",
        export_channel = "Canal",
        meter_hint = "Usa el modo editor de DragonUI para mover el medidor. Arrastra la esquina inferior derecha para cambiar el tamaño.",
        meter_waiting = "Esperando datos de combate...",
        dps_rankings = "Clasificación DPS",
        top_spell = "Mejor hechizo",
        threat_leader = "Amenaza",
        healing_leader = "Sanación",
        none = "Ninguno",
        out_of_date = "Tu versión de ClassForge está desactualizada. La más nueva detectada es %s. Tú tienes %s.",
        newer_user = "%s está usando ClassForge %s. Tu versión es %s.",
    },
    ru = {
        loaded = "Аддон загружен. Введите |cffffff00/cf help|r для списка команд.",
        class_label = "Класс",
        role_label = "Роль",
        role_auto_hint = "Использует выбранную в Blizzard роль группы, если она задана.",
        faction_label = "Фракция",
        source_label = "Источник",
        updated_label = "Обновлено",
        version_label = "Версия",
        color_label = "Цвет",
        downloads_label = "Загрузка",
        preview_label = "Предпросмотр",
        profile_tab = "Профиль",
        display_tab = "Отображение",
        cache_tab = "Кэш",
        meter_tab = "Метр",
        description_tab = "Описание",
        class_info_tab = "Инфо класса",
        options_subtitle = "Пользовательские классы для Wrath 3.3.5a с синхронизацией, кэшем и поддержкой карты.",
        language = "Язык",
        english = "Английский",
        spanish = "Испанский",
        russian = "Русский",
        custom_class_name = "Пользовательское имя класса",
        class_description = "Описание класса",
        class_color_hex = "Hex цвета класса",
        presets = "Пресеты",
        presets_hint = "Имя, цвет и описание.",
        pick = "Выбрать",
        save = "Сохранить",
        clear_description = "Очистить описание",
        undo_description = "Отменить описание",
        sync = "Синхронизация",
        reset = "Сброс",
        refresh = "Обновить",
        tank = "Танк",
        healer = "Лекарь",
        damage = "Урон",
        alliance = "Альянс",
        horde = "Орда",
        you = "Вы",
        addon = "Addon",
        observed = "Наблюдение",
        unknown = "Неизвестно",
        yes = "Да",
        no = "Нет",
        on = "Включено",
        off = "Выключено",
        shown = "Показано",
        hidden = "Скрыто",
        locked = "Закреплено",
        shift_drag = "Shift-перетащить",
        left_click_open = "Левый клик: открыть настройки",
        drag_move_button = "Перетаскивание: двигать кнопку",
        show_minimap_button = "Показывать кнопку у миникарты",
        reset_minimap = "Сброс миникарты",
        show_chat_tags = "Показывать метки пользовательского класса в группе, рейде, гильдии и шепоте",
        use_realm_aware = "Использовать имена с миром при наличии суффикса мира",
        auto_who_login = "Запуск фонового /who при входе",
        auto_who_group = "Запуск фонового /who при изменении группы",
        show_target_panel = "Показывать панель цели",
        lock_target_panel = "Закрепить панель цели",
        compact_target_panel = "Использовать компактную панель цели",
        color_group_frames = "Красить имена группы и рейда цветом пользовательского класса",
        auto_class_low_level = "Автоматически выбирать пресет по переброшенным заклинаниям 1 уровня",
        reset_panel = "Сброс панели",
        panel_hint = "Удерживайте Shift и перетаскивайте профиль цели, когда он не закреплен.",
        cached_players = "Игроки в кэше",
        database_schema = "Схема базы данных",
        no_cached_players = "Пока нет игроков в кэше.",
        recent_entries = "Последние записи",
        clear_stale = "Очистить старое",
        clear_all = "Очистить все",
        known_players = "Известные игроки",
        no_known_players = "Пока нет известных игроков.",
        no_matching_players = "Совпадений не найдено.",
        addon_version = "Версия аддона",
        sync_protocol = "Протокол синхронизации",
        last_sync = "Последняя синхронизация",
        last_who = "Последний /who",
        addon_users = "Пользователи аддона",
        use_sync_hint = "Используйте /cf sync для обновления своей записи и поиска ближайших игроков.",
        minimap_button = "Кнопка миникарты",
        target_profile = "Профиль цели",
        compact = "Компактно",
        group_colors = "Цвета группы",
        realm_aware_names = "Имена с миром",
        profile_saved = "Профиль сохранен.",
        language_updated = "Язык обновлен.",
        meter_box = "Окно метра",
        meter_persistent = "Сохранять основной метр до сброса",
        meter_mode_toggle = "Переключить режим сегмент/сессия",
        meter_mode_segment = "Текущий бой",
        meter_mode_session = "С момента сброса",
        meter_include_pets = "Учитывать урон и лечение питомцев",
        meter_debug = "Включить отладку метра",
        meter_debug_on = "Отладка метра ВКЛ",
        meter_debug_off = "Отладка метра ВЫКЛ",
        meter_filter_clear = "Сбросить выбранное заклинание",
        meter_click_segment = "Щелкните по сектору, чтобы выбрать это заклинание.",
        hits = "Попадания",
        crits = "Криты",
        min = "Мин",
        max = "Макс",
        meter_view_dps = "Наивысший DPS",
        meter_view_threat = "Наивысшая угроза",
        meter_view_healing_done = "Лучшее исцеление",
        meter_view_healing_received = "Больше всего получено исцеления",
        lock_meter = "Закрепить положение метра",
        reset_meter = "Сброс метра",
        reset_meter_data = "Сброс данных",
        meter_show_dps = "Показывать рейтинг DPS",
        meter_show_top_spell = "Показывать ваше самое сильное заклинание",
        meter_show_threat = "Показывать лидера угрозы на цели",
        meter_show_healing = "Показывать лидера лечения",
        meter_max_rows = "Макс. строк DPS",
        meter_size = "Размер",
        meter_export = "Экспорт метра",
        meter_breakdown = "Разбор заклинаний",
        meter_damage_spells = "Заклинания урона",
        meter_healing_spells = "Заклинания лечения",
        meter_personal = "Личное",
        meter_group = "Группа",
        inspect_tab = "DragonUI-CF",
        inspect_description = "Описание",
        inspect_spells = "Частые заклинания",
        meter_contribution = "Вклад",
        meter_no_spells = "Пока нет данных по заклинаниям.",
        meter_export_target = "Куда экспортировать",
        meter_export_channel = "Имя канала",
        export_say = "Сказать",
        export_party = "Группа",
        export_raid = "Рейд",
        export_guild = "Гильдия",
        export_officer = "Офицеры",
        export_yell = "Крик",
        export_channel = "Канал",
        meter_hint = "Используйте режим редактора DragonUI для перемещения счетчика. Тяните нижний правый угол, чтобы изменить размер.",
        meter_waiting = "Ожидание данных боя...",
        dps_rankings = "Рейтинг DPS",
        top_spell = "Лучшее заклинание",
        threat_leader = "Угроза",
        healing_leader = "Лечение",
        none = "Нет",
        out_of_date = "Ваша версия ClassForge устарела. Самая новая замеченная: %s. У вас %s.",
        newer_user = "%s использует ClassForge %s. Ваша версия %s.",
    },
}

function ClassForge:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff1784d1DragonUI-CF|r: " .. tostring(message))
end

function ClassForge:GetLanguage()
    local profile = self:GetProfile()
    local locale = profile and profile.locale or nil
    if self.translations[locale] then
        return locale
    end
    return "en"
end

function ClassForge:SetLanguage(locale)
    if not self.translations[locale] then
        locale = "en"
    end
    ClassForgeDB.profile.locale = locale
end

function ClassForge:L(key)
    local locale = self:GetLanguage()
    local tableForLocale = self.translations[locale] or self.translations.en
    return (tableForLocale and tableForLocale[key]) or (self.translations.en and self.translations.en[key]) or key
end

function ClassForge:GetRoleDisplayText(role)
    local normalized = self:NormalizeRole(role) or self.defaults.character.role
    if normalized == "Tank" then
        return self:L("tank")
    end
    if normalized == "Heal" then
        return self:L("healer")
    end

    return self:L("damage")
end

function ClassForge:SetCurrentRole(role)
    local normalized = self:NormalizeRole(role)
    if not normalized then
        return false
    end

    local characterProfile = self:GetCharacterProfile()
    if type(characterProfile) ~= "table" then
        return false
    end

    local changed = characterProfile.role ~= normalized
    characterProfile.role = normalized
    characterProfile.autoClassManualOverride = true

    if self.RefreshAutoClassWatcher then
        self:RefreshAutoClassWatcher()
    end

    self:RefreshPlayerCache()
    self:BroadcastStartup()
    self:RefreshAllDisplays()
    return changed, normalized
end

function ClassForge:GetProfile()
    return ClassForgeDB and ClassForgeDB.profile or self.defaults.profile
end

function ClassForge:GetCurrentCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName and GetRealmName() or nil

    playerName = self:Trim(playerName)
    realmName = self:GetNormalizedRealmName(realmName)

    if playerName == "" then
        return nil
    end

    if realmName and realmName ~= "" then
        return playerName .. "-" .. realmName
    end

    return playerName
end

function ClassForge:GetCharacterProfile()
    if not ClassForgeDB then
        return self.defaults.character
    end

    ClassForgeDB.characters = ClassForgeDB.characters or {}

    local characterKey = self:GetCurrentCharacterKey()
    if not characterKey then
        return self.defaults.character
    end

    ClassForgeDB.characters[characterKey] = self:CopyDefaults(self.defaults.character, ClassForgeDB.characters[characterKey] or {})
    return ClassForgeDB.characters[characterKey]
end

function ClassForge:EnsureCurrentCharacterProfile()
    local characterProfile = self:GetCharacterProfile()
    local globalProfile = self:GetProfile()

    if not characterProfile._migratedFromLegacy then
        local hasLegacyIdentity = globalProfile and (
            self:Trim(globalProfile.className) ~= ""
            or self:SanitizeHex(globalProfile.color)
            or self:NormalizeRole(globalProfile.role)
        )

        if hasLegacyIdentity then
            characterProfile.className = self:Trim(characterProfile.className) ~= "" and characterProfile.className or (self:Trim(globalProfile.className) ~= "" and self:Trim(globalProfile.className) or self.defaults.character.className)
            characterProfile.color = self:SanitizeHex(characterProfile.color) or self:SanitizeHex(globalProfile.color) or self.defaults.character.color
            characterProfile.role = self:NormalizeRole(characterProfile.role) or self:NormalizeRole(globalProfile.role) or self.defaults.character.role
            characterProfile.description = self:Trim(characterProfile.description) ~= "" and characterProfile.description or self:Trim(globalProfile.description)
        end

        characterProfile._migratedFromLegacy = true
    end

    return characterProfile
end

function ClassForge:IsAutoClassEnabled()
    local profile = self:GetProfile()
    local autoClass = profile and profile.autoClass or nil
    if autoClass and autoClass.enabled ~= nil then
        return autoClass.enabled and true or false
    end

    return self.defaults.profile.autoClass.enabled and true or false
end

function ClassForge:SetAutoClassEnabled(enabled)
    if not ClassForgeDB then
        return
    end

    ClassForgeDB.profile = ClassForgeDB.profile or {}
    ClassForgeDB.profile.autoClass = ClassForgeDB.profile.autoClass or {}
    ClassForgeDB.profile.autoClass.enabled = enabled and true or false
end

function ClassForge:IsAutoClassDebugEnabled()
    local profile = self:GetProfile()
    local autoClass = profile and profile.autoClass or nil
    return autoClass and autoClass.debug and true or false
end

function ClassForge:SetAutoClassDebugEnabled(enabled)
    if not ClassForgeDB then
        return
    end

    ClassForgeDB.profile = ClassForgeDB.profile or {}
    ClassForgeDB.profile.autoClass = ClassForgeDB.profile.autoClass or {}
    ClassForgeDB.profile.autoClass.debug = enabled and true or false
end

function ClassForge:AutoClassDebug(message)
    if self:IsAutoClassDebugEnabled() then
        self:Print("|cffaaaaaaAutoClass:|r " .. tostring(message))
    end
end

function ClassForge:GetAutoClassMaxLevel()
    local profile = self:GetProfile()
    local autoClass = profile and profile.autoClass or nil
    return tonumber(autoClass and autoClass.maxLevel) or self.defaults.profile.autoClass.maxLevel or 1
end

function ClassForge:IsAutoClassEligible()
    if not self:IsAutoClassEnabled() then
        return false
    end

    if not UnitLevel then
        return false
    end

    local level = tonumber(UnitLevel("player")) or 0
    return level == 1
end

function ClassForge:ShouldWatchAutoClass()
    local level = UnitLevel and tonumber(UnitLevel("player")) or 0
    return level == 1 and self:IsAutoClassEnabled()
end

function ClassForge:RefreshAutoClassWatcher()
    self.autoClassWatchElapsed = 0
    self.autoClassWatcherActive = self:ShouldWatchAutoClass()
end

function ClassForge:UpdateAutoClassWatcher(elapsed)
    if self.pendingAutoClassRefresh then
        self.pendingAutoClassRefresh = self.pendingAutoClassRefresh - (tonumber(elapsed) or 0)
        if self.pendingAutoClassRefresh <= 0 then
            self.pendingAutoClassRefresh = nil
            self:ApplyAutoClassFromDetectedSpells(true)
        end
    end

    if not self.autoClassWatcherActive then
        return
    end

    if not self:ShouldWatchAutoClass() then
        self.autoClassWatcherActive = false
        return
    end

    self.autoClassWatchElapsed = (self.autoClassWatchElapsed or 0) + (tonumber(elapsed) or 0)
    if self.autoClassWatchElapsed < 3 then
        return
    end

    self.autoClassWatchElapsed = 0
    self:ApplyAutoClassFromDetectedSpells(true)
end

function ClassForge:QueueAutoClassRefresh(delay)
    if not self:IsAutoClassEligible() then
        self:AutoClassDebug("refresh ignored; ineligible or disabled")
        return
    end

    self.pendingAutoClassRefresh = tonumber(delay) or 0.25
    self.autoClassWatcherActive = true
    self:AutoClassDebug("refresh queued in " .. tostring(self.pendingAutoClassRefresh) .. "s")
end

function ClassForge:AddKnownSpellName(known, spellName)
    local name = self:Trim(spellName)
    if name == "" then
        return
    end

    name = string.gsub(name, "%s*%.+$", "")
    name = string.gsub(name, "%s*%b()$", "")
    name = string.gsub(name, "%s+Rank%s+%d+$", "")
    name = self:Trim(name)
    if name ~= "" then
        known[name] = true
    end
end

function ClassForge:BuildAutoClassSpellSnapshot()
    local known = {}

    if GetNumSpellTabs and GetSpellTabInfo and GetSpellName then
        for tabIndex = 1, (tonumber(GetNumSpellTabs()) or 0) do
            local _, _, offset, numSpells = GetSpellTabInfo(tabIndex)
            offset = tonumber(offset) or 0
            numSpells = tonumber(numSpells) or 0
            for spellIndex = offset + 1, offset + numSpells do
                self:AddKnownSpellName(known, GetSpellName(spellIndex, BOOKTYPE_SPELL or "spell"))
            end
        end
    end

    if GetSpellName then
        for spellIndex = 1, 128 do
            self:AddKnownSpellName(known, GetSpellName(spellIndex, BOOKTYPE_SPELL or "spell"))
        end
    end

    for buttonIndex = 1, 12 do
        local button = _G["SpellButton" .. buttonIndex]
        local buttonName = button and button:GetName()
        local nameRegion = buttonName and (_G[buttonName .. "SpellName"] or _G[buttonName .. "Name"])
        if nameRegion and nameRegion.GetText then
            self:AddKnownSpellName(known, nameRegion:GetText())
        end
    end

    return known
end

function ClassForge:CaptureAutoClassSpellSnapshot()
    self.autoClassKnownSpellSnapshot = self:BuildAutoClassSpellSnapshot()
end

function ClassForge:DetectNewAutoClassSpells()
    local oldSnapshot = self.autoClassKnownSpellSnapshot or {}
    local newSnapshot = self:BuildAutoClassSpellSnapshot()
    local gained = {}

    for spellName in pairs(newSnapshot) do
        if not oldSnapshot[spellName] then
            gained[#gained + 1] = spellName
        end
    end

    self.autoClassKnownSpellSnapshot = newSnapshot
    table.sort(gained)
    if #gained > 0 then
        self:AutoClassDebug("snapshot gained: " .. table.concat(gained, ", "))
    end
    return gained
end

function ClassForge:MergeRecentAutoClassSpells(spells, reset)
    if reset or type(self.recentAutoClassSpells) ~= "table" then
        self.recentAutoClassSpells = {}
    end

    local added = 0
    for _, spellName in ipairs(spells or {}) do
        local before = self:GetKnownSpellSignature(self.recentAutoClassSpells)
        self:AddKnownSpellName(self.recentAutoClassSpells, spellName)
        if before ~= self:GetKnownSpellSignature(self.recentAutoClassSpells) then
            added = added + 1
        end
    end

    return added
end

function ClassForge:GetKnownSpellSet()
    local known = {}
    local recentCount = 0
    for spellName in pairs(self.recentAutoClassSpells or {}) do
        recentCount = recentCount + 1
        self:AddKnownSpellName(known, spellName)
    end

    if recentCount > 0 then
        return known
    end

    return self:BuildAutoClassSpellSnapshot()
end

function ClassForge:GetKnownSpellSignature(known)
    local names = {}
    for spellName in pairs(known or {}) do
        names[#names + 1] = spellName
    end
    table.sort(names)
    return table.concat(names, "|")
end

function ClassForge:GetDynamicAutoClassPreset(known)
    local traits = {
        {
            key = "ranged",
            prefix = "Hawkeye",
            suffix = "Ranger",
            color = "AAD372",
            spells = { "Auto Shot", "Arcane Shot", "Steady Shot", "Concussive Shot", "Serpent Sting", "Hunter's Mark", "Aspect of the Hawk" },
            description = "a ranged skirmisher who reads the battlefield from a distance, turning marks, shots, and clean openings into steady pressure.",
        },
        {
            key = "beast",
            prefix = "Wildfang",
            suffix = "Stalker",
            color = "9ACD32",
            spells = { "Mongoose Bite", "Raptor Strike", "Aspect of the Monkey", "Tame Beast", "Track Beasts" },
            description = "a feral opportunist who survives through animal instinct, quick counters, and close-range bite.",
        },
        {
            key = "holy",
            prefix = "Sunlit",
            suffix = "Cleric",
            color = "FFDE59",
            spells = { "Smite", "Holy Light", "Power Word: Shield", "Power Word: Fortitude", "Renew", "Seal of Righteousness", "Blessing of Might" },
            description = "a light-bearing caster who folds faith, protection, and punishment into a practical combat rhythm.",
        },
        {
            key = "totem",
            prefix = "Earthbound",
            suffix = "Totemist",
            color = "20B2AA",
            spells = { "Strength of Earth Totem", "Searing Totem", "Stoneclaw Totem", "Stoneskin Totem", "Earthbind Totem", "Rockbiter Weapon" },
            description = "a totemic field-shaper who anchors the fight with earth, strength, and summoned elemental pressure.",
        },
        {
            key = "storm",
            prefix = "Stormbrand",
            suffix = "Invoker",
            color = "00BFFF",
            spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Lightning Shield", "Stormstrike", "Flametongue Weapon" },
            description = "a storm-touched striker who turns shocks, lightning, and weapon-channelled magic into a crackling tempo.",
        },
        {
            key = "shadow",
            prefix = "Voidscar",
            suffix = "Hexer",
            color = "6A0DAD",
            spells = { "Shadow Word: Pain", "Shadow Bolt", "Corruption", "Curse of Agony", "Drain Soul", "Mind Blast" },
            description = "a shadow-marked caster who lets pain, curses, and void pressure unravel enemies from the inside.",
        },
        {
            key = "fire",
            prefix = "Ember",
            suffix = "Pyrehand",
            color = "FF4500",
            spells = { "Fireball", "Fire Blast", "Immolate", "Flame Shock", "Searing Totem", "Flametongue Weapon" },
            description = "a fire-touched combatant who solves problems with heat, sudden bursts, and burning persistence.",
        },
        {
            key = "arcane",
            prefix = "Arcane",
            suffix = "Spellwright",
            color = "B87333",
            spells = { "Arcane Missiles", "Arcane Intellect", "Mage Armor", "Polymorph", "Frost Nova" },
            description = "a precise spellwright who leans on arcane force, control, and clean magical calculation.",
        },
        {
            key = "frost",
            prefix = "Frostbound",
            suffix = "Warden",
            color = "AFEEEE",
            spells = { "Frostbolt", "Frost Armor", "Frost Nova", "Icy Touch", "Frost Presence" },
            description = "a cold-blooded controller who uses chill, armor, and slowing pressure to keep the fight on their terms.",
        },
        {
            key = "blade",
            prefix = "Shadowcut",
            suffix = "Duelist",
            color = "2B2B2B",
            spells = { "Sinister Strike", "Backstab", "Gouge", "Eviscerate", "Slice and Dice", "Stealth", "Sprint" },
            description = "a close-range duelist who turns quick openings, dirty counters, and sudden blade work into momentum.",
        },
        {
            key = "warrior",
            prefix = "Iron",
            suffix = "Mauler",
            color = "C69B6D",
            spells = { "Heroic Strike", "Battle Stance", "Victory Rush", "Battle Shout", "Bloodrage", "Thunder Clap", "Sunder Armor" },
            description = "a weapon-first bruiser who survives on grit, pressure, and the stubborn logic of steel.",
        },
        {
            key = "nature",
            prefix = "Wildroot",
            suffix = "Mystic",
            color = "228B22",
            spells = { "Moonfire", "Wrath", "Entangling Roots", "Thorns", "Mark of the Wild", "Rejuvenation", "Cat Form" },
            description = "a nature-woven hybrid who blends wild magic, roots, and instinct into an adaptive fighting style.",
        },
        {
            key = "rune",
            prefix = "Runeblood",
            suffix = "Reaver",
            color = "C41E3A",
            spells = { "Blood Presence", "Blood Strike", "Plague Strike", "Icy Touch", "Death Coil", "Obliterate", "Death and Decay" },
            description = "a runic combatant who turns presence, disease, and deathly force into an early engine of pressure.",
        },
        {
            key = "healing",
            prefix = "Lifebound",
            suffix = "Mender",
            color = "00FF98",
            spells = { "Healing Wave", "Healing Touch", "Greater Heal", "Holy Light", "Renew", "Rejuvenation", "Power Word: Shield" },
            description = "a restorative survivor who keeps momentum alive through shields, healing, and patient recovery magic.",
        },
        {
            key = "tank",
            prefix = "Bulwark",
            suffix = "Vanguard",
            color = "708090",
            spells = { "Defensive Stance", "Bear Form", "Righteous Fury", "Devotion Aura", "Shield of Righteousness", "Stoneclaw Totem", "Frost Presence" },
            description = "a defensive front-liner who draws danger in and answers it with armor, stance, and stubborn presence.",
        },
    }

    local matches = {}
    for _, trait in ipairs(traits) do
        local count = 0
        local weight = 0
        for index, spellName in ipairs(trait.spells) do
            if known[spellName] then
                count = count + 1
                weight = weight + (20 - math.min(index, 15))
            end
        end
        if count > 0 then
            matches[#matches + 1] = {
                trait = trait,
                count = count,
                weight = weight,
            }
        end
    end

    table.sort(matches, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        if a.weight ~= b.weight then
            return a.weight > b.weight
        end
        return a.trait.key < b.trait.key
    end)

    if #matches < 2 then
        return nil
    end

    local primary = matches[1].trait
    local secondary = matches[2].trait
    return {
        name = primary.prefix .. " " .. secondary.suffix,
        color = primary.color or secondary.color or "FFD100",
        description = "The " .. primary.prefix .. " " .. secondary.suffix .. " is " .. primary.description .. " They also carry traces of " .. secondary.description .. " The result is not a traditional class, but a first draft of something stranger taking shape.",
        dynamic = true,
    }
end

function ClassForge:GetAutoClassPresetForKnownSpells(known)
    local bestPreset, bestScore = nil, 0
    local bestTieValue = -1
    local fallbackPreset, fallbackScore = nil, 0
    local fallbackTieValue = -1
    local signature = self:GetKnownSpellSignature(known)
    local bestCandidates = {}
    local fallbackCandidates = {}

    local function getSignatureHash(extra)
        local value = 0
        local text = signature .. "|" .. tostring(extra or "")
        for index = 1, string.len(text) do
            value = (value + string.byte(text, index) * (index + 11)) % 104729
        end

        return value
    end

    local function pickCandidate(candidates, topScore)
        local closeCandidates = {}
        for _, candidate in ipairs(candidates) do
            if candidate.score >= math.max(1, topScore - 3) then
                closeCandidates[#closeCandidates + 1] = candidate
            end
        end

        if #closeCandidates == 0 then
            return nil
        end

        table.sort(closeCandidates, function(left, right)
            if left.score ~= right.score then
                return left.score > right.score
            end
            if left.matchCount ~= right.matchCount then
                return left.matchCount > right.matchCount
            end
            return left.tieValue > right.tieValue
        end)

        local pickIndex = (getSignatureHash(topScore) % #closeCandidates) + 1
        return closeCandidates[pickIndex].preset
    end

    for index, preset in ipairs(self.autoClassPresets or {}) do
        local matchesRequired = true
        local matchedSpells = {}
        local matchCount = 0

        local function noteMatch(spellName)
            if spellName and known[spellName] and not matchedSpells[spellName] then
                matchedSpells[spellName] = true
                matchCount = matchCount + 1
            end
        end

        if preset.required then
            for _, spellName in ipairs(preset.required) do
                if known[spellName] then
                    noteMatch(spellName)
                else
                    matchesRequired = false
                    break
                end
            end
        end

        local requiredAnyMatches = 0
        if preset.requiredAny then
            for _, spellName in ipairs(preset.requiredAny) do
                if known[spellName] then
                    requiredAnyMatches = requiredAnyMatches + 1
                    noteMatch(spellName)
                end
            end
            if requiredAnyMatches == 0 then
                matchesRequired = false
            end
        end

        local score = matchesRequired and 20 or 0
        for spellName, weight in pairs(preset.weights or {}) do
            if known[spellName] then
                noteMatch(spellName)
                score = score + (tonumber(weight) or 1)
            end
        end
        score = score + (requiredAnyMatches * 3)

        local requiredMatchCount = tonumber(preset.minMatches) or 2
        if matchCount < requiredMatchCount then
            score = 0
        end

        local tieValue = 0
        local tieSource = signature .. "|" .. tostring(index) .. "|" .. tostring(preset.name)
        for i = 1, string.len(tieSource) do
            tieValue = (tieValue + string.byte(tieSource, i) * i) % 9973
        end

        if score > 0 then
            fallbackCandidates[#fallbackCandidates + 1] = {
                preset = preset,
                score = score,
                tieValue = tieValue,
                matchCount = matchCount,
            }
        end

        if score > fallbackScore or (score == fallbackScore and score > 0 and tieValue > fallbackTieValue) then
            fallbackPreset = preset
            fallbackScore = score
            fallbackTieValue = tieValue
        end

        if preset.minScore and score < preset.minScore then
            score = 0
        end

        if score > 0 then
            bestCandidates[#bestCandidates + 1] = {
                preset = preset,
                score = score,
                tieValue = tieValue,
                matchCount = matchCount,
            }
        end

        if score > bestScore or (score == bestScore and score > 0 and tieValue > bestTieValue) then
            bestPreset = preset
            bestScore = score
            bestTieValue = tieValue
        end
    end

    if bestScore > 0 then
        return pickCandidate(bestCandidates, bestScore) or bestPreset
    end

    if fallbackScore > 0 then
        return pickCandidate(fallbackCandidates, fallbackScore) or fallbackPreset
    end

    return self:GetDynamicAutoClassPreset(known)
end

function ClassForge:ApplyAutoClassFromDetectedSpells(force)
    local gained = self:DetectNewAutoClassSpells()
    if #gained > 0 then
        self:MergeRecentAutoClassSpells(gained, false)
    end

    return self:ApplyAutoClassFromKnownSpells(force)
end

function ClassForge:ApplyAutoClassFromKnownSpells(force)
    if not self:IsAutoClassEligible() then
        self:AutoClassDebug("apply skipped; level=" .. tostring(UnitLevel and UnitLevel("player") or "?") .. ", enabled=" .. tostring(self:IsAutoClassEnabled()))
        return false
    end

    local known = self:GetKnownSpellSet()
    local preset = self:GetAutoClassPresetForKnownSpells(known)
    if not preset then
        self:AutoClassDebug("no preset for: " .. (self:GetKnownSpellSignature(known) or ""))
        return false
    end

    local characterProfile = self:GetCharacterProfile()
    local signature = self:GetKnownSpellSignature(known)
    local presetIcon = self:GetPresetIconTexture(preset)
    if not force
        and characterProfile.autoClassSignature == signature
        and characterProfile.className == preset.name
        and characterProfile.color == preset.color
        and self:GetResolvedIconTexture(characterProfile.icon, characterProfile.className, true) == presetIcon then
        return false
    end

    characterProfile.className = preset.name
    characterProfile.icon = presetIcon
    characterProfile.color = preset.color
    characterProfile.description = preset.description or characterProfile.description or ""
    characterProfile.autoClassSignature = signature
    characterProfile.autoClassManualOverride = false

    self:AutoClassDebug("applied " .. tostring(preset.name) .. " from " .. tostring(signature))

    self:RefreshPlayerCache()
    self:BroadcastStartup()
    self:RefreshAllDisplays()
    return true
end

function ClassForge:BuildProfileData()
    local profile = self:GetCharacterProfile()

    return {
        className = self:Trim(profile.className) ~= "" and self:Trim(profile.className) or self.defaults.character.className,
        icon = self:GetCurrentClassIconTexture(),
        description = self:Trim(profile.description),
        color = self:SanitizeHex(profile.color) or self.defaults.character.color,
        role = self:GetCurrentRole(),
        faction = self:GetUnitFaction("player") or "",
        topSpells = self.GetPersistentTopSpellsSummary and self:GetPersistentTopSpellsSummary(5) or "",
        addonVersion = self.version,
        updated = time(),
        source = "self",
    }
end

function ClassForge:RefreshPlayerCache()
    local playerName = UnitName("player")
    if not playerName then
        return nil
    end

    local data = self:BuildProfileData()
    self:SetDataForName(playerName, data)

    return data
end

function ClassForge:RefreshDragonUIPortraits()
    if not _G.DragonUI then
        return
    end

    if _G.PlayerFrame and UnitExists("player") and UnitFramePortrait_Update then
        UnitFramePortrait_Update(_G.PlayerFrame, "player")
    end

    if _G.TargetFrame and UnitExists("target") and UnitIsPlayer("target") and UnitFramePortrait_Update then
        UnitFramePortrait_Update(_G.TargetFrame, "target")
    end

    if _G.FocusFrame and UnitExists("focus") and UnitIsPlayer("focus") and UnitFramePortrait_Update then
        UnitFramePortrait_Update(_G.FocusFrame, "focus")
    end
end

function ClassForge:RefreshAllDisplays()
    if self.UpdateCharacterPanel then
        self:UpdateCharacterPanel()
    end
    if self.UpdateWhoList then
        self:UpdateWhoList()
    end
    if self.UpdateGuildRoster then
        self:UpdateGuildRoster()
    end
    if self.UpdateFriendsList then
        self:UpdateFriendsList()
    end
    if self.UpdatePartyFrameColors then
        self:UpdatePartyFrameColors()
    end
    if self.UpdateRaidBrowser then
        self:UpdateRaidBrowser()
    end
    if self.UpdateTargetClassTag then
        self:UpdateTargetClassTag()
    end
    if self.UpdateTargetProfile then
        self:UpdateTargetProfile()
    end
    if self.UpdateInspectFrame then
        self:UpdateInspectFrame()
    end
    if self.UpdateMapMemberColors then
        self:UpdateMapMemberColors()
    end
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
    self:RefreshDragonUIPortraits()
end

function ClassForge:ADDON_LOADED(name)
    if name == self.name or name == "DragonUI" or name == "ClassForge" then
        ClassForgeDB = self:CopyDefaults(self.defaults, ClassForgeDB or {})
        ClassForgeCache = ClassForgeCache or {}
        self:MigrateDatabase()
        return
    end

    if name == "Blizzard_InspectUI" and self.SetupInspectHooks then
        self:SetupInspectHooks()
        self:UpdateInspectFrame()
    end
end

function ClassForge:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end

    self.syncState = {
        broadcasts = {},
        whispers = {},
        who = {
            lastRun = 0,
            lastComplete = 0,
        },
        lastSync = 0,
    }

    self:EnsureCurrentCharacterProfile()
    self:CaptureAutoClassSpellSnapshot()
    self:ApplyAutoClassFromKnownSpells()
    self:RefreshAutoClassWatcher()
    self:SetupSlashCommands()
    self:InitDisplay()
    if self.ResetMeterCombat then
        self:ResetMeterCombat()
    end
    self:RefreshPlayerCache()
    self:BroadcastStartup()
    self:RefreshAllDisplays()
end

function ClassForge:PLAYER_ENTERING_WORLD()
    self:CaptureAutoClassSpellSnapshot()
    self:ApplyAutoClassFromKnownSpells()
    self:RefreshAutoClassWatcher()
    if ShowFriends then
        ShowFriends()
    end
    if IsInGuild and IsInGuild() and GuildRoster then
        GuildRoster()
    end
    self:RequestSyncFromFriends()
    self:RequestSyncFromGuild()
    self:RequestSyncFromGroup()
    if self:IsAutoWhoOnLoginEnabled() then
        self:PerformWhoSync()
    end
end

function ClassForge:PLAYER_LEVEL_UP(level)
    if tonumber(level) and tonumber(level) > 1 then
        self.autoClassWatcherActive = false
        return
    end

    self:CaptureAutoClassSpellSnapshot()
    self:ApplyAutoClassFromKnownSpells()
    self:RefreshAutoClassWatcher()
end

function ClassForge:SPELLS_CHANGED()
    self:QueueAutoClassRefresh(1.5)
    self:RefreshAutoClassWatcher()
end

function ClassForge:LEARNED_SPELL_IN_TAB()
    self:QueueAutoClassRefresh(1.5)
    self:RefreshAutoClassWatcher()
end

function ClassForge:CHAT_MSG_SYSTEM(message)
    local text = self:Trim(message)
    if text == "" then
        return
    end

    if string.find(text, "You have learned a new", 1, true) then
        self.recentAutoClassSpells = self.recentAutoClassSpells or {}
        local spellName = string.match(text, "^You have learned a new ability:%s*(.+)$")
            or string.match(text, "^You have learned a new spell:%s*(.+)$")
        if spellName then
            local now = GetTime and GetTime() or time()
            local resetBurst = false
            if not self.recentAutoClassLastLearnedTime or (now - self.recentAutoClassLastLearnedTime) > 2 then
                resetBurst = true
            end
            self.recentAutoClassLastLearnedTime = now

            local spellCount = 0
            for _ in pairs(self.recentAutoClassSpells or {}) do
                spellCount = spellCount + 1
            end
            self:MergeRecentAutoClassSpells({ spellName }, resetBurst or spellCount >= 4)
            self:AutoClassDebug("learned: " .. tostring(spellName))

            spellCount = 0
            for _ in pairs(self.recentAutoClassSpells or {}) do
                spellCount = spellCount + 1
            end
            if spellCount >= 2 then
                self:ApplyAutoClassFromKnownSpells(true)
            end
        end
        self:QueueAutoClassRefresh(1.5)
    end
end

function ClassForge:GROUP_ROSTER_UPDATE()
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
    self:RequestSyncFromGroup()
    if self:IsAutoWhoOnGroupEnabled() then
        self:PerformWhoSync()
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0.05)
    end
end

function ClassForge:GUILD_ROSTER_UPDATE()
    if self.RequestSyncFromGuild then
        self:RequestSyncFromGuild()
    end
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_GUILD_UPDATE()
    self:BroadcastSelf("GUILD")
    if IsInGuild and IsInGuild() and GuildRoster then
        GuildRoster()
    end
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_TARGET_CHANGED()
    self:UpdateTargetClassTag()
    self:UpdateTargetProfile()
    self:UpdateInspectFrame()

    if UnitExists("target") and UnitIsPlayer("target") then
        local targetName = UnitName("target")
        if targetName then
            self:RequestSyncFromName(targetName)
        end
    end

    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
end

function ClassForge:WHO_LIST_UPDATE()
    self:ProcessWhoResults()
    if self.RestoreSilentWhoSync then
        self:RestoreSilentWhoSync()
    end
    self:UpdateWhoList()
end

function ClassForge:FRIENDLIST_UPDATE()
    if self.RequestSyncFromFriends then
        self:RequestSyncFromFriends()
    end
    self:UpdateFriendsList()
end

function ClassForge:INSPECT_READY()
    self:UpdateInspectFrame()
end

function ClassForge:RefreshRoleFromBlizzard()
    local storedRole = self:GetStoredCharacterRole()
    if storedRole then
        self:RefreshAllDisplays()
        return
    end

    local role = self:GetAssignedGroupRole("player")
    if not role then
        return
    end

    local characterProfile = self:GetCharacterProfile()
    if characterProfile.role ~= role then
        characterProfile.role = role
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
    else
        self:RefreshAllDisplays()
    end
end

function ClassForge:PLAYER_TALENT_UPDATE()
    self:RefreshRoleFromBlizzard()
end

function ClassForge:PLAYER_ROLES_ASSIGNED()
    self:RefreshRoleFromBlizzard()
end

function ClassForge:ACTIVE_TALENT_GROUP_CHANGED()
    self:RefreshRoleFromBlizzard()
end

function ClassForge:PLAYER_REGEN_DISABLED()
    if not self:IsMeterEnabled() then
        return
    end

    if self.ResetMeterCombat and not self:IsMeterPersistent() then
        self:ResetMeterCombat()
    end
    if self.EnsureMeterCombatActive then
        self:EnsureMeterCombatActive()
    end
    if self.SeedMeterParticipants then
        self:SeedMeterParticipants()
    end
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:PLAYER_REGEN_ENABLED()
    if not self:IsMeterEnabled() then
        return
    end

    if self.meterState and self.meterState.combat then
        self.meterState.combat.active = false
        self.meterState.combat.ended = (GetTime and GetTime()) or time()
    end
    self.pendingSpellDamage = {}
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:ConsumePendingMeleeSpell(destGUID)
    local pending = self.pendingSpellDamage
    if type(pending) ~= "table" or #pending == 0 then
        return nil
    end

    local now = (GetTime and GetTime()) or time()
    for index = #pending, 1, -1 do
        local item = pending[index]
        if (now - (item.started or now)) > 6 then
            table.remove(pending, index)
        elseif (now - (item.started or now)) <= 0.4 and (not destGUID or not item.targetGUID or item.targetGUID == destGUID) then
            table.remove(pending, index)
            return item.spell
        end
    end

    return nil
end

function ClassForge:ConsumeSwingOverride(destGUID, amount)
    local override = self.pendingSwingOverride
    if type(override) ~= "table" then
        return nil, nil
    end

    local now = (GetTime and GetTime()) or time()
    if (override.expires or 0) < now then
        self.pendingSwingOverride = nil
        return nil, nil
    end

    if destGUID and override.targetGUID and override.targetGUID ~= destGUID then
        return nil, nil
    end

    local overrideAmount = tonumber(override.amount) or 0
    local swingAmount = tonumber(amount) or 0
    if overrideAmount > 0 and (swingAmount <= 0 or math.abs(overrideAmount - swingAmount) <= 1) then
        self.pendingSwingOverride = nil
        return override.spell, overrideAmount
    end

    return nil, nil
end

function ClassForge:ProcessPendingSpellDamage(unit)
    local pending = self.pendingSpellDamage
    if type(pending) ~= "table" or #pending == 0 then
        return false
    end

    unit = unit or "target"
    if unit ~= "target" or not UnitExists(unit) then
        return false
    end

    local now = (GetTime and GetTime()) or time()
    local currentGUID = UnitGUID and UnitGUID(unit) or nil
    local currentHealth = UnitHealth and UnitHealth(unit) or nil
    if not currentHealth then
        return false
    end

    for index = #pending, 1, -1 do
        local item = pending[index]
        if (now - (item.started or now)) > 6 then
            table.remove(pending, index)
        elseif item.targetGUID and currentGUID and item.targetGUID ~= currentGUID then
            -- Keep waiting briefly in case the player swaps targets back.
        elseif currentHealth < (item.health or 0) then
            local delta = (item.health or 0) - currentHealth
            if delta > 0 and self.RecordMeterDamage then
                self:RecordMeterDamage(UnitName("player"), item.spell, delta, nil, UnitGUID and UnitGUID("player") or nil)
                self:MeterDebug("health fallback recorded " .. tostring(item.spell) .. " for " .. tostring(delta))
                table.remove(pending, index)
                return true
            end
            table.remove(pending, index)
        end
    end

    return false
end

function ClassForge:TryRecordSelfCombatText(message, periodic)
    if not self:IsMeterEnabled() or not message or message == "" or not self.RecordMeterDamage then
        return false
    end

    local playerName = UnitName("player") or ""
    local escapedPlayerName = string.gsub(playerName, "([^%w])", "%%%1")

    local function firstPositiveInteger(text)
        for numeric in string.gmatch(text or "", "(%d+)") do
            local amount = tonumber(numeric)
            if amount and amount > 0 then
                return amount
            end
        end

        return nil
    end

    local spellName, amount = string.match(message, "^Your (.+) hits .+ for (%d+)")
    if not spellName then
        spellName, amount = string.match(message, "^Your (.+) crits .+ for (%d+)")
    end
    if not spellName then
        spellName, amount = string.match(message, "^Your (.+) drains .+ for (%d+)")
    end
    if not spellName and periodic then
        spellName, amount = string.match(message, "^.+ suffers (%d+) .+ damage from your (.+)%.")
        if spellName and amount then
            spellName, amount = amount, spellName
        end
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) hits .+ for (%d+)")
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) crits .+ for (%d+)")
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) drains .+ for (%d+)")
    end

    local numericAmount = tonumber(amount)
    if spellName and numericAmount and numericAmount > 0 then
        local _, _, _, castTime, _, maxRange = GetSpellInfo and GetSpellInfo(spellName) or nil
        local isMeleeSpecial = false
        if castTime == 0 then
            local lowRange = tonumber(maxRange or 0) <= 5
            local lowerSpell = string.lower(spellName)
            local meleeHint = string.find(lowerSpell, "strike", 1, true)
                or string.find(lowerSpell, "slash", 1, true)
                or string.find(lowerSpell, "stab", 1, true)
            isMeleeSpecial = lowRange or meleeHint
        end

        if isMeleeSpecial then
            self.pendingSwingOverride = {
                spell = spellName,
                amount = numericAmount,
                targetGUID = UnitGUID and UnitGUID("target") or nil,
                expires = ((GetTime and GetTime()) or time()) + 0.6,
            }
            return true
        end

        self:RecordMeterDamage(UnitName("player"), spellName, numericAmount, nil, UnitGUID and UnitGUID("player") or nil)
        self:MeterDebug("chat fallback recorded " .. tostring(spellName) .. " for " .. tostring(numericAmount))
        if self.UpdateMeterPanel then
            self:UpdateMeterPanel()
        end
        return true
    end

    local pending = self.pendingSpellDamage
    if type(pending) == "table" and #pending > 0 then
        local pendingAmount = firstPositiveInteger(message)
        if pendingAmount and pendingAmount > 0 then
            local fallbackIndex = nil
            local fallbackItem = nil
            for index = #pending, 1, -1 do
                local item = pending[index]
                if item and item.spell then
                    local _, _, _, castTime, _, maxRange = GetSpellInfo and GetSpellInfo(item.spell) or nil
                    local isMeleeSpecial = false
                    if castTime == 0 then
                        local lowRange = tonumber(maxRange or 0) <= 5
                        local lowerSpell = string.lower(item.spell)
                        local meleeHint = string.find(lowerSpell, "strike", 1, true)
                            or string.find(lowerSpell, "slash", 1, true)
                            or string.find(lowerSpell, "stab", 1, true)
                        isMeleeSpecial = lowRange or meleeHint
                    end

                    if not fallbackItem and not isMeleeSpecial then
                        fallbackIndex = index
                        fallbackItem = item
                        fallbackItem.isMeleeSpecial = false
                    end
                end
            end

            if fallbackItem then
                table.remove(pending, fallbackIndex)
                self:RecordMeterDamage(UnitName("player"), fallbackItem.spell, pendingAmount, nil, UnitGUID and UnitGUID("player") or nil)
                self:MeterDebug("pending fallback recorded " .. tostring(fallbackItem.spell) .. " for " .. tostring(pendingAmount))
                if self.UpdateMeterPanel then
                    self:UpdateMeterPanel()
                end
                return true
            end
        end
    end

    return false
end

do
    local function toNumber(value)
        return tonumber(value) or 0
    end

    local function normalizePlayerSource(self, sourceGUID, sourceName)
        if not sourceName and UnitGUID and sourceGUID and sourceGUID == UnitGUID("player") then
            sourceName = UnitName("player")
        end

        local playerGUID = UnitGUID and UnitGUID("player") or nil
        local playerName = UnitName("player")
        if sourceName and (sourceName == "You" or sourceName == self:L("you")) and playerName then
            sourceName = playerName
        end
        if not sourceGUID and playerGUID and sourceName and playerName and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(playerName) then
            sourceGUID = playerGUID
        end

        return sourceGUID, sourceName
    end

    local function recordSwingDamage(self, _, _, sourceGUID, sourceName, sourceFlags, destGUID, _, _, ...)
        local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
        local damageAmount = toNumber(amount)
        local swingLabel = "Melee"

        if (sourceGUID and UnitGUID and sourceGUID == UnitGUID("player"))
            or (sourceName and UnitName("player") and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(UnitName("player"))) then
            local overrideLabel, overrideAmount = nil, nil
            if self.ConsumeSwingOverride then
                overrideLabel, overrideAmount = self:ConsumeSwingOverride(destGUID, damageAmount)
            end
            if overrideLabel then
                swingLabel = overrideLabel
                damageAmount = overrideAmount or damageAmount
            elseif self.ConsumePendingMeleeSpell then
                swingLabel = self:ConsumePendingMeleeSpell(destGUID) or swingLabel
            end
        end

        self:RecordMeterDamage(sourceName, swingLabel, damageAmount, sourceFlags, sourceGUID, {
            spellID = 6603,
            school = 1,
            overkill = toNumber(overkill),
            resisted = toNumber(resisted),
            blocked = toNumber(blocked),
            absorbed = toNumber(absorbed),
            critical = critical,
            glancing = glancing,
            crushing = crushing,
        })
    end

    local function recordSpellDamage(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
        self:RecordMeterDamage(sourceName, spellName, toNumber(amount), sourceFlags, sourceGUID, {
            spellID = spellID,
            school = spellSchool or school,
            overkill = toNumber(overkill),
            resisted = toNumber(resisted),
            blocked = toNumber(blocked),
            absorbed = toNumber(absorbed),
            critical = critical,
            glancing = glancing,
            crushing = crushing,
        })
    end

    local function recordSpellHeal(self, _, _, sourceGUID, sourceName, sourceFlags, _, destName, _, ...)
        local spellID, spellName, spellSchool, amount, overheal, absorbed, critical = ...
        self:RecordMeterHealing(sourceName, toNumber(amount), sourceFlags, sourceGUID, destName, spellName, {
            spellID = spellID,
            school = spellSchool,
            overheal = toNumber(overheal),
            absorbed = toNumber(absorbed),
            critical = critical,
        })
    end

    local function recordSpellMiss(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local spellID, spellName, spellSchool, missType = ...
        if self.RecordMeterMiss then
            self:RecordMeterMiss(sourceName, spellName, sourceFlags, sourceGUID, {
                spellID = spellID,
                school = spellSchool,
                missed = missType,
            })
        end
    end

    local function recordSwingMiss(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local missType = ...
        if self.RecordMeterMiss then
            self:RecordMeterMiss(sourceName, "Melee", sourceFlags, sourceGUID, {
                spellID = 6603,
                school = 1,
                missed = missType,
            })
        end
    end

    local meterCLEUHandlers = {
        SWING_DAMAGE = recordSwingDamage,
        SPELL_DAMAGE = recordSpellDamage,
        SPELL_PERIODIC_DAMAGE = recordSpellDamage,
        SPELL_BUILDING_DAMAGE = recordSpellDamage,
        RANGE_DAMAGE = recordSpellDamage,
        DAMAGE_SHIELD = recordSpellDamage,
        DAMAGE_SPLIT = recordSpellDamage,
        SPELL_HEAL = recordSpellHeal,
        SPELL_PERIODIC_HEAL = recordSpellHeal,
        SPELL_MISSED = recordSpellMiss,
        SPELL_PERIODIC_MISSED = recordSpellMiss,
        SPELL_BUILDING_MISSED = recordSpellMiss,
        RANGE_MISSED = recordSpellMiss,
        SWING_MISSED = recordSwingMiss,
    }

    function ClassForge:DispatchMeterCombatEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
        local handler = meterCLEUHandlers[eventType]
        if not handler then
            return false
        end

        sourceGUID, sourceName = normalizePlayerSource(self, sourceGUID, sourceName)
        handler(self, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
        return true
    end
end

function ClassForge:COMBAT_LOG_EVENT_UNFILTERED(...)
    if not self:IsMeterEnabled() then
        return
    end

    if not self.RecordMeterDamage or not self.RecordMeterHealing then
        return
    end

    local payload = { ... }
    local timestamp = nil
    local eventType = nil
    local sourceGUID = nil
    local sourceName = nil
    local sourceFlags = nil
    local destGUID = nil
    local destName = nil
    local destFlags = nil
    local extras = {}

    local function normalizeCombatPayload(raw)
        local normalized = {
            timestamp = raw[1],
            eventType = raw[2],
            sourceGUID = nil,
            sourceName = nil,
            sourceFlags = nil,
            destGUID = nil,
            destName = nil,
            destFlags = nil,
            extras = {},
        }

        if type(raw[3]) == "boolean" then
            normalized.sourceGUID = raw[4]
            normalized.sourceName = raw[5]
            normalized.sourceFlags = raw[6]
            normalized.destGUID = raw[8]
            normalized.destName = raw[9]
            normalized.destFlags = raw[10]
            for index = 12, #raw do
                normalized.extras[#normalized.extras + 1] = raw[index]
            end
        else
            normalized.sourceGUID = raw[3]
            normalized.sourceName = raw[4]
            normalized.sourceFlags = raw[5]
            normalized.destGUID = raw[6]
            normalized.destName = raw[7]
            normalized.destFlags = raw[8]
            for index = 9, #raw do
                normalized.extras[#normalized.extras + 1] = raw[index]
            end
        end

        return normalized
    end

    local normalized = normalizeCombatPayload(payload)
    timestamp = normalized.timestamp
    eventType = normalized.eventType
    sourceGUID = normalized.sourceGUID
    sourceName = normalized.sourceName
    sourceFlags = normalized.sourceFlags
    destGUID = normalized.destGUID
    destName = normalized.destName
    destFlags = normalized.destFlags
    extras = normalized.extras

    if not eventType and _G.arg2 then
        local raw = {}
        for index = 1, 30 do
            raw[index] = _G["arg" .. index]
        end
        normalized = normalizeCombatPayload(raw)
        timestamp = normalized.timestamp
        eventType = normalized.eventType
        sourceGUID = normalized.sourceGUID
        sourceName = normalized.sourceName
        sourceFlags = normalized.sourceFlags
        destGUID = normalized.destGUID
        destName = normalized.destName
        destFlags = normalized.destFlags
        extras = normalized.extras
    end

    if not eventType then
        return
    end

    if self.DispatchMeterCombatEvent then
        self:DispatchMeterCombatEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, unpack(extras))
    end

    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:UNIT_COMBAT(unit, action, descriptor, amount, damageType, ...)
    if not self:IsMeterEnabled() then
        return
    end

    if not unit or not self.RecordMeterDamage or not self.RecordMeterHealing then
        return
    end

    local isTrackedUnit = (unit == "player")
    if not isTrackedUnit then
        if string.find(unit, "^party%d+$") or string.find(unit, "^raid%d+$") then
            isTrackedUnit = true
        end
    end

    if not isTrackedUnit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return
    end

    local sourceName = UnitName(unit)
    local sourceGUID = UnitGUID and UnitGUID(unit) or nil
    local normalizedAction = self:Trim(action):upper()
    local args = { descriptor, amount, damageType, ... }
    local value = 0
    local label = nil

    for _, candidate in ipairs(args) do
        if value <= 0 then
            local numeric = tonumber(candidate)
            if numeric and numeric > 0 then
                value = numeric
            end
        end

        if not label and type(candidate) == "string" then
            local trimmed = self:Trim(candidate)
            if trimmed ~= "" and trimmed ~= unit and string.upper(trimmed) ~= normalizedAction then
                label = trimmed
            end
        end
    end

    label = label or (self:Trim(descriptor) ~= "" and self:Trim(descriptor)) or "Melee"

    if value <= 0 then
        return
    end

    if normalizedAction == "WOUND" then
        return
    elseif string.find(normalizedAction, "HEAL", 1, true) then
        self:RecordMeterHealing(sourceName, value, nil, sourceGUID, unit, label)
    elseif string.find(normalizedAction, "DAMAGE", 1, true)
        or normalizedAction == "SPELL"
        or normalizedAction == "HIT" then
        self:RecordMeterDamage(sourceName, label, value, nil, sourceGUID)
    else
        self:RecordMeterDamage(sourceName, label, value, nil, sourceGUID)
    end

    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:UNIT_SPELLCAST_SUCCEEDED(unit, spellName)
    if not self:IsMeterEnabled() or unit ~= "player" then
        return
    end

    if not spellName or self:Trim(spellName) == "" then
        return
    end

    if not UnitExists("target") or not UnitCanAttack("player", "target") or UnitIsDead("target") then
        return
    end

    local targetGUID = UnitGUID and UnitGUID("target") or nil
    local targetName = UnitName("target")
    local targetHealth = UnitHealth and UnitHealth("target") or nil
    local targetMaxHealth = UnitHealthMax and UnitHealthMax("target") or nil
    if not targetGUID or not targetName or not targetHealth or targetHealth <= 0 then
        return
    end

    self.pendingSpellDamage = type(self.pendingSpellDamage) == "table" and self.pendingSpellDamage or {}
    self.pendingSpellDamage[#self.pendingSpellDamage + 1] = {
        spell = spellName,
        targetGUID = targetGUID,
        targetName = targetName,
        health = targetHealth,
        maxHealth = targetMaxHealth or 0,
        started = (GetTime and GetTime()) or time(),
    }
end

function ClassForge:UNIT_HEALTH(unit)
    if not self:IsMeterEnabled() then
        return
    end

    if self.ProcessPendingSpellDamage and self:ProcessPendingSpellDamage(unit) then
        if self.UpdateMeterPanel then
            self:UpdateMeterPanel()
        end
    end
end

function ClassForge:CHAT_MSG_SPELL_SELF_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_COMBAT_SELF_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end
