ClassForge = ClassForge or {}

ClassForge.autoClassPresets = {
    {
        name = "Abyssal Dreadstorm",
        color = "6A0DAD",
        description = "A walking calamity clad in flesh and fury, the Abyssal Dreadstorm is a harbinger of ruin that blurs the line between blade and cataclysm. Drawing power from the howling void beneath reality, they weave brutal melee strikes with surging tides of abyssal energy, tearing through enemies in a relentless storm of steel and shadow. Each swing feeds the tempest within, building toward devastating spellbursts that crack the battlefield open like a wound. To face a Dreadstorm is not to duel a warrior, but to stand against an oncoming apocalypse given form.",
        required = { "Blood Presence", "Sinister Strike", "Flametongue Weapon", "Seal of Righteousness" },
        weights = { ["Blood Presence"] = 6, ["Sinister Strike"] = 6, ["Flametongue Weapon"] = 6, ["Seal of Righteousness"] = 6, ["Shadow Bolt"] = 2, ["Earth Shock"] = 2 },
        minScore = 24,
    },
    {
        name = "Stormbrand Striker",
        color = "00BFFF",
        description = "A crackling weapon-channeler, the Stormbrand Striker binds elemental force to every swing. Flametongue, Stormstrike, and sudden shocks turn their melee rhythm into a rolling thunderhead of steel and lightning.",
        requiredAny = { "Stormstrike", "Flametongue Weapon", "Earth Shock" },
        weights = { ["Stormstrike"] = 7, ["Flametongue Weapon"] = 6, ["Earth Shock"] = 5, ["Lightning Shield"] = 4, ["Strength of Earth Totem"] = 3, ["Searing Totem"] = 3, ["Rockbiter Weapon"] = 2 },
        minScore = 25,
    },
    {
        name = "Thunderbrand Adept",
        color = "1E90FF",
        description = "A volatile shockcaster, the Thunderbrand Adept fights like a storm breaking through mortal skin. Lightning, shocks, and totemic fire strike in jagged rhythm until the battlefield feels charged enough to split.",
        requiredAny = { "Lightning Bolt", "Earth Shock", "Flame Shock" },
        weights = { ["Lightning Bolt"] = 6, ["Earth Shock"] = 6, ["Flame Shock"] = 5, ["Searing Totem"] = 5, ["Lightning Shield"] = 3, ["Flametongue Weapon"] = 2 },
        minScore = 24,
    },
    {
        name = "Magma Totemist",
        color = "FF4500",
        description = "A fire-totem battlecaller, the Magma Totemist pins enemies inside a furnace of shocks, flame, and summoned heat. They do not chase the fight so much as make the ground itself hostile.",
        requiredAny = { "Searing Totem", "Flame Shock", "Fire Blast" },
        weights = { ["Searing Totem"] = 7, ["Flame Shock"] = 6, ["Fire Blast"] = 5, ["Fireball"] = 4, ["Immolate"] = 3, ["Earthbind Totem"] = 2 },
        minScore = 24,
    },
    {
        name = "Runeblade Ravager",
        color = "C41E3A",
        description = "A death-charged melee executioner, the Runeblade Ravager turns presence, plague, and weapon strikes into a ruthless close-range engine. They carve through enemies with runic pressure and blood-fed momentum, building every exchange toward a killing blow.",
        requiredAny = { "Blood Presence", "Blood Strike", "Plague Strike", "Obliterate" },
        weights = { ["Blood Presence"] = 6, ["Blood Strike"] = 6, ["Plague Strike"] = 5, ["Obliterate"] = 5, ["Death Strike"] = 4, ["Icy Touch"] = 3, ["Death Coil"] = 2 },
        minScore = 24,
    },
    {
        name = "Plagueforged Butcher",
        color = "8B0000",
        description = "A gore-slick runebrawler, the Plagueforged Butcher spreads sickness with one hand and carves openings with the other. Every strike feels less like swordplay and more like a wound learning to walk.",
        requiredAny = { "Plague Strike", "Blood Boil", "Icy Touch" },
        weights = { ["Plague Strike"] = 7, ["Blood Boil"] = 6, ["Icy Touch"] = 5, ["Blood Strike"] = 4, ["Death and Decay"] = 4, ["Unholy Presence"] = 3 },
        minScore = 24,
    },
    {
        name = "Radiant Blade",
        color = "F48CBA",
        description = "A holy melee champion, the Radiant Blade carries divine judgment into the front line. Seals, crusader strikes, and righteous force turn their weapon into a bright sentence passed on anything foolish enough to stand close.",
        requiredAny = { "Seal of Righteousness", "Crusader Strike", "Judgement of Light" },
        weights = { ["Seal of Righteousness"] = 6, ["Crusader Strike"] = 7, ["Judgement of Light"] = 5, ["Judgement of Wisdom"] = 5, ["Blessing of Might"] = 4, ["Consecration"] = 3, ["Devotion Aura"] = 2 },
        minScore = 25,
    },
    {
        name = "Sunlit Executor",
        color = "FFDE59",
        description = "A bright-handed enforcer, the Sunlit Executor blends righteous seals, holy bursts, and blunt conviction. Their magic does not soothe first; it judges, burns, and only then decides whether mercy is useful.",
        requiredAny = { "Smite", "Seal of Righteousness", "Holy Light" },
        weights = { ["Smite"] = 6, ["Seal of Righteousness"] = 5, ["Holy Light"] = 4, ["Blessing of Might"] = 4, ["Power Word: Fortitude"] = 3, ["Power Word: Shield"] = 3 },
        minScore = 23,
    },
    {
        name = "Shadowcut Duelist",
        color = "2B2B2B",
        description = "A quick-handed melee opportunist, the Shadowcut Duelist wins through openings, poisons, and vicious precision. Sinister Strike, Slice and Dice, and finishing blows make them less a soldier than a sudden bad decision with a blade.",
        requiredAny = { "Sinister Strike", "Backstab", "Eviscerate" },
        weights = { ["Sinister Strike"] = 7, ["Slice and Dice"] = 6, ["Eviscerate"] = 5, ["Backstab"] = 5, ["Gouge"] = 4, ["Stealth"] = 3, ["Sprint"] = 2 },
        minScore = 24,
    },
    {
        name = "Gutterblade Stalker",
        color = "3B0A45",
        description = "A dirty-fighting ambusher, the Gutterblade Stalker survives by never letting a fight become fair. Gouges, backstabs, sudden sprints, and cruel openings turn panic into a weapon.",
        requiredAny = { "Backstab", "Gouge", "Stealth" },
        weights = { ["Backstab"] = 7, ["Gouge"] = 6, ["Stealth"] = 5, ["Sprint"] = 4, ["Sinister Strike"] = 3, ["Evasion"] = 3 },
        minScore = 24,
    },
    {
        name = "Feral Ripper",
        color = "FF7C0A",
        description = "A shapeshifting predator, the Feral Ripper fights from instinct, momentum, and blood on the ground. Cat Form, Claw, and Rip make every second in melee feel like being hunted by the wild itself.",
        requiredAny = { "Cat Form", "Claw", "Rip" },
        weights = { ["Cat Form"] = 7, ["Claw"] = 6, ["Rip"] = 6, ["Prowl"] = 4, ["Feral Charge - Cat"] = 4, ["Mark of the Wild"] = 2 },
        minScore = 24,
    },
    {
        name = "Moonclaw Mystic",
        color = "7FFFD4",
        description = "A lunar predator, the Moonclaw Mystic mixes animal violence with moonlit curses and roots. One moment they are claw and fang; the next, the sky itself is bleeding silver into the fight.",
        requiredAny = { "Cat Form", "Moonfire", "Wrath" },
        weights = { ["Cat Form"] = 6, ["Moonfire"] = 6, ["Wrath"] = 5, ["Entangling Roots"] = 4, ["Mark of the Wild"] = 3, ["Rejuvenation"] = 2 },
        minScore = 24,
    },
    {
        name = "Iron Mauler",
        color = "708090",
        description = "A brutal front-line bruiser, the Iron Mauler turns raw weapon pressure into steady ruin. Heroic Strike, Battle Shout, and heavy defensive instincts keep them planted in the fight long after softer killers would break.",
        requiredAny = { "Heroic Strike", "Victory Rush", "Battle Stance" },
        weights = { ["Heroic Strike"] = 6, ["Battle Shout"] = 5, ["Victory Rush"] = 5, ["Bloodrage"] = 4, ["Battle Stance"] = 4, ["Rend"] = 3, ["Thunder Clap"] = 2 },
        minScore = 24,
    },
    {
        name = "Thunderfoot Bruiser",
        color = "C69B6D",
        description = "A brawling shock-trooper, the Thunderfoot Bruiser opens space with thunder, rage, and weapon pressure. Their style is not elegant, but very little remains standing long enough to complain.",
        requiredAny = { "Thunder Clap", "Bloodrage", "Heroic Strike" },
        weights = { ["Thunder Clap"] = 7, ["Bloodrage"] = 5, ["Heroic Strike"] = 5, ["Battle Shout"] = 4, ["Sunder Armor"] = 3, ["Defensive Stance"] = 2 },
        minScore = 24,
    },
    {
        name = "Wildfang Warden",
        color = "AAD372",
        description = "A rugged beast-side skirmisher, the Wildfang Warden mixes hunter discipline with close-range savagery. Raptor Strike, Mongoose Bite, and animal instinct make them dangerous even when the fight collapses into tooth-and-claw range.",
        requiredAny = { "Raptor Strike", "Mongoose Bite", "Aspect of the Monkey" },
        weights = { ["Raptor Strike"] = 7, ["Mongoose Bite"] = 6, ["Aspect of the Monkey"] = 5, ["Hunter's Mark"] = 4, ["Tame Beast"] = 3, ["Serpent Sting"] = 3 },
        minScore = 24,
    },
    {
        name = "Hawkeye Skirmisher",
        color = "9ACD32",
        description = "A mobile bow-fighter, the Hawkeye Skirmisher marks prey, keeps distance, and threads shots through the chaos. When cornered, they still have enough bite to make pursuit expensive.",
        requiredAny = { "Arcane Shot", "Auto Shot", "Steady Shot" },
        weights = { ["Arcane Shot"] = 7, ["Auto Shot"] = 6, ["Steady Shot"] = 6, ["Aspect of the Hawk"] = 5, ["Hunter's Mark"] = 4, ["Concussive Shot"] = 3, ["Serpent Sting"] = 3 },
        minScore = 24,
    },
    {
        name = "Felbrand Reaver",
        color = "8788EE",
        description = "A fel-touched aggressor, the Felbrand Reaver mixes weapon pressure with curses, flame, and demonic attrition. They do not simply cut enemies down; they make the wound burn, linger, and answer to darker powers.",
        requiredAny = { "Immolate", "Corruption", "Shadow Bolt" },
        weights = { ["Demon Skin"] = 4, ["Immolate"] = 6, ["Corruption"] = 6, ["Curse of Agony"] = 5, ["Shadow Bolt"] = 5, ["Life Tap"] = 4, ["Drain Soul"] = 3 },
        minScore = 24,
    },
    {
        name = "Soulburn Hexer",
        color = "9932CC",
        description = "A curse-driven executioner, the Soulburn Hexer lets agony do the stalking while shadow and flame finish the argument. Their enemies rarely fall cleanly; they unravel.",
        requiredAny = { "Curse of Agony", "Drain Soul", "Corruption" },
        weights = { ["Curse of Agony"] = 7, ["Drain Soul"] = 6, ["Corruption"] = 6, ["Shadow Bolt"] = 4, ["Life Tap"] = 4, ["Fear"] = 3, ["Summon Imp"] = 2 },
        minScore = 24,
    },
    {
        name = "Frostfire Savant",
        color = "3FC7EB",
        description = "A dueling arcanist, the Frostfire Savant switches between freezing control, burning punishment, and raw arcane force. Their spellbook is less a school and more a loaded argument.",
        requiredAny = { "Frostbolt", "Fireball", "Arcane Missiles" },
        weights = { ["Frostbolt"] = 6, ["Fireball"] = 6, ["Arcane Missiles"] = 6, ["Fire Blast"] = 5, ["Frost Nova"] = 4, ["Arcane Intellect"] = 3, ["Mage Armor"] = 2 },
        minScore = 24,
    },
    {
        name = "Arcane Barragewright",
        color = "B87333",
        description = "A precision spellwright, the Arcane Barragewright shapes missiles, intellect, and sudden blasts into a clean mathematical violence. Everything about them suggests calculation until the air explodes.",
        requiredAny = { "Arcane Missiles", "Arcane Intellect", "Fire Blast" },
        weights = { ["Arcane Missiles"] = 7, ["Arcane Intellect"] = 5, ["Fire Blast"] = 5, ["Frost Nova"] = 3, ["Mage Armor"] = 3, ["Polymorph"] = 2 },
        minScore = 23,
    },
    {
        name = "Void Psalmist",
        color = "4B0082",
        description = "A shadow-prayer combatant, the Void Psalmist threads pain, mind force, and stolen breath into a hymn no sane enemy wants to hear twice. Their faith does not shine; it listens from the dark.",
        requiredAny = { "Shadow Word: Pain", "Mind Blast", "Smite" },
        weights = { ["Shadow Word: Pain"] = 7, ["Mind Blast"] = 6, ["Smite"] = 4, ["Power Word: Shield"] = 4, ["Power Word: Fortitude"] = 3, ["Renew"] = 2 },
        minScore = 24,
    },
    {
        name = "Battle Cleric",
        color = "FFFFFF",
        description = "A stubborn light-bearing combatant, the Battle Cleric survives by layering faith, protection, and punishment. Shields and blessings keep them moving while holy strikes and steady pressure wear the enemy down.",
        requiredAny = { "Smite", "Power Word: Shield", "Renew" },
        weights = { ["Power Word: Shield"] = 6, ["Power Word: Fortitude"] = 4, ["Smite"] = 6, ["Renew"] = 4, ["Greater Heal"] = 3, ["Holy Light"] = 2 },
        minScore = 23,
    },
    {
        name = "Blightshot Ranger",
        color = "556B2F",
        description = "A poison-and-arrow opportunist, the Blightshot Ranger stacks marks, stings, and quick shots until the target is fighting the wound as much as the hunter.",
        requiredAny = { "Serpent Sting", "Arcane Shot", "Hunter's Mark" },
        weights = { ["Serpent Sting"] = 7, ["Arcane Shot"] = 6, ["Hunter's Mark"] = 5, ["Auto Shot"] = 4, ["Concussive Shot"] = 3, ["Aspect of the Hawk"] = 3 },
        minScore = 24,
    },
    {
        name = "Emberknife Adept",
        color = "FF6347",
        description = "A close-range pyromancer, the Emberknife Adept prefers enemies near enough to see the fear arrive. Fire blasts, burning curses, and sudden blade work turn every fight into a flashover.",
        requiredAny = { "Fire Blast", "Immolate", "Sinister Strike" },
        weights = { ["Fire Blast"] = 6, ["Immolate"] = 6, ["Sinister Strike"] = 5, ["Flametongue Weapon"] = 4, ["Seal of Righteousness"] = 3, ["Fireball"] = 3 },
        minScore = 24,
    },
    {
        name = "Starshot Invoker",
        color = "4169E1",
        description = "A ranged spell-archer, the Starshot Invoker mixes missiles, moonfire, and marked shots into a strange celestial volley. Their best fights end before the enemy decides whether to raise a shield or look up.",
        requiredAny = { "Arcane Shot", "Arcane Missiles", "Moonfire" },
        weights = { ["Arcane Shot"] = 6, ["Arcane Missiles"] = 6, ["Moonfire"] = 6, ["Hunter's Mark"] = 4, ["Wrath"] = 3, ["Auto Shot"] = 3 },
        minScore = 24,
    },
    {
        name = "Gravefire Channeler",
        color = "800000",
        description = "A death-and-flame channeler, the Gravefire Channeler feeds shadow into fire until both become indistinguishable. Bolts, burns, and death magic gather around them like smoke around a battlefield pyre.",
        requiredAny = { "Shadow Bolt", "Death Coil", "Immolate" },
        weights = { ["Shadow Bolt"] = 6, ["Death Coil"] = 6, ["Immolate"] = 5, ["Corruption"] = 4, ["Icy Touch"] = 3, ["Drain Soul"] = 3 },
        minScore = 24,
    },
    {
        name = "Rootstorm Warden",
        color = "228B22",
        description = "A battlefield controller, the Rootstorm Warden turns nature magic into a trap that bites back. Roots, thorns, moonfire, and healing keep the fight exactly where they want it.",
        requiredAny = { "Entangling Roots", "Thorns", "Moonfire" },
        weights = { ["Entangling Roots"] = 7, ["Thorns"] = 5, ["Moonfire"] = 5, ["Wrath"] = 4, ["Mark of the Wild"] = 4, ["Rejuvenation"] = 3 },
        minScore = 23,
    },
    {
        name = "Bulwark Mystic",
        color = "AFEEEE",
        description = "A defensive spellguard, the Bulwark Mystic layers shields, armor, auras, and stubborn magic into a wall that still knows how to strike back.",
        requiredAny = { "Power Word: Shield", "Frost Armor", "Devotion Aura" },
        weights = { ["Power Word: Shield"] = 6, ["Frost Armor"] = 5, ["Devotion Aura"] = 5, ["Divine Protection"] = 4, ["Stoneskin Totem"] = 4, ["Smite"] = 2 },
        minScore = 23,
    },
}

