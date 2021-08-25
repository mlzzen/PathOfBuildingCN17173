-- Path of Building
--
-- Module: Calc Offence
-- Performs offence calculations.
--
local calcs = ...

local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local t_insert = table.insert
local m_abs = math.abs
local m_floor = math.floor
local m_ceil = math.ceil
local m_modf = math.modf
local m_min = math.min
local m_max = math.max
local m_sqrt = math.sqrt
local m_pi = math.pi
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local s_format = string.format

local tempTable1 = { }
local tempTable2 = { }
local tempTable3 = { }

local isElemental = { Fire = true, Cold = true, Lightning = true }
local cnElemental = { Fire = "火焰", Cold = "冰霜", Lightning = "闪电" }


local isChaos = { Chaos = true }
-- List of all damage types, ordered according to the conversion sequence
local dmgTypeList = {"Physical", "Lightning", "Cold", "Fire", "Chaos"}
local dmgTypeFlags = {
	Physical	= 0x01,
	Lightning	= 0x02,
	Cold		= 0x04,
	Fire		= 0x08,
	Elemental	= 0x0E,
	Chaos		= 0x10,
}

-- Magic table for caching the modifier name sets used in calcDamage()
local damageStatsForTypes = setmetatable({ }, { __index = function(t, k)
	local modNames = { "Damage" }
	for type, flag in pairs(dmgTypeFlags) do
		if band(k, flag) ~= 0 then
			t_insert(modNames, type.."Damage")
		end
	end
	t[k] = modNames
	return modNames
end })

-- Calculate min/max damage for the given damage type
local function calcDamage(activeSkill, output, cfg, breakdown, damageType, typeFlags, convDst)
	local skillModList = activeSkill.skillModList

	typeFlags = bor(typeFlags, dmgTypeFlags[damageType])

	-- Calculate conversions
	-- 其他伤害转化来的点伤
	local addMin, addMax = 0, 0
	local conversionTable = activeSkill.conversionTable
	for _, otherType in ipairs(dmgTypeList) do
		if otherType == damageType then
			-- Damage can only be converted from damage types that preceed this one in the conversion sequence, so stop here
			break
		end
		local convMult = conversionTable[otherType][damageType]
		if convMult > 0 then
			-- Damage is being converted/gained from the other damage type
			local min, max = calcDamage(activeSkill, output, cfg, breakdown, otherType, typeFlags, damageType)
			addMin = addMin + min * convMult
			addMax = addMax + max * convMult
		end
	end
	if addMin ~= 0 and addMax ~= 0 then
		addMin = round(addMin)
		addMax = round(addMax)
	end

	local baseMin = output[damageType.."MinBase"]
	local baseMax = output[damageType.."MaxBase"]
	if baseMin == 0 and baseMax == 0 then
		-- No base damage for this type, don't need to calculate modifiers
		if breakdown and (addMin ~= 0 or addMax ~= 0) then
			t_insert(breakdown.damageTypes, {
				source = damageType,
				convSrc = (addMin ~= 0 or addMax ~= 0) and (addMin .. " 至 " .. addMax),
				total = addMin .. " 至 " .. addMax,
				convDst = convDst and s_format("%d%% 至 %s", conversionTable[damageType][convDst] * 100, convDst),
			})
		end
		return addMin, addMax
	end

	-- Combine modifiers
	local modNames = damageStatsForTypes[typeFlags]
	local inc = 1 + skillModList:Sum("INC", cfg, unpack(modNames)) / 100
	local more = m_floor(skillModList:More(cfg, unpack(modNames)) * 100 + 0.50000001) / 100
	
	local moreMin = m_floor(skillModList:More(cfg, damageType.."Min") * 100 + 0.50000001) / 100
	local moreMax = m_floor(skillModList:More(cfg, damageType.."Max") * 100 + 0.50000001) / 100


	if breakdown then
		if damageType == 'Physical' then  
		t_insert(breakdown.damageTypes, {
			source = damageType,
			base = baseMin .. " 至 " .. baseMax,
			inc = (inc ~= 1 and "x "..inc),
			more = (more ~= 1 and "x "..more),
			moreMin = (moreMin ~= 1 and "x "..moreMin),
			moreMax = (moreMax ~= 1 and "x "..moreMax),
			convSrc = (addMin ~= 0 or addMax ~= 0) and (addMin .. " 至 " .. addMax),
			total = (round(baseMin * inc * more) + addMin)*moreMin .. " 至 " .. (round(baseMax * inc * more) + addMax)*moreMax,
			convDst = convDst and conversionTable[damageType][convDst] > 0 and s_format("%d%% 至 %s", conversionTable[damageType][convDst] * 100, convDst),
		})
		else
		t_insert(breakdown.damageTypes, {
			source = damageType,
			base = baseMin .. " 至 " .. baseMax,
			inc = (inc ~= 1 and "x "..inc),
			more = (more ~= 1 and "x "..more),			
			convSrc = (addMin ~= 0 or addMax ~= 0) and (addMin .. " 至 " .. addMax),
			total = (round(baseMin * inc * more) + addMin) .. " 至 " .. (round(baseMax * inc * more) + addMax),
			convDst = convDst and conversionTable[damageType][convDst] > 0 and s_format("%d%% 至 %s", conversionTable[damageType][convDst] * 100, convDst),
		})
		end 
		
	end
	
	--物理伤害的 其他伤害转化来的 addMin和addMax为0 所以才可以直接这样
	--如果其他伤害也要修饰 moreMin和moreMax  那么需要考虑转化来的点伤
	if damageType == 'Physical' then  
		return (round(baseMin* moreMin * inc * more) + addMin ) ,
		   (round(baseMax * moreMax * inc * more) + addMax )
	else
		return (round(baseMin * inc * more) + addMin),
		   (round(baseMax * inc * more) + addMax)
	end 
	 
end

local function calcAilmentSourceDamage(activeSkill, output, cfg, breakdown, damageType, typeFlags)
	local min, max = calcDamage(activeSkill, output, cfg, breakdown, damageType, typeFlags)
	local convMult = activeSkill.conversionTable[damageType].mult
	if breakdown and convMult ~= 1 then
t_insert(breakdown, "源伤害:")
t_insert(breakdown, s_format("%d 至 %d ^8(所有伤害)", min, max))
t_insert(breakdown, s_format("x %g ^8(%g%% 转化为其他伤害)", convMult, (1-convMult)*100))
		t_insert(breakdown, s_format("= %d 至 %d", min * convMult, max * convMult))
	end
	return min * convMult, max * convMult
end


---Calculates skill radius
---@param baseRadius number
---@param areaMod number
---@return number
local function calcRadius(baseRadius, areaMod)
	return m_floor(baseRadius * m_floor(100 * m_sqrt(areaMod)) / 100)
end

---Calculates modifiers needed to reach the next and previous radius breakpoints
---@param baseRadius number
---@param incArea number @Additive modifier
---@param moreArea number @Multiplicative modifier
---@return number, number, number, number @Next breakpoint: increased, more; Previous breakpoint: reduced, less
local function calcRadiusBreakpoints(baseRadius, incArea, moreArea)
	local radius = calcRadius(baseRadius, round(round(incArea * moreArea, 10), 2))
	local incAreaBreakpoint, redAreaBreakpoint, moreAreaBreakpoint, lessAreaBreakpoint
	if radius > 0 then
		incAreaBreakpoint = 0
		repeat 
			incAreaBreakpoint = incAreaBreakpoint + 1
			local newRadius = calcRadius(baseRadius, round(round((incArea + incAreaBreakpoint / 100) * moreArea, 10), 2))
		until (newRadius > radius)
		redAreaBreakpoint = 0
		repeat 
			redAreaBreakpoint = redAreaBreakpoint + 1
			local newRadius = calcRadius(baseRadius, round(round((incArea - redAreaBreakpoint / 100) * moreArea, 10), 2))
		until (newRadius < radius)
		moreAreaBreakpoint = 0
		repeat 
			moreAreaBreakpoint = moreAreaBreakpoint + 1
			local newRadius = calcRadius(baseRadius, round(round(incArea * moreArea * (1 + moreAreaBreakpoint / 100), 10), 2))
		until (newRadius > radius)
		lessAreaBreakpoint = 0
		repeat 
			lessAreaBreakpoint = lessAreaBreakpoint + 1
			local newRadius = calcRadius(baseRadius, round(round(incArea * moreArea * (1 - lessAreaBreakpoint / 100), 10), 2))
		until (newRadius < radius)
	end
	return incAreaBreakpoint, moreAreaBreakpoint, redAreaBreakpoint, lessAreaBreakpoint
end


function calcSkillCooldown(skillModList, skillCfg, skillData)
	local cooldownOverride = skillModList:Override(skillCfg, "CooldownRecovery")
	local cooldown = cooldownOverride or (skillData.cooldown  + skillModList:Sum("BASE", skillCfg, "CooldownRecovery")) / calcLib.mod(skillModList, skillCfg, "CooldownRecovery")
	cooldown = m_ceil(cooldown * data.misc.ServerTickRate) / data.misc.ServerTickRate
	return cooldown
end

local function calcWarcryCastTime(skillModList, skillCfg, actor)
	local baseSpeed = 1 / skillModList:Sum("BASE", skillCfg, "WarcryCastTime")
	local warcryCastTime = baseSpeed * calcLib.mod(skillModList, skillCfg, "WarcrySpeed") * calcs.actionSpeedMod(actor)
	warcryCastTime = m_min(warcryCastTime, data.misc.ServerTickRate)
	warcryCastTime = 1 / warcryCastTime
	if skillModList:Flag(skillCfg, "InstantWarcry") then
		warcryCastTime = 0
	end
	return warcryCastTime
end

function calcSkillDuration(skillModList, skillCfg, skillData, env, enemyDB)
	local durationMod = calcLib.mod(skillModList, skillCfg, "Duration", "PrimaryDuration", "SkillAndDamagingAilmentDuration", skillData.mineDurationAppliesToSkill and "MineDuration" or nil)
	local durationBase = (skillData.duration or 0) + skillModList:Sum("BASE", skillCfg, "Duration", "PrimaryDuration")
	local duration = durationBase * durationMod
	local debuffDurationMult = 1
	if env.mode_effective then
		debuffDurationMult = 1 / m_max(data.misc.BuffExpirationSlowCap, calcLib.mod(enemyDB, skillCfg, "BuffExpireFaster"))
	end
	if skillData.debuff then
		duration = duration * debuffDurationMult
	end
	return duration
end

-- Performs all offensive calculations
function calcs.offence(env, actor, activeSkill)
	local modDB = actor.modDB
	local enemyDB = actor.enemy.modDB
	local output = actor.output
	local breakdown = actor.breakdown

	local skillModList = activeSkill.skillModList
	local skillData = activeSkill.skillData
	local skillFlags = activeSkill.skillFlags
	local skillCfg = activeSkill.skillCfg
	if skillData.showAverage then
		skillFlags.showAverage = true
	else
		skillFlags.notAverage = true
	end


	if skillFlags.disable then
		-- Skill is disabled
		output.CombinedDPS = 0
		return
	end
	
	local function calcAreaOfEffect(skillModList, skillCfg, skillData, skillFlags, output, breakdown)
		local incArea, moreArea = calcLib.mods(skillModList, skillCfg, "AreaOfEffect")
		output.AreaOfEffectMod = round(round(incArea * moreArea, 10), 2)
		if skillData.radiusIsWeaponRange then
			local range = 0
			if skillFlags.weapon1Attack then
				range = m_max(range, actor.weaponRange1)
			end
			if skillFlags.weapon2Attack then
				range = m_max(range, actor.weaponRange2)
			end
			skillData.radius = range + 2
		end
		if skillData.radius then
			skillFlags.area = true
			local baseRadius = skillData.radius + (skillData.radiusExtra or 0) + skillModList:Sum("BASE", skillCfg, "AreaOfEffect")
			output.AreaOfEffectRadius = calcRadius(baseRadius, output.AreaOfEffectMod)
			if breakdown then
				local incAreaBreakpoint, moreAreaBreakpoint, redAreaBreakpoint, lessAreaBreakpoint = calcRadiusBreakpoints(baseRadius, incArea, moreArea)
				breakdown.AreaOfEffectRadius = breakdown.area(baseRadius, output.AreaOfEffectMod, output.AreaOfEffectRadius, incAreaBreakpoint, moreAreaBreakpoint, redAreaBreakpoint, lessAreaBreakpoint, skillData.radiusLabel)
			end
			if skillData.radiusSecondary then
				local incAreaSecondary, moreAreaSecondary = calcLib.mods(skillModList, skillCfg, "AreaOfEffect", "AreaOfEffectSecondary")
				output.AreaOfEffectModSecondary = round(round(incAreaSecondary * moreAreaSecondary, 10), 2)
				baseRadius = skillData.radiusSecondary + (skillData.radiusExtra or 0)
				output.AreaOfEffectRadiusSecondary = calcRadius(baseRadius, output.AreaOfEffectModSecondary)
				if breakdown then
					local incAreaBreakpointSecondary, moreAreaBreakpointSecondary, redAreaBreakpointSecondary, lessAreaBreakpointSecondary = calcRadiusBreakpoints(baseRadius, incAreaSecondary, moreAreaSecondary)
					breakdown.AreaOfEffectRadiusSecondary = breakdown.area(baseRadius, output.AreaOfEffectModSecondary, output.AreaOfEffectRadiusSecondary, incAreaBreakpointSecondary, moreAreaBreakpointSecondary, redAreaBreakpointSecondary, lessAreaBreakpointSecondary, skillData.radiusSecondaryLabel)
				end
			end
			if skillData.radiusTertiary then
				local incAreaTertiary, moreAreaTertiary = calcLib.mods(skillModList, skillCfg, "AreaOfEffect", "AreaOfEffectTertiary")
				output.AreaOfEffectModTertiary = round(round(incAreaTertiary * moreAreaTertiary, 10), 2)
				baseRadius = skillData.radiusTertiary + (skillData.radiusExtra or 0)
				output.AreaOfEffectRadiusTertiary = calcRadius(baseRadius, output.AreaOfEffectModTertiary)
				if breakdown then
					local incAreaBreakpointTertiary, moreAreaBreakpointTertiary, redAreaBreakpointTertiary, lessAreaBreakpointTertiary = calcRadiusBreakpoints(baseRadius, incAreaTertiary, moreAreaTertiary)
					breakdown.AreaOfEffectRadiusTertiary = breakdown.area(baseRadius, output.AreaOfEffectModTertiary, output.AreaOfEffectRadiusTertiary, incAreaBreakpointTertiary, moreAreaBreakpointTertiary, redAreaBreakpointTertiary, lessAreaBreakpointTertiary, skillData.radiusTertiaryLabel)
				end
			end
		end
		if breakdown then
			breakdown.AreaOfEffectMod = { }
			breakdown.multiChain(breakdown.AreaOfEffectMod, {
				{ "%.2f ^8(扩大/缩小)", 1 + skillModList:Sum("INC", skillCfg, "AreaOfEffect") / 100 },
				{ "%.2f ^8(额外总扩大/额外总缩小)", skillModList:More(skillCfg, "AreaOfEffect") },
				total = s_format("= %.2f", output.AreaOfEffectMod),
			})
		end
	end

