-- Path of Building
--
-- Module: Data
-- Contains static data used by other modules.
--
--local launch = ...

LoadModule("Data/Global")

local typeLabel = {
	{en="Amulet",cn="护身符"},
	{en="Flask: Life",cn="药剂: 生命"},
{en="Jewel",cn="珠宝"},
{en="Body Armour: Armour/Evasion/Energy Shield",cn="胸甲: 护甲/闪避/能量护盾"},
{en="Quiver",cn="箭袋"},
{en="Flask: Hybrid",cn="药剂: 复合"},
{en="Boots: Armour/Energy Shield",cn="鞋子: 护甲/能量护盾"},
{en="Helmet: Evasion/Energy Shield",cn="头盔: 闪避/能量护盾"},
{en="Shield: Armour/Energy Shield",cn="盾牌: 护甲/能量护盾"},
{en="Gloves: Armour/Energy Shield",cn="手套: 护甲/能量护盾"},
{en="Amulet: Talisman",cn="护身符: 魔符"},
{en="Belt",cn="腰带"},
{en="Shield: Energy Shield",cn="盾牌: 能量护盾"},
{en="Shield: Armour",cn="盾牌: 护甲"},
{en="Wand",cn="法杖"},
{en="Boots: Armour",cn="鞋子: 护甲"},
{en="Gloves: Evasion",cn="手套: 闪避"},
{en="Shield: Evasion",cn="盾牌: 闪避"},
{en="Gloves: Armour",cn="手套: 护甲"},
{en="Two Handed Axe",cn="双手斧"},
{en="Claw",cn="爪"},
{en="Flask: Utility",cn="药剂: 功能"},
{en="Boots: Evasion/Energy Shield",cn="鞋子: 闪避/能量护盾"},
{en="Gloves: Armour/Evasion",cn="手套: 护甲/闪避"},
{en="Helmet: Armour/Evasion",cn="头盔: 护甲/闪避"},
{en="Gloves: Evasion/Energy Shield",cn="手套: 闪避/能量护盾"},
{en="One Handed Axe",cn="单手斧"},
{en="Flask: Mana",cn="药剂: 魔力"},
{en="Boots: Evasion",cn="鞋子: 闪避"},
{en="Ring",cn="戒指"},
{en="Helmet: Armour/Energy Shield",cn="头盔: 护甲/能量护盾"},
{en="Helmet: Evasion",cn="头盔: 闪避"},
{en="Body Armour: Armour/Evasion",cn="胸甲: 护甲/闪避"},
{en="Body Armour: Energy Shield",cn="胸甲: 能量护盾"},
{en="One Handed Mace",cn="单手锤"},
{en="Shield: Armour/Evasion",cn="盾牌: 护甲/闪避"},
{en="Two Handed Mace",cn="双手锤"},
{en="Shield: Evasion/Energy Shield",cn="盾牌: 闪避/能量护盾"},
{en="Helmet: Energy Shield",cn="头盔: 能量护盾"},
{en="Body Armour: Armour",cn="胸甲: 护甲"},
{en="Bow",cn="弓"},
{en="Two Handed Sword",cn="双手剑"},
{en="Boots: Energy Shield",cn="鞋子: 能量护盾"},
{en="Body Armour: Armour/Energy Shield",cn="胸甲: 护甲/能量护盾"},
{en="Staff",cn="长杖"},
{en="Jewel: Abyss",cn="珠宝: 深渊"},
{en="Jewel: Cluster",cn="珠宝: 星团"},
{en="Dagger",cn="匕首"},
{en="Sceptre",cn="短杖"},
{en="Helmet: Armour",cn="头盔: 护甲"},
{en="Body Armour: Evasion/Energy Shield",cn="胸甲: 闪避/能量护盾"},
{en="Thrusting One Handed Sword",cn="细剑"},
{en="Body Armour: Evasion",cn="胸甲: 闪避"},
{en="One Handed Sword",cn="单手剑"},
{en="Boots: Armour/Evasion",cn="鞋子: 护甲/闪避"},
{en="Gloves: Energy Shield",cn="手套: 能量护盾"},
{en="Boots",cn="鞋子: 特殊"},
{en="Gloves",cn="手套: 特殊"},
{en="Dagger: Rune",cn="匕首: 符文匕首"},
{en="Shield",cn="盾牌: 特殊"},
{en="Jewel: Timeless",cn="珠宝: 永恒珠宝"},
{en="Staff: Warstaff",cn="长杖: 战斗长杖"},
{en="Helmet",cn="头盔: 特殊"},
{en="Boots: Ward",cn="鞋子: 结界"},
{en="Gloves: Ward",cn="手套: 结界"},
{en="Helmet: Ward",cn="头盔: 结界"},
}

