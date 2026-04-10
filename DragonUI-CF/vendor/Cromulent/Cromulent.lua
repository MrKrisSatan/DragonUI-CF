--[[
	Cromulent - Custom 3.3.5 Zone Info
	Original credit to ckknight for Cartographer_ZoneInfo

	Customised for private/custom WotLK servers:
	- Level cap 60
	- Outland available at 48
	- Northrend available at 48
--]]

Cromulent = LibStub("AceAddon-3.0"):NewAddon("Cromulent", "AceHook-3.0")
local Cromulent, self = Cromulent, Cromulent

local L = LibStub("AceLocale-3.0"):GetLocale("Cromulent")
local T = LibStub("LibTourist-3.0")

local string_format = string.format
local string_gsub = string.gsub
local table_concat = table.concat
local table_insert = table.insert
local table_wipe = table.wipe

local GetCurrentMapContinent = GetCurrentMapContinent
local GetNumSkillLines = GetNumSkillLines
local GetSkillLineInfo = GetSkillLineInfo
local GetSpellInfo = GetSpellInfo
local UnitLevel = UnitLevel
local GetMapContinents = GetMapContinents

local fishingSpell

-----------------------------------------------------------------------
-- CUSTOM SERVER DATA
-----------------------------------------------------------------------
-- Format:
-- ["Zone Name"] = {low, high}

local CUSTOM_ZONE_LEVELS = {
	-------------------------------------------------------------------
	-- EASTERN KINGDOMS
	-------------------------------------------------------------------
	["Dun Morogh"] = {1, 10},
	["Elwynn Forest"] = {1, 10},
	["Tirisfal Glades"] = {1, 10},
	["Eversong Woods"] = {1, 10},
	["Ghostlands"] = {10, 20},

	["Loch Modan"] = {10, 20},
	["Westfall"] = {10, 20},
	["Silverpine Forest"] = {10, 20},
	["Redridge Mountains"] = {15, 25},
	["Duskwood"] = {18, 28},
	["Wetlands"] = {20, 30},
	["Hillsbrad Foothills"] = {20, 30},

	["Arathi Highlands"] = {25, 35},
	["Alterac Mountains"] = {30, 40},
	["Stranglethorn Vale"] = {30, 45},
	["Badlands"] = {35, 45},
	["Swamp of Sorrows"] = {35, 45},
	["The Hinterlands"] = {40, 50},
	["Hinterlands"] = {40, 50}, -- fallback for weird map labels
	["Searing Gorge"] = {43, 50},
	["Western Plaguelands"] = {45, 51},

	["Burning Steppes"] = {50, 54},
	["Eastern Plaguelands"] = {51, 58},
	["Deadwind Pass"] = {52, 58},
	["Blasted Lands"] = {54, 58},
	["Isle of Quel'Danas"] = {58, 60},

	-------------------------------------------------------------------
	-- KALIMDOR
	-------------------------------------------------------------------
	["Durotar"] = {1, 10},
	["Mulgore"] = {1, 10},
	["Teldrassil"] = {1, 10},
	["Darkshore"] = {10, 20},

	["The Barrens"] = {10, 25},
	["Ashenvale"] = {18, 30},
	["Stonetalon Mountains"] = {15, 27},
	["Thousand Needles"] = {25, 35},
	["Desolace"] = {30, 40},
	["Dustwallow Marsh"] = {35, 45},

	["Feralas"] = {40, 50},
	["Tanaris"] = {40, 50},
	["Felwood"] = {45, 50},
	["Azshara"] = {45, 50},
	["Un'Goro Crater"] = {48, 55},
	["Winterspring"] = {50, 58},
	["Silithus"] = {55, 60},
	["Moonglade"] = {45, 55},

	-------------------------------------------------------------------
	-- STARTER / EXPANSION ISLANDS
	-------------------------------------------------------------------
	["Azuremyst Isle"] = {1, 10},
	["Bloodmyst Isle"] = {10, 20},

	-------------------------------------------------------------------
	-- OUTLAND (CUSTOM 48-60)
	-------------------------------------------------------------------
	["Hellfire Peninsula"] = {48, 52},
	["Zangarmarsh"] = {50, 54},
	["Terokkar Forest"] = {51, 55},
	["Nagrand"] = {53, 57},
	["Blade's Edge Mountains"] = {54, 58},
	["Netherstorm"] = {56, 60},
	["Shadowmoon Valley"] = {57, 60},

	-------------------------------------------------------------------
	-- NORTHREND (CUSTOM 48-60)
	-------------------------------------------------------------------
	["Borean Tundra"] = {48, 52},
	["Howling Fjord"] = {48, 52},
	["Dragonblight"] = {51, 55},
	["Grizzly Hills"] = {53, 56},
	["Zul'Drak"] = {54, 57},
	["Sholazar Basin"] = {55, 58},
	["Crystalsong Forest"] = {55, 58},
	["The Storm Peaks"] = {57, 60},
	["Storm Peaks"] = {57, 60}, -- fallback for weird labels
	["Icecrown"] = {58, 60},
	["Wintergrasp"] = {58, 60},

	-------------------------------------------------------------------
	-- CITIES / SPECIAL
	-------------------------------------------------------------------
	["Stormwind City"] = {1, 60},
	["Ironforge"] = {1, 60},
	["Darnassus"] = {1, 60},
	["The Exodar"] = {1, 60},
	["Orgrimmar"] = {1, 60},
	["Thunder Bluff"] = {1, 60},
	["Undercity"] = {1, 60},
	["Silvermoon City"] = {1, 60},
	["Shattrath City"] = {48, 60},
	["Dalaran"] = {48, 60},
	["Blackrock Mountain"] = {50, 60},
}

