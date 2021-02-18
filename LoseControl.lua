
--[[
-------------------------------------------
-- Addon: LoseControl
-- Version: 6.11
-- Authors: Kouri, millanzarreta
-------------------------------------------

-- Changelog:

No more changelogs in this file. To consult the last changes check https://www.curseforge.com/wow/addons/losecontrol/changes

Updated for 8.0.1
- Added more PvE spells (Uldir Raid, BfA Mythics and BfA Island Expeditions)
- Added ImmunePhysical category
- Added Interrupt category
- Fixed some minor bugs

Updated for 7.3.0 by millanzarreta
- Added Antorus Raid spells
- Added The Seat of the Triumvirate spells

Updated for 7.2.5 by millanzarreta
- Updated the spellID list to reflect the class changes
- Added more PvE spells (ToS Raid, Chromie Scenario)

Updated for 7.2.0 by millanzarreta
- Updated the spell ID list to reflect the class changes
- Added a large amount of PvE spells (EN Raid, ToV Raid, NH Raid and Legions Mythics) to spell ID list
- Added new option to allows hide party frames when the player is in raid group (never in arena)
- Improved the code to detect automatically the debuffs without defined duration (before, we had to add manually the spellId to the list)
- Fixed an error that could cause the icon to not display properly when the effect have not a defined time

Updated for 7.1.0 by millanzarreta
- Added most spells to spell ID list and corrected others (a lot of work, really...)
- Fixed the problem with spells that were not showing correctly (spells without duration, such as Solar Beam, Grounding Totem, Smoke Bomb, ...)
- Added new option to allows manage the blizzard cooldown countdown
- Added new option to allows remove the cooldown on bars for CC effects (tested for default Bars and Bartender4 Bars)
- Fixed a bug: now type /lc opens directly the LoseControl panel instead of Interface panel

Updated for 7.0.3 (Legion) by Hid@Emeriss and Wardz
- Added a large amount of spells, hopefully I didn't miss anything (important)
- Removed spell IDs that no longer exists.
- Added Ice Nova (mage) and Rake (druid) to spell ID list
- Fixed cooldown spiral

-- Code Credits - to the people whose code I borrowed and learned from:

Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

--Anchor to Gladius and Stealth/Alpha w/Gloss Option  Added
--Player LOCBliz Add All New CC  Added
----Add CC/Silence/Disarm/Root/Interrupt/Other Added
----Add Snare from string check “Movement”  Added
--Selected Priorities Show Newest Duration Remaining Aura Added
--Selected Priorities Show Highest Duration Remaining Aura Added
--Target/Focus/ToT/ToF Will Obey/Show Icons for Arena 123 Priorities if Arena 123 Added
--Arena Priorities vs Player, Party Priorities  Added
--Interupts Penance or Channel Casts Added
--Stealth Module  Added
--Mass Invis (Hack) Added
--Add stealth check and aura filters
--[[Duel (2 icons Red Layered Hue) test
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--[[SmokeBomb (2 icons Red Layered Hue)
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--cleu SpellCastSucess Timer (treated as buff in options for categoriesEnabled)
--2 Aura check Root Beam test
--Prio Change on Same SpellId per Spec : Ret/Holy Avenging Wrath test
--Stacks Only Icon: Tiger Eye Brew Inevitable Demise

local addonName, L = ...
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitHealth = UnitHealth
local UnitName = UnitName
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetInspectSpecialization = GetInspectSpecialization
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetName = GetName
local GetNumGroupMembers = GetNumGroupMembers
local GetNumArenaOpponents = GetNumArenaOpponents
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local SetPortraitToTexture = SetPortraitToTexture
local ipairs = ipairs
local pairs = pairs
local next = next
local type = type
local select = select
local strsplit = strsplit
local strfind = string.find
local strmatch = string.match
local tblinsert = table.insert
local tblremove= table.remove
local mathfloor = math.floor
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local Ctimer = C_Timer.After
local substring = string.sub
local CLocData = C_LossOfControl.GetActiveLossOfControlData
local unpack = unpack
local SetScript = SetScript
local SetUnitDebuff = SetUnitDebuff
local SetOwner = SetOwner
local OnEvent = OnEvent
local CreateFrame = CreateFrame
local SetTexture = SetTexture
local SetNormalTexture = SetNormalTexture
local SetSwipeTexture = SetSwipeTexture
local SetCooldown = SetCooldown
local SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor, SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor = SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor,  SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor
local ClearAllPoints = ClearAllPoints
local GetParent = GetParent
local GetFrameLevel = GetFrameLevel
local GetDrawSwipe = GetDrawSwipe
local GetDrawLayer = GetDrawLayer
local GetAlpha = GetAlpha
local Hide = Hide
local Show = Show
local IsShown = IsShown
local IsVisible = IsVisible
local playerGUID
local print = print
local debug = false -- type "/lc debug on" if you want to see UnitAura info logged to the console
local LCframes = {}
local LCframeplayer2
local Masque
if Masque then
Masque = LibStub("Masque", true)
end

local InterruptAuras = { }
local SmokeBombAuras = { }
local BeamAura = { }
local DuelAura = { }
local Arenastealth = {}

local spellIds = {}
local spellIdsArena = {}
local interruptsIds = {}
local cleuPrioCastedSpells = {}

-------------------------------------------------------------------------------
-- Thanks to all the people on the Curse.com and WoWInterface forums who help keep this list up to date :)
local cleuSpells = { -- nil = Do Not Show
 {188616, 60, "PvE",  "Snares_Casted_Melee", "Earth Ele", "Earth Ele"}, --Shaman Earth Ele
 {118323, 60, "PvE",  "Snares_Casted_Melee", "Primal Earth Ele", "Primal Earth Ele"}, --Shaman Primal  Earth Ele
 {188592, 60, nil,  "Snares_Casted_Melee", "Fire Ele", "Fire Ele"}, --Shaman Earth Ele
 {118291, 60, nil,  "Snares_Casted_Melee", "Primal Fire Ele", "Primal Fire Ele"}, --Shaman Primal  Earth Ele
 {157299, 30, nil,  "Snares_Casted_Melee", "Storm Ele", "Storm Ele"}, --Shaman Primal  Earth Ele
 {248280, 10, "PvE",  nil, "Trees", "Trees"}, --Druid Trees
 {288853, 25, nil,  "Melee_Major_OffenisiveCDs", "Abomination", "Abomination"}, --Dk Raise Abomination
 {123904, 24, nil,  "Small_Offenisive_CDs", "Xuen", "Xuen"}, --WW Xuen Pet Summmon
 {34433, 15, nil,  "Small_Offenisive_CDs", "Shadowfiend", "Shadowfiend"}, --Disc Pet Summmon
 {123040, 12, nil,  "Small_Offenisive_CDs", "Mindbender", "Mindbender"}, --Disc Pet Summmon
 {321686, 40, "PvE",  "Small_Defensive_CDs", "Mirror Image", "Mirror Image"}, --Mirror Images
 {111685, 30, nil,  "Ranged_Major_OffenisiveCDs", "Infernals", "Infernals"}, --Warlock Infernals
 {8143, 10, "CC_Reduction",  "Special_High", "Tremor", "Tremor"}, --Shaman Tremor Totem
 --{spellId, duration. prio, prioArena, name, nameArena} --must have both names
}

local interrupts = {
	{29443  , 10},	-- Counterspell (Clutch of Foresight)
	{13491  , 5},		-- Pummel (Iron Knuckles Item)
	{183752 , 3},		-- Consume Magic (Demon Hunter)
	{6552   , 4},		-- Pummel (Warrior)
	{115781 , 6},		-- Optical Blast (Warlock)
	{212619 , 6},		-- Call Felhunter (Warlock)
	{132409 , 6},		-- Spell Lock (command demon) (Warlock)
	{19647  , 6},		-- Spell Lock (felhunter) (Warlock)
	{347008 , 4},		-- Axe Toss(felguard) (Warlock)
	{1766   , 5},		-- Kick (Rogue)
	{231665 , 3},		-- Avengers Shield (Paladin)
	{217824 , 4},		-- Shield of Virtue (Protec Paladin)
	{96231  , 4},		-- Rebuke (Paladin)
	{116705 , 4},		-- Spear Hand Strike (Monk)
	{2139   , 6},		-- Counterspell (Mage)
	{97547  , 5},		-- Solar Beam (Druid Balance)
	{93985  , 4},		-- Skull Bash (Druid Feral)
	{91807 ,  2},   --Shambling Rush
	{91802  , 2},		-- Shambling Rush (Death Knight)
	{47528  , 3},		-- Mind Freeze (Death Knight)
	{57994  , 3},		-- Wind Shear (Shaman)
	{147362 , 3},		-- Countershot (Hunter)
	{187707 , 3},		-- Muzzle (Hunter)
}

local spellsArenaTable = {
	----------------
	-- Hunter
	----------------
	{186265 , "Immune_Arena"}, --Aspect of the Turtle
	{3355 , "CC_Arena"}, --Freezing Trap
	{203337 , "CC_Arena"}, --Freezing Trap
	{24394 , "CC_Arena"}, --Intimidation
	{213691 , "CC_Arena"}, --Scatter Shot
	{202933 , "Silence_Arena"}, --Spider Sting
	{233022 , "Silence_Arena"}, --Spider Sting
	{191241 , "Special_High"}, --Sticky Bomb
	{199483 , "Special_High"}, --Camouflage
	{5384 , "Special_High"}, --Fiegn Death
	{19574 , "Ranged_Major_OffenisiveCDs"}, --Bestial Wrath
	{212704 , "Ranged_Major_OffenisiveCDs"}, --The Beast Within (PvP)
	{193530 , "Ranged_Major_OffenisiveCDs"}, --Aspect of the Wild
	{266779 , "Ranged_Major_OffenisiveCDs"}, --Coordinated Assault
	{186289 , "Ranged_Major_OffenisiveCDs"}, --Aspect of the Eagle
	{260402 , "Ranged_Major_OffenisiveCDs"}, --Double Tap
	{288613 , "Ranged_Major_OffenisiveCDs"}, --Trueshot
	{117526 , "Roots_90_Snares"}, --Binding Shot
	{117405 , "Roots_90_Snares"}, --Binding Shot
	{162480 , "Roots_90_Snares"}, --Steel Trap
	{190927 , "Roots_90_Snares"}, --Harpoon
	{190925 , "Roots_90_Snares"}, --Harpoon
	{212638 , "Roots_90_Snares"}, --Tracker's Net
	{53148 , "Roots_90_Snares"}, --Charge (pet)
	{248519 , "Big_Defensive_CDs"}, --Interlope
	{53480 , "Big_Defensive_CDs"}, --Roar of Sacrifice
	{202748 , "Big_Defensive_CDs"}, --Survival Tactics
	{212640 , "Big_Defensive_CDs"}, --Mending Bandage
	{281195 , "Big_Defensive_CDs"}, --Survival of the Fittest
	{264735 , "Big_Defensive_CDs"}, --Survival of the Fittest
	{202797 , "Player_Party_OffensiveCDs"}, --Viper Sting
	{203268 , "Small_Offenisive_CDs"}, --Sticky Tar (80% Attack Speed Reduction)
	{202900 , "Small_Offenisive_CDs"}, --Scorpid Sting (Critical Strike chance reduced by 50% for 8 sec)
	{54216 , "Freedoms_Speed"}, --Master's Call
	{118922 , "Freedoms_Speed"}, --Posthaste
	{186257 , "Freedoms_Speed"}, --Aspect of the Cheetah
	{5116 , "Snares_WithCDs"}, --Concussive Shot
	{135299 , "Snares_Ranged_Spamable"}, --Tar Trap
  {204205 , "Snares_Casted_Melee"}, --Wild Protector

	----------------
	-- Shaman
	----------------
	{8178 ,  "Immune_Arena"}, --Grounding Totem Effect
	{"Hex" , "CC_Arena"},
	{305485 , "CC_Arena"}, --Lightning Lasso
	{118345 , "CC_Arena"}, --Pulverize
	{77505 , "CC_Arena"}, --Earthquake
	{197214 , "CC_Arena"}, --Sundering
	{290641 , "Special_High"}, --Ancestral Gift
	{335903 , "Ranged_Major_OffenisiveCDs"}, --Doomwinds (Shadowlands Legendary)
	{114051 , "Ranged_Major_OffenisiveCDs"}, --Ascendance Enhancement
	{114050 , "Ranged_Major_OffenisiveCDs"}, --Ascendance
	{191634 , "Ranged_Major_OffenisiveCDs"}, --Stormkeeper
	{320137 , "Ranged_Major_OffenisiveCDs"}, --Stormkeeper
	{204361 , "Ranged_Major_OffenisiveCDs"}, --Bloodlust
	{204362 , "Ranged_Major_OffenisiveCDs"}, --Heroism
	{64695 , "Roots_90_Snares"}, --Earthgrab
	{285515 , "Roots_90_Snares"}, --Surge of Power
	{207498 , "Big_Defensive_CDs"}, --Ancestral Protection
	{108271 , "Big_Defensive_CDs"}, --Astral Shift
	{210918 , "Big_Defensive_CDs"}, --Ethereal Form
	{118337 , "Big_Defensive_CDs"}, --Harden Skin
	{114052 , "Big_Defensive_CDs"}, --Ascendance
	{201633 , "Big_Defensive_CDs"}, --Earthen Wall
	{325174 , "Big_Defensive_CDs"}, --Spirit Link Totem
	{201846 , "Small_Offenisive_CDs"}, --Stormbringer
	{327942 , "Small_Offenisive_CDs"}, --Windfury Totem
	{208963 , "Small_Offenisive_CDs"}, --Skyfury Totem
	{320125 , "Small_Offenisive_CDs"}, --Echoing Shock
	{79206 , "Small_Defensive_CDs"}, --Spiritwalker's Grace
	{58875 , "Freedoms_Speed"}, --Spirit Walk
	{192082 , "Freedoms_Speed"}, -- Wind Rush
	{182387 , "Snares_WithCDs"}, --Earthquake
	{51490 , "Snares_WithCDs"}, --Thunderstorm
	{204293 , "Special_Low"}, --Spirit Link
	--{260881 , "Freedoms_Speed"}, --Spirit Wolf
	--{204262 , "Freedoms_Speed"}, --Spectral Recovery
	{2645 , "Freedoms_Speed"}, --Ghost Wolf
	{196840 , "Snares_Ranged_Spamable"}, --Frost Shock

	----------------
	-- Death Knight
	----------------
	{48707 , "Immune_Arena"}, --Anti-Magic Shell
	{221562 , "CC_Arena"}, --Asphyxiate
	{108194 , "CC_Arena"}, --Asphyxiate
	{91800 , "CC_Arena"}, --Gnaw
	{210141 , "CC_Arena"}, --Zombie Explosion
	{91797 , "CC_Arena"}, --Monstrous Blow
	{287254 , "CC_Arena"}, --Dead of Winter
	{207167 , "CC_Arena"}, --Blinding Sleet
  {334693 , "CC_Arena"}, -- Absolute Zero (Shadowlands Legendary Stun)
	{204490 , "Silence_Arena"}, --Strangulate
	{77606 , "Special_High"}, --Dark Simulacrum
	{315443 , "Ranged_Major_OffenisiveCDs"}, --Abomination Limb
	{91807 , "Roots_90_Snares"}, --Shambling Rush
	{204085 , "Roots_90_Snares"}, --Deathchill
	{233395 , "Roots_90_Snares"}, --Deathchill
	{47568 , "Melee_Major_OffenisiveCDs"}, --Empower Rune Weapon
	{207256 , "Melee_Major_OffenisiveCDs"}, --Obliteration
	{51271 , "Melee_Major_OffenisiveCDs"}, --Pillar of Frost
	--{215711 , "Melee_Major_OffenisiveCDs"}, --Soul Reaper
	--{207289 , "Melee_Major_OffenisiveCDs"}, --Unholy Frenzy
	{207289 , "Melee_Major_OffenisiveCDs"}, --Unholy Assault
	{48792 , "Big_Defensive_CDs"}, --Icebound Fortitude
	{49039 , "Big_Defensive_CDs"}, --Lichborne
	{145629 , "Big_Defensive_CDs"}, --Anti-Magic Zone
	{114556 , "Big_Defensive_CDs"}, --Purgatory
	{204206, "Small_Offenisive_CDs"}, --Chill Streak
	{77616 , "Small_Offenisive_CDs"}, --Dark Simulacrum
	{288977 , "Small_Defensive_CDs"}, --Transfusion
	{48743 , "Small_Defensive_CDs"}, --Death Pact
	{48265 , "Freedoms_Speed"}, -- Death's Advance
	{212552 , "Freedoms_Speed"}, -- Wraith Walk
	{45524 , "Snares_Ranged_Spamable"}, --Chains of Ice

	----------------
	-- Druid
	----------------
	{114108 , "Drink_Purge"}, --Soul of the Forest
	{5211 , "CC_Arena"}, --Mighty Bash
	{163505 , "CC_Arena"}, --Rake
	{203123 , "CC_Arena"}, --Maim
	{202244 , "CC_Arena"}, --Overrun
	{33786 , "CC_Arena"}, --Cyclone
	{99 , "CC_Arena"}, --Incapacitating Roar
	{2637 , "CC_Arena"}, --Hibernate
	{81261 , "Silence_Arena"}, --Solar Beam
	{5215 , "Special_High"}, --Prowl
	{106951, "Ranged_Major_OffenisiveCDs"}, --Berserk (Feral)
	{102543 , "Ranged_Major_OffenisiveCDs"}, --Incarnation: King of the Jungle
	{194223, "Ranged_Major_OffenisiveCDs"}, --Celestial Alignment
	{102560 , "Ranged_Major_OffenisiveCDs"}, --Incarnation: Chosen of Elune
	{50334 , "Ranged_Major_OffenisiveCDs"}, --Berserk (Guardian)
	{102558 , "Ranged_Major_OffenisiveCDs"}, --Incarnation: Guardian of Ursoc
	{339 , "Roots_90_Snares"}, --Entangling Roots
	{170855 , "Roots_90_Snares"}, --Entangling Roots (Nature's Grasp)
	{102359 , "Roots_90_Snares"}, --Mass Entanglement
	{45334 , "Roots_90_Snares"}, --Immobilized
	{127797 , "Roots_90_Snares"}, --Ursol's Vortex
	{102793 , "Roots_90_Snares"}, --Ursol's Vortex
	{209749 , "Disarms"}, --Faerie Swarm
	{22812 , "Big_Defensive_CDs"}, --Barkskin
	{102342 , "Big_Defensive_CDs"}, --IronBark
	{247563 , "Big_Defensive_CDs"}, --Nature's Grasp
	{29166 , "Big_Defensive_CDs"}, --Innervate
	{117679 , "Big_Defensive_CDs"}, --Incarnation: Tree of Life
	--{33891 , "Big_Defensive_CDs"}, --Tree of life
	{61336 , "Big_Defensive_CDs"}, --Survival Instincts
	{202461 , "Small_Offenisive_CDs"}, --Stellar Drift
	{108292 , "Small_Offenisive_CDs"}, --Heart of the Wild (Feral)
	{108293 , "Small_Offenisive_CDs"}, --Heart of the Wild (Guardian)
  {108294 , "Small_Offenisive_CDs"}, --Heart of the Wild (Resto)
	{5217 , "Small_Offenisive_CDs"}, --Tiger's Fury
	{22842 , "Small_Defensive_CDs"}, --Frenzied Regeneration
	{192081 , "Small_Defensive_CDs"}, --Ironfur
	{200947 , "Small_Defensive_CDs"}, --Encroaching Vines
	{305497 , "Small_Defensive_CDs"}, --Thorns
	{1850 , "Freedoms_Speed"}, --Dash
	{77764 , "Freedoms_Speed"}, --Stampeding Roar
	{252216 , "Freedoms_Speed"}, --Tiger's Dash
	{201940, "Special_Low"}, --Protector of the Pack
	{768 , "Special_Low"}, --Cat Forn
	{5487 , "Special_Low"}, --Bear Form
	{783 , "Special_Low"}, --Travel Form
	{197625 , "Special_Low"}, --Moonkin Form
	{24858 , "Special_Low"}, --Moonkin Form

	----------------
	-- Mage
	----------------
	{45438 , "Immune_Arena"}, --Ice Block
	{"Polymorph" , "CC_Arena"},
	{82691 , "CC_Arena"}, --Ring of Frost
	{31661 , "CC_Arena"}, --Dragon's Breath
	{317589 , "Silence_Arena"}, --Tormenting Backlash (Venthyr Mage)
	{66 , "Special_High"}, --Invisibility
	{32612 , "Special_High"}, --Invisibility
	{110960 , "Special_High"}, --Greater Invisibility
	{198158 , "Special_High"}, --Mass Invisibility
  {190319, "Ranged_Major_OffenisiveCDs"}, --Combustion
  {12042, "Ranged_Major_OffenisiveCDs"}, --Arcane Power
  {12472, "Ranged_Major_OffenisiveCDs"}, --Icy Veins
  {198144, "Ranged_Major_OffenisiveCDs"}, --Ice Form
  {122 , "Roots_90_Snares"}, --Frost Nova
  {198121 , "Roots_90_Snares"}, --Frost Bite
  {33395 , "Roots_90_Snares"}, --Freeze
  {157997 , "Roots_90_Snares"}, --Ice Nova
  {228600 , "Roots_90_Snares"}, --Glacial Spike
  {110909  , "Big_Defensive_CDs"}, --Alter Time
  {342246 , "Big_Defensive_CDs"}, --Alter Time
  {198111 , "Big_Defensive_CDs"}, --Temporal Shield
  {113862 , "Big_Defensive_CDs"}, --Greater Invisibility
  {87023 , "Big_Defensive_CDs"}, --Cauterilze
  {108839 , "Small_Offenisive_CDs"}, --Ice Floes
  {198065 , "Small_Offenisive_CDs"}, --Prismatic Cloak
  {116014 , "Small_Offenisive_CDs"}, --Rune of Power
  {116014 , "Small_Offenisive_CDs"}, --Rune of Power
  {314793 , "Small_Offenisive_CDs"}, --Mirrors of Torment
  {108843 , "Small_Defensive_CDs"}, --Blazing Speed
  {120 , "Snares_WithCDs"}, --Cone of Cold
  {11426 , "Special_Low"}, --Ice Barrier
  {235313 , "Special_Low"}, --Blazing Barrier
  {235450 , "Special_Low"}, --Prismatic Barrier
  {414425 , "Special_Low"}, --Hypothermia
  {31589 , "Snares_Ranged_Spamable"}, --Slow


	----------------
	-- Monk
	----------------
	{119381 , "CC_Arena"}, --Leg Sweep
	{202346 , "CC_Arena"}, --Double Barrel
	{202274 , "CC_Arena"}, --Incendiary Brew
	{198909 , "CC_Arena"}, --Song of Chi-ji
	{115078 , "CC_Arena"}, --Paralysis
	{209584 , "Special_High"}, --Zen Focus Tea
  {116706 , "Roots_90_Snares"}, --Disable
  {201787 , "Roots_90_Snares"}, --Heavy-Handed Strike
  {233759 , "Disarms"}, --Grapple Weapon
  {152173 , "Melee_Major_OffenisiveCDs"}, --Serenity
  {137639 , "Melee_Major_OffenisiveCDs"}, --Storm, Earth, and Fire
  {310454 , "Melee_Major_OffenisiveCDs"}, --Weapons of Order
	{125174 , "Big_Defensive_CDs"}, --Touch of Karma
  {116849 , "Big_Defensive_CDs"}, --Life Cacoon
  {122783 , "Big_Defensive_CDs"}, --Diffuse Magic
  {243435 , "Big_Defensive_CDs"}, --Fortifying Brew
  {122278 , "Big_Defensive_CDs"}, --Damoen Harm
  {115176 , "Big_Defensive_CDs"}, --Zen Meditation
  {247483 , "Small_Offenisive_CDs"}, --Tigereye Brew
  {201447 , "Freedoms_Speed"}, --Ride the Wind
  {116841 , "Freedoms_Speed"}, --Tiger's Lust
  {248646 , "Special_Low"}, --Tigereye Brew

	----------------
	-- Palladin
	----------------
	{210294 , "Drink_Purge"}, --Divine Favor
	{642 , "Immune_Arena"}, --Divine Shield
	{228050 , "Immune_Arena"}, --Divine Shield (PvP Guardian of the Forgotten Queen)
	{204018 , "Immune_Arena"}, --Blessing of Spellwarding
	{853 , "CC_Arena"}, --Hammer of Justice
	{20066 , "CC_Arena"}, --Repentance
	{105421 , "CC_Arena"}, --Blinding Light
	{217824 , "Silence_Arena"}, --Shield of Virtue
  {199545 , "Special_High"},			-- Steed of Glory
  {317929 , "Special_High"},			-- Aura Mastery
  {31884, "Big_Defensive_CDs"}, --Avenging Wrath
  {231895, "Big_Defensive_CDs"}, --Crusade
	{1022 , "Big_Defensive_CDs"}, --Blessing of Protection
  {6940 , "Big_Defensive_CDs"}, --Blessing of Sacrifice
  {199448 , "Big_Defensive_CDs"}, --Blessing of Sacrifice
  {199450 , "Big_Defensive_CDs"}, --Ultimate  Sacrifice
  {31821 , "Big_Defensive_CDs"}, --Aura Mastery
  {498 , "Big_Defensive_CDs"}, --Divine Protection
  {216331 , "Big_Defensive_CDs"}, --Avenging Crusader
  {184662 , "Big_Defensive_CDs"}, --Shield of Vengeance
  {205191 , "Big_Defensive_CDs"}, --Eye for an Eye
  {210256 , "Big_Defensive_CDs"}, --Blessing of Sanctuary
  {86659 , "Big_Defensive_CDs"}, --Guardian of Ancient Kings
  {318501 , "Big_Defensive_CDs"}, --Ardent Defender
  {204150 , "Big_Defensive_CDs"}, --Aegis of Light
  {152262 , "Small_Offenisive_CDs"}, --Seraphim
  {105809 , "Small_Defensive_CDs"}, --Holy Avenger
  {1044 , "Freedoms_Speed"}, --Blessing of Freedom (Not Purgeable)
  {305395 , "Freedoms_Speed"}, --Blessing of Freedom
  {221886 , "Freedoms_Speed"}, --Tiger's Lust
  {183218 , "Snares_WithCDs"}, --Hand of Hinderance
  {25771 , "Special_Low"}, --Forbearance

	----------------
	-- Priest
	----------------
	{47585 , "Immune_Arena"}, --Dispersion
	{215769 , "Immune_Arena"}, --Spirit of Redemption
  {27827 , "Immune_Arena"}, --Spirit of Redemption
	{64044 , "CC_Arena"}, --Psychic Horror
	{200200 , "CC_Arena"}, --Holy Word: Chastise
	{200196 , "CC_Arena"}, --Holy Word: Chastise
	{87204 , "CC_Arena"}, --Sin and Punishment
	{9484 , "CC_Arena"}, --Shackle Undead
	{8122 , "CC_Arena"}, --Psychic Scream
	{605 , "CC_Arena"}, --Mind Control
	{205369 , "CC_Arena"}, --Mind Bomb
	{226943 , "CC_Arena"}, --Mind Bomb
	{15487 , "Silence_Arena"}, --Silence_Arena
	{289655 , "Special_High"}, --Holy Word: Concentration
  {33206 , "Big_Defensive_CDs"}, --Pain Suprresion
  {81782 , "Big_Defensive_CDs"}, --Power Word: Barrier
  {213602 , "Big_Defensive_CDs"}, --Greater Fade
  {47788 , "Big_Defensive_CDs"}, --Guardian Spirit
  {232707 , "Big_Defensive_CDs"}, --Ray of Hope
  {10060, "Big_Defensive_CDs"}, --Power Infusion
	{199845, "Player_Party_OffensiveCDs"}, --Psyflay (PvP Talent 50% MS)
  {322442 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322464 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322463 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322462 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322461 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322460 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322459 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322458 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {322457 , "Player_Party_OffensiveCDs"}, --Thoughtstolen
  {323673 , "Player_Party_OffensiveCDs"}, --Mindgames
  {197871 , "Small_Offenisive_CDs"}, --Dark Archangel
  {197874 , "Small_Offenisive_CDs"}, --Dark Archangel
  {194249 , "Small_Offenisive_CDs"}, --Voidform
  {247776 , "Small_Offenisive_CDs"}, --Mind Trauma
  {47536 , "Small_Defensive_CDs"}, --Rapture
  {197862 , "Small_Defensive_CDs"}, --Archangel
  {200183 , "Small_Defensive_CDs"}, --Apotheosis
  {213610 , "Small_Defensive_CDs"}, --Holy Ward
  {64901 , "Small_Defensive_CDs"}, --Symbol of Hope
  {15286 , "Small_Defensive_CDs"}, --Vampiric Embrace
  {19236 , "Small_Defensive_CDs"}, --Desperate Prayer
  {204263 , "Snares_WithCDs"}, --Shining FOrce
  {193065, "Special_Low"}, --Masochism
  {265258 , "Special_Low"}, --Twist of Fate
  {123254 , "Special_Low"}, --Twist of Fate
  {327710, "Special_Low"}, -- Benevolent Faerie (Night Fae Priest)
  {65081 , "Snares_Casted_Melee"}, --Body and Soul
  {121557, "Snares_Casted_Melee"}, --Angelic Feather
	----------------
	-- Rogue
	----------------
	{45182 , "Immune_Arena"}, --Cheating Death
	{1833 , "CC_Arena"}, --Cheap Shot
	{408 , "CC_Arena"}, --Kidney Shot
	{199804 , "CC_Arena"}, --Between the Eyes
	{2094 , "CC_Arena"}, --Blind
	{6770 , "CC_Arena"}, --Sap
	{1776 , "CC_Arena"}, --Gouge
	{1330 , "Silence_Arena"}, --Garrote - Silence_Arena
	{212183 , "Special_High"}, --Smoke Bomb
	{207736 , "Special_High"}, --Shadowy Duel
	{11327 , "Special_High"}, --Vanish
	{115191 , "Special_High"}, --Stealth
	{1784 , "Special_High"}, --Stealth
  {198222 , "Roots_90_Snares"}, --System Shock
  {207777 , "Disarms"}, --Dismantle
  {197091 , "Disarms"}, --Neurotoxin
  {212150 , "Disarms"}, --Cheap Tricks
  {13750 , "Melee_Major_OffenisiveCDs"}, --Adrenaline Rush
  {198529 , "Melee_Major_OffenisiveCDs"}, --Plunder Armor
  {121471 , "Melee_Major_OffenisiveCDs"}, --Shadow Blades
  {185422 , "Melee_Major_OffenisiveCDs"}, --Shadow Dance
  {79140, "Player_Party_OffensiveCDs"}, --Vendetta
  {31224 , "Big_Defensive_CDs"}, --Cloak of Shadows
  {5277, "Big_Defensive_CDs"}, --Evasion
  {199027, "Big_Defensive_CDs"}, --Veil of Midnight
  {51690 , "Small_Offenisive_CDs"}, --Killing Spree
  {57934 , "Small_Offenisive_CDs"}, --Tricks of the Trade (PvP)
  {193359 , "Small_Offenisive_CDs"}, --True Bearing
  {13877 , "Small_Offenisive_CDs"}, --Blade Flurry
  {115192 , "Small_Offenisive_CDs"}, --Subterfuge
  {212283 , "Small_Offenisive_CDs"}, --Symbols of Death
  {185311, "Small_Defensive_CDs"}, --Crimson Vial
  {1966, "Small_Defensive_CDs"}, --Fient
  {197003 , "Freedoms_Speed"}, --Maneuverability
  {2983 , "Freedoms_Speed"}, --Sprint
  {36554 , "Freedoms_Speed"}, --Shadowstep
  {269513 , "Freedoms_Speed"}, --Death from Above
  {115196 , "Snares_WithCDs"}, -- Shiv
  {185763 , "Snares_Ranged_Spamable"}, --Pistol Shot
  {3409 , "Snares_Ranged_Spamable"}, --Crippling Poison

	----------------
	-- Warlock
	----------------
	{30283 , "CC_Arena"}, --Shadowfury
	{22703 , "CC_Arena"}, --Infernal Awakening
	{89766 , "CC_Arena"}, --Axe Toss
	--{347008 , "CC_Arena"}, --Axe Toss
	{213688 , "CC_Arena"}, --Fel Cleave
	{118699 , "CC_Arena"}, --Fear
  {5484 , "CC_Arena"}, --Howl of Terror
	{6789 , "CC_Arena"}, --Mortal Coil
	{6358 , "CC_Arena"}, --Seduction
	{261589 , "CC_Arena"}, --Seduction
	{115268 , "CC_Arena"}, --Mesmerize
	{710 , "CC_Arena"}, --Bansih
	{196364 , "Silence_Arena"}, --Unstable Affliction
  {221705 , "Special_High"}, --Casting Circle
  {104773, "Special_High"}, --Unending Resolve
  {307871, "Roots_90_Snares"}, --Spear of Bastion
  {113860, "Ranged_Major_OffenisiveCDs"}, --Dark Soul: Instability
  {113858, "Ranged_Major_OffenisiveCDs"}, --Dark Soul: Misery
  {212295 , "Big_Defensive_CDs"}, --Nether Ward
  {200587, "Player_Party_OffensiveCDs"}, --Fel Fissure (PvP Talent 50% MS)
  {344566 , "Small_Offenisive_CDs"}, --Rapid Contagion
  {1714 , "Small_Offenisive_CDs"}, --Curse of Tongues
  {199954 , "Small_Offenisive_CDs"}, --Curse of Fragility
  {80240 , "Small_Offenisive_CDs"}, --Havoc
  {108416 , "Small_Defensive_CDs"}, --Dark Pact
  {702 , "Special_Low"}, --Curse of Weakness
  {196099, "Snares_Casted_Melee"}, --Grimoire of Sacrifice
  {285933, "Snares_Casted_Melee"}, --Demon Armor
  {334320, "Snares_Casted_Melee"}, --Inevitable Demise


	----------------
	-- Warrior
	----------------
	{46924  , "Immune_Arena"}, -- Bladestorm (not immune to dmg}, only to LoC)
	{227847 , "Immune_Arena"}, -- Bladestorm (not immune to dmg}, only to LoC)
  {147833 , "Immune_Arena"}, -- Intervene
  {330279 , "Immune_Arena"}, -- Overwatch
  {335255 , "Immune_Arena"}, -- Mass Spell Reflection Legendary
	{132169 , "CC_Arena"}, --Storm Bolt
	{199085 , "CC_Arena"}, --Warpath
	{132168 , "CC_Arena"}, --Shockwave
	{5246 , "CC_Arena"}, --Intimidating Shout
  {236273 , "Special_High"}, -- Duel
  {23920 , "Special_High"}, -- Spell Reflection
  {105771 , "Roots_90_Snares"}, --Charge
  {199042 , "Roots_90_Snares"}, --Thunderstruck
  {236236 , "Disarms"}, --Disarm
  {236077 , "Disarms"}, --Disarm
  {107574 , "Melee_Major_OffenisiveCDs"}, -- Avatar
  {1719 , "Melee_Major_OffenisiveCDs"}, -- Recklessness
  {18499 , "Big_Defensive_CDs"}, -- Berserker Rage
  {118038 , "Big_Defensive_CDs"}, -- Die by the Sword
  {184364 , "Big_Defensive_CDs"}, -- Enraged Regeneration
  {236321 , "Big_Defensive_CDs"}, -- War Banner
  {12975 , "Big_Defensive_CDs"}, -- Last Stand
  {871 , "Big_Defensive_CDs"}, -- Shield Wall
  {213871 , "Big_Defensive_CDs"}, -- Bodyguard
  {198819, "Player_Party_OffensiveCDs"}, -- Mortal Strike
  {227744 , "Small_Offenisive_CDs"}, -- Ravager
  {260708 , "Small_Offenisive_CDs"}, -- Sweeping Strikes
  {132404 , "Small_Defensive_CDs"}, -- Shield Block
  {97463 , "Small_Defensive_CDs"}, -- Rallying Cry
  {12323 , "Snares_WithCDs"}, -- Piercing Howl
  {197690 , "Special_Low"}, -- Defensive Stance
  {199261, "Special_Low"}, -- Death Wish

	----------------
	-- Demon Hunter
	----------------
	{211881 , "CC_Arena"}, --Fel Eruption
	{179057 , "CC_Arena"}, --Choas Nova
	{205630 , "CC_Arena"}, --Illidan's Grasp
	{208618 , "CC_Arena"}, --Illidan's Grasp
	{221527 , "CC_Arena"}, --Imprison
	{217832 , "CC_Arena"}, --Imprison
	{207685 , "CC_Arena"}, --Sigil of Misery
	{213491 , "CC_Arena"}, --Demonic Trample
	{47476 , "Silence_Arena"}, --Sigil of Silence_Arena
  {188501, "Special_High"}, -- Spectral Sight
  {206649 , "Special_High"}, -- Eye of Leotheras
  {323996 , "Roots_90_Snares"}, --The Hunt NightFae Root
  {162264 , "Melee_Major_OffenisiveCDs"}, -- Metamorphosis
  {187827 , "Melee_Major_OffenisiveCDs"}, -- Metamorphosis
  {212800, "Big_Defensive_CDs"}, -- Blur
  {196555 , "Big_Defensive_CDs"}, -- Netherwalk
  {209426 , "Big_Defensive_CDs"}, -- Darkness
  {206804 , "Big_Defensive_CDs"}, -- Rain From Above
  {323802 , "Small_Offenisive_CDs"}, -- The Hunt
  {203819, "Small_Defensive_CDs"}, -- Demon Spikes
  {208796, "Small_Defensive_CDs"}, -- Jagged Spikes
  {205629, "Freedoms_Speed"}, -- Demonic Trample
  {213405 , "Snares_Ranged_Spamable"}, --Master of the Glaive

	----------------
	-- Misc.
	----------------

	{"Drink" , "Drink_Purge"},
	{"Refreshment" , "Drink_Purge"},
  {320224 , "Immune_Arena"}, --Podtender (NightFae Soulbind Tree)
  {323524 , "Immune_Arena"}, --Ultimate Form (Necro Soulbind Tree)
  {331866 , "CC_Arena"}, --Door of Shadows Fear
  {332423 , "CC_Arena"}, -- Sparkling Driftglobe Core 35% Stun (Kyrian)
	{107079 , "CC_Arena"}, --Quaking Palm
	{20549 , "CC_Arena"}, --War Stomp
	{255654 , "CC_Arena"}, --Bull Rush
	{287712 , "CC_Arena"}, --Haymaker
  {58984, "Special_High"}, -- Shadowmeld
  {320267, "Roots_90_Snares"},		-- Soothing Voice (Nightfae)
  {291944 , "Big_Defensive_CDs"}, -- Regeneratin'
  {59543, "Small_Defensive_CDs"}, -- Gift of the Naaru
  {277187, "Small_Defensive_CDs"}, -- Gladiator's Emblem
  {"Gladiator's Emblem", "Small_Defensive_CDs"}, -- Gladiator's Emblem
  {286342, "Small_Defensive_CDs"}, -- Gladiator's Safegaurd
  {332505, "Small_Defensive_CDs"}, -- Soulsteel Clamps
  {332506, "Small_Defensive_CDs"}, -- Soulsteel Clamps
  {68992, "Freedoms_Speed"}, -- Darkflight
  {310143, "Freedoms_Speed"}, -- Soulshape
  {324867, "Snares_Casted_Melee"}, --Flesh Craft

	}

local spellsTable = {

{"PVP", --TAB

  {3355   , "CC"},				-- Freezing Trap
  {203337 , "CC"},				-- Freezing Trap (Diamond Ice - pvp honor talent)
  {24394  , "CC"},				-- Intimidation
  {213691 , "CC"},				-- Scatter Shot (pvp honor talent)

  {"Hex"  , "CC"},				-- Hex
  {51514  , "CC"},				-- Hex
  {210873 , "CC"},				-- Hex (compy)
  {211010 , "CC"},				-- Hex (snake)
  {211015 , "CC"},				-- Hex (cockroach)
  {211004 , "CC"},				-- Hex (spider)
  {196942 , "CC"},				-- Hex (Voodoo Totem)
  {269352 , "CC"},				-- Hex (skeletal hatchling)
  {277778 , "CC"},				-- Hex (zandalari Tendonripper)
  {277784 , "CC"},				-- Hex (wicker mongrel)
  {77505  , "CC"},				-- Earthquake
  {118905 , "CC"},				-- Static Charge (Capacitor Totem)
  {305485 , "CC"},				-- Lightning Lasso
  {197214 , "CC"},				-- Sundering
  {118345 , "CC"},				-- Pulverize (Shaman Primal Earth Elemental)

  {108194 , "CC"},				-- Asphyxiate
  {221562 , "CC"},				-- Asphyxiate
  {207167 , "CC"},				-- Blinding Sleet
  {287254 , "CC"},				-- Dead of Winter (pvp talent)
  {210141 , "CC"},				-- Zombie Explosion (Reanimation PvP Talent)
  {91800  , "CC"},				-- Gnaw
  {91797  , "CC"},				-- Monstrous Blow (Dark Transformation)
  {334693 , "CC"},        -- Absolute Zero (Shadowlands Legendary Stun)

  {33786  , "CC"},				-- Cyclone
  {5211   , "CC"},				-- Mighty Bash
  {163505 , "CC"},				-- Rake
  {203123 , "CC"},				-- Maim
  {202244 , "CC"},				-- Overrun (pvp honor talent)
  {99     , "CC"},			-- Incapacitating Roar
  {2637   , "CC"},				-- Hibernate

  {"Polymorph"   , "CC"},	-- Polymorph
  {118    , "CC"},				-- Polymorph
  {61305  , "CC"},				-- Polymorph: Black Cat
  {28272  , "CC"},				-- Polymorph: Pig
  {61721  , "CC"},				-- Polymorph: Rabbit
  {61780  , "CC"},				-- Polymorph: Turkey
  {28271  , "CC"},				-- Polymorph: Turtle
  {161353 , "CC"},				-- Polymorph: Polar bear cub
  {126819 , "CC"},				-- Polymorph: Porcupine
  {161354 , "CC"},				-- Polymorph: Monkey
  {61025  , "CC"},				-- Polymorph: Serpent
  {161355 , "CC"},				-- Polymorph: Penguin
  {277787 , "CC"},				-- Polymorph: Direhorn
  {277792 , "CC"},				-- Polymorph: Bumblebee
  {161372 , "CC"},				-- Polymorph: Peacock
  {82691  , "CC"},				-- Ring of Frost
  {140376 , "CC"},				-- Ring of Frost
  {31661  , "CC"},				-- Dragon's Breath

  {119381 , "CC"},				-- Leg Sweep
  {115078 , "CC"},				-- Paralysis
	{198909 , "CC"},				-- Song of Chi-Ji
  {202274 , "CC"},				-- Incendiary Brew (honor talent)
	{202346 , "CC"},				-- Double Barrel (honor talent)

  {853    , "CC"},				-- Hammer of Justice
  {105421 , "CC"},				-- Blinding Light
  {20066  , "CC"},				-- Repentance

  {605    , "CC"},				-- Dominate Mind
	{8122   , "CC"},				-- Psychic Scream
	{9484   , "CC"},				-- Shackle Undead
	{64044  , "CC"},				-- Psychic Horror
	{87204  , "CC"},				-- Sin and Punishment
  {226943 , "CC"},				-- Mind Bomb
  {205369 , "CC"},				-- Mind Bomb
  {200196 , "CC"},				-- Holy Word: Chastise
  {200200 , "CC"},				-- Holy Word: Chastise (talent)

  {2094   , "CC"},				-- Blind
  {1833   , "CC"},				-- Cheap Shot
  {1776   , "CC"},				-- Gouge
  {408    , "CC"},				-- Kidney Shot
  {6770   , "CC"},				-- Sap
  {199804 , "CC"},				-- Between the eyes

	{118699 , "CC"},				-- Fear
  {5484   , "CC"},		    -- Howl of Terror
	{6789   , "CC"},				-- Mortal Coil
	{30283  , "CC"},				-- Shadowfury
  {710    , "CC"},				-- Banish
	{22703  , "CC"},				-- Infernal Awakening
  {213688 , "CC"},		  	-- Fel Cleave (Fel Lord - PvP Talent)
  {89766  , "CC"},		  	-- Axe Toss (Felguard/Wrathguard)
  --{347008  , "CC"},		  	-- Axe Toss (Felguard/Wrathguard)
  {115268 , "CC"},			  -- Mesmerize (Shivarra)
  {6358   , "CC"},		  	-- Seduction (Succubus)
  {261589  , "CC"},			  -- Seduction (Succubus)
  {171017 , "CC"},			  -- Meteor Strike (infernal)
  {171018 , "CC"},			  -- Meteor Strike (abisal)

	{5246   , "CC"},				-- Intimidating Shout (aoe)
	{132169 , "CC"},				-- Storm Bolt
	{132168 , "CC"},				-- Shockwave
  {199085 , "CC"},				-- Warpath

  {179057 , "CC"},				-- Chaos Nova
	{211881 , "CC"},				-- Fel Eruption
  {217832 , "CC"},				-- Imprison
  {221527 , "CC"},				-- Imprison (pvp talent)
	{200166 , "CC"},				-- Metamorfosis stun
	{207685 , "CC"},				-- Sigil of Misery
  {205630 , "CC"},				-- Illidan's Grasp
  {208618 , "CC"},				-- Illidan's Grasp (throw stun)
	{213491 , "CC"},				-- Demonic Trample Stun

  {331866 , "CC"},        -- Door of Shadows Fear (Venthyr)
  {332423 , "CC"},        -- Sparkling Driftglobe Core 35% Stun (Kyrian)
  {20549  , "CC"},				-- War Stomp (tauren racial)
  {107079 , "CC"},				-- Quaking Palm (pandaren racial)
  {255723 , "CC"},				-- Bull Rush (highmountain tauren racial)
  {287712 , "CC"},				-- Haymaker (kul tiran racial)

  {202914 , "Silence"},			-- Spider Sting (pvp honor talent) --no silence}, this its the previous effect
  {202933 , "Silence"},			-- Spider Sting	(pvp honor talent) --this its the silence effect
	{47476  , "Silence"},			-- Strangulate
	{317589 , "Silence"},			-- Tormenting Backlash (Venthyr Mage)
	{81261  , "Silence"},			-- Solar Beam
	{217824 , "Silence"},			-- Shield of Virtue (pvp honor talent)
	{15487  , "Silence"},			-- Silence
  {1330   , "Silence"},			-- Garrote - Silence
  {196364 , "Silence"},			-- Unstable Affliction
	{204490 , "Silence"},			-- Sigil of Silence

  {212638 , "RootPhyiscal_Special"},				-- Tracker's Net (pvp honor talent) -- Also -80% hit chance melee & range physical (CC and Root category)
  {307871 , "RootPhyiscal_Special"},				-- Spear of Bastion

	{117526 , "Root"},				-- Binding Shot
  {190927 , "Root"},				-- Harpoon
  {190925 , "Root"},				-- Harpoon
	{162480 , "Root"},				-- Steel Trap
  {53148  , "Root"},				-- Charge (tenacity ability)
  {64695  , "Root"},				-- Earthgrab (Earthgrab Totem)
  {285515 , "Root"},	      -- Surge of Power
  {233395 , "Root"},				-- Deathchill (pvp talent)
  {204085 , "Root"},				-- Deathchill (pvp talent)
  {91807  , "Root"},				-- Shambling Rush (Dark Transformation)
  {339    , "Root"},				-- Entangling Roots
  {170855 , "Root"},				-- Entangling Roots (Nature's Grasp)
  {45334  , "Root"},				-- Immobilized (Wild Charge - Bear)
  {102359 , "Root"},				-- Mass Entanglement
  {122    , "Root"},				-- Frost Nova
  {198121 , "Root"},				-- Frostbite (pvp talent)
  {157997 , "Root"},				-- Ice Nova
  {228600 , "Root"},				-- Glacial Spike
  {33395  , "Root"},				-- Freeze
	{116706 , "Root"},				-- Disable
	{105771 , "Root"},				-- Charge (root)
	{199042 , "Root"},				-- Thunderstruck
  {323996 , "Root"},				-- The Hunt

  {642    , "ImmunePlayer"},			-- Divine Shield
	{47585  , "ImmunePlayer"},			-- Dispersion
  {27827  , "ImmunePlayer"},			-- Spirit of Redemption
  {290114 , "ImmunePlayer"},			-- Spirit of Redemption	(pvp honor talent)
  {215769 , "ImmunePlayer"},			-- Spirit of Redemption	(pvp honor talent)
  {213602 , "ImmunePlayer"},			-- Greater Fade (pvp honor talent - protects vs spells. melee}, ranged attacks + 50% speed)
  {320224 , "ImmunePlayer"},			--Podtender (NightFae: Dreamweaver Tree)

	{202797 , "Disarm_Warning"},   -- Viper Sting Healing Reduction
	{77606  , "Disarm_Warning"},   -- Dark Simulacrum
  {314793 , "Disarm_Warning"},   -- Mirrors of Torment
  {322442 , "Disarm_Warning"}, --Thoughtstolen
  {322464 , "Disarm_Warning"}, --Thoughtstolen
  {322463 , "Disarm_Warning"}, --Thoughtstolen
  {322462 , "Disarm_Warning"}, --Thoughtstolen
  {322461 , "Disarm_Warning"}, --Thoughtstolen
  {322460 , "Disarm_Warning"}, --Thoughtstolen
  {322459 , "Disarm_Warning"}, --Thoughtstolen
  {322458 , "Disarm_Warning"}, --Thoughtstolen
  {322457 , "Disarm_Warning"}, --Thoughtstolen
	{197091 , "Disarm_Warning"},   -- Neurotoxin
	{206649 , "Disarm_Warning"},	 -- Eye of Leotheras (no silence}, 4% dmg and duration reset for spell casted)

  {117405 , "CC_Warning"},      -- Binding Shot
  {191241 , "CC_Warning"},      -- Sticky Bomb
  {182387 , "CC_Warning"},      -- Earthquake

  {199483 , "Stealth"},     -- Camo
  {5384   , "Stealth"},     -- Fiegn Death
  {5215   , "Stealth"},     -- Prowl
  {66     , "Stealth"},     -- Invis
  {32612  , "Stealth"},     -- Invis
  {110960 , "Stealth"},     -- Greater Invis
  {198158 , "Stealth"},     -- Mass Invis
  {1784   , "Stealth"},     -- Stealth
  {115191 , "Stealth"},     -- Stealth
  {11327  , "Stealth"},     -- Vanish
  {207736 , "Stealth"},	    -- Shadowy Duel
  {114018 , "Stealth"},	    -- Shroud of Concealment
  {58984  , "Stealth"},     -- Meld

  {228050 , "Immune"},			-- Divine Shield (Guardian of the Forgotten Queen)
  {1022   , "Immune"},	    -- Hand of Protection
  {204018 , "Immune"},	   	-- Blessing of Spellwarding
  {199448 , "Immune"},			-- Blessing of Sacrifice (Ultimate Sacrifice pvp talent) (not immune}, 100% damage transfered to paladin)

--  "ImmuneSpell",
--	"ImmunePhysical",

  {289655 , "AuraMastery_Cast_Auras"},			-- Holy Word: Concentration
  {317929 , "AuraMastery_Cast_Auras"},			-- Aura Mastery

	{127797 , "ROP_Vortex"},				-- Ursol's Vortex
	{102793 , "ROP_Vortex"},				-- Ursol's Vortex

	{209749 , "Disarm"},			-- Faerie Swarm (pvp honor talent)
	{233759 , "Disarm"},			-- Grapple Weapon
	{207777 , "Disarm"},			-- Dismantle
	--{197091 , "Disarm"},			-- Neurotoxin
  {236236 , "Disarm"},			-- Disarm (pvp honor talent - protection)
  {236077 , "Disarm"},			-- Disarm (pvp honor talent)S

  {320035 , "Haste_Reduction"},			-- Mirrors of Torment
  {247777 , "Haste_Reduction"},			-- Mind Trauma
  {199890 , "Haste_Reduction"},			-- Curse of Tongues


	{236273 , "Dmg_Hit_Reduction"},		-- Duel
  {199892 , "Dmg_Hit_Reduction"},   -- Curse of Weakness
  {200947 , "Dmg_Hit_Reduction"},   -- Encraching Vines
  {202900 , "Dmg_Hit_Reduction"},   -- Scorpid Sting
  {203268 , "Dmg_Hit_Reduction"},   -- Sticky Tar
	{212150 , "Dmg_Hit_Reduction"},		-- Cheap Tricks (pvp honor talent) (-75%  melee & range physical hit chance)

  --Interrupt

  {204361 , "AOE_DMG_Modifiers"},				-- Bloodlust (Shamanism pvp talent)
  {204362 , "AOE_DMG_Modifiers"},				-- Heroism (Shamanism pvp talent
  {208963 , "AOE_DMG_Modifiers"},				-- Skyfury Totem (Shamanism pvp talent
  {197871 , "AOE_DMG_Modifiers"},				-- Dark Archangel
  {197874 , "AOE_DMG_Modifiers"},				-- Dark Archangel
  {57934  , "AOE_DMG_Modifiers"},				-- Tricks of the Trade

  {212183 , "Friendly_Smoke_Bomb"},			-- Smoke Bomb

	{8178   , "AOE_Spell_Refections"},		-- Grounding Totem Effect (Grounding Totem)
  {213915 , "AOE_Spell_Refections"},		-- Mass Spell Reflection

  --{260881 , "Speed_Freedoms"}, --Spirit Wolf
  --{204262 , "Speed_Freedoms"}, --Spectral Recovery
  --{2645 , "Speed_Freedoms"}, --Ghost Wolf
  {212552 , "Speed_Freedoms"},		-- Wraith Walk
  {48265  , "Speed_Freedoms"},		-- Death's Advance
  {108843 , "Speed_Freedoms"},		-- Blazing Speed
  {269513 , "Speed_Freedoms"},		-- Death from Above
  {197003 , "Speed_Freedoms"},		-- Maneuverability
  {205629 , "Speed_Freedoms"},		-- Demonic Trample
  {310143 , "Speed_Freedoms"},    -- Soulshape

  {54216 , "Freedoms"},		-- Master's Call
  {118922 , "Freedoms"},		-- Posthaste
  {186257 , "Freedoms"},		-- Aspect of the Cheetah
  {192082 , "Freedoms"},		-- Wind Rush
  {58875 , "Freedoms"},		-- Spirit Walk
  {77764 , "Freedoms"},		-- Stampeding Roar
  {1850 , "Freedoms"},		-- Dash
  {252216 , "Freedoms"},		-- Tiger Dash
  {201447 , "Freedoms"},		-- Ride the Wind
  {116841 , "Freedoms"},		-- Tiger's Lust
  {1044 , "Freedoms"},		-- Blessing of Freedom
  {305395 , "Freedoms"}, --Blessing of Freedom (Not Purgeable)
  {221886 , "Freedoms"},		-- Divine Steed
  {36554 , "Freedoms"},		-- Shadowstep
  {2983 , "Freedoms"},		-- Sprint
  {68992 , "Freedoms"},		-- Darkflight

  {6940 , "Friendly_Defensives"},		-- Blessing of Sacrifice
  {147833 , "Friendly_Defensives"},		-- Intervene
  {330279 , "Friendly_Defensives"},		-- Overwatch
  {213871 , "Friendly_Defensives"},		-- Bodyguard

  {26166, "Mana_Regen"},		-- Innervate
  {64901, "Mana_Regen"},		-- Symbol of Hope

  --{213644, "CC_Reduction"},		-- Nimble Brew
  {210256, "CC_Reduction"},		-- Blessing of Sanctuary
  {213610, "CC_Reduction"},		-- Holy Ward
  {236321, "CC_Reduction"},		-- War Banner

  {200183, "Personal_Offensives"},		-- Apotheosis
  {319952, "Personal_Offensives"},		-- Surrender to Madness
  {117679, "Personal_Offensives"},		-- Incarnation

  {22842, "Peronsal_Defensives"},		-- Frenzied Regeneration
  {22812, "Peronsal_Defensives"},		-- Barkskin

  {108839, "Movable_Cast_Auras"},		-- Ice Floes
  {10060, "Movable_Cast_Auras"},		-- Power Infusion
  {331937, "Movable_Cast_Auras"},		-- Euphoria
  {332506, "Movable_Cast_Auras"},		-- Soulsteel Clamps
  {332505, "Movable_Cast_Auras"},		-- Soulsteel Clamps
  {315443, "Movable_Cast_Auras"},		-- Abomination Limb

  --"Other", --
	--"PvE", --PVE only

  {201787, "SnareSpecial"},		-- Heavy-Handed Strikes
  {199845, "SnareSpecial"},		-- Psyflay (pvp honor talent)
  {198222, "SnareSpecial"},		-- System Shock (pvp honor talent) (90% slow)
  {200587, "SnareSpecial"},		-- Fel Fissure
  {308498, "SnareSpecial"},   -- Resonating Arrow (Hunter Kyrain Special)
  {320267, "SnareSpecial"},		-- Soothing Voice
  {204206, "SnareSpecial"},		-- Chilled (Chill Streak)

  {45524,  "SnarePhysical70"},		-- Chains of Ice
  {273977, "SnarePhysical70"},		-- Grip of the Dead
  {157981, "SnarePhysical70"},		-- Blast Wave
  {248744, "SnarePhysical70"},		-- Shiv
  {115196, "SnarePhysical70"},		-- Crippling Posion
  {12323 , "SnarePhysical70"},		-- Piercing Howl
  {198813, "SnarePhysical70"},		-- Vengeful Retreat
  {247121, "SnarePhysical70"},		-- Metamorphosis

  {212792, "SnareMagic70"},		-- Cone of Cold
  {228354, "SnareMagic70"},		-- Flurry
  {321329, "SnareMagic70"},		-- Ring of Frost
  {123586, "SnareMagic70"},		-- Flying Serpent Kick
  {183218, "SnareMagic70"},		-- Hand of Hindrance
  {204263, "SnareMagic70"},		-- Shining Force
  {204843, "SnareMagic70"},		-- Sigil of Chains

  {195645, "SnarePhysical50"},		-- Wing Clip
  {135299, "SnarePhysical50"},		-- Tar Trap
  {5116, "SnarePhysical50"},		-- Concussive Shot
  {186387, "SnarePhysical50"},		-- Bursting Shot
  {51490, "SnarePhysical50"},		-- Thunderstorm
  {288548, "SnarePhysical50"},		-- Frostbolt
  {50259, "SnarePhysical50"},		-- Dazed
  {232559, "SnarePhysical50"},		-- Thorns
  {12486, "SnarePhysical50"},		-- Blizzard
  {205021, "SnarePhysical50"},		-- Ray of Frost
  {236299, "SnarePhysical50"},		-- Chrono Shift
  {317792, "SnarePhysical50"},		-- Frostbolt
  {116095, "SnarePhysical50"},		-- Disable
  {196733, "SnarePhysical50"},		-- Special Delivery
  {204242, "SnarePhysical50"},		-- Consecration
  {255937, "SnarePhysical50"},		-- Wake of Ashes
  {15407, "SnarePhysical50"},		-- Mind Flay
  {193473, "SnarePhysical50"},		-- Mind Flay
  {185763, "SnarePhysical50"},		-- Pistol Shot
  {1715, "SnarePhysical50"},		-- Hamstring
  {213405, "SnarePhysical50"},		-- Master of the Glaive

  {3409, "SnarePosion50"},		-- Crippling Poison
  {334275, "SnarePosion50"},		-- Curse of Exhaustion

  {147732, "SnareMagic50"},		-- Frostbrand
  {3600, "SnareMagic50"},		-- Earthbind
  {116947, "SnareMagic50"},		-- Earthbind
  {196840, "SnareMagic50"},		-- Frostshock
  {279303, "SnareMagic50"},		-- Frostwyrm's Fury
  {61391, "SnareMagic50"},		-- Typhoon
  {"Frostbolt", "SnareMagic50"},		-- Frostbolt
  {205708, "SnareMagic50"},		-- Chilled
  {31589, "SnareMagic50"},		-- Slow
  {336887, "SnareMagic50"},		-- Lingering Numbness
  {337956, "SnareMagic50"},		-- Mental Recovery
  {6360, "SnareMagic50"},		-- Whiplash
  {337113, "SnareMagic50"},		-- Sacrolash's Dark Strike
  {260369, "SnareMagic50"},		-- Arcane Pulse

  {162546, "SnarePhysical30"},		-- Frozen Ammo
  {197385, "SnarePhysical30"},		-- Fury of Air
  {211793, "SnarePhysical30"},		-- Remorseless Winter
  {206930, "SnarePhysical30"},		-- Heart Strike
  {2120, "SnarePhysical30"},		-- Flamestrike
  {289308, "SnarePhysical30"},		-- Frozen Orb
  {121253, "SnarePhysical30"},		-- Keg Smash
  {6343, "SnarePhysical30"},		-- Thunder Clap
  {210003, "SnarePhysical30"},		-- Razor Spikes

	{58180, "SnareMagic30"}, -- Infected Wounds
	{206760, "SnareMagic30"}, -- Shadow Grasp

	----------------
	-- Demonhunter
	----------------

	{196555 , "Other"},			  -- Netherwalk
	{188499 , "Other"},	      -- Blade Dance (dodge chance increased by 100%)
	{198589 , "Other"},				-- Blur
	{209426 , "Other"},				-- Darkness

	----------------
	-- Death Knight
	----------------

	{115018 , "Other"},				-- Desecrated Ground (Immune to CC)
	{48707  , "Other"},	     	-- Anti-Magic Shell
	{51271  , "Other"},				-- Pillar of Frost
	{48792  , "Other"},				-- Icebound Fortitude
	{287081 , "Other"},				-- Lichborne
	{81256  , "Other"},				-- Dancing Rune Weapon
	{194679 , "Other"},				-- Rune Tap
	{152279 , "Other"},				-- Breath of Sindragosa
	{207289 , "Other"},				-- Unholy Frenzy
	{145629 , "Other"},		    -- Anti-Magic Zone (not immune}, 60% damage reduction)

	----------------
	-- Druid
	----------------

	{61336  , "Other"},			  -- Survival Instincts (not immune}, damage taken reduced by 50%)
	{305497 , "Other"},				-- Thorns (pvp honor talent)
	{102543 , "Other"},				-- Incarnation: King of the Jungle
	{106951 , "Other"},				-- Berserk
	{102558 , "Other"},				-- Incarnation: Guardian of Ursoc
	{102560 , "Other"},				-- Incarnation: Chosen of Elune
	{236696 , "Other"},				-- Thorns
	{29166  , "Other"},				-- Innervate
	{102342 , "Other"},				-- Ironbark

	----------------
	-- Hunter
	----------------

	{186265 , "Other"},			  -- Deterrence (aspect of the turtle)
	{19574  , "Other"},		    -- Bestial Wrath (only if The Beast Within (212704) it's active) (immune to some CC's)
	{266779 , "Other"},				-- Coordinated Assault
	{193530 , "Other"},				-- Aspect of the Wild
	{186289 , "Other"},				-- Aspect of the Eagle
	{288613 , "Other"},				-- Trueshot
	{202748 , "Other"},			  -- Survival Tactics (pvp honor talent) (not immune}, 99% damage reduction)
	{248519 , "Other"},	    	-- Interlope (pvp honor talent)

	  ----------------
	  -- Hunter Pets
	  ----------------

	  {26064  , "Other"},			-- Shell Shield (damage taken reduced 50%) (Turtle)
	  {90339  , "Other"},			-- Harden Carapace (damage taken reduced 50%) (Beetle)
	  {160063 , "Other"},			-- Solid Shell (damage taken reduced 50%) (Shale Spider)
	  {264022 , "Other"},			-- Niuzao's Fortitude (damage taken reduced 60%) (Oxen)
	  {263920 , "Other"},			-- Gruff (damage taken reduced 60%) (Goat)
	  {263867 , "Other"},			-- Obsidian Skin (damage taken reduced 50%) (Core Hound)
	  {279410 , "Other"},			-- Bulwark (damage taken reduced 50%) (Krolusk)
	  {263938 , "Other"},			-- Silverback (damage taken reduced 60%) (Gorilla)
	  {263869 , "Other"},			-- Bristle (damage taken reduced 50%) (Boar)
	  {263868 , "Other"},			-- Defense Matrix (damage taken reduced 50%) (Mechanical)
	  {263926 , "Other"},			-- Thick Fur (damage taken reduced 60%) (Bear)
	  {263865 , "Other"},			-- Scale Shield (damage taken reduced 50%) (Scalehide)
	  {279400 , "Other"},			-- Ancient Hide (damage taken reduced 60%) (Pterrordax)
	  {160058 , "Other"},			-- Thick Hide (damage taken reduced 60%) (Clefthoof)

	----------------
	-- Mage
	----------------

	{45438  , "Other"},			-- Ice Block
	{198065 , "Other"},	-- Prismatic Cloak (pvp talent) (not immune}, 50% magic damage reduction)
	{110959 , "Other"},				-- Greater Invisibility
	{198144 , "Other"},				-- Ice form (stun/knockback immune)
	{12042  , "Other"},				-- Arcane Power
	{190319 , "Other"},				-- Combustion
	{12472  , "Other"},				-- Icy Veins
	{198111 , "Other"},			-- Temporal Shield (not immune}, heals all damage taken after 4 sec)

	----------------
	-- Monk
	----------------

	{125174 , "Other"},		  	-- Touch of Karma
  {124280 , "Other"},       -- Touch of Karma Dot
  {122470 , "Other"},       -- Touch of Karma
	{122783 , "Other"},     	-- Diffuse Magic (not immune}, 60% magic damage reduction)
	{115176 , "Other"},		  	-- Zen Meditation (60% damage reduction)
	{202248 , "Other"},	      -- Guided Meditation (pvp honor talent) (redirect spells to monk)
	{201325 , "Other"},				-- Zen Moment
	{122278 , "Other"},				-- Dampen Harm
	{243435 , "Other"},				-- Fortifying Brew
	{120954 , "Other"},				-- Fortifying Brew
	{201318 , "Other"},				-- Fortifying Brew (pvp honor talent)
	{116849 , "Other"},				-- Life Cocoon
	{214326 , "Other"},				-- Exploding Keg (artifact trait - blind)
	{213664 , "Other"},				-- Nimble Brew
	{209584 , "Other"},				-- Zen Focus Tea
	{216113 , "Other"},				-- Way of the Crane
	{137639 , "Other"},				-- Storm}, Earth}, and Fire
	{152173 , "Other"},				-- Serenity
	{115080 , "Other"},				-- Touch of Death

	----------------
	-- Paladin
	----------------

	{31821  , "Other"},				-- Aura Mastery
	{210294 , "Other"},				-- Divine Favor
	{105809 , "Other"},				-- Holy Avenger
	{31850  , "Other"},				-- Ardent Defender
	{31884  , "Other"},				-- Avenging Wrath
	{216331 , "Other"},				-- Avenging Crusader
	{86659  , "Other"},				-- Guardian of Ancient Kings

	----------------
	-- Priest
	----------------

	{47788  , "Other"},				-- Guardian Spirit (prevent the target from dying)
	{197268 , "Other"},				-- Ray of Hope
	{33206  , "Other"},				-- Pain Suppression
	{232707 , "Other"},		  	-- Ray of Hope (pvp honor talent - not immune}, only delay damage and heal)

	----------------
	-- Rogue
	----------------

	{31224  , "Other"},	     	-- Cloak of Shadows
	{51690  , "Other"},				-- Killing Spree
	{13750  , "Other"},				-- Adrenaline Rush
	{1966   , "Other"},				-- Feint
	{121471 , "Other"},				-- Shadow Blades
	{45182  , "Other"},			  -- Cheating Death (-85% damage taken)
	{5277   , "Other"},	      -- Evasion (dodge chance increased by 100%)
	{212283 , "Other"},				-- Symbols of Death
	{226364 , "Other"},				-- Evasion (Shadow Swiftness}, artifact trait)

	----------------
	-- Shaman
	----------------

	{207498 , "Other"},				-- Ancestral Protection (prevent the target from dying)
	{290641 , "Other"},				-- Ancestral Gift (PvP Talent) (immune to Silence and Interrupt effects)
	{108271 , "Other"},				-- Astral Shift
	{114050 , "Other"},				-- Ascendance (Elemental)
	{114051 , "Other"},				-- Ascendance (Enhancement)
	{114052 , "Other"},				-- Ascendance (Restoration)
  {210918 , "Other"},	      -- Ethereal Form

	----------------
	-- Warlock
	----------------

	{110913 , "Other"},				-- Dark Bargain
	{104773 , "Other"},				-- Unending Resolve
	{113860 , "Other"},				-- Dark Soul: Misery
	{113858 , "Other"},				-- Dark Soul: Instability
	{212295 , "Other"},	     	-- Netherward (reflects spells)

	----------------
	-- Warrior
	----------------

	{46924  , "Other"},		    -- Bladestorm (not immune to dmg}, only to LoC)
	{227847 , "Other"},			  -- Bladestorm (not immune to dmg}, only to LoC)
	{199038 , "Other"},			  -- Leave No Man Behind (not immune}, 90% damage reduction)
	{218826 , "Other"},			  -- Trial by Combat (warr fury artifact hidden trait) (only immune to death)
	{23920  , "Other"},		    -- Spell Reflection
	{216890 , "Other"},	   	  -- Spell Reflection
	{871    , "Other"},				-- Shield Wall
	{12975  , "Other"},				-- Last Stand
	{18499  , "Other"},				-- Berserker Rage
	{107574 , "Other"},				-- Avatar
	{262228 , "Other"},				-- Deadly Calm
	{198817 , "Other"},				-- Sharpen Blade (pvp honor talent)(Buff on Warrior)
	{198819 , "Other"},				-- Mortal Strike (Sharpen Blade pvp honor talent))(Debuff on Target)
	{184364 , "Other"},				-- Enraged Regeneration
	{118038 , "Other"},	      -- Die by the Sword (parry chance increased by 100%}, damage taken reduced by 30%)
	{198760 , "Other"},	      -- Intercept (pvp honor talent) (intercept the next ranged or melee hit)

},

	----------------
	-- Other
	----------------
{"Other", --TAB
	{56     , "CC"},				-- Stun (low lvl weapons proc)
	{835    , "CC"},				-- Tidal Charm (trinket)
	{15534  , "CC"},				-- Polymorph (trinket)
	{15535  , "CC"},				-- Enveloping Winds (Six Demon Bag trinket)
	{23103  , "CC"},				-- Enveloping Winds (Six Demon Bag trinket)
	{30217  , "CC"},				-- Adamantite Grenade
	{67769  , "CC"},				-- Cobalt Frag Bomb
	{67890  , "CC"},				-- Cobalt Frag Bomb (belt)
	{30216  , "CC"},				-- Fel Iron Bomb
	{224074 , "CC"},				-- Devilsaur's Bite (trinket)
	{127723 , "Root"},				-- Covered In Watermelon (trinket)
	{42803  , "Snare"},				-- Frostbolt (trinket)
	{195342 , "Snare"},				-- Shrink Ray (trinket)
	{256948 , "Other"},				-- Spatial Rift (void elf racial)
	{302731 , "Other"},				-- Ripple in Space (azerite essence)
	{214459 , "Silence"},			-- Choking Flames (trinket)
	{19821  , "Silence"},			-- Arcane Bomb
	{131510 , "Immune"},			-- Uncontrolled Banish
	{8346   , "Root"},				-- Mobility Malfunction (trinket)
	{39965  , "Root"},				-- Frost Grenade
	{55536  , "Root"},				-- Frostweave Net
	{13099  , "Root"},				-- Net-o-Matic (trinket)
	{13119  , "Root"},				-- Net-o-Matic (trinket)
	{16566  , "Root"},				-- Net-o-Matic (trinket)
	{13138  , "Root"},				-- Net-o-Matic (trinket)
	{148526 , "Root"},				-- Sticky Silk
	{15752  , "Disarm"},			-- Linken's Boomerang (trinket)
	{15753  , "CC"},				-- Linken's Boomerang (trinket)
	--{1604   , "Snare"},				-- Dazed
	{295048 , "Immune"},			-- Touch of the Everlasting (not immune}, damage taken reduced 85%)
	{221792 , "CC"},				-- Kidney Shot (Vanessa VanCleef (Rogue Bodyguard))
	{222897 , "CC"},				-- Storm Bolt (Dvalen Ironrune (Warrior Bodyguard))
	{222317 , "CC"},				-- Mark of Thassarian (Thassarian (Death Knight Bodyguard))
	{212435 , "CC"},				-- Shado Strike (Thassarian (Monk Bodyguard))
	{212246 , "CC"},				-- Brittle Statue (The Monkey King (Monk Bodyguard))
	{238511 , "CC"},				-- March of the Withered
	{252717 , "CC"},				-- Light's Radiance (Argus powerup)
	{148535 , "CC"},				-- Ordon Death Chime (trinket)
	{30504  , "CC"},				-- Poultryized! (trinket)
	{30501  , "CC"},				-- Poultryized! (trinket)
	{30506  , "CC"},				-- Poultryized! (trinket)
	{46567  , "CC"},				-- Rocket Launch (trinket)
	{24753  , "CC"},				-- Trick
	{21847  , "CC"},				-- Snowman
	{21848  , "CC"},				-- Snowman
	{21980  , "CC"},				-- Snowman
	{141928 , "CC"},				-- Growing Pains (Whole-Body Shrinka' toy)
	{285643 , "CC"},				-- Battle Screech
	{245855 , "CC"},				-- Belly Smash
	{262177 , "CC"},				-- Into the Storm
	{255978 , "CC"},				-- Pallid Glare
	{256050 , "CC"},				-- Disoriented (Electroshock Mount Motivator)
	{258258 , "CC"},				-- Quillbomb
	{260149 , "CC"},				-- Quillbomb
	{258236 , "CC"},				-- Sleeping Quill Dart
	{269186 , "CC"},				-- Holographic Horror Projector
	{255228 , "CC"},				-- Polymorphed (Organic Discombobulation Grenade and some NPCs)
	{272188 , "CC"},				-- Hammer Smash (quest)
	{264860 , "CC"},				-- Binding Talisman
	{238322 , "CC"},				-- Arcane Prison
	{171369 , "CC"},				-- Arcane Prison
	{295395 , "Silence"},			-- Oblivion Spear
	{268966 , "Root"},				-- Hooked Deep Sea Net
	{268965 , "Snare"},				-- Tidespray Linen Net
	{295366 , "CC"},				-- Purifying Blast (Azerite Essences)
	{293031 , "Snare"},				-- Suppressing Pulse (Azerite Essences)
	{300009 , "Snare"},				-- Suppressing Pulse (Azerite Essences)
	{300010 , "Snare"},				-- Suppressing Pulse (Azerite Essences)
	{299109 , "CC"},				-- Scrap Grenade
	{302880 , "Silence"},			-- Sharkbit (G99.99 Landshark)
	{299577 , "CC"},				-- Scroll of Bursting Power
	{296273 , "CC"},				-- Mirror Charm
	{304705 , "CC"},				-- Razorshell
	{304706 , "CC"},				-- Razorshell
	{299802 , "CC"},				-- Eel Trap
	{299803 , "CC"},				-- Eel Trap
	{299768 , "CC"},				-- Shiv and Shank
	{299769 , "CC"},				-- Undercut
	{299772 , "CC"},				-- Tsunami Slam
	{299805 , "Root"},				-- Undertow
	{310126 , "Immune"},			-- Psychic Shell (not immune}, 99% damage reduction) (Lingering Psychic Shell trinket)
	{314585 , "Immune"},			-- Psychic Shell (not immune}, 50-80% damage reduction) (Lingering Psychic Shell trinket)
	{313448 , "CC"},				-- Realized Truth (Corrupted Ring - Face the Truth ring)
	{290105 , "CC"},				-- Psychic Scream
	{295953 , "CC"},				-- Gnaw
	{292306 , "CC"},				-- Leg Sweep
	{247587 , "CC"},				-- Holy Word: Chastise
	{291391 , "CC"},				-- Sap
	{292224 , "CC"},				-- Chaos Nova
	{295459 , "CC"},				-- Mortal Coil
	{295240 , "CC"},				-- Dragon's Breath
	{284379 , "CC"},				-- Intimidation
	{290438 , "CC"},				-- Hex
	{283618 , "CC"},				-- Hammer of Justice
	{292055 , "Immune"},			-- Spirit of Redemption
	{290049 , "Immune"},			-- Ice Block
	{283627 , "Immune"},			-- Divine Shield
	{292230 , "ImmunePhysical"},	-- Evasion
	{290494 , "Silence"},			-- Avenger's Shield
	{284879 , "Root"},				-- Frost Nova
	{284844 , "Root"},				-- Glacial Spike
	{299256 , "Other"},				-- Blessing of Freedom
	{292266 , "Other"},				-- Avenging Wrath
	{292222 , "Other"},				-- Blur
	{292152 , "Other"},				-- Icebound Fortitude
	{292158 , "Other"},				-- Astral Shift
	{283433 , "Other"},				-- Avatar
	{292297 , "Snare"},				-- Cone of Cold
	{283649 , "Snare"},				-- Crippling Poison
	{284860 , "Snare"},				-- Flurry
	{284217 , "Snare"},				-- Concussive Shot
	{290292 , "Snare"},				-- Vengeful Retreat
	{292156 , "Snare"},				-- Typhoon
	{295282 , "Snare"},				-- Concussive Shot
	{283558 , "Snare"},				-- Chains of Ice
	{284414 , "Snare"},				-- Mind Flay
	{290441 , "Snare"},				-- Frost Shock
	{295577 , "Snare"},				-- Frostbrand
	{8312   , "Root"},				-- Trap (Hunting Net trinket)
	{17308  , "CC"},				-- Stun (Hurd Smasher fist weapon)
	{23454  , "CC"},				-- Stun (The Unstoppable Force weapon)
	{9179   , "CC"},				-- Stun (Tigule and Foror's Strawberry Ice Cream item)
	{13327  , "CC"},				-- Reckless Charge (Goblin Rocket Helmet)
	{13181  , "CC"},				-- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
	{26740  , "CC"},				-- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
	{8345   , "CC"},				-- Control Machine (Gnomish Universal Remote trinket)
	{13235  , "CC"},				-- Forcefield Collapse (Gnomish Harm Prevention belt)
	{13158  , "CC"},				-- Rocket Boots Malfunction (Engineering Rocket Boots)
	{13466  , "CC"},				-- Goblin Dragon Gun (engineering trinket malfunction)
	{8224   , "CC"},				-- Cowardice (Savory Deviate Delight effect)
	{8225   , "CC"},				-- Run Away! (Savory Deviate Delight effect)
	{23131  , "ImmuneSpell"},		-- Frost Reflector (Gyrofreeze Ice Reflector trinket) (only reflect frost spells)
	{23097  , "ImmuneSpell"},		-- Fire Reflector (Hyper-Radiant Flame Reflector trinket) (only reflect fire spells)
	{23132  , "ImmuneSpell"},		-- Shadow Reflector (Ultra-Flash Shadow Reflector trinket) (only reflect shadow spells)
	{30003  , "ImmuneSpell"},		-- Sheen of Zanza
	{23444  , "CC"},				-- Transporter Malfunction
	{23447  , "CC"},				-- Transporter Malfunction
	{23456  , "CC"},				-- Transporter Malfunction
	{23457  , "CC"},				-- Transporter Malfunction
	{8510   , "CC"},				-- Large Seaforium Backfire
	{7144   , "ImmunePhysical"},	-- Stone Slumber
	{12843  , "Immune"},			-- Mordresh's Shield
	{27619  , "Immune"},			-- Ice Block
	{21892  , "Immune"},			-- Arcane Protection
	{13237  , "CC"},				-- Goblin Mortar
	{5134   , "CC"},				-- Flash Bomb
	{4064   , "CC"},				-- Rough Copper Bomb
	{4065   , "CC"},				-- Large Copper Bomb
	{4066   , "CC"},				-- Small Bronze Bomb
	{4067   , "CC"},				-- Big Bronze Bomb
	{4068   , "CC"},				-- Iron Grenade
	{4069   , "CC"},				-- Big Iron Bomb
	{12543  , "CC"},				-- Hi-Explosive Bomb
	{12562  , "CC"},				-- The Big One
	{12421  , "CC"},				-- Mithril Frag Bomb
	{19784  , "CC"},				-- Dark Iron Bomb
	{19769  , "CC"},				-- Thorium Grenade
	{13808  , "CC"},				-- M73 Frag Grenade
	{21188  , "CC"},				-- Stun Bomb Attack
	{9159   , "CC"},				-- Sleep (Green Whelp Armor chest)
	--{9774   , "Other"},				-- Immune Root (spider belt)
	{18278  , "Silence"},			-- Silence (Silent Fang sword)
	{16470  , "CC"},				-- Gift of Stone
	{700    , "CC"},				-- Sleep (Slumber Sand item)
	{1090   , "CC"},				-- Sleep
	{12098  , "CC"},				-- Sleep
	{20663  , "CC"},				-- Sleep
	{20669  , "CC"},				-- Sleep
	{20989  , "CC"},				-- Sleep
	{24004  , "CC"},				-- Sleep
	{8064   , "CC"},				-- Sleepy
	{17446  , "CC"},				-- The Black Sleep
	{29848  , "CC"},				-- Polymorph
	{29124  , "CC"},				-- Polymorph
	{14621  , "CC"},				-- Polymorph
	{27760  , "CC"},				-- Polymorph
	{28406  , "CC"},				-- Polymorph Backfire
	{851    , "CC"},				-- Polymorph: Sheep
	{16707  , "CC"},				-- Hex
	{16708  , "CC"},				-- Hex
	{16709  , "CC"},				-- Hex
	{18503  , "CC"},				-- Hex
	{20683  , "CC"},				-- Highlord's Justice
	{17286  , "CC"},				-- Crusader's Hammer
	{17820  , "Other"},				-- Veil of Shadow
	{12096  , "CC"},				-- Fear
	{27641  , "CC"},				-- Fear
	{27990  , "CC"},				-- Fear
	{29168  , "CC"},				-- Fear
	{30002  , "CC"},				-- Fear
	{26042  , "CC"},				-- Psychic Scream
	{27610  , "CC"},				-- Psychic Scream
	{9915   , "Root"},				-- Frost Nova
	{14907  , "Root"},				-- Frost Nova
	{22645  , "Root"},				-- Frost Nova
	{29849  , "Root"},				-- Frost Nova
	{30094  , "Root"},				-- Frost Nova
	{15091  , "Snare"},				-- Blast Wave
	{17277  , "Snare"},				-- Blast Wave
	{23039  , "Snare"},				-- Blast Wave
	{23113  , "Snare"},				-- Blast Wave
	{30092  , "Snare"},				-- Blast Wave
	{12548  , "Snare"},				-- Frost Shock
	{22582  , "Snare"},				-- Frost Shock
	{23115  , "Snare"},				-- Frost Shock
	{19133  , "Snare"},				-- Frost Shock
	{21030  , "Snare"},				-- Frost Shock
	{11538  , "Snare"},				-- Frostbolt
	{21369  , "Snare"},				-- Frostbolt
	{20297  , "Snare"},				-- Frostbolt
	{20806  , "Snare"},				-- Frostbolt
	{20819  , "Snare"},				-- Frostbolt
	{12737  , "Snare"},				-- Frostbolt
	{20792  , "Snare"},				-- Frostbolt
	{28478  , "Snare"},				-- Frostbolt
	{28479  , "Snare"},				-- Frostbolt
	{17503  , "Snare"},				-- Frostbolt
	{23412  , "Snare"},				-- Frostbolt
	{24942  , "Snare"},				-- Frostbolt
	{23102  , "Snare"},				-- Frostbolt
	{20828  , "Snare"},				-- Cone of Cold
	{22746  , "Snare"},				-- Cone of Cold
	{30095  , "Snare"},				-- Cone of Cold
	{20717  , "Snare"},				-- Sand Breath
	{16568  , "Snare"},				-- Mind Flay
	{28310  , "Snare"},				-- Mind Flay
	{29407  , "Snare"},				-- Mind Flay
	{16094  , "Snare"},				-- Frost Breath
	{16340  , "Snare"},				-- Frost Breath
	{17174  , "Snare"},				-- Concussive Shot
	{27634  , "Snare"},				-- Concussive Shot
	{20654  , "Root"},				-- Entangling Roots
	{22800  , "Root"},				-- Entangling Roots
	{12520  , "Root"},				-- Teleport from Azshara Tower
	{12521  , "Root"},				-- Teleport from Azshara Tower
	{12024  , "Root"},				-- Net
	{12023  , "Root"},				-- Web
	{13608  , "Root"},				-- Hooked Net
	{10017  , "Root"},				-- Frost Hold
	{23279  , "Root"},				-- Crippling Clip
	{3542   , "Root"},				-- Naraxis Web
	{5567   , "Root"},				-- Miring Mud
	{4932   , "ImmuneSpell"},		-- Ward of Myzrael
	{7383   , "ImmunePhysical"},	-- Water Bubble
	{101    , "CC"},				-- Trip
	{3109   , "CC"},				-- Presence of Death
	{3143   , "CC"},				-- Glacial Roar
	{5403   , "Root"},				-- Crash of Waves
	{6605   , "CC"},				-- Terrifying Screech
	{3260   , "CC"},				-- Violent Shield Effect
	{3263   , "CC"},				-- Touch of Ravenclaw
	{3271   , "CC"},				-- Fatigued
	{5106   , "CC"},				-- Crystal Flash
	{6266   , "CC"},				-- Kodo Stomp
	{6730   , "CC"},				-- Head Butt
	{6982   , "CC"},				-- Gust of Wind
	{6749   , "CC"},				-- Wide Swipe
	{6754   , "CC"},				-- Slap!
	{6927   , "CC"},				-- Shadowstalker Slash
	{7961   , "CC"},				-- Azrethoc's Stomp
	{8151   , "CC"},				-- Surprise Attack
	{3635   , "CC"},				-- Crystal Gaze
	{8646   , "CC"},				-- Snap Kick
	{27620  , "Silence"},			-- Snap Kick
	{27814  , "Silence"},			-- Kick
	{21990  , "CC"},				-- Tornado
	{19725  , "CC"},				-- Turn Undead
	{19469  , "CC"},				-- Poison Mind
	{10134  , "CC"},				-- Sand Storm
	{12613  , "CC"},				-- Dark Iron Taskmaster Death
	{13488  , "CC"},				-- Firegut Fear Storm
	{17738  , "CC"},				-- Curse of the Plague Rat
	{20019  , "CC"},				-- Engulfing Flames
	{19136  , "CC"},				-- Stormbolt
	{20685  , "CC"},				-- Storm Bolt
	{16803  , "CC"},				-- Flash Freeze
	{14100  , "CC"},				-- Terrifying Roar
	{29685  , "CC"},				-- Terrifying Roar
	{17276  , "CC"},				-- Scald
	{18812  , "CC"},				-- Knockdown
	{11430  , "CC"},				-- Slam
	{28335  , "CC"},				-- Whirlwind
	{16451  , "CC"},				-- Judge's Gavel
	{23601  , "CC"},				-- Scatter Shot
	{25260  , "CC"},				-- Wings of Despair
	{23275  , "CC"},				-- Dreadful Fright
	{24919  , "CC"},				-- Nauseous
	{29484  , "CC"},				-- Web Spray
	{21167  , "CC"},				-- Snowball
	{25815  , "CC"},				-- Frightening Shriek
	{28786  , "CC"},				-- Locust Swarm
	{9612   , "CC"},				-- Ink Spray (Chance to hit reduced by 50%)
	{4320   , "Silence"},			-- Trelane's Freezing Touch
	{4243   , "Silence"},			-- Pester Effect
	{9552   , "Silence"},			-- Searing Flames
	{10576  , "Silence"},			-- Piercing Howl
	{12943  , "Silence"},			-- Fell Curse Effect
	{23417  , "Silence"},			-- Smother
	{10851  , "Disarm"},			-- Grab Weapon
	{6576   , "CC"},				-- Intimidating Growl
	{7093   , "CC"},				-- Intimidation
	{8715   , "CC"},				-- Terrifying Howl
	{8817   , "CC"},				-- Smoke Bomb
	{3442   , "CC"},				-- Enslave
	{3651   , "ImmuneSpell"},		-- Shield of Reflection
	{20223  , "ImmuneSpell"},		-- Magic Reflection
	{25772  , "CC"},				-- Mental Domination
	{16053  , "CC"},				-- Dominion of Soul (Orb of Draconic Energy)
	{15859  , "CC"},				-- Dominate Mind
	{20740  , "CC"},				-- Dominate Mind
	{21330  , "CC"},				-- Corrupted Fear (Deathmist Raiment set)
	{27868  , "Root"},				-- Freeze (Magister's and Sorcerer's Regalia sets)
	{17333  , "Root"},				-- Spider's Kiss (Spider's Kiss set)
	{26108  , "CC"},				-- Glimpse of Madness (Dark Edge of Insanity axe)
	{9462   , "Snare"},				-- Mirefin Fungus
	{19137  , "Snare"},				-- Slow
	{6724   , "Immune"},			-- Light of Elune
	{24360  , "CC"},				-- Greater Dreamless Sleep Potion
	{15822  , "CC"},				-- Dreamless Sleep Potion
	{15283  , "CC"},				-- Stunning Blow (Dark Iron Pulverizer weapon)
	{21152  , "CC"},				-- Earthshaker (Earthshaker weapon)
	{16600  , "CC"},				-- Might of Shahram (Blackblade of Shahram sword)
	{16597  , "Snare"},				-- Curse of Shahram (Blackblade of Shahram sword)
	{13496  , "Snare"},				-- Dazed (Mug O' Hurt mace)
	{3238   , "Other"},				-- Nimble Reflexes
	{5990   , "Other"},				-- Nimble Reflexes
	{6615   , "Other"},				-- Free Action Potion
	{11359  , "Other"},				-- Restorative Potion
	{24364  , "Other"},				-- Living Free Action
	{23505  , "Other"},				-- Berserking
	{24378  , "Other"},				-- Berserking
	{19135  , "Other"},				-- Avatar
	{17624  , "CC"},				-- Flask of Petrification
	{13534  , "Disarm"},			-- Disarm (The Shatterer weapon)
	{13439  , "Snare"},				-- Frostbolt (some weapons)
	{16621  , "ImmunePhysical"},	-- Self Invulnerability (Invulnerable Mail)
	{27559  , "Silence"},			-- Silence (Jagged Obsidian Shield)
	{13907  , "CC"},				-- Smite Demon (Enchant Weapon - Demonslaying)
	{18798  , "CC"},				-- Freeze (Freezing Band)

},

	-- PvE
	--{123456 , "PvE"},				-- This is just an example}, not a real spell
	------------------------
	---- PVE BFA
	------------------------
	-- Ny'alotha}, The Waking City Raid
	-- -- Trash
{"Ny'alotha, The Waking City Raid",
	{313949 , "Immune"},			-- Ny'alotha Gateway
	{315071 , "Immune"},			-- Ny'alotha Gateway
	{315080 , "Immune"},			-- Ny'alotha Gateway
	{315214 , "Immune"},			-- Ny'alotha Gateway
	{311052 , "Immune"},			-- Steadfast Defense (not immune}, 75% damage reduction)
	{311073 , "Immune"},			-- Steadfast Defense (not immune}, 75% damage reduction)
	{310830 , "CC"},				-- Disorienting Strike
	{315013 , "Silence"},			-- Bursting Shadows
	{316951 , "CC"},				-- Voracious Charge
	{311552 , "CC"},				-- Fear the Void
	{311041 , "CC"},				-- Drive to Madness
	{318785 , "CC"},				-- Corrupted Touch
	{318880 , "Root"},				-- Corrupted Touch
	{316143 , "Snare"},				-- Thunder Clap
	-- -- Wrathion
	{314347 , "CC"},				-- Noxious Choke
	{313175 , "Immune"},			-- Hardened Core
	{306995 , "Immune"},			-- Smoke and Mirrors
	-- -- Maut
	{307586 , "CC"},				-- Devoured Abyss
	{309853 , "Silence"},			-- Devoured Abyss
	-- -- The Prophet Skitra
	{313208 , "Immune"},			-- Intangible Illusion
	-- -- Dark Inquisitor
	{314035 , "Immune"},			-- Void Shield
	{316211 , "CC"},				-- Terror Wave
	{305575 , "Snare"},				-- Ritual Field
	--{309569 , "CC"},				-- Voidwoken (damage dealt reduced 99%)
	--{312406 , "CC"},				-- Voidwoken (damage dealt reduced 99%)
	-- -- The Hivemind
	{307202 , "Immune"},			-- Shadow Veil (damage taken reduced by 99%)
	{308873 , "CC"},				-- Corrosive Venom
	{313460 , "Other"},				-- Nullification (healing received reduced by 100%)
	-- -- Shad'har the Insatiable
	{306928 , "CC"},				-- Umbral Breath
	{306930 , "Other"},				-- Entropic Breath (healing received reduced by 50%)
	-- -- Drest'agath
	{310246 , "CC"},				-- Void Grip
	{310361 , "CC"},				-- Unleashed Insanity
	{310552 , "Snare"},				-- Mind Flay
	-- -- Il'gynoth
	{311367 , "CC"},				-- Touch of the Corruptor
	{310322 , "CC"},				-- Morass of Corruption
	-- -- Vexiona
	{307645 , "CC"},				-- Heart of Darkness
	{315932 , "CC"},				-- Brutal Smash
	{307729 , "CC"},				-- Fanatical Ascension
	{307075 , "CC"},				-- Power of the Chosen
	{316745 , "CC"},				-- Power of the Chosen
	{310323 , "Snare"},				-- Desolation
	-- -- Ra Den
	{315207 , "CC"},				-- Stunned
	{306637 , "Silence"},			-- Unstable Void Burst
	{306645 , "Silence"},			-- Consuming Void
	{309777 , "Other"},				-- Void Defilement (all healing taken reduced 50%)
	-- -- Carapace of N'Zoth
	{307832 , "CC"},				-- Servant of N'Zoth
	{312158 , "Immune"},			-- Ashjra'kamas}, Shroud of Resolve
	{317165 , "CC"},				-- Regenerative Expulsion
	{306978 , "CC"},				-- Madness Bomb
	{306985 , "CC"},				-- Insanity Bomb
	{307071 , "Immune"},			-- Synthesis
	{307061 , "Snare"},				-- Mycelial Growth
	{317164 , "Immune"},			-- Reactive Mass
	-- -- N'Zoth
	{308996 , "CC"},				-- Servant of N'Zoth
	{310073 , "CC"},				-- Mindgrasp
	{311392 , "CC"},				-- Mindgrasp
	{314843 , "CC"},				-- Corruptor's Gift
	{313793 , "CC"},				-- Flames of Insanity
	{319353 , "CC"},				-- Flames of Insanity
	{315675 , "CC"},				-- Shattered Ego
	{315672 , "CC"},				-- Shattered Ego
	{318976 , "CC"},				-- Stupefying Glare
	{310134 , "Immune"},			-- Manifest Madness (99% damage reduction)
},
	-- --
	-- The Eternal Palace Raid
	-- -- Trash
{"The Eternal Palace Raid",
	{303747 , "CC"},				-- Ice Tomb
	{303396 , "Root"},				-- Barbed Net
	{304189 , "Snare"},				-- Frostbolt
	{303316 , "Snare"},				-- Hindering Resonance
	-- -- Abyssal Commander Sivara
	{295807 , "CC"},				-- Frozen
	{295850 , "CC"},				-- Delirious
	{295704 , "CC"},				-- Frost Bolt
	{295705 , "CC"},				-- Toxic Bolt
	{300882 , "Root"},				-- Inversion Sickness
	{300883 , "Root"},				-- Inversion Sickness
	-- -- Radiance of Azshara
	{295916 , "Immune"},			-- Ancient Tempest (damage taken reduced 99%)
	{296746 , "CC"},				-- Arcane Bomb
	{304027 , "CC"},				-- Arcane Bomb
	{296389 , "Immune"},			-- Swirling Winds (damage taken reduced 99%)
	-- -- Lady Ashvane
	{297333 , "CC"},				-- Briny Bubble
	{302992 , "CC"},				-- Briny Bubble
	-- -- Orgozoa
	{305347 , "Immune"},			-- Massive Incubator (damage taken reduced 90%)
	{295822 , "CC"},				-- Conductive Pulse
	{305603 , "CC"},				-- Electro Shock
	{304280 , "Immune"},			-- Chaotic Growth (damage taken reduced 50%)
	{296914 , "Immune"},			-- Chaotic Growth (damage taken reduced 50%)
	-- -- The Queen's Court
	{296704 , "Immune"},			-- Separation of Power (damage taken reduced 99%)
	{296716 , "Immune"},			-- Separation of Power (damage taken reduced 99%)
	{304410 , "Silence"},			-- Repeat Performance
	{301832 , "CC"},				-- Fanatical Zeal
	-- -- Za'qul}, Harbinger of Ny'alotha
	{300133 , "CC"},				-- Snapped
	{294545 , "CC"},				-- Portal of Madness
	{292963 , "CC"},				-- Dread
	{302503 , "CC"},				-- Dread
	{303619 , "CC"},				-- Dread
	{295327 , "CC"},				-- Shattered Psyche
	{303832 , "CC"},				-- Tentacle Slam
	{301117 , "Immune"},			-- Dark Shield
	{296084 , "CC"},				-- Mind Fracture
	{299705 , "CC"},				-- Dark Passage
	{299591 , "Immune"},			-- Shroud of Fear
	{303543 , "CC"},				-- Dread Scream
	{296018 , "CC"},				-- Manic Dread
	{302504 , "CC"},				-- Manic Dread
	-- -- Queen Azshara
	{304759 , "CC"},				-- Queen's Disgust
	{304763 , "CC"},				-- Queen's Disgust
	{304760 , "Disarm"},			-- Queen's Disgust
	{304770 , "Snare"},				-- Queen's Disgust
	{304768 , "Snare"},				-- Queen's Disgust
	{304757 , "Snare"},				-- Queen's Disgust
	{298018 , "CC"},				-- Frozen
	{299094 , "CC"},				-- Beckon
	{302141 , "CC"},				-- Beckon
	{303797 , "CC"},				-- Beckon
	{303799 , "CC"},				-- Beckon
	{300001 , "CC"},				-- Devotion
	{303825 , "CC"},				-- Crushing Depths
	{300620 , "Immune"},			-- Crystalline Shield
	{303706 , "CC"},				-- Song of Azshara
},
	------------------------
	-- Crucible of Storms Raid
	-- -- Trash
{"Crucible of Storms Raid",
	{293957 , "CC"},				-- Maddening Gaze
	{295312 , "Immune"},			-- Shadow Siphon
	{286754 , "CC"},				-- Storm of Annihilation (damage done decreased by 50%)
	-- -- The Restless Cabal
	{282589 , "CC"},				-- Cerebral Assault
	{285154 , "CC"},				-- Cerebral Assault
	{282517 , "CC"},				-- Terrifying Echo
	{287876 , "CC"},				-- Enveloping Darkness (healing and damage done reduced by 99%)
	{282743 , "CC"},				-- Storm of Annihilation (damage done decreased by 50%)
	-- -- Uu'nat
	{285562 , "CC"},				-- Unknowable Terror
	{287693 , "Immune"},			-- Sightless Bond (damage taken reduced by 99%)
	{286310 , "Immune"},			-- Void Shield (damage taken reduced by 99%)
	{284601 , "CC"},				-- Storm of Annihilation (damage done decreased by 50%)
},
	------------------------
	-- Battle of Dazar'alor Raid
	-- -- Trash
{"Battle of Dazar'alor Raid",
	{289471 , "CC"},				-- Terrifying Roar
	{286740 , "CC"},				-- Light's Fury
	{289645 , "CC"},				-- Polymorph
	{287325 , "CC"},				-- Comet Storm
	{289772 , "CC"},				-- Impale
	{289937 , "CC"},				-- Thundering Slam
	{288842 , "CC"},				-- Throw Goods
	{289419 , "CC"},				-- Mass Hex
	{288815 , "CC"},				-- Breath of Fire
	{287456 , "Root"},				-- Frost Nova
	{289742 , "Immune"},			-- Defense Field (damage taken reduced 75%)
	{287295 , "Snare"},				-- Chilled
	-- -- Champion of the Light
	{288294 , "Immune"},			-- Divine Protection (damage taken reduced 99%)
	{283651 , "CC"},				-- Blinding Faith
	-- -- Grong
	{289406 , "CC"},				-- Bestial Throw
	{289412 , "CC"},				-- Bestial Impact
	{285998 , "CC"},				-- Ferocious Roar
	{290575 , "CC"},				-- Ferocious Roar
	-- -- Opulence
	{283609 , "CC"},				-- Crush
	{283610 , "CC"},				-- Crush
	-- -- Conclave of the Chosen
	{282079 , "Immune"},			-- Loa's Pact (damage taken reduced 90%)
	{282135 , "CC"},				-- Crawling Hex
	{290573 , "CC"},				-- Crawling Hex
	{285879 , "CC"},				-- Mind Wipe
	{265495 , "CC"},				-- Static Orb
	{286838 , "CC"},				-- Static Orb
	{282447 , "CC"},				-- Kimbul's Wrath
	-- -- King Rastakhan
	{284995 , "CC"},				-- Zombie Dust
	{284376 , "CC"},				-- Death's Presence
	{284377 , "Immune"},			-- Unliving
	-- -- High Tinker Mekkatorque
	{287167 , "CC"},				-- Discombobulation
	{284214 , "CC"},				-- Trample
	{289138 , "CC"},				-- Trample
	{289644 , "Immune"},			-- Spark Shield (damage taken reduced 99%)
	{282401 , "Immune"},			-- Gnomish Force Shield (damage taken reduced 99%)
	{289248 , "Immune"},			-- P.L.O.T Armor (damage taken reduced 99%)
	{282408 , "CC"},				-- Spark Pulse (stun)
	{289232 , "CC"},				-- Spark Pulse (hit chance reduced 100%)
	{289226 , "CC"},				-- Spark Pulse (pacify)
	{286480 , "CC"},				-- Anti-Tampering Shock
	{286516 , "CC"},				-- Anti-Tampering Shock
	-- -- Stormwall Blockade
	{284121 , "Silence"},			-- Thunderous Boom
	{286495 , "CC"},				-- Tempting Song
	{284369 , "Snare"},				-- Sea Storm
	-- -- Lady Jaina Proudmoore
	{287490 , "CC"},				-- Frozen Solid
	{289963 , "CC"},				-- Frozen Solid
	{285704 , "CC"},				-- Frozen Solid
	{287199 , "Root"},				-- Ring of Ice
	{287626 , "Root"},				-- Grasp of Frost
	{288412 , "Root"},				-- Hand of Frost
	{288434 , "Root"},				-- Hand of Frost
	{289219 , "Root"},				-- Frost Nova
	{289855 , "CC"},				-- Frozen Siege
	{275809 , "CC"},				-- Flash Freeze
	{271527 , "Immune"},			-- Ice Block
	{287322 , "Immune"},			-- Ice Block
	{282841 , "Immune"},			-- Arctic Armor
	{287282 , "Immune"},			-- Arctic Armor (damage taken reduced 90%)
	{287418 , "Immune"},			-- Arctic Armor (damage taken reduced 90%)
	{288219 , "Immune"},			-- Refractive Ice (damage taken reduced 99%)
},
	------------------------
	-- Uldir Raid
	-- -- Trash
{"Uldir Raid",
	{277498 , "CC"},				-- Mind Slave
	{277358 , "CC"},				-- Mind Flay
	{278890 , "CC"},				-- Violent Hemorrhage
	{278967 , "CC"},				-- Winged Charge
	{260275 , "CC"},				-- Rumbling Stomp
	{262375 , "CC"},				-- Bellowing Roar
	-- -- Taloc
	{271965 , "Immune"},			-- Powered Down (damage taken reduced 99%)
	-- -- Fetid Devourer
	{277800 , "CC"},				-- Swoop
	-- -- Zek'voz}, Herald of N'zoth
	{265646 , "CC"},				-- Will of the Corruptor
	{270589 , "CC"},				-- Void Wail
	{270620 , "CC"},				-- Psionic Blast
	-- -- Vectis
	{265212 , "CC"},				-- Gestate
	-- -- Zul}, Reborn
	{273434 , "CC"},				-- Pit of Despair
	{269965 , "CC"},				-- Pit of Despair
	{274271 , "CC"},				-- Deathwish
	-- -- Mythrax the Unraveler
	{272407 , "CC"},				-- Oblivion Sphere
	{284944 , "CC"},				-- Oblivion Sphere
	{274230 , "Immune"},			-- Oblivion Veil (damage taken reduced 99%)
	{276900 , "Immune"},			-- Critical Mass (damage taken reduced 80%)
	-- -- G'huun
	{269691 , "CC"},				-- Mind Thrall
	{273401 , "CC"},				-- Mind Thrall
	{263504 , "CC"},				-- Reorigination Blast
	{273251 , "CC"},				-- Reorigination Blast
	{267700 , "CC"},				-- Gaze of G'huun
	{255767 , "CC"},				-- Grasp of G'huun
	{263217 , "Immune"},			-- Blood Shield (not immune}, but heals 5% of maximum health every 0.5 sec)
	{275129 , "Immune"},			-- Corpulent Mass (damage taken reduced by 99%)
	{268174 , "Root"},				-- Tendrils of Corruption
	{263235 , "Root"},				-- Blood Feast
	{263321 , "Snare"},				-- Undulating Mass
	{270287 , "Snare"},				-- Blighted Ground
					-- Blighted Ground
},

	------------------------
	-- BfA World Bosses
{"BfA World Bosses",
	-- -- T'zane
	{261552 , "CC"},				-- Terror Wail
	-- -- Hailstone Construct
	{274895 , "CC"},				-- Freezing Tempest
	-- -- Warbringer Yenajz
	{274904 , "CC"},				-- Reality Tear
	-- -- The Lion's Roar and Doom's Howl
	{271778 , "Snare"},				-- Reckless Charge
	-- -- Ivus the Decayed
	{287554 , "Immune"},			-- Petrify
	{282615 , "Immune"},			-- Petrify
	-- -- Grand Empress Shek'zara
	{314306 , "CC"},				-- Song of the Empress
},

	------------------------
	-- Horrific Visions of N'zoth
{"Horrific Visions of N'zoth",
	{317865 , "CC"},				-- Emergency Cranial Defibrillation
	{304816 , "CC"},				-- Emergency Cranial Defibrillation
	{291782 , "CC"},				-- Controlled by the Vision
	{311558 , "ImmuneSpell"},		-- Volatile Intent
	{306965 , "CC"},				-- Shadow's Grasp
	{316510 , "CC"},				-- Split Personality
	{306545 , "CC"},				-- Haunting Shadows
	{288545 , "CC"},				-- Fear	(Madness: Terrified)
	{292240 , "Other"},				-- Entomophobia
	{306583 , "Root"},				-- Leaden Foot
	{288560 , "Snare"},				-- Slowed
	{298514 , "CC"},				-- Aqiri Mind Toxin
	{313639 , "CC"},				-- Hex
	{305155 , "Snare"},				-- Rupture
	{296510 , "Snare"},				-- Creepy Crawler
	{78622  , "CC"},				-- Heroic Leap
	{314723 , "CC"},				-- War Stomp
	{304969 , "CC"},				-- Void Torrent
	{298033 , "CC"},				-- Touch of the Abyss
	{299243 , "CC"},				-- Touch of the Abyss
	{300530 , "CC"},				-- Mind Carver
	{304634 , "CC"},				-- Despair
	{297574 , "CC"},				-- Hopelessness
	{283408 , "Snare"},				-- Charge
	{304350 , "CC"},				-- Mind Trap
	{299870 , "CC"},				-- Mind Trap
	{306828 , "CC"},				-- Defiled Ground
	{306726 , "CC"},				-- Defiled Ground
	{297746 , "CC"},				-- Seismic Slam
	{306646 , "CC"},				-- Ring of Chaos
	{305378 , "CC"},				-- Horrifying Shout
	{298630 , "CC"},				-- Shockwave
	{297958 , "Snare"},				-- Punishing Throw
	{314748 , "Snare"},				-- Slow
	{298701 , "CC"},				-- Chains of Servitude
	{298770 , "CC"},				-- Chains of Servitude
	{309648 , "CC"},				-- Tainted Polymorph
	{296674 , "Silence"},			-- Lurking Appendage
	{308172 , "Snare"},				-- Mind Flay
	{308375 , "CC"},				-- Psychic Scream
	{306748 , "CC"},				-- Psychic Scream
	{309882 , "CC"},				-- Brutal Smash
	{298584 , "Immune"},			-- Repel (not immune}, 75% damage reduction)
	{312017 , "Immune"},			-- Shrouded (not immune}, 90% damage reduction)
	{308481 , "CC"},				-- Rift Strike
	{308508 , "CC"},				-- Rift Strike
	{308575 , "Immune"},			-- Shadow Shift	(not immune}, 75% damage reduction)
	{311373 , "Snare"},				-- Numbing Poison
	{283655 , "CC"},				-- Cheap Shot
	{283106 , "ImmuneSpell"},		-- Cloak of Shadows
	{283661 , "CC"},				-- Kidney Shot
	{315254 , "Snare"},				-- Harsh Lesson
	{315391 , "Snare"},				-- Gladiator's Spite
	{311042 , "CC"},				-- Evacuation Protocol
	{306552 , "CC"},				-- Evacuation Protocol
	{306465 , "CC"},				-- Evacuation Protocol
	{314916 , "CC"},				-- Evacuation Protocol
	{302460 , "CC"},				-- Evacuation Protocol
	{297286 , "CC"},				-- Evacuation Protocol
	{311036 , "CC"},				-- Evacuation Protocol
	{302493 , "CC"},				-- Evacuation Protocol
	{311020 , "CC"},				-- Evacuation Protocol
	{308654 , "Immune"},			-- Shield Craggle (not immune}, 90% damage reduction)
},
	------------------------
	-- Visions of N'zoth Assaults (Uldum}, Vale of Eternal Blossoms and Misc)
{"Visions of N'zoth Assaults (Uldum}, Vale of Eternal Blossoms and Misc",
	{315818 , "CC"},				-- Burning
	{250490 , "CC"},				-- Animated Strike
	{317277 , "CC"},				-- Storm Bolt
	{316508 , "CC"},				-- Thunderous Charge
	{296820 , "CC"},				-- Invoke Niuzao
	{308969 , "CC"},				-- Dusted
	{166139 , "CC"},				-- Blinding Radiance
	{308890 , "CC"},				-- Shockwave
	{314193 , "CC"},				-- Massive Shockwave
	{314191 , "CC"},				-- Massive Shockwave
	{314880 , "CC"},				-- Wave of Hysteria
	{312678 , "CC"},				-- Insanity
	{312666 , "Other"},				-- Soulbreak
	{314796 , "CC"},				-- Bursting Darkness
	{157176 , "CC"},				-- Grip of the Void
	{309398 , "CC"},				-- Blinding Radiance
	{316997 , "CC"},				-- Blinding Radiance
	{315892 , "Silence"},			-- Void of Silence
	{314205 , "CC"},				-- Maddening Gaze
	{314614 , "CC"},				-- Fear of the Void
	{265721 , "Root"},				-- Web Spray
	{93585  , "CC"},				-- Serum of Torment
	{316093 , "CC"},				-- Terrifying Shriek
	{314458 , "ImmuneSpell"},		-- Magnetic Field
	{315829 , "CC"},				-- Evolution
	{314077 , "CC"},				-- Psychic Assault
	{86699  , "CC"},				-- Shockwave
	{88846  , "CC"},				-- Shockwave
	{309696 , "CC"},				-- Soul Wipe
	{316353 , "CC"},				-- Shield Bash
	{310271 , "CC"},				-- Bewildering Gaze
	{242085 , "CC"},				-- Disoriented
	{242084 , "CC"},				-- Fear
	{242088 , "CC"},				-- Polymorph
	{242090 , "CC"},				-- Sleep
	{296661 , "CC"},				-- Stomp
	{306875 , "CC"},				-- Electrostatic Burst
	{308886 , "Root"},				-- Grasp of the Stonelord
	{313751 , "Snare"},				-- Amber Burst
	{313934 , "Immune"},			-- Sticky Shield
	{310239 , "CC"},				-- Terror Gasp
	{81210  , "Root"},				-- Net
	{200434 , "CC"},				-- Petrified!
	{309709 , "CC"},				-- Petrified
	{312248 , "CC"},				-- Amber Hibernation
	{305141 , "Immune"},			-- Azerite-Hardened Carapace
	{317490 , "Snare"},				-- Mind Flay
	{97154  , "Snare"},				-- Concussive Shot
	{126339 , "CC"},				-- Shield Slam
	{126580 , "CC"},				-- Crippling Blow
	{177578 , "CC"},				-- Paralysis
	{314591 , "CC"},				-- Flesh to Stone
	{314382 , "Silence"},			-- Silence the Masses
	{312884 , "CC"},				-- Heaving Blow
	{270444 , "Other"},				-- Harden
	{309463 , "CC"},				-- Crystalline
	{309889 , "Snare"},				-- Grasp of N'Zoth
	{309411 , "Immune"},			-- Gift of Stone
	{307327 , "Immune"},			-- Expel Anima
	{312933 , "Immune"},			-- Void's Embrace
	{306791 , "Immune"},			-- Unexpected Results (not immune}, 75% damage reduction)
	{307234 , "CC"},				-- Disciple of N'Zoth
	{307786 , "CC"},				-- Spirit Bind
	{154793 , "Root"},				-- Spirit Bind
	{311522 , "CC"},				-- Nightmarish Stare
	{306222 , "CC"},				-- Critical Failure
	{304241 , "Root"},				-- Distorting Reality
	{316940 , "CC"},				-- Assassin Spawn
	{302338 , "CC"},				-- Ice Trap
	{302591 , "CC"},				-- Ice Trap
	{296810 , "Immune"},			-- Fear of Death
	{313275 , "CC"},				-- Cowardice
	{292451 , "CC"},				-- Binding Shot
	{306769 , "CC"},				-- Mutilate
	{302232 , "CC"},				-- Crushing Charge
	{314301 , "CC"},				-- Doom
	{299269 , "CC"},				-- Eye Beam
	{314118 , "CC"},				-- Glimpse of Infinity
	{306282 , "CC"},				-- Knockdown
	{303403 , "CC"},				-- Sap
	{296057 , "CC"},				-- Seeker's Song
	{299485 , "CC"},				-- Surging Shadows
	{311635 , "CC"},				-- Throw Hefty Coin Sack
	{303193 , "CC"},				-- Trample
	{313719 , "CC"},				-- X-52 Personnel Armor: Overload
	{313311 , "CC"},				-- Underhanded Punch
	{315850 , "CC"},				-- Vomit
},
	------------------------
	-- Battle for Darkshore
{"Battle for Darkshore",
	{314516 , "CC"},				-- Savage Charge
	{314519 , "CC"},				-- Ravage
	{314884 , "CC"},				-- Frozen Solid
	{7964   , "CC"},				-- Smoke Bomb
	{31274  , "CC"},				-- Knockdown
	{283921 , "CC"},				-- Lancer's Charge
	{285708 , "CC"},				-- Frozen Solid
	{288344 , "CC"},				-- Massive Stomp
	{288339 , "CC"},				-- Massive Stomp
	{286397 , "CC"},				-- Massive Stomp
	{282676 , "CC"},				-- Massive Stomp
	{212566 , "CC"},				-- Terrifying Screech
	{283880 , "CC"},				-- DRILL KILL
	{284949 , "CC"},				-- Warden's Prison
	{22127  , "Root"},				-- Entangling Roots
	{31290  , "Root"},				-- Net
	{286404 , "Root"},				-- Grasping Bramble
	{290013 , "Root"},				-- Volatile Bulb
	{311761 , "Root"},				-- Entangling Roots
	{311634 , "Root"},				-- Entangling Roots
	{22356  , "Snare"},				-- Slow
	{284221 , "Snare"},				-- Crippling Gash
	{194584 , "Snare"},				-- Crippling Slash
	{284737 , "Snare"},				-- Toxic Strike
	{289073 , "Snare"},				-- Terrifying Screech
	{286510 , "Snare"},				-- Nature's Force
},
	------------------------
	-- Battle for Stromgarde
{"Battle for Stromgarde",
	{6524   , "CC"},				-- Ground Tremor
	{97933  , "CC"},				-- Intimidating Shout
	{273867 , "CC"},				-- Intimidating Shout
	{262007 , "CC"},				-- Polymorph
	{261488 , "CC"},				-- Charge
	{264942 , "CC"},				-- Scatter Shot
	{258186 , "CC"}, 				-- Crushing Cleave
	{270411 , "CC"},				-- Earthshatter
	{259833 , "CC"},				-- Heroic Leap
	{259867 , "CC"},				-- Storm Bolt
	{272856 , "CC"},				-- Hex Bomb
	{266918 , "CC"},				-- Fear
	{262362 , "CC"},				-- Hex
	{253731 , "CC"},				-- Massive Stomp
	{269674 , "CC"},				-- Shattering Stomp
	{263665 , "CC"},				-- Conflagration
	{210131 , "CC"},				-- Trampling Charge
	{745    , "Root"},				-- Web
	{269680 , "Root"},				-- Entanglement
	{262610 , "Root"},				-- Weighted Net
	{20822  , "Snare"},				-- Frostbolt
	{141619 , "Snare"},				-- Frostbolt
	{183081 , "Snare"},				-- Frostbolt
	{266985 , "Snare"},				-- Oil Slick
	{271001 , "Snare"},				-- Poisoned Axe
	{273665 , "Snare"},				-- Seismic Disturbance
	{278190 , "Snare"},				-- Debilitating Infection
	{270089 , "Snare"},				-- Frostbolt Volley
	{262538 , "Snare"},				-- Thunder Clap
	{259850 , "Snare"},				-- Reverberating Clap
},
	------------------------
	-- BfA Island Expeditions
{" BfA Island Expeditions",
	{8377   , "Root"},				-- Earthgrab
	{270399 , "Root"},				-- Unleashed Roots
	{270196 , "Root"},				-- Chains of Light
	{267024 , "Root"},				-- Stranglevines
	{236467 , "Root"},				-- Pearlescent Clam
	{267025 , "Root"},				-- Animal Trap
	{276807 , "Root"},				-- Crude Net
	{276806 , "Root"},				-- Stoutthistle
	{255311 , "Root"},				-- Hurl Spear
	{8208   , "CC"},				-- Backhand
	{12461  , "CC"},				-- Backhand
	{276991 , "CC"},				-- Backhand
	{280061 , "CC"},				-- Brainsmasher Brew
	{280062 , "CC"},				-- Unluckydo
	{267029 , "CC"},				-- Glowing Seed
	{276808 , "CC"},				-- Heavy Boulder
	{267028 , "CC"},				-- Bright Lantern
	{276809 , "CC"},				-- Crude Spear
	{276804 , "CC"},				-- Crude Boomerang
	{267030 , "CC"},				-- Heavy Crate
	{276805 , "CC"},				-- Gloomspore Shroom
	{245638 , "CC"},				-- Thick Shell
	{267026 , "CC"},				-- Giant Flower
	{243576 , "CC"},				-- Sticky Starfish
	{278818 , "CC"},				-- Amber Entrapment
	{268345 , "CC"},				-- Azerite Suppression
	{278813 , "CC"},				-- Brain Freeze
	{272982 , "CC"},				-- Bubble Trap
	{278823 , "CC"},				-- Choking Mist
	{268343 , "CC"},				-- Crystalline Stasis
	{268341 , "CC"},				-- Cyclone
	{273392 , "CC"},				-- Drakewing Bonds
	{278817 , "CC"},				-- Drowning Waters
	{268337 , "CC"},				-- Flash Freeze
	{278914 , "CC"},				-- Ghostly Rune Prison
	{278822 , "CC"},				-- Heavy Net
	{273612 , "CC"},				-- Mental Fog
	{278820 , "CC"},				-- Netted
	{278816 , "CC"},				-- Paralyzing Pool
	{278811 , "CC"},				-- Poisoned Water
	{278821 , "CC"},				-- Sand Trap
	{274055 , "CC"},				-- Sap
	{273914 , "CC"},				-- Shadowy Conflagration
	{279986 , "CC"},				-- Shrink Ray
	{278814 , "CC"},				-- Sticky Ooze
	{259236 , "CC"},				-- Stone Rune Prison
	{290626 , "CC"},				-- Debilitating Howl
	{290625 , "CC"},				-- Creeping Decay
	{290624 , "CC"},				-- Necrotic Paralysis
	{290623 , "CC"},				-- Stone Prison
	{245139 , "CC"},				-- Petrified
	{274794 , "CC"},				-- Hex
	{278808 , "CC"},				-- Hex
	{278809 , "CC"},				-- Hex
	{275651 , "CC"},				-- Charge
	{262470 , "CC"},				-- Blast-O-Matic Frag Bomb
	{262906 , "CC"},				-- Arcane Charge
	{270460 , "CC"},				-- Stone Eruption
	{262500 , "CC"},				-- Crushing Charge
	{268203 , "CC"},				-- Death Lens
	{244880 , "CC"},				-- Charge
	{275087 , "CC"},				-- Charge
	{262342 , "CC"},				-- Hex
	{257748 , "CC"},				-- Blind
	{262147 , "CC"},				-- Wild Charge
	{262000 , "CC"},				-- Wyvern Sting
	{258822 , "CC"},				-- Blinding Peck
	{271227 , "CC"},				-- Wildfire
	{244888 , "CC"},				-- Bonk
	{273664 , "CC"},				-- Crush
	{256600 , "CC"},				-- Point Blank Blast
	{270457 , "CC"},				-- Slam
	{258371 , "CC"},				-- Crystal Gaze
	{266989 , "CC"},				-- Swooping Charge
	{258390 , "CC"},				-- Petrifying Gaze
	{275990 , "CC"},				-- Conflagrating Exhaust
	{277375 , "CC"},				-- Sucker Punch
	{278193 , "CC"},				-- Crush
	{275671 , "CC"},				-- Tremendous Roar
	{270459 , "CC"},				-- Earth Blast
	{270461 , "CC"},				-- Seismic Force
	{270463 , "CC"},				-- Jagged Slash
	{275192 , "CC"},				-- Blinding Sand
	{286907 , "CC"},				-- Volatile Eruption
	{244988 , "CC"},				-- Throw Boulder
	{244893 , "CC"},				-- Throw Boulder
	{250505 , "CC"},				-- Hysteria
	{285266 , "CC"},				-- Asphyxiate
	{285270 , "CC"},				-- Leg Sweep
	{275748 , "CC"},				-- Paralyzing Fang
	{275997 , "CC"},				-- Twilight Nova
	{270264 , "CC"},				-- Meteor
	{277161 , "CC"},				-- Shockwave
	{290764 , "CC"},				-- Dragon Roar
	{286780 , "CC"},				-- Terrifying Woof
	{276992 , "CC"},				-- Big Foot Kick
	{277111 , "CC"},				-- Serum of Torment
	{270248 , "CC"},				-- Conflagrate
	{266151 , "CC"},				-- Fire Bomb
	{265615 , "CC"},				-- Icy Charge
	{186637 , "CC"},				-- Grrlmmggr...
	{274758 , "CC"},				-- Shrink (damage done reduced by 50%)
	{277118 , "CC"},				-- Curse of Impotence (damage done reduced by 75%)
	--{262197 , "Immune"},			-- Tenacity of the Pack (unkillable but not immune to damage)
	{264115 , "Immune"},			-- Divine Shield
	{277040 , "Immune"},			-- Soul of Mist (damage taken reduced 90%)
	{265445 , "Immune"},			-- Shell Shield (damage taken reduced 75%)
	{267487 , "ImmunePhysical"},	-- Icy Reflection
	{163671 , "Immune"},			-- Ethereal
	{294375 , "CC"},				-- Spiritflame
	{275154 , "Silence"},			-- Silencing Calm
	{265723 , "Root"},				-- Web
	{274801 , "Root"},				-- Net
	{277115 , "Root"},				-- Hooked Net
	{270613 , "Root"},				-- Frost Nova
	{265584 , "Root"},				-- Frost Nova
	{270705 , "Root"},				-- Frozen Wave
	{265583 , "Root"},				-- Grasping Claw
	{278176 , "Root"},				-- Entangling Roots
	{278181 , "Root"},				-- Wrapping Vines
	{275821 , "Root"},				-- Earthen Hold
	{197720 , "Root"},				-- Elder Charge
	{288473 , "Root"},				-- Enslave
	{275052 , "Root"},				-- Shocking Reins
	{277496 , "Root"},				-- Spear Leap
	{85691  , "Snare"},				-- Piercing Howl
	{270285 , "Snare"},				-- Blast Wave
	{277870 , "Snare"},				-- Icy Venom
	{277109 , "Snare"},				-- Sticky Stomp
	{266974 , "Snare"},				-- Frostbolt
	{261962 , "Snare"},				-- Brutal Whirlwind
	{258748 , "Snare"},				-- Arctic Torrent
	{266286 , "Snare"},				-- Tendon Rip
	{270606 , "Snare"},				-- Frostbolt
	{294363 , "Snare"},				-- Spirit Chains
	{266288 , "Snare"},				-- Gnash
	{262465 , "Snare"},				-- Bug Zapper
	{267195 , "Snare"},				-- Slow
	{275038 , "Snare"},				-- Icy Claw
	{274968 , "Snare"},				-- Howl
	{273650 , "Snare"},				-- Thorn Spray
	{256661 , "Snare"},				-- Staggering Roar
	{256851 , "Snare"},				-- Vile Spew
	{179021 , "Snare"},				-- Slime
	{273124 , "Snare"},				-- Lethargic Poison
	{205187 , "Snare"},				-- Cripple
	{266158 , "Snare"},				-- Frost Bomb
	{263344 , "Snare"},				-- Subjugate
	{261095 , "Snare"},				-- Vermin Parade
	{245386 , "Other"},				-- Darkest Darkness (healing taken reduced by 99%)
	{274972 , "Other"},				-- Breath of Darkness (healing taken reduced by 75%)
},

	------------------------
	-- BfA Mythics

	-- -- Operation: Mechagon
{"Operation: Mechagon",
	{297283 , "CC"},				-- Cave In
	{294995 , "CC"},				-- Cave In
	{298259 , "CC"},				-- Gooped
	{298124 , "CC"},				-- Gooped
	{298718 , "CC"},				-- Mega Taze
	{302681 , "CC"},				-- Mega Taze
	{304452 , "CC"},				-- Mega Taze
	{296150 , "CC"},				-- Vent Blast
	{299994 , "CC"},				-- Vent Blast
	{300650 , "CC"},				-- Suffocating Smog
	{291974 , "CC"},				-- Obnoxious Monologue
	{295130 , "CC"},				-- Neutralize Threat
	{283640 , "CC"},				-- Rattled
	{282943 , "CC"},				-- Piston Smasher
	{285460 , "CC"},				-- Discom-BOMB-ulator
	{299572 , "CC"},				-- Shrink (damage and healing done reduced by 99%)
	{299707 , "CC"},				-- Trample
	{296571 , "Immune"},			-- Power Shield (damage taken reduced 99%)
	{293986 , "Silence"},			-- Sonic Pulse
	{303264 , "CC"},				-- Anti-Trespassing Field
	{296279 , "CC"},				-- Anti-Trespassing Teleport
	{300514 , "Immune"},			-- Stoneskin (damage taken reduced 75%)
	{304074 , "Immune"},			-- Stoneskin (damage taken reduced 75%)
	{295168 , "CC"},				-- Capacitor Discharge
	{295170 , "CC"},				-- Capacitor Discharge
	{295182 , "CC"},				-- Capacitor Discharge
	{295183 , "CC"},				-- Capacitor Discharge
	{300436 , "Root"},				-- Grasping Hex
	{299475 , "Snare"},				-- B.O.R.K
	{300764 , "Snare"},				-- Slimebolt
	{296560 , "Snare"},				-- Clinging Static
	{285388 , "Snare"},				-- Vent Jets
	{298602 , "Other"},				-- Smoke Cloud
	{300675 , "Other"},				-- Toxic Fog
},
	-- -- Atal'Dazar
{"Atal'Dazar",
	{255371 , "CC"},				-- Terrifying Visage
	{255041 , "CC"},				-- Terrifying Screech
	{252781 , "CC"},				-- Unstable Hex
	{279118 , "CC"},				-- Unstable Hex
	{252692 , "CC"},				-- Waylaying Jab
	{255567 , "CC"},				-- Frenzied Charge
	  {255421 , "CC"},				-- Devour (Rezan) --CHRIS
	{258653 , "Immune"},			-- Bulwark of Juju (90% damage reduction)
	{253721 , "Immune"},			-- Bulwark of Juju (90% damage reduction)
	{257483 , "Snare"},			--Pile of Bones (Rezan Boss) --CHRIS
	{250036 , "Snare"},			--Shadowy Remains (Yazma) --CHRIS
},
	-- -- Kings' Rest
{"Kings' Rest",
	{268796 , "CC"},				-- Impaling Spear
	{269369 , "CC"},				-- Deathly Roar
	{267702 , "CC"},				-- Entomb
	{271555 , "CC"},				-- Entomb
	{270920 , "CC"},				-- Seduction
	{270003 , "CC"},				-- Suppression Slam
	{270492 , "CC"},				-- Hex
	{276031 , "CC"},				-- Pit of Despair
	{267626 , "CC"},				-- Dessication (damage done reduced by 50%)
	{270931 , "Snare"},				-- Darkshot
	{270499 , "Snare"},				-- Frost Shock
  {271564 , "Snare"},				-- Embalming Fluid --CHRIS
},
	-- -- The MOTHERLODE!!
{"The MOTHERLODE!!",
	{257337 , "CC"},				-- Shocking Claw
	{257371 , "CC"},				-- Tear Gas
	{275907 , "CC"},				-- Tectonic Smash
	{280605 , "CC"},				-- Brain Freeze
	{263637 , "CC"},				-- Clothesline
	{268797 , "CC"},				-- Transmute: Enemy to Goo
	{268846 , "Silence"},			-- Echo Blade
	{267367 , "CC"},				-- Deactivated
	{278673 , "CC"},				-- Red Card
	{278644 , "CC"},				-- Slide Tackle
	{257481 , "CC"},				-- Fracking Totem
	{269278 , "CC"},				-- Panic!
	{260189 , "Immune"},			-- Configuration: Drill (damage taken reduced 99%)
	{268704 , "Snare"},				-- Furious Quake
},
	-- -- Shrine of the Storm
{"Shrine of the Storm",
	{268027 , "CC"},				-- Rising Tides
	{276268 , "CC"},				-- Heaving Blow
	{269131 , "CC"},				-- Ancient Mindbender
	{268059 , "Root"},				-- Anchor of Binding
	{269419 , "Silence"},			-- Yawning Gate
	{267956 , "CC"},				-- Zap
	{269104 , "CC"},				-- Explosive Void
	{268391 , "CC"},				-- Mental Assault
	{269289 , "CC"},				-- Disciple of the Vol'zith
	{264526 , "Root"},				-- Grasp from the Depths
	{276767 , "ImmuneSpell"},		-- Consuming Void
	{268375 , "ImmunePhysical"},	-- Detect Thoughts
	{267982 , "Snare"},			-- Protective Gaze (damage taken reduced 75%) --CHRIS
	{268212 , "Snare"},			-- Minor Reinforcing Ward (damage taken reduced 75%) --CHRIS
	{268186 , "Snare"},			-- Reinforcing Ward (damage taken reduced 75%) --CHRIS
	{267904 , "Snare"},			-- Reinforcing Ward (damage taken reduced 75%) --CHRIS
	{267901 , "Snare"},				-- Blessing of Ironsides
	{274631 , "Snare"},				-- Lesser Blessing of Ironsides
	{267899 , "Snare"},				-- Hindering Cleave
	{268896 , "Snare"},				-- Mind Rend
	{264560 , "Snare"},				-- Choking Brine --CHRIS
},
	-- -- Temple of Sethraliss
{"Temple of Sethraliss",
	{280032 , "CC"},				-- Neurotoxin
	{268993 , "CC"},				-- Cheap Shot
	{268008 , "CC"},				-- Snake Charm
	{263958 , "CC"},				-- A Knot of Snakes
	{269970 , "CC"},				-- Blinding Sand
	{256333 , "CC"},				-- Dust Cloud (0% chance to hit)
	{260792 , "CC"},				-- Dust Cloud (0% chance to hit)
	{269670 , "Immune"},			-- Empowerment (90% damage reduction)
	{261635 , "Immune"},			-- Stoneshield Potion
	{273274 , "Snare"},				-- Polarized Field
	{275566 , "Snare"},				-- Numb Hands
},
	-- -- Waycrest Manor
{"Waycrest Manor",
	{265407 , "Silence"},			-- Dinner Bell
	{263891 , "CC"},				-- Grasping Thorns
	{260900 , "CC"},				-- Soul Manipulation
	{260926 , "CC"},				-- Soul Manipulation
	{265352 , "CC"},				-- Toad Blight
	{264390 , "Silence"},			-- Spellbind
	{278468 , "CC"},				-- Freezing Trap
	{267907 , "CC"},				-- Soul Thorns
	{265346 , "CC"},				-- Pallid Glare
	{268202 , "CC"},				-- Death Lens
	{261265 , "Immune"},			-- Ironbark Shield (99% damage reduction)
	{261266 , "Immune"},			-- Runic Ward (99% damage reduction)
	{261264 , "Immune"},			-- Soul Armor (99% damage reduction)
	{271590 , "Immune"},			-- Soul Armor (99% damage reduction)
	{260923 , "Immune"},			-- Soul Manipulation (99% damage reduction)
	{264027 , "Other"},				-- Warding Candles (50% damage reduction)
	{264040 , "Snare"},				-- Uprooted Thorns
	{264712 , "Snare"},				-- Rotten Expulsion
	{261440 , "Snare"},				-- Virulent Pathogen
},
	-- -- Tol Dagor
{"Tol Dagor",
	{258058 , "Root"},				-- Squeeze
	{259711 , "Root"},				-- Lockdown
	{258313 , "CC"},				-- Handcuff (Pacified and Silenced)
	{260067 , "CC"},				-- Vicious Mauling
	{257791 , "CC"},				-- Howling Fear
	{257793 , "CC"},				-- Smoke Powder
	{257119 , "CC"},				-- Sand Trap
	{256474 , "CC"},				-- Heartstopper Venom
	{258128 , "CC"},				-- Debilitating Shout (damage done reduced by 50%)
	{258317 , "ImmuneSpell"},		-- Riot Shield (-75% spell damage and redirect spells to the caster)
	{258153 , "Immune"},			-- Watery Dome (75% damage redictopm)
	{265271 , "Snare"},				-- Sewer Slime
	{257777 , "Snare"},				-- Crippling Shiv
	{259188 , "Snare"},				-- Heavily Armed
},
	-- -- Freehold
{"Freehold",
	{274516 , "CC"},				-- Slippery Suds
	{257949 , "CC"},				-- Slippery
	{258875 , "CC"},				-- Blackout Barrel
	{274400 , "CC"},				-- Duelist Dash
	{274389 , "Root"},				-- Rat Traps
	{276061 , "CC"},				-- Boulder Throw
	{258182 , "CC"},				-- Boulder Throw
	{268283 , "CC"},				-- Obscured Vision (hit chance decreased 75%)
	{257274 , "Snare"},				-- Vile Coating
	{257478 , "Snare"},				-- Crippling Bite
	{257747 , "Snare"},				-- Earth Shaker
	{257784 , "Snare"},				-- Frost Blast
	{272554 , "Snare"},				-- Bloody Mess
},
	-- -- Siege of Boralus
{"Siege of Boralus",
	{256957 , "Immune"},			-- Watertight Shell
	{257069 , "CC"},				-- Watertight Shell
	{261428 , "CC"},				-- Hangman's Noose
	{257292 , "CC"},				-- Heavy Slash
	{272874 , "CC"},				-- Trample
	{257169 , "CC"},				-- Terrifying Roar
	{274942 , "CC"},				-- Banana Rampage
	{272571 , "Silence"},			-- Choking Waters
	{275826 , "Immune"},			-- Bolstering Shout (damage taken reduced 75%)
	{270624 , "Root"},				-- Crushing Embrace
	{256897 , "Root"},				-- Clamping-Jaws --CHRIS
	{272834 , "Snare"},				-- Viscous Slobber
},
	-- -- The Underrot
{"The Underrot",
	{265377 , "Root"},				-- Hooked Snare
	{272609 , "CC"},				-- Maddening Gaze
	{265511 , "CC"},				-- Spirit Drain
	{278961 , "CC"},				-- Decaying Mind
	{269406 , "CC"},				-- Purge Corruption
	{258347 , "Silence"},			-- Sonic Screech
},

	------------------------
	---- PVE LEGION
	------------------------
	-- EN Raid
{"EN Raid",
	-- -- Trash
	{223914 , "CC"},				-- Intimidating Roar
	{225249 , "CC"},				-- Devastating Stomp
	{225073 , "Root"},				-- Despoiling Roots
	{222719 , "Root"},				-- Befoulment
	-- -- Nythendra
	{205043 , "CC"},				-- Infested Mind (Nythendra)
	-- -- Ursoc
	{197980 , "CC"},				-- Nightmarish Cacophony (Ursoc)
	-- -- Dragons of Nightmare
	{205341 , "CC"},				-- Seeping Fog (Dragons of Nightmare)
	{225356 , "CC"},				-- Seeping Fog (Dragons of Nightmare)
	{203110 , "CC"},				-- Slumbering Nightmare (Dragons of Nightmare)
	{204078 , "CC"},				-- Bellowing Roar (Dragons of Nightmare)
	{203770 , "Root"},				-- Defiled Vines (Dragons of Nightmare)
	-- -- Il'gynoth
	{212886 , "CC"},				-- Nightmare Corruption (Il'gynoth)
	-- -- Cenarius
	{210315 , "Root"},				-- Nightmare Brambles (Cenarius)
	{214505 , "CC"},				-- Entangling Nightmares (Cenarius)
	------------------------
},
	-- ToV Raid
{" ToV Raid",
	-- -- Trash
	{228609 , "CC"},				-- Bone Chilling Scream
	{228883 , "CC"},				-- Unholy Reckoning
	{228869 , "CC"},				-- Crashing Waves
	-- -- Odyn
	{228018 , "Immune"},			-- Valarjar's Bond (Odyn)
	{229529 , "Immune"},			-- Valarjar's Bond (Odyn)
	{227781 , "CC"},				-- Glowing Fragment (Odyn)
	{227594 , "Immune"},			-- Runic Shield (Odyn)
	{227595 , "Immune"},			-- Runic Shield (Odyn)
	{227596 , "Immune"},			-- Runic Shield (Odyn)
	{227597 , "Immune"},			-- Runic Shield (Odyn)
	{227598 , "Immune"},			-- Runic Shield (Odyn)
	-- -- Guarm
	{228248 , "CC"},				-- Frost Lick (Guarm)
	-- -- Helya
	{232350 , "CC"},				-- Corrupted (Helya)
	------------------------
},

{"NH Raid",
	-- NH Raid
	-- -- Trash
	{225583 , "CC"},				-- Arcanic Release
	{225803 , "Silence"},			-- Sealed Magic
	{224483 , "CC"},				-- Slam
	{224944 , "CC"},				-- Will of the Legion
	{224568 , "CC"},				-- Mass Suppress
	{221524 , "Immune"},			-- Protect (not immune}, 90% less dmg)
	{226231 , "Immune"},			-- Faint Hope
	{230377 , "CC"},				-- Wailing Bolt
	-- -- Skorpyron
	{204483 , "CC"},				-- Focused Blast (Skorpyron)
	-- -- Spellblade Aluriel
	{213621 , "CC"},				-- Entombed in Ice (Spellblade Aluriel)
	-- -- Tichondrius
	{215988 , "CC"},				-- Carrion Nightmare (Tichondrius)
	-- -- High Botanist Tel'arn
	{218304 , "Root"},				-- Parasitic Fetter (Botanist)
	-- -- Star Augur
	{206603 , "CC"},				-- Frozen Solid (Star Augur)
	{216697 , "CC"},				-- Frigid Pulse (Star Augur)
	{207720 , "CC"},				-- Witness the Void (Star Augur)
	{207714 , "Immune"},			-- Void Shift (-99% dmg taken) (Star Augur)
	-- -- Gul'dan
	{206366 , "CC"},				-- Empowered Bonds of Fel (Knockback Stun) (Gul'dan)
	{206983 , "CC"},				-- Shadowy Gaze (Gul'dan)
	{208835 , "CC"},				-- Distortion Aura (Gul'dan)
	{208671 , "CC"},				-- Carrion Wave (Gul'dan)
	{229951 , "CC"},				-- Fel Obelisk (Gul'dan)
	{206841 , "CC"},				-- Fel Obelisk (Gul'dan)
	{227749 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{227750 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{227743 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{227745 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{227427 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{227320 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	{206516 , "Immune"},			-- The Eye of Aman'Thul (Gul'dan)
	------------------------
},
	-- ToS Raid
{"ToS Raid",
	-- -- Trash
	{243298 , "CC"},				-- Lash of Domination
	{240706 , "CC"},				-- Arcane Ward
	{240737 , "CC"},				-- Polymorph Bomb
	{239810 , "CC"},				-- Sever Soul
	{240592 , "CC"},				-- Serpent Rush
	{240169 , "CC"},				-- Electric Shock
	{241234 , "CC"},				-- Darkening Shot
	{241009 , "CC"},				-- Power Drain (-90% damage)
	{241254 , "CC"},				-- Frost-Fingered Fear
	{241276 , "CC"},				-- Icy Tomb
	{241348 , "CC"},				-- Deafening Wail
	-- -- Demonic Inquisition
	{233430 , "CC"},				-- Unbearable Torment (Demonic Inquisition) (no CC}, -90% dmg}, -25% heal}, +90% dmg taken)
	-- -- Harjatan
	{240315 , "Immune"},			-- Hardened Shell (Harjatan)
	-- -- Sisters of the Moon
	{237351 , "Silence"},			-- Lunar Barrage (Sisters of the Moon)
	-- -- Mistress Sassz'ine
	{234332 , "CC"},				-- Hydra Acid (Mistress Sassz'ine)
	{230362 , "CC"},				-- Thundering Shock (Mistress Sassz'ine)
	{230959 , "CC"},				-- Concealing Murk (Mistress Sassz'ine) (no CC}, hit chance reduced 75%)
	-- -- The Desolate Host
	{236241 , "CC"},				-- Soul Rot (The Desolate Host) (no CC}, dmg dealt reduced 75%)
	{236011 , "Silence"},			-- Tormented Cries (The Desolate Host)
	{236513 , "Immune"},			-- Bonecage Armor (The Desolate Host) (75% dmg reduction)
	-- -- Maiden of Vigilance
	{248812 , "CC"},				-- Blowback (Maiden of Vigilance)
	{233739 , "CC"},				-- Malfunction (Maiden of Vigilance
	-- -- Kil'jaeden
	{245332 , "Immune"},			-- Nether Shift (Kil'jaeden)
	{244834 , "Immune"},			-- Nether Gale (Kil'jaeden)
	{236602 , "CC"},				-- Soul Anguish (Kil'jaeden)
	{236555 , "CC"},				-- Deceiver's Veil (Kil'jaeden)
},

	------------------------
	-- Antorus Raid
	-- -- Trash
{" Antorus Raid",
	{246209 , "CC"},				-- Punishing Flame
	{254502 , "CC"},				-- Fearsome Leap
	{254125 , "CC"},				-- Cloud of Confusion
	-- -- Garothi Worldbreaker
	{246920 , "CC"},				-- Haywire Decimation
	-- -- Hounds of Sargeras
	{244086 , "CC"},				-- Molten Touch
	{244072 , "CC"},				-- Molten Touch
	{249227 , "CC"},				-- Molten Touch
	{249241 , "CC"},				-- Molten Touch
	{244071 , "CC"},				-- Weight of Darkness
	-- -- War Council
	{244748 , "CC"},				-- Shocked
	-- -- Portal Keeper Hasabel
	{246208 , "Root"},				-- Acidic Web
	{244949 , "CC"},				-- Felsilk Wrap
	-- -- Imonar the Soulhunter
	{247641 , "CC"},				-- Stasis Trap
	{255029 , "CC"},				-- Sleep Canister
	{247565 , "CC"},				-- Slumber Gas
	{250135 , "Immune"},			-- Conflagration (-99% damage taken)
	{248233 , "Immune"},			-- Conflagration (-99% damage taken)
	-- -- Kin'garoth
	{246516 , "Immune"},			-- Apocalypse Protocol (-99% damage taken)
	-- -- The Coven of Shivarra
	{253203 , "Immune"},			-- Shivan Pact (-99% damage taken)
	{249863 , "Immune"},			-- Visage of the Titan
	{256356 , "CC"},				-- Chilled Blood
	-- -- Aggramar
	{244894 , "Immune"},			-- Corrupt Aegis
	{246014 , "CC"},				-- Searing Tempest
	{255062 , "CC"},				-- Empowered Searing Tempest
},
	------------------------
	-- The Deaths of Chromie Scenario
{"The Deaths of Chromie Scenario",
	{246941 , "CC"},				-- Looming Shadows
	{245167 , "CC"},				-- Ignite
	{248839 , "CC"},				-- Charge
	{246211 , "CC"},				-- Shriek of the Graveborn
	{247683 , "Root"},				-- Deep Freeze
	{247684 , "CC"},				-- Deep Freeze
	{244959 , "CC"},				-- Time Stop
	{248516 , "CC"},				-- Sleep
	{245169 , "Immune"},			-- Reflective Shield
	{248716 , "CC"},				-- Infernal Strike
	{247730 , "Root"},				-- Faith's Fetters
	{245822 , "CC"},				-- Inescapable Nightmare
	{245126 , "Silence"},			-- Soul Burn
},


	------------------------
	-- Legion Mythics
	-- -- The Arcway
{"he Arcway",
	{195804 , "CC"},				-- Quarantine
	{203649 , "CC"},				-- Exterminate
	{203957 , "CC"},				-- Time Lock
	{211543 , "Root"},				-- Devour
},
	-- -- Black Rook Hold
{"Black Rook Hold",
	{194960 , "CC"},				-- Soul Echoes
	{197974 , "CC"},				-- Bonecrushing Strike
	{199168 , "CC"},				-- Itchy!
	{204954 , "CC"},				-- Cloud of Hypnosis
	{199141 , "CC"},				-- Cloud of Hypnosis
	{199097 , "CC"},				-- Cloud of Hypnosis
	{214002 , "CC"},				-- Raven's Dive
	{200261 , "CC"},				-- Bonebreaking Strike
	{201070 , "CC"},				-- Dizzy
	{221117 , "CC"},				-- Ghastly Wail
	{222417 , "CC"},				-- Boulder Crush
	{221838 , "CC"},				-- Disorienting Gas
},
	-- -- Court of Stars
{"- Court of Stars",
	{207278 , "Snare"},				-- Arcane Lockdown
	{207261 , "CC"},				-- Resonant Slash
	{215204 , "CC"},				-- Hinder
	{207979 , "CC"},				-- Shockwave
	{224333 , "CC"},				-- Enveloping Winds
	{209404 , "Silence"},			-- Seal Magic
	{209413 , "Silence"},			-- Suppress
	{209027 , "CC"},				-- Quelling Strike
	{212773 , "CC"},				-- Subdue
	{216000 , "CC"},				-- Mighty Stomp
	{213233 , "CC"},				-- Uninvited Guest
},
	-- -- Return to Karazhan
{"Return to Karazhan",
	{227567 , "CC"},				-- Knocked Down
	{228215 , "CC"},				-- Severe Dusting
	{227508 , "CC"},				-- Mass Repentance
	{227545 , "CC"},				-- Mana Drain
	{227909 , "CC"},				-- Ghost Trap
	{228693 , "CC"},				-- Ghost Trap
	{228837 , "CC"},				-- Bellowing Roar
	{227592 , "CC"},				-- Frostbite
	{228239 , "CC"},				-- Terrifying Wail
	{241774 , "CC"},				-- Shield Smash
	{230122 , "Silence"},			-- Garrote - Silence
	{39331  , "Silence"},			-- Game In Session
	{227977 , "CC"},				-- Flashlight
	{241799 , "CC"},				-- Seduction
	{227917 , "CC"},				-- Poetry Slam
	{230083 , "CC"},				-- Nullification
	{229489 , "Immune"},			-- Royalty (90% dmg reduction)
},
	-- -- Maw of Souls
{" Maw of Souls",
	{193364 , "CC"},				-- Screams of the Dead
	{198551 , "CC"},				-- Fragment
	{197653 , "CC"},				-- Knockdown
	{198405 , "CC"},				-- Bone Chilling Scream
	{193215 , "CC"},				-- Kvaldir Cage
	{204057 , "CC"},				-- Kvaldir Cage
	{204058 , "CC"},				-- Kvaldir Cage
	{204059 , "CC"},				-- Kvaldir Cage
	{204060 , "CC"},				-- Kvaldir Cage
},
	-- -- Vault of the Wardens
{" Vault of the Wardens",
	{202455 , "Immune"},			-- Void Shield
	{212565 , "CC"},				-- Inquisitive Stare
	{225416 , "CC"},				-- Intercept
	{6726   , "Silence"},			-- Silence
	{201488 , "CC"},				-- Frightening Shout
	{203774 , "Immune"},			-- Focusing
	{192517 , "CC"},				-- Brittle
	{201523 , "CC"},				-- Brittle
	{194323 , "CC"},				-- Petrified
	{206387 , "CC"},				-- Steal Light
	{197422 , "Immune"},			-- Creeping Doom
	{210138 , "CC"},				-- Fully Petrified
	{202615 , "Root"},				-- Torment
	{193069 , "CC"},				-- Nightmares
	{191743 , "Silence"},			-- Deafening Screech
	{202658 , "CC"},				-- Drain
	{193969 , "Root"},				-- Razors
	{204282 , "CC"},				-- Dark Trap
},
	-- -- Eye of Azshara
{"Eye of Azshara",
	{191975 , "CC"},				-- Impaling Spear
	{191977 , "CC"},				-- Impaling Spear
	{193597 , "CC"},				-- Static Nova
	{192708 , "CC"},				-- Arcane Bomb
	{195561 , "CC"},				-- Blinding Peck
	{195129 , "CC"},				-- Thundering Stomp
	{195253 , "CC"},				-- Imprisoning Bubble
	{197144 , "Root"},				-- Hooked Net
	{197105 , "CC"},				-- Polymorph: Fish
	{195944 , "CC"},				-- Rising Fury
},
	-- -- Darkheart Thicket
{" Darkheart Thicket",
	{200329 , "CC"},				-- Overwhelming Terror
	{200273 , "CC"},				-- Cowardice
	{204246 , "CC"},				-- Tormenting Fear
	{200631 , "CC"},				-- Unnerving Screech
	{200771 , "CC"},				-- Propelling Charge
	{199063 , "Root"},				-- Strangling Roots
},
	-- -- Halls of Valor
{"Halls of Valor",
	{198088 , "CC"},				-- Glowing Fragment
	{215429 , "CC"},				-- Thunderstrike
	{199340 , "CC"},				-- Bear Trap
	{210749 , "CC"},				-- Static Storm
},
	-- -- Neltharion's Lair
{"Neltharion's Lair",
	{200672 , "CC"},				-- Crystal Cracked
	{202181 , "CC"},				-- Stone Gaze
	{193585 , "CC"},				-- Bound
	{186616 , "CC"},				-- Petrified
},
	-- -- Cathedral of Eternal Night
{"Cathedral of Eternal Night",
	{238678 , "Silence"},			-- Stifling Satire
	{238484 , "CC"},				-- Beguiling Biography
	{242724 , "CC"},				-- Dread Scream
	{239217 , "CC"},				-- Blinding Glare
	{238583 , "Silence"},			-- Devour Magic
	{239156 , "CC"},				-- Book of Eternal Winter
	{240556 , "Silence"},			-- Tome of Everlasting Silence
	{242792 , "CC"},				-- Vile Roots
},
	-- -- The Seat of the Triumvirate
{"The Seat of the Triumvirate",
	{246913 , "Immune"},			-- Void Phased
	{244621 , "CC"},				-- Void Tear
	{248831 , "CC"},				-- Dread Screech
	{246026 , "CC"},				-- Void Trap
	{245278 , "CC"},				-- Void Trap
	{244751 , "CC"},				-- Howling Dark
	{248804 , "Immune"},			-- Dark Bulwark
	{247816 , "CC"},				-- Backlash
	{254020 , "Immune"},			-- Darkened Shroud
	{253952 , "CC"},				-- Terrifying Howl
	{248298 , "Silence"},			-- Screech
	{245706 , "CC"},				-- Ruinous Strike
	{248133 , "CC"},				-- Stygian Blast
},
	------------------------
	---- PVE CLASSIC
	------------------------
	-- Molten Core Raid
	-- -- Trash
{"Molten Core Raid",
	{19364  , "CC"},				-- Ground Stomp
	{19369  , "CC"},				-- Ancient Despair
	{19641  , "CC"},				-- Pyroclast Barrage
	{20276  , "CC"},				-- Knockdown
	{19393  , "Silence"},			-- Soul Burn
	{19636  , "Root"},				-- Fire Blossom
	-- -- Lucifron
	{20604  , "CC"},				-- Dominate Mind
	-- -- Magmadar
	{19408  , "CC"},				-- Panic
	-- -- Gehennas
	{20277  , "CC"},				-- Fist of Ragnaros
	{19716  , "Other"},				-- Gehennas' Curse
	-- -- Garr
	{19496  , "Snare"},				-- Magma Shackles
	-- -- Shazzrah
	{19714  , "ImmuneSpell"},		-- Deaden Magic (not immune}, 50% Magic damage reduction)
	-- -- Golemagg the Incinerator
	{19820  , "Snare"},				-- Mangle
	{22689  , "Snare"},				-- Mangle
	-- -- Sulfuron Harbinger
	{19780  , "CC"},				-- Hand of Ragnaros
	-- -- Majordomo Executus
	{20619  , "ImmuneSpell"},		-- Magic Reflection (not immune}, 50% chance reflect spells)
	{20229  , "Snare"},				-- Blast Wave
	------------------------
	-- Onyxia's Lair Raid
	-- -- Onyxia
	{18431  , "CC"},				-- Bellowing Roar
},
	------------------------
	-- Blackwing Lair Raid
{"Blackwing Lair Raid",
	-- -- Trash
	{24375  , "CC"},				-- War Stomp
	{22289  , "CC"},				-- Brood Power: Green
	{22291  , "CC"},				-- Brood Power: Bronze
	{22561  , "CC"},				-- Brood Power: Green
	{22247  , "Snare"},				-- Suppression Aura
	{22424  , "Snare"},				-- Blast Wave
	{15548  , "Snare"},				-- Thunderclap
	-- -- Razorgore the Untamed
	{19872  , "CC"},				-- Calm Dragonkin
	{23023  , "CC"},				-- Conflagration
	{15593  , "CC"},				-- War Stomp
	{16740  , "CC"},				-- War Stomp
	{27758  , "CC"},				-- War Stomp
	{28725  , "CC"},				-- War Stomp
	{14515  , "CC"},				-- Dominate Mind
	{22274  , "CC"},				-- Greater Polymorph
	{13747  , "Snare"},				-- Slow
	-- -- Broodlord Lashlayer
	{23331  , "Snare"},				-- Blast Wave
	{25049  , "Snare"},				-- Blast Wave
	-- -- Chromaggus
	{23310  , "CC"},				-- Time Lapse
	{23312  , "CC"},				-- Time Lapse
	{23174  , "CC"},				-- Chromatic Mutation
	{23171  , "CC"},				-- Time Stop (Brood Affliction: Bronze)
	{23153  , "Snare"},				-- Brood Affliction: Blue
	{23169  , "Other"},				-- Brood Affliction: Green
	-- -- Nefarian
	{22666  , "Silence"},			-- Silence
	{22667  , "CC"},				-- Shadow Command
	{22663  , "Immune"},			-- Nefarian's Barrier
	{22686  , "CC"},				-- Bellowing Roar
	{39427  , "CC"},				-- Bellowing Roar
	{22678  , "CC"},				-- Fear
	{23603  , "CC"},				-- Wild Polymorph
	{23364  , "CC"},				-- Tail Lash
	{23365  , "Disarm"},			-- Dropped Weapon
	{23415  , "ImmunePhysical"},	-- Improved Blessing of Protection
	{23414  , "Root"},				-- Paralyze
	{22687  , "Other"},				-- Veil of Shadow
},
	------------------------
	-- Zul'Gurub Raid
{"Zul'Gurub Raid",
	-- -- Trash
	{24619  , "Silence"},			-- Soul Tap
	{24048  , "CC"},				-- Whirling Trip
	{24600  , "CC"},				-- Web Spin
	{24335  , "CC"},				-- Wyvern Sting
	{24020  , "CC"},				-- Axe Flurry
	{24671  , "CC"},				-- Snap Kick
	{24333  , "CC"},				-- Ravage
	{6869   , "CC"},				-- Fall down
	{24053  , "CC"},				-- Hex
	{24021  , "ImmuneSpell"},		-- Anti-Magic Shield
	{24674  , "Other"},				-- Veil of Shadow
	{24002  , "Snare"},				-- Tranquilizing Poison
	{24003  , "Snare"},				-- Tranquilizing Poison
	-- -- High Priestess Jeklik
	{23918  , "Silence"},			-- Sonic Burst
	{22884  , "CC"},				-- Psychic Scream
	{22911  , "CC"},				-- Charge
	{23919  , "CC"},				-- Swoop
	{26044  , "CC"},				-- Mind Flay
	-- -- High Priestess Mar'li
	{24110  , "Silence"},			-- Enveloping Webs
	-- -- High Priest Thekal
	--{22666  , "Silence"},			-- Silence
	{21060  , "CC"},				-- Blind
	{12540  , "CC"},				-- Gouge
	{22691  , "Disarm"},			-- Disarm
	{24193  , "CC"},				-- Charge
	-- -- Bloodlord Mandokir & Ohgan
	{24408  , "CC"},				-- Charge
	{25821  , "CC"},				-- Charge
	-- -- Gahz'ranka
	{16099  , "Snare"},				-- Frost Breath
	-- -- Jin'do the Hexxer
	{17172  , "CC"},				-- Hex
	{24261  , "CC"},				-- Brain Wash
	-- -- Edge of Madness: Gri'lek}, Hazza'rah}, Renataki}, Wushoolay
	{24648  , "Root"},				-- Entangling Roots
	{24664  , "CC"},				-- Sleep
	-- -- Hakkar
	{24687  , "Silence"},			-- Aspect of Jeklik
	{24686  , "CC"},				-- Aspect of Mar'li
	{24690  , "CC"},				-- Aspect of Arlokk
	{24327  , "CC"},				-- Cause Insanity
	{24178  , "CC"},				-- Will of Hakkar
	{24322  , "CC"},				-- Blood Siphon
	{24323  , "CC"},				-- Blood Siphon
	{24324  , "CC"},				-- Blood Siphon
},
	------------------------
	-- Ruins of Ahn'Qiraj Raid
{"Ruins of Ahn'Qiraj Raid",
	-- -- Trash
	{25371  , "CC"},				-- Consume
	{25654  , "CC"},				-- Tail Lash
	--{3589   , "Silence"},			-- Deafening Screech
	--{12252  , "Root"},			-- Web Spray
	{25515  , "CC"},				-- Bash
	{25187  , "Snare"},				-- Hive'Zara Catalyst
	-- -- Kurinnaxx
	{25656  , "CC"},				-- Sand Trap
	-- -- General Rajaxx
	{19134  , "CC"},				-- Intimidating Shout
	{29544  , "CC"},				-- Intimidating Shout
	{25425  , "CC"},				-- Shockwave
	{25282  , "Immune"},			-- Shield of Rajaxx
	-- -- Moam
	{25685  , "CC"},				-- Energize
	-- -- Ayamiss the Hunter
	{25852  , "CC"},				-- Lash
	{6608   , "Disarm"},			-- Dropped Weapon
	{25725  , "CC"},				-- Paralyze
	-- -- Ossirian the Unscarred
	{25189  , "CC"},				-- Enveloping Winds
},
	------------------------
	-- Temple of Ahn'Qiraj Raid
{"Temple of Ahn'Qiraj Raid",
	-- -- Trash
	{18327  , "Silence"},			-- Silence
	{26069  , "Silence"},			-- Silence
	{26070  , "CC"},				-- Fear
	{26072  , "CC"},				-- Dust Cloud
	{25698  , "CC"},				-- Explode
	{26079  , "CC"},				-- Cause Insanity
	{26049  , "CC"},				-- Mana Burn
	{26071  , "Root"},				-- Entangling Roots
	--{13022  , "ImmuneSpell"},		-- Fire and Arcane Reflect (only reflect fire and arcane spells)
	--{19595  , "ImmuneSpell"},		-- Shadow and Frost Reflect (only reflect shadow and frost spells)
	{1906   , "Snare"},				-- Debilitating Charge
	{25809  , "Snare"},				-- Crippling Poison
	{26078  , "Snare"},				-- Vekniss Catalyst
	-- -- The Prophet Skeram
	{785    , "CC"},				-- True Fulfillment
	-- -- Bug Trio: Yauj}, Vem}, Kri
	{3242   , "CC"},				-- Ravage
	{26580  , "CC"},				-- Fear
	{19128  , "CC"},				-- Knockdown
	{25989  , "Snare"},				-- Toxin
	-- -- Fankriss the Unyielding
	{720    , "CC"},				-- Entangle
	{731    , "CC"},				-- Entangle
	{1121   , "CC"},				-- Entangle
	-- -- Viscidus
	{25937  , "CC"},				-- Viscidus Freeze
	-- -- Princess Huhuran
	{26180  , "CC"},				-- Wyvern Sting
	{26053  , "Silence"},			-- Noxious Poison
	-- -- Twin Emperors: Vek'lor & Vek'nilash
	{800    , "CC"},				-- Twin Teleport
	{804    , "Root"},				-- Explode Bug
	{568    , "Snare"},				-- Arcane Burst
	-- -- Ouro
	{26102  , "CC"},				-- Sand Blast
	-- -- C'Thun
	{23953  , "Snare"},				-- Mind Flay
	{26211  , "Snare"},				-- Hamstring
	{26141  , "Snare"},				-- Hamstring
},
	------------------------
	-- Classic World Bosses
{"Classic World Bosses",
	-- -- Azuregos
	{23186  , "CC"},				-- Aura of Frost
	{243901 , "CC"},				-- Mark of Frost
	{21099  , "CC"},				-- Frost Breath
	{22067  , "ImmuneSpell"},		-- Reflection
	{27564  , "ImmuneSpell"},		-- Reflection
	{243835 , "ImmuneSpell"},		-- Reflection
	{21098  , "Snare"},				-- Chill
	-- -- Doom Lord Kazzak & Highlord Kruul
	{8078   , "Snare"},				-- Thunderclap
	{23931  , "Snare"},				-- Thunderclap
	-- -- Dragons of Nightmare
	{25043  , "CC"},				-- Aura of Nature
	{24778  , "CC"},				-- Sleep (Dream Fog)
	{24811  , "CC"},				-- Draw Spirit
	{25806  , "CC"},				-- Creature of Nightmare
	{12528  , "Silence"},			-- Silence
	{23207  , "Silence"},			-- Silence
	{29943  , "Silence"},			-- Silence
	{30225  , "Silence"},			-- Silence
},
	------------------------
	-- Classic Dungeons
	-- -- Ragefire Chasm
{"Ragefire Chasm",
	{8242   , "CC"},				-- Shield Slam
},
	-- -- The Deadmines
{"The Deadmines",
	{6304   , "CC"},				-- Rhahk'Zor Slam
	{6713   , "Disarm"},			-- Disarm
	{7399   , "CC"},				-- Terrify
	{5213   , "Snare"},				-- Molten Metal
	{6435   , "CC"},				-- Smite Slam
	{6432   , "CC"},				-- Smite Stomp
	{6264   , "Other"},				-- Nimble Reflexes (chance to parry increased by 75%)
	{113    , "Root"},				-- Chains of Ice
	{5159   , "Snare"},				-- Melt Ore
	{228    , "CC"},				-- Polymorph: Chicken
	{6466   , "CC"},				-- Axe Toss
	{92614  , "Immune"},			-- Deflection
	{88348  , "CC"},				-- Off-line
	{91732  , "CC"},				-- Off-line
	{92100  , "CC"},				-- Noxious Concoction
	{88836  , "CC"},				-- Go For the Throat
	{87901  , "Snare"},				-- Fists of Frost
	{88177  , "Snare"},				-- Frost Blossom
	{88288  , "CC"},				-- Charge
	{91726  , "CC"},				-- Reaper Charge
	{90958  , "Other"},				-- Evasion
	{95491  , "CC"},				-- Cannonball
	{135337 , "CC"},				-- Cannonball
	{89769  , "CC"},				-- Explode
	{55041  , "CC"},				-- Freezing Trap Effect
},
	-- -- Wailing Caverns
{"Wailing Caverns",
	{8040   , "CC"},				-- Druid's Slumber
	{8147   , "Snare"},				-- Thunderclap
	{8142   , "Root"},				-- Grasping Vines
	{5164   , "CC"},				-- Knockdown
	{7967   , "CC"},				-- Naralex's Nightmare
	{8150   , "CC"},				-- Thundercrack
},
	-- -- Shadowfang Keep
{"Shadowfang Keep",
	{7295   , "Root"},				-- Soul Drain
	{7139   , "CC"},				-- Fel Stomp
	{13005  , "CC"},				-- Hammer of Justice
	{9080   , "Snare"},				-- Hamstring
	{7621   , "CC"},				-- Arugal's Curse
	{7068   , "Other"},				-- Veil of Shadow
	{23224  , "Other"},				-- Veil of Shadow
	{28440  , "Other"},				-- Veil of Shadow
	{7803   , "CC"},				-- Thundershock
	{7074   , "Silence"},			-- Screams of the Past
	{93956  , "Other"},				-- Cursed Veil
	{67781  , "Snare"},				-- Desecration
	{93691  , "Snare"},				-- Desecration
	{196178 , "Snare"},				-- Desecration
	{93697  , "Snare"},				-- Conjure Poisonous Mixture
	{91220  , "CC"},				-- Cowering Roar
	{93423  , "CC"},				-- Asphyxiate
	{30615  , "CC"},				-- Fear
	{15497  , "Snare"},				-- Frostbolt
	{93930  , "CC"},				-- Spectral Ravaging
	{93863  , "Root"},				-- Soul Drain
	{29321  , "CC"},				-- Fear
},
	-- -- Blackfathom Deeps
{" Blackfathom Deeps",
	{246    , "Snare"},				-- Slow
	{15531  , "Root"},				-- Frost Nova
	{6533   , "Root"},				-- Net
	{8399   , "CC"},				-- Sleep
	{8379   , "Disarm"},			-- Disarm
	{18972  , "Snare"},				-- Slow
	{9672   , "Snare"},				-- Frostbolt
	{8398   , "Snare"},				-- Frostbolt Volley
	{8391   , "CC"},				-- Ravage
	{7645   , "CC"},				-- Dominate Mind
	{15043  , "Snare"},				-- Frostbolt
	{151963 , "CC"},				-- Crush
	{150660 , "CC"},				-- Crush
	{152417 , "CC"},				-- Crush
	{149955 , "CC"},				-- Devouring Blackness
	{150634 , "CC"},				-- Leviathan's Grip
	{5424   , "Root"},				-- Claw Grasp
	{149910 , "Root"},				-- Catch of the Day
	{302956 , "Root"},				-- Catch of the Day
},
	-- -- The Stockade
{"The Stockade",
	{3419   , "Other"},				-- Improved Blocking
	--{19134  , "CC"},				-- Intimidating Shout
	--{29544  , "CC"},				-- Intimidating Shout
	{6253   , "CC"},				-- Backhand
	{204735 , "Snare"},				-- Frostbolt
	{86740  , "CC"},				-- Dirty Blow
	{86814  , "CC"},				-- Bash Head
},
	-- -- Gnomeregan
{"Gnomeregan",
	{10831  , "ImmuneSpell"},		-- Reflection Field
	{11820  , "Root"},				-- Electrified Net
	{10852  , "Root"},				-- Battle Net
	{10734  , "Snare"},				-- Hail Storm
	{11264  , "Root"},				-- Ice Blast
	{10730  , "CC"},				-- Pacify
	{74720  , "CC"},				-- Pound
},
	-- -- Razorfen Kraul
{"Razorfen Kraul",
	{8281   , "Silence"},			-- Sonic Burst
	{39052  , "Silence"},			-- Sonic Burst
	{8359   , "CC"},				-- Left for Dead
	{8285   , "CC"},				-- Rampage
	{8361   , "Immune"},			-- Purity
	{6984   , "Snare"},				-- Frost Shot
	{18802  , "Snare"},				-- Frost Shot
	{6728   , "CC"},				-- Enveloping Winds
	{3248   , "Other"},				-- Improved Blocking
	{151583 , "Root"},				-- Elemental Binding
	{286963 , "CC"},				-- Elemental Binding
	{153550 , "Silence"},			-- Solarshard Beam
	{150357 , "Silence"},			-- Solarshard Beam
	{150859 , "Snare"},				-- Wing Clip
	{153214 , "CC"},				-- Sonic Charge
	{150651 , "Root"},				-- Vine Line
	{150304 , "Root"},				-- Vine Line
},
	-- -- Scarlet Monastery
{"Scarlet Monastery",
	{9438   , "Immune"},			-- Arcane Bubble
	{13323  , "CC"},				-- Polymorph
	{8988   , "Silence"},			-- Silence
	{8989   , "ImmuneSpell"},		-- Whirlwind
	{13874  , "Immune"},			-- Divine Shield
	{9256   , "CC"},				-- Deep Sleep
	{3639   , "Other"},				-- Improved Blocking
	{6146   , "Snare"},				-- Slow
},
	-- -- Razorfen Downs
{"Razorfen Downs",
	{12252  , "Root"},				-- Web Spray
	{15530  , "Snare"},				-- Frostbolt
	{12946  , "Silence"},			-- Putrid Stench
	{11443  , "Snare"},				-- Cripple
	{11436  , "Snare"},				-- Slow
	{12531  , "Snare"},				-- Chilling Touch
	{12748  , "Root"},				-- Frost Nova
	{152773 , "CC"},				-- Possession
	{150082 , "Snare"},				-- Plagued Bite
	{150707 , "CC"},				-- Overwhelmed
	{150485 , "Root"},				-- Web Wrap
},
	-- -- Uldaman
{"Uldaman",
	{11876  , "CC"},				-- War Stomp
	{3636   , "CC"},				-- Crystalline Slumber
	{9906   , "ImmuneSpell"},		-- Reflection
	{10093  , "Snare"},				-- Harsh Winds
	{25161  , "Silence"},			-- Harsh Winds
	{55142  , "CC"},				-- Ground Tremor
},
	-- -- Maraudon
{"Maraudon",
	{12747  , "Root"},				-- Entangling Roots
	{21331  , "Root"},				-- Entangling Roots
	{21793  , "Snare"},				-- Twisted Tranquility
	{21808  , "CC"},				-- Landslide
	{29419  , "CC"},				-- Flash Bomb
	{22592  , "CC"},				-- Knockdown
	{21869  , "CC"},				-- Repulsive Gaze
	{11428  , "CC"},				-- Knockdown
	{16790  , "CC"},				-- Knockdown
	{11922  , "Root"},				-- Entangling Roots
},
	-- -- Zul'Farrak
{" Zul'Farrak",
	{11020  , "CC"},				-- Petrify
	{13704  , "CC"},				-- Psychic Scream
	{11089  , "ImmunePhysical"},	-- Theka Transform (also immune to shadow damage)
	{12551  , "Snare"},				-- Frost Shot
	{11836  , "CC"},				-- Freeze Solid
	{11131  , "Snare"},				-- Icicle
	{11641  , "CC"},				-- Hex
},
	-- -- The Temple of Atal'Hakkar (Sunken Temple)
{"The Temple of Atal'Hakkar (Sunken Temple)",
	{12888  , "CC"},				-- Cause Insanity
	{12480  , "CC"},				-- Hex of Jammal'an
	{12890  , "CC"},				-- Deep Slumber
	--{25852  , "CC"},				-- Lash
	{6607   , "CC"},				-- Lash
	--{6608   , "Disarm"},			-- Dropped Weapon
	{25774  , "CC"},				-- Mind Shatter
	{33126  , "Disarm"},			-- Dropped Weapon
	{34259  , "CC"},				-- Fear
},
	-- -- Blackrock Depths
{"Blackrock Depths",
	{8994   , "CC"},				-- Banish
	{15588  , "Snare"},				-- Thunderclap
	{12674  , "Root"},				-- Frost Nova
	{12675  , "Snare"},				-- Frostbolt
	{15244  , "Snare"},				-- Cone of Cold
	{15636  , "ImmuneSpell"},		-- Avatar of Flame
	{7121   , "ImmuneSpell"},		-- Anti-Magic Shield
	{15471  , "Silence"},			-- Enveloping Web
	{3609   , "CC"},				-- Paralyzing Poison
	{15474  , "Root"},				-- Web Explosion
	{17492  , "CC"},				-- Hand of Thaurissan
	{12169  , "Other"},				-- Shield Block
	{15062  , "Immune"},			-- Shield Wall (not immune}, 75% damage reduction)
	{29061  , "Immune"},			-- Shield Wall (not immune}, 75% damage reduction)
	{14030  , "Root"},				-- Hooked Net
	{14870  , "CC"},				-- Drunken Stupor
	{13902  , "CC"},				-- Fist of Ragnaros
	{15063  , "Root"},				-- Frost Nova
	{6945   , "CC"},				-- Chest Pains
	{3551   , "CC"},				-- Skull Crack
	{15621  , "CC"},				-- Skull Crack
	{11831  , "Root"},				-- Frost Nova
	{15499  , "Snare"},				-- Frost Shock
	{280494 , "CC"},				-- Conflagration
	{47442  , "CC"},				-- Barreled!
	{21401  , "Snare"},				-- Frost Shock
},
	-- -- Blackrock Spire
{"Blackrock Spire",
	{16097  , "CC"},				-- Hex
	{22566  , "CC"},				-- Hex
	{15618  , "CC"},				-- Snap Kick
	{16075  , "CC"},				-- Throw Axe
	{16045  , "CC"},				-- Encage
	{16104  , "CC"},				-- Crystallize
	{16508  , "CC"},				-- Intimidating Roar
	{15609  , "Root"},				-- Hooked Net
	{16497  , "CC"},				-- Stun Bomb
	{5276   , "CC"},				-- Freeze
	{18763  , "CC"},				-- Freeze
	{16805  , "CC"},				-- Conflagration
	{13579  , "CC"},				-- Gouge
	{24698  , "CC"},				-- Gouge
	{28456  , "CC"},				-- Gouge
	{16046  , "Snare"},				-- Blast Wave
	{15744  , "Snare"},				-- Blast Wave
	{16249  , "Snare"},				-- Frostbolt
	{16469  , "Root"},				-- Web Explosion
	{15532  , "Root"},				-- Frost Nova
},
	-- -- Stratholme
{"Stratholme",
	{17405  , "CC"},				-- Domination
	{17246  , "CC"},				-- Possessed
	{15655  , "CC"},				-- Shield Slam
	{19645  , "ImmuneSpell"},		-- Anti-Magic Shield
	{16799  , "Snare"},				-- Frostbolt
	{16798  , "CC"},				-- Enchanting Lullaby
	{12542  , "CC"},				-- Fear
	{12734  , "CC"},				-- Ground Smash
	{17293  , "CC"},				-- Burning Winds
	{4962   , "Root"},				-- Encasing Webs
	{13322  , "Snare"},				-- Frostbolt
	{15089  , "Snare"},				-- Frost Shock
	{12557  , "Snare"},				-- Cone of Cold
	{16869  , "CC"},				-- Ice Tomb
	{17244  , "CC"},				-- Possess
	--{18327  , "Silence"},			-- Silence
	{17307  , "CC"},				-- Knockout
	{15970  , "CC"},				-- Sleep
	{3589   , "Silence"},			-- Deafening Screech
	{54791  , "Snare"},				-- Frostbolt
	{66290  , "CC"},				-- Sleep
	{82107  , "CC"},				-- Deep Freeze
	-- -- Dire Maul
	{17145  , "Snare"},				-- Blast Wave
	{22651  , "CC"},				-- Sacrifice
	{22419  , "Disarm"},			-- Riptide
	--{22691  , "Disarm"},			-- Disarm
	{22833  , "CC"},				-- Booze Spit (chance to hit reduced by 75%)
	{22856  , "CC"},				-- Ice Lock
	{16727  , "CC"},				-- War Stomp
	--{22735  , "ImmuneSpell"},		-- Spirit of Runn Tum (not immune}, 50% chance reflect spells)
	{22994  , "Root"},				-- Entangle
	{22924  , "Root"},				-- Grasping Vines
	{22914  , "Snare"},				-- Concussive Shot
	{22915  , "CC"},				-- Improved Concussive Shot
	{22919  , "Snare"},				-- Mind Flay
	{22909  , "Snare"},				-- Eye of Immol'thar
	{28858  , "Root"},				-- Entangling Roots
	{22415  , "Root"},				-- Entangling Roots
	{22744  , "Root"},				-- Chains of Ice
	{12611  , "Snare"},				-- Cone of Cold
	{16838  , "Silence"},			-- Banshee Shriek
	{22519  , "CC"},				-- Ice Nova
	{57825  , "Snare"},				-- Frostbolt
},
	-- -- Scholomance
{"Scholomance",
	{5708   , "CC"},				-- Swoop
	{18144  , "CC"},				-- Swoop
	{18103  , "CC"},				-- Backhand
	{8140   , "Other"},				-- Befuddlement
	{8611   , "Immune"},			-- Phase Shift
	{17651  , "Immune"},			-- Image Projection
	{27565  , "CC"},				-- Banish
	{18099  , "Snare"},				-- Chill Nova
	{16350  , "CC"},				-- Freeze
	{17165  , "Snare"},				-- Mind Flay
	{22643  , "Snare"},				-- Frostbolt Volley
	{18101  , "Snare"},				-- Chilled (Frost Armor)
},

{"Discovered LC Spells"
},
}

L.spellsTable = spellsTable
L.spellsArenaTable = spellsArenaTable

local tabs = {
	"CC",
	"Silence",
	"RootPhyiscal_Special",
	"RootMagic_Special",
	"Root",
	"ImmunePlayer",
	"Disarm_Warning",
	"CC_Warning",
	--"Enemy_Smoke_Bomb",
	"Stealth",
	"Immune",
	"ImmuneSpell",
	"ImmunePhysical",
	"AuraMastery_Cast_Auras",
	"ROP_Vortex",
	"Disarm",
	"Haste_Reduction",
	"Dmg_Hit_Reduction",
	"Interrupt",
	"AOE_DMG_Modifiers",
	"Friendly_Smoke_Bomb",
	"AOE_Spell_Refections",
	"Trees",
	"Speed_Freedoms",
	"Freedoms",
	"Friendly_Defensives",
	"Mana_Regen",
	"CC_Reduction",
	"Personal_Offensives",
	"Peronsal_Defensives",
	"Movable_Cast_Auras",

	"Other", --PVE only
	"PvE", --PVE only

	"SnareSpecial",
	"SnarePhysical70",
	"SnareMagic70",
	"SnarePhysical50",
	"SnarePosion50",
	"SnareMagic50",
	"SnarePhysical30",
	"SnareMagic30",
	"Snare",
}

local tabsArena = {
	"Drink_Purge",
	"Immune_Arena",
	"CC_Arena",
	"Silence_Arena",
	"Interrupt", -- Needs to be same
	"Special_High",
	"Ranged_Major_OffenisiveCDs",
	"Roots_90_Snares",
	"Disarms",
	"Melee_Major_OffenisiveCDs",
	"Big_Defensive_CDs",
	"Player_Party_OffensiveCDs",
	"Small_Offenisive_CDs",
	"Small_Defensive_CDs",
	"Freedoms_Speed",
	"Snares_WithCDs",
	"Special_Low",
	"Snares_Ranged_Spamable",
	"Snares_Casted_Melee",
}

local tabsIndex = {}
for i = 1, #tabs do
	tabsIndex[tabs[i]] = i
end
local tabsArenaIndex = {}
for i = 1, #tabsArena do
	tabsArenaIndex[tabsArena[i]] = i
end


-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {
	}, -- empty but necessary
	BambiUI = {
		player = "PartyAnchor5", --Chris
		party1 = "PartyAnchor1", --Chris
		party2 = "PartyAnchor2", --Chris
		party3 = "PartyAnchor3", --Chris
		party4 = "PartyAnchor4",
	},
	Gladius = {
		arena1      = GladiusClassIconFramearena1 or nil,
		arena2      = GladiusClassIconFramearena2 or nil,
		arena3      = GladiusClassIconFramearena3 or nil,
		arena4      = GladiusClassIconFramearena4 or nil,
		arena5      = GladiusClassIconFramearena5 or nil,
	},
	Blizzard = {
		player       = "PlayerPortrait",
		pet          = "PetPortrait",
		target       = "TargetFramePortrait",
		targettarget = "TargetFrameToTPortrait",
		focus        = "FocusFramePortrait",
		focustarget  = "FocusFrameToTPortrait",
		party1       = "PartyMemberFrame1Portrait",
		party2       = "PartyMemberFrame2Portrait",
		party3       = "PartyMemberFrame3Portrait",
		party4       = "PartyMemberFrame4Portrait",
		--party1pet    = "PartyMemberFrame1PetFramePortrait",
		--party2pet    = "PartyMemberFrame2PetFramePortrait",
		--party3pet    = "PartyMemberFrame3PetFramePortrait",
		--party4pet    = "PartyMemberFrame4PetFramePortrait",
		arena1      = "ArenaEnemyFrame1ClassPortrait",
		arena2      = "ArenaEnemyFrame2ClassPortrait",
		arena3      = "ArenaEnemyFrame3ClassPortrait",
		arena4      = "ArenaEnemyFrame4ClassPortrait",
		arena5      = "ArenaEnemyFrame5ClassPortrait",

	},
	Perl = {
		player       = "Perl_Player_PortraitFrame",
		pet          = "Perl_Player_Pet_PortraitFrame",
		target       = "Perl_Target_PortraitFrame",
		targettarget = "Perl_Target_Target_PortraitFrame",
		focus        = "Perl_Focus_PortraitFrame",
		focustarget  = "Perl_Focus_Target_PortraitFrame",
		party1       = "Perl_Party_MemberFrame1_PortraitFrame",
		party2       = "Perl_Party_MemberFrame2_PortraitFrame",
		party3       = "Perl_Party_MemberFrame3_PortraitFrame",
		party4       = "Perl_Party_MemberFrame4_PortraitFrame",
	},
	XPerl = {
		player       = "XPerl_PlayerportraitFrameportrait",
		pet          = "XPerl_Player_PetportraitFrameportrait",
		target       = "XPerl_TargetportraitFrameportrait",
		targettarget = "XPerl_TargettargetportraitFrameportrait",
		focus        = "XPerl_FocusportraitFrameportrait",
		focustarget = "XPerl_FocustargetportraitFrameportrait",
		party1       = "XPerl_party1portraitFrameportrait",
		party2       = "XPerl_party2portraitFrameportrait",
		party3       = "XPerl_party3portraitFrameportrait",
		party4       = "XPerl_party4portraitFrameportrait",
	},
	LUI = {
		player       = "oUF_LUI_player",
		pet          = "oUF_LUI_pet",
		target       = "oUF_LUI_target",
		targettarget = "oUF_LUI_targettarget",
		focus        = "oUF_LUI_focus",
		focustarget  = "oUF_LUI_focustarget",
		party1       = "oUF_LUI_partyUnitButton1",
		party2       = "oUF_LUI_partyUnitButton2",
		party3       = "oUF_LUI_partyUnitButton3",
		party4       = "oUF_LUI_partyUnitButton4",
	},
	SyncFrames = {
		arena1 = "SyncFrame1Class",
		arena2 = "SyncFrame2Class",
		arena3 = "SyncFrame3Class",
		arena4 = "SyncFrame4Class",
		arena5 = "SyncFrame5Class",
	},
	SUF = {
		player       = SUFUnitplayer and SUFUnitplayer.portrait or nil,
		pet          = SUFUnitpet and SUFUnitpet.portrait or nil,
		target       = SUFUnittarget and SUFUnittarget.portrait or nil,
		targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil,
		focus        = SUFUnitfocus and SUFUnitfocus.portrait or nil,
		focustarget  = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil,
		party1       = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil,
		party2       = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil,
		party3       = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil,
		party4       = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil,
		arena1       = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil,
		arena2       = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil,
		arena3       = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil,
		arena4       = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil,
		arena5       = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil,
	},
	-- more to come here?
}

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	EnableGladiusGloss = true, --Add option Check Box for This
	InterruptIcons = false,
	InterruptOverlay = false,
	RedSmokeBomb = true,
	lossOfControl = true,
	lossOfControlInterrupt = 1,
	lossOfControlFull  = 0,
	lossOfControlSilence = 0,
	lossOfControlDisarm = 0,
	lossOfControlRoot = 0,
	DrawSwipeSetting = 0,
	DiscoveredSpells = { },

	spellEnabled = { },
	spellEnabledArena = { },

	customSpellIds = { },
	customSpellIdsArena = { },

	version = 9.1, -- This is the settings version, not necessarily the same as the LoseControl version
	noCooldownCount = false,
	noBlizzardCooldownCount = true,
	noLossOfControlCooldown = false, --Chris Need to Test what is better
	disablePartyInBG = true,
	disableArenaInBG = true,
	disablePartyInRaid = true,
	disablePlayerTargetTarget = true,
	disableTargetTargetTarget = true,
	disablePlayerTargetPlayerTargetTarget = true,
	disableTargetDeadTargetTarget = true,
	disablePlayerFocusTarget = true,
	disableFocusFocusTarget = true,
	disablePlayerFocusPlayerFocusTarget = true,
	disableFocusDeadFocusTarget = true,
	showNPCInterruptsTarget = true,
	showNPCInterruptsFocus = true,
	showNPCInterruptsTargetTarget = true,
	showNPCInterruptsFocusTarget = true,
	duplicatePlayerPortrait = true,
	priority = {		-- higher numbers have more priority; 0 = disabled
			CC = 100,
			Silence = 95,
			RootPhyiscal_Special = 90,
			RootMagic_Special = 85,
			Root = 80,
			ImmunePlayer = 75,
			Disarm_Warning = 70,
			CC_Warning = 65,
			Enemy_Smoke_Bomb = 60,
			Stealth = 55,
			Immune = 50,
			ImmuneSpell = 45,
			ImmunePhysical = 45,
			AuraMastery_Cast_Auras = 44,
			ROP_Vortex = 42,
			Disarm = 40,
			Haste_Reduction = 38,
			Dmg_Hit_Reduction = 38,
			Interrupt = 36,
			AOE_DMG_Modifiers = 34,
			Friendly_Smoke_Bomb = 32,
			AOE_Spell_Refections = 30,
			Trees = 28,
			Speed_Freedoms = 26,
			Freedoms = 24,
			Friendly_Defensives = 22,
			Mana_Regen = 20,
			CC_Reduction = 18,
			Personal_Offensives = 16,
			Peronsal_Defensives = 14,
			Movable_Cast_Auras = 10,

			Other = 10, --PVE only
			PvE = 10, --PVE only

			SnareSpecial = 12,
			SnarePhysical70 = 8,
			SnareMagic70 = 7,
			SnarePhysical50 = 6,
			SnarePosion50 = 5,
			SnareMagic50 = 4,
			SnarePhysical30 = 3,
			SnareMagic30 = 2,
			Snare = 1,
	},
	durationType = {		-- higher numbers have more priority; 0 = disabled
			CC = false,
			Silence = false,
			RootPhyiscal_Special = false,
			RootMagic_Special = false,
			Root = false,
			ImmunePlayer = false,
			Disarm_Warning = false,
			CC_Warning = false,
			Enemy_Smoke_Bomb = false,
			Stealth = false,
			Immune = false,
			ImmuneSpell = false,
			ImmunePhysical = false,
			AuraMastery_Cast_Auras = false,
			ROP_Vortex = false,
			Disarm = false,
			Haste_Reduction = false,
			Dmg_Hit_Reduction = false,
			Interrupt = false,
			AOE_DMG_Modifiers = false,
			Friendly_Smoke_Bomb = false,
			AOE_Spell_Refections = false,
			Trees = false,
			Speed_Freedoms = false,
			Freedoms = false,
			Friendly_Defensives = false,
			Mana_Regen = false,
			CC_Reduction = false,
			Personal_Offensives = false,
			Peronsal_Defensives = false,
			Movable_Cast_Auras = false,

			Other = false,
			PvE = false,

			SnareSpecial = false,
			SnarePhysical70 = false,
			SnareMagic70 = false,
			SnarePhysical50 = true,
			SnarePosion50 = true,
			SnareMagic50 = true,
			SnarePhysical30 = true,
			SnareMagic30 = true,
			Snare = true,
	},
	priorityArena = {		-- higher numbers have more priority; 0 = disabled
			Drink_Purge = 100,
			Immune_Arena = 95,
			CC_Arena = 85,
			Silence_Arena = 80,
			Interrupt = 75, -- Needs to be same
			Special_High = 65,
			Ranged_Major_OffenisiveCDs = 60,
			Roots_90_Snares = 55,
			Disarms = 50,
			Melee_Major_OffenisiveCDs = 45,
			Big_Defensive_CDs = 35,
			Player_Party_OffensiveCDs = 35,
			Small_Offenisive_CDs = 25,
			Small_Defensive_CDs = 25,
			Freedoms_Speed = 25,
			Snares_WithCDs = 20,
			Special_Low = 15,
			Snares_Ranged_Spamable = 10,
			Snares_Casted_Melee = 5,
	},
	durationTypeArena ={
			Drink_Purge = false,
			Immune_Arena = false,
			CC_Arena = false,
			Silence_Arena = false,
			Interrupt = false, -- Needs to be same
			Special_High = false,
			Ranged_Major_OffenisiveCDs = false,
			Roots_90_Snares = false,
			Disarms = false,
			Melee_Major_OffenisiveCDs = false,
			Big_Defensive_CDs = false,
			Player_Party_OffensiveCDs = false,
			Small_Offenisive_CDs = false,
			Small_Defensive_CDs = false,
			Freedoms_Speed = false,
			Snares_WithCDs = false,
			Special_Low = false,
			Snares_Ranged_Spamable = false,
			Snares_Casted_Melee = false,
	},
	frames = {
		player = {
			enabled = true,
			size = 48, --CHRIS
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
				},
				debuff ={
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
			},
				interrupt = {
					friendly = false
				}
			}
		},
		player2 = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
				},
				debuff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
			},
				interrupt = {
					friendly = true
				}
			}
		},
		pet = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				}
				},
				interrupt = {
					friendly = true
				}
			}
		},
		target = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		targettarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focus = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focustarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		party1 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
						 Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 						  Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party2 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
			        Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party3 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 					    Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party4 = {
			enabled = true,
			size = 64,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						 CC = true,
						 Silence = true,
						 RootPhyiscal_Special = true,
						 RootMagic_Special = true,
						 Root = true,
						 ImmunePlayer = false,
						 Disarm_Warning = false,
						 CC_Warning = false,
						 Enemy_Smoke_Bomb = true,
						 Stealth = false,
						 Immune = true,
						 ImmuneSpell = true,
						 ImmunePhysical = true,
						 AuraMastery_Cast_Auras = false,
					   ROP_Vortex = true,
						 Disarm = true,
             Haste_Reduction = false,
						 Dmg_Hit_Reduction = false,
						 AOE_DMG_Modifiers = true,
						 Friendly_Smoke_Bomb = true,
						 AOE_Spell_Refections = true,
						 Trees = true,
						 Speed_Freedoms = true,
						 Freedoms = true,
						 Friendly_Defensives = false,
						 Mana_Regen = false,
						 CC_Reduction = true,
						 Personal_Offensives = false,
						 Peronsal_Defensives = false,
						 Movable_Cast_Auras = true,
					   SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						 PvE = true,
						 Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              Haste_Reduction = false,
 						  Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = true,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true, 	Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
						},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires
------------------------------------------------------------------------------------
--[[
-------------------------------------------
-These functions filter to show newest buffs
-------------------------------------------]]
local function cmp_col1(lhs, rhs)
 return lhs.col1 > rhs.col1
end

local function cmp_col1_col2(lhs, rhs)
 if lhs.col1 > rhs.col1 then return true end
 if lhs.col1 < rhs.col1 then return false end
 return lhs.col2 > rhs.col2
end

local locBliz = CreateFrame("Frame")
locBliz:RegisterEvent("LOSS_OF_CONTROL_ADDED")
locBliz:SetScript("OnEvent", function(self, event, ...)
	if (event == "LOSS_OF_CONTROL_ADDED") then
		for i = 1, 40 do
		local data = CLocData(i);
		 	if not data then break end
			  local locType = data.locType;
			 	local spellID = data.spellID;
			 	local text = data.displayText;
			 	local iconTexture = data.iconTexture;
			 	local startTime = data.startTime;
			 	local timeRemaining = data.timeRemaining;
			 	local duration = data.duration;
			 	local lockoutSchool = data.lockoutSchool;
			 	local priority = data.priority;
			 	local displayType = data.displayType;
				local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
				local ZoneName = GetZoneText()
				local Type
		  	if not spellIds[spellID] and  (lockoutSchool == 0 or nil or false) then
			  	if (locType == "STUN_MECHANIC") or (locType =="PACIFY") or (locType =="STUN") or (locType =="FEAR") or (locType =="CHARM") or (locType =="CONFUSE") or (locType =="POSSESS") or (locType =="FEAR_MECHANIC") or (locType =="FEAR") then
								 print("Found New CC",locType,"", spellID)
								 Type = "CC"
					elseif locType == "DISARM" then
								 print("Found New Disarm",locType,"", spellID)
							   Type = "Disarm"
					elseif (locType == "PACIFYSILENCE") or (locType =="SILENCE") then
						    print("Found New Silence",locType,"", spellID)
						 	  Type = "Silence"
					elseif locType == "ROOT" then
						  	print("Found New Root",locType,"", spellID)
								Type = "Root"
					else
								print("Found New Other",locType,"", spellID)
								Type = "Other"
					end
					spellIds[spellID] = Type
					LoseControlDB.spellEnabled[spellID]= true
					tblinsert(LoseControlDB.customSpellIds, {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex[Type]], {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
			  elseif (not interruptsIds[spellID]) and lockoutSchool > 0 then
					print("Found New Interrupt",locType,"", spellID)
					interruptsIds[spellID] = duration
					LoseControlDB.spellEnabled[spellID]= true
					tblinsert(LoseControlDB.customSpellIds, {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex["Interrupt"]], {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
				else
				end
			end
		end
	end)


local tooltip = CreateFrame("GameTooltip", "DebuffTextDebuffScanTooltip", UIParent, "GameTooltipTemplate")
local function GetDebuffText(unitId, debuffNum)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetUnitDebuff(unitId, debuffNum)
	local snarestring = DebuffTextDebuffScanTooltipTextLeft2:GetText()
	tooltip:Hide()
	if snarestring then
		if strmatch(snarestring, "Movement") or strmatch(snarestring, "movement") then
		return true
	  else
		return false
		end
	end
end


-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent, "CooldownFrameTemplate") -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Utility function to handle registering for unit events
function LoseControl:RegisterUnitEvents(enabled)
	local unitId = self.unitId
	if debug then print("RegisterUnitEvents", unitId, enabled) end
	if enabled then
		if unitId == "target" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "target")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- TargetTarget Blizzard Frame Show
				TargetFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, -30)
						else
							self:UNIT_AURA(self.unitId, 30)
						end
					end
				end)
				-- TargetTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local TframeToTDebuff = _G["TargetFrameToTDebuff"..i]
					if (TframeToTDebuff ~= nil) then
						TframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, 40)
									end
								end)
							end
						end)
						TframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, 43)
									end
								end)
							end
						end)
					end
				end
				TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "focus" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "focus")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- FocusTarget Blizzard Frame Show
				FocusFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, -30)
						else
							self:UNIT_AURA(self.unitId, 30)
						end
					end
				end)
				-- FocusTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local FframeToTDebuff = _G["FocusFrameToTDebuff"..i]
					if (FframeToTDebuff ~= nil) then
						FframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, 30)
									end
								end)
							end
						end)
						FframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, 31)
									end
								end)
							end
						end)
					end
				end
				FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "pet" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterUnitEvent("UNIT_PET", "player")
		else
			self:RegisterUnitEvent("UNIT_AURA", unitId)
		end
	else
		if unitId == "target" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "focus" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "pet" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("UNIT_PET")
		else
			self:UnregisterEvent("UNIT_AURA")
		end
		if not self.unlockMode then
			self:Hide()
			self:GetParent():Hide()
		end
	end
	local someFrameEnabled = false
	for _, v in pairs(LCframes) do
		if v.frame and v.frame.enabled then
			someFrameEnabled = true
			break
		end
	end
	if someFrameEnabled then
		LCframes["target"]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		LCframes["target"]:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

local function SetInterruptIconsSize(iconFrame, iconSize)
	local interruptIconSize = (iconSize * 0.88) / 3
	local interruptIconOffset = (iconSize * 0.06)
	if iconFrame.frame.anchor == "Blizzard" then
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[2] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[3] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[4] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2},
			[6] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize*2},
			[7] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize*2}
		}
	else
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset, interruptIconOffset},
			[2] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[3] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset},
			[4] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[6] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[7] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2}
		}
	end
	iconFrame.iconInterruptBackground:SetWidth(iconSize)
	iconFrame.iconInterruptBackground:SetHeight(iconSize)
	for _, v in pairs(iconFrame.iconInterruptList) do
		v:SetWidth(interruptIconSize)
		v:SetHeight(interruptIconSize)
		v:SetPoint("BOTTOMRIGHT", iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][1], iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][2])
	end
end

-- Function to disable Cooldown on player bars for CC effects
function LoseControl:DisableLossOfControlUI()
	if (not DISABLELOSSOFCONTROLUI_HOOKED) then
		hooksecurefunc('CooldownFrame_Set', function(self)
			if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
				self:SetDrawBling(false)
				self:SetCooldown(0, 0)
			else
				if not self:GetDrawBling() then
					self:SetDrawBling(true)
				end
			end
		end)
		hooksecurefunc('ActionButton_UpdateCooldown', function(self)
			if ( self.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
				local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration;
				local modRate = 1.0;
				local chargeModRate = 1.0;
				if ( self.spellID ) then
					start, duration, enable, modRate = GetSpellCooldown(self.spellID);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetSpellCharges(self.spellID);
				else
					start, duration, enable, modRate = GetActionCooldown(self.action);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(self.action);
				end
				self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
				self.cooldown:SetSwipeColor(0, 0, 0);
				self.cooldown:SetHideCountdownNumbers(false);
				if ( charges and maxCharges and maxCharges > 1 and charges < maxCharges ) then
					if chargeStart == 0 then
						ClearChargeCooldown(self);
					else
						if self.chargeCooldown then
							CooldownFrame_Set(self.chargeCooldown, chargeStart, chargeDuration, true, true, chargeModRate);
						end
					end
				else
					ClearChargeCooldown(self);
				end
				CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
			end
		end)
		DISABLELOSSOFCONTROLUI_HOOKED = true
	end
end


function LoseControl:CompileArenaSpells()

	spellIdsArena = {}

	local spellsArena = {}
	local spellsArenaLua = {}
	local hash = {}
	local customSpells = {}
	local toremove = {}
	--Build Custom Table for Check
	for k, v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, _, _, _, _, tabId  = unpack(v)
		customSpells[spellID] = {spellID, prio, k}
	end
	--Build the Spells Table
	for i = 1, (#tabsArena) do
		if spellsArena[i] == nil then
			spellsArena[i] = {}
		end
	end
--Sort the spells
	for k, v in ipairs(spellsArenaTable) do
		local spellID, prio = unpack(v)
		tblinsert(spellsArena[tabsArenaIndex[prio]], ({spellID, prio }))
		spellsArenaLua[spellID] = true
	end

	L.spellsArenaLua = spellsArenaLua
	--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
	for i = 1, (#spellsArena) do
		local removed = 0
		for l = 1, (#spellsArena[i]) do
			local spellID, prio = unpack(spellsArena[i][l])
			if (not hash[spellID]) and (not customSpells[spellID]) then
				hash[spellID] = {spellID, prio}
			else
				if customSpells[spellID] then
					local CspellID, Cprio, Ck = unpack(customSpells[spellID])
					if CspellID == spellID and Cprio == prio then
					tblremove(_G.LoseControlDB.customSpellIdsArena, Ck)
					print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored Arena Spell to Orginal Value|r")
					else
						if type(spellID) == "number" then
							if GetSpellInfo(spellID) then
								local name = GetSpellInfo(spellID)
								--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
						else
								--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
						end
						tblinsert(toremove, {i , l, removed, spellID})
						removed = removed + 1
					end
				else
					local HspellID, Hprio = unpack(hash[spellID])
					if type(spellID) == "number" then
							local name = GetSpellInfo(spellID)
							--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					else
							--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					end
					tblinsert(toremove, {i , l, removed, spellID})
					removed = removed + 1
				end
			end
		end
	end
	--Now Remove all the Duplicates and Custom Spells
	for k, v in ipairs(toremove) do
	local i, l, r, s = unpack(v)
	tblremove(spellsArena[i], l - r)
	end
	--ReAdd all dbCustom Spells to spells
	for k,v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, instanceType, zone, duration, customname, _, cleuEvent  = unpack(v)
		if prio ~= "Delete" then
			tblinsert(spellsArena[tabsArenaIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
		end
	end

		--Make spellIds from Spells for AuraFilter
	for i = 1, #spellsArena do
		for l = 1, #spellsArena[i] do
			spellIdsArena[spellsArena[i][l][1]] = spellsArena[i][l][2]
		end
	end

	for k, v in ipairs(interrupts) do
	local spellID, duration = unpack(v)
	tblinsert(spellsArena[tabsArenaIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
	end

	for k, v in ipairs(cleuSpells) do
	local spellID, duration, _, prioArena, _, customnameArena = unpack(v)
		if prioArena then
		tblinsert(spellsArena[tabsArenaIndex[prioArena]], 1, {spellID , prioArena, nil, nil, duration, customnameArena, nil, "cleuEventArena"})
		end
	end

	L.spellsArena = spellsArena
	L.spellIdsArena = spellIdsArena

--ARENAENABLED-------------------------------------------------------------------------------------------
	for k in pairs(spellIdsArena) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
		_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(interruptsIds) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
		_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
		if _G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena] == nil then
		_G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena]= true
		end
	end

end

function LoseControl:CompileSpells(typeUpdate)

		spellIds = {}
		interruptsIds = {}
		cleuPrioCastedSpells = {}

		local	spells = {}
		local spellsLua = {}
		local hash = {}
		local customSpells = {}
		local toremove = {}
		--Build Custom Table for Check
		for k, v in ipairs(_G.LoseControlDB.customSpellIds) do
			local spellID, prio, _, _, _, _, tabId  = unpack(v)
			customSpells[spellID] = {spellID, prio, tabId, k}
		end
		--Build the Spells Table
		for i = 1, (#spellsTable) do
			if spells[i] == nil then
		    spells[i] = {}
			end
	    for l = 1, (#tabs) do
				if spells[i][l] == nil then
					spells[i][l] = {}
	    	end
			end
		end
		--Sort the spells
		for i = 1, (#spellsTable) do
   		for l = 2, #spellsTable[i] do
				local spellID, prio = unpack(spellsTable[i][l])
        tblinsert(spells[i][tabsIndex[prio]], ({spellID, prio}))
				spellsLua[spellID] = true
			end
		end

		L.spellsLua = spellsLua
		--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
		for i = 1, (#spells) do
			for l = 1, (#spells[i]) do
				local removed = 0
				for x = 1, (#spells[i][l]) do
					local spellID, prio = unpack(spells[i][l][x])
					if (not hash[spellID]) and (not customSpells[spellID]) then
						hash[spellID] = {spellID, prio}
					else
						if customSpells[spellID] then
							local CspellID, Cprio, CtabId, Ck = unpack(customSpells[spellID])
							if CspellID == spellID and Cprio == prio and CtabId == i then
							tblremove(_G.LoseControlDB.customSpellIds, Ck)
							print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored to Orginal Value|r")
              elseif CspellID == spellID and CtabId == #spells then
              tblremove(_G.LoseControlDB.customSpellIds, Ck)
              print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Added from Discovered Spells to LC Database (Reconfigure if Needed)|r")
							else
								if type(spellID) == "number" then
									if GetSpellInfo(spellID) then
										local name = GetSpellInfo(spellID)
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
									end
								else
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
								end
								tblinsert(toremove, {i , l, x, removed, spellID})
								removed = removed + 1
							end
						else
							local HspellID, Hprio = unpack(hash[spellID])
							if type(spellID) == "number" then
									local name = GetSpellInfo(spellID)
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							else
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
							tblinsert(toremove, {i , l, x, removed, spellID})
							removed = removed + 1
						end
					end
				end
			end
		end
		--Now Remove all the Duplicates and Custom Spells
		for k, v in ipairs(toremove) do
		local i, l, x, r, s = unpack(v)
		tblremove(spells[i][l], x - r)
		end
  	--ReAdd all dbCustom Spells to spells
			for k,v in ipairs(_G.LoseControlDB.customSpellIds) do
				local spellID, prio, instanceType, zone, duration, customname, row, cleuEvent, position  = unpack(v)
				if prio ~= "Delete" then
					if duration then
							interruptsIds[spellID] = duration
					end
          if customname == "Discovered" then row = #spells end
					if position then
          	tblinsert(spells[row][position], 1, v)
					else
            tblinsert(spells[row][tabsIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
					end
				end
			end
  	--Make spellIds from Spells for AuraFilter
		for i = 1, #spells do
			for l = 1, #spells[i] do
				for x = 1, #spells[i][l] do
					spellIds[spells[i][l][x][1]] = spells[i][l][x][2]
				end
			end
		end
		--Make interruptIds for cleu -- only need to compile 1x for arena and players
		for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		interruptsIds[spellID] = duration
		end
		--Make cleuPrioCastedSpells for cleu -- only need to compile 1x for arena and players
		for _, v in ipairs(cleuSpells) do
		local spellID, duration, prio, prioArena, cleuEvent, cleuEventArena = unpack(v)
		cleuPrioCastedSpells[spellID] = {["duration"] = duration, ["priority"] = prio, ["priorityArena"] = prioArena,  ["name"] = cleuEvent,  ["nameArena"] = cleuEventArena}
		end
		--Add interrupts to Spells for Table
		for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		tblinsert(spells[1][tabsIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
		end
		--Add cleuPrioCastedSpells  to Spells for Table
		for k, v in ipairs(cleuSpells) do
		local spellID, duration, prio, _, customname = unpack(v)
			if prio then
			tblinsert(spells[1][tabsIndex[prio]], 1, {spellID , prio, nil, nil, duration, customname, nil, "cleuEvent"})			--body...
			end
		end

		L.spells = spells
		L.spellIds = spellIds
		--check for any 1st time spells being added and set to On
		for k in pairs(spellIds) do --spellIds is the combined PVE list, Spell List and the Discovered & Custom lists from tblinsert above
			if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
			end
		end
		for k in pairs(interruptsIds) do --interruptsIds is the list and the Discovered list from tblinsert above
			if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
			end
		end
		for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
			if _G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name] == nil then
			_G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name]= true
			end
		end

end


-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == addonName then
			if (_G.LoseControlDB == nil) or (_G.LoseControlDB.version == nil) then
			_G.LoseControlDB = CopyTable(DBdefaults)
			print(L["LoseControl reset."])
		end
		if _G.LoseControlDB.version < DBdefaults.version then
			for j, u in pairs(DBdefaults) do
				if (_G.LoseControlDB[j] == nil) then
					_G.LoseControlDB[j] = u
				elseif (type(u) == "table") then
					for k, v in pairs(u) do
						if (_G.LoseControlDB[j][k] == nil) then
							_G.LoseControlDB[j][k] = v
						elseif (type(v) == "table") then
							for l, w in pairs(v) do
								if (_G.LoseControlDB[j][k][l] == nil) then
									_G.LoseControlDB[j][k][l] = w
								elseif (type(w) == "table") then
									for m, x in pairs(w) do
										if (_G.LoseControlDB[j][k][l][m] == nil) then
											_G.LoseControlDB[j][k][l][m] = x
										elseif (type(x) == "table") then
											for n, y in pairs(x) do
												if (_G.LoseControlDB[j][k][l][m][n] == nil) then
													_G.LoseControlDB[j][k][l][m][n] = y
												elseif (type(y) == "table") then
													for o, z in pairs(y) do
														if (_G.LoseControlDB[j][k][l][m][n][o] == nil) then
															_G.LoseControlDB[j][k][l][m][n][o] = z
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			_G.LoseControlDB.version = DBdefaults.version
		end
		LoseControlDB = _G.LoseControlDB
		self.VERSION = "9.0"
		self.noCooldownCount = LoseControlDB.noCooldownCount
		self.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
		self.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
		if LoseControlDB.noLossOfControlCooldown then
			LoseControl:DisableLossOfControlUI()
		end
		if (LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.anchor == "Blizzard") then
			LoseControlDB.duplicatePlayerPortrait = false
		end
		LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
		if LoseControlDB.noCooldownCount then
			self:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			end
			LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
		else
			self:SetHideCountdownNumbers(true)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(true)
			end
			LCframeplayer2:SetHideCountdownNumbers(true)
		end
		playerGUID = UnitGUID("player")
		if Masque then
			for _, v in pairs(LCframes) do
				v.MasqueGroup = Masque:Group(addonName, v.unitId)
				if (LoseControlDB.frames[v.unitId].anchor ~= "Blizzard") then
					v.MasqueGroup:AddButton(v:GetParent(), {
						FloatingBG = false,
						Icon = v.texture,
						Cooldown = v,
						Flash = _G[v:GetParent():GetName().."Flash"],
						Pushed = v:GetParent():GetPushedTexture(),
						Normal = v:GetParent():GetNormalTexture(),
						Disabled = v:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[v:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = v:GetParent():GetHighlightTexture(),
						Hotkey = _G[v:GetParent():GetName().."HotKey"],
						Count = _G[v:GetParent():GetName().."Count"],
						Name = _G[v:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[v:GetParent():GetName().."Shine"],
					}, "Button", true)
					if v.MasqueGroup then
						v.MasqueGroup:ReSkin()
					end
				end
			end
		end
		self:CompileSpells(1)
		self:CompileArenaSpells(1)
	  L.SpellsPVEConfig:Addon_Load()
	  L.SpellsConfig:Addon_Load()
		L.SpellsArenaConfig:Addon_Load()
	end
end

LoseControl:RegisterEvent("ADDON_LOADED")


function LoseControl:CheckSUFUnitsAnchors(updateFrame)
	if not(ShadowUF and (SUFUnitplayer or SUFUnitpet or SUFUnittarget or SUFUnittargettarget or SUFHeaderpartyUnitButton1 or SUFHeaderpartyUnitButton2 or SUFHeaderpartyUnitButton3 or SUFHeaderpartyUnitButton4)) then return false end
	local frames = { self.unitId }
	if strfind(self.unitId, "party") then
		frames = { "party1", "party2", "party3", "party4" }
	elseif strfind(self.unitId, "arena") then
		frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
	end
	for _, unitId in ipairs(frames) do
		if anchors.SUF.player == nil then anchors.SUF.player = SUFUnitplayer and SUFUnitplayer.portrait or nil end
		if anchors.SUF.pet == nil then anchors.SUF.pet    = SUFUnitpet and SUFUnitpet.portrait or nil end
		if anchors.SUF.target == nil then anchors.SUF.target = SUFUnittarget and SUFUnittarget.portrait or nil end
		if anchors.SUF.targettarget == nil then anchors.SUF.targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil end
		if anchors.SUF.focus == nil then anchors.SUF.focus = SUFUnitfocus and SUFUnitfocus.portrait or nil end
		if anchors.SUF.focustarget == nil then anchors.SUF.focustarget = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil end
		if anchors.SUF.party1 == nil then anchors.SUF.party1 = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil end
		if anchors.SUF.party2 == nil then anchors.SUF.party2 = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil end
		if anchors.SUF.party3 == nil then anchors.SUF.party3 = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil end
		if anchors.SUF.party4 == nil then anchors.SUF.party4 = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil end
		if anchors.SUF.arena1 == nil then anchors.SUF.arena1 = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil end
		if anchors.SUF.arena2 == nil then anchors.SUF.arena2 = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil end
		if anchors.SUF.arena3 == nil then anchors.SUF.arena3 = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil end
		if anchors.SUF.arena4 == nil then anchors.SUF.arena4 = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil end
		if anchors.SUF.arena5 == nil then anchors.SUF.arena5 = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil end
		if updateFrame and anchors.SUF[unitId] ~= nil then
			local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
			local icon = LCframes[unitId]
			if self.fakeUnitId == "player2" then
				icon = LCframeplayer2
			end
			local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if newAnchor ~= nil and icon.anchor ~= newAnchor then
				icon.anchor = newAnchor
				icon:SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				icon:GetParent():SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				if icon.anchor:GetParent() then
					icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
		end
	end
	if self.fakeUnitId ~= "player2" and self.unitId == "player" then
		LCframeplayer2:CheckSUFUnitsAnchors(updateFrame)
	end
	return true
end

function LoseControl:CheckGladiusUnitsAnchors(updateFrame)
  if (strfind(self.unitId, "arena")) and LoseControlDB.frames[self.unitId].anchor == "Gladius" then
    local inInstance, instanceType = IsInInstance();  local gladiusFrame;  local frames = {}
  	if Gladius and (not anchors.Gladius[self.unitId]) then
  		if not GladiusClassIconFramearena1 and instanceType ~= "arena" then
  			gladiusFrame = "on"
  			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
  			if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  			else
  				DEFAULT_CHAT_FRAME.editBox:Show()
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  				DEFAULT_CHAT_FRAME.editBox:Hide()
  			end
    	end
  		if GladiusClassIconFramearena1 then frames[1] = "arena1" end
    	if GladiusClassIconFramearena2 then frames[2] = "arena2" end
  		if GladiusClassIconFramearena3 then frames[3] = "arena3" end
  		if GladiusClassIconFramearena4 then frames[4] = "arena4" end
  		if GladiusClassIconFramearena5 then frames[5] = "arena5" end
  			for _, unitId in pairs(frames) do
  				if (unitId == "arena1") and anchors.Gladius.arena1 == nil then anchors.Gladius.arena1 = GladiusClassIconFramearena1 or nil end
  				if (unitId == "arena2") and anchors.Gladius.arena2 == nil then anchors.Gladius.arena2 = GladiusClassIconFramearena2 or nil end
  				if (unitId == "arena3") and anchors.Gladius.arena3 == nil then anchors.Gladius.arena3 = GladiusClassIconFramearena3 or nil end
  				if (unitId == "arena4") and anchors.Gladius.arena4 == nil then anchors.Gladius.arena4 = GladiusClassIconFramearena4 or nil end
  				if (unitId == "arena5") and anchors.Gladius.arena5 == nil then anchors.Gladius.arena5 = GladiusClassIconFramearena5 or nil end
  				if updateFrame and anchors.Gladius[unitId] ~= nil then
					local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
					local icon = LCframes[unitId]
					local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
					if newAnchor ~= nil and icon.anchor ~= newAnchor then
						icon.anchor = newAnchor
						icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
						icon:ClearAllPoints() -- if we don't do this then the frame won't always move
						icon:GetParent():ClearAllPoints()
						icon:SetWidth(frame.size)
						icon:SetHeight(frame.size)
						icon:GetParent():SetWidth(frame.size)
						icon:SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						icon:GetParent():SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						if icon.anchor:GetParent() then
							icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
						end
						if #frames < 5 then
						print("|cff00ccffLoseControl|r : Successfully Anchored "..unitId.." frame to Gladius")
					  end
					end
				end
			end
			if #frames == 5 then
			print("|cff00ccffLoseControl|r : Successfully Anchored All Arena Frames")
			end
			if gladiusFrame == "on" then
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
		end
	end
end
-- Initialize a frame's position and register for events
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	local unitId = self.unitId
	self.frame = LoseControlDB.frames[self.fakeUnitId or unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	local inInstance, instanceType = IsInInstance()
  if (instanceType=="arena" or instanceType=="pvp") then LoseControlDB.priority["PvE"] = 0 else LoseControlDB.priority["PvE"] = 10 end --Disables PVE in Arena
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and (
			( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
			( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
		)
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
	)
	if (ShadowUF ~= nil) and not(self:CheckSUFUnitsAnchors(false)) and (self.SUFDelayedSearch == nil) then
		self.SUFDelayedSearch = GetTime()
		Ctimer(8, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckSUFUnitsAnchors(true)
		end)
	end
	if strfind(unitId, "arena") then
	if (Gladius ~= nil) and (self.GladiusDelayedSearch == nil) then
		self.GladiusDelayedSearch = GetTime()
		Ctimer(3, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckGladiusUnitsAnchors(true)
		end)
	end
	end
	self.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
	self.unitGUID = UnitGUID(self.unitId)
	self.parent:SetParent(self.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:GetParent():ClearAllPoints()
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:GetParent():SetWidth(frame.size)
	self:GetParent():SetHeight(frame.size)
	self:RegisterUnitEvents(enabled)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	if self.anchor:GetParent() then
		self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
	end
	if self.MasqueGroup then
		self.MasqueGroup:ReSkin()
	end

	SetInterruptIconsSize(self, frame.size)

	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
	self:Hide()
	self:GetParent():Hide()

	if enabled and not self.unlockMode then
		self:UNIT_AURA(self.unitId, 0)
	end
end

function LoseControl:GROUP_ROSTER_UPDATE()
	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "party")) then
		return
	end
	local inInstance, instanceType = IsInInstance()
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and LoseControlDB.disablePartyInBG
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
	)
	self:RegisterUnitEvents(enabled)
	self.unitGUID = UnitGUID(unitId)
	self:CheckSUFUnitsAnchors(true)
	if (frame == nil) or (unitId == nil) and (strfind(unitId, "arena")) then
	self:CheckGladiusUnitsAnchors(true)
	end
	if enabled and not self.unlockMode then
		self:UNIT_AURA(unitId, 0)
	end
end

function LoseControl:GROUP_JOINED()
	self:GROUP_ROSTER_UPDATE()
end

function LoseControl:GROUP_LEFT()
	self:GROUP_ROSTER_UPDATE()
end

local function UpdateUnitAuraByUnitGUID(unitGUID, typeUpdate)
	local inInstance, instanceType = IsInInstance()
	for k, v in pairs(LCframes) do
		local enabled = v.frame.enabled and not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(v.unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(v.unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(v.unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
		)
		if enabled and not v.unlockMode then
			if v.unitGUID == unitGUID then
				v:UNIT_AURA(k, typeUpdate)
				if (k == "player") and LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(k, typeUpdate)
				end
			end
		end
	end
end

function LoseControl:ARENA_OPPONENT_UPDATE()

	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "arena")) then
		return
	end
	local inInstance, instanceType = IsInInstance()
	self:RegisterUnitEvents(
		frame.enabled and not (
			inInstance and instanceType == "pvp" and LoseControlDB.disableArenaInBG
		)
	)
	self.unitGUID = UnitGUID(self.unitId)
	self:CheckSUFUnitsAnchors(true)
	self:CheckGladiusUnitsAnchors(true)


	if enabled and not self.unlockMode then
		self:UNIT_AURA(unitId, 0)
	end
end

function LoseControl:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	self:CheckGladiusUnitsAnchors(true)
	self:ARENA_OPPONENT_UPDATE()
end


local ArenaSeen = CreateFrame("Frame")
ArenaSeen:RegisterEvent("ARENA_OPPONENT_UPDATE")
ArenaSeen:SetScript("OnEvent", function(self, event, ...)
	local unit, arg2 = ...;
	if (event == "ARENA_OPPONENT_UPDATE") then
	if (unit =="arena1") or (unit =="arena2") or (unit =="arena3") then
		if arg2 == "seen" then
			if UnitExists(unit) then
				if (unit =="arena1") and (GladiusClassIconFramearena1) then
					GladiusClassIconFramearena1:SetAlpha(1)
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
				if (unit =="arena2") and (GladiusClassIconFramearena2) then
					GladiusClassIconFramearena2:SetAlpha(1)
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
				if (unit =="arena3") and (GladiusClassIconFramearena3) then
					GladiusClassIconFramearena3:SetAlpha(1)
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
				end
			Arenastealth[unit] = nil
			end
		elseif arg2 == "unseen" then
				local guid = UnitGUID(unit)
				UpdateUnitAuraByUnitGUID(guid, -200)
		elseif arg2 == "destroyed" then
			Arenastealth[unit] = nil
		elseif arg2 == "cleared" then
			Arenastealth[unit] = nil
		end
	end
end
end)

local tip = CreateFrame('GameTooltip', 'GuardianOwnerTooltip', nil, 'GameTooltipTemplate')
local function GetGuardianOwner(guid) --Used for Infrnals and Ele
  tip:SetOwner(WorldFrame, 'ANCHOR_NONE')
  tip:SetHyperlink('unit:' .. guid or '')
  local text = GuardianOwnerTooltipTextLeft2
	local text1 = GuardianOwnerTooltipTextLeft3
	if text1 and type(text1:GetText()) == "string" then
		if strmatch(text1:GetText(), "Corpse") then
			return "Corpse"
		else
			return strmatch(text and text:GetText() or '', "^([^%s-]+)")
		end
	else
		return strmatch(text and text:GetText() or '', "^([^%s-]+)")
	end
end

-- This event check pvp interrupts and targettarget/focustarget unit aura triggers
function LoseControl:COMBAT_LOG_EVENT_UNFILTERED()
	if self.unitId == "target" then
		-- Check Interrupts
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (destGUID ~= nil) then --Diables Kicks for Player
			if (event == "SPELL_INTERRUPT") then
				local duration = interruptsIds[spellId]
				if (duration ~= nil) then
					local _, destClass = GetPlayerInfoByGUID(destGUID)
					if (destClass == "DRUID") then
						local unitIdFromGUID
						for _, v in pairs(LCframes) do
							if (UnitGUID(v.unitId) == destGUID) then
								unitIdFromGUID = v.unitId
								break
							end
						end
						if (unitIdFromGUID ~= nil) then
							for i = 1, 40 do
								local _, _, _, _, _, _, _, _, _, auxSpellId = UnitBuff(unitIdFromGUID, i)
								if not auxSpellId then break end
								if auxSpellId == 234084 then		-- Moon and Stars (Druid)
									duration = duration * 0.3
									break
								end
							end
						end
					end
					local expirationTime = GetTime() + duration
					if debug then print("interrupt", ")", destGUID, "|", GetSpellInfo(spellId), "|", duration, "|", expirationTime, "|", spellId) end
					local priority = LoseControlDB.priority.Interrupt
					local spellCategory = "Interrupt"
						if (destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3")) then
						priority = LoseControlDB.priorityArena.Interrupt
					  end
					local name, _, icon = GetSpellInfo(spellId)
					if (InterruptAuras[destGUID] == nil) then
						InterruptAuras[destGUID] = {}
					end
					tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
					UpdateUnitAuraByUnitGUID(destGUID, -20)
				end
			elseif (((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and (select(2, GetPlayerInfoByGUID(destGUID)) ~= "HUNTER")) then --may need to use UNIT_AURA check for Fiegn Death here to make more accurate
				if (InterruptAuras[destGUID] ~= nil) then --reset if the source of the kick dies
				InterruptAuras[destGUID] = nil
				UpdateUnitAuraByUnitGUID(destGUID, -21)
		  	end
				if (SmokeBombAuras[destGUID] ~= nil) then --reset if the source of the bomb dies
				SmokeBombAuras[destGUID] = nil
				UpdateUnitAuraByUnitGUID(destGUID, -21)
			  end
			end
		end
   	-- Check Channel Interrupts for player
      if (event == "SPELL_CAST_SUCCESS") then
		    if interruptsIds[spellId] then
	        if (destGUID == UnitGUID("player")) and (select(7, UnitChannelInfo("player")) == false) then
           local duration = interruptsIds[spellId]
  			  	if (duration ~= nil) then
  					local expirationTime = GetTime() + duration
  					local priority = LoseControlDB.priority.Interrupt
  					local spellCategory = "Interrupt"
  					local name, _, icon = GetSpellInfo(spellId)
  					if (InterruptAuras[destGUID] == nil) then
  						InterruptAuras[destGUID] = {}
  					end
  					tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
  					UpdateUnitAuraByUnitGUID(destGUID, -20)
  		     end
         end
       end
     end
			-- Check Channel Interrupts for arena
			if (event == "SPELL_CAST_SUCCESS") then
				if interruptsIds[spellId] then
					for i = 1, GetNumArenaOpponents() do
					  if (destGUID == UnitGUID("arena"..i)) and (select(7, UnitChannelInfo("arena"..i)) == false) then
		          local duration = interruptsIds[spellId]
							if (duration ~= nil) then
								local expirationTime = GetTime() + duration
								local priority = LoseControlDB.priorityArena.Interrupt
								local spellCategory = "Interrupt"
								local name, _, icon = GetSpellInfo(spellId)
								if (InterruptAuras[destGUID] == nil) then
									InterruptAuras[destGUID] = {}
								end
								tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
								UpdateUnitAuraByUnitGUID(destGUID, -20)
					    end
					  end
					end
				end
			end
			-- Check Channel Interrupts for party
			if (event == "SPELL_CAST_SUCCESS") then
				if interruptsIds[spellId] then
					for i = 1, GetNumGroupMembers() do
						 if (destGUID == UnitGUID("party"..i)) and (select(7, UnitChannelInfo("party"..i)) == false) then
	            local duration = interruptsIds[spellId]
							if (duration ~= nil) then
								local expirationTime = GetTime() + duration
								local priority = LoseControlDB.priority.Interrupt
								local spellCategory = "Interrupt"
								local name, _, icon = GetSpellInfo(spellId)
								if (InterruptAuras[destGUID] == nil) then
									InterruptAuras[destGUID] = {}
								end
								tblinsert(InterruptAuras[destGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
								UpdateUnitAuraByUnitGUID(destGUID, -20)
	            end
					  end
					end
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Reset Stealth Table if Unit Dies
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and ((destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3"))) then
				if (destGUID == UnitGUID("arena1")) then
					Arenastealth["arena1"] = nil
				elseif (destGUID == UnitGUID("arena2")) then
					Arenastealth["arena2"] = nil
				elseif (destGUID == UnitGUID("arena3")) then
					Arenastealth["arena3"] = nil
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--SmokeBomb Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 212182)) then
				if (sourceGUID ~= nil) then
				local duration = 5
				local expirationTime = GetTime() + duration
					if (SmokeBombAuras[sourceGUID] == nil) then
						SmokeBombAuras[sourceGUID] = {}
					end
			  	SmokeBombAuras[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					SmokeBombAuras[sourceGUID] = nil
					end)
			  end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Root Beam Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 78675)) then
				if (sourceGUID ~= nil) then
					local duration = 8
					local expirationTime = GetTime() + duration
					if (BeamAura[sourceGUID] == nil) then
						BeamAura[sourceGUID] = {}
					end
					BeamAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					BeamAura[sourceGUID] = nil
					end)
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Shaodwy Duel Enemy Check
			-----------------------------------------------------------------------------------------------------------------
			if ((event == "SPELL_CAST_SUCCESS") and (spellId == 207736)) then
				if sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
					local duration = 6
					local expirationTime = GetTime() + duration
					if (DuelAura[sourceGUID] == nil) then
						DuelAura[sourceGUID] = {}
					end
					if (DuelAura[destGUID] == nil) then
						DuelAura[destGUID] = {}
					end
					DuelAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
					DuelAura[destGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
					print("cleu enemy Dueled Data Stored destGUID is"..destGUID)
					print("cleu enemy Dueled Data Stored sourceGUID is"..sourceGUID)
					Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					DuelAura[sourceGUID] = nil
					DuelAura[destGUID] = nil
					end)
				end
			end

		-----------------------------------------------------------------------------------------------------------------
		--CLEU Spell Cast Check (if Cast dies it will not update currently, not sure how to track that)
		-----------------------------------------------------------------------------------------------------------------
		if (((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (cleuPrioCastedSpells[spellId])) then
			local priority, priorityArena, spellCategory, name
      ------------------------------------------Player/Party/Target/Etc-------------------------------------------------------------
			if cleuPrioCastedSpells[spellId].priority == nil then
			 priority = nil
			else
			 priority = LoseControlDB.priority[cleuPrioCastedSpells[spellId].priority]
			 spellCategory = cleuPrioCastedSpells[spellId].priority
			 name = cleuPrioCastedSpells[spellId].name
			end
			------------------------------------------Arena123-----------------------------------------------------------------------------
			if (sourceGUID == UnitGUID("arena1")) or (sourceGUID == UnitGUID("arena2")) or (sourceGUID == UnitGUID("arena3")) then
				if cleuPrioCastedSpells[spellId].priorityArena == nil then
				 priority = nil
				else
				 priority = LoseControlDB.priorityArena[cleuPrioCastedSpells[spellId].priorityArena]
				 spellCategory = cleuPrioCastedSpells[spellId].priorityArena
				 name = cleuPrioCastedSpells[spellId].nameArena
				end
	  	end
			--------------------------------------------------------------------------------------------------------------------------------
			if priority then
				local duration = cleuPrioCastedSpells[spellId].duration
				local expirationTime = GetTime() + duration
				if not InterruptAuras[sourceGUID]  then
						InterruptAuras[sourceGUID] = {}
				end
				local namePrint, _, icon = GetSpellInfo(spellId)

        if spellId == 321686 then
          icon = 135994
        end
        if spellId == 157299 then
          icon = 2065626
        end

        print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." LC")

				tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = nil, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID })
				UpdateUnitAuraByUnitGUID(sourceGUID, -20)
        self.ticker = C_Timer.NewTicker(0.5, function()
          if InterruptAuras[sourceGUID] then
            for k, v in pairs(InterruptAuras[sourceGUID]) do
    					if v.destGUID then
                if substring(v.destGUID, -5) == substring(destGUID, -5) then --string.sub is to help witj Mirror Images bug
                  if strmatch(GetGuardianOwner(v.destGUID), 'Corpse') or strmatch(GetGuardianOwner(v.destGUID), 'Level') then
                    InterruptAuras[sourceGUID][k] = nil
                    print(sourceName.." "..GetGuardianOwner(v.destGUID).." "..namePrint.." "..substring(v.destGUID, -7).." left w/ "..string.format("%.2f", expirationTime-GetTime()).." LC")
                    UpdateUnitAuraByUnitGUID(sourceGUID, -20)
                    self.ticker:Cancel()
                    break
                  end
                end
              end
            end
          end
        end, duration * 2)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Cold Snap Reset
		-----------------------------------------------------------------------------------------------------------------
		if ((sourceGUID ~= nil) and (event == "SPELL_CAST_SUCCESS") and (spellId == 235219)) then
			local needUpdateUnitAura = false
			if (InterruptAuras[sourceGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[sourceGUID]) do
					if (bit_band(v.spellSchool, 16) > 0) then
						needUpdateUnitAura = true
						if (v.spellSchool > 16) then
							InterruptAuras[sourceGUID][k].spellSchool = InterruptAuras[sourceGUID][k].spellSchool - 16
						else
							InterruptAuras[sourceGUID][k] = nil
						end
					end
				end
				if (next(InterruptAuras[sourceGUID]) == nil) then
					InterruptAuras[sourceGUID] = nil
				end
			end
			if needUpdateUnitAura then
				UpdateUnitAuraByUnitGUID(sourceGUID, -22)
			end
		end

	elseif (self.unitId == "targettarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerTargetTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableTargetTargetTarget) or (self.unitGUID ~= LCframes.target.unitGUID))) or (self.unitId == "focustarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerFocusTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableFocusFocusTarget) or (self.unitGUID ~= LCframes.focus.unitGUID))) then
			-- Manage targettarget/focustarget UNIT_AURA triggers
			local _, event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
			if (destGUID ~= nil and destGUID == self.unitGUID) then
				if (event == "SPELL_AURA_APPLIED") or (event == "SPELL_PERIODIC_AURA_APPLIED") or
				 (event == "SPELL_AURA_REMOVED") or (event == "SPELL_PERIODIC_AURA_REMOVED") or
				 (event == "SPELL_AURA_APPLIED_DOSE") or (event == "SPELL_PERIODIC_AURA_APPLIED_DOSE") or
				 (event == "SPELL_AURA_REMOVED_DOSE") or (event == "SPELL_PERIODIC_AURA_REMOVED_DOSE") or
				 (event == "SPELL_AURA_REFRESH") or (event == "SPELL_PERIODIC_AURA_REFRESH") or
				 (event == "SPELL_AURA_BROKEN") or (event == "SPELL_PERIODIC_AURA_BROKEN") or
				 (event == "SPELL_AURA_BROKEN_SPELL") or (event == "SPELL_PERIODIC_AURA_BROKEN_SPELL") or
				 (event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES") then
					local timeCombatLogAuraEvent = GetTime()
					Ctimer(0.01, function()	-- execute in some close next frame to accurate use of UnitAura function
						if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent ~= timeCombatLogAuraEvent)) then
							self:UNIT_AURA(self.unitId, 3)
						end
					end)
				end
			end
		end
	end


-- This is the main event. Check for (de)buffs and update the frame icon and cooldown.
function LoseControl:UNIT_AURA(unitId, typeUpdate) -- fired when a (de)buff is gained/lost
	if (((typeUpdate ~= nil and typeUpdate > 0) or (typeUpdate == nil and self.unitId == "targettarget") or (typeUpdate == nil and self.unitId == "focustarget")) and (self.lastTimeUnitAuraEvent == GetTime())) then return end
	if ((self.unitId == "targettarget" or self.unitId == "focustarget") and (not UnitIsUnit(unitId, self.unitId))) then return end
	local priority = LoseControlDB.priority
	local durationType = LoseControlDB.durationType
	local enabled = LoseControlDB.spellEnabled
	local spellIds = spellIds

	if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
		priority =  LoseControlDB.priorityArena
		durationType =  LoseControlDB.durationTypeArena
		enabled = LoseControlDB.spellEnabledArena
		spellIds = spellIdsArena
	end

	local maxPriority = 1
	local maxExpirationTime = 0
	local newExpirationTime = 0
	local maxPriorityIsInterrupt = false
	local Icon, Duration, Hue, Name, Spell, Count
	local LayeredHue = nil
	local forceEventUnitAuraAtEnd = false
	local buffs= {}
	self.lastTimeUnitAuraEvent = GetTime()

	if (self.anchor:IsVisible() or (self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard")) and UnitExists(self.unitId) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetPlayerTargetTarget) or not(UnitIsUnit("player", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetTarget) or not(UnitIsUnit("targettarget", "player")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetTargetTarget) or not(UnitIsUnit("targettarget", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetDeadTargetTarget) or (UnitHealth("target") > 0))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusPlayerFocusTarget) or not(UnitIsUnit("player", "focus") and UnitIsUnit("player", "focustarget")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusTarget) or not(UnitIsUnit("focustarget", "player")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusFocusTarget) or not(UnitIsUnit("focustarget", "focus")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusDeadFocusTarget) or (UnitHealth("focus") > 0))) then
		local reactionToPlayer = ((self.unitId == "target" or self.unitId == "focus" or self.unitId == "targettarget" or self.unitId == "focustarget" or strfind(self.unitId, "arena")) and UnitCanAttack("player", unitId)) and "enemy" or "friendly"
		-- Check debuffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura(unitId, i, "HARMFUL")
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (self.unitId == "targettarget") or (self.unitId == "focustarget") then
				if debug then print(unitId, "debuff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end
			end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end
			-----------------------------------------------------------------------------------------------------------------
			--Finds all Snares in game
			-----------------------------------------------------------------------------------------------------------------
			if unitId == "player" and not spellIds[spellId] then
				if GetDebuffText(unitId, i) then
					print("Found New CC SNARE",spellId,"", name,"", snarestring)
					spellIds[spellId] = "Snare"
					local spellCategory = spellIds[spellId]
					local Priority = priority[spellCategory]
					local Name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
					local ZoneName = GetZoneText()
					LoseControlDB.spellEnabled[spellId]= true
					tblinsert(LoseControlDB.customSpellIds, {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex["Snare"]], {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
					local locClass = "Creature"
					if source then
					local guid, name = UnitGUID(source), UnitName(source)
					local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
						if type == "Creature" then
						 print(name .. "'s NPC id is " .. npc_id)
						elseif type == "Vignette" then
						 print(name .. " is a Vignette and should have its npc_id be zero (" .. npc_id .. ").") --Vignette" refers to NPCs that appear as a rare when you first encounter them, but appear as a common after you've looted them once.
						elseif type == "Player" then
						 local Class, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
						 print(Class.." "..name .. " is a player.")
					  else
						end
						locClass = Class
					else
					end
				end
			end


			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end

			-----------------------------------------------------------------------------------------------------------------
			--Enemy Duel
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 207736 then --Shodowey Duel enemy on friendly, friendly frame (red)
				if DuelAura[UnitGUID(unitId)] then --enemyDuel
					name = "EnemyShadowyDuel"
					spellIds[spellId] = "Enemy_Smoke_Bomb"
					print(unitId.."Duel is Enemy")
					if (UnitGUID(unitId) == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
					spellIds[spellId] = "Special_High"
					end
				else
					print(UnitGUID(unitId).."Duel is Friendly")
					name = "FriendlyShadowyDuel"
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
					spellIds[spellId] = "Special_High"
					end
	  		end
			end

			-----------------------------------------------------------------------------------------------------------------
			--SmokeBomb Check For Arena
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 212183 then -- Smoke Bomb
				if source and SmokeBombAuras[UnitGUID(source)] then
					--print(source)
					if UnitIsEnemy("player", source) then --still returns true for an enemy currently under mindcontrol I can add your fix.
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Enemy_Smoke_Bomb"
						--print(unitId.."SmokeBombed is enemy check")
							if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
								--print(unitId.."Enemy SmokeBombed in Arean123 check")
								spellIds[spellId] = "Special_High"
							end
						name = "EnemySmokeBomb"
					elseif not UnitIsEnemy("player", source) then --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Friendly_Smoke_Bomb"
							if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
								--print(unitId.."Friendly SmokeBombed on Arean123 check")
								spellIds[spellId] = "Special_High" --
							end
					end
				else
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") or (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
						spellIds[spellId] = "Special_High"
					end
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Two debuff conidtions like Root Beam
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 81261 then
				local root = {}
					for i = 1, 40 do
		      local _, _, _, _, d, e, _, _, _, s = UnitAura(unitId, i, "HARMFUL")
					if not s then break end
							if (spellIds[s] == "RootPhyiscal_Special") or (spellIds[s] == "RootMagic_Special") or (spellIds[s] == "Root") or (spellIds[s] == "Roots_90_Snares") then
								tblinsert(root, {["col1"] = e, ["col2"]  = d})
							end
					end
					if #root then
						tblsort(root, cmp_col1)
					end
					if root[1] then
					expirationTime = root[1].col1 + .01
					duration = root[1].col2
						if source and BeamAura[UnitGUID(source)] then
							if (expirationTime - GetTime()) >  (BeamAura[UnitGUID(source)].expirationTime - GetTime()) then
								duration = BeamAura[UnitGUID(source)].duration
								expirationTime =BeamAura[UnitGUID(source)].expirationTime + .01
							end
						end
					end
				end

        -----------------------------------------------------------------------------------------------------------------
        --Icon Changes
        -----------------------------------------------------------------------------------------------------------------
        if spellId == 45524 then --Chains of Ice Dk
          --icon = 463560
          --icon = 236922
          icon = 236925
        end

        if spellId == 317589 then --Mirros of Toremnt, Tormenting Backlash (Venthyr Mage) to Frost Jaw
          icon = 538562
        end

        if spellId == 334693 then --Abosolute Zero Frost Dk Legendary Stun to Cube
          icon = 517161
        end

        if spellId == 115196 then --Shiv
          icon = 135428
        end

      	if spellId == 199845 then --Psyflay
      		icon = 537021
      	end

        -----------------------------------------------------------------------------------------------------------------
        --Hue Change
        -----------------------------------------------------------------------------------------------------------------
        if spellId == 320035 then -- Mirros of Torment Haste Reduction
          hue = "Purple"
        end

			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]

			if self.frame.categoriesEnabled.debuff[reactionToPlayer][spellCategory] then
				if Priority then
					-----------------------------------------------------------------------------------------------------------------
					--Unseen Table Debuffs
					-----------------------------------------------------------------------------------------------------------------
					if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
				  if typeUpdate == -200 and UnitExists(unitId) then
						if not Arenastealth[unitId] then
							Arenastealth[unitId] = {}
						end
						--print(unitId, "Debuff Stealth Table Information Captured", name)
						tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory],["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
					end
				  end
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration debuffs
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
						if Priority == maxPriority and expirationTime-duration > newExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						end
					elseif durationType[spellCategory] then
						if Priority == maxPriority and expirationTime > maxExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						end
					end
				end
			end
		end

		-- Check buffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unitId, i)
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end
			if debug then print(unitId, "buff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end

      -----------------------------------------------------------------------------w
			--Ghost Wolf hack for Spectral Recovery and Spirit Wolf
			------------------------------------------------------------------------------
      if spellId == 2645 then
        local ghostwolf = {}
        for i = 1, 40 do
        local _, _, c, _, _, _, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
        if not s then break end
          if s == 204262 or s == 260881 then
            tblinsert(ghostwolf, {s, c})
          end
        end
        if #ghostwolf == 2 then
          if ghostwolf[1][1] == 260881 then
            count = ghostwolf[1][2]
          else
            count = ghostwolf[2][2]
          end
          hue = "GhostPurple"
        elseif #ghostwolf == 1 then
          if ghostwolf[1][1] == 260881 then --Just Spirit Wolf
            count = ghostwolf[1][2]
          elseif ghostwolf[1][1] == 204262 then -- Just Spectral Recovery
            hue = "GhostPurple"
          end
        end
      end

      -----------------------------------------------------------------------------------------------------------------
      --Icon Changes
      -----------------------------------------------------------------------------------------------------------------
      if spellId == 317929 then --Aura Mastery Cast Immune Pally
        icon = 135863
      end

      if spellId == 199545 then --Steed of Glory Hack
    		icon = 135890
    	end

			-----------------------------------------------------------------------------
			--Mass Invis
			------------------------------------------------------------------------------
			if (spellId == 198158) then --Mass Invis Hack
				if source then
					if (UnitGUID(source) ~= UnitGUID(unitId)) then
						duration = 5
				  	expirationTime = GetTime() + duration
					end
				end
			end
      -----------------------------------------------------------------------------
      --Player Only Hacks
      ------------------------------------------------------------------------------

      if (spellId == 331937) then --Euphoria Venthyr Haste Buff Hack
				if unitId ~= "player" then
          spellIds[spellId] = "None"
        else
          spellIds[spellId] = "Movable_Cast_Auras"
				end
			end

      if (spellId == 332505) then --Soulsteel Clamps Hack player Only
				if unitId ~= "player" then
          spellIds[spellId] = "None"
        else
          spellIds[spellId] = "Movable_Cast_Auras"
				end
			end

      if (spellId == 332506) then --Soulsteel Clamps Hack player Only
				if unitId ~= "player" then
          spellIds[spellId] = "None"
        else
          spellIds[spellId] = "Movable_Cast_Auras"
				end
			end
      -----------------------------------------------------------------------------
      --Same Spell Id , Differnt Spec , Change Prio
      ------------------------------------------------------------------------------

      if (spellId == 31884) then --Avenging Wrath
        local i, specID
        if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
          if strfind(unitId, "1") then i = 1 elseif strfind(unitId, "2") then i = 2 elseif strfind(unitId, "3") then i = 3 end
          specID = GetArenaOpponentSpec(i);
        elseif (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
          specID = GetInspectSpecialization(unitId)
        end
        if specID then
          if (specID == 70) or (specID == 66) then
            --print("Ret Wings Active "..unitId)
            spellIds[spellId] = "Big_Defensive_CDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
          else
            --print("Holy Wings Active "..unitId)
            spellIds[spellId] = "Big_Defensive_CDs" --Sets Prio to Holy Wings to Defensive
          end
        end
      end

      if (spellId == 310454) then --Weapons of Order
        local i, specID
        if (unitId == "arena1") or (unitId == "arena2") or (unitId == "arena3") then
          if strfind(unitId, "1") then i = 1 elseif strfind(unitId, "2") then i = 2 elseif strfind(unitId, "3") then i = 3 end
          specID = GetArenaOpponentSpec(i);
        elseif (UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) then
          specID = GetInspectSpecialization(unitId)
        end
        if specID then
          if (specID == 269) or (specID == 268) then
            --print("WW Weapons Active "..unitId)
            spellIds[spellId] = "Melee_Major_OffenisiveCDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
          else
            --print("MW Weapons Active "..unitId)
            spellIds[spellId] = "None" --Sets Prio to Holy Wings to Defensive
          end
        end
      end

      if spellId == 248646 then -- WW Tiger Eye Stacks, Removes Timer
        duration = 0
        expirationTime = GetTime() + 1
      end

      if spellId == 334320 then -- Lock Drain LIfe Stacks, Removes Timer
        duration = 0
        expirationTime = GetTime() + 1
      end


			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]


			if self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory] then
				if Priority then
					-----------------------------------------------------------------------------------------------------------------
					--Unseen Table Debuffs
					-----------------------------------------------------------------------------------------------------------------
					if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
					if typeUpdate == -200 and UnitExists(unitId) then
						if not Arenastealth[unitId] then
							Arenastealth[unitId] = {}
						end
						--print(unitId, "Buff Stealth Table Information Captured", name)
						tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
					end
			  	end
					---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration buffs
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
						if Priority == maxPriority and expirationTime-duration > newExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						end
					elseif durationType[spellCategory] then
						if Priority == maxPriority and expirationTime > maxExpirationTime then
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						elseif Priority > maxPriority then
							maxPriority = Priority
							maxExpirationTime = expirationTime
							newExpirationTime = expirationTime - duration
							Duration = duration
							Icon = icon
							forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
							Hue = hue
							Name = name
              Count = count
						end
					end
				end
			end
		end

		-- Check interrupts or cleu
		if ((self.unitGUID ~= nil) and (UnitIsPlayer(unitId) or (((unitId ~= "target") or (LoseControlDB.showNPCInterruptsTarget)) and ((unitId ~= "focus") or (LoseControlDB.showNPCInterruptsFocus)) and ((unitId ~= "targettarget") or (LoseControlDB.showNPCInterruptsTargetTarget)) and ((unitId ~= "focustarget") or (LoseControlDB.showNPCInterruptsFocusTarget))))) then
			local spellSchoolInteruptsTable = {
				[1] = {false, 0},
				[2] = {false, 0},
				[4] = {false, 0},
				[8] = {false, 0},
				[16] = {false, 0},
				[32] = {false, 0},
				[64] = {false, 0}
			}
			if (InterruptAuras[self.unitGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[self.unitGUID]) do
					local Priority = v.priority
					local spellCategory = v.spellCategory
					local expirationTime = v.expirationTime
					local duration = v.duration
					local icon = v.icon
					local spellSchool = v.spellSchool
					local hue = v.hue
					local name = v.name
					local spellId = v.spellId
					if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil; Priority = 0 end
					if spellCategory ~= "Interrupt" and ((Priority == 0) or (not self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory])) then
							if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
							end
					elseif (spellCategory == "Interrupt") and ((Priority == 0) or (not self.frame.categoriesEnabled.interrupt[reactionToPlayer])) then
							if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
							end
					else
						if Priority then
							-----------------------------------------------------------------------------------------------------------------
							--Unseen Table Debuffs
							-----------------------------------------------------------------------------------------------------------------
							if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
							if typeUpdate == -200 and UnitExists(unitId) then
								if not Arenastealth[unitId] then
									Arenastealth[unitId] = {}
								end
								--print(unitId, "cleu Stealth Table Information Captured", name)
								local localForceEventUnitAuraAtEnd = false
								tblinsert(Arenastealth[unitId],  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
							end
				  		end
							---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
							local localForceEventUnitAuraAtEnd = false
							tblinsert(buffs,  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue }}) -- this will create a table to show the highest duration cleu
							---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
							if spellSchool then -- Stop Interrupt Check when Trees Prio or SPELL_CAST_SUCCESS event
								for schoolIntId, _ in pairs(spellSchoolInteruptsTable) do
									if (bit_band(spellSchool, schoolIntId) > 0) then
										spellSchoolInteruptsTable[schoolIntId][1] = true
										if expirationTime > spellSchoolInteruptsTable[schoolIntId][2] then
											spellSchoolInteruptsTable[schoolIntId][2] = expirationTime
										end
									end
								end
							end
							if not durationType[spellCategory] then
								if Priority == maxPriority and expirationTime-duration > newExpirationTime then
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								elseif Priority > maxPriority then
									maxPriority = Priority
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								end
							elseif durationType[spellCategory] then
								if Priority == maxPriority and expirationTime > maxExpirationTime then
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								elseif Priority > maxPriority then
									maxPriority = Priority
									maxExpirationTime = expirationTime
									newExpirationTime = expirationTime - duration
									Duration = duration
									Icon = icon
									maxPriorityIsInterrupt = true
									forceEventUnitAuraAtEnd = false
									Hue = hue
									Name = name
									Spell = spellId
									local nextTimerUpdate = expirationTime - GetTime() + 0.05
									if nextTimerUpdate < 0.05 then
										nextTimerUpdate = 0.05
									end
									Ctimer(nextTimerUpdate, function()
										if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
											self:UNIT_AURA(unitId, 20)
										end
										for e, f in pairs(InterruptAuras) do
											for g, h in pairs(f) do
												if (h.expirationTime < GetTime()) then
													InterruptAuras[e][g] = nil
												end
											end
											if (next(InterruptAuras[e]) == nil) then
												InterruptAuras[e] = nil
											end
										end
									end)
								end
							end
						end
					end
				end
			end
			if _G.LoseControlDB.InterruptIcons then
				for schoolIntId, schoolIntFrame in pairs(self.iconInterruptList) do
					if spellSchoolInteruptsTable[schoolIntId][1] then
						if (not schoolIntFrame:IsShown()) then
							schoolIntFrame:Show()
						end
						local orderInt = 1
						for schoolInt2Id, schoolInt2Info in pairs(spellSchoolInteruptsTable) do
							if ((schoolInt2Info[1]) and ((spellSchoolInteruptsTable[schoolIntId][2] < schoolInt2Info[2]) or ((spellSchoolInteruptsTable[schoolIntId][2] == schoolInt2Info[2]) and (schoolIntId > schoolInt2Id)))) then
								orderInt = orderInt + 1
							end
						end
						schoolIntFrame:SetPoint("BOTTOMRIGHT", self.interruptIconOrderPos[orderInt][1], self.interruptIconOrderPos[orderInt][2])
						schoolIntFrame.interruptIconOrder = orderInt
					elseif schoolIntFrame:IsShown() then
						schoolIntFrame.interruptIconOrder = nil
						schoolIntFrame:Hide()
					end
				end
			end
		end
	end
----------------------------------------------------------------------
--Filters for highest aura duration of specfied priority will not work for cleu , currently set for all snares
----------------------------------------------------------------------
	if #buffs then
		tblsort(buffs, cmp_col1)
		tblsort(buffs, cmp_col1_col2)
	end

----------------------------------------------------------------------
--transfer stealth table to buffs
----------------------------------------------------------------------
if Arenastealth[unitId] and (not UnitExists(unitId)) then
	for i = 1, #Arenastealth[unitId] do
	  buffs[i] =  {["col1"] = Arenastealth[unitId][i].col1 , ["col2"]  = Arenastealth[unitId][i].col2 , ["col3"] = { ["name"] = Arenastealth[unitId][i].col3.name, ["duration"] = Arenastealth[unitId][i].col3.duration, ["expirationTime"] = Arenastealth[unitId][i].col3.expirationTime,  ["icon"] = Arenastealth[unitId][i].col3.icon, ["localForceEventUnitAuraAtEnd"] = Arenastealth[unitId][i].col3.localForceEventUnitAuraAtEnd, ["hue"] = Arenastealth[unitId][i].col3.hue }}
	end
	tblsort(buffs, cmp_col1)
	tblsort(buffs, cmp_col1_col2)
end

-----------------------------------------------------------------------
--Stealth Filter What to show while unseen Arena Opponents
-------------------------------------------------------------------------
	if (not UnitExists(unitId)) then
		if (unitId =="arena1") or (unitId =="arena2") or (unitId =="arena3") then
			 if Arenastealth[unitId] and #buffs then
				 local foundbuff = 0
				 for i = 1, #buffs do
					 	if ((buffs[i].col3.expirationTime > GetTime() + .10) and (buffs[i].col3.duration ~= 0 ) and (buffs[i].col1 >= priority.Special_High)) then --Special_High is Stealth for Arena
								maxExpirationTime = buffs[i].col3.expirationTime
								Duration = buffs[i].col3.duration
								Icon = buffs[i].col3.icon
								forceEventUnitAuraAtEnd = false
								Hue = buffs[i].col3.hue
								Name = buffs[i].col3.name
								local nextTimerUpdate = (buffs[i].col3.expirationTime - GetTime()) + 0.05
								if nextTimerUpdate < 0.05 then
									nextTimerUpdate = 0.05
								end
								Ctimer(nextTimerUpdate, function()
										self:UNIT_AURA(unitId, -5)
								end)
								foundbuff = 1
								--print(unitId, "Unseen or Stealth w/", buffs[i].col3.name)
								break
							elseif ((buffs[i].col1 == priority.Special_High) or (buffs[i].col3.name == "FriendlyShadowyDuel") or (buffs[i].col3.name == "EnemyShadowyDuel")) then --and ((duration == 0) or (buffs[i].col3.expirationTime < (GetTime() + .10))) then
								maxExpirationTime = GetTime() + 1
								Duration = 0
								Icon = buffs[i].col3.icon
								forceEventUnitAuraAtEnd = false
								Hue = buffs[i].col3.hue
								Name = buffs[i].col3.name
								foundbuff = 1
								--print(unitId, "Permanent Stealthed w/", buffs[i].col3.name)
								break
							end
						end
						if foundbuff == 0 then
							maxExpirationTime = 0
							Duration = Duration
							Icon = Icon
							forceEventUnitAuraAtEnd = forceEventUnitAuraAtEnd
							Hue = Hue
							Name = Name
							--print(unitId, "No Stealth Buff Found")
							if unitId == "arena1" and GladiusClassIconFramearena1 and GladiusHealthBararena1 then
								GladiusClassIconFramearena1:SetAlpha(GladiusHealthBararena1:GetAlpha())
							end
							if unitId == "arena2" and GladiusClassIconFramearena2 and GladiusHealthBararena2 then
								GladiusClassIconFramearena2:SetAlpha(GladiusHealthBararena2:GetAlpha())
							end
							if unitId == "arena3" and GladiusClassIconFramearena3 and GladiusHealthBararena3 then
								GladiusClassIconFramearena3:SetAlpha(GladiusHealthBararena3:GetAlpha())
							end
            end
					end
		    end
		  end


	for i = 1, #buffs do --creates a layered hue for every icon when a specific priority, or spellid is present
		if not buffs[i] then break end
			if (buffs[i].col3.name == "EnemySmokeBomb") or (buffs[i].col3.name == "EnemyShadowyDuel") then --layered hue conidition
				if buffs[i].col3.expirationTime > GetTime() then
					if LoseControlDB.RedSmokeBomb then
					LayeredHue = true
					Hue = "Red"
					end
				local remaining = buffs[i].col3.expirationTime - GetTime() -- refires on layer exit, to reset the icons
				if  remaining  < 0.05 then
					 remaining  = 0.05
				end
				Ctimer(remaining + .05, function() self:UNIT_AURA(unitId, -55) end)
				end
			end
		end



	if (maxExpirationTime == 0) then -- no (de)buffs found
		self.maxExpirationTime = 0
		if self.anchor ~= UIParent and self.drawlayer then
			self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer
		end
		if self.iconInterruptBackground:IsShown() then
			self.iconInterruptBackground:Hide()
		end
		if self.gloss:IsShown() then
			self.gloss:Hide()
		end
    if self.count:IsShown() then
    self.count:Hide()
    end
		self:Hide()
		self:GetParent():Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime or ((LayeredHue) or (typeUpdate == -55) or (not UnitExists(unitId)))  then -- this is a different (de)buff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		if self.anchor ~= UIParent then
			self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard") and 3 or 0)) -- must be dynamic, frame level changes all the time
			if not self.drawlayer and self.anchor.GetDrawLayer then
				self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
			end
			if self.drawlayer and self.anchor.SetDrawLayer then
				self.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
			end
		end

		if LoseControlDB.EnableGladiusGloss and (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3")  or (self.unitId == "arena4") or (self.unitId == "arena5") and (self.frame.anchor == "Gladius") then
			self.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
			self.gloss.normalTexture = _G[self.gloss:GetName().."NormalTexture"]
			self.gloss.normalTexture:SetHeight(self.frame.size)
			self.gloss.normalTexture:SetWidth(self.frame.size)
			self.gloss.normalTexture:SetScale(.9)
			self.gloss.normalTexture:ClearAllPoints()
			self.gloss.normalTexture:SetPoint("CENTER", self, "CENTER")
			self.gloss:SetNormalTexture("Interface\\AddOns\\LoseControl\\Textures\\Gloss")
			self.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
			self.gloss:SetFrameLevel((self:GetParent():GetFrameLevel()) + 10)
			if (not self.gloss:IsShown()) then
				self.gloss:Show()
			end
		else
			if self.gloss:IsShown() then
				self.gloss:Hide()
			end
		end

    if Count then
        if (unitId == "player" or unitId == "party1" or unitId == "party2" or unitId == "party3" or unitId == "party4") and not ((unitId == "player") and (self.frame.anchor == "Blizzard")) then
         if ( Count > 1 ) then
          local countText = Count
          if ( Count >= 100 ) then
           countText = BUFF_STACKS_OVERFLOW
          end
          self.count:ClearAllPoints()
          self.count:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE, MONOCHROME")
          self.count:SetPoint("TOPRIGHT", -1, 8);
          self.count:SetJustifyH("RIGHT");
          self.count:Show();
          self.count:SetText(countText)
         else
          if self.count:IsShown() then
            self.count:Hide()
          end
         end
      elseif (unitId == "arena1" or unitId == "arena2" or unitId == "arena3") and (self.frame.anchor == "Gladius") then
        if ( Count > 1 ) then
         local countText = Count
         if ( Count >= 100 ) then
          countText = BUFF_STACKS_OVERFLOW
         end
         self.count:ClearAllPoints()
         self.count:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, MONOCHROME")
         self.count:SetPoint("BOTTOMRIGHT", 0, 0);
         self.count:SetJustifyH("RIGHT");
         self.count:Show();
         self.count:SetText(countText)
        else
         if self.count:IsShown() then
           self.count:Hide()
         end
        end
       end
    else
      if self.count:IsShown() then
        self.count:Hide()
      end
    end

		if maxPriorityIsInterrupt then
			if self.frame.anchor == "Blizzard" then
				if LoseControlDB.InterruptOverlay and interruptsIds[Spell] then
				self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait") --CHRIS
				end
			else
				if LoseControlDB.InterruptOverlay and interruptsIds[Spell] then
				self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background") --CHRIS
				end
			end
			if (not self.iconInterruptBackground:IsShown()) then
				self.iconInterruptBackground:Show()
			end
		else
			if self.iconInterruptBackground:IsShown() then
				self.iconInterruptBackground:Hide()
			end
		end
		if not interruptsIds[Spell] then
			if self.iconInterruptBackground:IsShown() then
				self.iconInterruptBackground:Hide()
			end
		end
		if self.frame.anchor == "Blizzard" then  --CHRIS DISABLE SQ
      if Hue then
        if Hue == "Red" then -- Changes Icon Hue to Red
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
          self.texture:SetDesaturated(nil) --Destaurate  Icon
          self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate  Icon
          self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Smoke Bomb Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
          SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
          self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(.65, .5, .9);  --Purple Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        end
      else
        SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
        self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
        self.texture:SetDesaturated(nil) --Destaurate Icon
        self.texture:SetVertexColor(1, 1, 1)
        self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
      end
		else
      if Hue then
        if Hue == "Red" then -- Changes Icon Hue to Red
          self.texture:SetTexture(Icon)   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
          self.texture:SetTexture(Icon)   --SetIcon
          self.texture:SetDesaturated(nil) --Destaurate Icon
          self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
          self.texture:SetTexture(Icon)   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
          self.texture:SetTexture(Icon)   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
          self.texture:SetTexture(Icon)   --Set Icon
          self.texture:SetDesaturated(1) --Destaurate Icon
          self.texture:SetVertexColor(.65, .5, .9); --Purple Hue Set For Icon
          self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
        end
      else
        self.texture:SetTexture(Icon)
        self.texture:SetDesaturated(nil) --Destaurate Icon
        self.texture:SetVertexColor(1, 1, 1)
        self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
      end
		end
		if forceEventUnitAuraAtEnd and maxExpirationTime > 0 and Duration > 0 then
			local nextTimerUpdate = maxExpirationTime - GetTime() + 0.10
			if nextTimerUpdate < 0.10 then
				nextTimerUpdate = 0.10
			end
			Ctimer(nextTimerUpdate, function()
				if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.08))) then
					self:UNIT_AURA(unitId, 4)
				end
			end)
		end
		self:Show()
		self:GetParent():Show()
		if Duration > 0 then
			if not self:GetDrawSwipe() then
				self:SetDrawSwipe(false) --SET TO FALSE TO DISABLE DRAWSWIPE , ADD OPTION FOR THIS
			end
			self:SetCooldown( maxExpirationTime - Duration, Duration )
		else
			if self:GetDrawSwipe() then
				if LoseControlDB.DrawSwipeSetting > 0 then
				self:SetDrawSwipe(true)
				else
				self:SetDrawSwipe(false)
				end
			end
			self:SetCooldown(GetTime(), 0)
			self:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
		end
					if (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3") or (self.unitId == "arena4") or (self.unitId == "arena5") then --Chris sets alpha timer/frame inherot of frame of selected units
						if self.frame.anchor == "Gladius" then
							self:GetParent():SetAlpha(self.anchor:GetAlpha())
							if (not UnitExists(unitId)) then
								if unitId == "arena1" and GladiusClassIconFramearena1 then
									self:GetParent():SetAlpha(0.8)
									GladiusClassIconFramearena1:SetAlpha(0)
								end
								if unitId == "arena2" and GladiusClassIconFramearena2 then
									self:GetParent():SetAlpha(0.8)
									GladiusClassIconFramearena2:SetAlpha(0)
								end
								if unitId == "arena3" and GladiusClassIconFramearena3 then
									self:GetParent():SetAlpha(0.8)
									GladiusClassIconFramearena3:SetAlpha(0)
								end
								end
							end
			  	else
						self:GetParent():SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
				end
		end
end




function LoseControl:PLAYER_FOCUS_CHANGED()
	--if (debug) then print("PLAYER_FOCUS_CHANGED") end
	if (self.unitId == "focus" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, -10)
		end
	end
end

function LoseControl:PLAYER_TARGET_CHANGED()
	--if (debug) then print("PLAYER_TARGET_CHANGED") endw
	if (self.unitId == "target" or self.unitId == "targettarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, -11)
		end
	end
end

function LoseControl:UNIT_TARGET(unitId)
	--if (debug) then print("UNIT_TARGET", unitId) end
	if (self.unitId == "targettarget" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, -12)
		end
	end
end

function LoseControl:UNIT_PET(unitId)
	--if (debug) then print("UNIT_PET", unitId) end
	if (self.unitId == "pet") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, -13)
		end
	end
end

-- Handle mouse dragging
function LoseControl:StopMoving()
	local frame = LoseControlDB.frames[self.unitId]
	frame.point, frame.anchor, frame.relativePoint, frame.x, frame.y = self:GetPoint()
	if not frame.anchor then
		frame.anchor = "None"
		local AnchorDropDown = _G['LoseControlOptionsPanel'..self.unitId..'AnchorDropDown']
		if (AnchorDropDown) then
			UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		end
		if self.MasqueGroup then
			self.MasqueGroup:RemoveButton(self:GetParent())
			self.MasqueGroup:AddButton(self:GetParent(), {
				FloatingBG = false,
				Icon = self.texture,
				Cooldown = self,
				Flash = _G[self:GetParent():GetName().."Flash"],
				Pushed = self:GetParent():GetPushedTexture(),
				Normal = self:GetParent():GetNormalTexture(),
				Disabled = self:GetParent():GetDisabledTexture(),
				Checked = false,
				Border = _G[self:GetParent():GetName().."Border"],
				AutoCastable = false,
				Highlight = self:GetParent():GetHighlightTexture(),
				Hotkey = _G[self:GetParent():GetName().."HotKey"],
				Count = _G[self:GetParent():GetName().."Count"],
				Name = _G[self:GetParent():GetName().."Name"],
				Duration = false,
				Shine = _G[self:GetParent():GetName().."Shine"],
			}, "Button", true)
		end
	end
	self.anchor = _G[anchors[frame.anchor][self.unitId]] or (type(anchors[frame.anchor][self.unitId])=="table" and anchors[frame.anchor][self.unitId] or UIParent)
	self:ClearAllPoints()
	self:GetParent():ClearAllPoints()
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	if self.MasqueGroup then
		self.MasqueGroup:ReSkin()
	end
	self:StopMovingOrSizing()
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown", addonName .. unitId, nil, 'CooldownFrameTemplate') --, UIParent)
	local op = CreateFrame("Button", addonName .. "ButtonParent" .. unitId, nil, 'ActionButtonTemplate')
	op:EnableMouse(false)
	if op:GetPushedTexture() ~= nil then op:GetPushedTexture():SetAlpha(0) op:GetPushedTexture():Hide() end
	if op:GetNormalTexture() ~= nil then op:GetNormalTexture():SetAlpha(0) op:GetNormalTexture():Hide() end
	if op:GetDisabledTexture() ~= nil then op:GetDisabledTexture():SetAlpha(0) op:GetDisabledTexture():Hide() end
	if op:GetHighlightTexture() ~= nil then op:GetHighlightTexture():SetAlpha(0) op:GetHighlightTexture():Hide() end
	if _G[op:GetName().."Shine"] ~= nil then _G[op:GetName().."Shine"]:SetAlpha(0) _G[op:GetName().."Shine"]:Hide() end
	if _G[op:GetName().."Count"] ~= nil then _G[op:GetName().."Count"]:SetAlpha(0) _G[op:GetName().."Count"]:Hide() end
	if _G[op:GetName().."HotKey"] ~= nil then _G[op:GetName().."HotKey"]:SetAlpha(0) _G[op:GetName().."HotKey"]:Hide() end
	if _G[op:GetName().."Flash"] ~= nil then _G[op:GetName().."Flash"]:SetAlpha(0) _G[op:GetName().."Flash"]:Hide() end
	if _G[op:GetName().."Name"] ~= nil then _G[op:GetName().."Name"]:SetAlpha(0) _G[op:GetName().."Name"]:Hide() end
	if _G[op:GetName().."Border"] ~= nil then _G[op:GetName().."Border"]:SetAlpha(0) _G[op:GetName().."Border"]:Hide() end
	if _G[op:GetName().."Icon"] ~= nil then _G[op:GetName().."Icon"]:SetAlpha(0) _G[op:GetName().."Icon"]:Hide() end


	setmetatable(o, self)
	self.__index = self

	o:SetParent(op)
	o.parent = op


	o:SetDrawEdge(false)

	-- Init class members
	if unitId == "player2" then
		o.unitId = "player" -- ties the object to a unit
		o.fakeUnitId = unitId
	else
		o.unitId = unitId -- ties the object to a unit
	end
	o:SetAttribute("unit", o.unitId)
	o.texture = o:CreateTexture(nil, "BORDER") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	o.text = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	o.text:SetText(L[o.unitId])
	o.text:SetPoint("BOTTOM", o, "BOTTOM")
	o.text:Hide()

  o.count = o.CreateFontString(o, "OVERLAY", "GameFontWhite");
  o.count:Hide()


-----------------------------------------------------------------------------------

	o:Hide()
	op:Hide()

	o.gloss = CreateFrame("Button", addonName .. "Gloss" .. unitId, nil, 'ActionButtonTemplate')
--	o.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
--	o.gloss.normalTexture = _G[o.gloss:GetName().."NormalTexture"]
--	o.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
	o.gloss:Hide()

	-- Create and initialize Interrupt Mini Icons
	o.iconInterruptBackground = o:CreateTexture(addonName .. unitId .. "InterruptIconBackground", "ARTWORK", nil, -2)
	--o.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background")
	o.iconInterruptBackground:SetAlpha(0.7)
	o.iconInterruptBackground:SetPoint("TOPLEFT", 0, 0)
	o.iconInterruptBackground:Hide()
	o.iconInterruptPhysical = o:CreateTexture(addonName .. unitId .. "InterruptIconPhysical", "ARTWORK", nil, -1)
	o.iconInterruptPhysical:SetTexture("Interface\\Icons\\Ability_meleedamage")
	o.iconInterruptHoly = o:CreateTexture(addonName .. unitId .. "InterruptIconHoly", "ARTWORK", nil, -1)
	o.iconInterruptHoly:SetTexture("Interface\\Icons\\Spell_holy_holybolt")
	o.iconInterruptFire = o:CreateTexture(addonName .. unitId .. "InterruptIconFire", "ARTWORK", nil, -1)
	o.iconInterruptFire:SetTexture("Interface\\Icons\\Spell_fire_selfdestruct")
	o.iconInterruptNature = o:CreateTexture(addonName .. unitId .. "InterruptIconNature", "ARTWORK", nil, -1)
	o.iconInterruptNature:SetTexture("Interface\\Icons\\Spell_nature_protectionformnature")
	o.iconInterruptFrost = o:CreateTexture(addonName .. unitId .. "InterruptIconFrost", "ARTWORK", nil, -1)
	o.iconInterruptFrost:SetTexture("Interface\\Icons\\Spell_frost_icestorm")
	o.iconInterruptShadow = o:CreateTexture(addonName .. unitId .. "InterruptIconShadow", "ARTWORK", nil, -1)
	o.iconInterruptShadow:SetTexture("Interface\\Icons\\Spell_shadow_antishadow")
	o.iconInterruptArcane = o:CreateTexture(addonName .. unitId .. "InterruptIconArcane", "ARTWORK", nil, -1)
	o.iconInterruptArcane:SetTexture("Interface\\Icons\\Spell_nature_wispsplode")
	o.iconInterruptList = {
		[1] = o.iconInterruptPhysical,
		[2] = o.iconInterruptHoly,
		[4] = o.iconInterruptFire,
		[8] = o.iconInterruptNature,
		[16] = o.iconInterruptFrost,
		[32] = o.iconInterruptShadow,
		[64] = o.iconInterruptArcane
	}
	for _, v in pairs(o.iconInterruptList) do
		v:SetAlpha(.8) --hide Interrupt Icons
		v:Hide()
		SetPortraitToTexture(v, v:GetTexture())
		v:SetTexCoord(0.08,0.92,0.08,0.92)
	end

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function

	o:RegisterEvent("PLAYER_ENTERING_WORLD")
	o:RegisterEvent("GROUP_ROSTER_UPDATE")
	o:RegisterEvent("GROUP_JOINED")
	o:RegisterEvent("GROUP_LEFT")
	o:RegisterEvent("ARENA_OPPONENT_UPDATE")
	o:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

	return o
end

-- Create new object instance for each frame
for k in pairs(DBdefaults.frames) do
	if (k ~= "player2") then
		LCframes[k] = LoseControl:new(k)
	end
end
LCframeplayer2 = LoseControl:new("player2")

-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = addonName .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(addonName)

local unlocknewline = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
unlocknewline:SetText("If a icon is Anchored, the Anchor must be showing, find a Target, TargetofTarget, FocusTarget ,FocusTargetofTarget")

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(addonName, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(addonName, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(L["Unlock"])
function Unlock:OnClick()
	if self:GetChecked() then
		_G[O.."UnlockText"]:SetText(L["Unlock"] .. L[" (drag an icon to move)"])
		unlocknewline:SetPoint("TOPLEFT", title, "TOPLEFT", 0, 23)
		unlocknewline:Show()
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LCframes) do
			v.maxExpirationTime = 0
			v.unlockMode = true
			local frame = LoseControlDB.frames[k]
			if frame.enabled and (_G[anchors[frame.anchor][k]] or (type(anchors[frame.anchor][k])=="table" and anchors[frame.anchor][k] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
				v:RegisterUnitEvents(false)
				v.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
				if _G[anchors[frame.anchor][k]] then
					if not _G[anchors[frame.anchor][k]]:IsVisible() then
						local frame = anchors[frame.anchor][k]
					 end
				end
				if frame.anchor == "None" then
				v.parent:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
				elseif frame.anchor == "Blizzard" then
				v.parent:SetParent(v.anchor:GetParent())
				end
				if v.anchor:GetParent() then
					v:SetFrameLevel(v.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
				v.text:Show()
				v:Show()
				v:GetParent():Show()
				v:SetDrawSwipe(true)
				v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
				v:SetCooldown( GetTime(), 60 )
				v:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
				v:SetMovable(true)
				v:RegisterForDrag("LeftButton")
				v:EnableMouse(true)
			end
		end
		LCframeplayer2.maxExpirationTime = 0
		LCframeplayer2.unlockMode = true
		local frame = LoseControlDB.frames.player2
		if frame.enabled and (_G[anchors[frame.anchor][LCframeplayer2.unit]] or (type(anchors[frame.anchor][LCframeplayer2.unit])=="table" and anchors[frame.anchor][LCframeplayer2.unit] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
			LCframeplayer2:RegisterUnitEvents(false)
			LCframeplayer2.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
			if frame.anchor == "None" then
			LCframeplayer2.parent:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
			end
			if LCframeplayer2.anchor:GetParent() then
				LCframeplayer2:SetFrameLevel(LCframeplayer2.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			LCframeplayer2.text:Show()
			LCframeplayer2:Show()
			LCframeplayer2:GetParent():Show()
			LCframeplayer2:SetDrawSwipe(true)
			LCframeplayer2:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
			LCframeplayer2:SetCooldown( GetTime(), 60 )
			LCframeplayer2:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
		end
	else
		_G[O.."UnlockText"]:SetText(L["Unlock"])
		for _, v in pairs(LCframes) do
			unlocknewline:Hide()
			v.unlockMode = falseI
			v:EnableMouse(false)
			v:RegisterForDrag()
			v:SetMovable(false)
			v.text:Hide()
			v:PLAYER_ENTERING_WORLD()
		end
		LCframeplayer2.unlockMode = false
		LCframeplayer2.text:Hide()
		LCframeplayer2:PLAYER_ENTERING_WORLD()
	end
end
Unlock:SetScript("OnClick", Unlock.OnClick)

local DisableBlizzardCooldownCount = CreateFrame("CheckButton", O.."DisableBlizzardCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableBlizzardCooldownCountText"]:SetText(L["Disable Blizzard Countdown"])
function DisableBlizzardCooldownCount:Check(value)
	LoseControlDB.noBlizzardCooldownCount = value
	LoseControl.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
	LoseControl:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	for _, v in pairs(LCframes) do
		v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	end
	LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
end
DisableBlizzardCooldownCount:SetScript("OnClick", function(self)
	DisableBlizzardCooldownCount:Check(self:GetChecked())
end)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(L["Disable OmniCC Support"])
DisableCooldownCount:SetScript("OnClick", function(self)
	LoseControlDB.noCooldownCount = self:GetChecked()
	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
	if self:GetChecked() then
		DisableBlizzardCooldownCount:Enable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
	else
		DisableBlizzardCooldownCount:Disable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
		DisableBlizzardCooldownCount:SetChecked(true)
		DisableBlizzardCooldownCount:Check(true)
	end
end)

local DisableLossOfControlCooldownAuxText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
DisableLossOfControlCooldownAuxText:SetText(L["NeedsReload"])
DisableLossOfControlCooldownAuxText:SetTextColor(1,0,0)
DisableLossOfControlCooldownAuxText:Hide()

local DisableLossOfControlCooldownAuxButton = CreateFrame("Button", O.."DisableLossOfControlCooldownAuxButton", OptionsPanel, "OptionsButtonTemplate")
_G[O.."DisableLossOfControlCooldownAuxButtonText"]:SetText(L["ReloadUI"])
DisableLossOfControlCooldownAuxButton:SetHeight(12)
DisableLossOfControlCooldownAuxButton:Hide()
DisableLossOfControlCooldownAuxButton:SetScript("OnClick", function(self)
	ReloadUI()
end)

local DisableLossOfControlCooldown = CreateFrame("CheckButton", O.."DisableLossOfControlCooldown", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableLossOfControlCooldownText"]:SetText(L["DisableLossOfControlCooldownText"])
DisableLossOfControlCooldown:SetScript("OnClick", function(self)
	LoseControlDB.noLossOfControlCooldown = self:GetChecked()
	LoseControl.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
	if (self:GetChecked()) then
		LoseControl:DisableLossOfControlUI()
		DisableLossOfControlCooldownAuxText:Hide()
		DisableLossOfControlCooldownAuxButton:Hide()
	else
		DisableLossOfControlCooldownAuxText:Show()
		DisableLossOfControlCooldownAuxButton:Show()
	end
end)

local LossOfControlSpells = CreateFrame("Button", O.."LossOfControlSpells", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpells"]:SetText("PVP Spells")
LossOfControlSpells:SetHeight(18)
LossOfControlSpells:SetWidth(185)
LossOfControlSpells:SetScale(1)
LossOfControlSpells:SetScript("OnClick", function(self)
L.SpellsConfig:Toggle()
end)
local LossOfControlSpellsArena = CreateFrame("Button", O.."LossOfControlSpellsArena", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpellsArena"]:SetText("Arena123")
LossOfControlSpellsArena:SetHeight(18)
LossOfControlSpellsArena:SetWidth(185)
LossOfControlSpellsArena:SetScale(1)
LossOfControlSpellsArena:SetScript("OnClick", function(self)
L.SpellsArenaConfig:Toggle()
end)
local LossOfControlSpellsPVE = CreateFrame("Button", O.."LossOfControlSpellsPVE", OptionsPanel, "OptionsButtonTemplate")
_G[O.."LossOfControlSpellsPVE"]:SetText("PVE Spells")
LossOfControlSpellsPVE:SetHeight(18)
LossOfControlSpellsPVE:SetWidth(185)
LossOfControlSpellsPVE:SetScale(1)
LossOfControlSpellsPVE:SetScript("OnClick", function(self)
L.SpellsPVEConfig:Toggle()
end)

local Priority = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Priority:SetText(L["Priority"])

local PriorityDescription = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
PriorityDescription:SetText(L["PriorityDescription"])

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv
local function CreateSlider(text, parent, low, high, step, globalName)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(150)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	return slider
end

local function CreateSliderMain(text, parent, low, high, step, globalName)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(185)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	return slider
end



local DrawSwipeSlider = CreateSliderMain(nil, OptionsPanel, 0, 1, .1, "DrawSwipe")
DrawSwipeSlider:SetScript("OnValueChanged", function(self, value)
_G["DrawSwipeText"]:SetText("DrawSwipe" .. " (" .. ("%.1f"):format(value) .. ")")
LoseControlDB.DrawSwipeSetting = value
end)

local PrioritySlider = {}
for k in pairs(DBdefaults.priority) do
	PrioritySlider[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "Priority"..k.."Slider")
	PrioritySlider[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

local PrioritySliderArena = {}
for k in pairs(DBdefaults.priorityArena) do
	PrioritySliderArena[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "priorityArena"..k.."Slider")
	PrioritySliderArena[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

-------------------------------------------------------------------------------
-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 8, -10)

local BambiText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
BambiText:SetFont("Fonts\\MORPHEUS.ttf", 14 )
BambiText:SetText("By ".."|cff00ccffBambi|r")
BambiText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 38, 1)

Unlock:SetPoint("TOPLEFT",  title, "BOTTOMLEFT", 110, 22)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, 6)

DisableBlizzardCooldownCount:SetPoint("TOPLEFT", subText, "TOPRIGHT", 15, 10)
DisableLossOfControlCooldownAuxButton:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 54, -5)

Priority:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
subText:SetPoint("TOPLEFT", Priority, "BOTTOMLEFT", 0, -3)
PriorityDescription:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -3)

PrioritySlider.CC:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", 0, -45)
PrioritySlider.Silence:SetPoint("TOPLEFT", PrioritySlider.CC, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootPhyiscal_Special:SetPoint("TOPLEFT", PrioritySlider.Silence, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootMagic_Special:SetPoint("TOPLEFT", PrioritySlider.RootPhyiscal_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.Root:SetPoint("TOPLEFT", PrioritySlider.RootMagic_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePlayer:SetPoint("TOPLEFT", PrioritySlider.Root, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm_Warning:SetPoint("TOPLEFT", PrioritySlider.ImmunePlayer, "BOTTOMLEFT", 0, -14)
PrioritySlider.CC_Warning:SetPoint("TOPLEFT", PrioritySlider.Disarm_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Enemy_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.CC_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Stealth:SetPoint("TOPLEFT", PrioritySlider.Enemy_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Immune:SetPoint("TOPLEFT", PrioritySlider.Stealth, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmuneSpell:SetPoint("TOPLEFT", PrioritySlider.Immune, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePhysical:SetPoint("TOPLEFT", PrioritySlider.ImmuneSpell, "BOTTOMLEFT", 0, -14)
PrioritySlider.AuraMastery_Cast_Auras:SetPoint("TOPLEFT", PrioritySlider.ImmunePhysical, "BOTTOMLEFT", 0, -14)
PrioritySlider.ROP_Vortex:SetPoint("TOPLEFT", PrioritySlider.AuraMastery_Cast_Auras, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm:SetPoint("TOPLEFT", PrioritySlider.ROP_Vortex, "BOTTOMLEFT", 0, -14)
PrioritySlider.Haste_Reduction:SetPoint("TOPLEFT", PrioritySlider.Disarm, "BOTTOMLEFT", 0, -14)
PrioritySlider.Dmg_Hit_Reduction:SetPoint("TOPLEFT", PrioritySlider.Haste_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.Interrupt:SetPoint("TOPLEFT", PrioritySlider.Dmg_Hit_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_DMG_Modifiers:SetPoint("TOPLEFT", PrioritySlider.Interrupt, "BOTTOMLEFT", 0, -14)
PrioritySlider.Friendly_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.AOE_DMG_Modifiers, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_Spell_Refections:SetPoint("TOPLEFT", PrioritySlider.Friendly_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Trees:SetPoint("TOPLEFT", PrioritySlider.AOE_Spell_Refections, "BOTTOMLEFT", 0, -14)

PrioritySlider.Snare:SetPoint("TOPLEFT", PrioritySlider.Trees, "TOPRIGHT", 42, 0)
PrioritySlider.SnareMagic30:SetPoint("BOTTOMLEFT", PrioritySlider.Snare, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical30:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePosion50:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePosion50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic70:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical70:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic70, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareSpecial:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical70, "TOPLEFT", 0, -14*-1)
PrioritySlider.PvE:SetPoint("BOTTOMLEFT", PrioritySlider.SnareSpecial, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Other:SetPoint("BOTTOMLEFT", PrioritySlider.PvE, "TOPLEFT", 0, -14*-1)
PrioritySlider.Movable_Cast_Auras:SetPoint("BOTTOMLEFT", PrioritySlider.Other, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Peronsal_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.Movable_Cast_Auras, "TOPLEFT", 0, -14*-1)
PrioritySlider.Personal_Offensives:SetPoint("BOTTOMLEFT", PrioritySlider.Peronsal_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.CC_Reduction:SetPoint("BOTTOMLEFT", PrioritySlider.Personal_Offensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Mana_Regen:SetPoint("BOTTOMLEFT", PrioritySlider.CC_Reduction, "TOPLEFT", 0, -14*-1)
PrioritySlider.Friendly_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.Mana_Regen, "TOPLEFT", 0, -14*-1)
PrioritySlider.Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Friendly_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Speed_Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Freedoms, "TOPLEFT", 0, -14*-1)

PrioritySliderArena.Snares_Casted_Melee:SetPoint("TOPLEFT", PrioritySlider.Snare, "TOPRIGHT", 42, 0)
PrioritySliderArena.Snares_Ranged_Spamable:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Casted_Melee, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_Low:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Ranged_Spamable, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Snares_WithCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_Low, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Freedoms_Speed:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_WithCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Freedoms_Speed, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Offenisive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Player_Party_OffensiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Offenisive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Big_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Player_Party_OffensiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Melee_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Big_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Disarms:SetPoint("BOTTOMLEFT", PrioritySliderArena.Melee_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Roots_90_Snares:SetPoint("BOTTOMLEFT", PrioritySliderArena.Disarms, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Ranged_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Roots_90_Snares, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_High:SetPoint("BOTTOMLEFT", PrioritySliderArena.Ranged_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Interrupt:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_High, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Silence_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Interrupt, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.CC_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Silence_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Immune_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.CC_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Drink_Purge:SetPoint("BOTTOMLEFT", PrioritySliderArena.Immune_Arena, "TOPLEFT", 0, -14*-1)

local durationTypeCheckBoxNew = {}
local durationTypeCheckBoxHigh = {}

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k] = CreateFrame("CheckButton", O.."durationTypeNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k] = CreateFrame("CheckButton", O.."durationTypeHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxNew[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k]:SetPoint("TOPLEFT", "Priority"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k]:SetPoint("TOPLEFT", O.."durationTypeNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxHigh[k]:SetScale(.8)
end

local durationTypeCheckBoxArenaNew = {}
local durationTypeCheckBoxArenaHigh = {}

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k] = CreateFrame("CheckButton", O.."durationTypeArenaNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k] = CreateFrame("CheckButton", O.."durationTypeArenaHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaNew[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k]:SetPoint("TOPLEFT", "priorityArena"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxArenaNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k]:SetPoint("TOPLEFT", O.."durationTypeArenaNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxArenaHigh[k]:SetScale(.8)
end

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeArenaText:SetPoint("BOTTOMLEFT", O.."durationTypeArenaNewDrink_Purge", "TOPLEFT", 1, 0)

local durtiontypeText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText:SetPoint("BOTTOMLEFT", O.."durationTypeNewCC", "TOPLEFT", 1, 0)

local durtiontypeText2 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText2:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText2:SetPoint("BOTTOMLEFT", O.."durationTypeNewSpeed_Freedoms", "TOPLEFT", 1, 0)

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("Set the duration for the priority:".."|cff00ccff[N]|r Newest Spell to affect you vs ".."|cffff0000[H] |r Highest duration spell affecting you ")
durtiontypeArenaText:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", -1, -3)

LossOfControlSpells:SetPoint("CENTER",PrioritySlider.Speed_Freedoms, "CENTER", 8, 55)
LossOfControlSpellsPVE:SetPoint("CENTER", LossOfControlSpells, "CENTER", 0, -20)
LossOfControlSpellsArena:SetPoint("CENTER", PrioritySliderArena.Drink_Purge, "CENTER", 8, 36)


SetInterruptIcons = CreateFrame("CheckButton", O.."SetInterruptIcons", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptIconsText"]:SetText("Enable Interrupt Icons")
SetInterruptIcons:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.InterruptIcons = true
	else
		LoseControlDB.InterruptIcons = false
	end
end)

SetRedSmokeBomb = CreateFrame("CheckButton", O.."SetRedSmokeBomb", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetRedSmokeBombText"]:SetText("Enable Red Enemy Smoke Bomb / Shadowy Duel")
SetRedSmokeBomb:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.RedSmokeBomb = true
	else
		LoseControlDB.RedSmokeBomb = false
	end
end)

SetInterruptOverlay = CreateFrame("CheckButton", O.."SetInterruptOverlay", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptOverlayText"]:SetText("Enable Interrupt Overlay")
SetInterruptOverlay:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.InterruptOverlay = true
	else
		LoseControlDB.InterruptOverlay = false
	end
end)

SetInterruptIcons:SetPoint("TOPLEFT", LossOfControlSpells, "TOPRIGHT", 18, -2)
SetInterruptOverlay:SetPoint("TOPLEFT", SetInterruptIcons, "BOTTOMLEFT", 0, 6)
SetRedSmokeBomb:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 150, 0)
DisableLossOfControlCooldown:SetPoint("TOPLEFT", SetRedSmokeBomb, "BOTTOMLEFT", 0, 6)
DisableLossOfControlCooldownAuxText:SetPoint("TOPLEFT", DisableLossOfControlCooldown, "BOTTOMLEFT", 26, 10)
DrawSwipeSlider:SetPoint("BOTTOMLEFT", SetInterruptIcons, "TOPLEFT", 1, 0)
-------------------------------------------------------------------------------
OptionsPanel.default = function() -- This method will run when the player clicks "defaults"
	L.SpellsConfig:ResetAllSpellList()
	L.SpellsPVEConfig:ResetAllSpellList()
	L.SpellsArenaConfig:ResetAllSpellList()
	_G.LoseControlDB = nil
	L.SpellsPVEConfig:WipeAll()
	L.SpellsConfig:WipeAll()
	L.SpellsArenaConfig:WipeAll()
	LoseControl:ADDON_LOADED(addonName)
	L.SpellsConfig:UpdateAll()
	L.SpellsPVEConfig:UpdateAll()
	L.SpellsArenaConfig:UpdateAll()
	for _, v in pairs(LCframes) do
		v:PLAYER_ENTERING_WORLD()
	end
	LCframeplayer2:PLAYER_ENTERING_WORLD()
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	DisableBlizzardCooldownCount:SetChecked(LoseControlDB.noBlizzardCooldownCount)
	DisableLossOfControlCooldown:SetChecked(LoseControlDB.noLossOfControlCooldown)
	DrawSwipeSlider:SetValue(LoseControlDB.DrawSwipeSetting)

	for k in pairs(DBdefaults.priority) do
	if LoseControlDB.durationType[k] == false then durationTypeCheckBoxNew[k]:SetChecked(true) else durationTypeCheckBoxNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priority) do
	if LoseControlDB.durationType[k] == true then durationTypeCheckBoxHigh[k]:SetChecked(true) else durationTypeCheckBoxHigh[k]:SetChecked(false) end
	end

	for k in pairs(DBdefaults.priorityArena) do
	if LoseControlDB.durationTypeArena[k] == false then durationTypeCheckBoxArenaNew[k]:SetChecked(true) else durationTypeCheckBoxArenaNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priorityArena) do
	if LoseControlDB.durationTypeArena[k] == true then durationTypeCheckBoxArenaHigh[k]:SetChecked(true) else durationTypeCheckBoxArenaHigh[k]:SetChecked(false) end
	end

	if LoseControlDB.InterruptIcons == false then SetInterruptIcons:SetChecked(false) else SetInterruptIcons:SetChecked(true) end
	if LoseControlDB.InterruptOverlay == false then SetInterruptOverlay:SetChecked(false) else SetInterruptOverlay:SetChecked(true) end
	if LoseControlDB.RedSmokeBomb == false then SetRedSmokeBomb:SetChecked(false) else SetRedSmokeBomb:SetChecked(true) end

	if not LoseControlDB.noCooldownCount then
		DisableBlizzardCooldownCount:Disable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
		DisableBlizzardCooldownCount:SetChecked(true)
		DisableBlizzardCooldownCount:Check(true)
	else
		DisableBlizzardCooldownCount:Enable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
	end
	local priority = LoseControlDB.priority
	for k in pairs(priority) do
		PrioritySlider[k]:SetValue(priority[k])
	end
	local priorityArena = LoseControlDB.priorityArena
	for k in pairs(priorityArena) do
		PrioritySliderArena[k]:SetValue(priorityArena[k])
	end
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
-- DropDownMenu helper function
local function AddItem(owner, text, value)
	local info = UIDropDownMenu_CreateInfo()
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

-------------------------------------------------------------------------------
-- Create sub-option frames
for _, v in ipairs({ "player", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
	local OptionsPanelFrame = CreateFrame("Frame", O..v)
	OptionsPanelFrame.parent = addonName
	OptionsPanelFrame.name = L[v]

	local AnchorDropDownLabel = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDownLabel", "ARTWORK", "GameFontNormal")
	AnchorDropDownLabel:SetText(L["Anchor"])
	local AnchorDropDown2Label
	if v == "player" then
		AnchorDropDown2Label = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDown2Label", "ARTWORK", "GameFontNormal")
		AnchorDropDown2Label:SetText(L["Anchor"])
	end
	local CategoriesEnabledLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoriesEnabledLabel", "ARTWORK", "GameFontNormal")
	CategoriesEnabledLabel:SetText(L["CategoriesEnabledLabel"])
	CategoriesEnabledLabel:SetJustifyH("LEFT")

	L.CategoryEnabledInterruptLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledInterruptLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledInterruptLabel:SetText(L["Interrupt"]..":")

	L.CategoryEnabledCCLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCCLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCCLabel:SetText(L["CC"]..":")
	L.CategoryEnabledSilenceLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilenceLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilenceLabel:SetText(L["Silence"]..":")
	L.CategoryEnabledRootPhyiscal_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootPhyiscal_SpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootPhyiscal_SpecialLabel:SetText(L["RootPhyiscal_Special"]..":")
	L.CategoryEnabledRootMagic_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootMagic_SpeciallLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootMagic_SpecialLabel:SetText(L["RootMagic_Special"]..":")
	L.CategoryEnabledRootLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootLabel:SetText(L["Root"]..":")
	L.CategoryEnabledImmunePlayerLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePlayerLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePlayerLabel:SetText(L["ImmunePlayer"]..":")
	L.CategoryEnabledDisarm_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarm_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarm_WarningLabel:SetText(L["Disarm_Warning"]..":")
	L.CategoryEnabledCC_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledEnemy_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledEnemy_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_WarningLabel:SetText(L["CC_Warning"]..":")
	L.CategoryEnabledEnemy_Smoke_BombLabel:SetText(L["Enemy_Smoke_Bomb"]..":")
	L.CategoryEnabledStealthLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledStealthLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledStealthLabel:SetText(L["Stealth"]..":")
	L.CategoryEnabledImmuneLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneLabel:SetText(L["Immune"]..":")
	L.CategoryEnabledImmuneSpellLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneSpellLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneSpellLabel:SetText(L["ImmuneSpell"]..":")
	L.CategoryEnabledImmunePhysicalLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePhysicalLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePhysicalLabel:SetText(L["ImmunePhysical"]..":")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAuraMastery_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel:SetText(L["AuraMastery_Cast_Auras"]..":")
	L.CategoryEnabledROP_VortexLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledROP_VortexLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledROP_VortexLabel:SetText(L["ROP_Vortex"]..":")
	L.CategoryEnabledDisarmLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmLabel:SetText(L["Disarm"]..":")
	L.CategoryEnabledHaste_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledHaste_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledHaste_ReductionLabel:SetText(L["Haste_Reduction"]..":")
	L.CategoryEnabledDmg_Hit_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDmg_Hit_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDmg_Hit_ReductionLabel:SetText(L["Dmg_Hit_Reduction"]..":")
	L.CategoryEnabledAOE_DMG_ModifiersLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_DMG_ModifiersLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_DMG_ModifiersLabel:SetText(L["AOE_DMG_Modifiers"]..":")
	L.CategoryEnabledFriendly_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_Smoke_BombLabel:SetText(L["Friendly_Smoke_Bomb"]..":")
	L.CategoryEnabledAOE_Spell_RefectionsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_Spell_RefectionsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_Spell_RefectionsLabel:SetText(L["AOE_Spell_Refections"]..":")
	L.CategoryEnabledTreesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledTreesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledTreesLabel:SetText(L["Trees"]..":")
	L.CategoryEnabledSpeed_FreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpeed_FreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpeed_FreedomsLabel:SetText(L["Speed_Freedoms"]..":")
	L.CategoryEnabledFreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedomsLabel:SetText(L["Freedoms"]..":")
	L.CategoryEnabledFriendly_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_DefensivesLabel:SetText(L["Friendly_Defensives"]..":")
	L.CategoryEnabledMana_RegenLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMana_RegenLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMana_RegenLabel:SetText(L["Mana_Regen"]..":")
	L.CategoryEnabledCC_ReductionLabel:SetText(L["CC_Reduction"]..":")
	L.CategoryEnabledPersonal_OffensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPersonal_OffensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPersonal_OffensivesLabel:SetText(L["Personal_Offensives"]..":")
	L.CategoryEnabledPeronsal_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPeronsal_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPeronsal_DefensivesLabel:SetText(L["Peronsal_Defensives"]..":")
	L.CategoryEnabledMovable_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMovable_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMovable_Cast_AurasLabel:SetText(L["Movable_Cast_Auras"]..":")
	L.CategoryEnabledOtherLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledOtherLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPvELabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPvELabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledOtherLabel:SetText(L["Other"]..":")
	L.CategoryEnabledPvELabel:SetText(L["PvE"]..":")
	L.CategoryEnabledSnareSpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareSpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareSpecialLabel:SetText(L["SnareSpecial"]..":")
	L.CategoryEnabledSnarePhysical70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical70Label:SetText(L["SnarePhysical70"]..":")
	L.CategoryEnabledSnareMagic70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic70Label:SetText(L["SnareMagic70"]..":")
	L.CategoryEnabledSnarePhysical50Label:SetText(L["SnarePhysical50"]..":")
	L.CategoryEnabledSnarePosion50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePosion50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePosion50Label:SetText(L["SnarePosion50"]..":")
	L.CategoryEnabledSnareMagic50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic50Label:SetText(L["SnareMagic50"]..":")
	L.CategoryEnabledSnarePhysical30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical30Label:SetText(L["SnarePhysical30"]..":")
	L.CategoryEnabledSnareMagic30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic30Label:SetText(L["SnareMagic30"]..":")
	L.CategoryEnabledSnareLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareLabel:SetText(L["Snare"]..":")

	L.CategoryEnabledDrink_PurgeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDrink_PurgeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDrink_PurgeLabel:SetText(L["Drink_Purge"]..":")
	L.CategoryEnabledImmune_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmune_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmune_ArenaLabel:SetText(L["Immune_Arena"]..":")
	L.CategoryEnabledCC_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ArenaLabel:SetText(L["CC_Arena"]..":")
	L.CategoryEnabledSilence_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilence_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilence_ArenaLabel:SetText(L["Silence_Arena"]..":")
	L.CategoryEnabledSpecial_HighLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_HighLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_HighLabel:SetText(L["Special_High"]..":")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRanged_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel:SetText(L["Ranged_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledRoots_90_SnaresLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRoots_90_SnaresLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRoots_90_SnaresLabel:SetText(L["Roots_90_Snares"]..":")
	L.CategoryEnabledDisarmsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmsLabel:SetText(L["Disarms"]..":")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMelee_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel:SetText(L["Melee_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledBig_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledBig_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledBig_Defensive_CDsLabel:SetText(L["Big_Defensive_CDs"]..":")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPlayer_Party_OffensiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Offenisive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Offenisive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Offenisive_CDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Defensive_CDsLabel:SetText(L["Small_Defensive_CDs"]..":")
	L.CategoryEnabledFreedoms_SpeedLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedoms_SpeedLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedoms_SpeedLabel:SetText(L["Freedoms_Speed"]..":")
	L.CategoryEnabledSnares_WithCDsLabel = OptionsPanelFrame:CreateFontString(O..v.." CategoryEnabledSnares_WithCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_WithCDsLabel:SetText(L["Snares_WithCDs"]..":")
	L.CategoryEnabledSpecial_LowLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_LowLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_LowLabel:SetText(L["Special_Low"]..":")
	L.CategoryEnabledSnares_Ranged_SpamableLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Ranged_SpamableLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Ranged_SpamableLabel:SetText(L["Snares_Ranged_Spamable"]..":")
	L.CategoryEnabledSnares_Casted_MeleeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Casted_MeleeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Casted_MeleeLabel:SetText(L["Snares_Casted_Melee"]..":")


	local CategoriesLabels = {
		["Interrupt"] = L.CategoryEnabledInterruptLabel,
		["CC"] = L.CategoryEnabledCCLabel,
		["Silence"] = L.CategoryEnabledSilenceLabel,
		["RootPhyiscal_Special"] = L.CategoryEnabledRootPhyiscal_SpecialLabel,
		["RootMagic_Special"] = L.CategoryEnabledRootMagic_SpecialLabel,
		["Root"] = L.CategoryEnabledRootLabel,
		["ImmunePlayer"] = L.CategoryEnabledImmunePlayerLabel,
		["Disarm_Warning"] = L.CategoryEnabledDisarm_WarningLabel,
		["CC_Warning"] = L.CategoryEnabledCC_WarningLabel,
		["Enemy_Smoke_Bomb"] = L.CategoryEnabledEnemy_Smoke_BombLabel,
		["Stealth"] = L.CategoryEnabledStealthLabel,
		["Immune"] = L.CategoryEnabledImmuneLabel,
		["ImmuneSpell"] = L.CategoryEnabledImmuneSpellLabel,
		["ImmunePhysical"] = L.CategoryEnabledImmunePhysicalLabel,
		["AuraMastery_Cast_Auras"] = L.CategoryEnabledAuraMastery_Cast_AurasLabel,
		["ROP_Vortex"] = L.CategoryEnabledROP_VortexLabel,
		["Disarm"] = L.CategoryEnabledDisarmLabel,
		["Haste_Reduction"] = L.CategoryEnabledHaste_ReductionLabel,
		["Dmg_Hit_Reduction"] = L.CategoryEnabledDmg_Hit_ReductionLabel,
		["AOE_DMG_Modifiers"] = L.CategoryEnabledAOE_DMG_ModifiersLabel,
		["Friendly_Smoke_Bomb"] = L.CategoryEnabledFriendly_Smoke_BombLabel,
		["AOE_Spell_Refections"] = L.CategoryEnabledAOE_Spell_RefectionsLabel,
		["Trees"] = L.CategoryEnabledTreesLabel,
		["Speed_Freedoms"] = L.CategoryEnabledSpeed_FreedomsLabel,
		["Freedoms"] = L.CategoryEnabledFreedomsLabel,
		["Friendly_Defensives"] = L.CategoryEnabledFriendly_DefensivesLabel,
		["Mana_Regen"] = L.CategoryEnabledMana_RegenLabel,
		["CC_Reduction"] = L.CategoryEnabledCC_ReductionLabel,
		["Personal_Offensives"] = L.CategoryEnabledPersonal_OffensivesLabel,
		["Peronsal_Defensives"] = L.CategoryEnabledPeronsal_DefensivesLabel,
		["Movable_Cast_Auras"] = L.CategoryEnabledMovable_Cast_AurasLabel,
		["Other"] =  L.CategoryEnabledOtherLabel,
		["PvE"] = L.CategoryEnabledPvELabel,
		["SnareSpecial"] = L.CategoryEnabledSnareSpecialLabel,
		["SnarePhysical70"] = L.CategoryEnabledSnarePhysical70Label,
		["SnareMagic70"] = L.CategoryEnabledSnareMagic70Label,
		["SnarePhysical50"] = L.CategoryEnabledSnarePhysical50Label,
		["SnarePosion50"] = L.CategoryEnabledSnarePosion50Label,
		["SnareMagic50"] = L.CategoryEnabledSnareMagic50Label,
		["SnarePhysical30"] = L.CategoryEnabledSnarePhysical30Label,
		["SnareMagic30"] = L.CategoryEnabledSnareMagic30Label,
		["Snare"] = L.CategoryEnabledSnareLabel,

		["Drink_Purge"] = L.CategoryEnabledDrink_PurgeLabel,
		["Immune_Arena"] = L.CategoryEnabledImmune_ArenaLabel,
		["CC_Arena"] = L.CategoryEnabledCC_ArenaLabel,
		["Silence_Arena"] = L.CategoryEnabledSilence_ArenaLabel,
		["Special_High"] = L.CategoryEnabledSpecial_HighLabel,
		["Ranged_Major_OffenisiveCDs"] = L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,
		["Roots_90_Snares"] = L.CategoryEnabledRoots_90_SnaresLabel,
		["Disarms"] = L.CategoryEnabledDisarmsLabel,
		["Melee_Major_OffenisiveCDs"] = L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,
		["Big_Defensive_CDs"] = L.CategoryEnabledBig_Defensive_CDsLabel,
		["Player_Party_OffensiveCDs"] = L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,
		["Small_Offenisive_CDs"] = L.CategoryEnabledSmall_Offenisive_CDsLabel,
		["Small_Defensive_CDs"] = L.CategoryEnabledSmall_Defensive_CDsLabel,
		["Freedoms_Speed"] = L.CategoryEnabledFreedoms_SpeedLabel,
		["Snares_WithCDs"] = L.CategoryEnabledSnares_WithCDsLabel,
		["Special_Low"] = L.CategoryEnabledSpecial_LowLabel,
		["Snares_Ranged_Spamable"] = L.CategoryEnabledSnares_Ranged_SpamableLabel,
		["Snares_Casted_Melee"] = L.CategoryEnabledSnares_Casted_MeleeLabel,
		}

	local AnchorDropDown = CreateFrame("Frame", O..v.."AnchorDropDown", OptionsPanelFrame, "UIDropDownMenuTemplate")
	function AnchorDropDown:OnClick()
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, self.value)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, unitId in ipairs(frames) do
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]
			frame.anchor = self.value
			icon.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if self.value ~= "None" then -- reset the frame position so it centers on the anchor frame
				frame.point = nil
				frame.relativePoint = nil
				frame.x = nil
				frame.y = nil
				if self.value == "Gladius" then
					if strfind(unitId, "arena") then
					LCframes[unitId]:CheckGladiusUnitsAnchors(true)
					end
					if GladiusClassIconFramearena1 then
						local W = GladiusClassIconFramearena1:GetWidth()
						local H = GladiusClassIconFramearena1:GetWidth()
						print("|cff00ccffLoseControl|r".." : "..unitId.." GladiusClassIconFrame Size "..mathfloor(H))
						portrSizeValue = W
					else
						if (strfind(unitId, "arena")) then
							portrSizeValue = 42
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
				if self.value == "BambiUI" then
					if (strfind(unitId, "party")) then
						portrSizeValue = 64
					end
					if unitId == "player" then
						portrSizeValue = 48
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
				if self.value == "Blizzard" then
					local portrSizeValue = 36
					if (unitId == "player" or unitId == "target" or unitId == "focus") then
						portrSizeValue = 62
					elseif (strfind(unitId, "arena")) then
						portrSizeValue = 28
					end
					if (unitId == "player") and LoseControlDB.duplicatePlayerPortrait then
						local DuplicatePlayerPortrait = _G['LoseControlOptionsPanel'..unitId..'DuplicatePlayerPortrait']
						if DuplicatePlayerPortrait then
							DuplicatePlayerPortrait:SetChecked(false)
							DuplicatePlayerPortrait:Check(false)
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					if icon.MasqueGroup then
						icon.MasqueGroup:RemoveButton(icon:GetParent())
					end
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
			else
				if icon.MasqueGroup then
					icon.MasqueGroup:RemoveButton(icon:GetParent())
					icon.MasqueGroup:AddButton(icon:GetParent(), {
						FloatingBG = false,
						Icon = icon.texture,
						Cooldown = icon,
						Flash = _G[icon:GetParent():GetName().."Flash"],
						Pushed = icon:GetParent():GetPushedTexture(),
						Normal = icon:GetParent():GetNormalTexture(),
						Disabled = icon:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[icon:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = icon:GetParent():GetHighlightTexture(),
						Hotkey = _G[icon:GetParent():GetName().."HotKey"],
						Count = _G[icon:GetParent():GetName().."Count"],
						Name = _G[icon:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[icon:GetParent():GetName().."Shine"],
					}, "Button", true)
				end
			end
			SetInterruptIconsSize(icon, frame.size)
			icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			if icon.MasqueGroup then
				icon.MasqueGroup:ReSkin()
			end
		end
	end

	local AnchorDropDown2
	if v == "player" then
		AnchorDropDown2	= CreateFrame("Frame", O..v.."AnchorDropDown2", OptionsPanelFrame, "UIDropDownMenuTemplate")
		function AnchorDropDown2:OnClick()
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, self.value)
			local frame = LoseControlDB.frames.player2
			local icon = LCframeplayer2
			frame.anchor = self.value
			frame.point = nil
			frame.relativePoint = nil
			frame.x = nil
			frame.y = nil
			if self.value == "Blizzard" then
				local portrSizeValue = 62
				frame.size = portrSizeValue
				icon:SetWidth(portrSizeValue)
				icon:SetHeight(portrSizeValue)
				icon:GetParent():SetWidth(portrSizeValue)
				icon:GetParent():SetHeight(portrSizeValue)
			end
			icon.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
			SetInterruptIconsSize(icon, frame.size)
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
		end
	end

	local SizeSlider = CreateSlider(L["Icon Size"], OptionsPanelFrame, 16, 256, 2, OptionsPanelFrame:GetName() .. "IconSizeSlider")
	SizeSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Icon Size"] .. " (" .. value .. "px)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].size = value
			LCframes[frame]:SetWidth(value)
			LCframes[frame]:SetHeight(value)
			LCframes[frame]:GetParent():SetWidth(value)
			LCframes[frame]:GetParent():SetHeight(value)
			if LCframes[frame].MasqueGroup then
				LCframes[frame].MasqueGroup:ReSkin()
			end
			SetInterruptIconsSize(LCframes[frame], value)
		end
	end)

	local AlphaSlider = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 2, OptionsPanelFrame:GetName() .. "OpacitySlider") -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
	AlphaSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. ("%.0f"):format(value) .. "%)")
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].alpha = value / 100 -- the real alpha value
			LCframes[frame]:GetParent():SetAlpha(value / 100)
		end
	end)

	local AlphaSlider2
	if v == "player" then
		AlphaSlider2 = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 2, OptionsPanelFrame:GetName() .. "Opacity2Slider") -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
		AlphaSlider2:SetScript("OnValueChanged", function(self, value)
			_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. ("%.0f"):format(value) .. "%)")
			local frames = { v }
			if v == "player" then
				LoseControlDB.frames.player2.alpha = value / 100 -- the real alpha value
				LCframeplayer2:GetParent():SetAlpha(value / 100)
			end
		end)
	end

	local DisableInBG
	if v == "party" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	elseif v == "arena" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disableArenaInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 5 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	end

	local DisableInRaid
	if v == "party" then
		DisableInRaid = CreateFrame("CheckButton", O..v.."DisableInRaid", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInRaidText"]:SetText(L["DisableInRaid"])
		DisableInRaid:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInRaid = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
		end)
	end

	local ShowNPCInterrupts
	if v == "target" or v == "focus" or v == "targettarget" or v == "focustarget"  then
		ShowNPCInterrupts = CreateFrame("CheckButton", O..v.."ShowNPCInterrupts", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."ShowNPCInterruptsText"]:SetText(L["ShowNPCInterrupts"])
		ShowNPCInterrupts:SetScript("OnClick", function(self)
			if v == "target" then
				LoseControlDB.showNPCInterruptsTarget = self:GetChecked()
			elseif v == "focus" then
				LoseControlDB.showNPCInterruptsFocus = self:GetChecked()
			elseif v == "targettarget" then
				LoseControlDB.showNPCInterruptsTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.showNPCInterruptsFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerTargetTarget
	if v == "targettarget" or v == "focustarget" then
		DisablePlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetTargetText"]:SetText(L["DisablePlayerTargetTarget"])
		DisablePlayerTargetTarget:SetScript("OnClick", function(self)
			if v == "targettarget" then
				LoseControlDB.disablePlayerTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.disablePlayerFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableTargetTargetTarget
	if v == "targettarget" then
		DisableTargetTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetTargetTargetText"]:SetText(L["DisableTargetTargetTarget"])
		DisableTargetTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerTargetPlayerTargetTarget
	if v == "targettarget" then
		DisablePlayerTargetPlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetPlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetPlayerTargetTargetText"]:SetText(L["DisablePlayerTargetPlayerTargetTarget"])
		DisablePlayerTargetPlayerTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerTargetPlayerTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableTargetDeadTargetTarget
	if v == "targettarget" then
		DisableTargetDeadTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetDeadTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetDeadTargetTargetText"]:SetText(L["DisableTargetDeadTargetTarget"])
		DisableTargetDeadTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetDeadTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableFocusFocusTarget
	if v == "focustarget" then
		DisableFocusFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusFocusTargetText"]:SetText(L["DisableFocusFocusTarget"])
		DisableFocusFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisablePlayerFocusPlayerFocusTarget
	if v == "focustarget" then
		DisablePlayerFocusPlayerFocusTarget = CreateFrame("CheckButton", O..v.."DisablePlayerFocusPlayerFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerFocusPlayerFocusTargetText"]:SetText(L["DisablePlayerFocusPlayerFocusTarget"])
		DisablePlayerFocusPlayerFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerFocusPlayerFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local DisableFocusDeadFocusTarget
	if v == "focustarget" then
		DisableFocusDeadFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusDeadFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusDeadFocusTargetText"]:SetText(L["DisableFocusDeadFocusTarget"])
		DisableFocusDeadFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusDeadFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
		end)
	end

	local EnableGladiusGloss
	if strfind(v, "arena") then
		EnableGladiusGloss = CreateFrame("CheckButton", O..v.."EnableGladiusGloss", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."EnableGladiusGlossText"]:SetText(L["EnableGladiusGloss"])
		EnableGladiusGloss:SetScript("OnClick", function(self)
			LoseControlDB.EnableGladiusGloss = self:GetChecked()
		end)
	end

	local lossOfControlInterrupt
	if  v == "player" then
		lossOfControlInterrupt = CreateSlider(L["lossOfControlInterrupt"], OptionsPanelFrame, 0, 2, 1, "lossOfControlInterrupt")
		lossOfControlInterrupt:SetScript("OnValueChanged", function(self, value)
		lossOfControlInterrupt:SetScale(.82)
		lossOfControlInterrupt:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlInterrupt"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlInterrupt = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlInterrupt", ("%.0f"):format(value))
		end)
	end

	local lossOfControlFull
	if  v == "player" then
		lossOfControlFull = CreateSlider(L["lossOfControlFull"], OptionsPanelFrame, 0, 2, 1, "lossOfControlFull")
		lossOfControlFull:SetScript("OnValueChanged", function(self, value)
		lossOfControlFull:SetScale(.82)
		lossOfControlFull:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlFull"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlFull = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlFull", ("%.0f"):format(value))
		end)
	end

	local lossOfControlSilence
	if  v == "player" then
		lossOfControlSilence = CreateSlider(L["lossOfControlSilence"], OptionsPanelFrame, 0, 2, 1, "lossOfControlSilence")
		lossOfControlSilence:SetScript("OnValueChanged", function(self, value)
		lossOfControlSilence:SetScale(.82)
		lossOfControlSilence:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlSilence"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlSilence = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlSilence", ("%.0f"):format(value))
		end)
	end

	local lossOfControlDisarm
	if  v == "player" then
		lossOfControlDisarm = CreateSlider(L["lossOfControlDisarm"], OptionsPanelFrame, 0, 2, 1, "lossOfControlDisarm")
		lossOfControlDisarm:SetScript("OnValueChanged", function(self, value)
		lossOfControlDisarm:SetScale(.82)
		lossOfControlDisarm:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlDisarm"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlDisarm = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlDisarm", ("%.0f"):format(value))
		end)
	end

	local lossOfControlRoot
	if  v == "player" then
		lossOfControlRoot = CreateSlider(L["lossOfControlRoot"], OptionsPanelFrame, 0, 2, 1, "lossOfControlRoot")
		lossOfControlRoot:SetScript("OnValueChanged", function(self, value)
		lossOfControlRoot:SetScale(.82)
		lossOfControlRoot:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlRoot"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlRoot = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlRoot", ("%.0f"):format(value))
		end)
	end

	local lossOfControl
	if  v == "player" then
		lossOfControl = CreateFrame("CheckButton", O..v.."lossOfControl", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		lossOfControl:SetScale(1)
		lossOfControl:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."lossOfControlText"]:SetText(L["lossOfControl"])
		lossOfControl:SetScript("OnClick", function(self)
			LoseControlDB.lossOfControl = self:GetChecked()
			if (self:GetChecked()) then
				SetCVar("lossOfControl", 1)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlFull)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm)
				BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot)
			else
				SetCVar("lossOfControl", 0)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlFull)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm)
				BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot)
			end
		end)
	end



	local catListEnChecksButtons = {
																	"CC","Silence","RootPhyiscal_Special","RootMagic_Special","Root","ImmunePlayer","Disarm_Warning","CC_Warning","Enemy_Smoke_Bomb","Stealth",
																	"Immune","ImmuneSpell","ImmunePhysical","AuraMastery_Cast_Auras","ROP_Vortex","Disarm","Haste_Reduction","Dmg_Hit_Reduction",
																	"AOE_DMG_Modifiers","Friendly_Smoke_Bomb","AOE_Spell_Refections","Trees","Speed_Freedoms","Freedoms","Friendly_Defensives","Mana_Regen",
																	"CC_Reduction","Personal_Offensives","Peronsal_Defensives","Movable_Cast_Auras","Other","PvE","SnareSpecial","SnarePhysical70","SnareMagic70",
																	"SnarePhysical50","SnarePosion50","SnareMagic50","SnarePhysical30","SnareMagic30","Snare",
																	}
--Interrupts
	local CategoriesCheckButtons = { }
	local FriendlyInterrupt = CreateFrame("CheckButton", O..v.."FriendlyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	FriendlyInterrupt:SetScale(.82)
	FriendlyInterrupt:SetHitRectInsets(0, -36, 0, 0)
	_G[O..v.."FriendlyInterruptText"]:SetText(L["CatFriendly"])
	FriendlyInterrupt:SetScript("OnClick", function(self)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframes[frame].maxExpirationTime = 0
			if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, 0)
			end
		end
	end)
	tblinsert(CategoriesCheckButtons, { frame = FriendlyInterrupt, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 120, yPos = 5 })

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
		local EnemyInterrupt = CreateFrame("CheckButton", O..v.."EnemyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		EnemyInterrupt:SetScale(.82)
		EnemyInterrupt:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."EnemyInterruptText"]:SetText(L["CatEnemy"])
		EnemyInterrupt:SetScript("OnClick", function(self)
			local frames = { v }
			if v == "arena" then
				frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
			end
			for _, frame in ipairs(frames) do
				LoseControlDB.frames[frame].categoriesEnabled.interrupt.enemy = self:GetChecked()
				LCframes[frame].maxExpirationTime = 0
				if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
					LCframes[frame]:UNIT_AURA(frame, 0)
				end
			end
		end)
		tblinsert(CategoriesCheckButtons, { frame = EnemyInterrupt, auraType = "interrupt", reaction = "enemy", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
	end

--Spells
	for _, cat in pairs(catListEnChecksButtons) do
		if not strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

		if not strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
				local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
				EnemyBuff:SetScale(.82)
				EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
				_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
				EnemyBuff:SetScript("OnClick", function(self)
					LoseControlDB.frames[v].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
					LCframes[v].maxExpirationTime = 0
					if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
						LCframes[v]:UNIT_AURA(v, 0)
					end
				end)
				tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
			end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
				local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
				EnemyDebuff:SetScale(.82)
				EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
				_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
				EnemyDebuff:SetScript("OnClick", function(self)
					LoseControlDB.frames[v].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
					LCframes[v].maxExpirationTime = 0
					if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
						LCframes[v]:UNIT_AURA(v, 0)
					end
				end)
				tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
			end
	end




---Spells Arena
local catListEnChecksButtonsArena = {
		"Drink_Purge",
		"Immune_Arena",
		"CC_Arena",
		"Silence_Arena",
		"Special_High",
		"Ranged_Major_OffenisiveCDs",
		"Roots_90_Snares",
		"Disarms",
		"Melee_Major_OffenisiveCDs",
		"Big_Defensive_CDs",
		"Player_Party_OffensiveCDs",
		"Small_Offenisive_CDs",
		"Small_Defensive_CDs",
		"Freedoms_Speed",
		"Snares_WithCDs",
		"Special_Low",
		"Snares_Ranged_Spamable",
		"Snares_Casted_Melee",
}
	for _, cat in pairs(catListEnChecksButtonsArena) do
		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

			if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyBuff:SetScale(.82)
			EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
			EnemyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyDebuff:SetScale(.82)
			EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
			EnemyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
		end
	end


	local CategoriesCheckButtonsPlayer2
	if (v == "player") then
		CategoriesCheckButtonsPlayer2 = { }
		local FriendlyInterruptPlayer2 = CreateFrame("CheckButton", O..v.."FriendlyInterruptPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		FriendlyInterruptPlayer2:SetScale(.82)
		FriendlyInterruptPlayer2:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."FriendlyInterruptPlayer2Text"]:SetText(L["CatFriendly"].."|cfff28614(Icon2)|r")
		FriendlyInterruptPlayer2:SetScript("OnClick", function(self)
			LoseControlDB.frames.player2.categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframeplayer2.maxExpirationTime = 0
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, 0)
			end
		end)
		tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyInterruptPlayer2, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
		for _, cat in pairs(catListEnChecksButtons) do
			local FriendlyBuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."BuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuffPlayer2:SetScale(.82)
			FriendlyBuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffPlayer2Text"]:SetText(L["CatFriendlyBuff"].."|cfff28614(Icon2)|r")
			FriendlyBuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.buff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyBuffPlayer2, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
			local FriendlyDebuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."DebuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuffPlayer2:SetScale(.82)
			FriendlyDebuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffPlayer2Text"]:SetText(L["CatFriendlyDebuff"].."|cfff28614(Icon2)|r")
			FriendlyDebuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyDebuffPlayer2, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 359, yPos = 5 })
		end
	end

	local DuplicatePlayerPortrait
	if v == "player" then
		DuplicatePlayerPortrait = CreateFrame("CheckButton", O..v.."DuplicatePlayerPortrait", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DuplicatePlayerPortraitText"]:SetText(L["DuplicatePlayerPortrait"])
		function DuplicatePlayerPortrait:Check(value)
			LoseControlDB.duplicatePlayerPortrait = self:GetChecked()
			local enable = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
			if AlphaSlider2 then
				if enable then
					BlizzardOptionsPanel_Slider_Enable(AlphaSlider2)
				else
					BlizzardOptionsPanel_Slider_Disable(AlphaSlider2)
				end
			end
			if AnchorDropDown2 then
				if enable then
					UIDropDownMenu_EnableDropDown(AnchorDropDown2)
				else
					UIDropDownMenu_DisableDropDown(AnchorDropDown2)
				end
			end
			if CategoriesCheckButtonsPlayer2 then
				if enable then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			LoseControlDB.frames.player2.enabled = enable
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(enable)
			if self:GetChecked() and LoseControlDB.frames.player.anchor ~= "None" then
				local frame = LoseControlDB.frames["player"]
				frame.anchor = "None"
				local AnchorDropDown = _G['LoseControlOptionsPanel'..LCframes.player.unitId..'AnchorDropDown']
				if (AnchorDropDown) then
					UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
				end
				if LCframes.player.MasqueGroup then
					LCframes.player.MasqueGroup:RemoveButton(LCframes.player:GetParent())
					LCframes.player.MasqueGroup:AddButton(LCframes.player:GetParent(), {
						FloatingBG = false,
						Icon = LCframes.player.texture,
						Cooldown = LCframes.player,
						Flash = _G[LCframes.player:GetParent():GetName().."Flash"],
						Pushed = LCframes.player:GetParent():GetPushedTexture(),
						Normal = LCframes.player:GetParent():GetNormalTexture(),
						Disabled = LCframes.player:GetParent():GetDisabledTexture(),
						Checked = false,
						Border = _G[LCframes.player:GetParent():GetName().."Border"],
						AutoCastable = false,
						Highlight = LCframes.player:GetParent():GetHighlightTexture(),
						Hotkey = _G[LCframes.player:GetParent():GetName().."HotKey"],
						Count = _G[LCframes.player:GetParent():GetName().."Count"],
						Name = _G[LCframes.player:GetParent():GetName().."Name"],
						Duration = false,
						Shine = _G[LCframes.player:GetParent():GetName().."Shine"],
					}, "Button", true)
				end
				LCframes.player.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
				LCframes.player:ClearAllPoints()
				LCframes.player:SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				LCframes.player:GetParent():SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				if LCframes.player.anchor:GetParent() then
					LCframes.player:SetFrameLevel(LCframes.player.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
				if LCframes.player.MasqueGroup then
					LCframes.player.MasqueGroup:ReSkin()
				end
			end
			if enable and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, 0)
			end
		end
		DuplicatePlayerPortrait:SetScript("OnClick", function(self)
			DuplicatePlayerPortrait:Check(self:GetChecked())
		end)
	end

	local Enabled = CreateFrame("CheckButton", O..v.."Enabled", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	_G[O..v.."EnabledText"]:SetText(L["Enabled"])
	Enabled:SetScript("OnClick", function(self)
		local enabled = self:GetChecked()
		if enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Enable(lossOfControl) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlFull)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm)
			BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Disable(lossOfControl) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(GRAY_FONT_COLOR:GetRGB())

			for k, catGrey in ipairs(CategoriesLabels) do
			catGrey:SetVertexColor(GRAY_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlFull)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm)
			BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot)
			UIDropDownMenu_DisableDropDown(AnchorDropDown)
			if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
			if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].enabled = enabled
			local inInstance, instanceType = IsInInstance()
			local enable = enabled and not (
				inInstance and instanceType == "pvp" and (
					( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
					( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
				)
			) and not (
				IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
			)
			LCframes[frame].maxExpirationTime = 0
			LCframes[frame]:RegisterUnitEvents(enable)
			if enable and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, 0)
			end
			if (frame == "player") then
				LoseControlDB.frames.player2.enabled = enabled and LoseControlDB.duplicatePlayerPortrait
				LCframeplayer2.maxExpirationTime = 0
				LCframeplayer2:RegisterUnitEvents(enabled and LoseControlDB.duplicatePlayerPortrait)
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(frame, 0)
				end
			end
		end
	end)

	Enabled:SetPoint("TOPLEFT", 8, -4)
	if DisableInBG then DisableInBG:SetPoint("TOPLEFT", Enabled, 275, 0) end
	if EnableGladiusGloss then EnableGladiusGloss:SetPoint("TOPLEFT", Enabled, 275, -25)end
	if DisableInRaid then DisableInRaid:SetPoint("TOPLEFT", Enabled, 275, -25) end
	if ShowNPCInterrupts then ShowNPCInterrupts:SetPoint("TOPLEFT", Enabled, 450, 2);ShowNPCInterrupts:SetScale(.8) end
	if DisablePlayerTargetTarget then DisablePlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -13);DisablePlayerTargetTarget:SetScale(.8) end
	if DisableTargetTargetTarget then DisableTargetTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -28); DisableTargetTargetTarget:SetScale(.8) end
	if DisableFocusFocusTarget then DisableFocusFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -28);DisableFocusFocusTarget:SetScale(.8) end
	if DisablePlayerTargetPlayerTargetTarget then DisablePlayerTargetPlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerTargetPlayerTargetTarget:SetScale(.8) end
	if DisablePlayerFocusPlayerFocusTarget then DisablePlayerFocusPlayerFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerFocusPlayerFocusTarget:SetScale(.8) end
	if DisableTargetDeadTargetTarget then DisableTargetDeadTargetTarget:SetPoint("TOPLEFT", Enabled,450, -58);DisableTargetDeadTargetTarget:SetScale(.8) end
	if DisableFocusDeadFocusTarget then DisableFocusDeadFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -58); DisableFocusDeadFocusTarget:SetScale(.8) end

	if DuplicatePlayerPortrait then DuplicatePlayerPortrait:SetPoint("TOPLEFT", Enabled, 275, 0) end
	AnchorDropDown:SetPoint("TOPLEFT", Enabled, "BOTTOMLEFT", -13, -3)
	AnchorDropDown:SetScale(.9)
	AnchorDropDownLabel:SetPoint("BOTTOMLEFT", AnchorDropDown, "TOPRIGHT", 60,-1)
	AnchorDropDownLabel:SetScale(.8)
	SizeSlider:SetPoint("TOPLEFT", Enabled, "TOPRIGHT", 115, -20)
	AlphaSlider:SetPoint("TOPLEFT", SizeSlider, "BOTTOMLEFT", 0, -16)
	CategoriesEnabledLabel:SetPoint("TOPLEFT", AnchorDropDown, "BOTTOMLEFT", 17, -3)

	if L.CategoryEnabledInterruptLabel then L.CategoryEnabledInterruptLabel:SetPoint("TOPLEFT", CategoriesEnabledLabel, "BOTTOMLEFT", 0, -6); L.CategoryEnabledInterruptLabel:SetScale(.75) end

	if v ~= "arena" then
		local labels ={
		  L.CategoryEnabledCCLabel,L.CategoryEnabledSilenceLabel,L.CategoryEnabledRootPhyiscal_SpecialLabel,L.CategoryEnabledRootMagic_SpecialLabel,L.CategoryEnabledRootLabel,L.CategoryEnabledImmunePlayerLabel,L.CategoryEnabledDisarm_WarningLabel,L.CategoryEnabledCC_WarningLabel,L.CategoryEnabledEnemy_Smoke_BombLabel,L.CategoryEnabledStealthLabel,L.CategoryEnabledImmuneLabel,L.CategoryEnabledImmuneSpellLabel,L.CategoryEnabledImmunePhysicalLabel,L.CategoryEnabledAuraMastery_Cast_AurasLabel,L.CategoryEnabledROP_VortexLabel,L.CategoryEnabledDisarmLabel,L.CategoryEnabledHaste_ReductionLabel,L.CategoryEnabledDmg_Hit_ReductionLabel,L.CategoryEnabledAOE_DMG_ModifiersLabel,L.CategoryEnabledFriendly_Smoke_BombLabel,L.CategoryEnabledAOE_Spell_RefectionsLabel,L.CategoryEnabledTreesLabel,L.CategoryEnabledSpeed_FreedomsLabel,L.CategoryEnabledFreedomsLabel,L.CategoryEnabledFriendly_DefensivesLabel,L.CategoryEnabledMana_RegenLabel,L.CategoryEnabledCC_ReductionLabel,L.CategoryEnabledPersonal_OffensivesLabel,L.CategoryEnabledPeronsal_DefensivesLabel,L.CategoryEnabledMovable_Cast_AurasLabel,L.CategoryEnabledOtherLabel,L.CategoryEnabledPvELabel,L.CategoryEnabledSnareSpecialLabel,L.CategoryEnabledSnarePhysical70Label,L.CategoryEnabledSnareMagic70Label,L.CategoryEnabledSnarePhysical50Label,L.CategoryEnabledSnarePosion50Label,L.CategoryEnabledSnareMagic50Label,L.CategoryEnabledSnarePhysical30Label,L.CategoryEnabledSnareMagic30Label,L.CategoryEnabledSnareLabel
		  }
	  for k, catEn in ipairs(labels) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labels[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if v == "arena" then
		local labelsArena ={									L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
		              }
	  for k, catEn in ipairs(labelsArena) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
		local labelsArena ={									L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
		              }
	  for k, catEn in ipairs(labelsArena) do
	    if k == 1 then
	      if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 381, 0); catEn:SetScale(.75) end
	    else
	      if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
	    end
	  end
	end

	if lossOfControl then lossOfControl:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 390, 7) end
	if lossOfControlInterrupt then lossOfControlInterrupt:SetPoint("TOPLEFT", lossOfControl, "BOTTOMLEFT", 0, -18) end
	if lossOfControlFull then lossOfControlFull:SetPoint("TOPLEFT", lossOfControlInterrupt, "BOTTOMLEFT", 0, -18) end
	if lossOfControlSilence then lossOfControlSilence:SetPoint("TOPLEFT", lossOfControlFull, "BOTTOMLEFT", 0, -18) end
	if lossOfControlDisarm then lossOfControlDisarm:SetPoint("TOPLEFT", lossOfControlSilence, "BOTTOMLEFT", 0, -18) end
	if lossOfControlRoot then lossOfControlRoot:SetPoint("TOPLEFT", lossOfControlDisarm, "BOTTOMLEFT", 0, -18) end
	if v == "player" then
		local LoCOptions = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions:SetText("Blizzard Loss of Control must be \nenabled to discover new spells \n\n|cffff00000:|r Disables Bliz LoC Type \n1: Shows icon for small duartion \n|cff00ff002:|r Shows icon for full duration \n \n ")
		LoCOptions:SetJustifyH("LEFT")
		LoCOptions:SetPoint("TOPLEFT", lossOfControlRoot, "TOPLEFT", -5, -15)
	end

	for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
		checkbuttonframe.frame:SetPoint("TOPLEFT", checkbuttonframe.anchorPos, checkbuttonframe.xPos, checkbuttonframe.yPos)
	end
	if CategoriesCheckButtonsPlayer2 then
		for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
			checkbuttonframeplayer2.frame:SetPoint("TOPLEFT", checkbuttonframeplayer2.anchorPos, checkbuttonframeplayer2.xPos, checkbuttonframeplayer2.yPos)
		end
	end

	if AnchorDropDown2 then AnchorDropDown2:SetPoint("TOPLEFT", DuplicatePlayerPortrait, "BOTTOMLEFT", -13, -3); AnchorDropDown2:SetScale(.9) end
	if AnchorDropDown2Label then AnchorDropDown2Label:SetPoint("BOTTOMLEFT", AnchorDropDown2, "TOPRIGHT", 60,-2);	AnchorDropDown2Label:SetScale(.8) end
	if AlphaSlider2 then AlphaSlider2:SetPoint("TOPLEFT", AlphaSlider, "TOPRIGHT", 155, 0) end

	OptionsPanelFrame.default = OptionsPanel.default
	OptionsPanelFrame.refresh = function()
		local unitId = v
		if unitId == "party" then
			DisableInBG:SetChecked(LoseControlDB.disablePartyInBG)
			DisableInRaid:SetChecked(LoseControlDB.disablePartyInRaid)
			unitId = "party1"
		elseif unitId == "arena" then
			DisableInBG:SetChecked(LoseControlDB.disableArenaInBG)
			EnableGladiusGloss:SetChecked(LoseControlDB.EnableGladiusGloss)
			unitId = "arena1"
		elseif unitId == "player" then
			DuplicatePlayerPortrait:SetChecked(LoseControlDB.duplicatePlayerPortrait)
			AlphaSlider2:SetValue(LoseControlDB.frames.player2.alpha * 100)
			lossOfControl:SetChecked(LoseControlDB.lossOfControl)
			SetCVar("lossOfControl", LoseControlDB.lossOfControl)
			lossOfControlInterrupt:SetValue(LoseControlDB.lossOfControlInterrupt)
			SetCVar("lossOfControlInterrupt", LoseControlDB.lossOfControlInterrupt)

			lossOfControlFull:SetValue(LoseControlDB.lossOfControlFull)
			SetCVar("lossOfControlFull", LoseControlDB.lossOfControlFull)

			lossOfControlSilence:SetValue(LoseControlDB.lossOfControlSilence)
			SetCVar("lossOfControlSilence", LoseControlDB.lossOfControlSilence)

			lossOfControlDisarm:SetValue(LoseControlDB.lossOfControlDisarm)
			SetCVar("lossOfControlDisarm", LoseControlDB.lossOfControlDisarm)

			lossOfControlRoot:SetValue(LoseControlDB.lossOfControlRoot)
			SetCVar("lossOfControlRoot", LoseControlDB.lossOfControlRoot)
		elseif unitId == "target" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTarget)
		elseif unitId == "focus" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocus)
		elseif unitId == "targettarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTargetTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetTarget)
			DisableTargetTargetTarget:SetChecked(LoseControlDB.disableTargetTargetTarget)
			DisablePlayerTargetPlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetPlayerTargetTarget)
			DisableTargetDeadTargetTarget:SetChecked(LoseControlDB.disableTargetDeadTargetTarget)
		elseif unitId == "focustarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocusTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerFocusTarget)
			DisableFocusFocusTarget:SetChecked(LoseControlDB.disableFocusFocusTarget)
			DisablePlayerFocusPlayerFocusTarget:SetChecked(LoseControlDB.disablePlayerFocusPlayerFocusTarget)
			DisableFocusDeadFocusTarget:SetChecked(LoseControlDB.disableFocusDeadFocusTarget)
		end
		LCframes[unitId]:CheckGladiusUnitsAnchors(true)
		LCframes[unitId]:CheckSUFUnitsAnchors(true)
		for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
			if checkbuttonframe.auraType ~= "interrupt" then
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction][checkbuttonframe.categoryType])
			else
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction])
			end
		end
		if CategoriesCheckButtonsPlayer2 then
			for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
				if checkbuttonframeplayer2.auraType ~= "interrupt" then
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction][checkbuttonframeplayer2.categoryType])
				else
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction])
				end
			end
		end
		local frame = LoseControlDB.frames[unitId]
		Enabled:SetChecked(frame.enabled)
		if frame.enabled then
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Enable(lossOfControl) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Enable(SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.lossOfControl then
			 	if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Enable(lossOfControlInterrupt) end
				if lossOfControlFull then BlizzardOptionsPanel_Slider_Enable(lossOfControlFull) end
				if lossOfControlSilence then BlizzardOptionsPanel_Slider_Enable(lossOfControlSilence) end
				if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Enable(lossOfControlDisarm) end
				if lossOfControlRoot then BlizzardOptionsPanel_Slider_Enable(lossOfControlRoot) end
				--
			else
				if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
				if lossOfControlFull then BlizzardOptionsPanel_Slider_Disable(lossOfControlFull) end
				if lossOfControlSilence then BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence) end
				if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm) end
				if lossOfControlRoot then BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot) end
			end
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then BlizzardOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then BlizzardOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then BlizzardOptionsPanel_CheckButton_Disable(lossOfControl) end
			if DisableInRaid then BlizzardOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then BlizzardOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then BlizzardOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then BlizzardOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					BlizzardOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			BlizzardOptionsPanel_Slider_Disable(SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
			UIDropDownMenu_DisableDropDown(AnchorDropDown)
			if lossOfControlInterrupt then BlizzardOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
			if lossOfControlFull then BlizzardOptionsPanel_Slider_Disable(lossOfControlFull) end
			if lossOfControlSilence then BlizzardOptionsPanel_Slider_Disable(lossOfControlSilence) end
			if lossOfControlDisarm then BlizzardOptionsPanel_Slider_Disable(lossOfControlDisarm) end
			if lossOfControlRoot then BlizzardOptionsPanel_Slider_Disable(lossOfControlRoot) end
			if AlphaSlider2 then BlizzardOptionsPanel_Slider_Disable(AlphaSlider2) end
			if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		SizeSlider:SetValue(frame.size)
		AlphaSlider:SetValue(frame.alpha * 100)
		UIDropDownMenu_Initialize(AnchorDropDown, function() -- called on refresh and also every time the drop down menu is opened
			AddItem(AnchorDropDown, L["None"], "None")
			AddItem(AnchorDropDown, "Blizzard", "Blizzard")
			if PartyAnchor5 then AddItem(AnchorDropDown, "Bambi's UI", "BambiUI") end
			if Gladius then AddItem(AnchorDropDown, "Gladius", "Gladius") end
			if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown, "Perl", "Perl") end
			if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown, "XPerl", "XPerl") end
			if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown, "LUI", "LUI") end
			if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown, "SUF", "SUF") end
			if _G[anchors["SyncFrames"][unitId]] or (type(anchors["SyncFrames"][unitId])=="table" and anchors["SyncFrames"][unitId]) then AddItem(AnchorDropDown, "SyncFrames", "SyncFrames") end

		end)
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		if AnchorDropDown2 then
			UIDropDownMenu_Initialize(AnchorDropDown2, function() -- called on refresh and also every time the drop down menu is opened
				AddItem(AnchorDropDown2, "Blizzard", "Blizzard")
				if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown2, "Perl", "Perl") end
				if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown2, "XPerl", "XPerl") end
				if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown2, "LUI", "LUI") end
				if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown2, "SUF", "SUF") end
			end)
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, LoseControlDB.frames.player2.anchor)
		end
	end

	InterfaceOptions_AddCategory(OptionsPanelFrame)
end

-------------------------------------------------------------------------------
SLASH_LoseControl1 = "/lc"
SLASH_LoseControl2 = "/losecontrol"

local SlashCmd = {}
function SlashCmd:help()
	print("|cff00ccffLoseControl|r", ": slash commands")
	print("    reset [<unit>]")
	print("    lock")
	print("    unlock")
	print("    enable <unit>")
	print("    disable <unit>")
end
function SlashCmd:debug(value)
	if value == "on" then
		debug = true
		print(addonName, "debugging enabled.")
	elseif value == "off" then
		debug = false
		print(addonName, "debugging disabled.")
	end
end
function SlashCmd:reset(unitId)
	if unitId == nil or unitId == "" or unitId == "all" then
		OptionsPanel.default()
	elseif unitId == "party" then
		for _, v in ipairs({"party1", "party2", "party3", "party4"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif unitId == "arena" then
		for _, v in ipairs({"arena1", "arena2", "arena3", "arena4", "arena5"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif LoseControlDB.frames[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId] = CopyTable(DBdefaults.frames[unitId])
		LCframes[unitId]:PLAYER_ENTERING_WORLD()
		if (unitId == "player") then
			LoseControlDB.frames.player2 = CopyTable(DBdefaults.frames.player2)
			LCframeplayer2:PLAYER_ENTERING_WORLD()
		end
		print(L["LoseControl reset."].." "..unitId)
	end
	Unlock:OnClick()
	OptionsPanel.refresh()
	for _, v in ipairs({ "player", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
		_G[O..v].refresh()
	end
end
function SlashCmd:lock()
	Unlock:SetChecked(false)
	Unlock:OnClick()
	print(addonName, "locked.")
end
function SlashCmd:unlock()
	Unlock:SetChecked(true)
	Unlock:OnClick()
	print(addonName, "unlocked.")
end
function SlashCmd:enable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = true
		local inInstance, instanceType = IsInInstance()
		local enabled = not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp"))
		)
		LCframes[unitId]:RegisterUnitEvents(enabled)
		if enabled and not LCframes[unitId].unlockMode then
			LCframes[unitId]:UNIT_AURA(unitId, 0)
		end
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait
			LCframeplayer2:RegisterUnitEvents(LoseControlDB.duplicatePlayerPortrait)
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(unitId, 0)
			end
		end
		print(addonName, unitId, "frame enabled.")
	end
end
function SlashCmd:disable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = false
		LCframes[unitId].maxExpirationTime = 0
		LCframes[unitId]:RegisterUnitEvents(false)
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = false
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(false)
		end
		print(addonName, unitId, "frame disabled.")
	end
end


SlashCmdList[addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print("|cff00ccffLoseControl|r", ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end