-- 一些特殊技能有特殊等级
local skillNameAndLevel = {

	--{name="血肉与岩石",grantedEffectId="BloodSandArmour",level=6},	
	{name="血与沙",grantedEffectId="BloodSandStance",level=6},
	{name="启蒙",grantedEffectId="SupportAdditionalXP",level=3},
	{name="烙印召回",grantedEffectId="SigilRecall",level=6},
}

local skillTypes = {
	"act_str",
	"act_dex",
	"act_int",
	"other",
	"glove",
	"minion",
	"spectre",
	"sup_str",
	"sup_dex",
	"sup_int",
}
local itemTypes = {
	"axe",
	"bow",
	"claw",
	"dagger",
	"mace",
	"staff",
	"sword",
	"wand",
	"helmet",
	"body",
	"gloves",
	"boots",
	"shield",
	"quiver",
	"amulet",
	"ring",
	"belt",
	"jewel",
	"flask",
}

local function makeSkillMod(modName, modType, modVal, flags, keywordFlags, ...)
	return {
		name = modName,
		type = modType,
		value = modVal,
		flags = flags or 0,
		keywordFlags = keywordFlags or 0,
		...
	}
end
local function makeFlagMod(modName, ...)
	return makeSkillMod(modName, "FLAG", true, 0, 0, ...)
end
local function makeSkillDataMod(dataKey, dataValue, ...)
	return makeSkillMod("SkillData", "LIST", { key = dataKey, value = dataValue }, 0, 0, ...)
end
local function processMod(grantedEffect, mod)
	mod.source = grantedEffect.modSource
	if type(mod.value) == "table" and mod.value.mod then
		mod.value.mod.source = "Skill:"..grantedEffect.id
	end
	for _, tag in ipairs(mod) do
		if tag.type == "GlobalEffect" then
			grantedEffect.hasGlobalEffect = true
			break
		end
	end
end

-----------------
-- Common Data --
-----------------

data = { }


data.powerStatList = {
	{ stat=nil, label="伤害/防御", combinedOffDef=true, ignoreForItems=true },
	{ stat=nil, label="Name", itemField="Name", ignoreForNodes=true, reverseSort=true, transform=function(value) return value:gsub("^The ","") end},
	{ stat="FullDPS", label="所有 DPS" },
	{ stat="CombinedDPS", label="包含所有的 DPS" },
	{ stat="TotalDPS", label="总 DPS" },
	--{ stat="WithImpaleDPS", label="Impale + Total DPS" },
	{ stat="AverageDamage", label="平均击中伤害" },
	{ stat="Speed", label="攻击/施法 速度" },
	{ stat="TotalDot", label="持续伤害 DPS" },
	{ stat="BleedDPS", label="流血 DPS" },
	{ stat="IgniteDPS", label="点燃 DPS" },
	{ stat="PoisonDPS", label="中毒 DPS" },
	{ stat="Life", label="生命" },
	{ stat="LifeRegen", label="生命回复" },
	{ stat="LifeLeechRate", label="生命偷取" },
	{ stat="Armour", label="护甲" },
	{ stat="Evasion", label="闪避" },
	{ stat="EnergyShield", label=" 能量护盾" },
	{ stat="EnergyShieldRecoveryCap", label="可回复的能量护盾" },
	{ stat="EnergyShieldRegen", label="能量护盾回复" },
	{ stat="EnergyShieldLeechRate", label="能量护盾偷取" },
	{ stat="Mana", label="魔力" },
	{ stat="ManaRegen", label="魔力回复" },
	{ stat="ManaLeechRate", label="魔力偷取" },
	{ stat="Ward", label="结界" },
	{ stat="Str", label="力量" },
	{ stat="Dex", label="敏捷" },
	{ stat="Int", label="智力" },
	{ stat="TotalAttr", label="所有属性" },
	{ stat="MeleeAvoidChance", label="近战伤害避免几率" },
	{ stat="SpellAvoidChance", label="法术伤害避免几率" },
	{ stat="ProjectileAvoidChance", label="投射物伤害避免几率" },
	{ stat="TotalEHP", label="合计有效血池" },
	{ stat="PhysicalTakenHitMult", label="承受物理伤害", transform=function(value) return 1-value end },
	{ stat="LightningTakenDotMult", label="承受闪电伤害", transform=function(value) return 1-value end },
	{ stat="ColdTakenDotMult", label="承受冰霜伤害", transform=function(value) return 1-value end },
	{ stat="FireTakenDotMult", label="承受火焰伤害", transform=function(value) return 1-value end },
	{ stat="ChaosTakenHitMult", label="承受混沌伤害", transform=function(value) return 1-value end },
	{ stat="CritChance", label="暴击几率" },
	{ stat="CritMultiplier", label="暴击伤害" },
	{ stat="BleedChance", label="流血几率" },
	{ stat="FreezeChance", label="冰冻几率" },
	{ stat="IgniteChance", label="点燃几率" },
	{ stat="ShockChance", label="感电几率" },
	{ stat="EffectiveMovementSpeedMod", label="移动速度" },
	{ stat="BlockChance", label="攻击格挡几率" },
	{ stat="SpellBlockChance", label="法术格挡几率" },
	{ stat="SpellSuppressionChance", label="法术伤害压制率" },
}

