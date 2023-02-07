-- Path of Building
--
-- Module: Config Options
-- List of options for the Configuration tab.
--

local m_min = math.min
local m_max = math.max


local function applyPantheonDescription(tooltip, mode, index, value)
	tooltip:Clear()
	if value.val == "None" then
		return
	end
	local applyModes = { BODY = true, HOVER = true }
	if applyModes[mode] then
		local god = data.pantheons[value.val]
		for _, soul in ipairs(god.souls) do
			local name = soul.name
			local lines = { }
			for _, mod in ipairs(soul.mods) do
				table.insert(lines, mod.line)
			end
			tooltip:AddLine(20, '^8'..name)
			tooltip:AddLine(14, '^6'..table.concat(lines, '\n'))
			tooltip:AddSeparator(10)
		end
	end
end

local function banditTooltip(tooltip, mode, index, value)
	local banditBenefits = {
		["None"] = "获得 2 天赋点数",
		["Oak"] = "每秒回复 1% 最大生命\n获得 2% 额外物理伤害减免\n物理伤害提高 20%",
		["Kraityn"] = "攻击和施法速度提高 6%\n有 10% 的几率避免元素异常状态\n移动速度提高 6%",
		["Alira"] = "每秒回复 5 魔力\n+20% 暴击伤害加成\n+15% 元素抗性",
	}
	local applyModes = { BODY = true, HOVER = true }
	tooltip:Clear()
	if applyModes[mode] then
		tooltip:AddLine(14, '^8'..banditBenefits[value.val])
	end
end