local function runSkillFunc(name)
		local func = activeSkill.activeEffect.grantedEffect[name]
		if func then
			func(activeSkill, output)
		end
	end

 	runSkillFunc("initialFunc")
	
	local isTriggered = skillData.triggeredWhileChannelling or skillData.triggeredByCoC or skillData.triggeredByMeleeKill or skillData.triggeredByCospris or skillData.triggeredByMjolner or skillData.triggeredByUnique or skillData.triggeredByFocus or skillData.triggeredByCraft or skillData.triggeredByManaSpent
	skillCfg.skillCond["SkillIsTriggered"] = skillData.triggered or isTriggered
	
	if skillCfg.skillCond["SkillIsTriggered"] then
		skillFlags.triggered = true
	end
	skillCfg.skillCond["SkillIsFocussed"] = skillData.triggeredByFocus
	if skillCfg.skillCond["SkillIsFocussed"] then
		skillFlags.focussed = true
	end
	
	skillCfg.skillCond["SkillIsFocussed"] = skillData.triggeredByFocus
	if skillCfg.skillCond["SkillIsFocussed"] then
		skillFlags.focussed = true
	end


	-- Update skill data
	for _, value in ipairs(skillModList:List(skillCfg, "SkillData")) do
		if value.merge == "MAX" then
			skillData[value.key] = m_max(value.value, skillData[value.key] or 0)
		else
			skillData[value.key] = value.value
		end
	end

	

	-- Add addition stat bonuses
	
	
	if skillModList:Flag(nil, "IronGrip") then
		skillModList:NewMod("PhysicalDamage", "INC", actor.strDmgBonus or 0, "Strength", bor(ModFlag.Attack, ModFlag.Projectile))		
	end
	if skillModList:Flag(nil, "IronWill") then
		skillModList:NewMod("Damage", "INC", actor.strDmgBonus or 0, "Strength", ModFlag.Spell)
	end


	if skillModList:Flag(nil, "TransfigurationOfBody") then
		skillModList:NewMod("Damage", "INC", m_floor(skillModList:Sum("INC", nil, "Life") * 0.3), "躯体幻化", ModFlag.Attack)
	end
	if skillModList:Flag(nil, "TransfigurationOfMind") then
		skillModList:NewMod("Damage", "INC", m_floor(skillModList:Sum("INC", nil, "Mana") * 0.3), "心灵幻化")
	end
	if skillModList:Flag(nil, "TransfigurationOfSoul") then
		skillModList:NewMod("Damage", "INC", m_floor(skillModList:Sum("INC", nil, "EnergyShield") * 0.3), "灵魂幻化", ModFlag.Spell)
	end
	
	
	-- modType: To look for "INC" or "BASE" for getting the percent conversion
	-- modName: Mod name to look for getting the percent conversion
	local getConversionMultiplier = function(modType, modName)
		-- Default to 100% conversion
		local multiplier = 1
		if modType and modName then
			local maxIncrease = 0
			for i, value in ipairs(skillModList:Tabulate(modType, skillCfg, modName)) do
				maxIncrease = m_max(maxIncrease, value.mod.value)
			end
			-- Convert from percent to fraction
			multiplier = maxIncrease / 100.
		end
		return multiplier
	end
	
	-- Correct the tags on conversion with multipliers so they carry over correctly
	local getConvertedModTags = function(mod, multiplier, minionMods)
		local modifiers = modLib.extractModTags(mod)
		for k, value in ipairs(modifiers) do
			if minionMods and value.type == "ActorCondition" and value.actor == "parent" then
				modifiers[k] = { type = "Condition", var = value.var }
			elseif value.limitTotal then
				-- LimitTotal can apply to 'per stat' or 'multiplier', so just copy the whole and update the limit
				local copy = copyTable(value)
				copy.limit = copy.limit * multiplier
				modifiers[k] = copy
			end
		end
		return modifiers
	end

	-- account for Battlemage
	-- Note: we check conditions of Main Hand weapon using actor.itemList as actor.weaponData1 is populated with unarmed values when no weapon slotted.
	if skillModList:Flag(nil, "WeaponDamageAppliesToSpells") and actor.itemList["Weapon 1"] and actor.itemList["Weapon 1"].weaponData and actor.itemList["Weapon 1"].weaponData[1] then
		-- the multiplier below exist for future possible extension of Battlemage modifiers
		local multiplier = getConversionMultiplier("INC", "ImprovedWeaponDamageAppliesToSpells") or 1
		for _, damageType in ipairs(dmgTypeList) do
			skillModList:NewMod(damageType.."Min", "BASE", (actor.weaponData1[damageType.."Min"] or 0) * multiplier, "战斗法师", ModFlag.Spell)
			skillModList:NewMod(damageType.."Max", "BASE", (actor.weaponData1[damageType.."Max"] or 0) * multiplier, "战斗法师", ModFlag.Spell)
		end
	end
	if skillModList:Flag(nil, "MinionDamageAppliesToPlayer") then
		-- Minion Damage conversion from Spiritual Aid and The Scourge
		local multiplier = getConversionMultiplier("INC", "ImprovedMinionDamageAppliesToPlayer")
		for _, value in ipairs(skillModList:List(skillCfg, "MinionModifier")) do
			if value.mod.name == "Damage" and value.mod.type == "INC" then
				local mod = value.mod
				local modifiers = getConvertedModTags(mod, multiplier, true)
				skillModList:NewMod("Damage", "INC", mod.value * multiplier, mod.source, mod.flags, mod.keywordFlags, unpack(modifiers))
			end
		end
	end
	if skillModList:Flag(nil, "MinionAttackSpeedAppliesToPlayer") then
		-- Minion Damage conversion from Spiritual Command
		local multiplier = getConversionMultiplier("INC", "ImprovedMinionAttackSpeedAppliesToPlayer")
		-- Minion Attack Speed conversion from Spiritual Command
		for _, value in ipairs(skillModList:List(skillCfg, "MinionModifier")) do
			if value.mod.name == "Speed" and value.mod.type == "INC" and (value.mod.flags == 0 or band(value.mod.flags, ModFlag.Attack) ~= 0) then
				local modifiers = getConvertedModTags(value.mod, multiplier, true)
				skillModList:NewMod("Speed", "INC", value.mod.value * multiplier, value.mod.source, ModFlag.Attack, value.mod.keywordFlags, unpack(modifiers))
			end
		end
	end
	if skillModList:Flag(nil, "SpellDamageAppliesToAttacks") then
		-- Spell Damage conversion from Crown of Eyes, Kinetic Bolt, and the Wandslinger notable
		local multiplier = getConversionMultiplier("INC", "ImprovedSpellDamageAppliesToAttacks")
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = ModFlag.Spell }, "Damage")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Spell) ~= 0 then
				local modifiers = getConvertedModTags(mod, multiplier)
				skillModList:NewMod("Damage", "INC", mod.value * multiplier, mod.source, bor(band(mod.flags, bnot(ModFlag.Spell)), ModFlag.Attack), mod.keywordFlags, unpack(modifiers))
			end
		end
	end

	if skillModList:Flag(nil, "CastSpeedAppliesToAttacks") then
		-- Get all increases for this; assumption is that multiple sources would not stack, so find the max
		local multiplier = getConversionMultiplier("INC", "ImprovedCastSpeedAppliesToAttacks")
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = ModFlag.Cast }, "Speed")) do
			local mod = value.mod
			-- Add a new mod for all mods that are cast only
			-- Replace this with a single mod for the sum?
			if band(mod.flags, ModFlag.Cast) ~= 0 then
				local modifiers = getConvertedModTags(mod, multiplier)
				skillModList:NewMod("Speed", "INC", mod.value * multiplier, mod.source, bor(band(mod.flags, bnot(ModFlag.Cast)), ModFlag.Attack), mod.keywordFlags, unpack(modifiers))
			end
		end
	end
	if skillModList:Flag(nil, "ClawDamageAppliesToUnarmed") then
		-- Claw Damage conversion from Rigwald's Curse		
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = ModFlag.Claw, keywordFlags = KeywordFlag.Hit }, "Damage")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Claw) ~= 0 then
					skillModList:NewMod("Damage", mod.type, mod.value, mod.source, bor(band(mod.flags, bnot(ModFlag.Claw)), ModFlag.Unarmed), mod.keywordFlags, unpack(mod))
			end
		end
	end
	if skillModList:Flag(nil, "ClawAttackSpeedAppliesToUnarmed") then
		-- Claw Attack Speed conversion from Rigwald's Curse
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = bor(ModFlag.Claw, ModFlag.Attack, ModFlag.Hit) }, "Speed")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Claw) ~= 0 and band(mod.flags, ModFlag.Attack) ~= 0 then
				skillModList:NewMod("Speed", mod.type, mod.value, mod.source, bor(band(mod.flags, bnot(ModFlag.Claw)), ModFlag.Unarmed), mod.keywordFlags, unpack(mod))
			end
		end
	end
	if skillModList:Flag(nil, "ClawCritChanceAppliesToUnarmed") then
		-- Claw Crit Chance conversion from Rigwald's Curse
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = bor(ModFlag.Claw, ModFlag.Hit) }, "CritChance")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Claw) ~= 0 then
				skillModList:NewMod("CritChance", mod.type, mod.value, mod.source, bor(band(mod.flags, bnot(ModFlag.Claw)), ModFlag.Unarmed), mod.keywordFlags, unpack(mod))
			end
		end
	end
	if skillModList:Flag(nil, "ClawCritChanceAppliesToMinions") then
		-- Claw Crit Chance conversion from Law of the Wilds
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = bor(ModFlag.Claw, ModFlag.Hit) }, "CritChance")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Claw) ~= 0 then
            env.minion.modDB:NewMod("CritChance", mod.type, mod.value, mod.source)
			end
		end
	end
   if skillModList:Flag(nil, "ClawCritMultiplierAppliesToMinions") then
		-- Claw Crit Multi conversion from Law of the Wilds
		for i, value in ipairs(skillModList:Tabulate("BASE", { flags = bor(ModFlag.Claw, ModFlag.Hit) }, "CritMultiplier")) do
			local mod = value.mod
			if band(mod.flags, ModFlag.Claw) ~= 0 then
				env.minion.modDB:NewMod("CritMultiplier", mod.type, mod.value, mod.source)
			end
		end
	end
	if skillModList:Flag(nil, "LightRadiusAppliesToAccuracy") then
		-- Light Radius conversion from Corona Solaris
		for i, value in ipairs(skillModList:Tabulate("INC",  { }, "LightRadius")) do
			local mod = value.mod
			skillModList:NewMod("Accuracy", "INC", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
	end
	if skillModList:Flag(nil, "HalfOfLightRadiusAppliesToAreaOfEffect") then
		-- Light Radius conversion from 费西亚的花环
		--照亮范围的扩大和缩小也同样作用于范围效果，等于其数值的 50%
		for i, value in ipairs(skillModList:Tabulate("INC",  { }, "LightRadius")) do
			local mod = value.mod
			skillModList:NewMod("AreaOfEffect", "INC", mod.value/2, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
	end
	if skillModList:Flag(nil, "LightRadiusAppliesToDamage") then
		-- Light Radius conversion from 费西亚的花环
		--照亮范围的扩大和缩小也同样作用于伤害
		for i, value in ipairs(skillModList:Tabulate("INC",  { }, "LightRadius")) do
			local mod = value.mod
			skillModList:NewMod("Damage", "INC", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
	end
	
	if skillModList:Flag(nil, "CastSpeedAppliesToTrapThrowingSpeed") then
		-- Cast Speed conversion from Slavedriver's Hand
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = ModFlag.Cast }, "Speed")) do
			local mod = value.mod
			if (mod.flags == 0 or band(mod.flags, ModFlag.Cast) ~= 0) then
				skillModList:NewMod("TrapThrowingSpeed", "INC", mod.value, mod.source, band(mod.flags, bnot(ModFlag.Cast), bnot(ModFlag.Attack)), mod.keywordFlags, unpack(mod))
			end
		end
	end
	if skillData.arrowSpeedAppliesToAreaOfEffect then
		-- Arrow Speed conversion for Galvanic Arrow
		for i, value in ipairs(skillModList:Tabulate("INC", { flags = ModFlag.Bow }, "ProjectileSpeed")) do
			local mod = value.mod
			skillModList:NewMod("AreaOfEffect", "INC", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
	end
	if skillData.projectileSpeedAppliesToMSAreaOfEffect then
		-- Projectile Speed conversion for Molten Stikes Projectile Range
		for i, value in ipairs(skillModList:Tabulate("INC",  { }, "ProjectileSpeed")) do
			local mod = value.mod
			skillModList:NewMod("AreaOfEffectSecondary", "INC", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
			skillModList:NewMod("AreaOfEffectTertiary", "INC", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
		for i, value in ipairs(skillModList:Tabulate("MORE",  { }, "ProjectileSpeed")) do
			local mod = value.mod
			skillModList:NewMod("AreaOfEffectSecondary", "MORE", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
			skillModList:NewMod("AreaOfEffectTertiary", "MORE", mod.value, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
		end
	end
	if skillModList:Flag(nil, "SequentialProjectiles") and not skillModList:Flag(nil, "OneShotProj") and not skillModList:Flag(nil,"NoAdditionalProjectiles") 
	and not skillModList:Flag(nil, "TriggeredBySnipe")
	then
		-- Applies DPS multiplier based on projectile count
		skillData.dpsMultiplier = skillModList:Sum("BASE", skillCfg, "ProjectileCount")
	end
	
	

	if skillData.gainPercentBaseWandDamage then
		local mult = skillData.gainPercentBaseWandDamage / 100
		if actor.weaponData1.type == "Wand" and actor.weaponData2.type == "Wand" then
			for _, damageType in ipairs(dmgTypeList) do
				skillModList:NewMod(damageType.."Min", "BASE", ((actor.weaponData1[damageType.."Min"] or 0) + (actor.weaponData2[damageType.."Min"] or 0)) / 2 * mult, "Spellslinger")
				skillModList:NewMod(damageType.."Max", "BASE", ((actor.weaponData1[damageType.."Max"] or 0) + (actor.weaponData2[damageType.."Max"] or 0)) / 2 * mult, "Spellslinger")
			end
		elseif actor.weaponData1.type == "Wand" then
			for _, damageType in ipairs(dmgTypeList) do
				skillModList:NewMod(damageType.."Min", "BASE", (actor.weaponData1[damageType.."Min"] or 0) * mult, "Spellslinger")
				skillModList:NewMod(damageType.."Max", "BASE", (actor.weaponData1[damageType.."Max"] or 0) * mult, "Spellslinger")
			end
		elseif actor.weaponData2.type == "Wand" then
			for _, damageType in ipairs(dmgTypeList) do
				skillModList:NewMod(damageType.."Min", "BASE", (actor.weaponData2[damageType.."Min"] or 0) * mult, "Spellslinger")
				skillModList:NewMod(damageType.."Max", "BASE", (actor.weaponData2[damageType.."Max"] or 0) * mult, "Spellslinger")
			end
		end
	end
	if skillModList:Flag(nil, "TriggeredBySnipe") and activeSkill.skillTypes[SkillType.Triggerable] then
		skillModList:NewMod("Damage", "MORE", 165, "Config", ModFlag.Hit, { type = "Multiplier", var = "SnipeStage" } )
		skillModList:NewMod("Damage", "MORE", 120, "Config", ModFlag.Ailment, { type = "Multiplier", var = "SnipeStage" } )
	end
	if skillModList:Sum("BASE", nil, "CritMultiplierAppliesToDegen") > 0 then
		for i, value in ipairs(skillModList:Tabulate("BASE", skillCfg, "CritMultiplier")) do
			local mod = value.mod
			if mod.source ~= "Base" then -- The global base Crit Multi doesn't apply to ailments with Perfect Agony
				skillModList:NewMod("DotMultiplier", "BASE", m_floor(mod.value / 2), mod.source, ModFlag.Ailment, { type = "Condition", var = "CriticalStrike" }, unpack(mod))
			end
		end
	end

	
	
	local isAttack = skillFlags.attack
	local isTriggered = skillData.triggeredWhileChannelling or skillData.triggeredByCoC or skillData.triggeredByMeleeKill or skillData.triggeredByCospris or skillData.triggeredByMjolner or skillData.triggeredByPoets

	runSkillFunc("preSkillTypeFunc")
	-- Calculate skill type stats
	if skillFlags.minion then
		if activeSkill.minion and activeSkill.minion.minionData.limit then
			output.ActiveMinionLimit = m_floor(calcLib.val(skillModList, activeSkill.minion.minionData.limit, skillCfg))
		end
	end
	if skillFlags.chaining then
		if skillModList:Flag(skillCfg, "CannotChain") then
output.ChainMaxString = "无法连锁"
		else
			output.ChainMax = skillModList:Sum("BASE", skillCfg, "ChainCountMax", not skillFlags.projectile and "BeamChainCountMax" or nil)
			output.ChainMaxString = output.ChainMax
			output.Chain = m_min(output.ChainMax, skillModList:Sum("BASE", skillCfg, "ChainCount"))
			output.ChainRemaining = m_max(0, output.ChainMax - output.Chain)
		end
	end
	if skillFlags.projectile then
		if skillModList:Flag(nil, "PointBlank") then
			skillModList:NewMod("Damage", "MORE", 30, "零点射击", bor(ModFlag.Attack, ModFlag.Projectile), { type = "DistanceRamp", ramp = {{10,1},{35,0},{150,-1}} })
		end
		if skillModList:Flag(nil, "FarShot") then
			skillModList:NewMod("Damage", "MORE", 100, "Far Shot", bor(ModFlag.Attack, ModFlag.Projectile), { type = "DistanceRamp", ramp = {{10, -0.2}, {35, 0}, {70, 0.6}} })
		end
		
		if skillModList:Flag(skillCfg, "NoAdditionalProjectiles") then
			output.ProjectileCount = 1
		else
			local projBase = skillModList:Sum("BASE", skillCfg, "ProjectileCount")
			local projMore = skillModList:More(skillCfg, "ProjectileCount")
			output.ProjectileCount = m_floor(projBase * projMore)
		end
		
		if skillModList:Flag(skillCfg, "CannotFork") then
			output.ForkCountString = "无法分叉"
		elseif skillModList:Flag(skillCfg, "ForkOnce") then
			skillFlags.forking = true
			if skillModList:Flag(skillCfg, "ForkTwice") then
				output.ForkCountMax = m_min(skillModList:Sum("BASE", skillCfg, "ForkCountMax"), 2)
			else
				output.ForkCountMax = m_min(skillModList:Sum("BASE", skillCfg, "ForkCountMax"), 1)
			end
			output.ForkedCount = m_min(output.ForkCountMax, skillModList:Sum("BASE", skillCfg, "ForkedCount"))
			output.ForkCountString = output.ForkCountMax
			output.ForkRemaining = m_max(0, output.ForkCountMax - output.ForkedCount)
		else
			output.ForkCountString = "0"
		end
		if skillModList:Flag(skillCfg, "CannotPierce") then
			output.PierceCount = 0
			output.PierceCountString = "无法穿透"
		else
			if skillModList:Flag(skillCfg, "PierceAllTargets") or enemyDB:Flag(nil, "AlwaysPierceSelf") then
				output.PierceCount = 100
				output.PierceCountString = "所有目标"
			else
				output.PierceCount = skillModList:Sum("BASE", skillCfg, "PierceCount")
				output.PierceCountString = output.PierceCount
			end
			if output.PierceCount > 0 then
				skillFlags.piercing = true
			end
			output.PiercedCount = m_min(output.PierceCount, skillModList:Sum("BASE", skillCfg, "PiercedCount"))
		end
		output.ProjectileSpeedMod = calcLib.mod(skillModList, skillCfg, "ProjectileSpeed")
		if breakdown then
			breakdown.ProjectileSpeedMod = breakdown.mod(skillModList, skillCfg, "ProjectileSpeed")
		end
		
		 
	end
	if skillFlags.melee then
		if skillFlags.weapon1Attack then
			actor.weaponRange1 = (actor.weaponData1.range and actor.weaponData1.range + skillModList:Sum("BASE", activeSkill.weapon1Cfg, "MeleeWeaponRange")) or (6 + skillModList:Sum("BASE", skillCfg, "UnarmedRange"))	
		end
		if skillFlags.weapon2Attack then
			actor.weaponRange2 = (actor.weaponData2.range and actor.weaponData2.range + skillModList:Sum("BASE", activeSkill.weapon2Cfg, "MeleeWeaponRange")) or (6 + skillModList:Sum("BASE", skillCfg, "UnarmedRange"))	
		end
		if activeSkill.skillTypes[SkillType.MeleeSingleTarget] then
			local range = 100
			if skillFlags.weapon1Attack then
				range = m_min(range, actor.weaponRange1)
			end
			if skillFlags.weapon2Attack then
				range = m_min(range, actor.weaponRange2)
			end
			output.WeaponRange = range + 2
			if breakdown then
				breakdown.WeaponRange = {
					radius = output.WeaponRange
				}
			end
		end
	end
	if skillFlags.area or skillData.radius or (skillFlags.mine and activeSkill.skillTypes[SkillType.Aura]) then
		calcAreaOfEffect(skillModList, skillCfg, skillData, skillFlags, output, breakdown)
	end
	if activeSkill.skillTypes[SkillType.Aura] then	
		
		local incFromPurposefulHarbinger = math.min(
							skillModList:Sum("INC", skillCfg, "PurpHarbAuraBuffEffect"),
							data.misc.PurposefulHarbingerMaxBuffPercent) / 100
				
		
		output.AuraEffectMod = calcLib.mod(skillModList, skillCfg, "AuraEffect")
		if breakdown then
			breakdown.AuraEffectMod = breakdown.mod(skillCfg, "AuraEffect") 
		end
		output.AuraEffectOnSelfMod=  calcLib.mod(skillModList, skillCfg, "AuraEffectOnSelf","AuraEffect")  + incFromPurposefulHarbinger
		if breakdown then			
			breakdown.AuraEffectOnSelfMod = breakdown.mod(skillCfg, "AuraEffectOnSelf","AuraEffect")  			 
			if incFromPurposefulHarbinger > 0  then 
				if not breakdown.AuraEffectOnSelfMod then 
					breakdown.AuraEffectOnSelfMod = {}
				end 
				t_insert(breakdown.AuraEffectOnSelfMod,"多个【勇毅先驱】最大效果 40%")
				
			end 
		end
	end
	if activeSkill.skillTypes[SkillType.ManaCostReserved] then
		output.ManaReservedMod = calcLib.mod(skillModList, skillCfg, "ManaReserved", "Reserved") * calcLib.mod(skillModList, skillCfg, "SupportManaMultiplier")
		if breakdown then
			breakdown.ManaReservedMod = breakdown.mod(skillModList, skillCfg, "ManaReserved", "Reserved", "SupportManaMultiplier")
		end
		output.LifeReservedMod = calcLib.mod(skillModList, skillCfg, "LifeReserved", "Reserved") * calcLib.mod(skillModList, skillCfg, "SupportManaMultiplier")
		if breakdown then
			breakdown.LifeReservedMod = breakdown.mod(skillModList, skillCfg, "LifeReserved", "Reserved", "SupportManaMultiplier")
		end
	end
	if activeSkill.skillTypes[SkillType.Hex] or activeSkill.skillTypes[SkillType.Mark]then
		output.CurseEffectMod = calcLib.mod(skillModList, skillCfg, "CurseEffect")
		if breakdown then
			breakdown.CurseEffectMod = breakdown.mod(skillCfg, "CurseEffect")
		end
	end
	if skillFlags.trap then
		local baseSpeed = 1 / skillModList:Sum("BASE", skillCfg, "TrapThrowingTime")
		local timeMod = calcLib.mod(skillModList, skillCfg, "SkillTrapThrowingTime")
		if timeMod > 0 then
			baseSpeed = baseSpeed * (1 / timeMod)
		end
		output.TrapThrowingSpeed = baseSpeed * calcLib.mod(skillModList, skillCfg, "TrapThrowingSpeed") * output.ActionSpeedMod
		output.TrapThrowingTime = 1 / output.TrapThrowingSpeed
		skillData.timeOverride = output.TrapThrowingTime
		if breakdown then
			breakdown.TrapThrowingSpeed = { }
			breakdown.multiChain(breakdown.TrapThrowingSpeed, {
				label = "投掷速率:",
				base = s_format("%.2f ^8(基础投掷速率)", baseSpeed),
{ "%.2f ^8(提高/降低 投掷速度)", 1 + skillModList:Sum("INC", skillCfg, "TrapThrowingSpeed") / 100 },
{ "%.2f ^8(额外提高/降低 总投掷速度)", skillModList:More(skillCfg, "TrapThrowingSpeed") },
{ "%.2f ^8(动作速度加成)",  output.ActionSpeedMod },
total = s_format("= %.2f ^8每秒", output.TrapThrowingSpeed),
			})
		end
		if breakdown and timeMod > 0 then
			breakdown.TrapThrowingTime = { }
			breakdown.multiChain(breakdown.TrapThrowingTime, {
				label = "投掷时间:",
				base = s_format("%.2f ^8(基础投掷时间)", 1 / (output.TrapThrowingSpeed * timeMod)),
				{ "%.2f ^8(所有加成)", timeMod },
				total = s_format("= %.2f ^8秒(每次投掷)", output.TrapThrowingTime),
			})
		end
		output.ActiveTrapLimit = skillModList:Sum("BASE", skillCfg, "ActiveTrapLimit")
		local baseCooldown = skillData.trapCooldown or skillData.cooldown
		if baseCooldown then
			output.TrapCooldown = baseCooldown / calcLib.mod(skillModList, skillCfg, "CooldownRecovery")
			if breakdown then
				breakdown.TrapCooldown = {
s_format("%.2fs ^8(基础)", skillData.trapCooldown or skillData.cooldown or 4),
s_format("/ %.2f ^8(提高/降低 冷却回复速度)", 1 + skillModList:Sum("INC", skillCfg, "CooldownRecovery") / 100),
					s_format("= %.2f秒", output.TrapCooldown)
				}
			end
		end
		local incArea, moreArea = calcLib.mods(skillModList, skillCfg, "TrapTriggerAreaOfEffect")
		local areaMod = round(round(incArea * moreArea, 10), 2)
		output.TrapTriggerRadius = calcRadius(data.misc.TrapTriggerRadiusBase, areaMod)
		if breakdown then
			local incAreaBreakpoint, moreAreaBreakpoint, redAreaBreakpoint, lessAreaBreakpoint = calcRadiusBreakpoints(data.misc.TrapTriggerRadiusBase, incArea, moreArea)
			breakdown.TrapTriggerRadius = breakdown.area(data.misc.TrapTriggerRadiusBase, areaMod, output.TrapTriggerRadius, incAreaBreakpoint, moreAreaBreakpoint, redAreaBreakpoint, lessAreaBreakpoint)
		end
		
	elseif skillData.cooldown then
	output.Cooldown = calcSkillCooldown(skillModList, skillCfg, skillData)
	if breakdown then			
			breakdown.Cooldown = {
				s_format("%.2fs ^8(基础)", skillData.cooldown + skillModList:Sum("BASE", skillCfg, "CooldownRecovery")),
				s_format("/ %.2f ^8(提高/降低 冷却速度)", 1 + skillModList:Sum("INC", skillCfg, "CooldownRecovery") / 100),
				s_format("调整为最接近的服务器速率"),
				s_format("= %.2f秒", output.Cooldown)
			}
		end
	end
	if skillFlags.mine then
		local baseSpeed = 1 / skillModList:Sum("BASE", skillCfg, "MineLayingTime")
		local timeMod = calcLib.mod(skillModList, skillCfg, "MineThrowingTimeMod")
		if timeMod > 0 then
			baseSpeed = baseSpeed * (1 / timeMod)
		end
		output.MineLayingSpeed = baseSpeed * calcLib.mod(skillModList, skillCfg, "MineLayingSpeed") * output.ActionSpeedMod
		output.MineLayingTime = 1 / output.MineLayingSpeed
		skillData.timeOverride = output.MineLayingTime
		if breakdown then
			breakdown.MineLayingTime = { }
			breakdown.multiChain(breakdown.MineLayingTime, {
label = "放置速率:",
				base = s_format("%.2f ^8(基础放置速率)", baseSpeed),
{ "%.2f ^8(提高/降低 放置速度)", 1 + skillModList:Sum("INC", skillCfg, "MineLayingSpeed") / 100 },
{ "%.2f ^8(额外提高/降低 总投掷速度)", skillModList:More(skillCfg, "MineLayingSpeed") },
{ "%.2f ^8(动作速度加成)",  output.ActionSpeedMod },
total = s_format("= %.2f ^8每秒", output.MineLayingSpeed),
			})
		end
		if breakdown and calcLib.mod(skillModList, skillCfg, "MineThrowingTimeMod") > 0 then
			breakdown.MineThrowingTime = { }
			breakdown.multiChain(breakdown.MineThrowingTime, {
			label = "放置时间:",
				base = s_format("%.2f ^8(基础放置时间)", 1 / (output.MineLayingSpeed * timeMod)),
				{ "%.2f ^8(所有加成)", timeMod },
				total = s_format("= %.2f ^8秒(每次放置)", output.MineLayingTime),
			})
		end
		output.ActiveMineLimit = skillModList:Sum("BASE", skillCfg, "ActiveMineLimit")
		local areaMod = calcLib.mod(skillModList, skillCfg, "MineDetonationAreaOfEffect")
		output.MineDetonationRadius = 60 * m_sqrt(areaMod)
		if breakdown then
			breakdown.MineDetonationRadius = breakdown.area(60, areaMod, output.MineDetonationRadius)
		end
		if activeSkill.skillTypes[SkillType.Aura] then
			output.MineAuraRadius = 35 * m_sqrt(output.AreaOfEffectMod)
			if breakdown then
				breakdown.MineAuraRadius = breakdown.area(35, output.AreaOfEffectMod, output.MineAuraRadius)
			end
		end
	end
	--烙印
	if skillFlags.brand then
	
	
		local attachLimit =  skillModList:Sum("BASE", cfg, "BrandsAttachedLimit")
		
		if activeSkill.activeEffect.grantedEffect.name == "冬潮烙印" then
				attachLimit = attachLimit + 1
		end
		
		output.BrandAttachmentRange = calcLib.mod(skillModList, skillCfg, "BrandAttachmentRange")
		output.ActiveBrandLimit = skillModList:Sum("BASE", skillCfg, "ActiveBrandLimit")	
		output.BrandsAttachedToEnemy = attachLimit
		 
	
	end
		
	if skillFlags.totem then
		if skillFlags.ballista then
			baseSpeed = 1 / skillModList:Sum("BASE", skillCfg, "BallistaPlacementTime")
		else
			baseSpeed = 1 / skillModList:Sum("BASE", skillCfg, "TotemPlacementTime")
		end
		output.TotemPlacementSpeed = baseSpeed * calcLib.mod(skillModList, skillCfg, "TotemPlacementSpeed") * output.ActionSpeedMod
		output.TotemPlacementTime = 1 / output.TotemPlacementSpeed
		if breakdown then
			breakdown.TotemPlacementTime = { }
			breakdown.multiChain(breakdown.TotemPlacementTime, {
				label = "放置速度:",
				base = s_format("%.2f ^8(基础放置速度)", baseSpeed),
				{ "%.2f ^8(提高/降低 放置速度)", 1 + skillModList:Sum("INC", skillCfg, "TotemPlacementSpeed") / 100 },
				{ "%.2f ^8(额外总提高/额外总降低 放置速度)", skillModList:More(skillCfg, "TotemPlacementSpeed") },
				{ "%.2f ^8(动作速度加成)",  output.ActionSpeedMod },
				total = s_format("= %.2f ^8每秒", output.TotemPlacementSpeed),
			})
		end
		output.ActiveTotemLimit = skillModList:Sum("BASE", skillCfg, "ActiveTotemLimit", "ActiveBallistaLimit")
		output.TotemsSummoned = env.modDB:Override(nil, "TotemsSummoned") or output.ActiveTotemLimit
		if breakdown then
			breakdown.ActiveTotemLimit = {
				"图腾放置: "..output.TotemsSummoned..(env.configInput.TotemsSummoned and " ^8(配置界面配置了数值)" or " ^8(可以在配置界面配置)"),
			}
		end
		output.TotemLifeMod = calcLib.mod(skillModList, skillCfg, "TotemLife")
		output.TotemLife = round(m_floor(env.data.monsterAllyLifeTable[skillData.totemLevel] * env.data.totemLifeMult[activeSkill.skillTotemId]) * output.TotemLifeMod)
		if breakdown then
			breakdown.TotemLifeMod = breakdown.mod(skillModList, skillCfg, "TotemLife")
			breakdown.TotemLife = {
				"图腾等级: "..skillData.totemLevel,
				env.data.monsterAllyLifeTable[skillData.totemLevel].." ^8(等级 "..skillData.totemLevel.." 的怪物基础生命)",
				"x "..env.data.totemLifeMult[activeSkill.skillTotemId].." ^8(这个图腾类型的生命加成)",
				"x "..output.TotemLifeMod.." ^8(图腾生命加成)",
				"= "..output.TotemLife,
			}
		end
		
	end
	if skillFlags.warcry then
		output.WarcryCastTime = calcWarcryCastTime(skillModList, skillCfg, actor)
	end

	 
	-- Skill duration
	local debuffDurationMult = 1
	if env.mode_effective then
		--debuffDurationMult = 1 / calcLib.mod(enemyDB, skillCfg, "BuffExpireFaster")
		debuffDurationMult = 1 / m_max(data.misc.BuffExpirationSlowCap, calcLib.mod(enemyDB, skillCfg, "BuffExpireFaster"))	
	end
	do
		output.DurationMod = calcLib.mod(skillModList, skillCfg, "Duration", "PrimaryDuration", "SkillAndDamagingAilmentDuration", skillData.mineDurationAppliesToSkill and "MineDuration" or nil)
		if breakdown then
			breakdown.DurationMod = breakdown.mod(skillCfg, "Duration", "PrimaryDuration", "SkillAndDamagingAilmentDuration", skillData.mineDurationAppliesToSkill and "MineDuration" or nil)
		end
		
		local durationBase = (skillData.duration or 0) + skillModList:Sum("BASE", skillCfg, "Duration", "PrimaryDuration")
		
		if durationBase > 0 then
			
				
			output.Duration = durationBase * output.DurationMod
			if skillData.debuff then
				output.Duration = output.Duration * debuffDurationMult
			end
			if breakdown and output.Duration ~= durationBase then
				breakdown.Duration = {
					s_format("%.2fs ^8(基础)", durationBase),
				}
				if output.DurationMod ~= 1 then
t_insert(breakdown.Duration, s_format("x %.2f ^8(持续时间加成)", output.DurationMod))
				end
				if skillData.debuff and debuffDurationMult ~= 1 then
t_insert(breakdown.Duration, s_format("/ %.2f ^8(debuff更快或更慢消退)", 1 / debuffDurationMult))
				end
				t_insert(breakdown.Duration, s_format("= %.2f秒", output.Duration))
			end
		end
		durationBase = (skillData.durationSecondary or 0) + skillModList:Sum("BASE", skillCfg, "Duration", "SecondaryDuration")
		if durationBase > 0 then
			local durationMod = calcLib.mod(skillModList, skillCfg, "Duration", "SecondaryDuration", "SkillAndDamagingAilmentDuration", skillData.mineDurationAppliesToSkill and "MineDuration" or nil)
			output.DurationSecondary = durationBase * durationMod
			if skillData.debuffSecondary then
				output.DurationSecondary = output.DurationSecondary * debuffDurationMult
			end
			if breakdown and output.DurationSecondary ~= durationBase then
				breakdown.DurationSecondary = {
					s_format("%.2fs ^8(base)", durationBase),
				}
				if output.DurationMod ~= 1 then
t_insert(breakdown.DurationSecondary, s_format("x %.2f ^8(持续时间修饰)", durationMod))
				end
				if skillData.debuffSecondary and debuffDurationMult ~= 1 then
t_insert(breakdown.DurationSecondary, s_format("/ %.2f ^8(debuff更快或更慢消退)", 1 / debuffDurationMult))
				end
				t_insert(breakdown.DurationSecondary, s_format("= %.2f秒", output.DurationSecondary))
			end
		end
		durationBase = (skillData.auraDuration or 0)
		if durationBase > 0 then
			local durationMod = calcLib.mod(skillModList, skillCfg, "Duration", "SkillAndDamagingAilmentDuration")
			output.AuraDuration = durationBase * durationMod
			if breakdown and output.AuraDuration ~= durationBase then
				breakdown.AuraDuration = {
					s_format("%.2fs ^8(基础)", durationBase),
					s_format("x %.2f ^8(持续时间加成)", durationMod),
					s_format("= %.2f秒", output.AuraDuration),
				}
			end
		end
		durationBase = (skillData.reserveDuration or 0)
		if durationBase > 0 then
			local durationMod = calcLib.mod(skillModList, skillCfg, "Duration", "SkillAndDamagingAilmentDuration")
			output.ReserveDuration = durationBase * durationMod
			if breakdown and output.ReserveDuration ~= durationBase then
				breakdown.ReserveDuration = {
					s_format("%.2fs ^8(基础)", durationBase),
					s_format("x %.2f ^8(持续时间加成)", durationMod),
					s_format("= %.2f秒", output.ReserveDuration),
				}
			end
		end	
	end

	-- Calculate costs (may be slightly off due to rounding differences)
	local names = {
		["Mana"] = "mana",
		["Life"] = "life",
		["ES"] = "energy shield",
		["Rage"] = "rage",
		["ManaPercent"] = "mana",
		["LifePercent"] = "life",
	}
	for resource, name in pairs(names) do
		local percent = resource == "ManaPercent" or resource == "LifePercent"
		if isTriggered or activeSkill.activeEffect.grantedEffect.triggered then
			output[resource.."Cost"] = 0
		else
			do
				local mult = m_floor(skillModList:More(skillCfg, "SupportManaMultiplier") * 100 + 0.0001) / 100
				local more = m_floor(skillModList:More(skillCfg, resource.."Cost", "Cost") * 100 + 0.0001) / 100
				local inc = skillModList:Sum("INC", skillCfg, resource.."Cost", "Cost")
				local base = skillModList:Sum("BASE", skillCfg, resource.."CostBase")
				local total = skillModList:Sum("BASE", skillCfg, resource.."Cost")
				local cost = base + (activeSkill.activeEffect.grantedEffectLevel.cost[resource] or 0)				
				if resource == "Mana" and skillData.baseManaCostIsAtLeastPercentUnreservedMana then
					cost = m_max(cost, m_floor((output.ManaUnreserved or 0) * skillData.baseManaCostIsAtLeastPercentUnreservedMana / 100))
				end
				output[resource.."Cost"] = m_floor(cost * mult)
				output[resource.."Cost"] = m_floor(m_abs(inc / 100) * output[resource.."Cost"]) * (inc >= 0 and 1 or -1) + output[resource.."Cost"]
				output[resource.."Cost"] = m_floor(m_abs(more - 1) * output[resource.."Cost"]) * (more >= 1 and 1 or -1) + output[resource.."Cost"]
				output[resource.."Cost"] = m_max(0, m_floor(output[resource.."Cost"] + total))
				if resource == "Mana" and skillFlags.totem then
					local reservedFlat = activeSkill.skillData.manaReservationFlat or activeSkill.activeEffect.grantedEffectLevel.manaReservationFlat or 0
					output[resource.."Cost"] = output[resource.."Cost"] + reservedFlat
					local reservedPercent = activeSkill.skillData.manaReservationPercent or activeSkill.activeEffect.grantedEffectLevel.manaReservationPercent or 0
					if reservedPercent ~= 0 then
						skillModList:NewMod("ManaPercentCostBase", "BASE", reservedPercent, "图腾 保留")
					end
				end
				if resource == "Life" and skillFlags.totem then
					local reservedFlat = activeSkill.skillData.lifeReservationFlat or activeSkill.activeEffect.grantedEffectLevel.lifeReservationFlat or 0
					output[resource.."Cost"] = output[resource.."Cost"] + reservedFlat
					local reservedPercent = activeSkill.skillData.lifeReservationPercent or activeSkill.activeEffect.grantedEffectLevel.lifeReservationPercent or 0
					if reservedPercent ~= 0 then
						skillModList:NewMod("LifePercentCostBase", "BASE", reservedPercent, "图腾 保留")
					end
				end
				if breakdown and output[resource.."Cost"] ~= cost then
					breakdown[resource.."Cost"] = {
						s_format("%d"..(percent and "%%" or "").." ^8(基础 "..name.." 消耗)", cost)
					}
					if mult ~= 1 then
						t_insert(breakdown[resource.."Cost"], s_format("x %.2f ^8(消耗 加成)", mult))
					end
					if inc ~= 0 then
						t_insert(breakdown[resource.."Cost"], s_format("x %.2f ^8(提高/降低 "..name.." 消耗)", 1 + inc/100))
					end	
					if more ~= 1 then
						t_insert(breakdown[resource.."Cost"], s_format("x %.2f ^8(额外总提高/降低 "..name.." 消耗)", more))
					end	
					if total ~= 0 then
						t_insert(breakdown[resource.."Cost"], s_format("- %d ^8(- "..name.." 消耗)", -total))
					end
					t_insert(breakdown[resource.."Cost"], s_format("= %d"..(percent and "%%" or ""), output[resource.."Cost"]))
				end
			end
			
		end
	end

	-- account for Sacrificial Zeal
	-- Note: Sacrificial Zeal grants Added Spell Physical Damage equal to 25% of the Skill's Mana Cost, and causes you to take Physical Damage over Time, for 4 seconds
	if skillModList:Flag(nil, "Condition:SacrificialZeal") then
		local multiplier = 0.25
		skillModList:NewMod("PhysicalMin", "BASE", m_floor(output.ManaCost * multiplier), "热情牺牲", ModFlag.Spell)
		skillModList:NewMod("PhysicalMax", "BASE", m_floor(output.ManaCost * multiplier), "热情牺牲", ModFlag.Spell)
	end

	runSkillFunc("preDamageFunc")


	-- Handle corpse explosions
	if skillData.explodeCorpse and skillData.corpseLife then
		local damageType = skillData.corpseExplosionDamageType or "Fire"
		skillData[damageType.."BonusMin"] = skillData.corpseLife * ( skillData.corpseExplosionLifeMultiplier or skillData.selfFireExplosionLifeMultiplier )
		skillData[damageType.."BonusMax"] = skillData.corpseLife * ( skillData.corpseExplosionLifeMultiplier or skillData.selfFireExplosionLifeMultiplier )
	end

	-- Cache global damage disabling flags
	local canDeal = { }
	for _, damageType in pairs(dmgTypeList) do
		canDeal[damageType] = not skillModList:Flag(skillCfg, "DealNo"..damageType)
	end

	-- Calculate damage conversion percentages
	activeSkill.conversionTable = wipeTable(activeSkill.conversionTable)
	for damageTypeIndex = 1, 4 do
		local damageType = dmgTypeList[damageTypeIndex]
		local globalConv = wipeTable(tempTable1)
		local skillConv = wipeTable(tempTable2)
		local add = wipeTable(tempTable3)
		local globalTotal, skillTotal = 0, 0
		for otherTypeIndex = damageTypeIndex + 1, 5 do
			-- For all possible destination types, check for global and skill conversions
			otherType = dmgTypeList[otherTypeIndex]
			globalConv[otherType] = skillModList:Sum("BASE", skillCfg, damageType.."DamageConvertTo"..otherType, isElemental[damageType] and "ElementalDamageConvertTo"..otherType or nil, damageType ~= "Chaos" and "NonChaosDamageConvertTo"..otherType or nil)
			globalTotal = globalTotal + globalConv[otherType]
			skillConv[otherType] = skillModList:Sum("BASE", skillCfg, "Skill"..damageType.."DamageConvertTo"..otherType)
			skillTotal = skillTotal + skillConv[otherType]
			add[otherType] = skillModList:Sum("BASE", skillCfg, damageType.."DamageGainAs"..otherType, isElemental[damageType] and "ElementalDamageGainAs"..otherType or nil, damageType ~= "Chaos" and "NonChaosDamageGainAs"..otherType or nil)
		end
		if skillTotal > 100 then
			-- Skill conversion exceeds 100%, scale it down and remove non-skill conversions
			local factor = 100 / skillTotal
			for type, val in pairs(skillConv) do
				-- Overconversion is fixed in 3.0, so I finally get to uncomment this line!
				skillConv[type] = val * factor
			end
			for type, val in pairs(globalConv) do
				globalConv[type] = 0
			end
		elseif globalTotal + skillTotal > 100 then
			-- Conversion exceeds 100%, scale down non-skill conversions
			local factor = (100 - skillTotal) / globalTotal
			for type, val in pairs(globalConv) do
				globalConv[type] = val * factor
			end
			globalTotal = globalTotal * factor
		end
		local dmgTable = { }
		for type, val in pairs(globalConv) do
			dmgTable[type] = (globalConv[type] + skillConv[type] + add[type]) / 100
		end
		dmgTable.mult = 1 - m_min((globalTotal + skillTotal) / 100, 1)
		activeSkill.conversionTable[damageType] = dmgTable
	end
	activeSkill.conversionTable["Chaos"] = { mult = 1 }

	
	-- Configure damage passes
	local passList = { }
	if isAttack then
		output.MainHand = { }
		output.OffHand = { }
		local critOverride = skillModList:Override(cfg, "WeaponBaseCritChance")
		if skillFlags.weapon1Attack then
			if breakdown then
				breakdown.MainHand = LoadModule(calcs.breakdownModule, skillModList, output.MainHand)
			end
			activeSkill.weapon1Cfg.skillStats = output.MainHand
			local source = copyTable(actor.weaponData1)
			if critOverride and source.type and source.type ~= "None" then
				source.CritChance = critOverride
			end
			t_insert(passList, {
label = "主手",
				source = source,
				cfg = activeSkill.weapon1Cfg,
				output = output.MainHand,
				breakdown = breakdown and breakdown.MainHand,
			})
		end
		if skillFlags.weapon2Attack then
			if breakdown then
				breakdown.OffHand = LoadModule(calcs.breakdownModule, skillModList, output.OffHand)
			end
			activeSkill.weapon2Cfg.skillStats = output.OffHand
			local source = copyTable(actor.weaponData2)
			if critOverride and source.type and source.type ~= "None" then
				source.CritChance = critOverride
			end
			if skillData.CritChance then
				source.CritChance = skillData.CritChance
			end
			
			if skillData.setOffHandPhysicalMin and skillData.setOffHandPhysicalMax then
				source.PhysicalMin = skillData.setOffHandPhysicalMin
				source.PhysicalMax = skillData.setOffHandPhysicalMax
			end
			if skillData.attackTime then
				source.AttackRate = 1000 / skillData.attackTime
			end
			t_insert(passList, {
label = "副手",
				source = source,
				cfg = activeSkill.weapon2Cfg,
				output = output.OffHand,
				breakdown = breakdown and breakdown.OffHand,
			})
		end
	else
		t_insert(passList, {
label = "技能",
			source = skillData,
			cfg = skillCfg,
			output = output,
			breakdown = breakdown,
		})
	end

	local function combineStat(stat, mode, ...)
		-- Combine stats from Main Hand and Off Hand according to the mode
		if mode == "OR" or not skillFlags.bothWeaponAttack then
			output[stat] = output.MainHand[stat] or output.OffHand[stat]
		elseif mode == "ADD" then
			output[stat] = (output.MainHand[stat] or 0) + (output.OffHand[stat] or 0)
		elseif mode == "AVERAGE" then
			output[stat] = ((output.MainHand[stat] or 0) + (output.OffHand[stat] or 0)) / 2
		elseif mode == "CHANCE" then
			if output.MainHand[stat] and output.OffHand[stat] then
				local mainChance = output.MainHand[...] * output.MainHand.HitChance
				local offChance = output.OffHand[...] * output.OffHand.HitChance
				local mainPortion = mainChance / (mainChance + offChance)
				local offPortion = offChance / (mainChance + offChance)
				output[stat] = output.MainHand[stat] * mainPortion + output.OffHand[stat] * offPortion
				if breakdown then
					if not breakdown[stat] then
						breakdown[stat] = { }
					end
t_insert(breakdown[stat], "主手占:")
					t_insert(breakdown[stat], s_format("%.1f", output.MainHand[stat]))
t_insert(breakdown[stat], s_format("x %.3f ^8(主手创建的实例部分)", mainPortion))
					t_insert(breakdown[stat], s_format("= %.1f", output.MainHand[stat] * mainPortion))
t_insert(breakdown[stat], "副手占:")
					t_insert(breakdown[stat], s_format("%.1f", output.OffHand[stat]))
t_insert(breakdown[stat], s_format("x %.3f ^8(副手创建的实例部分)", offPortion))
					t_insert(breakdown[stat], s_format("= %.1f", output.OffHand[stat] * offPortion))
					t_insert(breakdown[stat], "Total:")
					t_insert(breakdown[stat], s_format("%.1f + %.1f", output.MainHand[stat] * mainPortion, output.OffHand[stat] * offPortion))
					t_insert(breakdown[stat], s_format("= %.1f", output[stat]))
				end
			else
				output[stat] = output.MainHand[stat] or output.OffHand[stat]
			end
		elseif mode == "DPS" then
			output[stat] = (output.MainHand[stat] or 0) + (output.OffHand[stat] or 0)
			if not skillData.doubleHitsWhenDualWielding then
				output[stat] = output[stat] / 2
			end
		end
	end

	for _, pass in ipairs(passList) do
		local globalOutput, globalBreakdown = output, breakdown
		local source, output, cfg, breakdown = pass.source, pass.output, pass.cfg, pass.breakdown
		
		-- Calculate hit chance 
		 
		
		output.Accuracy = m_max(0, calcLib.val(skillModList, "Accuracy", cfg))
		if breakdown then
			breakdown.Accuracy = breakdown.simple(nil, cfg, output.Accuracy, "Accuracy")
		end
		if not isAttack or skillModList:Flag(cfg, "CannotBeEvaded") or skillData.cannotBeEvaded or (env.mode_effective and enemyDB:Flag(nil, "CannotEvade")) then
			output.HitChance = 100
		else
			local enemyEvasion = round(calcLib.val(enemyDB, "Evasion"))
			output.HitChance = calcs.hitChance(enemyEvasion, output.Accuracy) * calcLib.mod(skillModList, cfg, "HitChance")
		 
			local avoidblidval=skillModList:Sum("BASE", nil, "AvoidBlind") or 0
			
			if skillModList:Flag(cfg, "Condition:Blinded") and not skillModList:Flag(cfg, "IgnoreBlindHitChance") and avoidblidval <=0    then 
				output.HitChance=output.HitChance* 0.5
				if breakdown then
					 breakdown.HitChance = {
					 "你被致盲，击中几率减半。",
					"敌人等级: "..env.enemyLevel..(env.configInput.enemyLevel and " ^8(从配置界面的获取值" or " ^8(可以从配置界面修改)"),
					"敌人平均闪避: "..enemyEvasion,
					"预计击中几率: "..output.HitChance.."%",
									}
				end
			else 
				if breakdown then
				breakdown.HitChance = {
"敌人等级: "..env.enemyLevel..(env.configInput.enemyLevel and " ^8(从配置界面的获取值" or " ^8(可以从配置界面修改)"),
"敌人平均闪避: "..enemyEvasion,
"预计击中几率: "..output.HitChance.."%",
				}
				end
			end 
			
			
		end

		-- Calculate attack/cast speed
		if activeSkill.activeEffect.grantedEffect.castTime == 0 and not skillData.castTimeOverride then
			output.Time = 0
			output.Speed = 0
		elseif skillData.timeOverride then
			output.Time = skillData.timeOverride
			output.Speed = 1 / output.Time
		elseif skillData.fixedCastTime then
			output.Time = activeSkill.activeEffect.grantedEffect.castTime
			output.Speed = 1 / output.Time
		elseif skillData.triggerTime and skillData.triggered then
			local cwcLinkedSpells = skillModList:Sum("BASE", cfg, "CastWhileChannellingSpellsLinked")
			if cwcLinkedSpells > 0 then
				output.Time = skillData.triggerTime / (1 + skillModList:Sum("INC", cfg, "CooldownRecovery") / 100) * cwcLinkedSpells
			else
				output.Time = skillData.triggerTime / (1 + skillModList:Sum("INC", cfg, "CooldownRecovery") / 100)
			end
			output.TriggerTime = output.Time
			output.Speed = 1 / output.Time
			skillData.showAverage = false
		 elseif skillData.triggerRate and skillData.triggered then
            output.Time = 1 / skillData.triggerRate
			output.TriggerTime = output.Time
			output.Speed = skillData.triggerRate
			skillData.showAverage = false
		elseif skillData.triggeredByBrand and skillData.triggered then
			output.Time = 1 / (1 + skillModList:Sum("INC", cfg, "Speed", "BrandActivationFrequency") / 100) / skillModList:More(cfg, "BrandActivationFrequency") * (skillModList:Sum("BASE", cfg, "ArcanistSpellsLinked") or 1)
			output.TriggerTime = output.Time
			output.Speed = 1 / output.Time
		else
			local baseTime
			if isAttack then
				if skillData.castTimeOverridesAttackTime then
					-- Skill is overriding weapon attack speed
					baseTime = activeSkill.activeEffect.grantedEffect.castTime / (1 + (source.AttackSpeedInc or 0) / 100)
				elseif calcLib.mod(skillModList, skillCfg, "SkillAttackTime") > 0 then
					baseTime = (1 / ( source.AttackRate or 1 ) + skillModList:Sum("BASE", cfg, "Speed")) * calcLib.mod(skillModList, skillCfg, "SkillAttackTime")		
				else
					baseTime = 1 / ( source.AttackRate or 1 ) + skillModList:Sum("BASE", cfg, "Speed")
				end
			else
				baseTime = skillData.castTimeOverride or activeSkill.activeEffect.grantedEffect.castTime or 1
			end
			local inc = skillModList:Sum("INC", cfg, "Speed")
			local more = skillModList:More(cfg, "Speed")
			output.Speed = 1 / baseTime * round((1 + inc/100) * more, 2)
			output.CastRate = output.Speed
			output.Repeats = 1 + (skillModList:Sum("BASE", cfg, "RepeatCount") or 0)
			
			if skillFlags.selfCast then
				-- Self-cast skill; apply action speed
				output.Speed = output.Speed * globalOutput.ActionSpeedMod
				output.CastRate = output.Speed
			end
			if output.Cooldown then				
				output.Speed = m_min(output.Speed, 1 / output.Cooldown * output.Repeats)
			end
			if output.Cooldown and skillFlags.selfCast then
				skillFlags.notAverage = true
				skillFlags.showAverage = false
				skillData.showAverage = false
			end
			output.Speed = m_min(output.Speed, data.misc.ServerTickRate)
			
			if output.Speed == 0 then 
				output.Time = 0
			else 
				output.Time = 1 / output.Speed
			end
			
			if breakdown then
				breakdown.Speed = { }
				breakdown.multiChain(breakdown.Speed, {
					base = s_format("%.2f ^8(基础)", 1 / baseTime),
					{ "%.2f ^8(提高/降低)", 1 + inc/100 },
					{ "%.2f ^8(额外总提高/额外总降低)", more },
					{ "%.2f ^8(动作速度加成)", skillFlags.selfCast and globalOutput.ActionSpeedMod or 1 },
					total = s_format("= %.2f ^8每秒施放", output.CastRate)
				})
				if output.Cooldown and (1 / output.Cooldown) < output.CastRate then
					t_insert(breakdown.Speed, s_format("\n"))
					t_insert(breakdown.Speed, s_format("1 / %.2f ^8(技能冷却)", output.Cooldown))
					if output.Repeats > 1 then
						t_insert(breakdown.Speed, s_format("x %d ^8(重复次数)", output.Repeats))
					end
					t_insert(breakdown.Speed, s_format("= %.2f ^8(每秒施放)", output.Repeats / output.Cooldown))
					t_insert(breakdown.Speed, s_format("\n"))
					t_insert(breakdown.Speed, s_format("= %.2f ^8(最低施放速率)", output.Speed))
				end
			end
			if breakdown and calcLib.mod(skillModList, skillCfg, "SkillAttackTime") > 0 then
				breakdown.Time = { }
				breakdown.multiChain(breakdown.Time, {
					base = s_format("%.2f ^8(基础)", 1 / (output.Speed * calcLib.mod(skillModList, skillCfg, "SkillAttackTime") )),
					{ "%.2f ^8(总加成)", calcLib.mod(skillModList, skillCfg, "SkillAttackTime")  },
					total = s_format("= %.2f ^8每秒攻击", output.Time)
				})
			end 
		end
			if skillData.hitTimeOverride and not skillData.triggeredOnDeath then
			output.HitTime = skillData.hitTimeOverride
			output.HitSpeed = 1 / output.HitTime
			--Brands always have hitTimeOverride
			if skillFlags.brand then
				output.BrandTicks = m_floor(output.Duration * output.HitSpeed)
			end
		end
			 
	end

	if isAttack then
		-- Combine hit chance and attack speed
		combineStat("HitChance", "AVERAGE")
		combineStat("Speed", "AVERAGE")
		combineStat("HitSpeed", "OR")
		if output.Speed == 0 then
			output.Time = 0
		else
			output.Time = 1 / output.Speed
		end
		if skillFlags.bothWeaponAttack then
			if breakdown then
				breakdown.Speed = {
"所有武器:",
					s_format("(%.2f + %.2f) / 2", output.MainHand.Speed, output.OffHand.Speed),
					s_format("= %.2f", output.Speed),
				}
			end
		end
	end

-- Grab quantity multiplier
	local quantityMultiplier = m_max(activeSkill.skillModList:Sum("BASE", activeSkill.skillCfg, "QuantityMultiplier"), 1)
	if quantityMultiplier > 1 then
		output.QuantityMultiplier = quantityMultiplier
	end

	for _, pass in ipairs(passList) do
		local globalOutput, globalBreakdown = output, breakdown
		local source, output, cfg, breakdown = pass.source, pass.output, pass.cfg, pass.breakdown

		-- Exerted Attack members
		local exertedDoubleDamage = env.modDB:Sum("BASE", cfg, "ExertDoubleDamageChance")
		globalOutput.OffensiveWarcryEffect = 1
		globalOutput.MaxOffensiveWarcryEffect = 1
		globalOutput.TheoreticalOffensiveWarcryEffect = 1
		globalOutput.TheoreticalMaxOffensiveWarcryEffect = 1
		globalOutput.SeismicHitEffect = 1
		globalOutput.RallyingHitEffect = 1
		globalOutput.AilmentWarcryEffect = 1

		if env.mode_buffs then
			-- Iterative over all the active skills to account for exerted attacks provided by warcries
			if (activeSkill.activeEffect.grantedEffect.name == "瓦尔.裂地之击" or not activeSkill.skillTypes[SkillType.Vaal]) and not activeSkill.skillTypes[SkillType.Channelled] and not activeSkill.skillModList:Flag(cfg, "SupportedByMultistrike") then
			
				for index, value in ipairs(actor.activeSkillList) do
				
					if not activeSkill.skillTypes[SkillType.Channelled]  and value.activeEffect.grantedEffect.name == "先祖战吼" and activeSkill.skillTypes[SkillType.MeleeSingleTarget] and not globalOutput.AncestralCryCalculated then
						globalOutput.CreateWarcryOffensiveCalcSection = true
						globalOutput.AncestralCryDuration = calcSkillDuration(value.skillModList, value.skillCfg, value.skillData, env, enemyDB)
						globalOutput.AncestralCryCooldown = calcSkillCooldown(value.skillModList, value.skillCfg, value.skillData)
						output.GlobalWarcryCooldown = env.modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
						output.GlobalWarcryCount = env.modDB:Sum("BASE", nil, "GlobalWarcryCount")
						if modDB:Flag(nil, "WarcryShareCooldown") then
							globalOutput.AncestralCryCooldown = globalOutput.AncestralCryCooldown + (output.GlobalWarcryCooldown - globalOutput.AncestralCryCooldown) / output.GlobalWarcryCount
						end
						globalOutput.AncestralCryCastTime = calcWarcryCastTime(value.skillModList, value.skillCfg, actor)
						globalOutput.AncestralExertsCount = env.modDB:Sum("BASE", nil, "NumAncestralExerts") or 0
						local baseUptimeRatio = m_min((globalOutput.AncestralExertsCount / output.Speed) / (globalOutput.AncestralCryCooldown + globalOutput.AncestralCryCastTime), 1) * 100
						local additionalCooldownUses = value.skillModList:Sum("BASE", value.skillCfg, "AdditionalCooldownUses")
						globalOutput.AncestralUpTimeRatio = m_min(100, baseUptimeRatio * (additionalCooldownUses + 1))
						if globalBreakdown then
							globalBreakdown.AncestralUpTimeRatio = { }
							t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("(%d ^8(增助次数)", globalOutput.AncestralExertsCount))
							t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("/ %.2f) ^8(每秒攻击次数)", output.Speed))
							if globalOutput.AncestralCryCastTime > 0 then
								t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("/ (%.2f ^8(战吼冷却时间)", globalOutput.AncestralCryCooldown))
								t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("+ %.2f) ^8(战吼施放时间)", globalOutput.AncestralCryCastTime))
							else								
								t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("/ %.2f ^8(平均战吼冷却时间)", globalOutput.AncestralCryCooldown))
					
							end
							t_insert(globalBreakdown.AncestralUpTimeRatio, s_format("= %d%%", globalOutput.AncestralUpTimeRatio))
						end
						globalOutput.AncestralCryCalculated = true
					elseif not activeSkill.skillTypes[SkillType.Channelled]  and  value.activeEffect.grantedEffect.name == "炼狱呼嚎" and not globalOutput.InfernalCryCalculated then
						globalOutput.CreateWarcryOffensiveCalcSection = true
						globalOutput.InfernalCryDuration = calcSkillDuration(value.skillModList, value.skillCfg, value.skillData, env, enemyDB)
						globalOutput.InfernalCryCooldown = calcSkillCooldown(value.skillModList, value.skillCfg, value.skillData)
						output.GlobalWarcryCooldown = env.modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
						output.GlobalWarcryCount = env.modDB:Sum("BASE", nil, "GlobalWarcryCount")
						if modDB:Flag(nil, "WarcryShareCooldown") then
							globalOutput.InfernalCryCooldown = globalOutput.InfernalCryCooldown + (output.GlobalWarcryCooldown - globalOutput.InfernalCryCooldown) / output.GlobalWarcryCount
						end
						globalOutput.InfernalCryCastTime = calcWarcryCastTime(value.skillModList, value.skillCfg, actor)
						if activeSkill.skillTypes[SkillType.Melee] then
							globalOutput.InfernalExertsCount = env.modDB:Sum("BASE", nil, "NumInfernalExerts") or 0
							local baseUptimeRatio = m_min((globalOutput.InfernalExertsCount / output.Speed) / (globalOutput.InfernalCryCooldown + globalOutput.InfernalCryCastTime), 1) * 100			
							local additionalCooldownUses = value.skillModList:Sum("BASE", value.skillCfg, "AdditionalCooldownUses")
							globalOutput.InfernalUpTimeRatio = m_min(100, baseUptimeRatio * (additionalCooldownUses + 1))
							if globalBreakdown then
								globalBreakdown.InfernalUpTimeRatio = { }
								t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("(%d ^8(增助次数)", globalOutput.InfernalExertsCount))
								t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("/ %.2f) ^8(每秒攻击次数)", output.Speed))
								if globalOutput.InfernalCryCastTime > 0 then
									t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("/ (%.2f ^8(战吼冷却时间)", globalOutput.InfernalCryCooldown))
									t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("+ %.2f) ^8(战吼施放时间)", globalOutput.InfernalCryCastTime))
								else
									t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("/ %.2f ^8(平均战吼冷却时间)", globalOutput.InfernalCryCooldown))
								end
								t_insert(globalBreakdown.InfernalUpTimeRatio, s_format("= %d%%", globalOutput.InfernalUpTimeRatio))
							end
						end
						globalOutput.InfernalCryCalculated = true
					elseif  not activeSkill.skillTypes[SkillType.Channelled]  and value.activeEffect.grantedEffect.name == "威吓战吼" and activeSkill.skillTypes[SkillType.Melee] and not globalOutput.IntimidatingCryCalculated then
						globalOutput.CreateWarcryOffensiveCalcSection = true
						globalOutput.IntimidatingCryDuration = calcSkillDuration(value.skillModList, value.skillCfg, value.skillData, env, enemyDB)
						globalOutput.IntimidatingCryCooldown = calcSkillCooldown(value.skillModList, value.skillCfg, value.skillData)
						output.GlobalWarcryCooldown = env.modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
						output.GlobalWarcryCount = env.modDB:Sum("BASE", nil, "GlobalWarcryCount")
						if modDB:Flag(nil, "WarcryShareCooldown") then
							globalOutput.IntimidatingCryCooldown = globalOutput.IntimidatingCryCooldown + (output.GlobalWarcryCooldown - globalOutput.IntimidatingCryCooldown) / output.GlobalWarcryCount
						end
						globalOutput.IntimidatingCryCastTime = calcWarcryCastTime(value.skillModList, value.skillCfg, actor)
						globalOutput.IntimidatingExertsCount = env.modDB:Sum("BASE", nil, "NumIntimidatingExerts") or 0
						local baseUptime = m_min((globalOutput.IntimidatingExertsCount / output.Speed) / (globalOutput.IntimidatingCryCooldown + globalOutput.IntimidatingCryCastTime), 1) * 100
						local additionalCooldownUses = value.skillModList:Sum("BASE", value.skillCfg, "AdditionalCooldownUses")
						globalOutput.IntimidatingUpTimeRatio = m_min(100, baseUptime * (additionalCooldownUses + 1))
						if globalBreakdown then
							globalBreakdown.IntimidatingUpTimeRatio = { }
							t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("(%d ^8(增助次数)", globalOutput.IntimidatingExertsCount))
							t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("/ %.2f) ^8(每秒攻击)", output.Speed))
							if 	globalOutput.IntimidatingCryCastTime > 0 then
								t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("/ (%.2f ^8(战吼冷却时间)", globalOutput.IntimidatingCryCooldown))
								t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("+ %.2f) ^8(战吼施放时间)", globalOutput.IntimidatingCryCastTime))
							else
								t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("/ %.2f ^8(平均战吼冷却时间)", globalOutput.IntimidatingCryCooldown))
							end
							t_insert(globalBreakdown.IntimidatingUpTimeRatio, s_format("= %d%%", globalOutput.IntimidatingUpTimeRatio))
						end
						local ddChance = m_min(skillModList:Sum("BASE", cfg, "DoubleDamageChance") + (env.mode_effective and enemyDB:Sum("BASE", cfg, "SelfDoubleDamageChance") or 0) + exertedDoubleDamage, 100)
						globalOutput.IntimidatingAvgDmg = 2 * (1 - ddChance / 100) -- 1
						if globalBreakdown then
							globalBreakdown.IntimidatingAvgDmg = {
								s_format("平均【威吓战吼】伤害:"),
								s_format("%.2f%% ^8(基础双倍伤害几率 100%%)", (1 - ddChance / 100) * 100 ),
								s_format("x %d ^8(双倍伤害加成)", 2),
								s_format("= %.2f", globalOutput.IntimidatingAvgDmg),
							}
						end
						globalOutput.IntimidatingHitEffect = 1 + globalOutput.IntimidatingAvgDmg * globalOutput.IntimidatingUpTimeRatio / 100
						globalOutput.IntimidatingMaxHitEffect = 1 + globalOutput.IntimidatingAvgDmg
						if globalBreakdown then
							globalBreakdown.IntimidatingHitEffect = {
								s_format("1 + (%.2f ^8(平均增助伤害)", globalOutput.IntimidatingAvgDmg),
								s_format("x %.2f) ^8(增助效果覆盖率 %%)", globalOutput.IntimidatingUpTimeRatio / 100),
								s_format("= %.2f", globalOutput.IntimidatingHitEffect),
							}
						end

						globalOutput.TheoreticalOffensiveWarcryEffect = globalOutput.TheoreticalOffensiveWarcryEffect * globalOutput.IntimidatingHitEffect
						globalOutput.TheoreticalMaxOffensiveWarcryEffect = globalOutput.TheoreticalMaxOffensiveWarcryEffect * globalOutput.IntimidatingMaxHitEffect
						globalOutput.IntimidatingCryCalculated = true
					elseif  not activeSkill.skillTypes[SkillType.Channelled]  and value.activeEffect.grantedEffect.name == "激励战吼" and activeSkill.skillTypes[SkillType.Melee] and not globalOutput.RallyingCryCalculated then
						globalOutput.CreateWarcryOffensiveCalcSection = true
						globalOutput.RallyingCryDuration = calcSkillDuration(value.skillModList, value.skillCfg, value.skillData, env, enemyDB)
						globalOutput.RallyingCryCooldown = calcSkillCooldown(value.skillModList, value.skillCfg, value.skillData)
						output.GlobalWarcryCooldown = env.modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
						output.GlobalWarcryCount = env.modDB:Sum("BASE", nil, "GlobalWarcryCount")
						if modDB:Flag(nil, "WarcryShareCooldown") then
							globalOutput.RallyingCryCooldown = globalOutput.RallyingCryCooldown + (output.GlobalWarcryCooldown - globalOutput.RallyingCryCooldown) / output.GlobalWarcryCount
						end
						globalOutput.RallyingCryCastTime = calcWarcryCastTime(value.skillModList, value.skillCfg, actor)
						globalOutput.RallyingExertsCount = env.modDB:Sum("BASE", nil, "NumRallyingExerts") or 0
						local baseUptimeRatio = m_min((globalOutput.RallyingExertsCount / output.Speed) / (globalOutput.RallyingCryCooldown + globalOutput.RallyingCryCastTime), 1) * 100
						local additionalCooldownUses = value.skillModList:Sum("BASE", value.skillCfg, "AdditionalCooldownUses")
						globalOutput.RallyingUpTimeRatio = m_min(100, baseUptimeRatio * (additionalCooldownUses + 1))
						if globalBreakdown then
							globalBreakdown.RallyingUpTimeRatio = { }
							t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("(%d ^8(增助次数)", globalOutput.RallyingExertsCount))
							t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("/ %.2f) ^8(每秒攻击次数)", output.Speed))
							if 	globalOutput.RallyingCryCastTime > 0 then
								t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("/ (%.2f ^8(战吼冷却时间)", globalOutput.RallyingCryCooldown))
								t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("+ %.2f) ^8(战吼施放时间)", globalOutput.RallyingCryCastTime))
							else
								t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("/ %.2f ^8(平均战吼冷却时间)", globalOutput.RallyingCryCooldown))
							end
							t_insert(globalBreakdown.RallyingUpTimeRatio, s_format("= %d%%", globalOutput.RallyingUpTimeRatio))
						end
						globalOutput.RallyingAvgDmg = m_min(env.modDB:Sum("BASE", cfg, "Multiplier:NearbyAlly"), 5) * (env.modDB:Sum("BASE", nil, "RallyingExertMoreDamagePerAlly") / 100)
						if globalBreakdown then
							globalBreakdown.RallyingAvgDmg = {
								s_format("平均【激励战吼】伤害:"),
								s_format("%.2f ^8(每个附近友军伤害加成)", env.modDB:Sum("BASE", nil, "RallyingExertMoreDamagePerAlly") / 100),
								s_format("x %d ^8(友军数量 (最大=5))", m_min(env.modDB:Sum("BASE", cfg, "Multiplier:NearbyAlly"), 5)),
								s_format("= %.2f", globalOutput.RallyingAvgDmg),
							}
						end
						globalOutput.RallyingHitEffect = 1 + globalOutput.RallyingAvgDmg * globalOutput.RallyingUpTimeRatio / 100
						globalOutput.RallyingMaxHitEffect = 1 + globalOutput.RallyingAvgDmg
						if globalBreakdown then
							globalBreakdown.RallyingHitEffect = {
								s_format("1 + (%.2f ^8(平均增助伤害)", globalOutput.RallyingAvgDmg),
								s_format("x %.2f) ^8(增助效果覆盖率 %%)", globalOutput.RallyingUpTimeRatio / 100),
								s_format("= %.2f", globalOutput.RallyingHitEffect),
							}
						end
						globalOutput.OffensiveWarcryEffect = globalOutput.OffensiveWarcryEffect * globalOutput.RallyingHitEffect
						globalOutput.MaxOffensiveWarcryEffect = globalOutput.MaxOffensiveWarcryEffect * globalOutput.RallyingMaxHitEffect
						globalOutput.TheoreticalOffensiveWarcryEffect = globalOutput.TheoreticalOffensiveWarcryEffect * globalOutput.RallyingHitEffect
						globalOutput.TheoreticalMaxOffensiveWarcryEffect = globalOutput.TheoreticalMaxOffensiveWarcryEffect * globalOutput.RallyingMaxHitEffect
						globalOutput.RallyingCryCalculated = true

					elseif  not activeSkill.skillTypes[SkillType.Channelled]  and value.activeEffect.grantedEffect.name == "震地战吼" and activeSkill.skillTypes[SkillType.SlamSkill] and not globalOutput.SeismicCryCalculated then
						globalOutput.CreateWarcryOffensiveCalcSection = true
						globalOutput.SeismicCryDuration = calcSkillDuration(value.skillModList, value.skillCfg, value.skillData, env, enemyDB)
						globalOutput.SeismicCryCooldown = calcSkillCooldown(value.skillModList, value.skillCfg, value.skillData)
						output.GlobalWarcryCooldown = env.modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
						output.GlobalWarcryCount = env.modDB:Sum("BASE", nil, "GlobalWarcryCount")
						if modDB:Flag(nil, "WarcryShareCooldown") then
							globalOutput.SeismicCryCooldown = globalOutput.SeismicCryCooldown + (output.GlobalWarcryCooldown - globalOutput.SeismicCryCooldown) / output.GlobalWarcryCount
						end
						globalOutput.SeismicCryCastTime = calcWarcryCastTime(value.skillModList, value.skillCfg, actor)
						globalOutput.SeismicExertsCount = env.modDB:Sum("BASE", nil, "NumSeismicExerts") or 0
						local baseUptimeRatio = m_min((globalOutput.SeismicExertsCount / output.Speed) / (globalOutput.SeismicCryCooldown + globalOutput.SeismicCryCastTime), 1) * 100
						local additionalCooldownUses = value.skillModList:Sum("BASE", value.skillCfg, "AdditionalCooldownUses")
						globalOutput.SeismicUpTimeRatio = m_min(100, baseUptimeRatio * (additionalCooldownUses + 1))
						if globalBreakdown then
							globalBreakdown.SeismicUpTimeRatio = { }
							t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("(%d ^8(增助次数)", globalOutput.SeismicExertsCount))
							t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("/ %.2f) ^8(每秒攻击)", output.Speed))
							if 	globalOutput.SeismicCryCastTime > 0 then
								t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("/ (%.2f ^8(战吼冷却)", globalOutput.SeismicCryCooldown))
								t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("+ %.2f) ^8(战吼施放时间)", globalOutput.SeismicCryCastTime))
							else
								t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("/ %.2f ^8(平均战吼冷却时间)", globalOutput.SeismicCryCooldown))
							end
							t_insert(globalBreakdown.SeismicUpTimeRatio, s_format("= %d%%", globalOutput.SeismicUpTimeRatio))
						end
						-- calculate the stacking MORE dmg modifier of Seismic slams
						local SeismicMoreDmgAndAoEPerExert = env.modDB:Sum("BASE", cfg, "SeismicMoreDmgPerExert") / 100
						local TotalSeismicDmgImpact = 0
						local ThisSeismicDmgImpact = 0
						local LastSeismicImpact = 0
						local AoEImpact = 0
						local MaxSingleHitDmgImpact = 0
						local MaxSingleAoEImpact = 0
						for i = 1, globalOutput.SeismicExertsCount do
							ThisSeismicDmgImpact = SeismicMoreDmgAndAoEPerExert + (1 + SeismicMoreDmgAndAoEPerExert) * LastSeismicImpact
							MaxSingleHitDmgImpact = m_max(MaxSingleHitDmgImpact, ThisSeismicDmgImpact)
							LastSeismicImpact = LastSeismicImpact + SeismicMoreDmgAndAoEPerExert
							TotalSeismicDmgImpact = TotalSeismicDmgImpact + ThisSeismicDmgImpact
							AoEImpact = AoEImpact + (i * SeismicMoreDmgAndAoEPerExert)
							MaxSingleAoEImpact = MaxSingleAoEImpact + SeismicMoreDmgAndAoEPerExert
						end
						globalOutput.SeismicAvgDmg = (TotalSeismicDmgImpact / globalOutput.SeismicExertsCount)
						local AvgAoEImpact = AoEImpact / globalOutput.SeismicExertsCount
						if globalBreakdown then
							globalBreakdown.SeismicAvgDmg = {
								s_format("%.2f ^8(所有增助的总【震地战吼】伤害加成)", TotalSeismicDmgImpact),
								s_format("平均【震地战吼】伤害:"),
								s_format("(%.2f ^8(每次增助平均伤害加成)", TotalSeismicDmgImpact / globalOutput.SeismicExertsCount),
								s_format("= %.2f", globalOutput.SeismicAvgDmg),
							}
						end
						globalOutput.SeismicHitEffect = 1 + globalOutput.SeismicAvgDmg * globalOutput.SeismicUpTimeRatio / 100
						globalOutput.SeismicMaxHitEffect = 1 + MaxSingleHitDmgImpact
						if globalBreakdown then
							globalBreakdown.SeismicHitEffect = {
								s_format("1 + (%.2f ^8(平均增助伤害)", globalOutput.SeismicAvgDmg),
								s_format("x %.2f) ^8(增助效果覆盖率 %%)", globalOutput.SeismicUpTimeRatio / 100),
								s_format("= %.2f", globalOutput.SeismicHitEffect),
							}
						end
						globalOutput.OffensiveWarcryEffect = globalOutput.OffensiveWarcryEffect * globalOutput.SeismicHitEffect
						globalOutput.MaxOffensiveWarcryEffect = globalOutput.MaxOffensiveWarcryEffect * globalOutput.SeismicMaxHitEffect
						globalOutput.TheoreticalOffensiveWarcryEffect = globalOutput.TheoreticalOffensiveWarcryEffect * globalOutput.SeismicHitEffect
						globalOutput.TheoreticalMaxOffensiveWarcryEffect = globalOutput.TheoreticalMaxOffensiveWarcryEffect * globalOutput.SeismicMaxHitEffect

						-- account for AoE increase
						if activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
							skillModList:NewMod("AreaOfEffect", "INC", MaxSingleAoEImpact * 100, "最大【震地战吼】增助范围")
						else
							skillModList:NewMod("AreaOfEffect", "INC", m_floor(AvgAoEImpact * globalOutput.SeismicUpTimeRatio), "平均【震地战吼】增助范围")
						end
						calcAreaOfEffect(skillModList, skillCfg, skillData, skillFlags, globalOutput, globalBreakdown)
						globalOutput.SeismicCryCalculated = true
					end
				end

				if activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
					globalOutput.AilmentWarcryEffect = globalOutput.MaxOffensiveWarcryEffect
					skillData.showAverage = true
					skillFlags.showAverage = true
					skillFlags.notAverage = false
				else
					globalOutput.AilmentWarcryEffect = globalOutput.OffensiveWarcryEffect
				end

				-- Calculate Exerted Attack Uptime
				-- There are various strategies a player could use to maximize either warcry effect stacking or staggering
				-- 1) they don't pay attention and therefore we calculated exerted attack uptime as just the maximum uptime of any enabled warcries that exert attacks
				globalOutput.ExertedAttackUptimeRatio =m_max( m_max(m_max(
				m_max(globalOutput.AncestralUpTimeRatio or 0, globalOutput.InfernalUpTimeRatio or 0),
				m_max(globalOutput.IntimidatingUpTimeRatio or 0, globalOutput.RallyingUpTimeRatio or 0)),
				globalOutput.SeismicUpTimeRatio or 0),(globalOutput.GeneralsCryUpTimeRatio or 0))
				if globalBreakdown then
					globalBreakdown.ExertedAttackUptimeRatio = { }
					t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("最大:"))
					if globalOutput.AncestralUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【先祖战吼】增助效果覆盖率)", globalOutput.AncestralUpTimeRatio or 0))
					end
					if globalOutput.InfernalUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【炼狱呼嚎】增助效果覆盖率)", globalOutput.InfernalUpTimeRatio or 0))
					end
					if globalOutput.IntimidatingUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【威吓战吼】增助效果覆盖率)", globalOutput.IntimidatingUpTimeRatio or 0))
					end
					if globalOutput.RallyingUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【激励战吼】增助效果覆盖率)", globalOutput.RallyingUpTimeRatio or 0))
					end
					if globalOutput.SeismicUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【震地战吼】增助效果覆盖率)", globalOutput.SeismicUpTimeRatio or 0))
					end
					if globalOutput.GeneralsCryUpTimeRatio then
						t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("%d%% ^8(【将军之吼】增助效果覆盖率)", globalOutput.GeneralsCryUpTimeRatio or 0))
					end
					t_insert(globalBreakdown.ExertedAttackUptimeRatio, s_format("= %d%%", globalOutput.ExertedAttackUptimeRatio))
				end
				
				if globalOutput.ExertedAttackUptimeRatio > 0 then
					local incExertedAttacks = skillModList:Sum("INC", cfg, "ExertIncrease")
					local moreExertedAttacks = skillModList:More(cfg, "ExertIncrease")
					if activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
						skillModList:NewMod("Damage", "INC", incExertedAttacks, "增助攻击")
						skillModList:NewMod("Damage", "MORE", moreExertedAttacks, "增助攻击")
					else
						skillModList:NewMod("Damage", "INC", incExertedAttacks * globalOutput.ExertedAttackUptimeRatio / 100, "增助效果覆盖率加成后增助攻击")
						skillModList:NewMod("Damage", "MORE", moreExertedAttacks * globalOutput.ExertedAttackUptimeRatio / 100, "增助效果覆盖率加成后增助攻击")
					end
					globalOutput.ExertedAttackAvgDmg = calcLib.mod(skillModList, skillCfg, "ExertIncrease")
					globalOutput.ExertedAttackHitEffect = globalOutput.ExertedAttackAvgDmg * globalOutput.ExertedAttackUptimeRatio / 100
					globalOutput.ExertedAttackMaxHitEffect = globalOutput.ExertedAttackAvgDmg
					if globalBreakdown then
						globalBreakdown.ExertedAttackHitEffect = {
							s_format("(%.2f ^8(平均增助伤害)", globalOutput.ExertedAttackAvgDmg),
							s_format("x %.2f) ^8(增助效果覆盖率 %%)", globalOutput.ExertedAttackUptimeRatio / 100),
							s_format("= %.2f", globalOutput.ExertedAttackHitEffect),
						}
					end
				end
			end
		end

		output.RuthlessBlowEffect = 1
		output.FistOfWarHitEffect = 1
		output.FistOfWarAilmentEffect = 1
		if env.mode_combat then
			-- Calculate Ruthless Blow chance/multipliers + Fist of War multipliers
			output.RuthlessBlowMaxCount = skillModList:Sum("BASE", cfg, "RuthlessBlowMaxCount")
			if output.RuthlessBlowMaxCount > 0 then
				output.RuthlessBlowChance = round(100 / output.RuthlessBlowMaxCount)
			else
				output.RuthlessBlowChance = 0
			end
			output.RuthlessBlowMultiplier = 1 + skillModList:Sum("BASE", cfg, "RuthlessBlowMultiplier") / 100
			output.RuthlessBlowEffect = 1 - output.RuthlessBlowChance / 100 + output.RuthlessBlowChance / 100 * output.RuthlessBlowMultiplier

			globalOutput.FistOfWarCooldown = skillModList:Sum("BASE", cfg, "FistOfWarCooldown") or 0
			-- If Fist of War & Active Skill is a Slam Skill & NOT a Vaal Skill
			if globalOutput.FistOfWarCooldown ~= 0 and activeSkill.skillTypes[SkillType.SlamSkill] and not activeSkill.skillTypes[SkillType.Vaal] then
				globalOutput.FistOfWarHitMultiplier = skillModList:Sum("BASE", cfg, "FistOfWarHitMultiplier") / 100
				globalOutput.FistOfWarAilmentMultiplier = skillModList:Sum("BASE", cfg, "FistOfWarAilmentMultiplier") / 100
				globalOutput.FistOfWarUptimeRatio = m_min( (1 / output.Speed) / globalOutput.FistOfWarCooldown, 1) * 100
				if globalBreakdown then
					globalBreakdown.FistOfWarUptimeRatio = {
						s_format("min( (1 / %.2f) ^8(每秒攻击次数)", output.Speed),
						s_format("/ %.2f, 1) ^8(【战争铁拳】冷却时间)", globalOutput.FistOfWarCooldown),
						s_format("= %d%%", globalOutput.FistOfWarUptimeRatio),
					}
				end
				globalOutput.AvgFistOfWarHit = globalOutput.FistOfWarHitMultiplier
				globalOutput.AvgFistOfWarHitEffect = 1 + globalOutput.FistOfWarHitMultiplier * (globalOutput.FistOfWarUptimeRatio / 100)
				if globalBreakdown then
					globalBreakdown.AvgFistOfWarHitEffect = {
						s_format("1 + (%.2f ^8(【战争铁拳】击中加成)", globalOutput.FistOfWarHitMultiplier),
						s_format("x %.2f) ^8(【战争铁拳】使用速率)", globalOutput.FistOfWarUptimeRatio / 100),
						s_format("= %.2f", globalOutput.AvgFistOfWarHitEffect),
					}
				end
				globalOutput.AvgFistOfWarAilmentEffect = 1 + globalOutput.FistOfWarAilmentMultiplier * (globalOutput.FistOfWarUptimeRatio / 100)
				globalOutput.MaxFistOfWarHitEffect = 1 + globalOutput.FistOfWarHitMultiplier
				globalOutput.MaxFistOfWarAilmentEffect = 1 + globalOutput.FistOfWarAilmentMultiplier
				if activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
					output.FistOfWarHitEffect = globalOutput.MaxFistOfWarHitEffect
					output.FistOfWarAilmentEffect = globalOutput.MaxFistOfWarAilmentEffect
				else
					output.FistOfWarHitEffect = globalOutput.AvgFistOfWarHitEffect
					output.FistOfWarAilmentEffect = globalOutput.AvgFistOfWarAilmentEffect
				end
				globalOutput.TheoreticalOffensiveWarcryEffect = globalOutput.TheoreticalOffensiveWarcryEffect * globalOutput.AvgFistOfWarHitEffect
				globalOutput.TheoreticalMaxOffensiveWarcryEffect = globalOutput.TheoreticalMaxOffensiveWarcryEffect * globalOutput.MaxFistOfWarHitEffect
			else
				output.FistOfWarHitEffect = 1
				output.FistOfWarAilmentEffect = 1
			end
		end
		
		
		-- Calculate crit chance, crit multiplier, and their combined effect
		if skillModList:Flag(nil, "NeverCrit") then
			output.PreEffectiveCritChance = 0
			output.CritChance = 0
			output.CritMultiplier = 0
			output.BonusCritDotMultiplier = 0
			output.CritEffect = 1
		else
			local critOverride = skillModList:Override(cfg, "CritChance")
			local baseCrit = critOverride or source.CritChance or 0
			if baseCrit == 100 then
				output.PreEffectiveCritChance = 100
				output.CritChance = 100
			else
				local base = 0
				local inc = 0
				local more = 1
				if not critOverride then
					base = skillModList:Sum("BASE", cfg, "CritChance") + (env.mode_effective and enemyDB:Sum("BASE", nil, "SelfCritChance") or 0)
					inc = skillModList:Sum("INC", cfg, "CritChance") + (env.mode_effective and enemyDB:Sum("INC", nil, "SelfCritChance") or 0)
					more = skillModList:More(cfg, "CritChance")
				end
				local override = skillModList:Override(cfg, "CritChance")
				output.CritChance = (baseCrit + base) * (1 + inc / 100) * more
				local preCapCritChance = output.CritChance
				output.CritChance = m_min(output.CritChance, 100)
				if (baseCrit + base) > 0 then
					output.CritChance = m_max(output.CritChance, 0)
				end
				output.PreEffectiveCritChance = output.CritChance
				local preLuckyCritChance = output.CritChance
				if env.mode_effective and skillModList:Flag(cfg, "CritChanceLucky") then
					output.CritChance = (1 - (1 - output.CritChance / 100) ^ 2) * 100
				end
				
				output.CritChance = override or output.CritChance
				local preHitCheckCritChance = output.CritChance
				if env.mode_effective then
					output.CritChance = output.CritChance * output.HitChance / 100
				end
				if breakdown and output.CritChance ~= baseCrit then
					breakdown.CritChance = { }
					if base ~= 0 then
						t_insert(breakdown.CritChance, s_format("(%g + %g) ^8(基础)", baseCrit, base))
					else
						t_insert(breakdown.CritChance, s_format("%g ^8(基础)", baseCrit + base))
					end
					if inc ~= 0 then
						t_insert(breakdown.CritChance, s_format("x %.2f", 1 + inc/100).." ^8(提高/降低)")
					end
					if more ~= 1 then
						t_insert(breakdown.CritChance, s_format("x %.2f", more).." ^8(额外总提高/额外总降低)")
					end
					t_insert(breakdown.CritChance, s_format("= %.2f%% ^8(暴击几率)", output.PreEffectiveCritChance))
					if preCapCritChance > 100 then
						local overCap = preCapCritChance - 100
						t_insert(breakdown.CritChance, s_format("暴击几率溢出 %.2f%% (等同词缀“提高暴击几率 %d%%”)", overCap, overCap / more / (baseCrit + base) * 100))
					end
					if env.mode_effective and skillModList:Flag(cfg, "CritChanceLucky") then
						t_insert(breakdown.CritChance, "暴击几率是幸运的:")
						t_insert(breakdown.CritChance, s_format("1 - (1 - %.4f) x (1 - %.4f)", preLuckyCritChance / 100, preLuckyCritChance / 100))
						t_insert(breakdown.CritChance, s_format("= %.2f%%", preHitCheckCritChance))
					end
					if override  then 
						t_insert(breakdown.CritChance, s_format("暴击率覆盖:%.2f%%", override))				
					end
					if env.mode_effective and output.HitChance < 100 then
						t_insert(breakdown.CritChance, "暴击确认:")
						t_insert(breakdown.CritChance, s_format("%.2f%%", preHitCheckCritChance))
						t_insert(breakdown.CritChance, s_format("x %.2f ^8(命中率)", output.HitChance / 100))
						t_insert(breakdown.CritChance, s_format("= %.2f%%", output.CritChance))
					end
				end
			end
			if skillModList:Flag(cfg, "NoCritMultiplier") then
				output.CritMultiplier = 1
			else
				local extraDamage = skillModList:Sum("BASE", cfg, "CritMultiplier") / 100
				local multiOverride = skillModList:Override(skillCfg, "CritMultiplier")
				if multiOverride then
					extraDamage = (multiOverride - 100) / 100
				end
				if env.mode_effective then
					local enemyInc = 1 + enemyDB:Sum("INC", nil, "SelfCritMultiplier") / 100
					extraDamage = extraDamage + enemyDB:Sum("BASE", nil, "SelfCritMultiplier") / 100
					extraDamage = round(extraDamage * enemyInc, 2)
					if breakdown and enemyInc ~= 1 then
						breakdown.CritMultiplier = {
							s_format("%d%% ^8(额外伤害)", (enemyDB:Sum("BASE", nil, "SelfCritMultiplier")+skillModList:Sum("BASE", cfg, "CritMultiplier")) / 100),
							s_format("x %.2f ^8(敌人承受额外暴击伤害的提高/降低 )", enemyInc),
							s_format("= %d%% ^8(额外暴击伤害)", extraDamage * 100),
						}
					end
				end
				output.CritMultiplier = 1 + m_max(0, extraDamage)
			end
			local critChancePercentage = output.CritChance / 100
			output.CritEffect = 1 - critChancePercentage + critChancePercentage * output.CritMultiplier			
			output.BonusCritDotMultiplier = (skillModList:Sum("BASE", cfg, "CritMultiplier") - 50) * skillModList:Sum("BASE", cfg, "CritMultiplierAppliesToDegen") / 10000
			
			if breakdown and output.CritEffect ~= 1 then
				breakdown.CritEffect = {
					s_format("(1 - %.4f) ^8(非暴击部分的伤害)", critChancePercentage),
					s_format("+ [ (%.4f x %g) ^8(暴击部分的伤害)", critChancePercentage, output.CritMultiplier),
					
					s_format("= %.3f", output.CritEffect),
				}
			end
		end
		
 output.ScaledDamageEffect = 1
	
		-- Calculate chance and multiplier for dealing triple damage on Normal and Crit
		output.TripleDamageChanceOnCrit = m_min(skillModList:Sum("BASE", cfg, "TripleDamageChanceOnCrit"), 100)
		output.TripleDamageChance = m_min(skillModList:Sum("BASE", cfg, "TripleDamageChance") or 0 + (env.mode_effective and enemyDB:Sum("BASE", cfg, "SelfTripleDamageChance") or 0) + (output.TripleDamageChanceOnCrit * output.CritChance / 100), 100)
		output.TripleDamageEffect = 1 + (2 * output.TripleDamageChance / 100)
		output.ScaledDamageEffect = output.ScaledDamageEffect * output.TripleDamageEffect

		-- Calculate chance and multiplier for dealing double damage on Normal and Crit
		output.DoubleDamageChanceOnCrit = m_min(skillModList:Sum("BASE", cfg, "DoubleDamageChanceOnCrit"), 100)
		output.DoubleDamageChance = m_min(skillModList:Sum("BASE", cfg, "DoubleDamageChance") + (env.mode_effective and enemyDB:Sum("BASE", cfg, "SelfDoubleDamageChance") or 0) + (output.DoubleDamageChanceOnCrit * output.CritChance / 100), 100)
		if globalOutput.IntimidatingUpTimeRatio and activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
			output.DoubleDamageChance = 100
		elseif globalOutput.IntimidatingUpTimeRatio then
			output.DoubleDamageChance = m_min(output.DoubleDamageChance + globalOutput.IntimidatingUpTimeRatio, 100)
		end
		-- Triple Damage overrides Double Damage. If you have both, it's the same as just having Triple
		-- We need to subtract the probability of both happening in favor of Triple Damage
		if output.TripleDamageChance > 0 then
			output.DoubleDamageChance = m_max(output.DoubleDamageChance - output.TripleDamageChance * output.DoubleDamageChance / 100, 0)
		end
		output.DoubleDamageEffect = 1 + output.DoubleDamageChance / 100
		output.ScaledDamageEffect = output.ScaledDamageEffect * output.DoubleDamageEffect
		
		
		-- Calculate culling DPS
		local criticalCull = skillModList:Max(cfg, "CriticalCullPercent") or 0
		if criticalCull > 0 then
			criticalCull = criticalCull * (output.CritChance / 100)
		end
		local regularCull = skillModList:Max(cfg, "CullPercent") or 0
		local maxCullPercent = m_max(criticalCull, regularCull)
		globalOutput.CullPercent = maxCullPercent
		globalOutput.CullMultiplier = 100 / (100 - globalOutput.CullPercent)
		-- Calculate base hit damage
		for _, damageType in ipairs(dmgTypeList) do
			local damageTypeMin = damageType.."Min"
			local damageTypeMax = damageType.."Max"
			local baseMultiplier = activeSkill.activeEffect.grantedEffectLevel.baseMultiplier or 1
			local damageEffectiveness = activeSkill.activeEffect.grantedEffectLevel.damageEffectiveness or skillData.damageEffectiveness or 1
			local addedMin = skillModList:Sum("BASE", cfg, damageTypeMin) + enemyDB:Sum("BASE", cfg, "Self"..damageTypeMin)
			local addedMax = skillModList:Sum("BASE", cfg, damageTypeMax) + enemyDB:Sum("BASE", cfg, "Self"..damageTypeMax)
			local baseMin = ((source[damageTypeMin] or 0) + (source[damageType.."BonusMin"] or 0)) * baseMultiplier + addedMin * damageEffectiveness
			local baseMax = ((source[damageTypeMax] or 0) + (source[damageType.."BonusMax"] or 0)) * baseMultiplier + addedMax * damageEffectiveness
			
			if activeSkill.skillData.noShowHit then 
				
					baseMin = 0
					baseMax = 0
			 
			end		
			
			output[damageTypeMin.."Base"] = baseMin
			output[damageTypeMax.."Base"] = baseMax
			if breakdown then
				breakdown[damageType] = { damageTypes = { } }
				if baseMin ~= 0 and baseMax ~= 0 then