data.skillColorMap = { colorCodes.STRENGTH, colorCodes.DEXTERITY, colorCodes.INTELLIGENCE, colorCodes.NORMAL }

data.setJewelRadiiGlobally = function(treeVersion)
	local major, minor = treeVersion:match("(%d+)_(%d+)")
	if tonumber(major) <= 3 and tonumber(minor) <= 15 then
		data.jewelRadius = data.jewelRadii["3_15"]
	else
		data.jewelRadius = data.jewelRadii["3_16"]
	end
end

data.jewelRadii = {
	["3_15"] = {
		{ inner = 0, outer = 800, col = "^xBB6600", label = "小" },
		{ inner = 0, outer = 1200, col = "^x66FFCC", label = "中" },
		{ inner = 0, outer = 1500, col = "^x2222CC", label = "大" },

		{ inner = 850, outer = 1100, col = "^xD35400", label = "Variable" },
		{ inner = 1150, outer = 1400, col = "^x66FFCC", label = "Variable" },
		{ inner = 1450, outer = 1700, col = "^x2222CC", label = "Variable" },
		{ inner = 1750, outer = 2000, col = "^xC100FF", label = "Variable" },
	},
	["3_16"] = {
		{ inner = 0, outer = 960, col = "^xBB6600", label = "小" },
		{ inner = 0, outer = 1440, col = "^x66FFCC", label = "中" },
		{ inner = 0, outer = 1800, col = "^x2222CC", label = "大" },

		{ inner = 960, outer = 1320, col = "^xD35400", label = "Variable" },
		{ inner = 1320, outer = 1680, col = "^x66FFCC", label = "Variable" },
		{ inner = 1680, outer = 2040, col = "^x2222CC", label = "Variable" },
		{ inner = 2040, outer = 2400, col = "^xC100FF", label = "Variable" },
	}
}

data.jewelRadius = data.setJewelRadiiGlobally(latestTreeVersion)

data.enchantmentSource = {
	{ name = "ENKINDLING", label = "启明石" },
	{ name = "INSTILLING", label = "灌顶石" },
	{ name = "HEIST", label = "夺宝" },
	{ name = "HARVEST", label = "庄园" },
	{ name = "DEDICATION", label = "潜能终极帝王迷宫-女神祭献" },
	{ name = "ENDGAME", label = "终极帝王试炼" },
	{ name = "MERCILESS", label = "无情帝王试炼" },
	{ name = "CRUEL", label = "残酷帝王试炼" },
	{ name = "NORMAL", label = "帝王试炼" },
}

