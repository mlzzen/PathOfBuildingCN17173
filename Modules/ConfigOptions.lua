-- Path of Building
--
-- Module: Config Options
-- List of options for the Configuration tab.
--

local m_min = math.min
local m_max = math.max

return {
	-- Section: General options
{ section = "常规", col = 1 },
{ var = "resistancePenalty", type = "list", label = "抗性 惩罚:",  list = {{val=0,label="无"},{val=-30,label="第五章 (-30%)"},{val=nil,label="第十章 (-60%)"}} },
{ var = "enemyLevel", type = "count", label = "敌人 等级:", tooltip = "敌人等级的设置会影响你命中率和闪避率的估算\n默认的等级和你角色等级相同，上限是84级\n这个估算和游戏中的面板中相同。" },
{ var = "enemyHit", type = "count", label = "敌人击中伤害:", tooltip = "这个会影响你的护甲所能带来的伤害减免的估算\n 默认是 1.5 倍敌人的基础伤害\n这个估算和游戏中的面板中相同。" },
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
{ var = "conditionFullLife", type = "check", label = "你处于满血状态?", tooltip = "如果你有【异灵之体】天赋，你会自动被认为是满血的\n如果有必要，你可以勾选这个来认为你是满血的.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FullLife", "FLAG", true, "Config")
	end },
{ var = "conditionLowLife", type = "check", label = "你处于低血状态?", ifCond = "LowLife", tooltip = "当你至少有 50% 生命保留的时候会自动认为是低血状态,\n如果有必要，你可以勾选这个来认为你是低血的.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LowLife", "FLAG", true, "Config")
	end },
{ var = "conditionFullEnergyShield", type = "check", label = "你处于满能量护盾状态?", ifCond = "FullEnergyShield", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FullEnergyShield", "FLAG", true, "Config")
	end },
{ var = "conditionHaveEnergyShield", type = "check", label = "你经常保持有能量护盾?", ifCond = "HaveEnergyShield", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HaveEnergyShield", "FLAG", true, "Config")
	end },
{ var = "conditionMinionsFullLife", type = "check", label = "你的召唤生物处于满血状态?",  apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:FullLife", "FLAG", true, "Config") }, "Config")
	end },
{ var = "minionsConditionCreatedRecently", type = "check", label = "你的召唤物的近期内召唤的？", ifCond = "MinionsCreatedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MinionsCreatedRecently", "FLAG", true, "Config")
	end },
{ var = "igniteMode", type = "list", label = "异常计算模式:", tooltip = "目前以基础点伤来计算异常效果:\n平均伤害：异常是基于平均伤害计算，区分暴击和非暴击.\n暴击伤害：异常基于暴击计算.", list = {{val="AVERAGE",label="平均伤害"},{val="CRIT",label="暴击伤害"}} },
{ var = "armourCalculationMode", type = "list", label = "护甲计算模式:", 
tooltip = "配置护甲的计算方式\n\t最小：不计算双倍护甲\n\t平均：根据双倍护甲的几率进行计算预期减伤\n\t最大：始终使用100% 双倍护甲计算，如果有 100% 几率双倍护甲，那么此配置无效\n\t", 
list = {{val="MIN",label="最小"},{val="AVERAGE",label="平均"},{val="MAX",label="最大"}} },

{ var = "warcryMode", type = "list", label = "战吼计算模式:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", 
"激励战吼", "震地战吼" },
 tooltip = "控制战吼的增助攻击的计算模式：\n平均：根据施法/攻击/战吼冷却速度来计算\n最大击中：所有战吼按照最大击中计算",
 list = {{val="AVERAGE",label="平均"},{val="MAX",label="最大击中"}}, apply = function(val, modList, enemyModList)
		if val == "MAX" then
			modList:NewMod("Condition:WarcryMaxHit", "FLAG", true, "Config")
		end
	end },
	{ var = "EVBypass", type = "check", label = "禁用【皇帝的警戒】的无法规避能量护盾", ifCond = "EVBypass", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EVBypass", "FLAG", true, "Config")
	end },

	-- Section: Skill-specific options
{ section = "技能选项", col = 2 },

{ label = "【高等施法回响】:", ifSkill =  "高等施法回响"  },
	{ var = "spellEchoCount", type = "list", label = "回响次数:", ifSkill =  "高等施法回响" , list = {{val="0",label="无回响"},{val="1",label="回响1次"},{val="2",label="回响2次"}}, apply = function(val, modList, enemyModList)
		 
			
			modList:NewMod("Multiplier:spellEchoCount", "BASE", m_min(tonumber(val), 2), "Config")
			modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Multiplier:spellEchoCount", "BASE", m_min(tonumber(val), 2), "Config") }, "Config")
		 
	end },
{ label = "【多重打击】:", ifSkill =  "多重打击(辅)"  },
	{ var = "multistrikeIndex", type = "list", label = "多重次数:", ifSkill =  "多重打击(辅)" , list = {{val="0",label="无重复"},{val="1",label="重复1次"},{val="2",label="重复2次"}}, apply = function(val, modList, enemyModList)
		 
		   if val =="1" then 
				modList:NewMod("Condition:MultistrikeFirstRepeat", "FLAG", true, "Config")
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:MultistrikeFirstRepeat", "FLAG", true, "Config") }, "Config")
		   elseif val=="2" then 
				modList:NewMod("Condition:MultistrikeSecondRepeat", "FLAG", true, "Config")
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:MultistrikeSecondRepeat", "FLAG", true, "Config") }, "Config")
		   end 		   
			 
		 
	end },
{ label = "【多重打击（强辅）】:", ifSkill =  "多重打击（强辅）"  },
	{ var = "multistrikeIndex", type = "list", label = "多重次数:", ifSkill =  "多重打击（强辅）" , 
	list = {{val="0",label="无重复"},
	{val="1",label="重复1次"},{val="2",label="重复2次"}
	,{val="3",label="重复3次"}
	}, apply = function(val, modList, enemyModList)
		 
		   if val =="1" then 
				modList:NewMod("Condition:MultistrikeFirstRepeat", "FLAG", true, "Config")
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:MultistrikeFirstRepeat", "FLAG", true, "Config") }, "Config")
		   elseif val=="2" then 
				modList:NewMod("Condition:MultistrikeSecondRepeat", "FLAG", true, "Config")
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:MultistrikeSecondRepeat", "FLAG", true, "Config") }, "Config")
		   elseif val=="3" then 
				modList:NewMod("Condition:MultistrikeThirdRepeat", "FLAG", true, "Config")
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:MultistrikeThirdRepeat", "FLAG", true, "Config") }, "Config")
		   end 		   
			 
		 
	end },
	
