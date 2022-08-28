---
--- Programmatically generated uniques live here.
--- Some uniques have to be generated because the amount of variable mods makes it infeasible to implement them manually.
--- As a result, they are forward compatible to some extent as changes to the variable mods are picked up automatically.
---

data.uniques.generated = { }

local parseVeiledModName = function(string)
	return (string:
	gsub("%JunMasterVeiled", ""):
	gsub("%Local", ""):
	gsub("%Display", ""):
	gsub("%Crafted", ""):
	gsub("(%d)h", ""):
	gsub("%_", ""):
	gsub("(%l)(%u)", "%1 %2"):
	gsub("(%d)", " %1 "))
end

local veiledModIsActive = function(mod, baseType, specificType1, specificType2)
	local baseIndex = isValueInTable(mod.weightKey, baseType)
	local typeIndex1 = isValueInTable(mod.weightKey, specificType1)
	local typeIndex2 = isValueInTable(mod.weightKey, specificType2)
	return (typeIndex1 and mod.weightVal[typeIndex1] > 0) or (typeIndex2 and mod.weightVal[typeIndex2] > 0) or (not typeIndex1 and not typeIndex2 and baseIndex and mod.weightVal[baseIndex] > 0)
end

local modTypeCn = { Suffix = "后缀", Prefix = "前缀"}

local getVeiledMods = function (veiledPool, baseType, specificType1, specificType2)
	local veiledMods = { }
	for veiledModIndex, veiledMod in pairs(data.veiledMods) do
		if veiledModIsActive(veiledMod, baseType, specificType1, specificType2) then
			local veiledName = parseVeiledModName(veiledModIndex)

			veiledName = "("..modTypeCn[veiledMod.type]..") "..veiledMod[1]
			
			local veiled = { veiledName = veiledName, veiledLines = { } }
			for line, value in ipairs(veiledMod) do
				veiled.veiledLines[line] = value
			end

			if veiledPool == "base" and (veiledMod.affix == "天选的" or veiledMod.affix == "秩序之") then
				table.insert(veiledMods, veiled)
			elseif veiledPool == "catarina" and (veiledMod.affix == "卡塔莉娜的" or veiledMod.affix == "天选的" or veiledMod.affix == "秩序之") then
				table.insert(veiledMods, veiled)
			elseif veiledPool == "all" then
				table.insert(veiledMods, veiled)
			end
		end
	end
	table.sort(veiledMods, function (m1, m2) return m1.veiledName < m2.veiledName end )
	return veiledMods
end

local paradoxicaMods = getVeiledMods("base", "weapon", "one_hand_weapon")
local paradoxica = {
	"悖论",
	"瓦尔细剑",
	"联盟: 毁灭不朽",
	"Has Alt Variant: true",
	"Selected Variant: 4",
	"Selected Alt Variant: 16"
}

for index, mod in pairs(paradoxicaMods) do
	if (mod.veiledName == "(后缀) 有 (6-7)% 的几率造成双倍伤害") or
		(mod.veiledName == "(后缀) 专注时有 (18-20)% 的几率伤害翻倍") then
		table.remove(paradoxicaMods, index)
	end
end

for index, mod in pairs(paradoxicaMods) do
	table.insert(paradoxica, "版本: "..mod.veiledName)
end

table.insert(paradoxica, "源: 安全屋boss专属掉落")
table.insert(paradoxica, "等级需求: 66, 212 Dex")
table.insert(paradoxica, "固定基底词缀: 1")
table.insert(paradoxica, "+25% 攻击和法术暴击伤害加成")

for index, mod in pairs(paradoxicaMods) do
	for _, value in pairs(mod.veiledLines) do
		table.insert(paradoxica, "{variant:"..index.."}"..value.."")
	end
end

table.insert(paradoxica, "该武器的攻击伤害翻倍")
table.insert(data.uniques.generated, table.concat(paradoxica, "\n"))