local maxPenaltyFreeAreaLevel = 70
local maxAreaLevel = 87 -- T16 map + side area + three watchstones that grant +1 level
local penaltyMultiplier = 0.06

---@param areaLevel number
---@return number
local function effectiveMonsterLevel(areaLevel)
	--- Areas with area level above a certain penalty-free level are considered to have
	--- a scaling lower effective monster level for experience penalty calculations.
	if areaLevel <= maxPenaltyFreeAreaLevel then
		return areaLevel
	end
	return areaLevel - triangular(areaLevel - maxPenaltyFreeAreaLevel) * penaltyMultiplier
end

---@type table<number, number>
data.monsterExperienceLevelMap = {}
for i = 1, maxAreaLevel do
	data.monsterExperienceLevelMap[i] = effectiveMonsterLevel(i)
end

data.weaponTypeInfo = {
	["None"] = { oneHand = true, melee = true, flag = "Unarmed" },
	["Bow"] = { oneHand = false, melee = false, flag = "Bow" },
	["Claw"] = { oneHand = true, melee = true, flag = "Claw" },
	["Dagger"] = { oneHand = true, melee = true, flag = "Dagger" },
	["Staff"] = { oneHand = false, melee = true, flag = "Staff" },
	["Wand"] = { oneHand = true, melee = false, flag = "Wand" },
	["One Handed Axe"] = { oneHand = true, melee = true, flag = "Axe" },
	["One Handed Mace"] = { oneHand = true, melee = true, flag = "Mace" },
	["One Handed Sword"] = { oneHand = true, melee = true, flag = "Sword" },
	["Sceptre"] = { oneHand = true, melee = true, flag = "Mace", label = "One Handed Mace" },
	["Thrusting One Handed Sword"] = { oneHand = true, melee = true, flag = "Sword", label = "One Handed Sword" },
	["Two Handed Axe"] = { oneHand = false, melee = true, flag = "Axe" },
	["Two Handed Mace"] = { oneHand = false, melee = true, flag = "Mace" },
	["Two Handed Sword"] = { oneHand = false, melee = true, flag = "Sword" },
}
data.unarmedWeaponData = {
	[0] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 6 }, -- Scion
	[1] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 8 }, -- Marauder
	[2] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 5 }, -- Ranger
	[3] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 5 }, -- Witch
	[4] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 6 }, -- Duelist
	[5] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 6 }, -- Templar
	[6] = { type = "None", AttackRate = 1.2, CritChance = 0, PhysicalMin = 2, PhysicalMax = 5 }, -- Shadow
}