local generatedAutoClassThemes = {
    { suffix = "Stormblade", color = "00BFFF", spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Searing Totem" }, description = "storm-charged fighter who turns shocks, bolts, and crackling pressure into a fast battlefield rhythm." },
    { suffix = "Sunbreaker", color = "FFD700", spells = { "Smite", "Seal of Righteousness", "Blessing of Might", "Holy Light" }, description = "radiant combatant who carries light into the first exchange and makes every strike feel like judgment." },
    { suffix = "Voidscar", color = "6A0DAD", spells = { "Shadow Word: Pain", "Shadow Bolt", "Corruption", "Mind Blast" }, description = "shadow-marked caster who lets pain, void, and psychic pressure do the stalking." },
    { suffix = "Bulwark", color = "708090", spells = { "Defensive Stance", "Sunder Armor", "Devotion Aura", "Shield of Righteousness" }, description = "shield-minded defender who turns stance work, armor breaks, and holy protection into a stubborn front line." },
    { suffix = "Stonehide", color = "556B2F", spells = { "Bear Form", "Stoneclaw Totem", "Stoneskin Totem", "Thorns" }, description = "earthbound guardian who layers hide, thorns, and stone totems into a wall that bites back." },
    { suffix = "Rockbreaker", color = "B87333", spells = { "Rockbiter Weapon", "Thunder Clap", "Righteous Fury", "Lightning Shield" }, description = "threat-hungry bruiser who uses rockbiter force, thunder, and fury to keep danger focused on them." },
    { suffix = "Wildclaw", color = "FF7C0A", spells = { "Cat Form", "Claw", "Moonfire", "Mark of the Wild" }, description = "wild predator who blends instinct, claws, and nature magic into a hungry opening rush." },
    { suffix = "Lifebloom", color = "00FF98", spells = { "Healing Wave", "Rejuvenation", "Healing Touch", "Renew" }, description = "restorative mystic who keeps wounds closing through waves, blossoms, and quiet persistence." },
    { suffix = "Lightwell", color = "FFFFFF", spells = { "Power Word: Shield", "Holy Light", "Greater Heal", "Renew" }, description = "radiant protector who answers disaster with shields, light, and patient recovery magic." },
    { suffix = "Wisdomtide", color = "20B2AA", spells = { "Seal of Wisdom", "Healing Wave", "Hand of Protection", "Mage Armor" }, description = "resourceful field healer who survives through wisdom, protection, and steady healing cadence." },
    { suffix = "Ironhowl", color = "C69B6D", spells = { "Heroic Strike", "Battle Shout", "Victory Rush", "Bloodrage" }, description = "stubborn weapon fighter who answers danger with rage, steel, and a refusal to step back." },
    { suffix = "Guardfang", color = "9ACD32", spells = { "Raptor Strike", "Evasion", "Aspect of the Monkey", "Demon Skin" }, description = "avoidance fighter who survives through animal reflexes, evasive movement, and close-range punishment." },
    { suffix = "Blightspine", color = "556B2F", spells = { "Serpent Sting", "Corruption", "Curse of Agony", "Shadow Word: Pain" }, description = "attrition fighter who layers poison, pain, and rot until the enemy is losing to the wound itself." },
    { suffix = "Frostfang", color = "AFEEEE", spells = { "Frostbolt", "Icy Touch", "Mongoose Bite", "Raptor Strike" }, description = "cold-biting skirmisher who slows the field and punishes anything that gets close enough to snap at." },
    { suffix = "Dawnshield", color = "F48CBA", spells = { "Power Word: Shield", "Devotion Aura", "Divine Protection", "Holy Light" }, description = "radiant defender who turns protective magic into a steady wall of light and discipline." },
    { suffix = "Hexflame", color = "9932CC", spells = { "Immolate", "Curse of Agony", "Fire Blast", "Shadow Bolt" }, description = "curse-flinger who braids fire and shadow into a spiteful, burning pressure pattern." },
    { suffix = "Moonshot", color = "4169E1", spells = { "Moonfire", "Arcane Shot", "Auto Shot", "Wrath" }, description = "lunar marksman who fires from strange angles, mixing sky magic with clean ranged pressure." },
    { suffix = "Plagueheart", color = "8B0000", spells = { "Plague Strike", "Blood Boil", "Death Coil", "Corruption" }, description = "disease-marked aggressor who lets blood, rot, and dark force do the heavy lifting." },
    { suffix = "Tidecaller", color = "20B2AA", spells = { "Healing Wave", "Earth Shock", "Lightning Bolt", "Earthbind Totem" }, description = "elemental responder who shifts between recovery, shock pressure, and battlefield control." },
    { suffix = "Spiritguard", color = "00FF98", spells = { "Renew", "Healing Touch", "Mark of the Wild", "Power Word: Fortitude" }, description = "supportive survivor who turns blessings, restoration, and resilience into a quiet advantage." },
    { suffix = "Venomblade", color = "3B0A45", spells = { "Backstab", "Gouge", "Serpent Sting", "Shadow Word: Pain" }, description = "dirty close-range striker who mixes blades with lingering venom and cruel openings." },
    { suffix = "Starweaver", color = "7DF9FF", spells = { "Arcane Missiles", "Moonfire", "Smite", "Lightning Bolt" }, description = "celestial caster who stitches several schools of magic into a bright and unstable pattern." },
    { suffix = "Ashwarden", color = "A9A9A9", spells = { "Frost Armor", "Demon Skin", "Thorns", "Devotion Aura" }, description = "layered warder who survives through armor, skin, thorns, and stubborn defensive instincts." },
    { suffix = "Deathmarch", color = "C41E3A", spells = { "Blood Presence", "Unholy Presence", "Death and Decay", "Blood Strike" }, description = "runic advance fighter who moves like a bad omen, carrying blood and decay into the front line." },
}

local generatedAutoClassForms = {
    { prefix = "Acolyte", spells = { "Power Word: Shield", "Renew" }, description = "They are still raw, but already dangerous when their spell kit starts to line up." },
    { prefix = "Duelist", spells = { "Sinister Strike", "Gouge" }, description = "They prefer close openings, quick reads, and turning one clean hit into momentum." },
    { prefix = "Vanguard", spells = { "Defensive Stance", "Sunder Armor" }, description = "They step forward first, using defensive habits and armor pressure to define the fight." },
    { prefix = "Bulwark", spells = { "Righteous Fury", "Devotion Aura" }, description = "They are built to draw attention and stay upright while the field settles around them." },
    { prefix = "Mender", spells = { "Healing Wave", "Holy Light" }, description = "They lean toward recovery, turning a fragile roll into a surprisingly steady lifeline." },
    { prefix = "Preserver", spells = { "Rejuvenation", "Greater Heal" }, description = "They keep allies in the fight through patient restoration and one decisive answer to crisis." },
    { prefix = "Reaver", spells = { "Blood Strike", "Heroic Strike" }, description = "They turn simple weapon pressure into a hard, forward-moving threat." },
    { prefix = "Seer", spells = { "Mind Blast", "Lightning Bolt" }, description = "They read the opening through instinct and answer with sudden focused force." },
    { prefix = "Ranger", spells = { "Auto Shot", "Hunter's Mark" }, description = "They prefer distance, marks, and a clear lane before the fight gets messy." },
    { prefix = "Binder", spells = { "Entangling Roots", "Earthbind Totem" }, description = "They win space by making the battlefield itself refuse to cooperate." },
    { prefix = "Warden", spells = { "Frost Armor", "Thorns" }, description = "They survive by making every hit against them cost something in return." },
    { prefix = "Herald", spells = { "Battle Shout", "Blessing of Might" }, description = "They bring momentum before the first swing, turning confidence into pressure." },
    { prefix = "Hexblade", spells = { "Corruption", "Backstab" }, description = "They blend cruel blade work with lingering magic that keeps hurting after the opening." },
    { prefix = "Sentinel", spells = { "Aspect of the Hawk", "Devotion Aura" }, description = "They keep their posture, watch the field, and turn discipline into reliable pressure." },
    { prefix = "Channeler", spells = { "Drain Soul", "Arcane Missiles" }, description = "They build power through sustained casting and opportunistic bursts." },
    { prefix = "Harrier", spells = { "Concussive Shot", "Hamstring" }, description = "They specialize in making enemies slower, angrier, and easier to finish." },
    { prefix = "Oracle", spells = { "Smite", "Moonfire" }, description = "They carry bright omens and sharper punishments in equal measure." },
    { prefix = "Knight", spells = { "Seal of Righteousness", "Crusader Strike" }, description = "They turn conviction, seals, and close-range discipline into a focused charge." },
    { prefix = "Adept", spells = { "Fire Blast", "Earth Shock" }, description = "They favor short, decisive bursts that punish a target before it can reset." },
    { prefix = "Stalker", spells = { "Stealth", "Prowl" }, description = "They trust patience, positioning, and the first unfair second of a fight." },
}

local dropdownAutoClassPresets = {
    { name = "Death Knight", color = "C41E3A", spells = { "Blood Presence", "Icy Touch", "Plague Strike", "Death Coil", "Blood Strike", "Death and Decay" }, description = "A level-one death champion interpretation, the Death Knight turns blood, frost, plague, and dark force into an early omen of ruin." },
    { name = "Demon Hunter", color = "A330C9", spells = { "Evasion", "Sprint", "Demon Skin", "Immolate", "Shadow Bolt", "Backstab" }, description = "A level-one demon hunter interpretation, the Demon Hunter reads like a scarred skirmisher using speed, fel-touched protection, and burning pressure." },
    { name = "Druid", color = "FF7C0A", spells = { "Cat Form", "Moonfire", "Wrath", "Rejuvenation", "Mark of the Wild", "Entangling Roots" }, description = "A level-one druid interpretation, the Druid answers rerolls with nature magic, shifting instinct, healing, and roots." },
    { name = "Evoker", color = "33937F", spells = { "Fireball", "Flame Shock", "Healing Wave", "Healing Touch", "Lightning Bolt", "Power Word: Shield" }, description = "A level-one evoker interpretation, the Evoker uses flame, breath-like bursts, preservation magic, and elemental flow as a draconic echo." },
    { name = "Hunter", color = "AAD372", spells = { "Auto Shot", "Arcane Shot", "Hunter's Mark", "Serpent Sting", "Raptor Strike", "Mongoose Bite" }, description = "A level-one hunter interpretation, the Hunter turns marks, shots, stings, and survival instincts into a clean prey-tracking identity." },
    { name = "Mage", color = "3FC7EB", spells = { "Frostbolt", "Fireball", "Arcane Missiles", "Fire Blast", "Frost Nova", "Arcane Intellect" }, description = "A level-one mage interpretation, the Mage forms when frost, fire, and arcane force dominate the reroll." },
    { name = "Monk", color = "00FF98", spells = { "Battle Stance", "Mongoose Bite", "Evasion", "Healing Wave", "Renew", "Smite" }, description = "A level-one monk interpretation, the Monk is treated as discipline in motion: stance work, close strikes, evasive movement, and restorative focus." },
    { name = "Paladin", color = "F48CBA", spells = { "Seal of Righteousness", "Holy Light", "Blessing of Might", "Devotion Aura", "Crusader Strike", "Divine Protection" }, description = "A level-one paladin interpretation, the Paladin appears when holy defense, righteous seals, and martial conviction align." },
    { name = "Priest", color = "FFFFFF", spells = { "Smite", "Power Word: Shield", "Power Word: Fortitude", "Renew", "Shadow Word: Pain", "Mind Blast" }, description = "A level-one priest interpretation, the Priest balances faith, shieldcraft, healing, and shadowed insight." },
    { name = "Rogue", color = "FFF468", spells = { "Sinister Strike", "Backstab", "Gouge", "Evasion", "Stealth", "Sprint" }, description = "A level-one rogue interpretation, the Rogue wins through unfair openings, quick blades, and escape tools." },
    { name = "Shaman", color = "0070DD", spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Searing Totem", "Strength of Earth Totem", "Flametongue Weapon" }, description = "A level-one shaman interpretation, the Shaman speaks through shocks, totems, weapon blessings, and raw elemental rhythm." },
    { name = "Warlock", color = "8788EE", spells = { "Shadow Bolt", "Corruption", "Curse of Agony", "Immolate", "Drain Soul", "Life Tap" }, description = "A level-one warlock interpretation, the Warlock forms from curses, shadow bolts, soul magic, and risky power." },
    { name = "Warrior", color = "C69B6D", spells = { "Battle Stance", "Heroic Strike", "Victory Rush", "Bloodrage", "Battle Shout", "Thunder Clap" }, description = "A level-one warrior interpretation, the Warrior is raw stance, shout, steel, and momentum." },
    { name = "Spell Breaker", color = "7DF9FF", spells = { "Arcane Missiles", "Earth Shock", "Power Word: Shield", "Mage Armor", "Frost Nova", "Shield of Righteousness" }, description = "A level-one spell breaker interpretation, the Spell Breaker reads as warded anti-magic pressure and precise disruptive force." },
    { name = "Abyss Walker", color = "1A1A2E", spells = { "Shadow Bolt", "Corruption", "Fear", "Fade", "Stealth", "Death Coil" }, description = "A level-one abyss walker interpretation, the Abyss Walker emerges from shadow movement, fear, and void-touched pressure." },
    { name = "Bloodbinder", color = "8B0000", spells = { "Blood Presence", "Blood Strike", "Drain Soul", "Life Tap", "Renew", "Death Strike" }, description = "A level-one bloodbinder interpretation, the Bloodbinder turns life, pain, and blood-themed strikes into a crimson pact." },
    { name = "Chronomancer", color = "FFD700", spells = { "Arcane Missiles", "Arcane Intellect", "Frost Nova", "Polymorph", "Sprint", "Renew" }, description = "A level-one chronomancer interpretation, the Chronomancer uses arcane timing, control, quick movement, and delayed recovery as time-flavored magic." },
    { name = "Grave Warden", color = "4B5320", spells = { "Defensive Stance", "Death and Decay", "Demon Skin", "Stoneskin Totem", "Thorns", "Power Word: Fortitude" }, description = "A level-one grave warden interpretation, the Grave Warden is stubborn, earthy, death-marked, and hard to shift." },
    { name = "Storm Herald", color = "00BFFF", spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Thunder Clap", "Stormstrike", "Lightning Shield" }, description = "A level-one storm herald interpretation, the Storm Herald appears when thunder, shocks, and sudden elemental violence dominate." },
    { name = "Runesmith", color = "B87333", spells = { "Arcane Intellect", "Strength of Earth Totem", "Rockbiter Weapon", "Shield of Righteousness", "Blood Strike", "Runic Focus" }, description = "A level-one runesmith interpretation, the Runesmith is crafted power, reinforced weapons, and engraved battlefield pressure." },
    { name = "Soul Weaver", color = "6A0DAD", spells = { "Drain Soul", "Renew", "Healing Wave", "Power Word: Shield", "Shadow Word: Pain", "Mind Blast" }, description = "A level-one soul weaver interpretation, the Soul Weaver knots healing, shadow, and spirit pressure into one strange pattern." },
    { name = "Beast Warden", color = "556B2F", spells = { "Tame Beast", "Raptor Strike", "Mongoose Bite", "Aspect of the Monkey", "Hunter's Mark", "Thorns" }, description = "A level-one beast warden interpretation, the Beast Warden channels animal instinct, close counters, and wild protection." },
    { name = "Voidcaller", color = "2F4F4F", spells = { "Shadow Bolt", "Corruption", "Fear", "Summon Imp", "Summon Voidwalker", "Mind Blast" }, description = "A level-one voidcaller interpretation, the Voidcaller brings summons, fear, shadow, and abyssal pressure into the roll." },
    { name = "Sun Cleric", color = "FFDE59", spells = { "Smite", "Holy Light", "Renew", "Power Word: Fortitude", "Seal of Righteousness", "Blessing of Might" }, description = "A level-one sun cleric interpretation, the Sun Cleric shines through holy punishment, recovery, and radiant support." },
    { name = "Frostbinder", color = "AFEEEE", spells = { "Frostbolt", "Frost Armor", "Frost Nova", "Icy Touch", "Entangling Roots", "Power Word: Shield" }, description = "A level-one frostbinder interpretation, the Frostbinder is control, chill, armor, and the slow closing of options." },
    { name = "Ashbringer", color = "A9A9A9", spells = { "Immolate", "Fire Blast", "Consecration", "Devotion Aura", "Death and Decay", "Heroic Strike" }, description = "A level-one ashbringer interpretation, the Ashbringer blends aftermath, fire, holy ground, and grim martial force." },
    { name = "Hexblade", color = "3B0A45", spells = { "Sinister Strike", "Backstab", "Curse of Agony", "Corruption", "Shadow Word: Pain", "Gouge" }, description = "A level-one hexblade interpretation, the Hexblade binds curses and blade work into one hostile edge." },
    { name = "Spirit Dancer", color = "7FFFD4", spells = { "Evasion", "Sprint", "Renew", "Healing Wave", "Cat Form", "Moonfire" }, description = "A level-one spirit dancer interpretation, the Spirit Dancer appears through movement, recovery, grace, and spectral-feeling magic." },
    { name = "Iron Vanguard", color = "708090", spells = { "Defensive Stance", "Sunder Armor", "Shield Block", "Devotion Aura", "Stoneskin Totem", "Bloodrage" }, description = "A level-one iron vanguard interpretation, the Iron Vanguard is armor, stance, threat, and immovable intent." },
    { name = "Plaguebringer", color = "556B2F", spells = { "Plague Strike", "Blood Boil", "Corruption", "Curse of Agony", "Serpent Sting", "Death and Decay" }, description = "A level-one plaguebringer interpretation, the Plaguebringer wins with disease, blight, poison, and time." },
    { name = "Starcaller", color = "4169E1", spells = { "Arcane Missiles", "Moonfire", "Arcane Shot", "Smite", "Wrath", "Lightning Bolt" }, description = "A level-one starcaller interpretation, the Starcaller is celestial pressure through moonlight, arcane force, and distant strikes." },
    { name = "Shadow Duelist", color = "2B2B2B", spells = { "Backstab", "Gouge", "Stealth", "Shadow Word: Pain", "Shadow Bolt", "Evasion" }, description = "A level-one shadow duelist interpretation, the Shadow Duelist uses darkness, timing, and cruel precision." },
    { name = "Ember Knight", color = "FF4500", spells = { "Fire Blast", "Immolate", "Seal of Righteousness", "Crusader Strike", "Heroic Strike", "Flametongue Weapon" }, description = "A level-one ember knight interpretation, the Ember Knight is martial fire, heated steel, and burning conviction." },
    { name = "Tide Sage", color = "20B2AA", spells = { "Healing Wave", "Seal of Wisdom", "Earthbind Totem", "Frostbolt", "Renew", "Lightning Bolt" }, description = "A level-one tide sage interpretation, the Tide Sage flows between healing, control, wisdom, and elemental response." },
    { name = "Bone Oracle", color = "F5F5DC", spells = { "Mind Blast", "Power Word: Fortitude", "Death Coil", "Resurrection", "Shadow Word: Pain", "Smite" }, description = "A level-one bone oracle interpretation, the Bone Oracle reads omens through death, mind magic, and brittle faith." },
    { name = "Thunder Reaver", color = "1E90FF", spells = { "Lightning Bolt", "Earth Shock", "Stormstrike", "Thunder Clap", "Heroic Strike", "Mongoose Bite" }, description = "A level-one thunder reaver interpretation, the Thunder Reaver is storm impact translated into weapon pressure." },
    { name = "Nether Alchemist", color = "9932CC", spells = { "Arcane Missiles", "Life Tap", "Immolate", "Corruption", "Conjure Water", "Create Healthstone" }, description = "A level-one nether alchemist interpretation, the Nether Alchemist reads as unstable arcane, shadow, fuel, and strange utility." },
    { name = "Wildheart", color = "228B22", spells = { "Mark of the Wild", "Thorns", "Rejuvenation", "Cat Form", "Raptor Strike", "Entangling Roots" }, description = "A level-one wildheart interpretation, the Wildheart is green survival, instinct, roots, and stubborn vitality." },
    { name = "Doom Harbinger", color = "800000", spells = { "Shadow Bolt", "Curse of Agony", "Death and Decay", "Death Coil", "Immolate", "Fear" }, description = "A level-one doom harbinger interpretation, the Doom Harbinger carries shadow, flame, fear, and prophecy-of-ruin energy." },
}

local supplementalNamedAutoClassPresets = {
    { name = "Warrior", color = "C69B6D", spells = { "Battle Stance", "Heroic Strike", "Battle Shout", "Victory Rush" }, description = "A level-one warrior interpretation, the Warrior turns stance, shout, and weapon pressure into reliable front-line momentum." },
    { name = "Protector", color = "708090", spells = { "Defensive Stance", "Power Word: Shield", "Devotion Aura", "Hand of Protection" }, description = "A level-one protector interpretation, the Protector reads as a shield-first defender who survives by layering wards, aura, and defensive posture." },
    { name = "Champion", color = "FFDE59", spells = { "Blessing of Might", "Crusader Strike", "Seal of Righteousness", "Battle Shout" }, description = "A level-one champion interpretation, the Champion uses blessing, seal, shout, and conviction to look bigger than the roll should allow." },
    { name = "Devastator", color = "FF4500", spells = { "Thunder Clap", "Heroic Strike", "Death and Decay", "Fire Blast" }, description = "A level-one devastator interpretation, the Devastator is built around loud impact, brutal follow-through, and damage that refuses to stay tidy." },
    { name = "Weaponmaster", color = "B87333", spells = { "Sinister Strike", "Heroic Strike", "Raptor Strike", "Crusader Strike" }, description = "A level-one weaponmaster interpretation, the Weaponmaster turns any blade, claw, or oath-strike into a disciplined killing rhythm." },
    { name = "Knight", color = "F48CBA", spells = { "Seal of Righteousness", "Crusader Strike", "Devotion Aura", "Hammer of Justice" }, description = "A level-one knight interpretation, the Knight mixes holy seals, close-range judgment, and formal defensive discipline." },
    { name = "Defender", color = "708090", spells = { "Defensive Stance", "Sunder Armor", "Shield Block", "Taunt" }, description = "A level-one defender interpretation, the Defender exists to hold the line, strip armor, and make enemies pay attention." },
    { name = "Lightbringer", color = "FFDE59", spells = { "Holy Light", "Smite", "Seal of Righteousness", "Blessing of Might" }, description = "A level-one lightbringer interpretation, the Lightbringer answers danger with radiant force, healing, and righteous pressure." },
    { name = "Justicar", color = "F48CBA", spells = { "Hammer of Justice", "Judgement of Light", "Seal of Righteousness", "Crusader Strike" }, description = "A level-one justicar interpretation, the Justicar turns stun, judgment, seal, and crusader discipline into one sentence of punishment." },
    { name = "Sentinel", color = "AAD372", spells = { "Aspect of the Hawk", "Hunter's Mark", "Devotion Aura", "Auto Shot" }, description = "A level-one sentinel interpretation, the Sentinel keeps the field watched, marked, and covered from a disciplined distance." },
    { name = "Reaver", color = "8B0000", spells = { "Blood Strike", "Heroic Strike", "Mongoose Bite", "Stormstrike" }, description = "A level-one reaver interpretation, the Reaver is all forward motion, hard contact, and ugly weapon pressure." },
    { name = "Boneguard", color = "F5F5DC", spells = { "Death Coil", "Shield Block", "Power Word: Fortitude", "Resurrection" }, description = "A level-one boneguard interpretation, the Boneguard treats death as close company and defense as a sacred refusal." },
    { name = "Revenant", color = "4B5320", spells = { "Death Coil", "Unholy Presence", "Shadow Bolt", "Death and Decay" }, description = "A level-one revenant interpretation, the Revenant moves like something that already died and decided the fight was not finished." },
    { name = "Bloodletter", color = "8B0000", spells = { "Blood Strike", "Blood Presence", "Rend", "Blood Boil" }, description = "A level-one bloodletter interpretation, the Bloodletter makes the battlefield red through pressure, presence, and cruel openings." },
    { name = "Berserker", color = "C41E3A", spells = { "Bloodrage", "Battle Stance", "Heroic Strike", "Victory Rush" }, description = "A level-one berserker interpretation, the Berserker feeds on rage, momentum, and the next target in reach." },
    { name = "Rogue", color = "FFF468", spells = { "Stealth", "Sinister Strike", "Backstab", "Evasion" }, description = "A level-one rogue interpretation, the Rogue wins through unfair openings, quick blades, and just enough escape to make it look intentional." },
    { name = "Phantom", color = "2B2B2B", spells = { "Stealth", "Fade", "Shadow Bolt", "Gouge" }, description = "A level-one phantom interpretation, the Phantom slips between attention and shadow before the enemy realizes the fight began." },
    { name = "Shadow", color = "3B0A45", spells = { "Shadow Word: Pain", "Shadow Bolt", "Stealth", "Corruption" }, description = "A level-one shadow interpretation, the Shadow identity forms when darkness is both the approach and the wound left behind." },
    { name = "Bladesmith", color = "B87333", spells = { "Rockbiter Weapon", "Flametongue Weapon", "Sinister Strike", "Sunder Armor" }, description = "A level-one bladesmith interpretation, the Bladesmith treats the weapon as a craft project that happens to scream." },
    { name = "Scrapper", color = "C69B6D", spells = { "Gouge", "Mongoose Bite", "Raptor Strike", "Thunder Clap" }, description = "A level-one scrapper interpretation, the Scrapper wins through elbows, bites, dirty timing, and whatever works first." },
    { name = "Mage", color = "3FC7EB", spells = { "Frostbolt", "Fireball", "Arcane Missiles", "Arcane Intellect" }, description = "A level-one mage interpretation, the Mage appears when frost, fire, arcane focus, and raw spellcraft dominate the roll." },
    { name = "Pyromancer", color = "FF4500", spells = { "Fireball", "Fire Blast", "Immolate", "Flame Shock" }, description = "A level-one pyromancer interpretation, the Pyromancer does not solve problems so much as raise the temperature until they become ash." },
    { name = "Aeromancer", color = "00BFFF", spells = { "Lightning Bolt", "Earth Shock", "Arcane Missiles", "Concussive Shot" }, description = "A level-one aeromancer interpretation, the Aeromancer moves through shock, pressure, and bright force like weather with a grudge." },
    { name = "Terramancer", color = "B87333", spells = { "Earthbind Totem", "Strength of Earth Totem", "Stoneskin Totem", "Rockbiter Weapon" }, description = "A level-one terramancer interpretation, the Terramancer lets stone, binding, and earth-strength decide where the fight is allowed to happen." },
    { name = "Hydromancer", color = "20B2AA", spells = { "Healing Wave", "Frostbolt", "Frost Nova", "Conjure Water" }, description = "A level-one hydromancer interpretation, the Hydromancer bends water into recovery, cold control, and patient pressure." },
    { name = "Ranger", color = "AAD372", spells = { "Auto Shot", "Hunter's Mark", "Arcane Shot", "Track Beasts" }, description = "A level-one ranger interpretation, the Ranger tracks, marks, and ends the fight from the lane they chose before anyone else noticed it." },
    { name = "Medicinist", color = "00FF98", spells = { "Healing Wave", "Renew", "Holy Light", "Purify" }, description = "A level-one medicinist interpretation, the Medicinist is practical recovery, clean hands, and emergency answers under pressure." },
    { name = "Scout", color = "AAD372", spells = { "Track Humanoids", "Track Beasts", "Stealth", "Sprint" }, description = "A level-one scout interpretation, the Scout survives by seeing first, moving first, and not being where trouble expected." },
    { name = "Animist", color = "228B22", spells = { "Tame Beast", "Mark of the Wild", "Thorns", "Aspect of the Monkey" }, description = "A level-one animist interpretation, the Animist speaks in instincts, beasts, and small wild bargains." },
    { name = "Marksman", color = "AAD372", spells = { "Auto Shot", "Steady Shot", "Arcane Shot", "Hunter's Mark" }, description = "A level-one marksman interpretation, the Marksman is a clean line, a marked target, and a shot that arrives before regret." },
    { name = "Druid", color = "FF7C0A", spells = { "Cat Form", "Moonfire", "Rejuvenation", "Mark of the Wild" }, description = "A level-one druid interpretation, the Druid shifts between claw, moonlight, healing, and the old green rules of the world." },
    { name = "Sage", color = "7DF9FF", spells = { "Arcane Intellect", "Smite", "Wrath", "Mind Blast" }, description = "A level-one sage interpretation, the Sage turns knowledge into force and treats every school of magic as a useful footnote." },
    { name = "Mender", color = "00FF98", spells = { "Renew", "Healing Touch", "Healing Wave", "Holy Light" }, description = "A level-one mender interpretation, the Mender keeps life stitched together through every kind of early healing the roll can offer." },
    { name = "Naturist", color = "228B22", spells = { "Entangling Roots", "Thorns", "Mark of the Wild", "Wrath" }, description = "A level-one naturist interpretation, the Naturist lets roots, thorns, and green wrath argue on their behalf." },
    { name = "Magus", color = "9932CC", spells = { "Arcane Missiles", "Frostbolt", "Fireball", "Arcane Intellect" }, description = "A level-one magus interpretation, the Magus is an early study in making several kinds of magic equally inconvenient." },
    { name = "Cleric", color = "FFFFFF", spells = { "Smite", "Holy Light", "Power Word: Fortitude", "Renew" }, description = "A level-one cleric interpretation, the Cleric balances faith, punishment, and care in one bright pattern." },
    { name = "Restorer", color = "00FF98", spells = { "Rejuvenation", "Healing Touch", "Renew", "Greater Heal" }, description = "A level-one restorer interpretation, the Restorer is a promise that damage can be answered, slowly or all at once." },
    { name = "Theurgist", color = "FFDE59", spells = { "Smite", "Lightning Bolt", "Moonfire", "Shadow Word: Pain" }, description = "A level-one theurgist interpretation, the Theurgist pulls divine, lunar, storm, and shadow signs into one volatile rite." },
    { name = "Prelate", color = "F48CBA", spells = { "Devotion Aura", "Blessing of Might", "Holy Light", "Power Word: Shield" }, description = "A level-one prelate interpretation, the Prelate leads by blessing, shielding, and refusing to let the line collapse." },
    { name = "Watcher", color = "4169E1", spells = { "Hunter's Mark", "Track Humanoids", "Aspect of the Hawk", "Shadow Word: Pain" }, description = "A level-one watcher interpretation, the Watcher marks the enemy, reads the field, and lets patient pressure do the rest." },
    { name = "Necromancer", color = "2F4F4F", spells = { "Death Coil", "Death and Decay", "Shadow Bolt", "Summon Voidwalker" }, description = "A level-one necromancer interpretation, the Necromancer treats shadow, death, and borrowed bodies as the beginning of a proper education." },
    { name = "Necrotomist", color = "4B5320", spells = { "Blood Boil", "Plague Strike", "Corruption", "Drain Soul" }, description = "A level-one necrotomist interpretation, the Necrotomist studies decay closely enough that enemies become test subjects." },
    { name = "Bonemender", color = "F5F5DC", spells = { "Death Strike", "Renew", "Death Coil", "Resurrection" }, description = "A level-one bonemender interpretation, the Bonemender patches life and death together with alarming confidence." },
    { name = "Warlock", color = "8788EE", spells = { "Shadow Bolt", "Corruption", "Curse of Agony", "Life Tap" }, description = "A level-one warlock interpretation, the Warlock forms from shadow, curses, soul bargains, and bad ideas that work." },
    { name = "Plaguebringer", color = "556B2F", spells = { "Plague Strike", "Blood Boil", "Corruption", "Curse of Agony" }, description = "A level-one plaguebringer interpretation, the Plaguebringer wins by making time, breath, and flesh turn against the enemy." },
    { name = "Seer", color = "4169E1", spells = { "Mind Blast", "Arcane Intellect", "Shadow Word: Pain", "Moonfire" }, description = "A level-one seer interpretation, the Seer reads bright and dark signs, then weaponizes the answer." },
    { name = "Vaticinator", color = "FFD700", spells = { "Smite", "Mind Blast", "Power Word: Fortitude", "Arcane Intellect" }, description = "A level-one vaticinator interpretation, the Vaticinator sounds like prophecy and hits like a conclusion." },
    { name = "Mesmerist", color = "9932CC", spells = { "Polymorph", "Fear", "Gouge", "Frost Nova" }, description = "A level-one mesmerist interpretation, the Mesmerist wins by making enemies lose time, nerve, shape, or balance." },
    { name = "Monk", color = "00FF98", spells = { "Battle Stance", "Evasion", "Mongoose Bite", "Healing Wave" }, description = "A level-one monk interpretation, the Monk is discipline in motion: stance work, evasive footwork, close strikes, and recovery." },
    { name = "Augur", color = "7DF9FF", spells = { "Lightning Bolt", "Smite", "Earth Shock", "Healing Wave" }, description = "A level-one augur interpretation, the Augur reads the next moment through storm, faith, and the pulse of recovery." },
    { name = "Soldier", color = "C69B6D", spells = { "Battle Stance", "Heroic Strike", "Charge", "Battle Shout" }, description = "A level-one soldier interpretation, the Soldier is honest steel, loud orders, and being first into the problem." },
    { name = "Sawbones", color = "A9A9A9", spells = { "Renew", "Healing Touch", "Purify", "Gouge" }, description = "A level-one sawbones interpretation, the Sawbones mixes rough medicine with the kind of bedside manner that starts with a cheap shot." },
    { name = "Agitator", color = "FF4500", spells = { "Taunt", "Battle Shout", "Curse of Weakness", "Thunder Clap" }, description = "A level-one agitator interpretation, the Agitator makes enemies angry, weaker, and suddenly much easier to manage." },
    { name = "Wrecker", color = "C41E3A", spells = { "Sunder Armor", "Thunder Clap", "Bloodrage", "Heroic Strike" }, description = "A level-one wrecker interpretation, the Wrecker has one elegant theory: break the armor, break the rhythm, break the target." },
    { name = "Marauder", color = "8B0000", spells = { "Charge", "Raptor Strike", "Bloodrage", "Mongoose Bite" }, description = "A level-one marauder interpretation, the Marauder closes distance fast and lets appetite handle the rest." },
    { name = "Engineer", color = "B87333", spells = { "Searing Totem", "Stoneclaw Totem", "Conjure Water", "Arcane Intellect" }, description = "A level-one engineer interpretation, the Engineer turns improvised tools, totems, and clever preparation into battlefield machinery." },
    { name = "Inventor", color = "FFD700", spells = { "Searing Totem", "Arcane Missiles", "Shield of Righteousness", "Conjure Food" }, description = "A level-one inventor interpretation, the Inventor is not entirely sure why the device works, only that it does." },
    { name = "Scientist", color = "3FC7EB", spells = { "Arcane Intellect", "Polymorph", "Frost Nova", "Fire Blast" }, description = "A level-one scientist interpretation, the Scientist performs experiments in control, temperature, and consequences." },
    { name = "Machinist", color = "708090", spells = { "Auto Shot", "Steady Shot", "Searing Totem", "Shield Block" }, description = "A level-one machinist interpretation, the Machinist trusts repeatable output, stable bracing, and mechanisms that keep firing." },
    { name = "Tactician", color = "4169E1", spells = { "Hunter's Mark", "Battle Shout", "Defensive Stance", "Earthbind Totem" }, description = "A level-one tactician interpretation, the Tactician wins by deciding where everyone stands before anyone else understands why." },
}

local additionalAutoClassNames = {
    "Templar", "Hospitaler", "Knight Mendicant", "Combat Medic", "Warrior Chirurgeon", "Knight Physic", "Flower Knight", "Flesh Shaper",
    "Warlord", "Banneret", "Cavalier", "Warleader", "Champion", "Captain", "Swordmage", "Bladesinger",
    "Eldritch Knight", "Abjurant Champion", "Runeknight", "Witchblade", "Witchknight", "Shieldmage", "Force Mage", "Barrier Mage",
    "Abjurer", "Warden", "Abjurer", "Acrobat", "Adventurer", "Aeromancer", "Aeronaut", "Alchemist",
    "Alienist", "Animist", "Antihero", "Apothecary", "Arbalester", "Arbiter", "Arcanist", "Archeologist",
    "Archer", "Armiger", "Armorer", "Artificer", "Assassin", "Astrologer", "Avenger", "Bandit",
    "Barbarian", "Bard", "Battlemage", "Beastlord", "Beastrider", "Beguiler", "Berserker", "Binder",
    "Bishop", "Blackguard", "Blacksmith", "Bladesinger", "Blighter", "Bloodmage", "Bravo", "Brawler",
    "Brewmeister", "Brigand", "Cavalier", "Cavalryman", "Cestus", "Champion", "Channeler", "Charioteer",
    "Chevalier", "Chirurgeon", "Chronomancer", "Cleric", "Conjurer", "Corsair", "Crossbowman", "Crusader",
    "Cursebearer", "Deathknight", "Defender", "Demolitionist", "Demoniac", "Dervish", "Diabolist", "Diplomat",
    "Dirgesinger", "Diviner", "Djinncaller", "Doomsayer", "Dragonrider", "Dragoon", "Dreadnaught", "Dreamwalker",
    "Druid", "Duelist", "Earthspeaker", "Elementalist", "Empath", "Enchanter", "Engineer", "Evoker",
    "Executioner", "Exile", "Exorcist", "Explorer", "Falconer", "Fearmonger", "Fencer", "Fighter",
    "Firedancer", "Fleshwarper", "Forrester", "Frostmage", "Fusilier", "Gadgeteer", "Geomancer", "Gladiator",
    "Grappler", "Gravecaller", "Guardian", "Guerilla", "Gunslinger", "Gypsy", "Harbinger", "Harrier",
    "Haruspex", "Healer", "Heirophant", "Herald", "Herbalist", "Hermit", "Hero", "Hexmage",
    "Highwayman", "Hivemaster", "Hoodwink", "Hospitalier", "Houndmaster", "Hunter", "Hydromancer", "Hymnist",
    "Hypnotist", "Illusionist", "Incanter", "Infiltrator", "Inquisitor", "Invoker", "Jester", "Jinx",
    "Juggernaut", "Justicar", "Kensai", "Knight", "Lancer", "Lasher", "Legionnaire", "Lich",
    "Lightbringer", "Machinist", "Mageknight", "Magician", "Magus", "Malefactor", "Malus", "Maniac",
    "Marauder", "Mariner", "Marshal", "Masque", "Mastermind", "Medium", "Mentalist", "Mercenary",
    "Merchant", "Mindbender", "Miner", "Minstrel", "Monk", "Mountaineer", "Musketeer", "Mysterion",
    "Mystic", "Necromancer", "Nethermancer", "Ninja", "Noble", "Nomad", "Occultist", "Oracle",
    "Outcast", "Outlaw", "Outrider", "Paladin", "Paragon", "Pathfinder", "Piper", "Pirate",
    "Plaguemancer", "Planeswalker", "Poisoner", "Priest", "Prophet", "Psionicist", "Psychic", "Pugilist",
    "Pyromancer", "Qabalist", "Raider", "Raindancer", "Rake", "Ranger", "Ratcatcher", "Reaver",
    "Riddler", "Rifleman", "Ritualist", "Rogue", "Ronin", "Royal", "Runic", "Saboteur",
    "Sage", "Saint", "Samurai", "Sandman", "Sapper", "Savage", "Savant", "Scavenger",
    "Scholar", "Scout", "Scrier", "Seasinger", "Sensei", "Sentinel", "Shadowmancer", "Shaman",
    "Shapeshifter", "Sheriff", "Shieldbearer", "Sibyl", "Siegemaster", "Siren", "Skald", "Skirmisher",
    "Skycaptain", "Slavemaster", "Slayer", "Slimelord", "Sneak", "Sniper", "Soldier", "Soothsayer",
    "Sorcerer", "Soulblade", "Spearman", "Spellbinder", "Spellbreaker", "Spellknife", "Spiritualist", "Spy",
    "Stalker", "Stormlord", "Strategist", "Strider", "Summoner", "Swashbuckler", "Swordsman", "Tactician",
    "Taskmaster", "Telepath", "Templar", "Thaumaturgist", "Theurge", "Thief", "Thrall", "Tinkerer",
    "Tormentor", "Totemist", "Transmogrifist", "Transmuter", "Trapsmith", "Trickster", "Ur-Priest", "Valkyrie",
    "Vanguard", "Viking", "Vindicator", "Vizier", "Voidcaller", "Wanderer", "Warden", "Warlock",
    "Warlord", "Warpriest", "Warrior", "Weaponmaster", "Wilder", "Windcaller", "Witch", "Witchdoctor",
    "Wizard", "Wonderworker", "Wormtongue", "Wyrd", "Wyrmcaller", "Zealot", "Anti-paladin", "Lurk",
    "Psion", "Soulknife", "Myrmydon", "Soulknife", "Sohei", "Inkyo", "Oathsworn", "Mage-Blade",
    "Harrier", "Survivor", "Algai'd'siswai", "Defender", "Combatant", "Pursuer", "Scoundrel", "Lasserator",
    "Beguiler", "Deathmaster", "Duskblade", "Hexblade", "Spellthief", "Psithief", "Incarnate", "Shukenja",
    "Kensai", "Aegis", "Angakkuq", "Angler", "Aquanaut", "Cryptic", "Dread", "Kahuna",
    "Marksman", "Vitalist", "Abbot", "Aethernaut", "Archmage", "Bookbinder", "Bounty Hunter", "Cartographer",
    "Centurian", "Charlatan", "Chasseur", "Constabulary", "Consular", "Crimelord", "Demagogue", "Demonologist",
    "Disciple", "Dragonslayer", "Grave Robber", "Hedge Mage", "Impersonator", "Information Broker", "Investigator", "Kidnapper",
    "Martial Artist", "Meretrix", "Mesmerist", "Oceaneer", "Percamenarius", "Privateer", "Runecarver", "Scribe",
    "Slaver", "Snakecharmer", "Theocrat", "Tribesman", "Vigilante", "Bushi", "Wu-jen", "Luckbringer",
    "Jotun", "Onmyoji", "Rog-kalem", "Bone-breaker", "Mushakemono",
}

local autoClassPresetNames = {}
for _, preset in ipairs(ClassForge.autoClassPresets or {}) do
    if preset.name then
        autoClassPresetNames[preset.name] = true
    end
end

local generatedNamedAutoClassProfiles = {
    { color = "708090", roleFocus = "tank", keywords = { "armor", "armiger", "barrier", "defender", "guard", "guardian", "shield", "warden", "vanguard" }, spells = { "Defensive Stance", "Sunder Armor", "Devotion Aura", "Shield of Righteousness" }, description = "leans into protection, pressure, and the stubborn craft of staying in the enemy's way." },
    { color = "00FF98", roleFocus = "healer", keywords = { "chirurgeon", "cleric", "healer", "hospital", "medic", "mender", "physic", "priest", "restorer", "sawbones", "vitalist" }, spells = { "Holy Light", "Renew", "Power Word: Shield", "Healing Wave" }, description = "turns the first roll into triage, recovery, and the kind of calm that keeps allies upright." },
    { color = "228B22", roleFocus = "healer", keywords = { "animist", "druid", "flower", "forest", "herbalist", "nature", "shapeshifter", "wild", "wilder" }, spells = { "Rejuvenation", "Healing Touch", "Mark of the Wild", "Thorns" }, description = "draws on wild recovery, living wards, and the old green instinct to endure." },
    { color = "AAD372", roleFocus = "damage", keywords = { "arbalester", "archer", "crossbow", "falconer", "fusilier", "gunslinger", "hunter", "marksman", "musketeer", "ranger", "rifle", "sniper" }, spells = { "Auto Shot", "Hunter's Mark", "Arcane Shot", "Steady Shot" }, description = "favors distance, marks, and clean ranged pressure before the fight can fully close." },
    { color = "FFF468", roleFocus = "damage", keywords = { "assassin", "bandit", "brigand", "duelist", "fencer", "ninja", "rake", "rogue", "sneak", "thief" }, spells = { "Stealth", "Backstab", "Sinister Strike", "Evasion" }, description = "solves problems with unfair openings, quick hands, and a very practical exit plan." },
    { color = "00BFFF", roleFocus = "damage", keywords = { "aero", "djinn", "raindancer", "seasinger", "sky", "storm", "thunder", "wind" }, spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Searing Totem" }, description = "turns air, storm, and sudden impact into a rhythm that keeps enemies off balance." },
    { color = "FF4500", roleFocus = "damage", keywords = { "blast", "demolition", "dragon", "ember", "fire", "flame", "pyro", "wrecker" }, spells = { "Fireball", "Fire Blast", "Immolate", "Flame Shock" }, description = "prefers the direct argument: heat, force, and a battlefield that remembers where they stood." },
    { color = "3FC7EB", roleFocus = "damage", keywords = { "arcane", "archmage", "frost", "hydro", "ice", "mage", "magus", "wizard" }, spells = { "Frostbolt", "Arcane Missiles", "Frost Nova", "Arcane Intellect" }, description = "works through spell discipline, control, and bursts of practiced magical force." },
    { color = "8788EE", roleFocus = "damage", keywords = { "curse", "demon", "diabol", "hex", "malefactor", "occult", "warlock", "witch" }, spells = { "Shadow Bolt", "Corruption", "Curse of Agony", "Drain Soul" }, description = "takes the dark bargain early, then lets curses and shadow do the patient work." },
    { color = "4B5320", roleFocus = "damage", keywords = { "bone", "death", "grave", "lich", "necro", "plague", "revenant" }, spells = { "Death Coil", "Death and Decay", "Plague Strike", "Blood Strike" }, description = "carries death magic as a practical tool and treats decay as battlefield leverage." },
    { color = "C69B6D", roleFocus = "damage", keywords = { "barbarian", "brawler", "combatant", "fighter", "gladiator", "grappler", "pugilist", "soldier", "warrior" }, spells = { "Battle Stance", "Heroic Strike", "Victory Rush", "Bloodrage" }, description = "makes a simple promise: step forward, hit hard, and turn momentum into survival." },
    { color = "B87333", roleFocus = "generic", keywords = { "alchemist", "artificer", "engineer", "gadget", "inventor", "machinist", "scientist", "tinker" }, spells = { "Searing Totem", "Stoneclaw Totem", "Conjure Water", "Arcane Intellect" }, description = "uses improvised tools, clever preparation, and one or two ideas that probably should not work." },
    { color = "9932CC", roleFocus = "generic", keywords = { "beguiler", "hypnotist", "illusion", "jester", "mesmer", "riddler", "trickster" }, spells = { "Gouge", "Polymorph", "Fear", "Frost Nova" }, description = "wins by confusing the shape, timing, and confidence of whatever is standing opposite them." },
    { color = "F48CBA", roleFocus = "tank", keywords = { "cavalier", "champion", "chevalier", "crusader", "justicar", "knight", "paladin", "templar", "vindicator" }, spells = { "Righteous Fury", "Hand of Protection", "Hammer of Justice", "Seal of Righteousness" }, description = "carries oath, armor, and judgment into the first roll like a banner that bites back." },
    { color = "FF7C0A", roleFocus = "damage", keywords = { "beast", "cat", "feral", "lancer", "lasher", "marauder", "raider", "reaver", "savage" }, spells = { "Cat Form", "Claw", "Raptor Strike", "Mongoose Bite" }, description = "moves by instinct, closes quickly, and lets tooth, claw, or steel finish the thought." },
    { color = "20B2AA", roleFocus = "healer", keywords = { "aqua", "ocean", "sea", "tide", "water" }, spells = { "Healing Wave", "Frostbolt", "Earthbind Totem", "Seal of Wisdom" }, description = "flows between recovery, restraint, and elemental pressure without losing the current." },
}

local function GetAutoClassNameSeed(name)
    local seed = 0
    for index = 1, string.len(name or "") do
        seed = (seed + (string.byte(name, index) or 0) * index) % 9973
    end
    return seed
end

local function GetGeneratedNamedAutoClassProfile(name)
    local lowerName = string.lower(name or "")

    for _, profile in ipairs(generatedNamedAutoClassProfiles) do
        for _, keyword in ipairs(profile.keywords or {}) do
            if string.find(lowerName, keyword, 1, true) then
                return profile
            end
        end
    end

    return generatedNamedAutoClassProfiles[(GetAutoClassNameSeed(name) % #generatedNamedAutoClassProfiles) + 1]
end

local function BuildGeneratedNamedAutoClassPreset(name)
    local profile = GetGeneratedNamedAutoClassProfile(name)

    return {
        name = name,
        color = profile.color,
        spells = profile.spells,
        description = "A level-one " .. string.lower(name) .. " interpretation, the " .. name .. " " .. profile.description,
        minMatches = 3,
        roleFocus = profile.roleFocus,
    }
end

local function AddNamedAutoClassPreset(preset)
    if not preset or not preset.name or autoClassPresetNames[preset.name] then
        return false
    end

    local weights = {}
    for index, spellName in ipairs(preset.spells or {}) do
        weights[spellName] = math.max(3, 8 - math.floor((index - 1) / 2))
    end

    ClassForge.autoClassPresets[#ClassForge.autoClassPresets + 1] = {
        name = preset.name,
        color = preset.color,
        description = preset.description,
        requiredAny = preset.spells,
        weights = weights,
        minScore = 26,
        minMatches = preset.minMatches or 3,
        dropdownPreset = preset.dropdownPreset,
        namedPreset = true,
        roleFocus = preset.roleFocus,
    }

    autoClassPresetNames[preset.name] = true
    return true
end

for _, preset in ipairs(dropdownAutoClassPresets) do
    preset.dropdownPreset = true
    AddNamedAutoClassPreset(preset)
end

for _, preset in ipairs(supplementalNamedAutoClassPresets) do
    AddNamedAutoClassPreset(preset)
end

for _, name in ipairs(additionalAutoClassNames) do
    AddNamedAutoClassPreset(BuildGeneratedNamedAutoClassPreset(name))
end

local targetAutoClassRoleCounts = {
    tank = 300,
    healer = 300,
    damage = 300,
    generic = 300,
}

local generatedAutoClassNamingPrefixes = {
    "Fencer",
    "Grappler",
    "Marksman",
    "Scout",
    "Sage",
    "Ranger",
    "Sorcerer",
    "Conjurer",
    "Priest",
    "Artificer",
    "Druid",
    "Enhancer",
    "Tactician",
    "Battle Dancer",
    "Daemonologist",
    "Fairy Tamer",
}

local generatedAutoClassNamingSuffixes = {
    "Fighter",
    "Wanderer",
    "Invoker",
    "Wayfarer",
    "Striker",
    "Binder",
    "Mystic",
    "Warden",
    "Herald",
    "Arcanist",
    "Sentinel",
    "Channeler",
    "Skirmisher",
    "Seeker",
    "Spellblade",
    "Adventurer",
}

local function GetGeneratedAutoClassName(theme, form, themeIndex, formIndex)
    local seed = (themeIndex * 37) + (formIndex * 17)
    local prefix = form.prefix
    local suffix = theme.suffix

    if seed % 4 == 0 then
        prefix = generatedAutoClassNamingPrefixes[(seed % #generatedAutoClassNamingPrefixes) + 1]
    elseif seed % 6 == 0 then
        prefix = form.prefix .. " " .. generatedAutoClassNamingPrefixes[((seed + formIndex) % #generatedAutoClassNamingPrefixes) + 1]
    end

    if seed % 5 == 0 then
        suffix = generatedAutoClassNamingSuffixes[(seed % #generatedAutoClassNamingSuffixes) + 1]
    elseif seed % 7 == 0 then
        suffix = theme.suffix .. " " .. generatedAutoClassNamingSuffixes[((seed + themeIndex) % #generatedAutoClassNamingSuffixes) + 1]
    end

    return prefix .. " " .. suffix
end

local tankAutoClassThemes = {
    { suffix = "Ironwall", color = "708090", spells = { "Defensive Stance", "Sunder Armor", "Shield Block", "Devotion Aura" }, description = "front-line defender who turns stance, armor pressure, and steady discipline into a wall that refuses to move." },
    { suffix = "Stonehide", color = "556B2F", spells = { "Bear Form", "Stoneskin Totem", "Thorns", "Mark of the Wild" }, description = "wild protector who layers hide, bark, stone, and thorns into stubborn survival." },
    { suffix = "Sunshield", color = "F48CBA", spells = { "Righteous Fury", "Devotion Aura", "Shield of Righteousness", "Holy Light" }, description = "radiant shield-bearer who makes faith, armor, and holy threat feel like one heavy oath." },
    { suffix = "Thunderwall", color = "1E90FF", spells = { "Thunder Clap", "Lightning Shield", "Earth Shock", "Stoneclaw Totem" }, description = "storm-braced sentinel who answers pressure with thunder, shock, and crackling retaliation." },
    { suffix = "Bloodward", color = "8B0000", spells = { "Blood Presence", "Blood Strike", "Death Strike", "Death and Decay" }, description = "crimson bulwark who turns blood rites and grim runes into a hard point on the battlefield." },
    { suffix = "Frostguard", color = "AFEEEE", spells = { "Frost Presence", "Icy Touch", "Frost Armor", "Frost Nova" }, description = "cold guardian who slows the fight down until every enemy has to break against them." },
    { suffix = "Gravebastion", color = "4B5320", spells = { "Demon Skin", "Power Word: Fortitude", "Death and Decay", "Curse of Weakness" }, description = "grave-bound anchor who survives through grim endurance, curses, and a refusal to fall cleanly." },
    { suffix = "Rockbreaker", color = "B87333", spells = { "Rockbiter Weapon", "Strength of Earth Totem", "Sunder Armor", "Heroic Strike" }, description = "earth-weighted bruiser who holds attention by hitting like a tool meant for breaking stone." },
    { suffix = "Wildbulwark", color = "228B22", spells = { "Bear Form", "Growl", "Demoralizing Roar", "Maul" }, description = "feral defender who uses presence, roar, and raw animal weight to make the enemy commit." },
    { suffix = "Oathplate", color = "FFDE59", spells = { "Blessing of Might", "Hand of Protection", "Devotion Aura", "Seal of Righteousness" }, description = "oath-armored protector who uses blessing, seal, and discipline to hold the line." },
    { suffix = "Ashbastion", color = "A9A9A9", spells = { "Demon Skin", "Frost Armor", "Thorns", "Consecration" }, description = "ash-clad warder who turns every layer of protection into punishment for attackers." },
    { suffix = "Tidewall", color = "20B2AA", spells = { "Earthbind Totem", "Healing Wave", "Stoneclaw Totem", "Lightning Shield" }, description = "tide-stable guard who controls space, absorbs attention, and restores enough to keep standing." },
    { suffix = "Voidbulwark", color = "2F4F4F", spells = { "Power Word: Shield", "Fear", "Demon Skin", "Shadow Word: Pain" }, description = "shadowed shield who makes enemies hesitate before they can even begin to break through." },
    { suffix = "Boneguard", color = "F5F5DC", spells = { "Shield Block", "Power Word: Fortitude", "Death Coil", "Resurrection" }, description = "bone-marked protector who treats death as a nearby tool rather than a final threat." },
    { suffix = "Vanguard", color = "C69B6D", spells = { "Battle Stance", "Charge", "Battle Shout", "Victory Rush" }, description = "first-through-the-door fighter who turns momentum, shout, and impact into battlefield control." },
}

local healerAutoClassThemes = {
    { suffix = "Lifebloom", color = "00FF98", spells = { "Rejuvenation", "Healing Touch", "Mark of the Wild", "Thorns" }, description = "green-hearted healer who lets nature mend wounds while the thorns remind enemies to stop trying." },
    { suffix = "Lightwell", color = "FFFFFF", spells = { "Holy Light", "Renew", "Power Word: Fortitude", "Smite" }, description = "bright field medic who mixes holy recovery, faith, and simple punishment into a steady rhythm." },
    { suffix = "Wisdomtide", color = "20B2AA", spells = { "Healing Wave", "Seal of Wisdom", "Earthbind Totem", "Lightning Bolt" }, description = "flowing healer who balances water, wisdom, control, and sudden elemental reply." },
    { suffix = "Spiritmender", color = "7FFFD4", spells = { "Renew", "Healing Wave", "Power Word: Shield", "Fade" }, description = "spirit-guided mender who protects, fades back, and lets recovery keep moving." },
    { suffix = "Suncleric", color = "FFDE59", spells = { "Holy Light", "Blessing of Might", "Seal of Righteousness", "Lay on Hands" }, description = "sunlit cleric who carries last-second miracles and radiant certainty into the first roll." },
    { suffix = "Graceweaver", color = "F48CBA", spells = { "Greater Heal", "Renew", "Hand of Protection", "Power Word: Shield" }, description = "graceful preserver who wraps allies in shields and answers crisis with decisive healing." },
    { suffix = "Moonmender", color = "7DF9FF", spells = { "Moonfire", "Rejuvenation", "Healing Touch", "Entangling Roots" }, description = "moon-touched healer who binds space, restores flesh, and punishes with silver light." },
    { suffix = "Bloodmender", color = "8B0000", spells = { "Blood Presence", "Death Strike", "Renew", "Drain Soul" }, description = "strange crimson healer who steals, spends, and returns vitality in unsettling loops." },
    { suffix = "Frostsalve", color = "AFEEEE", spells = { "Frost Armor", "Frost Nova", "Holy Light", "Renew" }, description = "cool-headed medic who buys time with frost before sealing the wound." },
    { suffix = "Shieldchant", color = "4169E1", spells = { "Power Word: Shield", "Mage Armor", "Arcane Intellect", "Renew" }, description = "ward-chanter who treats shields, intellect, and patient recovery as one protective song." },
    { suffix = "Emberrenew", color = "FF4500", spells = { "Immolate", "Fire Blast", "Healing Wave", "Holy Light" }, description = "ember-bright healer who burns away danger and closes wounds before the smoke clears." },
    { suffix = "Soulwell", color = "6A0DAD", spells = { "Drain Soul", "Create Healthstone", "Renew", "Power Word: Shield" }, description = "soul-weaving support who turns dark bargains into practical survival." },
    { suffix = "Starhealer", color = "4169E1", spells = { "Smite", "Moonfire", "Greater Heal", "Power Word: Fortitude" }, description = "celestial healer who reads the fight through omens, light, and carefully timed restoration." },
    { suffix = "Wildspring", color = "228B22", spells = { "Healing Touch", "Rejuvenation", "Cat Form", "Mark of the Wild" }, description = "wild spring healer who keeps one foot in instinct and the other in restoration." },
    { suffix = "Totemkeeper", color = "0070DD", spells = { "Healing Wave", "Stoneskin Totem", "Strength of Earth Totem", "Searing Totem" }, description = "totem-bound keeper who turns the field itself into a quiet healing engine." },
}

local damageAutoClassThemes = {
    { suffix = "Stormblade", color = "00BFFF", spells = { "Sinister Strike", "Earth Shock", "Flametongue Weapon", "Lightning Bolt" }, description = "storm-cut striker who folds shocks, weapon flame, and clean blade work into one violent tempo." },
    { suffix = "Shadowcut", color = "3B0A45", spells = { "Backstab", "Shadow Word: Pain", "Shadow Bolt", "Gouge" }, description = "shadow-duelist who opens from an ugly angle and leaves darkness to finish the argument." },
    { suffix = "Emberknife", color = "FF4500", spells = { "Immolate", "Fire Blast", "Sinister Strike", "Flametongue Weapon" }, description = "close-range burner who turns every cut into a spark and every spark into a problem." },
    { suffix = "Frostfang", color = "AFEEEE", spells = { "Frostbolt", "Icy Touch", "Mongoose Bite", "Raptor Strike" }, description = "cold-blooded predator who slows prey before closing in with tooth and steel." },
    { suffix = "Blightspine", color = "556B2F", spells = { "Corruption", "Serpent Sting", "Plague Strike", "Curse of Agony" }, description = "damage-over-time hunter who lets poison, curse, and plague do the patient work." },
    { suffix = "Moonshot", color = "7DF9FF", spells = { "Arcane Shot", "Moonfire", "Auto Shot", "Hunter's Mark" }, description = "ranged skirmisher who marks the target and threads moonlit shots through the opening." },
    { suffix = "Runeblade", color = "C41E3A", spells = { "Blood Strike", "Obliterate", "Plague Strike", "Death Coil" }, description = "rune-fed executioner who translates death magic into hard weapon damage." },
    { suffix = "Hawkshot", color = "AAD372", spells = { "Aspect of the Hawk", "Auto Shot", "Arcane Shot", "Steady Shot" }, description = "disciplined marksman who trusts a clear line, a steady shot, and patience." },
    { suffix = "Felbrand", color = "8788EE", spells = { "Shadow Bolt", "Immolate", "Curse of Agony", "Life Tap" }, description = "reckless war-caster who pays in life and collects in flame, curse, and shadow." },
    { suffix = "Thunderreaver", color = "1E90FF", spells = { "Stormstrike", "Thunder Clap", "Earth Shock", "Heroic Strike" }, description = "thunderous bruiser who turns impact and shock into a rolling front of damage." },
    { suffix = "Venomblade", color = "3B0A45", spells = { "Backstab", "Serpent Sting", "Gouge", "Eviscerate" }, description = "venom-edged opportunist who stacks pain until the finishing cut is obvious." },
    { suffix = "Starburst", color = "4169E1", spells = { "Arcane Missiles", "Fireball", "Moonfire", "Smite" }, description = "volatile caster who throws bright schools of magic together and trusts the blast." },
    { suffix = "Plagueheart", color = "4B5320", spells = { "Death and Decay", "Blood Boil", "Corruption", "Flame Shock" }, description = "blight-hearted caster who makes the ground, blood, and air hostile at once." },
    { suffix = "Arcaneburst", color = "9932CC", spells = { "Arcane Missiles", "Fire Blast", "Mind Blast", "Lightning Bolt" }, description = "burst-minded spellfighter who favors immediate, loud, and difficult-to-ignore answers." },
    { suffix = "Ironhowl", color = "C69B6D", spells = { "Heroic Strike", "Battle Shout", "Victory Rush", "Rend" }, description = "weapon-forward brawler who turns shout, bleed, and momentum into practical violence." },
}

local function AddGeneratedAutoClassPreset(category, theme, form, themeIndex, formIndex, categoryOffset)
    local weights = {}
    local requiredAny = {}
    for _, spellName in ipairs(theme.spells) do
        weights[spellName] = 6
        requiredAny[#requiredAny + 1] = spellName
    end
    for _, spellName in ipairs(form.spells) do
        weights[spellName] = (weights[spellName] or 0) + 4
        requiredAny[#requiredAny + 1] = spellName
    end

    ClassForge.autoClassPresets[#ClassForge.autoClassPresets + 1] = {
        name = GetGeneratedAutoClassName(theme, form, themeIndex + (categoryOffset or 0), formIndex),
        color = theme.color,
        description = "A " .. theme.description .. " " .. form.description,
        requiredAny = requiredAny,
        weights = weights,
        minScore = 23,
        roleFocus = category,
    }
end

local function AddGeneratedAutoClassBucket(category, themes, forms, targetCount, existingCount, categoryOffset)
    local bucketCount = existingCount or 0

    for themeIndex, theme in ipairs(themes) do
        if bucketCount >= targetCount then
            break
        end

        for formIndex, form in ipairs(forms) do
            if bucketCount >= targetCount then
                break
            end

            AddGeneratedAutoClassPreset(category, theme, form, themeIndex, formIndex, categoryOffset)
            bucketCount = bucketCount + 1
        end
    end

    return bucketCount
end

local existingGenericAutoClassCount = #ClassForge.autoClassPresets
local genericAutoClassTarget = math.max(targetAutoClassRoleCounts.generic, existingGenericAutoClassCount)

AddGeneratedAutoClassBucket("tank", tankAutoClassThemes, generatedAutoClassForms, targetAutoClassRoleCounts.tank, 0, 100)
AddGeneratedAutoClassBucket("healer", healerAutoClassThemes, generatedAutoClassForms, targetAutoClassRoleCounts.healer, 0, 200)
AddGeneratedAutoClassBucket("damage", damageAutoClassThemes, generatedAutoClassForms, targetAutoClassRoleCounts.damage, 0, 300)
AddGeneratedAutoClassBucket("generic", generatedAutoClassThemes, generatedAutoClassForms, genericAutoClassTarget, existingGenericAutoClassCount, 400)

local function GetUniqueAutoClassPaletteColor(index)
    local hue = (index * 0.61803398875) % 1
    local saturation = 0.58 + ((index * 37) % 28) / 100
    local value = 0.74 + ((index * 53) % 24) / 100
    local segment = math.floor(hue * 6)
    local fraction = (hue * 6) - segment
    local p = value * (1 - saturation)
    local q = value * (1 - (fraction * saturation))
    local t = value * (1 - ((1 - fraction) * saturation))
    local red, green, blue

    segment = segment % 6
    if segment == 0 then
        red, green, blue = value, t, p
    elseif segment == 1 then
        red, green, blue = q, value, p
    elseif segment == 2 then
        red, green, blue = p, value, t
    elseif segment == 3 then
        red, green, blue = p, q, value
    elseif segment == 4 then
        red, green, blue = t, p, value
    else
        red, green, blue = value, p, q
    end

    return string.format(
        "%02X%02X%02X",
        math.floor((red * 255) + 0.5),
        math.floor((green * 255) + 0.5),
        math.floor((blue * 255) + 0.5)
    )
end

local usedAutoClassColors = {}
for index, preset in ipairs(ClassForge.autoClassPresets or {}) do
    local colorIndex = index
    local color = GetUniqueAutoClassPaletteColor(colorIndex)

    while usedAutoClassColors[color] do
        colorIndex = colorIndex + 4096
        color = GetUniqueAutoClassPaletteColor(colorIndex)
    end

    preset.color = color
    usedAutoClassColors[color] = true
end