local CUSTOM_INSTANCE_LEVELS = {
	-------------------------------------------------------------------
	-- CLASSIC DUNGEONS
	-------------------------------------------------------------------
	["Ragefire Chasm"] = {13, 18},
	["The Deadmines"] = {17, 22},
	["Wailing Caverns"] = {17, 24},
	["Shadowfang Keep"] = {22, 28},
	["Blackfathom Deeps"] = {24, 30},
	["The Stockade"] = {24, 30},
	["Gnomeregan"] = {29, 35},
	["Razorfen Kraul"] = {30, 36},
	["Scarlet Monastery"] = {32, 40},
	["Razorfen Downs"] = {37, 43},
	["Uldaman"] = {40, 46},
	["Zul'Farrak"] = {44, 50},
	["Maraudon"] = {46, 52},
	["Sunken Temple"] = {50, 56},
	["Blackrock Depths"] = {52, 58},
	["Dire Maul"] = {54, 60},
	["Scholomance"] = {56, 60},
	["Stratholme"] = {56, 60},
	["Lower Blackrock Spire"] = {56, 60},
	["Upper Blackrock Spire"] = {58, 60},

	-------------------------------------------------------------------
	-- CLASSIC RAIDS
	-------------------------------------------------------------------
	["Molten Core"] = {60, 60},
	["Onyxia's Lair"] = {60, 60},
	["Blackwing Lair"] = {60, 60},
	["Ruins of Ahn'Qiraj"] = {60, 60},
	["Temple of Ahn'Qiraj"] = {60, 60},
	["Naxxramas"] = {60, 60},
	["Karazhan Crypt"] = {58, 60}, -- custom/fallback if your server uses odd labels

	-------------------------------------------------------------------
	-- OUTLAND DUNGEONS
	-------------------------------------------------------------------
	["Hellfire Ramparts"] = {48, 50},
	["The Blood Furnace"] = {49, 52},
	["The Shattered Halls"] = {55, 60},

	["The Slave Pens"] = {50, 53},
	["The Underbog"] = {51, 54},
	["The Steamvault"] = {54, 57},

	["Mana-Tombs"] = {51, 54},
	["Auchenai Crypts"] = {52, 55},
	["Sethekk Halls"] = {54, 57},
	["Shadow Labyrinth"] = {56, 60},

	["Old Hillsbrad Foothills"] = {55, 58},
	["The Black Morass"] = {57, 60},

	["The Mechanar"] = {55, 58},
	["The Botanica"] = {56, 60},
	["The Arcatraz"] = {57, 60},

	["Magisters' Terrace"] = {58, 60},

	-------------------------------------------------------------------
	-- OUTLAND RAIDS
	-------------------------------------------------------------------
	["Karazhan"] = {60, 60},
	["Gruul's Lair"] = {60, 60},
	["Magtheridon's Lair"] = {60, 60},
	["Serpentshrine Cavern"] = {60, 60},
	["Tempest Keep"] = {60, 60},
	["The Eye"] = {60, 60},
	["Black Temple"] = {60, 60},
	["Hyjal Summit"] = {60, 60},
	["Sunwell Plateau"] = {60, 60},
	["Zul'Aman"] = {60, 60},

	-------------------------------------------------------------------
	-- NORTHREND DUNGEONS
	-------------------------------------------------------------------
	["Utgarde Keep"] = {48, 50},
	["The Nexus"] = {48, 51},
	["Azjol-Nerub"] = {50, 53},
	["Ahn'kahet: The Old Kingdom"] = {52, 55},
	["Drak'Tharon Keep"] = {53, 56},
	["Violet Hold"] = {54, 57},
	["Gundrak"] = {54, 57},
	["Halls of Stone"] = {55, 58},
	["Halls of Lightning"] = {56, 59},
	["The Oculus"] = {56, 59},
	["Utgarde Pinnacle"] = {57, 60},
	["Trial of the Champion"] = {58, 60},
	["The Forge of Souls"] = {58, 60},
	["Pit of Saron"] = {58, 60},
	["Halls of Reflection"] = {58, 60},

	-------------------------------------------------------------------
	-- NORTHREND RAIDS
	-------------------------------------------------------------------
	["Naxxramas (WotLK)"] = {60, 60},
	["The Obsidian Sanctum"] = {60, 60},
	["The Eye of Eternity"] = {60, 60},
	["Vault of Archavon"] = {60, 60},
	["Ulduar"] = {60, 60},
	["Trial of the Crusader"] = {60, 60},
	["Onyxia's Lair (WotLK)"] = {60, 60},
	["Icecrown Citadel"] = {60, 60},
	["The Ruby Sanctum"] = {60, 60},
}