data.specialBaseTags = {
	["Amulet"] = { shaper = "amulet_shaper", elder = "amulet_elder", crusader="amulet_crusader", redeemer = "amulet_eyrie",hunter ="amulet_basilisk",warlord="amulet_adjudicator" },
	["Ring"] = { shaper = "ring_shaper", elder = "ring_elder", crusader="ring_crusader", redeemer = "ring_eyrie",hunter ="ring_basilisk",warlord="ring_adjudicator"  },
	["Claw"] = { shaper = "claw_shaper", elder = "claw_elder", crusader="claw_crusader", redeemer = "claw_eyrie",hunter ="claw_basilisk",warlord="claw_adjudicator"  },
	["Dagger"] = { shaper = "dagger_shaper", elder = "dagger_elder", crusader="dagger_crusader", redeemer = "dagger_eyrie",hunter ="dagger_basilisk",warlord="dagger_adjudicator"  },
	["Wand"] = { shaper = "wand_shaper", elder = "wand_elder",  crusader="wand_crusader", redeemer = "wand_eyrie",hunter ="wand_basilisk",warlord="wand_adjudicator" },
	["One Handed Sword"] = { shaper = "sword_shaper", elder = "sword_elder", crusader="sword_crusader", redeemer = "sword_eyrie",hunter ="sword_basilisk",warlord="sword_adjudicator"  },
	["Thrusting One Handed Sword"] = { shaper = "sword_shaper", elder = "sword_elder",  crusader="sword_crusader", redeemer = "sword_eyrie",hunter ="sword_basilisk",warlord="sword_adjudicator" },
	["One Handed Axe"] = { shaper = "axe_shaper", elder = "axe_elder", crusader="axe_crusader", redeemer = "axe_eyrie",hunter ="axe_basilisk",warlord="axe_adjudicator"  },
	["One Handed Mace"] = { shaper = "mace_shaper", elder = "mace_elder",  crusader="mace_crusader", redeemer = "macet_eyrie",hunter ="mace_basilisk",warlord="mace_adjudicator" },
	["Bow"] = { shaper = "bow_shaper", elder = "bow_elder",  crusader="bow_crusader", redeemer = "bow_eyrie",hunter ="bow_basilisk",warlord="bow_adjudicator" },
	["Staff"] = { shaper = "staff_shaper", elder = "staff_elder",  crusader="staff_crusader", redeemer = "staff_eyrie",hunter ="staff_basilisk",warlord="staff_adjudicator" },
	["Two Handed Sword"] = { shaper = "2h_sword_shaper", elder = "2h_sword_elder",  crusader="2h_sword_crusader", redeemer = "2h_sword_eyrie",hunter ="2h_sword_basilisk",warlord="2h_sword_adjudicator" },
	["Two Handed Axe"] = { shaper = "2h_axe_shaper", elder = "2h_axe_elder",  crusader="2h_axe_crusader", redeemer = "2h_axe_eyrie",hunter ="2h_axe_basilisk",warlord="2h_axe_adjudicator" },
	["Two Handed Mace"] = { shaper = "2h_mace_shaper", elder = "2h_mace_elder",  crusader="2h_mace_crusader", redeemer = "2h_mace_eyrie",hunter ="2h_mace_basilisk",warlord="2h_mace_adjudicator" },
	["Quiver"] = { shaper = "quiver_shaper", elder = "quiver_elder",  crusader="quiver_crusader", redeemer = "quiver_eyrie",hunter ="quiver_basilisk",warlord="quiver_adjudicator" },
	["Belt"] = { shaper = "belt_shaper", elder = "belt_elder", crusader="belt_crusader", redeemer = "belt_eyrie",hunter ="belt_basilisk",warlord="belt_adjudicator"  },
	["Gloves"] = { shaper = "gloves_shaper", elder = "gloves_elder",  crusader="gloves_crusader", redeemer = "gloves_eyrie",hunter ="gloves_basilisk",warlord="gloves_adjudicator" },
	["Boots"] = { shaper = "boots_shaper", elder = "boots_elder",  crusader="boots_crusader", redeemer = "boots_eyrie",hunter ="boots_basilisk",warlord="boots_adjudicator" },
	["Body Armour"] = { shaper = "body_armour_shaper", elder = "body_armour_elder",  crusader="body_armour_crusader", redeemer = "body_armour_eyrie",hunter ="body_armour_basilisk",warlord="body_armour_adjudicator" },
	["Helmet"] = { shaper = "helmet_shaper", elder = "helmet_elder", crusader="helmet_crusader", redeemer = "helmet_eyrie",hunter ="helmet_basilisk",warlord="helmet_adjudicator"  },
	["Shield"] = { shaper = "shield_shaper", elder = "shield_elder", crusader="shield_crusader", redeemer = "shield_eyrie",hunter ="shield_basilisk",warlord="shield_adjudicator"  },
	["Sceptre"] = { shaper = "sceptre_shaper", elder = "sceptre_elder",  crusader="sceptre_crusader", redeemer = "sceptre_eyrie",hunter ="sceptre_basilisk",warlord="sceptre_adjudicator" },
}

---@type string[] @List of keystones that can be found on unique items.
data.keystones = {
	"移形换影",
	"先祖魂约",
	"箭矢闪跃",
	"火之化身",
	"祭血术",
	"召集部队",
	"能量连接",
	"玫红之舞",
	"异能魔力",
	"元素之相",
	"元素超载",
	"青春永驻",
	"灵能护体",
	"斗转星移",
	"失衡卫士",
	"钢铁之握",
	"霸体",
	"心灵升华",
	"复仇之灵",
	"凡人的信念",
	"苦痛灵曲",
	"完美苦痛",
	"移灵换影",
	"零点射击",
	"坚毅之心",
	"符文绑定者",
	"无上自我",
	"惘信者",
	"穿刺者",
	"烈士意志",
	"瓦尔冥约",
	"恶毒结界",
	"风舞者",
	"狂热誓言",
	"空明之掌",
	"Divine Shield",
	"灭亡之日",
	"幽灵舞步",
	"钢铁意志",
	"Lethe Shade",
	"MageBane",
	"Solipsism",
	"全方位斗士",
}