local caneOfKulemakMods = getVeiledMods("catarina", "weapon", "staff", "two_hand_weapon")
local caneOfKulemak = {
	"库勒马克藤杖",
	"蛇纹长杖",
	"Has Alt Variant: true",
	"Has Alt Variant Two: true",
	"Selected Variant: 1",
	"Selected Alt Variant: 20"
}

for index, mod in pairs(caneOfKulemakMods) do
	table.insert(caneOfKulemak, "版本: "..mod.veiledName)
end

table.insert(caneOfKulemak, "等级需求: 68, 85 Str, 85 Int")
table.insert(caneOfKulemak, "固定基底词缀: 1")
table.insert(caneOfKulemak, "持长杖时攻击伤害格挡几率 +20%")
table.insert(caneOfKulemak, "解密词缀的幅度扩大 (60-90)%")

for index, mod in pairs(caneOfKulemakMods) do
	for _, value in pairs(mod.veiledLines) do
		table.insert(caneOfKulemak, "{variant:"..index.."}"..value.."")
	end
end

table.insert(data.uniques.generated, table.concat(caneOfKulemak, "\n"))

local replicaParadoxicaMods = getVeiledMods("all", "weapon", "one_hand_weapon")
local replicaParadoxica = {
	"悖论【仿品】",
	"瓦尔细剑",
	"联盟: 夺宝奇兵",
	"Has Alt Variant: true",
	"Has Alt Variant Two: true",
	"Has Alt Variant Three: true",
	"Has Alt Variant Four: true",
	"Has Alt Variant Five: true",
	"Selected Variant: 1",
	"Selected Alt Variant: 2",
	"Selected Alt Variant Two: 3",
	"Selected Alt Variant Three: 25",
	"Selected Alt Variant Four: 27",
	"Selected Alt Variant Five: 34"
}

for index, mod in pairs(replicaParadoxicaMods) do
	table.insert(replicaParadoxica, "版本: "..mod.veiledName)
end

table.insert(replicaParadoxica, "等级需求: 66, 212 Dex")
table.insert(replicaParadoxica, "固定基底词缀: 1")
table.insert(replicaParadoxica, "+25% 攻击和法术暴击伤害加成")

for index, mod in pairs(replicaParadoxicaMods) do
	for _, value in pairs(mod.veiledLines) do
		table.insert(replicaParadoxica, "{variant:"..index.."}"..value.."")
	end
end

table.insert(data.uniques.generated, table.concat(replicaParadoxica, "\n"))

local queensHungerMods = getVeiledMods("base", "body_armour", "int_armour")
local queensHunger = {
	"女王的饥饿",
	"瓦尔法衣",
	"联盟: 毁灭不朽",
	"Has Alt Variant: true",
	"Selected Variant: 1",
	"Selected Alt Variant: 24"
}

for index, mod in pairs(queensHungerMods) do
	table.insert(queensHunger, "版本: "..mod.veiledName)
end

table.insert(queensHunger, "等级需求: 68, 194 Int")
table.insert(queensHunger, "每 5 秒触发 20 级的【骸骨奉献】、【血肉奉献】或【灵魂奉献】")
table.insert(queensHunger, "以此种方式触发的奉献技能也会影响你")
table.insert(queensHunger, "施法速度提高 (5-10)%")
table.insert(queensHunger, "该装备的能量护盾提高 (100-130)%")
table.insert(queensHunger, "最大生命提高 (6-10)%")

for index, mod in pairs(queensHungerMods) do
	for _, value in pairs(mod.veiledLines) do
		table.insert(queensHunger, "{variant:"..index.."}"..value.."")
	end
end

table.insert(data.uniques.generated, table.concat(queensHunger, "\n"))



local megalomaniac = {
	"妄想症",
	"中型星团珠宝",
	"联盟: 惊悸迷雾",
	"源: 「梦魇拟像」限定掉落",
	"Has Alt Variant: true",
	"Has Alt Variant Two: true",
	"增加 4 个天赋技能",
	"增加的小天赋无效果",
}
local notables = { }
for name in pairs(data.clusterJewels.notableSortOrder) do
	table.insert(notables, name)