{ label = "【鸟之势】:", ifSkill = "鸟之势" },
{ var = "conditionAviansMightActive", type = "check", label = "有【鸟之力量】buff?", ifSkill = "鸟之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AviansMightActive", "FLAG", true, "Config")
	end },
{ var = "conditionAviansFlightActive", type = "check", label = "有【鸟之斗魄】buff?", ifSkill = "鸟之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AviansFlightActive", "FLAG", true, "Config")
	end },
{ label = "【猫之势】:", ifSkill = "猫之势" },
{ var = "conditionCatsStealthActive", type = "check", label = "有【猫之隐匿】buff?", ifSkill = "猫之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CatsStealthActive", "FLAG", true, "Config")
	end },
{ var = "conditionCatsAgilityActive", type = "check", label = "有【猫之敏捷】buff?", ifSkill = "猫之势", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CatsAgilityActive", "FLAG", true, "Config")
	end },
{ label = "【蟹之势】:", ifSkill = "蟹之势" },
{ var = "conditionCrabBarriers", type = "count", label = "# 【深海屏障】数量(如果不是最大层的话):", ifSkill = "蟹之势", apply = function(val, modList, enemyModList)
		modList:NewMod("CrabBarriers", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ label = "【蛛之势】:", ifSkill = "蛛之势" },
{ var = "aspectOfTheSpiderWebStacks", type = "count", label = "# 蜘蛛网层数:", ifSkill = "蛛之势", apply = function(val, modList, enemyModList)
modList:NewMod("ExtraSkillMod", "LIST", { mod = modLib.createMod("Multiplier:SpiderWebApplyStack", "BASE", val) }, "Config", { type = "SkillName", skillName = "蛛之势" })
enemyModList:NewMod("Multiplier:Spider's WebStack", "BASE", val, "Config")
 

	end },

{ label = "旗帜技能:", ifSkillList = { "恐怖之旗", "战旗" } },
{ var = "conditionBannerPlanted", type = "check", label = "旗帜放置?", ifSkillList = { "恐怖之旗", "战旗"}, apply = function(val, modList, enemyModList)

modList:NewMod("Condition:BannerPlanted", "FLAG", true, "Config")
	end },
{ var = "bannerStages", type = "count", label = "旗帜阶层:", ifSkillList = { "恐怖之旗", "战旗" }, apply = function(val, modList, enemyModList)
modList:NewMod("Multiplier:BannerStage", "BASE", m_min(val, 50), "Config", { type = "SkillName", skillNameList = { "恐怖之旗", "战旗" } })
	end },

	-- 3.7 技能
{ label = "【剑刃风暴】:", ifSkill = "剑刃风暴" },
	{ var = "conditionBladestormInBloodstorm", type = "check", label = "你处于血姿态?", ifSkill = "剑刃风暴", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BladestormInBloodstorm", "FLAG", true, "Config", { type = "SkillName", skillName = "剑刃风暴" })
	end },
{ var = "conditionBladestormInSandstorm", type = "check", label = "你处于沙姿态?", ifSkill = "剑刃风暴", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BladestormInSandstorm", "FLAG", true, "Config", { type = "SkillName", skillName = "剑刃风暴" })
	end },
{ label = "姿态技能:", ifSkillList = { "血与沙", "血肉与岩石", "破空斩", "剑刃风暴", "凿击" } },
	{ var = "conditionSandStance", type = "list", label = "姿态:", ifSkillList = { "血与沙", "血肉与岩石", "破空斩", "剑刃风暴", "凿击" }, 
	list = {{val="BLOOD",label="血姿态"},{val="SAND",label="沙姿态"}}, apply = function(val, modList, enemyModList)
		if val == "SAND" then
			modList:NewMod("Condition:SandStance", "FLAG", true, "Config")
		elseif  val == "BLOOD" then
			modList:NewMod("Condition:BloodStance", "FLAG", true, "Config")
		end	
	end },
	
{ label = "【彻骨】:", ifSkill = "彻骨（辅）" },
	{ var = "bonechillEffect", type = "count", label = "冰缓效果:",
	tooltip = "如果你有稳定的冰缓来源，那么冰缓效果会自动计算\n你也可以在这里填写数值来覆盖.", 
	ifSkill = "彻骨（辅）", apply = function(val, modList, enemyModList)
		modList:NewMod("BonechillEffect", "OVERRIDE", m_min(val, 30), "Config")
		modList:NewMod("DesiredBonechillEffect", "BASE", m_min(val, 30), "Config")
	end },

{ label = "烙印技能:", ifSkillList = { "末日烙印", "风暴烙印","奥法烙印" ,"忏悔烙印","冬潮烙印"} }, -- I barely resisted the temptation to label this "Generic Brand:"
{ var = "BrandsAttachedToEnemy", type = "count", label = "附着到敌人身上的烙印：", ifSkillList = {  "末日烙印", "风暴烙印","奥法烙印" ,"忏悔烙印","冬潮烙印"}, apply = function(val, modList, enemyModList)
	
		modList:NewMod("Multiplier:ConfigBrandsAttachedToEnemy", "BASE", val, "Config")
	end },

{ label = "腐化魔像:", ifSkill = "召唤腐化魔像" },
	{ var = "carrionGolemNearbyMinion", type = "count", label = "#周围非魔像召唤生物数量:", ifSkill = "召唤腐化魔像", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyNonGolemMinion", "BASE", val, "Config")
	end }, 	
{ label = "旋风斩:", ifSkill = "旋风斩" },
	{ var = "channellingCycloneCheck", type = "check", label = "你正在吟唱旋风斩?", ifSkill = "旋风斩", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChannellingCyclone", "FLAG", true, "Config")
	end },
{ label = "【暗夜血契】:", ifSkill = "暗夜血契" },
{ var = "darkPactSkeletonLife", type = "count", label = "魔侍 生命:", ifSkill = "暗夜血契", tooltip = "设置使用【暗夜血契】时，魔侍的最大生命.", apply = function(val, modList, enemyModList)
modList:NewMod("SkillData", "LIST", { key = "skeletonLife", value = val }, "Config", { type = "SkillName", skillName = "暗夜血契" })
	end },

{ label = "【掠食（辅）】:", ifSkill = "掠食（辅）" },
{ var = "conditionEnemyHasDeathmark", type = "check", label = "敌人被标记?", ifSkill = "掠食（辅）", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:EnemyHasDeathmark", "FLAG", true, "Config")
	end },
	{ label = "【狂噬（辅）】:", ifSkill = "狂噬（辅）" }, 
	
{ var = "conditionFeedingFrenzyActive", type = "check", label = "启用狂噬增益效果?", ifSkill = "狂噬（辅）", tooltip = "狂噬增益效果:所有的召唤生物获得\n召唤生物移动速度提高 15%\n召唤生物攻击和施法速度提高 15%", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FeedingFrenzyActive", "FLAG", true, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Damage", "MORE", 10, "狂噬（辅）") }, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("MovementSpeed", "INC", 15, "狂噬（辅）") }, "Config")
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Speed", "INC", 15, "狂噬（辅）") }, "Config")
	end },
{ label = "烈焰之墙:", ifSkill = "烈焰之墙" },
	{ var = "flameWallAddedDamage", type = "check", label = "投射物穿过了烈焰之墙?", ifSkill = "烈焰之墙", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:FlameWallAddedDamage", "FLAG", true, "Config")
	end },
{ label = "寒冰弹:", ifSkill = "寒冰弹" },
	{ var = "frostboltExposure", type = "check", label = "造成冰霜曝露?", ifSkill = "寒冰弹", apply = function(val, modList, enemyModList)
		modList:NewMod("ColdExposureChance", "BASE", 20, "Config")
	end },
{ label = "冰霜护盾:", ifSkill = "冰霜护盾" },
	{ var = "frostShieldStages", type = "count", label = "层数:", ifSkill = "冰霜护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:冰霜护盾Stage", "BASE", val, "Config")
	end },
{ label = "【召唤高等时空先驱者】:", ifSkill =  "召唤高等时空先驱者" },
	{ var = "greaterHarbingerOfTimeSlipstream", type = "check", label = "开启时空先驱者光环?:", ifSkill =  "召唤高等时空先驱者", 
	tooltip = "【召唤高等时空先驱者】增益效果：\n动作速度提高 20%\n增益影响玩家和友军\n增益效果持续 8 秒，并且有 10 秒冷却时间", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:GreaterHarbingerOfTime", "FLAG", true, "Config")
	end },
	{ label = "【召唤时空先驱者】:", ifSkill =  "召唤时空先驱者" },
	{ var = "harbingerOfTimeSlipstream", type = "check", label = "开启时空先驱者光环?:", ifSkill =  "召唤时空先驱者", 
	tooltip = "【召唤时空先驱者】增益效果:\n动作速度提高 20%\n增益影响小范围内的友军，玩家和敌人\n增益效果持续 8 秒，并且有 20 秒冷却时间", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HarbingerOfTime", "FLAG", true, "Config")
	end },
{ label = "魔蛊:", ifSkillFlag = "hex" },
	{ var = "multiplierHexDoom", type = "count", label = "末日之力层数:", ifSkillFlag = "hex", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:HexDoomStack", "BASE", val, "Config")
	end },
{ label = "【苦痛之捷】:", ifSkill = "苦痛之捷" },
{ var = "heraldOfAgonyVirulenceStack", type = "count", label = "# 【毒力】层数:", ifSkill = "苦痛之捷", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:VirulenceStack", "BASE", val, "Config")
	end },
{ label = "【冰霜新星】:", ifSkill = "冰霜新星" },
{ var = "conditionCastOnFrostbolt", type = "check", label = "是否由【寒冰弹】触发?", ifSkill = "冰霜新星", apply = function(val, modList, enemyModList)
modList:NewMod("Condition:CastOnFrostbolt", "FLAG", true, "Config", { type = "SkillName", skillName = "冰霜新星" })
	end },
{ label = "【闪电支配】", ifSkill = "闪电支配(辅)" },
{ var = "conditionInnervationActive", type = "check", label = "处于【闪电支配】状态?", ifSkill = "闪电支配(辅)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:InnervationActive", "FLAG", true, "Config")
	end },
	
{ label = "【灌注】:", ifSkill = "灌能吟唱(辅)" },
	{ var = "conditionInfusionActive", type = "check", label = "激活【灌注】?", ifSkill = "灌能吟唱(辅)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:InfusionActive", "FLAG", true, "Config")
	end },
{ label = "【法术凝聚】:", ifSkillList = {"法术凝聚（辅）","电殛长枪","会心一击（辅）"} },
	{ var = "intensifyIntensity", type = "count", label = "# 层【法术凝聚】:", ifSkillList = {"法术凝聚（辅）","电殛长枪","会心一击（辅）"} , apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Intensity", "BASE",val, "Config")
	end },
{ label = "【肉盾（辅）】:", ifSkill = "肉盾（辅）" },
	{ var = "conditionMeatShieldEnemyNearYou", type = "check", label = "敌人在你附近?", ifSkill = "肉盾（辅）", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MeatShieldEnemyNearYou", "FLAG", true, "Config")
	end },
{ label = "【凿击】:", ifSkill = "凿击"},
	{ var = "perforateSpikeOverlap", type = "count", label = "# 凿击的尖刺:", tooltip = "影响凿击在血姿势模式下的伤害\n最大数量取决于凿击技能.", 
	ifSkill = "凿击", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:PerforateSpikeOverlap", "BASE", val, "Config", { type = "SkillName", skillName = "凿击" })
	end },
{ label = "物理神盾:", ifSkill = "物理神盾" },
	{ var = "physicalAegisDepleted", type = "check", label = "物理神盾耗尽了?", ifSkill = "物理神盾", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:PhysicalAegisDepleted", "FLAG", true, "Config")
	end },
	{ label = "【尊严】:", ifSkill = "尊严" },
	{ var = "prideEffect", type = "list", label = "尊严光环效果:", ifSkill = "尊严", 
	list = {{val="MIN",label="初始效果"},{val="MAX",label="最大效果"}}, apply = function(val, modList, enemyModList)
		if val == "MAX" then
			modList:NewMod("Condition:PrideMaxEffect", "FLAG", true, "Config")
		end
	end },
{ label = "【召唤灵体】:", ifSkill = "召唤灵体" },