data.ailmentTypeList = { "Bleed", "Poison", "Ignite", "Chill", "Freeze", "Shock", "Scorch", "Brittle", "Sap" }
data.elementalAilmentTypeList = { "Ignite", "Chill", "Freeze", "Shock", "Scorch", "Brittle", "Sap" }

data.nonDamagingAilment = {
	["Chill"] = { associatedType = "Cold", alt = false, default = 10, min = 5, max = 30, precision = 0, duration = 2 },
	["Freeze"] = { associatedType = "Cold", alt = false, default = nil, min = 0.3, max = 3, precision = 2, duration = nil },
	["Shock"] = { associatedType = "Lightning", alt = false, default = 15, min = 5, max = 50, precision = 0, duration = 2 },
	["Scorch"] = { associatedType = "Fire", alt = true, default = 10, min = 0, max = 30, precision = 0, duration = 4 },
	["Brittle"] = { associatedType = "Cold", alt = true, default = 5, min = 0, max = 15, precision = 2, duration = 4 },
	["Sap"] = { associatedType = "Lightning", alt = true, default = 6, min = 0, max = 20, precision = 0, duration = 4 },
}

data.misc = { -- magic numbers
	ServerTickTime = 0.033,
	ServerTickRate = 1 / 0.033,
	TemporalChainsEffectCap = 75,
	PhysicalDamageReductionCap = 90,
	DamageReductionCap = 90,
	ResistFloor = -200,
	MaxResistCap = 90,
	EvadeChanceCap = 95,
	DodgeChanceCap = 75,
	SuppressionChanceCap = 100,
	SuppressionEffect = 50,
	AvoidChanceCap = 75,
	EnergyShieldRechargeBase = 0.33,
	EnergyShieldRechargeDelay = 2,
	WardRechargeDelay = 5,
	Transfiguration = 0.3,
	EnemyMaxResist = 75,
	LeechRateBase = 0.02,
	BleedPercentBase = 70,
	BleedDurationBase = 5,
	PoisonPercentBase = 0.30,
	PoisonDurationBase = 2,
	IgnitePercentBase = 1.25,
	IgniteDurationBase = 4,
	ImpaleStoredDamageBase = 0.1,
	BuffExpirationSlowCap = 0.25,
	TrapTriggerRadiusBase = 10,
	MineDetonationRadiusBase = 60,
	MineAuraRadiusBase = 35,
	PurposefulHarbingerMaxBuffPercent = 40,
	VastPowerMaxAoEPercent = 50,
	ImpaleDurationBase = 8,
	ImpaleStacksMax =5,
	MaximumRage = 50,
	RageDurationBase = 0.5,
	MaxEnemyLevel = 84,
	LowPoolThreshold = 0.5,
	AccuracyPerDexBase = 2,
	BrandAttachmentRangeBase = 30,

	MurderousEyeJewelMaxCritChancePercent = 100,
	MurderousEyeJewelMaxCritCritMultiplierPercent = 50,
	GhastlyEyeJewelMaxMinionsDOTMultiplierPercent = 30,
	HypnoticEyeJewelMaxArcaneSurgeEffect = 40,
	-- Expected values to calculate EHP
	stdBossDPSMult = 4 / 4.25,
	shaperDPSMult = 8 / 4.25,
	shaperPen = 25 / 5,
	sirusDPSMult = 10 / 4.25,
	sirusPen = 40 / 5,
	
}




-- Misc data tables
LoadModule("Data/Misc", data)

-- Stat descriptions
data.describeStats = LoadModule("Modules/StatDescriber")