t_insert(breakdown[damageType], "基础伤害:")
					local plus = ""
					if (source[damageTypeMin] or 0) ~= 0 or (source[damageTypeMax] or 0) ~= 0 then
						if baseMultiplier ~= 1 then
t_insert(breakdown[damageType], s_format("(%d 至 %d) x %.2f ^8(来自基础伤害额外总加成 %s 的额外总加成基础伤害)", source[damageTypeMin], source[damageTypeMax], baseMultiplier, source.type and "武器" or "技能"))
						else
t_insert(breakdown[damageType], s_format("%d 至 %d ^8(基础伤害来自 %s)", source[damageTypeMin], source[damageTypeMax], source.type and "武器" or "技能"))
						end
						plus = "+ "
					end
					if addedMin ~= 0 or addedMax ~= 0 then
						if damageEffectiveness ~= 1 then
t_insert(breakdown[damageType], s_format("%s(%d 至 %d) x %.2f ^8(技能伤害效用调整附加点伤)", plus, addedMin, addedMax, damageEffectiveness))
						else
t_insert(breakdown[damageType], s_format("%s%d 至 %d ^8(附加伤害)", plus, addedMin, addedMax))
						end
					end
					
					local moreMin = m_floor(skillModList:More(cfg, damageType.."Min") * 100 + 0.50000001) / 100
					local moreMax = m_floor(skillModList:More(cfg, damageType.."Max") * 100 + 0.50000001) / 100


					if damageType == 'Physical'   then
						if moreMin~=nil and moreMin~=1 and moreMax~=nil and moreMax~=1 then
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax))								
							t_insert(breakdown[damageType], s_format("最小总物理伤害 x %.1f", moreMin))
							t_insert(breakdown[damageType], s_format("最大总物理伤害 x %.1f", moreMax))				
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin*moreMin, baseMax*moreMax))	
							
						elseif moreMin~=nil and moreMin~=1 then 
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax))								
							t_insert(breakdown[damageType], s_format("最小总物理伤害 x %.1f", moreMin))									
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin*moreMin, baseMax))
						elseif moreMax~=nil and moreMax~=1  then
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax))								
							t_insert(breakdown[damageType], s_format("最大总物理伤害 x %.1f", moreMax))									
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax*moreMax))
						else						
							t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax))						
						end 
					else
						t_insert(breakdown[damageType], s_format("= %.1f 至 %.1f", baseMin, baseMax))
					end 
					
				end
			end
		end
		
		-- Calculate hit damage for each damage type
		local totalHitMin, totalHitMax , totalHitAvg=  0, 0, 0
		local totalCritMin, totalCritMax , totalCritAvg =  0, 0, 0
		local ghostReaver = skillModList:Flag(nil, "GhostReaver")
		output.LifeLeech = 0
		output.LifeLeechInstant = 0
		output.EnergyShieldLeech = 0
		output.EnergyShieldLeechInstant = 0
		output.ManaLeech = 0
		output.ManaLeechInstant = 0
		output.impaleStoredHitAvg = 0
		
		
		for pass = 1, 2 do
			-- Pass 1 is critical strike damage, pass 2 is non-critical strike
			cfg.skillCond["CriticalStrike"] = (pass == 1)
			local lifeLeechTotal = 0
			local energyShieldLeechTotal = 0
			local manaLeechTotal = 0
			local noLifeLeech = skillModList:Flag(cfg, "CannotLeechLife") or enemyDB:Flag(nil, "CannotLeechLifeFromSelf")
			local noEnergyShieldLeech = skillModList:Flag(cfg, "CannotLeechEnergyShield") or enemyDB:Flag(nil, "CannotLeechEnergyShieldFromSelf")
			local noManaLeech = skillModList:Flag(cfg, "CannotLeechMana") or enemyDB:Flag(nil, "CannotLeechManaFromSelf")
			for _, damageType in ipairs(dmgTypeList) do
				local min, max,damageTypeHitAvg = 0, 0, 0
				if skillFlags.hit and canDeal[damageType] then
					min, max = calcDamage(activeSkill, output, cfg, pass == 2 and breakdown and breakdown[damageType], damageType, 0)
					local convMult = activeSkill.conversionTable[damageType].mult
					if pass == 2 and breakdown then