{ var = "animateWeaponLingeringBlade", type = "check", label = "幻化【徘徊之刃】?", ifSkill = "幻化武器", tooltip = "启用幻化【徘徊之刃】的伤害加成\n徘徊之刃的具体的武器基低尚不清楚，但是接近于匕首【玻璃利片】", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AnimatingLingeringBlades", "FLAG", true, "Config")
	end },
{ label = "威能法印:", ifSkill = "威能法印" },
	{ var = "sigilOfPowerStages", type = "count", label = "层数:", ifSkill = "威能法印", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:威能法印Stage", "BASE", val, "Config")
	end },
{ label = "【虹吸陷阱】:", ifSkill = "虹吸陷阱" },
{ var = "siphoningTrapAffectedEnemies", type = "count", label = "# 受到影响的敌人数量:", ifSkill = "虹吸陷阱", tooltip = "设置受到【虹吸陷阱】影响的敌人数量.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyAffectedBySiphoningTrap", "BASE", val, "Config")
		modList:NewMod("Condition:SiphoningTrapSiphoning", "FLAG", true, "Config")
	end },
{ var = "raiseSpectreEnableCurses", type = "check", label = "灵体自带诅咒、增益和光环:", ifSkill = "召唤灵体", tooltip = "激活你的灵体带的诅咒、增益和光环.", apply = function(val, modList, enemyModList)
modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Aura }, { type = "SkillName", skillName = "召唤灵体", summonSkill = true })
modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Buff }, { type = "SkillName", skillName = "召唤灵体", summonSkill = true })
modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Hex }, { type = "SkillName", skillName = "Raise Spectre", summonSkill = true })
modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillType", skillType = SkillType.Mark }, { type = "SkillName", skillName = "Raise Spectre", summonSkill = true })
		
		
	end },
{ label = "狙击:", ifSkill = "狙击" },
	{ var = "configSnipeStages", type = "count", label = "狙击层数:", ifSkill = "狙击", tooltip = "释放狙击之前吟唱的层数.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:狙击Stage", "BASE", m_min(val, 6), "Config")
	end },
{ label = "三位一体（辅）:", ifSkill = "三位一体（辅）" },
	{ var = "configResonanceCount", type = "count", label = "最低的共振效果数量:", ifSkill = "三位一体（辅）", tooltip = "设置最低的共振效果的数值.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ResonanceCount", "BASE", m_max(m_min(val, 50), 0), "Config")
	end },
{ label = "【召唤幽狼】:", ifSkill = "召唤幽狼" },
	{ var = "configSpectralWolfCount", type = "count", label = "幽狼数量:", 
	ifSkill = "召唤幽狼", tooltip = "设置幽狼的数量.\n最大是 10.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SpectralWolfCount", "BASE", m_min(val, 10), "Config")
	end },
{ var = "raiseSpectreBladeVortexBladeCount", type = "count", label = "飞刃风暴层数:", ifSkillList = {"DemonModularBladeVortexSpectre","GhostPirateBladeVortexSpectre"}, tooltip = "设置灵体使用的【飞刃风暴】层数.\n默认是 1; 最大是  5.", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "dpsMultiplier", value = val }, "Config", { type = "SkillId", skillId = "DemonModularBladeVortexSpectre" })
		modList:NewMod("SkillData", "LIST", { key = "dpsMultiplier", value = val }, "Config", { type = "SkillId", skillId = "GhostPirateBladeVortexSpectre" })
	end },
{ var = "raiseSpectreKaomFireBeamTotemStage", type = "count", label = "灼热射线图腾数量:", ifSkill = "KaomFireBeamTotemSpectre", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:灼热奔流图腾Stage", "BASE", val, "Config")
	end },
	
{ var = "changedStance", type = "check", label = "最近有切换姿态模式?", ifCond = "ChangedStanceRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ChangedStanceRecently", "FLAG", true, "Config")
	end },
{ label = "钢系技能:", ifSkillList = { "分裂钢刃", "破碎铁刃", "断金之刃" } },
	{ var = "shardsConsumed", type = "count", label = "消耗钢刃碎片:", ifSkillList = { "分裂钢刃", "破碎铁刃", "断金之刃" }, apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:SteelShardConsumed", "BASE", m_min(val, 12), "Config")
	end },
{ var = "steelWards", type = "count", label = "钢刃结界:", ifSkill = "破碎铁刃", tooltip = "消耗至少 2 个钢刃碎片时，获得一个钢刃结界，最多 6 个\n每个钢刃结界都使投射物攻击伤害的格挡率 +4%", apply = function(val, modList, enemyModList)
		modList:NewMod("ProjectileBlockChance", "BASE", m_min(val * 4, 24), "Config")
	end },

{ label = "【召唤圣物】:", ifSkill = "召唤圣物" },
{ var = "summonHolyRelicEnableHolyRelicBoon", type = "check", label = "启用圣物的加成光环:", ifSkill = "召唤圣物", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillId", skillId = "RelicTriggeredNova" })
	end },
	
{ label = "【召唤闪电魔像】:", ifSkill = "召唤闪电魔像" },
{ var = "summonLightningGolemEnableWrath", type = "check", label = "启用魔像【雷霆】光环:", ifSkill = "召唤闪电魔像", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillId", skillId = "LightningGolemWrath" })
	end },
{ label = "刽子手.杰克-【鲜血渴求】:", ifSkill = "鲜血渴求" },
	{ var = "nearbyBleedingEnemies", type = "count", label = "周围流血敌人数量:", ifSkill = "鲜血渴求", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyBleedingEnemies", "BASE", val, "Config" )
	end },
{ label = "【毒雨】:", ifSkill = "毒雨" },
	{ var = "toxicRainPodOverlap", type = "count", label = "孢囊数量:", tooltip = "最大是投射物数量.", ifSkill = "毒雨", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "podOverlapMultiplier", value = val }, "Config", { type = "SkillName", skillName = "毒雨" })
	end },
	{ label = "【灰烬之捷】:", ifSkill = "灰烬之捷" },
	{ var = "hoaOverkill", type = "count", label = "溢出的伤害:", tooltip = "溢出的伤害将会以持续伤害的形式扩散至附近的敌人", ifSkill = "灰烬之捷", 
	apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "hoaOverkill", value = val }, "Config", { type = "SkillName", skillName = "灰烬之捷" })
	end },
{ label = "【漩涡】 :", ifSkill = "漩涡 " },
{ var = "conditionCastOnFrostbolt", type = "check", label = "由【寒冰弹】触发?", ifSkill = "漩涡", apply = function(val, modList, enemyModList)
modList:NewMod("Condition:CastOnFrostbolt", "FLAG", true, "Config", { type = "SkillName", skillName = "漩涡" })
	end },
{ label = "【定罪波】:", ifSkill = "定罪波" },
	{ var = "waveOfConvictionExposureType", type = "list", label = "易伤负面效果类型:", ifSkill = "定罪波", list = {{val=0,label="无"},{val="Fire",label="火焰"},{val="Cold",label="冰霜"},{val="Lightning",label="闪电"}}, apply = function(val, modList, enemyModList)
		if val == "Fire" then
			modList:NewMod("Condition:WaveOfConvictionFireExposureActive", "FLAG", true, "Config")
		elseif val == "Cold" then
			modList:NewMod("Condition:WaveOfConvictionColdExposureActive", "FLAG", true, "Config")
		elseif val == "Lightning" then
			modList:NewMod("Condition:WaveOfConvictionLightningExposureActive", "FLAG", true, "Config")
		end
	end },
	