-----------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------
local function GetCustomLevel(zone)
	if CUSTOM_ZONE_LEVELS[zone] then
		return CUSTOM_ZONE_LEVELS[zone][1], CUSTOM_ZONE_LEVELS[zone][2]
	end
	if CUSTOM_INSTANCE_LEVELS[zone] then
		return CUSTOM_INSTANCE_LEVELS[zone][1], CUSTOM_INSTANCE_LEVELS[zone][2]
	end
	return nil, nil
end

local function GetZoneLevel(zone)
	local low, high = GetCustomLevel(zone)
	if low and high then
		return low, high
	end
	return T:GetLevel(zone)
end

local function GetLevelColorFromRange(low, high)
	local playerLevel = UnitLevel("player")
	local level = high or low or 0

	if level <= 0 then
		return 1, 1, 1
	elseif playerLevel >= level + 5 then
		return 0.5, 0.5, 0.5 -- gray
	elseif playerLevel >= level + 3 then
		return 0, 1, 0 -- green
	elseif playerLevel >= level - 2 then
		return 1, 1, 0 -- yellow
	elseif playerLevel >= level - 4 then
		return 1, 0.5, 0 -- orange
	else
		return 1, 0, 0 -- red
	end
end

local function SafeGetFactionColor(zone)
	local r, g, b = T:GetFactionColor(zone)
	if not r or not g or not b then
		return 1, 1, 1
	end
	return r, g, b
end

-----------------------------------------------------------------------
-- ADDON LIFECYCLE
-----------------------------------------------------------------------
function Cromulent:OnEnable()
	if not self.frame then
		self.frame = CreateFrame("Frame", "CromulentZoneInfo", WorldMapFrame)

		self.frame.text = WorldMapFrameAreaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		local text = self.frame.text
		local font, size = GameFontHighlightLarge:GetFont()
		text:SetFont(font, size, "OUTLINE")
		text:SetPoint("TOP", WorldMapFrameAreaDescription, "BOTTOM", 0, -5)
		text:SetWidth(1024)
	end

	fishingSpell = GetSpellInfo(7620)
	self.frame:Show()
	self:SecureHookScript(WorldMapButton, "OnUpdate", "WorldMapButton_OnUpdate")
end

function Cromulent:OnDisable()
	self.frame:Hide()
	WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
end

-----------------------------------------------------------------------
-- MAP DISPLAY
-----------------------------------------------------------------------
local lastZone
local t = {}