t_insert(breakdown[damageType], "击中伤害:")
t_insert(breakdown[damageType], s_format("%d 至 %d ^8(总伤害)", min, max))
						if convMult ~= 1 then
t_insert(breakdown[damageType], s_format("x %g ^8(%g%% 转化为其他伤害)", convMult, (1-convMult)*100))
						end
						if output.ScaledDamageEffect ~= 1 then
							t_insert(breakdown[damageType], s_format("x %.2f ^8(多倍伤害加成)", output.ScaledDamageEffect))
						
							if output.TripleDamageEffect ~= 1 then
								t_insert(breakdown[damageType], s_format("其中x %.2f ^8(加成来自 %.2f%% 几率造成三倍伤害)", output.TripleDamageEffect, output.TripleDamageChance))
							end
							if output.DoubleDamageEffect ~= 1 then
								t_insert(breakdown[damageType], s_format("其中x %.2f ^8(加成来自 %.2f%% 几率造成双倍伤害)", output.DoubleDamageEffect, output.DoubleDamageChance))
							end	
						end
											
						if output.RuthlessBlowEffect ~= 1 then
t_insert(breakdown[damageType], s_format("x %.2f ^8(【无情一击】加成)", output.RuthlessBlowEffect))
						end
						if output.FistOfWarHitEffect ~= 1 then
						t_insert(breakdown[damageType], s_format("x %.2f ^8(【战争铁拳】加成)", output.FistOfWarHitEffect))
						end
						
						if globalOutput.OffensiveWarcryEffect ~= 1  and not activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
							t_insert(breakdown[damageType], s_format("x %.2f ^8(综合战吼增助效果加成)", globalOutput.OffensiveWarcryEffect))
						end
						if globalOutput.MaxOffensiveWarcryEffect ~= 1 and activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
							t_insert(breakdown[damageType], s_format("x %.2f ^8(最大综合战吼增助效果加成)", globalOutput.MaxOffensiveWarcryEffect))
						end
						
						
					end
					if activeSkill.skillModList:Flag(nil, "Condition:WarcryMaxHit") then
						output.allMult = convMult * output.ScaledDamageEffect  * output.RuthlessBlowEffect * output.FistOfWarHitEffect * globalOutput.MaxOffensiveWarcryEffect
					else
						output.allMult = convMult * output.ScaledDamageEffect  * output.RuthlessBlowEffect * output.FistOfWarHitEffect * globalOutput.OffensiveWarcryEffect
					end
					
					local allMult = output.allMult
					
					if pass == 1 then
						-- Apply crit multiplier
						allMult = allMult * output.CritMultiplier
					end				
					min = min * allMult
					max = max * allMult
					
					if skillModList:Flag(skillCfg, "LuckyHits") or 
					(pass == 2 and damageType == "Lightning" and skillModList:Flag(skillCfg, "LightningNoCritLucky"))  
					or ((damageType == "Lightning" or damageType == "Cold" or damageType == "Fire") and skillModList:Flag(skillCfg, "ElementalLuckHits")) 
					or (pass == 1 and skillModList:Flag(skillCfg, "CritLucky"))
					then
					-- 幸运的伤害
						damageTypeHitAvg = (min / 3 + 2 * max / 3)
					else
					-- 默认是 （大伤+小伤）/2
						damageTypeHitAvg = (min / 2 + max / 2)
					end		

								
					if (min ~= 0 or max ~= 0) and env.mode_effective then
						
						-- Apply enemy resistances and damage taken modifiers
						local resist = 0
						local pen = 0
						local sourceRes = 0
						local takenInc = enemyDB:Sum("INC", cfg, "DamageTaken", damageType.."DamageTaken")
						local takenMore = enemyDB:More(cfg, "DamageTaken", damageType.."DamageTaken")
						-- Check if player is supposed to ignore a damage type, or if it's ignored on enemy side
						local useThisResist = function(damageType) 
							return (skillModList:Flag(cfg,
									 "CannotIgnoreElementalResistances")
									or  
									not skillModList:Flag(cfg, 
									"Ignore"..damageType.."Resistance", 
									isElemental[damageType] 
									and "IgnoreElementalResistances" or nil)
									)
									and not enemyDB:Flag(nil, "SelfIgnore"..damageType.."Resistance")							
							
						end
						local isIgnoreResist = false
						local isIgnorePen = false
						local isResistIsEnemy = false
						
						
						if damageType == "Physical" then
							--resist = m_max(0, enemyDB:Sum("BASE", nil, "PhysicalDamageReduction") + skillModList:Sum("BASE", cfg, "EnemyPhysicalDamageReduction"))
							-- store pre-armour physical damage from attacks for impale calculations
							if pass == 1 then
								output.impaleStoredHitAvg = output.impaleStoredHitAvg + damageTypeHitAvg * (output.CritChance / 100)
							else
								output.impaleStoredHitAvg = output.impaleStoredHitAvg + damageTypeHitAvg * (1 - output.CritChance / 100)
							
							end
							local enemyArmour = round(calcLib.val(enemyDB, "Armour") * enemyDB:More(nil, "Armour"))
							local armourReduction = calcs.armourReductionF(enemyArmour, damageTypeHitAvg)
							resist = m_max(0, enemyDB:Sum("BASE", nil, "PhysicalDamageReduction") + skillModList:Sum("BASE", cfg, "EnemyPhysicalDamageReduction") + armourReduction)
						
						else
						
							resist = enemyDB:Sum("BASE", nil, damageType.."Resist")
							
							if isElemental[damageType] then
								
								
								resist = resist + enemyDB:Sum("BASE", nil, "ElementalResist")								
								local base = resist 
								resist = base * calcLib.mod(enemyDB, nil, damageType.."Resist")
								
								if  skillModList:Flag(cfg,"CannotElementalPenetration") or skillModList:Flag(cfg,"Cannot"..damageType.."Penetration")  then
									pen = 0
									isIgnorePen = true
								else
									pen = skillModList:Sum("BASE", cfg, damageType.."Penetration", "ElementalPenetration")
									if skillModList:Flag(cfg, "ElementalDamageUsesLowestElementalResistance") then
										-- Default to using Elemental
										local elementUsed = damageType
										-- Find the lowest resist of all the elements and use that if it's lower than chaos
										for _, damageTypeFor in ipairs(dmgTypeList) do
											if isElemental[damageTypeFor] and useThisResist(damageTypeFor) then
												local elementalResistFor = enemyDB:Sum("BASE", nil, damageTypeFor.."Resist")
												local base = elementalResistFor + enemyDB:Sum("BASE", dotTypeCfg, "ElementalResist")
												local currentElementResist = base * calcLib.mod(enemyDB, nil, damageTypeFor.."Resist")
												-- If it's explicitly lower, then use the resist and update which element we're using to account for penetration
												if resist > currentElementResist then
													resist = currentElementResist
													elementUsed = damageTypeFor
												end
											end										
										end
										--Update the penetration based on the element used
										pen = skillModList:Sum("BASE", cfg, elementUsed.."Penetration", "ElementalPenetration")
										sourceRes = elementUsed
									end
									
								end						
								
								takenInc = takenInc + enemyDB:Sum("INC", nil, "ElementalDamageTaken")
								
								if skillModList:Flag(cfg,damageType.."ResistIsEnemy") and globalOutput[damageType.."ResistTotal"] then 									
									resist = globalOutput[damageType.."ResistTotal"]
									isResistIsEnemy = true
								end
								
								
							elseif damageType == "Chaos" then
								pen = skillModList:Sum("BASE", cfg, "ChaosPenetration")
								if skillModList:Flag(cfg, "ChaosDamageUsesLowestResistance") then
									-- Default to using Chaos
									local elementUsed = "Chaos"
									-- Find the lowest resist of all the elements and use that if it's lower than chaos
									for _, damageTypeForChaos in ipairs(dmgTypeList) do
										if isElemental[damageTypeForChaos] and useThisResist(damageTypeForChaos) then
											local elementalResistForChaos = enemyDB:Sum("BASE", nil, damageTypeForChaos.."Resist")
											local base = elementalResistForChaos + enemyDB:Sum("BASE", dotTypeCfg, "ElementalResist")
											local currentElementResist = base * calcLib.mod(enemyDB, nil, damageTypeForChaos.."Resist")
											-- If it's explicitly lower, then use the resist and update which element we're using to account for penetration
											if resist > currentElementResist then
												resist = currentElementResist
												elementUsed = damageTypeForChaos
											end
										end										
									end
									--Update the penetration based on the element used
									if isElemental[elementUsed] then 
										pen = skillModList:Sum("BASE", cfg, elementUsed.."Penetration", "ElementalPenetration")									
									end 
									sourceRes = elementUsed
								end
							end
							
							resist = m_min(resist, 75)
						end
						if skillFlags.projectile then
							takenInc = takenInc + enemyDB:Sum("INC", nil, "ProjectileDamageTaken")
						end
						if skillFlags.projectile and skillFlags.attack then
							takenInc = takenInc + enemyDB:Sum("INC", nil, "ProjectileAttackDamageTaken")
						end
						if skillFlags.trap or skillFlags.mine then
							takenInc = takenInc + enemyDB:Sum("INC", nil, "TrapMineDamageTaken")
						end
						local effMult = (1 + takenInc / 100) * takenMore
						local effMultChaos = (1 + takenInc / 100)	 * takenMore
						--[[如果不是元素  或者 不是 无视元素抗性 那么计算抗性收益
						
						]]--
						if skillModList:Flag(cfg, isElemental[damageType] and "CannotElePenIgnore" or nil) then
							effMult = effMult * (1 - resist / 100)
						elseif useThisResist(damageType) then
							effMult = effMult * (1 - (resist - pen) / 100)
						else 
							isIgnoreResist = true
						end
						 
						
						if  isChaos[damageType] and (skillModList:Flag(cfg, "IgnoreChaosResistances") or enemyDB:Flag(nil, "SelfIgnoreChaosResistance"))   then
							effMult = effMultChaos
						end
						min = min * effMult
						max = max * effMult
						damageTypeHitAvg = damageTypeHitAvg * effMult
						if env.mode == "CALCS" then
							output[damageType.."EffMult"] = effMult
						end
						
						if pass == 2 and breakdown  then