end
table.sort(notables)
for index, name in ipairs(notables) do
	table.insert(megalomaniac, "版本: "..name)
	table.insert(megalomaniac, "{variant:"..index.."}其中 1 个增加的天赋为【"..name.."】")
end
table.insert(data.uniques.generated, table.concat(megalomaniac, "\n"))

local forbiddenShako = {
	"禁断的军帽",
	"强化巨盔",
	"联盟: 古灵庄园",
	"源: 由传奇Boss【庄园化身欧莱娜】专属掉落",
	"等级需求: 68, 59 Str, 59 Int",
	"Has Alt Variant: true"
}
local replicaForbiddenShako = {
	"禁断的军帽【仿品】",
	"强化巨盔",
	"联盟: 夺宝奇兵",	
	"源: 在蓝图夺宝中从【古物陈列柜】中窃得",
	"等级需求: 53, 59 Str, 59 Int",
	"Has Alt Variant: true"
}
local excludedGems = {
	"减少格挡几率(辅)",
	"赋能",
	"强化",
	"启蒙",
	"物品数量增幅(辅)",
}
local gems = { }
for _, gemData in pairs(data.gems) do
	local grantedEffect = gemData.grantedEffect
	if grantedEffect.support and not (grantedEffect.plusVersionOf) and not isValueInArray(excludedGems, grantedEffect.name) then
		table.insert(gems, grantedEffect.name)
	end
end
table.sort(gems)
for index, name in ipairs(gems) do
	table.insert(forbiddenShako, "版本: "..name.. " (低等级)")
	table.insert(forbiddenShako, "{variant:"..(index * 2 - 1).."}此物品上的技能石受到 (1-10) 级的 "..name.." 辅助")
	table.insert(forbiddenShako, "版本: "..name.. " (高等级)")
	table.insert(forbiddenShako, "{variant:"..(index * 2).."}此物品上的技能石受到 (25-35) 级的 "..name.." 辅助")
	table.insert(replicaForbiddenShako, "版本: "..name.. " (低等级)")
	table.insert(replicaForbiddenShako, "{variant:"..(index * 2 - 1).."}此物品上的技能石受到 (1-10) 级的 "..name.." 辅助")
	table.insert(replicaForbiddenShako, "版本: "..name.. " (高等级)")
	table.insert(replicaForbiddenShako, "{variant:"..(index * 2).."}此物品上的技能石受到 (25-35) 级的 "..name.." 辅助")
end
table.insert(forbiddenShako, "+(25-30) 全属性")
table.insert(replicaForbiddenShako, "+(25-30) 全属性")
table.insert(data.uniques.generated, table.concat(forbiddenShako, "\n"))
table.insert(data.uniques.generated, table.concat(replicaForbiddenShako, "\n"))

local enduranceChargeMods = {
	[3] = {
		["Up to Max."] = "若你可以获得耐力球，则有 15% 的几率直接获得最大数量的耐力球",
		["Duration"] = "耐力球持续时间延长 (20-40)%",
		["Movement Speed"] = "每个耐力球可使移动速度提高 1%",
		["Armour"] = "每有一个耐力球，护甲提高 6%",
		["Add Fire Damage"] = "每个耐力球附加 (7-9) 到 (13-14) 基础火焰伤害",
		["Inc. Damage"] = "每个耐力球可使伤害提高 5%",
		["On Kill"] = "击败敌人有 10% 的几率时获得耐力球",
	},
	[2] = {
		["Block Attacks"] = "每有一个耐力球，攻击伤害格挡几率额外 +1%",
		["Spell Suppression"] = "法术伤害压制率按照每个耐力球 +1%",
		["Chaos Res"] = "混沌抗性按照每个耐力球 +4%",
		["Fire as Chaos"] = "每有一个耐力球则获得额外混沌伤害， 其数值等同于火焰伤害的 1%",
		["Attack and Cast Speed"] = "每个耐力球可使攻击和施法速度提高 1%",
		["Regen. Life"] = "生命按照每个耐力球每秒再生 0.3%",
		["Inc. Critical Strike Chance"] = "每个耐力球可使暴击率提高 6%",
	},
	[1] = {
		["Gain every second"] = "若你近期被击中，则每秒获得 1 个耐力球",
		["+1 Maximum"] = "耐力球数量上限 +1",
		["Cannot be Stunned"] = "耐力球达到上限时你无法被晕眩",
		["Vaal Pact"] = "你在拥有最大数量的耐力球时，获得【瓦尔冥约】状态",
		["Intimidate"] = "耐力球满时，攻击击中时威吓敌人 4 秒",
	},
}