function Cromulent:WorldMapButton_OnUpdate()
	if not self.frame then
		return
	end

	if not WorldMapDetailFrame:IsShown() or not WorldMapFrameAreaLabel:IsShown() then
		self.frame.text:SetText("")
		lastZone = nil
		return
	end

	local underAttack = false
	local zone = WorldMapFrameAreaLabel:GetText()

	if zone then
		zone = string_gsub(zone, " |cff.+$", "")
		if WorldMapFrameAreaDescription:GetText() then
			underAttack = true
			zone = string_gsub(WorldMapFrameAreaDescription:GetText(), " |cff.+$", "")
		end
	end

	-- Hide info when hovering over continents on the old world map
	if GetCurrentMapContinent() == 0 then
		local c1, c2 = GetMapContinents()
		if zone == c1 or zone == c2 then
			WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
			self.frame.text:SetText("")
			return
		end
	end

	if not zone or not T:IsZoneOrInstance(zone) then
		zone = WorldMapFrame.areaName
	end

	WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)

	if zone and (T:IsZoneOrInstance(zone) or T:DoesZoneHaveInstances(zone) or CUSTOM_ZONE_LEVELS[zone] or CUSTOM_INSTANCE_LEVELS[zone]) then
		local fr, fg, fb = SafeGetFactionColor(zone)

		if not underAttack then
			WorldMapFrameAreaLabel:SetTextColor(fr, fg, fb)
			WorldMapFrameAreaDescription:SetTextColor(1, 1, 1)
		else
			WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
			WorldMapFrameAreaDescription:SetTextColor(fr, fg, fb)
		end

		local low, high = GetZoneLevel(zone)
		local minFish = T:GetFishingLevel(zone)
		local fishingSkillText

		-------------------------------------------------------------------
		-- Fishing skill
		-------------------------------------------------------------------
		if minFish then
			for i = 1, GetNumSkillLines() do
				local skillName, _, _, skillRank = GetSkillLineInfo(i)
				if skillName == fishingSpell then
					local r, g, b = 1, 1, 0
					local r1, g1, b1 = 1, 0, 0

					if minFish < skillRank then
						r1, g1, b1 = 0, 1, 0
					end

					fishingSkillText = string_format(
						"|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r",
						r * 255, g * 255, b * 255, fishingSpell,
						r1 * 255, g1 * 255, b1 * 255, minFish
					)
					break
				end
			end

			if not fishingSkillText then
				minFish = nil
			end
		end

		-------------------------------------------------------------------
		-- Zone level display
		-------------------------------------------------------------------
		if low and high and low > 0 and high > 0 then
			local r, g, b = GetLevelColorFromRange(low, high)
			local levelText

			if low == high then
				levelText = string_format(" |cff%02x%02x%02x[%d]|r", r * 255, g * 255, b * 255, high)
			else
				levelText = string_format(" |cff%02x%02x%02x[%d-%d]|r", r * 255, g * 255, b * 255, low, high)
			end

			local groupSize = T:GetInstanceGroupSize(zone)
			local sizeText = ""

			if groupSize and groupSize > 0 then
				sizeText = " " .. string_format(L["%d-man"], groupSize)
			end

			if not underAttack then
				WorldMapFrameAreaLabel:SetText(string_gsub(WorldMapFrameAreaLabel:GetText(), " |cff.+$", "") .. levelText .. sizeText)
			else
				WorldMapFrameAreaDescription:SetText(string_gsub(WorldMapFrameAreaDescription:GetText(), " |cff.+$", "") .. levelText .. sizeText)
			end
		end

		-------------------------------------------------------------------
		-- Instance list
		-------------------------------------------------------------------
		if T:DoesZoneHaveInstances(zone) then
			if lastZone ~= zone then
				lastZone = zone
				table_insert(t, string_format("|cffffff00%s:|r", L["Instances"]))

				for instance in T:IterateZoneInstances(zone) do
					local complex = T:GetComplex(instance)
					local ilow, ihigh = GetZoneLevel(instance)
					local r1, g1, b1 = SafeGetFactionColor(instance)
					local r2, g2, b2 = GetLevelColorFromRange(ilow, ihigh)
					local groupSize = T:GetInstanceGroupSize(instance)
					local name = instance

					if complex then
						name = complex .. " - " .. instance
					end

					if ilow and ihigh then
						if ilow == ihigh then
							if groupSize and groupSize > 0 then
								table_insert(t, string_format(
									"|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r " .. L["%d-man"],
									r1 * 255, g1 * 255, b1 * 255, name,
									r2 * 255, g2 * 255, b2 * 255, ihigh,
									groupSize
								))
							else
								table_insert(t, string_format(
									"|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r",
									r1 * 255, g1 * 255, b1 * 255, name,
									r2 * 255, g2 * 255, b2 * 255, ihigh
								))
							end
						else
							if groupSize and groupSize > 0 then
								table_insert(t, string_format(
									"|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r " .. L["%d-man"],
									r1 * 255, g1 * 255, b1 * 255, name,
									r2 * 255, g2 * 255, b2 * 255, ilow, ihigh,
									groupSize
								))
							else
								table_insert(t, string_format(
									"|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r",
									r1 * 255, g1 * 255, b1 * 255, name,
									r2 * 255, g2 * 255, b2 * 255, ilow, ihigh
								))
							end
						end
					else
						-- fallback if instance level can't be resolved
						table_insert(t, string_format(
							"|cff%02x%02x%02x%s|r",
							r1 * 255, g1 * 255, b1 * 255, name
						))
					end
				end

				if minFish and fishingSkillText then
					table_insert(t, fishingSkillText)
				end

				self.frame.text:SetText(table_concat(t, "\n"))
				table_wipe(t)
			end
		else
			if minFish and fishingSkillText then
				self.frame.text:SetText(fishingSkillText)
			else
				self.frame.text:SetText("")
			end
			lastZone = nil
		end
	elseif not zone then
		lastZone = nil
		self.frame.text:SetText("")
	end
end