t_insert(breakdown[damageType], s_format("x %.3f ^8(有效 DPS 加成)", effMult))
							local spString = nil
							if isElemental[damageType] then 
								spString = ""
								if isIgnoreResist then 
									spString = spString.."【无视抗性】"
								end 
								if isIgnorePen then 
									spString =spString.."【无视抗性穿透】"
								end 
								if isResistIsEnemy then 
									spString =spString.."【周围敌人的"..cnElemental[damageType].."抗性等同于你的"..cnElemental[damageType].."抗性】"								
								end 
							 
							end 
							breakdown[damageType.."EffMult"] = breakdown.effMult(damageType, resist, pen, takenInc, effMult, takenMore, sourceRes, spString)
						end
					end
					if pass == 2 and breakdown then
						t_insert(breakdown[damageType], s_format("= %d 至 %d", min, max))
					end
					--Beginning of Leech Calculation for this DamageType
					if skillFlags.mine or skillFlags.trap or skillFlags.totem then
						if not noLifeLeech then
							local lifeLeech = skillModList:Sum("BASE", cfg, "DamageLifeLeechToPlayer")
							if lifeLeech > 0 then
								lifeLeechTotal = lifeLeechTotal + damageTypeHitAvg * lifeLeech / 100
							end
						end
					else
						if not noLifeLeech then				
							local lifeLeech
							if skillModList:Flag(nil, "LifeLeechBasedOnChaosDamage") then
								if damageType == "Chaos" then
									lifeLeech = skillModList:Sum("BASE", cfg, "DamageLeech", "DamageLifeLeech", "PhysicalDamageLifeLeech", "LightningDamageLifeLeech", "ColdDamageLifeLeech", "FireDamageLifeLeech", "ChaosDamageLifeLeech", "ElementalDamageLifeLeech") + enemyDB:Sum("BASE", cfg, "SelfDamageLifeLeech") / 100
						
								else
									lifeLeech = 0
								end
							else
								lifeLeech = skillModList:Sum("BASE", cfg, "DamageLeech", "DamageLifeLeech", damageType.."DamageLifeLeech", isElemental[damageType] and "ElementalDamageLifeLeech" or nil) + enemyDB:Sum("BASE", cfg, "SelfDamageLifeLeech") / 100
					
							end
							if lifeLeech > 0 then
								lifeLeechTotal = lifeLeechTotal + damageTypeHitAvg * lifeLeech / 100
							end
						end
						if not noEnergyShieldLeech then
							local energyShieldLeech = skillModList:Sum("BASE", cfg, "DamageEnergyShieldLeech", damageType.."DamageEnergyShieldLeech", isElemental[damageType] and "ElementalDamageEnergyShieldLeech" or nil) + enemyDB:Sum("BASE", cfg, "SelfDamageEnergyShieldLeech") / 100							
							if energyShieldLeech > 0 then
								energyShieldLeechTotal = energyShieldLeechTotal + damageTypeHitAvg * energyShieldLeech / 100
							end
						end
						if not noManaLeech then
							local manaLeech = skillModList:Sum("BASE", cfg, "DamageLeech", "DamageManaLeech", damageType.."DamageManaLeech", isElemental[damageType] and "ElementalDamageManaLeech" or nil) + enemyDB:Sum("BASE", cfg, "SelfDamageManaLeech") / 100
						
							if manaLeech > 0 then
								manaLeechTotal = manaLeechTotal + damageTypeHitAvg * manaLeech / 100
							end
						end
					end
				else
					min, max = 0, 0
					if breakdown then
						breakdown[damageType] = {
"你无法造成 "..damageType.." 伤害"
						}
					end
				end
				
				if pass == 1 then
					output[damageType.."CritAverage"] = damageTypeHitAvg
					totalCritAvg = totalCritAvg + damageTypeHitAvg
					totalCritMin = totalCritMin + min
					totalCritMax = totalCritMax + max
				else
					if env.mode == "CALCS" then
						output[damageType.."Min"] = min
						output[damageType.."Max"] = max
					end
					output[damageType.."HitAverage"] = damageTypeHitAvg
					totalHitAvg = totalHitAvg + damageTypeHitAvg					
					totalHitMin = totalHitMin + min
					totalHitMax = totalHitMax + max
				end
			end
			if skillData.lifeLeechPerUse then
				lifeLeechTotal = lifeLeechTotal + skillData.lifeLeechPerUse
			end
			if skillData.manaLeechPerUse then
				manaLeechTotal = manaLeechTotal + skillData.manaLeechPerUse
			end
			local portion = (pass == 1) and (output.CritChance / 100) or (1 - output.CritChance / 100)
			if skillModList:Flag(cfg, "InstantLifeLeech") and not ghostReaver then
				output.LifeLeechInstant = output.LifeLeechInstant + lifeLeechTotal * portion
			else
				output.LifeLeech = output.LifeLeech + lifeLeechTotal * portion
			end
			if skillModList:Flag(cfg, "InstantEnergyShieldLeech") then
				output.EnergyShieldLeechInstant = output.EnergyShieldLeechInstant + energyShieldLeechTotal * portion
			else
				output.EnergyShieldLeech = output.EnergyShieldLeech + energyShieldLeechTotal * portion
			end
			if skillModList:Flag(cfg, "InstantManaLeech") then
				output.ManaLeechInstant = output.ManaLeechInstant + manaLeechTotal * portion
			else
				output.ManaLeech = output.ManaLeech + manaLeechTotal * portion
			end
			
		end
		
		output.TotalMin = totalHitMin
		output.TotalMax = totalHitMax

		if skillModList:Flag(skillCfg, "ElementalEquilibrium") and not env.configInput.EEIgnoreHitDamage 
		and (output.FireHitAverage + output.ColdHitAverage + output.LightningHitAverage > 0) 
		and not skillFlags.minion
		then
		 
			-- Update enemy hit-by-damage-type conditions		
			--enemyDB.conditions.HitByFireDamage = output.FireHitAverage > 0
			--enemyDB.conditions.HitByColdDamage = output.ColdHitAverage > 0
			--enemyDB.conditions.HitByLightningDamage = output.LightningHitAverage > 0
			
			 
		end
		local highestType = "Physical"
		
		-- For each damage type, calculate percentage of total damage. Also tracks the highest damage type and outputs a Condition:TypeIsHighestDamageType flag for whichever the highest type is
		for _, damageType in ipairs(dmgTypeList) do
			if output[damageType.."HitAverage"] > 0 then
				local portion = output[damageType.."HitAverage"] / totalHitAvg * 100
				local highestPortion = output[highestType.."HitAverage"] / totalHitAvg * 100
				if portion > highestPortion then
					highestType = damageType
					highestPortion = portion
				end
				if breakdown then
					t_insert(breakdown[damageType], s_format("占总伤害的: %d%%", portion))
				end
			end
		end
		skillModList:NewMod("Condition:"..highestType.."IsHighestDamageType", "FLAG", true, "Config")
		

		local hitRate = output.HitChance / 100 * (globalOutput.HitSpeed or globalOutput.Speed) * (skillData.dpsMultiplier or 1)

		-- Calculate leech
		local function getLeechInstances(amount, total)
			if total == 0 then
				return 0, 0
			end
			local duration = amount / total / 0.02
			return duration, duration * hitRate
		end
		if ghostReaver then
			output.EnergyShieldLeech = output.EnergyShieldLeech + output.LifeLeech
			output.EnergyShieldLeechInstant = output.EnergyShieldLeechInstant + output.LifeLeechInstant
			output.LifeLeech = 0
			output.LifeLeechInstant = 0
		end
		output.LifeLeech = m_min(output.LifeLeech, globalOutput.MaxLifeLeechInstance)
		output.LifeLeechDuration, output.LifeLeechInstances = getLeechInstances(output.LifeLeech, globalOutput.Life)	
		output.LifeLeechInstantRate = output.LifeLeechInstant * hitRate
		output.EnergyShieldLeech = m_min(output.EnergyShieldLeech, globalOutput.MaxEnergyShieldLeechInstance)
		output.EnergyShieldLeechDuration, output.EnergyShieldLeechInstances = getLeechInstances(output.EnergyShieldLeech, globalOutput.EnergyShield)
		output.EnergyShieldLeechInstantRate = output.EnergyShieldLeechInstant * hitRate
		output.ManaLeech = m_min(output.ManaLeech, globalOutput.MaxManaLeechInstance)
		output.ManaLeechDuration, output.ManaLeechInstances = getLeechInstances(output.ManaLeech, globalOutput.Mana)
		output.ManaLeechInstantRate = output.ManaLeechInstant * hitRate

		-- Calculate gain on hit
		if skillFlags.mine or skillFlags.trap or skillFlags.totem then
			output.LifeOnHit = 0
			output.EnergyShieldOnHit = 0
			output.ManaOnHit = 0
		else
			output.LifeOnHit = (skillModList:Sum("BASE", cfg, "LifeOnHit") + enemyDB:Sum("BASE", cfg, "SelfLifeOnHit")) * globalOutput.LifeRecoveryMod
			output.EnergyShieldOnHit = (skillModList:Sum("BASE", cfg, "EnergyShieldOnHit") + enemyDB:Sum("BASE", cfg, "SelfEnergyShieldOnHit")) * globalOutput.EnergyShieldRecoveryMod
			output.ManaOnHit = (skillModList:Sum("BASE", cfg, "ManaOnHit") + enemyDB:Sum("BASE", cfg, "SelfManaOnHit")) * globalOutput.ManaRecoveryMod
		end
		output.LifeOnHitRate = output.LifeOnHit * hitRate
		output.EnergyShieldOnHitRate = output.EnergyShieldOnHit * hitRate
		output.ManaOnHitRate = output.ManaOnHit * hitRate


		
		-- Calculate average damage and final DPS		 
		output.AverageHit = totalHitAvg * (1 - output.CritChance / 100) + totalCritAvg * output.CritChance / 100
		output.AverageDamage = output.AverageHit * output.HitChance / 100
		
		
		
		output.TotalDPS = output.AverageDamage * (globalOutput.HitSpeed or globalOutput.Speed) * (skillData.dpsMultiplier or 1) * quantityMultiplier
		

		if breakdown then
			if output.CritEffect ~= 1 then
				
				breakdown.AverageHit = { }
				if skillModList:Flag(skillCfg, "LuckyHits") then
					t_insert(breakdown.AverageHit, s_format("(1/3) x %d + (2/3) x %d = %.1f ^8(来自非暴击的平均伤害)", totalHitMin, totalHitMax, totalHitAvg))
				end
				if skillModList:Flag(skillCfg, "CritLucky") or skillModList:Flag(skillCfg, "LuckyHits") then
					t_insert(breakdown.AverageHit, s_format("(1/3) x %d + (2/3) x %d = %.1f ^8(来自暴击的平均伤害)", totalCritMin, totalCritMax, totalCritAvg))
					t_insert(breakdown.AverageHit, "")
				end
				t_insert(breakdown.AverageHit, s_format("%.1f x (1 - %.4f) ^8(来自非暴击的伤害)", totalHitAvg, output.CritChance / 100))
				t_insert(breakdown.AverageHit, s_format("+ %.1f x %.4f ^8(来自暴击的伤害)", totalCritAvg, output.CritChance / 100))
				t_insert(breakdown.AverageHit, s_format("= %.1f", output.AverageHit))
				
				 
			end
			if isAttack then
				breakdown.AverageDamage = { }
				t_insert(breakdown.AverageDamage, s_format("%s:", pass.label))
t_insert(breakdown.AverageDamage, s_format("%.1f ^8(平均击中)", output.AverageHit))
t_insert(breakdown.AverageDamage, s_format("x %.2f ^8(击中几率)", output.HitChance / 100))
				t_insert(breakdown.AverageDamage, s_format("= %.1f", output.AverageDamage))
			end
		end
	end

	if isAttack then
		-- Combine crit stats, average damage and DPS
		combineStat("PreEffectiveCritChance", "AVERAGE")
		combineStat("CritChance", "AVERAGE")
		combineStat("CritMultiplier", "AVERAGE")
		combineStat("AverageDamage", "DPS")
		combineStat("TotalDPS", "DPS")
		combineStat("LifeLeechDuration", "DPS")
		combineStat("LifeLeechInstances", "DPS")
		combineStat("LifeLeechInstant", "DPS")
		combineStat("LifeLeechInstantRate", "DPS")
		combineStat("EnergyShieldLeechDuration", "DPS")
		combineStat("EnergyShieldLeechInstances", "DPS")
		combineStat("EnergyShieldLeechInstant", "DPS")
		combineStat("EnergyShieldLeechInstantRate", "DPS")
		combineStat("ManaLeechDuration", "DPS")
		combineStat("ManaLeechInstances", "DPS")
		combineStat("ManaLeechInstant", "DPS")
		combineStat("ManaLeechInstantRate", "DPS")
		combineStat("LifeOnHit", "DPS")
		combineStat("LifeOnHitRate", "DPS")
		combineStat("EnergyShieldOnHit", "DPS")
		combineStat("EnergyShieldOnHitRate", "DPS")
		combineStat("ManaOnHit", "DPS")
		combineStat("ManaOnHitRate", "DPS")
		if skillFlags.bothWeaponAttack then
			if breakdown then
				breakdown.AverageDamage = { }
				t_insert(breakdown.AverageDamage, "所有武器:")
				if skillData.doubleHitsWhenDualWielding then
t_insert(breakdown.AverageDamage, s_format("%.1f + %.1f ^8(技能使用2把武器同时击中)", output.MainHand.AverageDamage, output.OffHand.AverageDamage))
				else
t_insert(breakdown.AverageDamage, s_format("(%.1f + %.1f) / 2 ^8(技能交替使用2把武器)", output.MainHand.AverageDamage, output.OffHand.AverageDamage))
				end
				t_insert(breakdown.AverageDamage, s_format("= %.1f", output.AverageDamage))
			end
		end
	end
	if env.mode == "CALCS"  then
		if skillData.showAverage then
			output.DisplayDamage = formatNumSep(s_format("%.1f", output.AverageDamage)) .. " 平均伤害"
		else
			output.DisplayDamage = formatNumSep(s_format("%.1f", output.TotalDPS)) .. " DPS"
		end
	end
	
		
	if breakdown then
		if isAttack then
			breakdown.TotalDPS = {
s_format("%.1f ^8(平均伤害)", output.AverageDamage),
output.HitSpeed and s_format("x %.2f ^8(击中速率)", output.HitSpeed) or s_format("x %.2f ^8(攻击速度)", output.Speed),
			}
		elseif isTriggered then
			breakdown.TotalDPS = {
				s_format("%.1f ^8(平均伤害)", output.AverageDamage),
				output.HitSpeed and s_format("x %.2f ^8(击中速率)", output.HitSpeed) or s_format("x %.2f ^8(触发速率)", output.Speed),
			}
		else
			breakdown.TotalDPS = {
s_format("%.1f ^8(平均伤害)", output.AverageDamage),
output.HitSpeed and s_format("x %.2f ^8(击中速率)", output.HitSpeed) or s_format("x %.2f ^8(施法速度)", output.Speed),
			}
		end
		if skillData.dpsMultiplier then
	
t_insert(breakdown.TotalDPS, s_format("x %g ^8(技能 DPS 加成)", skillData.dpsMultiplier))
		end
		if quantityMultiplier > 1 then
			t_insert(breakdown.TotalDPS, s_format("x %g ^8(这个技能的数量加成)", quantityMultiplier))
		end
		t_insert(breakdown.TotalDPS, s_format("= %.1f", output.TotalDPS))
	end

	-- Calculate leech rates	
	output.LifeLeechInstanceRate = output.Life * 0.02 * calcLib.mod(skillModList, skillCfg, "LifeLeechRate")
	output.LifeLeechRate = output.LifeLeechInstantRate * output.LifeRecoveryMod + m_min(output.LifeLeechInstances * output.LifeLeechInstanceRate, output.MaxLifeLeechRate) * output.LifeRecoveryRateMod
	output.LifeLeechPerHit = output.LifeLeechInstant * output.LifeRecoveryMod + m_min(output.LifeLeechInstanceRate, output.MaxLifeLeechRate) * output.LifeLeechDuration * output.LifeRecoveryRateMod
	output.EnergyShieldLeechInstanceRate = output.EnergyShield * 0.02 * calcLib.mod(skillModList, skillCfg, "EnergyShieldLeechRate")
	output.EnergyShieldLeechRate = output.EnergyShieldLeechInstantRate * output.EnergyShieldRecoveryMod + m_min(output.EnergyShieldLeechInstances * output.EnergyShieldLeechInstanceRate, output.MaxEnergyShieldLeechRate) * output.EnergyShieldRecoveryRateMod
	output.EnergyShieldLeechPerHit = output.EnergyShieldLeechInstant * output.EnergyShieldRecoveryMod + m_min(output.EnergyShieldLeechInstanceRate, output.MaxEnergyShieldLeechRate) * output.EnergyShieldLeechDuration * output.EnergyShieldRecoveryRateMod
	output.ManaLeechInstanceRate = output.Mana * 0.02 * calcLib.mod(skillModList, skillCfg, "ManaLeechRate")
	output.ManaLeechRate = output.ManaLeechInstantRate * output.ManaRecoveryMod + m_min(output.ManaLeechInstances * output.ManaLeechInstanceRate, output.MaxManaLeechRate) * output.ManaRecoveryRateMod
	output.ManaLeechPerHit = output.ManaLeechInstant * output.ManaRecoveryMod  + m_min(output.ManaLeechInstanceRate, output.MaxManaLeechRate) * output.ManaLeechDuration * output.ManaRecoveryRateMod	 
	-- On full life, Immortal Ambition treats life leech as energy shield leech
	if skillModList:Flag(nil, "ImmortalAmbition") then
		output.EnergyShieldLeechRate = output.EnergyShieldLeechRate + output.LifeLeechRate
		output.EnergyShieldLeechPerHit = output.EnergyShieldLeechPerHit  + output.LifeLeechPerHit
		-- Clears output.LifeLeechRate to disable leechLife flag
		output.LifeLeechRate = 0
	end
	skillFlags.leechLife = output.LifeLeechRate > 0
	skillFlags.leechES = output.EnergyShieldLeechRate > 0
	skillFlags.leechMana = output.ManaLeechRate > 0
	if skillData.showAverage then
		output.LifeLeechGainPerHit = output.LifeLeechPerHit + output.LifeOnHit
		output.EnergyShieldLeechGainPerHit = output.EnergyShieldLeechPerHit + output.EnergyShieldOnHit
		output.ManaLeechGainPerHit = output.ManaLeechPerHit + output.ManaOnHit
	else
		output.LifeLeechGainRate = output.LifeLeechRate + output.LifeOnHitRate
		output.EnergyShieldLeechGainRate = output.EnergyShieldLeechRate + output.EnergyShieldOnHitRate
		output.ManaLeechGainRate = output.ManaLeechRate + output.ManaOnHitRate
	end
	if breakdown then
		if skillFlags.leechLife then
			breakdown.LifeLeech = breakdown.leech(output.LifeLeechInstant, output.LifeLeechInstantRate, output.LifeLeechInstances, output.Life, "LifeLeechRate", output.MaxLifeLeechRate, output.LifeLeechDuration)
		end
		if skillFlags.leechES then
			breakdown.EnergyShieldLeech = breakdown.leech(output.EnergyShieldLeechInstant, output.EnergyShieldLeechInstantRate, output.EnergyShieldLeechInstances, output.EnergyShield, "EnergyShieldLeechRate", output.MaxEnergyShieldLeechRate, output.EnergyShieldLeechDuration)
		end
		if skillFlags.leechMana then
			breakdown.ManaLeech = breakdown.leech(output.ManaLeechInstant, output.ManaLeechInstantRate, output.ManaLeechInstances, output.Mana, "ManaLeechRate", output.MaxManaLeechRate, output.ManaLeechDuration)
		end
	end

	

	skillFlags.bleed = false
	skillFlags.poison = false
	skillFlags.ignite = false
	skillFlags.igniteCanStack = skillModList:Flag(skillCfg, "IgniteCanStack")
	skillFlags.igniteToChaos = skillModList:Flag(skillCfg, "IgniteToChaos")
	skillFlags.shock = false
	skillFlags.freeze = false
	skillFlags.impale = false
	skillFlags.chill = false
	skillFlags.scorch = false
	skillFlags.brittle = false
	skillFlags.sap = false
	for _, pass in ipairs(passList) do
		local globalOutput, globalBreakdown = output, breakdown
		local source, output, cfg, breakdown = pass.source, pass.output, pass.cfg, pass.breakdown

		-- Calculate chance to inflict secondary dots/status effects
		cfg.skillCond["CriticalStrike"] = true
		if not skillFlags.attack or skillModList:Flag(cfg, "CannotBleed") then
			output.BleedChanceOnCrit = 0
		else
			output.BleedChanceOnCrit = m_min(100, skillModList:Sum("BASE", cfg, "BleedChance") + enemyDB:Sum("BASE", nil, "SelfBleedChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotPoison") then
			output.PoisonChanceOnCrit = 0
		else
			output.PoisonChanceOnCrit = m_min(100, skillModList:Sum("BASE", cfg, "PoisonChance") + enemyDB:Sum("BASE", nil, "SelfPoisonChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotIgnite") then
			output.IgniteChanceOnCrit = 0
		else
			output.IgniteChanceOnCrit = 100
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotShock") then
			output.ShockChanceOnCrit = 0
		else
			output.ShockChanceOnCrit = 100
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotFreeze") then
			output.FreezeChanceOnCrit = 0
		else
			output.FreezeChanceOnCrit = 100
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotChill") then
			output.ChillChanceOnCrit = 0
		else
			output.ChillChanceOnCrit = 100
		end
		if skillModList:Flag(cfg, "CritAlwaysAltAilments") and not skillModList:Flag(cfg, "NeverCrit") then
			skillFlags.inflictScorch = true
			skillFlags.inflictBrittle = true
			skillFlags.inflictSap = true
		end
		if skillModList:Flag(cfg, "CritAlwaysAltAilments") and not skillModList:Flag(cfg, "NeverCrit") and skillFlags.hit then
			output.ScorchChanceOnCrit = not skillModList:Flag(cfg, "CannotScorch") and 100 or 0
			output.BrittleChanceOnCrit = not skillModList:Flag(cfg, "CannotBrittle") and 100 or 0
			output.SapChanceOnCrit = not skillModList:Flag(cfg, "CannotSap") and 100 or 0
		else
			output.ScorchChanceOnCrit = 0
			output.BrittleChanceOnCrit = 0
			output.SapChanceOnCrit = 0
		end
		
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotKnockback") then
			output.KnockbackChanceOnCrit = 0
		else
			output.KnockbackChanceOnCrit = skillModList:Sum("BASE", cfg, "EnemyKnockbackChance")
		end
		if skillModList:Sum("BASE", cfg, "ScorchChance") > 0 then
			skillFlags.inflictScorch = true
		end
		if skillModList:Sum("BASE", cfg, "ScorchChance") > 0 and skillFlags.hit then
			output.ScorchChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "ScorchChance"))
		else
			output.ScorchChanceOnHit = 0
		end
		if skillModList:Sum("BASE", cfg, "BrittleChance") > 0 then
			skillFlags.inflictBrittle = true
		end
		if skillModList:Sum("BASE", cfg, "BrittleChance") > 0 and skillFlags.hit then
			output.BrittleChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "BrittleChance"))
		else
			output.BrittleChanceOnHit = 0
		end
		if skillModList:Sum("BASE", cfg, "SapChance") > 0 then
			skillFlags.inflictSap = true
		end
		if skillModList:Sum("BASE", cfg, "SapChance") > 0 and skillFlags.hit then
			output.SapChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "SapChance"))
		else
			output.SapChanceOnHit = 0
		end
		
		cfg.skillCond["CriticalStrike"] = false
		if not skillFlags.attack or skillModList:Flag(cfg, "CannotBleed") then
			output.BleedChanceOnHit = 0
		else
			output.BleedChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "BleedChance") + enemyDB:Sum("BASE", nil, "SelfBleedChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotPoison") then
			output.PoisonChanceOnHit = 0
			output.ChaosPoisonChance = 0
		else
			output.PoisonChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "PoisonChance") + enemyDB:Sum("BASE", nil, "SelfPoisonChance"))
			output.ChaosPoisonChance = m_min(100, skillModList:Sum("BASE", cfg, "ChaosPoisonChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotIgnite") then
			output.IgniteChanceOnHit = 0
		else
			output.IgniteChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "EnemyIgniteChance") + enemyDB:Sum("BASE", nil, "SelfIgniteChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotShock") then
			output.ShockChanceOnHit = 0
		else
			output.ShockChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "EnemyShockChance") + enemyDB:Sum("BASE", nil, "SelfShockChance"))
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotFreeze") then
			output.FreezeChanceOnHit = 0
		else
			output.FreezeChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "EnemyFreezeChance") + enemyDB:Sum("BASE", nil, "SelfFreezeChance"))
			if skillModList:Flag(cfg, "CritsDontAlwaysFreeze") then
				output.FreezeChanceOnCrit = output.FreezeChanceOnHit
			end
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotChill") then
			output.ChillChanceOnHit = 0
		else
			output.ChillChanceOnHit = 100
		end
		if not skillFlags.hit or skillModList:Flag(cfg, "CannotKnockback") then
			output.KnockbackChanceOnHit = 0
		else
			output.KnockbackChanceOnHit = skillModList:Sum("BASE", cfg, "EnemyKnockbackChance")
		end
		if skillModList:Sum("BASE", cfg, "ScorchChance") > 0 then
			skillFlags.inflictScorch = true
		end
		if skillModList:Sum("BASE", cfg, "ScorchChance") > 0 and skillFlags.hit then
			output.ScorchChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "ScorchChance"))
		else
			output.ScorchChanceOnHit = 0
		end
		if skillModList:Sum("BASE", cfg, "BrittleChance") > 0 then
			skillFlags.inflictBrittle = true
		end
		if skillModList:Sum("BASE", cfg, "BrittleChance") > 0 and skillFlags.hit then
			output.BrittleChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "BrittleChance"))
		else
			output.BrittleChanceOnHit = 0
		end
		if skillModList:Sum("BASE", cfg, "SapChance") > 0 then
			skillFlags.inflictSap = true
		end
		if skillModList:Sum("BASE", cfg, "SapChance") > 0 and skillFlags.hit then
			output.SapChanceOnHit = m_min(100, skillModList:Sum("BASE", cfg, "SapChance"))
		else
			output.SapChanceOnHit = 0
		end
		output.ImpaleChance = m_min(100, skillModList:Sum("BASE", cfg, "ImpaleChance"))
		if skillModList:Sum("BASE", cfg, "FireExposureChance") > 0 then
			skillFlags.applyFireExposure = true
		end
		if skillModList:Sum("BASE", cfg, "ColdExposureChance") > 0 then
			skillFlags.applyColdExposure = true
		end
		if skillModList:Sum("BASE", cfg, "LightningExposureChance") > 0 then
			skillFlags.applyLightningExposure = true
		end
		if env.mode_effective then
			local bleedMult = (1 - enemyDB:Sum("BASE", nil, "AvoidBleed") / 100)
			output.BleedChanceOnHit = output.BleedChanceOnHit * bleedMult
			output.BleedChanceOnCrit = output.BleedChanceOnCrit * bleedMult
			local poisonMult = (1 - enemyDB:Sum("BASE", nil, "AvoidPoison") / 100)
			output.PoisonChanceOnHit = output.PoisonChanceOnHit * poisonMult
			output.PoisonChanceOnCrit = output.PoisonChanceOnCrit * poisonMult
			output.ChaosPoisonChance = output.ChaosPoisonChance * poisonMult
			local igniteMult = (1 - enemyDB:Sum("BASE", nil, "AvoidIgnite") / 100)
			output.IgniteChanceOnHit = output.IgniteChanceOnHit * igniteMult
			output.IgniteChanceOnCrit = output.IgniteChanceOnCrit * igniteMult
			local shockMult = (1 - enemyDB:Sum("BASE", nil, "AvoidShock") / 100)
			output.ShockChanceOnHit = output.ShockChanceOnHit * shockMult
			output.ShockChanceOnCrit = output.ShockChanceOnCrit * shockMult
			local freezeMult = (1 - enemyDB:Sum("BASE", nil, "AvoidFreeze") / 100)
			output.FreezeChanceOnHit = output.FreezeChanceOnHit * freezeMult
			output.FreezeChanceOnCrit = output.FreezeChanceOnCrit * freezeMult
			local scorchMult = (1 - enemyDB:Sum("BASE", nil, "AvoidScorch") / 100)
			output.ScorchChanceOnHit = output.ScorchChanceOnHit * scorchMult
			output.ScorchChanceOnCrit = output.ScorchChanceOnCrit * scorchMult
			local brittleMult = (1 - enemyDB:Sum("BASE", nil, "AvoidBrittle") / 100)
			output.BrittleChanceOnHit = output.BrittleChanceOnHit * brittleMult
			output.BrittleChanceOnCrit = output.BrittleChanceOnCrit * brittleMult
			local sapMult = (1 - enemyDB:Sum("BASE", nil, "AvoidSap") / 100)
			output.SapChanceOnHit = output.SapChanceOnHit * sapMult
			output.SapChanceOnCrit = output.SapChanceOnCrit * sapMult
		end
	
		local function calcAilmentDamage(type, sourceHitDmg, sourceCritDmg)
			-- Calculate the inflict chance and base damage of a secondary effect (bleed/poison/ignite/shock/freeze)
			local chanceOnHit, chanceOnCrit = output[type.."ChanceOnHit"], output[type.."ChanceOnCrit"]
			local chanceFromHit = chanceOnHit * (1 - output.CritChance / 100)
			local chanceFromCrit = chanceOnCrit * output.CritChance / 100
			local chance = chanceFromHit + chanceFromCrit
			output[type.."Chance"] = chance
			local baseFromHit = sourceHitDmg * chanceFromHit / (chanceFromHit + chanceFromCrit)
			local baseFromCrit = sourceCritDmg * chanceFromCrit / (chanceFromHit + chanceFromCrit)
			local baseVal = baseFromHit + baseFromCrit
			local sourceMult = skillModList:More(nil, type.."AsThoughDealing")
			if breakdown and chance ~= 0 then
				local breakdownChance = breakdown[type.."Chance"] or { }
				breakdown[type.."Chance"] = breakdownChance
				if breakdownChance[1] then
					t_insert(breakdownChance, "")
				end
				if isAttack then
					t_insert(breakdownChance, pass.label..":")
				end