return {
	-- Section: General options
	{ section = "常规", col = 1 },
	{ var = "resistancePenalty", type = "list", label = "抗性 惩罚:",  list = {{val=0,label="无"},{val=-30,label="第五章 (-30%)"},{val=nil,label="第十章 (-60%)"}} },


	{ var = "bandit", type = "list", label = "盗贼任务:", tooltipFunc = banditTooltip, list = {{val="None",label="全杀"},{val="Oak",label="帮助欧克"},{val="Kraityn",label="帮助克雷顿"},{val="Alira",label="帮助阿莉亚"}} },
	{ var = "pantheonMajorGod", type = "list", label = "大神:", tooltipFunc = applyPantheonDescription, list = {
		{ label = "无", val = "None" },
		{ label = "惊海之王", val = "TheBrineKing" },
		{ label = "月影女神", val = "Lunaris" },
		{ label = "日耀女神", val = "Solaris" },
		{ label = "阿拉卡力", val = "Arakaali" },
	} },
	{ var = "pantheonMinorGod", type = "list", label = "小神:", tooltipFunc = applyPantheonDescription, list = {
		{ label = "无", val = "None" },
		{ label = "格鲁丝克", val = "Gruthkul" },
		{ label = "尤格尔", val = "Yugul" },
		{ label = "艾贝拉斯", val = "Abberath" },
		{ label = "图克哈玛", val = "Tukohama" },
		{ label = "格鲁坎", val = "Garukhan" },
		{ label = "古斯特", val = "Ralakesh" },
		{ label = "瑞斯拉萨", val = "Ryslatha" },
		{ label = "沙卡丽", val = "Shakari" },
	} },
	{ var = "detonateDeadCorpseLife", type = "count", label = "敌人尸体的生命:", tooltip = "设置【爆灵术】和类似的灵柩爆炸技能.\n作为参考，70级怪物的生命为："..data.monsterLifeTable[70].." ，80级怪物的生命为： "..data.monsterLifeTable[80]..".", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "corpseLife", value = val }, "Config")
	end },
	{ var = "conditionStationary", type = "count", label = "你静止不移动?", ifCond = "Stationary",
		tooltip = "可使词缀 `静止时` 和 `静止时每秒`生效",
		apply = function(val, modList, enemyModList)
		if type(val) == "boolean" then
			-- Backwards compatibility with older versions that set this condition as a boolean
			val = val and 1 or 0
		end
		local sanitizedValue = m_max(0, val)
		modList:NewMod("Multiplier:StationarySeconds", "BASE", sanitizedValue, "Config")
		if sanitizedValue > 0 then
			modList:NewMod("Condition:Stationary", "FLAG", true, "Config")
		end
	end },

	{ var = "conditionMoving", type = "check", label = "你处于移动状态?", ifCond = "Moving", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Moving", "FLAG", true, "Config")
	end },
	{ var = "conditionInsane", type = "check", label = "你处于疯狂状态?", ifCond = "Insane", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Insane", "FLAG", true, "Config")
	end },
	{ var = "conditionFullLife", type = "check", label = "你处于^xE05030满血^xFFFFFF状态?", tooltip = "如果你有【异灵之体】天赋，你会自动被认为是满血的\n如果有必要，你可以勾选这个来认为你是满血的.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FullLife", "FLAG", true, "Config")
	end },
	{ var = "conditionLowLife", type = "check", label = "你处于^xE05030低血^xFFFFFF状态?", ifCond = "LowLife", tooltip = "当你至少有 50% 生命保留的时候会自动认为是低血状态,\n如果有必要，你可以勾选这个来认为你是低血的.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LowLife", "FLAG", true, "Config")
	end },
	{ var = "conditionFullMana", type = "check", label = "你处于^x7070FF满蓝^xFFFFFF状态?", ifCond = "FullMana", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FullMana", "FLAG", true, "Config")
	end },
	{ var = "conditionLowMana", type = "check", label = "你处于^x7070FF低魔^xFFFFFF状态?", ifCond = "LowMana", tooltip = "当你至少有 50% 魔力保留的时候会自动认为是低魔状态,\n如果有必要，你可以勾选这个来认为你是低魔的.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LowMana", "FLAG", true, "Config")
	end },
	{ var = "conditionFullEnergyShield", type = "check", label = "你处于^x88FFFF满能量护盾^xFFFFFF状态?", ifCond = "FullEnergyShield", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FullEnergyShield", "FLAG", true, "Config")
	end },
	{ var = "conditionLowEnergyShield", type = "check", label = "你处于^x88FFFF低能量护盾^xFFFFFF状态?", ifCond = "LowEnergyShield", tooltip = "You will automatically be considered to be on Low ^x88FFFFEnergy Shield ^7if you have at least 50% ^x88FFFFES ^7reserved,\nbut you can use this option to force it if necessary.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LowEnergyShield", "FLAG", true, "Config")
	end },
	{ var = "conditionHaveEnergyShield", type = "check", label = "你经常保持有^x88FFFF能量护盾^xFFFFFF?", ifCond = "HaveEnergyShield", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HaveEnergyShield", "FLAG", true, "Config")
	end },
	{ var = "minionsConditionFullLife", type = "check", label = "你的召唤生物处于^xE05030满血^xFFFFFF状态?",  apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:FullLife", "FLAG", true, "Config") }, "Config")
	end },
	{ var = "minionsConditionCreatedRecently", type = "check", label = "你的召唤物的近期内召唤的？", ifCond = "MinionsCreatedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MinionsCreatedRecently", "FLAG", true, "Config")
	end },
	{ var = "igniteMode", type = "list", label = "异常计算模式:", tooltip = "目前以基础点伤来计算异常效果:\n平均伤害：异常是基于平均伤害计算，区分暴击和非暴击.\n暴击伤害：异常基于暴击计算.", list = {{val="AVERAGE",label="平均伤害"},{val="CRIT",label="暴击伤害"}} },
	{ var = "physMode", type = "list", label = "随机元素模式:", ifFlag = "randomPhys", tooltip = "控制随机转元素词缀该如何选择一种元素\n\t平均: 词缀会使得同时获得各三分之一的物理转火焰、冰霜、闪电效果\n\t火焰/冰霜/闪电: 词缀会根据选择的元素类型获得全额元素转换效果\n若一条词缀只在两种元素之间随机选择，那么全额数值只能在这两种元素之间分配", list = {{val="AVERAGE",label="平均"},{val="FIRE",label="火焰"},{val="COLD",label="冰霜"},{val="LIGHTNING",label="闪电"}} },
	{ var = "lifeRegenMode", type = "list", label = "^xE05030生命^7回复计算模式:", tooltip = "控制^xE05030生命^7回复如何计算:\n\t最小: 不包括爆发性回复\n\t平均: 包括爆发性回复，根据时间进行平均\n\t爆发: 包括爆发性回复", list = {{val="MIN",label="最小"},{val="AVERAGE",label="平均"},{val="FULL",label="爆发"}}, apply = function(val, modList, enemyModList)
		if val == "AVERAGE" then
			modList:NewMod("Condition:LifeRegenBurstAvg", "FLAG", true, "Config")
		elseif val == "FULL" then
			modList:NewMod("Condition:LifeRegenBurstFull", "FLAG", true, "Config")
		end
	end },
	{ var = "EHPUnluckyWorstOf", type = "list", label = "承受伤害不幸时的等效血池:", tooltip = "设置EHP计算方式以降低随机效果的影响", list = {{val=1,label="平均"},{val=2,label="不幸"},{val=4,label="非常不幸"}} },
	{ var = "DisableEHPGainOnBlock", type = "check", label = "忽略等效血池中格挡时回复部分:", tooltip = "设置EHP在计算时不应用格挡时回复的效果"},
	{ var = "armourCalculationMode", type = "list", label = "护甲计算模式:", tooltip = "配置护甲的计算方式:\n\t最小：不计算双倍护甲\n\t平均：根据双倍护甲的几率进行计算预期减伤\n\t最大：始终使用100% 双倍护甲计算，如果有 100% 几率双倍护甲，那么此配置无效.", list = {{val="MIN",label="最小"},{val="AVERAGE",label="平均"},{val="MAX",label="最大"}}, apply = function(val, modList, enemyModList)
		if val == "MAX" then
			modList:NewMod("Condition:ArmourMax", "FLAG", true, "Config")
		elseif val == "AVERAGE" then
			modList:NewMod("Condition:ArmourAvg", "FLAG", true, "Config")
		end
	end },




	{ var = "warcryMode", type = "list", label = "战吼计算模式:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", "激励战吼", "震地战吼" }, tooltip = "控制战吼的增助攻击的计算模式：\n平均：根据施法/攻击/战吼冷却速度来计算\n最大击中：所有战吼按照最大击中计算", list = {{val="AVERAGE",label="平均"},{val="MAX",label="最大击中"}}, apply = function(val, modList, enemyModList)
		if val == "MAX" then
			modList:NewMod("Condition:WarcryMaxHit", "FLAG", true, "Config")
		end
	end },
	{ var = "EVBypass", type = "check", label = "禁用【皇帝的警戒】的无法规避能量护盾", ifCond = "EVBypass", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EVBypass", "FLAG", true, "Config")
	end },

	-- Section: Skill-specific options
	{ section = "技能选项", col = 2 },
	{ label = "奥法烙印:", ifSkill = "Arcanist Brand" },
	{ var = "targetBrandedEnemy", type = "check", label = "技能目标为烙印附着的敌人?", ifSkill = "奥法烙印", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TargetingBrandedEnemy", "FLAG", true, "Config")
	end },
	{ label = "【鸟之势】:", ifSkill = "鸟之势" },
	{ var = "aspectOfTheAvianAviansMight", type = "check", label = "有【鸟之力量】buff?", ifSkill = "鸟之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AviansMightActive", "FLAG", true, "Config")
	end },
	{ var = "aspectOfTheAvianAviansFlight", type = "check", label = "有【鸟之斗魄】buff?", ifSkill = "鸟之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AviansFlightActive", "FLAG", true, "Config")
	end },
	{ label = "【猫之势】:", ifSkill = "猫之势" },
	{ var = "aspectOfTheCatCatsStealth", type = "check", label = "有【猫之隐匿】buff?", ifSkill = "猫之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CatsStealthActive", "FLAG", true, "Config")
	end },
	{ var = "aspectOfTheCatCatsAgility", type = "check", label = "有【猫之敏捷】buff?", ifSkill = "猫之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CatsAgilityActive", "FLAG", true, "Config")
	end },
	{ label = "【蟹之势】:", ifSkill = "蟹之势" },
	{ var = "overrideCrabBarriers", type = "count", label = "【深海屏障】数量(如果不是最大层的话):", ifSkill = "蟹之势", apply = function(val, modList, enemyModList)
		modList:NewMod("CrabBarriers", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ label = "【蛛之势】:", ifSkill = "蛛之势" },
	{ var = "aspectOfTheSpiderWebStacks", type = "count", label = "蜘蛛网层数:", ifSkill = "蛛之势", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraSkillMod", "LIST", { mod = modLib.createMod("Multiplier:SpiderWebApplyStack", "BASE", val) }, "Config", { type = "SkillName", skillName = "蛛之势" })


	end },

	{ label = "旗帜技能:", ifSkillList = { "恐怖之旗", "战旗", "抗争之旗" } },
	{ var = "bannerPlanted", type = "check", label = "旗帜放置?", ifSkillList = { "恐怖之旗", "战旗", "抗争之旗"}, apply = function(val, modList, enemyModList)

		modList:NewMod("Condition:BannerPlanted", "FLAG", true, "Config")
	end },
	{ var = "bannerStages", type = "count", label = "旗帜阶层:", ifSkillList = { "恐怖之旗", "战旗", "抗争之旗" }, apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:BannerStage", "BASE", m_min(val, 50), "Config")
	end },
	{ label = "【剑刃风暴】:", ifSkill = "剑刃风暴" },
	{ var = "bladestormInBloodstorm", type = "check", label = "你处于血姿态?", ifSkill = "剑刃风暴", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BladestormInBloodstorm", "FLAG", true, "Config", { type = "SkillName", skillName = "剑刃风暴" })
	end },
	{ var = "bladestormInSandstorm", type = "check", label = "你处于沙姿态?", ifSkill = "剑刃风暴", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BladestormInSandstorm", "FLAG", true, "Config", { type = "SkillName", skillName = "剑刃风暴" })
	end },
	{ label = "七伤破:", ifSkill = "七伤破" },
	{ var = "boneshatterTraumaStacks", type = "count", label = "# 层创伤:", ifSkill = "七伤破", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:TraumaStacks", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ label = "烙印技能:", ifSkillList = { "末日烙印", "风暴烙印","奥法烙印" ,"忏悔烙印","冬潮烙印" } }, -- I barely resisted the temptation to label this "Generic Brand:"
	{ var = "ActiveBrands", type = "count", label = "激活的烙印数量:", ifSkillList = { "Armageddon Brand", "Storm Brand", "Arcanist Brand", "Penance Brand", "Wintertide Brand" }, apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ConfigActiveBrands", "BASE", val, "Config")
	end },

	{ var = "BrandsAttachedToEnemy", type = "count", label = "附着到敌人身上的烙印：", ifEnemyMult = "BrandsAttached", apply = function(val, modList, enemyModList)

		modList:NewMod("Multiplier:ConfigBrandsAttachedToEnemy", "BASE", val, "Config")
	end },
	{ var = "BrandsInLastQuarter", type = "check", label = "处于最后25%的附着时间?", ifCond = "BrandLastQuarter", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BrandLastQuarter", "FLAG", true, "Config")
	end },

	{ label = "腐化魔像:", ifSkill = "召唤腐化魔像" },
	{ var = "carrionGolemNearbyMinion", type = "count", label = "#周围非魔像召唤生物数量:", ifSkill = "召唤腐化魔像", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyNonGolemMinion", "BASE", val, "Config")
	end },
	{ label = "近战:", ifSkill = "近战（辅）" },
	{ var = "closeCombatCombatRush", type = "check", label = "获得战斗冲击?", ifSkill = "近战（辅）", tooltip = "若位移技能没有被近战辅助，则战斗冲击使该位移技能的攻击速度总增 20%.",apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CombatRushActive", "FLAG", true, "Config")
	end },
	{ label = "凌厉:", ifSkill = "凌厉（辅）" },
	{ var = "overrideCruelty", type = "count", label = "持续伤害总增 % (如果没有达到最大):", ifSkill = "凌厉（辅）", tooltip = "技能被凌厉辅助时，按照击中时造成的伤害量使其持续伤害总增 40%", apply = function(val, modList, enemyModList)
		modList:NewMod("Cruelty", "OVERRIDE", m_min(val, 40), "Config", { type = "Condition", var = "Combat" })
	end },
	{ label = "旋风斩:", ifSkill = "旋风斩" },
	{ var = "channellingCycloneCheck", type = "check", label = "你正在吟唱旋风斩?", ifSkill = "旋风斩", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChannellingCyclone", "FLAG", true, "Config")
	end },
	{ label = "暗夜血契:", ifSkill = "暗夜血契" },
	{ var = "darkPactSkeletonLife", type = "count", label = "魔侍^xE05030生命:", ifSkill = "暗夜血契", tooltip = "设置使用【暗夜血契】时，魔侍的最大生命.", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "skeletonLife", value = val }, "Config", { type = "SkillName", skillName = "暗夜血契" })
	end },

	{ label = "掠食:", ifSkill = "掠食（辅）" },
	{ var = "deathmarkDeathmarkActive", type = "check", label = "敌人被标记?", ifSkill = "掠食（辅）", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EnemyHasDeathmark", "FLAG", true, "Config")
	end },
	{ label = "元素大军:", ifSkill = "元素大军（辅）" },
	{ var = "elementalArmyExposureType", type = "list", label = "曝露类型:", ifSkill = "元素大军（辅）", list = {{val=0,label="无"},{val="Fire",label="^xB97123火焰"},{val="Cold",label="^x3F6DB3冰霜"},{val="Lightning",label="^xADAA47闪电"}}, apply = function(val, modList, enemyModList)
		if val == "Fire" then
			modList:NewMod("FireExposureChance", "BASE", 100, "Config")
		elseif val == "Cold" then
			modList:NewMod("ColdExposureChance", "BASE", 100, "Config")
		elseif val == "Lightning" then
			modList:NewMod("LightningExposureChance", "BASE", 100, "Config")
		end
	end },
	{ label = "能量之刃:", ifSkill = "能量之刃" },
	{ var = "energyBladeActive", type = "check", label = "启用能量之刃?", ifSkill = "能量之刃", tooltip = "大幅降低你的能量护盾，将你装备的武器变为一把能量之刃", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EnergyBladeActive", "FLAG", true, "Config")
	end },
	{ label = "疯狂之拥:", ifSkill = "疯狂之拥" },
	{ var = "embraceMadnessActive", type = "check", label = "启用疯狂之拥?", ifSkill = "疯狂之拥", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AffectedBy疯狂荣光", "FLAG", true, "Config")
	end },
	{ label = "狂噬:", ifSkill = "狂噬（辅）" },
	{ var = "feedingFrenzyFeedingFrenzyActive", type = "check", label = "启用狂噬增益效果?", ifSkill = "狂噬（辅）", tooltip = "狂噬增益效果:所有的召唤生物获得\n召唤生物移动速度提高 15%\n召唤生物攻击和施法速度提高 15%", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FeedingFrenzyActive", "FLAG", true, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Damage", "MORE", 10, "狂噬（辅）") }, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("MovementSpeed", "INC", 10, "狂噬（辅）") }, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Speed", "INC", 10, "狂噬（辅）") }, "Config")
	end },
	{ label = "烈焰之墙:", ifSkill = "烈焰之墙" },
	{ var = "flameWallAddedDamage", type = "check", label = "投射物穿过了烈焰之墙?", ifSkill = "烈焰之墙", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FlameWallAddedDamage", "FLAG", true, "Config")
	end },
	{ label = "冰霜护盾:", ifSkill = "冰霜护盾" },
	{ var = "frostShieldStages", type = "count", label = "层数:", ifSkill = "冰霜护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:冰霜护盾Stage", "BASE", val, "Config")
	end },
	{ label = "【召唤高等时空先驱者】:", ifSkill =  "召唤高等时空先驱者" },
	{ var = "greaterHarbingerOfTimeSlipstream", type = "check", label = "开启时空先驱者光环?:", ifSkill =  "召唤高等时空先驱者", tooltip = "【召唤高等时空先驱者】增益效果：\n动作速度提高 10%\n增益影响玩家和友军\n增益效果持续 8 秒，并且有 10 秒冷却时间", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:GreaterHarbingerOfTime", "FLAG", true, "Config")
	end },
	{ label = "【召唤时空先驱者】:", ifSkill =  "召唤时空先驱者" },
	{ var = "harbingerOfTimeSlipstream", type = "check", label = "开启时空先驱者光环?:", ifSkill =  "召唤时空先驱者", tooltip = "【召唤时空先驱者】增益效果:\n动作速度提高 10%\n增益影响小范围内的友军，玩家和敌人\n增益效果持续 8 秒，并且有 20 秒冷却时间", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HarbingerOfTime", "FLAG", true, "Config")
	end },
	{ label = "【魔蛊】:", ifSkillFlag = "hex", ifMult = "MaxDoom" },
	{ var = "multiplierHexDoom", type = "count", label = "末日之力层数:", ifSkillFlag = "hex", ifMult = "MaxDoom", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:HexDoomStack", "BASE", val, "Config")
	end },
	{ label = "【苦痛之捷】:", ifSkill = "苦痛之捷" },
	{ var = "heraldOfAgonyVirulenceStack", type = "count", label = "【毒力】层数:", ifSkill = "苦痛之捷", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:VirulenceStack", "BASE", val, "Config")
	end },
	{ label = "【冰霜新星】:", ifSkill = "冰霜新星" },
	{ var = "conditionCastOnFrostbolt", type = "check", label = "是否由【寒冰弹】触发?", ifSkill = "冰霜新星", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastOnFrostbolt", "FLAG", true, "Config", { type = "SkillName", skillName = "冰霜新星" })
	end },
	{ label = "【灌注】:", ifSkill = "灌能吟唱(辅)" },
	{ var = "infusedChannellingInfusion", type = "check", label = "激活【灌注】?", ifSkill = "灌能吟唱(辅)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:InfusionActive", "FLAG", true, "Config")
	end },
	{ label = "【闪电支配】", ifSkill = "闪电支配(辅)" },
	{ var = "innervateInnervation", type = "check", label = "处于【闪电支配】状态?", ifSkill = "闪电支配(辅)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:InnervationActive", "FLAG", true, "Config")
	end },
	{ label = "【法术凝聚】:", ifSkillList = {"法术凝聚（辅）","电殛长枪", "会心一击（辅）"} },
	{ var = "intensifyIntensity", type = "count", label = "# 层【法术凝聚】:", ifSkillList = {"法术凝聚（辅）","电殛长枪","会心一击（辅）"} , apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Intensity", "BASE", val, "Config")
	end },
	{ label = "【肉盾（辅）】:", ifSkill = "肉盾（辅）" },
	{ var = "meatShieldEnemyNearYou", type = "check", label = "敌人在你附近?", ifSkill = "肉盾（辅）", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MeatShieldEnemyNearYou", "FLAG", true, "Config")
	end },
	{ label = "【瘟疫使徒】:", ifSkill = "瘟疫使徒"},
	{ var = "plagueBearerState", type = "list", label = "State:", ifSkill = "瘟疫使徒", list = {{val="INC",label="孕育中"},{val="INF",label="传染中"}}, apply = function(val, modList, enemyModList)
		if val == "INC" then
			modList:NewMod("Condition:PlagueBearerIncubating", "FLAG", true, "Config")
		elseif val == "INF" then
			modList:NewMod("Condition:PlagueBearerInfecting", "FLAG", true, "Config")
		end
	end },
	{ label = "【凿击】:", ifSkill = "凿击"},
	{ var = "perforateSpikeOverlap", type = "count", label = "凿击的尖刺数量:", tooltip = "影响凿击在血姿势模式下的伤害\n最大数量取决于凿击技能.", ifSkill = "凿击", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:PerforateSpikeOverlap", "BASE", val, "Config", { type = "SkillName", skillName = "凿击" })
	end },
	{ label = "【物理神盾】:", ifSkill = "物理神盾" },
	{ var = "physicalAegisDepleted", type = "check", label = "物理神盾耗尽了?", ifSkill = "物理神盾", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:PhysicalAegisDepleted", "FLAG", true, "Config")
	end },
	{ label = "【尊严】:", ifSkill = "尊严" },
	{ var = "prideEffect", type = "list", label = "尊严光环效果:", ifSkill = "尊严", list = {{val="MIN",label="初始效果"},{val="MAX",label="最大效果"}}, apply = function(val, modList, enemyModList)
		if val == "MAX" then
			modList:NewMod("Condition:PrideMaxEffect", "FLAG", true, "Config")
		end
	end },
	{ label = "【怒火漩涡】:", ifSkill = "怒火漩涡" },
	{ var = "sacrificedRageCount", type = "count", label = "献祭的怒火值:", ifSkill = "怒火漩涡", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:RageSacrificed", "BASE", val, "Config")
	end },
	{ label = "【召唤灵体】:", ifSkill = "召唤灵体" },
	{ var = "raiseSpectreEnableBuffs", type = "check", defaultState = true, label = "启用增益效果:", ifSkill = "召唤灵体", tooltip = "开启你的灵体拥有的增益效果.", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Buff }, { type = "SkillName", skillName = "召唤灵体", summonSkill = true })
	end },
	{ var = "raiseSpectreEnableCurses", type = "check", defaultState = true, label = "启用诅咒:", ifSkill = "召唤灵体", tooltip = "开启你的灵体拥有的诅咒技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Hex }, { type = "SkillName", skillName = "召唤灵体", summonSkill = true })
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Mark }, { type = "SkillName", skillName = "召唤灵体", summonSkill = true })
	end },
	{ var = "raiseSpectreBladeVortexBladeCount", type = "count", label = "飞刃风暴层数:", ifSkillList = {"DemonModularBladeVortexSpectre","GhostPirateBladeVortexSpectre"}, tooltip = "Sets the blade count for Blade Vortex skills used by spectres.\nDefault is 1; maximum is 5.", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "dpsMultiplier", value = val }, "Config", { type = "SkillId", skillId = "DemonModularBladeVortexSpectre" })
		modList:NewMod("SkillData", "LIST", { key = "dpsMultiplier", value = val }, "Config", { type = "SkillId", skillId = "GhostPirateBladeVortexSpectre" })
	end },
	{ var = "raiseSpectreKaomFireBeamTotemStage", type = "count", label = "灼热射线图腾数量:", ifSkill = "KaomFireBeamTotemSpectre", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:KaomFireBeamTotemStage", "BASE", val, "Config")
	end },
	{ var = "raiseSpectreEnableSummonedUrsaRallyingCry", type = "check", label = "召唤之爪的激励战吼:", ifSkill = "DropBearSummonedRallyingCry", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillId", skillId = "DropBearSummonedRallyingCry" })
	end },
	{ label = "【召唤毒蛛】:", ifSkill = "召唤毒蛛" },
	{ var = "raiseSpidersSpiderCount", type = "count", label = "蜘蛛数量:", ifSkill = "召唤毒蛛", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:RaisedSpider", "BASE", m_min(val, 20), "Config")
	end },
	{ var = "animateWeaponLingeringBlade", type = "check", label = "幻化【徘徊之刃】?", ifSkill = "幻化武器", tooltip = "启用幻化【徘徊之刃】的伤害加成\n徘徊之刃的具体的武器基低尚不清楚，但是接近于匕首【玻璃利片】", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AnimatingLingeringBlades", "FLAG", true, "Config")
	end },
	{ label = "【威能法印】:", ifSkill = "威能法印" },
	{ var = "sigilOfPowerStages", type = "count", label = "层数:", ifSkill = "威能法印", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SigilOfPowerStage", "BASE", val, "Config")
	end },
	{ label = "【虹吸陷阱】:", ifSkill = "虹吸陷阱" },
	{ var = "siphoningTrapAffectedEnemies", type = "count", label = "受到影响的敌人数量:", ifSkill = "虹吸陷阱", tooltip = "设置受到【虹吸陷阱】影响的敌人数量.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyAffectedBySiphoningTrap", "BASE", val, "Config")
		modList:NewMod("Condition:SiphoningTrapSiphoning", "FLAG", true, "Config")
	end },
	{ label = "【狙击】:", ifSkill = "狙击" },
	{ var = "configSnipeStages", type = "count", label = "狙击层数:", ifSkill = "狙击", tooltip = "释放狙击之前吟唱的层数.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:狙击Stage", "BASE", m_min(val, 6), "Config")
	end },
	{ label = "【三位一体】:", ifSkill = "三位一体（辅）" },
	{ var = "configResonanceCount", type = "count", label = "最低的共振效果数量:", ifSkill = "三位一体（辅）", tooltip = "设置最低的共振效果的数值.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ResonanceCount", "BASE", m_max(m_min(val, 50), 0), "Config")
	end },
	{ label = "【召唤幽狼】:", ifSkill = "召唤幽狼" },
	{ var = "configSpectralWolfCount", type = "count", label = "幽狼数量:", ifSkill = "召唤幽狼", tooltip = "设置幽狼的数量.\n最大是 10.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SpectralWolfCount", "BASE", m_min(val, 10), "Config")
	end },
	{ label = "姿态技能:", ifSkillList = { "血与沙", "血肉与岩石", "破空斩", "剑刃风暴", "凿击" } },
	{ var = "bloodSandStance", type = "list", label = "姿态:", ifSkillList = { "血与沙", "血肉与岩石", "破空斩", "剑刃风暴", "凿击" }, list = {{val="BLOOD",label="血姿态"},{val="SAND",label="沙姿态"}}, apply = function(val, modList, enemyModList)
		if val == "SAND" then
			modList:NewMod("Condition:SandStance", "FLAG", true, "Config")
		end
	end },
	{ var = "changedStance", type = "check", label = "最近有切换姿态模式?", ifCond = "ChangedStanceRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChangedStanceRecently", "FLAG", true, "Config")
	end },
	{ label = "钢系技能:", ifSkillList = { "分裂钢刃", "破碎铁刃", "断金之刃" } },
	{ var = "shardsConsumed", type = "count", label = "消耗钢刃碎片:", ifSkillList = { "分裂钢刃", "破碎铁刃", "断金之刃" }, apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SteelShardConsumed", "BASE", m_min(val, 12), "Config")
	end },
	{ var = "steelWards", type = "count", label = "钢刃结界:", ifSkill = "破碎铁刃", tooltip = "消耗至少 2 个钢刃碎片时，获得一个钢刃结界，最多 6 个\n每个钢刃结界都使投射物攻击伤害的格挡率 +4%", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SteelWardCount", "BASE", val, "Config")
	end },
	{ label = "【暴雨箭】:", ifSkill = "暴雨箭" },
	{ var = "stormRainBeamOverlap", type = "count", label = "# 道波束重叠:", ifSkill = "暴雨箭", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "beamOverlapMultiplier", value = val }, "Config", { type = "SkillName", skillName = "暴雨箭" })
	end },

	{ label = "【召唤圣物】:", ifSkill = "召唤圣物" },
	{ var = "summonHolyRelicEnableHolyRelicBoon", type = "check", label = "启用圣物的加成光环:", ifSkill = "召唤圣物", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HolyRelicBoonActive", "FLAG", true, "Config")
	end },

	{ label = "【召唤闪电魔像】:", ifSkill = "召唤闪电魔像" },
	{ var = "summonLightningGolemEnableWrath", type = "check", label = "启用魔像【雷霆】光环:", ifSkill = "召唤闪电魔像", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillId", skillId = "LightningGolemWrath" })
	end },
	{ label = "【鲜血渴求】:", ifSkill = "鲜血渴求" },
	{ var = "nearbyBleedingEnemies", type = "count", label = "周围流血敌人数量:", ifSkill = "鲜血渴求", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyBleedingEnemies", "BASE", val, "Config" )
	end },
	{ label = "【毒雨】:", ifSkill = "毒雨" },
	{ var = "toxicRainPodOverlap", type = "count", label = "孢囊数量:", tooltip = "最大是投射物数量.", ifSkill = "毒雨", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "podOverlapMultiplier", value = val }, "Config", { type = "SkillName", skillName = "毒雨" })
	end },
	{ label = "【灰烬之捷】:", ifSkill = "灰烬之捷" },
	{ var = "hoaOverkill", type = "count", label = "溢出的伤害:", tooltip = "溢出的伤害将会以燃烧伤害的形式扩散至附近的敌人", ifSkill = "灰烬之捷", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "hoaOverkill", value = val }, "Config", { type = "SkillName", skillName = "灰烬之捷" })
	end },
	{ label = "【雷电魔爆】:", ifSkill = "Voltaxic Burst" },
	{ var = "voltaxicBurstSpellsQueued", type = "count", label = "# 个等待释放的法术:", ifSkill = "Voltaxic Burst", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:VoltaxicWaitingStages", "BASE", val, "Config")
	end },
	{ label = "【漩涡】 :", ifSkill = "漩涡 " },
	{ var = "vortexCastOnFrostbolt", type = "check", label = "由【寒冰弹】触发?", ifSkill = "漩涡", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastOnFrostbolt", "FLAG", true, "Config", { type = "SkillName", skillName = "漩涡" })
	end },
	{ label = "【霜暴】:", ifSkill = "霜暴" },
	{ var = "ColdSnapBypassCD", type = "check", label = "忽略冷却时间?", ifSkill = "霜暴", apply = function(val, modList, enemyModList)
		modList:NewMod("CooldownRecovery", "OVERRIDE", 0, "Config", { type = "SkillName", skillName = "霜暴" })
	end },
	{ label = "战吼:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", "激励战吼", "震地战吼" } },
	{ var = "multiplierWarcryPower", type = "count", label = "威力值:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", "激励战吼", "震地战吼" }, tooltip = "设置战吼的威力值.\n普通敌人提供 1 点威力值，\n魔法敌人提供 2 点，\n稀有敌人提供 10 点，\n传奇敌人提供 20 点\n，玩家则提供 5 点", apply = function(val, modList, enemyModList)
		modList:NewMod("WarcryPower", "OVERRIDE", val, "Config")
	end },
	{ label = "【定罪波】:", ifSkill = "定罪波" },
	{ var = "waveOfConvictionExposureType", type = "list", label = "曝露效果类型:", ifSkill = "定罪波", list = {{val=0,label="无"},{val="Fire",label="火焰"},{val="Cold",label="冰霜"},{val="Lightning",label="闪电"}}, apply = function(val, modList, enemyModList)
		if val == "Fire" then
			modList:NewMod("Condition:WaveOfConvictionFireExposureActive", "FLAG", true, "Config")
		elseif val == "Cold" then
			modList:NewMod("Condition:WaveOfConvictionColdExposureActive", "FLAG", true, "Config")
		elseif val == "Lightning" then
			modList:NewMod("Condition:WaveOfConvictionLightningExposureActive", "FLAG", true, "Config")
		end
	end },



	{ label = "【熔岩护盾】:", ifSkill = "熔岩护盾" },
	{ var = "MoltenShellDamageMitigated", type = "count", label = "减免的伤害数值:", tooltip = "被熔岩护盾减免的伤害", ifSkill = "熔岩护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "MoltenShellDamageMitigated", value = val }, "Config", { type = "SkillName", skillName = "熔岩护盾" })
	end },
	{ label = "【瓦尔.熔岩护盾】:", ifSkill = "瓦尔.熔岩护盾" },
	{ var = "VaalMoltenShellDamageMitigated", type = "count", label = "减免的伤害数值:", tooltip = "最后一秒被瓦尔.熔岩护盾减免的伤害", ifSkill = "瓦尔.熔岩护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "VaalMoltenShellDamageMitigated", value = val }, "Config", { type = "SkillName", skillName = "熔岩护盾" })
	end },
	{ label = "多段范围技能:", ifSkillList = { "震波陷阱", "电塔陷阱" } },
	{ var = "enemySizePreset", type = "list", label = "敌人体积预设:", ifSkillList = { "震波陷阱", "电塔陷阱" }, defaultIndex = 2, tooltip = [[
配置敌人的碰撞盒的半径，用于计算一些多重范围技能的效果(霰弹效应)
"小型": 半径设为2.
	绝大多数怪物和玩家的大小.
"中型": 半径设为3.
	绝大多数人形Boss的大小(如贤主;塑界者;伊泽洛).
"大型": 半径设为5.
	一些大型Boss的大小(如贤主;卡鲁之王冈姆;瓦尔超灵).
"巨型": 半径设为11.
	一些体型最大的Boss的大小(如贤主之核;惊海之王索亚格斯).]], list = {{val="Small",label="小型"},{val="Medium",label="中型"},{val="Large",label="大型"},{val="Huge",label="巨型"}}, apply = function(val, modList, enemyModList, build)
		if val == "Small" then
			build.configTab.varControls['enemyRadius']:SetPlaceholder(2, false)
			modList:NewMod("EnemyRadius", "BASE", 2, "Config")
		elseif val == "Medium" then
			build.configTab.varControls['enemyRadius']:SetPlaceholder(3, false)
			modList:NewMod("EnemyRadius", "BASE", 3, "Config")
		elseif val == "Large" then
			build.configTab.varControls['enemyRadius']:SetPlaceholder(5, false)
			modList:NewMod("EnemyRadius", "BASE", 5, "Config")
		elseif val == "Huge" then
			build.configTab.varControls['enemyRadius']:SetPlaceholder(11, false)
			modList:NewMod("EnemyRadius", "BASE", 11, "Config")
		end
	end },
	{ var = "enemyRadius", type = "integer", label = "敌人半径:", ifSkillList = { "震波陷阱", "电塔陷阱" }, tooltip = "配置敌人的碰撞盒的半径，用于计算一些多重范围技能的效果(霰弹效应).", apply = function(val, modList, enemyModList)
		modList:NewMod("EnemyRadius", "OVERRIDE", m_max(val, 1), "Config")
	end },

	-- Section: Map modifiers/curses
	{ section = "地图词缀和玩家 Debuff", col = 2 },
	{ label = "地图词缀-前缀:" },
	{ var = "enemyHasPhysicalReduction", type = "list", label = "怪物物理伤害减伤:", tooltip = "'装甲的'", list = {{val=0,label="无"},{val=20,label="20% (低阶)"},{val=30,label="30% (中阶)"},{val=40,label="40% (高阶)"}}, apply = function(val, modList, enemyModList)
		enemyModList:NewMod("PhysicalDamageReduction", "BASE", val, "Config")
	end },
	{ var = "enemyIsHexproof", type = "check", label = "敌人是【无咒的】?", tooltip = "'无咒的'", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Hexproof", "FLAG", true, "Config")
	end },
	{ var = "enemyHasLessCurseEffectOnSelf", type = "list", label = "对怪物的诅咒总效果额外降低:", tooltip = "'魔抗的'", list = {{val=0,label="无"},{val=25,label="25% (低阶)"},{val=40,label="40% (中阶)"},{val=60,label="60% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			enemyModList:NewMod("CurseEffectOnSelf", "MORE", -val, "Config")
		end
	end },
	{ var = "enemyCanAvoidPoisonBlindBleed", type = "list", label = "怪物几率免疫中毒，致盲和流血:", tooltip = "'避毒的'", list = {{val=0,label="无"},{val=25,label="25% (低阶)"},{val=45,label="45% (中阶)"},{val=65,label="65% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			enemyModList:NewMod("AvoidPoison", "BASE", val, "Config")
			enemyModList:NewMod("AvoidBleed", "BASE", val, "Config")
		end
	end },
	{ var = "enemyHasResistances", type = "list", label = "增加怪物的火焰、冰霜、闪电、混沌抗性:", tooltip = "'抗性的'", list = {{val=0,label="无"},{val="LOW",label="20%/15% (低阶)"},{val="MID",label="30%/20% (中阶)"},{val="HIGH",label="40%/25% (高阶)"}}, apply = function(val, modList, enemyModList)
		local map = { ["LOW"] = {20,15}, ["MID"] = {30,20}, ["HIGH"] = {40,25} }
		if map[val] then
			enemyModList:NewMod("ElementalResist", "BASE", map[val][1], "Config")
			enemyModList:NewMod("ChaosResist", "BASE", map[val][2], "Config")
		end
	end },
	{ label = "地图词缀-后缀:" },
	{ var = "playerHasElementalEquilibrium", type = "check", label = "玩家有【元素之相】?", tooltip = "'平衡之'", apply = function(val, modList, enemyModList)
		modList:NewMod("Keystone", "LIST", "元素之相", "Config")
	end },
	{ var = "playerCannotLeech", type = "check", label = "无法偷取怪物生命和魔力?", tooltip = "'凝血之'", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("CannotLeechLifeFromSelf", "FLAG", true, "Config")
		enemyModList:NewMod("CannotLeechManaFromSelf", "FLAG", true, "Config")
	end },
	{ var = "playerGainsReducedFlaskCharges", type = "list", label = "玩家获得的药剂充能降低:", tooltip = "'干枯之'", list = {{val=0,label="无"},{val=30,label="30% (低阶)"},{val=40,label="40% (中阶)"},{val=50,label="50% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("FlaskChargesGained", "INC", -val, "Config")
		end
	end },
	{ var = "playerHasMinusMaxResist", type = "count", label = "-X% 玩家的抗性上限:", tooltip = "'曝露之'\n中阶: 5-8%\n高阶: 9-12%", apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("FireResistMax", "BASE", -val, "Config")
			modList:NewMod("ColdResistMax", "BASE", -val, "Config")
			modList:NewMod("LightningResistMax", "BASE", -val, "Config")
			modList:NewMod("ChaosResistMax", "BASE", -val, "Config")
		end
	end },
	{ var = "playerHasLessAreaOfEffect", type = "list", label = "玩家技能的总范围额外缩小:", tooltip = "'短程之'", list = {{val=0,label="无"},{val=15,label="15% (低阶)"},{val=20,label="20% (中阶)"},{val=25,label="25% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("AreaOfEffect", "MORE", -val, "Config")
		end
	end },
	{ var = "enemyCanAvoidStatusAilment", type = "list", label = "怪物免疫元素异常状态:", tooltip = "'	隔绝之'", list = {{val=0,label="无"},{val=30,label="30% (低阶)"},{val=60,label="60% (中阶)"},{val=90,label="90% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			enemyModList:NewMod("AvoidIgnite", "BASE", val, "Config")
			enemyModList:NewMod("AvoidShock", "BASE", val, "Config")
			enemyModList:NewMod("AvoidFreeze", "BASE", val, "Config")
		end
	end },
	{ var = "enemyHasIncreasedAccuracy", type = "list", label = "玩家在躲避时很不幸/怪物命中值提高:", tooltip = "'	迟钝之'", list = {{val=0,label="None"},{val=30,label="30% (低阶)"},{val=40,label="40% (中阶)"},{val=50,label="50% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("DodgeChanceIsUnlucky", "FLAG", true, "Config")
			enemyModList:NewMod("Accuracy", "INC", val, "Config")
		end
	end },
	{ var = "playerHasLessArmourAndBlock", type = "list", label = "玩家的格挡率和护甲额外降低:", tooltip = "'	生锈之'", list = {{val=0,label="无"},{val="LOW",label="20%/20% (低阶)"},{val="MID",label="30%/25% (中阶)"},{val="HIGH",label="40%/30% (高阶)"}}, apply = function(val, modList, enemyModList)
		local map = { ["LOW"] = {20,20}, ["MID"] = {30,25}, ["HIGH"] = {40,30} }
		if map[val] then
			modList:NewMod("BlockChance", "INC", -map[val][1], "Config")
			modList:NewMod("Armour", "MORE", -map[val][2], "Config")
		end
	end },
	{ var = "playerHasPointBlank", type = "check", label = "玩家拥有【零点射击】?", tooltip = "'冲突之'", apply = function(val, modList, enemyModList)
		modList:NewMod("Keystone", "LIST", "零点射击", "Config")
	end },
	{ var = "playerHasLessLifeESRecovery", type = "list", label = "玩家生命和能量护盾回复速度额外降低:", tooltip = "'窒息之'", list = {{val=0,label="无"},{val=20,label="20% (低阶)"},{val=40,label="40% (中阶)"},{val=60,label="60% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("LifeRecoveryRate", "MORE", -val, "Config")
			modList:NewMod("EnergyShieldRecoveryRate", "MORE", -val, "Config")
		end
	end },
	{ var = "playerCannotRegenLifeManaEnergyShield", type = "check", label = "玩家无法回复生命，魔力和能量护盾?", tooltip = "'瘀血之'", apply = function(val, modList, enemyModList)
		modList:NewMod("NoLifeRegen", "FLAG", true, "Config")
		modList:NewMod("NoEnergyShieldRegen", "FLAG", true, "Config")
		modList:NewMod("NoManaRegen", "FLAG", true, "Config")
	end },
	{ var = "enemyTakesReducedExtraCritDamage", type = "count", label = "怪物受到的暴击伤害降低:", tooltip = "'坚韧之'\n低阶: 25-30%\n中阶: 31-35%\n高阶: 36-40%" , apply = function(val, modList, enemyModList)
		if val ~= 0 then
			enemyModList:NewMod("SelfCritMultiplier", "INC", -val, "Config")
		end
	end },
	{ var = "multiplierSextant", type = "count", label = "# 个六分仪影响该地区", ifMult = "Sextant", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Sextant", "BASE", m_min(val, 5), "Config")
	end },
	{ label = "传奇地图词缀:" },
	{ var = "PvpScaling", type = "check", label = "PvP 伤害效用变化", tooltip = "'元帅殿堂'", apply = function(val, modList, enemyModList)
		modList:NewMod("HasPvpScaling", "FLAG", true, "Config")
	end },
	{ label = "玩家被诅咒:" },
	{ var = "playerCursedWithAssassinsMark", type = "count", label = "暗影印记:", tooltip = "设置玩家身上的【暗影印记】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "AssassinsMark", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithConductivity", type = "count", label = "导电:", tooltip = "设置玩家身上的【导电】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Conductivity", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithDespair", type = "count",  label = "绝望:", tooltip = "设置玩家身上的【绝望】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Despair", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithElementalWeakness", type = "count", label = "元素要害:", tooltip = "设置玩家身上的【元素要害】诅咒等级.\n中阶地图词缀的等级是 10.\n高阶地图词缀的等级是 15.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "ElementalWeakness", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithEnfeeble", type = "count", label = "衰弱:", tooltip = "设置玩家身上的【衰弱】诅咒等级.\n中阶地图词缀的等级是 10.\n高阶地图词缀的等级是 15.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Enfeeble", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithFlammability", type = "count", label = "易燃:", tooltip = "设置玩家身上的【易燃】诅咒等级..", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Flammability", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithFrostbite", type = "count", label = "冻伤:", tooltip = "设置玩家身上的【冻伤】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Frostbite", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithPoachersMark", type = "count", label = "盗猎者印记:", tooltip = "设置玩家身上的【盗猎者印记】诅咒等级", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "PoachersMark", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithProjectileWeakness", type = "count", label = "投射物要害:", tooltip = "设置玩家身上的【投射物要害】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "ProjectileWeakness", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithPunishment", type = "count", label = "惩戒:", tooltip = "设置玩家身上的【惩戒】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Punishment", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithTemporalChains", type = "count", label = "时空锁链:", tooltip = "设置玩家身上的【时空锁链】诅咒等级.\n中阶地图词缀的等级是 10.\n高阶地图词缀的等级是 15.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "TemporalChains", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithVulnerability", type = "count", label = "脆弱:", tooltip = "设置玩家身上的【脆弱】诅咒等级.\n中阶地图词缀的等级是 10.\n高阶地图词缀的等级是 15..", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "Vulnerability", level = val, applyToPlayer = true })
	end },
	{ var = "playerCursedWithWarlordsMark", type = "count", label = "督军印记:", tooltip = "设置玩家身上的【督军印记】诅咒等级.", apply = function(val, modList, enemyModList)
		modList:NewMod("ExtraCurse", "LIST", { skillId = "WarlordsMark", level = val, applyToPlayer = true })
	end },

	-- Section: Combat options
	{ section = "战斗状态配置", col = 1 },
	{ var = "usePowerCharges", type = "check", label = "你是否有暴击球?", apply = function(val, modList, enemyModList)
		modList:NewMod("UsePowerCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overridePowerCharges", type = "count", label = "暴击球数量(如果没达到最大值):", ifOption = "usePowerCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("PowerCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "useFrenzyCharges", type = "check", label = "你是否有狂怒球?", apply = function(val, modList, enemyModList)
		modList:NewMod("UseFrenzyCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideFrenzyCharges", type = "count", label = "狂怒球数量(如果没达到最大值):", ifOption = "useFrenzyCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("FrenzyCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "useEnduranceCharges", type = "check", label = "你是否有耐力球?", apply = function(val, modList, enemyModList)
		modList:NewMod("UseEnduranceCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideEnduranceCharges", type = "count", label = "耐力球数量(如果没达到最大值):", ifOption = "useEnduranceCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("EnduranceCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "useSiphoningCharges", type = "check", label = "你是否有轮回球?", ifMult = "SiphoningCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("UseSiphoningCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideSiphoningCharges", type = "count", label = "轮回球数量(如果没达到最大值):", ifOption = "useSiphoningCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("SiphoningCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "useChallengerCharges", type = "check", label = "你是否有挑战球?", ifMult = "ChallengerCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("UseChallengerCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideChallengerCharges", type = "count", label = "挑战球数量 (如果没达到最大值):", ifOption = "useChallengerCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("ChallengerCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "useBlitzCharges", type = "check", label = "你是否有疾电球?", ifMult = "BlitzCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("UseBlitzCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideBlitzCharges", type = "count", label = "疾电球数量 (如果没达到最大值):", ifOption = "useBlitzCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("BlitzCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierGaleForce", type = "count", label = "【飓风之力】层数:", ifFlag = "Condition:CanGainGaleForce", tooltip = "最多10 层飓风之力", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:GaleForce", "BASE", val, "Config", { type = "IgnoreCond" }, { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainGaleForce" })
	end },
	{ var = "overrideInspirationCharges", type = "count", label = "激励球数量 (如果没达到最大值):", ifMult = "InspirationCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("InspirationCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "useGhostShrouds", type = "check", label = "你是否有鬼影缠身?", ifMult = "GhostShroud", apply = function(val, modList, enemyModList)
		modList:NewMod("UseGhostShrouds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideGhostShrouds", type = "count", label = "鬼影缠身层数 (如果没有达到最大值):", ifOption = "useGhostShrouds", apply = function(val, modList, enemyModList)
		modList:NewMod("GhostShrouds", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "waitForMaxSeals", type = "check", label = "满层封印时释放?", ifFlag = "HasSeals", apply = function(val, modList, enemyModList)
		modList:NewMod("UseMaxUnleash", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideBloodCharges", type = "count", label = "赤炼球数量 (如果没达到最大值):", ifMult = "BloodCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("BloodCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "minionsUsePowerCharges", type = "check", label = "你的召唤生物有暴击球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UsePowerCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsUseFrenzyCharges", type = "check", label = "你的召唤生物有狂怒球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UseFrenzyCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsUseEnduranceCharges", type = "check", label = "你的召唤生物有耐力球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UseEnduranceCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsOverridePowerCharges", type = "count", label = "#召唤生物的暴击球数量:", ifFlag = "haveMinion", ifOption = "minionsUsePowerCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("PowerCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsOverrideFrenzyCharges", type = "count", label = "召唤生物的狂怒球数量:", ifFlag = "haveMinion", ifOption = "minionsUseFrenzyCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("FrenzyCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsOverrideEnduranceCharges", type = "count", label = "召唤生物的耐力球数量:", ifFlag = "haveMinion", ifOption = "minionsUseEnduranceCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("EnduranceCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "multiplierRampage", type = "count", label = "暴走层数:", tooltip = "暴走获得以下效果，最高1000层:\n\t每20层暴走移动速度提高 1%\n\t每20层暴走伤害提高 2%\n\t五秒内未击杀则失去暴走层数", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Rampage", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierSoulEater", type = "count", label = "噬魂者层数:", ifFlag = "Condition:CanHaveSoulEater", tooltip = "每层噬魂者获得以下效果\n\t攻击速度提高 5%\n\t施法速度提高\n\t角色体型增大 1%.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SoulEater", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionFocused", type = "check", label = "你处于专注期间?", ifCond = "Focused", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Focused", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffLifetap", type = "check", label = "是否处于赤炼效果期间?", ifCond = "Lifetap", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Lifetap", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("FlaskLifeRecovery", "INC", 20, "Lifetap")
	end },
	{ var = "buffOnslaught", type = "check", label = "你是否处于【猛攻】状态?", tooltip = "当你处于【猛攻】状态时的词缀生效,\n同时也会启用【猛攻】buff本身:提高 20% 移动、攻击和施法速度", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Onslaught", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "minionBuffOnslaught", type = "check", label = "你的召唤生物处于【猛攻】状态?", ifFlag = "haveMinion", tooltip = "除了会使得“召唤生物获得猛攻时……”的词缀,\n该选项也会为召唤物增加猛攻状态. (提高 20% 移动、攻击和施法速度)", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:Onslaught", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) })
	end },
	{ var = "buffUnholyMight", type = "check", label = "你是否有【不洁之力】?", tooltip = "这个会启用【不洁之力】buff (获得额外^xD02090混沌^7伤害，其数值等同于物理伤害的30%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UnholyMight", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "minionbuffUnholyMight", type = "check", label = "你的召唤生物是否有【不洁之力】?", ifFlag = "haveMinion", tooltip = "该选项会为你的召唤生物增加不洁之力buff. (获得额外^xD02090混沌^7伤害，其数值等同于物理伤害的30%)", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:UnholyMight", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) })
	end },
	{ var = "buffPhasing", type = "check", label = "你是否处于【迷踪】状态?", ifCond = "Phasing", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Phasing", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffFortification", type = "check", label = "你是否处于【护体】状态?", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Fortified", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "overrideFortification", type = "count", label = "护身层数 (如果没有达到最大值):", ifFlag = "Condition:Fortified", tooltip = "You have 1% less damage taken from hits per stack of fortification:\nHas a default cap of 20 stacks.", apply = function(val, modList, enemyModList)
		modList:NewMod("FortificationStacks", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffTailwind", type = "check", label = "你是否有【提速尾流】?", tooltip = "当你处于【提速尾流】状态时干啥干啥的词缀生效,\n同时也会启用【提速尾流】buff本身. (加速 8%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Tailwind", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffAdrenaline", type = "check", label = "你是否处于【肾上腺素】状态?", tooltip = "这个会启用【肾上腺素】buff:\n提高 100% 伤害\n提高 25% 攻击、施法和移动速度\n10%额外物理伤害减伤", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Adrenaline", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffAlchemistsGenius", type = "check", label = "你是否处于【炼金术天才】状态?", ifFlag = "Condition:CanHaveAlchemistGenius", tooltip = "这个配置可以启用【炼金术天才】增益:\n药剂充能提高 20%\n药剂效果提高 10%", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AlchemistsGenius", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanHaveAlchemistGenius" })
	end },
	{ var = "buffVaalArcLuckyHits", type = "check", label = "你是否有【瓦尔.电弧】的【特别幸运】增益效果？", ifFlag = "Condition:CanBeLucky",  tooltip = "电弧的击中伤害会 roll 2 次，取高的那次", apply = function(val, modList, enemyModList)

		modList:NewMod("LuckyHits", "FLAG", true, "Config", { type = "Condition", varList = { "Combat", "CanBeLucky" } }, { type = "SkillName", skillNameList = { "电弧", "瓦尔.电弧" } })

	end },
	{ var = "buffElusive", type = "check", label = "你是否处于【灵巧】状态?", ifFlag = "Condition:CanBeElusive", tooltip = "使得带有“灵巧时”的加成生效\n并会启用【灵巧】buff:\n\t15% 的机率避免击中伤害\n\t移动速度提高 30%\n灵巧效果会随着时间不断削弱.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Elusive", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanBeElusive" })
		modList:NewMod("Elusive", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanBeElusive" })
	end },
	{ var = "overrideBuffElusive", type = "count", label = "灵巧效果 (如果没有达到最大值):", ifOption = "buffElusive", tooltip = "如果你拥有稳定触发灵巧的方法, 最高效果的灵巧会生效. \n你可以修改此数值来查看buff的衰减效果", apply = function(val, modList, enemyModList)
		modList:NewMod("ElusiveEffect", "OVERRIDE", val, "Config", {type = "GlobalEffect", effectType = "Buff" })
	end },
	{ var = "buffDivinity", type = "check", label = "你处于【神圣】状态?", ifCond = "Divinity", tooltip = "获得【神性】Buff:\n火焰、冰霜、闪电总伤害额外提高 50%\n承受的火焰、冰霜、闪电总伤害额外降低 20% ", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Divinity", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierDefiance", type = "count", label = "抗争:", ifMult = "Defiance", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Defiance", "BASE", m_min(val, 10), "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierRage", type = "count", label = "怒火层数:", ifFlag = "Condition:CanGainRage", tooltip = "怒火的基础最大值为50, 获得以下效果:\n\t每点怒火使攻击伤害提高 1%\n\t每2点怒火使攻击速度提高 1%\n\t每5点怒火使移动速度提高 1%\n\t若你近期未被击中或获得怒火，每0.5秒失去1点怒火.",apply = function(val, modList, enemyModList)

		modList:NewMod("Multiplier:RageStack", "BASE", val, "Config", { type = "IgnoreCond" }, { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainRage" })
	end },
	{ var = "conditionLeeching", type = "check", label = "你正在偷取?", ifCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionLeechingLife", type = "check", label = "你正在偷取^xE05030生命^7?", ifCond = "LeechingLife", implyCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LeechingLife", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionLeechingEnergyShield", type = "check", label = "你正在偷取^x88FFFF能量护盾^7?", ifCond = "LeechingEnergyShield", implyCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LeechingEnergyShield", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionLeechingMana", type = "check", label = "你正在偷取^x7070FF魔力^7?", ifCond = "LeechingMana", implyCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LeechingMana", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsingFlask", type = "check", label = "你至少有1瓶药剂在生效?", ifCond = "UsingFlask", tooltip = "如果你勾选了药剂装备，那么这个自动生效,\n你也可以在这里勾选来启用.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsingFlask", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHaveTotem", type = "check", label = "你是否有图腾?", ifCond = "HaveTotem", tooltip = "如果你的主动技能是图腾，那么这个自动会生效,\n否则你需要手动勾选这个.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HaveTotem", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSummonedTotemRecently", type = "check", label = "近期有召唤图腾?", ifCond = "SummonedTotemRecently", tooltip = "如果选择的技能是图腾技能，那么这个自动会生效,\n否则你需要手动勾选这个.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SummonedTotemRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "TotemsSummoned", type = "count", label = "召唤的图腾数量 (如果不是最大值):", ifSkillList = { "法术图腾(辅)", "灼热连接", "弩炮图腾（辅）", "攻城炮台", "火力弩炮", "散射弩炮", "先祖卫士", "先祖战士长", "瓦尔.先祖战士长" }, tooltip = "这也意味着你有召唤图腾\n这个配置会解析'每存在 1 个图腾' 词缀.", apply = function(val, modList, enemyModList)
		modList:NewMod("TotemsSummoned", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:HaveTotem", "FLAG", val >= 1, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSummonedGolemInPast8Sec", type = "check", label = "过去 8 秒有召唤过魔像?", ifCond = "SummonedGolemInPast8Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SummonedGolemInPast8Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSummonedGolemInPast10Sec", type = "check", label = "过去 10 秒有召唤过魔像?", ifCond = "SummonedGolemInPast10Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SummonedGolemInPast10Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierNearbyAlly", type = "count", label = "附近友军数量：", ifMult = "NearbyAlly", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyAlly", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierNearbyCorpse", type = "count", label = "附近灵枢数量", ifMult = "NearbyCorpse", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyCorpse", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierSummonedMinion", type = "count", label = "召唤生物数量", ifMult = "SummonedMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SummonedMinion", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionOnConsecratedGround", type = "check", label = "你正在【奉献地面】上?", tooltip = "当你处于【奉献地面】状态时干啥干啥的词缀生效,\n同时也会启用【奉献地面】buff本身: 5%每秒生命回复.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) })
	end },
	{ var = "conditionOnFungalGround", type = "check", label = "你正在【真菌地表】上?", ifCond = "OnFungalGround", tooltip = "当你处于【真菌地表】状态时干啥干啥的词缀生效,\n同时也会启用【真菌地表】buff本身:\n在你真菌地表上的友军将获得 10% 的非混沌伤害的额外混沌伤害。\n在你真菌地表上的敌人造成的伤害降低 10%。", ifCond = "OnFungalGround", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnFungalGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionOnBurningGround", type = "check", label = "你正在【^xB97123燃烧^7地面】上?", ifCond = "OnBurningGround", implyCond = "Burning", tooltip = "这也意味着你被燃烧中.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnBurningGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Burning", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionOnChilledGround", type = "check", label = "你正在【^x3F6DB3冰缓^7地面】上?", ifCond = "OnChilledGround", implyCond = "Chilled", tooltip = "这也意味着你被冰缓.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnChilledGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionOnShockedGround", type = "check", label = "你正在【^xADAA47感电^7地面】上?", ifCond = "OnShockedGround", implyCond = "Shocked", tooltip = "这也意味着你被感电.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnShockedGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBlinded", type = "check", label = "你被致盲？", ifCond = "Blinded", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Blinded", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBurning", type = "check", label = "你被燃烧?", ifCond = "Burning", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Burning", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionIgnited", type = "check", label = "你被点燃?", ifCond = "Ignited", implyCond = "Burning", tooltip = "这也意味着你被燃烧.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Ignited", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionChilled", type = "check", label = "你被冰缓?", ifCond = "Chilled", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionChilledEffect", type = "count", label = "^x3F6DB3你身上的冰缓^7效果:", ifOption = "conditionChilled", apply = function(val, modList, enemyModList)
		modList:NewMod("ChillVal", "OVERRIDE", val, "Chill", { type = "Condition", var = "Chilled" })
	end },
	{ var = "conditionSelfChill", type = "check", label = "你身上的^x3F6DB3冰缓^7是自己施加的?", ifOption = "conditionChilled", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChilledSelf", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionFrozen", type = "check", label = "你被冰冻?", ifCond = "Frozen", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Frozen", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionShocked", type = "check", label = "你被感电?", ifCond = "Shocked", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("DamageTaken", "INC", 15, "Shock", { type = "Condition", var = "Shocked" })
	end },
	{ var = "conditionBleeding", type = "check", label = "你正在流血?", ifCond = "Bleeding", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Bleeding", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionPoisoned", type = "check", label = "你中毒了?", ifCond = "Poisoned", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Poisoned", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierPoisonOnSelf", type = "count", label = "你身上的中毒层数:", ifMult = "PoisonStack", implyCond = "Poisoned", tooltip = "这也意味着你中毒了.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:PoisonStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionAgainstDamageOverTime", type = "check", label = "你正在承受持续伤害?", ifCond = "AgainstDamageOverTime", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AgainstDamageOverTime", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "multiplierNearbyEnemies", type = "count", label = "附近敌人数量:", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:OnlyOneNearbyEnemy", "FLAG", val == 1, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "multiplierNearbyRareOrUniqueEnemies", type = "countAllowZero", label = "附近稀有或传奇敌人数量:", ifMult = "NearbyRareOrUniqueEnemies", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyRareOrUniqueEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Multiplier:NearbyEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:AtMostOneNearbyRareOrUniqueEnemy", "FLAG", val <= 1, "Config", { type = "Condition", var = "Combat" })
		enemyModList:NewMod("Condition:NearbyRareOrUniqueEnemy", "FLAG", val >= 1, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHitRecently", type = "check", label = "你近期有击中过敌人?", ifCond = "HitRecently", tooltip = "如果你的主要技能是自主施放，那么自动认为你近期有击中过\n若有必要，你可以强制修改它.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionCritRecently", type = "check", label = "你近期有造成暴击?", ifCond = "CritRecently", implyCond = "SkillCritRecently", tooltip = "这也意味着你的技能近期有造成暴击.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:SkillCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSkillCritRecently", type = "check", label = "你的技能近期有造成暴击?", ifCond = "SkillCritRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SkillCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionCritWithHeraldSkillRecently", type = "check", label = "你的捷技能近期有造成暴击?", ifCond = "CritWithHeraldSkillRecently", implyCond = "SkillCritRecently", tooltip = "这也意味着你的技能近期有造成暴击", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CritWithHeraldSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "LostNonVaalBuffRecently", type = "check", label = "近期有失去非瓦尔防卫技能?", ifCond = "LostNonVaalBuffRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LostNonVaalBuffRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionNonCritRecently", type = "check", label = "你近期有造成非暴击?", ifCond = "NonCritRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:NonCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionChannelling", type = "check", label = "你是否处于持续吟唱状态?", ifCond = "Channelling", tooltip = "当你主技能是吟唱技能时自动生效\n\t也可以强制该状态生效", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Channelling", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionHitRecentlyWithWeapon", type = "check", label = "你近期使用武器击中过敌人?", ifCond = "HitRecentlyWithWeapon", tooltip = "这也意味着你近期击中了敌人.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitRecentlyWithWeapon", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionKilledRecently", type = "check", label = "你近期有击杀?", ifCond = "KilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierKilledRecently", type = "count", label = "近期击杀的敌人数量", ifMult = "EnemyKilledRecently", implyCond = "KilledRecently", tooltip = "这也意味着你近期有击杀", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyKilledRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:KilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionKilledLast3Seconds", type = "check", label = "你近期 3 秒有击杀?", ifCond = "KilledLast3Seconds", implyCond = "KilledRecently", tooltip = "这也意味着你近期有击杀", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledLast3Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionKilledPoisonedLast2Seconds", type = "check", label = "过去 2 秒有击败中毒的敌人?", ifCond = "KilledPoisonedLast2Seconds", implyCond = "KilledRecently", tooltip = "这也意味着你近期有击杀", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledPoisonedLast2Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionTotemsNotSummonedInPastTwoSeconds", type = "check", label = "过去 2 秒内未召唤图腾?", ifCond = "NoSummonedTotemsInPastTwoSeconds", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:NoSummonedTotemsInPastTwoSeconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionTotemsKilledRecently", type = "check", label = "你的图腾近期有击杀?", ifCond = "TotemsKilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TotemsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedBrandRecently", type = "check", label = "你近期是否释放过烙印技能?", ifCond = "UsedBrandRecently",  apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedBrandRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierTotemsKilledRecently", type = "count", label = "近期图腾的击杀数", ifMult = "EnemyKilledByTotemsRecently", implyCond = "TotemsKilledRecently", tooltip = "这也意味着你的图腾近期有击杀.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyKilledByTotemsRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:TotemsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionMinionsKilledRecently", type = "check", label = "你的召唤生物近期有击杀?", ifCond = "MinionsKilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MinionsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionMinionsDiedRecently", type = "check", label = "你有召唤生物近期死亡?", ifCond = "MinionsDiedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MinionsDiedRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierMinionsKilledRecently", type = "count", label = "召唤生物近期击杀数", ifMult = "EnemyKilledByMinionsRecently", implyCond = "MinionsKilledRecently", tooltip = "这也意味着你的召唤生物近期有击杀.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyKilledByMinionsRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:MinionsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionKilledAffectedByDoT", type = "check", label = "近期有击杀被你的持续伤害影响的怪物?", ifCond = "KilledAffectedByDotRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledAffectedByDotRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierShockedEnemyKilledRecently", type = "count", label = "近期击杀感电怪物数量:", ifMult = "ShockedEnemyKilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ShockedEnemyKilledRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionFrozenEnemyRecently", type = "check", label = "近期有冰冻过怪物?", ifCond = "FrozenEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FrozenEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionChilledEnemyRecently", type = "check", label = "近期有冰缓过怪物?", ifCond = "ChilledEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChilledEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionShatteredEnemyRecently", type = "check", label = "近期有粉碎过怪物?", ifCond = "ShatteredEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ShatteredEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionIgnitedEnemyRecently", type = "check", label = "近期你有点燃过怪物?", ifCond = "IgnitedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:IgnitedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionShockedEnemyRecently", type = "check", label = "近期有感电过怪物?", ifCond = "ShockedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ShockedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionStunnedEnemyRecently", type = "check", label = "你近期有晕眩过敌人?", ifCond = "StunnedEnemyRecently", ifCond = "StunnedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:StunnedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierPoisonAppliedRecently", type = "count", label = "造成的中毒层数:", ifMult = "PoisonAppliedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:PoisonAppliedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierLifeSpentRecently", type = "count", label = "近期消耗 # 点^xE05030生命^7:", ifMult = "LifeSpentRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:LifeSpentRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierManaSpentRecently", type = "count", label = "近期消耗 # 点^x7070FF魔力 ^7:", ifMult = "ManaSpentRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ManaSpentRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBeenHitRecently", type = "check", label = "近期内你有被击中?", ifCond = "BeenHitRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierBeenHitRecently", type = "count", label = "近期内你被击中的次数:", ifMult = "BeenHitRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:BeenHitRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", 1 <= val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBeenHitByAttackRecently", type = "check", label = "你近期被攻击击中?", ifCond = "BeenHitByAttackRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BeenHitByAttackRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBeenCritRecently", type = "check", label = "你近期有承受过暴击?", ifCond = "BeenCritRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BeenCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionConsumed12SteelShardsRecently", type = "check", label = "消耗 12 枚钢刃碎片后?", ifCond = "Consumed12SteelShardsRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Consumed12SteelShardsRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionGainedPowerChargeRecently", type = "check", label = "近期有获得暴击球?", ifCond = "GainedPowerChargeRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:GainedPowerChargeRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionGainedFrenzyChargeRecently", type = "check", label = "近期有获得狂怒球?", ifCond = "GainedFrenzyChargeRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:GainedFrenzyChargeRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBeenSavageHitRecently", type = "check", label = "近期你有承受过【残暴打击】?", ifCond = "BeenSavageHitRecently", implyCond = "BeenHitRecently", tooltip = "这也意味着近期内你被击中过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BeenSavageHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHitByFireDamageRecently", type = "check", label = "近期内被火焰伤害击中?", ifCond = "HitByFireDamageRecently", implyCond = "BeenHitRecently", tooltip = "这也意味着近期内你被击中过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitByFireDamageRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHitByColdDamageRecently", type = "check", label = "近期内被冰霜伤害击中?", ifCond = "HitByColdDamageRecently", implyCond = "BeenHitRecently", tooltip = "这也意味着近期内你被击中过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitByColdDamageRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHitByLightningDamageRecently", type = "check", label = "近期内被闪电伤害击中?", ifCond = "HitByLightningDamageRecently", implyCond = "BeenHitRecently", tooltip = "这也意味着近期内你被击中过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitByLightningDamageRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHitBySpellDamageRecently", type = "check", label = "近期内被技能伤害击中?", ifCond = "HitBySpellDamageRecently", implyCond = "BeenHitRecently", tooltip = "This also implies that you have been Hit Recently.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitBySpellDamageRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionTakenFireDamageFromEnemyHitRecently", type = "check", label = "近期内承受来自敌人击中的^xB97123火焰^7伤害?", ifCond = "TakenFireDamageFromEnemyHitRecently", implyCond = "BeenHitRecently", tooltip = "This also implies that you have been Hit Recently.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TakenFireDamageFromEnemyHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBlockedRecently", type = "check", label = "近期内有过格挡?", ifCond = "BlockedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BlockedRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBlockedAttackRecently", type = "check", label = "近期内成功格挡过攻击?", ifCond = "BlockedAttackRecently", implyCond = "BlockedRecently", tooltip = "这也意味着近期内你格挡过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BlockedAttackRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BlockedRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionBlockedSpellRecently", type = "check", label = "近期内成功格挡过法术?", ifCond = "BlockedSpellRecently", implyCond = "BlockedRecently", tooltip = "这也意味着近期内你格挡过.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BlockedSpellRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BlockedRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionEnergyShieldRechargeRecently", type = "check", label = "近期内能量护盾开始回复?", ifCond = "EnergyShieldRechargeRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EnergyShieldRechargeRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionStoppedTakingDamageOverTimeRecently", type = "check", label = "近期内你停止受到持续伤害?", ifCond = "StoppedTakingDamageOverTimeRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:StoppedTakingDamageOverTimeRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionConvergence", type = "check", label = "汇聚状态?", ifFlag = "Condition:CanGainConvergence", apply = function(val, modList, enemyModList)

		modList:NewMod("Condition:Convergence", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainConvergence" })
	end },
	{ var = "buffPendulum", type = "list", label = "【毁灭光炮塔】升华天赋激活?", ifCond = "PendulumOfDestructionAreaOfEffect", list = {{val=0,label="不起作用"},{val="AREA",label="范围效果"},{val="DAMAGE",label="元素伤害"}}, apply = function(val, modList, enemyModList)
		if val == "AREA" then
			modList:NewMod("Condition:PendulumOfDestructionAreaOfEffect", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		elseif val == "DAMAGE" then
			modList:NewMod("Condition:PendulumOfDestructionElementalDamage", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
	end },
	{ var = "buffConflux", type = "list", label = "汇流:", ifCond = "ChillingConflux", list = {{val=0,label="不起作用"},{val="CHILLING",label="冰缓"},{val="SHOCKING",label="感电"},{val="IGNITING",label="点燃"},{val="ALL",label="冰缓，感电和点燃"}}, apply = function(val, modList, enemyModList)
		if val == "CHILLING" or val == "ALL" then
			modList:NewMod("Condition:ChillingConflux", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
		if val == "SHOCKING" or val == "ALL" then
			modList:NewMod("Condition:ShockingConflux", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
		if val == "IGNITING" or val == "ALL" then
			modList:NewMod("Condition:IgnitingConflux", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
	end },
	{ var = "highestDamageType", type = "list", ifFlag = "ChecksHighestDamage", label = "最高伤害类型:", tooltip = "会影响最高伤害类型相关加成的计算.", list = {{val="NONE",label="默认"},{val="Physical",label="物理"},{val="Lightning",label="闪电"},{val="Cold",label="冰霜"},{val="Fire",label="火焰"},{val="Chaos",label="混沌"}}, apply = function(val, modList, enemyModList)
		if val ~= "NONE" then
			modList:NewMod("Condition:"..val.."IsHighestDamageType", "FLAG", true, "Config")
			modList:NewMod("IsHighestDamageTypeOVERRIDE", "FLAG", true, "Config")
		end
	end },
	{ var = "buffHeartstopper", type = "list", label = "Heartstopper Mode:", ifCond = "HeartstopperHIT", list = {{val=0,label="None"},{val="AVERAGE",label="Average"},{val="HIT",label="Hit"},{val="DOT",label="Damage over Time"}}, apply = function(val, modList, enemyModList)
		if val == "HIT" then
			modList:NewMod("Condition:HeartstopperHIT", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		elseif val == "DOT" then
			modList:NewMod("Condition:HeartstopperDOT", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		elseif val == "AVERAGE" then
			modList:NewMod("Condition:HeartstopperAVERAGE", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
	end },
	{ var = "buffBastionOfHope", type = "check", label = "【希望壁垒】升华天赋激活?", ifCond = "BastionOfHopeActive", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BastionOfHopeActive", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffNgamahuFlamesAdvance", type = "check", label = "【火徒.努葛玛呼】升华天赋激活?", ifCond = "NgamahuFlamesAdvance", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:NgamahuFlamesAdvance", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "buffHerEmbrace", type = "check", label = "受到【她的拥抱】影响?", ifCond = "HerEmbrace", tooltip = "【鬼弑·查兰之剑】的选项.", apply = function(val, modList, enemyModList)
		modList:NewMod("HerEmbrace", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainHerEmbrace" })
	end },
	{ var = "conditionUsedSkillRecently", type = "check", label = "近期有使用过技能?", ifCond = "UsedSkillRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierSkillUsedRecently", type = "count", label = "近期使用过的技能数量:", ifMult = "SkillUsedRecently", implyCond = "UsedSkillRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SkillUsedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionAttackedRecently", type = "check", label = "你近期有攻击?", ifCond = "AttackedRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.\n如果你的主要技能是攻击技能，那么自动默认你近期有过攻击,\n如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AttackedRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionCastSpellRecently", type = "check", label = "你近期有施法?", ifCond = "CastSpellRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.\n如果你的主要技能是法术技能，那么自动默认你近期有过施法,\n如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastSpellRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionCastLast1Seconds", type = "check", label = "你近期 1 秒内有施法?", ifCond = "CastLast1Seconds", implyCond = "CastSpellRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastLast1Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierCastLast8Seconds", type = "count", label = "过去 8 秒施放多少次法术?", ifMult = "CastLast8Seconds", tooltip = "只算非立即触发的法术", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:CastLast8Seconds", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedFireSkillRecently", type = "check", label = "近期内你有使用过火焰技能?", ifCond = "UsedFireSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedFireSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedColdSkillRecently", type = "check", label = "近期内你有使用过冰霜技能?", ifCond = "UsedColdSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedColdSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedMinionSkillRecently", type = "check", label = "近期内你有使用过召唤生物技能?", ifCond = "UsedMinionSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能\n如果你的主要技能是召唤生物技能，那么自动默认你近期内有使用过召唤生物技能,\n如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedMinionSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedTravelSkillRecently", type = "check", label = "近期内使用过旅行技能?", ifCond = "UsedTravelSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedTravelSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedMovementSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedDashRecently", type = "check", label = "近期有使用冲刺技能?", ifCond = "CastDashRecently", implyCondList = { "UsedTravelSkillRecently", "UsedMovementSkillRecently", "UsedSkillRecently"}, tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastDashRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedTravelSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedMovementSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedMovementSkillRecently", type = "check", label = "近期内你有使用过移动技能?", ifCond = "UsedMovementSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能\n如果你的主要技能是移动技能，那么自动默认你近期内有使用过移动技能,\n如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedMovementSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedVaalSkillRecently", type = "check", label = "近期内你有使用过瓦尔技能?", ifCond = "UsedVaalSkillRecently", implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能\n如果你的主要技能是瓦尔技能，那么自动默认你近期内有使用过瓦尔技能,\n如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedVaalSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSoulGainPrevention", type = "check", label = "【阻灵术】生效期间?", ifCond = "SoulGainPrevention", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SoulGainPrevention", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedWarcryRecently", type = "check", label = "近期内你有使用过战吼?", implyCondList = {"UsedWarcryInPast8Seconds", "UsedSkillRecently"}, tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)

		modList:NewMod("Condition:UsedWarcryRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedWarcryInPast8Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionUsedWarcryInPast8Seconds", type = "check", label = "过去 8 秒你有使用过战吼?", ifCond = "UsedWarcryInPast8Seconds", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedWarcryInPast8Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierMineDetonatedRecently", type = "count", label = "近期引爆的地雷数量:", ifMult = "MineDetonatedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:MineDetonatedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierTrapTriggeredRecently", type = "count", label = "近期触发的陷阱数量:", ifMult = "TrapTriggeredRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:TrapTriggeredRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionThrownTrapOrMineRecently", type = "check", label = "近期投掷过地雷或陷阱?", ifCond = "TrapOrMineThrownRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TrapOrMineThrownRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionCursedEnemyRecently", type = "check", label = "近期诅咒过敌人?",  ifCond="CursedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CursedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionCastMarkRecently", type = "check", label = "近期释放过印记?", ifCond = "CastMarkRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CastMarkRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSpawnedCorpseRecently", type = "check", label = "近期召唤过灵柩", ifCond = "SpawnedCorpseRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SpawnedCorpseRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionConsumedCorpseRecently", type = "check", label = "近期消耗过灵柩?", ifCond = "ConsumedCorpseRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ConsumedCorpseRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionConsumedCorpseInPast2Sec", type = "check", label = "过去2秒内消耗过灵柩?", ifCond = "ConsumedCorpseInPast2Sec", implyCond = "ConsumedCorpseRecently",tooltip = "This also implies you have 'Consumed a corpse Recently'", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ConsumedCorpseInPast2Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierCorpseConsumedRecently", type = "count", label = "近期消耗的灵柩数量:", ifMult = "CorpseConsumedRecently", implyCond = "ConsumedCorpseRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:CorpseConsumedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:ConsumedCorpseRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierWarcryUsedRecently", type = "count", label = "近期使用过 # 次战吼:", ifMult = "WarcryUsedRecently", implyCondList = {"UsedWarcryRecently", "UsedWarcryInPast8Seconds", "UsedSkillRecently"}, tooltip = "This also implies you have 'Used a Warcry Recently', 'Used a Warcry in the past 8 seconds', and 'Used a Skill Recently'", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:WarcryUsedRecently", "BASE", m_min(val, 100), "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedWarcryRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedWarcryInPast8Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionTauntedEnemyRecently", type = "check", label = "近期嘲讽过怪物?", ifCond = "TauntedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TauntedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionLostEnduranceChargeInPast8Sec", type = "check", label = "过去 8 秒有失去过耐力球?", ifCond = "LostEnduranceChargeInPast8Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LostEnduranceChargeInPast8Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierEnduranceChargesLostRecently", type = "count", label = "近期失去耐力球的数量:", ifMult = "EnduranceChargesLostRecently", implyCond = "LostEnduranceChargeInPast8Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnduranceChargesLostRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:LostEnduranceChargeInPast8Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "conditionBlockedHitFromUniqueEnemyInPast10Sec", type = "check", label = "过去10秒内有成功格挡过传奇敌人的击中?", ifCond = "BlockedHitFromUniqueEnemyInPast10Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BlockedHitFromUniqueEnemyInPast10Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "BlockedPast10Sec", type = "count", label = "过去10秒内格挡的次数", ifCond = "BlockedHitFromUniqueEnemyInPast10Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:BlockedPast10Sec", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionImpaledRecently", type = "check", label = "近期有穿刺过敌人?", apply = function(val, modList, enemyModLIst)
		modList:NewMod("Condition:ImpaledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "multiplierImpalesOnEnemy", type = "countAllowZero", label = "敌人身上的穿刺数量:", ifFlag = "impale", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:ImpaleStacks", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierBleedsOnEnemy", type = "count", label = "敌人身上的流血数量:", ifFlag = "bleed", tooltip = "设置【玫红之舞】天赋的流血次数", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:BleedStacks", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		enemyModList:NewMod("Condition:Bleeding", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierFragileRegrowth", type = "count", label = "【脆弱重生】层数:", ifMult = "FragileRegrowthCount", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:FragileRegrowthCount", "BASE", m_min(val,10), "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionKilledUniqueEnemy", type = "check", label = "近期有击杀稀有或传奇敌人?", ifCond = "KilledUniqueEnemy", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledUniqueEnemy", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionHaveArborix", type = "check", label = "你是否有【霸体】?", ifFlag = "Condition:HaveArborix", tooltip = "This option is specific to Arborix.",apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HaveIronReflexes", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Keystone", "LIST", "Iron Reflexes", "Config")
	end },	
	{ var = "conditionHaveAugyre", type = "list", label = "【占星】当前效果:", ifFlag = "Condition:HaveAugyre", list = {{val="EleOverload",label="元素超载"},{val="ResTechnique",label="坚毅之心"}}, tooltip = "该选项专为装备【占星】设置.", apply = function(val, modList, enemyModList)
		if val == "EleOverload" then
			modList:NewMod("Condition:HaveElementalOverload", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
			modList:NewMod("Keystone", "LIST", "Elemental Overload", "Config")
		elseif val == "ResTechnique" then
			modList:NewMod("Condition:HaveResoluteTechnique", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
			modList:NewMod("Keystone", "LIST", "Resolute Technique", "Config")
		end
	end },	
	{ var = "conditionHaveVulconus", type = "check", label = "你是否有【火之化身】?", ifFlag = "Condition:HaveVulconus", tooltip = "该选项专为装备【火神锻台】设置.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HaveAvatarOfFire", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Keystone", "LIST", "Avatar of Fire", "Config")
	end },
	{ var = "conditionHaveManaStorm", type = "check", label = "你是否有【魔力风暴】增益效果?", ifFlag = "Condition:HaveManaStorm", tooltip = "该选项启用装备【魔力风暴】的伤害增益效果.\n\t(当你施放法术时，献祭所有魔力，获得等同于献祭魔力 25% 的附加最大闪电伤害，持续 4 秒)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SacrificeManaForLightning", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

	{ var = "buffFanaticism", type = "check", label = "你处于狂热状态?", ifFlag = "Condition:CanGainFanaticism", tooltip = " (【狂热】可使你的自施法的法术的:\n总施法速度额外提高 75%，\n魔力消耗降低 75%，\n范围效果扩大 75%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Fanaticism", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainFanaticism" })
	end },
	{ var = "multiplierPvpTvalueOverride", type = "count", label = "PvP Tvalue 设置 (ms):", ifFlag = "isPvP", tooltip = "Tvalue in milliseconds. This overrides the Tvalue of a given skill, for instance any with fixed Tvalues, or modified Tvalues", apply = function(val, modList, enemyModList)
		modList:NewMod("MultiplierPvpTvalueOverride", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "multiplierPvpDamage", type = "count", label = "自定义PVP伤害加成百分比:", ifFlag = "isPvP", tooltip = "This multiplies the damage of a given skill in pvp, for instance any with damage multiplier specific to pvp (from skill or support or item like sire of shards)", apply = function(val, modList, enemyModList)
		modList:NewMod("MultiplierPvpDamage", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
	-- Section: Effective DPS options
	{ section = "为了计算有效 DPS", col = 1 },
	{ var = "critChanceLucky", type = "check", label = "你的暴击率是幸运的?", apply = function(val, modList, enemyModList)
		modList:NewMod("CritChanceLucky", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "skillForkCount", type = "count", label = "分裂过的次数:", ifFlag = "forking", apply = function(val, modList, enemyModList)
		modList:NewMod("ForkedCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "skillChainCount", type = "count", label = "连锁过的次数:", ifFlag = "chaining", apply = function(val, modList, enemyModList)
		modList:NewMod("ChainCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "skillPierceCount", type = "count", label = "穿透敌人数量:", ifFlag = "piercing", apply = function(val, modList, enemyModList)
		modList:NewMod("PiercedCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "meleeDistance", type = "count", label = "近战攻击与敌人的距离:", ifFlag = "melee" },
	{ var = "projectileDistance", type = "count", label = "投射物飞行距离:" },
	{ var = "conditionAtCloseRange", type = "check", label = "怪物在近距离范围内?", ifCond = "AtCloseRange", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AtCloseRange", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyMoving", type = "check", label = "敌人在移动中?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Moving", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyFullLife", type = "check", label = "敌人满血状态?", ifEnemyCond = "FullLife", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:FullLife", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyLowLife", type = "check", label = "敌人低血状态?", ifEnemyCond = "LowLife", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:LowLife", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyCursed", type = "check", label = "敌人被诅咒?", ifEnemyCond = "Cursed", tooltip = "如果至少有一个诅咒技能激活，那么默认敌人被诅咒,\nn如果必要，可以在这里变更.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Cursed", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyBleeding", type = "check", label = "敌人在流血?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Bleeding", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },

	{ var = "multiplierRuptureStacks", type = "count", label = "# 残破层数", ifCond = "CanInflictRupture", tooltip = "【残破】持续 3秒\n最多叠加 3 层\n【残破】可使目标承受的总流血伤害额外提高 25%，身上的流血消退总速度额外提高 25%", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:RuptureStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("DamageTaken", "MORE", 25, "残破", nil, KeywordFlag.Bleed, { type = "Multiplier", var = "RuptureStack", limit = 3 }, { type = "ActorCondition", actor = "enemy", var = "CanInflictRupture" })
		enemyModList:NewMod("BleedExpireRate", "MORE", 25, "残破", nil, KeywordFlag.Bleed, { type = "Multiplier", var = "RuptureStack", limit = 3 }, { type = "ActorCondition", actor = "enemy", var = "CanInflictRupture" })
	end },
	{ var = "conditionEnemyPoisoned", type = "check", label = "敌人被中毒?", ifEnemyCond = "Poisoned", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Poisoned", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierPoisonOnEnemy", type = "count", label = "敌人身上的中毒层数:", implyCond = "Poisoned", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:PoisonStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierCurseExpiredOnEnemy", type = "count", label = "敌人的诅咒时间已过 #%:", ifEnemyMult = "CurseExpired", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:CurseExpired", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierCurseDurationExpiredOnEnemy", type = "count", label = "敌人的诅咒时间已持续:", ifEnemyMult = "CurseDurationExpired", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:CurseDurationExpired", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierWitheredStackCount", type = "count", label = "凋零层数:", ifFlag = "Condition:CanWither", tooltip = "每层凋零提高 6% 承受的^xD02090混沌^7伤害，最高15层.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:WitheredStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierCorrosionStackCount", type = "count", label = "腐蚀层数:", ifFlag = "Condition:CanCorrode", tooltip = "每层腐蚀使敌人 -5000 总护甲值和 -1000 总闪避值.\n腐蚀持续 4 秒且获得新的层数时刷新持续时间\n腐蚀无叠加次数上限", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:CorrosionStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Armour", "BASE", -5000, "Corrosion", { type = "Multiplier", var = "CorrosionStack" }, { type = "ActorCondition", actor = "enemy", var = "CanCorrode" })
		enemyModList:NewMod("Evasion", "BASE", -1000, "Corrosion", { type = "Multiplier", var = "CorrosionStack" }, { type = "ActorCondition", actor = "enemy", var = "CanCorrode" })
	end },
	{ var = "multiplierEnsnaredStackCount", type = "count", label = "圈套数量:", ifCond = "CanEnsnare", tooltip = "被捕获的敌人从攻击击中承受的投射物伤害提高, 每个敌人最多 3 个圈套.\n被诱捕的敌人始终视为在移动，并以更缓慢的速度试图突破圈套。\n一旦被捕猎的敌人离开范围效果，该圈套就被破坏。", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnsnareStackCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:Moving", "FLAG", true, "Config", { type = "MultiplierThreshold", actor = "enemy", var = "EnsnareStackCount", threshold = 1 })
	end },
	{ var = "conditionEnemyMaimed", type = "check", label = "敌人被瘫痪?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Maimed", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyHindered", type = "check", label = "敌人被阻碍?", ifEnemyCond = "Hindered", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Hindered", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyBlinded", type = "check", label = "敌人被致盲?", tooltip = "可以让“对致盲敌人什么什么”的词缀起作用\n同时减少敌人20%命中值和闪避值.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Blinded", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "overrideBuffBlinded", type = "count", label = "致盲效果(如果不是最大值的话):", ifOption = "conditionEnemyBlinded", tooltip = "如果你有其他稳定的致盲来源，会应用最高的一个", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("BlindEffect", "OVERRIDE", val, "Config", {type = "GlobalEffect", effectType = "Buff" })
	end },
	{ var = "conditionEnemyTaunted", type = "check", label = "敌人被嘲讽?", ifEnemyCond = "Taunted", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Taunted", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyDebilitated", type = "check", label = "敌人处于【疲惫】?", ifMod = "DebilitateChance", ifModType = "BASE", tooltip = "疲惫的敌人造成伤害额外降低 10%.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Debilitated", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyBurning", type = "check", label = "敌人被燃烧", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Burning", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyIgnited", type = "check", label = "敌人被点燃?", implyCond = "Burning", tooltip = "这也意味着敌人被燃烧.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Ignited", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyScorched", type = "check", ifFlag = "inflictScorch", label = "敌人被烧灼?", tooltip = "被烧灼的敌人降低元素抗性, 最大 -30%.\n勾选这个选项后可以在下面配置具体的烧灼效果", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Scorched", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ScorchedConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionScorchedEffect", type = "count", label = "【烧灼】效果:", ifOption = "conditionEnemyScorched", tooltip = "你可以对敌人造成烧灼的时候可以起作用.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ScorchVal", "BASE", val, "Config", { type = "Condition", var = "ScorchedConfig" })
		enemyModList:NewMod("DesiredScorchVal", "BASE", val, "Brittle", { type = "Condition", var = "ScorchedConfig", neg = true })
	end },
	{ var = "conditionEnemyOnScorchedGround", type = "check", label = "敌人在烧灼地面上?", tooltip = "这也意味着敌人被烧灼.", ifEnemyCond = "OnScorchedGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Scorched", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnScorchedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyChilled", type = "check", label = "敌人被冰缓?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ChilledConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyChilledEffect", type = "count", label = "冰缓效果:", ifOption = "conditionEnemyChilled", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:ChillEffect", "BASE", val, "Config", { type = "Condition", var = "ChilledConfig" })
		enemyModList:NewMod("ChillVal", "BASE", val, "Chill", { type = "Condition", var = "ChilledConfig" })
		enemyModList:NewMod("DesiredChillVal", "BASE", val, "Chill", { type = "Condition", var = "ChilledConfig", neg = true })
	end },
	{ var = "conditionEnemyChilledByYourHits", type = "check", ifEnemyCond = "ChilledByYourHits", label = "敌人是被你的击中所冰缓?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ChilledByYourHits", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyFrozen", type = "check", label = "敌人被冰冻?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Frozen", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyBrittle", type = "check", ifFlag = "inflictBrittle", label = "敌人被脆弱?", tooltip = "对脆弱的敌人的时提高自己的基础暴击率，最多 +6% \n勾选这个选项后可以在下面配置具体的脆弱效果", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Brittle", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:BrittleConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionBrittleEffect", type = "count", label = "【脆弱】效果:", ifOption = "conditionEnemyBrittle", tooltip = "你可以对敌人造成脆弱的时候可以起作用.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("BrittleVal", "BASE", val, "Config", { type = "Condition", var = "BrittleConfig" })
		enemyModList:NewMod("DesiredBrittleVal", "BASE", val, "Brittle", { type = "Condition", var = "BrittleConfig", neg = true })
	end },
	{ var = "conditionEnemyOnBrittleGround", type = "check", label = "敌人在脆弱地面上?", tooltip = "这也意味着敌人处于脆弱状态.", ifEnemyCond = "OnBrittleGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Brittle", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnBrittleGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyShocked", type = "check", label = "敌人被感电?", tooltip = "启用“对感电敌人……”的词缀,\n这也会让敌人感电承受额外伤害.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ShockedConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })

	end },
	{ var = "conditionShockEffect", type = "count", label = "感电效果:", tooltip = "如果你有稳定的感电来源,\n\t会在该配置项和其他来源中应用最强的效果.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:ShockEffect", "BASE", val, "Config", { type = "Condition", var = "ShockedConfig" })
		enemyModList:NewMod("ShockVal", "BASE", val, "Shock", { type = "Condition", var = "ShockedConfig" })
		enemyModList:NewMod("DesiredShockVal", "BASE", val, "Shock", { type = "Condition", var = "ShockedConfig", neg = true })
	end },
	{ var = "conditionEnemyOnShockedGround", type = "check", label = "敌人在感电地面上?", tooltip = "勾选后敌人也被感电.", ifEnemyCond = "OnShockedGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnShockedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemySapped", type = "check", ifFlag = "inflictSap", label = "敌人精疲力尽?", tooltip = "精疲力尽的敌人总伤害额外降低，最多降低 20%.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Sapped", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:SappedConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },

	{ var = "conditionSapEffect", type = "count", label = "精疲力尽效果:", ifOption = "conditionEnemySapped", tooltip = "如果你有稳定的精疲力尽来源,\n\t会在该配置项和其他来源中应用最强的效果.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("SapVal", "BASE", val, "Sap", { type = "Condition", var = "SappedConfig" })
		enemyModList:NewMod("DesiredSapVal", "BASE", val, "Sap", { type = "Condition", var = "SappedConfig", neg = true })
	end },
	{ var = "conditionEnemyOnSappedGround", type = "check", label = "敌人在精疲力尽地面上?", tooltip = "勾选后敌人也处于精疲力尽.", ifEnemyCond = "OnSappedGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Sapped", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnSappedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "multiplierFreezeShockIgniteOnEnemy", type = "count", label = "敌人身上的点燃感电冰缓数量:", ifMult = "FreezeShockIgniteOnEnemy", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:FreezeShockIgniteOnEnemy", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyFireExposure", type = "check", label = "敌人被火焰曝露影响?", ifFlag = "applyFireExposure", tooltip = "降低敌人 10% 火焰抗性.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("FireExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyFireExposure" })

	end },
	{ var = "conditionEnemyColdExposure", type = "check", label = "敌人被冰霜曝露影响?", ifFlag = "applyColdExposure", tooltip = "降低敌人 10% 冰霜抗性", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ColdExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyColdExposure" })

	end },
	{ var = "conditionEnemyLightningExposure", type = "check", label = "敌人被闪电曝露影响?", ifFlag = "applyLightningExposure", tooltip = "降低敌人 10% 闪电抗性", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("LightningExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyLightningExposure" })

	end },
	{ var = "conditionEnemyIntimidated", type = "check", label = "敌人被恐吓?", tooltip = "这个会附加词缀:\n提高 10% 敌人承受的攻击伤害", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Intimidated", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyCrushed", type = "check", label = "敌人被碾压?", tooltip = "被碾压的敌人降低 15% 额外物理减伤", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Crushed", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionNearLinkedTarget", type = "check", label = "敌人在你的链接目标附近?", ifEnemyCond = "NearLinkedTarget", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:NearLinkedTarget", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyUnnerved", type = "check",  label = "敌人被恐惧?", tooltip = "这个会附加词缀:\n提高 10% 敌人承受的法术伤害", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Unnerved", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyCoveredInAsh", type = "check", label = "敌人【灰烬缠身】?", tooltip = "这个会附加词缀:\n额外降低敌人 20% 移动速度\n提高 20% 敌人承受的火焰伤害", apply = function(val, modList, enemyModList)
		modList:NewMod("CoveredInAshEffect", "BASE", 20, "灰烬缠身")
	end },
	{ var = "conditionEnemyCoveredInFrost", type = "check", label = "敌人【冰霜附体】?", tooltip = "这个会附加词缀:\n\t提高 20% 敌人承受的冰霜伤害\n\t敌人暴击几率总降 50%", apply = function(val, modList, enemyModList)
		modList:NewMod("CoveredInFrostEffect", "BASE", 20, "冰霜附体")
	end },

	{ var = "conditionEnemyOnConsecratedGround", type = "check", label = "敌人在奉献地面上?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyOnProfaneGround", type = "check", label = "敌人在亵渎地面上?", ifFlag = "Condition:CreateProfaneGround", tooltip = "亵渎地面上的敌人 -10% 所有抗性，并对它们的击中 +1% 暴击率", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:OnProfaneGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("ElementalResist", "BASE", -10, "Config", { type = "Condition", var = "OnProfaneGround" })
		enemyModList:NewMod("ChaosResist", "BASE", -10, "Config", { type = "Condition", var = "OnProfaneGround" })
		modList:NewMod("CritChance", "BASE", 1, "Config", { type = "ActorCondition", actor = "enemy", var = "OnProfaneGround" })
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("CritChance", "BASE", 1, "Config", { type = "ActorCondition", actor = "enemy", var = "OnProfaneGround" }) })
	end },
	{ var = "multiplierEnemyAffectedByGraspingVines", type = "count", label = "敌人受到 # 个缓速藤蔓影响:", ifMult = "GraspingVinesAffectingEnemy", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:GraspingVinesAffectingEnemy", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyOnFungalGround", type = "check", label = "敌人在真菌地表上?", ifCond = "OnFungalGround", tooltip = "Enemies on your Fungal Ground deal 10% less Damage.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:OnFungalGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyInChillingArea", type = "check", label = "敌人在^x3F6DB3冰缓^7区域中?", ifEnemyCond = "InChillingArea", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:InChillingArea", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionEnemyInFrostGlobe", type = "check", label = "敌人在冰霜护盾区域中?", ifEnemyCond = "EnemyInFrostGlobe", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:EnemyInFrostGlobe", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "enemyConditionHitByFireDamage", type = "check", label = "敌人被^xB97123火焰^7伤害击中?", ifFlag = "ElementalEquilibrium", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByFireDamage", "FLAG", true, "Config")
	end },
	{ var = "enemyConditionHitByColdDamage", type = "check", label = "敌人被^x3F6DB3冰霜^7伤害击中?", ifFlag = "ElementalEquilibrium", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByColdDamage", "FLAG", true, "Config")
	end },
	{ var = "enemyConditionHitByLightningDamage", type = "check", label = "敌人被^xADAA47闪电^7伤害击中?", ifFlag = "ElementalEquilibrium", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByLightningDamage", "FLAG", true, "Config")
	end },
	{ var = "EEIgnoreHitDamage", type = "check", label = "忽略主技能的属性?", ifFlag = "ElementalEquilibrium", tooltip = "该选项避免元素之相被主要技能的击中属性影响." },
	-- Section: Enemy Stats
	{ section = "敌人状态设置", col = 3 },
	{ var = "enemyLevel", type = "count", label = "敌人等级:", tooltip = "该项重设了敌人的默认等级，用于估计你的击中和闪避几率.\n\n普通敌人和Boss的默认等级为83，同时不超过角色等级.\n\n异界Boss的默认等级为84,超级异界Boss的等级为85.\n这些首领的默认等级不受角色等级影响." },
	{ var = "conditionEnemyRareOrUnique", type = "check", label = "敌人是传奇或稀有怪物?", ifEnemyCond = "EnemyRareOrUnique", tooltip = "如果boss类型选项选择的是boss，那么这里会默认为传奇或稀有怪物.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "enemyIsBoss", type = "list", label = "敌人是Boss?", defaultIndex = 1, tooltip = [[
Boss伤害是将怪物的平均伤害分摊到四种类型上得到的数值
平均攻击伤害除以了 4.25 来表示四种伤害类型和部分混沌伤害
如果需要更准确的计算，请填入具体的伤害数值

普通Boss有以下加成:
	元素抗性提高 +40%
	混沌抗性提高 +25%
	怪物平均伤害的94%

守卫 / 异界首领有以下加成:
	元素抗性提高+50%
	混沌抗性提高% +30%
	护甲提高 +33%
	怪物平均伤害的 188%
	穿透 5% 抗性

超级异界首领有以下加成:
	元素抗性提高+50%
	混沌抗性提高% +30%
	护甲提高 +100%
	承受伤害额外降低 70%
	怪物平均伤害的 235%
	穿透 8% 抗性]], list = {{val="None",label="不是"},{val="Boss",label="普通Boss"},{val="Pinnacle",label="守卫/异界首领"},{val="Uber",label="超级异界首领"}}, apply = function(val, modList, enemyModList, build)
		--these defaults are here so that the placeholder gets reset correctly
		build.configTab.varControls['enemySpeed']:SetPlaceholder(700, true)
		build.configTab.varControls['enemyCritChance']:SetPlaceholder(5, true)
		build.configTab.varControls['enemyCritDamage']:SetPlaceholder(30, true)
		if val == "None" then
			local defaultResist = ""
			build.configTab.varControls['enemyLightningResist']:SetPlaceholder(defaultResist, true)
			build.configTab.varControls['enemyColdResist']:SetPlaceholder(defaultResist, true)
			build.configTab.varControls['enemyFireResist']:SetPlaceholder(defaultResist, true)
			build.configTab.varControls['enemyChaosResist']:SetPlaceholder(defaultResist, true)

			local defaultLevel = 83
			build.configTab.varControls['enemyLevel']:SetPlaceholder("", true)
			if build.configTab.enemyLevel then
				defaultLevel = build.configTab.enemyLevel
			end

			local defaultDamage = round(data.monsterDamageTable[defaultLevel] * 1.5)
			build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyLightningDamage']:SetPlaceholder("", true)
			build.configTab.varControls['enemyColdDamage']:SetPlaceholder("", true)
			build.configTab.varControls['enemyFireDamage']:SetPlaceholder("", true)
			build.configTab.varControls['enemyChaosDamage']:SetPlaceholder("", true)

			local defaultPen = ""
			build.configTab.varControls['enemyPhysicalOverwhelm']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyLightningPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyColdPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(defaultPen, true)
		elseif val == "Boss" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("AilmentThreshold", "MORE", 488, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")

			local defaultEleResist = 40
			build.configTab.varControls['enemyLightningResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyColdResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyFireResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyChaosResist']:SetPlaceholder(25, true)

			local defaultLevel = 83
			build.configTab.varControls['enemyLevel']:SetPlaceholder("", true)
			if build.configTab.enemyLevel then
				defaultLevel = build.configTab.enemyLevel
			end

			local defaultDamage = round(data.monsterDamageTable[defaultLevel] * 1.5  * data.misc.stdBossDPSMult)
			build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyLightningDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyColdDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyFireDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyChaosDamage']:SetPlaceholder(round(defaultDamage / 4), true)

			local defaultPen = ""
			build.configTab.varControls['enemyPhysicalOverwhelm']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyLightningPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyColdPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(defaultPen, true)
		elseif val == "Pinnacle" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("Condition:PinnacleBoss", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("Armour", "MORE", 33, "Boss")
			enemyModList:NewMod("AilmentThreshold", "MORE", 404, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")

			local defaultEleResist = 50
			build.configTab.varControls['enemyLightningResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyColdResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyFireResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyChaosResist']:SetPlaceholder(30, true)

			local defaultLevel = 84
			build.configTab.varControls['enemyLevel']:SetPlaceholder(defaultLevel, true)
			if build.configTab.enemyLevel then
				defaultLevel = m_max(build.configTab.enemyLevel, defaultLevel)
			end

			local defaultDamage = round(data.monsterDamageTable[defaultLevel] * 1.5  * data.misc.pinnacleBossDPSMult)
			build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyLightningDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyColdDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyFireDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyChaosDamage']:SetPlaceholder(round(defaultDamage / 4), true)

			build.configTab.varControls['enemyLightningPen']:SetPlaceholder(data.misc.pinnacleBossPen, true)
			build.configTab.varControls['enemyColdPen']:SetPlaceholder(data.misc.pinnacleBossPen, true)
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(data.misc.pinnacleBossPen, true)
		elseif val == "Uber" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("Condition:PinnacleBoss", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("Armour", "MORE", 100, "Boss")
			enemyModList:NewMod("DamageTaken", "MORE", -70, "Boss")
			enemyModList:NewMod("AilmentThreshold", "MORE", 404, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")

			local defaultEleResist = 50
			build.configTab.varControls['enemyLightningResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyColdResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyFireResist']:SetPlaceholder(defaultEleResist, true)
			build.configTab.varControls['enemyChaosResist']:SetPlaceholder(30, true)

			local defaultLevel = 85
			build.configTab.varControls['enemyLevel']:SetPlaceholder(defaultLevel, true)
			if build.configTab.enemyLevel then
				defaultLevel = m_max(build.configTab.enemyLevel, defaultLevel)
			end

			local defaultDamage = round(data.monsterDamageTable[defaultLevel] * 1.5  * data.misc.uberBossDPSMult)
			build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyLightningDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyColdDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyFireDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyChaosDamage']:SetPlaceholder(round(defaultDamage / 4), true)

			build.configTab.varControls['enemyLightningPen']:SetPlaceholder(data.misc.uberBossPen, true)
			build.configTab.varControls['enemyColdPen']:SetPlaceholder(data.misc.uberBossPen, true)
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(data.misc.uberBossPen, true)
		end
	end },
	{ var = "deliriousPercentage", type = "list", label = "亢奋等级:", list = {{val=0,label="无"},{val="20Percent",label="20% 亢奋"},{val="40Percent",label="40% 亢奋"},{val="60Percent",label="60% 亢奋"},{val="80Percent",label="80% 亢奋"},{val="100Percent",label="100% 亢奋"}}, tooltip = "亢奋效果使敌人承受更少伤害和造成更多伤害\n在100%亢奋时:\n敌人造成伤害提高 30%\n承受伤害额外降低 96%", apply = function(val, modList, enemyModList)
		if val == "20Percent" then
			enemyModList:NewMod("DamageTaken", "MORE", -19.2, "20% 亢奋")
			enemyModList:NewMod("Damage", "INC", 6, "20% 亢奋")
		end
		if val == "40Percent" then
			enemyModList:NewMod("DamageTaken", "MORE", -38.4, "40% 亢奋")
			enemyModList:NewMod("Damage", "INC", 12, "40% 亢奋")
		end
		if val == "60Percent" then
			enemyModList:NewMod("DamageTaken", "MORE", -57.6, "60% 亢奋")
			enemyModList:NewMod("Damage", "INC", 18, "60% 亢奋")
		end
		if val == "80Percent" then
			enemyModList:NewMod("DamageTaken", "MORE", -76.8, "80% 亢奋")
			enemyModList:NewMod("Damage", "INC", 24, "80% 亢奋")
		end
		if val == "100Percent" then
			enemyModList:NewMod("DamageTaken", "MORE", -96, "100% 亢奋")
			enemyModList:NewMod("Damage", "INC", 30, "100% 亢奋")
		end
	end },
	{ var = "enemyPhysicalReduction", type = "integer", label = "敌人物理伤害减伤:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("PhysicalDamageReduction", "BASE", val, "Config")
	end },
	{ var = "enemyLightningResist", type = "integer", label = "敌人闪电抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("LightningResist", "BASE", val, "Config")
	end },
	{ var = "enemyColdResist", type = "integer", label = "敌人冰霜抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ColdResist", "BASE", val, "Config")
	end },
	{ var = "enemyFireResist", type = "integer", label = "敌人火焰抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("FireResist", "BASE", val, "Config")
	end },
	{ var = "enemyChaosResist", type = "integer", label = "敌人混沌抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ChaosResist", "BASE", val, "Config")
	end },
	{ var = "presetBossSkills", type = "list", label = "首领技能", tooltip = [[
在未设置Boss伤害时使用特定Boss的技能进行计算

Boss的伤害采用roll值范围的2/3，不包括异界图鉴词缀，怪物等级正常（<=85）
若需要更精确的计算，请自行填入Boss伤害数值

部分技能的其他说明如下：

塑界者 冰球: 额外发射 2 个投射物，40% 冰霜抗性穿透
塑界者 砸地: 无法闪避、格挡、躲避，伤害总增 400%
贤主 记忆游戏: 三次单独攻击和附加高额持续伤害效果，这些额外效果暂未考虑，因此 “敌人最大攻击次数” >= 4 才表示可以在此技能下存活]], list = {{val="None",label="未设置"},{val="Uber Atziri Flameblast",label="超级阿兹里，炎爆"},{val="Shaper Ball",label="塑界者，冰球"},{val="Shaper Slam",label="塑界者，砸地"},{val="Maven Memory Game",label="贤主，记忆游戏"}}, apply = function(val, modList, enemyModList, build)
		--reset to empty
		if not (val == "None") then
			local defaultDamage = ""
			build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyLightningDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyColdDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyFireDamage']:SetPlaceholder(defaultDamage, true)
			build.configTab.varControls['enemyChaosDamage']:SetPlaceholder(defaultDamage, true)

			local defaultPen = ""
			build.configTab.varControls['enemyPhysicalOverwhelm']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyLightningPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyColdPen']:SetPlaceholder(defaultPen, true)
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(defaultPen, true)
		else
			build.configTab.varControls['enemyDamageType'].enabled = true
		end

		if val == "Uber Atziri Flameblast" then
			if build.configTab.enemyLevel then
				build.configTab.varControls['enemyFireDamage']:SetPlaceholder(round(data.monsterDamageTable[build.configTab.enemyLevel] * data.bossSkills["Uber Atziri Flameblast"].damageMult), true)
				build.configTab.varControls['enemyDamageType']:SelByValue("Spell", "val")
				build.configTab.varControls['enemyDamageType'].enabled = false
				build.configTab.input['enemyDamageType'] = "Spell"
			end
			build.configTab.varControls['enemyFirePen']:SetPlaceholder(10, true)

			build.configTab.varControls['enemySpeed']:SetPlaceholder(data.bossSkills["Uber Atziri Flameblast"].speed, true)
			build.configTab.varControls['enemyCritChance']:SetPlaceholder(0, true)
		elseif val == "Shaper Ball" then
			if build.configTab.enemyLevel then
				build.configTab.varControls['enemyColdDamage']:SetPlaceholder(round(data.monsterDamageTable[build.configTab.enemyLevel] * data.bossSkills["Shaper Ball"].damageMult), true)
			end

			build.configTab.varControls['enemyColdPen']:SetPlaceholder(25, true)
			build.configTab.varControls['enemySpeed']:SetPlaceholder(data.bossSkills["Shaper Ball"].speed, true)
			build.configTab.varControls['enemyDamageType'].enabled = false
			build.configTab.varControls['enemyDamageType']:SelByValue("SpellProjectile", "val")
			build.configTab.input['enemyDamageType'] = "SpellProjectile"
		elseif val == "Shaper Slam" then
			if build.configTab.enemyLevel then
				build.configTab.varControls['enemyPhysicalDamage']:SetPlaceholder(round(data.monsterDamageTable[build.configTab.enemyLevel] * data.bossSkills["Shaper Slam"].damageMult), true)
			end
			build.configTab.varControls['enemyDamageType'].enabled = false
			build.configTab.varControls['enemyDamageType']:SelByValue("Melee", "val")
			build.configTab.input['enemyDamageType'] = "Melee"

			build.configTab.varControls['enemySpeed']:SetPlaceholder(data.bossSkills["Shaper Slam"].speed, true)
		elseif val == "Maven Memory Game" then
			if build.configTab.enemyLevel then
				local defaultEleDamage = round(data.monsterDamageTable[build.configTab.enemyLevel] * data.bossSkills["Maven Memory Game"].damageMult)
				build.configTab.varControls['enemyLightningDamage']:SetPlaceholder(defaultEleDamage, true)
				build.configTab.varControls['enemyColdDamage']:SetPlaceholder(defaultEleDamage, true)
				build.configTab.varControls['enemyFireDamage']:SetPlaceholder(defaultEleDamage, true)
			end
			build.configTab.varControls['enemyDamageType'].enabled = false
			build.configTab.varControls['enemyDamageType']:SelByValue("Melee", "val")
			build.configTab.input['enemyDamageType'] = "Melee"
		end
	end },
	{ var = "enemyDamageType", type = "list", label = "敌人伤害类型:", tooltip = "在承受伤害时采用何种伤害模式进行计算:\n\t平均: 使用所有伤害类型的平均值\n\n如果选择了特定伤害类型, 计算时只会采用这一种伤害类型.", list = {{val="Average",label="平均"},{val="Melee",label="近战"},{val="Projectile",label="投射物"},{val="Spell",label="技能"},{val="SpellProjectile",label="技能投射物"}} },
	{ var = "enemySpeed", type = "integer", label = "敌人攻击/施法速度（毫秒）:", defaultPlaceholderState = 700 },
	{ var = "enemyMultiplierPvpDamage", type = "count", label = "PVP自定义伤害修正比例:", ifFlag = "isPvP", tooltip = "This multiplies the damage of a given skill in pvp, for instance any with damage multiplier specific to pvp (from skill or support or item like sire of shards)", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("MultiplierPvpDamage", "BASE", val, "Config")
	end },
	{ var = "enemyCritChance", type = "integer", label = "敌人暴击几率:", defaultPlaceholderState = 5 },
	{ var = "enemyCritDamage", type = "integer", label = "敌人暴击伤害加成:", defaultPlaceholderState = 30 },
	{ var = "enemyPhysicalDamage", type = "integer", label = "敌人技能物理伤害:", tooltip = "This overrides the default damage amount used to estimate your damage reduction from armour.\nThe default is 1.5 times the enemy's base damage, which is the same value\nused in-game to calculate the estimate shown on the character sheet."},
	{ var = "enemyPhysicalOverwhelm", type = "integer", label = "敌人技能物理伤害压制:"},
	{ var = "enemyLightningDamage", type = "integer", label = "敌人技能^xADAA47闪电伤害^7:"},
	{ var = "enemyLightningPen", type = "integer", label = "敌人技能^xADAA47闪电穿透^7:"},
	{ var = "enemyColdDamage", type = "integer", label = "敌人技能^x3F6DB3冰霜伤害^7:"},
	{ var = "enemyColdPen", type = "integer", label = "敌人技能^x3F6DB3冰霜穿透^7:"},
	{ var = "enemyFireDamage", type = "integer", label = "敌人技能^xB97123火焰伤害^7:"},
	{ var = "enemyFirePen", type = "integer", label = "敌人技能^xB97123火焰穿透^7:"},
	{ var = "enemyChaosDamage", type = "integer", label = "敌人技能^xD02090混沌伤害^7:"},
	
	-- Section: Custom mods
	{ section = "自定义加成", col = 1 },
	{ var = "customMods", type = "text", label = "", apply = function(val, modList, enemyModList)
		for line in val:gmatch("([^\n]*)\n?") do
			local mods, extra = modLib.parseMod(line)

			if mods then
				local source = "Custom"
				for i = 1, #mods do
					local mod = mods[i]

					if mod then
						mod = modLib.setSource(mod, source)
						modList:AddMod(mod)
					end
				end
			end
		end
	end },
}