-- Load item modifiers
data.itemMods = {
	Item = LoadModule("Data/ModItem"),
	Flask = LoadModule("Data/ModFlask"),
	Jewel = LoadModule("Data/ModJewel"),
	JewelAbyss = LoadModule("Data/ModJewelAbyss"),
	JewelCluster = LoadModule("Data/ModJewelCluster"),
}
data.masterMods = LoadModule("Data/ModMaster")
data.enchantments = {
	Helmet = LoadModule("Data/EnchantmentHelmet"),
	["Helmet"] = LoadModule("Data/EnchantmentHelmet"),
	Boots = LoadModule("Data/EnchantmentBoots"),
	["Boots"] = LoadModule("Data/EnchantmentBoots"),
	Gloves = LoadModule("Data/EnchantmentGloves"),
	["Gloves"] = LoadModule("Data/EnchantmentGloves"),
	Belt = LoadModule("Data/EnchantmentBelt"),
	["Belt"] = LoadModule("Data/EnchantmentBelt"),
	["Body Armour"] = LoadModule("Data/EnchantmentBody"),
	["Weapon"] = LoadModule("Data/EnchantmentWeapon"),
	["Flask"] = LoadModule("Data/EnchantmentFlask"),
}
data.synthesisedMods = {
		Item = LoadModule("Data/ModSynthesised"),
		
}
data.essences = LoadModule("Data/Essence")
data.veiledMods = LoadModule("Data/ModVeiled")
data.pantheons = LoadModule("Data/Pantheons")


-- Cluster jewel data
data.clusterJewels = LoadModule("Data/ClusterJewels")
data.harvestSeedEnchantments = LoadModule("Data/ModHarvestSeed")
data.delve = LoadModule("Data/ModDelve")
data.incursion = LoadModule("Data/ModIncursion")
	
data.blightPassives= LoadModule("Data/BlightPassives")
		
table.sort(data.blightPassives, function(a, b) 
			return a.name < b.name
		end)
		
-- Create a quick lookup cache from cluster jewel skill to the notables which use that skill
---@type table<string, table<string>>
local clusterSkillToNotables = { }
for notableKey, notableInfo in pairs(data.itemMods.JewelCluster) do
	-- Translate the notable key to its name
	local notableName = notableInfo[1] and notableInfo[1]:match("1 Added Passive Skill is (.*)")
	if notableName then
		for weightIndex, clusterSkill in pairs(notableInfo.weightKey) do
			if notableInfo.weightVal[weightIndex] > 0 then
				if not clusterSkillToNotables[clusterSkill] then
					clusterSkillToNotables[clusterSkill] = { }
				end
				table.insert(clusterSkillToNotables[clusterSkill], notableName)
			end
		end
	end
end

-- Create easy lookup from cluster node name -> cluster jewel size and types
data.clusterJewelInfoForNotable = { }
for size, jewel in pairs(data.clusterJewels.jewels) do
	for skill, skillInfo in pairs(jewel.skills) do
		local notables = clusterSkillToNotables[skill]
		if notables then
			for _, notableKey in ipairs(notables) do
				if not data.clusterJewelInfoForNotable[notableKey] then
					data.clusterJewelInfoForNotable[notableKey] = { }
					data.clusterJewelInfoForNotable[notableKey].jewelTypes = { }
					data.clusterJewelInfoForNotable[notableKey].size = { }
				end
				local curJewelInfo = data.clusterJewelInfoForNotable[notableKey]
				curJewelInfo.size[size] = true
				table.insert(curJewelInfo.jewelTypes, skill)
			end
		end
	end
end


-- Load skills
data.skills = { }
data.skillStatMap = LoadModule("Data/SkillStatMap", makeSkillMod, makeFlagMod, makeSkillDataMod)
data.skillStatMapMeta = {
	__index = function(t, key)
		local map = data.skillStatMap[key]
		if map then
			map = copyTable(map)
			t[key] = map
			for _, mod in ipairs(map) do
				processMod(t._grantedEffect, mod)
			end
			return map
		end
	end
}
for _, type in pairs(skillTypes) do
	LoadModule("Data/Skills/"..type, data.skills, makeSkillMod, makeFlagMod, makeSkillDataMod)