t_insert(breakdownChance, s_format("非暴击时的几率: %d%%", chanceOnHit))
t_insert(breakdownChance, s_format("暴击时的几率: %d%%", chanceOnCrit))
				if chanceOnHit ~= chanceOnCrit then
t_insert(breakdownChance, "预期几率:")
t_insert(breakdownChance, s_format("%d x (1 - %.4f) ^8(非暴击时的几率)", chanceOnHit, output.CritChance/100))
t_insert(breakdownChance, s_format("+ %d x %.4f ^8(暴击时的几率)", chanceOnCrit, output.CritChance/100))
					t_insert(breakdownChance, s_format("= %.2f", chance))
				end
			end
			if breakdown and baseVal > 0 then
				local breakdownDPS = breakdown[type.."DPS"] or { }
				breakdown[type.."DPS"] = breakdownDPS
				if breakdownDPS[1] then
					t_insert(breakdownDPS, "")
				end
				if isAttack then
					t_insert(breakdownDPS, pass.label..":")
				end
				if sourceHitDmg == sourceCritDmg then
t_insert(breakdownDPS, "总伤害:")
t_insert(breakdownDPS, s_format("%.1f ^8(来源伤害)",sourceHitDmg))
					if sourceMult > 1 then
						t_insert(breakdownDPS, s_format("x %.2f ^8(视为更多伤害来计算)", sourceMult))
						t_insert(breakdownDPS, s_format("= %.1f", baseVal * sourceMult))
					end
				else
					if baseFromHit > 0 then
t_insert(breakdownDPS, "非暴击时的伤害:")
t_insert(breakdownDPS, s_format("%.1f ^8(非暴击时的来源伤害)", sourceHitDmg))
t_insert(breakdownDPS, s_format("x %.3f ^8(不暴击的几率·非暴击的实例)", chanceFromHit / (chanceFromHit + chanceFromCrit)))
						t_insert(breakdownDPS, s_format("= %.1f", baseFromHit))
						if sourceMult == 1 or baseFromCrit ~= 0 then
							t_insert(breakdownDPS, s_format("= %.1f", baseFromHit))
						end
					end
					if baseFromCrit > 0 then
t_insert(breakdownDPS, "暴击的伤害:")
	t_insert(breakdownDPS, s_format("%.1f ^8(暴击时的来源伤害)", sourceCritDmg))
t_insert(breakdownDPS, s_format("x %.3f ^8(暴击率·暴击时的实例)", chanceFromCrit / (chanceFromHit + chanceFromCrit)))
						t_insert(breakdownDPS, s_format("= %.1f", baseFromCrit))
					end
					if baseFromHit > 0 and baseFromCrit > 0 then