local frenzyChargeMods = {
	[3] = {
		["Up to Max."] = "当你可能获得狂怒球时，有 15% 的几率直接获得最大数量的狂怒球",
		["Duration"] = "狂怒球持续时间延长 (20-40)%",
		["Movement Speed"] = "每个狂怒球可使移动速度提高 1%",
		["Evasion"] = "每个狂怒球提高 8% 闪避值",
		["Add Cold Damage"] = "每个狂怒球附加 (6-8) 到 (12-13) 点冰霜伤害",
		["Inc. Damage"] = "每个狂怒球可使伤害提高 5%",
		["On Kill"] = "击败敌人有 10% 的几率获得狂怒球",
	},
	[2] = {
		["Block Attacks"] = "每有一个狂怒球，攻击伤害格挡几率额外 +1%",
		["Spell Suppression"] = "法术伤害压制率按照每个狂怒球 +1%",
		["Accuracy Rating"] = "每个狂怒球可使命中值提高 10%",
		["Cold as Chaos"] = "每有一个狂怒球则获得额外混沌伤害， 其数值等同于冰霜伤害的 1%",
		["Phys. Damage Red."] = "每有一个暴击球，可使你获得额外 1% 物理伤害减免",
		["Regen. Life"] = "每个狂怒球每秒回复 0.3% 生命",
		["Inc. Critical Strike Chance"] = "每个狂怒球可使暴击率提高 6%",
	},
	[1] = {
		["Gain on Hit"] = "击中时有 10% 的几率获得狂怒球",
		["+1 Maximum"] = "狂怒球数量上限 +1",
		["Flask Charge on Crit"] = "狂怒球满时，打出暴击时获得 1 点充能",
		["Iron Reflexes"] = "你在拥有最大数量的狂怒球时，得到【霸体】状态",
		["Onslaught"] = "狂怒球满时，击中时获得【猛攻效果】 4 秒",
	},
}

local powerChargeMods = {
	[3] = {
		["Up to Max."] = "当你可能获得暴击球时，有 15% 的几率直接获得最大数量的暴击球",
		["Duration"] = "暴击球的持续时间延长 (20-40)%",
		["Movement Speed"] = "每个暴击球可使移动速度提高 1%",
		["Energy Shield"] = "每有一个暴击球，能量护盾提高 3%",
		["Add Lightning Damage"] = "每个暴击球造成 (1-2) 到 (18-20) 闪电伤害",
		["Inc. Damage"] = "每个暴击球可使伤害提高 5%",
		["On Kill"] = "击败敌人有 10% 的几率获得暴击球",
	},
	[2] = {
		["Block Attacks"] = "每有一个暴击球，攻击伤害格挡几率额外 +1%",
		["Spell Suppression"] = "法术伤害压制率按照每个暴击球 +1%",
		["Phys. Damage Red."] = "每有一个暴击球，可使你获得额外 1% 物理伤害减免",
		["Lightning as Chaos"] = "每有一个暴击球则获得额外混沌伤害， 其数值等同于闪电伤害的 1%",
		["Attack and Cast Speed"] = "每个暴击球可使攻击和施法速度提高 1%",
		["Regen. Life"] = "每个暴击球可使每秒回复 0.3% 生命",
		["Crit Strike Multi"] = "每个暴击球 +3% 暴击伤害加成",
	},
	[1] = {
		["Gain on Crit"] = "暴击时有 20% 的几率获得暴击球",
		["+1 Maximum"] = "暴击球数量上限 +1",
		["Arcane Surge with Spells"] = "暴击球满时，法术击中时获得【秘术增强】",
		["Mind over Matter"] = "你在拥有最大数量的暴击能量球时，得到【心胜于物】状态",
		["Additional Curse"] = "当暴击球达到上限时，你可以对敌人额外施加 1 个诅咒",
	},
}

