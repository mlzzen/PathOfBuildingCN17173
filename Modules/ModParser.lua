-- Path of Building
--
-- Module: Mod Parser for 3.0
-- Parser function for modifier names
--
--local launch=...
local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

local conquerorList = {
	["xibaqua"]		=	{id = 1, type = "vaal"},
	["zerphi"]		=	{id = 2, type = "vaal"},
	["doryani"]		=	{id = 3, type = "vaal"},
	["ahuana"]		=	{id = "2_v2", type = "vaal"},
	["deshret"]		=	{id = 1, type = "maraketh"},
	["asenath"]		=	{id = 2, type = "maraketh"},
	["nasima"]		=	{id = 3, type = "maraketh"},
	["balbala"]		=	{id = "1_v2", type = "maraketh"},
	["cadiro"]		=	{id = 1, type = "eternal"},
	["victario"]	=	{id = 2, type = "eternal"},
	["chitus"]		=	{id = 3, type = "eternal"},
	["caspiro"]		=	{id = "3_v2", type = "eternal"},
	["kaom"]		=	{id = 1, type = "karui"},
	["rakiata"]		=	{id = 2, type = "karui"},
	["kiloava"]		=	{id = 3, type = "karui"},
	["akoya"]		=	{id = "3_v2", type = "karui"},
	["venarius"]	=	{id = 1, type = "templar"},
	["dominus"]		=	{id = 2, type = "templar"},
	["avarius"]		=	{id = 3, type = "templar"},
	["maxarius"]	=	{id = "1_v2", type = "templar"},
	
	["夏巴夸亚"]		=	{id = 1, type = "vaal"},
	["泽佛伊"]		=	{id = 2, type = "vaal"},
	["多里亚尼"]		=	{id = 3, type = "vaal"},
	
	["阿华纳"]		=	{id = "2_v2", type = "vaal"},	
	["迪虚瑞特"]		=	{id = 1, type = "maraketh"},
	["安赛娜丝"]		=	{id = 2, type = "maraketh"},
	["娜斯玛"]		=	{id = 3, type = "maraketh"},
	["巴巴拉"]		=	{id = "1_v2", type = "maraketh"},
	
	["卡迪罗"]		=	{id = 1, type = "eternal"},
	["维多里奥"]	=	{id = 2, type = "eternal"},
	["切特斯"]		=	{id = 3, type = "eternal"},
	["卡斯皮罗"]		=	{id = "3_v2", type = "eternal"},
	["冈姆"]		=	{id = 1, type = "karui"},
	["拉凯尔塔"]		=	{id = 2, type = "karui"},
	["克洛瓦"]		=	{id = 3, type = "karui"},
	["阿克雅"]		=	{id = "3_v2", type = "karui"},
	
	["维纳留斯"]	=	{id = 1, type = "templar"},
	["多米纳斯"]		=	{id = 2, type = "templar"},
	["阿瓦留斯"]		=	{id = 3, type = "templar"},
	["玛萨留斯"]	=	{id = "1_v2", type = "templar"},
}

-- List of modifier forms
local formList = {
	--【中文化程序额外添加开始】
	["穿透 (%d+)%% 敌人"] = "PEN",
	["延长 (%d+)%%"] = "INC", --备注：^(%d+)%% increased
	["扩大 (%d+)%%"] = "INC", --备注：^(%d+)%% increased
	["提高 %+([%d%.]+)%%"] = "BASE", 	
	["获得 ([%+%-][%d%.]+)%%?"] = "BASE",
	["附加 ([%+%-][%d%.]+)%%?"] = "BASE",
	["有 ([%+%-]?%d+)%% 几率"] = "CHANCE", --备注：^([%+%-]?%d+)%% chance
	["有 ([%+%-]?%d+)%% 的几率"] = "CHANCE", --备注：^([%+%-]?%d+)%% chance
	["([%+%-][%d%.]+)%%?"] = "BASE",
	["([%+%-]?[%d%.]+)%%? 额外"] = "BASE", 
	["([%+%-]?[%d%.]+)%%? 的"] = "BASE", 
	["可以穿透? (%d+)%%"] = "PEN", --备注：penetrates? (%d+)%%
	["有额外 ([%+%-]?%d+)%% 几率"] = "CHANCE", --备注：^([%+%-]?%d+)%% chance
	["穿透敌人? (%d+)%% 的"] = "PEN", --备注：penetrates? (%d+)%%
	["缩短 (%d+)%%"] = "RED",
	["缩小 (%d+)%%"] = "RED",
	["穿透其 (%d+)%%"] = "PEN", --备注：penetrates? (%d+)%%
	["攻击和法术附加 (%d+)%-(%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", --备注：adds (%d+) to (%d+) (%a+) damage to attacks and spells
	["附加 (%d+)%-(%d+) 点基础([^\\x00-\\xff]*)伤害"] = "DMG",
	["附加 (%d+)%-(%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMG",
	["额外造成 (%d+) %- (%d+) ([^\\x00-\\xff]*)伤害"] = "DMG",
	["造成 (%d+) %- (%d+) ([^\\x00-\\xff]*)伤害"] = "DMG",
	["法术附加 (%d+) %- (%d+) ([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", --备注：adds (%d+)%-(%d+) (%a+) spell damage
	["增加 (%d+)%%"] = "INC",
	["附加 (%d+) %- (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMG",
	["附加 (%d+) %- (%d+) ([^\\x00-\\xff]*)伤害"] = "DMG",
	["便提高 (%d+)%%"] = "INC", --备注：^(%d+)%% increased
	["比平常慢 (%d+)%%"] = "RED",
	["(%d+) 次击中"] = "BASE",
	["加快 (%d+)%%"] = "INC",
	["减慢 (%d+)%%"] = "RED",
	--【中文化程序额外添加结束】
	["提高 (%d+)%%"] = "INC", --备注：^(%d+)%% increased
	["比平常快 (%d+)%%"] = "INC", --备注：^(%d+)%% faster
	["降低 (%d+)%%"] = "RED", --备注：^(%d+)%% reduced
	["延后 (%d+)%%"] = "RED", --备注：^(%d+)%% slower
	["总增 (%d+)%%"] = "MORE",
	["([^\\x00-\\xff]*)总([^\\x00-\\xff]*)额外提高 (%d+)%%"] = "MORE", --备注：^(%d+)%% more
	["总降 (%d+)%%"] = "LESS",
	["([^\\x00-\\xff]*)总([^\\x00-\\xff]*)额外降低 (%d+)%%"] = "LESS", --备注：^(%d+)%% less
	["^([%+%-][%d%.]+)%%?"] = "BASE",
	["^([%+%-][%d%.]+)%%? to"] = "BASE",
	["^([%+%-]?[%d%.]+)%%? of"] = "BASE",
	["([%+%-][%d%.]+)%%? 点"] = "BASE", --备注：^([%+%-][%d%.]+)%%? base
	["额外(.*) ([%+%-]?[%d%.]+)%%? (.*)"] = "BASE", --备注：^([%+%-]?[%d%.]+)%%? additional
	["你获得 ([%d%.]+)"] = "BASE", --备注：^you gain ([%d%.]+)
	["^gains? ([%d%.]+)%% of"] = "BASE",
	["([%+%-]?%d+)%% 几率"] = "CHANCE", --备注：^([%+%-]?%d+)%% chance
	["有 ([%+%-]?%d+)%% 的几率"] = "CHANCE", 
	["^([%+%-]?%d+)%% additional chance"] = "CHANCE",
	["^([%+%-]?%d+)%% 的几率"] = "CHANCE", 
	
	["穿透? (%d+)%%"] = "PEN", --备注：penetrates? (%d+)%%
	["penetrates (%d+)%% of"] = "PEN",
	["penetrates (%d+)%% of enemy"] = "PEN",
	["^([%d%.]+) (.+) regenerated per second"] = "REGENFLAT",
	["^([%d%.]+)%% (.+) regenerated per second"] = "REGENPERCENT",
	["每秒回复 ([%d%.]+)%% ([^\\x00-\\xff]*)"] = "REGENPERCENT", --备注：^([%d%.]+)%% of (.+) regenerated per second
	["^regenerate ([%d%.]+) (.+) per second"] = "REGENFLAT",
	["^regenerate ([%d%.]+)%% (.+) per second"] = "REGENPERCENT",
	["^regenerate ([%d%.]+)%% of (.+) per second"] = "REGENPERCENT",
	["^regenerate ([%d%.]+)%% of your (.+) per second"] = "REGENPERCENT",
	["每秒受到 ([%d%.]+) (%a+)伤害"] = "DEGEN", --备注：^([%d%.]+) (%a+) damage taken per second
	["^([%d%.]+) (%a+) damage per second"] = "DEGEN",
	["(%d+) to (%d+) added (%a+) damage"] = "DMG",
	["(%d+)%-(%d+) added (%a+) damage"] = "DMG",
	["(%d+) to (%d+) additional (%a+) damage"] = "DMG",
	["(%d+)%-(%d+) additional (%a+) damage"] = "DMG",
	["^(%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMG", --备注：^(%d+) to (%d+) (%a+) damage
	["附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMG", --备注：adds (%d+) to (%d+) (%a+) damage
	["附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMG", --备注：adds (%d+)%-(%d+) (%a+) damage
	["攻击附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", --备注：adds (%d+) to (%d+) (%a+) damage to attacks
	["攻击附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", --备注：adds (%d+)%-(%d+) (%a+) damage to attacks
	["攻击附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", --备注：adds (%d+) to (%d+) (%a+) attack damage
	["攻击附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", --备注：adds (%d+)%-(%d+) (%a+) attack damage
	["法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", --备注：adds (%d+) to (%d+) (%a+) damage to spells
	["法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", --备注：adds (%d+)%-(%d+) (%a+) damage to spells
	["法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", --备注：adds (%d+) to (%d+) (%a+) spell damage
	["法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", --备注：adds (%d+)%-(%d+) (%a+) spell damage
	["攻击和法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", --备注：adds (%d+) to (%d+) (%a+) damage to attacks and spells
	["攻击和法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", --备注：adds (%d+)%-(%d+) (%a+) damage to attacks and spells
	["攻击和法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", -- o_O --备注：adds (%d+) to (%d+) (%a+) damage to spells and attacks
	["攻击和法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", -- o_O --备注：adds (%d+)%-(%d+) (%a+) damage to spells and attacks
	["adds (%d+) to (%d+) (%a+) damage to hits"] = "DMGBOTH",
	["adds (%d+)%-(%d+) (%a+) damage to hits"] = "DMGBOTH",
	["给攻击附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", 	
	["给法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", 	
	["给攻击和法术附加 (%d+) %- (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", 
	["给攻击附加 (%d+) %- (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", 	
	["给法术附加 (%d+) %- (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", 	
	["给攻击和法术附加 (%d+) %- (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGBOTH", 
	["给攻击附加 (%d+) 到 (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", 	
	["给法术附加 (%d+) 到 (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGSPELLS",
	["给攻击和法术附加 (%d+) 到 (%d+) 基础([^\\x00-\\xff]*)伤害"] = "DMGBOTH", 
	["给攻击附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", 	
	["给法术附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGSPELLS", 	
	["给攻击和法术附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGBOTH", 
	["攻击附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGATTACKS", 	
	["附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)法术伤害"] = "DMGSPELLS",

	["附加 (%d+) 到 (%d+) 点([^\\x00-\\xff]*)伤害"] = "DMGBOTH", 
}

local function supportedByEffects(num,support)

		local skillId = FuckSkillSupportCnName(support)
		if skillId then
			local gemId = data.gemForBaseName[data.skills[skillId].name] 
			or data.gemForBaseName[data.skills[skillId].name .. "(辅)"]
			or data.gemForBaseName[data.skills[skillId].name .. "（辅）"]
			or data.gemForBaseName[data.skills[skillId].name .. " 辅助"]
			or data.gemForBaseName[data.skills[skillId].name .. "(强辅)"]
			or data.gemForBaseName[data.skills[skillId].name .. "（强辅）"]
			or data.gemForBaseName[data.skills[skillId].name .. "【强辅】"]
			
			if gemId then
				return {
					mod("ExtraSupport", "LIST", { skillId = data.gems[gemId].grantedEffectId, level = num }, { type = "SocketedIn", slotName = "{SlotName}" }),
					mod("ExtraSupport", "LIST", { skillId = data.gems[gemId].secondaryGrantedEffectId, level = num }, { type = "SocketedIn", slotName = "{SlotName}" })
				}
			else
				return {
					mod("ExtraSupport", "LIST", { skillId = skillId, level = num }, { type = "SocketedIn", slotName = "{SlotName}" }),
				}
			end
		end
		
end


-- Map of modifier names
local modNameList = {
	--【中文化程序额外添加开始】
	["你技能给予召唤生物的非诅咒光环效果"] = { "AuraEffectOnSelf", addToMinion = true },
	["魔像提供的增益效果"] = { "BuffEffect", tag = { type = "SkillType", skillType = SkillType.Golem } },
	 ["魔蛊技能的效果区域"] = { "AreaOfEffect", tag = { type = "SkillType", skillType = SkillType.Hex } },
	  ["魔蛊技能的范围效果"] = { "AreaOfEffect", tag = { type = "SkillType", skillType = SkillType.Hex } },
	  ["魔蛊的效果区域"] = { "AreaOfEffect", tag = { type = "SkillType", skillType = SkillType.Hex } },
	  ["魔蛊的范围效果"] = { "AreaOfEffect", tag = { type = "SkillType", skillType = SkillType.Hex } },
	["攻击和移动速度"] = { "Speed", "MovementSpeed" },
	["攻击速度，施法速度和移动速度"] = { "Speed", "MovementSpeed" },
	["不被攻击击中"] = "AttackDodgeChance", 
	["攻击和法术暴击伤害加成"] = {"CritMultiplier"}, --备注：critical strike multiplier -- 这个需要提到前面来
	["攻击和法术基础暴击伤害加成"] = {"CritMultiplier", ModFlag.Hit}, --备注：critical strike multiplier -- 
	["攻击和法术暴击伤害"] = {"CritMultiplier", ModFlag.Hit}, --备注：critical strike multiplier -- 
	["攻击与法术暴击率"] = { "CritChance" , tag = { type = "Global" }},
	["攻击和法术暴击率"] = { "CritChance" , tag = { type = "Global" }},
	["总魔力保留"] = "ManaReserved",
	["药剂持续期间间"] = "FlaskDuration",-- 官网的sx翻译
	["闪电伤害击中时有 ([%+%-]?%d+)%% 几率使敌人受到感电效果影响"] = "EnemyShockChance", --备注：to shock
	["法杖攻击伤害"] = { "Damage", flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["诅咒范围扩大"] = function(num) return {  mod("AreaOfEffect", "INC", num,nil, KeywordFlag.Curse)  } end,
	["冰冻"] = "EnemyFreezeChance", --备注：to freeze
	["攻击与施法速度"] = "Speed", --备注：attack and cast speed
	["攻击造成的物理伤害"] = { "PhysicalDamage", flags = ModFlag.Attack }, --备注：physical attack damage
	["物理伤害减伤"] = "PhysicalDamageReduction", --备注：physical damage reduction
	["造成流血"] = "BleedChance",
	["元素抗性上限"] = { "FireResistMax", "ColdResistMax", "LightningResistMax"},
	["所有元素抗性"] = "ElementalResist",
	["元素抗性"] = "ElementalResist", --备注：all elemental resistances
	["范围效果的"] = "AreaOfEffect", --备注：area of effect
	["效果区域的"] = "AreaOfEffect", --备注：area of effect
	["火焰、冰霜、闪电伤害的"] = "ElementalDamage", --备注：elemental damage
	["火焰伤害的"] = "FireDamage", --备注：fire damage
	["其伤害的"] = "Damage", --备注：damage
	["受到的火焰、冰霜、闪电伤害"] = "ElementalDamageTaken", --备注：damage taken
	["攻击和法术基础暴击率"] = "CritChance", --备注：critical strike chance
	["受到的伤害"] = "DamageTaken", --备注：damage taken
	["躲避法术伤害击中"] = "SpellDodgeChance", --备注：to dodge spells
	["最大能力护盾"] = "EnergyShield", --备注：maximum energy shield fuck国服翻译
	["受到的持续性伤害"] ="DamageTakenOverTime", --备注：damage over time
	["中毒持续时间便"] = { "EnemyPoisonDuration" }, --备注：poison duration
	["造成流血"] = "BleedChance", --备注：to cause bleeding
	["造成中毒"] = "PoisonChance",
	["所有属性"] = { "Str", "Dex", "Int" }, --备注：all attributes
	["造成冰冻、感电与点燃效果"] = { "EnemyFreezeChance", "EnemyShockChance", "EnemyIgniteChance" }, --备注：to freeze, shock and ignite
	["能量护盾回复速度"] = "EnergyShieldRecharge", --备注：energy shield recharge rate
	["晕眩和格挡回复"] = "StunRecovery", --备注：stun recovery
	["获得的充能数"] = "FlaskChargesGained", --备注：flask charges gained
	["武器攻击范围"] = "WeaponRange",
	["该装备的闪避与能量护盾"] = "EvasionAndEnergyShield", --备注：evasion and energy shield
	["闪避与能量护盾"] = "EvasionAndEnergyShield",
	["该装备的护甲与能量护盾"] = "ArmourAndEnergyShield", 
	["护甲与能量护盾"] = "ArmourAndEnergyShield", 
	["该装备的护甲与闪避"] = "ArmourAndEvasion",
	["护甲与闪避"] = "ArmourAndEvasion",
	["护甲、闪避和能量护盾"] = "Defences",
	["该装备的护甲、闪避和能量护盾"] = "Defences",
	["该装备的护甲"] = "Armour", --备注：armour
	["该装备的闪避值"] = "Evasion",
	["该装备的能量护盾"] = "EnergyShield", 
	["火焰与冰霜抗性"] = { "FireResist", "ColdResist" }, --备注：fire and cold resistances
	["火焰与闪电抗性"] = { "FireResist", "LightningResist" }, --备注：fire and lightning resistances
	["冰霜与闪电抗性"] = { "ColdResist", "LightningResist" }, --备注：cold and lightning resistances
	["对敌人的感电效果持续时间"] = "EnemyShockDuration", --备注：shock duration
	["的攻击格挡率套用于法术格挡"] = "BlockChanceConv",
	["格挡法术"] = "SpellBlockChance", --备注：to block spells
	["法术伤害格挡几率"] = "SpellBlockChance", --备注：to block spells
	["格挡法术伤害几率"] = "SpellBlockChance",
	["法术格挡几率"] = "SpellBlockChance", 
	["格挡法术伤害"] = "SpellBlockChance",
	["攻击格挡几率"] = "BlockChance", 
	["格挡攻击"] = "BlockChance", --备注：block chance
	["攻击伤害格挡率"] = "BlockChance", 
	["攻击伤害格挡几率"] = "BlockChance", --备注：block chance
	["基础暴击伤害加成"] = "CritMultiplier", --备注：critical strike multiplier
	["全部抗性上限"] = { "FireResistMax", "ColdResistMax", "LightningResistMax", "ChaosResistMax" }, --备注：all maximum resistances
	["混沌抗性上限"] = "ChaosResistMax",
	["火焰、冰霜、闪电伤害"] = "ElementalDamage", --备注：elemental damage
	["武器物理伤害"] = { "PhysicalDamage", flags = ModFlag.Weapon }, --备注：physical weapon damage
	["攻击造成的投射物伤害"] = { "Damage", flags = bor(ModFlag.Projectile, ModFlag.Attack) },
	["最大闪避值"] = "Evasion",
	["击中伤害和异常状态伤害"] = { "Damage",  keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment)}, 
	["击中和异常状态伤害"] = { "Damage",  keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment)}, 
	--备注：attack damage
	["击中火焰伤害和异常状态伤害"] = { "FireDamage",  keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment)}, 
	["击中物理伤害和异常状态伤害"] = { "PhysicalDamage",  keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment)}, 
	["【闪电之捷】的增益效果"] = { "BuffEffect", tag = { type = "SkillName", skillName = "闪电之捷" } },
	["你造成的中毒持续时间"] = { "EnemyPoisonDuration" }, --备注：duration of poisons you inflict
	["物品数量"] = "LootQuantity",
	["持续伤害"] = { "Damage", flags = ModFlag.Dot }, 
	["生效期间，"] = "FlaskDuration",
	["瓦尔技能的伤害"] = { "Damage",keywordFlags = KeywordFlag.Vaal },
	["法术格挡几率"] = "SpellBlockChance", --备注：to block spells
	["护甲值"] = "Armour", --备注：armour
	["免疫流血"] = "AvoidBleed", 
	["被击中后中毒"] = "PoisonChance", --备注：to poison on hit
	["持续性物理伤害"] = { "PhysicalDamage", flags = ModFlag.Dot },
	["基础暴击率"] = "CritChance", --备注：critical strike chance
	["攻击基础暴击率"] = { "CritChance", flags = ModFlag.Attack },
	["投射物的攻击伤害"] = { "Damage", flags = bor(ModFlag.Projectile, ModFlag.Attack) },
	["受到的混沌伤害"] = "ChaosDamageTaken",
	["物品掉落稀有度"] = "LootRarity", --备注：rarity of items found
	["近战武器范围"] = "MeleeWeaponRange",
	["法术伤害"] = {"Damage",  flags = ModFlag.Spell }, 
	["点燃敌人"] = "EnemyIgniteChance", --备注：to ignite
	["力量与敏捷"] = { "Str", "Dex" }, --备注：strength and dexterity
	["力量与智慧"] = { "Str", "Int" }, --备注：strength and intelligence
	["敏捷与智慧"] = { "Dex", "Int" }, --备注：dexterity and intelligence
	["攻击和法术伤害格挡几率上限"] = "BlockChanceMax", 
	["混沌技能的范围"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Chaos },
	["战吼技能的范围效果"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Warcry },
	["战吼技能的效果区域"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Warcry },
	["格挡法术伤害"] = "SpellBlockChance", --备注：to block spells
	["攻击及法术伤害格挡几率"] = { "BlockChance", "SpellBlockChance" },
	["召唤圣物数量上限"] = "ActiveHolyRelicLimit",
	["非异常状态混沌持续伤害加成"] = "NonAilmentChaosDotMultiplier",--non-ailment chaos damage over time multiplier
	["额外总冰霜持续伤害效果"] = "ColdDotMultiplier",--cold damage over time multiplier
	["暴击球数量下限"] = "PowerChargesMin",
	["狂怒球数量下限"] = "FrenzyChargesMin",
	["耐力球数量下限"] = "EnduranceChargesMin",
	["【统御哨兵】持续时间"] = { "Duration", tag = { type = "SkillName", skillName = "霸气之击" } },
	["烙印技能的激活频率"] = "BrandActivationFrequency",
	["烙印的激活频率"] = "BrandActivationFrequency",
	["烙印激活频率"] = "BrandActivationFrequency",
	["火焰与混沌抗性"] = { "FireResist", "ChaosResist" }, 
	["闪电与混沌抗性"] = { "LightningResist", "ChaosResist" }, 
	["冰霜与混沌抗性"] = { "ColdResist", "ChaosResist" }, 
	["非异常状态混沌伤害持续时间加成"] = "NonAilmentChaosDotMultiplier",
		["冰霜伤害持续时间加成"] = "ColdDotMultiplier",
	["持续冰霜伤害加成"] = "ColdDotMultiplier",
	["持续冰霜伤害效果"] = "ColdDotMultiplier",
	["冰霜持续伤害加成"] =  "ColdDotMultiplier",
	["持续物理伤害加成"] = "PhysicalDotMultiplier",
	["持续火焰伤害加成"] = "FireDotMultiplier",
	["持续混沌伤害加成"] = "ChaosDotMultiplier",
	["持续伤害加成"] = "DotMultiplier",
	["物理持续伤害加成"] = "PhysicalDotMultiplier",
	["火焰持续伤害加成"] = "FireDotMultiplier",
	["混沌持续伤害加成"] = "ChaosDotMultiplier",
	["几率造成双倍伤害"] = "DoubleDamageChance",
	["异常状态持续时间"] = { "EnemyShockDuration", "EnemyFreezeDuration", "EnemyChillDuration", "EnemyIgniteDuration", "EnemyPoisonDuration", "EnemyBleedDuration", "EnemyScorchDuration", "EnemyBrittleDuration", "EnemySapDuration"  },
	["非异常状态的持续混沌伤害加成"] = "NonAilmentChaosDotMultiplier",
	["非异常状态的持续混沌伤害额外加成"] = "NonAilmentChaosDotMultiplier",
	["持续混沌伤害额外加成"] = "ChaosDotMultiplier",
	["持续混沌伤害加成"] = "ChaosDotMultiplier",
	["混沌伤害持续时间加成"] = "ChaosDotMultiplier",
	["从偷取获取的每秒生命回复"] = "LifeLeechRate",
	["从偷取获取的每秒魔力回复"] = "ManaLeechRate",
	["从偷取获取的每秒能量护盾回复"] = "EnergyShieldLeechRate",
	["生命偷取总回复上限"] = "MaxLifeLeechRate",
	["魔力偷取总回复上限"] = "MaxManaLeechRate",
	["能量护盾偷取总回复上限提高"] = "MaxEnergyShieldLeechRate",
	["力量和智慧需求"]={ "StrRequirement","IntRequirement" }, 
	["元素伤害"] = "ElementalDamage", --备注：elemental damage
	["元素抗性"] = "ElementalResist", 
	["从生命偷取中获得的最大总恢复量"] = "MaxLifeLeechInstance",
	["从能量护盾偷取中获得的最大总恢复量"] = "MaxEnergyShieldLeechInstance",
	["从魔力偷取中获得的最大总恢复量"] = "MaxManaLeechInstance",
	["从生命偷取中获得的每秒总恢复量"] = "LifeLeechRate",
	["从魔力偷取中获得的每秒总恢复量"] = "ManaLeechRate",
	["从能量护盾偷取中获得的每秒总恢复量"] = "EnergyShieldLeechRate",
	["从生命偷取中获得的每秒最大总恢复量"] = "MaxLifeLeechRate",
	["从能量护盾偷取中获得的每秒最大总恢复量"] = "MaxEnergyShieldLeechRate",
	["从魔力偷取中获得的每秒最大总恢复量"] = "MaxManaLeechRate",
	["攻击伤害格挡几率上限"] = "BlockChanceMax", 
	["你身上的药剂效果"] = "FlaskEffect",
	["冷却恢复速度"] = "CooldownRecovery", 
	["法术暴击几率"] = { "CritChance", flags = ModFlag.Spell },
	["最大火焰抗性"] = "FireResistMax", 
	["能量护盾每秒回复"] = "EnergyShieldRegen",
	["最大挑战球数量上限"] = "ChallengerChargesMax",
	["挑战球数量上限"] = "ChallengerChargesMax",
	["最大疾电球数量上限"] = "BlitzChargesMax",
	["疾电球数量上限"] = "BlitzChargesMax",
	["晕眩持续时间"] = "EnemyStunDuration", 
	["受到的元素伤害"] = "ElementalDamageTaken",
	["你造成的穿刺效果会额外持续"] = "ImpaleStacksMax",
	["穿刺的效果"] = "ImpaleEffect",
	["几率穿刺敌人"] = "ImpaleChance",
	["技能的魔力消耗"] = "ManaCost",
	["从药剂获得的生命回复"] = "FlaskLifeRecovery",
	["对敌人施加的非伤害异常状态效果"] = { "EnemyShockEffect", "EnemyChillEffect", "EnemyFreezeEffech" ,"EnemyScorchEffect","EnemyBrittleEffect","EnemySapEffect"}, 
	["非诅咒类光环效果"] = "AuraEffect", --备注：aura effect
	["所有最大抗性"] = { "FireResistMax", "ColdResistMax", "LightningResistMax", "ChaosResistMax" }, 
	["生命和能量护盾回复速度"] = { "LifeRecoveryRate", "EnergyShieldRecoveryRate" },
	["生命和能量护盾回复率"] = { "LifeRecoveryRate", "EnergyShieldRecoveryRate" },
	["地雷提供的光环效果"] = { "AuraEffect", keywordFlags = KeywordFlag.Mine },
	["地雷的光环效果"] = { "AuraEffect", keywordFlags = KeywordFlag.Mine },
	["地雷投掷速度"] = "MineLayingSpeed",
	["烈毒持续伤害加成"] = { "DotMultiplier",keywordFlags =  KeywordFlag.Poison }, 
	["持续中毒伤害加成"] = { "DotMultiplier",keywordFlags =  KeywordFlag.Poison }, 
	["持续流血伤害加成"] = { "DotMultiplier", keywordFlags = KeywordFlag.Bleed }, 
	["持续点燃伤害加成"] = { "DotMultiplier", keywordFlags = KeywordFlag.Ignite }, 
	["光环技能范围效果"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Aura }, 
	["光环技能效果区域"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Aura }, 
	["暴击加成"] = {"CritMultiplier", ModFlag.Hit}, 
	["【灵巧】效果"] = "ElusiveEffectOnSelf",
	["灵巧效果"] = "ElusiveEffectOnSelf",
	["投掷地雷类技能的"] = { keywordFlags = KeywordFlag.Mine },
	["投掷地雷的"] = { keywordFlags = KeywordFlag.Mine },
	["几率躲避攻击"] = "EvadeChance",
	["躲避攻击"] = "EvadeChance",
	["近战打击距离"] = { "MeleeWeaponRange", "UnarmedRange" },
	["近战打击范围"] = { "MeleeWeaponRange", "UnarmedRange" },
	["法杖攻击物理伤害"] = { "PhysicalDamage", flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["爪攻击物理伤害"] = { "PhysicalDamage", flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["剑攻击物理伤害"] = { "PhysicalDamage", flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["暴击几率"] = { "CritChance", tag = { type = "Global" } },
	["异常状态伤害"] = { "Damage",  keywordFlags = KeywordFlag.Ailment}, 
	["空手攻击范围"] = {  "UnarmedRange" },
	["战吼施法速度"] = { "WarcrySpeed", keywordFlags = KeywordFlag.Warcry },
	["反射的物理伤害"] = "PhysicalReflectedDamageTaken",
	["反射的元素伤害"] = "ElementalReflectedDamageTaken",
	["对投射物伤害格挡几率"] = "ProjectileBlockChance",
	["对投射物格挡几率"] = "ProjectileBlockChance",
	["你身上的秘术增强效果"] = "秘术增强Effect",
	 ["魔蛊持续时间"] = { "Duration", tag = { type = "SkillType", skillType = SkillType.Hex } },
	 ["几率施加畏火"] = "FireExposureChance",
		["几率施加畏寒"] = "ColdExposureChance",
		["几率施加闪电曝露"] = "LightningExposureChance",
	["愤怒狂灵数量上限"] = "ActiveRagingSpiritLimit",
		["召唤的幻灵数量上限"] = "ActivePhantasmLimit",
		["冰缓效果"] = "EnemyChillEffect",
		["充能次数"] = "FlaskChargesUsed",
		["充能上限"] = "FlaskCharges",
		["暴击球和耐力球数量上限"] = { "EnduranceChargesMax", "PowerChargesMax" }, 
	["从生命偷取中获得的每秒恢复量"] = "LifeLeechRate",
	["生命偷取的每秒总恢复量"] = "LifeLeechRate",
	["从能量护盾偷取中获得的每秒恢复量"] = "EnergyShieldLeechRate",
	["从魔力偷取中获得的每秒恢复量"] = "ManaLeechRate",
	["偷取的每秒最大生命总恢复量提高"] = "MaxLifeLeechRate",
	["偷取的每秒最大生命总恢复量"] = "MaxLifeLeechRate",
	["偷取的每秒最大能量护盾总恢复量"] = "MaxEnergyShieldLeechRate",
	["偷取的每秒最大魔力总恢复量"] = "MaxManaLeechRate",
	["技能的生命消耗"] = "LifeCost",
	["total cost"] = "Cost",
	["资源消耗"] = "Cost",
	["cost of skills"] = "Cost",
	["技能的保留效果"] = "Reserved",
	["技能保留效果"] = "Reserved",
	["技能的保留"] = "Reserved",
	["资源保留"] = { "Reserved" },
	["赤炼球数量上限"] = "BloodChargesMax",
	["for stance skills"] = { tag = { type = "SkillType", skillType = SkillType.StanceSkill } },
	["of stance skills"] = { tag = { type = "SkillType", skillType = SkillType.StanceSkill } },
	["效果区域"] = "AreaOfEffect",
	["耐力球、狂怒球、暴击球下限"] = { "PowerChargesMin", "FrenzyChargesMin", "EnduranceChargesMin" },
	["持续混沌伤害"] = { "ChaosDamage", flags = ModFlag.Dot },
	--【中文化程序额外添加结束】
	-- Attributes
	["力量"] = "Str", --备注：strength
	["敏捷"] = "Dex", --备注：dexterity
	["智慧"] = "Int", --备注：intelligence
	["力量和敏捷"] = { "Str", "Dex" }, --备注：strength and dexterity
	["力量和智慧"] = { "Str", "Int" }, --备注：strength and intelligence
	["敏捷和智慧"] = { "Dex", "Int" }, --备注：dexterity and intelligence
	["属性"] = { "Str", "Dex", "Int" }, --备注：attributes
	["全属性"] = { "Str", "Dex", "Int" }, --备注：all attributes
	-- Life/mana
	["生命"] = "Life", --备注：life
	["最大生命"] = "Life", --备注：maximum life
	["魔力"] = "Mana", --备注：mana
	["最大魔力"] = "Mana", --备注：maximum mana
	["魔力回复"] = "ManaRegen", --备注：mana regeneration
	["魔力回复速度"] = "ManaRegen", --备注：mana regeneration rate
	["魔力消耗"] = "ManaCost", --备注：mana cost
	["魔力消耗"] = "ManaCost", --备注：mana cost of
	["技能魔力消耗"] = "ManaCost", --备注：mana cost of skills
	["技能的总魔力消耗"] = "ManaCost", --备注：total mana cost of skills
	["魔力保留"] = "ManaReserved", --备注：mana reserved
	["魔力保留"] = "ManaReserved", --备注：mana reservation
	["^技能的魔力保留"] = "ManaReserved", --备注：mana reservation of skills
	-- Primary defences
	["最大能量护盾"] = "EnergyShield", --备注：maximum energy shield
	["能量护盾的回复速度"] = "EnergyShieldRecharge", --备注：energy shield recharge rate
	["能量护盾启动回复"] = "EnergyShieldRechargeFaster", --备注：start of energy shield recharge
	["护甲"] = "Armour", --备注：armour
	["evasion"] = "Evasion",
	["闪避值"] = "Evasion", --备注：evasion rating
	["能量护盾"] = "EnergyShield", --备注：energy shield
	["护甲和闪避"] = "ArmourAndEvasion", --备注：armour and evasion
	["护甲和闪避值"] = "ArmourAndEvasion", --备注：armour and evasion rating
	["闪避值与护甲"] = "ArmourAndEvasion", --备注：evasion rating and armour
	["护甲与能量护盾"] = "ArmourAndEnergyShield", --备注：armour and energy shield
	["闪避值和能量护盾"] = "EvasionAndEnergyShield", --备注：evasion rating and energy shield
	["闪避和能量护盾"] = "EvasionAndEnergyShield", --备注：evasion and energy shield
	["护甲、闪避和能量护盾"] = "Defences", --备注：armour, evasion and energy shield
	["防御"] = "Defences", --备注：defences
	["to evade"] = "EvadeChance",
	["chance to evade"] = "EvadeChance",
	["to evade attacks"] = "EvadeChance",
	["闪避攻击"] = "EvadeChance", --备注：chance to evade attacks
	["chance to evade projectile attacks"] = "ProjectileEvadeChance",
	["chance to evade melee attacks"] = "MeleeEvadeChance",
	-- Resistances
	["物理伤害减免"] = "PhysicalDamageReduction", --备注：physical damage reduction
	["physical damage reduction from hits"] = "PhysicalDamageReductionWhenHit",
	["火焰抗性"] = "FireResist", --备注：fire resistance
	["火焰抗性上限"] = "FireResistMax", --备注：maximum fire resistance
	["冰霜抗性"] = "ColdResist", --备注：cold resistance
	["冰霜抗性上限"] = "ColdResistMax", --备注：maximum cold resistance
	["闪电抗性"] = "LightningResist", --备注：lightning resistance
	["闪电抗性上限"] = "LightningResistMax", --备注：maximum lightning resistance
	["混沌抗性"] = "ChaosResist", --备注：chaos resistance
	["火焰和冰霜抗性"] = { "FireResist", "ColdResist" }, --备注：fire and cold resistances
	["火焰和闪电抗性"] = { "FireResist", "LightningResist" }, --备注：fire and lightning resistances
	["冰霜和闪电抗性"] = { "ColdResist", "LightningResist" }, --备注：cold and lightning resistances
	["火焰、冰霜、闪电抗性"] = "ElementalResist", --备注：elemental resistance
	["获得 ([%+%-]?%d+)%% 火焰、冰霜、闪电抗性"] = "ElementalResist", --备注：elemental resistances
	["火焰、冰霜、闪电抗性"] = "ElementalResist", --备注：all elemental resistances
	["所有抗性"] = { "ElementalResist", "ChaosResist" }, --备注：all resistances
	["火焰、冰霜、闪电抗性上限"] = { "FireResistMax", "ColdResistMax", "LightningResistMax" }, --备注：all maximum elemental resistances
	["所有属性的最大抗性上限"] = { "FireResistMax", "ColdResistMax", "LightningResistMax", "ChaosResistMax" }, --备注：all maximum resistances
	-- Damage taken
	["承受的伤害"] = "DamageTaken", --备注：damage taken
	["被击中时承受额外"] = "DamageTakenWhenHit", --备注：damage taken when hit
	["damage taken from damage over time"] = "DamageTakenOverTime",
	["受到的物理伤害"] = "PhysicalDamageTaken", --备注：physical damage taken
	["受到击中物理伤害的"] = "PhysicalDamageTaken", --备注：physical damage from hits taken
	["physical damage taken when hit"] = "PhysicalDamageTakenWhenHit",
	["physical damage taken over time"] = "PhysicalDamageTakenOverTime",
	["承受的闪电伤害"] = "LightningDamageTaken", --备注：lightning damage taken
	["lightning damage from hits taken"] = "LightningDamageTaken",
	["lightning damage taken when hit"] = "LightningDamageTakenWhenHit",
	["lightning damage taken over time"] = "LightningDamageTakenOverTime",
	["承受的冰霜伤害"] = "ColdDamageTaken", --备注：cold damage taken
	["cold damage from hits taken"] = "ColdDamageTaken",
	["cold damage taken when hit"] = "ColdDamageTakenWhenHit",
	["cold damage taken over time"] = "ColdDamageTakenOverTime",
	["受到的火焰伤害"] = "FireDamageTaken", --备注：fire damage taken
	["fire damage from hits taken"] = "FireDamageTaken",
	["fire damage taken when hit"] = "FireDamageTakenWhenHit",
	["fire damage taken over time"] = "FireDamageTakenOverTime",
	["承受的混沌伤害"] = "ChaosDamageTaken", --备注：chaos damage taken
	["chaos damage from hits taken"] = "ChaosDamageTaken",
	["chaos damage taken when hit"] = "ChaosDamageTakenWhenHit",
	["受到的持续性混沌伤害"] = "ChaosDamageTakenOverTime", --备注：chaos damage taken over time
	["承受的元素伤害"] = "ElementalDamageTaken", --备注：elemental damage taken
	["被击中时受到的火焰、冰霜、闪电伤害"] = "ElementalDamageTakenWhenHit", --备注：elemental damage taken when hit
	["elemental damage taken over time"] = "ElementalDamageTakenOverTime",
	-- Other defences
	["to dodge attacks"] = "AttackDodgeChance",
	["躲避攻击击中"] = "AttackDodgeChance", --备注：to dodge attack hits
	["躲避法术击中"] = "SpellDodgeChance", --备注：to dodge spells
	["to dodge spell hits"] = "SpellDodgeChance",
	["to dodge spell damage"] = "SpellDodgeChance",
	["躲避攻击和法术击中"] = { "AttackDodgeChance", "SpellDodgeChance" }, --备注：to dodge attacks and spells
	["to dodge attacks and spell damage"] = { "AttackDodgeChance", "SpellDodgeChance" },
	["to dodge attack and spell hits"] = { "AttackDodgeChance", "SpellDodgeChance" },
	["to block"] = "BlockChance",
	["to block attacks"] = "BlockChance",
	["to block attack damage"] = "BlockChance",
	["攻击格挡率"] = "BlockChance", --备注：block chance
	["block chance with staves"] = { "BlockChance", tag = { type = "Condition", var = "UsingStaff" } },
	["to block with staves"] = { "BlockChance", tag = { type = "Condition", var = "UsingStaff" } },
	["spell block chance"] = "SpellBlockChance",
	["法术格挡率"] = "SpellBlockChance", --备注：to block spells
	["to block spell damage"] = "SpellBlockChance",
	["攻击及法术格挡率"] = { "BlockChance", "SpellBlockChance" }, --备注：chance to block attacks and spells
	["攻击和法术格挡率上限"] = "BlockChanceMax", --备注：maximum block chance
	["maximum chance to block attack damage"] = "BlockChanceMax",
	["maximum chance to block spell damage"] = "SpellBlockChanceMax",
	["避免被晕眩"] = "AvoidStun", --备注：to avoid being stunned
	["避免被感电"] = "AvoidShock", --备注：to avoid being shocked
	["避免被冰冻"] = "AvoidFrozen", --备注：to avoid being frozen
	["避免被冰缓"] = "AvoidChilled", --备注：to avoid being chilled
	["避免被点燃"] = "AvoidIgnite", --备注：to avoid being ignited
	["避免元素异常状态"] = { "AvoidShock", "AvoidFrozen", "AvoidChilled", "AvoidIgnite" }, --备注：to avoid elemental ailments
	["to avoid elemental status ailments"] = { "AvoidShock", "AvoidFrozen", "AvoidChilled", "AvoidIgnite" },
	["避免被流血"] = "AvoidBleed", --备注：to avoid bleeding
	["的伤害优先从魔力扣除"] = "DamageTakenFromManaBeforeLife", --备注：damage is taken from mana before life
	["damage taken from mana before life"] = "DamageTakenFromManaBeforeLife",
	["你受到的诅咒效果"] = "CurseEffectOnSelf", --备注：effect of curses on you
	["生命回复速度"] = "LifeRecoveryRate", --备注：life recovery rate
	["mana recovery rate"] = "ManaRecoveryRate",
	["energy shield recovery rate"] = "EnergyShieldRecoveryRate",
	["recovery rate of life, mana and energy shield"] = { "LifeRecoveryRate", "ManaRecoveryRate", "EnergyShieldRecoveryRate" },
	-- Stun/knockback modifiers
	["晕眩回复和格挡回复"] = "StunRecovery", --备注：stun recovery
	["stun and block recovery"] = "StunRecovery",
	["block and stun recovery"] = "StunRecovery",
	["晕眩门槛"] = "StunThreshold", --备注：stun threshold
	["格挡回复"] = "BlockRecovery", --备注：block recovery
	["敌人晕眩门槛"] = "EnemyStunThreshold", --备注：enemy stun threshold
	["使敌人眩晕的门槛"] = "EnemyStunThreshold", --备注：enemy stun threshold
	["敌人被晕眩时间"] = "EnemyStunDuration", --备注：stun duration on enemies
	["晕眩时间"] = "EnemyStunDuration", --备注：stun duration
	["to knock enemies back on hit"] = "EnemyKnockbackChance",
	["击退距离"] = "EnemyKnockbackDistance", --备注：knockback distance
	-- Auras/curses/buffs
	["非诅咒类光环的效果"] = "AuraEffect", --备注：aura effect
	["effect of non-curse auras you cast"] = { "AuraEffect", tagList = { { type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } } },
	["effect of non-curse auras from your skills"] = { "AuraEffect", tagList = { { type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } } },
	["effect of non-curse auras from your skills on your minions"] = { "AuraEffectOnSelf", tagList = { { type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } }, addToMinion = true },
	["effect of non-curse auras"] = { "AuraEffect", tag = { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } },	
	["你所施放诅咒的效果"] = "CurseEffect", --备注：effect of your curses
	["你身上的光环效果"] = "AuraEffectOnSelf", --备注：effect of auras on you
	["召唤生物身上的光环效果"] = { "AuraEffectOnSelf", addToMinion = true }, --备注：effect of auras on your minions
	["诅咒效果"] = "CurseEffect", --备注：curse effect
	["诅咒持续时间"] = { "Duration", keywordFlags = KeywordFlag.Curse }, --备注：curse duration
	["光环技能范围"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Aura }, --备注：radius of auras
	["诅咒范围"] = { "AreaOfEffect", keywordFlags = KeywordFlag.Curse }, --备注：radius of curses
	["buff effect"] = "BuffEffect",
	["你身上的增益效果"] = "BuffEffectOnSelf", --备注：effect of buffs on you
	["魔像的增益效果"] = { "BuffEffect", tag = { type = "SkillType", skillType = SkillType.Golem } }, --备注：effect of buffs granted by your golems
	["effect of buffs granted by socketed golem skills"] = { "BuffEffect", addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "golem" } },
	["effect of the buff granted by your stone golems"] = { "BuffEffect", tag = { type = "SkillName", skillName = "召唤巨石魔像" } },
	["effect of the buff granted by your lightning golems"] = { "BuffEffect", tag = { type = "SkillName", skillName = "召唤闪电魔像" } },
	["effect of the buff granted by your ice golems"] = { "BuffEffect", tag = { type = "SkillName", skillName = "召唤寒冰魔像" } },
	["effect of the buff granted by your flame golems"] = { "BuffEffect", tag = { type = "SkillName", skillName = "召唤烈焰魔像" } },
	["effect of the buff granted by your chaos golems"] = { "BuffEffect", tag = { type = "SkillName", skillName = "召唤混沌魔像" } },
	["effect of offering spells"] = { "BuffEffect", tag = { type = "SkillName", skillNameList = { "Bone Offering", "Flesh Offering", "Spirit Offering" } } },
	["你身上的捷增益效果"] = { "BuffEffect", tag = { type = "SkillType", skillType = SkillType.Herald } }, --备注：effect of heralds on you
	["战吼的增益效果"] = { "BuffEffect", keywordFlags = KeywordFlag.Warcry }, --备注：warcry effect
	["【鸟之势】增益效果"] = { "BuffEffect", tag = { type = "SkillName", skillName = "鸟之势" } }, --备注：aspect of the avian buff effect
	-- Charges
	["暴击球数量上限"] = "PowerChargesMax", --备注：maximum power charge
	["暴击球数量上限"] = "PowerChargesMax", --备注：maximum power charges
	["暴击球的持续时间"] = "PowerChargesDuration", --备注：power charge duration
	["狂怒球数量上限"] = "FrenzyChargesMax", --备注：maximum frenzy charge
	["狂怒球数量上限"] = "FrenzyChargesMax", --备注：maximum frenzy charges
	["狂怒球持续时间"] = "FrenzyChargesDuration", --备注：frenzy charge duration
	["耐力球数量上限"] = "EnduranceChargesMax", --备注：maximum endurance charge
	["耐力球数量上限"] = "EnduranceChargesMax", --备注：maximum endurance charges
	["耐力球持续时间"] = "EnduranceChargesDuration", --备注：endurance charge duration
	["狂怒球和暴击球数量上限"] = { "FrenzyChargesMax", "PowerChargesMax" }, --备注：maximum frenzy charges and maximum power charges
	["狂怒球数量上限和暴击球数量上限"] = { "FrenzyChargesMax", "PowerChargesMax" }, --备注：maximum frenzy charges and maximum power charges
	["耐力球，狂怒球，以及暴击球的持续时间"] = { "PowerChargesDuration", "FrenzyChargesDuration", "EnduranceChargesDuration" }, --备注：endurance, frenzy and power charge duration
	["最大轮回球"] = "SiphoningChargesMax", --备注：maximum siphoning charge
	["最大轮回球"] = "SiphoningChargesMax", --备注：maximum siphoning charges
	["【深海屏障】数量上限"] = "CrabBarriersMax", --备注：maximum number of crab barriers
	-- On hit/kill/leech effects
	["life gained on kill"] = "LifeOnKill",
	["mana gained on kill"] = "ManaOnKill",
	["life gained for each enemy hit"] = { "LifeOnHit" },
	["life gained for each enemy hit by attacks"] = { "LifeOnHit", flags = ModFlag.Attack },
	["life gained for each enemy hit by your attacks"] = { "LifeOnHit", flags = ModFlag.Attack },
	["life gained for each enemy hit by spells"] = { "LifeOnHit", flags = ModFlag.Spell },
	["life gained for each enemy hit by your spells"] = { "LifeOnHit", flags = ModFlag.Spell },
	["mana gained for each enemy hit by attacks"] = { "ManaOnHit", flags = ModFlag.Attack },
	["mana gained for each enemy hit by your attacks"] = { "ManaOnHit", flags = ModFlag.Attack },
	["energy shield gained for each enemy hit"] = { "EnergyShieldOnHit" },
	["energy shield gained for each enemy hit by attacks"] = { "EnergyShieldOnHit", flags = ModFlag.Attack },
	["energy shield gained for each enemy hit by your attacks"] = { "EnergyShieldOnHit", flags = ModFlag.Attack },
	["life and mana gained for each enemy hit"] = { "LifeOnHit", "ManaOnHit", flags = ModFlag.Attack },
	["damage as life"] = "DamageLifeLeech",
	["每秒生命偷取"] = "LifeLeechRate", --备注：life leeched per second
	["每秒魔力偷取"] = "ManaLeechRate", --备注：mana leeched per second
	["最大生命偷取率"] = "MaxLifeLeechRate", --备注：maximum life per second to maximum life leech rate
	["最大魔力偷取率"] = "MaxManaLeechRate", --备注：maximum mana per second to maximum mana leech rate
	-- Projectile modifiers
	["投射物"] = "ProjectileCount", --备注：projectile
	["投射物"] = "ProjectileCount", --备注：projectiles
	["投射物速度"] = "ProjectileSpeed", --备注：projectile speed
	["箭矢速度"] = { "ProjectileSpeed", flags = ModFlag.Bow }, --备注：arrow speed
	-- Totem/trap/mine modifiers
	["图腾放置速度"] = "TotemPlacementSpeed", --备注：totem placement speed
	["图腾的生命"] = "TotemLife", --备注：totem life
	["图腾的持续时间"] = "TotemDuration", --备注：totem duration
	["陷阱投掷速度"] = "TrapThrowingSpeed", --备注：trap throwing speed
	["陷阱触发范围"] = "TrapTriggerAreaOfEffect", --备注：trap trigger area of effect
	["陷阱持续时间"] = "TrapDuration", --备注：trap duration
	["陷阱冷却回复速度"] = { "CooldownRecovery", keywordFlags = KeywordFlag.Trap }, --备注：cooldown recovery speed for throwing traps
	["地雷放置速度"] = "MineLayingSpeed", --备注：mine laying speed
	["地雷引爆范围"] = "MineDetonationAreaOfEffect", --备注：mine detonation area of effect
	["地雷持续时间"] = "MineDuration", --备注：mine duration
	-- Minion modifiers
	["魔侍数量上限"] = "ActiveSkeletonLimit", --备注：maximum number of skeletons
	["魔卫数量上限"] = "ActiveZombieLimit", --备注：maximum number of zombies
	["魔卫数量上限"] = "ActiveZombieLimit", --备注：number of zombies allowed
	["灵体数量上限"] = "ActiveSpectreLimit", --备注：maximum number of spectres
	["魔像数量上限"] = "ActiveGolemLimit", --备注：maximum number of golems
	["maximum number of summoned golems"] = "ActiveGolemLimit",
	["召唤愤怒狂灵的最大数量"] = "ActiveRagingSpiritLimit", --备注：maximum number of summoned raging spirits
	["召唤生物持续时间"] = { "Duration", tag = { type = "SkillType", skillType = SkillType.CreateMinion } }, --备注：minion duration
	["魔侍的持续时间"] = { "Duration", tag = { type = "SkillName", skillName = "召唤魔侍" } }, --备注：skeleton duration
	-- Other skill modifiers
	["半径"] = "AreaOfEffect", --备注：radius
	["radius of area skills"] = "AreaOfEffect",
	["area of effect radius"] = "AreaOfEffect",
	["范围效果"] = "AreaOfEffect", --备注：area of effect
	["效果区域"] = "AreaOfEffect", --备注：area of effect
	["area of effect of skills"] = "AreaOfEffect",
	["area of effect of area skills"] = "AreaOfEffect",
	["【蛛之势】的范围效果"] = { "AreaOfEffect", tag = { type = "SkillName", skillName = "蛛之势" } }, --备注：aspect of the spider area of effect
	["firestorm explosion area of effect"] = { "AreaOfEffectSecondary", tag = { type = "SkillName", skillName = "烈炎风暴" } },
	["持续时间"] = "Duration", --备注：duration
	["技能效果持续时间"] = "Duration", --备注：skill effect duration
	["混沌技能效果持续时间"] = { "Duration", keywordFlags = KeywordFlag.Chaos }, --备注：chaos skill effect duration
	["【蛛之势】的减益持续时间"] = { "Duration", tag = { type = "SkillName", skillName = "蛛之势" } }, --备注：aspect of the spider debuff duration
	["fire trap burning ground duration"] = { "Duration", tag = { type = "SkillName", skillName = "火焰陷阱" } },
	["冷却速度"] = "CooldownRecovery", --备注：cooldown recovery
	["冷却回复速度"] = "CooldownRecovery", --备注：cooldown recovery speed
	["weapon range"] = "WeaponRange",
	["近战攻击范围"] = "MeleeWeaponRange", --备注：melee weapon range
	["近战与空手范围"] = { "MeleeWeaponRange", "UnarmedRange" }, --备注：melee weapon and unarmed range
	["近战与空手攻击范围"] = { "MeleeWeaponRange", "UnarmedRange" }, --备注：melee weapon and unarmed attack range
	["to deal double damage"] = "DoubleDamageChance",
	-- Buffs
	["【猛攻】效果"] = "OnslaughtEffect", --备注：onslaught effect
	["护体效果持续时间"] = "FortifyDuration", --备注：fortify duration
	["护体持续时间"] = "FortifyDuration", --备注：fortify duration
	["你身上的护体效果"] = "FortifyEffectOnSelf", --备注：effect of fortify on you
	["effect of tailwind on you"] = "TailwindEffectOnSelf",
	["【灌注】效果"] = "InfusionEffect",
	-- Basic damage types
	["伤害"] = "Damage", --备注：damage
	["物理伤害"] = "PhysicalDamage", --备注：physical damage
	["闪电伤害"] = "LightningDamage", --备注：lightning damage
	["冰霜伤害"] = "ColdDamage", --备注：cold damage
	["火焰伤害"] = "FireDamage", --备注：fire damage
	["混沌伤害"] = "ChaosDamage", --备注：chaos damage
	["非混沌伤害"] = "NonChaosDamage", --备注：non-chaos damage
	["火焰、冰霜、闪电伤害"] = "ElementalDamage", --备注：elemental damage
	-- Other damage forms
	["攻击伤害"] = { "Damage", flags = ModFlag.Attack }, --备注：attack damage
	["攻击物理伤害"] = { "PhysicalDamage", flags = ModFlag.Attack }, --备注：attack physical damage
	["物理攻击伤害"] = { "PhysicalDamage", flags = ModFlag.Attack }, --备注：physical attack damage
	["武器的物理伤害"] = { "PhysicalDamage", flags = ModFlag.Weapon }, --备注：physical weapon damage
	["武器上的*+物理伤害"] = { "PhysicalDamage", flags = ModFlag.Weapon }, --备注：physical damage with weapons
	["物理近战伤害"] = { "PhysicalDamage", flags = ModFlag.Melee }, --备注：physical melee damage
	["近战物理伤害"] = { "PhysicalDamage", flags = ModFlag.Melee }, --备注：melee physical damage
	["投射物伤害"] = { "Damage", flags = ModFlag.Projectile }, --备注：projectile damage
	["投射物攻击伤害"] = { "Damage", flags = bor(ModFlag.Projectile, ModFlag.Attack) }, --备注：projectile attack damage
	["bow damage"] = { "Damage", flags = ModFlag.Bow },
	["damage with arrow hits"] = { "Damage", flags = bor(ModFlag.Bow, ModFlag.Hit) },
	["wand damage"] = { "Damage", flags = ModFlag.Wand },
	["法杖物理伤害"] = { "PhysicalDamage", flags = ModFlag.Wand }, --备注：wand physical damage
	["爪物理伤害"] = { "PhysicalDamage", flags = ModFlag.Claw }, --备注：claw physical damage
	["sword physical damage"] = { "PhysicalDamage", flags = ModFlag.Sword },
	["持续伤害效果"] = { "Damage", flags = ModFlag.Dot }, --备注：damage over time
	["物理持续伤害"] = { "PhysicalDamage", keywordFlags = KeywordFlag.PhysicalDot }, --备注：physical damage over time
	["燃烧伤害"] = { "FireDamage", keywordFlags = KeywordFlag.FireDot }, --备注：burning damage
	["点燃伤害"] = { "Damage", keywordFlags = KeywordFlag.Ignite }, --备注：damage with ignite
	["damage with ignites"] = { "Damage", keywordFlags = KeywordFlag.Ignite },
	["incinerate damage for each stage"] = { "Damage", tagList = { { type = "Multiplier", var = "IncinerateStage" }, { type = "SkillName", skillName = "烧毁" } } },
	-- Crit/accuracy/speed modifiers
	["暴击率"] = "CritChance", --备注：critical strike chance
	["攻击暴击率"] = { "CritChance", flags = ModFlag.Attack }, --备注：attack critical strike chance
	["暴击伤害加成"] = "CritMultiplier", --备注：critical strike multiplier
	["命中值"] = "Accuracy", --备注：accuracy
	["攻击命中值"] = "Accuracy", --备注：accuracy rating
	["minion accuracy rating"] = { "Accuracy", addToMinion = true },
	["攻击速度"] = { "Speed", flags = ModFlag.Attack }, --备注：attack speed
	["施法速度"] = { "Speed", flags = ModFlag.Cast }, --备注：cast speed
	["攻击和施法速度"] = "Speed", --备注：attack and cast speed
	-- Elemental ailments
	["闪电伤害击中时有 ([%+%-]?%d+)%% 几率使敌人受到感电效果影响"] = "EnemyShockChance", --备注：to shock
	["shock chance"] = "EnemyShockChance",
	["使用冰霜伤害击中时冰冻敌人"] = "EnemyFreezeChance", --备注：to freeze
	["freeze chance"] = "EnemyFreezeChance",
	["点燃"] = "EnemyIgniteChance", --备注：to ignite
	["ignite chance"] = "EnemyIgniteChance",
	["使敌人受到冰冻，感电与点燃"] = { "EnemyFreezeChance", "EnemyShockChance", "EnemyIgniteChance" }, --备注：to freeze, shock and ignite
	["感电效果"] = "EnemyShockEffect", --备注：effect of shock
	["冰缓效果"] = "EnemyChillEffect", --备注：effect of chill
	["你受到的冰缓效果"] = "SelfChillEffect", --备注：effect of chill on you
	["对敌人施加的非伤害性异常状态效果的伤害"] = { "EnemyShockEffect", "EnemyChillEffect", "EnemyFreezeEffech", "EnemyScorchEffect", "EnemyBrittleEffect", "EnemySapEffect"  }, --备注：effect of non-damaging ailments
	["敌人的感电持续时间"] = "EnemyShockDuration", --备注：shock duration
	["敌人被冰冻的持续时间"] = "EnemyFreezeDuration", --备注：freeze duration
	["敌人被冰缓的持续时间"] = "EnemyChillDuration", --备注：chill duration
	["敌人被点燃的持续时间"] = "EnemyIgniteDuration", --备注：ignite duration
	["敌人受到的元素异常状态时间"] = { "EnemyShockDuration", "EnemyFreezeDuration", "EnemyChillDuration", "EnemyIgniteDuration" , "EnemyScorchDuration", "EnemyBrittleDuration", "EnemySapDuration" }, --备注：duration of elemental ailments
	["duration of elemental status ailments"] = { "EnemyShockDuration", "EnemyFreezeDuration", "EnemyChillDuration", "EnemyIgniteDuration" , "EnemyScorchDuration", "EnemyBrittleDuration", "EnemySapDuration" },
	["duration of ailments"] = { "EnemyShockDuration", "EnemyFreezeDuration", "EnemyChillDuration", "EnemyIgniteDuration", "EnemyPoisonDuration", "EnemyBleedDuration" , "EnemyScorchDuration", "EnemyBrittleDuration", "EnemySapDuration" },
	-- Other ailments
	["to poison"] = "PoisonChance",
	["to cause poison"] = "PoisonChance",
	["使敌人中毒"] = "PoisonChance", --备注：to poison on hit
	["中毒持续时间"] = { "EnemyPoisonDuration" }, --备注：poison duration
	["duration of poisons you inflict"] = { "EnemyPoisonDuration" },
	["使敌人流血"] = "BleedChance", --备注：to cause bleeding
	["导致流血"] = "BleedChance", --备注：to cause bleeding
	["to inflict bleeding"] = "BleedChance",
	["to cause bleeding on hit"] = "BleedChance",
	["流血持续时间"] = { "EnemyBleedDuration" }, --备注：bleed duration
	["bleeding duration"] = { "EnemyBleedDuration" },
	-- Misc modifiers
	["移动速度"] = "MovementSpeed", --备注：movement speed
	["攻击，施法和移动速度"] = { "Speed", "MovementSpeed" }, --备注：attack, cast and movement speed
	["照亮范围"] = "LightRadius", --备注：light radius
	["物品稀有度"] = "LootRarity", --备注：rarity of items found
	["物品掉落数量"] = "LootQuantity", --备注：quantity of items found
	["item quantity"] = "LootQuantity",
	["力量需求"] = "StrRequirement", --备注：strength requirement
	["dexterity requirement"] = "DexRequirement",
	["智慧需求"] = "IntRequirement", --备注：intelligence requirement
	["属性需求"] = { "StrRequirement", "DexRequirement", "IntRequirement" }, --备注：attribute requirements
	["插槽内的珠宝效果"] = "SocketedJewelEffect", --备注：effect of socketed jewels
	-- Flask modifiers
	-- ["效果"] = "FlaskEffect", --备注：effect
	["effect of flasks"] = "FlaskEffect",
	["药剂效果"] = "FlaskEffect", --备注：effect of flasks on you
	["回复量"] = "FlaskRecovery", --备注：amount recovered
	["life recovered"] = "FlaskRecovery",
	["mana recovered"] = "FlaskRecovery",
	["药剂回复的生命"] = "FlaskLifeRecovery", --备注：life recovery from flasks
	["药剂回复的魔力"] = "FlaskManaRecovery", --备注：mana recovery from flasks
	["药剂持续时间"] = "FlaskDuration", --备注：flask effect duration
	["回复速度"] = "FlaskRecoveryRate", --备注：recovery speed
	["recovery rate"] = "FlaskRecoveryRate",
	["flask recovery rate"] = "FlaskRecoveryRate",
	["药剂的回复速度"] = "FlaskRecoveryRate", --备注：flask recovery speed
	["药剂生命回复速度"] = "FlaskLifeRecoveryRate", --备注：flask life recovery rate
	["药剂魔力回复速度"] = "FlaskManaRecoveryRate", --备注：flask mana recovery rate
	["extra charges"] = "FlaskCharges",
	["maximum charges"] = "FlaskCharges",
	["药剂充能消耗"] = "FlaskChargesUsed", --备注：charges used
	["药剂充能使用"] = "FlaskChargesUsed", --备注：flask charges used
	["药剂充能获取"] = "FlaskChargesGained", --备注：flask charges gained
	["充能回复"] = "FlaskChargeRecovery", --备注：charge recovery
}

-- List of modifier flags
local modFlagList = {
	--【中文化程序额外添加开始】
	["锤类和短杖攻击的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["锤类和短杖类攻击的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["锤类和短杖类的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["锤类和短杖类攻击"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["锤类和短杖类"] = {flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["锤类和短杖攻击"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["锤类和短杖的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["锤类和短杖"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["持锤或短杖时，"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["锤类或短杖攻击"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["身体护甲提供的"] = { tag = { type = "SlotName", slotName = "Body Armour" } },
	["混沌技能的"] = { keywordFlags = KeywordFlag.Chaos },
	["单手武器攻击的"] = { flags = bor(ModFlag.Weapon1H, ModFlag.Hit)}, --备注：with one handed weapons
	["斧类攻击"] =  { flags = bor(ModFlag.Axe, ModFlag.Hit) },
	["弓类攻击"] =  { flags = bor(ModFlag.Bow, ModFlag.Hit) },
	["弓类技能的"] = { keywordFlags = KeywordFlag.Bow },
	["爪类攻击"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["匕首攻击"] =  { flags = bor(ModFlag.Dagger, ModFlag.Hit) },
	["锤类攻击"] = { flags = bor(ModFlag.Mace, ModFlag.Hit)  },
	["长杖攻击时，"] =  { flags = bor(ModFlag.Staff, ModFlag.Hit) },
	["长杖攻击"] =  { flags = bor(ModFlag.Staff, ModFlag.Hit) },
	["剑类攻击"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["剑攻击造成的"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["剑攻击"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["法杖攻击"] = { flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["弓类的"] =  { flags = bor(ModFlag.Bow, ModFlag.Hit) },
	["爪类的"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["爪类"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["匕首的"] =  { flags = bor(ModFlag.Dagger, ModFlag.Hit) },
	["锤类的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["长杖的"] =  { flags = bor(ModFlag.Staff, ModFlag.Hit) },
	["斧类的"] =  { flags = bor(ModFlag.Axe, ModFlag.Hit) },
	["剑类的"] ={ flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["法杖的"] =  { flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["攻击类技能"] = { keywordFlags = KeywordFlag.Attack },
	["攻击类技能造成的异常状态"] = { flags = ModFlag.Ailment, keywordFlags = KeywordFlag.Attack }, --备注：with ailments from attack skills
	["双手近战武器攻击造成的"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) }, --备注：with two handed melee weapons
	["双手近战武器的"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) }, --备注：with two handed melee weapons
	["攻击技能的"] ={ tag = { type = "SkillType", skillType = SkillType.Attack } },
	["攻击技能可使"] ={ tag = { type = "SkillType", skillType = SkillType.Attack } },
	["图腾施放的技能"] = { keywordFlags = KeywordFlag.Totem }, --备注：with totem skills
	["近战攻击"] = { flags = ModFlag.Melee }, --备注：melee
	["近战技能的"] = { flags = ModFlag.Melee },
	["近战单手武器的"] = { flags = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee, ModFlag.Hit) }, --备注：with one handed melee weapons
	["弓类攻击造成的"] =  { flags = bor(ModFlag.Bow, ModFlag.Hit) },
	["攻击技能造成的"] ={ tag = { type = "SkillType", skillType = SkillType.Attack } },
	["持续吟唱技能造成的"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["持续吟唱技能"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["持续吟唱技能的"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["该装备 "] = { },
	["在低血时，"] = { tag = { type = "Condition", var = "LowLife" } },
	["低血时，"] = { tag = { type = "Condition", var = "LowLife" } }, --备注：wh[ie][ln]e? on low life
	["击中和异常状态的"] = { keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment) }, --备注：with hits and ailments
	["攻击技能可以"] = { tag = { type = "SkillType", skillType = SkillType.Attack } }, --备注：with attack skills
	["攻击时"] = { keywordFlags = KeywordFlag.Attack }, 
	["复苏的魔卫"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魔卫复苏" } },
	["魔卫"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魔卫复苏" } }, --备注：zombie
	["魔侍的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤魔侍" } }, --备注：skeleton
	["移动技能的"] = { keywordFlags = KeywordFlag.Movement }, --备注：with movement skills
	["持弓"] =  { flags = bor(ModFlag.Bow, ModFlag.Hit) },
	["弓"] =  { flags = bor(ModFlag.Bow, ModFlag.Hit) }, --备注：to bow attacks
	["攻击"] = { flags = ModFlag.Attack }, 
	["剑类"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["剑"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["匕首"] = { flags = bor(ModFlag.Dagger, ModFlag.Hit) },
	["长杖"] =  { flags = bor(ModFlag.Staff, ModFlag.Hit) },
	["法杖"] =  { flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["锤"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["爪类"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["爪"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["斧类"] =  { flags = bor(ModFlag.Axe, ModFlag.Hit) },
	["斧"] =  { flags = bor(ModFlag.Axe, ModFlag.Hit) },
	["捷技能的"] = { tag = { type = "SkillType", skillType = SkillType.Herald } }, 
	["近战单手武器攻击"] = { flags = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee, ModFlag.Hit) }, 
	["双手近战武器的攻击"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) },
	["火焰、冰霜、闪电技能的"] = { keywordFlags = bor(KeywordFlag.Lightning, KeywordFlag.Cold, KeywordFlag.Fire) },
	["元素技能的"] = { keywordFlags = bor(KeywordFlag.Lightning, KeywordFlag.Cold, KeywordFlag.Fire) },
	["烙印技能的"] ={ tag = { type = "SkillType", skillType = SkillType.Brand } },
	["烙印的"] = { tag = { type = "SkillType", skillType = SkillType.Brand } },
	["烙印"] = { tag = { type = "SkillType", skillType = SkillType.Brand } },
	["烙印技能"] = { tag = { type = "SkillType", skillType = SkillType.Brand } },
	["异常状态"] = { flags = ModFlag.Ailment },
	["闪电技能的"] = { keywordFlags = KeywordFlag.Lightning }, --备注：with lightning skills
	["冰霜技能的"] = { keywordFlags = KeywordFlag.Cold }, --备注：with cold skills
	["火焰技能的"] = { keywordFlags = KeywordFlag.Fire }, --备注：with fire skills
	["诅咒技能的"] = { keywordFlags = KeywordFlag.Curse }, 
	["元素技能"] = { keywordFlags = bor(KeywordFlag.Lightning, KeywordFlag.Cold, KeywordFlag.Fire) }, 
	["攻击造成的"] = { flags = ModFlag.Attack }, 
	["武器的"] = { flags = ModFlag.Weapon }, 
	["双手近战武器攻击"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) }, 
	["从盾牌获取的"] = { tag = { type = "SlotName", slotName = "Weapon 2" } }, 
	["盾牌获取的"] = { tag = { type = "SlotName", slotName = "Weapon 2" } }, 
	["地雷类技能造成的"] = { keywordFlags = KeywordFlag.Mine },
	["投掷地雷的技能"] = { keywordFlags = KeywordFlag.Mine },
	["投掷地雷的"] = { keywordFlags = KeywordFlag.Mine },
	["地雷类技能的"] = { keywordFlags = KeywordFlag.Mine },
	["投掷陷阱的"] = { keywordFlags = KeywordFlag.Trap },
	["爪的"] ={ flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["锤, 短杖或长杖攻击时，"] = { flags = ModFlag.Hit, tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Mace, ModFlag.Staff) } },
	["爪或匕首攻击时，"] = { flags = ModFlag.Hit, tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } },
	["吟唱技能的"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["弓技能的"] = { keywordFlags = KeywordFlag.Bow },
	["魔蛊技能的"] = { tag = { type = "SkillType", skillType = SkillType.Hex } },
		["魔蛊的"] = { tag = { type = "SkillType", skillType = SkillType.Hex } },
		["魔蛊技能"] = { tag = { type = "SkillType", skillType = SkillType.Hex } },
	["咒印技能的"] = { tag = { type = "SkillType", skillType = SkillType.Mark } },
	["咒印的"] = { tag = { type = "SkillType", skillType = SkillType.Mark } },
	["咒印技能"] = { tag = { type = "SkillType", skillType = SkillType.Mark } },
	["诅咒光环技能的"] = { tag = { type = "SkillType", skillType = SkillType.Aura }, keywordFlags = KeywordFlag.Curse },
		["诅咒光环的"] = { keywordFlags = bor(KeywordFlag.Curse, KeywordFlag.Aura, KeywordFlag.MatchAll) },
	["锤类或短杖"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },	
	--【中文化程序额外添加结束】
	["斧类攻击的"] = { flags = bor(ModFlag.Axe, ModFlag.Hit) }, --备注：with axes
	["to axe attacks"] = { flags = bor(ModFlag.Axe, ModFlag.Hit) },
	["with axes or swords"] = { flags = ModFlag.Hit, tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) } },
	["弓类攻击的"] = { flags = bor(ModFlag.Bow, ModFlag.Hit) }, --备注：with bows
	["弓攻击"] = { flags = bor(ModFlag.Bow, ModFlag.Hit) }, --备注：to bow attacks
	["爪类攻击的"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) }, --备注：with claws
	["with claws or daggers"] = { flags = ModFlag.Hit, tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } },
	["to claw attacks"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["dealt with claws"] = { flags = bor(ModFlag.Claw, ModFlag.Hit) },
	["匕首攻击的"] = { flags = bor(ModFlag.Dagger, ModFlag.Hit) }, --备注：with daggers
	["to dagger attacks"] = { flags = bor(ModFlag.Dagger, ModFlag.Hit) },
	["锤类攻击的"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) }, --备注：with maces
	["to mace attacks"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["with maces and sceptres"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["with maces or sceptres"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["with maces, sceptres or staves"] = { flags = ModFlag.Hit, tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Mace, ModFlag.Staff) } },
	["to mace and sceptre attacks"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["to mace or sceptre attacks"] = { flags = bor(ModFlag.Mace, ModFlag.Hit) },
	["长杖攻击的"] = { flags = bor(ModFlag.Staff, ModFlag.Hit) }, --备注：with staves
	["to staff attacks"] = { flags = bor(ModFlag.Staff, ModFlag.Hit) },
	["剑类攻击的"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) }, --备注：with swords
	["to sword attacks"] = { flags = bor(ModFlag.Sword, ModFlag.Hit) },
	["法杖攻击的"] = { flags = bor(ModFlag.Wand, ModFlag.Hit) }, --备注：with wands
	["to wand attacks"] = { flags = bor(ModFlag.Wand, ModFlag.Hit) },
	["空手攻击时"] = { flags = bor(ModFlag.Unarmed, ModFlag.Hit) }, --备注：unarmed
	["空手攻击时的"] = { flags = bor(ModFlag.Unarmed, ModFlag.Hit) }, --备注：with unarmed attacks
	["to unarmed attacks"] = { flags = bor(ModFlag.Unarmed, ModFlag.Hit) },
	["单手武器的"] = { flags = bor(ModFlag.Weapon1H, ModFlag.Hit) }, --备注：with one handed weapons
	["近战单手武器攻击的"] = { flags = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee, ModFlag.Hit) }, --备注：with one handed melee weapons
	["双手武器的"] = { flags = bor(ModFlag.Weapon2H, ModFlag.Hit) }, --备注：with two handed weapons
	["双手近战武器攻击的"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee, ModFlag.Hit) }, --备注：with two handed melee weapons
	["远程武器攻击的"] = { flags = bor(ModFlag.WeaponRanged, ModFlag.Hit) }, --备注：with ranged weapons
	-- Skill types
	["法术"] = { flags = ModFlag.Spell }, --备注：spell
	["with spells"] = { flags = ModFlag.Spell },
	["for spells"] = { flags = ModFlag.Spell },
	["with attacks"] = { keywordFlags = KeywordFlag.Attack },
	["攻击技能"] = { keywordFlags = KeywordFlag.Attack }, --备注：with attack skills
	["for attacks"] = { flags = ModFlag.Attack },
	["武器"] = { flags = ModFlag.Weapon }, --备注：weapon
	["武器造成的"] = { flags = ModFlag.Weapon }, --备注：with weapons
	["近战"] = { flags = ModFlag.Melee }, --备注：melee
	["with melee attacks"] = { flags = ModFlag.Melee },
	["with melee critical strikes"] = { flags = ModFlag.Melee, tag = { type = "Condition", var = "CriticalStrike" } },
	["with bow skills"] = { keywordFlags = KeywordFlag.Bow },
	["近战攻击击中后"] = { flags = ModFlag.Melee }, --备注：on melee hit
	["击中"] = { keywordFlags = KeywordFlag.Hit }, --备注：with hits
	["击中和异常状态"] = { keywordFlags = bor(KeywordFlag.Hit, KeywordFlag.Ailment) }, --备注：with hits and ailments
	["with ailments"] = { flags = ModFlag.Ailment },
	["攻击技能造成的异常状态"] = { flags = ModFlag.Ailment, keywordFlags = KeywordFlag.Attack }, --备注：with ailments from attack skills
	["中毒"] = { keywordFlags = KeywordFlag.Poison }, --备注：with poison
	["流血"] = { keywordFlags = KeywordFlag.Bleed }, --备注：with bleeding
	["范围"] = { flags = ModFlag.Area }, --备注：area
	["地雷"] = { keywordFlags = KeywordFlag.Mine }, --备注：mine
	["with mines"] = { keywordFlags = KeywordFlag.Mine },
	["陷阱"] = { keywordFlags = KeywordFlag.Trap }, --备注：trap
	["with traps"] = { keywordFlags = KeywordFlag.Trap },
	["for traps"] = { keywordFlags = KeywordFlag.Trap },
	["放置地雷或投掷陷阱类技能的"] = { keywordFlags = bor(KeywordFlag.Mine, KeywordFlag.Trap) }, --备注：that place mines or throw traps
	["图腾"] = { keywordFlags = KeywordFlag.Totem }, --备注：totem
	["图腾技能"] = { keywordFlags = KeywordFlag.Totem }, --备注：with totem skills
	["图腾使用技能的"] = { keywordFlags = KeywordFlag.Totem }, --备注：for skills used by totems
	["光环技能"] = { tag = { type = "SkillType", skillType = SkillType.Aura } }, --备注：of aura skills
	["诅咒技能"] = { keywordFlags = KeywordFlag.Curse }, --备注：of curse skills
	["捷技能"] = { tag = { type = "SkillType", skillType = SkillType.Herald } }, --备注：of herald skills
	["召唤生物技能"] = { tag = { type = "SkillType", skillType = SkillType.Minion } }, --备注：of minion skills
	["诅咒"] = { keywordFlags = KeywordFlag.Curse }, --备注：for curses
	["战吼"] = { keywordFlags = KeywordFlag.Warcry }, --备注：warcry
	["瓦尔"] = { keywordFlags = KeywordFlag.Vaal }, --备注：vaal
	["瓦尔技能"] = { keywordFlags = KeywordFlag.Vaal }, --备注：vaal skill
	["移动技能"] = { keywordFlags = KeywordFlag.Movement }, --备注：with movement skills
	["闪电技能"] = { keywordFlags = KeywordFlag.Lightning }, --备注：with lightning skills
	["冰霜技能"] = { keywordFlags = KeywordFlag.Cold }, --备注：with cold skills
	["火焰技能"] = { keywordFlags = KeywordFlag.Fire }, --备注：with fire skills
	["火焰、冰霜、闪电技能"] = { keywordFlags = bor(KeywordFlag.Lightning, KeywordFlag.Cold, KeywordFlag.Fire) }, --备注：with elemental skills
	["混沌技能"] = { keywordFlags = KeywordFlag.Chaos }, --备注：with chaos skills
	["引导技能"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } }, --备注：with channelling skills
	["魔卫"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魔卫复苏" } }, --备注：zombie
	["raised zombie"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魔卫复苏" } },
	["魔侍的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤魔侍" } }, --备注：skeleton
	["spectre"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤灵体" } },
	["raised spectre"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤灵体" } },
	["golem"] = { },
	["chaos golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤混沌魔像" } },
	["flame golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤烈焰魔像" } },
	["increased flame golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤烈焰魔像" } },
	["ice golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤寒冰魔像" } },
	["lightning golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤闪电魔像" } },
	["stone golem"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤巨石魔像" } },
	["animated guardian"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "幻化守卫" } },
	-- Other
	["全局"] = { tag = { type = "Global" } }, --备注：global
	["从盾牌获取的"] = { tag = { type = "SlotName", slotName = "Weapon 2" } }, --备注：from equipped shield
}

-- List of modifier flags/tags that appear at the start of a line
local preFlagList = {
	--【中文化程序额外添加开始】
	["^召唤生物有 "] = { addToMinion = true }, --备注：^minions [hd][ae][va][el] 
	["^攻击击中有"] = { flags = ModFlag.Attack },
	["^图腾有"] = { keywordFlags = KeywordFlag.Totem },
	["^【魔侍】造成的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤魔侍" } },
	["当你拥有兽化的召唤生物时，"] = { tag = { type = "Condition", var = "HaveBestialMinion" } },
	["召唤生物的"] = { addToMinion = true },
	["召唤生物"] = { addToMinion = true },
	["周围友军的"] = { newAura = true, newAuraOnlyAllies = true },
	["^你和队友的"] = { newAura = true },
	["^该装备的"] = { },
	["此武器攻击造成的"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, --备注：^attacks with this weapon [hd][ae][va][el] 
	["灵体的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤灵体" } }, --备注：^spectres [hd][ae][va][el] 
		["灵体的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤灵体" } },
	["魔像"] = { addToMinion = true, addToMinionTag = { type = "SkillType", skillType = SkillType.Golem } }, 
	["可使该武器的"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, 
	["^召唤圣物有"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤圣物" } },
	["^闪电法术的"] = { keywordFlags = KeywordFlag.Lightning, flags = ModFlag.Spell },
	["^冰霜法术的"] = { keywordFlags = KeywordFlag.Cold, flags = ModFlag.Spell },
	["^火焰法术的"] = { keywordFlags = KeywordFlag.Fire, flags = ModFlag.Spell },
	["^法术技能的"] = {  flags = ModFlag.Spell },
	["^位移技能的"] = { type = "SkillType", skillType = SkillType.MovementSkill },
	["^持续吟唱技能造成的"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["^持续吟唱技能的"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["^持续吟唱技能"] = { tag = { type = "SkillType", skillType = SkillType.Channelled } },
	["地雷所使用的技能"] = { keywordFlags = KeywordFlag.Mine },
	["^你和友军受你的光环技能影响时，"] = { affectedByAura = true },
	["^防卫技能的"] = { tag = { type = "SkillType", skillType = SkillType.GuardSkill } },
	-- Weapon types
		["^斧攻击造成的"] = { flags = ModFlag.Axe },
		["^斧类攻击造成的"] = { flags = ModFlag.Axe },
		["^斧或剑攻击造成的"] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) } },
		["^斧类或剑类攻击造成的"] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) } },
		["^斧类或剑类的"] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) } },
		["^弓攻击造成的"] = { flags = ModFlag.Bow },
		["^爪类攻击造成的"] = { flags = ModFlag.Claw },
		["^爪攻击造成的"] = { flags = ModFlag.Claw },
		["^爪或匕首攻击造成的"] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } },
		["^匕首攻击造成的"] = { flags = ModFlag.Dagger },
		["^锤类或短杖的"] = { flags = ModFlag.Mace },
		["^锤或短杖攻击造成的"] = { flags = ModFlag.Mace },
		["^锤类或短杖攻击造成的"] = { flags = ModFlag.Mace },
		["^锤, 短杖或长杖攻击造成的"] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Mace, ModFlag.Staff) } },
		["^长杖攻击造成的"] = { flags = ModFlag.Staff },
		["^剑攻击造成的"] = { flags = ModFlag.Sword },
		["^剑类攻击造成的"] = { flags = ModFlag.Sword },
		["^法杖攻击造成的"] = { flags = ModFlag.Wand },
		["^空手攻击造成的"] = { flags = ModFlag.Unarmed },
		["^单手武器攻击造成的"] = { flags = ModFlag.Weapon1H },
		["^双手武器攻击造成的"] = { flags = ModFlag.Weapon2H },
		["^近战武器攻击造成的"] = { flags = ModFlag.WeaponMelee },
		["^单手近战武器攻击造成的"] = { flags = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee) },
		["^双手近战武器攻击造成的"] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) },
		["^远程武器攻击造成的"] = { flags = ModFlag.WeaponRanged },
	["^技能被【法术节魔】辅助时，其"] = { tag = { type = "Condition", var = "SupportedBySpellslinger" } },
		-- Damage types
	--【中文化程序额外添加结束】
	-- Weapon types
	["^axe attacks [hd][ae][va][el] "] = { flags = ModFlag.Axe },
	["^axe or sword attacks [hd][ae][va][el] "] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) } },
	["^bow attacks [hd][ae][va][el] "] = { flags = ModFlag.Bow },
	["^claw attacks [hd][ae][va][el] "] = { flags = ModFlag.Claw },
	["^claw or dagger attacks [hd][ae][va][el] "] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } },
	["^dagger attacks [hd][ae][va][el] "] = { flags = ModFlag.Dagger },
	["^mace or sceptre attacks [hd][ae][va][el] "] = { flags = ModFlag.Mace },
	["^mace, sceptre or staff attacks [hd][ae][va][el] "] = { tag = { type = "ModFlagOr", modFlags = bor(ModFlag.Mace, ModFlag.Staff) } },
	["^staff attacks [hd][ae][va][el] "] = { flags = ModFlag.Staff },
	["^sword attacks [hd][ae][va][el] "] = { flags = ModFlag.Sword },
	["^wand attacks [hd][ae][va][el] "] = { flags = ModFlag.Wand },
	["^unarmed attacks [hd][ae][va][el] "] = { flags = ModFlag.Unarmed },
	["^attacks with one handed weapons [hd][ae][va][el] "] = { flags = ModFlag.Weapon1H },
	["^attacks with two handed weapons [hd][ae][va][el] "] = { flags = ModFlag.Weapon1H },
	["^attacks with melee weapons [hd][ae][va][el] "] = { flags = ModFlag.WeaponMelee },
	["^attacks with one handed melee weapons [hd][ae][va][el] "] = { flags = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee) },
	["^attacks with two handed melee weapons [hd][ae][va][el] "] = { flags = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee) },
	["^attacks with ranged weapons [hd][ae][va][el] "] = { flags = ModFlag.WeaponRanged },
	-- Damage types
	["^hits deal "] = { keywordFlags = KeywordFlag.Hit },
	["^critical strikes deal "] = { tag = { type = "Condition", var = "CriticalStrike" } },
	["^minions "] = { addToMinion = true },
	["^召唤生物的"] = { addToMinion = true }, --备注：^minions [hd][ae][va][el] 
	["召唤生物获得"] = { addToMinion = true }, --备注：^minions leech 
	["^minions' attacks deal "] = { addToMinion = true, flags = ModFlag.Attack },
	["魔像的"] = { addToMinion = true, addToMinionTag = { type = "SkillType", skillType = SkillType.Golem } }, --备注：^golems [hd][ae][va][el] 
	["魔像施放技能的"] = { tag = { type = "SkillType", skillType = SkillType.Golem } }, --备注：^golem skills have 
	["^zombies [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魔卫复苏" } },
	["【魔侍造成】的"] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤魔侍" } }, --备注：^skeletons [hd][ae][va][el] 
	["^raging spirits [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤愤怒狂灵" } },
	["^spectres [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤灵体" } },
	["^chaos golems [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤混沌魔像" } },
	["^flame golems [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤烈焰魔像" } },
	["^ice golems [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤寒冰魔像" } },
	["^lightning golems [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤闪电魔像" } },
	["^stone golems [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "召唤巨石魔像" } },
	["^blink arrow and blink arrow clones [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "闪现射击" } },
	["^mirror arrow and mirror arrow clones [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "魅影射击" } },
	["^animated weapons [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "幻化武器" } },
	["^animated guardians [hd][ae][va][el] "] = { addToMinion = true, addToMinionTag = { type = "SkillName", skillName = "幻化守卫" } },
	["^【复苏的魔卫】打出重击攻击时，"] = { addToMinion = true, tag = { type = "SkillId", skillId = "ZombieSlam" } }, --备注：^raised zombies' slam attack has 
	["^图腾所使用攻击的"] = { keywordFlags = KeywordFlag.Totem }, --备注：^attacks used by totems have 
	["^图腾所使用法术的"] = { keywordFlags = KeywordFlag.Totem }, --备注：^spells cast by totems have 
	["此武器攻击击中"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, --备注：^attacks with this weapon 
	["此武器的攻击"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, --备注：^attacks with this weapon [hd][ae][va][el] 
	["^该武器对"] = { flags = ModFlag.Hit, tag = { type = "Condition", var = "{Hand}Attack" } }, --备注：^hits with this weapon [hd][ae][va][el] 
	["^attacks [hd][ae][va][el] "] = { flags = ModFlag.Attack },
	["^attack skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Attack },
	["^spells [hd][ae][va][el] "] = { flags = ModFlag.Spell },
	["投射物攻击技能的"] = { tagList = { { type = "SkillType", skillType = SkillType.Attack }, { type = "SkillType", skillType = SkillType.Projectile } } }, --备注：^projectile attack skills [hd][ae][va][el] 
	["^arrows [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Bow },
	["^bow attacks [hdf][aei][var][el] "] = { keywordFlags = KeywordFlag.Bow },
	["^projectiles [hdf][aei][var][el] "] = { flags = ModFlag.Projectile },
	["^melee attacks have "] = { flags = ModFlag.Melee },
	["^movement attack skills have "] = { flags = ModFlag.Attack, keywordFlags = KeywordFlag.Movement },
	["^trap and mine damage "] = { keywordFlags = bor(KeywordFlag.Trap, KeywordFlag.Mine) },
	["陷阱所使用的技能"] = { keywordFlags = KeywordFlag.Trap }, --备注：^skills used by traps [hd][ae][va][el] 
	["^lightning skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Lightning },
	["^cold skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Cold },
	["^fire skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Fire },
	["^chaos skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Chaos },
	["^vaal skills [hd][ae][va][el] "] = { keywordFlags = KeywordFlag.Vaal },
	["^skills [hdfg][aei][vari][eln] "] = { },
	["^左戒指栏位："] = { tag = { type = "SlotNumber", num = 1 } }, --备注：^left ring slot: 
	["^右戒指栏位："] = { tag = { type = "SlotNumber", num = 2 } }, --备注：^right ring slot: 
	["^此物品上的技能石"] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}" } }, --备注：^socketed gems [hgd][ae][via][enl] 
	["插槽内的攻击技能获得"] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "attack" } }, --备注：^socketed attacks [hgd][ae][via][enl] 
	["插槽内的法术获得"] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "spell" } }, --备注：^socketed spells [hgd][ae][via][enl] 
	["此物品上的诅咒技能石"] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "curse" } }, --备注：^socketed curse gems [hgd][ae][via][enl] 
	["插槽内的的近战技能石"] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "melee" } }, --备注：^socketed melee gems [hgd][ae][via][enl] 
	["^socketed golem gems [hgd][ae][via][enl] "] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "golem" } },
	["^socketed golem skills [hgd][ae][via][enl] "] = { addToSkill = { type = "SocketedIn", slotName = "{SlotName}", keyword = "golem" } },
	["^your flasks grant "] = { },
	["^when hit, "] = { },
	["^you and allies [hgd][ae][via][enl] "] = { },
	["^auras from your skills grant "] = { addToAura = true },
	["你和周围队友的"] = { newAura = true }, --备注：^you and nearby allies [hgd][ae][via][enl] 
	["周围友军获得"] = { newAura = true, newAuraOnlyAllies = true }, --备注：^nearby allies [hgd][ae][via][enl] 
	["你和友军受你的光环技能影响时，"] = { affectedByAura = true }, --备注：^you and allies affected by your aura skills [hgd][ae][via][enl] 
	["^承受"] = { modSuffix = "Taken" }, --备注：^take 
	["^marauder: melee skills have "] = { flags = ModFlag.Melee, tag = { type = "Condition", var = "ConnectedToMarauderStart" } },
	["^duelist: "] = { tag = { type = "Condition", var = "ConnectedToDuelistStart" } },
	["^ranger: "] = { tag = { type = "Condition", var = "ConnectedToRangerStart" } },
	["^shadow: "] = { tag = { type = "Condition", var = "ConnectedToShadowStart" } },
	["^witch: "] = { tag = { type = "Condition", var = "ConnectedToWitchStart" } },
	["^templar: "] = { tag = { type = "Condition", var = "ConnectedToTemplarStart" } },
	["^scion: "] = { tag = { type = "Condition", var = "ConnectedToScionStart" } },
}

-- List of modifier tags
local modTagList = {
	--【中文化程序额外添加开始】
	["每 (%d+) 点护甲值可使"] = function(num) return { tag = { type = "PerStat", stat = "Armour", div = num } } end, 
	["持爪或匕首时，"] = { tag = { type = "Condition", varList ={ "UsingClaw", "UsingDagger" } } },
	["持锤, 短杖或长杖时，"] = { tag = { type = "Condition", varList = { "UsingMace", "UsingStaff" } } },
	["持锤, 短杖或长杖时"] = { tag = { type = "Condition", varList = { "UsingMace", "UsingStaff" } } },
	["盾牌上每有 (%d+) 能量护盾可获得  "] = function(num) return { tag = { type = "PerStat", stat = "EnergyShieldOnWeapon 2", div = num } } end,
	["每 (%d+)%% 的攻击格挡率会使"] = function(num) return { tag = { type = "PerStat", stat = "BlockChance", div = num } } end,
	["每 (%d+)%% 攻击伤害格挡几率"] = function(num) return { tag = { type = "PerStat", stat = "BlockChance", div = num } } end,
	["每 (%d+)%% 攻击伤害格挡几率会使"] = function(num) return { tag = { type = "PerStat", stat = "BlockChance", div = num } } end,
	["空手时攻击"] = { tag = { type = "Condition", var = "Unarmed" } }, 
	["当你拥有兽化的召唤生物时，"] = { tag = { type = "Condition", var = "HaveBestialMinion" } },
	["近期内你若造成非暴击伤害，则"] = { tag = { type = "Condition", var = "NonCritRecently" } }, --备注：if you[' ]h?a?ve dealt a non%-critical strike recently
	["近期内你若没有击败敌人，则伤害会"] = { tag = { type = "Condition", var = "KilledRecently", neg = true } }, 
	["持盾牌时造成的"] = { tag = { type = "Condition", var = "UsingShield" } },
	["持盾牌时，"] = { tag = { type = "Condition", var = "UsingShield" } }, --备注：while holding a shield
	["持盾时，"] = { tag = { type = "Condition", var = "UsingShield" } },
		["你的副手未装备武器时，"] = { tag = { type = "Condition", var = "OffHandIsEmpty" } }, --备注：while your off hand is empty
		["双持武器时，"] = { tag = { type = "Condition", var = "DualWielding" } },
		["双持武器时"] = { tag = { type = "Condition", var = "DualWielding" } },
		["双持时，"] = { tag = { type = "Condition", var = "DualWielding" } }, --备注：while dual wielding
		["双持攻击时"] = { tag = { type = "Condition", var = "DualWielding" } }, --备注：while dual wielding
		["双持攻击的"] = { tag = { type = "Condition", var = "DualWielding" } }, --备注：while dual wielding
		["双持攻击"] = { tag = { type = "Condition", var = "DualWielding" } },
		["双持爪时，"] = { tag = { type = "Condition", var = "DualWieldingClaws" } }, --备注：while dual wielding claws
		["持斧时，"] = { tag = { type = "Condition", var = "UsingAxe" } }, --备注：while wielding an axe
		["持弓时，"] = { tag = { type = "Condition", var = "UsingBow" } }, --备注：while wielding a bow
		["持爪时，"] = { tag = { type = "Condition", var = "UsingClaw" } }, --备注：while wielding a claw
		["持匕时，"] = { tag = { type = "Condition", var = "UsingDagger" } }, --备注：while wielding a dagger
		["持锤时，"] = { tag = { type = "Condition", var = "UsingMace" } }, --备注：while wielding a mace
		["持长杖时，"] = { tag = { type = "Condition", var = "UsingStaff" } }, --备注：while wielding a staff
		["持剑时，"] = { tag = { type = "Condition", var = "UsingSword" } }, --备注：while wielding a sword
		["持近战武器时，"] = { tag = { type = "Condition", var = "UsingMeleeWeapon" } }, --备注：while wielding a melee weapon
		["持单手武器时，"] = { tag = { type = "Condition", var = "UsingOneHandedWeapon" } }, --备注：while wielding a one handed weapon
		["持双手武器时，"] = { tag = { type = "Condition", var = "UsingTwoHandedWeapon" } }, --备注：while wielding a two handed weapon
		["持双手近战武器时，"] =  { tagList = { { type = "Condition", var = "UsingTwoHandedWeapon" }, { type = "Condition", var = "UsingMeleeWeapon" } } },
		["双持或持盾牌时，"] = { tag = { type = "Condition", varList = { "DualWielding", "UsingShield" } } }, --备注：while dual wielding or holding a shield
		["持法杖时，"] = { tag = { type = "Condition", var = "UsingWand" } }, --备注：while wielding a wand
		["空手时，"] = { tag = { type = "Condition", var = "Unarmed" } }, --备注：while unarmed
		["静止时，"] = { tag = { type = "Condition", var = "Stationary" } }, --备注：while stationary
		["移动时，"] = { tag = { type = "Condition", var = "Moving" } }, --备注：while moving
		["当你没有暴击球时，"] = { tag = { type = "StatThreshold", stat = "PowerCharges", threshold = 0, upper = true } }, --备注：while you have no power charges
		["当你没有狂怒球时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", threshold = 0, upper = true } }, --备注：while you have no frenzy charges
		["当你身上没有狂怒球时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", threshold = 0, upper = true } }, 
		["当你没有耐力球时，"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", threshold = 0, upper = true } }, --备注：while you have no endurance charges
		["你拥有暴击球时，"] = { tag = { type = "StatThreshold", stat = "PowerCharges", threshold = 1 } }, --备注：while you have a power charge
		["你拥有狂怒球时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", threshold = 1 } }, --备注：while you have a frenzy charge
		["你拥有耐力球时，"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", threshold = 1 } },
		["当暴击球达到上限时，"] = { tag = { type = "StatThreshold", stat = "PowerCharges", thresholdStat = "PowerChargesMax" } }, --备注：while at maximum power charges
		["当狂怒球达到上限时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" } }, --备注：while at maximum frenzy charges
		["当耐力球达到上限时，"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" } }, --备注：while at maximum endurance charges
		["当你有图腾存在时，"] = { tag = { type = "Condition", var = "HaveTotem" } }, --备注：while you have a totem
		["有图腾存在时"] = { tag = { type = "Condition", var = "HaveTotem" } }, 
		["当你拥有护体时，"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify	
		["【护体】状态下，"] = { tag = { type = "Condition", var = "Fortify" } },
		["【迷踪】状态时，"] = { tag = { type = "Condition", var = "Phasing" } }, --备注：while phasing
		["迷踪状态下"] = { tag = { type = "Condition", var = "Phasing" } }, --备注：while phasing
		["拥有【提速尾流】时，"] = { tag = { type = "Condition", var = "Tailwind" } }, --备注：while you have tailwind
		["拥有【猫之隐匿】时，"] = { tag = { type = "Condition", var = "AffectedBy猫之隐匿" } }, --备注：while you have cat's stealth
		["拥有【鸟之力量】时，"] = { tag = { type = "Condition", var = "AffectedBy鸟之力量" } }, --备注：while you have avian's might
		["拥有【鸟之斗魄】时，"] = { tag = { type = "Condition", var = "AffectedBy鸟之斗魄" } }, --备注：while you have avian's flight	
		["拥有【猫之隐匿】时"] = { tag = { type = "Condition", var = "AffectedBy猫之隐匿" } }, --备注：while you have cat's stealth
		["拥有【鸟之力量】时"] = { tag = { type = "Condition", var = "AffectedBy鸟之力量" } }, --备注：while you have avian's might
		["拥有【鸟之斗魄】时"] = { tag = { type = "Condition", var = "AffectedBy鸟之斗魄" } }, --备注：while you have avian's flight
		["受到【猫之势】影响时，"] = { tag = { type = "Condition", varList = { "AffectedBy猫之隐匿", "AffectedBy猫之敏捷" } } }, --备注：while affected by aspect of the cat
		["偷取时，"] = { tag = { type = "Condition", var = "Leeching" } }, --备注：while leeching
		["使用药剂时，"] = { tag = { type = "Condition", var = "UsingFlask" } }, --备注：while using a flask	
		["在奉献地面上时，"] = { tag = { type = "Condition", var = "OnConsecratedGround" } }, --备注：while on consecrated ground
		["被点燃时，"] = { tag = { type = "Condition", var = "Ignited" } }, --备注：while ignited
		["冰冻时，"] = { tag = { type = "Condition", var = "Frozen" } }, --备注：while frozen
		["被感电时，"] = { tag = { type = "Condition", var = "Shocked" } }, --备注：while shocked	
		["流血时，"] = { tag = { type = "Condition", var = "Bleeding" } }, --备注：while bleeding
		["中毒时，"] = { tag = { type = "Condition", var = "Poisoned" } }, --备注：while poisoned
		["被诅咒时，"] = { tag = { type = "Condition", var = "Cursed" } }, --备注：while cursed
		["未被诅咒时，"] = { tag = { type = "Condition", var = "Cursed", neg = true } }, --备注：while not cursed
		["持长杖时 "] = { tag = { type = "Condition", var = "UsingStaff" } }, --备注：while wielding a staff
		["获得护体时，"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify
	["受到你光环影响时，"] = { affectedByAura = true }, --备注：while affected by auras you cast	
	["你和友军"] = { }, --备注：to you and allies
	["你和周围友军的"] = { }, --备注：to you and allies
	["每个狂怒球附加"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, --备注：per frenzy charge
	["每拥有 1 个狂怒球，"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, --备注：per frenzy charge
	["每个狂怒球会使"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, --备注：per frenzy charge
	["若过去 8 秒内你打出过暴击，则"] = { tag = { type = "Condition", var = "CritInPast8Sec" } },
	["耐力球达到上限时，"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" } }, --备注：while at maximum endurance charges
	["护体时"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify	
	["护体状态下，"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify	
	["护体状态下"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify	
	["近期内你若使用过移动技能，则"] = { tag = { type = "Condition", var = "UsedMovementSkillRecently" } }, --备注：if you[' ]h?a?ve used a movement skill recently
	["近期内你若使用过位移技能，则"] = { tag = { type = "Condition", var = "UsedMovementSkillRecently" } },
	["若你近期内使用过位移技能，则"] = { tag = { type = "Condition", var = "UsedMovementSkillRecently" } },
	["每个暴击球"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, --备注：per power charge
	["每个暴击球造成"] = { tag = { type = "Multiplier", var = "PowerCharge" } },
	["对流血敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Bleeding" } }, 
	["流血敌人时"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Bleeding" } }, --备注：against bleeding enemies
	["被点燃敌人时"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" } }, --备注：to ignited enemies
	["被点燃的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" } }, --备注：to ignited enemies
	["对中毒敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Poisoned" }},
	["药剂持续期间，"] = { tag = { type = "Condition", var = "UsingFlask" } }, --备注：while using a flask	
	["感电时"] = { tag = { type = "Condition", var = "Shocked" } }, --备注：while shocked	
	["每一级为你的"] = { tag = { type = "Multiplier", var = "Level" } },
	["每一级在"] = { tag = { type = "Multiplier", var = "Level" } },
	["每 (%d+) 点敏捷可使"] = function(num) return { tag = { type = "PerStat", stat = "Dex", div = num } } end, 
	["拥有最大数量的狂怒球时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" } }, --备注：while at maximum frenzy charges
	["近期内你若打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["近期内你若有打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["近期内你若有打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } }, --备注：if you[' ]h?a?ve dealt a critical strike recently
	["近期内你若打出暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["当不拥有耐力球时，"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", threshold = 0, upper = true } },
	["中毒时 "] = { tag = { type = "Condition", var = "Poisoned" } }, 
	["近期内你若有使用战吼，则"] = { tag = { type = "Condition", var = "UsedWarcryRecently" } }, --备注：if you[' ]h?a?ve used a warcry recently
	["你若过去 8 秒内使用过战吼，则有"] = { tag = { type = "Condition", var = "UsedWarcryInPast8Seconds" } }, 
	["你若过去 8 秒内使用过战吼，则"] = { tag = { type = "Condition", var = "UsedWarcryInPast8Seconds" } }, 
	["近期内你若有使用战吼，"] = { tag = { type = "Condition", var = "UsedWarcryRecently" } }, --备注：if you[' ]h?a?ve used a warcry recently
	["每 (%d+) 点智慧会使"] = function(num) return { tag = { type = "PerStat", stat = "Int", div = num } } end, --备注：per (%d+) intelligence
	["每 (%d+) 点敏捷会使"] = function(num) return { tag = { type = "PerStat", stat = "Dex", div = num } } end, 
	["每 (%d+) 点力量会使 "] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["每 (%d+) 点力量会使"] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["每有 (%d+) 点力量，"] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, 
	["近期若打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["近期内若造成暴击则给"] = { tag = { type = "Condition", var = "CritRecently" } },
	["近期内你若被击中过，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["近期内你若被击中并受到伤害，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["若近期没有格挡，则"] = { tag = { type = "Condition", var = "BlockedRecently" , neg = true} }, 
	["近期内你若有格挡，则"] = { tag = { type = "Condition", var = "BlockedRecently" } }, 
	["若你近期内有格挡法术，则"] = { tag = { type = "Condition", var = "BlockedRecently" } }, 
	["近期内你若有过格挡，则"] = { tag = { type = "Condition", var = "BlockedRecently" } }, 
	["近期内你若有过格挡，"] = { tag = { type = "Condition", var = "BlockedRecently" } }, 
	["每个轮回球可使"] = { tag = { type = "Multiplier", var = "SiphoningCharge" } }, 
	["每 (%d+) 命中值可使"] = function(num) return { tag = { type = "PerStat", stat = "Accuracy", div = num } } end, 
	["对致盲的敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Blinded" }}, --备注：against blinded enemies
	["每拥有 1 个暴击球，有 "] = { tag = { type = "Multiplier", var = "PowerCharge" } }, --备注：per power charge
	["在低血时，"] = { tag = { type = "Condition", var = "LowLife" } },
	["低血时，"] = { tag = { type = "Condition", var = "LowLife" } },
	["移动时获得"] = { tag = { type = "Condition", var = "Moving" } }, --备注：while moving
	["每 (%d+) 点智慧可使"] = function(num) return { tag = { type = "PerStat", stat = "Int", div = num } } end, --备注：per (%d+) intelligence
	["每 (%d+) 点智慧可以为"] = function(num) return { tag = { type = "PerStat", stat = "Int", div = num } } end, --备注：per (%d+) intelligence
	["每 (%d+) 点敏捷可以为"] = function(num) return { tag = { type = "PerStat", stat = "Dex", div = num } } end, 
	["每 (%d+) 点力量可以为 "] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["对冰缓的目标的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } },
	["对致盲的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Blinded" } },
	["每个暴击球为"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, --备注：per power charge
	["狂怒球达到上限时，"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" } }, --备注：while at maximum frenzy charges
	["近期内你若被击中，"] = { tag = { type = "Condition", var = "BeenHitRecently" } },	
	["对冰缓敌人造成的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" }},
	["对冰缓敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } }, 
	["对冰缓敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } }, 
	["在主手时，"] = { tag = { type = "SlotNumber", num = 1 } }, --备注：when in main hand
	["击中冰缓敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" }}, --备注：against chilled  
	["对被点燃敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" }}, 
	["每 (%d+) 点力量可使"] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["你获得【猫之隐匿】时"] = { tag = { type = "Condition", var = "AffectedBy猫之隐匿" } }, --备注：while you have cat's stealth
	["每 (%d+) 点力量使"] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength		
	["若你有至少 (%d+) 点敏捷，则"] = function(num) return { tag = { type = "StatThreshold", stat = "Dex", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) strength
	["若你有至少 (%d+) 点智慧，则"] = function(num) return { tag = { type = "StatThreshold", stat = "Int", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) dexterity
	["若你有至少 (%d+) 点力量，则"] = function(num) return { tag = { type = "StatThreshold", stat = "Str", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) intelligence
	["当力量超过 (%d+) 点时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Str", threshold = num } } end,
	["近期内你若被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["击中点燃敌人时"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" }, keywordFlags = KeywordFlag.Hit }, 
	["在主手时，"] = { tag = { type = "SlotNumber", num = 1 } }, --备注：when in main hand
	["在副手时，"] = { tag = { type = "SlotNumber", num = 2 } }, --备注：when in off hand
	["每 (%d+) 力量 "] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["使用此武器攻击时，"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, 
	["近期内你若击败过敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" } }, 
	["近期内你若击败过敌人，"] = { tag = { type = "Condition", var = "KilledRecently" } }, 
	["药剂持续期间，获得"] = { tag = { type = "Condition", var = "UsingFlask" } },
	["双持时的"] = { tag = { type = "Condition", var = "DualWielding" } }, 
	["当移动时，"] = { tag = { type = "Condition", var = "Moving" } },
	["持盾时的"] = { tag = { type = "Condition", var = "UsingShield" } }, --备注：with shields
	["持盾牌时的"] = { tag = { type = "Condition", var = "UsingShield" } }, --备注：with shields
	["近期内你若受到伤害，则"] = { tag = { type = "Condition", var = "BeenHitRecently"} },
	["近期内你若有被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["如果近期内被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["近期内你若被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["近期内如果没有被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently" , neg = true} },
	["近期内你若没有击败过敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" , neg = true} }, 
	["盾牌装备上每有 (%d+) 点护甲值，便 "] = function(num) return { tag = { type = "PerStat", stat = "ArmourOnWeapon 2", div = num } } end, 
	["盾牌装备上每有 (%d+) 点闪避值，便 "] = function(num) return { tag = { type = "PerStat", stat = "EvasionOnWeapon 2", div = num } } end, 
	["盾牌装备上每有 (%d+) 点能量护盾，便 "] = function(num) return { tag = { type = "PerStat", stat = "EnergyShieldOnWeapon 2", div = num } } end, 
	["近期内你若没被击中后受到伤害，则"] = { tag = { type = "Condition", var = "BeenHitRecently", neg = true } }, 
	["近期内你若格挡过攻击伤害，则"] = { tag = { type = "Condition", var = "BlockedAttackRecently" } }, --备注：if you[' ]h?a?ve blocked an attack recently
	["近期内你若格挡过法术，"] = { tag = { type = "Condition", var = "BlockedSpellRecently" } }, --备注：if you[' ]h?a?ve blocked a spell recently
	["装备的护盾上每有 (%d+) 点护甲，便 "] = function(num) return { tag = { type = "PerStat", stat = "ArmourOnWeapon 2", div = num } } end, 
	["装备的护盾上每有 (%d+) 点闪避值，便 "] = function(num) return { tag = { type = "PerStat", stat = "EvasionOnWeapon 2", div = num } } end, 
	["装备的护盾上每有 (%d+) 点最大能量护盾，便 "] = function(num) return { tag = { type = "PerStat", stat = "EnergyShieldOnWeapon 2", div = num } } end, 
	["近期内你每吞噬过 1 个灵柩，"] = { tag = { type = "Condition", var = "ConsumedCorpseRecently" } }, --备注：if you[' ]h?a?ve 
	["每有一个狂怒球，可使你"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, 
	["每有一个耐力球，可使你"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每有一个暴击球，可使你"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每个暴击球可使"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每个耐力球会使"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每 1 个耐力球可使"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } },
	["每有 1 个耐力球，就会"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每有 1 个耐力球，便获得"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 	
	["每有一个狂怒球，"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, 
	["每有一个耐力球，"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每有一个暴击球，"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每有 1 个暴击球，"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每个暴击球使你的"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每有一个狂怒球，便"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, 
	["每有一个耐力球，便"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每有一个暴击球，便"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每有一个狂怒求，"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, 
	["每有一个耐力求，"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每有一个暴击求，"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, 
	["每个耐力球附加"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每个狂怒球可使"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, --备注：per frenzy charge
	["每个耐力球可使"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["每个耐力球增加"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, 
	["拥有【秘术增强】时"] = { tag = { type = "Condition", var = "AffectedBy秘术增强" } },
	["拥有【秘术增强】效果时，"] = { tag = { type = "Condition", var = "AffectedBy秘术增强" } },
	["带有烙印敌人"] = { tag = { type = "MultiplierThreshold", var = "BrandsAttachedToEnemy", threshold = 1 } },
	["被附着烙印的敌人受到"] = { tag = { type = "MultiplierThreshold", var = "BrandsAttachedToEnemy", threshold = 1 } },
	["专注时，"] = { tag = { type = "Condition", var = "Focused" } },
	["专注时"] = { tag = { type = "Condition", var = "Focused" } },
	["近期内你若击中敌人，则"] = { tag = { type = "Condition", var = "HitRecently"} },
	["每有 1 个六分仪影响该地区，"] = { tag = { type = "Multiplier", var = "Sextant" } },
	["拥有阻灵术时，"] = { tag = { type = "Condition", var = "SoulGainPrevention" } },
	["【阻灵术】生效期间，"] = { tag = { type = "Condition", var = "SoulGainPrevention" } },
	["专注时造成的"] = { tag = { type = "Condition", var = "Focused" } },
	["每 (%d+) 总和属性"] = function(num) return { tag = { type = "PerStat", statList = { "Str", "Dex", "Int" }, div = num } } end,
	["冰霜抗性 75%% 以上时, 每高 (%d+)%%"] = function(num) return { tag  = { type = "PerStat", stat = "ColdResistOver75", div = num } } end,
	["闪电抗性 75%% 以上时, 每高 (%d+)%%"] = function(num) return { tag  = { type = "PerStat", stat = "LightningResistOver75", div = num } } end,
	["偷取能量护盾时，"] = { tag = { type = "Condition", var = "LeechingEnergyShield" } },
	["偷取生命时，"] = { tag = { type = "Condition", var = "LeechingLife" } },
	["偷取魔力时，"] = { tag = { type = "Condition", var = "LeechingMana" } },
	["偷取能量护盾时"] = { tag = { type = "Condition", var = "LeechingEnergyShield" } },
	["偷取生命时"] = { tag = { type = "Condition", var = "LeechingLife" } },
	["偷取魔力时"] = { tag = { type = "Condition", var = "LeechingMana" } },
	["每个敌人身上的诅咒"] = { tag = { type = "Multiplier", var = "CurseOnEnemy" } },
	["敌人身上每有 1 个诅咒，"] = { tag = { type = "Multiplier", var = "CurseOnEnemy" } },
	["冰霜抗性高于 75%% 时，每高 (%d+)%%，"] = function(num) return { tag  = { type = "PerStat", stat = "ColdResistOver75", div = num } } end,
	["闪电抗性高于 75%% 时，每高 (%d+)%%，"] = function(num) return { tag  = { type = "PerStat", stat = "LightningResistOver75", div = num } } end,
	["每 (%d+) 点魔力会使"] = function(num) return { tag = { type = "PerStat", stat = "Mana", div = num } } end,
	["每 (%d+) 点最大魔力会使"] = function(num) return { tag = { type = "PerStat", stat = "Mana", div = num } } end,
	["【猛攻】效果持续时，"] = { tag = { type = "Condition", var = "Onslaught" } },
	["近期内你若晕眩过敌人，则"] = { tag = { type = "Condition", var = "StunnedEnemyRecently" } },	
	["近期内你若有晕眩敌人，则"] = { tag = { type = "Condition", var = "StunnedEnemyRecently" } },	
	["近期内你若有击中敌人，"] = { tag = { type = "Condition", var = "HitRecently" } },	
	["敌人身上每层穿刺效果可以为"] = { tag = { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }},
	["近期内你若穿刺过敌人，"] = { tag = { type = "Condition", var = "ImpaledRecently" } },
	["使用【尊严】时，"] = { tag = { type = "Condition", var = "UsedBy尊严" } },
	["使用【尊严】时"] = { tag = { type = "Condition", var = "UsedBy尊严" } },
	["使用尊严时，"] = { tag = { type = "Condition", var = "UsedBy尊严" } }, 
	["使用尊严时"] = { tag = { type = "Condition", var = "UsedBy尊严" } }, 
	["如果敏捷高于智慧，则"] = { tag = { type = "Condition", var = "DexHigherThanInt" } }, 
	["力量高于智慧时，"] = { tag = { type = "Condition", var = "StrHigherThanInt" } }, 
	["当你获得【火之化身】时，"] = { tag = { type = "Condition", var = "Have火之化身Keystone" } }, 
	["当你没有获得【火之化身】时，"] = { tag = { type = "Condition", var = "Have火之化身Keystone" ,neg = true} },
	["当你没有获得【霸体】时，"] = { tag = { type = "Condition", var = "Have霸体Keystone" ,neg = true} },
	["当你获得【霸体】时，"] = { tag = { type = "Condition", var = "Have霸体Keystone"} },
	["每 (%d+) 点奉献使"] = function(num) return { tag = { type = "PerStat", stat = "Devotion", div = num } } end,
	["每 (%d+) 点奉献 使"] = function(num) return { tag = { type = "PerStat", stat = "Devotion", div = num } } end,
	["每 (%d+) 点奉献可使"] = function(num) return { tag = { type = "PerStat", stat = "Devotion", div = num } } end,
	["每 (%d+) 点奉献"] = function(num) return { tag = { type = "PerStat", stat = "Devotion", div = num } } end,
	["至少有 (%d+) 点奉献时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Devotion", threshold = num } } end,
	["至少 (%d+) 奉献时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Devotion", threshold = num } } end,
	["至少 (%d+) 点奉献时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Devotion", threshold = num } } end,
	["暴击时，"] = { tag = { type = "Condition", var = "CriticalStrike" } },
	["持锤或短杖时，"] = { tag = { type = "Condition", var = "UsingMace" } },
	["过去 8 秒你若有造成暴击，"] = { tag = { type = "Condition", var = "CritInPast8Sec" } },
	["若近期有引爆过地雷，则"] = { tag = { type = "Condition", var = "DetonatedMinesRecently" } },
	["近期内你若引爆过地雷，则"] = { tag = { type = "Condition", var = "DetonatedMinesRecently" } },
	["若你近期内引爆过地雷，则"] = { tag = { type = "Condition", var = "DetonatedMinesRecently" } },
	["对燃烧的敌人，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Burning" } },
	["对燃烧敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Burning" } },
	 ["处于【灵巧】状态时，"] = { tag = { type = "Condition", var = "Elusive" } }, 
	 ["【灵巧】效果下，"] = { tag = { type = "Condition", var = "Elusive" } }, 
	 ["每个图腾使你"] = { tag = { type = "PerStat", stat = "ActiveTotemLimit" } },
	 ["每个召唤的图腾"] = { tag = { type = "PerStat", stat = "ActiveTotemLimit" } },
	 ["每个召唤的图腾使"] = { tag = { type = "PerStat", stat = "ActiveTotemLimit" } },
	 ["近期内你若击中被诅咒的敌人，则"] = { tagList = { { type = "Condition", var = "HitRecently" }, { type = "ActorCondition", actor = "enemy", var = "Cursed" } } },
	 ["若你近期内击中被诅咒的敌人，则"] = { tagList = { { type = "Condition", var = "HitRecently" }, { type = "ActorCondition", actor = "enemy", var = "Cursed" } } },
	 ["能量护盾全满时"] = { tag = { type = "Condition", var = "FullEnergyShield" } },	 
	 ["持续吟唱时，"] = { tag = { type = "Condition", var = "OnChannelling" } },	 
	 ["若你已经持续吟唱至少 1 秒,则 "] = { tag = { type = "Condition", var = "OnChannelling" } },	 
	 ["若你近期内至少持续吟唱 1 秒,则 "] = { tag = { type = "Condition", var = "OnChannelling" } },	 
	 ["若近期有击败敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" } }, 
	 ["每有一个影响你的捷效果都使"] = { tag = { type = "Multiplier", var = "AffectedByHeraldCount" } }, 
	["每受到一个捷技能影响，"] = { tag = { type = "Multiplier", var = "AffectedByHeraldCount" } }, 
	["受捷影响时，"] = { tag = { type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷" 
	, "AffectedBy寒冰之捷"
	, "AffectedBy灰烬之捷"
	, "AffectedBy闪电之捷"
	} } }, 
	["受到捷技能影响时，"] = { tag = { type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷" 
		, "AffectedBy寒冰之捷"
		, "AffectedBy灰烬之捷"
		, "AffectedBy闪电之捷"
		} } }, 
	["对抗被嘲讽的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Taunted" } },
	["对被嘲讽敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Taunted" } },
	["对被嘲讽敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Taunted" } },
	["任何魔力药剂作用时间内，"] = { tag = { type = "Condition", var = "UsingManaFlask" } },
	["在任何生命药剂作用时间内，"] = { tag = { type = "Condition", var = "UsingLifeFlask" } },
	["任意生命和魔力药剂持续期间，"] = { tag = { type = "Condition", varList = { "UsingManaFlask", "UsingLifeFlask" } } },
	["每个召唤的魔像可使"] = { tag = { type = "PerStat", stat = "ActiveGolemLimit" } },
	["当你有召唤的魔像存在时，"] = { tag = { type = "Condition", varList = { "HavePhysicalGolem", "HaveLightningGolem", "HaveColdGolem", "HaveFireGolem", "HaveChaosGolem", "HaveCarrionGolem" } } },
	["总属性每有 (%d+) 点，"] = function(num) return { tag = { type = "PerStat", statList = { "Str", "Dex", "Int" }, div = num } } end,
	["处于【血姿态】时，"] = { tag = { type = "Condition", var = "BloodStance" } },	
	["处于【沙姿态】时，"] = { tag = { type = "Condition", var = "SandStance" } },	
	["血姿态下，"] = { tag = { type = "Condition", var = "BloodStance" } },	
	["沙姿态下，"] = { tag = { type = "Condition", var = "SandStance" } },	
	["对抗标记的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Marked" }},
	["对咒印标记的敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Marked" } },
		["击中被咒印标记的敌人时会"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Marked" } },
		["来自被咒印标记的敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Marked" } },
	["若近期内有冰冻过敌人，则"] = { tag = { type = "Condition", var = "FrozenEnemyRecently" } },
		["若近期内有冰缓过敌人，则"] = { tag = { type = "Condition", var = "ChilledEnemyRecently" } },
		["若近期内有点燃过敌人，则"] = { tag = { type = "Condition", var = "IgnitedEnemyRecently" } },
		["若近期内有感电过敌人，则"] = { tag = { type = "Condition", var = "ShockedEnemyRecently" } },
		["若近期内有晕眩过敌人，则"] = { tag = { type = "Condition", var = "StunnedEnemyRecently" } },
	["每层凝聚使"] = { tag = { type = "Multiplier", var = "Intensity" } },
	["若你的耐力球、狂怒球或暴击球总共有 (%d+) 个时，将"] = function(num) return { tag = { type = "MultiplierThreshold", var = "TotalCharges", threshold = num } } end,
	["物理神盾消散时，"] = { tag = { type = "Condition", var = "PhysicalAegisDepleted" } },
	["在召唤魔像后的 8 秒内"] = { tag = { type = "Condition", var = "SummonedGolemInPast8Sec" } },
	["若你近期内获得过暴击球，则"] = { tag = { type = "Condition", var = "GainedPowerChargeRecently" } },
	--["每个【召唤灵体】会使"] = { tag = { type = "PerStat", stat = "ActiveSpectreLimit" } },
	["冰缓时，"] = { tag = { type = "Condition", var = "Chilled" } },
	["被点燃时，"] = { tag = { type = "Condition", var = "Ignited" } },
	["被点燃时"] = { tag = { type = "Condition", var = "Ignited" } },
	["每 (%d+) 点护甲都使"] = function(num) return { tag = { type = "PerStat", stat = "Armour", div = num } } end, 
	["受到非瓦尔护卫技能影响时，"] = { tag = { type = "Condition", var =  "AffectedByNonVaalGuardSkill" } },
	["受到非瓦尔防卫技能影响时获得"] = { tag = { type = "Condition", var =  "AffectedByNonVaalGuardSkill" } },
	["受到防卫技能增益效果影响时，获得"] = { tag = { type = "Condition", var = "AffectedByGuardSkill" } },
	["受到防卫技能增益效果影响时，"] = { tag = { type = "Condition", var = "AffectedByGuardSkill" } },
	["被防卫技能的增益效果影响时，"] = { tag = { type = "Condition", var = "AffectedByGuardSkill" } },
	["若近期你有施加曝露,则"] = { tag = { type = "Condition", var = "AppliedExposureRecently" } },
	["你有热情牺牲时，"] = { tag = { type = "Condition", var = "SacrificialZeal" } },
	["每穿透 1 个敌人，"] = { tag = { type = "PerStat", stat = "PiercedCount" } },
	["疯狂状态下，"] = { tag = { type = "Condition", var = "InSaneInsanity" } },
	["理智状态下，"] = { tag = { type = "Condition", var = "SaneInsanity" } },
	["若过去 8 秒内你造成过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["若你近期内击中敌人，则"] = { tag = { type = "Condition", var = "HitRecently"} },
	["处于【灌注】状态时，"] = { tag = { type = "Condition", var = "InfusionActive" } },
	["【灌注】效果下，"] = { tag = { type = "Condition", var = "InfusionActive" } },
	["若你近期内没有获得暴击球，则"] = { tag = { type = "Condition", var = "GainedPowerChargeRecently", neg = true } },
	["若你近期内没有获得狂怒球，则"] = { tag = { type = "Condition", var = "GainedFrenzyChargeRecently", neg = true } },
	["若你近期内有击败敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" } }, 
	["若你近期内没有击败敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" , neg = true} }, 
	["若你近期内打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["若你近期内有打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } },
	["若你近期内没有击败过敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" , neg = true} }, 
	["若你近期内没有打出暴击，则"] = { tag = { type = "Condition", var = "CritRecently" , neg = true } },
	--["per (.+) eye jewel affecting you, up to a maximum of %+?(%d+)%%"] = function(type, _, num) return { tag = { type = "Multiplier", var = upperCaseFirstLetter(type) .. "EyeJewel", limit = tonumber(num), limitTotal = true } } end,
	["每层抗争使"] = { tag = { type = "Multiplier", var = "Defiance" } },
	["抗争状态下，"] = { tag = { type = "MultiplierThreshold", var = "Defiance", threshold = 1 } },
	["消耗生命所施放技能的"] = { tag = { type = "StatThreshold", stat = "LifeCost", threshold = 1 } },
	["用生命施放技能时，其"] = { tag = { type = "StatThreshold", stat = "LifeCost", threshold = 1 } },
	["对流血的敌人，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Bleeding" } }, 
	["对中毒的敌人，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Poisoned" } }, 
	["对瘫痪的敌人造成的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Maimed" } }, 
	["对抗【瘫痪】的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Maimed" } }, 
	["双持两种不同类型的武器时，"] = { tag = { type = "Condition", var = "WieldingDifferentWeaponTypes" } },
	["若双持不同类型的武器，则"] = { tag = { type = "Condition", var = "WieldingDifferentWeaponTypes" } },
	["若你近期内没有施放过冲刺，则"] = { tag = { type = "Condition", var = "CastDashRecently", neg = true } },
	["若你近期施放过冲刺，则"] = { tag = { type = "Condition", var = "CastDashRecently" } },	
	["若近期没有使用【冲刺】技能，"] = { tag = { type = "Condition", var = "CastDashRecently", neg = true } },
	["若近期有使用【冲刺】技能，"] = { tag = { type = "Condition", var = "CastDashRecently" } },	
	--【中文化程序额外添加结束】
	["on enemies"] = { },
	["while active"] = { },
	["暴击时"] = { tag = { type = "Condition", var = "CriticalStrike" } }, --备注： on critical strike
	["你和友军受你的光环影响时"] = { affectedByAura = true }, --备注：while affected by auras you cast
	["for you and nearby allies"] = { newAura = true },
	-- Multipliers
	["每个暴击球可使"] = { tag = { type = "Multiplier", var = "PowerCharge" } }, --备注：per power charge
	["每个狂怒球"] = { tag = { type = "Multiplier", var = "FrenzyCharge" } }, --备注：per frenzy charge
	["每个耐力球"] = { tag = { type = "Multiplier", var = "EnduranceCharge" } }, --备注：per endurance charge
	["每有 1 个轮回球，便获得"] = { tag = { type = "Multiplier", var = "SiphoningCharge" } }, --备注：per siphoning charge
	["每个【深海屏障】可使"] = { tag = { type = "Multiplier", var = "CrabBarrier" } }, --备注：per crab barrier
	["每级"] = { tag = { type = "Multiplier", var = "Level" } }, --备注：per level
	["per (%d+) player levels"] = function(num) return { tag = { type = "Multiplier", var = "Level", div = num } } end,
	["for each normal item you have equipped"] = { tag = { type = "Multiplier", var = "NormalItem" } },
	["for each equipped normal item"] = { tag = { type = "Multiplier", var = "NormalItem" } },
	["for each magic item you have equipped"] = { tag = { type = "Multiplier", var = "MagicItem" } },
	["每装备一个魔法物品，"] = { tag = { type = "Multiplier", var = "MagicItem" } }, --备注：for each equipped magic item
	["for each rare item you have equipped"] = { tag = { type = "Multiplier", var = "RareItem" } },
	["for each equipped rare item"] = { tag = { type = "Multiplier", var = "RareItem" } },
	["你每装备一个传奇装备，"] = { tag = { type = "Multiplier", var = "UniqueItem" } }, --备注：for each unique item you have equipped
	["for each equipped unique item"] = { tag = { type = "Multiplier", var = "UniqueItem" } },
	["每装备 1 个【裂界之器】，"] = { tag = { type = "Multiplier", var = "ElderItem" } }, --备注：per elder item equipped
	["per shaper item equipped"] = { tag = { type = "Multiplier", var = "ShaperItem" } },
	["每装备 1 个【裂界之器】或【塑界之器】，便"] = { tag = { type = "Multiplier", var = "ShaperOrElderItem" } }, --备注：per elder or shaper item equipped
	["每装备 1 个被腐化的物品，"] = { tag = { type = "Multiplier", var = "CorruptedItem" } }, --备注：for each equipped corrupted item
	["每个影响你的【深渊珠宝】可使"] = { tag = { type = "Multiplier", var = "AbyssJewel" } }, --备注：per abyssa?l? jewel affecting you
	["每种影响你的【深渊珠宝】可使"] = { tag = { type = "Multiplier", var = "AbyssJewelType" } }, --备注：for each type of abyssa?l? jewel affecting you
	["自身的每个增益会为"] = { tag = { type = "Multiplier", var = "BuffOnSelf" } }, --备注：per buff on you
	["敌人身上每个诅咒可使"] = { tag = { type = "Multiplier", var = "CurseOnEnemy" } }, --备注：per curse on enemy
	["自身的每个诅咒会使"] = { tag = { type = "Multiplier", var = "CurseOnSelf" } }, --备注：per curse on you
	["你身上的每层中毒状态使你获得"] = { tag = { type = "Multiplier", var = "PoisonStack" } }, --备注：per poison on you
	["per poison on you, up to (%d+) per second"] = function(num) return { tag = { type = "Multiplier", var = "PoisonStack", limit = tonumber(num), limitTotal = true } } end,
	["for each poison you have inflicted recently"] = { tag = { type = "Multiplier", var = "PoisonAppliedRecently" } },
	["近期内你每击败 1 个感电敌人，则"] = { tag = { type = "Multiplier", var = "ShockedEnemyKilledRecently" } }, --备注：for each shocked enemy you've killed recently
	["per enemy killed recently, up to (%d+)%%"] = function(num) return { tag = { type = "Multiplier", var = "EnemyKilledRecently", limit = tonumber(num), limitTotal = true } } end,
	["近期内，你或你的召唤生物每击败一个敌人，则每秒回复你 1%% 能量护盾，最多 (%d+)%%"] = function(num) return { tag = { type = "Multiplier", varList = {"EnemyKilledRecently","EnemyKilledByMinionsRecently"}, limit = tonumber(num), limitTotal = true } } end, --备注：for each enemy you or your minions have killed recently, up to (%d+)%%
	["近期你或你的图腾若有击败过敌人，则每击败 1 个，"] = { tag = { type = "Multiplier", varList = {"EnemyKilledRecently","EnemyKilledByTotemsRecently"} } }, --备注：per enemy killed by you or your totems recently
	["你和周围友方的"] = { }, --备注：to you and allies
	["每个红色插槽"] = { tag = { type = "Multiplier", var = "RedSocketIn{SlotName}" } }, --备注：per red socket
	["每个绿色插槽"] = { tag = { type = "Multiplier", var = "GreenSocketIn{SlotName}" } }, --备注：per green socket
	["每个蓝色插槽"] = { tag = { type = "Multiplier", var = "BlueSocketIn{SlotName}" } }, --备注：per blue socket
	["每个白色插槽会使"] = { tag = { type = "Multiplier", var = "WhiteSocketIn{SlotName}" } }, --备注：per white socket
	-- Per stat
	["每 (%d+) 点力量 "] = function(num) return { tag = { type = "PerStat", stat = "Str", div = num } } end, --备注：per (%d+) strength
	["每 (%d+) 点敏捷 "] = function(num) return { tag = { type = "PerStat", stat = "Dex", div = num } } end, --备注：per (%d+) dexterity
	["每 (%d+) 点智慧 "] = function(num) return { tag = { type = "PerStat", stat = "Int", div = num } } end, --备注：per (%d+) intelligence
	["你最低的属性每有 (%d+) 点，"] = function(num) return { tag = { type = "PerStat", stat = "LowestAttribute", div = num } } end, --备注：per (%d+) of your lowest attribute
	["每 (%d+) 点闪避值可使"] = function(num) return { tag = { type = "PerStat", stat = "Evasion", div = num } } end, --备注：per (%d+) evasion rating
	["per (%d+) evasion rating, up to (%d+)%%"] = function(num, _, limit) return { tag = { type = "PerStat", stat = "Evasion", div = num, limit = tonumber(limit), limitTotal = true } } end,
	["每有 (%d+) 层能量护盾可"] = function(num) return { tag = { type = "PerStat", stat = "EnergyShield", div = num } } end, --备注：per (%d+) maximum energy shield
	["per (%d+) maximum mana, up to (%d+)%%"] = function(num, _, limit) return { tag = { type = "PerStat", stat = "Mana", div = num, limit = tonumber(limit), limitTotal = true } } end,
	["每 (%d+) 点命中值可使"] = function(num) return { tag = { type = "PerStat", stat = "Accuracy", div = num } } end, --备注：per (%d+) accuracy rating
	["每 (%d+) 点命中值都使"] = function(num) return { tag = { type = "PerStat", stat = "Accuracy", div = num } } end, --备注：per (%d+) accuracy rating
	["每 (%d+)%% 攻击格挡率"] = function(num) return { tag = { type = "PerStat", stat = "BlockChance", div = num } } end, --备注：per (%d+)%% block chance
	["取护甲和闪避值之间的较低者，每 (%d+) 点可使"] = function(num) return { tag = { type = "PerStat", stat = "LowestOfArmourAndEvasion", div = num } } end, --备注：per (%d+) of the lowest of armour and evasion rating
	["头部装备上每有 (%d+) 点最大能量护盾，便"] = function(num) return { tag = { type = "PerStat", stat = "EnergyShieldOnHelmet", div = num } } end, --备注：per (%d+) maximum energy shield on helmet
	["身体护甲上每有 (%d+) 点闪避值，便"] = function(num) return { tag = { type = "PerStat", stat = "EvasionOnBody Armour", div = num } } end, --备注：per (%d+) evasion rating on body armour
	["per (%d+) armour on equipped shield"] = function(num) return { tag = { type = "PerStat", stat = "ArmourOnWeapon 2", div = num } } end,
	["per (%d+) evasion rating on equipped shield"] = function(num) return { tag = { type = "PerStat", stat = "EvasionOnWeapon 2", div = num } } end,
	["per (%d+) maximum energy shield on equipped shield"] = function(num) return { tag = { type = "PerStat", stat = "EnergyShieldOnWeapon 2", div = num } } end,
	["per totem"] = { tag = { type = "PerStat", stat = "ActiveTotemLimit" } },
	["for each time they have chained"] = { tag = { type = "PerStat", stat = "Chain" } },
	-- Stat conditions
	["with (%d+) or more strength"] = function(num) return { tag = { type = "StatThreshold", stat = "Str", threshold = num } } end,
	["with at least (%d+) strength"] = function(num) return { tag = { type = "StatThreshold", stat = "Str", threshold = num } } end,
	["至少有 (%d+) 点力量时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Str", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) strength
	["至少有 (%d+) 点敏捷时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Dex", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) dexterity
	["至少有 (%d+) 点智慧时，"] = function(num) return { tag = { type = "StatThreshold", stat = "Int", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) intelligence
	["at least (%d+) intelligence"] = function(num) return { tag = { type = "StatThreshold", stat = "Int", threshold = num } } end, -- lol
	["若你至少拥有 1500 层能量护盾，则"] = function(num) return { tag = { type = "StatThreshold", stat = "EnergyShield", threshold = num } } end, --备注：w?h?i[lf]e? you have at least (%d+) maximum energy shield
	["against targets they pierce"] = { tag = { type = "StatThreshold", stat = "PierceCount", threshold = 1 } },
	["against pierced targets"] = { tag = { type = "StatThreshold", stat = "PierceCount", threshold = 1 } },
	["箭矢对其穿透的目标所造成的"] = { tag = { type = "StatThreshold", stat = "PierceCount", threshold = 1 } }, --备注：to targets they pierce
	-- Slot conditions
	["装备在主手时"] = { tag = { type = "SlotNumber", num = 1 } }, --备注：when in main hand
	["装备于副手时有"] = { tag = { type = "SlotNumber", num = 2 } }, --备注：when in off hand
	["主手"] = { tag = { type = "InSlot", num = 1 } }, --备注：in main hand
	["副手"] = { tag = { type = "InSlot", num = 2 } }, --备注：in off hand
	["主手武器"] = { tag = { type = "Condition", var = "MainHandAttack" } }, --备注：with main hand
	["副手武器"] = { tag = { type = "Condition", var = "OffHandAttack" } }, --备注：with off hand
	["使用该武器时，"] = { tag = { type = "Condition", var = "{Hand}Attack" } }, --备注：with this weapon
	["若你的其他戒指中有【塑界之器】，则"] = { tag = { type = "Condition", var = "ShaperItemInRing {OtherSlotNum}" } }, --备注：if your other ring is a shaper item
	["若你的其他戒指中有【裂界之器】，则"] = { tag = { type = "Condition", var = "ElderItemInRing {OtherSlotNum}" } }, --备注：if your other ring is an elder item
	-- Equipment conditions
	["持盾牌时"] = { tag = { type = "Condition", var = "UsingShield" } }, --备注：while holding a shield
	["你的副手未装备武器时"] = { tag = { type = "Condition", var = "OffHandIsEmpty" } }, --备注：while your off hand is empty
	["持盾时"] = { tag = { type = "Condition", var = "UsingShield" } }, --备注：with shields
	["双持时"] = { tag = { type = "Condition", var = "DualWielding" } }, --备注：while dual wielding
	["双持爪时"] = { tag = { type = "Condition", var = "DualWieldingClaws" } }, --备注：while dual wielding claws
	["双持或持盾牌时"] = { tag = { type = "Condition", varList = { "DualWielding", "UsingShield" } } }, --备注：while dual wielding or holding a shield
	["持斧时"] = { tag = { type = "Condition", var = "UsingAxe" } }, --备注：while wielding an axe
	["持弓时"] = { tag = { type = "Condition", var = "UsingBow" } }, --备注：while wielding a bow
	["持爪时"] = { tag = { type = "Condition", var = "UsingClaw" } }, --备注：while wielding a claw
	["持匕时"] = { tag = { type = "Condition", var = "UsingDagger" } }, --备注：while wielding a dagger
	["持锤时"] = { tag = { type = "Condition", var = "UsingMace" } }, --备注：while wielding a mace
	["持长杖时"] = { tag = { type = "Condition", var = "UsingStaff" } }, --备注：while wielding a staff
	["持剑时"] = { tag = { type = "Condition", var = "UsingSword" } }, --备注：while wielding a sword
	["持近战武器时"] = { tag = { type = "Condition", var = "UsingMeleeWeapon" } }, --备注：while wielding a melee weapon
	["持单手武器时"] = { tag = { type = "Condition", var = "UsingOneHandedWeapon" } }, --备注：while wielding a one handed weapon
	["持双手武器时"] = { tag = { type = "Condition", var = "UsingTwoHandedWeapon" } }, --备注：while wielding a two handed weapon
	["持法杖时"] = { tag = { type = "Condition", var = "UsingWand" } }, --备注：while wielding a wand
	["空手时"] = { tag = { type = "Condition", var = "Unarmed" } }, --备注：while unarmed
	["装备 1 件普通物品时，"] = { tag = { type = "MultiplierThreshold", var = "NormalItem", threshold = 1 } }, --备注：with a normal item equipped
	["装备 1 件魔法物品时，"] = { tag = { type = "MultiplierThreshold", var = "MagicItem", threshold = 1 } }, --备注：with a magic item equipped
	["with a rare item equipped"] = { tag = { type = "MultiplierThreshold", var = "RareItem", threshold = 1 } },
	["with a unique item equipped"] = { tag = { type = "MultiplierThreshold", var = "UniqueItem", threshold = 1 } },
	["if you wear no corrupted items"] = { tag = { type = "MultiplierThreshold", var = "CorruptedItem", threshold = 0, upper = true } },
	["if no worn items are corrupted"] = { tag = { type = "MultiplierThreshold", var = "CorruptedItem", threshold = 0, upper = true } },
	["身上未装备已腐化的物品时，"] = { tag = { type = "MultiplierThreshold", var = "CorruptedItem", threshold = 0, upper = true } }, --备注：if no equipped items are corrupted
	["if all worn items are corrupted"] = { tag = { type = "MultiplierThreshold", var = "NonCorruptedItem", threshold = 0, upper = true } },
	["所有身上装备的物品皆为已腐化时，"] = { tag = { type = "MultiplierThreshold", var = "NonCorruptedItem", threshold = 0, upper = true } }, --备注：if all equipped items are corrupted
	["装备的护盾格挡几率若不低于 (%d+)%%，则"] = function(num) return { tag = { type = "StatThreshold", stat = "ShieldBlockChance", threshold = num } } end, --备注：if equipped shield has at least (%d+)%% chance to block
	["if you have (%d+) primordial items socketed or equipped"] = function(num) return { tag = { type = "MultiplierThreshold", var = "PrimordialItem", threshold = num } } end,
	-- Player status conditions
	["低血时"] = { tag = { type = "Condition", var = "LowLife" } }, --备注：wh[ie][ln]e? on low life
	["wh[ie][ln]e? not on low life"] = { tag = { type = "Condition", var = "LowLife", neg = true } },
	["满血时"] = { tag = { type = "Condition", var = "FullLife" } }, --备注：wh[ie][ln]e? on full life
	["wh[ie][ln]e? not on full life"] = { tag = { type = "Condition", var = "FullLife", neg = true } },
	["无生命保留时"] = { tag = { type = "StatThreshold", stat = "LifeReserved", threshold = 0, upper = true } }, --备注：wh[ie][ln]e? no life is reserved
	["无魔力保留时，"] = { tag = { type = "StatThreshold", stat = "ManaReserved", threshold = 0, upper = true } }, --备注：wh[ie][ln]e? no mana is reserved
	["能量护盾全满时，"] = { tag = { type = "Condition", var = "FullEnergyShield" } }, --备注：wh[ie][ln]e? on full energy shield
	["wh[ie][ln]e? not on full energy shield"] = { tag = { type = "Condition", var = "FullEnergyShield", neg = true } },
	["拥有能量护盾时"] = { tag = { type = "Condition", var = "HaveEnergyShield" } }, --备注：wh[ie][ln]e? you have energy shield
	["静止时"] = { tag = { type = "Condition", var = "Stationary" } }, --备注：while stationary
	["移动时"] = { tag = { type = "Condition", var = "Moving" } }, --备注：while moving
	["当你没有暴击球时"] = { tag = { type = "StatThreshold", stat = "PowerCharges", threshold = 0, upper = true } }, --备注：while you have no power charges
	["当你没有狂怒球时"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", threshold = 0, upper = true } }, --备注：while you have no frenzy charges
	["当你没有耐力球时"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", threshold = 0, upper = true } }, --备注：while you have no endurance charges
	["你拥有暴击球时"] = { tag = { type = "StatThreshold", stat = "PowerCharges", threshold = 1 } }, --备注：while you have a power charge
	["你拥有狂怒球时"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", threshold = 1 } }, --备注：while you have a frenzy charge
	["你拥有耐力球时"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", threshold = 1 } }, --备注：while you have an endurance charge
	["当暴击球达到上限时"] = { tag = { type = "StatThreshold", stat = "PowerCharges", thresholdStat = "PowerChargesMax" } }, --备注：while at maximum power charges
	["当狂怒球达到上限时"] = { tag = { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" } }, --备注：while at maximum frenzy charges
	["当耐力球达到上限时"] = { tag = { type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" } }, --备注：while at maximum endurance charges
	["你拥有至少 (%d+) 个【深海屏障】时，"] = function(num) return { tag = { type = "StatThreshold", stat = "CrabBarriers", threshold = num } } end, --备注：while you have at least (%d+) crab barriers
	["当你有图腾存在时"] = { tag = { type = "Condition", var = "HaveTotem" } }, --备注：while you have a totem
	["周围至少有 1 个友军时，"] = { tag = { type = "MultiplierThreshold", var = "NearbyAlly", threshold = 1 } }, --备注：while you have at least one nearby ally
	["当你拥有护体时"] = { tag = { type = "Condition", var = "Fortify" } }, --备注：while you have fortify
	["【猛攻】状态下"] = { tag = { type = "Condition", var = "Onslaught" } }, --备注：during onslaught
	["获得【猛攻】时"] = { tag = { type = "Condition", var = "Onslaught" } }, --备注：while you have onslaught
	["【迷踪】状态时"] = { tag = { type = "Condition", var = "Phasing" } }, --备注：while phasing
	["拥有【提速尾流】时"] = { tag = { type = "Condition", var = "Tailwind" } }, --备注：while you have tailwind
	["while you have cat's stealth"] = { tag = { type = "Condition", var = "AffectedByCat'sStealth" } },
	["while you have avian's might"] = { tag = { type = "Condition", var = "AffectedByAvian'sMight" } },
	["while you have avian's flight"] = { tag = { type = "Condition", var = "AffectedByAvian'sFlight" } },
	["while affected by aspect of the cat"] = { tag = { type = "Condition", varList = { "AffectedByCat'sStealth", "AffectedByCat'sAgility" } } },
	["偷取时"] = { tag = { type = "Condition", var = "Leeching" } }, --备注：while leeching
	["生命偷取时"] = { tag = { type = "Condition", var = "Leeching" } }, --备注：while leeching
	["使用药剂时"] = { tag = { type = "Condition", var = "UsingFlask" } }, --备注：while using a flask
	["during effect"] = { tag = { type = "Condition", var = "UsingFlask" } },
	["药剂持续期间，"] = { tag = { type = "Condition", var = "UsingFlask" } }, --备注：during flask effect
	["药剂持续期间，"] = { tag = { type = "Condition", var = "UsingFlask" } }, --备注：during any flask effect
	["在奉献地面上时"] = { tag = { type = "Condition", var = "OnConsecratedGround" } }, --备注：while on consecrated ground
	["在燃烧地面上的"] = { tag = { type = "Condition", var = "OnBurningGround" } }, --备注：on burning ground
	["在冰缓地面上"] = { tag = { type = "Condition", var = "OnChilledGround" } }, --备注：on chilled ground
	["在感电地面上的"] = { tag = { type = "Condition", var = "OnShockedGround" } }, --备注：on shocked ground
	["被点燃时"] = { tag = { type = "Condition", var = "Ignited" } }, --备注：while ignited
	["冰冻时"] = { tag = { type = "Condition", var = "Frozen" } }, --备注：while frozen
	["被感电时"] = { tag = { type = "Condition", var = "Shocked" } }, --备注：while shocked
	["没有被点燃，冰冻，感电时，"] = { tag = { type = "Condition", varList = { "Ignited", "Frozen", "Shocked" }, neg = true } }, --备注：while not ignited, frozen or shocked
	["流血时"] = { tag = { type = "Condition", var = "Bleeding" } }, --备注：while bleeding
	["中毒时"] = { tag = { type = "Condition", var = "Poisoned" } }, --备注：while poisoned
	["被诅咒时"] = { tag = { type = "Condition", var = "Cursed" } }, --备注：while cursed
	["未被诅咒时"] = { tag = { type = "Condition", var = "Cursed", neg = true } }, --备注：while not cursed
	["周围只有 1 个敌人时，"] = { tag = { type = "Condition", var = "OnlyOneNearbyEnemy" } }, --备注：while there is only one nearby enemy
	["if you[' ]h?a?ve hit recently"] = { tag = { type = "Condition", var = "HitRecently" } },
	["if you[' ]h?a?ve crit recently"] = { tag = { type = "Condition", var = "CritRecently" } },
	["近期内你若打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently" } }, --备注：if you[' ]h?a?ve dealt a critical strike recently
	["暴击后的 8 秒内，"] = { tag = { type = "Condition", var = "CritInPast8Sec" } }, --备注：if you[' ]h?a?ve crit in the past 8 seconds
	["若你在过去 8 秒内打出过暴击，则"] = { tag = { type = "Condition", var = "CritInPast8Sec" } }, --备注：if you[' ]h?a?ve dealt a critical strike in the past 8 seconds
	["近期内你若没有打出过暴击，则"] = { tag = { type = "Condition", var = "CritRecently", neg = true } }, --备注：if you haven't crit recently
	["近期内你若没有打出暴击，则"] = { tag = { type = "Condition", var = "CritRecently", neg = true } }, --备注：if you haven't dealt a critical strike recently
	["近期内你若造成非暴击伤害，则"] = { tag = { type = "Condition", var = "NonCritRecently" } }, --备注：if you[' ]h?a?ve dealt a non%-critical strike recently
	["if your skills have dealt a critical strike recently"] = { tag = { type = "Condition", var = "SkillCritRecently" } },
	["近期内你若有击败敌人，则"] = { tag = { type = "Condition", var = "KilledRecently" } }, --备注：if you[' ]h?a?ve killed recently
	["近期内你若没有击败敌人，则"] = { tag = { type = "Condition", var = "KilledRecently", neg = true } }, --备注：if you haven't killed recently
	["if you or your totems have killed recently"] = { tag = { type = "Condition", varList = {"KilledRecently","TotemsKilledRecently"} } },
	["if you[' ]h?a?ve killed a maimed enemy recently"] = { tagList = { { type = "Condition", var = "KilledRecently" }, { type = "ActorCondition", actor = "enemy", var = "Maimed" } } },
	["if you[' ]h?a?ve killed a cursed enemy recently"] = { tagList = { { type = "Condition", var = "KilledRecently" }, { type = "ActorCondition", actor = "enemy", var = "Cursed" } } },
	["if you[' ]h?a?ve killed a bleeding enemy recently"] = { tagList = { { type = "Condition", var = "KilledRecently" }, { type = "ActorCondition", actor = "enemy", var = "Bleeding" } } },
	["if you[' ]h?a?ve killed an enemy affected by your damage over time recently"] = { tag = { type = "Condition", var = "KilledAffectedByDotRecently" } },
	["近期内你若有冰冻敌人，则"] = { tag = { type = "Condition", var = "FrozenEnemyRecently" } }, --备注：if you[' ]h?a?ve frozen an enemy recently
	["点燃 1 个敌人后的短时间内，"] = { tag = { type = "Condition", var = "IgnitedEnemyRecently" } }, --备注：if you[' ]h?a?ve ignited an enemy recently
	["近期内你若感电任意敌人，则"] = { tag = { type = "Condition", var = "ShockedEnemyRecently" } }, --备注：if you[' ]h?a?ve shocked an enemy recently
	["若你近期内感电任意敌人，则"] = { tag = { type = "Condition", var = "ShockedEnemyRecently" } }, --备注：if you[' ]h?a?ve shocked an enemy recently
	["近期内你若被击中过，则"] = { tag = { type = "Condition", var = "BeenHitRecently" } }, --备注：if you[' ]h?a?ve been hit recently
	["if you were hit recently"] = { tag = { type = "Condition", var = "BeenHitRecently" } },
	["近期内你若因被击中而受伤，"] = { tag = { type = "Condition", var = "BeenHitRecently" } }, --备注：if you were damaged by a hit recently
	["if you[' ]h?a?ve taken a critical strike recently"] = { tag = { type = "Condition", var = "BeenCritRecently" } },
	["近期内你若受到【残暴打击】，则"] = { tag = { type = "Condition", var = "BeenSavageHitRecently" } }, --备注：if you[' ]h?a?ve taken a savage hit recently
	["近期内你若没有被击中，则"] = { tag = { type = "Condition", var = "BeenHitRecently", neg = true } }, --备注：if you have ?n[o']t been hit recently
	["近期内你若被击中但没有受到伤害，则"] = { tag = { type = "Condition", var = "BeenHitRecently", neg = true } }, --备注：if you[' ]h?a?ve taken no damage from hits recently
	["近期内，你若被击中并受到火焰伤害，则"] = { tag = { type = "Condition", var = "HitByFireDamageRecently" } }, --备注：if you[' ]h?a?ve taken fire damage from a hit recently
	["格挡后的短时间内"] = { tag = { type = "Condition", var = "BlockedRecently" } }, --备注：if you[' ]h?a?ve blocked recently
	["近期内你若格挡过攻击，则"] = { tag = { type = "Condition", var = "BlockedAttackRecently" } }, --备注：if you[' ]h?a?ve blocked an attack recently
	["近期内你若格挡过法术，则"] = { tag = { type = "Condition", var = "BlockedSpellRecently" } }, --备注：if you[' ]h?a?ve blocked a spell recently
	["过去 10 秒内你若成功格挡传奇怪物，则"] = { tag = { type = "Condition", var = "BlockedHitFromUniqueEnemyInPast10Sec" } }, --备注：if you[' ]h?a?ve blocked damage from a unique enemy in the past 10 seconds
	["近期内你若有进行攻击，则"] = { tag = { type = "Condition", var = "AttackedRecently" } }, --备注：if you[' ]h?a?ve attacked recently
	["近期内你若有施放法术，则"] = { tag = { type = "Condition", var = "CastSpellRecently" } }, --备注：if you[' ]h?a?ve cast a spell recently
	["近期内你若有消耗灵柩，则"] = { tag = { type = "Condition", var = "ConsumedCorpseRecently" } }, --备注：if you[' ]h?a?ve consumed a corpse recently
	["若你近期内有消耗灵柩，则"] = { tag = { type = "Condition", var = "ConsumedCorpseRecently" } }, --备注：if you[' ]h?a?ve consumed a corpse recently
	["每消耗 1 具灵柩后的短时间内，"] = { tag = { type = "Multiplier", var = "CorpseConsumedRecently" } }, --备注：for each corpse consumed recently
	["近期内你若有成功嘲讽敌人，则"] = { tag = { type = "Condition", var = "TauntedEnemyRecently" } }, --备注：if you[' ]h?a?ve taunted an enemy recently
	["若你近期内有成功嘲讽敌人，则"] = { tag = { type = "Condition", var = "TauntedEnemyRecently" } }, --备注：if you[' ]h?a?ve taunted an enemy recently
	["近期内你若有使用技能，"] = { tag = { type = "Condition", var = "UsedSkillRecently" } }, --备注：if you[' ]h?a?ve used a skill recently
	["for each skill you've used recently, up to (%d+)%%"] = function(num) return { tag = { type = "Multiplier", var = "SkillUsedRecently", limit = num, limitTotal = true } } end,
	["近期内你若使用过战吼，则"] = { tag = { type = "Condition", var = "UsedWarcryRecently" } }, --备注：if you[' ]h?a?ve used a warcry recently
	["近期内你若有使用战吼，"] = { tag = { type = "Condition", var = "UsedWarcryRecently" } }, --备注：if you[' ]h?a?ve warcried recently
	["for each of your mines detonated recently, up to (%d+)%%"] = function(num) return { tag = { type = "Multiplier", var = "MineDetonatedRecently", limit = num, limitTotal = true } } end,
	["for each of your traps triggered recently, up to (%d+)%%"] = function(num) return { tag = { type = "Multiplier", var = "TrapTriggeredRecently", limit = num, limitTotal = true } } end,
	["近期内你若使用过火焰技能，则"] = { tag = { type = "Condition", var = "UsedFireSkillRecently" } }, --备注：if you[' ]h?a?ve used a fire skill recently
	["近期内你若使用过冰霜技能，则"] = { tag = { type = "Condition", var = "UsedColdSkillRecently" } }, --备注：if you[' ]h?a?ve used a cold skill recently
	["if you[' ]h?a?ve used a fire skill in the past 10 seconds"] = { tag = { type = "Condition", var = "UsedFireSkillInPast10Sec" } },
	["if you[' ]h?a?ve used a cold skill in the past 10 seconds"] = { tag = { type = "Condition", var = "UsedColdSkillInPast10Sec" } },
	["if you[' ]h?a?ve used a lightning skill in the past 10 seconds"] = { tag = { type = "Condition", var = "UsedLightningSkillInPast10Sec" } },
	["近期内你若有召唤图腾，"] = { tag = { type = "Condition", var = "SummonedTotemRecently" } }, --备注：if you[' ]h?a?ve summoned a totem recently
	["若你近期内有召唤图腾，"] = { tag = { type = "Condition", var = "SummonedTotemRecently" } }, --备注：if you[' ]h?a?ve summoned a totem recently
	["近期内你若使用了召唤生物技能，则"] = { tag = { type = "Condition", var = "UsedMinionSkillRecently" } }, --备注：if you[' ]h?a?ve used a minion skill recently
	["若你近期内使用了召唤生物技能，则"] = { tag = { type = "Condition", var = "UsedMinionSkillRecently" } }, --备注：if you[' ]h?a?ve used a minion skill recently
	["近期内你若有使用过位移技能，则"] = { tag = { type = "Condition", var = "UsedMovementSkillRecently" } }, --备注：if you[' ]h?a?ve used a movement skill recently
	["近期内你若使用过瓦尔技能，则"] = { tag = { type = "Condition", var = "UsedVaalSkillRecently" } }, --备注：if you[' ]h?a?ve used a vaal skill recently
	["近期内你若引爆过地雷，则"] = { tag = { type = "Condition", var = "DetonatedMinesRecently" } }, --备注：if you detonated mines recently
	["近期内若有能量护盾开始回复，则"] = { tag = { type = "Condition", var = "EnergyShieldRechargeRecently" } }, --备注：if energy shield recharge has started recently
	["在【寒冰弹】上施放时，"] = { tag = { type = "Condition", var = "CastOnFrostbolt" } }, --备注：when cast on frostbolt
	-- Enemy status conditions
	["at close range"] = { tag = { type = "Condition", var = "AtCloseRange" }},
	["against rare and unique enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "RareOrUnique" } },
	["against enemies on full life"] = { tag = { type = "ActorCondition", actor = "enemy", var = "FullLife" } },
	["对满血敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "FullLife" } }, --备注：against enemies that are on full life
	["对低血敌人，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "LowLife" } }, --备注：against enemies on low life
	["击中低血的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "LowLife" } }, --备注：against enemies that are on low life
	["已被诅咒的敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Cursed" } }, --备注：against cursed enemies
	["攻击击中被诅咒敌人时有"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Cursed" }, keywordFlags = KeywordFlag.Hit }, --备注：when hitting cursed enemies
	["攻击被嘲讽的敌人时，"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Taunted" } }, --备注：against taunted enemies
	["对流血敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Bleeding" }}, --备注：against bleeding enemies
	["to bleeding enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Bleeding" } },
	["对中毒敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Poisoned" } }, --备注：against poisoned enemies
	["to poisoned enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Poisoned" }},
	["against enemies affected by (%d+) or more poisons"] = function(num) return { tag = { type = "MultiplierThreshold", actor = "enemy", var = "PoisonStack", threshold = num } } end,
	["against enemies affected by at least (%d+) poisons"] = function(num) return { tag = { type = "MultiplierThreshold", actor = "enemy", var = "PoisonStack", threshold = num } } end,
	["对被干扰敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Hindered" }}, --备注：against hindered enemies
	["against maimed enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Maimed" }},
	["对致盲敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Blinded" } }, --备注：against blinded enemies
	["against burning enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Burning" } },
	["对点燃敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" } }, --备注：against ignited enemies
	["被点燃敌人时"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Ignited" }}, --备注：to ignited enemies
	["对感电敌人的击中"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Shocked" } }, --备注：against shocked enemies
	["to shocked enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Shocked" } },
	["对被冰冻敌人的击中"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Frozen" }}, --备注：against frozen enemies
	["to frozen enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Frozen" }},
	["对冰缓敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } }, --备注：against chilled enemies
	["to chilled enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } },
	["inflicted on chilled enemies"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } },
	["被冰缓的敌人"] = { tag = { type = "ActorCondition", actor = "enemy", var = "Chilled" } }, --备注：enemies which are chilled
	["对被冰冻、感电、点燃敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", varList = {"Frozen","Shocked","Ignited"} } }, --备注：against frozen, shocked or ignited enemies
	["against enemies affected by elemental ailments"] = { tag = { type = "ActorCondition", actor = "enemy", varList = {"Frozen","Chilled","Shocked","Ignited"} }},
	["对元素异常状态的敌人的"] = { tag = { type = "ActorCondition", actor = "enemy", varList = {"Frozen","Chilled","Shocked","Ignited"} }}, --备注：against enemies that are affected by elemental ailments
	["对没有受到元素异常状态的敌人的"] = { tagList = { { type = "ActorCondition", actor = "enemy", varList = {"Frozen","Chilled","Shocked","Ignited"}, neg = true }, { type = "Condition", var = "Effective" } } }, --备注：against enemies that are affected by no elemental ailments
	["对受 (%d+) 层蜘蛛网影响的敌人，"] = function(num) return { tag = { type = "MultiplierThreshold", actor = "enemy", var = "Spider's WebStack", threshold = num } } end, --备注：against enemies affected by (%d+) spider's webs
	-- Enemy multipliers
	["per freeze, shock and ignite on enemy"] = { tag = { type = "Multiplier", var = "FreezeShockIgniteOnEnemy" } },
	["per poison affecting enemy"] = { tag = { type = "Multiplier", actor = "enemy", var = "PoisonStack" } },
	["per poison affecting enemy, up to %+([%d%.]+)%%"] = function(num) return { tag = { type = "Multiplier", actor = "enemy", var = "PoisonStack", limit = num, limitTotal = true } } end,
	["敌人身上每有 1 层蜘蛛网，则"] = { tag = { type = "Multiplier", actor = "enemy", var = "Spider's WebStack" } }, --备注：for each spider's web on the enemy
}

local mod = modLib.createMod
local function flag(name, ...)
	return mod(name, "FLAG", true, ...)
end

local gemIdLookup = { 
["power charge on critical strike"] = "SupportPowerChargeOnCrit"
}
local gemIdLookupPlayer = { 
["power charge on critical strike"] = "SupportPowerChargeOnCrit"
}



local function  ExtractSupportCnName(support_skillname)


support_skillname = support_skillname:gsub("灵魂滋养","启迪（辅）"):gsub("魔力减免","启迪（辅）"):gsub("遥控地雷","链爆地雷（辅）")
	:gsub("连环地雷","链爆地雷（辅）")
	:gsub("流血几率","几率流血(辅)")
	:gsub("【召唤幻灵】","召唤幻影（辅）")
	:gsub("召唤幻灵辅助","召唤幻影（辅）")
	:gsub("召唤幻灵","召唤幻影（辅）")
	:gsub("召唤幻影辅助","召唤幻影（辅）")
	:gsub("启迪辅助","启迪（辅）")
	:gsub("链爆地雷辅助","链爆地雷（辅）")
	:gsub("范围效果扩大（强辅）","增大范围（强辅）")
	:gsub("范围效果扩大（辅）","增大范围（辅）")

return
 gemIdLookupPlayer[support_skillname] or gemIdLookupPlayer[support_skillname:gsub("^提高","")] 
	or gemIdLookupPlayer[support_skillname.."(辅)"] 
	or gemIdLookupPlayer[support_skillname.."（辅）"]   
	or gemIdLookupPlayer[support_skillname:gsub("^提高","增加").."(辅)"]  
	or gemIdLookupPlayer[support_skillname:gsub("^提高","增加").."（辅）"]  
	or gemIdLookupPlayer[support_skillname:gsub("先祖呼唤","先祖召唤").."(辅)"] 
	or gemIdLookupPlayer[support_skillname:gsub("先祖呼唤","先祖召唤").."（辅）"] 
	or gemIdLookupPlayer[support_skillname:gsub("渎神","诅咒光环").."(辅)"] 
	or gemIdLookupPlayer[support_skillname:gsub("渎神","诅咒光环").."（辅）"] 
	or gemIdLookupPlayer[support_skillname.."辅助"]
	or gemIdLookup[support_skillname] or gemIdLookup[support_skillname:gsub("^提高","")] or gemIdLookup[support_skillname.."(辅)"] or gemIdLookup[support_skillname.."（辅）"]   or gemIdLookup[support_skillname:gsub("^提高","增加").."(辅)"]  
	or gemIdLookup[support_skillname:gsub("^提高","增加").."（辅）"]  
	or gemIdLookup[support_skillname:gsub("先祖呼唤","先祖召唤").."(辅)"] 
	or gemIdLookup[support_skillname:gsub("先祖呼唤","先祖召唤").."（辅）"] 
	or gemIdLookup[support_skillname:gsub("渎神","诅咒光环").."(辅)"] 
	or gemIdLookup[support_skillname:gsub("渎神","诅咒光环").."（辅）"] 
	or gemIdLookup[support_skillname.."辅助"]
	or "未知："..support_skillname

end


local function  FuckSkillSupportCnName(support_skillname)
	local skillid = ExtractSupportCnName(support_skillname)
	if skillid == 'SupportCastOnCrit' then 
		return 'SupportCastOnCritTriggered'
	elseif skillid == 'SupportCastOnCritPlus' then 
		return 'SupportCastOnCritTriggeredPlus'
	end 
	return skillid
end

local function  FuckSkillActivityCnName(activity_skillname)

if activity_skillname == nil then 

	return "未知"
else

	return activity_skillname:gsub("狂野部族打击","野性打击") :gsub("火舌图腾","圣焰图腾"):gsub("霜害","寒霜爆")
	:gsub("极地吐息","电光寒霜")
	:gsub("深渊战吼","炼狱呼嚎")
	:gsub("裂地崩山","尖刺战吼")
	
	:gsub("天雷之兆","闪电之捷")
	:gsub("绝命之镰","赤炼绝命")
	
	:gsub("骄傲","尊严")
	
	

end
end


for name, grantedEffect in pairs(data.skills) do
		 if not grantedEffect.hidden or grantedEffect.fromItem  or grantedEffect.fromTree then
			if not gemIdLookupPlayer[grantedEffect.name:lower()] then
				gemIdLookupPlayer[grantedEffect.name:lower()] = grantedEffect.id
			elseif  not grantedEffect.hidden or grantedEffect.fromItem  or grantedEffect.fromTree then
				gemIdLookupPlayer[grantedEffect.name:lower()] = grantedEffect.id
			end 
		 end
		 
		if not gemIdLookup[grantedEffect.name:lower()] then
			gemIdLookup[grantedEffect.name:lower()] = grantedEffect.id
		elseif  not grantedEffect.hidden or grantedEffect.fromItem  or grantedEffect.fromTree then
			gemIdLookup[grantedEffect.name:lower()] = grantedEffect.id
		end 
	--end
end
local function grantedExtraSkill(name, level, noSupports)
	name = name:gsub(" skill","")
	
	if gemIdLookupPlayer[name] then
		return { 
			mod("ExtraSkill", "LIST", { skillId = gemIdLookupPlayer[name], level = level, noSupports = noSupports }) 
		}
	end
	if gemIdLookup[name] then
		return { 
			mod("ExtraSkill", "LIST", { skillId = gemIdLookup[name], level = level, noSupports = noSupports }) 
		}
	end
end
local function triggerExtraSkill(name, level, noSupports)
	name = name:gsub(" skill","")
	
	if gemIdLookupPlayer[name] then
		return { 
			mod("ExtraSkill", "LIST", { skillId = gemIdLookupPlayer[name], level = level, noSupports = noSupports, triggered = true }) 
		}
	end
	if gemIdLookup[name] then
		return { 
			mod("ExtraSkill", "LIST", { skillId = gemIdLookup[name], level = level, noSupports = noSupports, triggered = true }) 
		}
	end
	
end

local function triggerExtraSkillWithSource(name, level, sourceSkill, noSupports)
	name = name:gsub(" skill","")
	sourceSkill = sourceSkill:gsub(" ", ""):gsub("'","")
	if gemIdLookupPlayer[name] then
		return {
			mod("ExtraSkill", "LIST", { skillId = gemIdLookup[name], level = level, noSupports = noSupports, triggered = true, source = sourceSkill })
		}
	end
	if gemIdLookup[name] then
		return {
			mod("ExtraSkill", "LIST", { skillId = gemIdLookup[name], level = level, noSupports = noSupports, triggered = true, source = sourceSkill })
		}
	end
	
	
end

-- List of special modifiers
local specialModList = {
	--【中文化程序额外添加开始】
	["插入的技能石同时消耗生命并保留生命而非消耗和保留魔力"]= { mod("ExtraSupport", "LIST", { skillId = "SupportBloodMagicUniquePrismGuardian", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["此物品上的技能石受到 血魔法 辅助"]= { mod("ExtraSupport", "LIST", { skillId = "SupportBloodMagicUniquePrismGuardian", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	-- Legion modifiers
	["主手总攻击速度额外加快 (%d+)%%"] = function(num) return { mod("Speed", "MORE", num,nil, ModFlag.Attack, { type = "Condition", var = "MainHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }) } end,
	["副手暴击率 %+([%d%.]+)%%"] = function(num) return { mod("CritChance", "BASE", num, { type = "Condition", var = "OffHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }) } end,
	["能量护盾回复率提高 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecoveryRate", "INC", num)  } end,
	["魔力回复率提高 (%d+)%%"] = function(num) return {  mod("ManaRecoveryRate", "INC", num)  } end,
	["生命回复率提高 (%d+)%%"] = function(num) return {  mod("LifeRecoveryRate", "INC", num)  } end,
	["passives in radius are conquered by the (%D+)"] = { },
	["historic"] = { },
	["获得(.+)麾下 (%d+) 名武士的领导权"]= function(_, npcName, num) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["获得(.+)麾下 (%d+) 名武士的领导权  范围内的天赋被卡鲁抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["获得(.+)麾下 (%d+) 名武士的领导权范围内的天赋被卡鲁抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用 (%d+) 名祭品之血浸染"]= function(_, npcName, num) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用  (%d+) 名祭品之血浸染范围内的天赋被瓦尔抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用 (%d+) 名祭品之血浸染  范围内的天赋被瓦尔抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用  (%d+) 名祭品之血浸染 范围内的天赋被瓦尔抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用 (%d+) 名祭品之血浸染 范围内的天赋被瓦尔抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["以(.+)的名义用(%d+)名祭品之血浸染范围内的天赋被瓦尔抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["赞美 (%d+) 名被高阶圣堂武僧(.+)转化的新信徒"]= function(_, num, npcName) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["赞美 (%d+) 名被高阶圣堂武僧(.+)转化的新信徒范围内的天赋被圣堂抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["赞美 (%d+) 名被高阶圣堂武僧(.+)转化的新信徒  范围内的天赋被圣堂抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["赞美 (%d+) 名被神主(.+)转化的新信徒范围内的天赋被圣堂教团抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["赞美 (%d+) 名被神主(.+)转化的新信徒"]= function(_, num, npcName) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["在(.+)的阿卡拉中指派 (%d+) 名德卡拉的服务"]= function(_, npcName, num) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["在(.+)的阿卡拉中指派 (%d+) 名德卡拉的服务范围中的天赋被马拉克斯抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["在(.+)的阿卡拉中指派 (%d+) 名德卡拉的服务  范围中的天赋被马拉克斯抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["在(.+)的阿卡拉中指派 (%d+) 名德卡拉的服务范围中的天赋被马拉克斯抑制"]= function(_, npcName, num) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["用 (%d+) 枚金币纪念(.+)"]= function(_, num, npcName) return {  mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["用 (%d+) 枚金币纪念(.+)范围内的天赋被永恒帝国抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["用 (%d+) 枚金币纪念(.+)  范围内的天赋被永恒帝国抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["用 (%d+) 枚金币纪念(.+)范围内的天赋被永恒帝国抑制"]= function(_, num, npcName) return {
	mod("JewelData", "LIST",
	{key = "conqueredBy", value = {id = num, conqueror = conquerorList[npcName:lower()] } })} end,
	["内在信念"] =  { mod("Keystone", "LIST", "内在信念") },
	["史实"] = { mod("Multiplier:HistoricItem", "BASE", 1) },
	["([%+%-]?%d+) 奉献"]= function(num) return {
	mod("Devotion", "BASE", num)
	}end,
	--能量护盾回复问题
	--（有带“的”的词缀解析为充能速度，不带“的”的解析为回复速度）
	["能量护盾的回复速度提高 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecharge", "INC", num)  } end,
	["能量护盾的回复速度降低 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecharge", "INC", -num)  } end,
	["能量护盾的充能速度提高 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecharge", "INC", num)  } end,
	["能量护盾的充能速度降低 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecharge", "INC", -num)  } end,
	["能量护盾回复速度提高 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecoveryRate", "INC", num)  } end,
	["能量护盾回复速度降低 (%d+)%%"] = function(num) return {  mod("EnergyShieldRecoveryRate", "INC", -num)  } end,
	-- 星团珠宝
	["附加 (%d+) 天赋点"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelNodeCount", value = num }) } end,
	["增加 (%d+) 个天赋技能"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelNodeCount", value = num }) } end,
	["其中 1 个增加的天赋为【珠宝槽】"] = { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = 1 }) },
	["其中 (%d+) 个增加的天赋为【珠宝槽】"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = num }) } end,
	["增加 (%d+) 个珠宝插槽天赋"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelSocketCountOverride", value = num }) } end,
	["增加 (%d+) 个无特殊效果的小天赋"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelNothingnessCount", value = num }) } end,
	["增加的小天赋无效果"] = { mod("JewelData", "LIST", { key = "clusterJewelSmallsAreNothingness", value = true }) },
	["增加的小天赋效果提高 (%d+)%%"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelIncEffect", value = num }) } end,
	-- 部分带召唤生物的装备内置技能  { type = "SkillId", skillId = "" }
	["使用该武器暴击时，有 (%d+)%% 几率触发 (%d+) 级的【召唤幽狼】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonRigwaldsPack", level = tonumber(levelname), triggered = true})   } end,
	["使用该武器暴击时，有 (%d+)%% 的几率触发 (%d+) 级的【召唤幽狼】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonRigwaldsPack", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 几率触发 (%d+) 级的【幻化武器】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="AnimateWeapon", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 几率触发 (%d+) 级的【召唤异动奇点】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonVoidSphere", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 几率触发 (%d+) 级的【召唤幽狼】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonRigwaldsPack", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 的几率触发 (%d+) 级的【幻化武器】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="AnimateWeapon", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 的几率触发 (%d+) 级的【召唤异动奇点】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonVoidSphere", level = tonumber(levelname), triggered = true})   } end,
	["击败敌人时有 (%d+)%% 的几率触发 (%d+) 级的【召唤幽狼】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonRigwaldsPack", level = tonumber(levelname), triggered = true})   } end,
	["获得 (%d+) 级的【召唤兽化之爪】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonBeastialUrsa", level = num})   } end,
	["获得 (%d+) 级的【召唤兽化巨蛇】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonBeastialSnake", level = num})   } end,
	["获得 (%d+) 级的【召唤兽化恐喙鸟】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonBeastialRhoa", level = num})   } end,
	--这里不要less？
	--local sumLocal
	["该装备的攻击暴击率提高 (%d+)%%"] = function(num) return {  mod("CritChance", "INC", num)  } end,
	--负数范围特殊处理
	["提高 ([%+%-]?%d+)%% 药剂充能消耗"]= function(num) return {  mod("FlaskChargesUsed", "INC", num)  } end,
	["(%d+)%% 法术伤害格挡几率"] = function(num) return {  mod("SpellBlockChance", "BASE", num) } end,
	["(%d+)%% 法术格挡几率"] = function(num) return {  mod("SpellBlockChance", "BASE", num) } end,
	["(%d+)%% 攻击伤害格挡率"] = function(num) return {  mod("BlockChance", "BASE", num) } end,
	["(%d+)%% 攻击格挡几率"] = function(num) return {  mod("BlockChance", "BASE", num) } end,
	["被诅咒时法术伤害格挡几率提高 (%d+)%%"]= function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "Cursed" })  } end,
	--处理【狂怒】和【狂怒】2个不同技能的附魔， 国服特别优秀的翻译
	["【狂怒】的伤害提高 (%d+)%%"]= function(num) return {
	mod("Damage", "INC", num, { type = "SkillId", skillId = "Frenzy" })
	} end,
	["每个狂怒球可使狂怒伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", tonumber(num),{ type = "Multiplier", var = "FrenzyCharge" },{ type = "SkillId", skillId = "Frenzy" })  } end,
	--Berserk
	["【狂怒】的增益效果提高 25%"]= function(num) return {
	mod("BuffEffect", "INC", num,{ type = "SkillId", skillId = "Berserk" })
	} end,
	["【盛怒】的增益效果提高 25%"]= function(num) return {
	mod("BuffEffect", "INC", num,{ type = "SkillId", skillId = "Berserk" })
	} end,
	["每 10 点智慧可以为攻击附加 0 %- 3 基础闪电伤害"]= function() return {
	mod("LightningMax", "BASE", 3,nil, ModFlag.Attack,  { type = "PerStat", stat = "Int", div = 10 })
	}end,
	--fu*k TX 格挡率用“提高”字样
	["药剂持续期间，攻击伤害格挡几率 ([%+%-]?%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，攻击格挡率提高 ([%+%-]?%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，法术伤害格挡几率提高 ([%+%-]?%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，法术格挡率提高 ([%+%-]?%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂生效期间，攻击伤害格挡几率 ([%+%-]?%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂生效期间，法术伤害格挡率 ([%+%-]?%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["每个暴击球可使法术格挡几率提高 ([%+%-]?%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num, { type = "Multiplier", var = "PowerCharge" })  } end,
	["每有 (%d+) 点力量，攻击伤害格挡几率额外 ([%+%-]?%d+)%%"] = function(_,num1,num2) return {  mod("BlockChance", "BASE", tonumber(num2),{ type = "PerStat", stat = "Str", div = tonumber(num1) })  } end,
	["持长杖时，攻击格挡率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "UsingStaff" })  } end,
	["持长杖时法术伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "UsingStaff" })  } end,
	["持盾时攻击格挡率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num, { type = "Condition", var = "UsingShield" } )  } end,
	["持盾牌时法术格挡率提高 (%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num, { type = "Condition", var = "UsingShield" } ) } end,
	["双持时攻击格挡率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num, { type = "Condition", var = "DualWielding" } )  } end,
	["双持攻击时武器暴击率提高 (%d+)%%"] = function(num) return {  mod("CritChance", "INC", num, { type = "Condition", var = "DualWielding" } )  } end,
	["双持或持盾牌时攻击格挡率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", varList = { "DualWielding", "UsingShield" } })  } end,
	["近期内你若因被击中而受伤，攻击格挡率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" } )  } end,
	["持长杖时，攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "UsingStaff" })  } end,
	["持盾时攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num, { type = "Condition", var = "UsingShield" } )  } end,
	["持盾牌时攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num, { type = "Condition", var = "UsingShield" } )  } end,
	["持盾牌时法术伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("SpellBlockChance", "BASE", num, { type = "Condition", var = "UsingShield" } ) } end,
	["双持时攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num, { type = "Condition", var = "DualWielding" } )  } end,
	["双持或持盾牌时攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", varList = { "DualWielding", "UsingShield" } })  } end,
	["近期内你若因被击中而受伤，攻击伤害格挡几率提高 (%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" } )  } end,
	["(%d+)%% 攻击伤害格挡几率"] = function(num) return {  mod("BlockChance", "BASE", num)  } end,
	["近期内你若有被击中，则每秒回复 ([%d%.]+)%% 生命和魔力"] = function(num) return {
	mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "BeenHitRecently" } ),
	mod("ManaRegenPercent", "BASE", num,{ type = "Condition", var = "BeenHitRecently" } ),
	} end,
	["近期内你若有被击中，则每秒回复 ([%d%.]+)%% 生命"] = function(num) return {
	mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "BeenHitRecently" } )
	} end,
	["非诅咒类光环的效果提高 (%d+)%%"]= function(num) return {  mod("AuraEffect", "INC", tonumber(num),{ type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } )  } end,
	["所有身上装备的物品皆为已腐化时，每秒回复 (%d+) 能量护盾"] = function(num) return {  mod("EnergyShieldRegen", "BASE", num,{ type = "MultiplierThreshold", var = "NonCorruptedItem", threshold = 0, upper = true })  } end,
	["感电时，每秒回复 (%d+)%% 能量护盾"] = function(num) return {  mod("EnergyShieldRegenPercent", "BASE", num,{ type = "Condition", var = "Shocked" })  } end,
	["此物品上装备的【技能石】品质 %+(%d+)%%"] = function(num) return { mod("GemProperty", "LIST",  { keyword = "all", key = "quality", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上装备的【辅助技能石】品质 %+(%d+)%%"] = function(num) return { mod("GemProperty", "LIST",  { keyword = "support", key = "quality", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上装备的【([^\\x00-\\xff]*)石】等级 %+(%d+)"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keyword = type_Cn
	:gsub("效果区域技能","aoe")
	:gsub("物理法术技能","physical_spell")
	:gsub("混沌法术技能","chaos_spell")
	:gsub("光环技能","aura")
	:gsub("绿色技能","dexterity")
	:gsub("蓝色技能","intelligence")
	:gsub("红色技能","strength")
	:gsub("闪电技能","lightning")
	:gsub("辅助技能","support")
	:gsub("火焰技能","fire")
	:gsub("冰霜技能","cold")
	:gsub("混沌技能","chaos")
	:gsub("物理技能","physical")
	:gsub("魔像技能","golem")
	:gsub("召唤生物技能","minion")
	:gsub("近战技能","melee")
	:gsub("战吼技能","warcry")
	:gsub("瓦尔技能","vaal")
	:gsub("移动技能","movement")
	:gsub("弓技能","bow")
	:gsub("诅咒技能","curse")
	:gsub("捷技能","herald")
	:gsub("法术技能","spell")
	:gsub("主动技能","active_skill")
	:gsub("持续时间技能","duration")
	:gsub("陷阱技能石】或【地雷技能","trap or mine")
	:gsub("投射物技能","projectile")
	:gsub("持续吟唱技能","channelling")
	:gsub("范围效果技能","aoe")
	, key = "level", value = tonumber(num) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["所有物品上装备的【([^\\x00-\\xff]*)石】等级 %+(%d+)"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keywordList =  {"active_skill", type_Cn
	:gsub("效果区域技能","aoe")
	:gsub("物理法术技能","physical_spell")
	:gsub("混沌法术技能","chaos_spell")
	:gsub("光环技能","aura")
	:gsub("敏捷技能","dexterity")
	:gsub("智慧技能","intelligence")
	:gsub("智力技能","intelligence")
	:gsub("力量技能","strength")
	:gsub("绿色技能","dexterity")
	:gsub("蓝色技能","intelligence")
	:gsub("红色技能","strength")
	:gsub("闪电技能","lightning")
	:gsub("辅助技能","support")
	:gsub("火焰技能","fire")
	:gsub("冰霜技能","cold")
	:gsub("混沌技能","chaos")
	:gsub("物理技能","physical")
	:gsub("魔像技能","golem")
	:gsub("召唤生物技能","minion")
	:gsub("近战技能","melee")
	:gsub("战吼技能","warcry")
	:gsub("瓦尔技能","vaal")
	:gsub("移动技能","movement")
	:gsub("弓技能","bow")
	:gsub("诅咒技能","curse")
	:gsub("捷技能","herald")
	:gsub("法术技能","spell")
	:gsub("主动技能","active_skill")
	:gsub("持续时间技能","duration")
	:gsub("陷阱技能石】或【地雷技能","trap or mine")
	:gsub("投射物技能","projectile")
	:gsub("持续吟唱技能","channelling")
	:gsub("范围效果技能","aoe")
	}, key = "level", value = tonumber(num) }) } end,
	["所有法术技能石等级 %+(%d+)"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keywordList =  {"active_skill", "spell"}, key = "level", value = tonumber(num) }) } end,
	["所有([^\\x00-\\xff]*)法术技能石等级 %+(%d+)"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keywordList =  {"active_skill", "spell",type_Cn
	:gsub("效果区域技能","aoe")
	:gsub("光环","aura")
	:gsub("绿色","dexterity")
	:gsub("蓝色","intelligence")
	:gsub("红色","strength")
	:gsub("闪电","lightning")
	:gsub("辅助","support")
	:gsub("火焰","fire")
	:gsub("冰霜","cold")
	:gsub("混沌","chaos")
	:gsub("物理","physical")
	:gsub("魔像","golem")
	:gsub("召唤生物","minion")
	:gsub("近战","melee")
	:gsub("战吼","warcry")
	:gsub("瓦尔","vaal")
	:gsub("移动","movement")
	:gsub("弓","bow")
	:gsub("诅咒","curse")
	:gsub("捷","herald")
	:gsub("法术","spell")
	:gsub("主动","active_skill")
	:gsub("持续时间","duration")
	:gsub("陷阱或地雷","trap or mine")
	:gsub("投射物","projectile")
	:gsub("持续吟唱","channelling")
	:gsub("范围效果","aoe")
	}, key = "level", value = tonumber(num) }) } end,
	["([%+%-]?%d+)%% 召唤灵体, 魔卫复苏, 召唤魔侍的暴击伤害"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("CritMultiplier", "BASE", num) },{ type = "SkillName", skillNameList = { "召唤灵体", "魔卫复苏", "召唤魔侍" } })  } end,
	["【召唤魔侍】 (%d+)%% 的物理伤害会转化为混沌伤害"]
	= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageConvertToChaos", "BASE", num) }, { type = "SkillName", skillName = "召唤魔侍" }) } end,
	["所有([^\\x00-\\xff]*)石等级 %+(%d+)"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keywordList =  {"active_skill",  type_Cn
	:gsub("效果区域技能","aoe")
	:gsub("物理法术技能","physical_spell")
	:gsub("混沌法术技能","chaos_spell")
	:gsub("敏捷技能","dexterity")
	:gsub("智慧技能","intelligence")
	:gsub("力量技能","strength")
	:gsub("光环技能","aura")
	:gsub("绿色技能","dexterity")
	:gsub("智慧技能","intelligence")
	:gsub("蓝色技能","intelligence")
	:gsub("红色技能","strength")
	:gsub("闪电技能","lightning")
	:gsub("辅助技能","support")
	:gsub("火焰技能","fire")
	:gsub("冰霜技能","cold")
	:gsub("混沌技能","chaos")
	:gsub("物理技能","physical")
	:gsub("魔像技能","golem")
	:gsub("召唤生物技能","minion")
	:gsub("近战技能","melee")
	:gsub("战吼技能","warcry")
	:gsub("瓦尔技能","vaal")
	:gsub("移动技能","movement")
	:gsub("弓技能","bow")
	:gsub("诅咒技能","curse")
	:gsub("捷技能","herald")
	:gsub("法术技能","spell")
	:gsub("主动技能","active_skill")
	:gsub("持续时间技能","duration")
	:gsub("陷阱技能石】或【地雷技能","trap or mine")
	:gsub("投射物技能","projectile")
	:gsub("持续吟唱技能","channelling")
	:gsub("范围效果技能","aoe")
	}, key = "level", value = tonumber(num) }) } end,
	["此物品上装备的【([^\\x00-\\xff]*)石】品质 %+(%d+)%%"] = function( _, type_Cn,num) return { mod("GemProperty", "LIST", {
	keyword = type_Cn:gsub("光环技能","aura")
	:gsub("效果区域技能","aoe")
	:gsub("绿色技能","dexterity")
	:gsub("蓝色技能","intelligence")
	:gsub("红色技能","strength")
	:gsub("闪电技能","lightning")
	:gsub("辅助技能","support")
	:gsub("火焰技能","fire")
	:gsub("冰霜技能","cold")
	:gsub("混沌技能","chaos")
	:gsub("物理技能","physical")
	:gsub("魔像技能","golem")
	:gsub("召唤生物技能","minion")
	:gsub("近战技能","melee")
	:gsub("战吼技能","warcry")
	:gsub("瓦尔技能","vaal")
	:gsub("移动技能","movement")
	:gsub("弓技能","bow")
	:gsub("诅咒技能","curse")
	:gsub("捷技能","herald")
	:gsub("法术技能","spell")
	:gsub("主动技能","active_skill")
	:gsub("持续时间技能","duration")
	:gsub("陷阱技能石】或【地雷技能","trap or mine")
	:gsub("投射物技能","projectile")
	:gsub("持续吟唱技能","channelling")
	:gsub("范围效果技能","aoe")
	:gsub("技能","all")
	, key = "quality", value = tonumber(num) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	-- 一些涉及到技能名称的
	["奉献技能的持续时间降低 (%d+)%%"] =  function(num) return {  mod("Duration", "INC", -num,
	{ type = "SkillName", skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} } )  } end,
	["奉献技能的效果降低 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffect", "INC", -num) }, { type = "SkillName",
	skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} }) } end,
	["奉献效果降低 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffect", "INC", -num) }, { type = "SkillName",
	skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} }) } end,
	["奉献效果提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffect", "INC", num) }, { type = "SkillName",
	skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} }) } end,
	["你的奉献技能会同时影响你"] = { mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "buffNotPlayer", value = false }) },
	{ type = "SkillName", skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} }) },
	["你的奉献技能对自身的效果降低 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffectOnPlayer", "INC", -num) }, { type = "SkillName",
	skillNameList = { "骸骨奉献", "血肉奉献", "灵魂奉献" ,"血脉奉献"} }) } end,
	["【闪现射击】和【魅影射击】冷却回复速度提高 (%d+)%%"] = function(num) return { --备注：(%d+)%% increased blink arrow and mirror arrow cooldown recovery speed
	mod("CooldownRecovery", "INC", num, { type = "SkillName", skillName = "闪现射击" }),
	mod("CooldownRecovery", "INC", num, { type = "SkillName", skillName = "魅影射击" }),
	} end,
	["【异灵魔侍】的击中无法闪避"] = { mod("MinionModifier", "LIST", { mod = flag("CannotBeEvaded") }, { type = "SkillName", skillName = "召唤魔侍" }) }, --备注：summoned skeletons' hits can't be evaded
	["每有 (%d+) 点敏捷，你的攻城炮台图腾数量上限便提高 1 个"] = function(num) return { mod("ActiveTotemLimit", "BASE", 1, { type = "SkillName", skillName = "攻城炮台" }, { type = "PerStat", stat = "Dex", div = num }) } end,
	["每有 (%d+) 敏捷，攻城炮台 %+1 召唤图腾数量上限"] = function(num) return { mod("ActiveTotemLimit", "BASE", 1, { type = "SkillName", skillName = "攻城炮台" }, { type = "PerStat", stat = "Dex", div = num }) } end,
	["每有 (%d+) 力量，散射弩炮 %+1 召唤图腾数量上限"] = function(num) return { mod("ActiveTotemLimit", "BASE", 1, { type = "SkillName", skillName = "散射弩炮" }, { type = "PerStat", stat = "Str", div = num }) } end,
	["每 (%d+) 点力量都使散射弩炮的召唤图腾上限 %+1"] = function(num) return { mod("ActiveTotemLimit", "BASE", 1, { type = "SkillName", skillName = "散射弩炮" }, { type = "PerStat", stat = "Str", div = num }) } end,
	["每 (%d+) 点力量都使攻击附加 (%d+) 到 (%d+) 点物理伤害"] = function(_,num1,num2,num3) return {
	mod("PhysicalMin", "BASE", tonumber(num2),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	mod("PhysicalMax", "BASE", tonumber(num3),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	} end,
	["每有 (%d+) 点力量就给攻击附加 (%d+) 到 (%d+) 点混沌伤害"] = function(_,num1,num2,num3) return {
	mod("ChaosMin", "BASE", tonumber(num2),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	mod("ChaosMax", "BASE", tonumber(num3),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	} end,
	["每 (%d+) 点力量都使攻击附加 (%d+) 到 (%d+) 点混沌伤害"] = function(_,num1,num2,num3) return {
	mod("ChaosMin", "BASE", tonumber(num2),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	mod("ChaosMax", "BASE", tonumber(num3),nil,ModFlag.Attack , { type = "PerStat", stat = "Str", div = tonumber(num1) }),
	} end,
	["【愤怒狂灵】击中后必定造成点燃"] = { mod("MinionModifier", "LIST", { mod = mod("EnemyIgniteChance", "BASE", 100) }, { type = "SkillName", skillName = "召唤愤怒狂灵" }) }, --备注：raging spirits' hits always
	["所有身上穿戴的物品皆为已腐化时，每秒回复 (%d+) 魔力"] = function(num) return {  mod("ManaRegen", "BASE", num,{ type = "MultiplierThreshold", var = "NonCorruptedItem", threshold = 0, upper = true })  } end,
	["身上未装备已腐化的物品时，每秒回复 (%d+) 生命"] = function(num) return {  mod("LifeRegen", "BASE", num,{ type = "MultiplierThreshold", var = "CorruptedItem", threshold = 0, upper = true })  } end,
	["被点燃时，获得 (%d+) 每秒生命回复"] = function(num) return {  mod("LifeRegen", "BASE", num,{ type = "Condition", var = "Ignited" })  } end,
	["在冰缓地面上每秒回复 (%d+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "OnChilledGround" } )  } end,
	["当力量超过 (%d+) 点时，每秒回复 ([%d%.]+)%% 生命"] = function(num1,_,num2) return {  mod("LifeRegenPercent", "BASE", tonumber(num2),{ type = "StatThreshold", stat = "Str", threshold = tonumber(num1) } )  } end,
	["移动时每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "Moving" } )  } end,
	["每秒回复 ([%d%.]+) 生命"] = function(num) return {  mod("LifeRegen", "BASE", num)  } end,
	["每个耐力球提高 ([%d%.]+)%% 每秒生命回复"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "EnduranceCharge" })  } end,
	["每个暴击球每秒回复 ([%d%.]+) 魔力"] = function(num) return {  mod("ManaRegen", "BASE", num,{ type = "Multiplier", var = "PowerCharge" })  } end,
	["每秒回复 ([%d%.]+) 魔力"] = function(num) return {  mod("ManaRegen", "BASE", num)  } end,
	["击败敌人时，每个狂怒球可以回复 %+(%d+) 生命"] = function(num) return {  mod("LifeOnKill", "BASE", num,{ type = "Multiplier", var = "FrenzyCharge" } )  } end,
	["每个狂怒球每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegen", "BASE", num,{ type = "Multiplier", var = "FrenzyCharge" } )  } end,
	["每个耐力球可使每秒生命回复提高 ([%d%.]+)"] = function(num) return {  mod("LifeRegen", "BASE", num,{ type = "Multiplier", var = "EnduranceCharge" } )  } end,
	["每级获得每秒回复 (%d+) 生命"] = function(num) return {  mod("LifeRegen", "BASE", num, { type = "Multiplier", var = "Level" })  } end,
	["击败敌人回复 %+(%d+) 生命"] = function(num) return {  mod("LifeOnKill", "BASE", num)  } end,
	["击败敌人回复 %+(%d+) 魔力"] = function(num) return {  mod("ManaOnKill", "BASE", num)  } end,
	["闪电伤害击中时有 ([%+%-]?%d+)%% 几率使敌人受到感电效果影响"] =function(num) return {  mod("EnemyShockChance", "BASE", num)  } end,  --   "EnemyShockChance", --备注：to shock
	["闪电伤害击中时有 ([%+%-]?%d+)%% 的几率使敌人受到感电效果影响"] =function(num) return {  mod("EnemyShockChance", "BASE", num)  } end,  --   "EnemyShockChance", --备注：to shock
	["火焰伤害击中时有 ([%+%-]?%d+)%% 几率点燃敌人"] =function(num) return {  mod("EnemyIgniteChance", "BASE", num)  } end,  --   "EnemyShockChance", --备注：to shock
	["火焰伤害击中时有 ([%+%-]?%d+)%% 的几率点燃敌人"] =function(num) return {  mod("EnemyIgniteChance", "BASE", num)  } end,  --   "EnemyShockChance", --备注：to shock
	["法杖攻击 ([%+%-]?%d+)%% 暴击伤害加成"] = function(num) return {  mod("CritMultiplier", "BASE", num,nil, ModFlag.Wand)  } end,
	["获得额外闪电伤害， 其数值等同于物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsLightning", "BASE", num)  } end, --备注：^gain ([%d%.]+)%% of
	["获得额外闪电伤害， 其数值等同于法杖物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsLightning", "BASE", num,nil, ModFlag.Wand)  } end, --备注：^gain ([%d%.]+)%% of
	["获得额外火焰伤害， 其数值等同于法杖物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num,nil, ModFlag.Wand)  } end,
	["获得额外冰霜伤害， 其数值等同于法杖物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsCold", "BASE", num,nil, ModFlag.Wand)  } end,
	["获得额外混沌伤害，其数值等同于物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsChaos", "BASE", num)  } end,
	["获得额外混沌伤害， 其数值等同于闪电伤害的 ([%d%.]+)%%"] = function(num) return {  mod("LightningDamageGainAsChaos", "BASE", num)  } end,
	["获得额外混沌伤害， 其数值等同于火焰伤害的 ([%d%.]+)%%"] = function(num) return {  mod("FireDamageGainAsChaos", "BASE", num)  } end,
	["获得额外混沌伤害， 其数值等同于冰霜伤害的 ([%d%.]+)%%"] = function(num) return {  mod("ColdDamageGainAsChaos", "BASE", num)  } end,
	["获得额外火焰伤害， 其数值等同于物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num)  } end,
	["近期内你若打出过暴击，则获得物理伤害 ([%d%.]+)%% 的额外火焰伤害"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num, { type = "Condition", var = "CritRecently" })  } end,
	["获得额外冰霜伤害， 其数值等同于物理伤害的 ([%d%.]+)%%"] = function(num) return {  mod("PhysicalDamageGainAsCold", "BASE", num)  } end,
	["获得等同 ([%d%.]+)%% 物理攻击伤害的闪电伤害"] = function(num) return {  mod("PhysicalDamageGainAsLightning", "BASE", num,nil, ModFlag.Attack)  } end,
	["获得等同 ([%d%.]+)%% 物理攻击伤害的火焰伤害"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num,nil, ModFlag.Attack)  } end,
	["获得等同 ([%d%.]+)%% 物理攻击伤害的冰霜伤害"] = function(num) return {  mod("PhysicalDamageGainAsCold", "BASE", num,nil, ModFlag.Attack)  } end,
	["获得等同 ([%d%.]+)%% 物理伤害的闪电伤害"] = function(num) return {  mod("PhysicalDamageGainAsLightning", "BASE", num)  } end,
	["获得等同 ([%d%.]+)%% 物理伤害的火焰伤害"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num)  } end,
	["获得等同 ([%d%.]+)%% 物理伤害的冰霜伤害"] = function(num) return {  mod("PhysicalDamageGainAsCold", "BASE", num)  } end,
	["对冰缓敌人获得额外冰霜伤害，其数值等同于闪电伤害的 ([%d%.]+)%%"] = function(num) return {  mod("LightningDamageGainAsCold", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Chilled" })  } end,
	["召唤生物每秒回复 ([%d%.]+)%% 生命"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) })  } end,
	["召唤生物有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("DoubleDamageChance", "BASE", num) })  } end,
	["召唤生物有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("DoubleDamageChance", "BASE", num) })  } end,
	["召唤生物获得等同 ([%d%.]+)%% 最大生命的额外能量护盾"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeGainAsEnergyShield", "BASE", num) })  } end,
	["召唤生物获得额外混沌伤害，其数值等同于元素伤害的 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalDamageGainAsChaos", "BASE", num) })  } end,
	["召唤生物获得物理伤害 (%d+)%% 的额外火焰伤害"] = function(num) return { mod("MinionModifier", "LIST",
	{ mod = mod("PhysicalDamageGainAsFire", "BASE", num) })  } end,
	["召唤生物总生命额外提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "MORE", num) })  } end,
	["召唤生物每秒回复 ([%d%.]+) 生命"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeRegen", "BASE", num) })  } end,
	["召唤生物获得 ([%d%.]+)%% 生命偷取"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("DamageLifeLeech", "BASE", num) })  } end,
	["持长杖时 ([%+%-]?%d+)%% 攻击和法术暴击伤害加成"] = function(num) return {  mod("CritMultiplier", "BASE", num, { type = "Global" } , { type = "Condition", var = "UsingStaff" })  } end,
	["你的攻击击中每个敌人会回复 ([%+%-]?%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,nil, ModFlag.Attack)  } end,
	["你的法术击中每个敌人会回复 ([%+%-]?%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,nil, ModFlag.Spell)  } end,
	["你的攻击击中每个敌人会回复 ([%+%-]?%d+) 能量护盾"] = function(num) return {  mod("EnergyShieldOnHit" , "BASE", num,nil, ModFlag.Attack)  } end,
	["你的法术击中每个敌人会回复 ([%+%-]?%d+) 能量护盾"] = function(num) return {  mod("EnergyShieldOnHit" , "BASE", num,nil, ModFlag.Spell)  } end,
	["攻击击中每个敌人会回复 ([%+%-]?%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,nil, ModFlag.Attack)  } end,
	["法术击中每个敌人会回复 ([%+%-]?%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,nil, ModFlag.Spell)  } end,
	["击中每个敌人会回复 ([%+%-]?%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,nil, ModFlag.Hit)  } end,
	["你的攻击击中每个敌人会回复 ([%+%-]?%d+) 魔力"] = function(num) return {  mod("ManaOnHit", "BASE", num,nil, ModFlag.Attack)  } end,
	["攻击击中每个敌人会回复 ([%+%-]?%d+) 魔力"] = function(num) return {  mod("ManaOnHit", "BASE", num,nil, ModFlag.Attack)  } end,
	["物理攻击伤害的 ([%d%.]+)%% 会转化为生命偷取"]= function(num) return {  mod("PhysicalDamageLifeLeech", "BASE", num,nil, ModFlag.Attack)  } end,
	["火焰伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"]= function(num) return {  mod("FireDamageEnergyShieldLeech", "BASE", num)  } end,
	["冰霜伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"]= function(num) return {  mod("ColdDamageEnergyShieldLeech", "BASE", num)  } end,
	["闪电伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"]= function(num) return {  mod("LightningDamageEnergyShieldLeech", "BASE", num)  } end,
	["法术伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"]= function(num) return {  mod("DamageEnergyShieldLeech", "BASE", num,nil, ModFlag.Spell)  } end,
	["火焰伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("FireDamageEnergyShieldLeech", "BASE", num)  } end,
	["冰霜伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("ColdDamageEnergyShieldLeech", "BASE", num)  } end,
	["闪电伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("LightningDamageEnergyShieldLeech", "BASE", num)  } end,
	["法术伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("DamageEnergyShieldLeech", "BASE", num,nil, ModFlag.Spell)  } end,
	["混沌伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"]= function(num) return {  mod("ChaosDamageEnergyShieldLeech", "BASE", num)  } end,
	["敌人身上每有 1 个诅咒，法术伤害的 ([%d%.]+)%% 会转化为能量护盾偷取"] = function(num) return {  mod("DamageEnergyShieldLeech", "BASE", num,nil, ModFlag.Spell,{ type = "Multiplier", var = "CurseOnEnemy" })  } end,
	["敌人身上每有 1 个诅咒，法术伤害的 ([%d%.]+)%% 便转化为能量护盾偷取"] = function(num) return {  mod("DamageEnergyShieldLeech", "BASE", num,nil, ModFlag.Spell,{ type = "Multiplier", var = "CurseOnEnemy" })  } end,
	["每个生命偷取实例降低 (%d+)%% 最大回复"] = function(num) return {  mod("MaxLifeLeechInstance", "INC", -num)  } end,
	["拥有【秘术增强】效果时，法术伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Spell,{ type = "Condition", var = "AffectedBy秘术增强" })  } end,
	["攻击伤害的 ([%d%.]+)%% 会转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack)  } end,
	["药剂持续期间，物理攻击伤害的 ([%d%.]+)%% 作为生命偷取"]= function(num) return {  mod("PhysicalDamageLifeLeech", "BASE", num,nil, ModFlag.Attack,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，物理攻击伤害的 ([%d%.]+)%% 作为魔力偷取"]= function(num) return {  mod("PhysicalDamageManaLeech", "BASE", num,nil, ModFlag.Attack,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，附加 (%d+)%% 火焰、冰霜、闪电抗性"]= function(num) return {  mod("ElementalResist", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，附加 (%d+)%% 元素抗性"]= function(num) return {  mod("ElementalResist", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，每秒回复 ([%d%.]+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["近期内你若有击败敌人，则造成伤害的 ([%d%.]+)%% 转化为生命和魔力偷取"]= function(num) return {
	mod("DamageLifeLeech", "BASE", num,{ type = "Condition", var = "KilledRecently" }) ,
	mod("DamageManaLeech", "BASE", num,{ type = "Condition", var = "KilledRecently" })   } end,
	["近期内你若有击败敌人，则造成伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {
	mod("DamageLifeLeech", "BASE", num,{ type = "Condition", var = "KilledRecently" })  } end,
	["对感电敌人造成伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["对感电敌人的暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["对感电目标的暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["你击中造成的感电效果始终使承受的伤害提高至少 (%d+)%%"] = function(num) return {
	mod("ShockBase", "BASE", num)
	} end,
	["药剂持续期间，使周围的敌人感电，他们受到的伤害提高 (%d+)%%"]  = function(num) return { mod("EnemyModifier", "LIST", { mod =
	mod("SelfShockEffect", "BASE", num)} , { type = "Condition", var = "UsingFlask" }),
	} end,
	["敌人若位于你近期所生成的灵柩周围，则使其受到冰缓和感电"] = {
	mod("EnemyModifier", "LIST", { mod = mod("Condition:Chilled", "FLAG", true) }, { type = "Condition", var = "SpawnedCorpseRecently" }),
	mod("EnemyModifier", "LIST", { mod = mod("Condition:Shocked", "FLAG", true) }, { type = "Condition", var = "SpawnedCorpseRecently" }),
	mod("ShockBase", "BASE", 15, { type = "Condition", var = "SpawnedCorpseRecently"}),
	},
	["对被你击中所造成冰缓的敌人造成感电"] = {
	mod("ShockBase", "BASE", 15, { type = "ActorCondition", actor = "enemy", var = "ChilledByYourHits" } ),
	mod("EnemyModifier", "LIST", { mod = mod("Condition:Shocked", "FLAG", true, { type = "Condition", var = "ChilledByYourHits" } ) } )
	},
	["格挡时有 (%d+)%% 几率使攻击者感电 (%d+) 秒"] = { mod("ShockBase", "BASE", 15) },
	["格挡时有 (%d+)%% 的几率使攻击者感电 (%d+) 秒"] = { mod("ShockBase", "BASE", 15) },
	["shock nearby enemies for (%d+) seconds when you focus"]  = {
	mod("ShockBase", "BASE", 15, { type = "Condition", var = "Focused" }),
	mod("EnemyModifier", "LIST", { mod = flag("Condition:Shocked") }, { type = "Condition", var = "Focused" } ),
	},
	["移动时留下【感电地面】，持续 (%d+) 秒 (%d+)"] = { mod("ShockOverride", "BASE", 10, { type = "ActorCondition", actor = "enemy", var = "OnShockedGround"} ) },
	["左戒指栏位：用插入的【诅咒】替换你【冰冷的飞掠者】的光环"] = { flag("SkitterbotsCannotChill", { type = "SlotNumber", num = 1 }) },
	["右戒指栏位：用插入的【诅咒】替换你【电震的飞掠者】的光环"] = { flag("SkitterbotsCannotShock", { type = "SlotNumber", num = 2 }) },
	["药剂持续期间，使周围的敌人感电，他们受到的伤害提高 (%d+)%%"] = function(num) return {
	--	mod("EnemyModifier", "LIST", { mod = mod("Condition:Shocked", "FLAG", true) } ),
	mod("ShockOverride", "BASE", num, { type = "Condition", var = "UsingFlask" } )
	} end,
	["近期有感电过敌人，伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,{ type = "Condition", var = "ShockedEnemyRecently"  })  } end,
	["对被冰冻敌人造成伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Frozen" })  } end,
	["对被感电敌人造成伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["对冰冻敌人造成伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Frozen" })  } end,
	["对冰冻敌人造成伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("DamageEnergyShieldLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Frozen" })  } end,
	["对感电敌人造成伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack)  } end,
	["攻击伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,nil, ModFlag.Attack)  } end,
	["法术伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,nil, ModFlag.Spell)  } end,
	["法术伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Spell)  } end,
	["击中时有 ([%d%.]+)%% 几率击退敌人"]= function(num) return {  mod("EnemyKnockbackChance", "BASE", num)  } end,
	["击中时有 ([%d%.]+)%% 的几率击退敌人"]= function(num) return {  mod("EnemyKnockbackChance", "BASE", num)  } end,
	["获得护体时护甲提高 ([%d%.]+)%%"]= function(num) return {  mod("Armour", "INC", num, { type = "Condition", var = "Fortify" } )  } end,
	["击中时有 ([%d%.]+)%% 几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num)  } end,
	["击中时有 ([%d%.]+)%% 的几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num)  } end,
	["击中时有 ([%d%.]+)%% 几率使目标流血"]= function(num) return {  mod("BleedChance", "BASE", num)  } end,
	["击中时有 ([%d%.]+)%% 的几率使目标流血"]= function(num) return {  mod("BleedChance", "BASE", num)  } end,
	["攻击击中时有 ([%d%.]+)%% 几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Attack)  } end,
	["匕首攻击的暴击有 (%d+)%% 几率使敌人中毒"] = function(num) return { mod("PoisonChance", "BASE", num, nil, ModFlag.Dagger, { type = "Condition", var = "CriticalStrike" }) } end, --备注：critical strikes with daggers have a (%d+)%% chance to poison the enemy
	["攻击击中时有 ([%d%.]+)%% 的几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Attack)  } end,
	["匕首攻击的暴击有 (%d+)%% 的几率使敌人中毒"] = function(num) return { mod("PoisonChance", "BASE", num, nil, ModFlag.Dagger, { type = "Condition", var = "CriticalStrike" }) } end, --备注：critical strikes with daggers have a (%d+)%% chance to poison the enemy
	["地雷伤害可以穿透 (%d+)%% 元素抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", num,nil,nil,   KeywordFlag.Mine)  } end,
	["暴击后的 8 秒内，火焰、冰霜和闪电总伤害额外提高 (%d+)%%"]= function(num) return {  mod("ElementalDamage", "MORE", num,{ type = "Condition", var = "CritInPast8Sec" })  } end,
	["过去 8 秒你若有造成暴击，火焰、冰霜和闪电总伤害额外提高 (%d+)%%"]= function(num) return {  mod("ElementalDamage", "MORE", num,{ type = "Condition", var = "CritInPast8Sec" })  } end,
	["若你过去 8 秒内造成暴击，则总元素伤害总增 (%d+)%%"]= function(num) return {  mod("ElementalDamage", "MORE", num,{ type = "Condition", var = "CritInPast8Sec" })  } end,
	["没有暴击伤害加成"] = { flag("NoCritMultiplier") },
	["所承受伤害的前 (%d+)%% 会扣除魔力，而非生命"]= function(num) return {  mod("DamageTakenFromManaBeforeLife", "BASE", num)  } end,
	["总魔力保留额外降低 (%d+)%%"]= function(num) return {  mod("ManaReserved", "MORE", -num)  } end,
	["总魔力保留额外提高 (%d+)%%"]= function(num) return {  mod("ManaReserved", "MORE", num)  } end,
	["技能的魔力保留总降 (%d+)%%"]= function(num) return {  mod("ManaReserved", "MORE", -num)  } end,
	["【(.+)】的总魔力保留额外降低 (%d+)%%"]= function(_, skill_name, num) return {  mod("ManaReserved", "MORE", -num,{ type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)})  } end,
	["(.+)的总魔力保留额外降低 (%d+)%%"]= function(_, skill_name, num) return {  mod("ManaReserved", "MORE", -num,{ type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)})  } end,
	["此物品上的技能石魔力消耗倍率为原来的 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("SupportManaMultiplier", "MORE", num - 100) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["总流血伤害额外降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num,nil,nil, KeywordFlag.Bleed)  } end,
	["对投射物攻击的总闪避率总增 (%d+)%%"]= function(num) return {  mod("ProjectileEvadeChance", "MORE", num)  } end,
	["对近战攻击的总闪避率总降 (%d+)%%"]= function(num) return {  mod("MeleeEvadeChance", "MORE", -num)  } end,
	["能量护盾回复总速度降低 (%d+)%%"]= function(num) return {  mod("EnergyShieldRecharge", "MORE", -num)  } end,
	["能量护盾充能总速度降低 (%d+)%%"]= function(num) return {  mod("EnergyShieldRecharge", "MORE", -num)  } end,
	["能量护盾充能率总降 (%d+)%%"]= function(num) return {  mod("EnergyShieldRecharge", "MORE", -num)  } end,
	["能量护盾总速度降低 (%d+)%%"]= function(num) return {  mod("EnergyShieldRecharge", "MORE", -num)  } end,
	["低血时法术总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil, ModFlag.Spell,{ type = "Condition", var = "LowLife" })  } end,
	["召唤生物有 (%d+)%% 攻击格挡率"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("BlockChance", "BASE", num) })   } end,
	["召唤生物有 (%d+)%% 攻击伤害格挡几率"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("BlockChance", "BASE", num) })   } end,
	["召唤生物有%+(%d+)%% 攻击伤害格挡几率"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("BlockChance", "BASE", num) })   } end,
	["击中的总伤害额外降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num,nil,ModFlag.Hit)  } end,
	["击中总伤害降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num,nil,ModFlag.Hit)  } end,
	["地雷总伤害额外降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num,nil,KeywordFlag.Mine )  } end,
	["近期内，你或你的召唤生物每击败一个敌人，则每秒回复你 1%% 能量护盾，最多 (%d+)%%"] = function(num) return { mod("EnergyShieldRegenPercent", "BASE", 1, { type = "Multiplier", varList = {"EnemyKilledRecently","EnemyKilledByMinionsRecently"}, limit = tonumber(num), limitTotal = true } )  }end,
	["点燃总伤害额外提高 (%d+)%%"] = function(num) return {  mod("Damage", "MORE", num,nil,nil,KeywordFlag.Ignite )  } end,
	["火焰、冰霜、闪电伤害的 ([%d%.]+)%% 转化为生命偷取"] = function(num) return {  mod("ElementalDamageLifeLeech", "BASE", num )  } end,
	["元素伤害的 ([%d%.]+)%% 转化为生命偷取"] = function(num) return {  mod("ElementalDamageLifeLeech", "BASE", num )  } end,
	["近期内你若使用了召唤生物技能，则召唤生物伤害提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "Condition", var = "UsedMinionSkillRecently" } )})  } end,
	["若你近期内使用了召唤生物技能，则召唤生物的伤害提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "Condition", var = "UsedMinionSkillRecently" } )})  } end,
	["近期内你若使用了召唤生物技能，则召唤生物的伤害提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "Condition", var = "UsedMinionSkillRecently" } )})  } end,
	["近期内你若使用了召唤生物技能，则召唤生物的范围效果扩大 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num, { type = "Condition", var = "UsedMinionSkillRecently" } )})  } end,
	["若你近期内使用了召唤生物技能，则召唤生物的效果区域扩大 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num, { type = "Condition", var = "UsedMinionSkillRecently" } )})  } end,
	["你施放的光环每秒回复你和周围友军 ([%d%.]+)%% 最大生命"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("LifeRegenPercent", "BASE", num) }) } end,
	["(%d+)%% 的伤害优先从魔力扣除"]= function(num) return {  mod("DamageTakenFromManaBeforeLife", "BASE", num)  } end,
	["获得等同 (%d+)%% 魔力的额外能量护盾"]= function(num) return {  mod("ManaGainAsEnergyShield", "BASE", num)  } end,
	["获得等同 (%d+)%% 最大魔力的额外能量护盾"]= function(num) return {  mod("ManaGainAsEnergyShield", "BASE", num)  } end,
	["位于奉献地面上时，每秒回复 ([%d%.]+) 魔力"]= function(num) return {
	mod("ManaRegen", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,
	} end,
	["在奉献地面上时，每秒回复 ([%d%.]+) 魔力"]= function(num) return {
	mod("ManaRegen", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,
	} end,
	["位于奉献地面上时，每秒回复 ([%d%.]+) 能量护盾"]= function(num) return {
	mod("EnergyShieldRegen", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,
	} end,
	["在奉献地面上时，每秒回复 ([%d%.]+) 能量护盾"]= function(num) return {
	mod("EnergyShieldRegen", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,
	} end,
	["在奉献地面上时，每秒回复 ([%d%.]+)%% 最大魔力和能量护盾"]= function(num) return {
	mod("ManaRegenPercent", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,
	mod("EnergyShieldRegenPercent", "BASE", num,{ type = "Condition", var = "OnConsecratedGround" } ) ,} end,
	["受到击中物理伤害的 (%d+)%% 转化为火焰伤害"] = function(num) return {  mod("PhysicalDamageTakenAsFire", "BASE", num)  } end,
	["受到击中物理伤害的 (%d+)%% 转化为冰霜伤害"] = function(num) return {  mod("PhysicalDamageTakenAsCold", "BASE", num)  } end,
	["受到击中物理伤害的 (%d+)%% 转化为闪电伤害"] = function(num) return {  mod("PhysicalDamageTakenAsLightning", "BASE", num)  } end,
	["受到击中物理伤害的 (%d+)%% 转化为混沌伤害"] = function(num) return {  mod("PhysicalDamageTakenAsChaos", "BASE", num)  } end,
	["受到击中火焰、冰霜、闪电伤害的 (%d+)%% 转换为混沌伤害"] = function(num) return {  mod("ElementalDamageTakenAsChaos", "BASE", num)  } end,
	["受到击中元素伤害的 (%d+)%% 转换为混沌伤害"] = function(num) return {  mod("ElementalDamageTakenAsChaos", "BASE", num)  } end,
	["受到击中火焰伤害的 (%d+)%% 转化为物理伤害"] = function(num) return {  mod("FireDamageTakenAsPhysical", "BASE", num)  } end,
	-- fuck 国服翻译
	["受到的闪电总伤害额外降低 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["受到的冰霜总伤害额外降低 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["受到的火焰总伤害额外降低 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["受到的闪电总伤害降低 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["受到的冰霜总伤害降低 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["受到的火焰总伤害降低 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["受到的闪电伤害总降 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["受到的冰霜伤害总降 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["受到的火焰伤害总降 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["承受的闪电总伤害降低 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["承受的冰霜总伤害降低 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["承受的火焰总伤害降低 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["承受的闪电总伤害额外降低 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["承受的冰霜总伤害额外降低 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["承受的火焰总伤害额外降低 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["近期内，你若被击中并受到火焰伤害，则每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "HitByFireDamageRecently" })  } end,
	["火焰伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("FireDamageLifeLeech", "BASE", num)  } end,
	["冰霜伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("ColdDamageLifeLeech", "BASE", num)  } end,
	["闪电伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("LightningDamageLifeLeech", "BASE", num)  } end,
	["混沌伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("ChaosDamageLifeLeech", "BASE", num)  } end,
	["物理伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("PhysicalDamageLifeLeech", "BASE", num)  } end,
	["若你近期内有击败敌人，则攻击伤害的 ([%d%.]+)%% 转化为偷取生命和魔力"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack, { type = "Condition", var = "KilledRecently" })  } end,
	["近期内你若受到【残暴打击】，则其伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,{ type = "Condition", var = "BeenSavageHitRecently" })  } end,
	["总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num)  } end,
	["每秒回复 ([%d%.]+)%% 能量护盾"]=function(num) return {  mod("EnergyShieldRegenPercent", "BASE", num)  } end,
	["每秒回复 ([%d%.]+) 能量护盾"]=function(num) return {  mod("EnergyShieldRegen", "BASE", num)  } end,
	["每秒回复 ([%d%.]+)%% 生命"]=function(num) return {  mod("LifeRegenPercent", "BASE", num)  } end,
	["每秒回复 ([%d%.]+)%% 魔力"]=function(num) return {  mod("ManaRegenPercent", "BASE", num)  } end,
	["近期内你若被击中，则每秒回复 ([%d%.]+)%% 生命"]=function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "BeenHitRecently" })  } end,
	["(%d+)%% 的攻击格挡率同样套用于法术格挡"]=function(num) return {  mod("BlockChanceConv", "BASE", num)  } end,
	["流血总伤害额外提高 (%d+)%%"]=function(num) return {  mod("Damage", "MORE", num,nil,nil, KeywordFlag.Bleed)  } end,
	["流血总伤害额外降低 (%d+)%%"]=function(num) return {  mod("Damage", "MORE", -num,nil,nil, KeywordFlag.Bleed)  } end,
	["你可以对 1 个敌人造成最多 (%d+) 次流血"] = function(num) return { mod("BleedStacksMax", "OVERRIDE", num) } end,
	["投掷地雷类技能的魔力保留降低 (%d+)%%"]=function(num) return {  mod("ManaReserved", "INC", -num,nil,KeywordFlag.Mine  )  } end,
	["投掷地雷的技能保留效果降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num,nil,KeywordFlag.Mine  )  } end,
	["近期内你若引爆过地雷，则地雷放置投掷速度提高 (%d+)%%"]=function(num) return {  mod("MineLayingSpeed", "INC", num,{ type = "Condition", var = "DetonatedMinesRecently" })  } end,
	["若你近期内引爆过地雷，则地雷放置投掷速度提高 (%d+)%%"]=function(num) return {  mod("MineLayingSpeed", "INC", num,{ type = "Condition", var = "DetonatedMinesRecently" })  } end,
	["若你近期内引爆过地雷，则地雷类技能造成的范围伤害提高 (%d+)%%"]=function(num) return {  mod("Damage", "INC", num,nil,ModFlag.Area,KeywordFlag.Mine,{ type = "Condition", var = "DetonatedMinesRecently" })  } end,
	["若你近期内引爆过地雷，则地雷类技能的效果范围扩大 (%d+)%%"]=function(num) return {  mod("AreaOfEffect", "INC", num,nil,0,KeywordFlag.Mine,{ type = "Condition", var = "DetonatedMinesRecently" })  } end,
	["近期内你若有使用过位移技能，则每秒回复 (%d+) 魔力"]=function(num) return {  mod("ManaRegen", "BASE", num,{ type = "Condition", var = "UsedMovementSkillRecently" })  } end,
	["若你近期内击败了有你持续伤害状态的敌人，则生命，魔力，和能量护盾回复提高 (%d+)%%"]=function(num) return {  mod("LifeRecoveryRate", "INC", num,{ type = "Condition", var = "KilledAffectedByDotRecently" }),mod("ManaRecoveryRate", "INC", num,{ type = "Condition", var = "KilledAffectedByDotRecently" }),mod("EnergyShieldRecoveryRate", "INC", num,{ type = "Condition", var = "KilledAffectedByDotRecently" })  } end,
	["近期每有 1 个你的地雷被引爆，则每秒回复 (%d+)%% 生命，最多 20%%"]= function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "MineDetonatedRecently", limit = 20, limitTotal = true } )  } end,
	["近期每有 1 个你的陷阱被触发，则每秒回复 (%d+)%% 生命，最多 20%%"]= function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "TrapTriggeredRecently", limit = 20, limitTotal = true } )  } end,
	["近期每击败一个敌人，范围效果提高 (%d+)%%，最大 (%d+)%%"]= function(_,num1,num2) return {  mod("AreaOfEffect", "INC", tonumber(num1),{ type = "Multiplier", var = "EnemyKilledRecently", limit = tonumber(num2), limitTotal = true } )  } end,
	["你的耐力球数量上限等于狂怒球数量上限"] = { flag("MaximumEnduranceChargesIsMaximumFrenzyCharges") },
	["你的耐力球数量上限等于你的狂怒球数量上限"] = { flag("MaximumEnduranceChargesIsMaximumFrenzyCharges") },
	["最大耐力球数量等同于最大狂怒球数量"] = { flag("MaximumEnduranceChargesIsMaximumFrenzyCharges") },
	["最大狂怒球数量等同于最大暴击球数量"] = { flag("MaximumFrenzyChargesIsMaximumPowerCharges") },
	["你的狂怒球数量上限等于暴击球数量上限"] = { flag("MaximumFrenzyChargesIsMaximumPowerCharges") },
	["狂怒球达到上限时，物理总伤害额外提高 (%d+)%%"]= function(num) return {  mod("PhysicalDamage", "MORE", num, { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" })  } end,
	["击中和异常状态对流血敌人的伤害提高 (%d+)%%"]= function(num) return {  	mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) , { type = "ActorCondition", actor = "enemy", var = "Bleeding" })  } end,
	["近期内你若有嘲讽敌人，则每秒回复 ([%d%.]+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "TauntedEnemyRecently" } )  } end,
	["近期内你若有成功嘲讽敌人，则每秒回复 ([%d%.]+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "TauntedEnemyRecently" } )  } end,
	["近期内你若有击败敌人，则总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num, { type = "Condition", var = "KilledRecently" })  } end,
	["【猛攻】状态下闪避近战攻击的几率额外提高 (%d+)%%"] = function(num) return {  mod("MeleeEvadeChance", "MORE", num, { type = "Condition", var = "Onslaught" } )  } end,
	["【猛攻】状态下闪避近战攻击的几率总增 (%d+)%%"] = function(num) return {  mod("MeleeEvadeChance", "MORE", num, { type = "Condition", var = "Onslaught" } )  } end,
	["在【猛攻】状态期间闪避值提高 (%d+)%%"] = function(num) return {  mod("Evasion", "INC", num, { type = "Condition", var = "Onslaught" } )  } end,
	["总闪避值额外提高 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num)  } end,
	["闪避值额外提高 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num)  } end,
	["如果近期内被击中，则总闪避值额外提高 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num, { type = "Condition", var = "BeenHitRecently" })  } end,
	["【猛攻】状态下闪避投射物的总几率额外提高 (%d+)%%"]= function(num) return {  mod("ProjectileEvadeChance", "MORE", num,{ type = "Condition", var = "Onslaught" })  } end,
	["【猛攻】状态下闪避投射物的几率总增 (%d+)%%"]= function(num) return {  mod("ProjectileEvadeChance", "MORE", num,{ type = "Condition", var = "Onslaught" })  } end,
	["药剂持续期间，有 ([%d%.]+)%% 几率击中时使敌人中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，有 (%d+)%% 几率冰冻，感电和点燃敌人"]= function(num) return {mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }),mod("EnemyShockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }),mod("EnemyIgniteChance", "BASE", num,{ type ="Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，有 ([%d%.]+)%% 的几率击中时使敌人中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，有 (%d+)%% 的几率冰冻，感电和点燃敌人"]= function(num) return {mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }),mod("EnemyShockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }),mod("EnemyIgniteChance", "BASE", num,{ type ="Condition", var = "UsingFlask" })  } end,
	["投射物穿透目标后，投射物对它们的暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,nil,ModFlag.Projectile ,{ type = "StatThreshold", stat = "PierceCount", threshold = 1 } )  } end,
	["近期内你若使用过技能，每使用 1 个技能，你身上的【提速尾流】效果提高 (%d+)%%，最多 100%%"] = function(num) return {  mod("TailwindEffectOnSelf", "INC", num,{ type = "Multiplier", var = "SkillUsedRecently", limit = 100, limitTotal = true } )  } end,
	["击中流血中的敌人时回复 %+(%d+) 生命"] = function(num) return {  mod("LifeOnHit", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Bleeding" })  } end,
	["陷阱所使用的技能范围扩大 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "INC", num,nil,nil, KeywordFlag.Trap)  } end,
	["能量护盾全满时，总闪避率额外提高 (%d+)%%"]= function(num) return {  mod("EvadeChance", "MORE", num,{ type = "Condition", var = "FullEnergyShield" })  } end,
	["持续性总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil, ModFlag.Dot)  } end,
	["持续性伤害总增 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil, ModFlag.Dot)  } end,
	["持续伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil, ModFlag.Dot)  } end,
	["对满血敌人的攻击和法术总暴击率总增 (%d+)%%"]= function(num) return {  mod("CritChance", "MORE", num,{ type = "ActorCondition", actor = "enemy", var = "FullLife" })  } end,
	["对满血敌人的暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "FullLife" })  } end,
	["对低血敌人的攻击和法术总暴击率总增 (%d+)%%"]= function(num) return {  mod("CritChance", "MORE", num,{ type = "ActorCondition", actor = "enemy", var = "LowLife" })  } end,
	["每对敌人造成一层中毒效果，便附加 %+([%d%.]+)%% 攻击和法术基础暴击率，最多 %+2%.0%%"]= function(num) return {  mod("CritChance", "BASE", num,{ type = "Multiplier", actor = "enemy", var = "PoisonStack", limit = 2, limitTotal = true })  } end,
	["攻击附加 %+([%d%.]+)%% 攻击基础暴击率"]= function(num) return {  mod("CritChance", "BASE",num,nil, ModFlag.Attack)  } end,
	["法术获得 %+([%d%.]+)%% 基础暴击率"]= function(num) return {  mod("CritChance", "BASE", num,nil,ModFlag.Spell)  } end,
	["近期你每造成一层中毒效果，中毒持续时间便延长 (%d+)%%"]= function(num) return {  mod("EnemyPoisonDuration", "INC", num, { type = "Multiplier", var = "PoisonAppliedRecently" })  } end,	
	["近期内你施加的每层中毒效果都使中毒持续时间延长 (%d+)%%，最多可延长 100%%"]= function(num) return {  mod("EnemyPoisonDuration", "INC", num, { type = "Multiplier", var = "PoisonAppliedRecently", limit = 100, limitTotal = true})  } end,
	["对中毒敌人时，获得额外混沌伤害，其数值等同于物理伤害的 (%d+)%%"]= function(num) return {  mod("PhysicalDamageGainAsChaos", "BASE", num,nil, ModFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Poisoned"})  } end,
	["暴击时攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack, { type = "Condition", var = "CriticalStrike" })  } end,
	["击中时有 ([%d%.]+)%% 几率使敌人中毒"]= function(num) return {  mod("PoisonChance", "BASE", num)  } end,
	["击中时有 ([%d%.]+)%% 的几率使敌人中毒"]= function(num) return {  mod("PoisonChance", "BASE", num)  } end,
	["对中毒敌人造成攻击伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,nil, ModFlag.Attack, { type = "ActorCondition", actor = "enemy", var = "Poison" })  } end,
	["攻击瘫痪的敌人时，攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack, { type = "ActorCondition", actor = "enemy", var = "Maimed" })  } end,
	["对瘫痪敌人的攻击伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,nil, ModFlag.Attack, { type = "ActorCondition", actor = "enemy", var = "Maimed" })  } end,
	["对低血敌人的击中和异常状态总伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "LowLife" })  } end,
	["对低血的敌人时，击中和异常状态总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "LowLife" })  } end,
	["敌人身上的非伤害异常状态效果提高 (%d+)%%"] = function(num) return {
	mod("EnemyShockEffect", "INC", num) ,
	mod("EnemyChillEffect", "INC", num) ,
	mod("EnemyFreezeEffect", "INC", num) ,
	mod("EnemyScorchEffect", "INC", num),
	mod("EnemyBrittleEffect", "INC", num),
	mod("EnemySapEffect", "INC", num),
	} end,
	["非伤害型异常状态效果提高 (%d+)%%"] = function(num) return {
	mod("EnemyShockEffect", "INC", num) ,
	mod("EnemyChillEffect", "INC", num) ,
	mod("EnemyFreezeEffect", "INC", num) ,
	mod("EnemyScorchEffect", "INC", num),
	mod("EnemyBrittleEffect", "INC", num),
	mod("EnemySapEffect", "INC", num),
	} end,
	["周围友军伤害提高 (%d+)%%"]  = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("Damage", "INC", num), onlyAllies = true} )} end,
	["周围友军获得每秒回复 ([%d%.]+)%% 生命"] = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("LifeRegenPercent", "BASE", num), onlyAllies = true} )} end,
	["周围友军获得 (%d+)%% 魔力回复"]  = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("ManaRegen", "INC", num), onlyAllies = true} )} end,
	["周围友军获得护体"] = function() return { mod("ExtraAura", "LIST",{ mod =flag("Condition:Fortify"), onlyAllies = true} )} end,
	["周围友军 %+(%d+)%% 暴击伤害加成"]  = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("CritMultiplier", "BASE", num, { type = "Global" } ), onlyAllies = true} )} end,
	["此物品上的技能石受到 (%d+) 级的 【祝福】 辅助"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportAuraDuration", level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石受到 (%d+) 级的 技能陷阱化 辅助"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportTrap", level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石受到 (%d+) 级的 额外击中 辅助"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportAdditionalAccuracy", level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石受到 (%d+) 级的 【(.+)】 辅助"] = function(num, _, support) return {
	mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["物品上的技能石受到 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return {
	mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石受到 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return {
	mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内的的技能石被 (%d+) 级的【(.+)】辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["插槽内的的技能石被 (%d+) 级的(.+)辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["此物品上的技能石受到 (%d+) 级的【(.+)】辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石受到 (%d+) 级的(.+)辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["此物品上的技能石由 (%d+) 级的【(.+)】辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的技能石由 (%d+) 级的(.+)辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["插槽内的的技能石被 (%d+) 级的 【(.+)】 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内的的技能石被 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["插槽内的技能石受到 (%d+) 级的 【(.+)】 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内的技能石受到 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["插槽内的技能石受到 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["插槽内的技能石被 (%d+) 级的 【(.+)】 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内的技能石被等级 (%d+) 的【(.+)】辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["此物品上的【召唤生物技能石】由 (%d+) 级的 生命偷取 辅助"] = function(num) return { mod("ExtraSupport", "LIST",
	{ skillId = "SupportLifeLeech", level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的诅咒技能石受到 (%d+) 级的 【(.+)】 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST",
	{ skillId = FuckSkillSupportCnName(support), level = num },
	{ type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的诅咒技能石受到 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST",
	{ skillId = FuckSkillSupportCnName(support), level = num },
	{ type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["([%d%.]+)%% 额外物理伤害减伤"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num)  } end,
	["受到击中冰霜伤害的 (%d+)%% 转为火焰伤害"] = function(num) return {  mod("ColdDamageTakenAsFire", "BASE", num)  } end,
	["受到击中冰霜伤害的 (%d+)%% 转为闪电伤害"] = function(num) return {  mod("ColdDamageTakenAsLightning", "BASE", num)  } end,
	["受到击中火焰伤害的 (%d+)%% 转为冰霜伤害"] = function(num) return {  mod("FireDamageTakenAsCold", "BASE", num)  } end,
	["受到击中火焰伤害的 (%d+)%% 转为闪电伤害"] = function(num) return {  mod("FireDamageTakenAsLightning", "BASE", num)  } end,
	["受到击中闪电伤害的 (%d+)%% 转为冰霜伤害"] = function(num) return {  mod("LightningDamageTakenAsCold", "BASE", num)  } end,
	["受到击中闪电伤害的 (%d+)%% 转为火焰伤害"] = function(num) return {  mod("LightningDamageTakenAsFire", "BASE", num)  } end,
	["(%d+)%% 攻击格挡率"] = function(num) return {  mod("BlockChance", "BASE", num)  } end,
	["(%d+)%% 法术格挡率"] = function(num) return {  mod("SpellBlockChance", "BASE", num)  } end,
	["未被诅咒时获得 (%d+)%% 额外格挡率"] = function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "Cursed", neg = true })  } end,
	["被诅咒时获得 (%d+)%% 额外法术格挡率"]= function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "Cursed" })  } end,
	["冰冻时每秒回复 (%d+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "Frozen" })  } end,
	["移动时每秒回复 (%d+) 生命"]= function(num) return {  mod("LifeRegen", "BASE", num, { type = "Condition", var = "Moving" })  } end,
	["低血时闪避值提高 %+(%d+)"]= function(num) return {  mod("Evasion", "BASE", num, { type = "Condition", var = "LowLife" })  } end,
	["低血时每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "LowLife" })  } end,
	["满血时闪避值提高 %+(%d+)"]= function(num) return {  mod("Evasion", "BASE", num, { type = "Condition", var = "FullLife" })  } end,
	["每有一个暴击球，你受到伤害的 ([%d%.]+)%% 由魔力先承担"]= function(num) return {  mod("DamageTakenFromManaBeforeLife", "BASE", num, { type = "Multiplier", var = "PowerCharge" } )  } end,
	["装备时触发等级 20 闪电圣盾"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="LightningAegis", level = 20, triggered = true})   } end,
	["获得等级 22 的 精准 技能"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="AccuracyAndCritsAura", level = 22})   } end,
	["提供 20 级死亡之愿"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="DeathWish", level = 20})   } end,
	["获得 20 级的【狙击】技能"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="ChannelledSnipe", level = 22})   } end,
	["插入的弓类技能触发时，造成的总伤害额外降低 (%d+)%%"]= function(num) return {  } end,
	["插入的弓类技能触发时，造成的伤害总降 (%d+)%%"]= function(num) return {  } end,
	["插入的非吟唱型弓类技能被【狙击】触发"] = {
	mod("ExtraSkillMod", "LIST", { mod = flag("TriggeredBySnipe") },  { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "showAverage", value = true } ) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "triggered", value = 1 } ) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	},
	["插入的非持续吟唱型弓类技能被【狙击】触发"] = {
	mod("ExtraSkillMod", "LIST", { mod = flag("TriggeredBySnipe") },  { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "showAverage", value = true } ) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "triggered", value = 1 } ) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "bow" }, { type = "SkillType", skillType = SkillType.Triggerable } ),
	},
	--["获得等级 20 的【骨制战甲】技能"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="BoneArmour", level = 20})   } end,
	["击败敌人时触发 10 级的【玷污】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="CreateFungalGroundOnKill", level = 10})   } end,
	["你的暴击加成为 (%d+)%%"]= function(num) return {  mod("CritMultiplier", "OVERRIDE", num, { type = "Global" } )  } end,
	["你的暴击伤害加成为 (%d+)%%"]= function(num) return {  mod("CritMultiplier", "OVERRIDE", num, { type = "Global" } )  } end,
	["获得 (%d+) 级的主动技能【元素之愈】"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="VaalAuraElementalDamageHealing", level = num})   } end,
	["获得 (%d+) 级的【幻象传送】"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="MerveilWarp", level = num})   } end,
	["(%d+)%% 的最大生命转化为能量护盾"]= function(num) return {  mod("LifeConvertToEnergyShield", "BASE", num)  } end,
	["冰霜伤害击中时有 (%d+)%% 的几率冰冻敌人"]= function(num) return {  mod("EnemyFreezeChance", "BASE", num)  } end,
	["冰霜伤害击中时有 (%d+)%% 几率冰冻敌人"]= function(num) return {  mod("EnemyFreezeChance", "BASE", num)  } end,
	["%−(%d+)%% 攻击和法术暴击伤害加成"]= function(num) return {  mod("CritMultiplier", "BASE", -num, { type = "Global" } )  } end,
	["被点燃时，火焰伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("FireDamageLifeLeech", "BASE", num, { type = "Condition", var = "Ignited" } )  } end,
	["药剂持续期间，能量护盾延后 (%d+)%% 开始回复"]= function(num) return {  mod("EnergyShieldRechargeFaster", "INC", num,  { type = "Condition", var = "UsingFlask" }  )  } end,
	["装备和技能石的属性需求提高 (%d+)%%"] = function(num) return { mod("GlobalAttributeRequirements", "INC", num) } end,
	["攻击和法术总暴击率额外降低 (%d+)%%"] = function(num) return { mod("CritChance", "MORE", -num) } end,
	["攻击和法术总暴击率总降 %-(%d+)%%"] = function(num) return { mod("CritChance", "MORE", -num) } end,
	["攻击和法术总暴击率总降 (%d+)%%"] = function(num) return { mod("CritChance", "MORE", -num) } end,
	["用该武器击中时，触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["获得 (%d+) 级的主动技能【(.+)】，且可被此道具上的技能石辅助"] = function(num, _, skill) return grantedExtraSkill(skill, num) end, --备注：grants level (%d+) (.+)
	["获得 (%d+) 级【(.+)】"] = function(num, _, skill) return grantedExtraSkill(skill, num) end,
	["造成的异常状态持续时间缩短 (%d+)%%"] = function(num) return {
	mod("EnemyShockDuration", "INC", -num),mod("EnemyFreezeDuration", "INC", -num),mod("EnemyChillDuration", "INC", -num),mod("EnemyIgniteDuration", "INC", -num),mod("EnemyBleedDuration", "INC", -num),
	mod("EnemyPoisonDuration", "INC", -num),
	mod("EnemyScorchDuration", "INC", -num),
	mod("EnemyBrittleDuration", "INC", -num),
	mod("EnemySapDuration", "INC", -num),
	} end,
	["造成的异常状态持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyShockDuration", "INC", num),
	mod("EnemyFreezeDuration", "INC", num),
	mod("EnemyChillDuration", "INC", num),
	mod("EnemyIgniteDuration", "INC", num),
	mod("EnemyBleedDuration", "INC", num),mod("EnemyPoisonDuration", "INC", num),
	mod("EnemyScorchDuration", "INC", num),
	mod("EnemyBrittleDuration", "INC", num),
	mod("EnemySapDuration", "INC", num),
	} end,
	["([%d%.]+) 每秒生命回复"] = function(num) return {  mod("LifeRegen", "BASE", num)  } end,
	["([%d%.]+) 每秒魔力回复"] = function(num) return {  mod("ManaRegen", "BASE", num)  } end,
	["魔力回复 ([%d%.]+)"] = function(num) return {  mod("ManaRegen", "BASE", num)  } end,
	["每 (%d+) 点奉献 使魔力回复 ([%d%.]+)"] = function(_,num1,num2) return {  mod("ManaRegen", "BASE", tonumber(num2),{ type = "PerStat", stat = "Devotion", div = tonumber(num1) })  } end,
	["每 (%d+) 点奉献便每秒回复 ([%d%.]+) 魔力"] = function(_,num1,num2) return {  mod("ManaRegen", "BASE", tonumber(num2),{ type = "PerStat", stat = "Devotion", div = tonumber(num1) })  } end,
	["每秒 ([%d%.]+) 基础魔力回复"] = function(num) return {  mod("ManaRegen", "BASE", num)  } end,
	["每秒 ([%d%.]+)%% 魔力回复"]= function(num) return {  mod("ManaRegenPercent", "BASE", num )  } end,
	["物理攻击伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("PhysicalDamageManaLeech", "BASE", num,nil, ModFlag.Attack)  } end,
	["【(.+)】的魔力保留降低 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("ManaReserved", "INC",-num, { type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["【(.+)】的保留效果降低 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("Reserved", "INC",-num, { type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["药剂持续期间，有 (%d+)%% 几率冰冻"]= function(num) return {mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }) } end,
	["药剂持续期间，有 (%d+)%% 几率感电"]= function(num) return {mod("EnemyShockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }) } end,
	["药剂持续期间，有 (%d+)%% 几率点燃"]= function(num) return {mod("EnemyIgniteChance", "BASE", num,{ type ="Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，有 (%d+)%% 的几率冰冻"]= function(num) return {mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }) } end,
	["药剂持续期间，有 (%d+)%% 的几率感电"]= function(num) return {mod("EnemyShockChance", "BASE", num,{ type = "Condition", var = "UsingFlask" }) } end,
	["药剂持续期间，有 (%d+)%% 的几率点燃"]= function(num) return {mod("EnemyIgniteChance", "BASE", num,{ type ="Condition", var = "UsingFlask" })  } end,
	["每个暴击球所获得物理攻击伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("PhysicalDamageManaLeech", "BASE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "PowerCharge" })  } end,
	["每个暴击球会提供攻击伤害 ([%d%.]+)%% 的魔力偷取"]= function(num) return {  mod("DamageManaLeech", "BASE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "PowerCharge" })  } end,
	["对被冰缓敌人所造成的攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "Chilled" })  } end,
	["获得等同 ([%d%.]+)%% 最大生命的额外能量护盾"]= function(num) return {  mod("LifeGainAsEnergyShield", "BASE", num)  } end,
	["获得【(.+)】"] = function(_,skill) return grantedExtraSkill(skill) end,
	["暴走时触发 (%d+) 级的【(.+)】"]= function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["暴击时触发 (%d+) 级的【(.+)】"]= function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["插槽内的的近战技能石范围扩大 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("AreaOfEffect", "INC", num) },{ type = "SocketedIn", slotName = "{SlotName}", keyword = "melee" } ) } end,
	["近战技能的范围扩大 (%d+)%%"]= function(num) return { mod("AreaOfEffect", "INC", num,nil,ModFlag.Melee ) } end,
	["每装备 1 个【裂界之器】，异常状态的伤害便提高 (%d+)%%"] = function(num) return {  mod("Damage", "INC", num,nil,ModFlag.Ailment,{ type = "Multiplier", var = "ElderItem" })  } end,
	--["每装备 1 个【裂界之器】，异常状态的持续伤害加成便提高 (%d+)%%"] = function(num) return {  mod("DotMultiplier", "BASE", num,nil,ModFlag.Ailment,{ type = "Multiplier", var = "ElderItem" })  } end,
	["每装备 1 个【裂界之器】，最大生命提高 %+(%d+)"]= function(num) return {  mod("Life", "BASE", num,{ type = "Multiplier", var = "ElderItem" })  } end,
	["每装备 1 个【裂界之器】，非伤害性异常状态的效果便提高 (%d+)%%"]= function(num) return {
	mod("EnemyShockEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }) ,
	mod("EnemyChillEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }) ,
	mod("EnemyFreezeEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }),
	mod("EnemyScorchEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }),
	mod("EnemyBrittleEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }),
	mod("EnemySapEffect", "INC", num,{ type = "Multiplier", var = "ElderItem" }),
	} end,
	["【(.+)魔像】的伤害提高 (%d+)%%"] = function(_, skill_name, num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "召唤"..skill_name:gsub("雷电","闪电").."魔像" or "Unknown" })  } end,
	["【幻化(.+)】的伤害提高 (%d+)%%"] = function(_, skill_name, num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "幻化"..skill_name or "Unknown" })  } end,
	["【魔侍造成】的伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "召唤魔侍" })  } end,
	["【召唤(.+)】的伤害提高 (%d+)%%"] = function(_, skill_name,num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "召唤"..skill_name })  } end,
	["召唤的(.+)魔像造成的伤害提高 (%d+)%%"] = function(_, skill_name,num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "召唤"..skill_name.."魔像" })  } end,
	["【召唤圣物】的范围效果扩大 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num) },{ type = "SkillName", skillName = "召唤圣物" })  } end,
	["召唤的圣物的增益效果提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("BuffEffect", "INC", num) },{ type = "SkillName", skillName = "召唤圣物" })  } end,
	["【幻化([^\\x00-\\xff]*)】造成的伤害提高 (%d+)%%"] = function(_,skill_name,num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },{ type = "SkillName", skillName = "幻化"..skill_name })  } end,
	["(.+)地雷的伤害提高 (%d+)%%"] = function(_, skill_name, num) return { mod("Damage", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name.."地雷")}) } end,
	["(.+)地雷投掷速度提高 (%d+)%%"] = function(_, skill_name, num) return { mod("MineLayingSpeed", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name.."地雷")}) } end,
	["(.+)地雷的投掷速度提高 (%d+)%%"] = function(_, skill_name, num) return { mod("MineLayingSpeed", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name.."地雷")}) } end,
	["(.+)地雷光环效果提高 (%d+)%%"] = function(_, skill_name, num) return { mod("AuraEffect", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name.."地雷")}) } end,
	["【(.+)】的伤害提高 (%d+)%%"] = function(_, skill_name, num) return { mod("Damage", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name)}) } end,
	["【(.+)】的技能持续时间提高 (%d+)%%"] = function(_, skill_name, num) return { mod("Duration", "INC",num, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name)}) } end,
	["【(.+)】投射物速度提高 (%d+)%%"] = function(_, skill_name, num) return { mod("ProjectileSpeed", "INC",num, { type = "SkillName", skillName = FuckSkillActivityCnName(skill_name)}) } end,
	["【([^\\x00-\\xff]*)】造成的伤害提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("Damage", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】获得等同其 (%d+)%% 物理伤害的额外冰霜伤害"]= function(_,skill_name,num) return {  mod("PhysicalDamageGainAsCold", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】获得等同其 (%d+)%% 物理伤害的额外闪电伤害"]= function(_,skill_name,num) return {  mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】获得等同其 (%d+)%% 物理伤害的额外火焰伤害"]= function(_,skill_name,num) return {  mod("PhysicalDamageGainAsFire", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["敌人身上每有 1 层蜘蛛网，则附加 (%d+) %- (%d+) 混沌伤害"] = function(_,num1,num2) return {
	mod("ChaosMin", "BASE", num1,{ type = "Multiplier", actor = "enemy", var = "Spider's WebStack" } ),
	mod("ChaosMax", "BASE", num2,{ type = "Multiplier", actor = "enemy", var = "Spider's WebStack" } ) } end,
	["空手攻击时的物理总伤害额外提高 (%d+)%%"]= function(num) return { mod("PhysicalDamage", "MORE", num,nil, ModFlag.Unarmed ) } end,
	["空手攻击时的物理伤害总增 (%d+)%%"]= function(num) return { mod("PhysicalDamage", "MORE", num,nil, ModFlag.Unarmed ) } end,
	["空手时攻击附加 (%d+) %- (%d+) 基础闪电伤害"] = function(_,num1,num2) return {
	mod("LightningMin", "BASE", num1,nil,ModFlag.Unarmed ),
	mod("LightningMax", "BASE", num2,nil,ModFlag.Unarmed  ) } end,
	["中毒持续总时间额外降低 (%d+)%%"] = function(num) return {  mod("EnemyPoisonDuration", "MORE", -num)  } end,
	["火焰技能有 (%d+)%% 几率使敌人中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Fire)  } end,
	["冰霜技能有 (%d+)%% 几率使敌人中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Cold)  } end,
	["闪电技能击中有 (%d+)%% 几率造成中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Lightning)  } end,
	["火焰技能有 (%d+)%% 的几率使敌人中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Fire)  } end,
	["冰霜技能有 (%d+)%% 的几率使敌人中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Cold)  } end,
	["闪电技能击中有 (%d+)%% 的几率造成中毒"] = function(num) return {  mod("PoisonChance", "BASE", num,nil,nil,KeywordFlag.Lightning)  } end,
	["此物品上的火焰、冰霜、闪电技能石等级 %+(%d+)"] = function(num) return { mod("GemProperty", "LIST",  { keyword = "elemental", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的元素技能石等级 %+(%d+)"] = function(num) return { mod("GemProperty", "LIST",  { keyword = "elemental", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["拥有最大数量的狂怒球时，攻击有 (%d+)%% 几率使敌人中毒"] = function(num) return{ mod("PoisonChance", "BASE", num, nil, ModFlag.Attack, { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }end,
	["拥有最大数量的狂怒球时，攻击有 (%d+)%% 的几率使敌人中毒"] = function(num) return{ mod("PoisonChance", "BASE", num, nil, ModFlag.Attack, { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }end,
	["召唤生物获得等同 (%d+)%% 物理伤害的额外冰霜伤害"]=function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageGainAsCold", "BASE", num) })  } end,
	["召唤生物获得等同于 (%d+)%% 物理伤害的额外火焰伤害"]=function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageGainAsFire", "BASE", num) })  } end,
	["(%d+)%% 较少(.+)时间"]= function(_, num,skill_name)  return {  mod("Duration", "MORE", -num,{ type = "SkillName", skillName = FuckSkillActivityCnName(skill_name)})  } end,
	["击败敌人时有 (%d+)%% 几率触发 (%d+) 级的【(.+)】"]= function(_, num,levelname,skill_name)return triggerExtraSkill(skill_name, levelname) end,
	["击败敌人时有 (%d+)%% 的几率触发 (%d+) 级的【(.+)】"]= function(_, num,levelname,skill_name)return triggerExtraSkill(skill_name, levelname) end,
	["物理伤害的 (%d+)%% 转换为闪电伤害"] = function(num) return { mod("PhysicalDamageConvertToLightning", "BASE", num) } end,
	["闪电法术的 (%d+)%% 物理伤害转换为闪电伤害"] = function(num) return { mod("PhysicalDamageConvertToLightning", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Lightning) } end,
	["火焰法术的 (%d+)%% 物理伤害转换为火焰伤害"] = function(num) return { mod("PhysicalDamageConvertToFire", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Fire) } end,
	["冰霜法术的 (%d+)%% 物理伤害转换为冰霜伤害"] = function(num) return { mod("PhysicalDamageConvertToCold", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Cold) } end,
	["闪电法术可将物理伤害的 (%d+)%% 转换为闪电伤害"] = function(num) return { mod("PhysicalDamageConvertToLightning", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Lightning) } end,
	["火焰法术可将物理伤害的 (%d+)%% 转换为火焰伤害"] = function(num) return { mod("PhysicalDamageConvertToFire", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Fire) } end,
	["冰霜法术可将物理伤害的 (%d+)%% 换为冰霜伤害"] = function(num) return { mod("PhysicalDamageConvertToCold", "BASE", num, nil, ModFlag.Spell, KeywordFlag.Cold) } end,
	["(%d+)%% 物理伤害转换为闪电伤害"] = function(num) return { mod("PhysicalDamageConvertToLightning", "BASE", num) } end,
	["(%d+)%% 物理伤害转换为火焰伤害"] = function(num) return { mod("PhysicalDamageConvertToFire", "BASE", num) } end,
	["(%d+)%% 物理伤害转换为冰霜伤害"] = function(num) return { mod("PhysicalDamageConvertToCold", "BASE", num) } end,
	["(%d+)%% 物理伤害转化为闪电伤害"] = function(num) return { mod("PhysicalDamageConvertToLightning", "BASE", num) } end,
	["(%d+)%% 物理伤害转化为火焰伤害"] = function(num) return { mod("PhysicalDamageConvertToFire", "BASE", num) } end,
	["(%d+)%% 物理伤害转化为冰霜伤害"] = function(num) return { mod("PhysicalDamageConvertToCold", "BASE", num) } end,
	["装备时触发 (%d+) 级的【元素神盾】"] = function(num) return{mod("ExtraSkill", "LIST", { skillId = "ElementalAegis", level = num, triggered = true}) }end,
	["装备时触发 (%d+) 级的【寒冰神盾】"] = function(num) return{mod("ExtraSkill", "LIST", { skillId = "ColdAegis", level = num, triggered = true}) }end,
	["装备时触发 (%d+) 级的【火焰神盾】"] = function(num) return{mod("ExtraSkill", "LIST", { skillId = "FireAegis", level = num, triggered = true}) }end,
	["低血时，(%d+)%% 的攻击格挡率套用于法术格挡"] = function(num) return {  mod("BlockChanceConv", "BASE", num, { type = "Condition", var = "LowLife" } )  } end,
	["若你近期内有击败敌人，则效果区域扩大 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { mod("AreaOfEffect", "INC", num1, { type = "Multiplier", var = "EnemyKilledRecently", limit = tonumber(num2), limitTotal = true } ) } end,
	["格挡时，用 (%d+) 级的【(.+)】诅咒敌人"] = function(num, _, skill) return triggerExtraSkill(skill, num, true) end,
	["攻击被嘲讽的敌人时，攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "Taunted" })  } end,
	["你身上的每层中毒状态使你每秒回复 (%d+) 能量护盾，最多可有 (%d+) 秒"]= function(_,num1,num2) return {  mod("EnergyShieldRegen", "BASE", tonumber(num1),{ type = "Multiplier", var = "PoisonStack", limit = tonumber(num2), limitTotal = true })  } end,
	["获得 (%d+) 级的【(.+)】"] =  function( _,num, skill) return grantedExtraSkill(skill, num) end,
	["对受诅咒敌人造成伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num, nil, ModFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Cursed" })  } end,
	["攻击击中被诅咒敌人时有 (%d+)%% 几率造成流血"]= function(num) return {  mod("BleedChance", "BASE", num, nil, ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "Cursed" })  } end,
	["攻击击中被诅咒敌人时有 (%d+)%% 的几率造成流血"]= function(num) return {  mod("BleedChance", "BASE", num, nil, ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "Cursed" })  } end,
	["当你拥有兽化的召唤生物时，投射物攻击击中时有 (%d+)%% 几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num,  { type = "SkillType", skillType = SkillType.Attack }, { type = "SkillType", skillType = SkillType.Projectile },{ type = "Condition", var = "HaveBestialMinion" }   ) }end,
	["当你拥有兽化的召唤生物时，投射物攻击击中时有 (%d+)%% 几率造成中毒"] =  function(num) return 	{mod("PoisonChance", "BASE", num,  { type = "SkillType", skillType = SkillType.Attack }, { type = "SkillType", skillType = SkillType.Projectile },{ type = "Condition", var = "HaveBestialMinion" }   ) }end,
	["当你拥有兽化的召唤生物时，投射物攻击击中时有 (%d+)%% 的几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num,  { type = "SkillType", skillType = SkillType.Attack }, { type = "SkillType", skillType = SkillType.Projectile },{ type = "Condition", var = "HaveBestialMinion" }   ) }end,
	["当你拥有兽化的召唤生物时，投射物攻击击中时有 (%d+)%% 的几率造成中毒"] =  function(num) return 	{mod("PoisonChance", "BASE", num,  { type = "SkillType", skillType = SkillType.Attack }, { type = "SkillType", skillType = SkillType.Projectile },{ type = "Condition", var = "HaveBestialMinion" }   ) }end,
	["击中时有 (%d+)%% 几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num, { type = "Condition", var = "{Hand}Attack" }) }end,
	["击中时有 (%d+)%% 的几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num, { type = "Condition", var = "{Hand}Attack" }) }end,
	["击中时 (%d+)%% 几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num, { type = "Condition", var = "{Hand}Attack" }) }end,
	["击中时 (%d+)%% 的几率造成流血"] =  function(num) return 	{mod("BleedChance", "BASE", num, { type = "Condition", var = "{Hand}Attack" }) }end,
	["近战击中有 %d+%% 几率触发 (%d+) 级的【熔岩爆破】"] =  function( _, num) return 	{mod("ExtraSkill", "LIST", { skillId = "TriggeredMoltenStrike", level = num, triggered = true}) }end,
	["近战击中有 %d+%% 的几率触发 (%d+) 级的【熔岩爆破】"] =  function( _, num) return 	{mod("ExtraSkill", "LIST", { skillId = "TriggeredMoltenStrike", level = num, triggered = true}) }end,
	["暴击时偷取等同 ([%d%.]+)%% 伤害的生命"]= function(num) return {  mod("DamageLifeLeech", "BASE", num, { type = "Condition", var = "CriticalStrike" })  } end,
	["每 (%d+) 点力量会使武器物理伤害提高 (%d+)%%"] = function(_,num1,num2) return {  mod("PhysicalDamage", "INC", num2,nil, ModFlag.Weapon,{ type = "PerStat", stat = "Str", div = num1 })  } end,
	["获得额外混沌伤害，其数值等同于火焰、冰霜、闪电伤害的 (%d+)%%"] = function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num)  } end,
	["获得额外混沌伤害，其数值等同于元素伤害的 (%d+)%%"] = function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num)  } end,
	["每有 1 个轮回球，便获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"]
	= function(num) return {  mod("NonChaosDamageGainAsChaos", "BASE", num, { type = "Multiplier", var = "SiphoningCharge" })  } end,
	["每有 1 个轮回球，便获得 ([%d%.]+)%% 击中物理伤害减免"]
	= function(num) return {  mod("PhysicalDamageReduction", "BASE", num, { type = "Multiplier", var = "SiphoningCharge" })  } end,
	["每个轮回球可使伤害的 ([%d%.]+)%% 转化为生命偷取"]
	= function(num) return {  mod("DamageLifeLeech", "BASE", num, { type = "Multiplier", var = "SiphoningCharge" })  } end,
	["近期内你若有使用技能，每有 1 个轮回球，则每秒受到 (%d+) 物理伤害"]
	= function(num) return {  mod("PhysicalDegen", "BASE", num, { type = "Multiplier", var = "SiphoningCharge" },{ type = "Condition", var = "UsedSkillRecently" })  } end,
	["近期内你若有使用战吼你和周围友军的攻击速度提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("Speed", "INC", num,nil, ModFlag.Attack) },{ type = "Condition", var = "UsedWarcryRecently" }) ,
	} end,
	["你和周围友军的物品稀有度提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("LootRarity", "INC", num) }) ,
	} end,
	["近期内你若有使用战吼，你和周围友军的攻击，施法和移动速度提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("Speed", "INC", num) },{ type = "Condition", var = "UsedWarcryRecently" }) ,
	mod("ExtraAura", "LIST", { mod =  mod("MovementSpeed", "INC", num) },{ type = "Condition", var = "UsedWarcryRecently" })
	} end,
	["近期内你若有使用战吼，你和周围友军的攻击速度提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("Speed", "INC", num,nil, ModFlag.Attack) },{ type = "Condition", var = "UsedWarcryRecently" }) ,
	} end,
	["近期内你若有使用战吼，你和周围友军的伤害提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("Damage", "INC", num) },{ type = "Condition", var = "UsedWarcryRecently" }) ,
	} end,
	["([%+%-]?%d+) 灵体最大生命"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "BASE", num) },{ type = "SkillName", skillName = "召唤灵体" })  } end,
	["被击中时承受额外 ([%+%-]?%d+) 火焰伤害"] = function(num) return {  mod("FireDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受额外 ([%+%-]?%d+) 混沌伤害"] = function(num) return {  mod("ChaosDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受额外 ([%+%-]?%d+) 闪电伤害"] = function(num) return {  mod("LightningDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受额外 ([%+%-]?%d+) 冰霜伤害"] = function(num) return {  mod("ColdDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受额外 ([%+%-]?%d+) 物理伤害"] = function(num) return {  mod("PhysicalDamageTakenWhenHit", "BASE", num)  } end,
	["攻击击中承受 ([%+%-]?%d+) 物理伤害"] = function(num) return {  mod("PhysicalDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受 ([%+%-]?%d+) 火焰伤害"] = function(num) return {  mod("FireDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受 ([%+%-]?%d+) 混沌伤害"] = function(num) return {  mod("ChaosDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受 ([%+%-]?%d+) 闪电伤害"] = function(num) return {  mod("LightningDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受 ([%+%-]?%d+) 冰霜伤害"] = function(num) return {  mod("ColdDamageTakenWhenHit", "BASE", num)  } end,
	["被击中时承受 ([%+%-]?%d+) 物理伤害"] = function(num) return {  mod("PhysicalDamageTakenWhenHit", "BASE", num)  } end,
	["([%+%-]?%d+) 承受的混沌伤害"] = function(num) return {  mod("ChaosDamageTaken", "BASE", num)  } end,
	["([%+%-]?%d+) 承受的火焰伤害"] = function(num) return {  mod("FireDamageTaken", "BASE", num)  } end,
	["([%+%-]?%d+) 承受的闪电伤害"] = function(num) return {  mod("LightningDamageTaken", "BASE", num)  } end,
	["([%+%-]?%d+) 承受的冰霜伤害"] = function(num) return {  mod("ColdDamageTaken", "BASE", num)  } end,
	["([%+%-]?%d+) 承受的物理伤害"] = function(num) return {  mod("PhysicalDamageTaken", "BASE", num)  } end,
	--注意中文的 −
	["%−(%d+) 承受的混沌伤害"] = function(num) return {  mod("ChaosDamageTaken", "BASE", -num)  } end,
	["%−(%d+) 承受的火焰伤害"] = function(num) return {  mod("FireDamageTaken", "BASE", -num)  } end,
	["%−(%d+) 承受的闪电伤害"] = function(num) return {  mod("LightningDamageTaken", "BASE", -num)  } end,
	["%−(%d+) 承受的冰霜伤害"] = function(num) return {  mod("ColdDamageTaken", "BASE", -num)  } end,
	["%−(%d+) 承受的物理伤害"] = function(num) return {  mod("PhysicalDamageTaken", "BASE", -num)  } end,
	["敌人在你造成的冰缓区域内承受的闪电伤害提高 (%d+)%%"] = function(num) return {  mod("LightningDamageTaken", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "Chilled" })  } end,
	["承受的来自致盲敌人的伤害降低 (%d+)%%"] = function(num) return {  mod("DamageTaken", "INC", -num, { type = "ActorCondition", actor = "enemy", var = "Blinded" })  } end,
	["承受来自致盲敌人的伤害降低 (%d+)%%"] = function(num) return {  mod("DamageTaken", "INC", -num, { type = "ActorCondition", actor = "enemy", var = "Blinded" })  } end,
	["每拥有 1 个暴击球，有 (%d+)%% 几率造成中毒"]= function(num) return { mod("PoisonChance", "BASE", num,{ type = "Multiplier", var = "PowerCharge" } ) } end,
	["每拥有 1 个暴击球，有 (%d+)%% 的几率造成中毒"]= function(num) return { mod("PoisonChance", "BASE", num,{ type = "Multiplier", var = "PowerCharge" } ) } end,
	["当暴击球达到上限时，获得等同 (%d+)%% 物理伤害的混沌伤害"] = function(num) return {  mod("PhysicalDamageGainAsChaos", "BASE", num,{ type = "StatThreshold", stat = "PowerCharges", thresholdStat = "PowerChargesMax" } )  } end,
	["你拥有至少 (%d+) 个【深海屏障】时，格挡几率额外提高 (%d+)%%"] = function(num1,_,num2) return {  mod("BlockChance", "BASE", num2,{ type = "StatThreshold", stat = "CrabBarriers", threshold = num1} )  } end,
	["每 (%d+) 点力量可使魔卫召唤上限额外提高 1 个"]= function(num) return {  mod("ActiveZombieLimit", "BASE", 1,{ type = "PerStat", stat = "Str", div = num })  } end,
	["每 (%d+) 点力量可使魔卫的召唤上限 ([%+%-]?%d+)"]= function(num) return {  mod("ActiveZombieLimit", "BASE", 1,{ type = "PerStat", stat = "Str", div = num })  } end,
	["([%+%-]?%d+) 【复苏的魔卫】数量上限"]= function(num) return {  mod("ActiveZombieLimit", "BASE", num)  } end,
	["([%+%-]?%d+) 【魔卫复苏】数量上限"]= function(num) return {  mod("ActiveZombieLimit", "BASE", num)  } end,
	["【复苏的魔卫】最大数量降低 (%d+)%%"]= function(num) return {  mod("ActiveZombieLimit", "INC", -num)  } end,
	["【魔卫复苏】最大数量降低 (%d+)%%"]= function(num) return {  mod("ActiveZombieLimit", "INC", -num)  } end,
	["([%+%-]?%d+) 最大怒火"]= function(num) return {  mod("MaximumRage", "BASE", num)  } end,
	["([%+%-]?%d+) 怒火数量上限"]= function(num) return {  mod("MaximumRage", "BASE", num)  } end,
	["([%+%-]?%d+) 暴击球和耐力球数量上限"]= function(num) return {  mod("PowerChargesMax", "BASE", num),mod("EnduranceChargesMax", "BASE", num)   } end,
	["暴击球和耐力球上限 ([%+%-]?%d+)"]= function(num) return {  mod("PowerChargesMax", "BASE", num),mod("EnduranceChargesMax", "BASE", num)   } end,
	["失去怒火的速度减慢 (%d+)%%"]= function(num) return {  mod("RageDuration", "INC", num)  } end,
	["【怒火】的衰减速度减缓 (%d+)%%"]= function(num) return {  mod("RageDuration", "INC", num)  } end,
	["持握剑类时，([%+%-]?%d+) 最大怒火"]= function(num) return {
	mod("MaximumRage", "BASE", num,{ type = "Condition", varList ={ "UsingSword" }})
	} end,
	["持握斧类时，每点【怒火】都使【流血】 ([%+%-]?%d+)%% 持续伤害加成"]= function(num) return {
	mod( "DotMultiplier","BASE", num,nil,nil,  KeywordFlag.Bleed,
	{ type = "Multiplier", var = "Rage"},
	{ type = "Condition", varList ={ "UsingAxe" }}
	)
	} end,
	["你可以额外附着一个烙印到敌人身上"] = { mod("BrandsAttachedLimit", "BASE", 1) },
	["可以施放 (%d+) 个额外烙印"]= function(num) return {  mod("ActiveBrandLimit", "BASE", num)  } end,
	["烙印的附着范围扩大 (%d+)%%"]= function(num) return {  mod("BrandAttachmentRange", "INC", num)  } end,
	["你每使敌人附着一种烙印，它们受到的伤害便提高 (%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num, { type = "Multiplier", var = "BrandsAttached" }) }) } end,
	["召唤愤怒狂灵的最大数量减少 (%d+)%%"]= function(num) return {  mod("ActiveRagingSpiritLimit", "INC", -num)  } end,
	["每有 (%d+) 层能量护盾可每秒回复 ([%d%.]+)%% 生命"]= function(_,num1,num2) return {  mod("LifeRegenPercent", "BASE", num2,{ type = "PerStat", stat = "EnergyShield", div = num1 })  } end,
	["移动时获得额外 (%d+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "Moving" } )  } end,
	["若你至少拥有 (%d+) 层能量护盾，则每秒回复 (%d+) 生命"]= function(num1,_,num2) return {
	mod("LifeRegen", "BASE", num2,{ type = "StatThreshold", stat = "EnergyShield", threshold = num1 })  } end,
	["血魔法"] = { mod("Keystone", "LIST", "祭血术") },
	["凡人信念"] = { mod("Keystone", "LIST", "凡人的信念") },
	["凡人的信念"] = { mod("Keystone", "LIST", "凡人的信念") },
	["致死定罪"] = { mod("Keystone", "LIST", "致死定罪") },
	["腐化的灵魂"] = { mod("Keystone", "LIST", "腐化的灵魂") },
	["腐化之魂"] = { mod("Keystone", "LIST", "腐化的灵魂") },
	["神圣血肉"] = { mod("Keystone", "LIST", "神圣血肉") },
	["不朽野望"] = { mod("Keystone", "LIST", "不朽野望") },
	["苦难秘辛"] = { mod("Keystone", "LIST", "苦难秘辛") },
	["近距离用弓击中后的总伤害额外提高 (%d+)%%"] = function(num) return {  mod("Damage", "MORE", num,nil,bor(ModFlag.Bow, ModFlag.Hit) , { type = "Condition", var = "AtCloseRange" } )  } end,
	["近距离用弓击中后的伤害总增 (%d+)%%"] = function(num) return {  mod("Damage", "MORE", num,nil,bor(ModFlag.Bow, ModFlag.Hit) , { type = "Condition", var = "AtCloseRange" } )  } end,
	["每个狂怒球可使攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack, { type = "Multiplier", var = "FrenzyCharge" })  } end,
	["移动时每有 1 个狂怒球，则每秒受到 (%d+) 冰霜伤害"]= function(num) return {  mod("ColdDegen", "BASE", num,{ type = "Multiplier", var = "FrenzyCharge" },{ type = "Condition", var = "Moving" })  } end,
	["药剂持续期间，获得 完美苦痛 天赋效果"] = { mod("Keystone", "LIST", "完美苦痛", { type = "Condition", var = "UsingFlask" }) }, --备注：grants perfect agony during flask effect
	["武器总伤害额外降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num, nil,ModFlag.Weapon)  } end,
	["总伤害额外降低 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num)  } end,
	["伤害总降 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", -num)  } end,
	["药剂持续期间，获得等同 (%d+)%% 物理伤害的冰霜伤害"]= function(num) return {  mod("PhysicalDamageGainAsCold", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["生效期间，瓦尔技能的伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,nil,nil,KeywordFlag.Vaal,{ type = "Condition", var = "UsingFlask" })  } end,
	["生效期间，瓦尔技能的暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,nil,nil,KeywordFlag.Vaal,{ type = "Condition", var = "UsingFlask" })  } end,
	["生效期间，瓦尔技能的总伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil,nil,KeywordFlag.Vaal,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，近战物理总伤害额外提高 (%d+)%%"]= function(num) return {  mod("PhysicalDamage", "MORE", num,nil, ModFlag.Melee,{ type = "Condition", var = "UsingFlask" })  } end,
	["生效期间近战物理伤害总增 (%d+)%%"]= function(num) return {  mod("PhysicalDamage", "MORE", num,nil, ModFlag.Melee,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，物理伤害的 (%d+)%% 转换为闪电伤害"]= function(num) return {  mod("PhysicalDamageConvertToLightning", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，闪电伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("LightningDamageLifeLeech", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，混沌伤害的 ([%d%.]+)%% 会转化为生命偷取"]= function(num) return {  mod("ChaosDamageLifeLeech", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，技能可以额外发射 (%d+) 个投射物"]= function(num) return {  mod("ProjectileCount", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，获得额外混沌伤害，其数值等同于 (%d+)%% 物理伤害"]= function(num) return {  mod("PhysicalDamageGainAsChaos", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，获得额外混沌伤害，其数值等同于 (%d+)%% 火焰、冰霜、闪电伤害"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["药剂持续期间，获得额外混沌伤害，其数值等同于 (%d+)%% 元素伤害"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["近期内你若打出过暴击，则每有 1 个暴击球，就会每秒受到 (%d+) 闪电伤害"]= function(num) return {  mod("LightningDegen", "BASE", num,{ type = "Multiplier", var = "PowerCharge" },{ type = "Condition", var = "CritRecently" }) } end,
	["该武器击中致盲敌人时，附加 (%d+) %- (%d+) 基础火焰伤害"]= function(_,num1,num2) return {
	mod("FireMin", "BASE", num1, { type = "Condition", var = "{Hand}Attack" } ,{ type = "ActorCondition", actor = "enemy", var = "Blinded" }),
	mod("FireMax", "BASE", num2, { type = "Condition", var = "{Hand}Attack" } ,{ type = "ActorCondition", actor = "enemy", var = "Blinded" })  } end,
	["人物等级每到达 (%d+) 级，该插槽内的【主动技能石】等级 %+(%d+)"] = function(div, _,num )return { mod("GemProperty", "LIST", { keyword = "active_skill", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "Multiplier", var = "Level", div = tonumber(div) }) } end,
	["玩家等级每提高 (%d+) 级，该武器攻击时便附加 (%d+) %- (%d+) 物理伤害"]= function(_,level,num1,num2) return {
	mod("PhysicalMin", "BASE", num1,nil,ModFlag.Attack,{ type = "Condition", var = "{Hand}Attack" },{ type = "Multiplier", var = "Level", div = level } ) ,
	mod("PhysicalMax", "BASE", num2,nil,ModFlag.Attack,{ type = "Condition", var = "{Hand}Attack" },{ type = "Multiplier", var = "Level", div = level } ) } end,
	["召唤生物击中时有 ([%d%.]+)%% 几率使目标中毒"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PoisonChance", "BASE", num) })  } end,
	["召唤生物击中时有 ([%d%.]+)%% 的几率使目标中毒"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PoisonChance", "BASE", num) })  } end,
	["召唤生物对中毒的敌人造成伤害的 ([%d%.]+)%% 转化为生命偷取"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Poisoned"}) })  } end,
	["获得额外火焰伤害，其数值等同于 (%d+)%% 剑类物理伤害"]= function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num,nil, ModFlag.Sword )  } end,
	["该武器对被点燃敌人的击中伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,nil,ModFlag.Hit,{ type = "Condition", var = "{Hand}Attack" } ,{ type = "ActorCondition", actor = "enemy", var = "Ignited" })  } end,
	["该武器对被冰冻敌人的击中伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,nil,ModFlag.Hit,{ type = "Condition", var = "{Hand}Attack" } ,{ type = "ActorCondition", actor = "enemy", var = "Frozen" })  } end,
	["该武器对被感电敌人的击中伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", num,nil,ModFlag.Hit,{ type = "Condition", var = "{Hand}Attack" } ,{ type = "ActorCondition", actor = "enemy", var = "Shocked" })  } end,
	["近期内你若使用过移动技能，技能可以额外发射 (%d+) 个投射物"]= function(num) return {  mod("ProjectileCount", "BASE", num, { type = "Condition", var = "UsedMovementSkillRecently" })  } end,
	["近期内你若使用过移动技能，则每秒回复 (%d+) 魔力"]= function(num) return {  mod("ManaRegen", "BASE", num, { type = "Condition", var = "UsedMovementSkillRecently" })  } end,
	["技能可以额外发射 (%d+) 个投射物"]= function(num) return {  mod("ProjectileCount", "BASE", num)  } end,
	["技能会发射 (%d+) 枚额外投射物"]= function(num) return {  mod("ProjectileCount", "BASE", num)  } end,
	["近期内你若被击中，技能可以额外发射 (%d+) 个投射物"]= function(num) return {  mod("ProjectileCount", "BASE", num, { type = "Condition", var = "BeenHitRecently" })  } end,
	["武器上的每个红色插槽使物理伤害提高 (%d+)%%"]= function(num) return {  mod("PhysicalDamage", "INC", num,nil, ModFlag.Weapon, { type = "Multiplier", var = "RedSocketIn{SlotName}" })  } end,
	["每个绿色插槽会使全局攻击速度提高 (%d+)%%"]= function(num) return {  mod("Speed", "INC", num,nil, ModFlag.Attack, { type = "Global" }, { type = "Multiplier", var = "GreenSocketIn{SlotName}" })  } end,
	["每个蓝色插槽会使你物理攻击伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("PhysicalDamageManaLeech", "BASE", num,nil, ModFlag.Attack, { type = "Multiplier", var = "BlueSocketIn{SlotName}" })  } end,
	["每个白色插槽可以扩大 %+(%d+) 近战武器范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num, { type = "Multiplier", var = "WhiteSocketIn{SlotName}" })  } end,
	["%+(%d+) 匕首近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Dagger   )  } end,
	["%+(%d+) 长杖类近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Staff   )  } end,
	["%+(%d+) 剑类近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Sword   )  } end,
	["%+(%d+) 爪类近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Claw   )  } end,
	["%+(%d+) 斧类近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Axe   )  } end,
	["%+(%d+) 锤类和短杖类近战范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num,nil,ModFlag.Mace   )  } end,
	["被击中时承受 ([%+%-]?%d+) 物理伤害"] = function(num) return {  mod("PhysicalDamageTaken", "BASE", num)  } end,
	["每等级被击中时，承受 ([%+%-]?%d+) 物理伤害"] = function(num) return {  mod("PhysicalDamageTaken", "BASE", num, { type = "Multiplier", var = "Level", div = tonumber(div) })  } end,
	["静止时获得【霸体】"] = { mod("Keystone", "LIST", "霸体", { type = "Condition", var = "Stationary" }) },
	["每个红色插槽会使你物理攻击伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("PhysicalDamageLifeLeech", "BASE", num,nil, ModFlag.Attack, { type = "Multiplier", var = "RedSocketIn{SlotName}" })  } end,
	["每个绿色插槽 %+(%d+)%% 攻击和法术暴击伤害加成"]= function(num) return {  mod("CritMultiplier", "BASE", num,{ type = "Global" }, { type = "Multiplier", var = "GreenSocketIn{SlotName}" })  } end,
	["每个白色插槽会使防御提高 (%d+)%%"]= function(num) return {  mod("Defences", "INC", num,{ type = "Global" }, { type = "Multiplier", var = "WhiteSocketIn{SlotName}" })  } end,
	["装备于副手时有 (%d+)%% 额外格挡几率"]= function(num) return {  mod("BlockChance", "BASE", num, { type = "SlotNumber", num = 2 })  } end,
	["副手攻击和法术附加 (%d+) %- (%d+) 基础混沌伤害"]= function(_,num1,num2) return {
	mod("ChaosMin", "BASE", tonumber(num1), { type = "InSlot", num = 2 }),
	mod("ChaosMax", "BASE", tonumber(num2), { type = "InSlot", num = 2 }),
	} end,
	["神殿效果提高 (%d+)%%"]= function(num) return {  mod("ShrineEffect", "INC", num)  } end,
	["你具有次级威猛神龛效果"] = { flag("Condition:LesserMassiveShrine") },
	["你具有次级狂击神龛效果"] = { flag("Condition:LesserBrutalShrine") },
	["不洁之力"] = { flag("Condition:UnholyMight") },
	["点燃敌人时获得 %d+ 秒【她的拥抱】效果"] = { flag("Condition:CanGainHerEmbrace") },
	["召唤生物的攻击额外造成 (%d+) %- (%d+) 物理伤害"]= function(_,num1,num2) return {mod("MinionModifier", "LIST", {mod=mod("PhysicalMin","BASE",num1,nil,ModFlag.Attack )  }),mod("MinionModifier", "LIST", { mod = mod("PhysicalMax", "BASE", num2,nil,ModFlag.Attack )})} end,
	["近期内你若被击中过，则每有 1 个耐力球，就会每秒受到 (%d+) 火焰伤害"]
	= function(num) return {  mod("FireDegen", "BASE", num, { type = "Multiplier", var = "EnduranceCharge" }, { type = "Condition", var = "BeenHitRecently" })  } end,
	["对流血敌人造成的攻击伤害的 (%d+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "Bleeding" })  } end,
	["游侠：移动速度提高 (%d+)%%"]= function(num) return {  mod("MovementSpeed", "INC", num,{ type = "Condition", var = "ConnectedTo游侠Start" })  } end,
	["圣堂武僧：伤害穿透 (%d+)%% 火焰、冰霜、闪电抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", num,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" })  } end,
	["圣堂武僧：伤害穿透 (%d+)%% 元素抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", num,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" })  } end,
	["暗影：%+([%d%.]+)%% 暴击率"]= function(num) return {  mod("CritChance", "BASE", num,{ type = "Condition", var = "ConnectedTo暗影刺客Start" })  } end,
	["贵族：%+(%d+) 所有属性"]= function(num) return {
	mod("Str", "BASE", num,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Dex", "BASE", num,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Int", "BASE", num,{ type = "Condition", var = "ConnectedTo贵族Start" })
	} end,
	["【(.+)】的持续时间缩短 (%d+)%%"]  = function( _,skill_name, num) return { mod("Duration", "INC",-num, { type = "SkillName", skillName = FuckSkillActivityCnName(skill_name) }) } end,
	["召唤生物有额外 (%d+)%% 躲避击中几率"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("AttackDodgeChance", "BASE", num) })  } end,
	["灵体有 (%d+) 秒的持续时间"] = function(num) return { mod("SkillData", "LIST", { key = "duration", value = 6 }, { type = "SkillName", skillName = "召唤灵体" }) } end,
	["【(.+)】的魔力消耗降低 (%d+)%%"] = function( _,skill_name, num) return { mod("ManaCost", "INC",-num, { type = "SkillName", skillName = FuckSkillActivityCnName(skill_name) }) } end,
	["技能的总魔力消耗额外降低 (%d+)%%"] = function( num) return { mod("ManaCost", "MORE",-num) } end,
	["技能总魔力消耗额外降低 (%d+)%%"] = function( num) return { mod("ManaCost", "MORE",-num) } end,
	["召唤生物有 (%d+)%% 几率冰冻、感电、点燃敌人"] = function(num) return {
	mod("MinionModifier", "LIST", { mod = mod("EnemyFreezeChance", "BASE", num) }),
	mod("MinionModifier", "LIST", { mod = mod("EnemyShockChance", "BASE", num) }),
	mod("MinionModifier", "LIST", { mod = mod("EnemyIgniteChance", "BASE", num) }),
	} end,
	["召唤生物有 (%d+)%% 的几率冰冻、感电、点燃敌人"] = function(num) return {
	mod("MinionModifier", "LIST", { mod = mod("EnemyFreezeChance", "BASE", num) }),
	mod("MinionModifier", "LIST", { mod = mod("EnemyShockChance", "BASE", num) }),
	mod("MinionModifier", "LIST", { mod = mod("EnemyIgniteChance", "BASE", num) }),
	} end,
	["持续吟唱技能总魔力消耗 ([%+%-]?%d+)"] =function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ManaCost", "BASE", num, nil, 0, { type = "SkillType", skillType = SkillType.Channelled }) })}end,
	["插槽内的移动技能不消耗魔力"] = function() return { mod("ExtraSkillMod", "LIST", { mod = mod("ManaCost", "MORE", -100, nil, 0,  KeywordFlag.Movement) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内攻击技能的总魔力消耗 ([%+%-]?%d+)"]= function(num) return { mod("ManaCost", "BASE",num, { type = "SocketedIn", slotName = "{SlotName}", keyword = "attack" }  ) } end,
	["插槽内的法术魔力消耗降低 (%d+)%%"]= function(num) return { mod("ManaCost", "INC",-num, { type = "SocketedIn", slotName = "{SlotName}", keyword = "spell" }  ) } end,
	["野蛮人： 近战技能范围扩大 (%d+)%%"]= function(num) return {  mod("AreaOfEffect", "INC", num,nil, ModFlag.Melee,{ type = "Condition", var = "ConnectedTo野蛮人Start" })  } end,
	["决斗者：攻击伤害的 ([%d%.]+)%% 会转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", num,nil, ModFlag.Attack,{ type = "Condition", var = "ConnectedTo决斗者Start" })  } end,
	["女巫：每秒回复 ([%d%.]+)%% 最大魔力"]= function(num) return {  mod("ManaRegenPercent", "BASE", num, { type = "Condition", var = "ConnectedTo女巫Start" })  } end,
	["魔像的增益效果提高 (%d+)%%"] = function(num) return {  mod("BuffEffect", "INC", num, { type = "SkillType", skillType = SkillType.Golem })  } end,
	["【召唤魔像】的冷却速度提高 (%d+)%%"]  = function(num) return { mod("MinionModifier", "LIST", { mod = mod("CooldownRecovery", "INC",num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像每秒回复 ([%d%.]+)%% 最大生命"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["召唤的魔像每秒回复 ([%d%.]+)%% 生命"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["若你有 3 个起源天赋珠宝，召唤魔像的数量 %+(%d)"] = function(num) return { mod("ActiveGolemLimit", "BASE", num, { type = "MultiplierThreshold", var = "PrimordialItem", threshold = 3 }) } end,
	["你身上的每层中毒状态使你获得 %+(%d+)%% 混沌抗性"]= function(num) return {  mod("ChaosResist", "BASE", num, { type = "Multiplier", var = "PoisonStack" } )  } end,
	["【苦痛爬行者】的伤害提高 (%d+)%%"]= function(num) return {  mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "SkillId", skillId = "HeraldOfAgony" })   } end,
	["召唤的苦痛爬行者伤害提高 (%d+)%%"]= function(num) return {  mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "SkillId", skillId = "HeraldOfAgony" })   } end,
	["召唤的苦痛爬行者额外发射 (%d+) 的投射物"]= function(num) return {  mod("MinionModifier", "LIST", { mod = mod("ProjectileCount", "BASE", num) }, { type = "SkillId", skillId = "HeraldOfAgony" })   } end,
	["受到【愤怒】影响时，(%d+)%% 的物理伤害转化为火焰伤害"]= function(num) return {  mod("PhysicalDamageConvertToFire", "BASE", num,{ type = "Condition", var = "AffectedBy愤怒" })  } end,
	["受到【愤怒】影响时，火焰伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("FireDamageLifeLeech", "BASE", num,{ type = "Condition", var = "AffectedBy愤怒" })  } end,
	["受到【愤怒】影响时，获得物理伤害 (%d+)%% 的额外火焰伤害"]= function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num,{ type = "Condition", var = "AffectedBy愤怒" })  } end,
	["受到【清晰】影响时，受到伤害的 (%d+)%% 伤害优先从魔力扣除"]= function(num) return {  mod("DamageTakenFromManaBeforeLife", "BASE", num,{ type = "Condition", var = "AffectedBy清晰" })  } end,
	["受到【清晰】影响时，获得等同最大魔力 (%d+)%% 的额外最大能量护盾"]= function(num) return {  mod("ManaGainAsEnergyShield", "BASE", num,{ type = "Condition", var = "AffectedBy清晰" })  } end,
	["受到【坚定】影响时，有 (%d+)%% 几率格挡"]= function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "AffectedBy坚定" })  } end,
	["受到【坚定】影响时攻击伤害格挡几率 %+(%d+)%%"]= function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "AffectedBy坚定" })  } end,
	["受到【坚定】影响时，获得额外 (%d+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "AffectedBy坚定" })  } end,
	["受到【纯净之捷】影响时，获得额外 (%d+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "AffectedBy纯净之捷" })  } end,
	["受到【纪律】影响时，最大能量护盾每秒回复 ([%d%.]+)%%"]= function(num) return {  mod("EnergyShieldRegenPercent", "BASE", num,{ type = "Condition", var = "AffectedBy纪律" })  } end,
	["受到【纪律】影响时，能量护盾提早 (%d+)%% 开始恢复"]= function(num) return {  mod("EnergyShieldRechargeFaster", "INC", num,{ type = "Condition", var = "AffectedBy纪律" })  } end,
	["受到【优雅】影响时，有 %+(%d+)%% 几率闪避攻击"]= function(num) return {  mod("EvadeChance", "BASE", num,{ type = "Condition", var = "AffectedBy优雅" })  } end,
	["受到【优雅】影响时，有 %+(%d+)%% 的几率闪避攻击"]= function(num) return {  mod("EvadeChance", "BASE", num,{ type = "Condition", var = "AffectedBy优雅" })  } end,
	["受到【迅捷】影响时获得【迷踪】状态"]= { flag("Condition:Phasing", { type = "Condition", var = "AffectedBy迅捷" }) },
	["受到【元素净化】影响时，受到击中物理伤害的 (%d+)%% 转换为冰霜伤害"]= function(num) return {  mod("PhysicalDamageTakenAsCold", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy元素净化" })  } end,
	["受到【元素净化】影响时，受到击中物理伤害的 (%d+)%% 转换为火焰伤害"]= function(num) return {  mod("PhysicalDamageTakenAsFire", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy元素净化" })  } end,
	["受到【元素净化】影响时，受到击中物理伤害的 (%d+)%% 转换为闪电伤害"]= function(num) return {  mod("PhysicalDamageTakenAsLightning", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy元素净化" })  } end,
	["受到【火焰净化】影响时，受到击中物理伤害的 (%d+)%% 转换为火焰伤害"]= function(num) return {  mod("PhysicalDamageTakenAsFire", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy火焰净化" })  } end,
	["受到【冰霜净化】影响时，受到击中物理伤害的 (%d+)%% 转换为冰霜伤害"]= function(num) return {  mod("PhysicalDamageTakenAsCold", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy冰霜净化" })  } end,
	["受到【闪电净化】影响时，受到击中物理伤害的 (%d+)%% 转换为闪电伤害"]= function(num) return {  mod("PhysicalDamageTakenAsLightning", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy闪电净化" })  } end,
	["受到【活力】影响时，伤害的 ([%d%.]+)%% 转化为生命偷取"]= function(num) return {  mod("DamageLifeLeech", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy活力" })  } end,
	["受到【活力】影响时， 每秒回复 ([%d%.]+) 生命"]= function(num) return {  mod("LifeRegen", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy活力" })  } end,
	["被活力影响时每秒再生 ([%d%.]+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy活力" })  } end,
	["受到【雷霆】影响时，闪电伤害的 ([%d%.]+)%% 转化为魔力偷取"]= function(num) return {  mod("LightningDamageManaLeech", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy雷霆" })  } end,
	["受到【雷霆】影响时，闪电伤害的 ([%d%.]+)%% 转化为能量护盾偷取"]= function(num) return {  mod("LightningDamageEnergyShieldLeech", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy雷霆" })  } end,
	["受到【雷霆】影响时，获得物理伤害 (%d+)%% 的额外闪电伤害"]= function(num) return {  mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy雷霆" })  } end,
	["受到【雷霆】影响时，(%d+)%% 的物理伤害转化为闪电伤害"]= function(num) return {  mod("PhysicalDamageConvertToLightning", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy雷霆" })  } end,
	["受到【奋锐光环】影响时，位于奉献地面之上的敌人受到的暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy奋锐光环" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" })  } end,
	["受到【奋锐光环】影响时，从能量护盾偷取中获得的每秒最大总恢复量提高 (%d+)%%"]= function(num) return {  mod("MaxEnergyShieldLeechRate", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy奋锐光环" })  } end,
	["当你受到奋锐光环影响时，创造的【奉献地面】可以使敌人承受的伤害提高 (%d+)%%"]= function(num) return {  mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" },{ type = "Condition", var = "AffectedBy奋锐光环" })  } end,
	["你创造的【奉献地面】可以使敌人承受的伤害提高 (%d+)%%"]= function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) },
	{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" })  } end,
	["受【奋锐光环】影响时，暴击穿透敌人 (%d+)%% 的元素抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", tonumber(num), { type = "Condition", var = "CriticalStrike" },{ type = "Condition", var = "AffectedBy奋锐光环" })  } end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 非异常状态的持续混沌伤害加成"]= function(num) return {  mod("NonAilmentChaosDotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 非异常状态持续混沌伤害额外加成"]= function(num) return {  mod("NonAilmentChaosDotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受到【怨毒光环】影响时，技能持续时间提高 (%d+)%%"]= function(num) return {  mod("Duration", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受【怨毒光环】影响时，你造成的伤害类异常状态的伤害生效速度提高 (%d+)%%"]= function(num) return {
	mod("PoisonFaster", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" }) ,
	mod("IgniteBurnFaster", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" }) ,
	mod("BleedFaster", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" }) ,
	} end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 持续伤害加成"]= function(num) return {  mod("DotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["被【怨毒光环】影响时，([%+%-]?%d+)%% 伤害持续时间加成"]= function(num) return {  mod("DotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 非异常状态混沌伤害持续时间加成"]= function(num) return {  mod("NonAilmentChaosDotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 持续冰霜伤害加成"]= function(num) return {  mod("ColdDotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受【怨毒光环】影响时，([%+%-]?%d+)%% 冰霜伤害持续时间加成"]= function(num) return {  mod("ColdDotMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })  } end,
	["受到【怨毒光环】影响时，生命和能量护盾回复率提高 (%d+)%%"]= function(num) return {
	mod("EnergyShieldRecoveryRate", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" }),
	mod("LifeRecoveryRate", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy怨毒光环" })
	} end,
	["装备时施放 (%d+) 级的【艾贝拉斯之怒】"]= function(num) return{mod("ExtraSkill", "LIST", { skillId = "RepeatingShockwave", level = tonumber(num), triggered = true}) }end,
	["每 (%d+) 点敏捷提高 %+(%d+) 最大生命"] =function(_,num1,num2) return {  mod("Life", "BASE", tonumber(num2),{ type = "PerStat", stat = "Dex", div = tonumber(num1) })  } end,
	["最大魔力每有 (%d+) 点，则有 (%d+)%% 几率不被攻击和法术击中，最多 (%d+)%%"]=function(_,num1,num2,num3) return {
	mod("AttackDodgeChance", "BASE", num2,{ type = "PerStat", stat = "Mana", div = num1, limit = tonumber(num3), limitTotal = true }),
	mod("SpellDodgeChance", "BASE", num2,{ type = "PerStat", stat = "Mana", div = num1, limit = tonumber(num3), limitTotal = true }) } end,
	["最大魔力每有 (%d+) 点，则有 (%d+)%% 的几率不被攻击和法术击中，最多 (%d+)%%"]=function(_,num1,num2,num3) return {
	mod("AttackDodgeChance", "BASE", num2,{ type = "PerStat", stat = "Mana", div = num1, limit = tonumber(num3), limitTotal = true }),
	mod("SpellDodgeChance", "BASE", num2,{ type = "PerStat", stat = "Mana", div = num1, limit = tonumber(num3), limitTotal = true }) } end,
	["拥有【鸟之斗魄】时每秒回复 (%d+) 生命"]= function(num) return {  mod("LifeRegen", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy鸟之斗魄" } )  } end,
	["拥有【鸟之斗魄】时每秒回复 (%d+) 魔力"]= function(num) return {  mod("ManaRegen", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy鸟之斗魄" } )  } end,
	["每 (%d+) 点力量使最大能量护盾提高 %+(%d+)"]= function(_,num1,num2) return {  mod("EnergyShield", "BASE", num2,{ type = "PerStat", stat = "Str", div = num1 } )  } end,
	["此物品上的【(.+)技能石】由 (%d+) 级的 (.+) 辅助"] = function( _,_2,num, support) return { mod("ExtraSupport", "LIST",
	{ skillId = FuckSkillSupportCnName(support), level = tonumber(num) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["每 (%d+) 闪避值提高 (%d+)%% 移动速度，最多 (%d+)%%"]=function(_,num1,num2,num3) return {
	mod("MovementSpeed", "INC", num2,{ type = "PerStat", stat = "Evasion", div = num1, limit = tonumber(num3), limitTotal = true }) } end,
	["当你使用物品上的技能时，有 (%d+)%% 的几率触发 (%d+) 级的 【暗影姿态】"]
	= function(_,num,levelnum) return{mod("ExtraSkill", "LIST", { skillId = "ShadeForm", level = levelnum}) }end,
	["近期内你若未被击中，则受到的总伤害额外降低 (%d+)%%"]= function(num) return {  mod("DamageTaken", "MORE", -tonumber(num), { type = "Condition", var = "BeenHitRecently", neg = true } )  } end,
	["若你近期内未被击中，则受到的伤害总降 (%d+)%%"]= function(num) return {  mod("DamageTaken", "MORE", -tonumber(num), { type = "Condition", var = "BeenHitRecently", neg = true } )  } end,
	["不再通过力量获得伤害加成，每 (%d+) 点力量会使近战伤害提高 (%d+)%%"] = function( _,perStr, num) return { mod("StrDmgBonusRatioOverride", "BASE", tonumber(num) / tonumber(perStr)) } end,
	["不再通过力量获得伤害加成，每 (%d+) 点力量会使近战物理伤害提高 (%d+)%%"] = function( _,perStr, num) return { mod("StrDmgBonusRatioOverride", "BASE", tonumber(num) / tonumber(perStr)) } end,
	["【(.+)】的增益效果提高 (%d+)%%"] = function(_, skill_name,num) return { mod("BuffEffect", "INC", tonumber(num),{ type = "SkillName", skillName = FuckSkillActivityCnName(skill_name) } ) } end,
	["插槽内魔像技能攻击和施法速度提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num)) },
	{ type = "SkillType", skillType = SkillType.Golem },  { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内魔像技能的增益效果提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffect", "INC", tonumber(num)) },
	{ type = "SkillType", skillType = SkillType.Golem },  { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内魔像技能获得等同最大生命 (%d+)%% 的额外能量护盾"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("LifeGainAsEnergyShield", "BASE", num) },
	{ type = "SkillType", skillType = SkillType.Golem },  { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["插槽内的魔像技能每秒回复 (%d+)%% 生命"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("LifeRegenPercent", "BASE", tonumber(num)) },
	{ type = "SkillType", skillType = SkillType.Golem },  { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["你受到的时空锁链效果降低 (%d+)%%"] = function(num) return { mod("CurseEffectOnSelf", "INC", -tonumber(num), { type = "SkillName", skillName = "时空锁链" }) } end,
	["在奉献地面上时有 (%d+)%% 额外格挡率"]= function(num) return {  mod("BlockChance", "BASE", tonumber(num),{ type = "Condition", var = "OnConsecratedGround"})  } end,
	["右戒指栏位：每秒回复 (%d+)%% 能量护盾"]=function(num) return {  mod("EnergyShieldRegenPercent", "BASE", tonumber(num),{ type = "SlotNumber", num = 2 })  } end,
	["左戒指栏位：每秒回复 (%d+) 魔力"]=function(num) return {  mod("ManaRegen", "BASE", tonumber(num),{ type = "SlotNumber", num = 1 })  } end,
	["异灵魔侍获得【火之化身】"] = { mod("MinionModifier", "LIST", { mod = mod("Keystone", "LIST", "火之化身") }, { type = "SkillName", skillName = "召唤魔侍" }) },
	["此物品上的技能石额外造成 (%d+) %- (%d+) 火焰伤害"] = function(_,num1,num2) return {
	mod("FireMin", "BASE", tonumber(num1),{ type = "SocketedIn", slotName = "{SlotName}" } ),
	mod("FireMax", "BASE", tonumber(num2),{ type = "SocketedIn", slotName = "{SlotName}" } ) } end,
	["生命偷取会套用于能量护盾"] = { flag("GhostReaver") },
	["中毒 (%d+) 层以上的敌人被该武器攻击击中时，该武器附加 (%d+) %- (%d+) 混沌伤害"] = function(num1,num2,num3,num4) return {
	mod("ChaosMin", "BASE", tonumber(num3),{ type = "Condition", var = "{Hand}Attack" } , { type = "MultiplierThreshold", actor = "enemy", var = "PoisonStack", threshold = tonumber(num1) } ),
	mod("ChaosMax", "BASE", tonumber(num4), { type = "Condition", var = "{Hand}Attack" } ,{ type = "MultiplierThreshold", actor = "enemy", var = "PoisonStack", threshold = tonumber(num1) } )
	} end,
	["使用该武器攻击可穿透 (%d+)%% 闪电抗性"]= function(num) return {  mod("LightningPenetration", "BASE", num,{ type = "Condition", var = "{Hand}Attack" } )  } end,
	["使用该武器攻击可穿透 (%d+)%% 火焰抗性"]= function(num) return {  mod("FirePenetration", "BASE", num,{ type = "Condition", var = "{Hand}Attack" } )  } end,
	["使用该武器攻击可穿透 (%d+)%% 冰霜抗性"]= function(num) return {  mod("ColdPenetration", "BASE", num,{ type = "Condition", var = "{Hand}Attack" } )  } end,
	["使用该武器攻击可穿透 (%d+)%% 元素抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", num,{ type = "Condition", var = "{Hand}Attack" } )  } end,
	["使用该武器攻击可穿透 (%d+)%% 混沌抗性"]= function(num) return {  mod("ChaosPenetration", "BASE", num,{ type = "Condition", var = "{Hand}Attack" } )  } end,
	["【([^\\x00-\\xff]*)】的伤害穿透 (%d+)%% 的闪电抗性"]= function(_,skill_name,num)  return {  mod("LightningPenetration", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的伤害穿透 (%d+)%% 的火焰抗性"]= function(_,skill_name,num)  return {  mod("FirePenetration", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的伤害穿透 (%d+)%% 的冰霜抗性"]= function(_,skill_name,num)  return {  mod("ColdPenetration", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的伤害穿透 (%d+)%% 的元素抗性"]= function(_,skill_name,num)  return {  mod("ElementalPenetration", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的伤害穿透 (%d+)%% 的混沌抗性"]= function(_,skill_name,num)  return {  mod("ChaosPenetration", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】发射一支额外的箭矢"]= function(_,skill_name) return {  mod("ProjectileCount", "BASE", 1,{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】发射 (%d+) 支额外的箭矢"]= function(_,skill_name,num) return {  mod("ProjectileCount", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】穿透 (%d+) 个额外的额外的目标"]= function(_,skill_name,num) return {  mod("PierceCount", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["([^\\x00-\\xff]*)光环的效果提高 (%d+)%%"]= function(_, skill_name,num) return {
	skill_name=="非诅咒类" and   mod("AuraEffect", "INC", tonumber(num),{ type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } )   or  mod("AuraEffect", "INC", tonumber(num),  { type = "SkillName", skillName = FuckSkillActivityCnName(skill_name) })
	} end,
	["【(.+)】的光环效果提高 (%d+)%%"]= function(_, skill_name,num) return {  mod("AuraEffect", "INC", tonumber(num),  { type = "SkillName", skillName = FuckSkillActivityCnName(skill_name) })  } end,
	["此物品上的技能石总攻击和施法速度额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "MORE", tonumber(num)) },  { type = "SocketedIn", slotName ="{SlotName}"} ) } end,
	["此物品上的技能石火焰、冰霜、闪电总伤害额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ElementalDamage", "MORE", tonumber(num)) }, { type = "SocketedIn", slotName ="{SlotName}"} ) } end,
	["此物品上的技能石元素总伤害额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ElementalDamage", "MORE", tonumber(num)) }, { type = "SocketedIn", slotName ="{SlotName}"} ) } end,
	["承受的冰霜伤害降低 (%d+)%%"]= function(num) return {  mod("ColdDamageTaken", "INC", -tonumber(num))  } end,
	["承受的持续物理伤害降低 (%d+)%%"]= function(num) return {  mod("PhysicalDamageTakenOverTime", "INC", -tonumber(num))  } end,
	["承受的闪电伤害降低 (%d+)%%"]= function(num) return {  mod("LightningDamageTaken", "INC", -tonumber(num))  } end,
	["你的法术每击中 1 个敌人会回复 %+(%d+) 魔力"]= function(num) return {  mod("ManaOnHit", "BASE", tonumber(num),nil,ModFlag.Spell )  } end,
	["你的法术每击中 1 个敌人会回复 %+(%d+) 生命"]= function(num) return {  mod("LifeOnHit", "BASE", tonumber(num),nil,ModFlag.Spell )  } end,
	["药剂持续期间，获得额外 (%d+)%% 物理伤害减免"] = function(num) return {  mod("PhysicalDamageReduction", "BASE", tonumber(num),  { type = "Condition", var = "UsingFlask" })  } end,
	["此物品上的技能石持续总伤害额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", tonumber(num),nil,ModFlag.Dot) },  { type = "SocketedIn", slotName ="{SlotName}"} ) } end,
	["击中时有 (%d+)%% 几率施放 (%d+) 级的【(.+)】"]= function( _,chance,num, skill) return triggerExtraSkill(skill, tonumber(num)) end,
	["击中时有 (%d+)%% 的几率施放 (%d+) 级的【(.+)】"]= function( _,chance,num, skill) return triggerExtraSkill(skill, tonumber(num)) end,
	["药剂持续期间，暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", tonumber(num),{ type = "Condition", var = "UsingFlask" } )  } end,
	["近期内你若没有击败过敌人，则伤害穿透 (%d+)%% 元素抗性"]= function(num) return {  mod("ElementalPenetration", "BASE", tonumber(num),{ type = "Condition", var = "KilledRecently", neg = true }  )  } end,
	["击中时触发【(.+)】"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["击败敌人时触发【(.+)】"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["击杀时触发【(.+)】"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	--这个不支持，【寒冰之誓】有问题：["你的技能或召唤生物击败敌人时触发【(.+)】"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["被击中时触发【(.+)】"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["先祖战士长图腾范围扩大 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "INC", tonumber(num),nil,nil, KeywordFlag.Totem,{ type = "SkillName", skillName = "先祖战士长" })  } end,
	["先祖卫士图腾造成的伤害提高 (%d+)%%"] = function(num) return {  mod("Damage", "INC", tonumber(num),nil,nil, KeywordFlag.Totem,{ type = "SkillName", skillName = "先祖卫士" })  } end,
	["先祖卫士放置速度提高 (%d+)%%"] = function(num) return {  mod("TotemPlacementSpeed", "INC", tonumber(num),nil,nil, KeywordFlag.Totem,{ type = "SkillName", skillName = "先祖卫士" })  } end,
	["先祖卫士的火焰、冰霜、闪电抗性 %+(%d+)%%"] = function(num) return {  mod("ElementalResist", "BASE", tonumber(num),nil,nil, KeywordFlag.Totem,{ type = "SkillName", skillName = "先祖卫士" })  } end,
	["先祖卫士的元素抗性 %+(%d+)%%"] = function(num) return {  mod("ElementalResist", "BASE", tonumber(num),nil,nil, KeywordFlag.Totem,{ type = "SkillName", skillName = "先祖卫士" })  } end,
	["【([^\\x00-\\xff]*)】范围扩大 (%d+)%%"] = function(_,skill_name,num) return {  mod("AreaOfEffect", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["在【寒冰弹】上施放时，【漩涡】的范围效果扩大 (%d+)%%"]= function(num) return {  mod("AreaOfEffect", "INC", tonumber(num),{ type = "Condition", var = "CastOnFrostbolt" },{ type = "SkillName", skillName ="漩涡" })  } end,
	["在【寒冰弹】上施放时，【漩涡】的效果区域扩大 (%d+)%%"]= function(num) return {  mod("AreaOfEffect", "INC", tonumber(num),{ type = "Condition", var = "CastOnFrostbolt" },{ type = "SkillName", skillName ="漩涡" })  } end,
	["【([^\\x00-\\xff]*)】可以额外发射 (%d+) 个投射物"]= function(_,skill_name,num) return {  mod("ProjectileCount", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】可以额外发射 (%d+) 个箭矢"]= function(_,skill_name,num) return {  mod("ProjectileCount", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】有 (%d+)%% 几率造成双倍伤害"]= function(_,skill_name,num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】有 (%d+)%% 的几率造成双倍伤害"]= function(_,skill_name,num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的总移动速度额外提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("MovementSpeed", "MORE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的移动速度总增 (%d+)%%"]= function(_,skill_name,num) return {  mod("MovementSpeed", "MORE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["([^\\x00-\\xff]*)魔像给予你的增益效果提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("BuffEffect", "INC", tonumber(num),{ type = "SkillName", skillName ="召唤"..skill_name:gsub("雷电","闪电").."魔像" })  } end,
	["([^\\x00-\\xff]*)魔像给与你的增益效果提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("BuffEffect", "INC", tonumber(num),{ type = "SkillName", skillName ="召唤"..skill_name:gsub("雷电","闪电").."魔像" })  } end,
	["%+(%d+)%% ([^\\x00-\\xff]*)魔像的火焰、冰霜、闪电抗性"] = function(_,num,skill_name) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤"..skill_name:gsub("雷电","闪电").."魔像" })  } end,
	["%+(%d+)%% ([^\\x00-\\xff]*)魔像的元素抗性"] = function(_,num,skill_name) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤"..skill_name:gsub("雷电","闪电").."魔像" })  } end,
	["召唤的([^\\x00-\\xff]*)魔像获得 %+(%d+)%% 所有元素抗性"] = function(_,num,skill_name) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤"..skill_name:gsub("雷电","闪电").."魔像" })  } end,
	["【([^\\x00-\\xff]*)】的范围扩大 (%d+)%%"]= function(_,skill_name,num) return {  mod("AreaOfEffect", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["攻城炮台的放置速度提高 (%d+)%%"]= function(num) return {  mod("TotemPlacementSpeed", "INC", tonumber(num),{ type = "SkillName", skillName ="攻城炮台" })  } end,
	["%+(%d+)%% 幻化守卫的火焰、冰霜、闪电抗性"] = function(_,num,skill_name) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="幻化守卫" })  } end,
	["%+(%d+)%% 幻化守卫的元素抗性"] = function(_,num,skill_name) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="幻化守卫" })  } end,
	["【([^\\x00-\\xff]*)】爆炸范围扩大 (%d+)%%"]= function(_,skill_name,num) return {  mod("AreaOfEffectSecondary", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】对流血敌人附加 (%d+) %- (%d+) 基础物理伤害"]= function(_,skill_name,num1,num2) return {
	mod("PhysicalMin", "BASE", num1,nil,0, KeywordFlag.Hit, { type = "ActorCondition", actor = "enemy", var = "Bleeding" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) }) ,
	mod("PhysicalMax", "BASE", num2, nil,0,KeywordFlag.Hit, { type = "ActorCondition", actor = "enemy", var = "Bleeding" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) }) } end,
	["冰霜新星有 %+(%d+)%% 冰冻几率"]= function(num) return {  mod("EnemyFreezeChance", "BASE", tonumber(num),{ type = "SkillName", skillName ="冰霜新星" })  } end,
	["冰霜之锤有 %+(%d+)%% 几率冰冻"]= function(num) return {  mod("EnemyFreezeChance", "BASE", tonumber(num),{ type = "SkillName", skillName ="冰霜之锤" })  } end,
	["冰霜之锤有 %+(%d+)%% 的几率冰冻"]= function(num) return {  mod("EnemyFreezeChance", "BASE", tonumber(num),{ type = "SkillName", skillName ="冰霜之锤" })  } end,
	["【燃火烧尽】范围效果扩大 (%d+)%%"]= function(num) return {  mod("AreaOfEffect", "INC", tonumber(num),{ type = "SkillName", skillName ="烧毁" })  } end,
	["回春图腾的光环效果提高 (%d+)%%"]= function(num) return {  mod("AuraEffect", "INC", tonumber(num),{ type = "SkillName", skillName ="回春图腾" })  } end,
	["火球有 %+(%d+)%% 几率点燃"]= function(num) return {  mod("EnemyIgniteChance", "BASE", tonumber(num),{ type = "SkillName", skillName ="火球" })  } end,
	["火球有 %+(%d+)%% 的几率点燃"]= function(num) return {  mod("EnemyIgniteChance", "BASE", tonumber(num),{ type = "SkillName", skillName ="火球" })  } end,
	["【([^\\x00-\\xff]*)】有 %+(%d+)%% 的几率点燃"]=  function(_,skill_name,num)  return {  mod("EnemyIgniteChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】有 %+(%d+)%% 的几率感电"]=  function(_,skill_name,num)  return {  mod("EnemyShockChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】和其召唤生物的伤害提高 (%d+)%%"] = function(_,skill_name,num)  return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", tonumber(num)) },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】和该技能的召唤生物攻击速度提高 (%d+)%%"] = function(_,skill_name,num)  return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack) },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【火焰新星】的地雷伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", tonumber(num),{ type = "SkillName", skillName ="火焰新星地雷" })  } end,
	["【([^\\x00-\\xff]*)】会使攻击速度额外提高 (%d+)%%"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack,{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】会使攻击速度总增 (%d+)%%"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack,{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】的护体持续时间延长 (%d+)%%"]= function(_,skill_name,num) return {  mod("FortifyDuration", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】提供的攻击格挡率提高 %+(%d+)%%"]= function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BlockChance", "BASE", tonumber(num),{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【飞刃风暴】的每片刀刃 %+(%d+)%% 攻击和法术暴击伤害加成"] = function(num) return { mod("CritMultiplier", "BASE", tonumber(num), { type = "Multiplier", var = "BladeVortexBlade" }, { type = "SkillName", skillName = "飞刃风暴" }) } end,
	["提高 (%d+)%% 幻化武器时间"]= function(num) return {  mod("Duration", "INC", tonumber(num),{ type = "SkillName", skillName ="幻化武器" })  } end,
	["【([^\\x00-\\xff]*)】造成冰冻，感电，点燃的几率提高 %+(%d+)%%"]= function(_,skill_name,num) return {
	mod("EnemyFreezeChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  ,
	mod("EnemyShockChance", "BASE", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  ,
	mod("EnemyIgniteChance", "BASE", tonumber(num),{ type = "SkillName", skillName =skill_name })   } end,
	["【([^\\x00-\\xff]*)】额外连锁弹射 (%d+) 次"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", tonumber(num)) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】有额外 (%d+) 次连锁弹射"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", tonumber(num)) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】会额外连锁 (%d+) 次"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", tonumber(num)) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【灵魂奉献】给予等同 %+(%d+)%% 物理伤害的额外混沌伤害"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("PhysicalDamageGainAsChaos", "BASE", tonumber(num), { type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName = "灵魂奉献" }) } end,
	["闪电陷阱的伤害提高 (%d+)%%"]= function(num) return {  mod("Damage", "INC", tonumber(num),{ type = "SkillName", skillName ="闪电陷阱" })  } end,
	["【([^\\x00-\\xff]*)】有 (%d+)%% 几率对流血敌人造成双倍伤害"]= function(_,skill_name,num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "ActorCondition", actor = "enemy", var = "Bleeding" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】有 (%d+)%% 的几率对流血敌人造成双倍伤害"]= function(_,skill_name,num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "ActorCondition", actor = "enemy", var = "Bleeding" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["踩中【捕熊陷阱】的敌人受到陷阱或地雷的击中伤害提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("TrapMineDamageTaken", "INC", tonumber(num), { type = "GlobalEffect", effectType = "Debuff" }) }, { type = "SkillName", skillName = "捕熊陷阱" }) } end,
	["【([^\\x00-\\xff]*)】对燃烧中敌人的伤害提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("Damage", "INC", tonumber(num),{ type = "ActorCondition", actor = "enemy", var = "Burning" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】的投掷伤害提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("Damage", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name)})  } end,
	["【([^\\x00-\\xff]*)】的投掷物速度提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("ProjectileSpeed", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name)})  } end,
	["【([^\\x00-\\xff]*)】技能会使减益效果的持续时间延长 (%d+)%%"]= function(_,skill_name,num) return {  mod("SecondaryDuration", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name)})  } end,
	["【([^\\x00-\\xff]*)】提供的召唤生物攻击速度提高 (%d+)%%"]= function(_,skill_name,num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack,{ type = "GlobalEffect", effectType = "Buff" }) },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["先祖战士长图腾生效时，你的近战伤害提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "INC", tonumber(num),nil, ModFlag.Melee,{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName ="先祖战士长" } ) } end,
	["当先祖卫士图腾存在时，攻击速度提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil, ModFlag.Attack,{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName ="先祖卫士" } ) } end,
	["【灵体】的攻击和施法速度提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", tonumber(num)) },{ type = "SkillName", skillName ="召唤灵体" })  } end,
	["%+(%d+)%% 唤醒灵体的火焰、冰霜、闪电抗性"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤灵体" })  } end,
	["%+(%d+)%% 召唤灵体的元素抗性"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤灵体" })  } end,
	["%+(%d+)%% 唤醒灵体的元素抗性"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num)) },{ type = "SkillName", skillName ="召唤灵体" })  } end,
	["召唤愤怒狂灵的持续时间延长 (%d+)%%"]= function(num) return {  mod("Duration", "INC", tonumber(num),{ type = "SkillName", skillName ="召唤愤怒狂灵" })  } end,
	["你和友军受你的光环技能影响时，获得 %+([%d%.]+)%% 火焰、冰霜、闪电抗性"]= function(num) return {  mod("AffectedByAuraMod", "LIST", { mod =  mod("ElementalResist", "BASE", num) }) } end,
	["你和友军受你的光环技能影响时，伤害提高 ([%d%.]+)%%"]= function(num) return {  mod("AffectedByAuraMod", "LIST", { mod =  mod("Damage", "INC", num) }) } end,
	["你和友军受你的光环影响时，元素抗性 %+([%d%.]+)%%"]= function(num) return {  mod("AffectedByAuraMod", "LIST", { mod =  mod("ElementalResist", "BASE", num) }) } end,
	["你和友军受你的光环影响时，伤害提高 ([%d%.]+)%%"]= function(num) return {  mod("AffectedByAuraMod", "LIST", { mod =  mod("Damage", "INC", num) }) } end,
	["你技能的光环可使你和周围友军的攻击和施法速度提高 ([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("Speed", "INC", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你技能的光环可使你和周围友方的物理伤害减免提高 %+([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("PhysicalDamageReduction", "BASE", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你技能的光环给你和周围友军每秒回复 ([%d%.]+)%% 生命"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("LifeRegenPercent", "BASE", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你和周围友军的元素抗性 %+([%d%.]+)%%"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("ElementalResist", "BASE", num) }) } end,
	["你和周围友军的魔力再生率提高 ([%d%.]+)%%"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("ManaRegen", "INC", num) }) } end,
	["【召唤愤怒狂灵】的生命提高 (%d+)%%"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("Life", "INC", num) }, { type = "SkillName", skillName = "召唤愤怒狂灵" })  } end,
	["愤怒狂灵的最大生命提高 (%d+)%%"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("Life", "INC", num) }, { type = "SkillName", skillName = "召唤愤怒狂灵" })  } end,
	["召唤愤怒狂灵的伤害提高 (%d+)%%"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "SkillName", skillName = "召唤愤怒狂灵" })  } end,
	["劈砍攻击速度提高 (%d+)%%"]= function(num) return {  mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack,{ type = "SkillName", skillName ="劈砍" })  } end,
	["每个狂怒球可使【([^\\x00-\\xff]*)】的伤害提高 (%d+)%%"]= function(_,skill_name,num) return {  mod("Damage", "INC", tonumber(num),{ type = "Multiplier", var = "FrenzyCharge" },{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【([^\\x00-\\xff]*)】可使移动速度额外提高 (%d+)%%"]= function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("MovementSpeed", "INC", tonumber(num),{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】可使移动速度总增 (%d+)%%"]= function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("MovementSpeed", "INC", tonumber(num),{ type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["【([^\\x00-\\xff]*)】的施放速度提高 (%d+)%%"]= function(_,skill_name,num)  return {  mod("Speed", "INC", tonumber(num),nil,ModFlag.Cast,{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["诱饵图腾的生命提高 (%d+)%%"]= function(num) return {  mod("TotemLife", "INC", tonumber(num),{ type = "SkillName", skillName ="诱饵图腾" })  } end,
	["【([^\\x00-\\xff]*)】造成的燃烧地面持续时间延长 (%d+)%%"]= function(_,skill_name,num)  return {  mod("Duration", "INC", tonumber(num),{ type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) })  } end,
	["【灼热连接】放置速度提高 (%d+)%%"]= function(num)  return {  mod("TotemPlacementSpeed", "INC", tonumber(num),{ type = "SkillName", skillName ="灼热连接" })  } end,
	["【冰矛】第二阶段的暴击率提高 (%d+)%%"]= function(num)  return {  mod("CritChance", "INC", tonumber(num),{ type = "SkillName", skillName ="冰矛" },{ type = "SkillPart", skillPart = 2 })  } end,
	["受到【雷霆之捷】影响时，伤害穿透 (%d+)%% 闪电抗性"]= function(num) return {  mod("LightningPenetration", "BASE", num,{ type = "Condition", var = "AffectedBy闪电之捷" })  } end,
	["拥有【猫之隐匿】时获得【迷踪】状态"] = { flag("Condition:Phasing", { type = "Condition", var = "AffectedBy猫之隐匿" }) }, --备注：you have phasing while you have cat's stealth
	["拥有【猫之隐匿】时，你的攻击必定造成流血"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Attack, { type = "Condition", var = "AffectedBy猫之隐匿" }) }, --备注：attacks always inflict bleeding while you have cat's stealth
	["受到【脆弱】诅咒时，非满血时被视作低血状态"] = { flag("Condition:LowLife", { type = "Condition", var = "AffectedBy脆弱" }) }, --备注：you count as on low life while you are cursed with vulnerability
	["拥有【猫之隐匿】时获得【玫红之舞】"] = { mod("Keystone", "LIST", "玫红之舞", { type = "Condition", var = "AffectedBy猫之隐匿" }) }, --备注：you have crimson dance while you have cat's stealth
	["近期内你若打出过暴击，则获得【玫红之舞】"] = { mod("Keystone", "LIST", "玫红之舞", { type = "Condition", var = "CritRecently" }) }, --备注：you have crimson dance if
	["近期内你若打出过暴击，则获得【瓦尔冥约】"] = { mod("Keystone", "LIST", "瓦尔冥约", { type = "Condition", var = "CritRecently" }) }, --备注：you have vaal pact if you've dealt a critical strike recently
	["近期内你若没有被击中，则获得【狂热誓言】"] = { mod("Keystone", "LIST", "狂热誓言", { type = "Condition", var = "BeenHitRecently", neg = true }) }, --备注：you have zealot's oath if you haven't been hit recently
	["近期内你若打出过暴击，则获得【完美苦痛】"] = { mod("Keystone", "LIST", "完美苦痛", { type = "Condition", var = "CritRecently" }) },
	["魔像总伤害额外降低 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像总生命额外降低 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像的总伤害额外降低 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像的总生命额外降低 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像的伤害总降 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["魔像的生命总降 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "MORE", -num) },{ type = "SkillType", skillType = SkillType.Golem })  } end,
	["([%+%-]?%d+) 魔像数量上限"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end,
	["最多可同时召唤额外 ([%+%-]?%d+) 个魔像"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end,
	["召唤魔像的数量上限 ([%+%-]?%d+)"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end,
	["魔像上限 ([%+%-]?%d+)"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end,
	["最多可同时召唤额外 (%d) 个魔像"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end,
	["你和周围友军的伤害提高 (%d+)%%"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("Damage", "INC", num) }) } end,
	["你和周围友军移动速度提高 (%d+)%%"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("MovementSpeed", "INC", num) }) } end,
	["你和周围友军的移动速度提高 (%d+)%%"]= function(num) return {  mod("ExtraAura", "LIST", { mod =  mod("MovementSpeed", "INC", num) }) } end,
	["近期内你若没被击中后受到伤害，则获得 ([%d%.]+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "BeenHitRecently", neg = true })  } end,
	["近期内你若被击中伤害，则有 ([%d%.]+)%% 几率格挡法术"]= function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently"})  } end,
	["受到【纪律】影响时，每击中一个敌人便会获得 %+(%d+) 能量护盾"]= function(num) return {  mod("EnergyShieldOnHit", "BASE", num,{ type = "Condition", var = "AffectedBy纪律" })  } end,
	["受到【活力】影响时，每击中一个敌人便会获得 %+(%d+) 生命"]= function(num) return {  mod("LifeOnHit", "BASE", num,{ type = "Condition", var = "AffectedBy活力" })  } end,
	["使用尊严时有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用尊严时，攻击击中时有 (%d+)%% 几率穿刺敌人"]= function(num) return { mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用尊严时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用尊严时，攻击击中时有 (%d+)%% 的几率穿刺敌人"]= function(num) return { mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用尊严时，你造成的穿刺效果会额外持续 (%d+) 次击中"]= function(num) return { mod("ImpaleStacksMax", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用【尊严】时有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用【尊严】时，攻击击中有 (%d+)%% 几率穿刺敌人"]= function(num) return { mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用【尊严】时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用【尊严】时，攻击击中有 (%d+)%% 的几率穿刺敌人"]= function(num) return { mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["使用【尊严】时，你造成的穿刺效果会造成 (%d+) 次额外击中"]= function(num) return { mod("ImpaleStacksMax", "BASE", num,{ type = "Condition", var = "UsedBy尊严" }) } end,
	["法术有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num, nil, ModFlag.Spell) } end,
	["法术有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num, nil, ModFlag.Spell) } end,
	["技能效果持续时间延长 ([%+%-]?%d+)%%"]= function(num) return {  mod("Duration", "INC", num)  } end,
	["技能效果持续时间缩短 ([%+%-]?%d+)%%"]= function(num) return {  mod("Duration", "INC", -num)  } end,
	["对燃烧的敌人附加 (%d+) %- (%d+) 火焰伤害"]= function(_,num1,num2) return {
	mod("FireMin", "BASE", tonumber(num1),nil, ModFlag.Hit, { type = "ActorCondition", actor = "enemy", var = "Burning" }),
	mod("FireMax", "BASE", tonumber(num2), nil, ModFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Burning" })
	}end,
	["每个红色插槽会使你和周围友军附加 (%d+) %- (%d+) 基础火焰伤害"]= function(_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("FireMin", "BASE", tonumber(num1))},{ type = "Multiplier", var = "RedSocketIn{SlotName}" } ),
	mod("ExtraAura", "LIST",
	{ mod = mod("FireMax", "BASE", tonumber(num2)) },{ type = "Multiplier", var = "RedSocketIn{SlotName}" }),
	}end,
	["每个绿色插槽会使你和周围友军附加 (%d+) %- (%d+) 基础冰霜伤害"]= function(_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("ColdMin", "BASE", tonumber(num1))},{ type = "Multiplier", var = "GreenSocketIn{SlotName}" } ),
	mod("ExtraAura", "LIST",
	{ mod = mod("ColdMax", "BASE", tonumber(num2))},{ type = "Multiplier", var = "GreenSocketIn{SlotName}" } ),
	}end,
	["每个蓝色插槽会使你和周围友军附加 (%d+) %- (%d+) 基础闪电伤害"]= function(_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("LightningMin", "BASE", tonumber(num1))},{ type = "Multiplier", var = "BlueSocketIn{SlotName}" } ),
	mod("ExtraAura", "LIST",
	{ mod = mod("LightningMax", "BASE", tonumber(num2))},{ type = "Multiplier", var = "BlueSocketIn{SlotName}" } ),
	}end,
	["每个白色插槽会使你和周围友军附加 (%d+) %- (%d+) 基础混沌伤害"]= function(_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("ChaosMin", "BASE", tonumber(num1))},{ type = "Multiplier", var = "WhiteSocketIn{SlotName}" } ),
	mod("ExtraAura", "LIST",
	{ mod = mod("ChaosMax", "BASE", tonumber(num2))},{ type = "Multiplier", var = "WhiteSocketIn{SlotName}" } ),
	}end,
	["获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num) return {  mod("NonChaosDamageGainAsChaos", "BASE", num)  } end,
	["受到【雷霆】影响时，闪电伤害提高 (%d+)%%"]= function(num) return {  mod("LightningDamage", "INC", num,{ type = "Condition", var = "AffectedBy雷霆" })  } end,
	-- 国服目前 ManaRecoveryRate和ManaRegen 2个词缀共用“魔力回复速度”
	["任何魔力药剂作用时间内，魔力回复速度提高 (%d+)%%"]= function(num) return {  mod("ManaRecoveryRate", "INC", num,{ type = "Condition", var = "UsingManaFlask" } )  } end,
	["受到【清晰】影响时，魔力回复速度提高 (%d+)%%"]= function(num) return {  mod("ManaRecoveryRate", "INC", num,{ type = "Condition", var = "AffectedBy清晰" })  } end,
	["受到【纪律】影响时，能量护盾回复速度提高 (%d+)%%"]= function(num) return {  mod("EnergyShieldRecoveryRate", "INC", num,{ type = "Condition", var = "AffectedBy纪律" })  } end,
	["受到【活力】影响时，药剂的生命回复提高 (%d+)%%"]= function(num) return {  mod("FlaskLifeRecovery", "INC", num,{ type = "Condition", var = "AffectedBy活力" })  } end,
	["受到【元素净化】影响时，%+(%d+)%% 混沌抗性"]= function(num) return {  mod("ChaosResist", "BASE", num,{ type = "Condition", var = "AffectedBy元素净化" })  } end,
	["受到【迅捷】影响时，移动技能的冷却速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", num,nil, 0, KeywordFlag.Movement,{ type = "Condition", var = "AffectedBy迅捷" } )  } end,
	["魔卫的物理总伤害额外提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamage", "MORE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["魔卫复苏物理伤害总增 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamage", "MORE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["魔卫复苏物理总伤害额外提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamage", "MORE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["复苏的魔卫物理总伤害额外提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamage", "MORE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["【复苏的魔卫】的重击攻击效果范围扩大 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num,{ type = "SkillId", skillId = "ZombieSlam" })})  } end,
	["药剂效果套用于你的魔卫和灵体身上"] = { flag("FlasksApplyToMinion", { type = "SkillName", skillNameList = { "魔卫复苏", "召唤灵体" } }) }, --备注：flasks apply to your zombies and spectres
	["药剂效果套用于魔卫复苏和灵体"] = { flag("FlasksApplyToMinion", { type = "SkillName", skillNameList = { "魔卫复苏", "召唤灵体" } }) },
	["【魔卫】攻击速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["魔卫复苏攻击速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["魔卫抗性提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["%+(%d+)%% 魔卫的火焰、冰霜、闪电抗性"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["%+(%d+)%% 魔卫的元素抗性"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ElementalResist", "BASE", tonumber(num))},{ type = "SkillName", skillName = "魔卫复苏" } )  } end,
	["【魔卫造成】的伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", tonumber(num),nil,ModFlag.Attack )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["魔卫复苏伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", tonumber(num),nil,ModFlag.Attack )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["复苏的魔卫最大生命提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "INC", tonumber(num) )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["魔卫的最大生命提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "INC", tonumber(num) )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["魔卫复苏最大生命提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "INC", tonumber(num) )},{ type = "SkillName", skillName = "魔卫复苏" })  } end,
	["药剂持续期间，(%d+)%% 承受的击中物理伤害转化为冰霜伤害"] = function(num) return {  mod("PhysicalDamageTakenAsCold", "BASE", num,{ type = "Condition", var = "UsingFlask" })  } end,
	["([%+%-]?%d+)%% 闪避几率"]= function(num) return {  mod("EvadeChance", "BASE", num)  } end,
	["对投射物攻击的总闪避率额外提高 (%d+)%% "]= function(num) return {  mod("ProjectileEvadeChance", "MORE", num)  } end,
	["对近战攻击的总闪避率额外降低 (%d+)%% "]= function(num) return {  mod("MeleeEvadeChance", "MORE", -num)  } end,
	["30%% 的几率躲避攻击击中、总护甲降低 50%%、总能量护盾降低 30%%、攻击与法术伤害总格挡几率降低 30%%"] = {
	mod("AttackDodgeChance", "BASE", 30),
	mod("Armour", "MORE", -50),
	mod("EnergyShield", "MORE", -30),
	mod("BlockChance", "MORE", -30),
	mod("SpellBlockChance", "MORE", -30)
	},
	-- 3.4
	["你技能的光环可使你和周围友方的伤害提高 ([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("Damage", "INC", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你技能的光环可使你和周围友军的伤害提高 ([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("Damage", "INC", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你技能的光环可使你和周围友方的攻击和施法速度提高 ([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("Speed", "INC", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["你技能的光环可使你和周围友军的物理伤害减免提高 %+([%d%.]+)%%"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("PhysicalDamageReduction", "BASE", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["受到你嘲讽的敌人所承受的伤害提高 (%d+)%% "] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num, { type = "Condition", var = "Taunted" }) }) } end,
	["攻击技能可使混沌总伤害额外提高 (%d+)%%"] = function(num) return {  mod("ChaosDamage", "MORE", num, { type = "SkillType", skillType = SkillType.Attack }) } end,
	["你技能的光环每秒回复你和周围友军 ([%d%.]+)%% 最大生命"]= function(num) return {  mod("ExtraAuraEffect", "LIST", { mod =  mod("LifeRegenPercent", "BASE", num,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }) }) } end,
	["周围至少有 1 个友军时，攻击总伤害额外提高 ([%d%.]+)%%"] = function(num) return {  mod("Damage", "MORE", num,{ type = "MultiplierThreshold", var = "NearbyAlly", threshold = 1 } ) } end,
	["周围至少有 1 个友军时，总伤害额外提高 ([%d%.]+)%%"] = function(num) return {  mod("Damage", "MORE", num,{ type = "MultiplierThreshold", var = "NearbyAlly", threshold = 1 } ) } end,
	["当周围有至少 1 个友军，你与周围友军的伤害总增 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "MultiplierThreshold", var = "NearbyAlly", threshold = 1 }) } end,
	["当周围有至少 5 个友军，你和周围的友军获得【猛攻】状态"] = { mod("ExtraAura", "LIST", { mod = flag("Onslaught") }, { type = "MultiplierThreshold", var = "NearbyAlly", threshold = 5 }) },
	["周围友军的攻击，施法，移动速度提高 (%d+)%%"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("Speed", "INC", num ) }),
	mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("MovementSpeed", "INC", num ) })
	} end,
	["每 %d 秒攻击伤害格挡几率 %+(%d+)%%，持续 %d 秒"] = function(_,num,_2) return { mod("BlockChance", "BASE", num, { type = "Condition", var = "BastionOfHopeActive" }) } end,
	["近期内你的技能若打出过暴击，则每有 1 个暴击球，就会每秒受到 (%d+) 闪电伤害"]= function(num) return {  mod("LightningDegen", "BASE", num,{ type = "Multiplier", var = "PowerCharge" },{ type = "Condition", var = "CritRecently" }) } end,
	["低血时，法术伤害格挡几率额外 %+(%d+)%%"]= function(num) return {  mod("SpellBlockChance", "BASE", num, { type = "Condition", var = "LowLife" }   ) } end,
	["法术伤害格挡几率额外 %+(%d+)%%"]= function(num) return {  mod("SpellBlockChance", "BASE", num  ) } end,
	["攻击伤害格挡几率额外 %+(%d+)%%"]= function(num) return {  mod("BlockChance", "BASE", num  ) } end,
	["【冰川之刺】的 (%d+)%% 物理伤害转换为冰霜伤害"]= function(num)  return {  mod("PhysicalDamageConvertToCold", "BASE", tonumber(num),{ type = "SkillName", skillName ="冰川之刺" })  } end,
	["获得 (%d+) 级的主动技能【(.+)】"] = function(num, _, skill) return grantedExtraSkill(skill, num) end,
	["【(.+)】不保留魔力"] = function( _,skill) return { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillName", skillName = skill }) } end,
	["获得 (%d+) 级的的主动技能【(.+)】"] = function(num, _, skill) return grantedExtraSkill(skill, num) end,
	["【(.+)】不保留魔力"] = function( _,skill) return { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillName", skillName = skill }) } end,
	["装备的护盾格挡几率若不低于 (%d+)%%，则法术伤害的 ([%d%.]+)%% 转化为生命偷取"] = function(num, _,num2) return {  mod("DamageLifeLeech", "BASE", tonumber(num2),nil, ModFlag.Spell,{ type = "StatThreshold", stat = "ShieldBlockChance", threshold = tonumber(num) }) } end,
	["插入苍白之凝珠宝时，召唤生物的命中值 %+(%d+)"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Accuracy", "BASE", num) }, { type = "Condition", var = "Have苍白之凝珠宝In{SlotName}" }) } end,
	["总命中值额外提高 (%d+)%%"] = function(num) return {  mod("Accuracy", "MORE", num ) } end,
	["全局命中值额外提高 (%d+)%%"] = function(num) return {  mod("Accuracy", "MORE", num ) } end,
	["周围敌人的火焰和冰霜抗性提高 (%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("FireResist", "INC", num) }),
	mod("EnemyModifier", "LIST", { mod = mod("ColdResist", "INC", num) })
	} end,
	["周围敌人的所有抗性提高 (%-%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num) }),
	mod("EnemyModifier", "LIST", { mod = mod("ElementalResist", "BASE", num) }),
	} end,
	["每个红色插槽可为你和周围友军附加 (%d+) %- (%d+) 基础火焰伤害"] = function(_,num1,num2) return { mod("ExtraAura", "LIST", { mod = mod("FireMin", "BASE", tonumber(num1) )},{ type = "Multiplier", var = "RedSocketIn{SlotName}" }),
	mod("ExtraAura", "LIST", { mod = mod("FireMax", "BASE", tonumber(num2)) },{ type = "Multiplier", var = "RedSocketIn{SlotName}" })
	} end,
	["每个绿色插槽可为你和周围友军附加 (%d+) %- (%d+) 基础冰霜伤害"]= function(_,num1,num2) return { mod("ExtraAura", "LIST", { mod = mod("ColdMin", "BASE", tonumber(num1) )},{ type = "Multiplier", var = "GreenSocketIn{SlotName}" }),
	mod("ExtraAura", "LIST", { mod = mod("ColdMax", "BASE", tonumber(num2)) },{ type = "Multiplier", var = "GreenSocketIn{SlotName}" })
	} end,
	["每个蓝色插槽可为你和周围友军附加 (%d+) %- (%d+) 基础闪电伤害"]= function(_,num1,num2) return { mod("ExtraAura", "LIST", { mod = mod("LightningMin", "BASE", tonumber(num1) )},{ type = "Multiplier", var = "BlueSocketIn{SlotName}" }),
	mod("ExtraAura", "LIST", { mod = mod("LightningMax", "BASE", tonumber(num2)) },{ type = "Multiplier", var = "BlueSocketIn{SlotName}" })
	} end,
	["每个白色插槽可为你和周围友军附加 (%d+) %- (%d+) 基础混沌伤害"]= function(_,num1,num2) return { mod("ExtraAura", "LIST", { mod = mod("ChaosMin", "BASE", tonumber(num1) )},{ type = "Multiplier", var = "WhiteSocketIn{SlotName}" }),
	mod("ExtraAura", "LIST", { mod = mod("ChaosMax", "BASE", tonumber(num2)) },{ type = "Multiplier", var = "WhiteSocketIn{SlotName}" })
	} end,
	["每有一个耐力球，攻击伤害格挡几率额外 ([%+%-]?%d+)%%"] = function(num) return {  mod("BlockChance", "BASE", num , { type = "Multiplier", var = "EnduranceCharge" }) } end,
	["每有一个狂怒球，攻击伤害格挡几率额外 ([%+%-]?%d+)%%"]= function(num) return {  mod("BlockChance", "BASE", num , { type = "Multiplier", var = "FrenzyCharge" }) } end,
	["每有一个暴击球，攻击伤害格挡几率额外 ([%+%-]?%d+)%%"]= function(num) return {  mod("BlockChance", "BASE", num, { type = "Multiplier", var = "PowerCharge" } ) } end,
	["当暴击球达到上限时，你可以对敌人额外施加 1 个诅咒"]= function(num) return {mod("EnemyCurseLimit", "BASE", 1,{ type = "StatThreshold", stat = "PowerCharges", thresholdStat = "PowerChargesMax" }) } end,
	["耐力球达到上限时你无法被晕眩"]= function() return {mod("AvoidStun", "BASE", 100,{ type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" }) } end,
	["每有一个狂怒球则获得额外混沌伤害， 其数值等同于冰霜伤害的 (%d+)%%"]= function(num) return {  mod("ColdDamageGainAsChaos", "BASE", num, { type = "Multiplier", var = "FrenzyCharge" }) } end,
	["每有一个耐力球则获得额外混沌伤害， 其数值等同于火焰伤害的 (%d+)%%"]= function(num) return {  mod("FireDamageGainAsChaos", "BASE", num, { type = "Multiplier", var = "EnduranceCharge" }) } end,
	["每有一个暴击球则获得额外混沌伤害， 其数值等同于闪电伤害的 (%d+)%%"]= function(num) return {  mod("LightningDamageGainAsChaos", "BASE", num, { type = "Multiplier", var = "PowerCharge" }) } end,
	["每个暴击球可使每秒生命回复提高 ([%d%.]+)%%"]= function(num) return {  mod("LifeRegen", "BASE", num, { type = "Multiplier", var = "PowerCharge" }) } end,
	["你在拥有最大数量的狂怒球时，得到【霸体】状态"] = { mod("Keystone", "LIST", "霸体", nil,{ type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) },
	["你在拥有最大数量的暴击能量球时，得到【心胜于物】状态"] = { mod("Keystone", "LIST", "心灵升华", nil,{ type = "StatThreshold", stat = "PowerCharges", thresholdStat = "PowerChargesMax" }) },
	["你在拥有最大数量的耐力球时，获得【瓦尔冥约】状态"] = { mod("Keystone", "LIST", "瓦尔冥约", nil,{ type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" }) },
	["每有一个暴击球，可使你获得额外 (%d+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num, { type = "Multiplier", var = "PowerCharge" }) } end,
	["每有一个狂怒球，可使你获得额外 (%d+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num, { type = "Multiplier", var = "FrenzyCharge" }) } end,
	["每 (%d+) 点敏捷提高 (%d+)%% 召唤生物造成的伤害"] = function(_,num1,num2) return {  mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", tonumber(num2)) },{ type = "PerStat", stat = "Dex", div = tonumber(num1) })   } end,
	["近期你每消耗 (%d+) 魔力，法术伤害便提高 (%d+)%%"] = function(_,num1,num2)return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "Multiplier", var = "ManaSpentRecently", div = tonumber(num1) }) } end,
	["近期你每消耗 (%d+) 魔力，法术伤害便提高 (%d+)%%,最多可提高 (%d+)%%"] = function(_,num1,num2,num3)return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "Multiplier", var = "ManaSpentRecently", div = tonumber(num1) , limit = tonumber(num3), limitTotal = true}) } end,
	["近期你每消耗 (%d+) 魔力，法术伤害便提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2,num3)return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "Multiplier", var = "ManaSpentRecently", div = tonumber(num1) , limit = tonumber(num3), limitTotal = true}) } end,
	["若近期总计消耗魔力超过 (%d+) 点，则你所施放诅咒的效果提高 (%d+)%%"] = function(_,num1,num2)return {  mod("CurseEffect", "INC", tonumber(num2), { type = "StatThreshold", stat = "ManaSpentRecently", threshold = tonumber(num1) }) } end,
	["身体护甲提供的能量护盾提高 (%d+)%%"] =  function(num) return {  mod("EnergyShield", "INC", num, { type = "SlotName", slotName = "Body Armour" }) } end,
	["盾牌提供的能量护盾提高 (%d+)%%"] =  function(num) return {  mod("EnergyShield", "INC", num, { type = "SlotName", slotName = "Weapon 2" }) } end,
	["每 (%d+)%% 攻击伤害格挡几率都使攻击伤害提高 (%d+)%%"] =  function(_,num1,num2) return {  mod("Damage", "INC", tonumber(num2), nil, ModFlag.Attack, { type = "PerStat", stat = "BlockChance", div = tonumber(num1) }  ) } end,
	["每 (%d+)%% 的攻击伤害格挡几率会使法术伤害提高 (%d+)%%"] =  function(_,num1,num2) return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "PerStat", stat = "BlockChance", div = tonumber(num1) }  ) } end,
	["持盾时，有 (%d+)%% 的几率免疫元素异常状态"]= function(num) return {
		mod("AvoidShock", "BASE", num, { type = "Condition", var = "UsingShield" } ),
		mod("AvoidFrozen", "BASE", num, { type = "Condition", var = "UsingShield" } ),
		mod("AvoidChilled", "BASE", num, { type = "Condition", var = "UsingShield" } ),
		mod("AvoidIgnite", "BASE", num, { type = "Condition", var = "UsingShield" } ),
	} end,
	["持盾时，有 (%d+)%% 的几率免疫晕眩"]= function(num) return {
		mod("AvoidStun", "BASE", num, { type = "Condition", var = "UsingShield" } ),
	} end,
	["每 (%d+)%% 的法术伤害格挡几率会使魔力回复速度提高 (%d+)%%"] =  function(_,num1,num2) return {  mod("ManaRegen", "INC", tonumber(num2),{ type = "PerStat", stat = "SpellBlockChance", div = tonumber(num1) }  ) } end,
	["每有 (%d+)%% 的法术伤害格挡几率，则魔力回复速度提高 (%d+)%%"] =  function(_,num1,num2) return {  mod("ManaRegen", "INC", tonumber(num2),{ type = "PerStat", stat = "SpellBlockChance", div = tonumber(num1) }  ) } end,
	["魔力回复速度加快 (%d+)%%"] =  function(num) return {  mod("ManaRegen", "INC", tonumber(num) ) } end,
	["每 (%d+)%% 的攻击格挡率会使法术伤害提高 (%d+)%%"]=function(_,num1,num2) return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "PerStat", stat = "BlockChance", div = tonumber(num1) }  ) } end,
	["召唤生物在低血时会爆炸，对周围敌人造成自身生命 33%% 的火焰伤害"] = { mod("ExtraMinionSkill", "LIST", { skillId = "MinionInstability" }) },
	["召唤的哨兵会使用【圣战猛击】"] = { mod("ExtraMinionSkill", "LIST", { skillId = "SentinelHolySlam", minionList = { "AxisEliteSoldierHeraldOfLight", "AxisEliteSoldierDominatingBlow" } }) },
	["([%+%-]?%d+) 纯净哨兵数量上限"]= function(num) return {  mod("ActiveSentinelOfPurityLimit", "BASE", num)  } end,
	["【纯净哨兵】的伤害提高 (%d+)%%"] = function(num) return {  mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "SkillId", skillId = "HeraldOfPurity" })   } end,
	["召唤的纯净哨兵伤害提高 (%d+)%%"] = function(num) return {  mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "SkillId", skillId = "HeraldOfPurity" })   } end,
	["【召唤纯净哨兵】的范围效果扩大 (%d+)%%"] = function(num) return {  mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num) }, { type = "SkillId", skillId = "HeraldOfPurity" })   } end,
	["你的【复苏的魔卫】死亡时产生腐蚀地面，每秒造成等同它们 50%% 最大生命的混沌伤害"]= { mod("ExtraMinionSkill", "LIST", { skillId = "BeaconZombieCausticCloud", minionList = { "RaisedZombie" } }) },
	["当你吞噬灵柩时触发 (%d+) 级的【召唤幻灵】技能"] = function(num) return { mod("ExtraSkill", "LIST", { skillId = "TriggeredSummonGhostOnKill", level = num , triggered = true}) } end,
	["周围敌人获得 (%-%d+)%% 火焰抗性"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("FireResist", "BASE", num) }) } end,
	["周围敌人获得 (%-%d+)%% 冰霜抗性"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("ColdResist", "BASE", num) }) } end,
	["周围敌人获得 (%-%d+)%% 闪电抗性"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("LightningResist", "BASE", num) }) } end,
	["每一个周围的敌人 %+(%d+)%% 攻击暴击伤害加成，最大%+(%d+)%%"] = function(_,num1,num2) return {  mod("CritMultiplier", "BASE", tonumber(num1),{ type = "Multiplier", var = "NearbyEnemy", limit = tonumber(num2), limitTotal = true }) } end,
	["每装备 1 个未腐化的物品，每秒回复 (%d+) 生命"]= function(num) return {  mod("LifeRegen", "BASE", tonumber(num),{ type = "Multiplier", var = "NonCorruptedItem" })  } end,
	["每装备一个未腐化的物品，便每秒回复 (%d+) 生命"]= function(num) return {  mod("LifeRegen", "BASE", tonumber(num),{ type = "Multiplier", var = "NonCorruptedItem" })  } end,
	["每装备一个【被腐化的物品】，技能的总魔力消耗 %-(%d+)"]= function(num) return {  mod("ManaCost", "BASE", tonumber(num),{ type = "Multiplier", var = "CorruptedItem" })  } end,
	["该武器击中后造成的 (%d+)%% 物理伤害转换为一种随机元素伤害"]= function(num) return {
	mod("PhysicalDamageConvertToFire", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementFire" }),
	mod("PhysicalDamageConvertToCold", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementCold" }),
	mod("PhysicalDamageConvertToLightning", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementLightning" }),
	} end,
	["获得等同武器物理伤害 (%d+)%% 的随机一种额外火焰，冰霜，或者闪电伤害"]= function(num) return {
	mod("PhysicalDamageGainAsFire", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementFire" }),
	mod("PhysicalDamageGainAsCold", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementCold" }),
	mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementLightning" }),
	} end,
	["获得等同 (%d+)%% 物理伤害的 1 个随机火焰、冰霜、闪电伤害"]= function(num) return {
	mod("PhysicalDamageGainAsFire", "BASE", tonumber(num), { type = "Condition", var = "PhysicsRandomElementFire" }),
	mod("PhysicalDamageGainAsCold", "BASE", tonumber(num),{ type = "Condition", var = "PhysicsRandomElementCold" }),
	mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num),{ type = "Condition", var = "PhysicsRandomElementLightning" }),
	} end,
	["获得等同 (%d+)%% 物理伤害的 1 个随机元素伤害"]= function(num) return {
	mod("PhysicalDamageGainAsFire", "BASE", tonumber(num), { type = "Condition", var = "PhysicsRandomElementFire" }),
	mod("PhysicalDamageGainAsCold", "BASE", tonumber(num), { type = "Condition", var = "PhysicsRandomElementCold" }),
	mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num), { type = "Condition", var = "PhysicsRandomElementLightning" }),
	} end,
	["药剂持续期间，被点燃的敌人承受的火焰伤害提高 (%d+)%%"]=   function(num) return { mod("EnemyModifier", "LIST", { mod = mod("FireDamageTaken", "INC", num) },{ type = "ActorCondition", actor = "enemy", var = "Ignited" },{ type = "Condition", var = "UsingFlask" }) } end,
	["药剂持续期间，被你点燃的敌人受到的伤害提高 (%d+)%%"]=   function(num) return { mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) },{ type = "ActorCondition", actor = "enemy", var = "Ignited" },{ type = "Condition", var = "UsingFlask" }) } end,
	["被你点燃的敌人火焰抗性 ([%+%-]?%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("FireResist", "BASE", num) },{ type = "ActorCondition", actor = "enemy", var = "Ignited" }) } end,
	["此武器的攻击对敌人造成双倍伤害"] = { mod("DoubleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "{Hand}Attack" }) },
	["此武器的攻击造成双倍伤害"] = { mod("DoubleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "{Hand}Attack" }) },
	["你若过去 8 秒内使用过战吼，则有 (%d+)%% 几率造成双倍伤害"]= function(num) return { mod("DoubleDamageChance", "BASE", num, { type = "Condition", var = "UsedWarcryInPast8Seconds" } ) } end,
	["你若过去 8 秒内使用过战吼，则有 (%d+)%% 的几率造成双倍伤害"]= function(num) return { mod("DoubleDamageChance", "BASE", num, { type = "Condition", var = "UsedWarcryInPast8Seconds" } ) } end,
	["投射物的伤害随着飞行距离提升，击中目标时最多提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile), { type = "DistanceRamp", ramp = {{35,0},{70,1}} }) } end,
	["当你没有获得【霸体】时，获得【远射】"] = { flag("FarShot", { type = "Condition", var = "Have霸体Keystone" ,neg = true}) },
	["当你获得【霸体】时，近距离用弓击中后的总伤害额外提高 (%d+)%%"] = function(num) return {
	mod("Damage", "MORE", num,nil,ModFlag.Hit, { type = "Condition", var = "AtCloseRange" }, { type = "Condition", var = "Have霸体Keystone"})
	} end,
	["在【猛攻】状态期间，得到【迷踪】状态"] = { flag("Condition:Phasing", { type = "Condition", var = "Onslaught" }) },
	["获得【远射】"] = { flag("FarShot") },
	["远射"] = { flag("FarShot") },
	["狙击"] = { flag("FarShot") },
	["%-(%d+) 最大图腾数量"] = function(num) return { mod("ActiveTotemLimit", "BASE", -num) } end,
	["([%+%-]?%d+) 召唤图腾数量上限"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end,
	["召唤图腾数量上限([%+%-]?%d+)"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end,
	["召唤图腾数量上限 ([%+%-]?%d+)"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end,
	["召唤图腾的上限 ([%+%-]?%d+)"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end,
	["召唤图腾的上限 ([%+%-]?%d+)。"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end,
	["攻击的技能 ([%+%-]?%d+) 召唤图腾数量上限"] = function(num) return { mod("ActiveTotemLimit", "BASE", num, nil, 0, KeywordFlag.Attack) } end,
	["每个图腾额外提高 (%d+)%% 总伤害"] = function(num) return { mod("Damage", "MORE", num, { type = "PerStat", stat = "ActiveTotemLimit" }) } end,
	["每存在 1 个图腾，总伤害额外提高 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, { type = "PerStat", stat = "ActiveTotemLimit" }) } end,
	["([%+%-]?%d+)%% 额外总冰霜持续伤害效果"] = function(num) return { mod("ColdDotMultiplier", "BASE", num) } end,
	["寒冬宝珠每阶可使范围效果扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "SkillName", skillName = "寒冬宝珠"}, { type = "Multiplier", var = "WinterOrbStage" }) } end,
	["寒冬宝珠每阶可使效果区域扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "SkillName", skillName = "寒冬宝珠"}, { type = "Multiplier", var = "WinterOrbStage" }) } end,
	["【寒冬宝珠】每一阶范围效果扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "SkillName", skillName = "寒冬宝珠"}, { type = "Multiplier", var = "WinterOrbStage" }) } end,
	["【旗帜技能】不保留魔力"] = { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillName", skillNameList = { "恐怖之旗", "战旗" } }) },
	["【(.+)】会发射 (%d+) 个额外投射物"]=  function(_,skill_name,num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", tonumber(num)) }, { type = "SkillName", skillName =FuckSkillActivityCnName(skill_name) } ) } end,
	["被击中时，受到的闪电总伤害额外降低 (%d+)%%"] = function(num) return { mod("LightningDamageTaken", "MORE", -num) } end,
	["被击中时，受到的冰霜总伤害额外降低 (%d+)%%"] = function(num) return { mod("ColdDamageTaken", "MORE", -num) } end,
	["被击中时，受到的火焰总伤害额外降低 (%d+)%%"] = function(num) return { mod("FireDamageTaken", "MORE", -num) } end,
	["静止时受到的元素伤害降低 (%d+)%%"] = function(num) return { mod("ElementalDamageTaken", "INC", -num, { type = "Condition", var = "Stationary" }) } end,
	["静止时，每秒回复 ([%d%.]+)%% 能量护盾"] = function(num) return { mod("EnergyShieldRegenPercent", "BASE", num, { type = "Condition", var = "Stationary" }) } end,
	["左戒指栏位：法术的投射物无法弹射"] = { flag("CannotChain", nil, bor(ModFlag.Spell, ModFlag.Projectile), { type = "SlotNumber", num = 1 }) },
	["右戒指栏位：法术的投射物会额外弹射 1 次"] = { mod("ChainCountMax", "BASE", 1, nil, bor(ModFlag.Spell, ModFlag.Projectile), { type = "SlotNumber", num = 2 }) },
	["法术的投射物无法穿透"] = { flag("CannotPierce", nil, ModFlag.Spell) },
	["法术的投射物无法穿刺"] = { flag("CannotPierce", nil, ModFlag.Spell) },
	["击败敌人时触发 1 级的【召唤毒蛛】"]= function() return {  mod("ExtraSkill", "LIST", { skillId ="TriggeredSummonSpider", level = 1, triggered = true})   } end,
	["击败敌人时有 (%d+)%% 几率触发 1 级的【召唤毒蛛】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="TriggeredSummonSpider", level = 1, triggered = true})   } end,
	["击败敌人时有 (%d+)%% 的几率触发 1 级的【召唤毒蛛】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="TriggeredSummonSpider", level = 1, triggered = true})   } end,
	["专注时，你的暴击率会特别幸运"] ={ flag("CritChanceLucky",  { type = "Condition", var = "Focused" }) },
	["专注时获得额外 (%d+)%% 物理伤害减免"] = function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "Focused" } )  } end,
	["你在专注时获得【瓦尔冥约】状态"] = { mod("Keystone", "LIST", "瓦尔冥约", { type = "Condition", var = "Focused" }) },
	["专注时，伤害的 (%d+)%% 转化为生命偷取"] = function(num) return {  mod("DamageLifeLeech", "BASE", num,{ type = "Condition", var = "Focused" })  } end,
	["装备时可以施放 (%d+) 级的【幽鬼之灵】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonEssenceSpirits", level = num})   } end,
	["插槽内的技能造成的法术总伤害额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", tonumber(num),nil, ModFlag.Spell) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内的技能造成的攻击总伤害额外提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", tonumber(num),nil, ModFlag.Attack) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内的技能造成的法术伤害总增 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", tonumber(num),nil, ModFlag.Spell) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内的技能造成的攻击伤害总增 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", tonumber(num),nil, ModFlag.Attack) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内的技能施法速度提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil, ModFlag.Cast) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插槽内的技能攻击速度提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Speed", "INC", tonumber(num),nil, ModFlag.Attack) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["【风暴烙印】的伤害会穿透带有烙印敌人闪电抗性的 (%d+)%%"]= function(num) return {  mod("LightningPenetration", "BASE", num,{ type = "Condition", var = "BrandAttachedToEnemy" },{ type = "SkillName", skillName = "风暴烙印" })  } end,
	["此物品上的技能石获得 ([%d%.]+)%% 物理伤害，并转化为额外闪电伤害"]= function(num) return{ mod("ExtraSkillMod", "LIST", { mod = mod("PhysicalDamageGainAsLightning", "BASE", num) },{ type = "SocketedIn", slotName = "{SlotName}" })}end,
	["有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num) } end,
	["有 (%d+)%% 几率造成三倍伤害"] = function(num) return { mod("TripleDamageChance", "BASE", num) } end,
	["有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num) } end,
	["有 (%d+)%% 的几率造成三倍伤害"] = function(num) return { mod("TripleDamageChance", "BASE", num) } end,
	["专注时有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "Focused" }) } end,
	["专注时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "Focused" }) } end,
	["若周围有稀有或传奇敌人，则 %+(%d+)%% 基础暴击伤害加成"] = function(num) return { mod("CritMultiplier", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["对传奇的敌人的击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["对被诅咒的敌人的击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "Cursed" }) } end,
	["攻击技能的异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,ModFlag.Ailment,  { type = "SkillType", skillType = SkillType.Attack }) } end,
	["对传奇的敌人的总伤害额外提高 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["对传奇敌人时，总伤害额外提高 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["周围有稀有或传奇敌人时，攻击速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", tonumber(num),nil,ModFlag.Attack,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["周围有稀有或传奇敌人时，每秒回复 (%d+) 能量护盾"] = function(num) return { mod("EnergyShieldRegen", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["每装备一个【塑界者物品】，获得额外混沌伤害，等同于元素伤害的 (%d+)%%"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Multiplier", varList = { "ShaperItem" } } )  } end,
	["每装备一个塑界者物品，获得额外混沌伤害，其数值等同于元素伤害的 (%d+)%%"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Multiplier", varList = { "ShaperItem" } } )  } end,
	["每装备 1 个【塑界之器】，便获得额外混沌伤害，其数值等同于火焰、冰霜、闪电伤害的 (%d+)%%"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Multiplier", varList = { "ShaperItem" } } )  } end,
	["每装备 1 个【塑界之器】，便获得额外混沌伤害，其数值等同于元素伤害的 (%d+)%%"]= function(num) return {  mod("ElementalDamageGainAsChaos", "BASE", num,{ type = "Multiplier", varList = { "ShaperItem" } } )  } end,
	["每装备一个裂界者物品，就将物理伤害的 (%d+)%% 视为额外混沌伤害"]= function(num) return {  mod("PhysicalDamageGainAsChaos", "BASE", num,{ type = "Multiplier", varList = { "ElderItem" } } )  } end,
	["药剂持续时间内对在奉献地面上的敌人的基础暴击提高 ([%d%.]+)%%"]= function(num) return {  mod("CritChance", "BASE", num,{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" })  } end,
	["在效果持续期间，对位于奉献地面之上的敌人的暴击几率 %+([%d%.]+)%%"]= function(num) return {  mod("CritChance", "BASE", num,{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" })  } end,
	["药剂生效期间，对奉献地面上的敌人的暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" })  } end,
	["效果期间，你创造的【奉献地面】可以使敌人承受的伤害提高 (%d+)%%"]= function(num) return { mod("EnemyModifier", "LIST", { mod =  mod("DamageTaken", "INC", num)},{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" }) } end,
	["药剂持续时间内奉献地面上的敌人所受伤害提高 (%d+)%%"]= function(num) return { mod("EnemyModifier", "LIST", { mod =  mod("DamageTaken", "INC", num)},{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" }) } end,
	["生效期间产生的奉献地面使敌人承受的伤害提高 (%d+)%%"]= function(num) return { mod("EnemyModifier", "LIST", { mod =  mod("DamageTaken", "INC", num)},{ type = "Condition", var = "UsingFlask" },{ type = "ActorCondition", actor = "enemy", var = "OnConsecratedGround" }) } end,
	["周围友军的行动速度无法被减速至基础以下"] = function() return { mod("ExtraAura", "LIST",{ mod = flag("ActionSpeedCannotBeBelowBase") , onlyAllies = true} )} end,
	["周围队友的行动速度无法被减速至基础以下"] = function() return { mod("ExtraAura", "LIST",{ mod = flag("ActionSpeedCannotBeBelowBase") , onlyAllies = true} )} end,
	["每 100 点力量可为周围友军的全局防御提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("Defences", "INC", num), onlyAllies = true},{ type = "PerStat", stat = "Str", div = 100 } )} end,
	["你每有 100 点力量，周围队友的防御属性便提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("Defences", "INC", num), onlyAllies = true},{ type = "PerStat", stat = "Str", div = 100 } )} end,
	["每 100 点敏捷可为周围友军 %+(%d+)%% 攻击和法术暴击伤害加成"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("CritMultiplier", "BASE", num) }, { type = "PerStat", stat = "Dex", div = 100 }) } end,
	["你每有 100 点敏捷，周围队友获得 %+(%d+)%% 暴击伤害加成"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("CritMultiplier", "BASE", num) }, { type = "PerStat", stat = "Dex", div = 100 }) } end,
	["每 100 点智慧可为周围友军的施法速度提高 (%d+)%%"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("Speed", "INC", num, nil, ModFlag.Cast ) }, { type = "PerStat", stat = "Int", div = 100 }) } end,
	["你每有 100 点智慧，周围队友的施法速度便提高 (%d+)%%"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("Speed", "INC", num, nil, ModFlag.Cast ) }, { type = "PerStat", stat = "Int", div = 100 }) } end,
	["你每有 100 点力量，周围友军的防御属性便提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST",{ mod =mod("Defences", "INC", num), onlyAllies = true},{ type = "PerStat", stat = "Str", div = 100 } )} end,
	["你每有 100 点敏捷，周围友军获得 %+(%d+)%% 暴击伤害加成"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("CritMultiplier", "BASE", num) }, { type = "PerStat", stat = "Dex", div = 100 }) } end,
	["你每有 100 点智慧，周围友军的施法速度便提高 (%d+)%%"]  = function(num) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("Speed", "INC", num, nil, ModFlag.Cast ) }, { type = "PerStat", stat = "Int", div = 100 }) } end,
	["周围敌人受到的物理伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("PhysicalDamageTaken", "INC", num) }) } end,
	["周围敌人受到的元素伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("ElementalDamageTaken", "INC", num) }) } end,
	["移动时无法被感电或点燃"] = function() return {  mod("AvoidShock", "BASE", 100,{ type = "Condition", var = "Moving" } ),
	mod("AvoidIgnite", "BASE", 100,{ type = "Condition", var = "Moving" } )
	} end,
	["移动时无法被冰缓或冻结"] = function() return {  mod("AvoidChill", "BASE", 100,{ type = "Condition", var = "Moving" } ),
	mod("AvoidFreeze", "BASE", 100,{ type = "Condition", var = "Moving" } )
	} end,
	["近期内你若击中敌人，则每秒回复 ([%d%.]+) 能量护盾"]  = function(num) return { mod("EnergyShieldRegen", "BASE", num,{ type = "Condition", var = "HitRecently" }) } end,
	["近期内你若击中敌人，则每秒回复 ([%d%.]+) 魔力"]  = function(num) return { mod("ManaRegen", "BASE", num,{ type = "Condition", var = "HitRecently" }) } end,
	["消耗总计 (%d+) 魔力后触发 (%d+) 级的【(.+)】"] = function( _,_2,num, skill) return triggerExtraSkill(skill, num) end,
	["当你拥有阻灵术时获得【猛攻】状态"]= { flag("Condition:Onslaught", { type = "Condition", var = "SoulGainPrevention" }) },
	["所有身上装备的物品皆为【塑界之器】时，击中无视目标的混沌抗性"] = { flag("IgnoreChaosResistances", { type = "MultiplierThreshold", var = "NonShaperItem", threshold = 0, upper = true }) },
	["若全部装备塑界者物品，则击中无视敌方怪物的混沌抗性"] = { flag("IgnoreChaosResistances", { type = "MultiplierThreshold", var = "NonShaperItem", threshold = 0, upper = true }) },
	["若全套装备均为裂界者物品，则击中无视敌人的混沌抗性"] = { flag("IgnoreChaosResistances", { type = "MultiplierThreshold", var = "NonElderItem", threshold = 0, upper = true }) },
	["造成暴击时无视目标的元素抗性"] = { flag("IgnoreElementalResistances", { type = "Condition", var = "CriticalStrike" }) },
	["非暴击伤害穿透敌人 (%d+)%% 的元素抗性"] = function(num) return { mod("ElementalPenetration", "BASE", num, { type = "Condition", var = "CriticalStrike", neg = true }) } end,
	["除火焰伤害外不造成其他伤害"] = { flag("DealNoPhysical"), flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoChaos") },
	["无法造成点燃"] = { flag("CannotIgnite") },
	["无法造成元素伤害"] = { flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire") }, --备注：deal no elemental damage
	["无法造成非元素伤害"] = { flag("DealNoPhysical"), flag("DealNoChaos") }, --备注：deal no non%-elemental damage
	["不能点燃"] = { flag("CannotIgnite") },
	["无法造成冻结或冰缓"] = { flag("CannotFreeze"), flag("CannotChill") },
	["无法造成感电"] = { flag("CannotShock") },
	["无法点燃、冰缓、冻结、感电"] = {  flag("CannotIgnite") ,flag("CannotFreeze"), flag("CannotChill"),flag("CannotShock") },
	["你的元素伤害可以造成感电"] = { flag("ColdCanShock"), flag("FireCanShock") },
	["近期内你若击中敌人，你和周围友军每秒回复 ([%d%.]+)%% 生命"]= function(num) return {
	mod("ExtraAura", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) },  { type = "Condition", var = "HitRecently" })} end,
	["每秒对周围敌人造成【死亡凋零】，持续 15 秒"]= {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" }) -- Make the Configuration option appear
	},
	["用该武器击中时施加 2 秒枯萎"]= {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" }) -- Make the Configuration option appear
	},
	["用该武器击中时施加 2 秒凋零"]= {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" }) -- Make the Configuration option appear
	},
	["使用此武器击中有 (%d+)%% 几率附加凋零"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["使用此武器击中有 (%d+)%% 的几率附加凋零"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["用该武器击中时有 (%d+)%% 几率施加 2 秒枯萎"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["用该武器击中时有 (%d+)%% 的几率施加 2 秒枯萎"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["用该武器击中时有 (%d+)%% 几率施加 2 秒凋零"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["用该武器击中时有 (%d+)%% 的几率施加 2 秒凋零"]=function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["对周围敌人，攻击和法术暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "Global" })   } end,
	["你的行动速度无法被减速至基础以下"] = { flag("ActionSpeedCannotBeBelowBase") },
	["生命偷取总回复上限翻倍。"] = { mod("MaxLifeLeechRate", "MORE", 100) },
	["从生命偷取中获得的每秒最大总恢复量翻倍。"] = { mod("MaxLifeLeechRate", "MORE", 100) },
	["从生命偷取中获得的每秒最大总恢复量翻倍"] = { mod("MaxLifeLeechRate", "MORE", 100) },
	["最近你若遭到【残暴打击】，那么从生命偷取中得到的每秒总回复量提高 ([%d%.]+)%%"]= function(num) return {  mod("MaxLifeLeechRate", "INC", num,{ type = "Condition", var = "BeenSavageHitRecently" })  } end,
	["生命偷取每秒总恢复量翻倍"] = { mod("LifeLeechRate", "MORE", 100) },
	["从生命偷取中获得的每秒总恢复量翻倍"] = { mod("LifeLeechRate", "MORE", 100) },
	["能量护盾偷取总回复上限翻倍。"] = { mod("MaxEnergyShieldLeechRate", "MORE", 100) },
	["从能量护盾偷取中获得的每秒最大总恢复量翻倍。"] = { mod("MaxEnergyShieldLeechRate", "MORE", 100) },
	["从能量护盾偷取中获得的总最大恢复量额外降低 (%d+)%%"] = function(num) return {  mod("MaxEnergyShieldLeechRate", "MORE", -num)  } end,
	["能量护盾偷取总回复上限额外降低 (%d+)%%"] = function(num) return {  mod("MaxEnergyShieldLeechRate", "MORE", -num)  } end,
	["能量护盾偷取总回复上限提高 (%d+)%%"] = function(num) return {  mod("MaxEnergyShieldLeechRate", "INC", num)  } end,
	["不再获得生命回复效果"] = { flag("NoLifeRegen") },
	["从能量护盾偷取中获得的每秒最大总恢复量提高翻倍"] = { mod("MaxEnergyShieldLeechRate", "MORE", 100) },
	["不再获得生命偷取，将其偷取效果套用于能量护盾"] = { flag("GhostReaver") },
	["能量护盾偷取改为生命偷取"] = { flag("GhostReaver") },
	["(%d+)%% 几率获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num, _, perc) return { mod("NonChaosDamageGainAsChaos", "BASE", num / 100 * tonumber(perc)) } end,
	["有 (%d+)%% 几率获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num, _, perc) return { mod("NonChaosDamageGainAsChaos", "BASE", num / 100 * tonumber(perc)) } end,
	["(%d+)%% 的几率获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num, _, perc) return { mod("NonChaosDamageGainAsChaos", "BASE", num / 100 * tonumber(perc)) } end,
	["有 (%d+)%% 的几率获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num, _, perc) return { mod("NonChaosDamageGainAsChaos", "BASE", num / 100 * tonumber(perc)) } end,
	["nearby allies have (%d+)%% increased defences per (%d+) strength you have"] = function(num, _, div) return { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("Defences", "INC", num) }, { type = "PerStat", stat = "Str", div = tonumber(div) }) } end,
	["持续吟唱时，获得 (%d+)%% 额外物理伤害减伤"] = function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时，有额外 (%d+)%% 几率躲避攻击击中"] = function(num) return {  mod("AttackDodgeChance", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时有 (%d+)%% 几率不被攻击击中"] = function(num) return {  mod("AttackDodgeChance", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时，有 (%d+)%% 几率免疫晕眩"] = function(num) return {  mod("AvoidStun", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时，有额外 (%d+)%% 的几率躲避攻击击中"] = function(num) return {  mod("AttackDodgeChance", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时有 (%d+)%% 的几率不被攻击击中"] = function(num) return {  mod("AttackDodgeChance", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时，有 (%d+)%% 的几率免疫晕眩"] = function(num) return {  mod("AvoidStun", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["持续吟唱时，每秒回复 ([%d%.]+)%% 最大生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["拥有能量护盾时法术躲避几率 %+(%d+)%%"] = function(num) return {  mod("SpellDodgeChance", "BASE", num,{ type = "Condition", var = "HaveEnergyShield" })  } end,
	["拥有能量护盾时闪避几率 %+(%d+)%%"] = function(num) return {  mod("EvadeChance", "BASE", num,{ type = "Condition", var = "HaveEnergyShield" })  } end,
	["你没有能量护盾时无法格挡"] = function() return {
	flag("CannotBlockAttacks",{ type = "Condition", var = "HaveEnergyShield", neg = true }),
	flag("CannotBlockSpells",{ type = "Condition", var = "HaveEnergyShield", neg = true })
	} end,
	["持续吟唱时获得 (%d+)%% 额外物理伤害减伤"] = function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "OnChannelling" })  } end,
	["神圣球达到上限时获得【神圣】状态"] = {
	mod("ElementalDamage", "MORE", 50, { type = "Condition", var = "Divinity" }),
	mod("ElementalDamageTaken", "MORE", -20, { type = "Condition", var = "Divinity" }),
	},
	["满神圣球时，你获得【神性】，持续 10 秒"] = {
	mod("ElementalDamage", "MORE", 50, { type = "Condition", var = "Divinity" }),
	mod("ElementalDamageTaken", "MORE", -20, { type = "Condition", var = "Divinity" }),
	},
	["当你发射箭矢时，会消耗 1 个虚空之矢来触发 (%d+) 级的【虚空射击】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="VoidShot", level = num, triggered = true})   } end,
	["追忆词缀"] = { mod("Multiplier:SynthesisedItem", "BASE", 1) },
	["【定罪波】的特效会使元素抗性 ([%+%-]?%d+)%%"]	= function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("FireResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "Fire Exposure", effectCond = "WaveOfConvictionFireExposureActive" }) }, { type = "Condition", var = "WaveOfConvictionFireExposureActive" }),
	mod("EnemyModifier", "LIST", { mod = mod("ColdResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "Cold Exposure", effectCond = "WaveOfConvictionColdExposureActive" }) }, { type = "Condition", var = "WaveOfConvictionColdExposureActive" }),
	mod("EnemyModifier", "LIST", { mod = mod("LightningResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "Lightning Exposure", effectCond = "WaveOfConvictionLightningExposureActive" }) }, { type = "Condition", var = "WaveOfConvictionLightningExposureActive" }),
	} end,
	["被你嘲讽的敌人无法闪避攻击"] = { mod("EnemyModifier", "LIST", { mod = flag("CannotEvade", { type = "Condition", var = "Taunted" }) }) },
	["当你在你在天赋树上连接到一个职业的出发位置时，你获得：野蛮人： 近战技能范围扩大 (%d+)%%决斗者：攻击伤害的 ([%d%.]+)%% 会转化为生命偷取游侠：移动速度提高 (%d+)%%暗影：%+([%d%.]+)%% 暴击率女巫：每秒回复 ([%d%.]+)%% 最大魔力圣堂武僧：伤害穿透 5%% 元素抗性贵族：%+25 所有属性"]= function(_,num_ymr,num_jdz,num_yx,num_ay,num_nw) return {
	mod("AreaOfEffect", "INC", tonumber(num_ymr),nil, ModFlag.Melee,{ type = "Condition", var = "ConnectedTo野蛮人Start" }) ,
	mod("DamageLifeLeech", "BASE", tonumber(num_jdz),nil, ModFlag.Attack,{ type = "Condition", var = "ConnectedTo决斗者Start" }),
	mod("MovementSpeed", "INC", tonumber(num_yx),{ type = "Condition", var = "ConnectedTo游侠Start" }) ,
	mod("CritChance", "BASE", tonumber(num_ay),{ type = "Condition", var = "ConnectedTo暗影刺客Start" }),
	mod("ManaRegenPercent", "BASE", tonumber(num_nw), { type = "Condition", var = "ConnectedTo女巫Start" }),
	mod("ElementalPenetration", "BASE", 5,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" }),
	mod("Str", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Dex", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Int", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" })
	} end,
	["当你在你在天赋树上连接到一个职业的出发位置时，你获得：野蛮人： 近战技能范围扩大 (%d+)%%决斗者：攻击伤害的 ([%d%.]+)%% 会转化为生命偷取游侠：移动速度提高 (%d+)%%暗影：%+([%d%.]+)%% 暴击率女巫：每秒回复 ([%d%.]+)%% 魔力圣堂武僧：伤害穿透 5%% 元素抗性贵族：%+25 所有属性"]= function(_,num_ymr,num_jdz,num_yx,num_ay,num_nw) return {
	mod("AreaOfEffect", "INC", tonumber(num_ymr),nil, ModFlag.Melee,{ type = "Condition", var = "ConnectedTo野蛮人Start" }) ,
	mod("DamageLifeLeech", "BASE", tonumber(num_jdz),nil, ModFlag.Attack,{ type = "Condition", var = "ConnectedTo决斗者Start" }),
	mod("MovementSpeed", "INC", tonumber(num_yx),{ type = "Condition", var = "ConnectedTo游侠Start" }) ,
	mod("CritChance", "BASE", tonumber(num_ay),{ type = "Condition", var = "ConnectedTo暗影刺客Start" }),
	mod("ManaRegenPercent", "BASE", tonumber(num_nw), { type = "Condition", var = "ConnectedTo女巫Start" }),
	mod("ElementalPenetration", "BASE", 5,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" }),
	mod("Str", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Dex", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" }) ,
	mod("Int", "BASE", 25,{ type = "Condition", var = "ConnectedTo贵族Start" })
	} end,
	--[[
	["总属性每有 (%d+) 点，魔力保留降低 (%d+)%%"] = function(_,num1,num2) return {  mod("ManaReserved", "INC", -tonumber(num2),{ type = "PerStat", statList = { 'Str', 'Dex', 'Int' }, div = tonumber(num1),stat= "Dex" } )  } end,
	]]--
	["最大物理攻击总伤害额外提高 (%d+)%%"]= function(num) return {  mod("PhysicalMax", "MORE", num,{ type = "SkillType", skillType = SkillType.Attack })   } end,
	["最小物理攻击总伤害额外降低 (%d+)%%"]= function(num) return {  mod("PhysicalMin", "MORE", -num, { type = "SkillType", skillType = SkillType.Attack } )   } end,
	["最大物理攻击伤害总增 (%d+)%%"]= function(num) return {  mod("PhysicalMax", "MORE", num,{ type = "SkillType", skillType = SkillType.Attack })   } end,
	["最小物理攻击伤害总降 (%d+)%%"]= function(num) return {  mod("PhysicalMin", "MORE", -num, { type = "SkillType", skillType = SkillType.Attack } )   } end,
	["每个幽灵护罩可使承受的伤害降低 (%d+)%%"]= function(num) return {  mod("DamageTaken", "INC", -num,{ type = "Multiplier", var = "GhostShroud" } )   } end,
	["每层【鬼影缠身】会使承受的伤害降低 (%d+)%%"]= function(num) return {  mod("DamageTaken", "INC", -num,{ type = "Multiplier", var = "GhostShroud" })   } end,
	["每层鬼影缠身可使攻击和施法速度提高 (%d+)%%"]= function(num) return {  mod("Speed", "INC", num,{ type = "Multiplier", var = "GhostShroud" })   } end,
	["每个幽灵护罩可使攻击和施法速度提高 (%d+)%%"]= function(num) return {  mod("Speed", "INC", num,{ type = "Multiplier", var = "GhostShroud" })   } end,
	["拥有幽灵护罩时免疫眩晕"]= function(num) return {  mod("AvoidStun", "BASE", 100,{ type = "MultiplierThreshold", var = "GhostShroud", threshold = 1 } )   } end,
	["拥有鬼影缠身时免疫晕眩"]= function(num) return {  mod("AvoidStun", "BASE", 100,{ type = "MultiplierThreshold", var = "GhostShroud", threshold = 1 } )   } end,
	["拥有鬼影缠身时免疫眩晕"]= function(num) return {  mod("AvoidStun", "BASE", 100,{ type = "MultiplierThreshold", var = "GhostShroud", threshold = 1 } )   } end,
	["每 100 最大生命提高 (%d+)%% 法术暴击几率"]= function(num) return {
	mod("CritChance", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["每 100 最大生命提高 (%d+)%% 法术伤害"]= function(num) return {
	mod("Damage", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["每 100 点最大生命使法术伤害提高 (%d+)%%"]= function(num) return {
	mod("Damage", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["每 100 点最大生命会使法术暴击几率提高 (%d+)%%"]= function(num) return {
	mod("CritChance", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["每 100 玩家最大生命提高 (%d+)%% 法术伤害"]= function(num) return {
	mod("Damage", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["每 100 玩家最大生命提高 (%d+)%% 法术暴击几率"]= function(num) return {
	mod("CritChance", "INC", num,nil, ModFlag.Spell,  { type = "PerStat", stat = "PlayerLife", div = 100 })
	}end,
	["总能量护盾每秒回复额外降低 (%d+)%%"]= function(num) return {
	mod("EnergyShieldRegen", "MORE", -num)
	}end,
	["能量护盾再生率总降 (%d+)%%"]= function(num) return {
	mod("EnergyShieldRegen", "MORE", -num)
	}end,
	["武器攻击的基础暴击几率为 ([%d%.]+)%%"]= function(num) return { mod("WeaponBaseCritChance", "OVERRIDE", num) } end,
	["基础武器暴击率为 ([%d%.]+)%%"]= function(num) return { mod("WeaponBaseCritChance", "OVERRIDE", num) } end,
	["每次击中获得 %d+ 层怒火，最多每 [%d%.]+ 秒获得一次"] = {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["每秒回复 (%d+) 点怒火"]= function(num) return {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }),
	mod("RageRegen", "BASE", num)
	}end,
	["若你的怒火少于 25 点，则战吼每 5 【威力值】即可获得 10 点怒火"]= function(num) return {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }),
	}end,
	["攻击击中获得 %d+ 点怒火。每 [%d%.]+ 秒只会发生一次"] = {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["无视属性需求"] = {
	flag("GlobalNoAttributeRequirements"),
	},
	["无法获得属性加成"] = {
	flag("NoAttributeBonus"),
	},
	["来自斧或剑的攻击击中时获得 %d+ 层怒火，每秒最多获得一层"] = {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["使用战吼时获得 %d+ 层怒火"] = {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["每 1 点怒火都获得额外火焰伤害， 其数值等同于物理伤害的 (%d+)%%"]= function(num) return {
	mod("PhysicalDamageGainAsFire", "BASE", num, { type = "Multiplier", var = "Rage", div = 1 })
	}end,
	["不损失怒火时，每一点怒火就会每秒失去 ([%d%.]+)%% 生命"] = function(num) return { mod("LifeDegen", "BASE", num / 100, { type = "PerStat", stat = "Life" }, { type = "Multiplier", var = "Rage" }) } end,
	["当你没有损失怒火时，每点怒火使你每秒失去 ([%d%.]+)%% 的最大生命"] = function(num) return { mod("LifeDegen", "BASE", num / 100, { type = "PerStat", stat = "Life" }, { type = "Multiplier", var = "Rage"}) } end,
	["每 4 层怒火有 (%d+)%% 几率造成双倍伤害"]= function(num) return {
	mod("DoubleDamageChance", "BASE", num, { type = "Multiplier", var = "Rage", div = 4 })
	}end,
	["每 4 层怒火有 (%d+)%% 的几率造成双倍伤害"]= function(num) return {
	mod("DoubleDamageChance", "BASE", num, { type = "Multiplier", var = "Rage", div = 4 })
	}end,
	["【怒火】带来的固定效果变成三倍"] = { mod("Multiplier:RageEffect", "BASE", 2) },
	["怒火的效果变为三倍"] = { mod("Multiplier:RageEffect", "BASE", 2) },
	["投射物穿透 (%d+) 个额外目标"] = function(num) return { mod("PierceCount", "BASE", num) } end,
	["你造成的中毒伤害生效速度提高 (%d+)%%"]= function(num) return {
	mod("PoisonFaster", "INC", num)
	}end,
	["中毒伤害额外提高 (%d+)%%"]= function(num) return {  mod("Damage", "MORE", num,nil,nil,KeywordFlag.Poison )  } end,
	["你造成的烈毒的伤害生效速度加快 (%d+)%%"]= function(num) return {
	mod("PoisonFaster", "INC", num)
	}end,
	["你攻击造成的点燃的伤害生效速度加快 (%d+)%%"] = function(num) return { mod("IgniteBurnFaster", "INC", num, nil, ModFlag.Attack) } end,
	["你造成的点燃的伤害生效速度加快 (%d+)%%"] = function(num) return { mod("IgniteBurnFaster", "INC", num) } end,
	["你造成的流血伤害生效速度提高 (%d+)%%"]= function(num) return {
	mod("BleedFaster", "INC", num)
	}end,
	["你造成的流血的伤害生效速度加快 (%d+)%%"]= function(num) return {
	mod("BleedFaster", "INC", num)
	}end,
	["每个挑战球使总攻击和移动速度额外提高 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "ChallengerCharge" }) ,
	mod("MovementSpeed", "MORE", num,{ type = "Multiplier", var = "ChallengerCharge" })
	}end,
	["每个挑战球可使总攻击速度和移动速度额外提高 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "ChallengerCharge" }) ,
	mod("MovementSpeed", "MORE", num,{ type = "Multiplier", var = "ChallengerCharge" })
	}end,
	["每个挑战球使总攻击和移动速度总增 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "ChallengerCharge" }) ,
	mod("MovementSpeed", "MORE", num,{ type = "Multiplier", var = "ChallengerCharge" })
	}end,
	["每个疾电球可使暴击几率降低 (%d+)%%"]= function(num) return {
	mod("CritChance", "INC", -num,{ type = "Multiplier", var = "BlitzCharge" }) ,
	}end,
	["每个疾电球使攻击速度总增 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "BlitzCharge" }) ,
	}end,
	["每个疾电球可使暴击率降低 (%d+)%%"]= function(num) return {
	mod("CritChance", "INC", -num,{ type = "Multiplier", var = "BlitzCharge" }) ,
	}end,
	["每个疾电球使总攻击速度额外提高 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", num,nil, ModFlag.Attack,{ type = "Multiplier", var = "BlitzCharge" }) ,
	}end,
	["总攻击速度额外降低 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", -num,nil, ModFlag.Attack) ,
	}end,
	["攻击速度总降 (%d+)%%"]= function(num) return {
	mod("Speed", "MORE", -num,nil, ModFlag.Attack) ,
	}end,
	["无法造成混沌伤害"] = { flag("DealNoChaos") },
	["若你近期内穿刺过敌人，你和周围友军获得护甲 %+(%d+)"] = function (num) return { mod("ExtraAura", "LIST", { mod = mod("Armour", "BASE", num) }, { type = "Condition", var = "ImpaledRecently" }) } end,
	["攻击击中时有 (%d+)%% 几率穿刺敌人"]= function(num) return {
	mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack)
	}end,
	["攻击击中时有 (%d+)%% 的几率穿刺敌人"]= function(num) return {
	mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack)
	}end,
	["法术击中有 (%d+)%% 几率穿刺敌人"]= function(num) return {
	mod("ImpaleChance", "BASE", num, nil, ModFlag.Spell,KeywordFlag.Hit)
	}end,
	["法术击中有 (%d+)%% 的几率穿刺敌人"]= function(num) return {
	mod("ImpaleChance", "BASE", num, nil, ModFlag.Spell,KeywordFlag.Hit)
	}end,
	["你造成的穿刺效果会额外持续 (%d+) 次击中"]= function(num) return {
	mod("ImpaleStacksMax", "BASE", num)
	}end,
	["你施加的【穿刺】效果持续 (%d+) 次额外击中"]= function(num) return {
	mod("ImpaleStacksMax", "BASE", num)
	}end,
	["敌人身上每有一个穿刺效果，你和周围友军的攻击便额外造成 (%d+) %- (%d+) 附加物理伤害"]= function (_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("PhysicalMin", "BASE", tonumber(num1)) },  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }),
	mod("ExtraAura", "LIST",
	{ mod = mod("PhysicalMax", "BASE", tonumber(num2)) },  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }),
	} end,
	["敌人身上每层穿刺效果可以为你和周围友军附加 (%d+) %- (%d+) 物理伤害"]= function (_,num1,num2) return {
	mod("ExtraAura", "LIST",
	{ mod = mod("PhysicalMin", "BASE", tonumber(num1)) },  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }),
	mod("ExtraAura", "LIST",
	{ mod = mod("PhysicalMax", "BASE", tonumber(num2)) },  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }),
	} end,
	["根据和目标的距离来提升总近战伤害，最高额外提高 (%d+)%%"]= function(num) return {
	flag("Condition:CanMeleeDistanceRamp"),
	mod("Damage", "MORE", num,nil, ModFlag.Melee, 0, { type = "DistanceRamp",  ramp = {{15,1},{40,0}}},{ type = "Condition", var = "CanMeleeDistanceRamp" }),
	}end,
	["基于距离对敌人的总近战伤害最多总增 (%d+)%%"]= function(num) return {
	flag("Condition:CanMeleeDistanceRamp"),
	mod("Damage", "MORE", num,nil, ModFlag.Melee, 0, { type = "DistanceRamp",  ramp = {{15,1},{40,0}}},{ type = "Condition", var = "CanMeleeDistanceRamp" }),
	}end,
	["照亮范围的扩大和缩小也同样作用于范围效果，等于其数值的 50%%"] = { flag("HalfOfLightRadiusAppliesToAreaOfEffect") },
	["照亮范围的扩大和缩小也同样作用于伤害"] = { flag("LightRadiusAppliesToDamage") },
	["当你使用弓箭攻击时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["你用弓类攻击时触发 (%d+) 级(.+)"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["每个暴击球使法术总伤害额外提高 (%d+)%%"]= function(num) return {
	mod("Damage", "MORE", num,nil, ModFlag.Spell,{ type = "Multiplier", var = "PowerCharge" }),
	}end,
	["每个暴击球使法术伤害总增 (%d+)%%"]= function(num) return {
	mod("Damage", "MORE", num,nil, ModFlag.Spell,{ type = "Multiplier", var = "PowerCharge" }),
	}end,
	["范围内的天赋被圣堂抑制"] = { flag("好战的信仰") },
	["范围中的天赋被马拉克斯抑制"] = { flag("残酷的约束") },
	["范围内的天赋被永恒帝国抑制"] = { flag("优雅的狂妄") },
	["范围内的天赋被卡鲁抑制"] = { flag("致命的骄傲") },
	["范围内的天赋被瓦尔抑制"] = { flag("光彩夺目") },
	["只影响小环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 4 }) },
	["只影响中环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 5 }) },
	["只影响大环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 6 }) },
	["只影响超大环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 7 }) },
	["只影响巨环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 7 }) },
	["影响小环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 4 }) },
	["影响中环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 5 }) },
	["影响大环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 6 }) },
	["影响超大环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 7 }) },
	["影响巨环内的天赋"] = { mod("JewelData", "LIST", { key = "radiusIndex", value = 7 }) },
	["最大能量护盾为 (%d+)"]  = function(num) return { mod("EnergyShield", "OVERRIDE", tonumber(num)) } end,
	["最大魔力的 (%d+)%% 转化为双倍的护甲"]  = function(num) return { mod("ManaConvertToDoubleArmour", "BASE", tonumber(num)) } end,
	["暴击率特别幸运"] = { flag("CritChanceLucky") },
	["你瞎了"] = { flag("Condition:Blinded") },
	["目盲不影响你的照亮范围"] = {  },
	["目盲时总近战暴击率总增 (%d+)%%"]= function(num) return { mod("CritChance", "MORE", num,nil, ModFlag.Melee,{ type = "Condition", var = "Blinded" }) } end,
	["目盲时总近战暴击率额外提高 (%d+)%%"]= function(num) return { mod("CritChance", "MORE", num,nil, ModFlag.Melee,{ type = "Condition", var = "Blinded" }) } end,
	["受到的冰霜和闪电伤害有 (%d+)%% 视为火焰伤害"]= function(num) return {
	mod("ColdDamageTakenAsFire", "BASE", num),
	mod("LightningDamageTakenAsFire", "BASE", num),
	} end,
	["受到的元素伤害有 (%d+)%% 视为混沌伤害"]= function(num) return {
	mod("ColdDamageTakenAsChaos", "BASE", num),
	mod("LightningDamageTakenAsChaos", "BASE", num),
	mod("FireDamageTakenAsChaos", "BASE", num),
	} end,
	["总冰霜抗性额外降低 (%d+)%%"]= function(num) return {
	mod("ColdResist", "MORE", -num)
	} end,
	["总闪电抗性额外降低 (%d+)%%"]= function(num) return {
	mod("LightningResist", "MORE", -num)
	} end,
	["攻击格挡率翻倍"]= function() return {
	mod("BlockChance", "MORE", 100)
	} end,
	["法术格挡率翻倍"]= function() return {
	mod("SpellBlockChance", "MORE", 100)
	} end,
	["光环效果对友军没有作用"] = { flag("SelfAuraSkillsCannotAffectAllies") },
	["无法获得友军光环效果"] = { flag("AlliesAurasCannotAffectSelf") },
	["光环技能不能影响友军"] = { flag("SelfAuraSkillsCannotAffectAllies") },
	["总生命回复速度额外降低 (%d+)%%"]= function(num) return {
	mod("LifeRecoveryRate", "MORE", -num)
	} end,
	["生命回复额外降低 (%d+)%%"]= function(num) return {
	mod("LifeRecoveryRate", "MORE", -num)
	} end,
	["生命再生率总降 (%d+)%%"]= function(num) return {
	mod("LifeRecoveryRate", "MORE", -num)
	} end,
	["从药剂获得的生命回复额外降低 (%d+)%%"]= function(num) return {
	mod("FlaskLifeRecovery", "MORE", -num)
	} end,
	["获得等同 ([%d%.]+)%% 最大生命的额外最大能量护盾"]= function(num) return {  mod("LifeGainAsEnergyShield", "BASE", num)  } end,
	["获得等于最大生命 ([%d%.]+)%% 的额外最大能量护盾"]= function(num) return {  mod("LifeGainAsEnergyShield", "BASE", num)  } end,
	["至少有 (%d+) 点奉献时，获得等同 (%d+)%% 最大魔力的额外最大能量护盾"]= function(_,num1,num2) return {  mod("ManaGainAsEnergyShield", "BASE", tonumber(num2),{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num1) })  } end,
	["至少 (%d+) 点奉献时，位于奉献地面之上免疫元素异常状态"]= function(num) return {
	mod("AvoidShock", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" },{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num) })  ,
	mod("AvoidChilled", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" },{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num) })  ,
	mod("AvoidFrozen", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" },{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num) })  ,
	mod("AvoidIgnite", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" },{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num) })  ,
	} end,
	["至少 (%d+) 点奉献时，额外获得 (%d+)%% 物理伤害减免"] = function(_,num1,num2) return {  mod("PhysicalDamageReduction", "BASE", tonumber(num2),{ type = "StatThreshold", stat = "Devotion", threshold = tonumber(num1) } )  } end,
	["无法使用生命偷取的恢复效果"]= function(num) return {
	mod("LifeLeechRate", "MORE", -100)
	} end,
	["生命偷取的每秒恢复效果每 (%d+)%% 使受到的总伤害额外降低 (%d+)%%"] = function(_,num1,num2) return {
	mod("DamageTaken", "MORE", -tonumber(num2),{ type = "PerStat", stat = "MaxLifeLeechRatePercentage", div = tonumber(num1) },{ type = "Condition", var = "LeechingLife" } )
	} end,
	["从生命偷取中获得的每秒最大总恢复量额外降低 ([%d%.]+)%%"]= function(num) return {
	mod("MaxLifeLeechRate", "MORE", -num)  } end,
	["冰霜闪现的冷却回复速度提高 (%d+)%%"] = function(num) return {
	mod("CooldownRecovery", "INC", num, { type = "SkillName", skillName = "冰霜闪现" })
	} end,
	["所有物理法术技能石等级 %+(%d+)"] = function(num) return { mod("GemProperty", "LIST",  { keyword = "physical_spell", key = "level", value = num }) } end,
	["每个红色插槽使召唤生物 (%d+)%% 的物理伤害转化为火焰伤害"]
	= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageConvertToFire", "BASE", num) },{ type = "Multiplier", var = "RedSocketIn{SlotName}" }) } end,
	["每个绿色插槽使召唤生物 (%d+)%% 的物理伤害转化为冰霜伤害"]
	= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageConvertToCold", "BASE", num) },{ type = "Multiplier", var = "GreenSocketIn{SlotName}" }) } end,
	["每个蓝色插槽使召唤生物 (%d+)%% 的物理伤害转化为闪电伤害"]
	= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageConvertToLightning", "BASE", num) },{ type = "Multiplier", var = "BlueSocketIn{SlotName}" }) } end,
	["每个白色插槽使召唤生物 (%d+)%% 的物理伤害转化为混沌伤害"]
	= function(num) return { mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageConvertToChaos", "BASE", num) },{ type = "Multiplier", var = "WhiteSocketIn{SlotName}" }) } end,
	["旅行技能冷却回复速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", num,{ type = "SkillType", skillType = SkillType.TravelSkill })  } end,
	["旅行技能的冷却回复速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", num,{ type = "SkillType", skillType = SkillType.TravelSkill })  } end,
	["每个狂怒球可使旅行技能冷却回复速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", tonumber(num),{ type = "SkillType", skillType = SkillType.TravelSkill },{ type = "Multiplier", var = "FrenzyCharge" })  } end,
	["每个狂怒球使旅行技能的冷却回复速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", tonumber(num),{ type = "SkillType", skillType = SkillType.TravelSkill },{ type = "Multiplier", var = "FrenzyCharge" })  } end,
	["你的移动速度变为基础值的 (%d+)%%"] = function(num) return {
	mod("MovementSpeed", "OVERRIDE", tonumber(num)/100 )
	} end,
	["你的移动速度为基础移动速度的 (%d+)%%"] = function(num) return {
	mod("MovementSpeed", "OVERRIDE", tonumber(num)/100 )
	} end,
	["你偷取生命，数值等同于你的地雷造成伤害的 ([%d%.]+)%%"] = function(num) return { mod("DamageLifeLeechToPlayer", "BASE", num, nil, 0, KeywordFlag.Mine) } end,
	["地雷造成 ([%d%.]+)%% 的伤害转化为你的生命偷取"] = function(num) return { mod("DamageLifeLeechToPlayer", "BASE", num, nil, 0, KeywordFlag.Mine) } end,
	["暴击造成异常状态时，用于暴击伤害加成的词缀也套用于持续伤害加成，等于其数值的 (%d+)%%"] = function(num) return { mod("CritMultiplierAppliesToDegen", "BASE", num) } end,
	["暴击造成异常状态时，%+(%d+)%% 伤害持续时间加成"] = function(num) return {
	mod("DotMultiplier", "BASE", num,nil,ModFlag.Ailment, { type = "Condition", var = "CriticalStrike" }  )
	} end,
	["暴击伤害加成也会套用于异常状态的持续伤害加成，数值为 (%d+)%%"] = function(num) return { mod("CritMultiplierAppliesToDegen", "BASE", num) } end,
	["周围至少有 1 个友军时，你和周围友军总伤害额外提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "MultiplierThreshold", var = "NearbyAlly", threshold = 1 }) } end,
	["周围至少有 5 个友军时，你和周围友军获得【猛攻】状态"] = { mod("ExtraAura", "LIST", { mod = flag("Onslaught") }, { type = "MultiplierThreshold", var = "NearbyAlly", threshold = 5 }) },
	["近期内你若有消耗灵柩，则你和召唤生物范围效果扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "Condition", var = "ConsumedCorpseRecently" }), mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num) }, { type = "Condition", var = "ConsumedCorpseRecently" }) } end,
	["附近至少有一个灵柩时，你和周围友军的总伤害额外提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "MultiplierThreshold", var = "NearbyCorpse", threshold = 1 }) } end,
	["周围每有 1 个灵柩，你和周围友军每秒回复 ([%d%.]+)%% 能量护盾，最多 ([%d%.]+)%%"] = function(num, _, limit) return { mod("ExtraAura", "LIST", { mod = mod("EnergyShieldRegenPercent", "BASE", num) }, { type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true }) } end,
	["周围每有 1 个灵柩，你和周围友军每秒回复 (%d+) 魔力，最多 (%d+)"] = function(num, _, limit) return { mod("ExtraAura", "LIST", { mod = mod("ManaRegen", "BASE", num) }, { type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true }) } end,
	["近期每消耗 1 具灵柩，攻击和施法速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", num,{ type = "Multiplier", var = "CorpseConsumedRecently" }) } end,
	["异常状态伤害加成不计算来自暴击的部分"] = { flag("AilmentsAreNeverFromCrit") },
	["你的火焰抗性为 (%d+)%%"] = function(num) return { mod("FireResist", "OVERRIDE", num) } end,
	["你的冰霜抗性为 (%d+)%%"] = function(num) return { mod("ColdResist", "OVERRIDE", num) } end,
	["你的闪电抗性为 (%d+)%%"] = function(num) return { mod("LightningResist", "OVERRIDE", num) } end,
	["火焰抗性 (%d+)%%"] = function(num) return { mod("FireResist", "OVERRIDE", num) } end,
	["冰霜抗性 (%d+)%%"] = function(num) return { mod("ColdResist", "OVERRIDE", num) } end,
	["闪电抗性 (%d+)%%"] = function(num) return { mod("LightningResist", "OVERRIDE", num) } end,
	["混沌抗性翻倍"] = { mod("ChaosResist", "MORE", 100) },
	["你身上的药剂效果提高 (%d+)%%"] = function(num) return { mod("FlaskEffect", "INC", num) } end,
	--["([%+%-]?%d+)%% 持续中毒伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Poison) } end,
	--["([%+%-]?%d+)%% 持续流血伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Bleed ) } end,
	--["([%+%-]?%d+)%% 持续点燃伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Ignite ) } end,
	["([%+%-]?%d+)%% 暴击导致的烈毒持续伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Poison,{ type = "Condition", var = "CriticalStrike" }) } end,	
	["([%+%-]?%d+)%% 暴击导致的中毒持续伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Poison,{ type = "Condition", var = "CriticalStrike" }) } end,
	["([%+%-]?%d+)%% 暴击导致的点燃持续伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Ignite,{ type = "Condition", var = "CriticalStrike" }) } end,
	["([%+%-]?%d+)%% 暴击导致的流血持续伤害加成"] = function(num) return { mod("DotMultiplier", "BASE", num,nil,nil,  KeywordFlag.Bleed,{ type = "Condition", var = "CriticalStrike" }) } end,
	["每个耐力球每秒回复 ([%d%.]+) 生命"] = function(num) return {  mod("LifeRegen", "BASE", num,{ type = "Multiplier", var = "EnduranceCharge" })  } end,
	["每个耐力球获得 ([%d%.]+)%% 每秒生命回复"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "EnduranceCharge" })  } end,
	["每个耐力球便使每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "EnduranceCharge" })  } end,
	["承受来自流血敌人的伤害降低 (%d+)%%"] = function(num) return { mod("DamageTaken", "INC", -num, { type = "ActorCondition", actor = "enemy", var = "Bleeding" })   } end,
	["召唤生物有 (%d+)%% 法术伤害格挡几率"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("SpellBlockChance", "BASE", num) })   } end,
	["召唤生物获得 %+(%d+)%% 格挡法术伤害率"]= function(num) return {   mod("MinionModifier", "LIST", { mod = mod("SpellBlockChance", "BASE", num) })   } end,
	["魔像提供的增益效果提高 (%d+)%%"]  = function(num) return { mod("BuffEffect", "INC", num, { type = "SkillType", skillType = SkillType.Golem })   } end,
	["每 (%d+) 点最大魔力会使法术伤害提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2,num3)return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "PerStat", stat = "Mana", div = tonumber(num1), limit = tonumber(num3), limitTotal = true  }) } end,
	["每有 (%d+) 最大魔力，混沌伤害提高 (%d+)%% ，最多提高 (%d+)%%"] = function(_,num1,num2,num3)return {  mod("ChaosDamage", "INC", tonumber(num2), { type = "PerStat", stat = "Mana", div = tonumber(num1), limit = tonumber(num3), limitTotal = true  }) } end,
	["每 (%d+) 魔力提高 (%d+)%% 法术伤害，最多 (%d+)%%"] = function(_,num1,num2,num3)return {  mod("Damage", "INC", tonumber(num2), nil,ModFlag.Spell,{ type = "PerStat", stat = "Mana", div = tonumber(num1), limit = tonumber(num3), limitTotal = true  }) } end,
	["每 (%d+) 生命保留 %+(%d+) 最大能量护盾"] = function( _, num1,num2,limit)  return { mod("EnergyShield", "BASE", tonumber(num2), { type = "PerStat", stat = "LifeReserved", div = tonumber(num1), limit = tonumber(limit), limitTotal = true })   } end,
	["每 (%d+) 点生命保留 %+(%d+) 最大能量护盾"] = function( _, num1,num2,limit)  return { mod("EnergyShield", "BASE", tonumber(num2), { type = "PerStat", stat = "LifeReserved", div = tonumber(num1), limit = tonumber(limit), limitTotal = true })   } end,
	["每 (%d+) 点未保留的最大魔力使效果区域扩大 (%d+)%%，最大 (%d+)%%"] = function( _, num1,num2,limit)  return { mod("AreaOfEffect", "INC", tonumber(num2), { type = "PerStat", stat = "ManaUnreserved", div = tonumber(num1), limit = tonumber(limit), limitTotal = true })   } end,
	["每有 (%d+) 未保留的魔力，范围效果扩大 (%d+)%%，最多 (%d+)%%"] = function( _, num1,num2,limit)  return { mod("AreaOfEffect", "INC", tonumber(num2), { type = "PerStat", stat = "ManaUnreserved", div = tonumber(num1), limit = tonumber(limit), limitTotal = true })   } end,
	["近期你或你的召唤生物每击败 1 个敌人回复 (%d+)%% 能量护盾，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("EnergyShieldRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", varList = {"EnemyKilledRecently","EnemyKilledByMinionsRecently"}, limit = tonumber(limit), limitTotal = true })   } end,
	["近期每有 1 个你的地雷被引爆，则每秒回复 (%d+)%% 生命，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("LifeRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期每有 1 个你的陷阱被触发，则每秒回复 (%d+)%% 生命，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("LifeRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", var = "TrapTriggeredRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期内，每个引爆的地雷使每秒回复 (%d+)%% 生命，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("LifeRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期内每个触发的陷阱使每秒回复 (%d+)%% 生命，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("LifeRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", var = "TrapTriggeredRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期内每引爆一个地雷，暴击几率提高 (%d+)%%，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("CritChance", "INC", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期内每引爆一个地雷，([%+%-]?%d+)%% 暴击伤害加成，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("CritMultiplier", "BASE", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期每个引爆的地雷可使暴击率提高 (%d+)%%，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("CritChance", "INC", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["近期每个引爆的地雷可使暴击伤害 ([%+%-]?%d+)%%，最多 (%d+)%%"] = function( _, num1,limit)  return { mod("CritMultiplier", "BASE", tonumber(num1), { type = "Multiplier", var = "MineDetonatedRecently", limit = tonumber(limit), limitTotal = true })   } end,
	["召唤飞掠者的魔力保留降低 (%d+)%%"] = function(num) return {  mod("ManaReserved", "INC", -num,{ type = "SkillId", skillId = "Skitterbots" })  } end,
	["配置 (.+)"] =  function(_, passive) return { mod("GrantedPassive", "LIST", passive) } end,
	["分配(.+)"] =  function(_, passive) return { mod("GrantedPassive", "LIST", passive) } end,
	["身体幻化"] = { flag("TransfigurationOfBody") },
	["躯体幻化"] = { flag("TransfigurationOfBody") },
	["心灵幻化"] = { flag("TransfigurationOfMind") },
	["灵魂幻化"] = { flag("TransfigurationOfSoul") },
	["暴击时，有 (%d+)%% 几率获得【灵巧】状态"]= function(num) return {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" })
	} end,
	["暴击时，有 (%d+)%% 的几率获得【灵巧】状态"]= function(num) return {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" })
	} end,
	["暴击时有 (%d+)%% 几率获得【灵巧】"]= function(num) return {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" })
	} end,
	["暴击时有 (%d+)%% 的几率获得【灵巧】"]= function(num) return {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" })
	} end,
	["暴击获得【灵巧】"]= function() return {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" })
	} end,
	["当你施放法术, 牺牲所有魔力，附加等同於牺牲魔力 (%d+)%% 的最大闪电伤害，持续 4 秒"] =
	function(num)  return { mod("LightningMax", "BASE", 1,
	{ type = "PerStat", stat = "ManaUnreserved", div = (100/tonumber(num))})   } end,
	["当你施放法术时，献祭所有魔力，获得等同于献祭魔力 (%d+)%% 的附加最大闪电伤害，持续 4 秒"] =
	function(num)  return { mod("LightningMax", "BASE", 1,
	{ type = "PerStat", stat = "ManaUnreserved", div = (100/tonumber(num))})   } end,
	["最大生命和最大魔力，以及全局能量护盾提高 (%d+)%%"] =
	function(num)  return {
	mod("Life", "INC", num),
	mod("Mana", "INC", num),
	mod("EnergyShield", "INC", num,{ type = "Global" } )
	} end,
	["最大生命, 魔力与全域能量护盾提高 (%d+)%%"] =
	function(num)  return {
	mod("Life", "INC", num),
	mod("Mana", "INC", num),
	mod("EnergyShield", "INC", num,{ type = "Global" } )
	} end,
	["优先使用能量护盾代替魔力消耗"] = { },
	["周围每个灵枢使你和周围队友每秒回复 ([%d%.]+)%% 能量护盾，每秒最多 ([%d%.]+)%%"] = function(num, _, limit) return { mod("ExtraAura", "LIST", { mod = mod("EnergyShieldRegenPercent", "BASE", num) }, { type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true }) } end,
	["周围每个灵枢使你和周围队友每秒回复 (%d+) 魔力，最多每秒 (%d+) 点"] = function(num, _, limit) return { mod("ExtraAura", "LIST", { mod = mod("ManaRegen", "BASE", num) }, { type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true }) } end,
	["召唤生物的最大生命总值总增 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Life", "MORE", num) })  } end,
	["近期内你若有吞噬 1 个灵柩，你和你的召唤生物的范围效果提高 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "Condition", var = "ConsumedCorpseRecently" }), mod("MinionModifier", "LIST", { mod = mod("AreaOfEffect", "INC", num) }, { type = "Condition", var = "ConsumedCorpseRecently" }) } end,
	["当周围有至少 1 个灵柩，你与周围友军的总伤害额外提高 (%d+)%%"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "MultiplierThreshold", var = "NearbyCorpse", threshold = 1 }) } end,
	["近期内，你或你的召唤生物每击败一个敌人则每秒回复你 (%d+)%% 能量护盾，每秒最多 (%d+)%%"] = function( _, num1,limit)  return { mod("EnergyShieldRegenPercent", "BASE", tonumber(num1), { type = "Multiplier", varList = {"EnemyKilledRecently","EnemyKilledByMinionsRecently"}, limit = tonumber(limit), limitTotal = true })   } end,
	["激活的先祖图腾使增益效果提高 (%d+)%%"] = function(num) return {  mod("BuffEffect", "INC", num,{ type = "SkillName", skillNameList = {  "先祖卫士", "先祖战士长","瓦尔.先祖战士长"  } })  } end,
	["新星法术的总范围效果额外缩小 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "MORE", -num,{ type = "SkillName", skillNameList = {  "冰霜新星", "瓦尔.冰霜新星 ","闪电新星", "解放","漩涡","暗夜血契","瓦尔.枯萎","震波图腾","永恒窥视","电击地面","血肉盛宴","秘术苏醒","风暴之诫","烈火之诫","雷电之诫"} })  } end,
	["新星法术的总范围效果缩小 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "MORE", -num,{ type = "SkillName", skillNameList = {  "冰霜新星", "瓦尔.冰霜新星 ","闪电新星", "解放","漩涡","暗夜血契","瓦尔.枯萎","震波图腾","永恒窥视","电击地面","血肉盛宴","秘术苏醒","风暴之诫","烈火之诫","雷电之诫"} })  } end,
	["投射物攻击近距离目标时造成的总伤害最多额外提高 30%%，但攻击远距离目标时总伤害则会额外降低"] = { flag("PointBlank") },
	["敌人对你的击中有 %-(%d+)%% 总物理伤害减伤"] = function(num) return {  mod("EnemyPhysicalDamageReduction", "BASE", -num)  }
	end,
	["敌人对抗该武器击中的总物理伤害减免 %-(%d+)%%"] = function(num) return {  mod("EnemyPhysicalDamageReduction", "BASE", -num, { type = "Condition", var = "{Hand}Attack" })  }
	end,
	["你创造的【护体】改为使总闪避值额外提高 30%%"] =  { flag("FortifyBuffInsteadGrantEvasionRating") },
	["你创造的【护体】改为使总闪避值总增 30%%"] =  { flag("FortifyBuffInsteadGrantEvasionRating") },
	["压制敌人 (%d+)%% 总物理伤害减免"] = function(num) return {  mod("EnemyPhysicalDamageReduction", "BASE", -num)  } end,
	["压制 (%d+)%% 物理伤害减免"] = function(num) return {  mod("EnemyPhysicalDamageReduction", "BASE", -num)  } end,
	["站定时，脚下产生真菌地表"] = function() return {
	flag("Condition:OnFungalGround"),
	mod("ExtraAura", "LIST",{ mod =mod("NonChaosDamageGainAsChaos", "BASE", 10), onlyAllies = true} ,{ type = "Condition", var = "OnFungalGround" }),
	mod("EnemyModifier", "LIST", { mod = mod("Damage", "MORE", -10, {type = "ActorCondition", actor = "enemy", var = "OnFungalGround"})})
	} end,
	["近期内如果没有被击中，则承受的总伤害额外降低 (%d+)%%"] = function(num) return {  mod("DamageTaken", "MORE", -num,{ type = "Condition", var = "BeenHitRecently", neg = true })  }
	end,
	["近期内如果没有被击中，则总闪避值额外降低 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", -num,{ type = "Condition", var = "BeenHitRecently", neg = true })  } end,
	["盾牌上每 (%d+) 点护甲值或闪避值都使攻击伤害提高 (%d+)%%"]= function(_,num1,num2) return {  mod("Damage", "INC", tonumber(num2),{ type = "PerStat", stat = "EvasionOnWeapon 2", div = tonumber(num1) } ),
	mod("Damage", "INC", tonumber(num2),{ type = "PerStat", stat = "ArmourOnWeapon 2", div = tonumber(num1) } )
	}end,
	["盾牌上每有 (%d+) 点最大能量护盾，就 %+(%d+)%% 暴击伤害加成"]= function(_,num1,num2) return {  mod("CritMultiplier", "BASE", tonumber(num2),{ type = "PerStat", stat = "EnergyShieldOnWeapon 2", div = tonumber(num1) } )  }end,
	["若你已经持续吟唱至少 1 秒,则 %+(%d+)%% 暴击伤害"]= function(num) return {  mod("CritMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "OnChannelling" } )  }end,
	["若你近期内至少持续吟唱 1 秒，则 %+(%d+)%% 暴击伤害加成"]= function(num) return {  mod("CritMultiplier", "BASE", tonumber(num),{ type = "Condition", var = "OnChannelling" } )  }end,
	["持锤, 短杖或长杖时有 (%d+)%% 几率造成双倍伤害"] = function(num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "Condition", varList = { "UsingMace", "UsingStaff" } } )  }end,
	["持锤, 短杖或长杖时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return {  mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "Condition", varList = { "UsingMace", "UsingStaff" } } )  }end,
	["法杖攻击有 (%d+)%% 的物理伤害转换为闪电伤害"] = function(num) return {  mod("PhysicalDamageConvertToLightning", "BASE", num,nil, ModFlag.Wand)  } end,
	["无法造成点燃，冰缓，冰冻或感电"]  = { flag("CannotFreeze"), flag("CannotChill"),flag("CannotIgnite"),flag("CannotShock") },
	["攻击投射物必定造成流血和瘫痪，和击退敌人"] =function() return {
	mod("BleedChance", "BASE", 100, nil,  bor(ModFlag.Projectile, ModFlag.Attack)),
	mod("EnemyKnockbackChance", "BASE", 100, nil,  bor(ModFlag.Projectile, ModFlag.Attack)),
	mod("EnemyModifier", "LIST", { mod = mod("Condition:Maimed", "FLAG", true) }, nil,  bor(ModFlag.Projectile, ModFlag.Attack)),
	} end,
	["投射物无法穿透, 分裂或连锁"]  = { flag("CannotPierce", nil, ModFlag.Projectile), flag("CannotFork", nil, ModFlag.Projectile),flag("CannotChain", nil, ModFlag.Projectile) },
	["若近期有击败敌人，则每秒回复 (%d+)%% 能量护盾"] = function(num) return {  mod("EnergyShieldRegenPercent", "BASE", num,{ type = "Condition", var = "KilledRecently" })  } end,
	["你若近期内击败过敌人，则每秒回复 (%d+)%% 能量护盾"] = function(num) return {  mod("EnergyShieldRegenPercent", "BASE", num,{ type = "Condition", var = "KilledRecently" })  } end,
	["每个聚光之石都使暴击率提高 (%d+)%%"] = function(num) return {
	mod("CritChance", "INC", num, { type = "Multiplier", var = "GrandSpectrum" }),
	mod("Multiplier:GrandSpectrum", "BASE", 1)
	} end,
	["每 1 个聚光之石可使暴击几率提高 (%d+)%%"] = function(num) return {
	mod("CritChance", "INC", num, { type = "Multiplier", var = "GrandSpectrum" }),
	mod("Multiplier:GrandSpectrum", "BASE", 1)
	} end,
	["每 1 个聚光之石获得 %+(%d+)%% 元素抗性"] = function(num) return {
	mod("ElementalResist", "BASE", num, { type = "Multiplier", var = "GrandSpectrum" }),
	mod("Multiplier:GrandSpectrum", "BASE", 1)
	} end,
	["每个聚光之石都 %+(%d+)%% 所有元素抗性"] = function(num) return {
	mod("ElementalResist", "BASE", num, { type = "Multiplier", var = "GrandSpectrum" }),
	mod("Multiplier:GrandSpectrum", "BASE", 1)
	} end,
	["每 1 个聚光之石可使元素伤害提高 (%d+)%%"] = function(num) return {  --备注：(%d+)%% increased elemental damage per grand spectrum
	mod("ElementalDamage", "INC", num, { type = "Multiplier", var = "GrandSpectrum" }),
	mod("Multiplier:GrandSpectrum", "BASE", 1)
	} end,
	["持法杖时，对法术伤害的增幅与减益也套用于攻击"] = {
	flag("SpellDamageAppliesToAttacks",{ type = "Condition", var = "UsingWand" }),
	mod("ImprovedSpellDamageAppliesToAttacks", "INC", 100,{ type = "Condition", var = "UsingWand" }) },
	["increases and reductions to cast speed apply to attack speed at (%d+)%% of their value"] =  function(num) return { flag("CastSpeedAppliesToAttacks"), mod("ImprovedCastSpeedAppliesToAttacks", "INC", num) } end,
	["对法术伤害的增幅与减益也会套用于攻击上"] = { flag("SpellDamageAppliesToAttacks"), mod("ImprovedSpellDamageAppliesToAttacks", "INC", 100) },
	["对法术伤害的增幅与减益也套用于攻击，等于其数值的 (%d+)%%"] = function(num) return { flag("SpellDamageAppliesToAttacks"), mod("ImprovedSpellDamageAppliesToAttacks", "INC", num) } end,
	["对法术伤害的增幅与减益也会套用于攻击上，相当于其效果的 (%d+)%%"] = function(num) return { flag("SpellDamageAppliesToAttacks"), mod("ImprovedSpellDamageAppliesToAttacks", "INC", num) } end,
	["你的光环技能被禁用"] = { flag("DisableSkill", { type = "SkillType", skillType = SkillType.Aura}) },
	["你禁用光环技能"] = { flag("DisableSkill", { type = "SkillType", skillType = SkillType.Aura}) },
	["你身上的捷增益总效果总增 (%d+)%%"] = function(num) return {
	mod("BuffEffect", "MORE", num, { type = "SkillType", skillType = SkillType.Herald }),
	} end,
	["捷技能的总击中伤害总增 (%d+)%%"] = function(num) return {
	mod("Damage", "MORE", num,nil, ModFlag.Hit, { type = "SkillType", skillType = SkillType.Herald }),
	} end,
	["捷技能的总持续伤害总增 (%d+)%%"] = function(num) return {
	mod("Damage", "MORE", num,nil, ModFlag.Dot, { type = "SkillType", skillType = SkillType.Herald }),
	} end,
	["捷技能的召唤生物的伤害总增 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "MORE", num )}, { type = "SkillType", skillType = SkillType.Herald })  } end,
	["每 (%d+) 智慧使冰霜伤害提高 (%d+)%%"] =function(_,num1,num2) return {  mod("ColdDamage", "INC", tonumber(num2),{ type = "PerStat", stat = "Int", div = tonumber(num1) })  } end,
	["每 (%d+) 力量使冰霜伤害提高 (%d+)%%"] =function(_,num1,num2) return {  mod("ColdDamage", "INC", tonumber(num2),{ type = "PerStat", stat = "Str", div = tonumber(num1) })  } end,
	["每 (%d+) 敏捷使冰霜伤害提高 (%d+)%%"] =function(_,num1,num2) return {  mod("ColdDamage", "INC", tonumber(num2),{ type = "PerStat", stat = "Dex", div = tonumber(num1) })  } end,
	["持爪或匕首时，攻击技能发射一个额外的投射物"]=  function() return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", 1,{ type = "SkillType", skillType = SkillType.Attack }) },  { type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } ) } end,
	["爪或匕首攻击时，([%+%-]?%d+)%% 暴击伤害"] = function(num) return {  mod("CritMultiplier", "BASE", num,nil, ModFlag.Hit,{ type = "ModFlagOr", modFlags = bor(ModFlag.Claw, ModFlag.Dagger) } )  } end,
	["对被嘲讽敌人, ([%+%-]?%d+)%% 暴击伤害"] = function(num) return { mod("CritMultiplier", "BASE", num,{ type = "ActorCondition", actor = "enemy", var = "Taunted" }) } end,
	["【两手空空】状态下视为双持"] = function() return {  mod("Condition:DualWielding", "FLAG", true,{ type = "Condition", var = "Unencumbered" })  } end,
	["【两手空空】状态下总攻击速度额外提高 (%d+)%%"] =function(num) return {  mod("Speed", "MORE", tonumber(num),nil,ModFlag.Attack,{ type = "Condition", var = "Unencumbered" })  } end,
	["【两手空空】状态下每 (%d+) 点敏捷附加 (%d+) %- (%d+) 攻击物理伤害"] =function(_,num1,num2,num3) return {  mod("PhysicalMax", "BASE", tonumber(num3),{ type = "PerStat", stat = "Dex", div = tonumber(num1) },{ type = "Condition", var = "Unencumbered" }),
	mod("PhysicalMin", "BASE", tonumber(num2),{ type = "PerStat", stat = "Dex", div = tonumber(num1) },{ type = "Condition", var = "Unencumbered" }),  } end,
	["受到你诅咒的敌人承受的伤害提高 (%d+)%%"] = function(num) return { mod("AffectedByCurseMod", "LIST", { mod = mod("DamageTaken", "INC", num) }) } end,
	["每保留有 1 次连锁，则投射物伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil, ModFlag.Projectile, { type = "PerStat", stat = "ChainRemaining" }) } end,
	["面对被诅咒的敌人，有 (%d+)%% 几率躲避攻击击中"] = function(num) return { mod("AttackDodgeChance", "BASE",num,  { type = "ActorCondition", actor = "enemy", var = "Cursed" } ) } end,
	["对被诅咒的敌人有 (%d+)%% 几率躲避攻击"] = function(num) return { mod("AttackDodgeChance", "BASE",num,  { type = "ActorCondition", actor = "enemy", var = "Cursed" } ) } end,
	["面对被诅咒的敌人，有 (%d+)%% 的几率躲避攻击击中"] = function(num) return { mod("AttackDodgeChance", "BASE",num,  { type = "ActorCondition", actor = "enemy", var = "Cursed" } ) } end,
	["对被诅咒的敌人有 (%d+)%% 的几率躲避攻击"] = function(num) return { mod("AttackDodgeChance", "BASE",num,  { type = "ActorCondition", actor = "enemy", var = "Cursed" } ) } end,
	["诅咒技能石降低 (%d+)%% 魔力保留"]=function(num) return {  mod("ManaReserved", "INC", -num,nil,nil,KeywordFlag.Curse  )  } end,
	["诅咒技能的魔力保留降低 (%d+)%%"]=function(num) return {  mod("ManaReserved", "INC", -num,nil,nil,KeywordFlag.Curse  )  } end,
	["近期内你若有击败受到诅咒的敌人，则伤害提高 (%d+)%%"]= function(num) return { mod("Damage", "INC",num, { type = "Condition", var = "KilledRecently" }, { type = "ActorCondition", actor = "enemy", var = "Cursed" } ) } end,
	["从你职业的出发位置到该珠宝槽之间\n每一点配置的天赋就使该珠宝插槽的效果提高 (%d+)%%"] = function(num) return { mod("JewelData", "LIST", { key = "jewelIncEffectFromClassStart", value = num }) } end,
	["从你职业的出发位置到该珠宝槽之间每一点配置的天赋就使该珠宝插槽的效果提高 (%d+)%%"] = function(num) return { mod("JewelData", "LIST", { key = "jewelIncEffectFromClassStart", value = num }) } end,
	["每一点配置的天赋就使该珠宝插槽的效果提高 (%d+)%%"] = function(num) return { mod("JewelData", "LIST", { key = "jewelIncEffectFromClassStart", value = num }) } end,
	["你技能的非诅咒类光环效果提高 (%d+)%%"]= function(num) return {  mod("AuraEffect", "INC", tonumber(num),{ type = "SkillType", skillType = SkillType.Aura }, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true } )  } end,
	["每受到一个捷技能影响，你身上的来自光环技能的增益效果提高 (%d+)%%"] =function(num) return {  mod("AuraEffectOnSelf", "INC", num,nil,nil,KeywordFlag.Aura,{ type = "Multiplier", var = "AffectedByHeraldCount" }  )  } end,
	["每有一个影响你的捷效果都使你身上来自技能的光环增益效果提高 (%d+)%%"] =function(num) return {  mod("AuraEffectOnSelf", "INC", num,nil,nil,KeywordFlag.Aura,{ type = "Multiplier", var = "AffectedByHeraldCount" }  )  } end,
	["你的光环技能对自身造成的总效果额外提高 (%d+)%%"]= function(num) return {
	mod("SkillAuraEffectOnSelf", "MORE", num,nil,nil,KeywordFlag.Aura)
	} end,
	["召唤生物身上的光环效果提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("AuraEffectOnSelf", "INC", num) })  } end,
	["召唤生物身上的来自你技能的光环效果提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("AuraEffectOnSelf", "INC", num, num,nil,nil,KeywordFlag.Aura) })  } end,
	["最近8秒内你若有使用战吼，则获得 (%d+)%% 额外物理伤害减伤"]= function(num) return { mod("PhysicalDamageReduction", "BASE", num, { type = "Condition", var = "UsedWarcryInPast8Seconds" } ) } end,
	["命中值提高 (%d+)%%"]= function(num) return { mod("Accuracy", "INC", num,{ type = "Global" } ) } end,
	["近期内你若有使用战吼，([%+%-]?%d+)%% 近战暴击伤害"]= function(num) return { mod("CritMultiplier", "BASE", num,nil,ModFlag.Melee , { type = "Condition", var = "UsedWarcryRecently" } ) } end,
	["你和周围友军的暴击几率提高 (%d+)%%"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("CritChance", "INC", num) }) ,
	} end,
	["你和周围友军 ([%+%-]?%d+)%% 暴击伤害"] = function(num) return {
	mod("ExtraAura", "LIST", { mod =  mod("CritMultiplier", "BASE", num) }) ,
	} end,
	["旗帜技能的魔力保留降低 (%d+)%% "]=function(num) return {  mod("ManaReserved", "INC", -num,{ type = "SkillName", skillNameList = { "恐怖之旗", "战旗" } } )  } end,
	["旗帜技能的魔力保留降低 (%d+)%%"]=function(num) return {  mod("ManaReserved", "INC", -num,{ type = "SkillName", skillNameList = { "恐怖之旗", "战旗" } } )  } end,
	["伤害型异常状态生效速度加快 (%d+)%%"]= function(num) return {
	mod("PoisonFaster", "INC", tonumber(num)) ,
	mod("IgniteBurnFaster", "INC", tonumber(num)) ,
	mod("BleedFaster", "INC", tonumber(num)) ,
	} end,
	["异常造成的伤害的消失速度加快 (%d+)%%"]= function(num) return {
	mod("PoisonFaster", "INC", tonumber(num)) ,
	mod("IgniteBurnFaster", "INC", tonumber(num)) ,
	mod("BleedFaster", "INC", tonumber(num)) ,
	} end,
	["箭矢飞得越远，暴击率越高，暴击率最多提高 (%d+)%%"] = function(num) return { mod("CritChance", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile,ModFlag.Bow), { type = "DistanceRamp", ramp = {{35,0},{70,1}} }) } end,
	["箭矢投射物的暴击几率随着飞行距离提升，击中目标时最多提高 (%d+)%%"] = function(num) return { mod("CritChance", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile,ModFlag.Bow), { type = "DistanceRamp", ramp = {{35,0},{70,1}} }) } end,
	["箭矢的伤害随着飞行距离提升，击中目标时最多提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile,ModFlag.Bow), { type = "DistanceRamp", ramp = {{35,0},{70,1}} }) } end,
	["箭矢飞得越远，伤害越高，击中目标最多使伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile,ModFlag.Bow), { type = "DistanceRamp", ramp = {{35,0},{70,1}} }) } end,
	["持斧或剑时，([%+%-]?%d+)%% 物理持续伤害加成"] = function(num) return { mod("PhysicalDotMultiplier", "BASE", num,{ type = "Condition", varList ={ "UsingAxe", "UsingSword" }}) } end,
	["持斧类或剑类时，([%+%-]?%d+)%% 持续物理伤害加成"] = function(num) return { mod("PhysicalDotMultiplier", "BASE", num,{ type = "Condition", varList ={ "UsingAxe", "UsingSword" }}) } end,
	["斧或剑攻击击中有 (%d+)%% 几率穿刺敌人"] = function(num) return { mod("ImpaleChance", "BASE", num, { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) }) } end,
	["斧或剑攻击击中有 (%d+)%% 的几率穿刺敌人"] = function(num) return { mod("ImpaleChance", "BASE", num, { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) }) } end,
	["斧类或剑类击中有 (%d+)%% 的几率【穿刺】敌人"] = function(num) return { mod("ImpaleChance", "BASE", num, { type = "ModFlagOr", modFlags = bor(ModFlag.Axe, ModFlag.Sword) }) } end,
	["斧类攻击造成的击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil,ModFlag.Axe,bor(KeywordFlag.Hit, KeywordFlag.Ailment)) } end,
	["剑类攻击造成的击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil,ModFlag.Sword,bor(KeywordFlag.Hit, KeywordFlag.Ailment)) } end,
	["锤类或短杖攻击造成的击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, nil,ModFlag.Mace,bor(KeywordFlag.Hit, KeywordFlag.Ailment)) } end,
	["%+(%d+) 武器范围"]= function(num) return {  mod("MeleeWeaponRange", "BASE", num )  } end,
	["被你穿刺的敌人对穿刺伤害有获得 %-(%d+)%% 总物理伤害减伤"] = function(num) return {
	mod("EnemyImpalePhysicalDamageReduction", "BASE", -num)
	} end,
	["你造成的穿刺伤害压制敌人 (%d+)%% 总物理伤害减免"] = function(num) return {
	mod("EnemyImpalePhysicalDamageReduction", "BASE", -num)
	} end,
	["你对已穿刺的敌人造成的穿刺伤害压制 (%d+)%% 物理伤害减免"] = function(num) return {
	mod("EnemyImpalePhysicalDamageReduction", "BASE", -num)
	} end,
	["双手武器攻击击中时有 (%d+)%% 几率穿刺敌人"] = function(num) return { mod("ImpaleChance", "BASE", num,nil, ModFlag.Weapon2H) } end,
	["双手武器攻击击中时有 (%d+)%% 的几率穿刺敌人"] = function(num) return { mod("ImpaleChance", "BASE", num,nil, ModFlag.Weapon2H) } end,
	["用双手武器击中时，有 (%d+)%% 的几率穿刺敌人"] = function(num) return { mod("ImpaleChance", "BASE", num,nil, ModFlag.Weapon2H) } end,
	["你用双手武器施加的穿刺效果提高 (%d+)%%"] = function(num) return { mod("ImpaleEffect", "INC", num, nil, ModFlag.Weapon2H) } end,
	["穿刺持续时间延长 (%d+)%%"] = function(num) return { mod("ImpaleDuration", "INC", num) } end,
	["【召唤纯净哨兵】的技能冷却速度提高 (%d+)%%"] = function(num) return {
	mod("MinionModifier", "LIST", { mod = mod("CooldownRecovery", "INC", num) }, { type = "SkillId", skillId = "HeraldOfPurity" })   } end,
	["在任何生命药剂作用时间内，获得护体效果"] = { flag("Condition:Fortify",{ type = "Condition", var = "UsingLifeFlask" } ) },
	["护体"] = { flag("Condition:Fortify" ) },
	-- 友军问题 暂时不解析
	-- ["周围友军击中造成的伤害特别幸运"] = { mod("ExtraAura", "LIST", { onlyAllies = true, mod = mod("LuckyHits", "FLAG", true) }) },
	["非暴击造成的闪电伤害特别幸运"] = { flag("LightningNoCritLucky") },
	["非暴击造成的闪电伤害是幸运的"] = { flag("LightningNoCritLucky") },
	["每受到一个捷技能影响，召唤生物的移动速度提高 (%d+)%%"]
	= function(num) return { mod("MinionModifier", "LIST", {
	mod = mod("MovementSpeed", "INC", num, { type = "Multiplier", var = "AffectedByHeraldCount", actor = "parent" }) }) } end,
	["你受捷影响时，召唤生物的伤害提高 (%d+)%%"] = function(num) return {
	mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num,
	{ type = "ActorCondition", actor = "parent", var = "AffectedByHerald" }) }) } end,
	["你受到捷技能影响时，召唤生物的伤害提高 (%d+)%%"] = function(num) return {
	mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num,
	{ type = "ActorCondition", actor = "parent", var = "AffectedByHerald" }) }) } end,
	["每个召唤的魔像可使它们为你提供的增益效果提高 (%d+)%%"] = function(num) return {
	mod("BuffEffect", "INC", num,{ type = "SkillType", skillType = SkillType.Golem } , { type = "PerStat", stat = "ActiveGolemLimit" } )
	} end,
	["每个召唤的魔像可使它们为你提供的增益效果提高 (%d+)%%"] = function(num) return {
	mod("BuffEffect", "INC", num,{ type = "SkillType", skillType = SkillType.Golem } , { type = "PerStat", stat = "ActiveGolemLimit" } )
	} end,
	["每个召唤出的魔像可使魔像伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) },
	{ type = "SkillType", skillType = SkillType.Golem }, { type = "PerStat", stat = "ActiveGolemLimit" }) } end,
	["每个召唤的魔像可使伤害提高 (%d+)%%"] = function(num) return {
	mod("Damage", "INC", num, { type = "PerStat", stat = "ActiveGolemLimit" } )
	} end,
	["当你有召唤的魔像存在时，伤害提高 (%d+)%%"] = function(num) return {
	mod("Damage", "INC", num,{ type = "Condition", varList = { "HavePhysicalGolem", "HaveLightningGolem", "HaveColdGolem", "HaveFireGolem", "HaveChaosGolem", "HaveCarrionGolem" } }  )
	} end,
	["击中时有 (%d+)%% 机率造成凋零，持续 (%d+) 秒"] = function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["击中有 (%d+)%% 几率施加【枯萎】，持续 (%d+) 秒"] = function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["击中有 (%d+)%% 的几率施加【枯萎】，持续 (%d+) 秒"] = function(num) return {
	flag("Condition:CanWither"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" })
	} end,
	["你对敌人造成的每个凋零使其承受的击中元素伤害提高 (%d+)%%"] = function(num) return {
	mod("ExtraSkillMod", "LIST", {
	mod = mod("ElementalDamageTaken", "INC", tonumber(num),
	{ type = "GlobalEffect", effectType = "Debuff", effectName = "死亡凋零", effectStackVar = "WitheredStack" }) }) } end,
	["给敌人施加的每个【枯萎】都使它们从你的击中中受到的元素伤害提高 (%d+)%%"] = function(num) return {
	mod("ExtraSkillMod", "LIST", {
	mod = mod("ElementalDamageTaken", "INC", tonumber(num),
	{ type = "GlobalEffect", effectType = "Debuff", effectName = "死亡凋零", effectStackVar = "WitheredStack" }) }) } end,
	["你的击中无法穿透或忽视元素抗性"] = { flag("CannotIgnoreElementalResistances"),flag("CannotElementalPenetration")},
	["你的击中无法穿透或无视元素抗性"] = { flag("CannotIgnoreElementalResistances"),flag("CannotElementalPenetration")},
	["无法造成非闪电伤害"] = {  flag("DealNoCold"), flag("DealNoFire"), flag("DealNoPhysical"), flag("DealNoChaos")},
	["不造成非闪电伤害"] = {  flag("DealNoCold"), flag("DealNoFire"), flag("DealNoPhysical"), flag("DealNoChaos")},
	["周围敌人的闪电抗性等同于你"] = {
	flag("LightningResistIsEnemy")
	},
	["周围敌人的闪电抗性等同于你的闪电抗性"] = {
	flag("LightningResistIsEnemy")
	},
	["用该武器击中时，获得额外冰霜或闪电伤害，其数值等同于物理伤害的 (%d+)%%"]= function(num) return {
	mod("PhysicalDamageGainAsCold", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementCold" }),
	mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num), nil, ModFlag.Weapon,{ type = "Condition", var = "PhysicsRandomElementLightning" }),
	} end,
	["击中流血敌人时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：triggers? level (%d+) (.+) when you kill a bleeding enemy
	["当召唤生物有能量护盾时，它们的击中无视怪物的元素抗性"] = function() return {
	mod("MinionModifier", "LIST", { mod = flag("IgnoreElementalResistances",{ type = "StatThreshold", stat = "EnergyShield", threshold = 1 } ) })  } end,
	["召唤生物有能量护盾时，它们的击中无视怪物的元素抗"] = function() return {
	mod("MinionModifier", "LIST", { mod = flag("IgnoreElementalResistances",{ type = "StatThreshold", stat = "EnergyShield", threshold = 1 } ) })  } end,
	["召唤生物的能量护盾提前 (%d+)%% 开始回复"] = function(_,num) return
	{ mod("MinionModifier", "LIST", { mod =  mod("EnergyShieldRechargeFaster", "INC", tonumber(num)	)  })  } end,
	["召唤生物每有 (%d+)%% 混沌抗性，转换 (%d+)%% 最大生命为最大能量护盾"] = function(_,num1,num2) return
	{ mod("MinionModifier", "LIST", { mod =  mod("LifeConvertToEnergyShield", "BASE", tonumber(num2)
	,{ type = "PerStat", stat = "ChaosResist", div = tonumber(num1) }
	)  })  } end,
	["召唤生物每有 (%d+)%% 混沌抗性就将其 (%d+)%% 最大生命转化为最大能量护盾"] = function(_,num1,num2) return
	{ mod("MinionModifier", "LIST", { mod =  mod("LifeConvertToEnergyShield", "BASE", tonumber(num2)
	,{ type = "PerStat", stat = "ChaosResist", div = tonumber(num1) }
	)  })  } end,
	["每受到一个捷技能影响，你身上的光环技能的效果提高 (%d+)%%，最多提高 (%d+)%%"] = function(num, _, limit) return {
	mod("PurpHarbAuraBuffEffect", "INC", num, { type = "Multiplier", var = "AffectedByHeraldCount" })
	-- Maximum buff effect is handled in CalcPerform, PurpHarbAuraBuffEffect is capped with a constant there.
	} end,
	["每消耗 1 具灵柩后的短时间内，攻击和施法速度提高 (%d+)%%，最多提高 (%d+)%%"] = function(_,num1,num2) return {
	mod("Speed", "INC", tonumber(num1),  { type = "Multiplier", var = "CorpseConsumedRecently"  ,
	limit = tonumber(num2), limitTotal = true} )
	} end,
	["若近期你没有被击中，闪避值提高 (%d+)%%"] = function(num) return {
	mod("Evasion", "INC", num,{ type = "Condition", var = "BeenHitRecently", neg = true })  } end,
	["每 (%d+) 点未保留的最大魔力 %+(%d+) 护甲"] = function( _, num1,num2)  return { mod("Armour", "BASE",
	tonumber(num2), { type = "PerStat", stat = "ManaUnreserved", div = tonumber(num1) })   } end,
	["近期内你若有吞噬 1 个灵柩，则每秒回复 ([%d%.]+)%% 最大生命"] = function(num) return { mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "ConsumedCorpseRecently" }) } end,
	["近期内你若没有被击中，则总承受的伤害额外降低 (%d+)%%"] = function(num) return {  mod("DamageTaken", "MORE", -num,{ type = "Condition", var = "BeenHitRecently", neg = true })  }
	end,
	["近期内你若没有被击中，则总闪避值额外降低 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", -num,{ type = "Condition", var = "BeenHitRecently", neg = true })  } end,
	["近期内你若有被击中，则总闪避值额外提高 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num,
	{ type = "Condition", var = "BeenHitRecently"})  } end,
	["如果近期内被击中，则闪避值总增(%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num, { type = "Condition", var = "BeenHitRecently"}) } end,
	["投射物在飞行开始时击中目标的伤害提高 (%d+)%%，并随飞行距离逐渐衰减为 0%%"]
	= function(num) return { mod("Damage", "INC", num, nil, ModFlag.Projectile, { type = "DistanceRamp", ramp = {{35,1},{70,0}} }) } end,
	["你和周围友军每秒回复 ([%d%.]+)%% 生命"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) }) } end,
	["因你而中毒的敌人 (%-%d+)%% 混沌抗性"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num) },
	{ type = "ActorCondition", actor = "enemy", var = "Poisoned"}) } end,
	["被诅咒时你近战攻击击中一个敌人，触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：trigger level (%d+) (.+) when you hit an enemy while cursed
	["被诅咒的情况下，近战击中触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：trigger level (%d+) (.+) when you hit an enemy while cursed
	["【(.+)】每次连锁，总伤害额外提高 (%d+)%%"] = function(   _1,skill_name,num,_0) return {
	mod("Damage", "MORE", tonumber(num), { type = "PerStat", stat = "Chain" },{ type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["【(.+)】的总伤害额外降低 (%d+)%%"] = function(   _1,skill_name,num,_0) return {
	mod("Damage", "MORE", tonumber(-num),{ type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["偷取每秒总恢复量提高 (%d+)%%"] = function(num) return {
	mod("LifeLeechRate", "INC", num),
	mod("ManaLeechRate", "INC", num),
	mod("EnergyShieldLeechRate", "INC", num)
	} end,
	["充能次数减少 (%d+)%%"]= function(num) return {
	mod("FlaskChargesUsed", "INC", -num )
	} end,
	["【召唤魔侍】有 %+(%d+) 秒冷却时间"]= function(num) return {
	mod("CooldownRecovery", "OVERRIDE", num, { type = "SkillName", skillNameList = { "召唤魔侍"} })
	} end,
	["%+(%d+) 近战打击范围"]= function(num) return {
	mod("MeleeWeaponRange", "BASE", num ) ,
	mod("UnarmedRange", "BASE", num )
	} end,
	["你若近期内击败过敌人，%+(%d+) 近战打击范围"]= function(num) return {
	mod("MeleeWeaponRange", "BASE", num,{ type = "Condition", var = "KilledRecently" } ) ,
	mod("UnarmedRange", "BASE", num,{ type = "Condition", var = "KilledRecently" } )
	} end,
	["战吼技能冷却时间为 (%d+) 秒"]= function(num) return {
	mod("CooldownRecovery", "OVERRIDE", num, nil, 0, KeywordFlag.Warcry)
	} end,
	["你至少有 (%d+) 点怒火时，周围敌人被压垮"]= function(num) return {
	mod("EnemyPhysicalDamageReduction", "BASE", -15, { type = "GlobalEffect", effectType = "Debuff", effectName = "压垮" },
	{ type = "MultiplierThreshold", var = "Rage", threshold = tonumber(num) })} end,
	["每 (%d+) 点怒火使物理伤害提高 (%d+)%%"]= function(_,num1,num2) return {
	mod("PhysicalDamage", "INC", tonumber(num2),{ type = "Multiplier", var = "Rage", div = tonumber(num1) } )  } end,
	["血姿态下获得 (%d+) 每秒生命回复"]= function(num) return {
	mod("LifeRegen", "BASE", num, { type = "Condition", var = "BloodStance" } )  } end,
	["血姿态下，投射物伤害提高 (%d+)%%"]= function(num) return {
	mod("Damage", "INC", num, nil, ModFlag.Projectile, { type = "Condition", var = "BloodStance" } )  } end,
	["沙姿态下 %+(%d+) 闪避值"]= function(num) return {
	mod("Evasion", "BASE", num, { type = "Condition", var = "SandStance" } )  } end,
	["沙姿态下，范围效果扩大 (%d+)%%"]= function(num) return {
	mod("AreaOfEffect", "INC", num, { type = "Condition", var = "SandStance" } )  } end,
	["获得【召唤高等不屈先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfFocusUber"})   } end,
	["获得【召唤高等射术先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfDirectionsUber"})   } end,
	["获得【召唤高等秘法先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfTheArcaneUber"})   } end,
	["获得【召唤高等冰雷先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfStormsUber"})   } end,
	["获得【召唤高等时空先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfTimeUber"})   } end,
	["获得【召唤高等残暴先驱者】"]= function(num) return {  mod("ExtraSkill", "LIST", { skillId ="SummonHarbingerOfBrutalityUber"})   } end,
	["你在【护体】状态下 %+(%d+) 护甲"]= function(num) return {
	mod("Armour", "BASE", num, { type = "Condition", var = "Fortify" } )  } end,
	["你在【迷踪】状态下 %+(%d+) 闪避值"]= function(num) return {
	mod("Evasion", "BASE", num, { type = "Condition", var = "Phasing" } )  } end,
	["你在【灵巧】状态下，有 (%d+)%% 几率避免元素异常状态"]= function(num) return {
	mod("AvoidShock", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidFrozen", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidChilled", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidIgnite", "BASE", num, { type = "Condition", var = "Elusive" } ),
	} end,
	["你在【灵巧】状态下，有 (%d+)%% 的几率避免元素异常状态"]= function(num) return {
	mod("AvoidShock", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidFrozen", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidChilled", "BASE", num, { type = "Condition", var = "Elusive" } ),
	mod("AvoidIgnite", "BASE", num, { type = "Condition", var = "Elusive" } ),
	} end,
	["在【奉献地面】上，你身上的诅咒效果降低 (%d+)%%"]= function(num) return {
	mod("CurseEffectOnSelf", "INC", -num, { type = "Condition", var = "OnConsecratedGround" } )  } end,
	["你具有【猛攻】的情况下，命中值提高 (%d+)%%"]= function(num) return {
	mod("Accuracy", "INC", num, { type = "Condition", var = "Onslaught" } )  } end,
	["被你瘫痪的敌人受到的持续伤害提高 (%d+)%%"] = function(num) return { 
	mod("EnemyModifier", "LIST", { mod = mod("DamageTakenOverTime", "INC", num, { type = "Condition", var = "Maimed" }) })
	 } end, 
	["%-(%d+)%% 最大元素抗性"]= function(num) return {
	mod("FireResistMax", "BASE", -num),
	mod("ColdResistMax", "BASE", -num),
	mod("LightningResistMax", "BASE", -num),
	} end,
	["召集部队"] = { mod("Keystone", "LIST", "召集部队") },
	["【斗转星移】"] = { mod("Keystone", "LIST", "斗转星移") },
	["钢铁意志"] = { flag("IronWill") },
	["品质不提高物理伤害"] = { mod("AlternateQualityWeapon", "BASE", 1) },
	["每 (%d+)%% 品质使效果区域扩大 (%d+)%%"] = function(_,div, num) return { mod("AreaOfEffect", "INC", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 4%% 品质使暴击率提高 (%d+)%%"] = function(num) return { mod("AlternateQualityLocalCritChancePer4Quality", "INC", num) } end,
	["每 (%d+)%% 品质使命中值提高提高 (%d+)%%"] = function( _,div, num) return { mod("Accuracy", "INC", num,  { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质使命中值提高 (%d+)%%"] = function( _,div, num) return { mod("Accuracy", "INC", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 8%% 品质使攻击速度加快 (%d+)%%"] = function(num) return { mod("AlternateQualityLocalAttackSpeedPer8Quality", "INC", num) } end,
	["每 10%% 品质 %+(%d+) 武器范围"] = function(num) return { mod("AlternateQualityLocalWeaponRangePer10Quality", "BASE", num) } end,
	["每 (%d+)%% 品质使元素伤害提高 (%d+)%%"] = function( _,div, num) return { mod("ElementalDamage", "INC", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质使范围效果扩大 (%d+)%%"] = function(_,div, num) return { mod("AreaOfEffect", "INC", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["品质不提高防御属性"] = { mod("AlternateQualityArmour", "BASE", 1) },
	["每 (%d+)%% 品质 %+(%d+) 最大生命"] = function(_,div, num) return { mod("Life", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+) 最大魔力"] = function(_,div, num) return { mod("Mana", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+) 力量"] = function(_,div, num) return { mod("Str", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+) 敏捷"] = function(_,div, num) return { mod("Dex", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+) 智慧"] = function(_,div, num) return { mod("Int", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+)%% 火焰抗性"] = function(_,div, num) return { mod("FireResist", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+)%% 冰霜抗性"] = function(_,div, num) return { mod("ColdResist", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["每 (%d+)%% 品质 %+(%d+)%% 闪电抗性"] = function(_,div, num) return { mod("LightningResist", "BASE", num, { type = "Multiplier", var = "QualityOn{SlotName}", div = tonumber(div) }) } end,
	["被击中时有 (%d+)%% 几率避免火焰伤害"]= function(num) return {
	mod("AvoidFireDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 几率避免冰霜伤害"]= function(num) return {
	mod("AvoidColdDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 几率避免闪电伤害"]= function(num) return {
	mod("AvoidLightningDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 几率避免物理伤害"]= function(num) return {
	mod("AvoidPhysicalDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 几率避免混沌伤害"]= function(num) return {
	mod("AvoidChoasDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 几率避免元素伤害"]= function(num) return {
	mod("AvoidFireDamageChance", "BASE", num ) ,
	mod("AvoidColdDamageChance", "BASE", num ) ,
	mod("AvoidLightningDamageChance", "BASE", num ) ,
	} end,
	["被击中时有 (%d+)%% 几率避免投射物伤害"]= function(num) return {
	mod("AvoidProjectilesChance", "BASE", num ) ,
	} end,
	["被击中时有 (%d+)%% 的几率避免火焰伤害"]= function(num) return {
	mod("AvoidFireDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免冰霜伤害"]= function(num) return {
	mod("AvoidColdDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免闪电伤害"]= function(num) return {
	mod("AvoidLightningDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免物理伤害"]= function(num) return {
	mod("AvoidPhysicalDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免混沌伤害"]= function(num) return {
	mod("AvoidChoasDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免元素伤害"]= function(num) return {
	mod("AvoidFireDamageChance", "BASE", num ) ,
	mod("AvoidColdDamageChance", "BASE", num ) ,
	mod("AvoidLightningDamageChance", "BASE", num ) ,
	} end,
	["被击中时有 (%d+)%% 的几率避免投射物伤害"]= function(num) return {
	mod("AvoidProjectilesChance", "BASE", num ) ,
	} end,
	["被击中时 (%d+)%% 的闪电伤害优先从魔力优先扣除"]= function(num) return {
	mod("LightningDamageTakenFromManaBeforeLife", "BASE", num ) ,
	} end,
	["混沌伤害不能穿透能量护盾"] = { flag("ChaosNotBypassEnergyShield") },
	["承受的混沌伤害优先从魔力扣除"] = function() return { mod("ChaosDamageTakenFromManaBeforeLife", "BASE", 100) } end,
	["不会承受反射的元素伤害"] = { mod("ElementalReflectedDamageTaken", "MORE", -100) },
	["不会承受反射的物理伤害"] = { mod("PhysicalReflectedDamageTaken", "MORE", -100) },
	["右戒指栏位：反射的物理伤害降低 (%d+)%%"]=function(num) return {  mod("PhysicalReflectedDamageTaken", "BASE",
	tonumber(num),{ type = "SlotNumber", num = 2 })  } end,
	["左戒指栏位：反射的元素伤害降低 (%d+)%%"]=function(num) return {  mod("ElementalReflectedDamageTaken", "BASE", tonumber(num),{ type = "SlotNumber", num = 1 })  } end,
	["左戒指栏位：反射的火焰、冰霜、闪电伤害降低 (%d+)%%"]=function(num) return {  mod("ElementalReflectedDamageTaken", "BASE", tonumber(num),{ type = "SlotNumber", num = 1 })  } end,
	["格挡时回复 (%d+) 生命"] = function(num) return { mod("LifeOnBlock", "BASE", num) } end,
	["格挡时回复 (%d+)%% 生命"] = function(num) return { mod("LifeOnBlock", "BASE", 1,  { type = "PerStat", stat = "Life", div = 100 / num }) } end,
	["格挡时回复 (%d+)%% 最大魔力"] = function(num) return { mod("ManaOnBlock", "BASE", 1,  { type = "PerStat", stat = "Mana", div = 100 / num }) } end,
	["格挡时补充 (%d+)%% 的能量护盾"] = function(num) return { mod("EnergyShieldOnBlock", "BASE", 1,  { type = "PerStat", stat = "EnergyShield", div = 100 / num }) } end,
	["格挡时回复能量护盾，数值等同于 (%d+)%% 的护甲"] = function(num) return { mod("EnergyShieldOnBlock", "BASE", 1,  { type = "PerStat", stat = "Armour", div = 100 / num }) } end,
	["格挡时回复 (%d+)%% 的能量护盾"] = function(num) return { mod("EnergyShieldOnBlock", "BASE", 1,  { type = "PerStat", stat = "EnergyShield", div = 100 / num }) } end,
	["格挡时回复 %+(%d+) 生命"] = function(num) return { mod("LifeOnBlock", "BASE", num) } end,
	["格挡时回复 %+(%d+) 魔力"] = function(num) return { mod("ManaOnBlock", "BASE", num) } end,
	["格挡时回复 (%d+) 魔力"] = function(num) return { mod("ManaOnBlock", "BASE", num) } end,
	["施法时有 (%d+)%% 几率免疫晕眩打断"] = function(num) return { mod("AvoidInteruptStun", "BASE", num) } end,
	["施法时有 (%d+)%% 的几率免疫晕眩打断"] = function(num) return { mod("AvoidInteruptStun", "BASE", num) } end,
	["被格挡的击中对你造成 (%d+)%% 伤害"] = function(num) return { mod("BlockEffect", "BASE", num) } end,
	["受到的所有伤害穿透护盾"] = {
	mod("PhysicalEnergyShieldBypass", "BASE", 100),
	mod("LightningEnergyShieldBypass", "BASE", 100),
	mod("ColdEnergyShieldBypass", "BASE", 100),
	mod("FireEnergyShieldBypass", "BASE", 100),
	},
	["受到的非混沌伤害有 (%d+)%% 穿透能量护盾"] = function(num) return {
	mod("PhysicalEnergyShieldBypass", "BASE", num),
	mod("LightningEnergyShieldBypass", "BASE", num),
	mod("ColdEnergyShieldBypass", "BASE", num),
	mod("FireEnergyShieldBypass", "BASE", num),
	} end,
	["承受的非混沌伤害有 (%d+)%% 规避能量护盾"] = function(num) return {
	mod("PhysicalEnergyShieldBypass", "BASE", num),
	mod("LightningEnergyShieldBypass", "BASE", num),
	mod("ColdEnergyShieldBypass", "BASE", num),
	mod("FireEnergyShieldBypass", "BASE", num),
	} end,
	["召唤的魔像免疫元素伤害"] = {
	mod("MinionModifier", "LIST", { mod = mod("FireResist", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	mod("MinionModifier", "LIST", { mod = mod("FireResistMax", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	mod("MinionModifier", "LIST", { mod = mod("ColdResist", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	mod("MinionModifier", "LIST", { mod = mod("ColdResistMax", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	mod("MinionModifier", "LIST", { mod = mod("LightningResist", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	mod("MinionModifier", "LIST", { mod = mod("LightningResistMax", "OVERRIDE", 100) }, { type = "SkillType", skillType = SkillType.Golem }),
	},
	["每有 1 个召唤的魔像，便有 (%d+)%% 几率免疫元素异常状态"] = function(num) return {
	mod("AvoidChill", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidFreeze", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidIgnite", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidShock", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	} end,
	["每有 1 个召唤的魔像，便有 (%d+)%% 的几率免疫元素异常状态"] = function(num) return {
	mod("AvoidChill", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidFreeze", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidIgnite", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	mod("AvoidShock", "BASE", num,{ type = "PerStat", stat = "ActiveGolemLimit" } ),
	} end,
	["你获得【鸟之力量】或【鸟之斗魄】时会触发 (%d+) 级的【鸟之龙卷】"] = function(num, _, skill)
	return { mod("ExtraSkill", "LIST", {  skillId ="AvianTornado", level = tonumber(num), triggered = true})} end,
	["你获得【鸟之力量】或【鸟之斗魄】时触发 (%d+) 级的【鸟之龙卷】"] = function(num, _, skill)
	return { mod("ExtraSkill", "LIST", {  skillId ="AvianTornado", level = tonumber(num), triggered = true})} end,
	["【猫之隐匿】的持续时间 ([%+%-][%d%.]+) 秒"] = function(num) return { mod("PrimaryDuration", "BASE", num, { type = "SkillName", skillName = "猫之势" }) } end,
	["【鸟之力量】的持续时间 ([%+%-][%d%.]+) 秒"] = function(num) return { mod("PrimaryDuration", "BASE", num, { type = "SkillName", skillName = "鸟之势" }) } end,
	["【鸟之斗魄】的持续时间 ([%+%-][%d%.]+) 秒"] = function(num) return { mod("SecondaryDuration", "BASE", num, { type = "SkillName", skillName = "鸟之势" }) } end,
	["猫之敏捷持续时间 ([%+%-][%d%.]+) 秒"] = function(num) return { mod("PrimaryDuration", "BASE", num, { type = "SkillName", skillName = "猫之势" }) } end,
	["你有猫之敏捷时，具有猛攻效果"] = { flag("Condition:Onslaught", { type = "Condition", var = "AffectedBy猫之敏捷" }) },
	["弓技能 ([%+%-]?%d+)%% 持续伤害加成"] = function(num) return { mod("DotMultiplier", "BASE",
	num, nil,nil,KeywordFlag.Bow ) } end,
	["弓技能的技能效果延长 (%d+)%%"] = function(num) return { mod("Duration", "INC",
	num, nil,nil,KeywordFlag.Bow ) } end,
	["持弓时，异常持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyShockDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyFreezeDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyChillDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyIgniteDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyPoisonDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyBleedDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyScorchDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemyBrittleDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	mod("EnemySapDuration", "INC", num, { type = "Condition", var = "UsingBow" } ),
	} end,
	["【迷踪】状态下，周围敌人的总命中值总降 (%d+)%%"] =
	function(num) return { mod("EnemyModifier", "LIST", { mod = mod("Accuracy", "MORE", -num) }, { type = "Condition", var = "Phasing" } )} end,
	["暴击造成烧灼、脆弱和精疲力尽"] = { flag("CritAlwaysAltAilments") },
	["魔力回复速度的加快和减慢效果也作用与怒火回复速度"] = { flag("ManaRegenToRageRegen") },
	["魔力再生率的加快和减慢效果也作用与怒火再生速度"] = { flag("ManaRegenToRageRegen") },
	["魔力再生率的加快和减慢效果改为作用于怒火再生速度"] = { flag("ManaRegenToRageRegen") },
	["魔力再生率的增幅与减益效果改为对怒火再生率生效"] = { flag("ManaRegenToRageRegen") },
	["你的感电效果可以提高承受伤害，最大 (%d+)%%"] = function(num) return { mod("ShockMax", "OVERRIDE", num) } end,
	["你的感电效果所提供的提高承受伤害的效果最高提高 (%d+)%%"] = function(num) return { mod("ShockMax", "OVERRIDE", num) } end,
	["如同额外造成 (%d+)%% 总伤害来计算感电门槛"] = function(num) return { mod("ShockAsThoughDealing", "MORE", num) } end,
	["使敌人感电如同伤害总增 (%d+)%%"] = function(num) return { mod("ShockAsThoughDealing", "MORE", num) } end,
	["使敌人感电如同总伤害额外提高 (%d+)%%"] = function(num) return { mod("ShockAsThoughDealing", "MORE", num) } end,
	["施加的非伤害型异常状态如同总伤害额外提高 (%d+)%%"] = function(num) return {
	mod("ShockAsThoughDealing", "MORE", num),
	mod("ChillAsThoughDealing", "MORE", num),
	mod("FreezeAsThoughDealing", "MORE", num)
	} end,
	["施加的非伤害型异常状态如同伤害总增 (%d+)%%"] = function(num) return {
	mod("ShockAsThoughDealing", "MORE", num),
	mod("ChillAsThoughDealing", "MORE", num),
	mod("FreezeAsThoughDealing", "MORE", num)
	} end,
	["(%d+)%% 几率造成焦灼"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 几率造成烧灼"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 几率造成脆弱"] = function(num) return { mod("BrittleChance", "BASE", num ) } end,
	["(%d+)%% 几率造成精疲力尽"] = function(num) return { mod("SapChance", "BASE", num ) } end,
	["(%d+)%% 几率焦灼敌人"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 几率烧灼敌人"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 几率脆弱敌人"] = function(num) return { mod("BrittleChance", "BASE", num ) } end,
	["(%d+)%% 几率精疲力尽敌人"] = function(num) return { mod("SapChance", "BASE", num ) } end,
	["(%d+)%% 的几率造成焦灼"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 的几率造成烧灼"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 的几率造成脆弱"] = function(num) return { mod("BrittleChance", "BASE", num ) } end,
	["(%d+)%% 的几率造成精疲力尽"] = function(num) return { mod("SapChance", "BASE", num ) } end,
	["(%d+)%% 的几率焦灼敌人"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 的几率烧灼敌人"] = function(num) return { mod("ScorchChance", "BASE", num ) } end,
	["(%d+)%% 的几率脆弱敌人"] = function(num) return { mod("BrittleChance", "BASE", num ) } end,
	["(%d+)%% 的几率精疲力尽敌人"] = function(num) return { mod("SapChance", "BASE", num ) } end,
	["插槽内的法术获得 %+([%d%.]+)%% 法术基础暴击率"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("CritChance", "BASE", num) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "spell" } ) } end,
	["【天雷之兆】的风暴击中敌人的频率提高 (%d+)%%"] = function(num) return { mod("HeraldStormFrequency", "INC", num ) } end,
	["【闪电之捷】的风暴击中敌人的频率提高 (%d+)%%"] = function(num) return { mod("HeraldStormFrequency", "INC", num ) } end,
	["若周围最多有一个稀有或传奇敌人，你造成的伤害总增 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, nil, 0, { type = "Condition", var = "AtMostOneNearbyRareOrUniqueEnemy" }) } end,
	["若周围至少有两个稀有或传奇敌人时，则受到的伤害降低 (%d+)%%"] = function(num) return { mod("DamageTaken", "INC", -num, nil, 0, { type = "MultiplierThreshold", var = "NearbyRareOrUniqueEnemies", threshold = 2 }) } end,
	["战吼有，额外造成 (%d+) 【威力值】数量下限"] = { flag("CryWolfMinimumPower") },
	["战吼额外增助 (%d+) 次攻击"] = function(num) return { mod("ExtraExertedAttacks", "BASE", num) } end,
	["战吼增助 (%d+) 次额外攻击"] = function(num) return { mod("ExtraExertedAttacks", "BASE", num) } end,
	["战吼(%d+) 次额外攻击"] = function(num) return { mod("ExtraExertedAttacks", "BASE", num) } end,
	["战吼立即施放"] = { flag("InstantWarcry") },
	-- Exerted Attacks
	["战吼增助的攻击伤害提高 (%d+)%%"] = function(num) return { mod("ExertIncrease", "INC", num, nil, ModFlag.Attack, 0) } end,
	["若战吼在近期内献祭过怒火，则增助攻击的伤害总增 (%d+)%%"] = function(num) return { mod("ExertIncrease", "MORE", num, nil, ModFlag.Attack, 0) } end,
	["被战吼增助的攻击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("ExertDoubleDamageChance", "BASE", num, nil, ModFlag.Attack, 0) } end,
	["增助攻击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("ExertDoubleDamageChance", "BASE", num, nil, ModFlag.Attack, 0) } end,
	["被战吼增助的攻击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("ExertDoubleDamageChance", "BASE", num, nil, ModFlag.Attack, 0) } end,
	["你应用到敌人身上的非诅咒光环效果提高 (%d+)%%"] = function(num) return {
	mod("DebuffEffect", "INC", num, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true }),
	mod("AuraEffect", "INC", num, { type = "SkillName", skillName = "死神光环" }),
	} end,	
	["你的技能施加给敌人的非诅咒光环效果提高 (%d+)%%"] = function(num) return {
		mod("DebuffEffect", "INC", num, { type = "SkillType", skillType = SkillType.AppliesCurse, neg = true }),
		mod("AuraEffect", "INC", num, { type = "SkillName", skillName = "死神光环" }),
	} end,
	["放置的旗帜可使你和周围友军的攻击伤害提高 (%d+)%%"] = function(num) return { mod("ExtraAuraEffect", "LIST", { mod = mod("Damage", "INC", num, nil, ModFlag.Attack) }, { type = "Condition", var = "BannerPlanted" }) } end,
	["放置的旗帜也使你和友军的攻击伤害提高 (%d+)%%"] = function(num) return { mod("ExtraAuraEffect", "LIST", { mod = mod("Damage", "INC", num, nil, ModFlag.Attack) }, { type = "Condition", var = "BannerPlanted" }) } end,
	["最近你每消耗 (%d+) 点魔力，你身上的秘术增强效果提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2,num3)return {
	mod("秘术增强Effect", "INC", tonumber(num2),
	{ type = "Multiplier", var = "ManaSpentRecently", div = tonumber(num1) , limit = tonumber(num3), limitTotal = true}) } end,
	["最近你每消耗 (%d+) 点魔力你身上的秘术增强效果提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2,num3)return {
	mod("秘术增强Effect", "INC", tonumber(num2),
	{ type = "Multiplier", var = "ManaSpentRecently", div = tonumber(num1) , limit = tonumber(num3), limitTotal = true}) } end,
	["拥有【秘术增强】时免疫元素异常状态"]= function() return {
	mod("AvoidShock", "BASE", 100, { type = "Condition", var = "AffectedBy秘术增强" } ),
	mod("AvoidFrozen", "BASE", 100, { type = "Condition", var = "AffectedBy秘术增强" } ),
	mod("AvoidChilled", "BASE", 100, { type = "Condition", var = "AffectedBy秘术增强" } ),
	mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "AffectedBy秘术增强" } ),
	} end,
	["你制造的奉献地面将会是亵渎地面"] = {
	flag("Condition:CreateProfaneGround"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CreateProfaneGround" }), -- Make the Configuration option appear
	},
	["创造【渎神地面】来代替【奉献地面】"] = {
	flag("Condition:CreateProfaneGround"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CreateProfaneGround" }), -- Make the Configuration option appear
	},
	["免疫致盲"] = { mod("AvoidBlind", "BASE", 100) },
	["目盲不会影响你的命中率"] = { flag("IgnoreBlindHitChance") },
	["你的暴击有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("CritDoubleDamageChance", "BASE", num) } end,
	["你的暴击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("CritDoubleDamageChance", "BASE", num) } end,
	["暴击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("CritDoubleDamageChance", "BASE", num) } end,
	["你使用战吼时，每 (%d+) 点威力值使护甲在 8 秒内提高 (%d+)%%，最大 (%d+)%%"] = function(mp, _, num, max_inc) return {
	mod("Armour", "INC", num, { type = "Multiplier", var = "WarcryPower", div = tonumber(mp), limit = tonumber(max_inc), limitTotal = true }, { type = "Condition", var = "UsedWarcryInPast8Seconds" })
	} end,
	["【鸟之势】也会使周围友军获得【鸟之力量】和【鸟之斗魄】"] = { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffectOnMinion", "MORE", 100) }, { type = "SkillName", skillName = "鸟之势" }) },
	["被击中时，护甲值不对物理伤害生效，改为对火焰、冰霜、闪电伤害生效"] = {
	flag("ArmourAppliesToFireDamageTaken"),
	flag("ArmourAppliesToColdDamageTaken"),
	flag("ArmourAppliesToLightningDamageTaken"),
	flag("ArmourDoesNotApplyToPhysicalDamageTaken") },
	["承受伤害减免的最大上限为 (%d+)%%"] = function(num) return { mod("DamageReductionMax", "OVERRIDE", num) } end,
	["被击中受到闪电伤害时也套用护甲值"] = { flag("ArmourAppliesToLightningDamageTaken") },
	["闪电抗性不对承受的闪电伤害生效"] = { flag("SelfIgnoreLightningResistance") },
	["(%d+)%% 几率以双倍护甲进行防御"] = function(num) return { mod("DoubleArmourChance", "BASE", num ) } end,
	["召唤生物在满血时有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("MinionModifier", "LIST",
	{ mod = mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "FullLife" }) }) ,
	} end,
	["(%d+)%% 的几率以双倍护甲进行防御"] = function(num) return { mod("DoubleArmourChance", "BASE", num ) } end,
	["召唤生物在满血时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("MinionModifier", "LIST",
	{ mod = mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "FullLife" }) }) ,
	} end,
	["召唤生物在满血时，有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("MinionModifier", "LIST",
	{ mod = mod("DoubleDamageChance", "BASE", num,{ type = "Condition", var = "FullLife" }) }) ,
	} end,
	["你在专注时，冰缓周围敌人，使其行动速度降低 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("Condition:Chilled", "FLAG", true) },{ type = "Condition", var = "Focused" }) } end,
	["对感电敌人的冰霜击中伤害提高 (%d+)%%"] = function(num) return { mod("ColdDamage", "INC", num,nil,0,KeywordFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Shocked" } ) } end,
	["对冰缓敌人的闪电击中伤害提高 (%d+)%%"] = function(num) return { mod("LightningDamage", "INC", num,nil,0,KeywordFlag.Hit,{ type = "ActorCondition", actor = "enemy", var = "Chilled" } ) } end,
	["玩家使用药剂回复的生命和魔力提高 (%d+)%%"] = function(num) return {
	mod("FlaskLifeRecovery", "INC", num ),
	mod("FlaskManaRecovery", "INC", num )
	} end,
	["周围敌人被冰缓"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Chilled", "FLAG", true) }) },
	["使用药剂时获得【炼金术天才】状态"] = {
	flag("Condition:CanHaveAlchemistGenius"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanHaveAlchemistGenius" }), -- Make the Configuration option appear
	},
	["击中有 5 层或少于 5 层【死亡凋零】减益状态的敌人时，有 (%d+)%% 几率施加持续 (%d+) 秒的【死亡凋零】"] = { flag("Condition:CanWither") },
	["击中有 5 层或少于 5 层【死亡凋零】减益状态的敌人时，有 (%d+)%% 的几率施加持续 (%d+) 秒的【死亡凋零】"] = { flag("Condition:CanWither") },
	["你使用战吼时， 你和周围友军在 4 秒内获得【猛攻】"] = { mod("ExtraAura", "LIST", { mod = flag("Onslaught") }, { type = "Condition", var = "UsedWarcryRecently" }) },
	["免疫点燃和感电"] = {
	mod("AvoidIgnite", "BASE", 100),
	mod("AvoidShock", "BASE", 100),
	},
	["在【迷踪】状态时免疫元素异常状态"] = {
	mod("AvoidChill", "BASE", 100, { type = "Condition", var = "Phasing" }),
	mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "Phasing" }),
	mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "Phasing" }),
	mod("AvoidShock", "BASE", 100, { type = "Condition", var = "Phasing" }),
	},
	["药剂持续期间，免疫元素异常状态"] = {
	mod("AvoidChill", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
	mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
	mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
	mod("AvoidShock", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
	},
	["位于奉献地面之上时，免疫元素异常状态"] = {
	mod("AvoidChill", "BASE", 100, { type = "Condition", var = "OnConsecratedGround" }),
	mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "OnConsecratedGround" }),
	mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "OnConsecratedGround" }),
	mod("AvoidShock", "BASE", 100, { type = "Condition", var = "OnConsecratedGround" }),
	},
	["药剂效果的持续时间延长 (%d+)%%"] = function(num) return {
	mod("FlaskDuration", "INC", num )
	} end,
	["非药剂效果持续时间，移动速度提高 (%d+)%%"] = function(num) return {
	mod("MovementSpeed", "INC", num, { type = "Condition", var = "UsingFlask" , neg = true} )
	} end,
	["非药剂效果持续期间，移动速度提高 (%d+)%%"] = function(num) return {
	mod("MovementSpeed", "INC", num, { type = "Condition", var = "UsingFlask" , neg = true} )
	} end,
	["任意生命或魔力药剂持续期间，你身上诅咒的效果降低 (%d+)%%"] = function(num) return {
		mod("CurseEffectOnSelf", "INC", -num, { type = "Condition", varList = { "UsingManaFlask", "UsingLifeFlask" } } )
		} end,
	["【燃烧箭矢】的减益效果提高 (%d+)%%"] = function(num) return { mod("DebuffEffect", "INC", num, { type = "SkillName", skillName = "燃烧箭矢"}) } end,
	["【燃烧箭矢】提高等同 (%d+)%% 物理伤害的火焰伤害"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num, { type = "SkillName", skillName = "燃烧箭矢"})  } end,
	["所有战吼技能共享冷却时间"] = { flag("WarcryShareCooldown") },
	["你的暴击有 (%d+)%% 几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChanceOnCrit", "BASE", num) } end,
	["你的暴击有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { mod("DoubleDamageChanceOnCrit", "BASE", num) } end,
	["格挡击中造成的伤害无法规避能量护盾"] = { flag("BlockedDamageDoesntBypassES", { type = "Condition", var = "EVBypass", neg = true }) },
	["非格挡击中造成的伤害始终规避能量护盾"] = { flag("UnblockedDamageDoesBypassES", { type = "Condition", var = "EVBypass", neg = true }) },
	["你的召唤生物死亡时产生腐蚀地面，每秒造成等同它们 20%% 最大生命的混沌伤害"] = { mod("ExtraMinionSkill", "LIST", { skillId = "SiegebreakerCausticGround" }) },
	["你的召唤生物死亡时产生燃烧地面，每秒造成等同它们最大生命 20%% 的火焰伤害"] = { mod("ExtraMinionSkill", "LIST", { skillId = "SiegebreakerBurningGround" }) },
	["%+(%d) 最大毒力"] = function(num) return { mod("Multiplier:VirulenceStacksMax", "BASE", num) } end,
	["【凿击】创造 %+(%d+) 根尖刺"] = function(num) return { mod("Multiplier:PerforateMaxSpikes", "BASE", num) } end,
	["燃尽的范围效果扩大 (%d+)%%"]  = function(num) return {  mod("AreaOfEffect", "INC", num, { type = "SkillName", skillName = "燃尽"})  } end,
	["受到捷技能影响时，有 (%d+)%% 几率冰冻，感电和点燃敌人"]  = function(num) return {
	mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} }),
	mod("EnemyShockChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} }),
	mod("EnemyIgniteChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} })
	} end,
	["受到捷技能影响时，有 (%d+)%% 的几率冰冻，感电和点燃敌人"]  = function(num) return {
	mod("EnemyFreezeChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} }),
	mod("EnemyShockChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} }),
	mod("EnemyIgniteChance", "BASE", num,{ type = "Condition", varList = { "AffectedBy苦痛之捷", "AffectedBy纯净之捷", "AffectedBy寒冰之捷", "AffectedBy灰烬之捷", "AffectedBy闪电之捷"} })
	} end,
	["敌人在你造成的冰缓区域里，受到的闪电伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("LightningDamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "InChillingArea" }) } end,
	["有 (%d+)%% 几率使冰缓区域中的敌人【精疲力尽】"] = function(num) return { mod("SapChance", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "InChillingArea" } ) } end,
	["有 (%d+)%% 的几率使冰缓区域中的敌人【精疲力尽】"] = function(num) return { mod("SapChance", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "InChillingArea" } ) } end,
	["你没有智慧"] = function() return { mod("Int", "OVERRIDE", 0) } end,
	["使用此武器的攻击有 (%d+)%% 暴击率"] = function(num)
	return { mod("CritChance", "OVERRIDE", num, { type = "Condition",  var = "{Hand}Attack" } ) } end,
	["用该武器击中时，暴击率为 (%d+)%%"] = function(num)
	return { mod("CritChance", "OVERRIDE", num, { type = "Condition",  var = "{Hand}Attack" } ) } end,
	["周围每个灵枢使你每秒回复 ([%d%.]+)%% 生命，每秒最多 ([%d%.]+)%%"] = function(num, _, limit)
	return {
	mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true })
	} end,
	["每个激活的图腾提供 %+(%d+) 护甲"] = function(num)
	return { mod("Armour", "BASE", num, { type = "PerStat",  stat = "ActiveTotemLimit" } ) } end,
	["每个烙印可使暴击几率提高 (%d+)%%"] = function(num)
	return { mod("CritChance", "INC", num, { type = "PerStat", stat = "ActiveBrandLimit" }) } end,
	["对敌人的闪电异常效果持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyShockDuration", "INC", num),
	mod("EnemySapDuration", "INC", num)
	} end,
	["闪电异常状态持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyShockDuration", "INC", num),
	mod("EnemySapDuration", "INC", num)
	} end,
	["对敌人的冰霜异常效果持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyFreezeDuration", "INC", num),
	mod("EnemyChillDuration", "INC", num),
	mod("EnemyBrittleDuration", "INC", num)
	} end,
	["冰霜异常状态持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyFreezeDuration", "INC", num),
	mod("EnemyChillDuration", "INC", num),
	mod("EnemyBrittleDuration", "INC", num)
	} end,
	["对敌人的火焰异常效果持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyIgniteDuration", "INC", num),
	mod("EnemyScorchDuration", "INC", num)
	} end,
	["火焰异常状态持续时间延长 (%d+)%%"] = function(num) return {
	mod("EnemyIgniteDuration", "INC", num),
	mod("EnemyScorchDuration", "INC", num)
	} end,
	["闪电异常效果提高 (%d+)%%"] = function(num) return {
	mod("EnemyShockEffect", "INC", num),
	mod("EnemySapEffect", "INC", num)
	} end,
	["冰霜异常效果提高 (%d+)%%"] = function(num) return {
	mod("EnemyFreezeEffect", "INC", num),
	mod("EnemyChillEffect", "INC", num),
	mod("EnemyBrittleEffect", "INC", num)
	} end,
	["火焰异常效果提高 (%d+)%%"] = function(num) return {
	mod("EnemyIgniteEffect", "INC", num),
	mod("EnemyScorchEffect", "INC", num)
	} end,
	["若近期你没有格挡，则暴击几率提高  (%d+)%%"]= function(num) return {  mod("CritChance", "INC", tonumber(num),{ type = "Condition", var = "BlockedRecently" , neg = true}  )  } end,
	["若近期你没有格挡，则暴击几率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", tonumber(num),{ type = "Condition", var = "BlockedRecently" , neg = true}  )  } end,
	["【闪现射击】和【魅影射击】的冷却回复速度提高 (%d+)%%"]= function(num) return {
	mod("CooldownRecovery", "INC", tonumber(num),{ type = "SkillName", skillName = "闪现射击" }  ),
	mod("CooldownRecovery", "INC", tonumber(num),{ type = "SkillName", skillName = "魅影射击" }  )
	} end,
	["【风暴烙印】的伤害会穿透带有烙印敌人闪电抗性的 (%d+)%%"]= function(num) return {
	mod("LightningPenetration", "BASE", tonumber(num),{ type = "SkillName", skillName = "风暴烙印" },{ type = "MultiplierThreshold", var = "BrandsAttachedToEnemy", threshold = 1 }  )  } end,
	["施放光环图腾技能时需要的魔力降低 (%d+)%%"] = function(num) return {
	mod("ManaCost", "INC", -num,nil,nil, KeywordFlag.Totem,{ type = "SkillType", skillType = SkillType.Aura }),
	} end,
	["非持续吟唱技能总魔力消耗 %-(%d+)"] = function(num) return {
	mod("ManaCost", "BASE", -num,{ type = "SkillType", skillType = SkillType.Channelled, neg = true } ),
	} end,
	["受到【清晰】影响时，非持续吟唱技能的总魔力消耗 %-(%d+)"] = function(num) return {
	mod("ManaCost", "BASE", -num,{ type = "SkillType", skillType = SkillType.Channelled, neg = true },{ type = "Condition", var = "AffectedBy清晰" } ),
	} end,
	["装备在主手时，召唤的魔侍复制此武器"] =
	{ mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "minionUses", value = "Weapon 1" }) },
	{ type = "SkillName", skillNameList = { "召唤魔侍"} },{ type = "SlotNumber", num = 1 }) },
	["召唤魔侍勇士时，它会持握你主手武器的副本"] =
	{ mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "minionUses", value = "Weapon 1" }) },
	{ type = "SkillName", skillNameList = { "召唤魔侍"} },{ type = "SlotNumber", num = 1 }) },
	["当你近期使用此武器击中时，召唤的魔侍使用此武器的伤害为三倍"]
	= {
	mod("MinionModifier", "LIST", { mod =
	mod("TripleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "MainHandAttack" }) })
	},
	["召唤魔侍勇士时，若你近期用该武器击中过敌人则它用该武器造成三倍伤害"]
	= {
	mod("MinionModifier", "LIST", { mod =
	mod("TripleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "MainHandAttack" }) })
	},
	["则它用该武器造成三倍伤害"]
	= {
	mod("MinionModifier", "LIST", { mod =
	mod("TripleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "MainHandAttack" }) })
	},
	["被标记的敌人承受的伤害提高 (%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, {type = "ActorCondition", actor = "enemy", var = "Marked"}),
	} end,
	["被标记的敌人的命中值降低 (%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("Accuracy", "INC", -num) }, {type = "ActorCondition", actor = "enemy", var = "Marked"}),
	} end,
	["你施放的魔蛊有 %+(%d+) 层末日之力数量上限"] = function(num) return { mod("MaxDoom", "BASE", num) } end,
	["你施加魔蛊的最大灭能 %+(%d+)"] = function(num) return { mod("MaxDoom", "BASE", num) } end,
	["魔蛊技能范围提高 (%d+)%%"]= function(num) return { mod("AreaOfEffect", "INC", num, { type = "SkillType", skillType = SkillType.Hex } ) } end,
	["被【法术凝聚（辅）】辅助的技能有 %+(%d) 最大层"] = function(num) return { mod("Multiplier:IntensityLimit", "BASE", num) } end,
	["能获得凝聚的法术的最大凝聚 %+(%d)"] = function(num) return { mod("Multiplier:IntensityLimit", "BASE", num) } end,
	["插槽内的技能石造成双倍伤害"]= { mod("ExtraSkillMod", "LIST",
	{ mod = mod("DoubleDamageChance", "BASE", 100) }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["插入的技能伤害翻倍"]= { mod("ExtraSkillMod", "LIST",
	{ mod = mod("DoubleDamageChance", "BASE", 100) }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["冻结冰缓的敌人如同总伤害额外提高 (%d+)%%"] = function(num) return { mod("FreezeAsThoughDealing", "MORE", num, { type = "ActorCondition", actor = "enemy", var = "Chilled" } ) } end,
	["冻结冰缓的敌人如同伤害总增 (%d+)%%"] = function(num) return { mod("FreezeAsThoughDealing", "MORE", num, { type = "ActorCondition", actor = "enemy", var = "Chilled" } ) } end,
	["对冰缓的敌人如同额外造成 (%d+)%% 总伤害来计算冰冻门槛"] = function(num) return { mod("FreezeAsThoughDealing", "MORE", num, { type = "ActorCondition", actor = "enemy", var = "Chilled" } ) } end,
	["you have perfect agony if you've dealt a critical strike recently"] = {mod("Keystone", "LIST", "Perfect Agony", { type = "Condition", var = "CritRecently" })},
	["grants eldritch battery during flask effect"] = { mod("Keystone", "LIST", "Eldritch Battery", { type = "Condition", var = "UsingFlask" }) },
	["increases and reductions to cast speed apply to attack speed at (%d+)%% of their value"] =  function(num) return { flag("CastSpeedAppliesToAttacks"), mod("ImprovedCastSpeedAppliesToAttacks", "INC", num) } end,
	["装备时触发等级 20 的尸体行走"]= function() return {  mod("ExtraSkill", "LIST", { skillId ="CorpseWalk", level = 20, triggered = true})   } end,
	["受到冰霜伤害的 (%d+)%% 转换为闪电伤害"]= function(num) return { mod("ColdDamageTakenAsLightning", "BASE", num ) } end,
	["受到火焰伤害的 (%d+)%% 转换为闪电伤害"]= function(num) return { mod("FireDamageTakenAsLightning", "BASE", num ) } end,
	["将承受的 (%d+)%% 冰霜伤害视为闪电伤害"]= function(num) return { mod("ColdDamageTakenAsLightning", "BASE", num ) } end,
	["将承受的 (%d+)%% 火焰伤害视为闪电伤害"]= function(num) return { mod("FireDamageTakenAsLightning", "BASE", num ) } end,
	["周围敌人被【冰缓】"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Chilled", "FLAG", true) }) },
	["无法造成非混沌伤害"] = { flag("DealNoPhysical"),flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire") },
	["不能造成非混沌伤害"] = { flag("DealNoPhysical"),flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire") },
	["(%d+)%% 几率免疫中毒"]= function(num) return { mod("AvoidPoison", "BASE", num ) } end,
	["(%d+)%% 的几率免疫中毒"]= function(num) return { mod("AvoidPoison", "BASE", num ) } end,
	["无法偷取或自然回复魔力"] = { flag("CannotLeechMana") ,flag("NoManaRegen") },
	["无法偷取或自然再生魔力"] = { flag("CannotLeechMana") ,flag("NoManaRegen") },
	["无法造成冰霜伤害"] = { flag("DealNoCold")},
	["可以对敌人施放 %-1 个额外诅咒"] = { mod("EnemyCurseLimit", "BASE", -1) },
	["魔卫复苏每秒将其最大生命的 ([%d%.]+)%% 转化为火焰伤害"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("FireDegen", "BASE", num/100, { type = "PerStat", stat = "Life", div = 1 }) }, { type = "SkillName", skillName = "魔卫复苏" }) } end,
	["魔卫复苏获得【火之化身】"] = { mod("MinionModifier", "LIST", { mod = mod("Keystone", "LIST", "火之化身") }, { type = "SkillName", skillName = "魔卫复苏" }) },
	["你的混沌伤害可以造成冰缓"] = { flag("ChaosCanChill")},
	["你的物理伤害可以造成冰冻"] = { flag("PhysicalCanChill")},
	["你的冰霜伤害无法冰冻"] = { flag("CannotFreeze") },
	["用该武器击中时，所有伤害都导致中毒"] = {
	flag("FireCanPoison", { type = "Condition", var = "{Hand}Attack" } ) ,
	flag("ColdCanPoison", { type = "Condition", var = "{Hand}Attack" } ) ,
	flag("LightningCanPoison", { type = "Condition", var = "{Hand}Attack" } )
	},
	["你使用插入的技能时触发 (%d+) 级烈焰冲刺"] = function(num) return { mod("ExtraSkill", "LIST", { skillId = "FlameDash", level = num , triggered = true}) } end,
	["你使用药剂时触发 (%d+) 级召唤嘲讽装置"] = function(num) return { mod("ExtraSkill", "LIST", { skillId = "SummonTauntingContraption", level = num , triggered = true}) } end,
	["暴击攻击无视敌人的元素抗性"] = { flag("IgnoreElementalResistances", nil, ModFlag.Attack, { type = "Condition", var = "CriticalStrike" }) },
	["装备时触发 20 级灵枢行走"]= function() return {  mod("ExtraSkill", "LIST", { skillId ="CorpseWalk", level = 20, triggered = true})   } end,
	["周围每个灵枢都使你每秒再生 ([%d%.]+)%% 生命，最多 ([%d%.]+)%%"] = function(num, _, limit)
	return {
	mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "NearbyCorpse", limit = tonumber(limit), limitTotal = true })
	} end,
	["迷踪状态下，每隔 0.5 秒便触发 20 级隐形打击"]= function() return {  mod("ExtraSkill", "LIST", { skillId ="HiddenBlade", level = 20, triggered = true})   } end,
	["迷踪状态下，攻击速度减慢 (%d+)%%"]= function(num) return {
	mod("Speed", "INC", -num,nil, ModFlag.Attack, { type = "Condition", var = "Phasing" } )  } end,
	--["你被感电时，元素伤害击中特别幸运"] = { flag("LuckyHits",{ type = "Condition", var = "Shocked" } )},
	["你被冰缓时，伤害穿透 (%d+)%% 元素抗性"]= function(num) return {
	mod("ElementalPenetration", "BASE", num, { type = "Condition", var = "Chilled" } )  } end,
	["你被点燃时，将物理伤害的 (%d+)%% 视为一种随机元素额外伤害"]= function(num) return {
	mod("PhysicalDamageGainAsFire", "BASE", tonumber(num), { type = "Condition", var = "PhysicsRandomElementFire" }, { type = "Condition", var = "Ignited" } ),
	mod("PhysicalDamageGainAsCold", "BASE", tonumber(num),{ type = "Condition", var = "PhysicsRandomElementCold" }, { type = "Condition", var = "Ignited" } ),
	mod("PhysicalDamageGainAsLightning", "BASE", tonumber(num),{ type = "Condition", var = "PhysicsRandomElementLightning" }, { type = "Condition", var = "Ignited" } ),
	} end,
	["若你近期内获得过暴击球，则暴击伤害加成 ([%+%-]?%d+)%%"]= function(num) return {  mod("CritMultiplier", "BASE", num, { type = "StatThreshold", stat = "PowerCharges", threshold = 1 })  } end,
	["暴击球总持续时间额外缩短 (%d+)%%"]= function(num) return {  mod("PowerChargesDuration", "MORE", -num)  } end,
	["暴击球总持续时间额外缩短 (%d+)%%"]= function(num) return {  mod("PowerChargesDuration", "MORE", -num)  } end,
	["【迷踪】状态下，附近的敌人获得火焰、冰霜、闪电曝露，并使它们的抗性 %-(%d+)%%"] = function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("FireExposure", "BASE", -num) }, { type = "Condition", var = "Phasing" } ),
	mod("EnemyModifier", "LIST", { mod = mod("ColdExposure", "BASE", -num) }, { type = "Condition", var = "Phasing" } ),
	mod("EnemyModifier", "LIST", { mod = mod("LightningExposure", "BASE", -num) }, { type = "Condition", var = "Phasing" } ),
	} end,
	["火焰技能有 (%d+)%% 几率击中附加火焰曝露"] = function(num) return { mod("FireExposureChance", "BASE", num) } end,
	["冰霜技能有 (%d+)%% 几率击中附加冰霜曝露"] = function(num) return { mod("ColdExposureChance", "BASE", num) } end,
	["闪电技能有 (%d+)%% 几率击中附加闪电曝露"] = function(num) return { mod("LightningExposureChance", "BASE", num) } end,
	["火焰技能有 (%d+)%% 的几率击中附加火焰曝露"] = function(num) return { mod("FireExposureChance", "BASE", num) } end,
	["冰霜技能有 (%d+)%% 的几率击中附加冰霜曝露"] = function(num) return { mod("ColdExposureChance", "BASE", num) } end,
	["闪电技能有 (%d+)%% 的几率击中附加闪电曝露"] = function(num) return { mod("LightningExposureChance", "BASE", num) } end,
	["周围敌人有火焰曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("FireExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }),
	},
	["周围敌人有冰霜曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("ColdExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }),
	},
	["周围敌人有闪电曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("LightningExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }),
	},
	["你受到【灰烬之捷】影响时，附近的敌人获得火焰曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("FireExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }, { type = "Condition", var = "AffectedBy灰烬之捷" }),
	},
	["你受到【寒冰之捷】影响时，附近的敌人获得冰霜曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("ColdExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }, { type = "Condition", var = "AffectedBy寒冰之捷" }),
	},
	["你受到【闪电之捷】影响时，附近的敌人获得闪电曝露"] = {
	mod("EnemyModifier", "LIST", { mod = mod("LightningExposure", "BASE", -10) }, { type = "Condition", var = "Effective" }, { type = "Condition", var = "AffectedBy闪电之捷" }),
	},
	["击中时有 (%d+)%% 几率施加畏火"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 几率施加畏寒"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 几率施加畏电"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 几率施加火焰曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 几率施加冰霜曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 几率施加闪电曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加畏火"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加畏寒"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加畏电"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加火焰曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加冰霜曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["击中时有 (%d+)%% 的几率施加闪电曝露"]= function(num) return {  mod("FireExposureChance", "BASE", num)  } end,
	["总点燃持续时间额外缩短 (%d+)%%"]= function(num) return {  mod("EnemyIgniteDuration", "MORE", -num)  } end,
	["每失去 (%d+)%% 冰霜抗性，就使冰霜伤害提高 (%d+)%%"]= function(_,num1,num2) return {
	mod("ColdDamage", "INC", tonumber(num2),{ type = "PerStat", stat = "MissingColdResist", div = tonumber(num1) } )  } end,
	["每失去 (%d+)%% 火焰抗性，就使火焰伤害提高 (%d+)%%"]= function(_,num1,num2) return {
	mod("FireDamage", "INC", tonumber(num2),{ type = "PerStat", stat = "MissingFireResist", div = tonumber(num1) } )  } end,
	["插入的旅行技能的总伤害额外提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "SkillType", skillType = SkillType.TravelSkill } ) } end,
	["插入的旅行技能的伤害总增 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", num) }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "SkillType", skillType = SkillType.TravelSkill } ) } end,
	["若你的耐力球、狂怒球或暴击球总共有 (%d+) 个时，将伤害的 ([%d%.]+)%% 转化为生命偷取"] = function(_,num1,num2) return {
	mod("DamageLifeLeech", "BASE", tonumber(num2),{ type = "MultiplierThreshold", var = "TotalCharges", threshold = tonumber(num1) } )  } end,
	["你格挡时触发 (%d+) 级(.+)"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["你的所有伤害均可造成冰冻"] = { flag("PhysicalCanFreeze"), flag("LightningCanFreeze"),  flag("FireCanFreeze"), flag("ChaosCanFreeze") },
	["格挡时使攻击者感电 (%d+) 秒"]  = {
	mod("ShockBase", "BASE", 15, { type = "Condition", var = "BlockedRecently" }),
	mod("EnemyModifier", "LIST", { mod = flag("Condition:Shocked") }, { type = "Condition", var = "BlockedRecently" } ),
	},
	["你被感电时，元素伤害击中特别幸运"] = { flag("ElementalLuckHits", { type = "Condition", var = "Shocked" }) },
	--SummonedGolemInPast8Sec
	["你造成的咒术效果为厄运的 2 倍"] = { mod("DoomEffect", "MORE", 100) },
	["若你近期内没有格挡过敌人，则法术伤害格挡率 %+(%d+)%%"] = function(num) return { mod("SpellBlockChance", "BASE", num, { type = "Condition", var = "BlockedRecently", neg = true }) } end,
	["同时可以放置的陷阱减少 (%d+) 个"] = function(num) return { mod("ActiveTrapLimit", "BASE", -num) } end,
	["魔像在召唤后的 8 秒内伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "SummonedGolemInPast8Sec" }) }, { type = "SkillType", skillType = SkillType.Golem }) } end,
	["在召唤魔像后的 8 秒内伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, { type = "Condition", var = "SummonedGolemInPast8Sec" }) } end,
	["迷踪状态下，承受的伤害提高 (%d+)%%"] = function(num) return { mod("DamageTaken", "INC", num, { type = "Condition", var = "Phasing" }) } end,
	["你在迷踪状态下，投射物连锁次数 %+(%d)"] = function(num) return { mod("ChainCountMax", "BASE", num, nil, ModFlag.Projectile, { type = "Condition", var = "Phasing" }) } end,
	["攻击可以额外发射 1 个投射物"] = { mod("ProjectileCount", "BASE", 1, nil, ModFlag.Attack) },
	["若你近期内被击中，则每秒失去 (%d+)%% 生命"] = function(num) return { mod("LifeDegen", "BASE", 1, { type = "PercentStat", stat = "Life", percent = num }, { type = "Condition", var = "BeenHitRecently" }) } end,
	["防御为零"] = {
	mod("Armour", "MORE", -100),
	mod("EnergyShield", "MORE", -100),
	mod("Evasion", "MORE", -100),
	},
	["物理神盾没有消散时，周围敌人会目盲"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Blinded", "FLAG", true) }, { type = "Condition", var = "PhysicalAegisDepleted", neg = true }) },
	["你至少有 (%d+) 点怒火时免疫诅咒"] = function(num) return { mod("AvoidCurse", "BASE", 100, { type = "MultiplierThreshold", var = "Rage", threshold = num }) } end,
	["药剂持续期间具有异能魔力"] = { mod("Keystone", "LIST", "Eldritch Battery", { type = "Condition", var = "UsingFlask" }) },
	["deal no damage"] = { flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire"), flag("DealNoChaos"), flag("DealNoPhysical") },
	["当不处于低血或低魔状态时，混沌伤害无法穿透能量护盾"] = { flag("ChaosNotBypassEnergyShield", { type = "Condition", varList = { "LowLife", "LowMana" }, neg = true }) },
	["非低血状态时不造成伤害"] = {
	flag("DealNoLightning", { type = "Condition", var = "LowLife", neg = true }),
	flag("DealNoCold", { type = "Condition", var = "LowLife", neg = true }),
	flag("DealNoFire", { type = "Condition", var = "LowLife", neg = true }),
	flag("DealNoChaos",{ type = "Condition", var = "LowLife", neg = true }),
	flag("DealNoPhysical", { type = "Condition", var = "LowLife", neg = true }),
	},
	["暴击获得【灵巧】"] = {
	flag("Condition:CanBeElusive"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanBeElusive" }), -- Make the Configuration option appear
	},
	["能量护盾每秒损失 (%d+)%%"] = function(num) return { mod("EnergyShieldDegen", "BASE", 1, { type = "PercentStat", stat = "EnergyShield", percent = num }) } end,
	["无法回复，也无法补充"] = {
	flag("NoEnergyShieldRecharge"),
	flag("NoEnergyShieldRegen")
	},
	["满血时无法移除生命偷取效果"] = {
	flag("CanLeechLifeOnFullLife")
	},
	["生命偷取在满血时恢复能量护盾"] = {
	flag("GhostReaver", { type = "Condition", var = "FullLife" })
	},
	["能量护盾回复改为恢复生命"] = { flag("EnergyShieldRechargeAppliesToLife") },
	["能量护盾充能改为对生命生效"] = { flag("EnergyShieldRechargeAppliesToLife") },
	["能量护盾充能应用到生命而非能量护盾"] = { flag("EnergyShieldRechargeAppliesToLife") },
	["你的混沌伤害可以点燃敌人"] = { flag("ChaosCanIgnite") },
	["你的光环效果不影响友军"] = { flag("SelfAurasCannotAffectAllies") },
	["你技能产生的光环不影响队友"] = { flag("SelfAurasCannotAffectAllies") },
	["你身上的光环总效果额外提高 (%d+)%%"] = function(num) return { mod("SkillAuraEffectOnSelf", "MORE", num) } end,
	["你技能产生的光环对自己的效果总增 (%d+)%%"] = function(num) return { mod("SkillAuraEffectOnSelf", "MORE", num) } end,
	["如果近期内被击中，则闪避值提高 (%d+)%%"] = function(num) return {  mod("Evasion", "MORE", num, { type = "Condition", var = "BeenHitRecently" })  } end,
	["每秒再生 (%d+) 点怒火"]= function(num) return {
	flag("Condition:CanGainRage"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }),
	mod("RageRegen", "BASE", num)
	}end,
	["暴击伤害特别幸运"] = { flag("CritLucky") },
	["你击中稀有或传奇敌人时触发 (%d+) 级(.+)"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["格挡时用(%D+)诅咒敌人，其效果提高 (%d+)%%"] = function(_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1, noSupports = true, triggered = true  }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["击中时用(%D+)诅咒敌人，它的效果提高 (%d+)%%"] = function(_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1, noSupports = true, triggered = true  }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["击中时用(.+)诅咒敌人，它的效果提高 (%d+)%%"] = function(_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1 , noSupports = true, triggered = true }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["击中时用(.+)诅咒敌人，他的效果提高 (%d+)%%"] = function(_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1 , noSupports = true, triggered = true }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["击中时有 (%d+)%% 几率用(.+)诅咒敌人，它的效果提高 (%d+)%%"] = function(_,_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1 , noSupports = true, triggered = true }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["击中时有 (%d+)%% 的几率用(.+)诅咒敌人，它的效果提高 (%d+)%%"] = function(_,_, skill, num) return {
	mod("ExtraSkill", "LIST", { skillId = gemIdLookup[skill], level = 1 , noSupports = true, triggered = true }),
	mod("CurseEffect", "INC", tonumber(num), { type = "SkillName", skillName = gemIdLookup[skill] }),
	} end,
	["你被(%D+)诅咒，其效果提高 (%d+)%%"] = function( _,name, num) return {
	mod("ExtraCurse", "LIST", { skillId = FuckSkillSupportCnName(name), level = 1, applyToPlayer = true }),
	mod("CurseEffectOnSelf", "INC", tonumber(num), { type = "SkillName", skillName = FuckSkillSupportCnName(name) }),
	} end,
	["每个暴击球可使每秒回复 ([%d%.]+)%% 生命"] = function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Multiplier", var = "PowerCharge" })  } end,
	["【迷踪】状态下，%+(%d+)%% 避免元素伤害几率"]= function(num) return {
	mod("AvoidFireDamageChance", "BASE", num, { type = "Condition", var = "Phasing" } ) ,
	mod("AvoidColdDamageChance", "BASE", num, { type = "Condition", var = "Phasing" } ) ,
	mod("AvoidLightningDamageChance", "BASE", num, { type = "Condition", var = "Phasing" } ) ,
	} end,
	["若近期内有过格挡，你则获得【迷踪】状态"] = { flag("Condition:Phasing", { type = "Condition", var = "BlockedRecently" }) },
	["迷踪状态下，被击中时避免物理伤害的几率 %+(%d+)%%"]= function(num) return {
	mod("AvoidPhysicalDamageChance", "BASE", num, { type = "Condition", var = "Phasing" } ) ,
	} end,
	["你在天赋树上连接到野蛮人的出发位置时，你获得：每秒生命再生 ([%d%.]+)%%"]= function(num)
	return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "ConnectedTo野蛮人Start" })  } end,
	["你在天赋树上连接到决斗者的出发位置时，你获得：近战打击距离 %+(%d+)"]= function(num)
	return {
	mod("MeleeWeaponRange", "BASE", num,{ type = "Condition", var = "ConnectedTo决斗者Start" }),
	mod("UnarmedRange", "BASE", num,{ type = "Condition", var = "ConnectedTo决斗者Start" }),
	} end,
	["你在天赋树上连接到游侠的出发位置时，你获得: 药剂充能获取率提高 (%d+)%%"]= function(num)
	return {
	mod("FlaskChargesGained", "INC", num,{ type = "Condition", var = "ConnectedTo游侠Start" })
	} end,
	["你在天赋树上连接到游侠的出发位置时，你获得：药剂充能获取率提高 (%d+)%%"]= function(num)
	return {
	mod("FlaskChargesGained", "INC", num,{ type = "Condition", var = "ConnectedTo游侠Start" })
	} end,
	["你在天赋树上连接到暗影的出发位置时，你获得：攻击和施法速度提高 (%d+)%%"]= function(num)
	return {
	mod("Speed", "INC", num,{ type = "Condition", var = "ConnectedTo暗影Start" })
	} end,
	["你在天赋树上连接到女巫的出发位置时，你获得：技能效果持续时间延长 (%d+)%%"]= function(num)
	return {
	mod("Duration", "INC", num,{ type = "Condition", var = "ConnectedTo女巫Start" })
	} end,
	["你在天赋树上连接到圣堂武僧的出发位置时，你获得：攻击和法术伤害格挡率 %+(%d+)%%"]= function(num)
	return {
	mod("BlockChance", "BASE", num,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" }),
	mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "ConnectedTo圣堂武僧Start" }),
	} end,
	["你在天赋树上连接到贵族的出发位置时，你获得：伤害提高 (%d+)%%"]= function(num)
	return {
	mod("Damage", "INC", num,{ type = "Condition", var = "ConnectedTo贵族Start" })
	} end,
	["最大魔力的 (%d+)%% 转化为双倍的护甲"] = function(num) return {
	mod("ManaConvertToArmour", "BASE", num),
	} end,
	["获得等同 (%d+)%% 最大生命的额外护甲"] = function(num) return {
	mod("LifeGainAsArmour", "BASE", num),
	} end,
	["击中时 (%d+)%% 几率触发插槽内的闪电法术"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["击中时 (%d+)%% 的几率触发插槽内的闪电法术"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["击中时触发插槽内的闪电法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["击中时触发一个插入的闪电法术，它有 0.15 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["近战暴击时触发插槽内的冰霜技能"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueCosprisMaliceColdSpellsCastOnMeleeCriticalStrike", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["你用该武器攻击时触发一个插入的法术，它有 0.15 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["【炼狱之击】的减益效果每层可额外造成 (%d+)%% 伤害"] = function(num) return { mod("DebuffEffect", "BASE", num,
	{ type = "SkillName", skillName = "炼狱之击"}) } end,
	["击中被诅咒的敌人时造成中毒"] = function() return {
	mod("PoisonChance", "BASE", 100,{ type = "ActorCondition", actor = "enemy", var = "Cursed" }),
	} end,
	["你的魔蛊可以影响无咒的敌人"] = { flag("CursesIgnoreHexproof") },
	["你能施加一个额外诅咒"] = { mod("EnemyCurseLimit", "BASE", 1) },
	["你技能给予召唤生物的非诅咒光环效果提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", { mod = mod("AuraEffectOnSelf", "INC", num) })  } end,
	["左戒指栏位：你的冰冷的飞掠者用插入的魔蛊替代光环"] = { flag("SkitterbotsCannotChill", { type = "SlotNumber", num = 1 }) },
	["右戒指栏位：电震的飞掠者用插入的魔蛊替代光环"] = { flag("SkitterbotsCannotShock", { type = "SlotNumber", num = 2 }) },
	["你的攻击给敌人施加的每个诅咒都使你获得 (%d+) 点生命"] = function(num) return { mod("LifeOnHit", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "Cursed"})} end,
	["你的攻击给敌人施加的每个诅咒都使你获得 (%d+) 点魔力"] = function(num) return { mod("ManaOnHit", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "Cursed"})} end,
	["解除护甲和最大能量护盾"] = {
	mod("Armour", "MORE", -100),
	mod("EnergyShield", "MORE", -100),
	},
	["法术伤害击中有 ([%d%.]+)%% 几率施加【中毒】"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Spell)  } end,
	["法术击中时有 ([%d%.]+)%% 几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Spell)  } end,
	["法术伤害击中有 ([%d%.]+)%% 的几率施加【中毒】"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Spell)  } end,
	["法术击中时有 ([%d%.]+)%% 的几率使目标中毒"]= function(num) return {  mod("PoisonChance", "BASE", num,nil, ModFlag.Spell)  } end,
	["法术技能 ([%+%-]?%d+)%% 中毒持续伤害加成"]= function(num) return {  mod("DotMultiplier", "BASE", num, 0, 0, KeywordFlag.Spell)  } end,
	["每 (%d+) 点敏捷可使召唤生物的攻击速度提高 (%d+)%%"]= function(_,num1,num2) return { mod("MinionModifier", "LIST",
	{ mod = mod("Speed", "INC", tonumber(num2),nil, ModFlag.Attack )}, { type = "PerStat", stat = "Dex", div = tonumber(num1) })  } end,
	["每 (%d+) 点敏捷可使召唤生物的移动速度提高 (%d+)%%"]= function(_,num1,num2) return { mod("MinionModifier", "LIST",
	{ mod = mod("MovementSpeed", "INC", tonumber(num2))}, { type = "PerStat", stat = "Dex", div = tonumber(num1) })  } end,
	["你的击中造成的元素伤害由最低的抗性来抵抗"] = { flag("ElementalDamageUsesLowestElementalResistance") },
	["若你在过去 8 秒内失去过耐力球，则伤害总增 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, { type = "Condition", var = "LostEnduranceChargeInPast8Sec" })	} end,
	["近期内每失去一个耐力球就使总伤害额外提高 (%d+)%%，最大 (%d+)%%"] = function(num, _, limit) return {
	mod("Damage", "MORE", num, { type = "Multiplier", var = "EnduranceChargesLostRecently", limit = tonumber(limit), limitTotal = true }),
	} end,
	["若敌人身上有冻结、感电、点燃效果，每有一种都使对它的击中和异常状态伤害提高 (%d+)%%"] = function(num) return {
	mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) , { type = "Multiplier", var = "FreezeShockIgniteOnEnemy" })
	} end,
	["对被冰冻、感电、点燃敌人的击中伤害和异常状态伤害提高 (%d+)%%"] = function(num) return {
	mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) , { type = "Multiplier", var = "FreezeShockIgniteOnEnemy" })
	} end,
	["连锁的投射物将 (%d+)%% 非混沌伤害作为其额外混沌伤害"] = function(num) return { mod("NonChaosDamageGainAsChaos", "BASE", num, nil, ModFlag.Projectile, { type = "StatThreshold", stat = "Chain", threshold = 1 }) } end,
	["连锁的投射物获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num) return { mod("NonChaosDamageGainAsChaos", "BASE", num, nil, ModFlag.Projectile, { type = "StatThreshold", stat = "Chain", threshold = 1 }) } end,
	["你格挡时触发 (%d+) 级破盾击"]= function(num)return {   mod("ExtraSkill", "LIST", {  skillId ="ShieldShatter", level = tonumber(num), triggered = true})   } end,
	["你使用药剂时触发 (%d+) 级召唤嘲讽装置"]= function(num)return {   mod("ExtraSkill", "LIST", {  skillId ="SummonTauntingContraption", level = tonumber(num), triggered = true})   } end,
	["使用该武器近战击中时触发 (%d+) 级火烈冲击"]= function(num)return {   mod("ExtraSkill", "LIST", {  skillId ="FieryImpactHeistMaceImplicit", level = tonumber(num), triggered = true})   } end,
	["召唤生物攻击击中时有 (%d+)%% 几率穿刺目标"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack) })  } end,
	["召唤生物攻击击中时有 (%d+)%% 的几率穿刺目标"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack) })  } end,
	["近期所召唤的召唤生物的攻击和施法速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", num) }, { type = "Condition", var = "MinionsCreatedRecently" }) } end,
	["近期所召唤的召唤生物的移动速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("MovementSpeed", "INC", num) }, { type = "Condition", var = "MinionsCreatedRecently" }) } end,
	["被你枯萎的敌人 (%-%d+)%% 所有抗性"]= function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "被凋零敌人减抗" }, { type = "MultiplierThreshold",  var = "WitheredStack", threshold = 1 }) }),
	mod("EnemyModifier", "LIST", { mod = mod("ElementalResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "被凋零敌人减抗" }, { type = "MultiplierThreshold",  var = "WitheredStack", threshold = 1 }) }),
	} end,
	["被你凋零的敌人 (%-%d+)%% 所有抗性"]= function(num) return {
	mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "被凋零敌人减抗" }, { type = "MultiplierThreshold",  var = "WitheredStack", threshold = 1 }) }),
	mod("EnemyModifier", "LIST", { mod = mod("ElementalResist", "BASE", num,{ type = "GlobalEffect", effectType = "Debuff", effectName = "被凋零敌人减抗" }, { type = "MultiplierThreshold",  var = "WitheredStack", threshold = 1 }) }),
	} end,
	["施加在被你曝露的敌人身上的元素异常状态持续时间延长 20%"]= function(num) return {
	mod("EnemyShockDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemyFreezeDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemyChillDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemyIgniteDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemyScorchDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemyBrittleDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	mod("EnemySapDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "HaveExposure" }),
	} end,
	["受到防卫技能增益效果影响时，获得额外 ([%d%.]+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "AffectedByGuardSkill" })  } end,
	["受到非瓦尔防卫技能影响时获得 ([%d%.]+)%% 物理伤害减伤"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" })  } end,
	["受到非瓦尔护卫技能影响时， ([%d%.]+)%% 物理伤害减伤"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" })  } end,
	["受到非瓦尔护卫技能影响时，%+(%d+)%% 所有元素抗性和所有元素抗性上限"]= function(num) return {
	mod("ElementalResist", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" }),
	mod("FireResistMax", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" }),
	mod("ColdResistMax", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" }),
	mod("LightningResistMax", "BASE", num,{ type = "Condition", var = "AffectedByNonVaalGuardSkill" }),
	} end,
	["被防卫技能的增益效果影响时，每秒回复 ([%d%.]+)%% 生命"]= function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "AffectedByGuardSkill" })  } end,
	["你在靠近敌人使用非瓦尔猛击时触发 20 级的【塔赫亚神选】"] = function()return {   mod("ExtraSkill", "LIST", {  skillId ="SummonMirageChieftain", level = 20, triggered = true})   } end,
	["每层威能法印增益效果都使暴击率提高 (%d+)%%"] = function(num) return { mod("CritChance", "INC", num, 0, 0, { type = "Multiplier", var = "SigilOfPowerStage", limit = 4 }, { type = "GlobalEffect", effectType = "Buff", effectName = "威能法印" } ) } end,
	["【燃火烧尽】最多 %+(%d+) 阶"]= function(num) return {
	mod("Multiplier:烧毁MaxStages", "BASE", tonumber(num)/2, 0, 0, { type = "SkillPart", skillPart = 2 }),
	mod("Multiplier:烧毁MaxStages", "BASE", tonumber(num), 0, 0, { type = "SkillPart", skillPart = 3 })	} end,
	["【烧毁】最多 %+(%d+) 阶"]= function(num) return {
	mod("Multiplier:烧毁MaxStages", "BASE", tonumber(num)/2, 0, 0, { type = "SkillPart", skillPart = 2 }),
	mod("Multiplier:烧毁MaxStages", "BASE", tonumber(num), 0, 0, { type = "SkillPart", skillPart = 3 })	} end,
	["寒冬宝珠的最大等阶 %+(%d+)"] = function(num) return { mod("Multiplier:寒冬宝珠MaxStagesAfterFirst", "BASE", num) } end,
	["%+(%d+) 【寒冬宝珠】最大阶"] = function(num) return { mod("Multiplier:寒冬宝珠MaxStagesAfterFirst", "BASE", num) } end,
	["冬潮烙印 %+(%d+) 最大层数"] = function(num) return { mod("Multiplier:冬潮烙印MaxStages", "BASE", num, { type = "SkillName", skillName = "冬潮烙印" }) } end,
	["生命偷取在满血时恢复能量护盾"] = {
	flag("ImmortalAmbition", { type = "Condition", var = "FullLife" }, { type = "Condition", var = "LeechingLife"} ),
	},
	["在药剂持续期间，击败敌人会补充 (%d+)%% 的生命"] = function(num) return { mod("LifeOnKill", "BASE", 1, { type = "PerStat", stat = "Life", div = 100 / num }, { type = "Condition", var = "UsingFlask" } )
	} end,
	["在药剂持续期间，击败敌人会补充 (%d+)%% 的魔力"] = function(num) return { mod("ManaOnKill", "BASE", 1, { type = "PerStat", stat = "Mana", div = 100 / num }, { type = "Condition", var = "UsingFlask" } )
	} end,
	["在药剂持续期间，击败敌人会补充 (%d+)%% 的能量护盾"] = function(num) return { mod("EnergyShieldOnKill", "BASE", 1,  { type = "PerStat", stat = "EnergyShield", div = 100 / num }, { type = "Condition", var = "UsingFlask" } )
	} end,
	["药剂持续期间，你的技能不消耗魔力"] = { mod("ManaCost","MORE",-100, { type = "Condition", var = "UsingFlask" } ) },
	["从药剂获得的生命回复同样作用于能量护盾"] = { flag("LifeFlaskAppliesToEnergyShield", { type = "Condition", var = "UsingFlask" } ) },
	["立即回复 (%d+)%% 回复量"] = function(num) return { mod("FlaskInstantRecovery", "BASE", num) } end,
	["立即回复(%d+)%% 回复量"] = function(num) return { mod("FlaskInstantRecovery", "BASE", num) } end,
	["incinerate has %+(%d+) to maximum stages"] = function(num) return { mod("Multiplier:IncinerateMaxStages", "BASE", num, { type = "SkillName", skillName = "烧毁" }) } end,
	["召唤生物持续时间延长 (%d+)%%"] = function(num) return { mod("Duration", "INC", num,{ type = "SkillType", skillType = SkillType.CreateMinion }) } end,
	["力量属性对近战攻击和投射物的攻击物理伤害均会加成"] = { flag("IronGrip") }, 
	["投射物攻击伤害可以同样获得力量伤害奖励"] = { flag("IronGrip") },
	["总混沌伤害额外提高 (%d+)%%"] = function(num) return { mod("ChaosDamage", "MORE", num) } end,
	["总混沌伤害总增 (%d+)%%"] = function(num) return { mod("ChaosDamage", "MORE", num) } end,
	["总冰霜伤害额外提高 (%d+)%%"] = function(num) return { mod("ColdDamage", "MORE", num) } end,
	["总冰霜伤害总增 (%d+)%%"] = function(num) return { mod("ColdDamage", "MORE", num) } end,
	["暴击造成流血时也会造成撕裂"] = function() return {
			flag("Condition:CanInflictRupture", { type = "Condition", neg = true, var = "NeverCrit"}),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanInflictRupture" }), -- Make the Configuration option appear
		} end,
	["施加流血的暴击同样施加残破效果"] = function() return {
			flag("Condition:CanInflictRupture", { type = "Condition", neg = true, var = "NeverCrit"}),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanInflictRupture" }), -- Make the Configuration option appear
		} end,
	["你的咒印效果效果提高 (%d+)%%"] = function(num) return { mod("CurseEffect", "INC", num,{ type = "SkillType", skillType = SkillType.Mark }) } end,
	["你和周围友军具有提速尾流效果"] = { mod("ExtraAura", "LIST", { mod = flag("Condition:Tailwind") }) }, 
	["你使用技能时获得 1 个飓风之力"] = { 
	flag("Condition:CanGainGaleForce"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainGaleForce" }), -- Make the Configuration option appear
	 }, 
	["每个飓风之力使你身上的提速尾流效果提高 (%d+)%%"] = function(num) return { 
	mod("TailwindEffectOnSelf", "INC", num,{ type = "Multiplier", var = "GaleForce" }) } end,
	["每个飓风之力都使承受的伤害总降 (%d+)%%"] = function(num) return { 
	mod("DamageTaken", "MORE", -num,{ type = "Multiplier", var = "GaleForce" }) } end,
	["对抗传奇敌人时，击中和异常状态伤害总增 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "RareOrUnique" }) } end,
	["偷取时免疫晕眩"] = function() return {  mod("AvoidStun", "BASE", 100,{ type = "Condition", var = "Leeching" })  } end,
	["获得等同双倍力量数值的命中值"] = function() return { mod("Accuracy", "BASE", 2,{ type = "PerStat", stat = "Str", div = 1 }) } end,
	["获得等同于你力量值的命中值"] = function() return { mod("Accuracy", "BASE", 1,{ type = "PerStat", stat = "Str", div = 1 }) } end,
	["你创建的奉献地面可使你和周围友军免疫元素异常"] = function() return {
	 mod("ExtraAura", "LIST", { mod = mod("AvoidShock", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" })  }),
	 mod("ExtraAura", "LIST", { mod = mod("AvoidChilled", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" })  }),
	 mod("ExtraAura", "LIST", { mod = mod("AvoidFrozen", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" })  }),
	 mod("ExtraAura", "LIST", { mod = mod("AvoidIgnite", "BASE", 100,{ type = "Condition", var = "OnConsecratedGround" })  }),
	 }end,
	["被你点燃的敌人承受的点燃伤害由火焰伤害替换为混沌伤害"] = { flag("IgniteToChaos") },
	["被你点燃的敌人承受混沌伤害来代替火焰伤害"] = { flag("IgniteToChaos") },
	["你施加的曝露效果会使受影响的抗性额外 (%-?%d+)%%"] = function(num) return { mod("ExtraExposure", "BASE", num) } end,
	["若近期内你施加过曝露效果，则每秒再生 (%d+)%% 魔力"] = function(num) return { 
	mod("ManaRegenPercent", "BASE", num,{ type = "Condition", var = "AppliedExposureRecently" }) } end,
	["你击中传奇敌人时获得汇聚效果，每 %d+ 秒触发一次"] = { 
			flag("Condition:CanGainConvergence"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainConvergence" }) -- Dummy mod so it appears on config tab
		},
	["你没有汇聚效果时，效果区域扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "Condition", neg = true, var = "Convergence" }) } end,
	["战斗法师"] = { flag("WeaponDamageAppliesToSpells"), mod("ImprovedWeaponDamageAppliesToSpells", "INC", 100) },
	["抵达狂热球数量上限时，获得 4 秒欣喜若狂效果"] =function() return {
	flag("Condition:CanGainFanaticism"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainFanaticism" })
	} end ,
	["在力量和智慧中取低的那一个，每一点都使暴击率提高 (%d+)%%"] = function(num) return { 
			mod("CritChance", "INC", num, { type = "PerStat", stat = "Str" }, { type = "Condition", var = "IntHigherThanStr" }), 
			mod("CritChance", "INC", num, { type = "PerStat", stat = "Int" }, { type = "Condition", neg = true, var = "IntHigherThanStr" }) 
		} end,
	["你创建的奉献地面可使你和友军的生命再生效果也回复到能量护盾"] = function(num) return { 
			flag("LifeRegenerationRecoversEnergyShield", { type = "Condition", var = "OnConsecratedGround"}),
			mod("MinionModifier", "LIST", { mod = flag("LifeRegenerationRecoversEnergyShield", { type = "Condition", var = "OnConsecratedGround"}) })
		} end,
	["你在过去 8 秒内施放的每个非立即施放法术都使攻击伤害总增 (%d+)%%，最多 (%d+)%%"] = function(num, _, max) return { 
			mod("Damage", "MORE", num, nil, ModFlag.Attack, { type = "Multiplier", var = "CastLast8Seconds", limit = max, limitTotal = true}),	
		} end,
	["若你击中的最高伤害类型为火焰，则你施加的点燃伤害总增 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, nil, 0, KeywordFlag.Ignite, { type = "Condition", var = "FireIsHighestDamageType" } ) } end,
	["若你击中的最高伤害类型为冰霜，则你施加的总冰霜异常状态效果总增 (%d+)%%"] = function(num) return { mod("EnemyChillEffect", "MORE", num, { type = "Condition", var = "ColdIsHighestDamageType" } ) } end,
	["若你击中的最高伤害类型为闪电，则你施加的总闪电异常状态效果总增 (%d+)%%"] = function(num) return { mod("EnemyShockEffect", "MORE", num, { type = "Condition", var = "LightningIsHighestDamageType" } ) } end,
	["你的击中始终具有点燃效果"] = { mod("EnemyIgniteChance", "BASE", 100) },
	["你的击中始终具有感电效果"] = { mod("EnemyShockChance", "BASE", 100) },
	["所有伤害均可点燃"] = {
		flag("PhysicalCanIgnite"),
		flag("ColdCanIgnite"),
		flag("LightningCanIgnite"),
		flag("ChaosCanIgnite")
	},
	["所有击中的伤害都有冰缓效果"] = {
		flag("PhysicalCanChill"),
		flag("FireCanChill"),
		flag("LightningCanChill"),
		flag("ChaosCanChill")
		},
	["所有伤害均可感电"] = {
		flag("PhysicalCanShock"),
		flag("FireCanShock"),
		flag("ColdCanShock"),
		flag("ChaosCanShock")
	},	
	["你使用技能时获得热情牺牲效果，每秒造成等于其魔力消耗 %d+%% 的物理伤害"] = {
			flag("Condition:SacrificialZeal"),
		},
	["你有热情牺牲时，击中压制 (%d+)%% 物理伤害减免"] = function(num) return {
			mod("EnemyPhysicalDamageReduction", "BASE", -num, nil, { type = "Condition", var = "SacrificialZeal" }),
		} end,
	["每穿透 1 个敌人，投射物的伤害就提高 (%d+)%%"] = function(num) return {
			mod("Damage", "INC", num, nil, ModFlag.Projectile,  { type = "PerStat", stat = "PiercedCount" }),
		} end,
	["被格挡的攻击对你造成 (%d+)%% 伤害"] = function(num) return { mod("BlockEffect", "BASE", num) } end,
	["每 (%d+) 点命中值都附加 (%d+) 到 (%d+) 点攻击闪电伤害"] = function(_,num1,num2,num3) return {
		mod("LightningMin", "BASE", tonumber(num2),nil,ModFlag.Attack , { type = "PerStat", stat = "Accuracy", div = tonumber(num1) }),
		mod("LightningMax", "BASE", tonumber(num3),nil,ModFlag.Attack , { type = "PerStat", stat = "Accuracy", div = tonumber(num1) }),
		} end,
	["总命中值额外降低 (%d+)%%"] = function(num) return { mod("Accuracy", "MORE", -num) } end,	
	["位移技能的的冷却恢复速度提高 (%d+)%%"]= function(num) return {  mod("CooldownRecovery", "INC", num,{ type = "SkillType", skillType = SkillType.MovementSkill })  } end,
	["主手攻击伤害降低 (%d+)%%"] = function(num) return { mod("Damage", "INC", -num,nil,ModFlag.Attack ,{ type = "Condition", var = "MainHandAttack" } ) } end,	
	["副手攻击伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,ModFlag.Attack ,{ type = "Condition", var = "OffHandAttack" } ) } end,	
	["增助攻击的伤害提高 (%d+)%%"] = function(num) return { mod("ExertIncrease", "INC", num, nil, ModFlag.Attack, 0) } end,
	["战吼技能冷却时间 %+(%d+) 秒"]= function(num) return {
		mod("CooldownRecovery", "BASE", num, nil, 0, KeywordFlag.Warcry)
		} end,
	["水源法球的伤害提高 (%d+)%%"]= function(num) return {
		mod("Damage", "INC", num, { type = "SkillId", skillId = "WaterSphere" })
		} end,
	["水源法球的脉冲频率加快 (%d+)%%"]= function(num) return {
		mod("HydroSphereFrequency", "INC", num, { type = "SkillId", skillId = "WaterSphere" })
		} end,
	["你被碾压了"] = function(num) return { mod("PhysicalDamageReduction", "BASE", -15) } end,
	["你每有一个暴击球便使召唤生物的暴击率提高 (%d+)%%"]= function(num) return { mod("MinionModifier", "LIST", 
	{ mod = mod("CritChance", "INC", num, { type = "Multiplier", var = "PowerCharge" , actor = "parent"} )})  } end,
	["召唤生物造成暴击后会在 5 秒内听到低语"] = {
	flag("Condition:MinionsCanHearTheWhispers"),
	mod("Dummy", "DUMMY", 1, { type = "Condition", var = "MinionsCanHearTheWhispers" }) -- Make the Configuration option appear
	},
	["若你近期内没有获得狂怒球，则攻击速度加快 (%d+)%%"]= function(num) return {
		mod("Speed", "INC", num,nil, ModFlag.Attack, { type = "Condition", var = "GainedFrenzyChargeRecently", neg = true } )
		} end,
	["若你近期内没有获得暴击球，则暴击率提高 (%d+)%%"]= function(num) return {
		mod("CritChance", "INC", num,nil, ModFlag.Attack,{ type = "Condition", var = "GainedPowerChargeRecently", neg = true }  )
		} end,
	["(%d+)%% 的几率躲避法术击中"]= function(num) return {
		mod("SpellDodgeChance", "BASE", num )
		} end,	
	["若过去 8 秒内你造成过暴击，则每秒生命再生 ([%d%.]+)%%"]= function(num) return {  mod("LifeRegenPercent", "BASE", num,{ type = "Condition", var = "CritRecently" })  } end,
	["对抗被诅咒的敌人时，击中和异常状态伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,0,bor(KeywordFlag.Hit, KeywordFlag.Ailment) ,{ type = "ActorCondition", actor = "enemy", var = "Cursed" }) } end,
	["每 (%d+) 点力量都使护甲降低 (%d+)%%"] = function(_,num1,num2) return {  
	mod("Armour", "INC", -tonumber(num2),{ type = "PerStat", stat = "Str", div = tonumber(num1) })  } end,
	["提供 (%d+) 级精神失常"]= function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="Unhinge", level = tonumber(num)})   
		} end,	
	["疯狂状态下，总暴击率额外提高 (%d+)%%"] = function(num) return {  mod("CritChance", "MORE", num,{ type = "Condition", var = "InSaneInsanity" })  } end,
	["疯狂状态下，总暴击率总增 (%d+)%%"] = function(num) return {  mod("CritChance", "MORE", num,{ type = "Condition", var = "InSaneInsanity" })  } end,
	["理智状态下，承受的物理和混沌总伤害额外降低 (%d+)%%"] = function(num) return {  
	mod("PhysicalDamageTaken", "MORE", -num,{ type = "Condition", var = "SaneInsanity" }),
	mod("ChaosDamageTaken", "MORE", -num,{ type = "Condition", var = "SaneInsanity" }),
	  } end,
	["理智状态下，承受的物理和混沌伤害总降 (%d+)%%"] = function(num) return {  
	mod("PhysicalDamageTaken", "MORE", -num,{ type = "Condition", var = "SaneInsanity" }),
	mod("ChaosDamageTaken", "MORE", -num,{ type = "Condition", var = "SaneInsanity" }),
	  } end,
	["在药剂生效期间，你造成的中毒总伤害有 (%d+)%% 几率额外提高 (%d+)%%"] = function(num, _, more) return { mod("Damage", "MORE", tonumber(more) * num / 100, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "UsingFlask" }) } end,
	["在药剂生效期间，你造成的中毒总伤害有 (%d+)%% 的几率额外提高 (%d+)%%"] = function(num, _, more) return { mod("Damage", "MORE", tonumber(more) * num / 100, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "UsingFlask" }) } end,
	["在药剂生效期间，你造成的中毒效果有 (%d+)%% 几率伤害提高 (%d+)%%"] = function(num, _, more) return {  mod("Damage", "MORE", tonumber(more) * num / 100,nil,nil,KeywordFlag.Poison ,{ type = "Condition", var = "UsingFlask" }) } end,
	["在药剂生效期间，你造成的中毒效果有 (%d+)%% 的几率伤害提高 (%d+)%%"] = function(num, _, more) return {  mod("Damage", "MORE", tonumber(more) * num / 100,nil,nil,KeywordFlag.Poison ,{ type = "Condition", var = "UsingFlask" }) } end,
	["使用此武器攻击所造成的中毒效果有 (%d+)%% 的几率使中毒伤害提高 (%d+)%%"] = function(num, _, more) return {
			mod("Damage", "MORE", tonumber(more) * num / 200, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "DualWielding"}, { type = "SkillType", skillType = SkillType.Attack }),
			mod("Damage", "MORE", tonumber(more) * num / 100, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "DualWielding", neg = true }, { type = "SkillType", skillType = SkillType.Attack })
		} end,
	["使用此武器攻击所造成的流血效果有 (%d+)%% 的几率使流血伤害提高 (%d+)%%"] = function(num, _, more) return {
			mod("Damage", "MORE", tonumber(more) * num / 200, nil, 0, KeywordFlag.Bleed, { type = "Condition", var = "DualWielding"}, { type = "SkillType", skillType = SkillType.Attack }),
			mod("Damage", "MORE", tonumber(more) * num / 100, nil, 0, KeywordFlag.Bleed, { type = "Condition", var = "DualWielding", neg = true }, { type = "SkillType", skillType = SkillType.Attack })
		} end,
	["若你近期内击中敌人，则每秒回复 ([%d%.]+)%% 能量护盾"] = function(num) return {  
	mod("EnergyShieldRegenPercent", "BASE", num, { type = "Condition", var = "HitRecently"})  } end,
	["若你近期内击中敌人，则每秒回复 ([%d%.]+)%% 魔力"] = function(num) return {  
	mod("ManaRegenPercent", "BASE", num, { type = "Condition", var = "HitRecently"})  } end,
	["(%d+)%% 的几率免疫中毒"]= function(num) return { mod("AvoidPoison", "BASE", num ) } end,
	["(%d+)%% 的几率免疫流血"]= function(num) return { mod("AvoidBleed", "BASE", num ) } end,
	["(%d+)%% 的几率免疫点燃"]= function(num) return { mod("AvoidIgnite", "BASE", num ) } end,
	["施法时有 (%d+)%% 的几率免疫晕眩打断"] = function(num) return { mod("AvoidInteruptStun", "BASE", num) } end,
	["(%d+)%% 的几率免疫投射物"]= function(num) return {
		mod("AvoidProjectilesChance", "BASE", num ) ,
		} end,
	["攻击击中时有 (%d+)%% 的几率穿刺敌人"]= function(num) return {
		mod("ImpaleChance", "BASE", num, 0, 0, KeywordFlag.Attack)
		}end,
	["对被点燃敌人附加 (%d+) %- (%d+) 基础火焰伤害"]= function(_,num1,num2) return {
		mod("FireMin", "BASE", tonumber(num1),  { type = "ActorCondition", actor = "enemy", var = "Ignited" } ),
		mod("FireMax", "BASE", tonumber(num2),  { type = "ActorCondition", actor = "enemy", var = "Ignited" } ),
		} end,
	["对被冰缓或被冰冻敌人附加 (%d+) %- (%d+) 基础冰霜伤害"]= function(_,num1,num2) return {
		mod("ColdMin", "BASE", tonumber(num1),  { type = "ActorCondition",actor = "enemy", varList = { "Frozen", "Chilled" } } ),
		mod("ColdMax", "BASE", tonumber(num2),  { type = "ActorCondition",actor = "enemy", varList = { "Frozen", "Chilled" } } ),
		} end,
	["闪电伤害击中时有 (%d+)%% 的几率使敌人受到感电效果影响"]= function(num) return {
		mod("EnemyShockChance", "BASE", num)
		}end,
	["对被感电敌人附加 (%d+) %- (%d+) 基础闪电伤害"]= function(_,num1,num2) return {
		mod("LightningMin", "BASE", tonumber(num1),  { type = "ActorCondition", actor = "enemy", var = "Shocked" } ),
		mod("LightningMax", "BASE", tonumber(num2),  { type = "ActorCondition", actor = "enemy", var = "Shocked" } ),
		} end,
	["有 (%d+)%% 的几率以双倍护甲防御"] = function(num) return { mod("DoubleArmourChance", "BASE", num ) } end,
	["%+(%d+)%% 闪避攻击击中率"] = function(num) return { mod("Evasion", "BASE", num ) } end,
	["若你近期内被击中，则攻击速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", num,nil, ModFlag.Attack, { type = "Condition", var = "BeenHitRecently" }) } end,
	["效果区域扩大 (%d+)%%"] = function(num) return { mod("AreaOfEffect", "INC", num) } end,
	["无法回复，也无法补充"] = { flag("NoEnergyShieldRecharge"), flag("NoEnergyShieldRegen") },
	["能量护盾每秒损失 (%d+)%%"] = function(num) return { mod("EnergyShieldDegen", "BASE", 1, { type = "PercentStat", stat = "EnergyShield", percent = num }) } end,
	["满血时无法移除生命偷取效果"] = { flag("CanLeechLifeOnFullLife") },
	["生命偷取在满血时恢复能量护盾"] = { flag("ImmortalAmbition", { type = "Condition", var = "FullLife" }, { type = "Condition", var = "LeechingLife"}) },
	["未保留的生命全满时不会移除生命偷取效果"] = { flag("CanLeechLifeOnFullLife") },
	["攻击带来的能量护盾偷取效果不会在能量护盾全满时移除"] = { flag("CanLeechLifeOnFullEnergyShield") },
	["无法自动回复能量护盾" ] = { flag("NoEnergyShieldRegen") },
	["左戒指栏位：不能再生能量护盾"] = { flag("NoEnergyShieldRecharge", { type = "SlotNumber", num = 1 }), flag("NoEnergyShieldRegen", { type = "SlotNumber", num = 1 }) },
	["左戒指栏位：不能回复能量护盾"] = { flag("NoEnergyShieldRecharge", { type = "SlotNumber", num = 1 }), flag("NoEnergyShieldRegen", { type = "SlotNumber", num = 1 }) },
	["无法获得能量护盾"] = { flag("NoEnergyShieldRegen"), flag("NoEnergyShieldRecharge"), flag("CannotLeechEnergyShield") },
	["获得 (%d+) 级的【疯狂之拥】技能"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="EmbraceMadness", level = tonumber(num)})   
		} end,	
	["暴击时触发 (%d+) 级的【奉献】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="TriggeredConsecrate", level = tonumber(num), triggered = true})   
		} end,	
	["受【疯狂荣光】影响时，所有伤害都施加【中毒】"] = function(num) return { 
	flag("FireCanPoison", { type = "Condition", var = "AffectedBy疯狂荣光" } ) ,
		flag("ColdCanPoison", { type = "Condition", var = "AffectedBy疯狂荣光" } ) ,
		flag("LightningCanPoison", { type = "Condition", var = "AffectedBy疯狂荣光" })	
	 } end,
	["受【疯狂荣光】影响时，免疫元素异常状态"] = function() return { 
	mod("AvoidChill", "BASE", num,{ type = "Condition", var = "AffectedBy疯狂荣光" } ),
		mod("AvoidFreeze", "BASE", num,{ type = "Condition", var = "AffectedBy疯狂荣光" } ),
		mod("AvoidIgnite", "BASE", num,{ type = "Condition", var = "AffectedBy疯狂荣光" } ),
		mod("AvoidShock", "BASE", num,{ type = "Condition", var = "AffectedBy疯狂荣光" } ),	
	 } end,
	["受【疯狂荣光】影响时，你身上的【护体】效果提高 (%d+)%%"] = function(num) return { 
	 mod("FortifyEffectOnSelf", "INC", tonumber(num),{ type = "Condition", var = "AffectedBy疯狂荣光" })  } end,
	["受【疯狂荣光】影响时有 (%d+)%% 几率造成双倍伤害"] = function(num) return { 
	 mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy疯狂荣光" })  } end,
	["受【疯狂荣光】影响时有 (%d+)%% 的几率造成双倍伤害"] = function(num) return { 
	 mod("DoubleDamageChance", "BASE", tonumber(num),{ type = "Condition", var = "AffectedBy疯狂荣光" })  } end,
	["装备时触发 (%d+) 级的主动技能【失明光环】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="CastAuraBlinding", level = tonumber(num), triggered = true})   
		} end,	
	["装备时触发 (%d+) 级的主动技能【失明光环】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="CastAuraBlinding", level = tonumber(num), triggered = true})   
		} end,	
	["每 5 秒触发 (%d+) 级的【血肉盛宴】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="FeastOfFlesh", level = tonumber(num), triggered = true})   
		} end,	
	["插槽内的技能石被 (%d+) 级的 闪电支配 辅助"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = 'SupportOnslaughtOnSlayingShockedEnemy', level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["格挡时回复 (%d+)%% 最大生命"] = function(num) return { mod("LifeOnBlock", "BASE", 1,  { type = "PerStat", stat = "Life", div = 100 / num }) } end,
	["%−(%d+)%% 全部抗性上限"] = function(num) return { 
	mod("FireResistMax", "BASE", -num),
	mod("ColdResistMax", "BASE", -num),
	mod("LightningResistMax", "BASE", -num),
	mod("ChaosResistMax", "BASE", -num)
	} end,
	["提供 (%d+) 级鲜血渴求技能"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="VampiricIcon", level = tonumber(num)})   
		} end,	
	["用该武器击中时，流血的持续伤害加成 %+(%d+)%%"]= function(num) return {
		mod("DotMultiplier", "BASE", num / 2, nil, 0, KeywordFlag.Bleed, { type = "Condition", var = "DualWielding"}, { type = "SkillType", skillType = SkillType.Attack }),
			mod("DotMultiplier", "BASE", num, nil, 0, KeywordFlag.Bleed, { type = "Condition", var = "DualWielding", neg = true }, { type = "SkillType", skillType = SkillType.Attack })
		} end,
	["调整暴击球数量下限的词缀改为调整榨取球数量下限"] = { flag("MinimumAbsorptionChargesModInsteadToMinimumPowerCharges") },
	["调整狂怒球数量下限词缀改为调整痛苦球数量下限"] = { flag("MinimumAfflictionChargesModInsteadToMinimumFrenzyCharges") },
	["调整耐力球数量下限的词缀改为调整残暴球数量下限"] = { flag("MinimumBrutalChargesModInsteadToMinimumEnduranceCharges") },
	["榨取球数量上限等于暴击球数量上限"] = { flag("MaximumAbsorptionChargesIsMaximumPowerCharges") },
	["痛苦球数量上限等于狂怒球数量上限"] = { flag("MaximumAfflictionChargesIsMaximumFrenzyCharges") },
	["残暴球数量上限等于耐力球数量上限"] = { flag("MaximumBrutalChargesIsMaximumEnduranceCharges") },
	["获得榨取球替代暴击球"] = { 
	flag("GainAbsorptionChargesInsteadPowerCharges"),
	mod("PowerCharges", "OVERRIDE", 0),
	flag("Condition:CanGainAbsorptionCharges"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainAbsorptionCharges" }) 
	 },
	["获得痛苦球替代狂怒球"]  = { 
	flag("GainAfflictionChargesInsteadFrenzyCharges"),
	mod("FrenzyCharges", "OVERRIDE", 0),
	flag("Condition:CanGainAfflictionCharges"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainAfflictionCharges" }) 
	 },
	["获得残暴球替代耐力球"]  = { 
	flag("GainBrutalChargesInsteadEnduranceCharges"),
	mod("EnduranceCharges", "OVERRIDE", 0),
	flag("Condition:CanGainBrutalCharges"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainBrutalCharges" }) 
	 },
	["右戒指栏位：不能再生魔力"] = { flag("NoManaRegen", { type = "SlotNumber", num = 2 }) },
	["右戒指栏位：不能回复魔力"] = { flag("NoManaRegen", { type = "SlotNumber", num = 2 }) },
	["烙印伤害提高 (%d+)%%"]= function(num) return {
		mod("Damage", "INC", num ,{ type = "SkillType", skillType = SkillType.Brand } )
		} end,	
	["每失去 (%d+)%% 冰霜抗性，冰霜伤害就提高 (%d+)%%，最多提高 300%%"]= function(_,num1,num2) return {
		mod("ColdDamage", "INC", tonumber(num2),
		{ type = "Condition", var = "DualWielding", neg = true },
		{ type = "PerStat", stat = "MissingColdResist", div = tonumber(num1) ,	limit = 300, limitTotal = true }),
		mod("ColdDamage", "INC", tonumber(num2),
		{ type = "Condition", var = "DualWielding" },
		{ type = "PerStat", stat = "MissingColdResist", div = tonumber(num1) ,	limit = 150, limitTotal = true }),	
		} end,
	["每失去 (%d+)%% 火焰抗性，火焰伤害就提高 (%d+)%%，最多提高 300%%"]= function(_,num1,num2) return {
		mod("FireDamage", "INC", tonumber(num2),
		{ type = "Condition", var = "DualWielding", neg = true },
		{ type = "PerStat", stat = "MissingFireResist", div = tonumber(num1) ,limit =300, limitTotal = true } ) ,
		mod("FireDamage", "INC", tonumber(num2),
		{ type = "Condition", var = "DualWielding"},
		{ type = "PerStat", stat = "MissingFireResist", div = tonumber(num1) ,limit =150, limitTotal = true } ) ,	
		} end,
	["你击中被冻结的敌人时触发 (%d+) 级的【爆环冰刺】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="TriggeredIcicleNova", level = tonumber(num), triggered = true})   
		} end,	
	["你击败被冻结的敌人时触发 (%d+) 级的【爆环冰刺】"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="TriggeredIcicleNova", level = tonumber(num), triggered = true})   
		} end,	
	["你击中冻结的敌人时触发 (%d+) 级爆环冰刺"] = function(num) return {
	mod("ExtraSkill", "LIST", {  skillId ="TriggeredIcicleNova", level = tonumber(num), triggered = true})   
		} end,	
	["插入的主动技能石品质 %+(%d+)%%"] = function(num) return { mod("GemProperty", "LIST",  
	{ keyword = "active_skill", key = "quality", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["被击中时有 (%d+)%% 的几率避免冰霜伤害"]= function(num) return {	mod("AvoidColdDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免闪电伤害"]= function(num) return {	mod("AvoidLightningDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免火焰伤害"]= function(num) return {	mod("AvoidFireDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免混沌伤害"]= function(num) return {	mod("AvoidChoasDamageChance", "BASE", num )  } end,
	["被击中时有 (%d+)%% 的几率避免物理伤害"]= function(num) return {	mod("AvoidPhysicalDamageChance", "BASE", num )  } end,
	["若你近期内造成暴击，则附加 (%d+) to (%d+) 点冰霜伤害"] = function(_,num1,num2) return {
		mod("ColdMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("ColdMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) %- (%d+) 点冰霜伤害"] = function(_,num1,num2) return {
		mod("ColdMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("ColdMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) to (%d+) 点火焰伤害"] = function(_,num1,num2) return {
		mod("FireMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("FireMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) %- (%d+) 点火焰伤害"] = function(_,num1,num2) return {
		mod("FireMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("FireMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) to (%d+) 点闪电伤害"] = function(_,num1,num2) return {
		mod("LightningMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("LightningMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) %- (%d+) 点闪电伤害"] = function(_,num1,num2) return {
		mod("LightningMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("LightningMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) to (%d+) 点物理伤害"] = function(_,num1,num2) return {
		mod("PhysicalMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("PhysicalMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) %- (%d+) 点物理伤害"] = function(_,num1,num2) return {
		mod("PhysicalMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("PhysicalMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) to (%d+) 点混沌伤害"] = function(_,num1,num2) return {
		mod("ChaosMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("ChaosMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内造成暴击，则附加 (%d+) %- (%d+) 点混沌伤害"] = function(_,num1,num2) return {
		mod("ChaosMin", "BASE", num1, { type = "Condition", var = "CritRecently" }  ),
		mod("ChaosMax", "BASE", num2, { type = "Condition", var = "CritRecently" }  ) } end,
	["若你近期内没有被击中，则攻击和施法速度加快 (%d+)%%"] = function(num) return {  
	mod("Speed", "INC", num,{ type = "Condition", var = "BeenHitRecently", neg = true })  }
		end,
	["闪电异常状态效果提高 (%d+)%%"] = function(num) return {
		mod("EnemyShockEffect", "INC", num),
		mod("EnemySapEffect", "INC", num)
		} end,
	["冰霜异常状态效果提高 (%d+)%%"] = function(num) return {
		mod("EnemyFreezeEffect", "INC", num),
		mod("EnemyChillEffect", "INC", num),
		mod("EnemyBrittleEffect", "INC", num)
		} end,
	["火焰异常状态效果提高 (%d+)%%"] = function(num) return {
		mod("EnemyIgniteEffect", "INC", num),
		mod("EnemyScorchEffect", "INC", num)
		} end,
	["冻结敌人如同总伤害额外提高 (%d+)%%"] = function(num) return { mod("FreezeAsThoughDealing", "MORE", num ) } end,
	["战吼技能的效果区域扩大 (%d+)%%"]= function(num) return {
			mod("AreaOfEffect", "INC", num, nil, 0, KeywordFlag.Warcry)
			} end,
	["非低魔力时，攻击速度加快 (%d+)%%"] = function(num) return {  
	mod("Speed", "INC", num,nil, ModFlag.Attack,{ type = "Condition", var = "LowMana", neg = true })  }
		end,
	["每个耐力球可使效果区域扩大 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "INC", num,{ type = "Multiplier", var = "EnduranceCharge" })  } end,
	["你造成的中毒的伤害生效速度加快 (%d+)%%"]= function(num) return {
		mod("PoisonFaster", "INC", num)
		}end,
	["敌人身上每个穿刺效果都附加 (%d+) 到 (%d+) 点物理伤害"]= function (_,num1,num2) return {
	mod("PhysicalMin", "BASE", tonumber(num1),  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" }),
	mod("PhysicalMax", "BASE", tonumber(num2),  { type = "Multiplier", var = "ImpaleStack", actor = "enemy" })	
		} end,
	["若你近期内造成过暴击，则获得【提速尾流】"] = { flag("Condition:Tailwind") },
	["你身上的【提速尾流】效果提高 (%d+)%%"] = function(num) return { 
		mod("TailwindEffectOnSelf", "INC", num) } end,
	["%+(%d+)%% 躲避攻击击中几率上限"] = function(num) return {
		mod("AttackDodgeChanceMax", "BASE", num)	
		} end,
	["%+(%d+)%% 躲避法术击中几率上限"] = function(num) return {
		mod("SpellDodgeChanceMax", "BASE", num)	
		} end,
	["【召唤圣物】的冷却恢复速度降低 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST",
	 { mod = mod("CooldownRecovery", "INC", -num) },{ type = "SkillName", skillName = "召唤圣物" })  } end,
	["【毒蛇鞭击】有额外 (%d+) 次连锁弹射"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", num) }, { type = "SkillName", skillName = "毒蛇鞭击" }) } end,
	["你的击中将冰霜抗性视为比实际高 (%d+)%%"] = function(num) return {
			mod("ColdPenetration", "BASE", -num, nil, 0, KeywordFlag.Hit),
		} end,
	["移动时留下烧灼地面，持续 (%d+) 秒"] = { mod("ScorchBase", "BASE", 10, { type = "ActorCondition", actor = "enemy", var = "OnScorchedGround"} ) },
	["每个召唤的幻灵都给你【幽影之力】"] =  { flag("Condition:PhantasmalMight") },
	["%+(%d+)%% 品质"] = function(num) return { mod("Quality", "BASE", num) } end,
	["若你近期内受到伤害，则有 (%d+)%% 的几率躲避攻击和法术击中"] = function(num) return {  
	mod("AttackDodgeChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" }),
	mod("SpellDodgeChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" }),
	  } end,
	["承受的持续物理伤害效果降低 (%d+)%%"]= function(num) return {  mod("PhysicalDamageTakenOverTime", "INC", -tonumber(num))  } end,
	["若你近期内没被击中后受到伤害，则获得 ([%d%.]+)%% 物理伤害减免"]= function(num) return {  mod("PhysicalDamageReduction", "BASE", num,{ type = "Condition", var = "BeenHitRecently", neg = true })  } end,
	["若你近期内被击中并受到伤害，则 %+([%d%.]+)%% 的几率格挡法术伤害"]= function(num) return {  mod("SpellBlockChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" })  } end,
	["若你近期内没受到伤害，则移动速度提高 (%d+)%%"]= function(num) return {  mod("MovementSpeed", "INC", num,{ type = "Condition", var = "BeenHitRecently", neg = true  })  } end,
	["若你近期内因被击中而受伤，攻击伤害格挡几率 %+([%d%.]+)%%"]= function(num) return {  mod("BlockChance", "BASE", num,{ type = "Condition", var = "BeenHitRecently" })  } end,
	["若你近期内没有击败敌人，则命中值提高 (%d+)%%"]= function(num) return {  mod("Accuracy", "INC", num,{ type = "Condition", var = "KilledRecently", neg = true })  } end,
	["若你近期内或你的召唤生物击败过敌人，则召唤生物攻击和施法速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", num) }, { type = "Condition", varList = { "KilledRecently", "MinionsKilledRecently" } }) } end, 
	["若你近期内打出过暴击，则获得物理伤害 ([%d%.]+)%% 的额外火焰伤害"] = function(num) return {  mod("PhysicalDamageGainAsFire", "BASE", num, { type = "Condition", var = "CritRecently" })  } end,
	["召唤德瑞的塑像时，触发插入的魔蛊技能"] = { mod("ExtraSupport", "LIST", { skillId = "SupportCursePillarTriggerCurses", level = 20 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["提供 (%d+) 级召唤德瑞的塑像"]= function(num) return { mod("ExtraSkill", "LIST", { skillId = "CursePillar", level = num }) } end,
	["获得 (%d+) 级的的主动技能【召唤德瑞的塑像】技能"] = function(num) return { mod("ExtraSkill", "LIST", { skillId = "CursePillar", level = num }) } end,
	["【灵巧】效果下，不会受到暴击造成的额外伤害"] = function(num) return { mod("ReduceCritExtraDamage", "BASE", 100, { type = "Condition", var = "Elusive" }) } end,
	["受到的暴击伤害降低 (%d+)%%"] = function(num) return { mod("ReduceCritExtraDamage", "BASE", num) } end,
	["当你没有暴击球时，受到的暴击伤害降低 (%d+)%%"] = function(num) return { mod("ReduceCritExtraDamage", "BASE", num, { type = "StatThreshold", stat = "PowerCharges", threshold = 0, upper = true }) } end,
	["受到【坚定】影响时，你被暴击时受到的额外伤害降低 (%d+)%%"]= function(num) return {  mod("ReduceCritExtraDamage", "BASE", num,{ type = "Condition", var = "AffectedBy坚定" })  } end,
	["被你的战吼嘲讽的敌人受到的伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num, { type = "Condition", var = "Taunted" }) }, { type = "Condition", var = "UsedWarcryRecently" }) } end,
	["血量低于 (%d+)%% 的敌人被你的技能击中时，会直接被终结"] = function(num) return { mod("CullPercent", "MAX", num) } end,
	-- Culling
	["终结"] = { mod("CullPercent", "MAX", 10)},
	["该武器击中流血敌人时会获得【终结】效果"] = { mod("CullPercent", "MAX", 10, { type = "ActorCondition", actor = "enemy", var = "Bleeding" })},
	["你可以【终结】被诅咒的敌人"] = { mod("CullPercent", "MAX", 10, { type = "ActorCondition", actor = "enemy", var = "Cursed" })},
	["对被诅咒的敌人有【终结】效果"] = { mod("CullPercent", "MAX", 10, { type = "ActorCondition", actor = "enemy", var = "Cursed" })},
	["暴击拥有终结能力"] = { mod("CriticalCullPercent", "MAX", 10 )},
	["你的法术拥有【终结】效果"] = { mod("CullPercent", "MAX", 10, nil, ModFlag.Spell )},
	["终结燃烧中的敌人"] = { mod("CullPercent", "MAX", 10, { type = "ActorCondition", actor = "enemy", var = "Burning" })},
	["终结被标记的敌人"] = { mod("CullPercent", "MAX", 10, { type = "ActorCondition", actor = "enemy", var = "Marked" })},
	["靑春永驻"] = { mod("Keystone", "LIST", "青春永驻") },
	["青春永驻"] = { mod("Keystone", "LIST", "青春永驻") },
	["灭亡之日"] = { mod("Keystone", "LIST", "灭亡之日") },
	["攻击技能可以额外召唤 %+1 个弩炮图腾"] = function(num) return { mod("ActiveBallistaLimit", "BASE", 1, 
	{ type = "SkillType", skillType = SkillType.ProjectileAttack }) } end, -- Mark plz
	["攻击技能获得 %+1 召唤弩炮图腾数量上限"] = function(num) return { mod("ActiveBallistaLimit", "BASE", 1, 
	{ type = "SkillType", skillType = SkillType.ProjectileAttack }) } end, -- Mark plz
	["药剂持续期间，能量护盾充能速度提高 (%d+)%%"]= function(num) return {mod("EnergyShieldRecharge", "INC", num,{ type = "Condition", var = "UsingFlask" })
	 } end,
	["【将军之吼】 ([%+%-]%d) 蜃影武士数量上限"] = function(num) return { mod("GeneralsCryDoubleMaxCount", "BASE", num) } end,
	["装备时触发等级 20 的反射"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="UniqueMirageWarriors", level = 20, triggered = true})   } end,
	["当你攻击时触发一个插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["当你使用此武器攻击时触发一个插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["使用技能时触发一个插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnSkillUse", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["专注时，你有 (%d+)%% 的几率触发插槽内的法术"]  = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellFromHelmet", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "Condition", var = "Focused" }) } end,
	["你在专注时触发插入的法术，它有 0.25 秒冷却时间"]  = function() return { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellFromHelmet", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "Condition", var = "Focused" }) } end,
	["专注时触发插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellFromHelmet", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "Condition", var = "Focused" }) },
	["当你使用弓箭攻击时触发一个插槽内的弓类法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerBowSkillOnBowAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["你用弓类攻击时触发一个插入的弓类技能，它有1 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerBowSkillOnBowAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["当你用弓攻击时触发一个插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnBowAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["当你用弓攻击时，触发一个插槽内的法术"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnBowAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["你用弓类攻击时触发一个插入的法术，它有 0.3 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnBowAttack", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["使用至少 (%d+) 魔力施放技能时，有 (%d+)%% 的几率触发插槽内的法术"]  = function(amount, _, num) return {
		mod("KitavaTriggerChance", "BASE", num, "奇塔弗之渴望"),
			mod("KitavaRequiredManaCost", "BASE", tonumber(amount), "奇塔弗之渴望"),
			mod("ExtraSupport", "LIST", { skillId = "SupportCastOnManaSpent", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }),
	 } end,
	["使用至少 (%d+) 魔力施放技能时，有 (%d+)%% 几率触发插槽内的法术"]  = function(amount, _, num) return {
	mod("KitavaTriggerChance", "BASE", num, "奇塔弗之渴望"),
			mod("KitavaRequiredManaCost", "BASE", tonumber(amount), "奇塔弗之渴望"),
			mod("ExtraSupport", "LIST", { skillId = "SupportCastOnManaSpent", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }),
	} end,
	["当你使用技能消耗至少 (%d+) 点魔力后有 (%d+)%% 几率触发插入的法术，它有 0.1 秒冷却时间"]  = function(amount, _, num) return {
	mod("KitavaTriggerChance", "BASE", num, "奇塔弗之渴望"),
			mod("KitavaRequiredManaCost", "BASE", tonumber(amount), "奇塔弗之渴望"),
			mod("ExtraSupport", "LIST", { skillId = "SupportCastOnManaSpent", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }),
	} end,
	["专注的冷却回复速度提高 (%d+)%%"] = function(num) return { mod("FocusCooldownRecovery", "INC", num, { type = "Condition", var = "Focused"}) } end,
	["【幻影射手】的持续时间延长 (%d+)%%"] = function(num) return { mod("MirageArcherDuration", "INC", num), } end,
	["幻影弓手持续时间延长 (%d+)%%"] = function(num) return { mod("MirageArcherDuration", "INC", num), } end,
	["召唤的幻影弓手数量上限 ([%-%+]%d+)"] = function(num) return { mod("MirageArcherMaxCount", "BASE", num),	} end,
	["你在目盲状态下，被你致盲的敌人受到【恶语术】影响"] = { mod("EnemyModifier", "LIST", { mod = flag("HasMalediction", { type = "Condition", var = "Blinded" }) }, { type = "Condition", var = "Blinded" } )},
	["你在【目盲】状态下，被你致盲的敌人受到【恶语术】影响"] = { mod("EnemyModifier", "LIST", { mod = flag("HasMalediction", { type = "Condition", var = "Blinded" }) }, { type = "Condition", var = "Blinded" } )},
	["使用非触发型技能发射箭矢时，消耗一枚【虚空之矢】可以触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["击中满血敌人时，将使他们永久受到威吓"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true)} )},
	-- Intimidate
	["格挡时永久恐吓敌人"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true)}, { type = "Condition", var = "BlockedRecently" } )},
	["当插槽内有 1 个【凶残之凝】珠宝时，攻击击中敌人会恐吓它们 (%d) 秒"] = function(jewelName, num) return  { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true)}, { type = "Condition", var = "HaveMurderousEyeJewelIn{SlotName}" }) } end,
	["周围的敌人会被恐吓"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true)} )},
	["对被你战吼所嘲讽的敌人造成恐吓"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true, { type = "Condition", var = "Taunted" }) }, { type = "Condition", var = "UsedWarcryRecently" }) },
	["被你的战吼嘲讽的敌人同时被【恐吓】"] = { mod("EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true, { type = "Condition", var = "Taunted" }) }, { type = "Condition", var = "UsedWarcryRecently" }) },
	["击中被你恐惧的敌人时，法术暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,nil, ModFlag.Spell,{ type = "ActorCondition", actor = "enemy", var = "Unnerved" })  } end,
	["对抗被你恐吓的敌人时，它们的眩晕持续时间延长 (%d+)%%"]= function(num) return {  mod("EnemyStunDuration", "INC", num,{ type = "ActorCondition", actor = "enemy", var = "Intimidated" })  } end,
	["来自插入技能的魔蛊无视诅咒限制"] = { flag("CursesIgnoreHexLimit", { type = "SocketedIn", slotName = "{SlotName}" } )},
	 ["【奥术斗篷】获得生命回复，等于每秒消耗魔力的 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("LifeRegen", "BASE", num / 100, 0, 0, { type = "Multiplier", var = "ArcaneCloakConsumedMana" }, { type = "GlobalEffect", effectType = "Buff" }) }, { type = "SkillName", skillName = "Arcane Cloak" }) } end,
	["钢铁之肤可以承受的伤害提高 (%d+)%%"] = function(num) return { mod("ExtraSkillStat", "LIST", { key = "steelskin_damage_limit_+%", value = num }, { type = "SkillName", skillName = "Steelskin" }) } end,
	["不会被晕眩"] = function() return {  mod("AvoidStun", "BASE", 100)  } end,
	["伤害无法被反射"] = { mod("ElementalReflectedDamageTaken", "MORE", -100),mod("PhysicalReflectedDamageTaken", "MORE", -100) },
	["混沌抗性为零"] = function() return {  mod("ChaosResist", "OVERRIDE", 0)  } end,
	["混沌抗性归零"] = function() return {  mod("ChaosResist", "OVERRIDE", 0)  } end,
	["没有能量护盾"] = { mod("ArmourData", "LIST", { key = "EnergyShield", value = 0 }) }, 
	["静止时每秒回复 ([%d%.]+)%% 最大生命"] = function(num, _, limit) return {		
			mod("LifeRegenPercent", "BASE", num, { type = "Condition", var = "Stationary" }),
		} end,
	-- Pantheon: Soul of Tukohama support
		["静止时，每秒获得 ([%d%.]+)%% 每秒生命回复，最多 (%d+)%%"] = function(num, _, limit) return {
			flag("Condition:Stationary"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "Stationary" }), -- Make the Configuration option appear 
			mod("LifeRegenPercent", "BASE", num, { type = "Multiplier", var = "StationarySeconds", limit = tonumber(limit), limitTotal = true }),
		} end,
	-- Pantheon: Soul of Tukohama support
		["静止时，每秒获得 (%d+)%% 额外物理减伤，最多 (%d+)%%"] = function(num, _, limit) return {
			flag("Condition:Stationary"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "Stationary" }), -- Make the Configuration option appear 
			mod("PhysicalDamageReduction", "BASE", num, { type = "Multiplier", var = "StationarySeconds", limit = tonumber(limit), limitTotal = true }),
		} end,
	["静止时，每秒可使范围效果扩大 (%d+)%% ，最多 (%d+)%%"] = function(num, _, limit) return {
			flag("Condition:Stationary"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "Stationary" }), -- Make the Configuration option appear 
			mod("AreaOfEffect", "INC", num, { type = "Multiplier", var = "StationarySeconds", limit = tonumber(limit), limitTotal = true }),
		} end,
	["当静止时每秒获得 (%d+) 层缓速藤蔓"] = function(num) return {
			flag("Condition:Stationary"),
			mod("Dummy", "DUMMY", 1, { type = "Condition", var = "Stationary" }), -- Make the Configuration option appear
			mod("Multiplier:GraspingVinesCount", "BASE", num, { type = "Multiplier", var = "StationarySeconds", limit = 10, limitTotal = true }),
		} end,	
	["近期内若你停止受到持续伤害，则生命和能量护盾回复速度提高 (%d+)%%"] = function(num) return {  
		mod("LifeRecoveryRate", "INC", num,{ type = "Condition", var = "StoppedTakingDamageOverTimeRecently" }),
		mod("EnergyShieldRecoveryRate", "INC", num,{ type = "Condition", var = "StoppedTakingDamageOverTimeRecently" })
		} end,
	["若附近只有 1 个敌人，则受到的物理伤害降低 (%d+)%%"] = function(num) return {  
		mod("PhysicalDamageTaken", "INC", -num,{ type = "Condition", var = "OnlyOneNearbyEnemy" })	
		} end,	
	["若你近期内没有被击中，则受到的元素伤害降低 (%d+)%%"] = function(num) return {  
		mod("ElementalDamageTaken", "INC", -num,{ type = "Condition", var = "BeenHitRecently", neg = true })	
		} end,		
	["身边每存在 1 个敌人，受到的物理伤害便降低 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("PhysicalDamageTaken", "INC", -tonumber(num1), { type = "Multiplier", var = "NearbyEnemies", limit = tonumber(num2), limitTotal = true }  )  }end,
	["身边每有 1 个敌人，自己的移动速度提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("MovementSpeed", "INC", tonumber(num1), { type = "Multiplier", var = "NearbyEnemies", limit = tonumber(num2), limitTotal = true }  )  }end,
	["近期每受到 1 次伤害，下次承受的物理伤害減少 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("PhysicalDamageTaken", "INC", -tonumber(num1), { type = "Multiplier", var = "BeenHitRecently", limit = tonumber(num2), limitTotal = true } )  }end,
	["你和你的召唤生物受到的反射伤害降低 (%d+)%%"] = function(num) return { 
	mod("PhysicalReflectedDamageTaken", "BASE", -num),
	mod("ElementalReflectedDamageTaken", "BASE", -num),
	mod("MinionModifier", "LIST", { mod = mod("PhysicalReflectedDamageTaken", "BASE", -num) }) ,
	mod("MinionModifier", "LIST", { mod = mod("ElementalReflectedDamageTaken", "BASE", -num) }) 
	 } end,
	["若你近期内受到过伤害，则冰霜伤害降低 (%d+)%%"] = function(num) return { 
	mod("ColdDamageTaken", "INC", -num)
	 } end,
	["若你近期内受到过伤害，则承受的冰霜伤害降低 (%d+)%%"] = function(num) return { 
	mod("ColdDamageTaken", "INC", -num)
	 } end,
	["若你近期内受到【残暴打击】则 %+(%d+)%% 闪避攻击击中率"] = function(num) return { 
	mod("EvadeChance", "BASE", num,{ type = "Condition", var = "BeenSavageHitRecently" })
	 } end,
	["低血时，使用药剂会提高 (%d+)%% 生命回复量"] = function(num) return { 
	mod("FlaskLifeRecovery", "INC", num,{ type = "Condition", var = "LowLife" })
	 } end,
	["若你近期内没有被击中，则移动速度提高 (%d+)%%"] = function(num) return { 
	mod("MovementSpeed", "INC", num,{ type = "Condition", var = "BeenHitRecently", neg = true })
	 } end,
	["以光环形式施放时，【(.+)】的魔力保留降低 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("ManaReserved", "INC",-num, { type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["插入的技能石被 (%d+) 级的【(.+)】辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["持续物理伤害总增 (%d+)%%"] = function(num) return { 
	mod("PhysicalDamage", "MORE", num,nil,  ModFlag.Dot)
	 } end,
	["偷取的每秒最大生命总恢复量翻倍"] = { mod("MaxLifeLeechRate", "MORE", 100) },
	["偷取的每秒最大能量护盾总恢复量翻倍"] = { mod("MaxEnergyShieldLeechRate", "MORE", 100) },
	["每个暴击球可使范围效果扩大 (%d+)%%，最多扩大 (%d+)%%"] = function(num, _, limit) return {
			mod("VastPowerAoE", "INC", num),
			-- Maximum effect is handled in CalcPerform, VastPowerAoE is capped with a constant there.
	} end,
	["每个影响你的凶残之凝珠宝都使你的主手暴击率提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("MurderousEyeJewelCritChance", "INC", tonumber(num1)),
			-- Maximum effect is handled in CalcPerform, MurderousEyeJewelCritChance is capped with a constant there.
	} end,
	["每个影响你的凶残之凝珠宝都使你的副手暴击伤害加成 %+(%d+)，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("MurderousEyeJewelCritMultiplier", "BASE", tonumber(num1)),
			-- Maximum effect is handled in CalcPerform, MurderousEyeJewelCritChance is capped with a constant there.
	} end,
	-- Maximum effect is handled in CalcPerform, GhastlyEyeJewelMinionsDOTMultiplier is capped with a constant there.
	["每个影响你的苍白之凝珠宝都使召唤生物持续伤害加成%+(%d+)%%，最多 %+(%d+)%%"] = function(_,num1,num2)
	return { mod("MinionModifier", "LIST", { mod = mod("GhastlyEyeJewelMinionsDOTMultiplier", "BASE", tonumber(num1)) }) } end,
	["每个影响你的安睡之凝珠宝都使你身上的秘术增强效果提高 (%d+)%%，最多 (%d+)%%"] = function(_,num1,num2) return { 
	mod("HypnoticEyeJewelArcaneSurgeEffect", "INC", tonumber(num1)),
			-- Maximum effect is handled in CalcPerform, HypnoticEyeJewelArcaneSurgeEffect is capped with a constant there.
	} end,
	["移除所有魔力"] = { mod("Mana", "MORE", -100) },
	["技能消耗生命而非魔力"] = { flag("BloodMagicCost") },
	["技能保留生命而非魔力"] = { flag("BloodMagicReserved") },
	["技能效果需要消耗生命而非魔力"] = { },
	["技能优先消耗能量护盾，而非魔力"] = { },
	["消耗魔力的技能在消耗魔力前先消耗能量护盾"] = { },
	["被燃烧时免疫冰缓"] = { mod("AvoidChill", "BASE", 100, { type = "Condition", var = "Burning" }) },
	["旗帜类技能没有魔力保留"] = { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }) },
	["旗帜类技能没有资源保留"] = { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }) },
	["旗帜技能没有保留效果"] = { mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }) },
	--保留
	["技能的总保留额外降低 (%d+)%%"]= function(num) return {  mod("Reserved", "MORE", -num)  } end,
	["技能的总保留额外提高 (%d+)%%"]= function(num) return {  mod("Reserved", "MORE", num)  } end,
	["技能的保留效果总增 (%d+)%%"]= function(num) return {  mod("Reserved", "MORE", num)  } end,
	["投掷地雷类技能的保留降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num,{ type = "SkillType", skillType = SkillType.Mine }  )  } end,
	["诅咒光环类技能的保留降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num, { type = "SkillType", skillType = SkillType.Hex }   )  } end,
	["旗帜类技能的保留降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num,{ type = "SkillType", skillType = SkillType.Banner }  )  } end,
	["姿态类技能的保留降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num, { type = "SkillType", skillType = SkillType.StanceSkill } )  } end,
	["姿态技能的保留效果降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num, { type = "SkillType", skillType = SkillType.StanceSkill } )  } end,
	["捷技能的保留效果降低 (%d+)%%"]=function(num) return {  mod("Reserved", "INC", -num,{ type = "SkillType", skillType = SkillType.Herald }  )  } end,
	["以光环形式施放时，【(.+)】的保留降低 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("Reserved", "INC",-num, { type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	["【(.+)】的保留降低 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("Reserved", "INC",-num, { type = "SkillName", skillName =  FuckSkillActivityCnName(skill_name)}) } end,
	----消耗
	["持续吟唱类技能的资源消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num ,{ type = "SkillType", skillType = SkillType.Channelled} )  } end,
	["吟唱技能的消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num ,{ type = "SkillType", skillType = SkillType.Channelled} )  } end,
	["投掷陷阱类技能的资源消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num,{ type = "SkillType", skillType = SkillType.Trap}  )  } end,
	["投掷陷阱的技能消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num,{ type = "SkillType", skillType = SkillType.Trap}  )  } end,
	["技能资源消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num  )  } end,
	["技能消耗降低 (%d+)%%"]=function(num) return {  mod("Cost", "INC", -num  )  } end,
	["持续吟唱类技能的总资源消耗 %-(%d+)"]=function(num) return {  mod("Cost", "BASE", -num ,{ type = "SkillType", skillType = SkillType.Channelled} )  } end,
	["吟唱技能的总魔力消耗 %-(%d+)"]=function(num) return {  mod("ManaCost", "BASE", -num ,{ type = "SkillType", skillType = SkillType.Channelled} )  } end,
	--
	["若你近期内换过姿态，则攻击速度加快 (%d+)%%"]=function(num) return {  mod("Speed", "INC", num,nil, ModFlag.Attack,{ type = "Condition", var = "ChangedStanceRecently" } )  } end,
	["近期内你若晕眩过敌人，则每秒回复 ([%d%.]+)%% 生命"]=function(num) return {  mod("LifeRegenPercent ", "BASE", num,{ type = "Condition", var = "StunnedEnemyRecently" }  )  } end,
	["抗争状态下，偷取的每秒最大生命总恢复量提高 (%d+)%%"]=function(num) return {  mod("MaxLifeLeechRate", "INC", num,{ type = "MultiplierThreshold", var = "Defiance", threshold = 1 })  } end,
	["击中时有 (%d+)%% 的几率施放 (%d+) 级的【火焰爆破】"]= function(_, num,levelname,skill_name)return {   mod("ExtraSkill", "LIST", {  skillId ="FireBurstOnHit", level = tonumber(levelname), triggered = true})   } end,
	["击中施放 (%d+) 级火焰爆破"]= function(num)return {   mod("ExtraSkill", "LIST", {  skillId ="FireBurstOnHit", level = tonumber(num), triggered = true})   } end,
	["每 (%d+) 点最大生命或最大魔力（取其低值）附加 (%d+) 到 (%d+) 点火焰伤害"] = function(_,num1,num2,num3) return {
	mod("FireMin", "BASE", tonumber(num2),{ type = "PerStat", stat = "LowestOfLifeAndMana", div = tonumber(num1) }),
	mod("FireMax", "BASE", tonumber(num3),{ type = "PerStat", stat = "LowestOfLifeAndMana", div = tonumber(num1) }),
	} end,
	["若最大生命和最大魔力在 (%d+) 以内，则免受点燃或感电影响"]=function(num) return {  
	mod("AvoidIgnite", "BASE", 100 ,{ type = "StatThreshold", stat = "Mana", threshold = num} ,{ type = "StatThreshold", stat = "Life", threshold = num}  ),
	mod("AvoidShock", "BASE", 100 ,{ type = "StatThreshold", stat = "Mana", threshold = num} ,{ type = "StatThreshold", stat = "Life", threshold = num}  )
	  } end,
	["最大生命提高 (%d+)%%，并且火焰抗性等量降低"]=function(num) return {  
	mod("Life", "INC", num),
	mod("FireResist", "INC", -num)
	  } end,
	["最大魔力提高 (%d+)%%，并且冰霜抗性等量降低"]=function(num) return {  
	mod("Mana", "INC", num),
	mod("ColdResist", "INC", -num)
	  } end,
	["全局最大能量护盾提高 (%d+)%%，并且闪电抗性等量降低"]=function(num) return {  
	mod("EnergyShield", "INC", num,{ type = "Global" }),
	mod("LightningResist", "INC", -num)
	  } end, 
	["偷取的每秒最大生命总恢复量额外提高 (%d+)%%"]=function(num) return {  
	mod("MaxLifeLeechRate", "MORE", num)
	  } end,
	["偷取的每秒最大生命总恢复量总降 (%d+)%%"]=function(num) return {  
	mod("MaxLifeLeechRate", "MORE", -num)
	  } end,
	 ["偷取的每秒最大生命总恢复量额外降低 (%d+)%%"]=function(num) return {  
	mod("MaxLifeLeechRate", "MORE", -num)
	  } end,   
	["技能 %+(%d+) 点怒火消耗"]=function(num) return {  
	mod("RageCostBase", "BASE", num)
	  } end,
	["技能的怒火消耗降低 (%d+)%%"]=function(num) return {  
	mod("RageCostBase", "INC", -num)
	  } end,
	["技能消耗 %+(%d+) 点怒火"]=function(num) return {  
	mod("RageCostBase", "BASE", num)
	  } end,
	["弓类攻击附加 (%d+) 到 (%d+) 点物理伤害"] = function(_,num1,num2) return {
			mod("PhysicalMin", "BASE", num1,nil,bor(ModFlag.Bow, ModFlag.Hit)  ),
			mod("PhysicalMax", "BASE", num2,nil,bor(ModFlag.Bow, ModFlag.Hit)  ) } end,
	["弓类攻击附加 (%d+) 到 (%d+) 点火焰伤害"] = function(_,num1,num2) return {
			mod("FireMin", "BASE", num1,nil,bor(ModFlag.Bow, ModFlag.Hit)  ),
			mod("FireMax", "BASE", num2,nil,bor(ModFlag.Bow, ModFlag.Hit)  ) } end,
	["弓类攻击附加 (%d+) 到 (%d+) 点冰霜伤害"] = function(_,num1,num2) return {
			mod("ColdMin", "BASE", num1,nil,bor(ModFlag.Bow, ModFlag.Hit)  ),
			mod("ColdMax", "BASE", num2,nil,bor(ModFlag.Bow, ModFlag.Hit)  ) } end,
	["弓类攻击附加 (%d+) 到 (%d+) 点闪电伤害"] = function(_,num1,num2) return {
			mod("LightningMin", "BASE", num1,nil,bor(ModFlag.Bow, ModFlag.Hit)  ),
			mod("LightningMax", "BASE", num2,nil,bor(ModFlag.Bow, ModFlag.Hit)  ) } end,
	["弓类攻击附加 (%d+) 到 (%d+) 点混沌伤害"] = function(_,num1,num2) return {
			mod("ChaosMin", "BASE", num1,nil,bor(ModFlag.Bow, ModFlag.Hit)  ),
			mod("ChaosMax", "BASE", num2,nil,bor(ModFlag.Bow, ModFlag.Hit)  ) } end,
	["提供 (%d+) 级女王敕令"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="QueensDemand", level = num})   } end,
	["女王敕令可以触发 (%d+) 级审判烈焰"]= function(num) return triggerExtraSkillWithSource("审判烈焰", tonumber(num), "女王敕令") end,
	["女王敕令可以触发 (%d+) 级审判风暴"]= function( num) return triggerExtraSkillWithSource("审判风暴", tonumber(num), "女王敕令") end,
	["提供 (%d+) 级赤色誓言"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="BloodSacramentUnique", level = num})   } end,
	["你的暴击率在低血时特别幸运"] ={ flag("CritChanceLucky",  { type = "Condition", var = "LowLife" }) },
	["提供钢铁呼唤"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="ImpactingSteelReload", level = 1})   } end,
	["造成非物理伤害"] = {  flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire"), flag("DealNoChaos")  },
	["你身上每层中毒效果都使伤害提高 (%d+)%%，最大提升至 (%d+)%%"]= function(_,num1,num2) return {  mod("Damage", "INC", tonumber(num1),{ type = "Multiplier", var = "PoisonStack", limit = tonumber(num2), limitTotal = true })  } end,
	["你身上每层中毒效果都使移动速度加快 (%d+)%%，最大 (%d+)%%"]= function(_,num1,num2) return {  mod("MovementSpeed", "INC", tonumber(num1),{ type = "Multiplier", var = "PoisonStack", limit = tonumber(num2), limitTotal = true })  } end,
	["提高或降低召唤生物伤害的效果也作用于你自身，等于其数值的 (%d+)%%"] = function(num) return { flag("MinionDamageAppliesToPlayer"), mod("ImprovedMinionDamageAppliesToPlayer", "INC", num) } end,
	["召唤生物伤害提高或降低，将同样套用于自身，等于其数值的 (%d+)%%"] = function(num) return { flag("MinionDamageAppliesToPlayer"), mod("ImprovedMinionDamageAppliesToPlayer", "INC", num) } end,
	["插入的技能石没有保留效果"] = { mod("Reserved", "MORE", -100, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["你被脆弱诅咒时视为满血状态"] = { flag("Condition:FullLife", { type = "Condition", var = "AffectedByVulnerability" }) },
	["奉献之路的效果区域扩大 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("AreaOfEffect", "INC",num, { type = "SkillName", skillName =  '奉献之路'}) } end,
	["绝命之镰的效果区域扩大 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("AreaOfEffect", "INC",num, { type = "SkillName", skillName =  '赤炼绝命'}) } end,
	["绝命之镰的伤害提高 ([%d%.]+)%%"] = function(_, skill_name, num) return { mod("Damage", "INC",num, { type = "SkillName", skillName =  '赤炼绝命'}) } end,
	["灵魂牧者"] = { mod("Damage", "MORE", -30, { type = "SkillType", skillType = SkillType.Vaal, neg = true }) },
	["插入的技能石的消耗及保留加成为原来的 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("SupportManaMultiplier", "MORE", num - 100) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["周围敌人有恶语术效果"] = { mod("EnemyModifier", "LIST", { mod = flag("HasMalediction") }) },
	["周围敌人被碾压"] = { mod("EnemyPhysicalDamageReduction", "BASE", -15) },
	["你总共消耗 12 枚钢刃碎片后技能在 4 秒内发射 (%d+) 枚额外投射物"] = function(num) return { mod("ProjectileCount", "BASE", num, { type = "Condition", var = "Consumed12SteelShardsRecently" }) } end,
	["近战暴击时触发一个插入的冰霜法术，它有 0.15 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueCosprisMaliceColdSpellsCastOnMeleeCriticalStrike", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["插入的技能石的保留效果降低 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Reserved", "INC", -num) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插入的技能石的保留效果提高 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Reserved", "INC", num) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["插入的诅咒宝石的保留效果降低 (%d+)%%"]= function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("Reserved", "INC", -num,nil,nil,KeywordFlag.Curse ) }, { type = "SocketedIn", slotName = "{SlotName}" })}end,
	["非满血状态时，每秒献祭 ([%d%.]+)%% 魔力来回复同等数值的生命"] = function(num) return {
			mod("ManaDegen", "BASE", 1, { type = "PercentStat", stat = "Mana", percent = num }, { type = "Condition", var = "FullLife", neg = true }),
			mod("LifeRecovery", "BASE", 1, { type = "PercentStat", stat = "Mana", percent = num }, { type = "Condition", var = "FullLife", neg = true })
		} end,
	["猫之势没有保留效果"] = function(_, name) return {
			mod("SkillData", "LIST", { key = "manaReservationFlat", value = 0 }, { type = "SkillId", skillId = "CatAspect" }),
			mod("SkillData", "LIST", { key = "lifeReservationFlat", value = 0 }, { type = "SkillId", skillId = "CatAspect" }),
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillId", skillId = "CatAspect" }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillId", skillId = "CatAspect" }),
		} end,
	["至少有 150 点力量时，击中触发等级 (%d+) 的涂炭震波"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="GoreShockwave", level = num, triggered = true})   } end,
	["至少 150 点力量下近战击中时，触发 (%d+) 级的【涂炭震波】"] = function(num) return {  mod("ExtraSkill", "LIST", { skillId ="GoreShockwave", level = num, triggered = true})   } end,
	["插入的闪电法术触发时造成的法术伤害提高 (%d+)%%"] = { },
	["([%a%s]+) reserves no mana"] = function(_, name) return {
			mod("SkillData", "LIST", { key = "manaReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "lifeReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
		} end,
		["([%a%s]+)没有保留效果"] = function(_, name) return {
			mod("SkillData", "LIST", { key = "manaReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "lifeReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[name] }),
		} end,
		["banner skills reserve no mana"] = {
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }),
		},
		["banner skills have no reservation"] = {
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillType", skillType = SkillType.Banner }),
		},
	["插入的瓦尔技能的伤害总增 (%d+)%%"] = function(num) return {  mod("Damage", "MORE", num,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" })  } end,
	["插入的瓦尔技能击中时无视敌方怪物的抗性"] = { 
	 mod("IgnoreChaosResistances", "FLAG", true,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" }),
	  mod("IgnoreElementalResistances", "FLAG", true,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" }),
	 },
	["插入的瓦尔技能的效果区域扩大 (%d+)%%"] = function(num) return {  mod("AreaOfEffect", "INC", num,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" })  } end,
	["插入的瓦尔技能的投射物速度加快 (%d+)%%"] = function(num) return {  mod("ProjectileSpeed", "INC", num,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" })  } end,
	["插入的瓦尔技能效果持续时间提高 (%d+)%%"] = function(num) return {  mod("Duration", "INC", num,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" })  } end,
	["插入的瓦尔技能的光环效果提高 (%d+)%%"] = function(num) return {  mod("AuraEffect", "INC", num,nil,nil,KeywordFlag.Vaal, { type = "SocketedIn", slotName = "{SlotName}" })  } end,
	["恐惧被你诅咒的敌人"] = { 
	mod("EnemyModifier", "LIST", { mod = mod("Condition:Unnerved", "FLAG", true,{ type = "Condition", var = "Cursed" } ) }), 
	 }, 
	["生命偷取时免疫晕眩"] = function() return {  mod("AvoidStun", "BASE", 100,{ type = "Condition", var = "Leeching" })  } end,
	["免疫元素异常状态"]= function() return {
	mod("AvoidShock", "BASE", 100)  ,
	mod("AvoidChilled", "BASE", 100)  ,
	mod("AvoidFrozen", "BASE", 100)  ,
	mod("AvoidIgnite", "BASE", 100)  ,
	} end,
	["近期内你若有消耗过生命，则 ([%+%-]?%d+)%% 物理持续伤害加成"] = function(num) return {  mod("PhysicalDotMultiplier", "BASE", num,{ type = "Condition", var = "CostLifeRecently" } )  } end,
	["你使用技能时触发一个插入的法术，它有 4 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnSkillUse", level = 2 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["你使用技能时触发一个插入的法术，它有 8 秒冷却时间"] = { mod("ExtraSupport", "LIST", { skillId = "SupportTriggerSpellOnSkillUse", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["弓类攻击发射 (%d+) 支额外箭矢"] = function(num) return {  mod("ProjectileCount", "BASE", num, nil, ModFlag.Bow )  } end,
	["弓类攻击发射一支额外箭矢"] = function() return {  mod("ProjectileCount", "BASE", 1, nil, ModFlag.Bow )  } end,
	["每有 1 个图腾，你和你的图腾每秒便回复 ([%d%.]+)%% 生命"] = function (num) return {
			mod("LifeRegenPercent", "BASE", num, { type = "PerStat", stat = "TotemsSummoned" }),
			mod("LifeRegenPercent", "BASE", num, { type = "PerStat", stat = "TotemsSummoned" }, 0, KeywordFlag.Totem),
		} end,
	["每个召唤的图腾都使你和你的图腾每秒回复 ([%d%.]+)%% 生命"] = function (num) return {
			mod("LifeRegenPercent", "BASE", num, { type = "PerStat", stat = "TotemsSummoned" }),
			mod("LifeRegenPercent", "BASE", num, { type = "PerStat", stat = "TotemsSummoned" }, 0, KeywordFlag.Totem),
		} end,
	["每个召唤的图腾都使伤害总增 ([%d%.]+)%%"] = function (num) return { 
			mod("Damage", "MORE", num, { type = "PerStat", stat = "TotemsSummoned" }),
		} end,	
	["每个召唤的图腾使你每秒回复 ([%d%.]+)%% 魔力"] = function (num) return { 
			mod("ManaRegenPercent", "BASE", num, { type = "PerStat", stat = "TotemsSummoned" }),
		} end,	
	["所有魔卫复苏技能石等级 %+(%d+)"] = function(num)  return { mod("GemProperty", "LIST",  {  keyword =FuckSkillActivityCnName('魔卫复苏'), key = "level", value = num }) } end,
	["所有召唤灵体技能石等级 %+(%d+)"] = function(num)  return { mod("GemProperty", "LIST",  { keyword =FuckSkillActivityCnName('召唤灵体'), key = "level", value = num }) } end,
	["【(.+)】技能石等级 %+(%d+)"] = function(_,skill_name,num)  return { mod("GemProperty", "LIST",  { keyword =FuckSkillActivityCnName(skill_name), key = "level", value = num }) } end,
	["若双持不同类型的武器，则主手攻击伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,nil,ModFlag.Attack ,{ type = "Condition", var = "MainHandAttack" } ,{ type = "Condition", var = "WieldingDifferentWeaponTypes" } ) } end,	
	["若双持不同类型的武器，则副手攻击速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", num,nil,ModFlag.Attack ,{ type = "Condition", var = "OffHandAttack" },{ type = "Condition", var = "WieldingDifferentWeaponTypes" }  ) } end,	
	["战吼的威力值无限"] = { flag("WarcryInfinitePower") },
	["插入的技能石被 (%d+) 级的(.+)辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support), level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	["若你近期内没有施放过冲刺，则弓类攻击发射 (%d+) 枚额外箭矢"] = function(num) return { mod("ProjectileCount", "BASE", num, nil, ModFlag.Bow, { type = "Condition", var = "CastDashRecently", neg = true }) } end,
	["禁用除冲刺外的旅行技能"] = { flag("DisableSkill", { type = "SkillName", skillNameList = { "跃击", "重盾冲锋", "回旋之刃", "暗影迷踪", "烟雾地雷", "闪现射击", "魅影射击", "凋零步", "闪电传送", "瓦尔.闪电传送", "烈焰冲刺", "灵体转换", "冰霜闪现" } }) },
	["若近期没有使用【冲刺】技能，弓攻击发射 (%d+) 额外箭矢"] = function(num) return { mod("ProjectileCount", "BASE", num, nil, ModFlag.Bow, { type = "Condition", var = "CastDashRecently", neg = true }) } end,
	["禁用除【冲刺】以外的旅行技能"] = { flag("DisableSkill", { type = "SkillName", skillNameList = { "跃击", "重盾冲锋", "回旋之刃", "暗影迷踪", "烟雾地雷", "闪现射击", "魅影射击", "凋零步", "闪电传送", "瓦尔.闪电传送", "烈焰冲刺", "灵体转换", "冰霜闪现" } }) },
	["获得 (%d+) 级的【(.+)】技能"]= function(num, _, skill) return grantedExtraSkill(skill, num) end,
	["妒忌没有保留效果"] = function(_, name) return {
			mod("SkillData", "LIST", { key = "manaReservationFlat", value = 0 }, { type = "SkillId", skillId = "DamageOverTimeAura" }),
			mod("SkillData", "LIST", { key = "lifeReservationFlat", value = 0 }, { type = "SkillId", skillId = "DamageOverTimeAura" }),
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillId", skillId = "DamageOverTimeAura" }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillId", skillId = "DamageOverTimeAura" }),
		} end,
	["主手攻击伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,{ type = "Condition", var = "MainHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }  ) } end,	
	["副手攻击速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", num,nil, ModFlag.Attack,{ type = "Condition", var = "OffHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }  ) } end,	
	["副手攻击伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num,{ type = "Condition", var = "OffHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }  ) } end,	
	["主手攻击速度提高 (%d+)%%"] = function(num) return { mod("Speed", "INC", num,nil, ModFlag.Attack,{ type = "Condition", var = "MainHandAttack" },{ type = "SkillType", skillType = SkillType.Attack }  ) } end,	
	--【中文化程序额外添加结束】
	-- Keystones
	["你的攻击和法术无法被闪避"] = { flag("CannotBeEvaded") }, --备注：your hits can't be evaded
	["无法造成暴击"] = { flag("NeverCrit"), flag("Condition:NeverCrit") }, --备注：never deal critical strikes
	["击中没有暴击伤害加成"] = { flag("NoCritMultiplier") }, --备注：no critical strike multiplier
	["暴击造成的异常状态不计入在内"] = { flag("NoCritDegenMultiplier") }, --备注：no damage multiplier for ailments from critical strikes
	["力量属性对近战攻击和投射物的物理伤害均会加成"] = { flag("IronGrip") }, --备注：the increase to physical damage from strength applies to projectile attacks as well as melee attacks
	["将所有闪避值转换为护甲，敏捷不再提供闪避值加成"] = { flag("IronReflexes") }, --备注：converts all evasion rating to armour%. dexterity provides no bonus to evasion rating
	["30%% chance to dodge attack hits%. 50%% less armour, 30%% less energy shield, 30%% less chance to block spell and attack damage"] = { 
		mod("AttackDodgeChance", "BASE", 30), 
		mod("Armour", "MORE", -50), 
		mod("EnergyShield", "MORE", -30), 
		mod("BlockChance", "MORE", -30),
		mod("SpellBlockChance", "MORE", -30) 
	},
	["最大生命上限变成 1，免疫混沌伤害"] = { flag("ChaosInoculation") }, --备注：maximum life becomes 1, immune to chaos damage
	["不再获得生命回复，将其回复效果套用于能量护盾"] = { flag("ZealotsOath") }, --备注：life regeneration is applied to energy shield instead
	["每秒生命偷取效果翻倍。"] = { mod("LifeLeechRate", "MORE", 100) }, --备注：life leeched per second is doubled%.
	["生命偷取速度上限翻倍。"] = { mod("MaxLifeLeechRate", "MORE", 100) }, --备注：maximum life leech rate is doubled%.
	["不再获得生命回复效果。"] = { flag("NoLifeRegen") }, --备注：life regeneration has no effect%.
	["生命再生不生效"] = { flag("NoLifeRegen") }, --备注：life regeneration has no effect%.
	["只能造成火焰伤害"] = { flag("DealNoPhysical"), flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoChaos") }, --备注：deal no non%-fire damage
	["(%d+)%% 的物理、冰霜和闪电伤害转换为火焰伤害"] = function(num) return { --备注：(%d+)%% of physical, cold and lightning damage converted to fire damage
		mod("PhysicalDamageConvertToFire", "BASE", num), 
		mod("LightningDamageConvertToFire", "BASE", num),
		mod("ColdDamageConvertToFire", "BASE", num) 
	} end,
	["移除魔力，施放所有技能改为消耗生命"] = { mod("Mana", "MORE", -100), flag("BloodMagic") }, --备注：removes all mana%. spend life instead of mana for skills
	["被火焰、冰霜和闪电伤害击中的敌人暂时提高 (%d+)%% 的该属性抗性，其他属性抗性降低 (%d+)%%"] = function(plus, _, minus) --备注：enemies you hit with elemental damage temporarily get (%+%d+)%% resistance to those elements and (%-%d+)%% resistance to other elements
minus = -tonumber(minus)
		return {
			flag("ElementalEquilibrium"),
			mod("EnemyModifier", "LIST", { mod = mod("FireResist", "BASE", plus, { type = "Condition", var = "HitByFireDamage" }) }),
			mod("EnemyModifier", "LIST", { mod = mod("FireResist", "BASE", minus, { type = "Condition", var = "HitByFireDamage", neg = true }, { type = "Condition", varList={"HitByColdDamage","HitByLightningDamage"} }) }),
			mod("EnemyModifier", "LIST", { mod = mod("ColdResist", "BASE", plus, { type = "Condition", var = "HitByColdDamage" }) }),
			mod("EnemyModifier", "LIST", { mod = mod("ColdResist", "BASE", minus, { type = "Condition", var = "HitByColdDamage", neg = true }, { type = "Condition", varList={"HitByFireDamage","HitByLightningDamage"} }) }),
			mod("EnemyModifier", "LIST", { mod = mod("LightningResist", "BASE", plus, { type = "Condition", var = "HitByLightningDamage" }) }),
			mod("EnemyModifier", "LIST", { mod = mod("LightningResist", "BASE", minus, { type = "Condition", var = "HitByLightningDamage", neg = true }, { type = "Condition", varList={"HitByFireDamage","HitByColdDamage"} }) }),
		}
	end,
	["投射物攻击近距离目标时造成的总伤害最多额外提高 50%%，但攻击远距离目标时总伤害则会额外降低"] = { flag("PointBlank") }, --备注：projectile attack hits deal up to 50%% more damage to targets at the start of their movement, dealing less damage to targets as the projectile travels farther
	["投射物攻击近距离目标时造成的伤害最多总增 30%%，但攻击远距离目标时伤害则会总降"] = { flag("PointBlank") }, --备注：projectile attack hits deal up to 50%% more damage to targets at the start of their movement, dealing less damage to targets as the projectile travels farther
	["不再获得生命偷取，将其偷取效果套用于能量护盾"] = { flag("GhostReaver") }, --备注：life leech is applied to energy shield instead
	["召唤生物在低血时会爆炸，对周围敌人造成自身最大生命 33%% 的火焰伤害"] = { mod("ExtraMinionSkill", "LIST", { skillId = "MinionInstability" }) }, --备注：minions explode when reduced to low life, dealing 33%% of their maximum life as fire damage to surrounding enemies
	["盾牌上的所有属性会套用于你的召唤生物，而非角色本身"] = { }, -- The node itself is detected by the code that handles it --备注：all bonuses from an equipped shield apply to your minions instead of you
	["技能优先消耗能量护盾，而非魔力"] = { }, --备注：spend energy shield before mana for skill costs
	["能量护盾从生命护盾变成魔力护盾"] = { flag("EnergyShieldProtectsMana") }, --备注：energy shield protects mana instead of life
	["能量护盾保护魔力而非生命"] = { flag("EnergyShieldProtectsMana") }, --备注：energy shield protects mana instead of life
	["暴击伤害加成也会套用于异常状态的伤害加成，数值为 (%d+)%%"] = function(num) return { mod("CritMultiplierAppliesToDegen", "BASE", num) } end, --备注：modifiers to critical strike multiplier also apply to damage multiplier for ailments from critical strikes at (%d+)%% of their value
	["当敌人移动时，你的流血无法造成额外伤害"] = { flag("Condition:NoExtraBleedDamageToMovingEnemy") }, --备注：your bleeding does not deal extra damage while the enemy is moving
	-- Ascendant
	["grants (%d+) passive skill points?"] = function(num) return { mod("ExtraPoints", "BASE", num) } end,
	["赋予 (%d+) 天赋点数?"] = function(num) return { mod("ExtraPoints", "BASE", num) } end,
	["可以从([^\\x00-\\xff]*)的起点配置天赋"] = { }, --备注：can allocate passives from the %a+'s starting point
	-- Assassin
	["你暴击造成的中毒伤害总增 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "CriticalStrike" }) } end, --备注：poison you inflict with critical strikes deals (%d+)%% more damage
	-- Berserker
	["击败敌人时获得 %d+ 怒火"] = { --备注：gain %d+ rage when you kill an enemy
		flag("Condition:CanGainRage"),
		mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["使用战吼时获得 %d+ 怒火"] = { --备注：gain %d+ rage when you use a warcry
		flag("Condition:CanGainRage"),
		mod("Dummy", "DUMMY", 1, { type = "Condition", var = "CanGainRage" }) -- Make the Configuration option appear
	},
	["怒火带来的效果翻倍"] = { mod("Multiplier:RageEffect", "BASE", 1) }, --备注：effects granted for having rage are doubled
	["当你的怒火至少有 (%d+) 点时，免疫晕眩"] = function(num) return { mod("AvoidStun", "BASE", 100, { type = "MultiplierThreshold", var = "Rage", threshold = 25 }) } end, --备注：cannot be stunned while you have at least (%d+) rage
	-- Champion
	["获得护体效果"] = { flag("Condition:Fortify") }, --备注：you have fortify
	["拥有护体时免疫晕眩"] = { mod("AvoidStun", "BASE", 100, { type = "Condition", var = "Fortify" }) }, --备注：cannot be stunned while you have fortify
	["受到你嘲讽的敌人所承受的伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num, { type = "Condition", var = "Taunted" }) }) } end, --备注：enemies you taunt take (%d+)%% increased damage
	["被你嘲讽的敌人无法躲避攻击"] = { mod("EnemyModifier", "LIST", { mod = flag("CannotEvade", { type = "Condition", var = "Taunted" }) }) }, --备注：enemies taunted by you cannot evade attacks
	["若你没有【肾上腺素】，则低血时获得【肾上腺素】，持续 %d+ 秒"] = { flag("Condition:CanGainAdrenaline") }, --备注：gain adrenaline for %d+ seconds when you reach low life if you do not have adrenaline
	-- Chieftan
	["在你图腾周围，敌人承受的物理和火焰伤害提高 (%d+)%%"] = function(num) return { --备注：enemies near your totems take (%d+)%% increased physical and fire damage
		mod("EnemyModifier", "LIST", { mod = mod("PhysicalDamageTaken", "INC", num) }), 
		mod("EnemyModifier", "LIST", { mod = mod("FireDamageTaken", "INC", num) }) 
	} end,
	-- Deadeye
	["投射物可以穿透所有周围目标"] = { flag("PierceAllTargets") }, --备注：projectiles pierce all nearby targets
	["gain %+(%d+) life when you hit a bleeding enemy"] = function(num) return { mod("LifeOnHit", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "Bleeding" }) } end,
	["命中值翻倍"] = { mod("Accuracy", "MORE", 100) }, --备注：accuracy rating is doubled
	["【闪现射击】和【魅影射击】冷却回复速度提高 (%d+)%%"] = function(num) return { --备注：(%d+)%% increased blink arrow and mirror arrow cooldown recovery speed
		mod("CooldownRecovery", "INC", num, { type = "SkillName", skillName = "闪现射击" }),
		mod("CooldownRecovery", "INC", num, { type = "SkillName", skillName = "魅影射击" }),
	} end,
	["近期内你若有使用技能，你和周围友军获得【提速尾流】"] = { mod("ExtraAura", "LIST", { mod = flag("Condition:Tailwind") }, { type = "Condition", var = "UsedSkillRecently" }) }, --备注：if you've used a skill recently, you and nearby allies have tailwind
	["每保留有 1 根锁链，则投射物总伤害额外提高 (%d+)%%"] = function(num) return { mod("Damage", "MORE", num, nil, ModFlag.Projectile, { type = "PerStat", stat = "ChainRemaining" }) } end, --备注：projectiles deal (%d+)%% more damage for each remaining chain
	-- Elementalist
	["范围效果扩大 (%d+)%%，持续 5 秒"] = function(num) return { mod("AreaOfEffect", "INC", num, { type = "Condition", var = "PendulumOfDestructionAreaOfEffect" }) } end, --备注：gain (%d+)%% increased area of effect for %d+ seconds
	["元素伤害提高 (%d+)%%，持续 5 秒"] = function(num) return { mod("ElementalDamage", "INC", num, { type = "Condition", var = "PendulumOfDestructionElementalDamage" }) } end, --备注：gain (%d+)%% increased elemental damage for %d+ seconds
	["近期内，每个击中你的元素可使你的该元素伤害提高 (%d+)%%"] = function(num) return {  --备注：for each element you've been hit by damage of recently, (%d+)%% increased damage of that element
		mod("FireDamage", "INC", num, { type = "Condition", var = "HitByFireDamageRecently" }),
		mod("ColdDamage", "INC", num, { type = "Condition", var = "HitByColdDamageRecently" }),
		mod("LightningDamage", "INC", num, { type = "Condition", var = "HitByLightningDamageRecently" })
	} end,
	["近期内，每个击中你的元素可使你所承受的该元素伤害降低 (%d+)%%"] = function(num) return {  --备注：for each element you've been hit by damage of recently, (%d+)%% reduced damage taken of that element
		mod("FireDamageTaken", "INC", -num, { type = "Condition", var = "HitByFireDamageRecently" }), 
		mod("ColdDamageTaken", "INC", -num, { type = "Condition", var = "HitByColdDamageRecently" }), 
		mod("LightningDamageTaken", "INC", -num, { type = "Condition", var = "HitByLightningDamageRecently" })
	} end,
	["每隔 %d+ 秒："] = { }, --备注：every %d+ seconds:
	["获得持续 %d 秒的冰缓汇流"] = {  --备注：gain chilling conflux for %d seconds
		flag("PhysicalCanChill", { type = "Condition", var = "ChillingConflux" }),
		flag("LightningCanChill", { type = "Condition", var = "ChillingConflux" }),
		flag("FireCanChill", { type = "Condition", var = "ChillingConflux" }),
		flag("ChaosCanChill", { type = "Condition", var = "ChillingConflux" }),
	},
	["获得持续 %d 秒的感电汇流"] = { --备注：gain shocking conflux for %d seconds
		mod("EnemyShockChance", "BASE", 100, { type = "Condition", var = "ShockingConflux" }),
		flag("PhysicalCanShock", { type = "Condition", var = "ShockingConflux" }),
		flag("ColdCanShock", { type = "Condition", var = "ShockingConflux" }),
		flag("FireCanShock", { type = "Condition", var = "ShockingConflux" }),
		flag("ChaosCanShock", { type = "Condition", var = "ShockingConflux" }),
	},
	["获得持续 %d 秒的点燃汇流"] = { --备注：gain igniting conflux for %d seconds
		mod("EnemyIgniteChance", "BASE", 100, { type = "Condition", var = "IgnitingConflux" }),
		flag("PhysicalCanIgnite", { type = "Condition", var = "IgnitingConflux" }),
		flag("LightningCanIgnite", { type = "Condition", var = "IgnitingConflux" }),
		flag("ColdCanIgnite", { type = "Condition", var = "IgnitingConflux" }),
		flag("ChaosCanIgnite", { type = "Condition", var = "IgnitingConflux" }),
	},
	["获得 %d 秒的冰缓，感电，点燃汇流"] = { }, --备注：gain chilling, shocking and igniting conflux for %d seconds
	-- Gladiator
	["被你瘫痪的敌人受到的物理伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("PhysicalDamageTaken", "INC", num, { type = "Condition", var = "Maimed" }) }) } end, --备注：enemies maimed by you take (%d+)%% increased physical damage
	["格挡法术伤害的几率等同于格挡攻击伤害的几率"] = { flag("SpellBlockChanceIsBlockChance") }, --备注：chance to block spell damage is equal to chance to block attack damage
	["格挡法术伤害的最大几率等同于格挡攻击伤害的最大几率"] = { flag("SpellBlockChanceMaxIsBlockChanceMax") }, --备注：maximum chance to block spell damage is equal to maximum chance to block attack damage
	-- Guardian
	["给予你和周围友军等同你 (%d+)%% 生命保留的额外护甲"] = function(num) return { mod("GrantReservedLifeAsAura", "LIST", { mod = mod("Armour", "BASE", num / 100) }) } end, --备注：grants armour equal to (%d+)%% of your reserved life to you and nearby allies
	["给予你和周围友军等同你 (%d+)%% 魔力保留的额外能量护盾"] = function(num) return { mod("GrantReservedManaAsAura", "LIST", { mod = mod("EnergyShield", "BASE", num / 100) }) } end, --备注：grants maximum energy shield equal to (%d+)%% of your reserved mana to you and nearby allies
	["战吼不消耗魔力"] = { mod("ManaCost", "MORE", -100, nil, 0, KeywordFlag.Warcry) }, --备注：warcries cost no mana
	["%+(%d+)%% chance to block attack damage for %d seconds? every %d seconds"] = function(num) return { mod("BlockChance", "BASE", num, { type = "Condition", var = "BastionOfHopeActive" }) } end,
	["若你近期内有进行攻击，你和周围友军有 %+(%d+)%% 的几率格挡攻击伤害"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("BlockChance", "BASE", num) }, { type = "Condition", var = "AttackedRecently" }) } end, --备注：if you've attacked recently, you and nearby allies have %+(%d+)%% chance to block attack damage
	["若你近期内有施放法术，你和周围友军有 %+(%d+)%% 的几率格挡法术伤害"] = function(num) return { mod("ExtraAura", "LIST", { mod = mod("SpellBlockChance", "BASE", num) }, { type = "Condition", var = "CastSpellRecently" }) } end, --备注：if you've cast a spell recently, you and nearby allies have %+(%d+)%% chance to block spell damage
	-- Hierophant
	-- Inquisitor
	["造成暴击时无视目标的火焰、冰霜、闪电抗性"] = { flag("IgnoreElementalResistances", { type = "Condition", var = "CriticalStrike" }) }, --备注：critical strikes ignore enemy monster elemental resistances
	["非暴击时穿透敌人 (%d+)%% 的火焰、冰霜、闪电抗性"] = function(num) return { mod("ElementalPenetration", "BASE", num, { type = "Condition", var = "CriticalStrike", neg = true }) } end, --备注：non%-critical strikes penetrate (%d+)%% of enemy elemental resistances
	["你制造的奉献地面会使你与友军的伤害提高 (%d+)%%"] = function(num) return { mod("Damage", "INC", num, { type = "Condition", var = "OnConsecratedGround" }) } end, --备注：consecrated ground you create grants (%d+)%% increased damage to you and allies
	["周围敌人受到的火焰、冰霜、闪电伤害提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("ElementalDamageTaken", "INC", num) }) } end, --备注：nearby enemies take (%d+)%% increased elemental damage
	-- Juggernaut
	["从身体护甲获得的护甲提高 1 倍"] = { flag("Unbreakable") }, --备注：armour received from body armour is doubled
	["你的移动速度加成不会让你减速至基础速度以下"] = { flag("MovementSpeedCannotBeBelowBase") }, --备注：movement speed cannot be modified to below base value
	["你无法被减速至基础速度以下"] = { flag("ActionSpeedCannotBeBelowBase") }, --备注：you cannot be slowed to below base speed
	["cannot be slowed to below base speed"] = { flag("ActionSpeedCannotBeBelowBase") },
	["获得等同于你力量数值的命中值"] = { mod("Accuracy", "BASE", 1, { type = "PerStat", stat = "Str" }) }, --备注：gain accuracy rating equal to your strength
	-- Necromancer
	["your offering skills also affect you"] = { mod("ExtraSkillMod", "LIST", { mod = mod("SkillData", "LIST", { key = "buffNotPlayer", value = false }) }, { type = "SkillName", skillNameList = { "Bone Offering", "Flesh Offering", "Spirit Offering" } }) },
	["your offerings have (%d+)%% reduced effect on you"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("BuffEffectOnPlayer", "INC", -num) }, { type = "SkillName", skillNameList = { "Bone Offering", "Flesh Offering", "Spirit Offering" } }) } end,
	["你的【复苏的魔卫】死亡时产生腐蚀地面，每秒造成等同它们 50%% 最大生命的混沌伤害"] = { mod("ExtraMinionSkill", "LIST", { skillId = "BeaconZombieCausticCloud", minionList = { "RaisedZombie" } }) }, --备注：your raised zombies spread caustic ground on death, dealing 50%% of their maximum life as chaos damage per second
	["you and your minions have (%d+)%% physical damage reduction"] = function(num) return { mod("PhysicalDamageReduction", "BASE", num), mod("MinionModifier", "LIST", { mod = mod("PhysicalDamageReduction", "BASE", num) }) } end,
	["近期内你若或你的召唤生物击败过敌人，则召唤生物攻击和施法速度提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", num) }, { type = "Condition", varList = { "KilledRecently", "MinionsKilledRecently" } }) } end, --备注：minions have (%d+)%% increased attack and cast speed if you or your minions have killed recently
	["summoned skeletons' hits can't be evaded"] = { mod("MinionModifier", "LIST", { mod = flag("CannotBeEvaded") }, { type = "SkillName", skillName = "召唤魔侍" }) },
	-- Occultist
	["被你诅咒的敌人会遭受【恶语术】影响"] = { mod("AffectedByCurseMod", "LIST", { mod = flag("HasMalediction") }) }, --备注：enemies you curse have malediction
	["周围敌人获得 (%-%d+)%% 混沌抗性"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num) }) } end, --备注：nearby enemies have (%-%d+)%% to chaos resistance
	["当你击败敌人时，敌人身上每有 1 个诅咒，便给予你等同 (%d+)%% 非混沌伤害的额外混沌伤害，持续 4 秒"] = function(num) return {  --备注：when you kill an enemy, for each curse on that enemy, gain (%d+)%% of non%-chaos damage as extra chaos damage for 4 seconds
		mod("NonChaosDamageGainAsChaos", "BASE", num, { type = "Condition", var = "KilledRecently" }, { type = "Multiplier", var = "CurseOnEnemy" }), 
	} end,
	["拥有能量护盾时无法被晕眩"] = { mod("AvoidStun", "BASE", 100, { type = "Condition", var = "HaveEnergyShield" }) }, --备注：cannot be stunned while you have energy shield
	["每有 1 个召唤生物，便获得 1% 额外物理伤害减免，最多 (%d+)%%"] = function(num) return { mod("PhysicalDamageReduction", "BASE", num, { type = "Multiplier", var = "SummonedMinion", limit = tonumber(num), limitTotal = true })  } end,
	-- Pathfinder
	["always poison on hit while using a flask"] = { mod("PoisonChance", "BASE", 100, { type = "Condition", var = "UsingFlask" }) },
	["poisons you inflict during any flask effect have (%d+)%% chance to deal (%d+)%% more damage"] = function(num, _, more) return { mod("Damage", "MORE", tonumber(more) * num / 100, nil, 0, KeywordFlag.Poison, { type = "Condition", var = "UsingFlask" }) } end,
	-- Raider
	["你在拥有最大数量的狂怒球时，得到【迷踪】状态"] = { flag("Condition:Phasing", { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }, --备注：you have phasing while at maximum frenzy charges
	["你在获得猛攻时，得到【迷踪】状态"] = { flag("Condition:Phasing", { type = "Condition", var = "Onslaught" }) }, --备注：you have phasing while you have onslaught
	["狂怒球达到上限时，你获得【猛攻】状态"] = { flag("Condition:Onslaught", { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }, --备注：you have onslaught while on full frenzy charges
	["耐力球达到上限时获得【猛攻】状态"] = { flag("Condition:Onslaught", { type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" }) }, --备注：you have onslaught while at maximum endurance charges
	-- Sabotuer
	-- Slayer
	-- Trickster
	["你的攻击和法术有 (%d+)%% 几率获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num, _, perc) return { mod("NonChaosDamageGainAsChaos", "BASE", num / 100 * tonumber(perc)) } end, --备注：your hits have (%d+)%% chance to gain (%d+)%% of non%-chaos damage as extra chaos damage
	["位移技能不消耗魔力"] = { mod("ManaCost", "MORE", -100, nil, 0, KeywordFlag.Movement) }, --备注：movement skills cost no mana
	-- Item local modifiers
	["没有插槽"] = { flag("NoSockets") }, --备注：has no sockets
	["有 (%d+) 个插槽"] = function(num) return { mod("SocketCount", "BASE", num) } end, --备注：has (%d+) sockets?
	["拥有 (%d+) 个深渊插槽"] = function(num) return { mod("AbyssalSocketCount", "BASE", num) } end, --备注：has (%d+) abyssal sockets?
	["没有物理伤害"] = { mod("WeaponData", "LIST", { key = "PhysicalMin" }), mod("WeaponData", "LIST", { key = "PhysicalMax" }), mod("WeaponData", "LIST", { key = "PhysicalDPS" }) }, --备注：no physical damage
	["此武器进行的所有攻击皆是暴击"] = { mod("WeaponData", "LIST", { key = "CritChance", value = 100 }) }, --备注：all attacks with this weapon are critical strikes
	["视作双持武器"] = { mod("WeaponData", "LIST", { key = "countsAsDualWielding", value = true}) }, --备注：counts as dual wielding
	["可视为所有类型的单手近战武器"] = { mod("WeaponData", "LIST", { key = "countsAsAll1H", value = true }) }, --备注：counts as all one handed melee weapon types
	["没有格档率"] = { mod("ArmourData", "LIST", { key = "BlockChance", value = 0 }) }, --备注：no block chance
	["攻击和法术无法被闪避"] = { flag("CannotBeEvaded", { type = "Condition", var = "{Hand}Attack" }) }, --备注：hits can't be evaded
	["击中时造成流血"] = { mod("BleedChance", "BASE", 100, { type = "Condition", var = "{Hand}Attack" }) }, --备注：causes bleeding on hit
	["poisonous hit"] = { mod("PoisonChance", "BASE", 100, { type = "Condition", var = "{Hand}Attack" }) },
	["此武器的攻击对冰缓的敌人造成双倍伤害"] = { mod("DoubleDamageChance", "BASE", 100, nil, ModFlag.Hit, { type = "Condition", var = "{Hand}Attack" }, { type = "ActorCondition", actor = "enemy", var = "Chilled" }) }, --备注：attacks with this weapon deal double damage to chilled enemies
	["life leech from hits with this weapon applies instantly"] = { flag("InstantLifeLeech", { type = "Condition", var = "{Hand}Attack" }) },
	["使用此武器击中敌人立即获得生命偷取"] = { flag("InstantLifeLeech", { type = "Condition", var = "{Hand}Attack" }) }, --备注：gain life from leech instantly from hits with this weapon
	["立即回复"] = {  mod("FlaskInstantRecovery", "BASE", 100) }, --备注：instant recovery
	["(%d+)%% of recovery applied instantly"] = function(num) return { mod("FlaskInstantRecovery", "BASE", num) } end,
	["穿戴对人物属性无需求"] = { flag("NoAttributeRequirements") }, --备注：has no attribute requirements
	-- Socketed gem modifiers
	["此物品上装备的技能石等级 %+(%d+)"] = function(num) return { mod("GemProperty", "LIST", { keyword = "all", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：%+(%d+) to level of socketed gems
	["%+(%d+) to level of socketed ([%a ]+) gems"] = function(num, _, type) return { mod("GemProperty", "LIST", { keyword = type, key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["%+(%d+)%% to quality of socketed ([%a ]+) gems"] = function(num, _, type) return { mod("GemProperty", "LIST", { keyword = type, key = "quality", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["%+(%d+) to level of active socketed skill gems"] = function(num) return { mod("GemProperty", "LIST", { keyword = "active_skill", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["%+(%d+) to level of socketed active skill gems"] = function(num) return { mod("GemProperty", "LIST", { keyword = "active_skill", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["人物等级每到达 25 级，该插槽内的【主动技能石】等级 +1"] = function(num, _, div) return { mod("GemProperty", "LIST", { keyword = "active_skill", key = "level", value = num }, { type = "SocketedIn", slotName = "{SlotName}" }, { type = "Multiplier", var = "Level", div = tonumber(div) }) } end, --备注：%+(%d+) to level of socketed active skill gems per (%d+) player levels
	["socketed gems fire an additional projectile"] = { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", 1) }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["此物品上的技能石可以发射 (%d+) 个额外投射物"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", num) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed gems fire (%d+) additional projectiles
	["此物品上的技能石无魔力保留"] = { mod("ManaReserved", "MORE", -100, { type = "SocketedIn", slotName = "{SlotName}" }) }, --备注：socketed gems reserve no mana
	["socketed skill gems get a (%d+)%% mana multiplier"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("SupportManaMultiplier", "MORE", num - 100) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["socketed gems gain (%d+)%% of physical damage as extra lightning damage"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("PhysicalDamageGainAsLightning", "BASE", num) }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["此物品上的红色技能石额外获得 (%d+)%% 的物理伤害，并转化为火焰伤害"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("PhysicalDamageGainAsFire", "BASE", num) }, { type = "SocketedIn", slotName = "{SlotName}", keyword = "strength" }) } end, --备注：socketed red gems get (%d+)%% physical damage as extra fire damage
	-- Extra skill/support
	["grants (%D+)"] = function(_, skill) return grantedExtraSkill(skill, 1) end,
	["获得 (%d+) 级的(.+)"] = function(num, _, skill) return grantedExtraSkill(skill, num) end, --备注：grants level (%d+) (.+)
	["装备时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when equipped
	["[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) on %a+"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["use level (%d+) (.+) on %a+"] = function(num, _, skill) return grantedExtraSkill(skill, num) end,
	["当你攻击时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when you attack
	["暴击时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when you deal a critical strike
	["[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when hit"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["击败敌人时召唤 (%d+) 级的(.+)"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when you kill an enemy
	["当你使用技能时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：[ct][ar][si][tg]g?e?r?s? level (%d+) (.+) when you use a skill
	["在你有精神球时使用技能，触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：trigger level (%d+) (.+) when you use a skill while you have a spirit charge
	["被诅咒时你击中一个敌人，触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：trigger level (%d+) (.+) when you hit an enemy while cursed
	["你击败被冻结的敌人时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：trigger level (%d+) (.+) when you kill a frozen enemy
	["%d+%% chance to attack with level (%d+) (.+) on melee hit"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["%d+%% chance to trigger level (%d+) (.+) on melee hit"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["%d+%% chance to trigger level (%d+) (.+) on kill"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["%d+%% chance to trigger level (%d+) (.+) when you use a socketed skill"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["你获得【鸟之力量】或【鸟之斗魄】时有 %d+%% 几率触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：%d+%% chance to trigger level (%d+) (.+) when you gain avian's might or avian's flight
	["%d+%% chance to [ct][ar][si][tg]g?e?r? level (%d+) (.+) on %a+"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["attack with level (%d+) (.+) when you kill a bleeding enemy"] = function(num, _, skill) return triggerExtraSkill(skill, num) end,
	["击败流血敌人时触发 (%d+) 级的【(.+)】"] = function(num, _, skill) return triggerExtraSkill(skill, num) end, --备注：triggers? level (%d+) (.+) when you kill a bleeding enemy
	["击中敌人时，用【(.+)】诅咒敌人"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end, --备注：curse enemies with (%D+) on %a+
	["击中时用 (%d+) 级的【(%D+)】诅咒敌人，对诅咒免疫的敌人也有效"] = function(num, _, skill) return triggerExtraSkill(skill, num, true) end, --备注：curse enemies with level (%d+) (%D+) on %a+, which can apply to hexproof enemies
	["击中敌人时，用 (%d+) 级的【(.+)】诅咒敌人"] = function(num, _, skill) return triggerExtraSkill(skill, num, true) end, --备注：curse enemies with level (%d+) (.+) on %a+
	["[ct][ar][si][tg]g?e?r?s? (.+) on %a+"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["[at][tr][ti][ag][cg][ke]r? w?i?t?h? ?(.+) on %a+"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["[ct][ar][si][tg]g?e?r?s? (.+) when hit"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["[at][tr][ti][ag][cg][ke]r? w?i?t?h? ?(.+) when hit"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["[ct][ar][si][tg]g?e?r?s? (.+) when your skills or minions kill"] = function(_, skill) return triggerExtraSkill(skill, 1, true) end,
	["[at][tr][ti][ag][cg][ke]r? w?i?t?h? (.+) when you take a critical strike"] = function( _, skill) return triggerExtraSkill(skill, 1, true) end,
	["暴击时触发【(.+)】"] = function( _, skill) return triggerExtraSkill(skill, 1, true) end, --备注：trigger (.+) on critical strike
	["你被暴击时触发【(.+)】"] = function( _, skill) return triggerExtraSkill(skill, 1, true) end, --备注：triggers? (.+) when you take a critical strike
	["此物品上的【(.+)技能石】由 (%d+) 级的 (.+) 辅助"] = function(num, _, support) return { mod("ExtraSupport", "LIST", { skillId = FuckSkillSupportCnName(support) or FuckSkillSupportCnName(support:gsub("^increased ","")) or "Unknown", level = num }, { type = "SocketedIn", slotName = "{SlotName}" }) } end, --备注：socketed [%a+]* ?gems a?r?e? ?supported by level (%d+) (.+)
	-- Conversion
	["召唤生物伤害提高或降低，将同样套用于自身"] = { flag("MinionDamageAppliesToPlayer") , mod("ImprovedMinionDamageAppliesToPlayer", "INC", 100) }, --备注：increases and reductions to minion damage also affects? you
	["召唤生物攻击速度的加成同时套用于你身上"] = { flag("MinionAttackSpeedAppliesToPlayer") , mod("ImprovedMinionAttackSpeedAppliesToPlayer", "INC", 100)}, --备注：increases and reductions to minion attack speed also affects? you
	["对法术伤害的增幅与减益也会套用于攻击上"] ={ flag("SpellDamageAppliesToAttacks"), mod("ImprovedSpellDamageAppliesToAttacks", "INC", 100)  }, --备注：increases and reductions to spell damage also apply to attacks
	
	["modifiers to claw damage also apply to unarmed"] = { flag("ClawDamageAppliesToUnarmed") },
	["对爪类武器的伤害加成同时套用于空手攻击伤害上"] = { flag("ClawDamageAppliesToUnarmed") }, --备注：modifiers to claw damage also apply to unarmed attack damage
	["modifiers to claw attack speed also apply to unarmed"] = { flag("ClawAttackSpeedAppliesToUnarmed") },
	["对爪类武器的攻击速度加成同时套用于空手攻击速度上"] = { flag("ClawAttackSpeedAppliesToUnarmed") }, --备注：modifiers to claw attack speed also apply to unarmed attack speed
	["modifiers to claw critical strike chance also apply to unarmed"] = { flag("ClawCritChanceAppliesToUnarmed") },
	["对爪类武器的攻击暴击率加成同时套用于空手攻击暴击率上"] = { flag("ClawCritChanceAppliesToUnarmed") }, --备注：modifiers to claw critical strike chance also apply to unarmed attack critical strike chance
	["照亮范围的扩大和缩小也同样作用于命中值"] = { flag("LightRadiusAppliesToAccuracy") }, --备注：increases and reductions to light radius also apply to accuracy
	["施法速度的提高和降低也同样作用于陷阱投掷速度"] = { flag("CastSpeedAppliesToTrapThrowingSpeed") }, --备注：increases and reductions to cast speed also apply to trap throwing speed
	["gain (%d+)%% of bow physical damage as extra damage of each element"] = function(num) return { 
		mod("PhysicalDamageGainAsLightning", "BASE", num, nil, ModFlag.Bow), 
		mod("PhysicalDamageGainAsCold", "BASE", num, nil, ModFlag.Bow), 
		mod("PhysicalDamageGainAsFire", "BASE", num, nil, ModFlag.Bow) 
	} end,
	["获得等同武器物理伤害 (%d+)%% 的全部三种额外火焰，冰霜和闪电伤害"] = function(num) return {  --备注：gain (%d+)%% of weapon physical damage as extra damage of each element
		mod("PhysicalDamageGainAsLightning", "BASE", num, nil, ModFlag.Weapon), 
		mod("PhysicalDamageGainAsCold", "BASE", num, nil, ModFlag.Weapon), 
		mod("PhysicalDamageGainAsFire", "BASE", num, nil, ModFlag.Weapon) 
	} end,
	-- Crit
	["幸运的暴击率"] = { flag("CritChanceLucky") }, --备注：your critical strike chance is lucky
	["你的暴击不造成额外伤害"] = { flag("NoCritMultiplier") }, --备注：your critical strikes do not deal extra damage
	["暴击无法造成伤害"] = { mod("Damage", "MORE", -100, { type = "Condition", var = "CriticalStrike" }) }, --备注：critical strikes deal no damage
	["暴击率将随绝对闪电抗性而提高"] = { mod("CritChance", "INC", 1, { type = "PerStat", stat = "LightningResistTotal", div = 1 }) }, --备注：critical strike chance is increased by uncapped lightning resistance
	["暴击率随闪电抗性提高"] = { mod("CritChance", "INC", 1, { type = "PerStat", stat = "LightningResist", div = 1 }) }, --备注：critical strike chance is increased by lightning resistance
	["non%-critical strikes deal (%d+)%% damage"] = function(num) return { mod("Damage", "MORE", -100+num, nil, ModFlag.Hit, { type = "Condition", var = "CriticalStrike", neg = true }) } end,
	-- Generic Ailments
	["你每使敌人受到一种异常状态，它们受到的伤害便提高 (%d+)%%"] = function(num) return { --备注：enemies take (%d+)%% increased damage for each type of ailment you have inflicted on them
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Frozen"}),
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Chilled"}),
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Ignited"}),
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Shocked"}),
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Bleeding"}),
		mod("EnemyModifier", "LIST", { mod = mod("DamageTaken", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Poisoned"})
	} end,
	-- Elemental Ailments
	["你的火焰、冰霜、闪电伤害可以造成感电"] = { flag("ColdCanShock"), flag("FireCanShock") }, --备注：your elemental damage can shock
	["你的冰霜伤害可以点燃"] = { flag("ColdCanIgnite") }, --备注：your cold damage can ignite
	["你的闪电伤害可以造成点燃"] = { flag("LightningCanIgnite") }, --备注：your lightning damage can ignite
	["你的火焰伤害可以感电但无法点燃"] = { flag("FireCanShock"), flag("FireCannotIgnite") }, --备注：your fire damage can shock but not ignite
	["你的冰霜伤害可以点燃但无法冰冻或冰缓"] = { flag("ColdCanIgnite"), flag("ColdCannotFreeze"), flag("ColdCannotChill") }, --备注：your cold damage can ignite but not freeze or chill
	["你的闪电伤害可以冰冻但无法感电"] = { flag("LightningCanFreeze"), flag("LightningCannotShock") }, --备注：your lightning damage can freeze but not shock
	["混沌伤害可以造成感电"] = { flag("ChaosCanShock") }, --备注：your chaos damage can shock
	["混沌伤害可以造成点燃、冰缓和感电效果"] = { flag("ChaosCanIgnite"), flag("ChaosCanChill"), flag("ChaosCanShock") }, --备注：chaos damage can ignite, chill and shock
	["物理伤害可以造成冰缓"] = { flag("PhysicalCanChill") }, --备注：your physical damage can chill
	["你的物理伤害造成感电"] = { flag("PhysicalCanShock") }, --备注：your physical damage can shock
	["你正在燃烧时总能点燃敌人"] = { mod("EnemyIgniteChance", "BASE", 100, { type = "Condition", var = "Burning" }) }, --备注：you always ignite while burning
	["暴击不会必定造成冰冻"] = { flag("CritsDontAlwaysFreeze") }, --备注：critical strikes do not always freeze
	["you can inflict up to (%d+) ignites on an enemy"] = { flag("IgniteCanStack") },
	["enemies chilled by you take (%d+)%% increased burning damage"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("FireDamageTakenOverTime", "INC", num) }, { type = "ActorCondition", actor = "enemy", var = "Chilled" }) } end,
	["被点燃敌人的燃烧加快 (%d+)%%"] = function(num) return { mod("IgniteBurnFaster", "INC", num) } end, --备注：ignited enemies burn (%d+)%% faster
	["被点燃敌人的燃烧减缓 (%d+)%%"] = function(num) return { mod("IgniteBurnSlower", "INC", num) } end, --备注：ignited enemies burn (%d+)%% slower
	["攻击被点燃敌人会使燃烧加快 (%d+)%%"] = function(num) return { mod("IgniteBurnFaster", "INC", num, nil, ModFlag.Attack) } end, --备注：enemies ignited by an attack burn (%d+)%% faster
	-- Bleed
	["melee attacks cause bleeding"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Melee) },
	["attacks cause bleeding when hitting cursed enemies"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Attack, { type = "ActorCondition", actor = "enemy", var = "Cursed" }) },
	["melee critical strikes cause bleeding"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Melee, { type = "Condition", var = "CriticalStrike" }) },
	["causes bleeding on melee critical strike"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Melee, { type = "Condition", var = "CriticalStrike" }) },
	["melee critical strikes have (%d+)%% chance to cause bleeding"] = function(num) return { mod("BleedChance", "BASE", num, nil, ModFlag.Melee, { type = "Condition", var = "CriticalStrike" }) } end,
	["attacks always inflict bleeding while you have cat's stealth"] = { mod("BleedChance", "BASE", 100, nil, ModFlag.Attack, { type = "Condition", var = "AffectedByCat'sStealth" }) },
	["you have crimson dance while you have cat's stealth"] = { mod("Keystone", "LIST", "Crimson Dance", { type = "Condition", var = "AffectedByCat'sStealth" }) },
	["you have crimson dance if you have dealt a critical strike recently"] = { mod("Keystone", "LIST", "Crimson Dance", { type = "Condition", var = "CritRecently" }) },
	-- Poison
	["你的火焰伤害会使敌人中毒"] = { flag("FireCanPoison") }, --备注：y?o?u?r? ?fire damage can poison
	["你的冰霜伤害会使敌人中毒"] = { flag("ColdCanPoison") }, --备注：y?o?u?r? ?cold damage can poison
	["你的闪电伤害会使敌人中毒"] = { flag("LightningCanPoison") }, --备注：y?o?u?r? ?lightning damage can poison
	["your chaos damage poisons enemies"] = { mod("ChaosPoisonChance", "BASE", 100) },
	["你的混沌伤害有 (%d+)%% 几率使敌人中毒"] = function(num) return { mod("ChaosPoisonChance", "BASE", num) } end, --备注：your chaos damage has (%d+)%% chance to poison enemies
	["melee attacks poison on hit"] = { mod("PoisonChance", "BASE", 100, nil, ModFlag.Melee) },
	["melee critical strikes have (%d+)%% chance to poison the enemy"] = function(num) return { mod("PoisonChance", "BASE", num, nil, ModFlag.Melee, { type = "Condition", var = "CriticalStrike" }) } end,
	["匕首攻击的暴击有 (%d+)%% 几率使敌人中毒"] = function(num) return { mod("PoisonChance", "BASE", num, nil, ModFlag.Dagger, { type = "Condition", var = "CriticalStrike" }) } end, --备注：critical strikes with daggers have a (%d+)%% chance to poison the enemy
	["poison cursed enemies on hit"] = { mod("PoisonChance", "BASE", 100, { type = "ActorCondition", actor = "enemy", var = "Cursed" }) },
	["当你拥有最大数量的狂怒球时，攻击使敌人中毒"] = { mod("PoisonChance", "BASE", 100, nil, ModFlag.Attack, { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }, --备注：wh[ie][ln]e? at maximum frenzy charges, attacks poison enemies
	["陷阱和地雷击中时，有 (%d+)%% 几率使敌人中毒"] = function(num) return { mod("PoisonChance", "BASE", num, nil, 0, bor(KeywordFlag.Trap, KeywordFlag.Mine)) } end, --备注：traps and mines have a (%d+)%% chance to poison on hit
	-- Buffs/debuffs
	["【迷踪】状态"] = { flag("Condition:Phasing") }, --备注：phasing
	["迷踪"] = { flag("Condition:Phasing") }, --备注：phasing
	["猛攻"] = { flag("Condition:Onslaught") }, --备注：onslaught
	["近期内你若有击败敌人，则进入【迷踪】状态"] = { flag("Condition:Phasing", { type = "Condition", var = "KilledRecently" }) }, --备注：you have phasing if you've killed recently
	["you have phasing while affected by haste"] = { flag("Condition:Phasing", { type = "Condition", var = "AffectedByHaste" }) },
	["you have phasing while you have cat's stealth"] = { flag("Condition:Phasing", { type = "Condition", var = "AffectedByCat'sStealth" }) },
	["低血时获得【猛攻】"] = { flag("Condition:Onslaught", { type = "Condition", var = "LowLife" }) }, --备注：you have onslaught while on low life
	["非低魔时获得【猛攻】"] = { flag("Condition:Onslaught", { type = "Condition", var = "LowMana", neg = true }) }, --备注：you have onslaught while not on low mana
	["光环效果对友方没有作用"] = { flag("SelfAurasCannotAffectAllies") }, --备注：your aura buffs do not affect allies
	["无法获得友方光环效果"] = { flag("AlliesAurasCannotAffectSelf") }, --备注：allies' aura buffs do not affect you
	["可以对敌人施放 1 个额外诅咒"] = { mod("EnemyCurseLimit", "BASE", 1) }, --备注：enemies can have 1 additional curse
	["周围敌人被诅咒的效果提高 (%d+)%%"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("CurseEffectOnSelf", "INC", num) }) } end, --备注：nearby enemies have (%d+)%% increased effect of curses on them
	["周围敌人有额外 (%d+)%% 几率受到暴击"] = function(num) return { mod("EnemyModifier", "LIST", { mod = mod("SelfExtraCritChance", "BASE", num) }) } end, --备注：nearby enemies have an additional (%d+)%% chance to receive a critical strike
	["nearby enemies have (%-%d+)%% to all resistances"] = function(num) return {
		mod("EnemyModifier", "LIST", { mod = mod("ElementalResist", "BASE", num) }),
		mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num) }) 
	} end,
	["your hits inflict decay, dealing (%d+) chaos damage per second for %d+ seconds"] = function(num) return { mod("SkillData", "LIST", { key = "decay", value = num, merge = "MAX" }) } end,
	["temporal chains has (%d+)%% reduced effect on you"] = function(num) return { mod("CurseEffectOnSelf", "INC", -num, { type = "SkillName", skillName = "时空锁链" }) } end,
	["unaffected by temporal chains"] = { mod("CurseEffectOnSelf", "MORE", -100, { type = "SkillName", skillName = "时空锁链" }) },
	["【猫之隐匿】的持续时间 ([%+%-]%d+) 秒"] = function(num) return { mod("PrimaryDuration", "BASE", num, { type = "SkillName", skillName = "猫之势" }) } end, --备注：([%+%-]%d+) seconds to cat's stealth duration
	["([%+%-]%d+) seconds to avian's might duration"] = function(num) return { mod("PrimaryDuration", "BASE", num, { type = "SkillName", skillName = "鸟之势" }) } end,
	["([%+%-]%d+) seconds to avian's flight duration"] = function(num) return { mod("SecondaryDuration", "BASE", num, { type = "SkillName", skillName = "鸟之势" }) } end,
	["【蛛之势】可对敌人额外造成 1 层蜘蛛网"] = { mod("ExtraSkillMod", "LIST", { mod = mod("Multiplier:SpiderWebApplyStackMax", "BASE", 1) }, { type = "SkillName", skillName = "蛛之势" }) }, --备注：aspect of the spider can inflict spider's web on enemies an additional time
	["受你至少 1 层蜘蛛网影响的敌人，所有抗性 (%-%d+)%%"] = function(num) return { --备注：enemies affected by your spider's webs have (%-%d+)%% to all resistances
		mod("EnemyModifier", "LIST", { mod = mod("ElementalResist", "BASE", num, { type = "MultiplierThreshold", var = "Spider's WebStack", threshold = 1 }) }),
		mod("EnemyModifier", "LIST", { mod = mod("ChaosResist", "BASE", num, { type = "MultiplierThreshold", var = "Spider's WebStack", threshold = 1 }) }),
	} end,
	["你受到 (%d+) 级【(%D+)】的诅咒"] = function(num, _, name) return { mod("ExtraCurse", "LIST", { skillId = FuckSkillSupportCnName(name), level = num, applyToPlayer = true }) } end, --备注：you are cursed with level (%d+) (%D+)
	["you count as on low life while you are cursed with vulnerability"] = { flag("Condition:LowLife", { type = "Condition", var = "AffectedByVulnerability" }) },
	["近期内你每吞噬过 1 个灵柩，你和周围队友每秒回复 (%d+)%% 生命"] = function (num) return { mod("ExtraAura", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) }, { type = "Condition", var = "ConsumedCorpseRecently" }) } end, --备注：if you consumed a corpse recently, you and nearby allies regenerate (%d+)%% of life per second
	-- Traps, Mines and Totems
	["陷阱和地雷造成 (%d+) %- (%d+) 额外物理伤害"] = function(_, min, max) return { mod("PhysicalMin", "BASE", tonumber(min), nil, 0, bor(KeywordFlag.Trap, KeywordFlag.Mine)), mod("PhysicalMax", "BASE", tonumber(max), nil, 0, bor(KeywordFlag.Trap, KeywordFlag.Mine)) } end, --备注：traps and mines deal (%d+)%-(%d+) additional physical damage
	["traps and mines deal (%d+) to (%d+) additional physical damage"] = function(_, min, max) return { mod("PhysicalMin", "BASE", tonumber(min), nil, 0, bor(KeywordFlag.Trap, KeywordFlag.Mine)), mod("PhysicalMax", "BASE", tonumber(max), nil, 0, bor(KeywordFlag.Trap, KeywordFlag.Mine)) } end,
	["最多同时可额外放置 (%d+) 个陷阱"] = function(num) return { mod("ActiveTrapLimit", "BASE", num) } end, --备注：can have up to (%d+) additional traps? placed at a time	
	["同时可以放置最多 (%d+) 个额外陷阱"] = function(num) return { mod("ActiveTrapLimit", "BASE", num) } end, --备注：can have up to (%d+) additional traps? placed at a time
	["最多同时可额外放置 (%d+) 个遥控地雷"] = function(num) return { mod("ActiveMineLimit", "BASE", num) } end, --备注：can have up to (%d+) additional remote mines? placed at a time
	["最多同时可以额外召唤 (%d+) 个图腾"] = function(num) return { mod("ActiveTotemLimit", "BASE", num) } end, --备注：can have up to (%d+) additional totems? summoned at a time
	["攻击技能可以额外召唤 (%d+) 个图腾"] = function(num) return { mod("ActiveTotemLimit", "BASE", num, nil, 0, KeywordFlag.Attack) } end, --备注：attack skills can have (%d+) additional totems? summoned at a time
	["每有 (%d+) 点敏捷，你的攻城炮台图腾数量上限便提高 1 个"] = function(num) return { mod("ActiveTotemLimit", "BASE", 1, { type = "SkillName", skillName = "攻城炮台" }, { type = "PerStat", stat = "Dex", div = num }) } end, --备注：can [hs][au][vm][em]o?n? 1 additional siege ballista totem per (%d+) dexterity
	
	["图腾发射 (%d+) 个额外投射物"] = function(num) return { mod("ProjectileCount", "BASE", num, nil, 0, KeywordFlag.Totem) } end, --备注：totems fire (%d+) additional projectiles
	["你偷取生命，数值等同于你的图腾造成伤害的 ([%d%.]+)%%"] = function(num) return { mod("DamageLifeLeechToPlayer", "BASE", num, nil, 0, KeywordFlag.Totem) } end, --备注：([%d%.]+)%% of damage dealt by y?o?u?r? ?totems is leeched to you as life
	-- Minions
	["your strength is added to your minions"] = { flag("HalfStrengthAddedToMinions") },
	["你一半的力量属性将添加至你的召唤生物身上"] = { flag("HalfStrengthAddedToMinions") }, --备注：half of your strength is added to your minions
	["minions poison enemies on hit"] = { mod("MinionModifier", "LIST", { mod = mod("PoisonChance", "BASE", 100) }) },
	["minions have (%d+)%% chance to poison enemies on hit"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("PoisonChance", "BASE", num) }) } end,
	["近期内你若造成过伤害，则召唤生物伤害提高 (%d+)%%"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "Condition", var = "HitRecently" }) } end, --备注：(%d+)%% increased minion damage if you have hit recently
	["(%d+)%% increased minion damage if you've used a minion skill recently"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "Condition", var = "UsedMinionSkillRecently" }) } end,
	["(%d+)%% increased minion attack speed per (%d+) dexterity"] = function(num, _, div) return { mod("MinionModifier", "LIST", { mod = mod("Speed", "INC", num, nil, ModFlag.Attack) }, { type = "PerStat", stat = "Dex", div = tonumber(div) }) } end,
	["(%d+)%% increased minion movement speed per (%d+) dexterity"] = function(num, _, div) return { mod("MinionModifier", "LIST", { mod = mod("MovementSpeed", "INC", num) }, { type = "PerStat", stat = "Dex", div = tonumber(div) }) } end,
	["minions deal (%d+)%% increased damage per (%d+) dexterity"] = function(num, _, div) return { mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num) }, { type = "PerStat", stat = "Dex", div = tonumber(div) }) } end,
	["每 1 个召唤出的不同魔像可使魔像伤害提高 (%d+)%%"] = function(num) return { --备注：(%d+)%% increased golem damage for each type of golem you have summoned
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HavePhysicalGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HaveLightningGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HaveColdGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HaveFireGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HaveChaosGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
		mod("MinionModifier", "LIST", { mod = mod("Damage", "INC", num, { type = "ActorCondition", actor = "parent", var = "HaveCarrionGolem" }) }, { type = "SkillType", skillType = SkillType.Golem }),
	} end,
	["最多可同时拥有额外 (%d) 个魔像"] = function(num) return { mod("ActiveGolemLimit", "BASE", num) } end, --备注：can summon up to (%d) additional golems? at a time
	["若你有 3 个起源天赋珠宝，可以额外召唤 (%d) 个魔像"] = function(num) return { mod("ActiveGolemLimit", "BASE", num, { type = "MultiplierThreshold", var = "PrimordialItem", threshold = 3 }) } end, --备注：if you have 3 primordial jewels, can summon up to (%d) additional golems? at a time
	["golems regenerate (%d)%% of their maximum life per second"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("LifeRegenPercent", "BASE", num) }, { type = "SkillType", skillType = SkillType.Golem }) } end,
	["【愤怒狂灵】击中后必定造成点燃"] = { mod("MinionModifier", "LIST", { mod = mod("EnemyIgniteChance", "BASE", 100) }, { type = "SkillName", skillName = "召唤愤怒狂灵" }) }, --备注：raging spirits' hits always ignite
	["summoned skeletons have avatar of fire"] = { mod("MinionModifier", "LIST", { mod = mod("Keystone", "LIST", "Avatar of Fire") }, { type = "SkillName", skillName = "召唤魔侍" }) },
	["异灵魔侍每秒将其最大生命的 ([%d%.]+)%% 转化为火焰伤害"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("FireDegen", "BASE", num/100, { type = "PerStat", stat = "Life", div = 1 }) }, { type = "SkillName", skillName = "召唤魔侍" }) } end, --备注：summoned skeletons take ([%d%.]+)%% of their maximum life per second as fire damage
	-- Projectiles
	["投射物可以连锁弹射 %+(%d) 次"] = function(num) return { mod("ChainCountMax", "BASE", num) } end, --备注：skills chain %+(%d) times
	["技能可以连锁弹射 %+(%d) 次"] = function(num) return { mod("ChainCountMax", "BASE", num) } end, --备注：skills chain %+(%d) times
	["当你拥有最大数量的狂怒球时，技能额外连锁弹射 1 次"] = { mod("ChainCountMax", "BASE", 1, { type = "StatThreshold", stat = "FrenzyCharges", thresholdStat = "FrenzyChargesMax" }) }, --备注：skills chain an additional time while at maximum frenzy charges
	["装备于主手时，攻击额外连锁弹射 1 次"] = { mod("ChainCountMax", "BASE", 1, nil, ModFlag.Attack, { type = "SlotNumber", num = 1 }) }, --备注：attacks chain an additional time when in main hand
	["用弓攻击时额外发射 1 根箭矢"] = { mod("ProjectileCount", "BASE", 1, nil, ModFlag.Attack) }, --备注：adds an additional arrow
	["用弓攻击时额外发射 (%d+) 根箭矢"] = function(num) return { mod("ProjectileCount", "BASE", num, nil, ModFlag.Attack) } end, --备注：(%d+) additional arrows
	["bow attacks fire an additional arrow"] = { mod("ProjectileCount", "BASE", 1, nil, ModFlag.Bow) },
	["bow attacks fire (%d+) additional arrows"] = function(num) return { mod("ProjectileCount", "BASE", num, nil, ModFlag.Bow) } end,
	["技能可以额外发射 1 个投射物"] = { mod("ProjectileCount", "BASE", 1) }, --备注：skills fire an additional projectile
	["法术可以额外发射 1 个投射物"] = { mod("ProjectileCount", "BASE", 1, nil, ModFlag.Spell) }, --备注：spells have an additional projectile
	["装备在副手时，攻击可以额外发射 1 个投射物"] = { mod("ProjectileCount", "BASE", 1, nil, ModFlag.Attack, { type = "SlotNumber", num = 2 }) }, --备注：attacks have an additional projectile when in off hand
	["projectiles pierce an additional target"] = { mod("PierceCount", "BASE", 1) },
	["投射物会穿透 (%d+) 个额外目标"] = function(num) return { mod("PierceCount", "BASE", num) } end, --备注：projectiles pierce (%d+) targets?
	["projectiles pierce (%d+) additional targets?"] = function(num) return { mod("PierceCount", "BASE", num) } end,
	["处于【迷踪】状态时，投射物穿透 (%d+) 个额外目标"] = function(num) return { mod("PierceCount", "BASE", num, { type = "Condition", var = "Phasing" }) } end, --备注：projectiles pierce (%d+) additional targets while you have phasing
	["箭矢会穿透 1 个额外目标"] = { mod("PierceCount", "BASE", 1, nil, ModFlag.Attack) }, --备注：arrows pierce an additional target
	["arrows pierce one target"] = { mod("PierceCount", "BASE", 1, nil, ModFlag.Attack) },
	["arrows pierce (%d+) targets?"] = function(num) return { mod("PierceCount", "BASE", num, nil, ModFlag.Attack) } end,
	["always pierce with arrows"] = { flag("PierceAllTargets", nil, ModFlag.Attack) },
	["arrows always pierce"] = { flag("PierceAllTargets", nil, ModFlag.Attack) },
	["箭矢穿透所有目标"] = { flag("PierceAllTargets", nil, ModFlag.Attack) }, --备注：arrows pierce all targets
	["穿透后的箭矢造成流血"] = { mod("BleedChance", "BASE", 100, nil, bor(ModFlag.Attack, ModFlag.Projectile), { type = "StatThreshold", stat = "PierceCount", threshold = 1 }) }, --备注：arrows that pierce cause bleeding
	["穿透后的箭矢有 (%d+)%% 几率造成流血"] = function(num) return { mod("BleedChance", "BASE", num, nil, bor(ModFlag.Attack, ModFlag.Projectile), { type = "StatThreshold", stat = "PierceCount", threshold = 1 }) } end, --备注：arrows that pierce have (%d+)%% chance to cause bleeding
	["arrows that pierce deal (%d+)%% increased damage"] = function(num) return { mod("Damage", "INC", num, nil, bor(ModFlag.Attack, ModFlag.Projectile), { type = "StatThreshold", stat = "PierceCount", threshold = 1 }) } end,
	["每连锁弹射 1 次，投射物获得额外混沌伤害，其数值等同于非混沌伤害的 (%d+)%%"] = function(num) return { mod("NonChaosDamageGainAsChaos", "BASE", num, nil, ModFlag.Projectile, { type = "PerStat", stat = "Chain" }) } end, --备注：projectiles gain (%d+)%% of non%-chaos damage as extra chaos damage per chain
	-- Leech/Gain on Hit
	["不能偷取生命"] = { flag("CannotLeechLife") }, --备注：cannot leech life
	["不能偷取魔力"] = { flag("CannotLeechMana") }, --备注：cannot leech mana
	["低血时不能偷取"] = { flag("CannotLeechLife", { type = "Condition", var = "LowLife" }), flag("CannotLeechMana", { type = "Condition", var = "LowLife" }) }, --备注：cannot leech when on low life
	["暴击无法吸血"] = { flag("CannotLeechLife", { type = "Condition", var = "CriticalStrike" }) }, --备注：cannot leech life from critical strikes
	["leech applies instantly on critical strike"] = { flag("InstantLifeLeech", { type = "Condition", var = "CriticalStrike" }), flag("InstantManaLeech", { type = "Condition", var = "CriticalStrike" }) },
	["暴击时立即获得生命和魔力偷取"] = { flag("InstantLifeLeech", { type = "Condition", var = "CriticalStrike" }), flag("InstantManaLeech", { type = "Condition", var = "CriticalStrike" }) }, --备注：gain life and mana from leech instantly on critical strike
	["leech applies instantly during flask effect"] = { flag("InstantLifeLeech", { type = "Condition", var = "UsingFlask" }), flag("InstantManaLeech", { type = "Condition", var = "UsingFlask" }) },
	["gain life and mana from leech instantly during flask effect"] = { flag("InstantLifeLeech", { type = "Condition", var = "UsingFlask" }), flag("InstantManaLeech", { type = "Condition", var = "UsingFlask" }) },
	["装备 5 个被腐化物品时：生命偷取只按照造成的混沌伤害计算"] = { flag("LifeLeechBasedOnChaosDamage", { type = "MultiplierThreshold", var = "CorruptedItem", threshold = 5 }) }, --备注：with 5 corrupted items equipped: life leech recovers based on your chaos damage instead
	["you have vaal pact if you've dealt a critical strike recently"] = { mod("Keystone", "LIST", "Vaal Pact", { type = "Condition", var = "CritRecently" }) },
	["你每击中 1 个被【蜘蛛网】覆盖的敌人，便获得 (%d+) 能量护盾"] = function(num) return { mod("EnergyShieldOnHit", "BASE", num, { type = "MultiplierThreshold", actor = "enemy", var = "Spider's WebStack", threshold = 1 }) } end, --备注：gain (%d+) energy shield for each enemy you hit which is affected by a spider's web
	["(%d+) life gained for each enemy hit if you have used a vaal skill recently"] = function(num) return { mod("LifeOnHit", "BASE", num, { type = "Condition", var = "UsedVaalSkillRecently"}) } end,
	-- Defences
	["无法闪避敌人攻击"] = { flag("CannotEvade") }, --备注：cannot evade enemy attacks
	["无法格档"] = { flag("CannotBlockAttacks"), flag("CannotBlockSpells") }, --备注：cannot block
	["无法格挡攻击"] = { flag("CannotBlockAttacks") }, --备注：cannot block attacks
	["无法格挡法术"] = { flag("CannotBlockSpells") }, --备注：cannot block spells
	["无法回复生命"] = { flag("NoLifeRegen") }, --备注：you have no life regeneration
	["解除护甲或能量护盾"] = { --备注：you have no armour or energy shield
		mod("Armour", "MORE", -100),
		mod("EnergyShield", "MORE", -100),
	},
	["火焰、冰霜、闪电抗性为零"] = { --备注：elemental resistances are zero
		mod("FireResist", "OVERRIDE", 0),
		mod("ColdResist", "OVERRIDE", 0),
		mod("LightningResist", "OVERRIDE", 0)
	},
	["你的最大抗性为 (%d+)%%"] = function(num) return { --备注：your maximum resistances are (%d+)%%
		mod("FireResistMax", "OVERRIDE", num),
		mod("ColdResistMax", "OVERRIDE", num),
		mod("LightningResistMax", "OVERRIDE", num),
		mod("ChaosResistMax", "OVERRIDE", num)
	} end,
	["护甲将随绝对火焰抗性而提高"] = { mod("Armour", "INC", 1, { type = "PerStat", stat = "FireResistTotal", div = 1 }) }, --备注：armour is increased by uncapped fire resistance
	["闪避值将随绝对冰霜抗性提高"] = { mod("Evasion", "INC", 1, { type = "PerStat", stat = "ColdResistTotal", div = 1 }) }, --备注：evasion rating is increased by uncapped cold resistance
	["反射 (%d+) 物理伤害给近战攻击者"] = { }, --备注：reflects (%d+) physical damage to melee attackers
	["无视穿着护甲所带来的移动速度降低效果"] = { flag("Condition:IgnoreMovementPenalties") }, --备注：ignore all movement penalties from armour
	["获得等同于你魔力保留数值的护甲"] = { mod("Armour", "BASE", 1, { type = "PerStat", stat = "ManaReserved", div = 1 }) }, --备注：gain armour equal to your reserved mana
	["免疫晕眩"] = { mod("AvoidStun", "BASE", 100) }, --备注：cannot be stunned
	["若你近期内没有被击中，则免疫晕眩"] = { mod("AvoidStun", "BASE", 100, { type = "Condition", var = "BeenHitRecently", neg = true }) }, --备注：cannot be stunned if you haven't been hit recently
	["若你拥有 (%d+) 个以上的【深海屏障】，则无法被晕眩"] = function(num) return { mod("AvoidStun", "BASE", 100, { type = "StatThreshold", stat = "CrabBarriers", threshold = num }) } end, --备注：cannot be stunned if you have at least (%d+) crab barriers
	["cannot be shocked"] = { mod("AvoidShock", "BASE", 100) },
	["免疫感电"] = { mod("AvoidShock", "BASE", 100) }, --备注：immune to shock
	["免疫冰冻"] = { mod("AvoidFreeze", "BASE", 100) }, --备注：cannot be frozen
	["immune to freeze"] = { mod("AvoidFreeze", "BASE", 100) },
	["免疫冰缓"] = { mod("AvoidChill", "BASE", 100) }, --备注：cannot be chilled
	["免疫冰缓"] = { mod("AvoidChill", "BASE", 100) }, --备注：immune to chill
	["cannot be ignited"] = { mod("AvoidIgnite", "BASE", 100) },
	["免疫点燃"] = { mod("AvoidIgnite", "BASE", 100) }, --备注：immune to ignite
	["你在耐力球达到上限时无法被感电"] = { mod("AvoidShock", "BASE", 100, { type = "StatThreshold", stat = "EnduranceCharges", thresholdStat = "EnduranceChargesMax" }) }, --备注：you cannot be shocked while at maximum endurance charges
	["若智慧高于力量，则无法被感电"] = { mod("AvoidShock", "BASE", 100, { type = "Condition", var = "IntHigherThanStr" }) }, --备注：cannot be shocked if intelligence is higher than strength
	["若敏捷高于智慧，则无法被冰冻"] = { mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "DexHigherThanInt" }) }, --备注：cannot be frozen if dexterity is higher than intelligence
	["若力量高于敏捷，则无法被点燃"] = { mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "StrHigherThanDex" }) }, --备注：cannot be ignited if strength is higher than dexterity
	["cannot be inflicted with bleeding"] = { mod("AvoidBleed", "BASE", 100) },
	["免疫流血"] = { mod("AvoidBleed", "BASE", 100) }, --备注：you are immune to bleeding
	["药剂持续期间免疫感电效果"] = { mod("AvoidShock", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：immunity to shock during flask effect
	["药剂持续期间免疫冰冻和冰缓"] = {  --备注：immunity to freeze and chill during flask effect
		mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "UsingFlask" }), 
		mod("AvoidChill", "BASE", 100, { type = "Condition", var = "UsingFlask" }) 
	},
	["药剂持续期间免疫点燃"] = { mod("AvoidIgnite", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：immunity to ignite during flask effect
	["药剂持续期间免疫流血"] = { mod("AvoidBleed", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：immunity to bleeding during flask effect
	["药剂持续期间免疫中毒"] = { mod("AvoidPoison", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：immune to poison during flask effect
	["药剂持续期间免疫诅咒"] = { mod("AvoidCurse", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：immune to curses during flask effect
	["药剂持续期间，免疫冰冻、冰缓、诅咒和晕眩"] = {  --备注：immune to freeze, chill, curses and stuns during flask effect
		mod("AvoidFreeze", "BASE", 100, { type = "Condition", var = "UsingFlask" }), 
		mod("AvoidChill", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
		mod("AvoidCurse", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
		mod("AvoidStun", "BASE", 100, { type = "Condition", var = "UsingFlask" }),
	},
	["不受诅咒影响"] = { mod("CurseEffectOnSelf", "MORE", -100) }, --备注：unaffected by curses
	["你身上的冰缓效果颠倒"] = { flag("SelfChillEffectIsReversed") }, --备注：the effect of chill on you is reversed
	-- Knockback
	["无法击退敌人"] = { flag("CannotKnockback") }, --备注：cannot knock enemies back
	["长杖攻击暴击时击退敌人"] = { mod("EnemyKnockbackChance", "BASE", 100, nil, ModFlag.Staff, { type = "Condition", var = "CriticalStrike" }) }, --备注：knocks back enemies if you get a critical strike with a staff
	["弓类攻击暴击时击退敌人"] = { mod("EnemyKnockbackChance", "BASE", 100, nil, ModFlag.Bow, { type = "Condition", var = "CriticalStrike" }) }, --备注：knocks back enemies if you get a critical strike with a bow
	["近距离时，弓类攻击会击退敌人"] = { mod("EnemyKnockbackChance", "BASE", 100, nil, ModFlag.Bow, { type = "Condition", var = "AtCloseRange" }) }, --备注：bow knockback at close range
	["药剂持续期间，附加击退效果"] = { mod("EnemyKnockbackChance", "BASE", 100, { type = "Condition", var = "UsingFlask" }) }, --备注：adds knockback during flask effect
	["药剂持续期间，近战攻击会击退敌人"] = { mod("EnemyKnockbackChance", "BASE", 100, nil, ModFlag.Melee, { type = "Condition", var = "UsingFlask" }) }, --备注：adds knockback to melee attacks during flask effect
	-- Flasks
	["不会获得药剂的效果"] = { flag("FlasksDoNotApplyToPlayer") }, --备注：flasks do not apply to you
	["flasks apply to your zombies and spectres"] = { flag("FlasksApplyToMinion", { type = "SkillName", skillNameList = { "Raise Zombie", "Raise Spectre" } }) },
	["使用时制造一团烟雾"] = { }, --备注：creates a smoke cloud on use
	["creates chilled ground on use"] = { },
	["使用时制造奉献地面"] = { }, --备注：creates consecrated ground on use
	["药剂持续期间，获得不洁之力"] = { flag("Condition:UnholyMight", { type = "Condition", var = "UsingFlask" }) }, --备注：gain unholy might during flask effect
	["药剂持续期间获得【狂热誓言】"] = { mod("ZealotsOath", "FLAG", true, { type = "Condition", var = "UsingFlask" }) }, --备注：zealot's oath during flask effect
	["药剂持续期间，获得 (%d+) 级的【(.+)】诅咒光环"] = function(num, _, skill) return { mod("ExtraCurse", "LIST", { skillId = FuckSkillSupportCnName(skill:gsub(" skill","")) or "Unknown", level = num }, { type = "Condition", var = "UsingFlask" }) } end, --备注：grants level (%d+) (.+) curse aura during flask effect
	["药剂持续期间，你绝对抗性最低的元素属性，会使你受到的该属性伤害降低 (%d+)%%"] = function(num) return { --备注：during flask effect, (%d+)%% reduced damage taken of each element for which your uncapped elemental resistance is lowest
		mod("LightningDamageTaken", "INC", -num, { type = "StatThreshold", stat = "LightningResistTotal", thresholdStat = "ColdResistTotal", upper = true }, { type = "StatThreshold", stat = "LightningResistTotal", thresholdStat = "FireResistTotal", upper = true }),
		mod("ColdDamageTaken", "INC", -num, { type = "StatThreshold", stat = "ColdResistTotal", thresholdStat = "LightningResistTotal", upper = true }, { type = "StatThreshold", stat = "ColdResistTotal", thresholdStat = "FireResistTotal", upper = true }),
		mod("FireDamageTaken", "INC", -num, { type = "StatThreshold", stat = "FireResistTotal", thresholdStat = "LightningResistTotal", upper = true }, { type = "StatThreshold", stat = "FireResistTotal", thresholdStat = "ColdResistTotal", upper = true }),
	} end,
	["药剂持续期间，你绝对抗性最高的元素属性，会使你穿透 (%d+)%% 该抗性"] = function(num) return { --备注：during flask effect, damage penetrates (%d+)%% o?f? ?resistance of each element for which your uncapped elemental resistance is highest
		mod("LightningPenetration", "BASE", num, { type = "StatThreshold", stat = "LightningResistTotal", thresholdStat = "ColdResistTotal" }, { type = "StatThreshold", stat = "LightningResistTotal", thresholdStat = "FireResistTotal" }),
		mod("ColdPenetration", "BASE", num, { type = "StatThreshold", stat = "ColdResistTotal", thresholdStat = "LightningResistTotal" }, { type = "StatThreshold", stat = "ColdResistTotal", thresholdStat = "FireResistTotal" }),
		mod("FirePenetration", "BASE", num, { type = "StatThreshold", stat = "FireResistTotal", thresholdStat = "LightningResistTotal" }, { type = "StatThreshold", stat = "FireResistTotal", thresholdStat = "ColdResistTotal" }),
	} end,
	["每秒受到等同 (%d+)%% 最大生命的混沌伤害"] = function(num) return { mod("ChaosDegen", "BASE", num/100, { type = "PerStat", stat = "Life", div = 1 }) } end, --备注：(%d+)%% of maximum life taken as chaos damage per second
	["药剂持续期间，你的暴击无法造成暴击伤害加成"] = { flag("NoCritMultiplier", { type = "Condition", var = "UsingFlask" }) }, --备注：your critical strikes do not deal extra damage during flask effect
	["grants perfect agony during flask effect"] = { mod("Keystone", "LIST", "Perfect Agony", { type = "Condition", var = "UsingFlask" }) },
	-- Jewels
	["未连结至天赋树的技能，仍然可以在范围内配置"] = { mod("JewelData", "LIST", { key = "intuitiveLeapLike", value = true }) }, --备注：passives in radius can be allocated without being connected to your tree
	["每 1 个聚光之石可使火焰、冰霜、闪电伤害提高 (%d+)%%"] = function(num) return {  --备注：(%d+)%% increased elemental damage per grand spectrum
		mod("ElementalDamage", "INC", num, { type = "Multiplier", var = "GrandSpectrum" }), 
		mod("Multiplier:GrandSpectrum", "BASE", 1) 
	} end,
	["每 1 个聚光之石可使护甲提高 (%d+)"] = function(num) return {  --备注：gain (%d+) armour per grand spectrum
		mod("Armour", "BASE", num, { type = "Multiplier", var = "GrandSpectrum" }), 
		mod("Multiplier:GrandSpectrum", "BASE", 1) 
	} end,
	["每 1 个聚光之石可使魔力提高 (%d+)"] = function(num) return { --备注：gain (%d+) mana per grand spectrum
		mod("Mana", "BASE", num, { type = "Multiplier", var = "GrandSpectrum" }),
		mod("Multiplier:GrandSpectrum", "BASE", 1) 
	} end,
	["起源珠宝"] = { mod("Multiplier:PrimordialItem", "BASE", 1) }, --备注：primordial
	["spectres have a base duration of (%d+) seconds"] = function(num) return { mod("SkillData", "LIST", { key = "duration", value = 6 }, { type = "SkillName", skillName = "召唤灵体" }) } end,
	["flasks applied to you have (%d+)%% increased effect"] = function(num) return { mod("FlaskEffect", "INC", num) } end,
	["adds (%d+) passive skills"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelNodeCount", value = num }) } end,
	
	["1 added passive skill is a jewel socket"] = { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = 1 }) },
	["(%d+) added passive skills are jewel sockets"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = num }) } end,
	["adds (%d+) jewel socket passive skills"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelSocketCountOverride", value = num }) } end,
	["adds (%d+) small passive skills? which grants? nothing"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelNothingnessCount", value = num }) } end,
	["added small passive skills grant nothing"] = { mod("JewelData", "LIST", { key = "clusterJewelSmallsAreNothingness", value = true }) },
	
	
	["added small passive skills have (%d+)%% increased effect"] = function(num) return { mod("JewelData", "LIST", { key = "clusterJewelIncEffect", value = num }) } end,
	-- Misc
	["iron will"] = { flag("IronWill") },
	["iron reflexes while stationary"] = { mod("Keystone", "LIST", "Iron Reflexes", { type = "Condition", var = "Stationary" }) },
	["you have zealot's oath if you haven't been hit recently"] = { mod("Keystone", "LIST", "Zealot's Oath", { type = "Condition", var = "BeenHitRecently", neg = true }) },
	["无法造成物理伤害"] = { flag("DealNoPhysical") }, --备注：deal no physical damage
	["无法造成火焰、冰霜、闪电伤害"] = { flag("DealNoLightning"), flag("DealNoCold"), flag("DealNoFire") }, --备注：deal no elemental damage
	["无法造成非火焰、冰霜、闪电伤害"] = { flag("DealNoPhysical"), flag("DealNoChaos") }, --备注：deal no non%-elemental damage
	["所有攻击都受到血魔法辅助"] = { flag("SkillBloodMagic", nil, ModFlag.Attack) }, --备注：attacks have blood magic
	["(%d+)%% chance to cast a? ?socketed lightning spells? on hit"] = function(num) return { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) } end,
	["cast a socketed lightning spell on hit"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["trigger a socketed lightning spell on hit"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueMjolnerLightningSpellsCastOnHit", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) },
	["近战暴击时触发插槽内的冰霜技能"] = { mod("ExtraSupport", "LIST", { skillId = "SupportUniqueCosprisMaliceColdSpellsCastOnMeleeCriticalStrike", level = 1 }, { type = "SocketedIn", slotName = "{SlotName}" }) }, --备注：cast a socketed cold s[pk][ei]ll on melee critical strike
	["你的诅咒对有【无咒】词缀的敌人依然有效"] = { flag("CursesIgnoreHexproof") }, --备注：your curses can apply to hexproof enemies
	["当你拥有护体时获得【猛攻】状态"] = { flag("Condition:Onslaught", { type = "Condition", var = "Fortify" }) }, --备注：you have onslaught while you have fortify
	["保留 (%d+)%% 生命"] = function(num) return { mod("ExtraLifeReserved", "BASE", num) } end, --备注：reserves (%d+)%% of life
	["装备和技能石的属性需求降低 (%d+)%%"] = function(num) return { mod("GlobalAttributeRequirements", "INC", -num) } end, --备注：items and gems have (%d+)%% reduced attribute requirements
	["items and gems have (%d+)%% increased attribute requirements"] = function(num) return { mod("GlobalAttributeRequirements", "INC", num) } end,
	["捷光环的魔力保留总是 (%d+)%%"] = function(num) return { mod("SkillData", "LIST", { key = "ManaReservationPercentForced", value = num }, { type = "SkillType", skillType = SkillType.Herald }) } end, --备注：mana reservation of herald skills is always (%d+)%%
	["【猫之势】不保留魔力值"] = { mod("SkillData", "LIST", { key = "ManaReservationPercentForced", value = 0 }, { type = "SkillName", skillName = "猫之势" }) }, --备注：aspect of the cat reserves no mana
	["你的法术被禁用了"] = { flag("DisableSkill", { type = "SkillType", skillType = SkillType.Spell }) }, --备注：your spells are disabled
	["strength's damage bonus instead grants (%d+)%% increased melee physical damage per (%d+) strength"] = function(num, _, perStr) return { mod("StrDmgBonusRatioOverride", "BASE", num / tonumber(perStr)) } end,
	["受到【她的拥抱】影响时，每级根据你的最大生命和最大护盾总量，造成每秒 ([%d%.]+)%% 火焰伤害"] = function(num) return {  --备注：while in her embrace, take ([%d%.]+)%% of your total maximum life and energy shield as fire damage per second per level
		mod("FireDegen", "BASE", 0.005, { type = "PerStat", stat = "Life" }, { type = "Multiplier", var = "Level" }, { type = "Condition", var = "HerEmbrace" }),
		mod("FireDegen", "BASE", 0.005, { type = "PerStat", stat = "EnergyShield" }, { type = "Multiplier", var = "Level" }, { type = "Condition", var = "HerEmbrace" }),
	} end,
	["点燃敌人时获得【女神的祝福】 %d+ 秒"] = { flag("Condition:CanGainHerEmbrace") }, --备注：gain her embrace for %d+ seconds when you ignite an enemy
	["你被点燃时，击中怪物敌人无视其火焰抗性"] = { flag("IgnoreFireResistance", { type = "Condition", var = "Ignited" }) }, --备注：hits ignore enemy monster fire resistance while you are ignited
	["你的攻击和法术无法被致盲的敌人所闪避"] = { flag("CannotBeEvaded", { type = "ActorCondition", actor = "enemy", var = "Blinded" }) }, --备注：your hits can't be evaded by blinded enemies
	["投掷陷阱的技能受到血魔法辅助"] = { flag("BloodMagic", { type = "SkillType", skillType = SkillType.Trap }) }, --备注：skills which throw traps have blood magic
	["每秒失去 ([%d%.]+) 魔力"] = function(num) return { mod("ManaDegen", "BASE", num) } end, --备注：lose ([%d%.]+) mana per second
	["每秒失去 ([%d%.]+)%% 最大魔力"] = function(num) return { mod("ManaDegen", "BASE", num/100, { type = "PerStat", stat = "Mana" }) } end, --备注：lose ([%d%.]+)%% of maximum mana per second
	["力量不对最大生命提供加成"] = { flag("NoStrBonusToLife") }, --备注：strength provides no bonus to maximum life
	["智慧不对最大魔力提供加成"] = { flag("NoIntBonusToMana") }, --备注：intelligence provides no bonus to maximum mana
	["with a ghastly eye jewel socketed, minions have %+(%d+) to accuracy rating"] = function(num) return { mod("MinionModifier", "LIST", { mod = mod("Accuracy", "BASE", num) }, { type = "Condition", var = "HaveGhastlyEyeJewelIn{SlotName}" }) } end,
	-- Skill-specific enchantment modifiers
	["(%d+)%% increased decoy totem life"] = function(num) return { mod("TotemLife", "INC", num, { type = "SkillName", skillName = "诱饵图腾" }) } end,
	["(%d+)%% increased ice spear critical strike chance in second form"] = function(num) return { mod("CritChance", "INC", num, { type = "SkillName", skillName = "冰矛" }, { type = "SkillPart", skillPart = 2 }) } end,
	["shock nova ring deals (%d+)%% increased damage"] = function(num) return { mod("Damage", "INC", num, { type = "SkillName", skillName = "闪电新星" }, { type = "SkillPart", skillPart = 1 }) } end,
	["lightning strike pierces (%d) additional targets?"] = function(num) return { mod("PierceCount", "BASE", num, { type = "SkillName", skillName = "闪电打击" }) } end,
	["lightning trap pierces (%d) additional targets?"] = function(num) return { mod("PierceCount", "BASE", num, { type = "SkillName", skillName = "闪电陷阱" }) } end,
	["enemies affected by bear trap take (%d+)%% increased damage from trap or mine hits"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("TrapMineDamageTaken", "INC", num, { type = "GlobalEffect", effectType = "Debuff" }) }, { type = "SkillName", skillName = "捕熊陷阱" }) } end,
	["blade vortex has %+(%d+)%% to critical strike multiplier for each blade"] = function(num) return { mod("CritMultiplier", "BASE", num, { type = "Multiplier", var = "BladeVortexBlade" }, { type = "SkillName", skillName = "飞刃风暴" }) } end,
	["double strike has a (%d+)%% chance to deal double damage to bleeding enemies"] = function(num) return { mod("DoubleDamageChance", "BASE", num, { type = "ActorCondition", actor = "enemy", var = "Bleeding" }, { type = "SkillName", skillName = "双重打击" }) } end,
	["ethereal knives pierces an additional target"] = { mod("PierceCount", "BASE", 1, { type = "SkillName", skillName = "虚空匕首" }) },
	["frost bomb has (%d+)%% increased debuff duration"] = function(num) return { mod("SecondaryDuration", "INC", num, { type = "SkillName", skillName = "寒霜爆" }) } end,
	["incinerate has %+(%d+) to maximum stages"] = function(num) return {
		mod("Multiplier:IncinerateStage", "BASE", num/2, 0, 0, { type = "SkillPart", skillPart = 2 }),
		mod("Multiplier:IncinerateStage", "BASE", num, 0, 0, { type = "SkillPart", skillPart = 3 })
	} end,
	["scourge arrow has (%d+)%% chance to poison per stage"] = function(num) return { mod("PoisonChance", "BASE", num, { type = "SkillName", skillName = "Scourge Arrow" }, { type = "Multiplier", var = "ScourgeArrowStage" }) } end,
	-- Display-only modifiers
	["prefixes:"] = { },
	["suffixes:"] = { },
	["当你在你在天赋树上连接到一个职业的出发位置时，你获得："] = { }, --备注：while your passive skill tree connects to a class' starting location, you gain:
	["触发后，插槽内闪电法术的法术伤害提高 (%d+)%%"] = { }, --备注：socketed lightning spells [hd][ae][va][el] (%d+)%% increased spell damage if triggered
	["【幻化之刃德尔维希】会使你主手和副手武器装备栏失效"] = { }, --备注：manifeste?d? dancing dervish disables both weapon slots
	["【幻化之刃德尔维希】在暴走结束时死亡"] = { }, --备注：manifeste?d? dancing dervish dies when rampage ends
	--3.15
	["烙印暴击率提高 (%d+)%%"]= function(num) return {  mod("CritChance", "INC", num,{ type = "SkillType", skillType = SkillType.Brand })   } end,
	["(%d+)%% 烙印暴击伤害加成"]= function(num) return {  mod("CritMultiplier", "BASE", num,{ type = "SkillType", skillType = SkillType.Brand })   } end,
	["枯萎效果提高"] = function(num) return {  mod("WitherEffect", "INC", num)   } end,
	["持续混沌伤害提高 %+(%d+)%%"] = function(num) return {  mod("ChaosDamage", "INC", num, nil, ModFlag.ChaosDot)  } end,
}

for _, name in pairs(data.keystones) do
	specialModList[name:lower()] = { mod("Keystone", "LIST", name) }
end
local oldList = specialModList
specialModList = { }
for k, v in pairs(oldList) do
	specialModList["^"..k.."$"] = v
end

-- Modifiers that are recognised but unsupported
local unsupportedModList = {
	
	["properties are doubled while in a breach"] = true,
	["mirrored"] = true,
	["split"] = true,
}

-- Special lookups used for various modifier forms
local suffixTypes = {
	["as extra lightning damage"] = "GainAsLightning",
	["added as lightning damage"] = "GainAsLightning",
	["gained as extra lightning damage"] = "GainAsLightning",
	["as extra cold damage"] = "GainAsCold",
	["added as cold damage"] = "GainAsCold",
	["gained as extra cold damage"] = "GainAsCold",
	["as extra fire damage"] = "GainAsFire",
	["added as fire damage"] = "GainAsFire",
	["gained as extra fire damage"] = "GainAsFire",
	["as extra chaos damage"] = "GainAsChaos",
	["added as chaos damage"] = "GainAsChaos",
	["gained as extra chaos damage"] = "GainAsChaos",
	["转换为闪电"] = "ConvertToLightning", --备注：converted to lightning
	["转换为闪电伤害"] = "ConvertToLightning", --备注：converted to lightning damage
	["转换为冰霜伤害"] = "ConvertToCold", --备注：converted to cold damage
	["转换为火焰伤害"] = "ConvertToFire", --备注：converted to fire damage
	["转换为混沌伤害"] = "ConvertToChaos", --备注：converted to chaos damage
	["added as energy shield"] = "GainAsEnergyShield",
	["的额外能量护盾"] = "GainAsEnergyShield", --备注：as extra maximum energy shield
	["converted to energy shield"] = "ConvertToEnergyShield",
	["as physical damage"] = "AsPhysical",
	["as lightning damage"] = "AsLightning",
	["as cold damage"] = "AsCold",
	["转化为火焰伤害"] = "AsFire", --备注：as fire damage
	["as chaos damage"] = "AsChaos",
	["生命和魔力"] = "Leech", --备注：leeched as life and mana
	["生命偷取"] = "LifeLeech", --备注：leeched as life
	["转化为生命偷取"] = "LifeLeech", --备注：is leeched as life
	["魔力偷取"] = "ManaLeech", --备注：leeched as mana
	["转化为魔力偷取"] = "ManaLeech", --备注：is leeched as mana
	["leeched as energy shield"] = "EnergyShieldLeech",
	["is leeched as energy shield"] = "EnergyShieldLeech",
}
local dmgTypes = {
	["物理"] = "Physical", --备注：physical
	["闪电"] = "Lightning", --备注：lightning
	["冰霜"] = "Cold", --备注：cold
	["火焰"] = "Fire", --备注：fire
	["混沌"] = "Chaos", --备注：chaos
}
local penTypes = {
	["闪电抗性"] = "LightningPenetration", --备注：lightning resistance
	["冰霜抗性"] = "ColdPenetration", --备注：cold resistance
	["火焰抗性"] = "FirePenetration", --备注：fire resistance
	["火焰、冰霜、闪电抗性"] = "ElementalPenetration", --备注：elemental resistance
	["获得 ([%+%-]?%d+)%% 火焰、冰霜、闪电抗性"] = "ElementalPenetration", --备注：elemental resistances
	["混沌抗性"] = "ChaosPenetration", --备注：chaos resistance
	["元素抗性"] = "ElementalPenetration",
}
local regenTypes = {
	["生命"] = "LifeRegen", --备注：life
	["最大生命"] = "LifeRegen", --备注：maximum life
	["life and mana"] = { "LifeRegen", "ManaRegen" },
	["魔力"] = "ManaRegen", --备注：mana
	["最大魔力"] = "ManaRegen", --备注：maximum mana
	["能量护盾"] = "EnergyShieldRegen", --备注：energy shield
	["最大能量护盾"] = "EnergyShieldRegen", --备注：maximum energy shield
	["maximum mana and energy shield"] = { "ManaRegen", "EnergyShieldRegen" },
	["怒火"] = "RageRegen",
}

-- Build active skill name lookup
local skillNameList = {
	[" corpse cremation " ] = { tag = { type = "SkillName", skillName = "火葬" } }, -- Sigh.
}
local preSkillNameList = { }
	--【中文化程序额外添加开始】
	 skillNameList["【旋涡】"] = { tag = { type = "SkillName", skillName = “漩涡” } }
	  skillNameList["先祖战士长图腾"] = { tag = { type = "SkillName", skillName = 先祖战士长 } }
	--【中文化程序额外添加结束】
for gemId, gemData in pairs(data.gems) do
	local grantedEffect = gemData.grantedEffect
	if not grantedEffect.hidden and not grantedEffect.support then
		local skillName = FuckSkillActivityCnName(grantedEffect.name)
		skillNameList[" "..skillName:lower().." "] = { tag = { type = "SkillName", skillName = skillName } }
		preSkillNameList["^"..skillName:lower().." "] = { tag = { type = "SkillName", skillName = skillName } }
preSkillNameList["^"..skillName:lower().." has ?a? "] = { tag = { type = "SkillName", skillName = skillName } } preSkillNameList["^【"..skillName:lower().."】"] = { tag = { type = "SkillName", skillName = skillName } }  preSkillNameList["^【"..skillName:lower().."】的"] = { tag = { type = "SkillName", skillName = skillName } }
		preSkillNameList["^"..skillName:lower().." deals "] = { tag = { type = "SkillName", skillName = skillName } }
		preSkillNameList["^"..skillName:lower().." damage "] = { tag = { type = "SkillName", skillName = skillName } }
		
		specialModList["【"..skillName:lower().."】的伤害提高 ([%d%.]+)%%"] = function(num) return { mod("Damage", "INC", num, { type = "SkillName", skillName = skillName }) } end
		specialModList[skillName:lower().."的伤害提高 ([%d%.]+)%%"] = function(num) return { mod("Damage", "INC", num, { type = "SkillName", skillName = skillName }) } end
		
		if gemData.tags.duration then
			specialModList["【"..skillName:lower().."】的持续时间延长 ([%d%.]+)%%"] = function(num) return { mod("Duration", "INC", num, { type = "SkillName", skillName = skillName }) } end
			specialModList[skillName:lower().."的持续时间延长 ([%d%.]+)%%"] = function(num) return { mod("Duration", "INC", num, { type = "SkillName", skillName = skillName }) } end
		end	
			
		if gemData.tags.totem then
			preSkillNameList["^"..skillName:lower().." totem deals "] = { tag = { type = "SkillName", skillName = skillName } }
			preSkillNameList["^"..skillName:lower().." totem grants "] = { addToSkill = { type = "SkillName", skillName = skillName }, tag = { type = "GlobalEffect", effectType = "Buff" } }
		end
		if grantedEffect.skillTypes[SkillType.Buff] or grantedEffect.baseFlags.buff then
			preSkillNameList["^"..skillName:lower().." grants "] = { addToSkill = { type = "SkillName", skillName = skillName }, tag = { type = "GlobalEffect", effectType = "Buff" } }
			preSkillNameList["^"..skillName:lower().." grants a?n? ?additional "] = { addToSkill = { type = "SkillName", skillName = skillName }, tag = { type = "GlobalEffect", effectType = "Buff" } }
			
			
		end
		if grantedEffect.skillTypes[SkillType.Buff] or grantedEffect.baseFlags.buff or grantedEffect.skillTypes[SkillType.Aura] 
		or  grantedEffect.skillTypes[SkillType.ManaCostReserved] 
		then
		
		specialModList["【"..skillName:lower().."】的保留效果降低 ([%d%.]+)%%"] = function(num) return { mod("Reserved", "INC", -num, { type = "SkillName", skillName = skillName }) } end
		specialModList[skillName:lower().."的保留效果降低 ([%d%.]+)%%"] = function(num) return { mod("Reserved", "INC", -num, { type = "SkillName", skillName = skillName }) } end
		specialModList[skillName:lower().."没有保留效果"] = function(num) return { 
			
			mod("SkillData", "LIST", { key = "manaReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[skillName] }),			
			mod("SkillData", "LIST", { key = "lifeReservationFlat", value = 0 }, { type = "SkillId", skillId = gemIdLookup[skillName] }),			
			mod("SkillData", "LIST", { key = "manaReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[skillName] }),
			mod("SkillData", "LIST", { key = "lifeReservationPercent", value = 0 }, { type = "SkillId", skillId = gemIdLookup[skillName] }),
			
			} end
			
		end	
			
		if gemData.tags.curse then 			
			specialModList[skillName:lower().."以光环形式施放时，其保留效果降低 ([%d%.]+)%%"]  = function(num) return { mod("Reserved", "INC", -num, { type = "SkillName", skillName = skillName }) } end
		end
		
		if gemData.tags.aura or gemData.tags.herald  then
skillNameList["受到【"..skillName:lower().."】影响时，"] = { tag = { type = "Condition", var = "AffectedBy"..skillName:gsub(" ","") } }
			
			skillNameList["while using "..skillName:lower()] = { tag = { type = "Condition", var = "AffectedBy"..skillName:gsub(" ","") } }
			 
			specialModList[skillName:lower().."的保留效果总降 ([%d%.]+)%%"] = function(num) return { mod("Reserved", "MORE", -num, { type = "SkillName", skillName = skillName }) } end
		
			
		

		end
		if gemData.tags.mine then
			specialModList["^"..skillName:lower().."的投掷速度提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("MineLayingSpeed", "INC", num) }, { type = "SkillName", skillName = skillName }) } end
			specialModList["^"..skillName:lower().."投掷速度提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("MineLayingSpeed", "INC", num) }, { type = "SkillName", skillName = skillName }) } end
			specialModList["^"..skillName:lower().."地雷投掷速度提高 (%d+)%%"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("MineLayingSpeed", "INC", num) }, { type = "SkillName", skillName = skillName }) } end
			
		end
		if gemData.tags.chaining then
			specialModList["^【"..skillName:lower().."】额外连锁弹射 1 次"] = { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", 1) }, { type = "SkillName", skillName = skillName }) }
			specialModList["^【"..skillName:lower().."】额外连锁弹射 (%d+) 次"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", num) }, { type = "SkillName", skillName = skillName }) } end
			specialModList["^【"..skillName:lower().."】的射线会额外连锁 (%d+) 次"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ChainCountMax", "BASE", num) }, { type = "SkillName", skillName = skillName }) } end
		end
		if gemData.tags.bow then
			specialModList["^【"..skillName:lower().."】可以额外发射 (%d+) 个箭矢"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", num) }, { type = "SkillName", skillName = skillName }) } end
		end
		if gemData.tags.bow or gemData.tags.projectile then
			specialModList["^【"..skillName:lower().."】可以额外发射 1 个投射物"] = { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", 1) }, { type = "SkillName", skillName = skillName }) }
			specialModList["^【"..skillName:lower().."】可以额外发射 (%d+) 个投射物"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", num) }, { type = "SkillName", skillName = skillName }) } end
			specialModList["^【"..skillName:lower().."】可额外发射 (%d+) 个碎片投射物"] = function(num) return { mod("ExtraSkillMod", "LIST", { mod = mod("ProjectileCount", "BASE", num) }, { type = "SkillName", skillName = skillName }) } end
		
		end
	end	
end

-- Radius jewels that modify other nodes
local function getSimpleConv(srcList, dst, type, remove, factor)
	return function(node, out, data)
		if node then
			for _, src in pairs(srcList) do
				for _, mod in ipairs(node.modList) do
					if mod.name == src and mod.type == type then
						if remove then
							out:MergeNewMod(src, type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						end
						if factor then
							out:MergeNewMod(dst, type, math.floor(mod.value * factor), mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						else
							out:MergeNewMod(dst, type, mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						end
					end
				end	
			end
		end
	end
end
local jewelOtherFuncs = {
	--【中文化程序额外添加开始】
	["范围内提高闪电抗性或所有元素抗性的天赋也会以 35% 的比例提高法术伤害格挡几率"] = getSimpleConv({"LightningResist","ElementalResist"}, "SpellBlockChance", "BASE", false, 0.35),
	["范围内提高火焰抗性或所有元素的天赋也会以 35% 的比例提高攻击伤害格挡几率"] = getSimpleConv({"FireResist","ElementalResist"}, "BlockChance", "BASE", false, 0.35),
	["范围内提高冰霜抗性或所有元素的天赋也会以 35% 的比例提高躲避攻击击中几率"] = getSimpleConv({"ColdResist","ElementalResist"}, "AttackDodgeChance", "BASE", false, 0.35), 
	--【中文化程序额外添加结束】
	["将范围内天赋所给予的力量转换成敏捷"] = getSimpleConv({"Str"}, "Dex", "BASE", true), --备注：Strength from Passives in Radius is Transformed to Dexterity
	["将范围内天赋所给予的敏捷转换成力量"] = getSimpleConv({"Dex"}, "Str", "BASE", true), --备注：Dexterity from Passives in Radius is Transformed to Strength
	["将范围内天赋所给予的力量转换成智慧"] = getSimpleConv({"Str"}, "Int", "BASE", true), --备注：Strength from Passives in Radius is Transformed to Intelligence
	["将范围内天赋所给予的智慧转换成力量"] = getSimpleConv({"Int"}, "Str", "BASE", true), --备注：Intelligence from Passives in Radius is Transformed to Strength
	["将范围内天赋所给予的敏捷转换成智慧"] = getSimpleConv({"Dex"}, "Int", "BASE", true), --备注：Dexterity from Passives in Radius is Transformed to Intelligence
	["将范围内天赋所给予的智慧转换成敏捷"] = getSimpleConv({"Int"}, "Dex", "BASE", true), --备注：Intelligence from Passives in Radius is Transformed to Dexterity
	["范围内生命的增减转换成能量护盾"] = function(node, out, data)  --备注：Increases and Reductions to Life in Radius are Transformed to apply to Energy Shield
	 srcList={"Life"}
	 dst="EnergyShield" 
	 thetype="INC"	  
		if node then
			for _, src in pairs(srcList) do
				for _, mod in ipairs(node.modList) do
				
				if mod.name=='MinionModifier' and mod.type =='LIST' then 
					
					if mod.value and mod.value.mod then 
					
						local moditem=mod.value.mod;
						if moditem.name == src and moditem.type == thetype then
							
							local dm={mod={
							source=moditem.source,
							value= -moditem.value,
							type=moditem.type,
							keywordFlags=moditem.keywordFlags,
							name=moditem.name,
							flags=moditem.flags
							}}	
							local nm={mod={
							source=moditem.source,
							value= moditem.value,
							type=moditem.type,
							keywordFlags=moditem.keywordFlags,
							name=dst,
							flags=moditem.flags
							}}							
							out:MergeNewMod(mod.name, mod.type, dm , mod.source, mod.flags, mod.keywordFlags, unpack(mod))							
							out:MergeNewMod(mod.name, mod.type, nm, mod.source, mod.flags, mod.keywordFlags, unpack(mod))	

 							
						end
						
					end 
				
				elseif mod.name =='TotemLife' and mod.type == thetype then
					out:MergeNewMod('TotemLife', mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
					out:MergeNewMod('TotemEnergyShield', mod.type, mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
										
				else 
					if mod.name == src and mod.type == thetype then
						 
						out:MergeNewMod(src, mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						out:MergeNewMod(dst, mod.type, mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
					end
				
				end
				
					
				end	
			end
		end
	end,
--	= getSimpleConv({"Life"}, "EnergyShield", "INC", true),
	["范围内能量护盾的增减转换成 200% 的护甲"] = getSimpleConv({"EnergyShield"}, "Armour", "INC", true, 2), --备注：Increases and Reductions to Energy Shield in Radius are Transformed to apply to Armour at 200% of their value
	["范围内增减的生命转换成 200% 魔力"] = function(node, out, data)  --备注：Increases and Reductions to Life in Radius are Transformed to apply to Mana at 200% of their value
	 srcList={"Life"}
	 dst="Mana" 
	 thetype="INC"	
	factor=2	 
	remove=true
		if node then
			for _, src in pairs(srcList) do
				for _, mod in ipairs(node.modList) do
				
				if mod.name=='MinionModifier' and mod.type =='LIST' then 
					
					if mod.value and mod.value.mod then 
					
						local moditem=mod.value.mod;
						if moditem.name == src and moditem.type == thetype then
							
							local dm={mod={
							source=moditem.source,
							value= -moditem.value,
							type=moditem.type,
							keywordFlags=moditem.keywordFlags,
							name=moditem.name,
							flags=moditem.flags
							}}	
							local nm={mod={
							source=moditem.source,
							value= math.floor(moditem.value * factor) ,
							type=moditem.type,
							keywordFlags=moditem.keywordFlags,
							name=dst,
							flags=moditem.flags
							}}							
							out:MergeNewMod(mod.name, mod.type, dm , mod.source, mod.flags, mod.keywordFlags, unpack(mod))							
							out:MergeNewMod(mod.name, mod.type, nm, mod.source, mod.flags, mod.keywordFlags, unpack(mod))	

 							
						end
						
					end 
				
				elseif mod.name =='TotemLife' and mod.type == thetype then
					out:MergeNewMod('TotemLife', mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
				--	out:MergeNewMod('TotemMana', mod.type, math.floor(mod.value * factor), mod.source, mod.flags, mod.keywordFlags, unpack(mod))
										
				else 
				
					if mod.name == src and mod.type == thetype then
					
						if remove then
							out:MergeNewMod(src, mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						end
						if factor then
							out:MergeNewMod(dst, mod.type, math.floor(mod.value * factor), mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						else
							out:MergeNewMod(dst, mod.type, mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
						end
						
				
					end
				
				end
				
					
				end	
			end
		end
	end,
	--	= getSimpleConv({"Life"}, "Mana", "INC", true, 2),
	["范围内物理伤害的增减转换成冰霜伤害"] = getSimpleConv({"PhysicalDamage"}, "ColdDamage", "INC", true), --备注：Increases and Reductions to Physical Damage in Radius are Transformed to apply to Cold Damage
	["范围内冰霜伤害的增减转换成物理伤害"] = getSimpleConv({"ColdDamage"}, "PhysicalDamage", "INC", true), --备注：Increases and Reductions to Cold Damage in Radius are Transformed to apply to Physical Damage
	["范围内其他伤害类型的增减转换成火焰伤害"] = getSimpleConv({"PhysicalDamage","ColdDamage","LightningDamage","ChaosDamage"}, "FireDamage", "INC", true), --备注：Increases and Reductions to other Damage Types in Radius are Transformed to apply to Fire Damage
	["范围内提高闪电抗性的天赋也会以 35% 的比例提高法术格挡率"] = getSimpleConv({"LightningResist","ElementalResist"}, "SpellBlockChance", "BASE", false, 0.35), --备注：Passives granting Lightning Resistance or all Elemental Resistances in Radius also grant Chance to Block Spells at 35% of its value
	["范围内提高冰霜抗性的天赋也会以 35% 的比例提高躲避攻击击中几率"] = getSimpleConv({"ColdResist","ElementalResist"}, "AttackDodgeChance", "BASE", false, 0.35), --备注：Passives granting Cold Resistance or all Elemental Resistances in Radius also grant Chance to Dodge Attacks at 35% of its value
	["范围内提高火焰抗性的天赋也会以 35% 的比例提高攻击格挡率"] = getSimpleConv({"FireResist","ElementalResist"}, "BlockChance", "BASE", false, 0.35), --备注：Passives granting Fire Resistance or all Elemental Resistances in Radius also grant Chance to Block at 35% of its value
	["范围内的近战和近战武器加成转换成弓类武器加成"] = function(node, out, data) --备注：Melee and Melee Weapon Type modifiers in Radius are Transformed to Bow Modifiers
		if node then
			local mask1 = bor(ModFlag.Axe, ModFlag.Claw, ModFlag.Dagger, ModFlag.Mace, ModFlag.Staff, ModFlag.Sword, ModFlag.Melee)
			local mask2 = bor(ModFlag.Weapon1H, ModFlag.WeaponMelee)
			local mask3 = bor(ModFlag.Weapon2H, ModFlag.WeaponMelee)
			for _, mod in ipairs(node.modList) do
				if band(mod.flags, mask1) ~= 0 or band(mod.flags, mask2) == mask2 or band(mod.flags, mask3) == mask3 then
					out:MergeNewMod(mod.name, mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
					out:MergeNewMod(mod.name, mod.type, mod.value, mod.source, bor(band(mod.flags, bnot(bor(mask1, mask2, mask3))), ModFlag.Bow), mod.keywordFlags, unpack(mod))
				elseif mod[1] then
					local using = { UsingAxe = true, UsingClaw = true, UsingDagger = true, UsingMace = true, UsingStaff = true, UsingSword = true, UsingMeleeWeapon = true }
					for _, tag in ipairs(mod) do
						if tag.type == "Condition" and using[tag.var] then
							local newTagList = copyTable(mod)
							for _, tag in ipairs(newTagList) do
								if tag.type == "Condition" and using[tag.var] then
									tag.var = "UsingBow"
									break
								end
							end
							out:MergeNewMod(mod.name, mod.type, -mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
							out:MergeNewMod(mod.name, mod.type, mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(newTagList))
							break
						end
					end
				end
			end
		end
	end,
	["范围内的非核心天赋技能效果提高 50%"] = function(node, out, data) --备注：50% increased Effect of non-Keystone Passive Skills in Radius
		if node and node.type ~= "Keystone" then
			out:NewMod("PassiveSkillEffect", "INC", 50, data.modSource)
		end
	end,
	["范围内配置的核心天赋技能不会提供任何加成"] = function(node, out, data) --备注：Notable Passive Skills in Radius grant nothing
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasNoEffect", "FLAG", true, data.modSource)
		end
	end,
	["范围内配置的小天赋点技能不会提供任何加成"] = function(node, out, data) --备注：Allocated Small Passive Skills in Radius grant nothing
		if node and node.type == "Normal" then
			out:NewMod("AllocatedPassiveSkillHasNoEffect", "FLAG", true, data.modSource)
		end
	end,
	 
	["范围内的核心天赋替换为："]= function(node, out, data)
		 
	end,
	["范围内的核心天赋替换为：技能魔力消耗提高 10%，法术伤害提高 20%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", { mod = mod("ManaCost", "INC", 10, data.modSource) },			
			data.modSource)
			out:NewMod("NodeModifier", "LIST", 		
			{ mod = mod("Damage", "INC", 20, data.modSource, ModFlag.Spell) }, 			
			data.modSource)
		
			
		end
	end,
	["技能魔力消耗提高 10%，法术伤害提高 20%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", { mod = mod("ManaCost", "INC", 10, data.modSource) },			
			data.modSource)
			out:NewMod("NodeModifier", "LIST", 		
			{ mod = mod("Damage", "INC", 20, data.modSource, ModFlag.Spell) }, 			
			data.modSource)
		
			
		end
	end,
	
	
	
	["范围内的核心天赋技能转化替代为：召唤生物受到的伤害提高 20%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", 
			{ mod = mod("MinionModifier", "LIST", { mod = mod("DamageTaken", "INC", 20, data.modSource) } ) },
			
			data.modSource)
		end
	end,	
	["替代为：召唤生物受到的伤害提高 20%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", 
			{ mod = mod("MinionModifier", "LIST", { mod = mod("DamageTaken", "INC", 20, data.modSource) } ) },
			
			data.modSource)
		end
	end,
	
	
	["范围内的核心天赋技能转化替代为：召唤生物的移动速度降低 25%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", 
			{ mod = mod("MinionModifier", "LIST", { mod = mod("MovementSpeed", "INC", -25, data.modSource) } ) },			
			data.modSource)	 
		end
	end,
	["范围内的核心天赋技能转化"] = function(node, out, data)
		
	end,
	["替代为：召唤生物的移动速度降低 25%"] = function(node, out, data)
		if node and node.type == "Notable" then
			out:NewMod("PassiveSkillHasOtherEffect", "FLAG", true, data.modSource)
			out:NewMod("NodeModifier", "LIST", 
			{ mod = mod("MinionModifier", "LIST", { mod = mod("MovementSpeed", "INC", -25, data.modSource) } ) },			
			data.modSource)	 
		end
	end,
	
	
}

-- Radius jewels that modify the jewel itself based on nearby allocated nodes
local function getPerStat(dst, modType, flags, stat, factor)
	return function(node, out, data)
		if node then
			data[stat] = (data[stat] or 0) + out:Sum("BASE", nil, stat)
		elseif data[stat] ~= 0 then
			out:NewMod(dst, modType, math.floor((data[stat] or 0) * factor + 0.5), data.modSource, flags)
		end
	end
end
local jewelSelfFuncs = {




	["范围内每配置 10 点智慧，则魔力回复速度加快 3%"] = getPerStat("ManaRecoveryRate", "INC", 0, "Int", 3 / 10),
	["范围内每配置 10 点智慧，则魔力回复速度加快 2%"] = getPerStat("ManaRecoveryRate", "INC", 0, "Int", 2 / 10),
	

	["范围内每配置 10 点敏捷，移动速度提高 3%"] = getPerStat("MovementSpeed", "INC", 0, "Dex", 3 / 10),
	["范围内每配置 10 点敏捷，移动速度提高 2%"] = getPerStat("MovementSpeed", "INC", 0, "Dex", 2 / 10),
	
	["范围内每配置 10 点力量，则生命回复速度加快 3%"] = getPerStat("LifeRecoveryRate", "INC", 0, "Str", 3 / 10),
	["范围内每配置 10 点力量，则生命回复速度加快 2%"] = getPerStat("LifeRecoveryRate", "INC", 0, "Str", 2 / 10),
	["范围内每配置 10 点智慧，混沌伤害提高 5%"] = getPerStat("ChaosDamage", "INC", 0, "Int", 5 / 10),
	["Adds 1 to maximum Life per 3 Intelligence in Radius"] = getPerStat("Life", "BASE", 0, "Int", 1 / 3),
	["范围内每配置 3 点智慧，最大生命提高 1 点"] = getPerStat("Life", "BASE", 0, "Int", 1 / 3), --备注：Adds 1 to Maximum Life per 3 Intelligence Allocated in Radius
	["范围内每配置 3 点敏捷，闪避值提高 1%"] = getPerStat("Evasion", "INC", 0, "Dex", 1 / 3), --备注：1% increased Evasion Rating per 3 Dexterity Allocated in Radius
	["范围内每配置 3 点敏捷，爪类武器物理伤害提高 1%"] = getPerStat("PhysicalDamage", "INC", ModFlag.Claw, "Dex", 1 / 3), --备注：1% increased Claw Physical Damage per 3 Dexterity Allocated in Radius
	["空手攻击时，范围内每分配 3 点敏捷，近战物理伤害提高 1%"] = getPerStat("PhysicalDamage", "INC", ModFlag.Unarmed, "Dex", 1 / 3), --备注：1% increased Melee Physical Damage while Unarmed per 3 Dexterity Allocated in Radius
	["3% increased Totem Life per 10 Strength in Radius"] = getPerStat("TotemLife", "INC", 0, "Str", 3 / 10),
	["范围内每配置 10 点力量，图腾生命提高 3%"] = getPerStat("TotemLife", "INC", 0, "Str", 3 / 10), --备注：3% increased Totem Life per 10 Strength Allocated in Radius
	["范围内每配置 1 点敏捷，攻击附加 1 点最大闪电伤害"] = getPerStat("LightningMax", "BASE", ModFlag.Attack, "Dex", 1), --备注：Adds 1 maximum Lightning Damage to Attacks per 1 Dexterity Allocated in Radius
	["5% increased Chaos damage per 10 Intelligence from Allocated Passives in Radius"] = getPerStat("ChaosDamage", "INC", 0, "Int", 5 / 10),
	["范围内来自天赋的敏捷和智慧转为力量近战伤害加成"] = function(node, out, data) --备注：Dexterity and Intelligence from passives in Radius count towards Strength Melee Damage bonus
		if node then
			data.Dex = (data.Dex or 0) + node.modList:Sum("BASE", nil, "Dex")
			data.Int = (data.Int or 0) + node.modList:Sum("BASE", nil, "Int")
		else
			out:NewMod("DexIntToMeleeBonus", "BASE", data.Dex + data.Int, data.modSource)
		end
	end,
	["范围内每配置 1 点力量，便获得 -1 点力量"] = getPerStat("Str", "BASE", 0, "Str", -1), --备注：-1 Strength per 1 Strength on Allocated Passives in Radius
	["范围内每配置 10 点力量，便获得 1% 额外物理伤害减免"] = getPerStat("PhysicalDamageReduction", "BASE", 0, "Str", 1 / 10), --备注：1% additional Physical Damage Reduction per 10 Strength on Allocated Passives in Radius
	["范围内每配置 1 点智慧，便获得 -1 点智慧"] = getPerStat("Int", "BASE", 0, "Int", -1), --备注：-1 Intelligence per 1 Intelligence on Allocated Passives in Radius
	["范围内每配置 10 点智慧，则每秒回复 0.4% 能量护盾"] = getPerStat("EnergyShieldRegenPercent", "BASE", 0, "Int", 0.4 / 10), --备注：0.4% of Energy Shield Regenerated per Second for every 10 Intelligence on Allocated Passives in Radius
	["范围内每配置 1 点敏捷，便获得 -1 点敏捷"] = getPerStat("Dex", "BASE", 0, "Dex", -1), --备注：-1 Dexterity per 1 Dexterity on Allocated Passives in Radius
	["范围内每配置 10 点敏捷，移动速度提高 2%"] = getPerStat("MovementSpeed", "INC", 0, "Dex", 2 / 10), --备注：2% increased Movement Speed per 10 Dexterity on Allocated Passives in Radius
}
local jewelSelfUnallocFuncs = {


["范围内若未配置力量，则每 10 点 +7% 攻击和法术暴击伤害加成"] = getPerStat("CritMultiplier", "BASE", 0, "Str", 7 / 10), 
["范围内每有 10 点未配置的力量，则生命回复速度减慢 2%"] = getPerStat("LifeRecoveryRate", "RED", 0, "Str", 2 / 10), 
["范围内每有 10 点未配置的敏捷，便 +125 命中值"] = getPerStat("Accuracy", "BASE", 0, "Dex", 125 / 10), 
["范围内每有 10 点未配置的敏捷，则移动速度减慢 2%"] = getPerStat("MovementSpeed", "RED", 0, "Dex", 2 / 10), 

["范围内每有 10 点未配置的智慧，则魔力回复速度减慢 2%"] = getPerStat("ManaRecoveryRate", "RED", 0, "Int", 2 / 10), 
["范围内每有 10 点未配置的智慧，便 +3% 持续伤害加成"] = getPerStat("DotMultiplier", "BASE", 0, "Int", 3 / 10), 
	["范围内若未配置力量，则每 10 点 +7% 攻击和法术暴击伤害加成"] = getPerStat("CritMultiplier", "BASE", 0, "Str", 7 / 10), 
	["范围内若未配置智慧，则每 10 点 +125 最大命中值"] = getPerStat("Accuracy", "BASE", 0, "Int", 125 / 10), 
	["范围内若未配置力量，则每 10 点 +5% 攻击和法术暴击伤害加成"] = getPerStat("CritMultiplier", "BASE", 0, "Str", 5 / 10), --备注：+5% to Critical Strike Multiplier per 10 Strength on Unallocated Passives in Radius
	["范围内若未配置敏捷，则每 10 点 +15 最大魔力"] = getPerStat("Mana", "BASE", 0, "Dex", 15 / 10), --备注：+15 to maximum Mana per 10 Dexterity on Unallocated Passives in Radius
	["范围内若未配置智慧，则每 10 点 +100 最大命中值"] = getPerStat("Accuracy", "BASE", 0, "Int", 100 / 10), --备注：+100 to Accuracy Rating per 10 Intelligence on Unallocated Passives in Radius
	["范围内未配置的小天赋点技能会提供任何加成"] = function(node, out, data) --备注：Grants all bonuses of Unallocated Small Passive Skills in Radius
		if node then
			if node.type == "Normal" then
				data.modList = data.modList or new("ModList")
				data.modList:AddList(out)
			end
		elseif data.modList then
			out:AddList(data.modList)
		end
	end,
}

-- Radius jewels with bonuses conditional upon attributes of nearby nodes
local function getThreshold(attrib, name, modType, value, ...)
	local baseMod = mod(name, modType, value, "", ...)
	return function(node, out, data)
		if node then
			if type(attrib) == "table" then
				for _, att in ipairs(attrib) do
					local nodeVal = out:Sum("BASE", nil, att)
					data[att] = (data[att] or 0) + nodeVal
					data.total = (data.total or 0) + nodeVal
				end
			else
				local nodeVal = out:Sum("BASE", nil, attrib)
				data[attrib] = (data[attrib] or 0) + nodeVal
				data.total = (data.total or 0) + nodeVal
			end
		elseif (data.total or 0) >= 40 then
			local mod = copyTable(baseMod)
			mod.source = data.modSource
			if type(value) == "table" and value.mod then
				value.mod.source = data.modSource
			end
			out:AddMod(mod)
		end
	end
end

local jewelThresholdFuncs = {
	["若范围内含有 40 点敏捷，【冰霜之刃】造成的近战伤害穿透 15% 冰霜抗性"] = getThreshold("Dex", "ColdPenetration", "BASE", 15, ModFlag.Melee, { type = "SkillName", skillName = "冰霜之刃" }), --备注：With at least 40 Dexterity in Radius, Frost Blades Melee Damage Penetrates 15% Cold Resistance
	["若范围内含有 40 点敏捷，【冰霜之刃】造成的近战伤害穿透 15% 冰霜抗性"] = getThreshold("Dex", "ColdPenetration", "BASE", 15, ModFlag.Melee, { type = "SkillName", skillName = "冰霜之刃" }), --备注：With at least 40 Dexterity in Radius, Melee Damage dealt by Frost Blades Penetrates 15% Cold Resistance
	["若范围内含有 40 点敏捷，\\n【冰霜之刃】的投射物速度提高 25%"] = getThreshold("Dex", "ProjectileSpeed", "INC", 25, { type = "SkillName", skillName = "冰霜之刃" }), --备注：With at least 40 Dexterity in Radius, Frost Blades has 25% increased Projectile Speed
	["若范围配置了 40 点敏捷，【冰霜射击】的范围扩大 25%"] = getThreshold("Dex", "AreaOfEffect", "INC", 25, { type = "SkillName", skillName = "冰霜射击" }), --备注：With at least 40 Dexterity in Radius, Ice Shot has 25% increased Area of Effect
	["若范围配置了 40 点敏捷，【冰霜射击】会穿透 5 个额外目标"] = getThreshold("Dex", "PierceCount", "BASE", 5, { type = "SkillName", skillName = "冰霜射击" }), --备注：Ice Shot Pierces 5 additional Targets with 40 Dexterity in Radius
	["若范围配置了 40 点敏捷，【冰霜射击】会穿透 3 个额外目标"] = getThreshold("Dex", "PierceCount", "BASE", 3, { type = "SkillName", skillName = "冰霜射击" }), --备注：With at least 40 Dexterity in Radius, Ice Shot Pierces 3 additional Targets
	["若范围配置了 40 点敏捷，【冰霜射击】会穿透 5 个额外目标"] = getThreshold("Dex", "PierceCount", "BASE", 5, { type = "SkillName", skillName = "冰霜射击" }), --备注：With at least 40 Dexterity in Radius, Ice Shot Pierces 5 additional Targets
	["若范围内含有 40 点智慧，【寒冰弹】会额外发射 2 个投射物"] = getThreshold("Int", "ProjectileCount", "BASE", 2, { type = "SkillName", skillName = "寒冰弹" }), --备注：With at least 40 Intelligence in Radius, Frostbolt fires 2 additional Projectiles
	["若范围内含有 40 点智慧，【熔岩之核】会额外发射 1 个投射物"] = getThreshold("Int", "ProjectileCount", "BASE", 1, { type = "SkillName", skillName = "熔岩之核" }), --备注：With at least 40 Intelligence in Radius, Magma Orb fires an additional Projectile
	["若范围内含有 40 点智慧，【熔岩之核】每次连锁弹射的范围扩大 10%"] = getThreshold("Int", "AreaOfEffect", "INC", 10, { type = "SkillName", skillName = "熔岩之核" }, { type = "PerStat", stat = "Chain" }), --备注：With at least 40 Intelligence in Radius, Magma Orb has 10% increased Area of Effect per Chain
	["若范围内含有 40 点敏捷，\\n则【流星射击】的范围效果扩大 25%"] = getThreshold("Dex", "AreaOfEffect", "INC", 25, { type = "SkillName", skillName = "流星射击" }), --备注：With at least 40 Dexterity in Radius, Shrapnel Shot has 25% increased Area of Effect
	["若范围内含有 40 点敏捷，【流星射击】的锥形范围内有 50% 几率造成双倍伤害"] = getThreshold("Dex", "DoubleDamageChance", "BASE", 50, { type = "SkillName", skillName = "流星射击" }, { type = "SkillPart", skillPart = 2 }), --备注：With at least 40 Dexterity in Radius, Shrapnel Shot's cone has a 50% chance to deal Double Damage
	["若范围内含有 40 点智慧，则【冰霜脉冲】额外发射 2 个投射物"] = getThreshold("Int", "ProjectileCount", "BASE", 2, { type = "SkillName", skillName = "冰霜脉冲" }), --备注：With at least 40 Intelligence in Radius, Freezing Pulse fires 2 additional Projectiles
	["当范围内含有至少 40 点智慧时，近期内你若粉碎被冰冻的敌人，则【冰霜脉冲】伤害提高 25%"] = getThreshold("Int", "Damage", "INC", 25, { type = "SkillName", skillName = "冰霜脉冲" }, { type = "Condition", var = "ShatteredEnemyRecently" }), --备注：With at least 40 Intelligence in Radius, 25% increased Freezing Pulse Damage if you've Shattered an Enemy Recently
	["若范围内含有 40 点敏捷，\\n则【虚空匕首】会额外发射 10 个投射物"] = getThreshold("Dex", "ProjectileCount", "BASE", 10, { type = "SkillName", skillName = "虚空匕首" }), --备注：With at least 40 Dexterity in Radius, Ethereal Knives fires 10 additional Projectiles
	["若范围内含有 40 点敏捷，\\n则【虚空匕首】会额外发射 5 个投射物"] = getThreshold("Dex", "ProjectileCount", "BASE", 5, { type = "SkillName", skillName = "虚空匕首" }), --备注：With at least 40 Dexterity in Radius, Ethereal Knives fires 5 additional Projectiles
	["若范围内含有 40 点力量，【熔岩之击】会额外发射 2 个投射物"] = getThreshold("Str", "ProjectileCount", "BASE", 2, { type = "SkillName", skillName = "熔岩之击" }), --备注：With at least 40 Strength in Radius, Molten Strike fires 2 additional Projectiles
	["若范围内含有 40 点力量，【熔岩之击】的范围扩大 25%"] = getThreshold("Str", "AreaOfEffect", "INC", 25, { type = "SkillName", skillName = "熔岩之击" }), --备注：With at least 40 Strength in Radius, Molten Strike has 25% increased Area of Effect
	["若范围内含有 40 点力量，则【冰霜之锤】25% 的物理伤害会转化为冰霜伤害"] = getThreshold("Str", "SkillPhysicalDamageConvertToCold", "BASE", 25, { type = "SkillName", skillName = "冰霜之锤" }), --备注：With at least 40 Strength in Radius, 25% of Glacial Hammer Physical Damage converted to Cold Damage
	["若范围内含有 40 点力量，【重击】有 20% 几率造成双倍伤害"] = getThreshold("Str", "DoubleDamageChance", "BASE", 20, { type = "SkillName", skillName = "重击" }), --备注：With at least 40 Strength in Radius, Heavy Strike has a 20% chance to deal Double Damage
	["若范围内含有 40 点力量，【重击】有 20% 几率造成双倍伤害"] = getThreshold("Str", "DoubleDamageChance", "BASE", 20, { type = "SkillName", skillName = "重击" }), --备注：With at least 40 Strength in Radius, Heavy Strike has a 20% chance to deal Double Damage.
	["若范围内含有 40 点敏捷，双持打击时主手武器有 20% 几率造成双倍伤害"] = getThreshold("Dex", "DoubleDamageChance", "BASE", 20, { type = "SkillName", skillName = "双持打击" }, { type = "Condition", var = "MainHandAttack" }), --备注：With at least 40 Dexterity in Radius, Dual Strike has a 20% chance to deal Double Damage with the Main-Hand Weapon
	["若范围内含有 40 点智慧，【魔卫复苏】的重击攻击会使冷却回复速度提高 100%"] = getThreshold("Int", "MinionModifier", "LIST", { mod = mod("CooldownRecovery", "INC", 100, { type = "SkillId", skillId = "ZombieSlam" }) }), --备注：With at least 40 Intelligence in Radius, Raised Zombies' Slam Attack has 100% increased Cooldown Recovery Speed
	["若范围内含有 40 点智慧，【魔卫复苏】的重击攻击伤害提高 30%"] = getThreshold("Int", "MinionModifier", "LIST", { mod = mod("Damage", "INC", 30, { type = "SkillId", skillId = "ZombieSlam" }) }), --备注：With at least 40 Intelligence in Radius, Raised Zombies' Slam Attack deals 30% increased Damage
	["若范围内有 40 点敏捷，敌人身上的每层中毒会使【毒蛇打击】的攻击伤害提高 2%"] = getThreshold("Dex", "Damage", "INC", 2, ModFlag.Attack, { type = "SkillName", skillName = "毒蛇打击" }, { type = "Multiplier", actor = "enemy", var = "PoisonStack" }), --备注：With at least 40 Dexterity in Radius, Viper Strike deals 2% increased Attack Damage for each Poison on the Enemy
	["若范围内有 40 点敏捷，敌人身上的每层中毒会使【毒蛇打击】的击中和中毒伤害提高 2%"] = getThreshold("Dex", "Damage", "INC", 2, 0, bor(KeywordFlag.Hit, KeywordFlag.Poison), { type = "SkillName", skillName = "毒蛇打击" }, { type = "Multiplier", actor = "enemy", var = "PoisonStack" }), --备注：With at least 40 Dexterity in Radius, Viper Strike deals 2% increased Damage with Hits and Poison for each Poison on the Enemy
	["若范围内含有 40 点智慧，【电球】会发射 2 个额外投射物"] = getThreshold("Int", "ProjectileCount", "BASE", 2, { type = "SkillName", skillName = "电球" }), --备注：With at least 40 Intelligence in Radius, Spark fires 2 additional Projectiles
	["若范围内含有 40 点智慧，【枯萎】的干扰持续时间延长 50%"] = getThreshold("Int", "SecondaryDuration", "INC", 50, { type = "SkillName", skillName = "枯萎" }), --备注：With at least 40 Intelligence in Radius, Blight has 50% increased Hinder Duration
	["若范围内含有 40 点智慧，被【枯萎】干扰的敌人受到的混沌伤害提高 25%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("ChaosDamageTaken", "INC", 25, { type = "GlobalEffect", effectType = "Debuff", effectName = "Hinder"  }) }, { type = "SkillName", skillName = "枯萎" }, { type = "ActorCondition", actor = "enemy", var = "Hindered" }), --备注：With at least 40 Intelligence in Radius, Enemies Hindered by Blight take 25% increased Chaos Damage
	["若范围内含有 40 点智慧，【冰川之刺】物理伤害的 20%\\n转化为冰霜伤害"] = getThreshold("Int", "SkillPhysicalDamageConvertToCold", "BASE", 20, { type = "SkillName", skillName = "冰川之刺" }), --备注：With 40 Intelligence in Radius, 20% of Glacial Cascade Physical Damage Converted to Cold Damage
	["若范围内含有 40 点智慧，【冰川之刺】物理伤害的 20% 转化为冰霜伤害"] = getThreshold("Int", "SkillPhysicalDamageConvertToCold", "BASE", 20, { type = "SkillName", skillName = "冰川之刺" }), 
	["若范围内含有 40 点智慧，【冰川之刺】物理伤害的 20%转化为冰霜伤害"] = getThreshold("Int", "SkillPhysicalDamageConvertToCold", "BASE", 20, { type = "SkillName", skillName = "冰川之刺" }),
	["若范围内含有 40 点智慧，【冰川之刺】物理伤害的  20%转化为冰霜伤害"] = getThreshold("Int", "SkillPhysicalDamageConvertToCold", "BASE", 20, { type = "SkillName", skillName = "冰川之刺" }),--注意 这个 20% 前面有2个空格 fuck 国服翻译
	
	
	["若范围内含有 40 点敏捷，【冰霜之刃】的投射物速度提高 25%"] = getThreshold("Dex", "ProjectileSpeed", "INC", 25, { type = "SkillName", skillName = "冰霜之刃" }), 
	
	
	["范围内配置的敏捷和力量总计 40 点时，【灵盾投掷】连锁弹射次数 +4"] = getThreshold({"Str","Dex"}, "ChainCountMax", "BASE", 4, { type = "SkillName", skillName = "灵盾投掷" }), 
	["范围内配置的敏捷和力量总计 40 点时，【灵盾投掷】的碎片投射物数量额外降低 75%"] = getThreshold({"Str","Dex"}, "ProjectileCount", "MORE", -75, { type = "SkillName", skillName = "灵盾投掷" }), 
	 
	 
	["若范围内含有 40 点智慧，【冰川之刺】物理伤害的 20% 转化为冰霜伤害"] = getThreshold("Int", "SkillPhysicalDamageConvertToCold", "BASE", 20, { type = "SkillName", skillName = "冰川之刺" }), --备注：With at least 40 Intelligence in Radius, 20% of Glacial Cascade Physical Damage Converted to Cold Damage
	["范围内含的智慧和敏捷总计 40 点时，【元素打击】的火焰伤害降低 50%"] = getThreshold({"Int","Dex"}, "FireDamage", "MORE", -50, { type = "SkillName", skillName = "元素打击" }), --备注：With 40 total Intelligence and Dexterity in Radius, Elemental Hit deals 50% less Fire Damage
	["范围内含的力量和智慧总计 40 点时，【元素打击】的冰冷伤害降低 50%"] = getThreshold({"Str","Int"}, "ColdDamage", "MORE", -50, { type = "SkillName", skillName = "元素打击" }), --备注：With 40 total Strength and Intelligence in Radius, Elemental Hit deals 50% less Cold Damage
	["范围内含的敏捷和力量总计 40 点时，【元素打击】的闪电伤害降低 50%"] = getThreshold({"Dex","Str"}, "LightningDamage", "MORE", -50, { type = "SkillName", skillName = "元素打击" }), --备注：With 40 total Dexterity and Strength in Radius, Elemental Hit deals 50% less Lightning Damage
	
	
	["范围内敏捷和力量总计 40 点时，【元素打击】和【狂野打击】的总闪电伤害额外降低 50%"] =getThreshold({"Dex","Str"}, "LightningDamage", "MORE", -50, { type = "SkillName", skillNameList = { "元素打击", "野性打击" }}),
	["范围内智慧和敏捷总计 40 点时，【元素打击】和【狂野打击】的总火焰伤害额外降低 50%"] =getThreshold({"Dex","Str"}, "FireDamage", "MORE", -50, { type = "SkillName", skillNameList = { "元素打击", "野性打击" }}),
	["范围内力量和智慧总计 40 点时，【元素打击】和【狂野打击】的总冰霜伤害额外降低 50%"] =getThreshold({"Dex","Str"}, "ColdDamage", "MORE", -50, { type = "SkillName", skillNameList = { "元素打击", "野性打击" }}),
	["若范围内含有 40 点智慧，造成的枯萎效果持续 2 秒"] = getThreshold({"Int"}, "Dummy", "DUMMY", 1, { type = "Condition", var = "CanWither" }, { type = "SkillName", skillName = "枯萎" } , flag("Condition:CanWither")),
	
	
	["若范围内含有 40 点力量，【熔岩之击】的投射物 +1 次连锁"] =
 getThreshold("Str", "ChainCountMax", "BASE", 1, { type = "SkillName", skillName = "熔岩之击" }),
["若范围内含有 40 点力量，【熔岩之击】的发射的总投射物额外减少 50%"] =
 getThreshold("Str", "ProjectileCount", "MORE", -50, { type = "SkillName", skillName = "熔岩之击" }),
 
 ["若范围内至少有 40 点力量，则周围每有一个敌人就使【劈砍】的扩散范围 +1，最大 +10"] = getThreshold("Str", "AreaOfEffect", "BASE", 1, { type = "Multiplier", var = "NearbyEnemies", limit = 10 }, { type = "SkillName", skillName = "劈砍" }),
	["若范围内含有 40 点力量，则【劈砍】击中时获得护体效果"] = getThreshold("Str", "ExtraSkillMod", "LIST", { mod = mod("Condition:Fortify", "FLAG", true) }, { type = "SkillName", skillName = "劈砍" }),
	["若范围内至少有 40 点智慧，【火球】无法【点燃】"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("CannotIgnite", "FLAG", true) }, { type = "SkillName", skillName = "火球" }),	

["若范围内至少有 40 点智慧，【解放】的总范围效果额外缩小 60%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("AreaOfEffect", "MORE", -60) }, { type = "SkillName", skillName = "解放" }),	
["若范围内至少有 40 点智慧，解放的总效果区域额外缩小 60%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("AreaOfEffect", "MORE", -60) }, { type = "SkillName", skillName = "解放" }),	
["若范围内至少有 40 点智慧，【解放】的总伤害额外降低 60%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", -60) }, { type = "SkillName", skillName = "解放" }),	
["若范围内至少有 40 点智慧，解放的总伤害额外降低 60%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", -60) }, { type = "SkillName", skillName = "解放" }),	
["若范围内至少有 40 点智慧，解放的伤害总降 60%"] = getThreshold("Int", "ExtraSkillMod", "LIST", { mod = mod("Damage", "MORE", -60) }, { type = "SkillName", skillName = "解放" }),	

["若范围内至少有 40 点智慧，【解放】的基础冷却时间为 250 毫秒"] = getThreshold("Int", "CooldownRecovery", "OVERRIDE", 0.25, { type = "SkillName", skillName = "解放" }),
["若范围内至少有 40 点智慧，解放的冷却时间为 250 毫秒"] = getThreshold("Int", "CooldownRecovery", "OVERRIDE", 0.25, { type = "SkillName", skillName = "解放" }),

["若范围内至少有 40 点敏捷，【双持打击】持握斧类时击中恐吓敌人 4 秒"] = function() return end,
["若范围内至少有 40 点敏捷，【双持打击】持握爪类时攻击速度加快 (%d+)%%"] = function(num) return getThreshold("Dex", "Speed", "INC", num, { type = "SkillName", skillName = "双持打击" }, { type = "Condition", var = "UsingClaw" }) end,
["若范围内至少有 40 点敏捷，【双持打击】持握匕首时 %+(%d+)%% 暴击伤害加成"] = function(num) return getThreshold("Dex", "CritMultiplier", "BASE", num, { type = "SkillName", skillName = "双持打击" }, { type = "Condition", var = "UsingDagger" }) end,
["若范围内至少有 40 点敏捷，【双持打击】持握锤类时对周围目标造成溅射伤害"] = function() return end,
["若范围内至少有 40 点敏捷，【双持打击】持握剑类时命中值提高 (%d+)%%"] = function(num) return getThreshold("Dex", "Accuracy", "INC", num, { type = "SkillName", skillName = "双持打击" }, { type = "Condition", var = "UsingSword" }) end,
	
		
	["若范围内含有 40 点智慧，【熔岩奔涌】会额外发射 1 个投射物"] = getThreshold("Int", "ProjectileCount", "BASE", 1, { type = "SkillName", skillName = "熔岩奔涌" }),
	["若范围内至少有 40 点智慧，则熔岩奔涌每次连锁的效果区域扩大 10%"] = getThreshold("Int", "AreaOfEffect", "INC", 10, { type = "SkillName", skillName = "熔岩奔涌" }, { type = "PerStat", stat = "Chain" }),
	["若范围内至少有 40 点智慧，则熔岩奔涌每次连锁的总伤害额外提高 40%"] = getThreshold("Int", "Damage", "MORE", 40, { type = "SkillName", skillName = "熔岩奔涌" }, { type = "PerStat", stat = "Chain" }),
	["若范围内至少有 40 点智慧，则熔岩奔涌每次连锁的伤害总增 40%"] = getThreshold("Int", "Damage", "MORE", 40, { type = "SkillName", skillName = "熔岩奔涌" }, { type = "PerStat", stat = "Chain" }),
	
	["若范围内至少有 40 点智慧，则熔岩奔涌总伤害额外降低 50%"] = getThreshold("Int", "Damage", "MORE", -50, { type = "SkillName", skillName = "熔岩奔涌" }),
	["若范围内至少有 40 点智慧，则熔岩奔涌伤害总降 50%"] = getThreshold("Int", "Damage", "MORE", -50, { type = "SkillName", skillName = "熔岩奔涌" }),
	
	["若范围内至少有 40 点敏捷，【双持打击】持握斧类时击中恐吓敌人 4 秒"] = getThreshold("Dex", "EnemyModifier", "LIST", { mod = mod("Condition:Intimidated", "FLAG", true)}, { type = "Condition", var = "UsingAxe" }),
	
}

-- Unified list of jewel functions
local jewelFuncList = { }
-- Jewels that modify nodes
for k, v in pairs(jewelOtherFuncs) do
	jewelFuncList[k:lower()] = { func = function(cap1, cap2, cap3, cap4, cap5)
		-- Need to not modify any nodes already modified by timeless jewels
		-- Some functions return a function instead of simply adding mods, so if
		-- we don't see a node right away, run the outer function first
		if cap1 and type(cap1) == "table" and cap1.conqueredBy then
			return
		end
		local innerFuncOrNil = v(cap1, cap2, cap3, cap4, cap5)
		-- In all (current) cases, there is only one nested layer, so no need for recursion
		return function(node, out, other)
			if node and type(node) == "table" and node.conqueredBy then
				return
			end
			return innerFuncOrNil(node, out, other)
		end
	end, type = "Other" }
end
for k, v in pairs(jewelSelfFuncs) do
	jewelFuncList[k:lower()] = { func = v, type = "Self" }
end
for k, v in pairs(jewelSelfUnallocFuncs) do
	jewelFuncList[k:lower()] = { func = v, type = "SelfUnalloc" }
end
-- Threshold Jewels
for k, v in pairs(jewelThresholdFuncs) do
	jewelFuncList[k:lower()] = { func = v, type = "Threshold" }
end
-- Generate list of cluster jewel skills
local clusterJewelSkills = {}
for baseName, jewel in pairs(data.clusterJewels.jewels) do
	for skillId, skill in pairs(jewel.skills) do		
		if skill.enchant then 
		for i = 1,  #skill.enchant do
			
			local str = skill.enchant[i]:lower():gsub("^%s+", ""):gsub("%s+$", "")
			 
			if skill.enchant[i] == '其中 1 个增加的天赋为【珠宝槽】' then 
			 clusterJewelSkills[str] = { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = 1 }) }	
				
			elseif skill.enchant[i] == '其中 2 个增加的天赋为【珠宝槽】' then 
			
				 clusterJewelSkills[str] = { mod("JewelData", "LIST", { key = "clusterJewelSocketCount", value = 2 }) }	
				 
			else 					 
				clusterJewelSkills[str] = { mod("JewelData", "LIST", { key = "clusterJewelSkill", value = skillId }) }	
			end 
			
		end 
		end	
	
	end
end
for notable in pairs(data.clusterJewels.notableSortOrder) do
	clusterJewelSkills["1 added passive skill is "..notable:lower()] = { mod("ClusterJewelNotable", "LIST", notable) }
end
for notable in pairs(data.clusterJewels.notableSortOrder) do
	clusterJewelSkills["其中 1 个增加的天赋为【"..notable:lower().."】"] = { mod("ClusterJewelNotable", "LIST", notable) }
end
for _, keystone in ipairs(data.clusterJewels.keystones) do
	clusterJewelSkills["adds "..keystone:lower()] = { mod("JewelData", "LIST", { key = "clusterJewelKeystone", value = keystone }) }
end
for _, keystone in ipairs(data.clusterJewels.keystones) do
	clusterJewelSkills["增加【"..keystone:lower().."】"] = { mod("JewelData", "LIST", { key = "clusterJewelKeystone", value = keystone }) }
end
-- Scan a line for the earliest and longest match from the pattern list
-- If a match is found, returns the corresponding value from the pattern list, plus the remainder of the line and a table of captures
local function scan(line, patternList, plain)
	local bestIndex, bestEndIndex
	local bestPattern = ""
	local bestVal, bestStart, bestEnd, bestCaps
	local lineLower = line:lower()
	for pattern, patternVal in pairs(patternList) do
		local index, endIndex, cap1, cap2, cap3, cap4, cap5 = lineLower:find(pattern, 1, plain)
		if index and (not bestIndex or index < bestIndex or (index == bestIndex and (endIndex > bestEndIndex or (endIndex == bestEndIndex and #pattern > #bestPattern)))) then
			bestIndex = index
			bestEndIndex = endIndex
			bestPattern = pattern
			bestVal = patternVal
			bestStart = index
			bestEnd = endIndex
			bestCaps = { cap1, cap2, cap3, cap4, cap5 }
		end
	end
	if bestVal then
		return bestVal, line:sub(1, bestStart - 1) .. line:sub(bestEnd + 1, -1), bestCaps
	else
		return nil, line
	end
end

local function parseMod(line, order)
	-- Check if this is a special modifier
	local lineLower = line:lower()
	local jewelFunc = jewelFuncList[lineLower]
	if jewelFunc then
		return { mod("JewelFunc", "LIST", jewelFunc) }
	end
	local clusterJewelSkill = clusterJewelSkills[lineLower]
	if clusterJewelSkill then
		return clusterJewelSkill
	end
	if unsupportedModList[lineLower] then
		return { }, line
	end
	local specialMod, specialLine, cap = scan(line, specialModList)
	if specialMod and #specialLine == 0 then
		if type(specialMod) == "function" then
			return specialMod(tonumber(cap[1]), unpack(cap))
		else
			return copyTable(specialMod)
		end
	end
	-- Check for add-to-cluster-jewel special
	--注意 星团珠宝
	local addToCluster = line:match("^Added Small Passive Skills also grant： (.+)$")
	if addToCluster then
		return { mod("AddToClusterJewelNode", "LIST", addToCluster) }
	end
	local addToCluster = line:match("^增加的小天赋还获得：(.+)$")
	if addToCluster then
		return { mod("AddToClusterJewelNode", "LIST", addToCluster) }
	end
	line = line .. " "

	-- Check for a flag/tag specification at the start of the line
	local preFlag, preFlagCap
	preFlag, line, preFlagCap = scan(line, preFlagList)
	if type(preFlag) == "function" then
		preFlag = preFlag(unpack(preFlagCap))
	end

	-- Check for skill name at the start of the line
	local skillTag
	skillTag, line = scan(line, preSkillNameList)

	-- Scan for modifier form
	local modForm, formCap
	modForm, line, formCap = scan(line, formList)
	if not modForm then
		return nil, line
	end
	local num = tonumber(formCap[1])

	-- Check for tags (per-charge, conditionals)
	local modTag, modTag2, tagCap
	modTag, line, tagCap = scan(line, modTagList)
	if type(modTag) == "function" then
		modTag = modTag(tonumber(tagCap[1]), unpack(tagCap))
	end
	if modTag then
		modTag2, line, tagCap = scan(line, modTagList)
		if type(modTag2) == "function" then
			modTag2 = modTag2(tonumber(tagCap[1]), unpack(tagCap))
		end
	end
	
	-- Scan for modifier name and skill name
	local modName
	if order == 2 and not skillTag then
		skillTag, line = scan(line, skillNameList, true)
	end
	if modForm == "PEN" then
		modName, line = scan(line, penTypes, true)
		if not modName then
			return { }, line
		end
		local _
		_, line = scan(line, modNameList, true)
	else
		modName, line = scan(line, modNameList, true)
	end
	if order == 1 and not skillTag then
		skillTag, line = scan(line, skillNameList, true)
	end
	
	-- Scan for flags
	local modFlag
	modFlag, line = scan(line, modFlagList, true)

	-- Find modifier value and type according to form
	local modValue = num
	local modType = "BASE"
	local modSuffix
	if modForm == "INC" then
		modType = "INC"
	elseif modForm == "RED" then
		modValue = -num
		modType = "INC"
	elseif modForm == "MORE" then
		modType = "MORE"
	elseif modForm == "LESS" then
		if num == nill then
			--launch:ShowErrMsg2(spline) 
		else
			modValue = -num
			modType = "MORE"
		end
	elseif modForm == "BASE" then
		modSuffix, line = scan(line, suffixTypes, true)
	elseif modForm == "CHANCE" then
	elseif modForm == "REGENPERCENT" then
		modName = regenTypes[formCap[2]]
		modSuffix = "Percent"
	elseif modForm == "REGENFLAT" then
		modName = regenTypes[formCap[2]]
	elseif modForm == "DEGEN" then
		local damageType = dmgTypes[formCap[2]]
		if not damageType then
			return { }, line
		end
		modName = damageType .. "Degen"
		modSuffix = ""
	elseif modForm == "DMG" then
		local damageType = dmgTypes[formCap[3]]
		if not damageType then
			return { }, line
		end
		modValue = { tonumber(formCap[1]), tonumber(formCap[2]) }
		modName = { damageType.."Min", damageType.."Max" }
	elseif modForm == "DMGATTACKS" then
		local damageType = dmgTypes[formCap[3]]
		if not damageType then
			return { }, line
		end
		modValue = { tonumber(formCap[1]), tonumber(formCap[2]) }
		modName = { damageType.."Min", damageType.."Max" }
		modFlag = modFlag or { keywordFlags = KeywordFlag.Attack }
	elseif modForm == "DMGSPELLS" then
		local damageType = dmgTypes[formCap[3]]
		if not damageType then
			return { }, line
		end
		modValue = { tonumber(formCap[1]), tonumber(formCap[2]) }
		modName = { damageType.."Min", damageType.."Max" }
		modFlag = modFlag or { keywordFlags = KeywordFlag.Spell }
	elseif modForm == "DMGBOTH" then
		local damageType = dmgTypes[formCap[3]]
		if not damageType then
			return { }, line
		end
		modValue = { tonumber(formCap[1]), tonumber(formCap[2]) }
		modName = { damageType.."Min", damageType.."Max" }
		modFlag = modFlag or { keywordFlags = bor(KeywordFlag.Attack, KeywordFlag.Spell) }
	end
	if not modName then
		return { }, line
	end

	-- Combine flags and tags
	local flags = 0
	local keywordFlags = 0
	local tagList = { }
	local misc = { }
	for _, data in pairs({ modName, preFlag, modFlag, modTag, modTag2, skillTag }) do
		if type(data) == "table" then
			flags = bor(flags, data.flags or 0)
			keywordFlags = bor(keywordFlags, data.keywordFlags or 0)
			if data.tag then
				t_insert(tagList, copyTable(data.tag))
			elseif data.tagList then
				for _, tag in ipairs(data.tagList) do
					t_insert(tagList, copyTable(tag))
				end
			end
			for k, v in pairs(data) do
				misc[k] = v
			end
		end
	end

	-- Generate modifier list
	local nameList = modName
	local modList = { }
	for i, name in ipairs(type(nameList) == "table" and nameList or { nameList }) do
		modList[i] = {
			name = name .. (modSuffix or misc.modSuffix or ""),
			type = modType,
			value = type(modValue) == "table" and modValue[i] or modValue,
			flags = flags,
			keywordFlags = keywordFlags,
			unpack(tagList)
		}
	end
	if modList[1] then
		-- Special handling for various modifier types
		if misc.addToAura then
			-- Modifiers that add effects to your auras
			for i, effectMod in ipairs(modList) do
			--,{ type = "GlobalEffect", effectType = "ExtraAuraEffect" }
				effectMod.type= "GlobalEffect";
				effectMod.effectType="ExtraAuraEffect";			
				modList[i] = mod("ExtraAuraEffect", "LIST", { mod = effectMod })
			end
		elseif misc.newAura then
			-- Modifiers that add extra auras
			for i, effectMod in ipairs(modList) do
				local tagList = { }
				for i, tag in ipairs(effectMod) do
					tagList[i] = tag
					effectMod[i] = nil
				end
				modList[i] = mod("ExtraAura", "LIST", { mod = effectMod, onlyAllies = misc.newAuraOnlyAllies }, unpack(tagList))
			end
		elseif misc.affectedByAura then
			-- Modifiers that apply to actors affected by your auras
			for i, effectMod in ipairs(modList) do
				modList[i] = mod("AffectedByAuraMod", "LIST", { mod = effectMod })
			end
		elseif misc.addToMinion then
			-- Minion modifiers
			for i, effectMod in ipairs(modList) do
				modList[i] = mod("MinionModifier", "LIST", { mod = effectMod }, misc.addToMinionTag)
			end
		elseif misc.addToSkill then
			-- Skill enchants or socketed gem modifiers that add additional effects
			for i, effectMod in ipairs(modList) do
				modList[i] = mod("ExtraSkillMod", "LIST", { mod = effectMod }, misc.addToSkill)
			end
		elseif misc.convertFortifyEffect then
			for i, effectMod in ipairs(modList) do
				modList[i] = mod("convertFortifyBuff", "LIST", { mod = effectMod })
			end
		elseif misc.applyToEnemy then
			for i, effectMod in ipairs(modList) do
				modList[i] = mod("EnemyModifier", "LIST", { mod = effectMod })
			end
		end
	end
	return modList, line:match("%S") and line
end

local cache = { }
local unsupported = { }
local count = 0
--local foo = io.open("../unsupported.txt", "w")
--foo:close()
return function(line, isComb)
	if not cache[line] then
		local modList, extra = parseMod(line, 1)
		if modList and extra then
			modList, extra = parseMod(line, 2)
		end
		cache[line] = { modList, extra }
		if foo and not isComb and not cache[line][1] then
			local form = line:gsub("[%+%-]?%d+%.?%d*","{num}")
			if not unsupported[form] then
				unsupported[form] = true
				count = count + 1
				foo = io.open("../unsupported.txt", "a+")
				foo:write(count, ': ', form, (cache[line][2] and #cache[line][2] < #line and ('    {' .. cache[line][2]).. '}') or "", '\n')
				foo:close()
			end
		end
	end
	return unpack(copyTable(cache[line]))
end, cache