{ label = "【元素大军（辅）】:", ifSkill = "元素大军（辅）" },
	{ var = "ElementalArmyExposureTypeTest1", type = "list", label = "曝露效果类型:", ifSkill = "元素大军（辅）", list = {{val=0,label="无"},{val="Fire",label="火焰"},{val="Cold",label="冰霜"},{val="Lightning",label="闪电"}}, apply = function(val, modList, enemyModList)
		if val == "Fire" then
			modList:NewMod("FireExposureChance", "BASE", 100, "Config")
		elseif val == "Cold" then
			modList:NewMod("ColdExposureChance", "BASE", 100, "Config")
		elseif val == "Lightning" then
			modList:NewMod("LightningExposureChance", "BASE", 100, "Config")
		end
	end },
	

	
	{ label = "【死亡凋零】:", ifCond = "CanWither"},
{ var = "witheringTouchWitheredStackCount", type = "count", label = "# 【死亡凋零】层数:", 
ifCond = "CanWither", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:WitheredStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
	
{ label = "欺诈师升华天赋:",    ifNode = 28884},
{ var = "ghostShroudCount", type = "count", label = "幽灵护盾层数:", ifNode = 28884, apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:GhostShroud", "BASE", m_min(val, 3), "Config")
	end },
	
{ label = "【狙击】:", ifCond = "CanSnipeStage"},
{ var = "snipeStageCount", type = "count", label = "# 【狙击】层数:", tooltip="持续吟唱给弓箭充能，积累层数，最大 6 层。",
ifCond = "CanSnipeStage", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:狙击Stage", "BASE", m_min(val, 6), "Config", { type = "Condition", var = "Effective" })
	end },
	
{ var = "affectedByHeraldCount", type = "count", label = "你受到几个捷光环影响:", ifSkillList = {"灰烬之捷","寒冰之捷","闪电之捷","纯净之捷","苦痛之捷"}, tooltip = "设置受到几个捷光环影响.\n默认是 0; 最大是  5.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:AffectedByHeraldCount", "BASE", m_min(val, 5), "Config", { type = "Condition", var = "Effective" })
	end },
	
	

{ label = "战吼:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", "激励战吼", "震地战吼" } },
{ var = "multiplierWarcryPower", type = "count", label = "威力值:", ifSkillList = { "炼狱呼嚎", "先祖战吼", "坚决战吼", "将军之吼", "威吓战吼", "激励战吼", "震地战吼" }
, tooltip = "设置战吼的威力值.\n普通敌人提供 1 点威力值，\n魔法敌人提供 2 点，\n稀有敌人提供 10 点，\n传奇敌人提供 20 点\n，玩家则提供 5 点", apply = function(val, modList, enemyModList)
		modList:NewMod("WarcryPower", "OVERRIDE", val, "Config")		
	end },