local precursorsEmblem = {
[[先驱的纹章
联盟: 地心
版本: 黄玉戒指
版本: 蓝玉戒指
版本: 红玉戒指
版本: 双玉戒指(冰闪)
版本: 双玉戒指(火闪)
版本: 双玉戒指(火冰)
版本: 三相戒指]]
}

for _, type in ipairs({ { prefix = "耐力球 - ", mods = enduranceChargeMods }, { prefix = "狂怒球 - ", mods = frenzyChargeMods }, { prefix = "暴击球 - ", mods = powerChargeMods } }) do
	for tier, mods in ipairs(type.mods) do
		for desc, mod in pairs(mods) do
			table.insert(precursorsEmblem, "版本: " .. type.prefix .. desc)
		end
	end
end
table.insert(precursorsEmblem, [[Selected Variant: 1
{variant:1}黄玉戒指
{variant:2}蓝玉戒指
{variant:3}红玉戒指
{variant:4}双玉戒指(冰闪)
{variant:5}双玉戒指(火闪)
{variant:6}双玉戒指(火冰)
{variant:7}三相戒指
Has Alt Variant: true
Has Alt Variant Two: true
Has Alt Variant Three: true
等级需求: 49
固定基底词缀: 7
{tags:jewellery_resistance}{variant:1}+(20-30)% 闪电抗性
{tags:jewellery_resistance}{variant:2}+(20-30)% 冰霜抗性
{tags:jewellery_resistance}{variant:3}+(20-30)% 火焰抗性
{tags:jewellery_resistance}{variant:4}+(12-16)% 冰霜和闪电抗性
{tags:jewellery_resistance}{variant:5}+(12-16)% 火焰和闪电抗性
{tags:jewellery_resistance}{variant:6}+(12-16)% 火焰和冰霜抗性
{tags:jewellery_resistance}{variant:7}+(8-10)% 所有元素抗性
{tags:jewellery_attribute}{variant:1}+20 智慧
{tags:jewellery_attribute}{variant:2}+20 敏捷
{tags:jewellery_attribute}{variant:3}+20 力量
{tags:jewellery_attribute}{variant:4}+20 力量和智慧
{tags:jewellery_attribute}{variant:5}+20 敏捷和智慧
{tags:jewellery_attribute}{variant:6}+20 力量和敏捷
{tags:jewellery_attribute}{variant:7}+20 全属性
{tags:jewellery_defense}最大能量护盾提高 5%
{tags:life}最大生命提高 5%]])

local index = 8
for _, type in ipairs({ enduranceChargeMods, frenzyChargeMods, powerChargeMods }) do
	for tier, mods in ipairs(type) do
		for desc, mod in pairs(mods) do
			if mod:match("[%+%-]?[%d%.]*%d+%%") then
				mod = mod:gsub("([%d%.]*%d+)", function(num) return "(" .. num .. "-" .. tonumber(num) * tier .. ")" end)
			elseif mod:match("%(%-?[%d%.]+%-[%d%.]+%)%%") then
				mod = mod:gsub("(%(%-?[%d%.]+%-)([%d%.]+)%)", function(preceding, higher) return preceding .. tonumber(higher) * tier .. ")" end)
			elseif mod:match("%(%d+%-%d+%) 到 %(%d+%-%d+%)") then
				mod = mod:gsub("(%(%d+%-)(%d+)(%) 到 %(%d+%-)(%d+)%)", function(preceding, higher1, middle, higher2) return preceding .. higher1 * tier .. middle .. higher2 * tier .. ")" end)
			end
			table.insert(precursorsEmblem, "{variant:" .. index .. "}{range:0}" .. mod)
			index = index + 1
		end
	end