end
for skillId, grantedEffect in pairs(data.skills) do
	grantedEffect.id = skillId
	grantedEffect.modSource = "Skill:"..skillId
	-- Add sources for skill mods, and check for global effects
	for _, list in pairs({grantedEffect.baseMods, grantedEffect.qualityMods, grantedEffect.levelMods}) do
		for _, mod in pairs(list) do
			if mod.name then
				processMod(grantedEffect, mod)
			else
				for _, mod in ipairs(mod) do
					processMod(grantedEffect, mod)
				end
			end
		end
	end
	-- Install stat map metatable
	grantedEffect.statMap = grantedEffect.statMap or { }
	setmetatable(grantedEffect.statMap, data.skillStatMapMeta)
	grantedEffect.statMap._grantedEffect = grantedEffect
	for _, map in pairs(grantedEffect.statMap) do
		for _, mod in ipairs(map) do
			processMod(grantedEffect, mod)
		end
	end
end


-- Load gems
data.gems = LoadModule("Data/Gems")
data.gemForSkill = { }
data.gemForBaseName = { }
for gemId, gem in pairs(data.gems) do
	gem.id = gemId
	
	gem.grantedEffect = data.skills[gem.grantedEffectId]
	data.gemForSkill[gem.grantedEffect] = gemId
	
	--lucifer 导入无辅助技能找这里
	data.gemForBaseName[gem.name] = gemId
	gem.secondaryGrantedEffect = gem.secondaryGrantedEffectId and data.skills[gem.secondaryGrantedEffectId]
	gem.grantedEffectList = {
		gem.grantedEffect,
		gem.secondaryGrantedEffect
	}
	gem.defaultLevel = gem.defaultLevel or (#gem.grantedEffect.levels > 20 and #gem.grantedEffect.levels - 20) or (gem.grantedEffect.levels[3][1] and 3) or 1
end

-- Load minions
data.minions = { }
LoadModule("Data/Minions", data.minions, makeSkillMod)
data.spectres = { }
LoadModule("Data/Spectres", data.spectres, makeSkillMod)
for name, spectre in pairs(data.spectres) do
	spectre.limit = "ActiveSpectreLimit"
	data.minions[name] = spectre
end
local missing = { }
for _, minion in pairs(data.minions) do
	for _, skillId in ipairs(minion.skillList) do
		if launch.devMode and not data.skills[skillId] and not missing[skillId] then
			ConPrintf("'%s' missing skill '%s'", minion.name, skillId)
			missing[skillId] = true
		end
	end
	for _, mod in ipairs(minion.modList) do
		mod.source = "Minion:"..minion.name
	end
end

-- Item bases
data.itemBases = { }
for _, type in pairs(itemTypes) do
	LoadModule("Data/Bases/"..type, data.itemBases)
end


-- Build lists of item bases, separated by type
data.itemBaseLists = { }
for name, base in pairs(data.itemBases) do
	if not base.hidden then
		local type = base.type
		if base.subType then
			type = type .. ": " .. base.subType
		end
		
			--lucifer 
		for index in pairs(typeLabel) do
				if type==typeLabel[index].en then
					type=typeLabel[index].cn
				end
		end
			 
		data.itemBaseLists[type] = data.itemBaseLists[type] or { }
		table.insert(data.itemBaseLists[type], { label = name:gsub(" %(.+%)",""), name = name, base = base })
	end
end
data.itemBaseTypeList = { }
for type, list in pairs(data.itemBaseLists) do
	table.insert(data.itemBaseTypeList, type)
	table.sort(list, function(a, b)
		if a.base.req and b.base.req then
			if a.base.req.level == b.base.req.level then
				return a.name < b.name
			else
				return (a.base.req.level or 1) > (b.base.req.level or 1)
			end
		elseif a.base.req and not b.base.req then
			return true
		elseif b.base.req and not a.base.req then
			return false
		else
			return a.name < b.name
		end
	end)
end
table.sort(data.itemBaseTypeList)


-- Rare templates
data.rares = LoadModule("Data/Rares")

-- Uniques (loaded after version-specific data because reasons)
data.uniques = { }
for _, type in pairs(itemTypes) do
	data.uniques[type] = LoadModule("Data/Uniques/"..type)
end

LoadModule("Data/Uniques/Special/Generated")
LoadModule("Data/New")
 