{ label = "【熔岩护盾】:", ifSkill = "熔岩护盾" },
	{ var = "MoltenShellDamageMitigated", type = "count", label = "减免的伤害数值:", tooltip = "被熔岩护盾减免的伤害", 
	ifSkill = "熔岩护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "MoltenShellDamageMitigated", value = val }, "Config", { type = "SkillName", skillName = "熔岩护盾" })
	end },
{ label = "【瓦尔.熔岩护盾】:", ifSkill = "瓦尔.熔岩护盾" },
{ var = "VaalMoltenShellDamageMitigated", type = "count", label = "减免的伤害数值:", 
tooltip = "最后一秒被瓦尔.熔岩护盾减免的伤害", ifSkill = "瓦尔.熔岩护盾", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "VaalMoltenShellDamageMitigated", value = val }, "Config", { type = "SkillName", skillName = "熔岩护盾" })
	end },
{ label = "破盾击:", ifSkill = "破盾击" },
	{ var = "ShieldShatter", type = "check", label = "破盾击触发?", ifSkill = "破盾击", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ShieldShatterTrigger", "FLAG", true, "Config")
	end },
{ label = "上古之颅:", ifCond = "MinionsCanHearTheWhispers" },
	{ var = "conditionMinionsCanHearTheWhispers", type = "check", label = "召唤生物听到低语?", tooltip="（听到低语的召唤生物:\n每秒受到等于其 20% 最大生命的混沌伤害，\n攻击速度加快 50%，\n攻击伤害提高 50%，\n并且不会听从你的命令）",
	ifCond = "MinionsCanHearTheWhispers", apply = function(val, modList, enemyModList)

modList:NewMod("MinionModifier", "LIST", { mod = modLib.
createMod("ChaosDegen", "BASE", 20/100, "Config", { type = "PerStat", stat = "Life", div = 1 },{ type = "Condition", var = "Combat" }) }, "Config",{ type = "Condition", var = "MinionsCanHearTheWhispers" })
modList:NewMod("MinionModifier", "LIST", { mod = modLib.
createMod("Speed", "INC", 50, "Config", ModFlag.Attack, { type = "Condition", var = "Combat" }) }, "Config",{ type = "Condition", var = "MinionsCanHearTheWhispers" })
modList:NewMod("MinionModifier", "LIST", { mod = modLib.
createMod("Damage", "INC", 50, "Config", { type = "Condition", var = "Combat" }) }, "Config",{ type = "Condition", var = "MinionsCanHearTheWhispers" })


	end },	
	
	{ label = "变形者外衣:", ifSkillList = { "精神失常"} },
	{ var = "conditionSandStance", type = "list", label = "错乱效果:", ifSkillList = { "精神失常" }, 
	list = {{val="SANE",label="理智"},{val="INSANE",label="疯狂"}}, apply = function(val, modList, enemyModList)
		if val == "SANE" then
			modList:NewMod("Condition:SaneInsanity", "FLAG", true, "Config")
		elseif  val == "INSANE" then
			modList:NewMod("Condition:InSaneInsanity", "FLAG", true, "Config")
		end	
	end },
	
	{ label = "疯狂的象征:", ifSkill = "疯狂之拥" },
	{ var = "conditionAffectedBy疯狂荣光", type = "check", label = "被【疯狂之拥】影响?", ifSkill = "疯狂之拥", 
	tooltip="受【疯狂荣光】影响时有XX的词缀生效用\n【疯狂荣光】每秒施加一个随机【触动】减益效果（迷雾里经常遇到）\n减益效果有4种,每种最多10层，pob暂时不支持。"..
	"\n 1 Diluting touch：每层使药剂充能和药剂效果降低\n 2 Eroding touch:每层使承受的伤害提高 6%\n 3 Paralysing touch:每层使动作速度 -6%\n 4 Wasting Touch:每层使生命和能量护盾回复速率 -9%",
	apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AffectedBy疯狂荣光", "FLAG", true, "Config")
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
{ var = "playerHasLessArmourandBlock", type = "list", label = "玩家的格挡率和护甲额外降低:", tooltip = "'	生锈之'", list = {{val=0,label="无"},{val="LOW",label="20%/20% (低阶)"},{val="MID",label="30%/25% (中阶)"},{val="HIGH",label="40%/30% (高阶)"}}, apply = function(val, modList, enemyModList)
		local map = { ["LOW"] = {20,20}, ["MID"] = {30,25}, ["HIGH"] = {40,30} }
		if map[val] then
			modList:NewMod("BlockChance", "INC", -map[val][1], "Config")
			modList:NewMod("Armour", "MORE", -map[val][2], "Config")
		end
	end },
{ var = "playerHasPointBlank", type = "check", label = "玩家拥有【零点射击】?", tooltip = "'冲突之'", apply = function(val, modList, enemyModList)
modList:NewMod("Keystone", "LIST", "零点射击", "Config")
	end },
{ var = "playerHasLessLifeESRecovery", type = "list", label = "玩家的生命和能量护盾总回复速度额外降低:", tooltip = "'窒息之'", list = {{val=0,label="无"},{val=20,label="20% (低阶)"},{val=40,label="40% (中阶)"},{val=60,label="60% (高阶)"}}, apply = function(val, modList, enemyModList)
		if val ~= 0 then
			modList:NewMod("LifeRecovery", "MORE", -val, "Config")
			modList:NewMod("EnergyShieldRecovery", "MORE", -val, "Config")
		end
	end },
{ var = "playerCannotRegenLifeManaEnergyShield", type = "check", label = "玩家无法回复生命，魔力和能量护盾?", tooltip = "'瘀血之'", apply = function(val, modList, enemyModList)
		modList:NewMod("NoLifeRegen", "FLAG", true, "Config")
		modList:NewMod("NoEnergyShieldRegen", "FLAG", true, "Config")
		modList:NewMod("NoManaRegen", "FLAG", true, "Config")
	end },
{ var = "enemyTakesReducedExtraCritDamage", type = "count", label = "怪物受到的暴击伤害降低:", tooltip = "'	坚韧之'\n低阶: 25-30%\n中阶: 31-35%\n高阶: 36-40%" , apply = function(val, modList, enemyModList)
		if val ~= 0 then
			enemyModList:NewMod("SelfCritMultiplier", "INC", -val, "Config")
		end
	end },
{ var = "multiplierSextant", type = "count", label = "# 个六分仪影响该地区", ifMult = "Sextant", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Sextant", "BASE", m_min(val, 5), "Config")
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
{ var = "useAbsorptionCharges", type = "check", label = "你是否有榨取球?", 
tooltip="（每个榨取球使玩家将受到元素伤害的 14% 回收为能量护盾。）\n（仅能回收击中伤害，它在击中 4 秒内回收）",
ifCond = "CanGainAbsorptionCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("UseAbsorptionCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "overrideAbsorptionCharges", type = "count", label = "榨取球数量(如果没达到最大值):",
 ifOption = "useAbsorptionCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("AbsorptionCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" },{type = "Condition", var = "CanGainAbsorptionCharges" })
	end },
{ var = "useAfflictionCharges", type = "check", label = "你是否有痛苦球?",
tooltip="（每个痛苦球使玩家异常状态总伤害额外提高 8%，非伤害型异常状态总效果额外提高 8%）",
 ifCond = "CanGainAfflictionCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("UseAfflictionCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "overrideAfflictionCharges", type = "count", label = "痛苦球数量(如果没达到最大值):", 
ifOption = "useAfflictionCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("AfflictionCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" },{type = "Condition", var = "CanGainAfflictionCharges" })
	end },
{ var = "useBrutalCharges", type = "check", label = "你是否有残暴球?",
tooltip="（每个残暴球使玩家有 3% 几率造成三倍伤害，眩晕门槛提高 10%）",
 ifCond = "CanGainBrutalCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("UseBrutalCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		 
	end },
{ var = "overrideBrutalCharges", type = "count", label = "残暴球数量(如果没达到最大值):", ifOption = "useBrutalCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("BrutalCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" },{type = "Condition", var = "CanGainBrutalCharges" })
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
{ var = "overrideChallengerCharges", type = "count", label = "# 挑战球数量 (如果没达到最大值):", ifOption = "useChallengerCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("ChallengerCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "useBlitzCharges", type = "check", label = "你是否有疾电球?", ifMult = "BlitzCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("UseBlitzCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "overrideBlitzCharges", type = "count", label = "# 疾电球数量 (如果没达到最大值):", ifOption = "useBlitzCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("BlitzCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "overrideInspirationCharges", type = "count", label = "# 激励球数量 (如果没达到最大值):", ifMult = "InspirationCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("InspirationCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "overrideBloodCharges", type = "count", label = "# 赤炼球数量 (如果没达到最大值):", ifMult = "BloodCharge", apply = function(val, modList, enemyModList)
		modList:NewMod("BloodCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "minionsUsePowerCharges", type = "check", label = "你的召唤生物有暴击球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UsePowerCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
{ var = "minionsOverridePowerCharges", type = "count", label = "#召唤生物的暴击球数量 (如果不是最大值的话):", ifFlag = "haveMinion", ifOption = "minionsUsePowerCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("PowerCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
{ var = "minionsUseFrenzyCharges", type = "check", label = "你的召唤生物有狂怒球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UseFrenzyCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
{ var = "minionsOverrideFrenzyCharges", type = "count", label = "召唤生物的狂怒球数量 (如果不是最大值的话):", ifFlag = "haveMinion", ifOption = "minionsUseFrenzyCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("FrenzyCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
{ var = "minionsUseEnduranceCharges", type = "check", label = "你的召唤生物有耐力球?", ifFlag = "haveMinion", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("UseEnduranceCharges", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	{ var = "minionsOverrideEnduranceCharges", type = "count", label = "召唤生物的耐力球数量 (如果不是最大值的话):", ifFlag = "haveMinion", ifOption = "minionsUseEnduranceCharges", apply = function(val, modList, enemyModList)
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("EnduranceCharges", "OVERRIDE", val, "Config", { type = "Condition", var = "Combat" }) }, "Config")
	end },
	

{ var = "conditionFocused", type = "check", label = "你处于专注期间?", ifCond = "Focused", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Focused", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffLifetap", type = "check", label = "是否处于赤炼效果期间?", ifCond = "Lifetap", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Lifetap", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionOnChannelling", type = "check", label = "你是否处于持续吟唱状态?", ifCond = "OnChannelling", tooltip = "当你处于持续吟唱状态时的词缀生效", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnChannelling", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },	
{ var = "buffOnslaught", type = "check", label = "你是否处于【猛攻】状态?", tooltip = "当你处于【猛攻】状态时干啥干啥的词缀生效,\n同时也会启用【猛攻】buff本身:提高 20% 移动、攻击和施法速度", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Onslaught", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffUnholyMight", type = "check", label = "你是否有【不洁之力】?", tooltip = "这个会启用【不洁之力】buff (额外混沌伤害，其数值等同于物理伤害的30%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UnholyMight", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffPhasing", type = "check", label = "你是否处于【迷踪】状态?", ifCond = "Phasing", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Phasing", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffFortify", type = "check", label = "你是否处于【护体】状态?", ifCond = "Fortify", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Fortify", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	
{ var = "buffVaalArcLuckyHits", type = "check", label = "你是否有【瓦尔.电弧】的【特别幸运】增益效果？", ifCond = "CanBeLucky",  
tooltip = "电弧的击中伤害会 roll 2 次，取高的那次", apply = function(val, modList, enemyModList)

modList:NewMod("LuckyHits", "FLAG", true, "Config", { type = "Condition", varList = { "Combat", "CanBeLucky" } }, 
{ type = "SkillName", skillNameList = { "电弧", "瓦尔.电弧" } })

end },
{ var = "buffElusive", type = "check", label = "你是否处于【灵巧】状态?", tooltip="这个会启用【灵巧】buff (\n·15% 几率躲避攻击伤害 \n·15% 几率躲避法术伤害\n·移动速度提高 30%)\n灵巧效果会随着时间不断削弱，每秒降低 20%\n在已经获得【灵巧】的情况下，无法再次获得【灵巧】)",
ifCond = "CanBeElusive", apply = function(val, modList, enemyModList)
	
		modList:NewMod("Condition:Elusive", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanBeElusive" })
		modList:NewMod("Elusive", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanBeElusive" })

	end },
{ var = "multiplierBuffElusiveHasLasted", type = "count", label = "【灵巧】持续几秒了:",ifCond = "CanBeElusive", tooltip="灵巧效果会随着时间不断削弱，每秒降低 20%\n在已经获得【灵巧】的情况下，无法再次获得【灵巧】",apply = function(val, modList, enemyModList)
		modList:NewMod("ElusiveEffectOnSelf", "INC", val*(-20), "Config")
	end },
	
	
{ var = "buffTailwind", type = "check", label = "你是否有【提速尾流】?", tooltip = "当你处于【提速尾流】状态时干啥干啥的词缀生效,\n同时也会启用【提速尾流】buff本身. (加速 8%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Tailwind", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffAdrenaline", type = "check", label = "你是否处于【肾上腺素】状态?", tooltip = "这个会启用【肾上腺素】buff:\n提高 100% 伤害\n提高 25% 攻击、施法和移动速度\n10%额外物理伤害减伤", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Adrenaline", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "buffAlchemistsGenius", type = "check", label = "你是否处于【炼金术天才】状态?", ifCond = "CanHaveAlchemistGenius", 
tooltip = "这个配置可以启用【炼金术天才】增益:\n药剂充能提高 20%\n药剂效果提高 20%", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AlchemistsGenius", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanHaveAlchemistGenius" })
	end },
{ var = "buffDivinity", type = "check", label = "你处于【神圣】状态?",ifCond = "Divinity", tooltip = "获得【神性】Buff:\n火焰、冰霜、闪电总伤害额外提高 50%\n承受的火焰、冰霜、闪电总伤害额外降低 20% ", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Divinity", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierDefiance", type = "count", label = "抗争:", ifMult = "Defiance", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:Defiance", "BASE", m_min(val, 10), "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierRage", type = "count", label = "怒火层数:", ifCond = "CanGainRage", apply = function(val, modList, enemyModList)
--		modList:NewMod("Multiplier:Rage", "BASE", val, "Config", { type = "IgnoreCond" }, { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainRage" })
	modList:NewMod("Multiplier:RageStack", "BASE", val, "Config", { type = "IgnoreCond" }, { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainRage" })

	
	end },
{ var = "multiplierGaleForce", type = "count", label = "【飓风之力】层数:", 
tooltip="【飓风之力】每一层独自持续 4 秒。最多有 10层",
ifCond = "CanGainGaleForce", apply = function(val, modList, enemyModList)
	modList:NewMod("Multiplier:GaleForce", "BASE", val, "Config", { type = "IgnoreCond" }, { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainGaleForce" })

	
end },
	
	
{ var = "conditionLeeching", type = "check", label = "你正在偷取?", ifCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	
	
 

	
 
{ var = "conditionLeechingLife", type = "check", label = "你正在偷取生命?", ifCond = "LeechingLife", implyCond = "Leeching", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LeechingLife", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionLeechingEnergyShield", type = "check", label = "你正在偷取能量护盾?", ifCond = "LeechingEnergyShield", implyCond = "Leeching", apply = function(val, modList, enemyModList)
modList:NewMod("Condition:LeechingEnergyShield", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
modList:NewMod("Condition:Leeching", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionLeechingMana", type = "check", label = "你正在偷取魔力?", ifCond = "LeechingMana", implyCond = "Leeching", apply = function(val, modList, enemyModList)
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
{ var = "multiplierNearbyAlly", type = "count", label = "附近友军数量：", ifMult = "NearbyAlly", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyAlly", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierNearbyEnemy", type = "count", label = "# 周围敌人数量", ifMult = "NearbyEnemy", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyEnemy", "BASE", val, "Config", { type = "Condition", var = "Combat" })
  end },
{ var = "multiplierNearbyCorpse", type = "count", label = "# 附近灵枢数量", ifMult = "NearbyCorpse", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyCorpse", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionAlliesOnFungalGround", type = "check", label = "友军和敌人正在【真菌地表】上?", tooltip = "当你处于【真菌地表】状态时干啥干啥的词缀生效,\n同时也会启用【真菌地表】buff本身:\n在你真菌地表上的友军将获得 10% 的非混沌伤害的额外混沌伤害。\n在你真菌地表上的敌人造成的伤害降低 10%。",
ifCond = "OnFungalGround",
 apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnFungalGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })	
		enemyModList:NewMod("Condition:OnFungalGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })			
	
	end },
{ var = "conditionOnConsecratedGround", type = "check", label = "你正在【奉献地面】上?", tooltip = "当你处于【奉献地面】状态时干啥干啥的词缀生效,\n同时也会启用【奉献地面】buff本身:6%每秒生命回复.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" }) })
	end },
{ var = "conditionOnBurningGround", type = "check", label = "你正在【燃烧地面】上?", ifCond = "OnBurningGround", implyCond = "Burning", tooltip = "这也意味着你被燃烧中.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnBurningGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Burning", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionOnChilledGround", type = "check", label = "你正在【冰缓地面】上?", ifCond = "OnChilledGround", implyCond = "Chilled", tooltip = "这也意味着你被冰缓.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:OnChilledGround", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionOnShockedGround", type = "check", label = "你正在【感电地面】上?", ifCond = "OnShockedGround", implyCond = "Shocked", tooltip = "这也意味着你被感电.", apply = function(val, modList, enemyModList)
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
{ var = "conditionFrozen", type = "check", label = "你被冰冻?", ifCond = "Frozen", implyCond = "Chilled", tooltip = "在也意味着你被冰缓.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Frozen", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionShocked", type = "check", label = "你被感电?", ifCond = "Shocked", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
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

{ var = "multiplierNearbyEnemies", type = "count", label = "# 附近敌人数量:", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:OnlyOneNearbyEnemy", "FLAG", val == 1, "Config", { type = "Condition", var = "Combat" })
	end },

{ var = "multiplierNearbyRareOrUniqueEnemies", type = "countAllowZero", label = "# 附近稀有或传奇敌人数量:", ifMult = "NearbyRareOrUniqueEnemies", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:NearbyRareOrUniqueEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Multiplier:NearbyEnemies", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:AtMostOneNearbyRareOrUniqueEnemy", "FLAG", val <= 1, "Config", { type = "Condition", var = "Combat" })
		enemyModList:NewMod("Condition:NearbyRareOrUniqueEnemy", "FLAG", val >= 1, "Config", { type = "Condition", var = "Combat" })
	end },
	
	
{ var = "conditionCostLifeRecently", type = "check", label = "你近期有消耗过生命?", ifCond = "CostLifeRecently",  apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CostLifeRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionHitRecently", type = "check", label = "你近期有击中过敌人?", ifCond = "HitRecently", tooltip = "如果你的主要技能是自主施放，那么自动认为你近期有击中过\n若有必要，你可以强制修改它.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:HitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionStunnedEnemyRecently", type = "check", label = "你近期有晕眩过敌人?", ifCond = "StunnedEnemyRecently", implyCond = "HitRecently", tooltip = "这也意味着你近期有击中过敌人.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:StunnedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:HitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionCritRecently", type = "check", label = "你近期有造成暴击?", ifCond = "CritRecently", implyCond = "SkillCritRecently", tooltip = "这也意味着你的技能近期有造成暴击.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:SkillCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
	{ var = "conditionSkillCritRecently", type = "check", label = "你的技能近期有造成暴击?", ifCond = "SkillCritRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:SkillCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionNonCritRecently", type = "check", label = "你近期有造成非暴击?", ifCond = "NonCritRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:NonCritRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
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
{ var = "conditionKilledPosionedLast2Seconds", type = "check", label = "过去 2 秒有击败中毒的敌人?", ifCond = "KilledPosionedLast2Seconds", implyCond = "KilledRecently", tooltip = "这也意味着你近期有击杀", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:KilledPosionedLast2Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionTotemsKilledRecently", type = "check", label = "你的图腾近期有击杀?", ifCond = "TotemsKilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TotemsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierTotemsKilledRecently", type = "count", label = "近期图腾的击杀数", ifMult = "EnemyKilledByTotemsRecently", implyCond = "TotemsKilledRecently", tooltip = "这也意味着你的图腾近期有击杀.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnemyKilledByTotemsRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:TotemsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionMinionsKilledRecently", type = "check", label = "你的召唤生物近期有击杀?", ifCond = "MinionsKilledRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:MinionsKilledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
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
{ var = "multiplierPoisonAppliedRecently", type = "count", label = "造成的中毒层数:", ifMult = "PoisonAppliedRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:PoisonAppliedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionBeenHitRecently", type = "check", label = "近期内你有被击中?", ifCond = "BeenHitRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BeenHitRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierBeenHitRecently", type = "count", label = "近期内你被击中的次数:", ifMult = "BeenHitRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:BeenHitRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:BeenHitRecently", "FLAG", 1 <= val, "Config", { type = "Condition", var = "Combat" })
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
{ var = "conditionConvergence", type = "check", label = "汇聚状态?", ifCond = "CanGainConvergence", apply = function(val, modList, enemyModList)

		modList:NewMod("Condition:Convergence", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainConvergence" })
		
	end },
{ var = "buffPendulum", type = "list",  label = "【毁灭光炮塔】升华天赋激活?", ifNode = 57197, list = {{val=0,label="不起作用"},{val="AREA",label="范围效果"},{val="DAMAGE",label="元素伤害"}}, apply = function(val, modList, enemyModList)
		if val == "AREA" then
			modList:NewMod("Condition:PendulumOfDestructionAreaOfEffect", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		elseif val == "DAMAGE" then
			modList:NewMod("Condition:PendulumOfDestructionElementalDamage", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		end
	end },
{ var = "buffConflux", type = "list", label = "汇流:", ifNode = 51391, list = {{val=0,label="不起作用"},{val="CHILLING",label="冰缓"},{val="SHOCKING",label="感电"},{val="IGNITING",label="点燃"},{val="ALL",label="冰缓，感电和点燃"}}, apply = function(val, modList, enemyModList)
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
{ var = "buffBastionOfHope", type = "check", label = "【希望壁垒】升华天赋激活?", ifNode = 39728, apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BastionOfHopeActive", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
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
{ var = "conditionUsedWarcryRecently", type = "check", label = "近期内你有使用过战吼?", implyCondList = {"UsedWarcryInPast8Seconds", "UsedSkillRecently"}, implyCond = "UsedSkillRecently", tooltip = "这也意味着你近期有使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:UsedWarcryInPast8Seconds", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedWarcryRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
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
{ var = "conditionConsumedCorpseRecently", type = "check", label = "近期消耗过灵柩?", ifCond = "ConsumedCorpseRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:ConsumedCorpseRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierCorpseConsumedRecently", type = "count", label = "近期消耗的灵柩数量:", ifMult = "CorpseConsumedRecently", implyCond = "ConsumedCorpseRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:CorpseConsumedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:ConsumedCorpseRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
		
	end },
{ var = "conditionTauntedEnemyRecently", type = "check", label = "近期嘲讽过怪物?", ifCond = "TauntedEnemyRecently", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:TauntedEnemyRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionLostEnduranceChargeInPast8Sec", type = "check", label = "过去 8 秒有失去过耐力球?", ifCond = "LostEnduranceChargeInPast8Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:LostEnduranceChargeInPast8Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "multiplierEnduranceChargesLostRecently", type = "count", label = "# 近期失去耐力球的数量:", ifMult = "EnduranceChargesLostRecently", implyCond = "LostEnduranceChargeInPast8Sec", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnduranceChargesLostRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:LostEnduranceChargeInPast8Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },

{ var = "conditionBlockedHitFromUniqueEnemyInPast10Sec", type = "check",  label = "过去10秒内有成功格挡过传奇敌人的击中?", ifNode = 63490, apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:BlockedHitFromUniqueEnemyInPast10Sec", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionCriticalStrike", type = "check", label = "解析【暴击时】词缀?", ifCond = "CriticalStrike", tooltip = "用于判官升华：无视元素抗性。",apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:CriticalStrike", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "conditionImpaledRecently", type = "check", label = "近期有穿刺过敌人?", apply = function(val, modList, enemyModLIst)
		modList:NewMod("Condition:ImpaledRecently", "FLAG", true, "Config", { type = "Condition", var = "Combat" })
	end },
{ var = "meleeDistanceWithEnemy", type = "count", label = "# 近战和敌人距离（15下拿满40+不起效）:" , ifCond = "CanMeleeDistanceRamp" },
{ var = "multiplierImaplesOnEnemy", type = "count", label = "# 敌人身上的穿刺数量:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:ImpaleStack", "BASE", val, "Config")
	end },
{ var = "multiplierBleedsOnEnemy", type = "count", label = "# 敌人身上的流血数量(如果没达到最大值):", ifFlag = "bleed", tooltip = "设置【玫红之舞】天赋的流血次数", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:BleedStacks", "BASE", val, "Config", { type = "Condition", var = "Combat" })
	end },

{ var = "buffFanaticism", type = "check", label = "你处于狂热状态?", ifCond = "CanGainFanaticism", tooltip = " (【狂热】可使你的自施法的法术的:\n总施法速度额外提高 75%，\n魔力消耗降低 75%，\n范围效果扩大 75%)", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:Fanaticism", "FLAG", true, "Config", { type = "Condition", var = "Combat" }, { type = "Condition", var = "CanGainFanaticism" })
	end },
	-- Section: Effective DPS options
{ section = "为了计算有效 DPS", col = 1 },
{ var = "critChanceLucky", type = "check", label = "你的暴击率是幸运的?", apply = function(val, modList, enemyModList)
		modList:NewMod("CritChanceLucky", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	

	
{ var = "skillChainCount", type = "count", label = "连锁过的次数:", ifFlag = "chaining", apply = function(val, modList, enemyModList)
		modList:NewMod("ChainCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "skillPierceCount", type = "count", label = "穿透敌人数量:", ifFlag = "piercing", apply = function(val, modList, enemyModList)
		modList:NewMod("PiercedCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "projectileDistance", type = "count", label = "投射物飞行距离:" },
{ var = "conditionAtCloseRange", type = "check", label = "怪物在近距离范围内?", ifCond = "AtCloseRange", apply = function(val, modList, enemyModList)
		modList:NewMod("Condition:AtCloseRange", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyMoving", type = "check", label = "敌人在移动中?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Moving", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },

{ var = "conditionEnemyOnConsecratedGround", type = "check", label = "敌人在奉献地面上?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:OnConsecratedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		
	end },	
{ var = "conditionEnemyOnProfaneGround", type = "check", label = "敌人在亵渎地面上?", ifCond = "CreateProfaneGround",
 tooltip = "亵渎地面上的敌人 -10% 所有抗性，并对它们的击中 +1% 暴击率", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:OnProfaneGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("ElementalResist", "BASE", -10, "Config", { type = "Condition", var = "OnProfaneGround" })
		enemyModList:NewMod("ChaosResist", "BASE", -10, "Config", { type = "Condition", var = "OnProfaneGround" })
		modList:NewMod("CritChance", "BASE", 1, "Config", { type = "ActorCondition", actor = "enemy", var = "OnProfaneGround" })
		modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("CritChance", "BASE", 1, { type = "ActorCondition", actor = "enemy", var = "OnProfaneGround" }) }, "Config")
		
	end },
{ var = "conditionEnemyInChillingArea", type = "check", label = "敌人在冰缓区域上?", ifEnemyCond = "InChillingArea", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:InChillingArea", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
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
{ var = "conditionEnemyPoisoned", type = "check", label = "敌人被中毒?", ifEnemyCond = "Poisoned", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Poisoned", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "multiplierPoisonOnEnemy", type = "count", label = "敌人身上的中毒层数:", implyCond = "Poisoned", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:PoisonStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "multiplierEnsnaredStackCount", type = "count", label = "# 圈套数量:", ifCond = "CanEnsnare", tooltip = "被捕获的敌人从攻击击中承受的投射物伤害提高, 每个敌人最多 3 个圈套.\n被诱捕的敌人始终视为在移动，并以更缓慢的速度试图突破圈套。\n一旦被捕猎的敌人离开范围效果，该圈套就被破坏。", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:EnsnareStackCount", "BASE", val, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:Moving", "FLAG", true, "Config", { type = "MultiplierThreshold", actor = "enemy", var = "EnsnareStackCount", threshold = 1 })
	end },
{ var = "conditionEnemyMaimed", type = "check", label = "敌人被瘫痪?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Maimed", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyHindered", type = "check", label = "敌人被阻碍?", ifEnemyCond = "Hindered", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Hindered", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyBlinded", type = "check", label = "敌人被致盲?", tooltip = "可以让“对致盲敌人什么什么”的词缀起作用\n同时减少敌人的命中率，增加你的闪避率.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Blinded", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyTaunted", type = "check", label = "敌人被嘲讽?", ifEnemyCond = "Taunted", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Taunted", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyBurning", type = "check", label = "敌人被燃烧", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Burning", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyIgnited", type = "check", label = "敌人被点燃?", implyCond = "Burning", tooltip = "这也意味着敌人被燃烧.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Ignited", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyScorched", type = "check", ifFlag = "inflictScorch", label = "敌人被烧灼?", 
tooltip = "被烧灼的敌人降低元素抗性, 最大 -30%.\n勾选这个选项后可以在下面配置具体的烧灼效果", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Scorched", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionScorchedEffect", type = "count", label = "【烧灼】效果:", ifOption = "conditionEnemyScorched", 
tooltip = "你可以对敌人造成烧灼的时候可以起作用.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ElementalResist", "BASE", -m_min(val, 30), "Config", { type = "Condition", var = "Scorched" })
	end },
{ var = "conditionEnemyOnScorchedGround", type = "check", label = "敌人在烧灼地面上?", tooltip = "这也意味着敌人被烧灼.", ifEnemyCond = "OnScorchedGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Scorched", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnScorchedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyChilled", type = "check", label = "敌人被冰缓?", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyChilledByYourHits", type = "check", ifEnemyCond = "ChilledByYourHits", label = "敌人是被你的击中所冰缓?",
 apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Chilled", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ChilledByYourHits", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyFrozen", type = "check", label = "敌人被冰冻?", implyCond = "Chilled", tooltip = "这也意味着敌人被冰冻.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Frozen", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyBrittle", type = "check", ifFlag = "inflictBrittle", label = "敌人被脆弱?", 
tooltip = "对脆弱的敌人的时提高自己的基础暴击率，最多 +15% \n勾选这个选项后可以在下面配置具体的脆弱效果", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Brittle", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	{ var = "conditionBrittleEffect", type = "count", label = "【脆弱】效果:", ifOption = "conditionEnemyBrittle",
	tooltip = "你可以对敌人造成脆弱的时候可以起作用.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("SelfCritChance", "BASE", m_min(val, 15), "Config", { type = "Condition", var = "Brittle" })
	end },
{ var = "conditionEnemyShocked", type = "check", label = "敌人被感电?", tooltip = "启用“对感电敌人什么什么”的词缀,\n这也会让敌人感电承受额外伤害.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:ShockedConfig", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			
	end },
{ var = "baseShockEffect", type = "integer", label = "强制固定感电的伤害加成",
 tooltip = "强制固定感电的伤害加成，其他不会感电加成不起作用，最高是 承受的总伤害额外提高 50%", ifOption = "conditionEnemyShocked",
		apply = function(val, modList, enemyModList) 
			modList:NewMod("EnemyShockEffect", "OVERRIDE", m_min(tonumber(val), 50), "Config") 
			enemyModList:NewMod("ShockVal", "BASE", val, "Shock", { type = "Condition", var = "ShockedConfig" })
			enemyModList:NewMod("DesiredShockVal", "BASE", val, "Shock", { type = "Condition", var = "ShockedConfig", neg = true })
				 
	end },
{ var = "conditionEnemyOnShockedGround", type = "check", label = "敌人在感电地面上?", 
tooltip = "勾选后敌人也被感电.", ifEnemyCond = "OnShockedGround", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Shocked", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("Condition:OnShockedGround", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemySapped", type = "check", ifFlag = "inflictSap", label = "敌人精疲力尽?", 
tooltip = "精疲力尽的敌人总伤害额外降低，最多降低 20%.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Sapped", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "multiplierFreezeShockIgniteOnEnemy", type = "count", label = "敌人身上的点燃感电冰缓数量:", ifMult = "FreezeShockIgniteOnEnemy", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:FreezeShockIgniteOnEnemy", "BASE", val, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyFireExposure", type = "check", label = "敌人被火焰曝露影响?", ifFlag = "applyFireExposure", tooltip = "降低敌人 10% 火焰抗性.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("FireExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyFireExposure" })
		enemyModList:NewMod("Condition:HaveExposure", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
{ var = "conditionEnemyColdExposure", type = "check", label = "敌人被冰霜曝露影响?", ifFlag = "applyColdExposure", tooltip = "降低敌人 10% 冰霜抗性", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ColdExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyColdExposure" })
		enemyModList:NewMod("Condition:HaveExposure", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end 
},
{ var = "conditionEnemyLightningExposure", type = "check", label = "敌人被闪电曝露影响?", ifFlag = "applyLightningExposure", tooltip = "降低敌人 10% 闪电抗性", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("LightningExposure", "BASE", -10, "Config", { type = "Condition", var = "Effective" }, { type = "ActorCondition", actor = "enemy", var = "CanApplyLightningExposure" })
		enemyModList:NewMod("Condition:HaveExposure", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },

{ var = "conditionEnemyIntimidated", type = "check",  label = "敌人被恐吓?", tooltip = "这个会附加词缀:\n提高 10% 敌人承受的攻击伤害", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Intimidated", "FLAG", true, "Config", { type = "Condition", var = "Effective" })	
			
	end },
{ var = "conditionEnemyUnnerved", type = "check",  label = "敌人被恐惧?", tooltip = "这个会附加词缀:\n提高 10% 敌人承受的法术伤害", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:Unnerved", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
	
{ var = "conditionEnemyCoveredInAsh", type = "check", label = "敌人【灰烬缠身】?", tooltip = "这个会附加词缀:\n额外降低敌人 20% 移动速度\n提高 20% 敌人承受的火焰伤害", apply = function(val, modList, enemyModList)
		
		
		modList:NewMod("CoveredInAshEffect", "BASE", 20, "灰烬缠身")
		
		
	end },
{ var = "conditionEnemyRareOrUnique", type = "check", label = "敌人是传奇或稀有怪物?", ifEnemyCond  = "EnemyRareOrUnique", tooltip = "如果boss类型选项选择的是boss，那么这里会默认为传奇或稀有怪物.", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
	end },
 
 
 { var = "multiplierRuptureStacks", type = "count", label = "# 残破层数", ifCond = "CanInflictRupture", tooltip = "【残破】持续 3秒\n最多叠加 3 层\n【残破】可使目标承受的总流血伤害额外提高 25%，身上的流血消退总速度额外提高 25%", 
 apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Multiplier:RuptureStack", "BASE", val, "Config", { type = "Condition", var = "Effective" })
		enemyModList:NewMod("DamageTaken", "MORE", 25, "残破", nil, KeywordFlag.Bleed, { type = "Multiplier", var = "RuptureStack", limit = 3}, { type = "ActorCondition", actor = "enemy", var = "CanInflictRupture" })
		modList:NewMod("EnemyBleedDuration", "INC", -25, "残破", { type = "Multiplier", var = "RuptureStack", limit = 3, actor = "enemy" }, { type = "ActorCondition", var = "CanInflictRupture" })
	end },
 
	
{ var = "enemyIsBoss", type = "list",  label = "敌人是boss?", 
tooltip = "普通boss有以下词缀：\n额外降低 33% 魔蛊效果\n+40% 火焰、冰霜、闪电抗性\n+25% 混沌抗性\n\n塑界者/塑界守卫有以下词缀：\n额外降低 66% 魔蛊效果\n+50% 火焰、冰霜、闪电抗性\n+30% 混沌抗性\n总护甲额外提高 33%\n\n诸界觉者希鲁斯有以下词缀：\n额外降低 66% 魔蛊效果\n+50% 火焰、冰霜、闪电抗性\n+30% 混沌抗性\n总护甲额外提高 100%",
list = {{val="NONE",label="不是"},{val="Uber Atziri",label="普通Boss"},
{val="Shaper",label="塑界者/塑界守卫"},
{val="Sirus",label="诸界觉者希鲁斯"}},
 apply = function(val, modList, enemyModList)
		if val == "Uber Atziri" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("CurseEffectOnSelf", "MORE", -33, "Boss")
			enemyModList:NewMod("ElementalResist", "BASE", 40, "Boss")
			enemyModList:NewMod("ChaosResist", "BASE", 25, "Boss")
			enemyModList:NewMod("AilmentThreshold", "BASE", 2190202, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")
		elseif val == "Shaper" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("CurseEffectOnSelf", "MORE", -66, "Boss")
			enemyModList:NewMod("ElementalResist", "BASE", 50, "Boss")
			enemyModList:NewMod("ChaosResist", "BASE", 30, "Boss")
			enemyModList:NewMod("Armour", "MORE", 33, "Boss")
			enemyModList:NewMod("AilmentThreshold", "BASE", 44360789, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")
		elseif val == "Sirus" then
			enemyModList:NewMod("Condition:RareOrUnique", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
			enemyModList:NewMod("CurseEffectOnSelf", "MORE", -66, "Boss")
			enemyModList:NewMod("ElementalResist", "BASE", 50, "Boss")
			enemyModList:NewMod("ChaosResist", "BASE", 30, "Boss")
			enemyModList:NewMod("Armour", "MORE", 100, "Boss")
			enemyModList:NewMod("AilmentThreshold", "BASE", 37940148, "Boss")
			modList:NewMod("WarcryPower", "BASE", 20, "Boss")
		end
	end },
	
{ var = "enemyAwakeningLevel", type = "count", label = "觉醒等级:", tooltip = "每层觉醒等级可以让boss的总生命额外提高 3%", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Life", "MORE", 3 * m_min(val, 9), "Config")
		modList:NewMod("AwakeningLevel", "BASE", m_min(val, 9), "Config")
	end },
{ var = "enemyPhysicalReduction", type = "integer", label = "敌人物理伤害减伤:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("PhysicalDamageReduction", "BASE", val, "Config")
	end },
{ var = "enemyFireResist", type = "integer", label = "敌人火焰抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("FireResist", "BASE", val, "Config")
	end },
{ var = "enemyColdResist", type = "integer", label = "敌人冰霜抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ColdResist", "BASE", val, "Config")
	end },
{ var = "enemyLightningResist", type = "integer", label = "敌人闪电抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("LightningResist", "BASE", val, "Config")
	end },
{ var = "enemyChaosResist", type = "integer", label = "敌人混沌抗性:", apply = function(val, modList, enemyModList)
		enemyModList:NewMod("ChaosResist", "BASE", val, "Config")
	end },
{ var = "enemyConditionHitByFireDamage", type = "check", label = "敌人被火焰伤害击中?", ifNode = 39085, apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByFireDamage", "FLAG", true, "Config")
	end },
{ var = "enemyConditionHitByColdDamage", type = "check", label = "敌人被冰霜伤害击中?", ifNode = 39085, apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByColdDamage", "FLAG", true, "Config")
	end },
{ var = "enemyConditionHitByLightningDamage", type = "check", label = "敌人被闪电伤害击中?", ifNode = 39085, apply = function(val, modList, enemyModList)
		enemyModList:NewMod("Condition:HitByLightningDamage", "FLAG", true, "Config")
	end },
	--[[
{ var = "EEIgnoreHitDamage", type = "check", label = "忽略技能击中伤害?", ifNode = 39085, tooltip = "这个选项是防止【元素之相】受到你的主要技能的伤害类型的影响." },
]]--

 




{ var = "multiplierManaSpentRecently", type = "count", label = "# 近期消耗的总魔力:", ifMult = "ManaSpentRecently", implyCond = "UsedSkillRecently", tooltip = "这个选项只用于【靛蓝之冠 灵主之环】.\n同时也意味着你近期使用过技能.", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:ManaUsedRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })			
		modList:NewMod("Multiplier:ManaSpentRecently", "BASE", val, "Config", { type = "Condition", var = "Combat" })
		modList:NewMod("Condition:UsedSkillRecently", "FLAG", val >= 1, "Config", { type = "Condition", var = "Combat" })
end },
{ var = "raiseSpectreEnableSummonedUrsaRallyingCry", type = "check", label = "启用【召唤之爪】的激励战吼:", ifSkill = "DropBearSummonedRallyingCry", apply = function(val, modList, enemyModList)
		modList:NewMod("SkillData", "LIST", { key = "enable", value = true }, "Config", { type = "SkillId", skillId = "DropBearSummonedRallyingCry" })
	end },
{ label = "召唤毒蛛:", ifSkill = "召唤毒蛛" },
{ var = "raiseSpidersSpiderCount", type = "count", label = "蜘蛛数量:", ifSkill = "召唤毒蛛", apply = function(val, modList, enemyModList)
		modList:NewMod("Multiplier:RaisedSpider", "BASE", m_min(val, 20), "Config")
	end },
{ var = "physicsRandomElement", type = "list",  label = "随机元素想要随机哪一个？", tooltip = "【注意】随机元素在游戏内是随机计算的，\n这里允许你选择其一种或不生效，\n所以模拟这个伤害和真实情况是会有差距的，\n新手请勿选择.", list = {{val="NONE",label="不生效"},{val="Fire",label="随机到火焰"},{val="Cold",label="随机到冰霜"},{val="Lightning",label="随机到闪电"}}, apply = function(val, modList, enemyModList)
		if val == "Fire" then
				modList:NewMod("Condition:PhysicsRandomElementFire", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:PhysicsRandomElementFire", "FLAG", true, "Config") }, "Config", { type = "Condition", var = "Effective" })
			 
		elseif val == "Cold" then
			 	modList:NewMod("Condition:PhysicsRandomElementCold", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:PhysicsRandomElementCold", "FLAG", true, "Config") }, "Config", { type = "Condition", var = "Effective" })
			
		 
		elseif val == "Lightning" then
			 	modList:NewMod("Condition:PhysicsRandomElementLightning", "FLAG", true, "Config", { type = "Condition", var = "Effective" })
				modList:NewMod("MinionModifier", "LIST", { mod = modLib.createMod("Condition:PhysicsRandomElementLightning", "FLAG", true, "Config") }, "Config", { type = "Condition", var = "Effective" })
			
		end
	end },
	 

}