end
table.insert(data.uniques.generated, table.concat(precursorsEmblem, "\n"))

local skinOfTheLords = {
	"君主之肤",
	"简易之袍",
	"联盟: 裂隙",
	"源: 传奇【忠诚之肤】使用通货【夏乌拉的祝福】升级",
}
local excludedItemKeystones = {
	"腐化的灵魂", -- exclusive to specific unique
	"神圣血肉", -- exclusive to specific unique
	"空明之掌", -- exclusive to specific unique
	"不朽野望", -- exclusive to specific unique
	"苦难秘辛", -- exclusive to specific items
	"内在信念", -- exclusive to specific items
	"移灵换影", -- removed from game
	"凡人的信念", -- removed from game
}
local excludedPassiveKeystones = {
	"异灵之体", -- to prevent infinite loop
	"灵能护盾", -- to prevent infinite loop
}
local skinOfTheLordsKeystones = {}
for _, name in ipairs(data.keystones) do
	if not isValueInArray(excludedItemKeystones, name) and not isValueInArray(excludedPassiveKeystones, name) then
		table.insert(skinOfTheLordsKeystones, name)
	end
end
for _, name in ipairs(skinOfTheLordsKeystones) do
	table.insert(skinOfTheLords, "版本: "..name)
end
table.insert(skinOfTheLords, "固定基底词缀: 0")
table.insert(skinOfTheLords, "插槽无法被调整")
table.insert(skinOfTheLords, "此物品上装备的技能石等级 +2")
table.insert(skinOfTheLords, "全局防御提高 100%")
table.insert(skinOfTheLords, "只能在此物品上放入已腐化的技能石")
for index, name in ipairs(skinOfTheLordsKeystones) do
	table.insert(skinOfTheLords, "{variant:"..index.."}"..name)
end
table.insert(skinOfTheLords, "已腐化")
table.insert(data.uniques.generated, table.concat(skinOfTheLords, "\n"))

local impossibleEscapeKeystones = {}
for _, name in ipairs(data.keystones) do
	if not isValueInArray(excludedItemKeystones, name) then
		table.insert(impossibleEscapeKeystones, name)
	end
end
local impossibleEscape = {
	"无所遁形",
	"翠绿珠宝",
	"联盟: 罪恶枷锁",
	"仅限: 1",
	"来源: 传奇Boss【贤主】专属掉落",
	"范围: 小"
}
for _, name in ipairs(impossibleEscapeKeystones) do
	table.insert(impossibleEscape, "版本: "..name)
end
table.insert(impossibleEscape, "版本: 全部 (用于测试)")
local variantCount = #impossibleEscapeKeystones + 1
for index, name in ipairs(impossibleEscapeKeystones) do
	table.insert(impossibleEscape, "{variant:"..index..","..variantCount.."}"..name.."范围内的天赋可以在未连结至天赋树的情况下配置")
end
table.insert(impossibleEscape, "已腐化")
table.insert(data.uniques.generated, table.concat(impossibleEscape, "\n"))