t_insert(breakdownDPS, "总伤害:")
						t_insert(breakdownDPS, s_format("%.1f + %.1f", baseFromHit, baseFromCrit))
						t_insert(breakdownDPS, s_format("= %.1f", baseVal))
					end
				end
			end
			return baseVal
		end

		
		local function calcAilmentDamage(type, sourceHitDmg, sourceCritDmg)
			-- Calculate the inflict chance and base damage of a secondary effect (bleed/poison/ignite/shock/freeze)
			local chanceOnHit, chanceOnCrit = output[type.."ChanceOnHit"], output[type.."ChanceOnCrit"]
			local chanceFromHit = chanceOnHit * (1 - output.CritChance / 100)
			local chanceFromCrit = chanceOnCrit * output.CritChance / 100
			local chance = chanceFromHit + chanceFromCrit
			output[type.."Chance"] = chance
			local baseFromHit = sourceHitDmg * chanceFromHit / (chanceFromHit + chanceFromCrit)
			local baseFromCrit = sourceCritDmg * chanceFromCrit / (chanceFromHit + chanceFromCrit)
			local baseVal = baseFromHit + baseFromCrit
			local sourceMult = skillModList:More(nil, type.."AsThoughDealing")
			if breakdown and chance ~= 0 then
				local breakdownChance = breakdown[type.."Chance"] or { }
				breakdown[type.."Chance"] = breakdownChance
				if breakdownChance[1] then
					t_insert(breakdownChance, "")
				end
				if isAttack then
					t_insert(breakdownChance, pass.label..":")
				end
				t_insert(breakdownChance, s_format("非暴击时的几率: %d%%", chanceOnHit))
				t_insert(breakdownChance, s_format("暴击时的几率: %d%%", chanceOnCrit))
				if chanceOnHit ~= chanceOnCrit then
					t_insert(breakdownChance, "综合几率:")
					t_insert(breakdownChance, s_format("%d x (1 - %.4f) ^8(非暴击时的几率)", chanceOnHit, output.CritChance/100))
					t_insert(breakdownChance, s_format("+ %d x %.4f ^8(暴击时的几率)", chanceOnCrit, output.CritChance/100))
					t_insert(breakdownChance, s_format("= %.2f", chance))
				end
			end
			if breakdown and baseVal > 0 then
				local breakdownDPS = breakdown[type.."DPS"] or { }
				breakdown[type.."DPS"] = breakdownDPS
				if breakdownDPS[1] then
					t_insert(breakdownDPS, "")
				end
				if isAttack then
					t_insert(breakdownDPS, pass.label..":")
				end
				if sourceHitDmg == sourceCritDmg then
					t_insert(breakdownDPS, "总伤害:")
					t_insert(breakdownDPS, s_format("%.1f ^8(源伤害)",sourceHitDmg))
					if sourceMult > 1 then
						t_insert(breakdownDPS, s_format("x %.2f ^8(视为更多伤害来计算异常)", sourceMult))
						t_insert(breakdownDPS, s_format("= %.1f", baseVal * sourceMult))
					end
				else
					if baseFromHit > 0 then
						t_insert(breakdownDPS, "非暴击时的伤害:")
						t_insert(breakdownDPS, s_format("%.1f ^8(非暴击时的源伤害)", sourceHitDmg))
						t_insert(breakdownDPS, s_format("x %.3f ^8(非暴击创建的实例)", chanceFromHit / (chanceFromHit + chanceFromCrit)))
						if sourceMult == 1 or baseFromCrit ~= 0 then
							t_insert(breakdownDPS, s_format("= %.1f", baseFromHit))
						end
					end
					if baseFromCrit > 0 then
						t_insert(breakdownDPS, "暴击时的伤害:")
						t_insert(breakdownDPS, s_format("%.1f ^8(暴击时的源伤害)", sourceCritDmg))
						t_insert(breakdownDPS, s_format("x %.3f ^8(暴击创建的实例)", chanceFromCrit / (chanceFromHit + chanceFromCrit)))
						if sourceMult == 1 or baseFromHit ~= 0 then
							t_insert(breakdownDPS, s_format("= %.1f", baseFromCrit))
						end
					end
					if baseFromHit > 0 and baseFromCrit > 0 then
						t_insert(breakdownDPS, "总伤害:")
						t_insert(breakdownDPS, s_format("%.1f + %.1f", baseFromHit, baseFromCrit))
						if sourceMult == 1 then
							t_insert(breakdownDPS, s_format("= %.1f", baseVal))
						end
					end
					if sourceMult > 1 then
						t_insert(breakdownDPS, s_format("x %.2f ^8(视为更多伤害来计算异常)", sourceMult))
						t_insert(breakdownDPS, s_format("= %.1f", baseVal * sourceMult))
					end
				end
			end
			return baseVal
		end


		-- Calculate bleeding chance and damage
		if canDeal.Physical and (output.BleedChanceOnHit + output.BleedChanceOnCrit) > 0 then
			if not activeSkill.bleedCfg then
				activeSkill.bleedCfg = {
					skillName = skillCfg.skillName,
					skillPart = skillCfg.skillPart,
					skillTypes = skillCfg.skillTypes,
					slotName = skillCfg.slotName,
					flags = bor(ModFlag.Dot, ModFlag.Ailment, band(cfg.flags, ModFlag.WeaponMask), band(cfg.flags, ModFlag.Melee) ~= 0 and ModFlag.MeleeHit or 0),
					keywordFlags = bor(band(cfg.keywordFlags, bnot(KeywordFlag.Hit)), KeywordFlag.Bleed, KeywordFlag.Ailment, KeywordFlag.PhysicalDot),
					skillCond = setmetatable({["CriticalStrike"] = true }, { __index = skillCfg.skillCond } ),
				}
			end
			local dotCfg = activeSkill.bleedCfg
			local sourceHitDmg, sourceCritDmg
			if breakdown then
				breakdown.BleedPhysical = { damageTypes = { } }
			end
			for pass = 1, 2 do
				if skillModList:Flag(dotCfg, "AilmentsAreNeverFromCrit") or pass == 1 then
					dotCfg.skillCond["CriticalStrike"] = false
				else
					dotCfg.skillCond["CriticalStrike"] = true
				end
				local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.BleedPhysical, "Physical", 0)				
				output.BleedPhysicalMin = min
				output.BleedPhysicalMax = max
				if pass == 2 then
					globalOutput.CritBleedDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "PhysicalDotMultiplier") / 100
					sourceCritDmg = (min + max) / 2 * globalOutput.CritBleedDotMulti
				else
					globalOutput.BleedDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "PhysicalDotMultiplier") / 100
					sourceHitDmg = (min + max) / 2 * globalOutput.BleedDotMulti
				end
				
			end
			
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.BleedChanceOnHit = 0
			end
			if globalBreakdown then
				globalBreakdown.BleedDPS = {
					s_format("异常计算模式: %s ^8(在配置界面配置)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			local basePercent = skillData.bleedBasePercent or data.misc.BleedPercentBase
			local baseVal = calcAilmentDamage("Bleed", sourceHitDmg, sourceCritDmg) * basePercent / 100 * output.RuthlessBlowEffect * output.FistOfWarAilmentEffect * globalOutput.AilmentWarcryEffect
			if baseVal > 0 then
				skillFlags.bleed = true
				skillFlags.duration = true
				local effMult = 1
				if env.mode_effective then
					local resist = m_max(0, enemyDB:Sum("BASE", nil, "PhysicalDamageReduction"))
					local takenInc = enemyDB:Sum("INC", dotCfg, "DamageTaken", "DamageTakenOverTime", "PhysicalDamageTaken", "PhysicalDamageTakenOverTime")
					local takenMore = enemyDB:More(dotCfg, "DamageTaken", "DamageTakenOverTime", "PhysicalDamageTaken", "PhysicalDamageTakenOverTime")
					effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
					globalOutput["BleedEffMult"] = effMult
					if breakdown and effMult ~= 1 then
						globalBreakdown.BleedEffMult = breakdown.effMult("Physical", resist, 0, takenInc, effMult, takenMore)
					end
				end
				
				local mult = skillModList:Sum("BASE", dotCfg, "DotMultiplier", "PhysicalDotMultiplier", "BleedMultiplier")
				local effectMod = calcLib.mod(skillModList, dotCfg, "AilmentEffect")				
				local rateMod = calcLib.mod(skillModList, cfg, "BleedFaster") + enemyDB:Sum("INC", nil, "SelfBleedFaster")  / 100
				local maxStacks = skillModList:Override(cfg, "BleedStacksMax") or skillModList:Sum("BASE", cfg, "BleedStacksMax")
				local configStacks = enemyDB:Sum("BASE", nil, "Multiplier:BleedStacks")
				local bleedStacks = configStacks > 0 and m_min(configStacks, maxStacks) or maxStacks
				output.BaseBleedDPS = baseVal * effectMod * rateMod * effMult
				output.BleedDPS = (baseVal * effectMod * rateMod * effMult) * bleedStacks
				local durationBase
				if skillData.bleedDurationIsSkillDuration then
					durationBase = skillData.duration
				else
					durationBase = data.misc.BleedDurationBase
				end
				local durationMod = calcLib.mod(skillModList, dotCfg, "EnemyBleedDuration", "SkillAndDamagingAilmentDuration", skillData.bleedIsSkillEffect and "Duration" or nil) * calcLib.mod(enemyDB, nil, "SelfBleedDuration")
				globalOutput.BleedDuration = durationBase * durationMod / rateMod * debuffDurationMult
				globalOutput.BleedDamage = output.BaseBleedDPS * globalOutput.BleedDuration
				globalOutput.BleedStacksMax = maxStacks
				globalOutput.BleedStacks = bleedStacks
				if breakdown then
					if globalOutput.CritBleedDotMulti and (globalOutput.CritBleedDotMulti ~= globalOutput.BleedDotMulti) then
						local chanceFromHit = output.BleedChanceOnHit / 100 * (1 - globalOutput.CritChance / 100)
						local chanceFromCrit = output.BleedChanceOnCrit / 100 * output.CritChance / 100
						local totalFromHit = chanceFromHit / (chanceFromHit + chanceFromCrit)
						local totalFromCrit = chanceFromCrit / (chanceFromHit + chanceFromCrit)
						globalBreakdown.BleedDotMulti = breakdown.critDot(globalOutput.BleedDotMulti, globalOutput.CritBleedDotMulti, totalFromHit, totalFromCrit)
						globalOutput.BleedDotMulti = (globalOutput.BleedDotMulti * totalFromHit) + (globalOutput.CritBleedDotMulti * totalFromCrit)
					end
					t_insert(breakdown.BleedDPS, s_format("x %.2f ^8(流血每秒造成基础伤害的 %d%%)", basePercent/100, basePercent))
					if effectMod ~= 1 then
						t_insert(breakdown.BleedDPS, s_format("x %.2f ^8(异常效果加成)", effectMod))
					end
					if output.RuthlessBlowEffect ~= 1 then
						t_insert(breakdown.BleedDPS, s_format("x %.2f ^8(【无情一击】加成)", output.RuthlessBlowEffect))
					end
					if output.FistOfWarAilmentEffect ~= 1 then
						t_insert(breakdown.BleedDPS, s_format("x %.2f ^8(【战争铁拳】加成)", output.FistOfWarAilmentEffect))
					end
					if globalOutput.AilmentWarcryEffect > 1 then
						t_insert(breakdown.BleedDPS, s_format("x %.2f ^8(combined ailment warcry effect modifier)", globalOutput.AilmentWarcryEffect))
					end
					
					
					t_insert(breakdown.BleedDPS, s_format("= %.1f", baseVal))
					breakdown.multiChain(breakdown.BleedDPS, {
						label = "流血 DPS:",
						base = s_format("%.1f ^8(每秒总伤害)", baseVal), 
						{ "%.2f ^8(异常效果加成)", effectMod },
						{ "%.2f ^8(速率加成)", rateMod },
						{ "%.3f ^8(有效DPS加成)", effMult },
						total = s_format("= %.1f ^8 每秒", output.BleedDPS),
					})
					if globalOutput.BleedDuration ~= durationBase then
						globalBreakdown.BleedDuration = {
							s_format("%.2fs ^8(基础持续时间)", durationBase)
						}
						if durationMod ~= 1 then
							t_insert(globalBreakdown.BleedDuration, s_format("x %.2f ^8(持续时间加成)", durationMod))
						end
						if rateMod ~= 1 then
							t_insert(globalBreakdown.BleedDuration, s_format("/ %.2f ^8(伤害速率加成)", rateMod))
						end
						if debuffDurationMult ~= 1 then
							t_insert(globalBreakdown.BleedDuration, s_format("/ %.2f ^8(减益消退速度加快或减慢)", 1 / debuffDurationMult))
						end
						t_insert(globalBreakdown.BleedDuration, s_format("= %.2f秒", globalOutput.BleedDuration))
					end
				end
			end
		end

		-- Calculate poison chance and damage
		if canDeal.Chaos and (output.PoisonChanceOnHit + output.PoisonChanceOnCrit + output.ChaosPoisonChance) > 0 then
			if not activeSkill.poisonCfg then
				activeSkill.poisonCfg = {
					skillName = skillCfg.skillName,
					skillPart = skillCfg.skillPart,
					skillTypes = skillCfg.skillTypes,
					slotName = skillCfg.slotName,
					flags = bor(ModFlag.Dot, ModFlag.Ailment, band(cfg.flags, ModFlag.WeaponMask), band(cfg.flags, ModFlag.Melee) ~= 0 and ModFlag.MeleeHit or 0),
					keywordFlags = bor(band(cfg.keywordFlags, bnot(KeywordFlag.Hit)), KeywordFlag.Poison, KeywordFlag.Ailment, KeywordFlag.ChaosDot),
					skillCond = setmetatable({["CriticalStrike"] = true }, { __index = skillCfg.skillCond } ),
				}
			end
			local dotCfg = activeSkill.poisonCfg
			local sourceHitDmg, sourceCritDmg
			if breakdown then
				breakdown.PoisonPhysical = { damageTypes = { } }
				breakdown.PoisonLightning = { damageTypes = { } }
				breakdown.PoisonCold = { damageTypes = { } }
				breakdown.PoisonFire = { damageTypes = { } }
				breakdown.PoisonChaos = { damageTypes = { } }
			end
			for pass = 1, 2 do
				if skillModList:Flag(dotCfg, "AilmentsAreNeverFromCrit") or pass == 1 then
					dotCfg.skillCond["CriticalStrike"] = false
				else
					dotCfg.skillCond["CriticalStrike"] = true
				end
				local totalMin, totalMax = 0, 0
				do
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.PoisonChaos, "Chaos", 0)
					output.PoisonChaosMin = min
					output.PoisonChaosMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				local nonChaosMult = 1
				if output.ChaosPoisonChance > 0 and output.PoisonChaosMax > 0 then
					-- Additional chance for chaos
					local chance = (pass == 2) and "PoisonChanceOnCrit" or "PoisonChanceOnHit"
					local chaosChance = m_min(100, output[chance] + output.ChaosPoisonChance)
					nonChaosMult = output[chance] / chaosChance
					output[chance] = chaosChance
				end
				if canDeal.Lightning and skillModList:Flag(cfg, "LightningCanPoison") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.PoisonLightning, "Lightning", dmgTypeFlags.Chaos)
					output.PoisonLightningMin = min
					output.PoisonLightningMax = max
					totalMin = totalMin + min * nonChaosMult
					totalMax = totalMax + max * nonChaosMult
				end
				if canDeal.Cold and skillModList:Flag(cfg, "ColdCanPoison") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.PoisonCold, "Cold", dmgTypeFlags.Chaos)
					output.PoisonColdMin = min
					output.PoisonColdMax = max
					totalMin = totalMin + min * nonChaosMult
					totalMax = totalMax + max * nonChaosMult
				end
				if canDeal.Fire and skillModList:Flag(cfg, "FireCanPoison") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.PoisonFire, "Fire", dmgTypeFlags.Chaos)
					output.PoisonFireMin = min
					output.PoisonFireMax = max
					totalMin = totalMin + min * nonChaosMult
					totalMax = totalMax + max * nonChaosMult
				end
				if canDeal.Physical then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.PoisonPhysical, "Physical", dmgTypeFlags.Chaos)
					output.PoisonPhysicalMin = min
					output.PoisonPhysicalMax = max
					totalMin = totalMin + min * nonChaosMult
					totalMax = totalMax + max * nonChaosMult
				end
				if pass == 2 then
					globalOutput.CritPoisonDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "ChaosDotMultiplier") / 100
					sourceCritDmg = (totalMin + totalMax) / 2 * globalOutput.CritPoisonDotMulti
				else
					globalOutput.PoisonDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "ChaosDotMultiplier") / 100
					sourceHitDmg = (totalMin + totalMax) / 2 * globalOutput.PoisonDotMulti
				end
			end
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.PoisonChanceOnHit = 0
			end
			if globalBreakdown then
				globalBreakdown.PoisonDPS = {
					s_format("异常计算模式: %s ^8(可以在配置界面修改)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			--local baseVal = calcAilmentDamage("Poison", sourceHitDmg, sourceCritDmg) * 0.20
			local baseVal = calcAilmentDamage("Poison", sourceHitDmg, sourceCritDmg) * data.misc.PoisonPercentBase * output.FistOfWarAilmentEffect * globalOutput.AilmentWarcryEffect
			if baseVal > 0 then
				skillFlags.poison = true
				skillFlags.duration = true
				local effMult = 1
				--抗性计算
				if env.mode_effective then
					local resist = m_min(enemyDB:Sum("BASE", nil, "ChaosResist"), 75)
					local takenInc = enemyDB:Sum("INC", dotCfg, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
					local takenMore = enemyDB:More(dotCfg, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
					effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
					globalOutput["PoisonEffMult"] = effMult
					if breakdown and effMult ~= 1 then
						globalBreakdown.PoisonEffMult = breakdown.effMult("Chaos", resist, 0, takenInc, effMult, takenMore)
					end
				end
			 
				
				--异常伤害效果
				local effectMod = calcLib.mod(skillModList, dotCfg, "AilmentEffect")
				--中毒消化速度
				local rateMod = calcLib.mod(skillModList, cfg, "PoisonFaster") + enemyDB:Sum("INC", nil, "SelfPoisonFaster")  / 100
				output.PoisonDPS = baseVal * effectMod * rateMod * effMult 
				local durationBase
				if skillData.poisonDurationIsSkillDuration then
					durationBase = skillData.duration
				else
					durationBase = 2
				end
				local durationMod = calcLib.mod(skillModList, dotCfg, "EnemyPoisonDuration", "SkillAndDamagingAilmentDuration", skillData.poisonIsSkillEffect and "Duration" or nil) * calcLib.mod(enemyDB, nil, "SelfPoisonDuration")
				globalOutput.PoisonDuration = durationBase * durationMod / rateMod * debuffDurationMult
				output.PoisonDamage = output.PoisonDPS * globalOutput.PoisonDuration
				if skillData.showAverage then
					output.TotalPoisonAverageDamage = output.HitChance / 100 * output.PoisonChance / 100 * output.PoisonDamage
					output.TotalPoisonDPS = output.PoisonDPS
				else
					output.TotalPoisonStacks = output.HitChance / 100 * output.PoisonChance / 100 * globalOutput.PoisonDuration * (globalOutput.HitSpeed or globalOutput.Speed) * (skillData.dpsMultiplier or 1) * quantityMultiplier
					output.TotalPoisonDPS = output.PoisonDPS * output.TotalPoisonStacks
				end
				if breakdown then
					if globalOutput.CritPoisonDotMulti and (globalOutput.CritPoisonDotMulti ~= globalOutput.PoisonDotMulti) then
						local chanceFromHit = output.PoisonChanceOnHit / 100 * (1 - globalOutput.CritChance / 100)
						local chanceFromCrit = output.PoisonChanceOnCrit / 100 * output.CritChance / 100
						local totalFromHit = chanceFromHit / (chanceFromHit + chanceFromCrit)
						local totalFromCrit = chanceFromCrit / (chanceFromHit + chanceFromCrit)
						globalBreakdown.PoisonDotMulti = breakdown.critDot(globalOutput.PoisonDotMulti, globalOutput.CritPoisonDotMulti, totalFromHit, totalFromCrit)
						globalOutput.PoisonDotMulti = (globalOutput.PoisonDotMulti * totalFromHit) + (globalOutput.CritPoisonDotMulti * totalFromCrit)
					end
t_insert(breakdown.PoisonDPS, "x 0.30 ^8(中毒每秒造成基础伤害的 30%)")
					t_insert(breakdown.PoisonDPS, s_format("= %.1f", baseVal, 1))
					breakdown.multiChain(breakdown.PoisonDPS, {
label = "中毒 DPS:",
base = s_format("%.1f ^8(每秒总伤害)", baseVal), 
{ "%.2f ^8(异常效果加成)", effectMod },
{ "%.2f ^8(伤害生效速率加成)", rateMod },
{ "%.3f ^8(有效 DPS 加成)", effMult },
{ "%.3f ^8(额外加成)", multAll },
total = s_format("= %.1f ^8每秒", output.PoisonDPS),
					})
					if globalOutput.PoisonDuration ~= 2 then
						globalBreakdown.PoisonDuration = {
s_format("%.2fs ^8(基础持续时间)", durationBase)
						}
						if durationMod ~= 1 then
t_insert(globalBreakdown.PoisonDuration, s_format("x %.2f ^8(持续时间加成)", durationMod))
						end
						if rateMod ~= 1 then
t_insert(globalBreakdown.PoisonDuration, s_format("/ %.2f ^8(伤害生效速率加成)", rateMod))
						end
						if debuffDurationMult ~= 1 then
t_insert(globalBreakdown.PoisonDuration, s_format("/ %.2f ^8(更快或较慢 debuff消退)", 1 / debuffDurationMult))
						end
						t_insert(globalBreakdown.PoisonDuration, s_format("= %.2fs", globalOutput.PoisonDuration))
					end
					breakdown.PoisonDamage = { }
					if isAttack then
						t_insert(breakdown.PoisonDamage, pass.label..":")
					end
t_insert(breakdown.PoisonDamage, s_format("%.1f ^8(每秒伤害)", output.PoisonDPS))
t_insert(breakdown.PoisonDamage, s_format("x %.2fs ^8(中毒持续时间)", globalOutput.PoisonDuration))
t_insert(breakdown.PoisonDamage, s_format("= %.1f ^8每层中毒伤害", output.PoisonDamage))
					if not skillData.showAverage then
						breakdown.TotalPoisonStacks = { }
						if isAttack then
							t_insert(breakdown.TotalPoisonStacks, pass.label..":")
						end
						breakdown.multiChain(breakdown.TotalPoisonStacks, {
base = s_format("%.2fs ^8(中毒持续时间)", globalOutput.PoisonDuration),
{ "%.2f ^8(中毒几率)", output.PoisonChance / 100 },
{ "%.2f ^8(命中几率)", output.HitChance / 100 },
{ "%.2f ^8(每秒击中)", globalOutput.HitSpeed or globalOutput.Speed },
{ "%g ^8(本技能DPS加成)", skillData.dpsMultiplier or 1 },
{ "%g ^8(本技能数量加成)", quantityMultiplier },
							total = s_format("= %.1f", output.TotalPoisonStacks),
						})
					end
				end
			end
		end	

		-- Calculate ignite chance and damage
		if canDeal.Fire and (output.IgniteChanceOnHit + output.IgniteChanceOnCrit) > 0 then
			if not activeSkill.igniteCfg then
				activeSkill.igniteCfg = {
					skillName = skillCfg.skillName,
					skillPart = skillCfg.skillPart,
					skillTypes = skillCfg.skillTypes,
					slotName = skillCfg.slotName,
					flags = bor(ModFlag.Dot, ModFlag.Ailment, band(cfg.flags, ModFlag.WeaponMask), band(cfg.flags, ModFlag.Melee) ~= 0 and ModFlag.MeleeHit or 0),
					keywordFlags = bor(band(cfg.keywordFlags, bnot(KeywordFlag.Hit)), KeywordFlag.Ignite, KeywordFlag.Ailment, KeywordFlag.FireDot),
					skillCond = setmetatable({["CriticalStrike"] = true }, { __index = skillCfg.skillCond } ),
				}
			end
			local dotCfg = activeSkill.igniteCfg
			local sourceHitDmg, sourceCritDmg
			if breakdown then
				breakdown.IgnitePhysical = { damageTypes = { } }
				breakdown.IgniteLightning = { damageTypes = { } }
				breakdown.IgniteCold = { damageTypes = { } }
				breakdown.IgniteFire = { damageTypes = { } }
				breakdown.IgniteChaos = { damageTypes = { } }
			end
			for pass = 1, 2 do
				if skillModList:Flag(dotCfg, "AilmentsAreNeverFromCrit") or pass == 1 then
					dotCfg.skillCond["CriticalStrike"] = false
				else
					dotCfg.skillCond["CriticalStrike"] = true
				end
				local totalMin, totalMax = 0, 0
				if canDeal.Physical and skillModList:Flag(cfg, "PhysicalCanIgnite") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.IgnitePhysical, "Physical", dmgTypeFlags.Fire)
					output.IgnitePhysicalMin = min
					output.IgnitePhysicalMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				if canDeal.Lightning and skillModList:Flag(cfg, "LightningCanIgnite") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.IgniteLightning, "Lightning", dmgTypeFlags.Fire)
					output.IgniteLightningMin = min
					output.IgniteLightningMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				if canDeal.Cold and skillModList:Flag(cfg, "ColdCanIgnite") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.IgniteCold, "Cold", dmgTypeFlags.Fire)
					output.IgniteColdMin = min
					output.IgniteColdMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				if canDeal.Fire and not skillModList:Flag(cfg, "FireCannotIgnite") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.IgniteFire, "Fire", 0)
					output.IgniteFireMin = min
					output.IgniteFireMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				if canDeal.Chaos and skillModList:Flag(cfg, "ChaosCanIgnite") then
					local min, max = calcAilmentSourceDamage(activeSkill, output, dotCfg, pass == 1 and breakdown and breakdown.IgniteChaos, "Chaos", dmgTypeFlags.Fire)
					output.IgniteChaosMin = min
					output.IgniteChaosMax = max
					totalMin = totalMin + min
					totalMax = totalMax + max
				end
				if pass == 2 then
					globalOutput.CritIgniteDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "FireDotMultiplier") / 100
					sourceCritDmg = (totalMin + totalMax) / 2 * globalOutput.CritIgniteDotMulti
				else
					globalOutput.IgniteDotMulti = 1 + skillModList:Sum("BASE", dotCfg, "DotMultiplier", "FireDotMultiplier") / 100
					sourceHitDmg = (totalMin + totalMax) / 2 * globalOutput.IgniteDotMulti
				end
			end
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.IgniteChanceOnHit = 0
			end
			if globalBreakdown then
				globalBreakdown.IgniteDPS = {
s_format("异常计算模式: %s ^8(可以在配置面板修改)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			--local baseVal = calcAilmentDamage("Ignite", sourceHitDmg, sourceCritDmg) * 0.5
			local baseVal = calcAilmentDamage("Ignite", sourceHitDmg, sourceCritDmg) *
			data.misc.IgnitePercentBase * output.FistOfWarAilmentEffect * globalOutput.AilmentWarcryEffect
			
		
				
			if baseVal > 0 then
				skillFlags.ignite = true
				local effMult = 1
				if env.mode_effective then
				
					  if skillModList:Flag(cfg, "IgniteToChaos") then
						local resist = m_min(enemyDB:Sum("BASE", nil, "ChaosResist") * calcLib.mod(enemyDB, nil, "ChaosResist"), data.misc.EnemyMaxResist)
						local takenInc = enemyDB:Sum("INC", dotCfg, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
						local takenMore = enemyDB:More(dotCfg, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
						effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
						globalOutput["IgniteEffMult"] = effMult
						if breakdown and effMult ~= 1 then
							globalBreakdown.IgniteEffMult = breakdown.effMult("Chaos", resist, 0, takenInc, effMult, takenMore)
						end
					else
						local resist = m_min(enemyDB:Sum("BASE", nil, "FireResist", "ElementalResist") * calcLib.mod(enemyDB, nil, "FireResist", "ElementalResist"), data.misc.EnemyMaxResist)
						local takenInc = enemyDB:Sum("INC", dotCfg, "DamageTaken", "DamageTakenOverTime", "FireDamageTaken", "FireDamageTakenOverTime", "ElementalDamageTaken")
						local takenMore = enemyDB:More(dotCfg, "DamageTaken", "DamageTakenOverTime", "FireDamageTaken", "FireDamageTakenOverTime", "ElementalDamageTaken")
						effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
						globalOutput["IgniteEffMult"] = effMult
						if breakdown and effMult ~= 1 then
							globalBreakdown.IgniteEffMult = breakdown.effMult("Fire", resist, 0, takenInc, effMult, takenMore)
						end
					end
				end
				local effectMod = calcLib.mod(skillModList, dotCfg, "AilmentEffect")
				local rateMod = (calcLib.mod(skillModList, cfg, "IgniteBurnFaster") + enemyDB:Sum("INC", nil, "SelfIgniteBurnFaster") / 100)  / calcLib.mod(skillModList, cfg, "IgniteBurnSlower")
				output.IgniteDPS = baseVal * effectMod * rateMod * effMult	
				
				
				local incDur = skillModList:Sum("INC", dotCfg, "EnemyIgniteDuration", "SkillAndDamagingAilmentDuration") + enemyDB:Sum("INC", nil, "SelfIgniteDuration")
				local moreDur = enemyDB:More(nil, "SelfIgniteDuration")
				globalOutput.IgniteDuration = 4 * (1 + incDur / 100) * moreDur / rateMod * debuffDurationMult
				globalOutput.IgniteDamage = output.IgniteDPS * globalOutput.IgniteDuration
			
				if skillFlags.igniteCanStack then
					output.IgniteDamage = output.IgniteDPS * globalOutput.IgniteDuration
					output.TotalIgniteStacks = 1 + skillModList:Sum("BASE", cfg, "IgniteStacks")
					output.TotalIgniteDPS = output.IgniteDPS * output.TotalIgniteStacks
				end
				if breakdown then
t_insert(breakdown.IgniteDPS, "x 0.5 ^8(点燃每秒造成 50% 伤害)")
					t_insert(breakdown.IgniteDPS, s_format("= %.1f", baseVal, 1))
					breakdown.multiChain(breakdown.IgniteDPS, {
						label = "Ignite DPS:",
base = s_format("%.1f ^8(每秒总伤害)", baseVal), 
{ "%.2f ^8(异常效果加成)", effectMod },
{ "%.2f ^8(燃烧速率加成)", rateMod  },
{ "%.3f ^8(有效 DPS 加成)", effMult },
total = s_format("= %.1f ^8每秒", output.IgniteDPS),
					})
					if globalOutput.CritIgniteDotMulti and (globalOutput.CritIgniteDotMulti ~= globalOutput.IgniteDotMulti) then
						local chanceFromHit = output.IgniteChanceOnHit / 100 * (1 - globalOutput.CritChance / 100)
						local chanceFromCrit = output.IgniteChanceOnCrit / 100 * output.CritChance / 100
						local totalFromHit = chanceFromHit / (chanceFromHit + chanceFromCrit)
						local totalFromCrit = chanceFromCrit / (chanceFromHit + chanceFromCrit)
						globalBreakdown.IgniteDotMulti = breakdown.critDot(globalOutput.IgniteDotMulti, globalOutput.CritIgniteDotMulti, totalFromHit, totalFromCrit)
						globalOutput.IgniteDotMulti = (globalOutput.IgniteDotMulti * totalFromHit) + (globalOutput.CritIgniteDotMulti * totalFromCrit)
					end
					if skillFlags.igniteCanStack then
						breakdown.IgniteDamage = { }
						if isAttack then
							t_insert(breakdown.IgniteDamage, pass.label..":")
						end
t_insert(breakdown.IgniteDamage, s_format("%.1f ^8(每秒伤害)", output.IgniteDPS))
t_insert(breakdown.IgniteDamage, s_format("x %.2fs ^8(点燃持续时间)", globalOutput.IgniteDuration))
t_insert(breakdown.IgniteDamage, s_format("= %.1f ^8每层点燃伤害", output.IgniteDamage))
						if not skillData.showAverage then
							breakdown.TotalIgniteStacks = { }
							if isAttack then
								t_insert(breakdown.TotalIgniteStacks, pass.label..":")
							end
							breakdown.multiChain(breakdown.TotalIgniteStacks, {
								base = s_format("%.2fs ^8(点燃持续时间)", globalOutput.IgniteDuration),
{ "%.2f ^8(点燃几率)", output.IgniteChance / 100 },
{ "%.2f ^8(命中几率)", output.HitChance / 100 },
{ "%.2f ^8(每秒击中)", globalOutput.HitSpeed or globalOutput.Speed },
{ "%g ^8(本技能DPS加成)", skillData.dpsMultiplier or 1 },
								total = s_format("= %.1f", output.TotalIgniteStacks),
							})
						end
					end
					if globalOutput.IgniteDuration ~= 4 then
						globalBreakdown.IgniteDuration = {
							s_format("4.00s ^8(基础持续时间)", durationBase)
						}
						if incDur ~= 0 then
t_insert(globalBreakdown.IgniteDuration, s_format("x %.2f ^8(延长/缩短 持续时间)", 1 + incDur/100))
						end
						if moreDur ~= 1 then
t_insert(globalBreakdown.IgniteDuration, s_format("x %.2f ^8(额外延长/缩短 总持续时间)", moreDur))
						end
						if rateMod  ~= 1 then
t_insert(globalBreakdown.IgniteDuration, s_format("/ %.2f ^8(燃烧速率加成)", rateMod))
						end
						if debuffDurationMult ~= 1 then
t_insert(globalBreakdown.IgniteDuration, s_format("/ %.2f ^8(更快或较慢 debuff消退)", 1 / debuffDurationMult))
						end
						t_insert(globalBreakdown.IgniteDuration, s_format("= %.2f秒", globalOutput.IgniteDuration))
					end
				end
			end
		end

		-- Calculate shock and freeze chance + duration modifier
		-- FIXME Completely fucking wrong now
		if (output.ShockChanceOnHit + output.ShockChanceOnCrit) > 0 then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if canDeal.Physical and skillModList:Flag(cfg, "PhysicalCanShock") then
				sourceHitDmg = sourceHitDmg + output.PhysicalHitAverage
				sourceCritDmg = sourceCritDmg + output.PhysicalCritAverage
			end
			if canDeal.Lightning and not skillModList:Flag(cfg, "LightningCannotShock") then
				sourceHitDmg = sourceHitDmg + output.LightningHitAverage
				sourceCritDmg = sourceCritDmg + output.LightningCritAverage
			end
			if canDeal.Cold and skillModList:Flag(cfg, "ColdCanShock") then
				sourceHitDmg = sourceHitDmg + output.ColdHitAverage
				sourceCritDmg = sourceCritDmg + output.ColdCritAverage
			end
			if canDeal.Fire and skillModList:Flag(cfg, "FireCanShock") then
				sourceHitDmg = sourceHitDmg + output.FireHitAverage
				sourceCritDmg = sourceCritDmg + output.FireCritAverage
			end
			if canDeal.Chaos and skillModList:Flag(cfg, "ChaosCanShock") then
				sourceHitDmg = sourceHitDmg + output.ChaosHitAverage
				sourceCritDmg = sourceCritDmg + output.ChaosCritAverage
			end
			if globalBreakdown then
				globalBreakdown.ShockDurationMod = {
					s_format("异常计算模式: %s ^8(可以在配置界面修改)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			local baseVal = calcAilmentDamage("Shock", sourceHitDmg, sourceCritDmg) * skillModList:More(cfg, "ShockAsThoughDealing")
			if baseVal > 0 then
				skillFlags.shock = true
				output.ShockDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemyShockDuration") / 100 + enemyDB:Sum("INC", nil, "SelfShockDuration") / 100
				 
				output.ShockEffectMod = calcLib.mod(skillModList, cfg, "EnemyShockEffect")
				output.ShockEffectModDisplay = 100 * (output.ShockEffectMod - 1)
				local maximum = skillModList:Override(nil, "ShockMax") or 50
				local current = m_min(globalOutput.CurrentShock or 0, maximum)
				local desired = m_min(enemyDB:Sum("BASE", nil, "DesiredShockVal"), maximum)
				local enemyThreshold = enemyDB:Sum("BASE", nil, "AilmentThreshold") * enemyDB:More(nil, "Life")
				local effList = { 5, 15, 50 }
				if enemyThreshold > 0 then
					local bossEffect = 100 * 0.5 * ((baseVal / enemyThreshold) ^ (0.4)) * (output.ShockEffectMod)
					t_insert(effList, bossEffect)
				end
				if maximum ~= 50 then
					t_insert(effList, maximum)
				end
				if current > 5 and current ~= (15 or 50 or maximum) and current < maximum then
					t_insert(effList, current)
				end
				if desired > 5 and desired ~= (15 or 50 or current or maximum) and desired < maximum and current == 0 then
					t_insert(effList, desired)
				end
				table.sort(effList)
				
				if breakdown then
				
					if current > 0 then
						breakdown.ShockDPS.label = s_format("感电效果持续 %.1f 秒 ^8(敌人身上的感电效果 ^7%s%% ^8)^7", 2 * output.ShockDurationMod, current)
					else
						breakdown.ShockDPS.label = s_format("感电效果持续 %.1f 秒", 2 * output.ShockDurationMod)
					end
					breakdown.ShockDPS.footer = s_format("^8(感电门槛大致等于怪物的生命，在boss身上的话是等于其生命的一半)")
					breakdown.ShockDPS.rowList = { }
					breakdown.ShockDPS.colList = {
						{ label = "目标感电效果", key = "effect" },
						{ label = "异常门槛", key = "thresh" },
					}
					for _, value in ipairs(effList) do
						local thresh = (((100 + (100 * (output.ShockEffectMod - 1)))^(2.5)) * baseVal) / ((2 * value) ^ (2.5))
						local decCheck = value / m_floor(value)
						value = m_floor(value)
						local threshString = ""
						if m_floor(thresh + 0.5) == m_floor(enemyThreshold + 0.5) then
							threshString = s_format("%.0f ^8(觉醒等级%.0f %s)", thresh, skillModList:Sum("BASE", nil, "AwakeningLevel"), env.configInput.enemyIsBoss)
						else
							threshString = s_format("%.0f", thresh)
						end
						if decCheck ~= 1 then -- don't put a label on the calculated boss effect
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%%", value),
								thresh = threshString,
							})
						elseif current > 0 and value == current then
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%% ^8(当前)", value),
								thresh = threshString,
							})
						elseif value == desired then
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%% ^8(期望)", value),
								thresh = threshString,
							})
						elseif value == maximum then
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%% ^8(最大)", value),
								thresh = threshString,
							})
						elseif value == 5 then
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%% ^8(最小)", value),
								thresh = threshString,
							})
						else
							t_insert(breakdown.ShockDPS.rowList, {
								effect = s_format("%s%%", value),
								thresh = threshString,
							})
						end
					end
				end
				
 			end
			
			 
		end
		
	if (output.ChillChanceOnHit + output.ChillChanceOnCrit) > 0 or (activeSkill.skillTypes[SkillType.ChillingArea] or activeSkill.skillTypes[SkillType.ChillNotHit]) then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if canDeal.Cold and not skillModList:Flag(cfg, "ColdCannotChill") then
				sourceHitDmg = sourceHitDmg + output.ColdHitAverage
				sourceCritDmg = sourceCritDmg + output.ColdCritAverage
			end
			if canDeal.Physical and skillModList:Flag(cfg, "PhysicalCanChill") then
				sourceHitDmg = sourceHitDmg + output.PhysicalHitAverage
				sourceCritDmg = sourceCritDmg + output.PhysicalCritAverage
			end
			if canDeal.Lightning and skillModList:Flag(cfg, "LightningCanChill") then
				sourceHitDmg = sourceHitDmg + output.LightningHitAverage
				sourceCritDmg = sourceCritDmg + output.LightningCritAverage
			end
			if canDeal.Fire and skillModList:Flag(cfg, "FireCanChill") then
				sourceHitDmg = sourceHitDmg + output.FireHitAverage
				sourceCritDmg = sourceCritDmg + output.FireCritAverage
			end
			if canDeal.Chaos and skillModList:Flag(cfg, "ChaosCanChill") then
				sourceHitDmg = sourceHitDmg + output.ChaosHitAverage
				sourceCritDmg = sourceCritDmg + output.ChaosCritAverage
			end
			if globalBreakdown then
				globalBreakdown.ChillDurationMod = {
					s_format("异常计算模式: %s ^8(可以从配置界面修改)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			local baseVal = calcAilmentDamage("Chill", sourceHitDmg, sourceCritDmg) * skillModList:More(cfg, "ChillAsThoughDealing")
			if baseVal > 0 then
				skillFlags.chill = true
				output.ChillEffectMod = calcLib.mod(skillModList, cfg, "EnemyChillEffect")
				output.ChillEffectModDisplay = 100 * (output.ChillEffectMod - 1)
				output.ChillDurationMod = 1 + (skillModList:Sum("INC", cfg, "EnemyChillDuration") + enemyDB:Sum("INC", nil, "SelfChillDuration")) / 100
				local enemyThreshold = enemyDB:Sum("BASE", nil, "AilmentThreshold") * enemyDB:More(nil, "Life")
				effList = { 5, 10, 30 }
				local desired = skillModList:Sum("BASE", nil, "DesiredBonechillEffect") or 0
				if output.BonechillEffect then
					t_insert(effList, output.BonechillEffect)
				end
				if not output.BonechillEffect and desired ~= (0 or 5 or 10 or 30 or output.BonechillEffect) and desired > 5 and desired < 30 then
					t_insert(effList, desired)
				end
				if enemyThreshold > 0 then
					local bossEffect = 100 * 0.5 * ((baseVal / enemyThreshold) ^ (0.4)) * (output.ChillEffectMod)
					t_insert(effList, bossEffect)
				end
				table.sort(effList)
				if breakdown then
					breakdown.ChillDPS.label = s_format("冰缓 %.1f 秒", 2 * output.ChillDurationMod)
					if output.BonechillEffect then
						breakdown.ChillDPS.label = s_format("冰缓 %.1f 秒 ^8(如果敌人身上有 ^7%s%% ^8 的【彻骨】效果)^7", 2 * output.ChillDurationMod, output.BonechillEffect)
					else
						breakdown.ChillDPS.label = s_format("冰缓 %.1f 秒", 2 * output.ChillDurationMod)
					end
					breakdown.ChillDPS.rowList = { }
					breakdown.ChillDPS.colList = {
						{ label = "冰缓效果", key = "effect" },
						{ label = "异常门槛", key = "thresh" },
					}
					breakdown.ChillDPS.footer = s_format("^8(冰缓门槛大致等于怪物的生命，在boss身上的话是等于其生命的一半)")
					for _, value in ipairs(effList) do
						local thresh = (((100 + (100 * (output.ChillEffectMod - 1)))^(2.5)) * baseVal) / ((2 * value) ^ (2.5))
						local decCheck = value / m_floor(value)
						value = m_floor(value)
						if m_floor(thresh + 0.5) == m_floor(enemyThreshold + 0.5) then
							threshString = s_format("%.0f ^8(觉醒等级%.0f %s)", thresh, skillModList:Sum("BASE", nil, "AwakeningLevel"), env.configInput.enemyIsBoss)
						else
							threshString = s_format("%.0f", thresh)
						end
						if decCheck ~= 1 then -- don't put a label on the calculated boss effect
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%%", value),
								thresh = threshString,
							})
						elseif value == output.BonechillEffect then
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%% ^8(当前)", value),
								thresh = threshString,
							})
						elseif value == desired then
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%% ^8(期望)", value),
								thresh = threshString,
							})
						elseif value == 30 then
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%% ^8(最大)", value),
								thresh = threshString,
							})
						elseif value == 5 then
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%% ^8(最小)", value),
								thresh = threshString,
							})
						else
							t_insert(breakdown.ChillDPS.rowList, {
								effect = s_format("%s%%", value),
								thresh = threshString,
							})
						end
					end
				end
			end
		end
		
		if activeSkill.skillTypes[SkillType.ChillingArea] or activeSkill.skillTypes[SkillType.NonHitChill] then
			skillFlags.chill = true
			output.ChillEffectMod = skillModList:Sum("INC", cfg, "EnemyChillEffect")
			output.ChillDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemyChillDuration") / 100
			output.ChillSourceEffect = m_min(30, m_floor(10 * (1 + output.ChillEffectMod / 100)))
			if breakdown then
				breakdown.DotChill = { }
				breakdown.multiChain(breakdown.DotChill, {
					label = "冰缓效果: ^8(最大 30%)",
					base = "10% ^8(基础)",
					{ "%.2f ^8(冰缓效果提高)", 1 + output.ChillEffectMod / 100},
					total = s_format("= %.0f%%", output.ChillSourceEffect)
				})
			end
		end
		if (output.FreezeChanceOnHit + output.FreezeChanceOnCrit) > 0 then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if canDeal.Cold and not skillModList:Flag(cfg, "ColdCannotFreeze") then
				sourceHitDmg = sourceHitDmg + output.ColdHitAverage
				sourceCritDmg = sourceCritDmg + output.ColdCritAverage
			end
			if canDeal.Physical and skillModList:Flag(cfg, "PhysicalCanFreeze") then
				sourceHitDmg = sourceHitDmg + output.PhysicalHitAverage
				sourceCritDmg = sourceCritDmg + output.PhysicalCritAverage
			end
			if canDeal.Lightning and skillModList:Flag(cfg, "LightningCanFreeze") then
				sourceHitDmg = sourceHitDmg + output.LightningHitAverage
				sourceCritDmg = sourceCritDmg + output.LightningCritAverage
			end
			
			if canDeal.Fire and skillModList:Flag(cfg, "FireCanFreeze") then
				sourceHitDmg = sourceHitDmg + output.FireHitAverage
				sourceCritDmg = sourceCritDmg + output.FireCritAverage
			end
			if canDeal.Chaos and skillModList:Flag(cfg, "ChaosCanFreeze") then
				sourceHitDmg = sourceHitDmg + output.ChaosHitAverage
				sourceCritDmg = sourceCritDmg + output.ChaosCritAverage
			end
			if globalBreakdown then
				globalBreakdown.FreezeDurationMod = {
					s_format("异常计算模式: %s ^8(可以从配置界面修改)", igniteMode == "CRIT" and "暴击伤害" or "平均伤害")
				}
			end
			local baseVal = calcAilmentDamage("Freeze", sourceHitDmg, sourceCritDmg) * skillModList:More(cfg, "FreezeAsThoughDealing")
			if baseVal > 0 then
				skillFlags.freeze = true
				skillFlags.chill = true
				output.FreezeDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemyFreezeDuration") / 100 + enemyDB:Sum("INC", nil, "SelfFreezeDuration") / 100
				if breakdown then
					t_insert(breakdown.FreezeDPS, s_format("如果要触发最小冰冻效果 5%% 持续 0.3 秒, 目标的冰冻门槛不能大于  %.0f.", baseVal * 20 * output.FreezeDurationMod))
					t_insert(breakdown.FreezeDPS, s_format("^8(冰冻门槛大致等于怪物的生命，在boss身上的话是等于其生命的一半)"))
				end
			end
		end

		if (output.ScorchChanceOnHit + output.ScorchChanceOnCrit) > 0 or enemyDB:Flag(nil, "Condition:AlreadyScorched") then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if output.ScorchChanceOnCrit == 0 and output.ScorchChanceOnHit > 0 then
				output.ScorchChanceOnCrit = output.ScorchChanceOnHit
			end
			if canDeal.Fire then
				sourceHitDmg = sourceHitDmg + output.FireHitAverage
				sourceCritDmg = sourceCritDmg + output.FireCritAverage
			end
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.ScorchChanceOnHit = 0
			end
			local baseVal = calcAilmentDamage("Scorch", sourceHitDmg, sourceCritDmg)
			if baseVal > 0 or enemyDB:Flag(nil, "Condition:AlreadyScorched") then
				skillFlags.scorch = true
				output.ScorchEffectMod = skillModList:Sum("INC", cfg, "EnemyScorchEffect")
				output.ScorchDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemyScorchDuration") / 100 + enemyDB:Sum("INC", nil, "SelfScorchDuration") / 100
			end
		end
		if (output.BrittleChanceOnHit + output.BrittleChanceOnCrit) > 0 then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if output.BrittleChanceOnCrit == 0 and output.BrittleChanceOnHit > 0 then
				output.BrittleChanceOnCrit = output.BrittleChanceOnHit
			end
			if canDeal.Cold then
				sourceHitDmg = sourceHitDmg + output.ColdHitAverage
				sourceCritDmg = sourceCritDmg + output.ColdCritAverage
			end
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.BrittleChanceOnHit = 0
			end
			local baseVal = calcAilmentDamage("Brittle", sourceHitDmg, sourceCritDmg)
			if baseVal > 0 then
				skillFlags.brittle = true
				output.BrittleEffectMod = skillModList:Sum("INC", cfg, "EnemyBrittleEffect")
				output.BrittleDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemyBrittleDuration") / 100 + enemyDB:Sum("INC", nil, "SelfBrittleDuration") / 100
			end
		end
		if (output.SapChanceOnHit + output.SapChanceOnCrit) > 0 then
			local sourceHitDmg = 0
			local sourceCritDmg = 0
			if output.SapChanceOnCrit == 0 and output.SapChanceOnHit > 0 then
				output.SapChanceOnCrit = output.SapChanceOnHit
			end
			if canDeal.Lightning then
				sourceHitDmg = sourceHitDmg + output.LightningHitAverage
				sourceCritDmg = sourceCritDmg + output.LightningCritAverage
			end
			local igniteMode = env.configInput.igniteMode or "AVERAGE"
			if igniteMode == "CRIT" then
				output.SapChanceOnHit = 0
			end
			local baseVal = calcAilmentDamage("Sap", sourceHitDmg, sourceCritDmg)
			if baseVal > 0 then
				skillFlags.sap = true
				output.SapEffectMod = skillModList:Sum("INC", cfg, "EnemySapEffect")
				output.SapDurationMod = 1 + skillModList:Sum("INC", cfg, "EnemySapDuration") / 100 + enemyDB:Sum("INC", nil, "SelfSapDuration") / 100
			end
		end
		-- Calculate knockback chance/distance
		output.KnockbackChance = m_min(100, output.KnockbackChanceOnHit * (1 - output.CritChance / 100) + output.KnockbackChanceOnCrit * output.CritChance / 100 + enemyDB:Sum("BASE", nil, "SelfKnockbackChance"))
		if output.KnockbackChance > 0 then
			output.KnockbackDistance = round(4 * calcLib.mod(skillModList, cfg, "EnemyKnockbackDistance"))
			if breakdown then
				breakdown.KnockbackDistance = {
					radius = output.KnockbackDistance,
				}
			end
		end

		-- Calculate enemy stun modifiers
		local enemyStunThresholdRed = -skillModList:Sum("INC", cfg, "EnemyStunThreshold")
		if enemyStunThresholdRed > 75 then
			output.EnemyStunThresholdMod = 1 - (75 + (enemyStunThresholdRed - 75) * 25 / (enemyStunThresholdRed - 50)) / 100
		else
			output.EnemyStunThresholdMod = 1 - enemyStunThresholdRed / 100
		end
		local base = skillData.baseStunDuration or 0.35
		local incDur = skillModList:Sum("INC", cfg, "EnemyStunDuration")
		local incRecov = enemyDB:Sum("INC", nil, "StunRecovery")
		output.EnemyStunDuration = base * (1 + incDur / 100) / (1 + incRecov / 100)
		if breakdown then
			if output.EnemyStunDuration ~= base then
				breakdown.EnemyStunDuration = {
					s_format("%.2fs ^8(基础持续时间)", base),
				}
				if incDur ~= 0 then
t_insert(breakdown.EnemyStunDuration, s_format("x %.2f ^8(延长/缩短 晕眩持续时间)", 1 + incDur/100))
				end
				if incRecov ~= 0 then
t_insert(breakdown.EnemyStunDuration, s_format("/ %.2f ^8(延长/缩短 敌人晕眩回复)", 1 + incRecov/100))
				end
				t_insert(breakdown.EnemyStunDuration, s_format("= %.2f秒", output.EnemyStunDuration))
			end
		end
		
		--怒火
		if skillModList:Flag(cfg, "Condition:CanGainRage")  then
			skillFlags.rage = true
			local rageStacks =  skillModList:Sum("BASE", cfg, "Multiplier:Rage") +skillModList:Sum("BASE", cfg, "Rage")			
			local maxRageStacks =skillModList:Sum("BASE", cfg, "MaximumRage")
			local rageDuration = (data.misc.RageDurationBase + skillModList:Sum("BASE", cfg, "RageDuration"))*
			calcLib.mod(skillModList, cfg,  "RageDuration")
			
			globalOutput.RageStacks = rageStacks
			globalOutput.MaxRageStacks = maxRageStacks
			globalOutput.RageDuration = rageDuration
			
			
		end
		
		
		-- Calculate impale chance and modifiers
		if canDeal.Physical and output.ImpaleChance > 0 then
            skillFlags.impale = true
            local impaleChance = m_min(output.ImpaleChance/100, 1)
            local maxStacks = data.misc.ImpaleStacksMax + skillModList:Sum("BASE", cfg, "ImpaleStacksMax") -- magic number: base stacks duration
			
			
			local impaleDuration = (data.misc.ImpaleDurationBase + skillModList:Sum("BASE", cfg, "ImpaleDuration"))*
			 calcLib.mod(skillModList, cfg,  "ImpaleDuration")
			
			
			
            local configStacks = enemyDB:Sum("BASE", nil, "Multiplier:ImpaleStack")
            local impaleStacks = configStacks > 0 and m_min(configStacks, maxStacks) or  maxStacks

             local baseStoredDamage = data.misc.ImpaleStoredDamageBase -- 0.1 magic number: base impale stored damage
            local storedDamageInc = skillModList:Sum("INC", cfg, "ImpaleEffect")/100
            local storedDamageMore = round(skillModList:More(cfg, "ImpaleEffect"), 2)
            local storedDamageModifier = (1 + storedDamageInc) * storedDamageMore
            local impaleStoredDamage = baseStoredDamage * storedDamageModifier

			local impaleHitDamageMod = impaleStoredDamage * impaleStacks  -- Source: https://www.reddit.com/r/pathofexile/comments/chgqqt/impale_and_armor_interaction/
			local enemyArmour = round(calcLib.val(enemyDB, "Armour") * enemyDB:More(nil, "Armour"))
			 
            local impaleArmourReduction = calcs.armourReductionF(enemyArmour, impaleHitDamageMod * output.impaleStoredHitAvg)
			
			
			
			local ePhysicalDamageReduction = enemyDB:Sum("BASE", nil, "PhysicalDamageReduction")
			local eEnemyPhysicalDamageReduction = skillModList:Sum("BASE", cfg, "EnemyPhysicalDamageReduction") 
			local eEnemyImpalePhysicalDamageReduction = skillModList:Sum("BASE", cfg, "EnemyImpalePhysicalDamageReduction") 
			
			
			
			local impaleResist = m_max(0, 
			 ePhysicalDamageReduction+ 
			 eEnemyPhysicalDamageReduction + 
			 eEnemyImpalePhysicalDamageReduction
			 + impaleArmourReduction)
			  
 			local impaleDMGModifier = impaleHitDamageMod * (1 - impaleResist / 100) * impaleChance

			local enemyImpaleReductionModifier = (1 - impaleResist / 100)
			output.EnemyImpaleReductionModifier = enemyImpaleReductionModifier
			globalOutput.EnemyImpaleReductionModifier = enemyImpaleReductionModifier
			
            globalOutput.ImpaleStacksMax = maxStacks
			globalOutput.ImpaleStacks = impaleStacks
			
			globalOutput.ImpaleDuration = impaleDuration
			output.ImpaleStoredDamage = impaleStoredDamage * 100
			output.ImpaleModifier = 1 + impaleDMGModifier

 			if breakdown then
			
			breakdown.EnemyImpaleReductionModifier = {}
			
			t_insert(breakdown.EnemyImpaleReductionModifier, s_format("+ %.0f%% ^8(敌人护甲物理减伤)", impaleArmourReduction))
			t_insert(breakdown.EnemyImpaleReductionModifier, s_format("+ %.0f%% ^8(敌人物理减伤)", ePhysicalDamageReduction))
			t_insert(breakdown.EnemyImpaleReductionModifier, s_format("+ %.0f%% ^8(降低或提高敌人的物理减伤)", eEnemyPhysicalDamageReduction))
			t_insert(breakdown.EnemyImpaleReductionModifier, s_format("+ %.0f%% ^8(降低或提高敌人的穿刺物理减伤)", eEnemyImpalePhysicalDamageReduction))
			t_insert(breakdown.EnemyImpaleReductionModifier, s_format("敌人穿刺抗性 = %.0f%% ^8(敌人穿刺抗性，不能小于 0)", impaleResist))
		 	t_insert(breakdown.EnemyImpaleReductionModifier, s_format("敌人物理减伤加成 = %.2f ^8", enemyImpaleReductionModifier))
			
			
			
				breakdown.ImpaleStoredDamage = {}