--[[ 3 scenarios exist for legacy mods
	- Mod changed, but kept the same mod Id
		-- Has legacyMod
	- Mod removed, or changed with a new mod Id
		-- Has only a version when it changed
	- Mod changed/removed, but isn't legacy
		-- Has empty table to exclude it from the list

	4th scenario: Mod was changed (not legacy), but the mod ID (aka Variant name) no longer reflects the mod
		-- Has 'rename' field to customize the name
]]
local watchersEyeLegacyMods = {
	["ClarityManaAddedAsEnergyShield"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(12-18)")) end,
	},
	["ClarityReducedManaCost"] = {
		["version"] = "3.8.0",
	},
	["ClarityManaRecoveryRate"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(20-30)")) end,
	},
	["DisciplineEnergyShieldRecoveryRate"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(20-30)")) end,
	},
	["MalevolenceDamageOverTimeMultiplier"] = {
		["version"] = "3.8.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(36-44)")) end,
	},
	["MalevolenceLifeAndEnergyShieldRecoveryRate"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(15-20)")) end,
	},
	["PrecisionIncreasedCriticalStrikeMultiplier"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(30-50)")) end,
	},
	["VitalityDamageLifeLeech"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(1-1.5)")) end,
	},
	["VitalityFlatLifeRegen"] = {
		["version"] = "3.12.0",
	},
	["VitalityLifeRecoveryRate"] = {
		["version"] = "3.12.0",
		["legacyMod"] = function(currentMod) return (currentMod:gsub("%(.*%)", "(20-30)")) end,
	},
	["WrathLightningDamageManaLeech"] = {
		["version"] = "3.8.0",
	},
	["GraceChanceToDodge"] = {
		["rename"] = "Grace: Chance to Suppress Spells",
	},
	["HasteChanceToDodgeSpells"] = {
		["rename"] = "Haste: Chance to Suppress Spells",
	},
	["PurityOfFireReducedReflectedFireDamage"] = { },
	["PurityOfIceReducedReflectedColdDamage"] = { },
	["PurityOfLightningReducedReflectedLightningDamage"] = { },
	["MalevolenceSkillEffectDuration"] = { },
	["ZealotryMaximumEnergyShieldPerSecondToMaximumEnergyShieldLeechRate"] = { },
	["MalevolenceColdDamageOverTimeMultiplier"] = { },
	["MalevolenceChaosNonAilmentDamageOverTimeMultiplier"] = { },
}

local watchersEye = {
[[
守望之眼
三相珠宝
源: 传奇Boss【裂界者】专属掉落（【缥缈幻境】2词【创世之境】3词）
仅限: 1
Has Alt Variant: true
Has Alt Variant Two: true]]
}

local sublimeVision = {
[[
崇高愿景
三相珠宝
源: 传奇Boss【终极裂界者】专属掉落
仅限: 1
]]
}

local abbreviateModId = function(string)
	return (string:
	gsub("Increased", "Inc"):
	gsub("Reduced", "Red."):
	gsub("Critical", "Crit"):
	gsub("Physical", "Phys"):
	gsub("Elemental", "Ele"):
	gsub("Multiplier", "Mult"):
	gsub("EnergyShield", "ES"))
end

local variantNameCn = {
	Anger = "愤怒", Clarity = "清晰", Determination = "坚定", Discipline = "纪律",
	Grace = "优雅", Haste = "迅捷", Hatred = "憎恨", Malevolence = "怨毒",
	Precision = "精准", Pride = "骄傲", PurityOfElements = "元素净化", 
	PurityOfFire = "火焰净化", PurityOfIce = "冰霜净化", PurityOfLightning = "闪电净化", 
	Vitality = "活力", Wrath = "雷霆", Zealotry = "奋锐"
}

for _, mod in ipairs(data.uniqueMods["Watcher's Eye"]) do
	if not mod.Id:match("^SublimeVision") then
		-- local variantName = abbreviateModId(mod.Id):gsub("^[Purity Of ]*%u%l+", "%1:"):gsub("New", ""):gsub("[%u%d]", " %1"):gsub("_", ""):gsub("E S", "ES")
		local variantName = " " .. mod.mod[1]
		if not variantName then
			variantName = abbreviateModId(mod.Id):gsub("^[Purity Of ]*%u%l+", "%1:"):gsub("New", ""):gsub("[%u%d]", " %1"):gsub("_", ""):gsub("E S", "ES")
		end
		if watchersEyeLegacyMods[mod.Id] then
			if watchersEyeLegacyMods[mod.Id].version then
				table.insert(watchersEye, "版本:" .. variantName .. " (" .. watchersEyeLegacyMods[mod.Id].version .. "前)")
			end
			if watchersEyeLegacyMods[mod.Id].legacyMod then
				table.insert(watchersEye, "版本:" .. variantName)
			end
			if watchersEyeLegacyMods[mod.Id].rename then
				table.insert(watchersEye, "版本: " .. watchersEyeLegacyMods[mod.Id].rename)
			end
		else
			table.insert(watchersEye, "版本:" .. variantName)
		end
	else
		local variantName = mod.Id:gsub("SublimeVision", ""):gsub("[%u%d]", " %1")
		table.insert(sublimeVision, "版本:" .. " " .. variantNameCn[variantName:gsub(" ", "")])
	end
end

table.insert(watchersEye,
[[
最大能量护盾提高 (4-6)%
最大生命提高 (4-6)%
最大魔力提高 (4-6)%]])

local indexWatchersEye = 1
local indexSublimeVision = 1
for _, mod in ipairs(data.uniqueMods["Watcher's Eye"]) do
	if not mod.Id:match("^SublimeVision") then
		if watchersEyeLegacyMods[mod.Id] then
			if watchersEyeLegacyMods[mod.Id].legacyMod then
				table.insert(watchersEye, "{variant:" .. indexWatchersEye .. "}" .. watchersEyeLegacyMods[mod.Id].legacyMod(mod.mod[1]))
				indexWatchersEye = indexWatchersEye + 1
			end
			if watchersEyeLegacyMods[mod.Id].version or watchersEyeLegacyMods[mod.Id].rename then
				table.insert(watchersEye, "{variant:" .. indexWatchersEye .. "}" .. mod.mod[1])
				indexWatchersEye = indexWatchersEye + 1
			end
		else
			table.insert(watchersEye, "{variant:" .. indexWatchersEye .. "}" .. mod.mod[1])
			indexWatchersEye = indexWatchersEye + 1
		end
	else
		for i, _ in ipairs(mod.mod) do
			table.insert(sublimeVision, "{variant:" .. indexSublimeVision .. "}" .. mod.mod[i])
		end
		indexSublimeVision = indexSublimeVision + 1
	end
end

table.insert(data.uniques.generated, table.concat(watchersEye, "\n"))
table.insert(data.uniques.generated, table.concat(sublimeVision, "\n"))

function buildTreeDependentUniques(tree)
	buildForbidden(tree.classNotables)
end

function buildForbidden(classNotables)
	local forbidden = { }
	for _, name in pairs({"之火", "之肉"}) do
		forbidden[name] = { }
		table.insert(forbidden[name], "禁断" .. name)
		table.insert(forbidden[name], "三相珠宝")
		local index = 1
		for className, notableTable in pairs(classNotables) do
			for _, notableName in ipairs(notableTable) do
				table.insert(forbidden[name], "版本: (" .. className .. ") " .. notableName)
				index = index + 1
			end
		end
		if name == "之火" then
			table.insert(forbidden[name], "源: 传奇Boss【焚界者】专属掉落")
		else
			table.insert(forbidden[name], "源: 传奇Boss【灭界者】专属掉落")
		end
		table.insert(forbidden[name], "仅限: 1")
		table.insert(forbidden[name], "等级需求: 83")
		index = 1
		for className, notableTable in pairs(classNotables) do
			for _, notableName in ipairs(notableTable) do
				table.insert(forbidden[name], "{variant:" .. index .. "}" .. "需求 职业: " .. className)
				table.insert(forbidden[name], "{variant:" .. index .. "}" .. "禁断" .. (name == "之火" and "之肉" or "之火") .. "上有匹配的词缀则配置 ".. notableName)
				index = index + 1
			end
		end
		table.insert(forbidden[name], "已腐化")
	end
	table.insert(data.uniques.generated, table.concat(forbidden["之火"], "\n"))
	table.insert(data.uniques.generated, table.concat(forbidden["之肉"], "\n"))
end