t_insert(breakdown.ImpaleStoredDamage, "10% ^8(基础值)")
t_insert(breakdown.ImpaleStoredDamage, s_format("x %.2f ^8(效果提高或降低)", storedDamageModifier))
				t_insert(breakdown.ImpaleStoredDamage, s_format("= %.1f%%", output.ImpaleStoredDamage))

 				breakdown.ImpaleModifier = {}
t_insert(breakdown.ImpaleModifier, s_format("%d ^8(叠加层数, 可以在配置界面修改)", impaleStacks))
t_insert(breakdown.ImpaleModifier, s_format("x %.3f ^8(存储伤害)", impaleStoredDamage))
t_insert(breakdown.ImpaleModifier, s_format("x %.2f ^8(穿刺几率)", impaleChance))
				if impaleResist == 0 then 
					t_insert(breakdown.ImpaleModifier, s_format("x %.2f ^8(敌人的穿刺物理伤害减伤为0)", (1 - impaleResist / 100)))
				else
					t_insert(breakdown.ImpaleModifier, s_format("x %.2f ^8(敌人的穿刺物理伤害减伤)", (1 - impaleResist / 100)))
				end 
				t_insert(breakdown.ImpaleModifier, s_format("= %.3f", impaleDMGModifier))

 			end
		end
		
	end

	-- Combine secondary effect stats
	if isAttack then
		combineStat("BleedChance", "AVERAGE")
		combineStat("BleedDPS", "CHANCE", "BleedChance")
		combineStat("PoisonChance", "AVERAGE")
		combineStat("PoisonDPS", "CHANCE", "PoisonChance")
		combineStat("TotalPoisonDPS", "DPS")
		combineStat("PoisonDamage", "CHANCE", "PoisonChance")
		if skillData.showAverage then
			combineStat("TotalPoisonAverageDamage", "DPS")
		else
			combineStat("TotalPoisonStacks", "DPS")
		end
		combineStat("IgniteChance", "AVERAGE")
		combineStat("IgniteDPS", "CHANCE", "IgniteChance")
		if skillFlags.igniteCanStack then
			combineStat("IgniteDamage", "CHANCE", "IgniteChance")
			if skillData.showAverage then
				combineStat("TotalIgniteAverageDamage", "DPS")
				combineStat("TotalIgniteStacks", "DPS")
				combineStat("TotalIgniteDPS", "DPS")
			else
				combineStat("TotalIgniteStacks", "DPS")
				combineStat("TotalIgniteDPS", "DPS")
			end
		end
		combineStat("ChillEffectMod", "AVERAGE")
		combineStat("ChillDurationMod", "AVERAGE")
		combineStat("ShockChance", "AVERAGE")
		combineStat("ShockDurationMod", "AVERAGE")
		combineStat("ShockEffectMod", "AVERAGE")
		combineStat("FreezeChance", "AVERAGE")
		combineStat("FreezeDurationMod", "AVERAGE")
		combineStat("ScorchChance", "AVERAGE")
		combineStat("ScorchEffectMod", "AVERAGE")
		combineStat("ScorchDurationMod", "AVERAGE")
		combineStat("BrittleChance", "AVERAGE")
		combineStat("BrittleEffectMod", "AVERAGE")
		combineStat("BrittleDurationMod", "AVERAGE")
		combineStat("SapChance", "AVERAGE")
		combineStat("SapEffectMod", "AVERAGE")
		combineStat("SapDurationMod", "AVERAGE")
		combineStat("BrittleChance", "AVERAGE")
		combineStat("ImpaleChance", "AVERAGE")
		combineStat("ImpaleStoredDamage", "AVERAGE")
		combineStat("ImpaleModifier", "CHANCE", "ImpaleChance")
		
	 
	
		
	end

	if skillFlags.hit and skillData.decay and canDeal.Chaos then
		-- Calculate DPS for Essence of Delirium's Decay effect
		skillFlags.decay = true
		activeSkill.decayCfg = {
			skillName = skillCfg.skillName,
			skillPart = skillCfg.skillPart,
			skillTypes = skillCfg.skillTypes,
			slotName = skillCfg.slotName,
			flags = ModFlag.Dot,
			keywordFlags = bor(band(skillCfg.keywordFlags, bnot(KeywordFlag.Hit)), KeywordFlag.ChaosDot),
		}
		local dotCfg = activeSkill.decayCfg
		local effMult = 1
		if env.mode_effective then
			local resist = m_min(enemyDB:Sum("BASE", nil, "ChaosResist"), 75)
			local takenInc = enemyDB:Sum("INC", nil, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
			local takenMore = enemyDB:More(nil, "DamageTaken", "DamageTakenOverTime", "ChaosDamageTaken", "ChaosDamageTakenOverTime")
			
			effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
			output["DecayEffMult"] = effMult
			if breakdown and effMult ~= 1 then
				breakdown.DecayEffMult = breakdown.effMult("Chaos", resist, 0, takenInc, effMult, takenMore)
			end
		end
		local inc = skillModList:Sum("INC", dotCfg, "Damage", "ChaosDamage")
		local more = round(skillModList:More(dotCfg, "Damage", "ChaosDamage"), 2)
		--local multChaosDot = skillModList:Sum("BASE", dotTypeCfg, "ChaosDotMultiplier")
		--local multNonAilment = skillModList:Sum("BASE", dotTypeCfg, "NonAilmentChaosDotMultiplier")		
		local mult = skillModList:Sum("BASE", dotTypeCfg, "DotMultiplier", "ChaosDotMultiplier")
		
		output.DecayDPS = skillData.decay * (1 + inc/100) * more * (1 + mult/100) * effMult
		local durationMod = calcLib.mod(skillModList, dotCfg, "Duration", "SkillAndDamagingAilmentDuration")
		output.DecayDuration = 10 * durationMod * debuffDurationMult
		if breakdown then
			breakdown.DecayDPS = { }
t_insert(breakdown.DecayDPS, "腐蚀 DPS:")
			breakdown.dot(breakdown.DecayDPS, skillData.decay, inc, more, mult, nil, effMult, output.DecayDPS)
			if output.DecayDuration ~= 2 then
				breakdown.DecayDuration = {
s_format("%.2fs ^8(基础持续时间)", 10)
				}
				if durationMod ~= 1 then
t_insert(breakdown.DecayDuration, s_format("x %.2f ^8(持续时间加成)", durationMod))
				end
				if debuffDurationMult ~= 1 then
t_insert(breakdown.DecayDuration, s_format("/ %.2f ^8(更快或较慢 debuff消退)", 1 / debuffDurationMult))
				end
				t_insert(breakdown.DecayDuration, s_format("= %.2f秒", output.DecayDuration))
			end
		end
	end


-- Calculate skill DOT components
	local dotCfg = {
		skillName = skillCfg.skillName,
		skillPart = skillCfg.skillPart,
		skillTypes = skillCfg.skillTypes,
		slotName = skillCfg.slotName,
		flags = bor(ModFlag.Dot, skillCfg.flags),
		--flags = bor(ModFlag.Dot, skillData.dotIsSpell and ModFlag.Spell or 0, skillData.dotIsArea and ModFlag.Area or 0, skillData.dotIsProjectile and ModFlag.Projectile or 0),
		keywordFlags = band(skillCfg.keywordFlags, bnot(KeywordFlag.Hit)),
	}
	if bor(dotCfg.flags, ModFlag.Area) == dotCfg.flags and not skillData.dotIsArea then
		dotCfg.flags = band(dotCfg.flags, bnot(ModFlag.Area))
	end
	if bor(dotCfg.flags, ModFlag.Projectile) == dotCfg.flags and not skillData.dotIsProjectile then
		dotCfg.flags = band(dotCfg.flags, bnot(ModFlag.Projectile))
	end
	if bor(dotCfg.flags, ModFlag.Spell) == dotCfg.flags and not skillData.dotIsSpell then
		dotCfg.flags = band(dotCfg.flags, bnot(ModFlag.Spell))
	end
	if bor(dotCfg.flags, ModFlag.Attack) == dotCfg.flags and not skillData.dotIsAttack then
		dotCfg.flags = band(dotCfg.flags, bnot(ModFlag.Attack))
	end

	if bor(dotCfg.flags, ModFlag.Hit) == dotCfg.flags and not skillData.dotIsHit then
		dotCfg.flags = band(dotCfg.flags, bnot(ModFlag.Hit))
	end
	-- spell_damage_modifiers_apply_to_skill_dot does not apply to enemy damage taken
	local dotTakenCfg = copyTable(dotCfg, true)
	if (skillData.dotIsSpell) then
		dotTakenCfg.flags = band(dotTakenCfg.flags, bnot(ModFlag.Spell))
	end

	activeSkill.dotCfg = dotCfg
	output.TotalDotInstance = 0
	
	runSkillFunc("preDotFunc")

	for _, damageType in ipairs(dmgTypeList) do
		local dotTypeCfg = copyTable(dotCfg, true)
		dotTypeCfg.keywordFlags = bor(dotTypeCfg.keywordFlags, KeywordFlag[damageType.."Dot"])
		activeSkill["dot"..damageType.."Cfg"] = dotTypeCfg
		local baseVal 
		if canDeal[damageType] then
			baseVal = skillData[damageType.."Dot"] or 0
		else
			baseVal = 0
		end
		if baseVal > 0 or (output[damageType.."Dot"] or 0) > 0 then
			skillFlags.dot = true
			local effMult = 1
			if env.mode_effective then
				local resist = 0
				local takenInc = enemyDB:Sum("INC", dotTakenCfg, "DamageTaken", "DamageTakenOverTime", damageType.."DamageTaken", damageType.."DamageTakenOverTime")
				local takenMore = enemyDB:More(dotTakenCfg, "DamageTaken", "DamageTakenOverTime", damageType.."DamageTaken", damageType.."DamageTakenOverTime")
				if damageType == "Physical" then
					resist = enemyDB:Sum("BASE", nil, "PhysicalDamageReduction")
				else
					resist = enemyDB:Sum("BASE", nil, damageType.."Resist")
					if isElemental[damageType] then
						local base = resist + enemyDB:Sum("BASE", dotTypeCfg, "ElementalResist")
						resist = base * calcLib.mod(enemyDB, nil, damageType.."Resist")
						takenInc = takenInc + enemyDB:Sum("INC", dotTypeCfg, "ElementalDamageTaken")
					end
					resist = m_min(resist, data.misc.EnemyMaxResist)
				end
				effMult = (1 - resist / 100) * (1 + takenInc / 100) * takenMore
				output[damageType.."DotEffMult"] = effMult
				if breakdown and effMult ~= 1 then
					breakdown[damageType.."DotEffMult"] = breakdown.effMult(damageType, resist, 0, takenInc, effMult, takenMore)
				end
			end
			local inc = skillModList:Sum("INC", dotTypeCfg, "Damage", damageType.."Damage", isElemental[damageType] and "ElementalDamage" or nil)
			local more = round(skillModList:More(dotTypeCfg, "Damage", damageType.."Damage", isElemental[damageType] and "ElementalDamage" or nil), 2)
			local mult = skillModList:Sum("BASE", dotTypeCfg, "DotMultiplier", damageType.."DotMultiplier")
			local aura = activeSkill.skillTypes[SkillType.Aura] and not activeSkill.skillTypes[SkillType.Mine] and calcLib.mod(skillModList, dotTypeCfg, "AuraEffect")
			
			local total = baseVal * (1 + inc/100) * more * (1 + mult/100) * (aura or 1) * effMult
			if output[damageType.."Dot"] == 0 or output[damageType.."Dot"] == nil then
				output[damageType.."Dot"] = total
				output.TotalDotInstance = output.TotalDotInstance + total
			else
				output.TotalDotInstance = output.TotalDotInstance + total + (output[damageType.."Dot"] or 0)
			end
			
			if breakdown then
				breakdown[damageType.."Dot"] = { }
				breakdown.dot(breakdown[damageType.."Dot"], baseVal, inc, more, mult, nil, aura, effMult, total)
			end
		end
	end
	if skillModList:Flag(nil, "DotCanStack") then
		skillFlags.DotCanStack = true
		local speed = output.Speed
		-- Check if skill is being triggered via Mine (e.g., Blastchain Mine Support) or Trap
		-- if "yes", you cannot use output.Speed but rather should use output.MineLayingSpeed or output.TrapThrowingSpeed
		if band(dotCfg.keywordFlags, KeywordFlag.Mine) ~= 0 then
			speed = output.MineLayingSpeed
		elseif band(dotCfg.keywordFlags, KeywordFlag.Trap) ~= 0 then
			speed = output.TrapThrowingSpeed
		end
		output.TotalDot = output.TotalDotInstance * speed * output.Duration * (skillData.dpsMultiplier or 1) * quantityMultiplier
		if breakdown then
			breakdown.TotalDot = {
				s_format("%.1f ^8(每个实例的伤害)", output.TotalDotInstance),
				s_format("x %.2f ^8(每秒击中次数)", speed),				
				s_format("x %.2f ^8(技能持续时间)", output.Duration),
			}
			if skillData.dpsMultiplier then
				t_insert(breakdown.TotalDot, s_format("x %g ^8(技能DPS加成)", skillData.dpsMultiplier))
			end
			if quantityMultiplier > 1 then
				t_insert(breakdown.TotalDot, s_format("x %g ^8(技能数量加成)", quantityMultiplier))
			end
			t_insert(breakdown.TotalDot, s_format("= %.1f", output.TotalDot))
		end
	else
		output.TotalDot = output.TotalDotInstance
	end
-- General's Cry Mirage Warriors
	if activeSkill.activeEffect.grantedEffect.name == "将军之吼" then
		
		local usedSkill = nil
		local calcMode = env.mode == "CALCS" and "CALCS" or "MAIN"
		for _, triggerSkill in ipairs(actor.activeSkillList) do
			if triggerSkill.socketGroup == activeSkill.socketGroup and triggerSkill ~= activeSkill and triggerSkill.skillData.triggeredByGeneralsCry then
				-- Grab a fully-processed by calcs.perform() version of the skill that Mirage Warrior(s) will use
				local uuid = cacheSkillUUID(triggerSkill)
				if not GlobalCache.cachedData[calcMode][uuid] then
					calcs.buildActiveSkill(env, calcMode, triggerSkill)
					env.dontCache = true
				end
				if GlobalCache.cachedData[calcMode][uuid] then
					usedSkill = GlobalCache.cachedData[calcMode][uuid].ActiveSkill
					
				end
				break
			end
		end

		if usedSkill then
			local moreDamage =  usedSkill.skillModList:Sum("BASE", usedSkill.skillCfg, "GeneralsCryMirageWarriorLessDamage")
			local exertInc = env.modDB:Sum("INC", usedSkill.skillCfg, "ExertIncrease")
			local exertMore = env.modDB:Sum("MORE", usedSkill.skillCfg, "ExertIncrease")
			
			local newSkill, newEnv = calcs.copyActiveSkill(env, calcMode, usedSkill)

			-- Add new modifiers to new skill (which already has all the old skill's modifiers)
			newSkill.skillModList:NewMod("Damage", "MORE", moreDamage, "将军之吼", activeSkill.ModFlags, activeSkill.KeywordFlags)
			newSkill.skillModList:NewMod("Damage", "INC", exertInc, "将军之吼增助攻击", activeSkill.ModFlags, activeSkill.KeywordFlags)
			newSkill.skillModList:NewMod("Damage", "MORE", exertMore, "将军之吼增助攻击", activeSkill.ModFlags, activeSkill.KeywordFlags)
			local maxMirageWarriors = 0
			for i, value in ipairs(env.player.mainSkill.skillModList:Tabulate("BASE", env.player.mainSkill.skillCfg, "GeneralsCryDoubleMaxCount")) do
				local mod = value.mod
				newSkill.skillModList:NewMod("QuantityMultiplier", "BASE", mod.value, mod.source, activeSkill.ModFlags, activeSkill.KeywordFlags)
				maxMirageWarriors = maxMirageWarriors + mod.value
			end
			-- Non-channeled skills only attack once, disregard attack rate
			if not usedSkill.skillTypes[SkillType.Channelled] then
				newSkill.skillData.timeOverride = 1
			end
			
			
			if usedSkill.skillPartName then
				activeSkill.skillPart = usedSkill.skillPart
				env.player.mainSkill.skillPartName = usedSkill.skillPartName
				env.player.mainSkill.infoMessage2 = usedSkill.activeEffect.grantedEffect.name
			else
				activeSkill.skillPartName = usedSkill.activeEffect.grantedEffect.name
			end
			
			-- Recalculate the offensive/defensive aspects of this new skill
			newEnv.player.mainSkill = newSkill
			calcs.perform(newEnv)
			env.player.mainSkill = newSkill
			
			activeSkill.infoMessage = tostring(maxMirageWarriors) .. " 蜃影武士使用 " .. usedSkill.activeEffect.grantedEffect.name


			-- Re-link over the output
			env.player.output = newEnv.player.output
			if newSkill.minion then
				env.minion = newEnv.player.mainSkill.minion
				env.minion.output = newEnv.minion.output
			end

			-- Make any necessary corrections to output
			-- Don't show attack rate for non-channeled skills
			if not usedSkill.skillTypes[SkillType.Channelled] then
				env.player.output.Speed = 0
			end
			env.player.output.ManaCost = output.ManaCost
			env.player.output.Cooldown = output.Cooldown


			-- Re-link over the breakdown (if present)
			if newEnv.player.breakdown then
				env.player.breakdown = newEnv.player.breakdown
				if newSkill.minion then
					env.minion.breakdown = newEnv.minion.breakdown
				end
				-- Make any necessary corrections to breakdown
			end

			-- Copy over original breakdown components (if present)
			if breakdown then
				env.player.breakdown.ManaCost = breakdown.ManaCost
			end

			 
			usedSkill.TotalDPS = 0
			usedSkill.CombinedDPS = 0
		end
	end
	-- The Saviour
	if activeSkill.activeEffect.grantedEffect.name == "反射" then
		
		local usedSkill = nil
		local usedSkillBestDps = 0
		local calcMode = env.mode == "CALCS" and "CALCS" or "MAIN"
		for _, triggerSkill in ipairs(actor.activeSkillList) do
			if triggerSkill ~= activeSkill and triggerSkill.skillTypes[SkillType.Attack] and band(triggerSkill.skillCfg.flags, bor(ModFlag.Sword, ModFlag.Weapon1H)) == bor(ModFlag.Sword, ModFlag.Weapon1H) then
				-- Grab a fully-processed by calcs.perform() version of the skill that Mirage Warrior(s) will use
				local uuid = cacheSkillUUID(triggerSkill)
				if not GlobalCache.cachedData[calcMode][uuid] then
					calcs.buildActiveSkill(env, calcMode, triggerSkill)
					env.dontCache = true
				end
				-- We found a skill and it can crit
				if GlobalCache.cachedData[calcMode][uuid] and GlobalCache.cachedData[calcMode][uuid].CritChance and GlobalCache.cachedData[calcMode][uuid].CritChance > 0 then
					if not usedSkill then
						usedSkill = GlobalCache.cachedData[calcMode][uuid].ActiveSkill
						usedSkillBestDps = GlobalCache.cachedData[calcMode][uuid].TotalDPS
					else
						if GlobalCache.cachedData[calcMode][uuid].TotalDPS > usedSkillBestDps then
							usedSkill = GlobalCache.cachedData[calcMode][uuid].ActiveSkill
							usedSkillBestDps = GlobalCache.cachedData[calcMode][uuid].TotalDPS
						end
					end
				end
				
			end
		end

		if usedSkill then
			local moreDamage = activeSkill.skillModList:Sum("BASE", activeSkill.skillCfg, "SaviourMirageWarriorLessDamage")
			local maxMirageWarriors = activeSkill.skillModList:Sum("BASE", activeSkill.skillCfg, "SaviourMirageWarriorMaxCount")

			local newSkill, newEnv = calcs.copyActiveSkill(env, calcMode, usedSkill)

			-- Add new modifiers to new skill (which already has all the old skill's modifiers)
			newSkill.skillModList:NewMod("Damage", "MORE", moreDamage, "【救世者】", activeSkill.ModFlags, activeSkill.KeywordFlags)
			if env.player.itemList["Weapon 1"] and env.player.itemList["Weapon 2"] and env.player.itemList["Weapon 1"].name == env.player.itemList["Weapon 2"].name then
				maxMirageWarriors = maxMirageWarriors / 2
			end
			newSkill.skillModList:NewMod("QuantityMultiplier", "BASE", maxMirageWarriors, "【救世者】的蜃影救世者", activeSkill.ModFlags, activeSkill.KeywordFlags)
			
			

			if usedSkill.skillPartName then
				activeSkill.skillPart = usedSkill.skillPart
				env.player.mainSkill.skillPartName = usedSkill.skillPartName
				env.player.mainSkill.infoMessage2 = usedSkill.activeEffect.grantedEffect.name
			else
				activeSkill.skillPartName = usedSkill.activeEffect.grantedEffect.name
			end
			-- Recalculate the offensive/defensive aspects of this new skill
			newEnv.player.mainSkill = newSkill
			calcs.perform(newEnv)
			env.player.mainSkill = newSkill
			
			activeSkill.infoMessage = tostring(maxMirageWarriors) .. " 蜃影救世者使用 " .. usedSkill.activeEffect.grantedEffect.name
			
			-- Re-link over the output
			env.player.output = newEnv.player.output
			if newSkill.minion then
				env.minion = newEnv.player.mainSkill.minion
				env.minion.output = newEnv.minion.output
			end

			-- Make any necessary corrections to output
			env.player.output.ManaCost = 0

			-- Re-link over the breakdown (if present)
			if newEnv.player.breakdown then
				env.player.breakdown = newEnv.player.breakdown
				if newSkill.minion then
					env.minion.breakdown = newEnv.minion.breakdown
				end
				-- Make any necessary corrections to breakdown
				env.player.breakdown.ManaCost = nil
				if newSkill.minion then
					env.minion.breakdown = newEnv.minion.breakdown
				end
			end
			
  
			
		else
			activeSkill.infoMessage2 = "未发现救世者可用的主动技能"
		end
	end
	-- Calculate combined DPS estimate, including DoTs
	local baseDPS = output[(skillData.showAverage and "AverageDamage") or "TotalDPS"]
	output.CombinedDPS = baseDPS
	output.CombinedAvg = baseDPS
	if skillFlags.dot then
		output.CombinedDPS = output.CombinedDPS + (output.TotalDot or 0)
		output.WithDotDPS = baseDPS + (output.TotalDot or 0)
	end
	if quantityMultiplier > 1 and output.TotalPoisonDPS then
		output.TotalPoisonDPS = output.TotalPoisonDPS * quantityMultiplier
	end
	if skillData.showAverage then
		output.CombinedDPS = output.CombinedDPS + (output.TotalPoisonAverageDamage or 0)
		output.WithPoisonAverageDamage = baseDPS + (output.TotalPoisonAverageDamage or 0)
	else
		output.CombinedDPS = output.CombinedDPS + (output.TotalPoisonDPS or 0)
		output.WithPoisonDPS = baseDPS + (output.TotalPoisonDPS or 0)
	end
	if skillFlags.ignite then
		if skillFlags.igniteCanStack then
			if skillData.showAverage then
				output.CombinedDPS = output.CombinedDPS + output.TotalIgniteDPS
				output.CombinedAvg = output.CombinedDPS + output.IgniteDamage
			else
				output.CombinedDPS = output.CombinedDPS + output.TotalIgniteDPS
				output.WithIgniteDPS = baseDPS + output.TotalIgniteDPS
			end
		elseif skillData.showAverage then
			
			output.WithIgniteDPS = baseDPS + output.IgniteDamage
			output.CombinedDPS = output.CombinedDPS + output.IgniteDPS
			output.CombinedAvg = output.CombinedAvg + output.IgniteDamage
		else
			output.WithIgniteDPS = baseDPS + output.IgniteDPS
			output.CombinedDPS = output.CombinedDPS + output.IgniteDPS
		end
	else
		output.WithIgniteDPS = baseDPS
	end
	if skillFlags.bleed then
		if skillData.showAverage then
			output.WithBleedDPS = baseDPS + output.BleedDamage
			output.CombinedDPS = output.CombinedDPS + output.BleedDPS
			output.CombinedAvg = output.CombinedAvg + output.BleedDamage
		else
			output.WithBleedDPS = baseDPS + output.BleedDPS
			output.CombinedDPS = output.CombinedDPS + output.BleedDPS
		end
	else
		output.WithBleedDPS = baseDPS
	end
	if skillFlags.decay then
		output.CombinedDPS = output.CombinedDPS + output.DecayDPS
	end
	output.TotalDotDPS = (output.TotalDot or 0) + (output.TotalPoisonDPS or 0) + (output.TotalIgniteDPS or output.IgniteDPS or 0) + (output.BleedDPS or 0) + (output.DecayDPS or 0)
	
	if skillFlags.impale then
		if skillFlags.attack then
			output.ImpaleHit = ((output.MainHand.PhysicalHitAverage or output.OffHand.PhysicalHitAverage) + (output.OffHand.PhysicalHitAverage or output.MainHand.PhysicalHitAverage)) / 2 * (1-output.CritChance/100) + ((output.MainHand.PhysicalCritAverage or output.OffHand.PhysicalCritAverage) + (output.OffHand.PhysicalCritAverage or output.MainHand.PhysicalCritAverage)) / 2 * (output.CritChance/100)
			if skillData.doubleHitsWhenDualWielding and skillFlags.bothWeaponAttack then
				output.ImpaleHit = output.ImpaleHit * 2
			end
		else
			output.ImpaleHit = output.PhysicalHitAverage * (1-output.CritChance/100) + output.PhysicalCritAverage * (output.CritChance/100)
		end
		output.ImpaleDPS = output.ImpaleHit * ((output.ImpaleModifier or 1) - 1) * output.HitChance / 100 * (skillData.dpsMultiplier or 1)
		if skillData.showAverage then
			output.WithImpaleDPS = output.AverageDamage + output.ImpaleDPS
		else
			skillFlags.notAverage = true
			output.ImpaleDPS = output.ImpaleDPS * (output.HitSpeed or output.Speed)
			output.WithImpaleDPS = output.TotalDPS + output.ImpaleDPS
		end
		if quantityMultiplier > 1 then
			output.ImpaleDPS = output.ImpaleDPS * quantityMultiplier
		end
		output.CombinedDPS = output.CombinedDPS + output.ImpaleDPS
		if breakdown then
			breakdown.ImpaleDPS = {}
			t_insert(breakdown.ImpaleDPS, s_format("%.2f ^8(平均物理击中)", output.ImpaleHit))
			t_insert(breakdown.ImpaleDPS, s_format("x %.2f ^8(命中率)", output.HitChance / 100))
			if skillFlags.notAverage then
				t_insert(breakdown.ImpaleDPS, output.HitSpeed and s_format("x %.2f ^8(击中速率)", output.HitSpeed) or s_format("x %.2f ^8(%s rate)", output.Speed, skillFlags.attack and "attack" or "cast"))
			end
			t_insert(breakdown.ImpaleDPS, s_format("x %.2f ^8(穿刺伤害加成)", ((output.ImpaleModifier or 1) - 1)))
			if skillData.dpsMultiplier then
				t_insert(breakdown.ImpaleDPS, s_format("x %g ^8(这个技能的dps伤害加成)", skillData.dpsMultiplier))
			end
			if quantityMultiplier > 1 then
				t_insert(breakdown.ImpaleDPS, s_format("x %g ^8(这个技能的数量加成)", quantityMultiplier))
			end
			t_insert(breakdown.ImpaleDPS, s_format("= %.1f", output.ImpaleDPS))
		end
	end
	if output.CullMultiplier > 1 then
		output.CullingDPS = output.CombinedDPS * (output.CullMultiplier - 1)
	end
	output.CombinedDPS = output.CombinedDPS * output.CullMultiplier
	if activeSkill.mirage and activeSkill.mirage.output and activeSkill.mirage.output.TotalDPS then
		local mirageCount = activeSkill.mirage.count or 1
		output.MirageDPS = activeSkill.mirage.output.TotalDPS * mirageCount
		output.CombinedDPS = output.CombinedDPS + activeSkill.mirage.output.TotalDPS * mirageCount

		if activeSkill.mirage.output.IgniteDPS and activeSkill.mirage.output.IgniteDPS > (output.IgniteDPS or 0) then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.IgniteDPS
			output.IgniteDPS = 0
		end
		if activeSkill.mirage.output.BleedDPS and activeSkill.mirage.output.BleedDPS > (output.BleedDPS or 0) then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.BleedDPS
			output.BleedDPS = 0
		end

		if activeSkill.mirage.output.PoisonDPS then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.PoisonDPS * mirageCount
			output.CombinedDPS = output.CombinedDPS + activeSkill.mirage.output.PoisonDPS * mirageCount
		end
		if activeSkill.mirage.output.ImpaleDPS then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.ImpaleDPS * mirageCount
			output.CombinedDPS = output.CombinedDPS + activeSkill.mirage.output.ImpaleDPS * mirageCount
		end
		if activeSkill.mirage.output.DecayDPS then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.DecayDPS
			output.CombinedDPS = output.CombinedDPS + activeSkill.mirage.output.DecayDPS
		end
		if activeSkill.mirage.output.TotalDot and (skillFlags.DotCanStack or not output.TotalDot or output.TotalDot == 0) then
			output.MirageDPS = output.MirageDPS + activeSkill.mirage.output.TotalDot * (skillFlags.DotCanStack and mirageCount or 1)
			output.CombinedDPS = output.CombinedDPS + activeSkill.mirage.output.TotalDot * (skillFlags.DotCanStack and mirageCount or 1)
		end
	end
	
end

