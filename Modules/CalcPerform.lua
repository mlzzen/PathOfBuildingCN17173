-- Path of Building
--
-- Module: Calc Perform
-- Manages the offence/defence calculations.
--
local calcs = ...

local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local m_min = math.min
local m_max = math.max
local m_ceil = math.ceil
local m_floor = math.floor
local m_modf = math.modf
local s_format = string.format
local bor = bit.bor
local band = bit.band


-- Identify the trigger action skill for trigger conditions, take highest Attack Per Second 
local function findTriggerSkill(env, skill, source, triggerRate, reqManaCost)
	local uuid = cacheSkillUUID(skill)
	if not GlobalCache.cachedData["CACHE"][uuid] then
		calcs.buildActiveSkill(env, "CACHE", skill)
		env.dontCache = true
	end

	if GlobalCache.cachedData["CACHE"][uuid] then
		-- Below code sets the trigger skill to highest APS skill it finds that meets all conditions
		local cachedSpeed = GlobalCache.cachedData["CACHE"][uuid].Speed
		local cachedManaCost = GlobalCache.cachedData["CACHE"][uuid].ManaCost

		if ((not source and cachedSpeed) or (cachedSpeed and cachedSpeed > triggerRate)) and 
			((reqManaCost and cachedManaCost and cachedManaCost >= reqManaCost) or not reqManaCost) then
			return skill, GlobalCache.cachedData["CACHE"][uuid].Speed
		end
	end
	return source, triggerRate
end



-- Calculate Trigger Rate Cap accounting for ICDR
local function getTriggerActionTriggerRate(baseActionCooldown, env, breakdown, focus)
	local baseActionCooldown = env.player.mainSkill.skillData.cooldown
	local icdr = 1
	if focus then
		icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "FocusCooldownRecovery")
		env.player.mainSkill.skillData.focussed = true
	else
		icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
	end
	local modActionCooldown = baseActionCooldown / (icdr)
	local rateCapAdjusted = m_ceil(modActionCooldown * data.misc.ServerTickRate) / data.misc.ServerTickRate
	local extraICDRNeeded = m_ceil((modActionCooldown - rateCapAdjusted + data.misc.ServerTickTime) * icdr * 1000)
	if breakdown then
		breakdown.ActionTriggerRate = {
			s_format("%.2f ^8(被触发的基础冷却时间)", baseActionCooldown),
			s_format("/ %.2f ^8(提高/降低 冷却速度)", icdr),
			s_format("= %.4f ^8(最终冷却时间)", modActionCooldown),
			s_format(""),
			s_format("%.3f ^8(调整为服务器触发速率)", rateCapAdjusted),			
			s_format("^8(需要额外的冷却缩减 %d%% 将会到达下个触发点)", extraICDRNeeded),
			s_format(""),
			s_format("触发速率:"),
			s_format("1 / %.3f", rateCapAdjusted),
			s_format("= %.2f ^8每秒", 1 / rateCapAdjusted),
			
		}
	end
	
	return 1 / rateCapAdjusted
end

-- Calculate Trigger Rate
-- This is achieved by simulating a 100 second cast rotation
local function calcMultiSpellRotationImpact(env, skillRotation, sourceAPS)
	
	local SIM_TIME = 100.0
	local TIME_STEP = 0.0001
	local index = 1
	local time = 0
	local tick = 0
	local currTick = 0
	local next_trigger = 0
	local trigger_increment = 1 / sourceAPS
	local wasted = 0

	while time < SIM_TIME do
		local currIndex = index

		if time >= next_trigger then
			while skillRotation[index].next_trig > time do
				index = (index % #skillRotation) + 1
				if index == currIndex then
					wasted = wasted + 1
					-- Triggers are free from the server tick so cooldown starts at current time
					next_trigger = time + trigger_increment
					break
				end
			end

			if skillRotation[index].next_trig <= time then				
				skillRotation[index].count = skillRotation[index].count + 1
				-- Cooldown starts at the beginning of current tick
				skillRotation[index].next_trig = currTick + skillRotation[index].cd
				local tempTick = tick

				while skillRotation[index].next_trig > tempTick do
					tempTick = tempTick + (1/data.misc.ServerTickRate)
				end
				-- Cooldown ends at the start of the next tick. Price is right rules.
				skillRotation[index].next_trig = tempTick
				index = (index % #skillRotation) + 1
				next_trigger = time + trigger_increment
			end
		end
		-- Increment time by smallest reasonable amount to attempt to hit every trigger event and every server tick. Frees attacks from the server tick. 
		time = time + TIME_STEP
		-- Keep track of the server tick as the trigger cooldown is still bound by it
		if tick < time then
			currTick = tick
			tick = tick + (1/data.misc.ServerTickRate)
		end
	end
	local mainRate = 0
	local trigRateTable = { simTime = SIM_TIME, rates = {}, }
	if wasted > 0 then
		trigRateTable.extraSimInfo = "存在被浪费的触发机会. 提高你的冷却速度也许可以修复它."
	else
		trigRateTable.extraSimInfo = "干得好！没有被浪费的触发机会"
		t_insert(trigRateTable.rates, { name = "无 击中被浪费_ _ ", rate = wasted / SIM_TIME })
	end
	for _, sd in ipairs(skillRotation) do
		if cacheSkillUUID(env.player.mainSkill) == sd.uuid then
			mainRate = sd.count / SIM_TIME
		end
		t_insert(trigRateTable.rates, { name = sd.uuid, rate = sd.count / SIM_TIME })
	end
	return mainRate, trigRateTable
end


-- Calculate the actual Trigger rate of active skill causing the trigger
local function calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown, dualWield)
	-- Get action trigger rate
	if sourceAPS == nil and source.skillTypes[SkillType.Channelled] then
		output.ActionTriggerRate = 1 / (source.skillData.triggerTime or 1)
		if breakdown then
			breakdown.ActionTriggerRate = {
				s_format("%.2f ^8(被触发的基础冷却时间)", source.skillData.triggerTime),
				s_format(""),
				s_format("触发速率:"),
				s_format("1 / %.2f", source.skillData.triggerTime),
				s_format("= %.2f ^8每秒", output.ActionTriggerRate),
			}
		end
	else
		output.ActionTriggerRate = getTriggerActionTriggerRate(env.player.mainSkill.skillData.cooldown, env, breakdown)
	end
	local trigRate
	local skillRotationImpact = #spellCount
	if sourceAPS ~= nil then
		output.SourceTriggerRate = sourceAPS / skillRotationImpact
		if dualWield then
			output.SourceTriggerRate, simBreakdown = calcMultiSpellRotationImpact(env, spellCount, sourceAPS)
			if breakdown then
				breakdown.SourceTriggerRate = {
					s_format("(%.2f ^8(【%s】的每秒攻击)", sourceAPS * 2, source.activeEffect.grantedEffect.name),
					s_format("/ 2) ^8(双持加成)"),
					s_format("/ %.2f ^8(模拟连接法术的影响)", sourceAPS / output.SourceTriggerRate),
					s_format("= %.2f ^8每秒", output.SourceTriggerRate),
					s_format(""),
					s_format("模拟"),
					s_format("模拟持续时间: %.2f", simBreakdown.simTime),
				}
				if simBreakdown.extraSimInfo then
					t_insert(breakdown.SourceTriggerRate, "")
					t_insert(breakdown.SourceTriggerRate, simBreakdown.extraSimInfo)
				end
				breakdown.SimData = {
					rowList = { },
					colList = {
						{ label = "速率", key = "rate" },
						{ label = "技能名称", key = "skillName" },
						{ label = "插槽名称", key = "slotName" },
						{ label = "技能位置", key = "gemIndex" },
					},
				}
				for _, rateData in ipairs(simBreakdown.rates) do
					local t = { }
					for str in string.gmatch(rateData.name, "([^_]+)") do
						t_insert(t, str)
		
					end
					local row = {
						rate = rateData.rate,
						skillName = t[1],
						slotName = t[2],
						gemIndex = t[3],
					}
					t_insert(breakdown.SimData.rowList, row)
				end
			end
		else
			output.SourceTriggerRate, simBreakdown = calcMultiSpellRotationImpact(env, spellCount, sourceAPS)
			if breakdown then
				breakdown.SourceTriggerRate = {
					s_format("%.2f ^8(【%s】的每秒攻击)", sourceAPS, source.activeEffect.grantedEffect.name),
					s_format("/ %.2f ^8(模拟连接法术的影响)", sourceAPS / output.SourceTriggerRate),
					s_format("= %.2f ^8每秒", output.SourceTriggerRate),
					s_format(""),
					s_format("模拟"),
					s_format("模拟持续时间: %.2f", simBreakdown.simTime),
				}
				if simBreakdown.extraSimInfo then
					t_insert(breakdown.SourceTriggerRate, "")
					t_insert(breakdown.SourceTriggerRate, simBreakdown.extraSimInfo)
				end
				breakdown.SimData = {
					rowList = { },
					colList = {
						{ label = "速率", key = "rate" },
						{ label = "技能名称", key = "skillName" },
						{ label = "插槽名称", key = "slotName" },
						{ label = "技能位置", key = "gemIndex" },
					},
				}
				for _, rateData in ipairs(simBreakdown.rates) do
					local t = { }
					for str in string.gmatch(rateData.name, "([^_]+)") do
						t_insert(t, str)
					end
					local row = {
						rate = rateData.rate,
						skillName = t[1],
						slotName = t[2],
						gemIndex = t[3],
					}
					t_insert(breakdown.SimData.rowList, row)
				end
			end
			
		end
		-- Set trigger rate
		trigRate = m_min(output.SourceTriggerRate, output.ActionTriggerRate)
	else
		output.SourceTriggerRate = output.ActionTriggerRate / skillRotationImpact
		if breakdown then
			breakdown.SourceTriggerRate = {
				s_format("%.2f ^8(【%s】的每秒触发)", output.ActionTriggerRate, source.activeEffect.grantedEffect.name),
				s_format("/ %.2f ^8(连接的被触发主动技能的数量)", skillRotationImpact),
				s_format("= %.2f ^8每秒", output.SourceTriggerRate),
			}
		end
		-- Set trigger rate
		trigRate = output.SourceTriggerRate
	 
	end

	
	-- Adjust for server tick rate
	local trigCD = 1 / trigRate
	
	if breakdown then
		breakdown.ServerTriggerRate = {
			s_format("%.2f ^8('触发速率上限' 和 '技能触发速率' 之间的较小值)", trigRate),			
		}
	end
	output.ServerTriggerRate = trigRate
	return trigRate
end


-- Account for APS modifications do to Dual Wield or Simultaneous Strikes
local function calcDualWieldImpact(env, sourceAPS, skillDoubleHitsWhenDualWielding)
	-- See if we are dual wielding
	local dualWield = false
	if env.player.weaponData1.type and env.player.weaponData2.type then
		dualWield = true
		sourceAPS = sourceAPS * 0.5
	end
	--lucifer
	-- See if we are using a trigger skill that hits with both weapons simultaneously
	if dualWield and skillDoubleHitsWhenDualWielding then
		-- those source skills hit with both weapons simultaneously, thus doubling the trigger rate
		sourceAPS = sourceAPS * 2.0
	end
	return sourceAPS, dualWield
end


-- Add trigger-based damage modifiers
local function addTriggerIncMoreMods(activeSkill, sourceSkill)
	for _,  value in ipairs(activeSkill.skillModList:Tabulate("INC", sourceSkill.skillCfg, "TriggeredDamage")) do
		activeSkill.skillModList:NewMod("Damage", "INC", value.mod.value, value.mod.source, value.mod.flags, value.mod.keywordFlags, unpack(value.mod))
	end
	for _,  value in ipairs(activeSkill.skillModList:Tabulate("MORE", sourceSkill.skillCfg, "TriggeredDamage")) do
		activeSkill.skillModList:NewMod("Damage", "MORE", value.mod.value, value.mod.source, value.mod.flags, value.mod.keywordFlags, unpack(value.mod))
	end
end



local function getUniqueSkillProperty(env, strUniqueSkill, strProperty)
	if env.data.skills[strUniqueSkill] and env.data.skills[strUniqueSkill].levels and env.data.skills[strUniqueSkill].levels[1] then
		return env.data.skills[strUniqueSkill].levels[1][strProperty]
	end
	return nil
end

-- Find unique item trigger name
local function getUniqueItemTriggerName(skill)
	
	if skill.supportList and #skill.supportList >= 1 then
		for _, gemInstance in ipairs(skill.supportList) do
			if gemInstance.grantedEffect and gemInstance.grantedEffect.fromItem then
				return gemInstance.grantedEffect.name
			end
		end
	end
	return ""
end

local function getTriggerDefaultCooldown(supportList, name)
	for _, support in ipairs(supportList) do
		if support.grantedEffect and support.grantedEffect.id == name then
			return support.grantedEffect.levels[support.level].cooldown
		end
	end
	return 100
end

-- Merge an instance of a buff, taking the highest value of each modifier
local function mergeBuff(src, destTable, destKey)
	if not destTable[destKey] then
		destTable[destKey] = new("ModList")
	end
	local dest = destTable[destKey]
	for _, mod in ipairs(src) do
		local match = false
		if mod.type ~= "LIST" then
			for index, destMod in ipairs(dest) do
				if modLib.compareModParams(mod, destMod) then
					if type(destMod.value) == "number" and mod.value > destMod.value then
						dest[index] = mod
					end
					match = true
					break
				end
			end
		else
			--lucifer buff叠加计算
			for index, destMod in ipairs(dest) do			
				if mod.value 
				and type(mod.value) ~= "number"
				and mod.value.mod 				
				and type(destMod.value) ~= "number"
				and destMod.value and destMod.value.mod then
					if modLib.compareModParams(mod.value.mod, destMod.value.mod) then
						
						if type(destMod.value.mod.value) == "number" and mod.value.mod.value > destMod.value.mod.value then
							dest[index] = mod
						end
						match = true
						break
					end	
				end
				
			end
		end
		if not match then
			t_insert(dest, mod)
		end
	end
end

local function fuckCnKeystones(name)

return name:gsub("致死定罪","凡人的信念")

end


local function fuckCnNotable(name)
--中点命名问题处理
return name 

end


-- Merge keystone modifiers
local function mergeKeystones(env)
	local modDB = env.modDB

	for _, name in ipairs(modDB:List(nil, "Keystone")) do
		name =fuckCnKeystones(name)
		
		if not env.keystonesAdded[name]  and env.spec.tree.keystoneMap[name] then
			env.keystonesAdded[name] = true		
			
			modDB:AddList(env.spec.tree.keystoneMap[name].modList)
		end
	end
end



-- Calculate attributes and life/mana pools, and set conditions
local function doActorAttribsPoolsConditions(env, actor)
	local modDB = actor.modDB
	local output = actor.output
	local breakdown = actor.breakdown
	local condList = modDB.conditions


	
	-- Set conditions
	if (actor.itemList["Weapon 2"] and actor.itemList["Weapon 2"].type == "Shield") or (actor == env.player and env.aegisModList) then
		condList["UsingShield"] = true
	end
	if not actor.itemList["Weapon 2"] then
		condList["OffHandIsEmpty"] = true
	end
	if actor.weaponData1.type == "None" then
		condList["Unarmed"] = true
		 
		if  not actor.itemList["Weapon 2"]  and 
		not actor.itemList["Gloves"] then
			condList["Unencumbered"] = true
		end
	else
		 
		if actor.weaponData1 and actor.weaponData1.quality then 
			output["QualityOnWeapon 1"] = actor.weaponData1.quality
		end		
		local info = env.data.weaponTypeInfo[actor.weaponData1.type]
		condList["Using"..info.flag] = true
        if actor.weaponData1.countsAsAll1H then
            condList["UsingAxe"] = true
            condList["UsingSword"] = true
            condList["UsingDagger"] = true
            condList["UsingMace"] = true
            condList["UsingClaw"] = true
			-- GGG stated that a single Varunastra satisfied requirement for wielding two different weapons
			condList["WieldingDifferentWeaponTypes"] = true
        end
		if info.melee then
			condList["UsingMeleeWeapon"] = true
		end
		if info.oneHand then
			condList["UsingOneHandedWeapon"] = true
		else
			condList["UsingTwoHandedWeapon"] = true
		end
	end
	if actor.weaponData2.type then
		if actor.weaponData2 and actor.weaponData2.quality then 
			output["QualityOnWeapon 2"] = actor.weaponData2.quality
		end
		local info = env.data.weaponTypeInfo[actor.weaponData2.type]
		condList["Using"..info.flag] = true
        if actor.weaponData2.countsAsAll1H then
            condList["UsingAxe"] = true
            condList["UsingSword"] = true
            condList["UsingDagger"] = true
            condList["UsingMace"] = true
            condList["UsingClaw"] = true
			-- GGG stated that a single Varunastra satisfied requirement for wielding two different weapons
			condList["WieldingDifferentWeaponTypes"] = true
        end
		if info.melee then
			condList["UsingMeleeWeapon"] = true
		end
		if info.oneHand then
			condList["UsingOneHandedWeapon"] = true
		else
			condList["UsingTwoHandedWeapon"] = true
		end
	end
	
	if actor.weaponData1.type and actor.weaponData2.type and actor.weaponData1.type ~= "None" then
		condList["DualWielding"] = true
		if (actor.weaponData1.type == "Claw" or actor.weaponData1.countsAsAll1H) and (actor.weaponData2.type == "Claw" or actor.weaponData2.countsAsAll1H) then
			condList["DualWieldingClaws"] = true
		end
		if (actor.weaponData1.type == "Dagger" or actor.weaponData1.countsAsAll1H) and (actor.weaponData2.type == "Dagger" or actor.weaponData2.countsAsAll1H) then
			condList["DualWieldingDaggers"] = true
		end
		if (env.data.weaponTypeInfo[actor.weaponData1.type].label or actor.weaponData1.type) ~= (env.data.weaponTypeInfo[actor.weaponData2.type].label or actor.weaponData2.type) then
			local info1 = env.data.weaponTypeInfo[actor.weaponData1.type]
			local info2 = env.data.weaponTypeInfo[actor.weaponData2.type]
			if info1.oneHand and info2.oneHand then
				condList["WieldingDifferentWeaponTypes"] = true
			end
		end
	end
	if env.mode_combat then	
		
		if not modDB:Flag(nil, "NeverCrit") then
			condList["CritInPast8Sec"] = true
		end
		if not actor.mainSkill.skillData.triggered and not actor.mainSkill.skillFlags.trap and not actor.mainSkill.skillFlags.mine and not actor.mainSkill.skillFlags.totem then 
			if actor.mainSkill.skillFlags.attack then
				condList["AttackedRecently"] = true
			elseif actor.mainSkill.skillFlags.spell then
				condList["CastSpellRecently"] = true
			end
			if actor.mainSkill.skillTypes[SkillType.MovementSkill] then
				condList["UsedMovementSkillRecently"] = true
			end
			if actor.mainSkill.skillFlags.minion then
				condList["UsedMinionSkillRecently"] = true
			end
			if actor.mainSkill.skillTypes[SkillType.Vaal] then
				condList["UsedVaalSkillRecently"] = true
			end
			if actor.mainSkill.skillTypes[SkillType.Channelled] then
				condList["Channelling"] = true
			end
		end
		if actor.mainSkill.skillFlags.hit and not actor.mainSkill.skillFlags.trap and not actor.mainSkill.skillFlags.mine and not actor.mainSkill.skillFlags.totem then
			condList["HitRecently"] = true
		end
		if actor.mainSkill.skillFlags.totem then
			condList["HaveTotem"] = true
			condList["SummonedTotemRecently"] = true
		end
		if actor.mainSkill.skillFlags.mine then
			condList["DetonatedMinesRecently"] = true
		end
		
		if modDB:Sum("BASE", nil, "ScorchChance") > 0 or modDB:Flag(nil, "CritAlwaysAltAilments") and not modDB:Flag(nil, "NeverCrit") then
			condList["CanInflictScorch"] = true
		end
		if modDB:Sum("BASE", nil, "BrittleChance") > 0 or modDB:Flag(nil, "CritAlwaysAltAilments") and not modDB:Flag(nil, "NeverCrit") then
			condList["CanInflictBrittle"] = true
		end
		if modDB:Sum("BASE", nil, "SapChance") > 0 or modDB:Flag(nil, "CritAlwaysAltAilments") and not modDB:Flag(nil, "NeverCrit") then
			condList["CanInflictSap"] = true
		end
	end
	if env.mode_effective then
		if modDB:Sum("BASE", nil, "FireExposureChance") > 0 then
			condList["CanApplyFireExposure"] = true
		end
		if modDB:Sum("BASE", nil, "ColdExposureChance") > 0 then
			condList["CanApplyColdExposure"] = true
		end
		if modDB:Sum("BASE", nil, "LightningExposureChance") > 0 then
			condList["CanApplyLightningExposure"] = true
		end
	end
--计算 属性
	-- Calculate attributes
	for _, stat in pairs({"Str","Dex","Int","Devotion"}) do
		output[stat] = m_max(round(calcLib.val(modDB, stat)), 0)		
		output[stat] = modDB:Override(nil,stat)	 or output[stat]
		if breakdown then
			breakdown[stat] = breakdown.simple(nil, nil, output[stat], stat)
		end
	end
--计算大于小于
	output.LowestAttribute = m_min(output.Str, output.Dex, output.Int)
	condList["DexHigherThanInt"] = output.Dex > output.Int
	condList["DexHigherThanStr"] = output.Dex > output.Str	
	condList["IntHigherThanStr"] = output.Int > output.Str
	condList["IntHigherThanDex"] = output.Int > output.Dex	
	condList["StrHigherThanDex"] = output.Str > output.Dex
	condList["StrHigherThanInt"] = output.Str > output.Int
	
--大于小于之后重新计算属性（如：力量高于智慧时，敏捷提高 15%）
	for _, stat in pairs({"Str","Dex","Int"}) do
		output[stat] = m_max(round(calcLib.val(modDB, stat)), 0)		
		output[stat] = modDB:Override(nil,stat)	 or output[stat]
		if breakdown then
			breakdown[stat] = breakdown.simple(nil, nil, output[stat], stat)
		end
	end
	
	-- Calculate total attributes
	output.TotalAttr = output.Str + output.Dex + output.Int

	
	 
	-- Add attribute bonuses
	if not modDB:Flag(nil, "NoAttributeBonuses") then
		if not modDB:Flag(nil, "NoStrengthAttributeBonuses") then
			if not modDB:Flag(nil, "NoStrBonusToLife") then
				modDB:NewMod("Life", "BASE", m_floor(output.Str / 2), "力量")
			end
			local strDmgBonusRatioOverride = modDB:Sum("BASE", nil, "StrDmgBonusRatioOverride")
			if strDmgBonusRatioOverride > 0 then
				actor.strDmgBonus = round((output.Str + modDB:Sum("BASE", nil, "DexIntToMeleeBonus")) * strDmgBonusRatioOverride)
			else
				actor.strDmgBonus = round((output.Str + modDB:Sum("BASE", nil, "DexIntToMeleeBonus")) / 5)
			end
			modDB:NewMod("PhysicalDamage", "INC", actor.strDmgBonus, "力量", ModFlag.Melee)
		end
		if not modDB:Flag(nil, "NoDexterityAttributeBonuses") then
			modDB:NewMod("Accuracy", "BASE", output.Dex * 2, "敏捷")
			if not modDB:Flag(nil, "IronReflexes") then
				modDB:NewMod("Evasion", "INC", round(output.Dex / 5), "敏捷")
			end
		end
		if not modDB:Flag(nil, "NoIntelligenceAttributeBonuses") then
			if not modDB:Flag(nil, "NoIntBonusToMana") then
				modDB:NewMod("Mana", "BASE", round(output.Int / 2), "智慧")
			end
			modDB:NewMod("EnergyShield", "INC", round(output.Int / 5), "智慧")
		end
	end
	
	-- Check shrine buffs, must be done before life pool calculated for massive shrine
	for _, value in ipairs(modDB:List(nil, "ShrineBuff")) do
		modDB:ScaleAddList({ value.mod }, calcLib.mod(modDB, nil, "BuffEffectOnSelf", "ShrineBuffEffect"))
	end

	-- Life/mana pools
	output.ChaosInoculation = modDB:Flag(nil, "ChaosInoculation")
	if output.ChaosInoculation then
		output.Life = 1
		condList["FullLife"] = true
	else
		local base = modDB:Sum("BASE", nil, "Life")
		local inc = modDB:Sum("INC", nil, "Life")		
		local more = modDB:More(nil, "Life")
	 
		local conv = modDB:Sum("BASE", nil, "LifeConvertToEnergyShield")
		if conv > 100 then 
			conv = 100
		end 
		if conv < 0 then 
			conv = 0
		end 
		output.Life = round(base * (1 + inc/100) * more * (1 - conv/100))
		
		if breakdown then
			if inc ~= 0 or more ~= 1 or conv ~= 0 then
				breakdown.Life = { }
				breakdown.Life[1] = s_format("%g ^8(基础)", base)
				if inc ~= 0 then
					t_insert(breakdown.Life, s_format("x %.2f ^8(提高/降低)", 1 + inc/100))
				end
				if more ~= 1 then
					t_insert(breakdown.Life, s_format("x %.2f ^8(额外提高/降低)", more))
				end
				if conv ~= 0 then
					t_insert(breakdown.Life, s_format("x %.2f ^8(转化为能量护盾)", 1 - conv/100))
				end
				t_insert(breakdown.Life, s_format("= %g", output.Life))
			end
		end
	end
	local convMana = modDB:Sum("BASE", nil, "ManaConvertToDoubleArmour")
	
	
	local baseMana = modDB:Sum("BASE", nil, "Mana")
	local incMana = modDB:Sum("INC", nil, "Mana")
	local moreMana = modDB:More(nil, "Mana")
	
	output.Mana = round(calcLib.val(modDB, "Mana")* (1 - convMana/100))
	if breakdown then
		breakdown.Mana = breakdown.simple(nil, nil, output.Mana, "Mana")
		if incMana ~= 0 or moreMana ~= 1 or convMana ~= 0 then
				breakdown.Mana = { }
				breakdown.Mana[1] = s_format("%g ^8(基础)", baseMana)
				if incMana ~= 0 then
					t_insert(breakdown.Mana, s_format("x %.2f ^8(提高/降低)", 1 + incMana/100))
				end
				if moreMana ~= 1 then
					t_insert(breakdown.Mana, s_format("x %.2f ^8(额外提高/降低)", moreMana))
				end
				if convMana ~= 0 then
					t_insert(breakdown.Mana, s_format("x %.2f ^8(转化为护甲)", 1 - convMana/100))
				end
				t_insert(breakdown.Mana, s_format("= %g", output.Mana))
		end
		
	end

end
-- Calculate life/mana reservation
---@param actor table
local function doActorLifeManaReservation(actor)
	local modDB = actor.modDB
	local output = actor.output
	local condList = modDB.conditions

	-- Life/mana reservation
	for _, pool in pairs({"Life", "Mana"}) do
		local max = output[pool]
		local reserved
		if max > 0 then
			reserved = (actor["reserved_"..pool.."Base"] or 0) + m_ceil(max * (actor["reserved_"..pool.."Percent"] or 0) / 100)
			output[pool.."Reserved"] = m_min(reserved, max)
			output[pool.."ReservedPercent"] = m_min(reserved / max * 100, 100)
			output[pool.."Unreserved"] = max - reserved
			output[pool.."UnreservedPercent"] = (max - reserved) / max * 100
			if (max - reserved) / max <= data.misc.LowPoolThreshold then
				condList["Low"..pool] = true
			end
		else
			reserved = 0
		end
		for _, value in ipairs(modDB:List(nil, "GrantReserved"..pool.."AsAura")) do
			local auraMod = copyTable(value.mod)
			auraMod.value = m_floor(auraMod.value * m_min(reserved, max))
			modDB:NewMod("ExtraAura", "LIST", { mod = auraMod })
		end
	end
end

-- Process charges, enemy modifiers, and other buffs
local function doActorMisc(env, actor)
	local modDB = actor.modDB
	local enemyDB = actor.enemy.modDB
	local output = actor.output
	local condList = modDB.conditions

	-- Calculate current and maximum charges
	output.PowerChargesMin = modDB:Sum("BASE", nil, "PowerChargesMin")
	output.PowerChargesMax = modDB:Sum("BASE", nil, "PowerChargesMax")
	output.FrenzyChargesMin = modDB:Sum("BASE", nil, "FrenzyChargesMin")
	output.FrenzyChargesMax = modDB:Flag(nil, "MaximumFrenzyChargesIsMaximumPowerCharges") and output.PowerChargesMax or modDB:Sum("BASE", nil, "FrenzyChargesMax")	
		
	output.EnduranceChargesMin = modDB:Sum("BASE", nil, "EnduranceChargesMin")
	output.EnduranceChargesMax = modDB:Flag(nil, "MaximumEnduranceChargesIsMaximumFrenzyCharges") and output.FrenzyChargesMax or modDB:Sum("BASE", nil, "EnduranceChargesMax")	
	
	output.BrutalChargesMax= modDB:Flag(nil, "MaximumBrutalChargesIsMaximumEnduranceCharges") and output.EnduranceChargesMax or modDB:Sum("BASE", nil, "BrutalChargesMax")	
	output.AbsorptionChargesMax= modDB:Flag(nil, "MaximumAbsorptionChargesIsMaximumPowerCharges") and output.PowerChargesMax or modDB:Sum("BASE", nil, "AbsorptionChargesMax")	
	output.AfflictionChargesMax= modDB:Flag(nil, "MaximumAfflictionChargesIsMaximumFrenzyCharges") and output.FrenzyChargesMax or modDB:Sum("BASE", nil, "AfflictionChargesMax")	
	
		
	if modDB:Flag(nil, "MinimumBrutalChargesModInsteadToMinimumEnduranceCharges") then 
		output.BrutalChargesMin = output.EnduranceChargesMin
		output.EnduranceChargesMin = 0
	else 
		output.BrutalChargesMin = modDB:Sum("BASE", nil, "BrutalChargesMin")
	end 
	if modDB:Flag(nil, "MinimumAbsorptionChargesModInsteadToMinimumPowerCharges") then 
		output.AbsorptionChargesMin = output.PowerChargesMin
		output.PowerChargesMin = 0
	else 
		output.AbsorptionChargesMin = modDB:Sum("BASE", nil, "AbsorptionChargesMin")
	end 
	if modDB:Flag(nil, "MinimumAfflictionChargesModInsteadToMinimumFrenzyCharges") then 
		output.AfflictionChargesMin = output.FrenzyChargesMin
		output.FrenzyChargesMin = 0
	else 
		output.AfflictionChargesMin = modDB:Sum("BASE", nil, "AfflictionChargesMin")
	end 		
	
	
	output.SiphoningChargesMax = modDB:Sum("BASE", nil, "SiphoningChargesMax")
	output.ChallengerChargesMax = modDB:Sum("BASE", nil, "ChallengerChargesMax")
	output.BlitzChargesMax = modDB:Sum("BASE", nil, "BlitzChargesMax")
	output.InspirationChargesMax = modDB:Sum("BASE", nil, "InspirationChargesMax")
	output.CrabBarriersMax = modDB:Sum("BASE", nil, "CrabBarriersMax")
	output.BloodChargesMax = modDB:Sum("BASE", nil, "BloodChargesMax")

	
	-- Initialize Charges
	output.PowerCharges = 0
	output.FrenzyCharges = 0
	output.EnduranceCharges = 0
	output.SiphoningCharges = 0
	output.ChallengerCharges = 0
	output.BlitzCharges = 0
	output.InspirationCharges = 0
	output.GhostShrouds = 0
	output.BrutalCharges = 0
	output.AbsorptionCharges = 0
	output.AfflictionCharges = 0
	output.BloodCharges = 0
	
	if modDB:Flag(nil, "UsePowerCharges") and  not modDB:Flag(nil, "GainAbsorptionChargesInsteadPowerCharges") then
		output.PowerCharges = modDB:Override(nil, "PowerCharges") or output.PowerChargesMax	
	end
	output.PowerCharges = m_max(output.PowerCharges, m_min(output.PowerChargesMax, output.PowerChargesMin))
	output.RemovablePowerCharges = m_max(output.PowerCharges - output.PowerChargesMin, 0)
	if modDB:Flag(nil, "UseFrenzyCharges") and  not modDB:Flag(nil, "GainAfflictionChargesInsteadFrenzyCharges") then
		output.FrenzyCharges = modDB:Override(nil, "FrenzyCharges") or output.FrenzyChargesMax	
	end
	output.FrenzyCharges = m_max(output.FrenzyCharges, m_min(output.FrenzyChargesMax, output.FrenzyChargesMin))
	output.RemovableFrenzyCharges = m_max(output.FrenzyCharges - output.FrenzyChargesMin, 0)
	if modDB:Flag(nil, "UseEnduranceCharges") and  not modDB:Flag(nil, "GainBrutalChargesInsteadEnduranceCharges") then
		output.EnduranceCharges = modDB:Override(nil, "EnduranceCharges") or output.EnduranceChargesMax
	end
	output.EnduranceCharges = m_max(output.EnduranceCharges, m_min(output.EnduranceChargesMax, output.EnduranceChargesMin))
	output.RemovableEnduranceCharges = m_max(output.EnduranceCharges - output.EnduranceChargesMin, 0)
	
	--新3球
	if modDB:Flag(nil, "UseBrutalCharges") then
		output.BrutalCharges = modDB:Override(nil, "BrutalCharges") or output.BrutalChargesMax	
	end
	output.BrutalCharges = m_max(output.BrutalCharges, m_min(output.BrutalChargesMax, output.BrutalChargesMin))
	output.RemovableBrutalCharges = m_max(output.BrutalCharges - output.BrutalChargesMin, 0)
	
	if modDB:Flag(nil, "UseAfflictionCharges") then
		output.AfflictionCharges = modDB:Override(nil, "AfflictionCharges") or output.AfflictionChargesMax		
	end
	output.AfflictionCharges = m_max(output.AfflictionCharges, m_min(output.AfflictionChargesMax, output.AfflictionChargesMin))
	output.RemovableAfflictionCharges = m_max(output.AfflictionCharges - output.AfflictionChargesMin, 0)
	
	if modDB:Flag(nil, "UseAbsorptionCharges") then
		output.AbsorptionCharges = modDB:Override(nil, "AbsorptionCharges") or output.AbsorptionChargesMax
	end
	output.AbsorptionCharges = m_max(output.AbsorptionCharges, m_min(output.AbsorptionChargesMax, output.AbsorptionChargesMin))
	output.RemovableAbsorptionCharges = m_max(output.AbsorptionCharges - output.AbsorptionChargesMin, 0)
	
	
	if modDB:Flag(nil, "UseSiphoningCharges") then
		output.SiphoningCharges = modDB:Override(nil, "SiphoningCharges") or output.SiphoningChargesMax
	end
	 
	if modDB:Flag(nil, "UseChallengerCharges") then
		output.ChallengerCharges = modDB:Override(nil, "ChallengerCharges") or output.ChallengerChargesMax	
	end
	if modDB:Flag(nil, "UseBlitzCharges") then
		output.BlitzCharges = modDB:Override(nil, "BlitzCharges") or output.BlitzChargesMax
	end
	output.InspirationCharges = modDB:Override(nil, "InspirationCharges") or output.InspirationChargesMax
	
	if modDB:Flag(nil, "UseGhostShrouds") then
		output.GhostShrouds = modDB:Override(nil, "GhostShrouds") or 3
	end
	if modDB:Flag(nil, "CryWolfMinimumPower") and modDB:Sum("BASE", nil, "WarcryPower") < 10 then
		modDB:NewMod("WarcryPower", "OVERRIDE", 10, "来自【恶狼哭号】的战吼威力值下限")
	end
	if modDB:Flag(nil, "WarcryInfinitePower") then
		modDB:NewMod("WarcryPower", "OVERRIDE", 999999, "战吼的威力值无限")
	end
	output.BloodCharges = m_min(modDB:Override(nil, "BloodCharges") or output.BloodChargesMax, output.BloodChargesMax)


	output.WarcryPower = modDB:Override(nil, "WarcryPower") or modDB:Sum("BASE", nil, "WarcryPower") or 0
	output.CrabBarriers = m_min(modDB:Override(nil, "CrabBarriers") or output.CrabBarriersMax, output.CrabBarriersMax)
	output.TotalCharges = output.PowerCharges + output.FrenzyCharges + output.EnduranceCharges
	modDB.multipliers["WarcryPower"] = output.WarcryPower
	modDB.multipliers["PowerCharge"] = output.PowerCharges
	modDB.multipliers["PowerChargeMax"] = output.PowerChargesMax
	modDB.multipliers["RemovablePowerCharge"] = output.RemovablePowerCharges
	modDB.multipliers["FrenzyCharge"] = output.FrenzyCharges
	modDB.multipliers["RemovableFrenzyCharge"] = output.RemovableFrenzyCharges
	modDB.multipliers["EnduranceCharge"] = output.EnduranceCharges
	modDB.multipliers["RemovableEnduranceCharge"] = output.RemovableEnduranceCharges
	modDB.multipliers["TotalCharges"] = output.TotalCharges
	modDB.multipliers["SiphoningCharge"] = output.SiphoningCharges
	modDB.multipliers["ChallengerCharge"] = output.ChallengerCharges
	modDB.multipliers["BlitzCharge"] = output.BlitzCharges
	modDB.multipliers["InspirationCharge"] = output.InspirationCharges
	modDB.multipliers["CrabBarrier"] = output.CrabBarriers
	
	modDB.multipliers["BrutalCharge"] = output.BrutalCharges
	modDB.multipliers["RemovableBrutalCharge"] = output.RemovableBrutalCharges
	modDB.multipliers["AfflictionCharge"] = output.AfflictionCharges
	modDB.multipliers["RemovableAfflictionCharge"] = output.RemovableAfflictionCharges
	modDB.multipliers["AbsorptionCharge"] = output.AbsorptionCharges
	modDB.multipliers["RemovableAbsorptionCharge"] = output.RemovableAbsorptionCharges
	modDB.multipliers["BloodCharge"] = output.BloodCharges
	-- Process enemy modifiers 
	for _, value in ipairs(modDB:List(nil, "EnemyModifier")) do
		enemyDB:AddMod(value.mod)
	end

	-- Add misc buffs/debuffs
	if env.mode_combat then
		if modDB:Flag(nil, "Fortify") then
		
			if modDB:Flag(nil, "FortifyBuffInsteadGrantEvasionRating") then
					local effect = m_floor(30 * (1 + modDB:Sum("INC", nil, "FortifyEffectOnSelf", "BuffEffectOnSelf") / 100))
					modDB:NewMod("Evasion", "MORE", effect, "护体")
			else 
					local effect = m_floor(20 * (1 + modDB:Sum("INC", nil, "FortifyEffectOnSelf", "BuffEffectOnSelf") / 100))
					modDB:NewMod("DamageTakenWhenHit", "MORE", -effect, "护体")			
					
			end
				
				
			
			
			modDB.multipliers["BuffOnSelf"] = (modDB.multipliers["BuffOnSelf"] or 0) + 1
		end
		if modDB:Flag(nil, "Condition:PhantasmalMight") then
			modDB.multipliers["BuffOnSelf"] = (modDB.multipliers["BuffOnSelf"] or 0) + (output.ActivePhantasmLimit or 1) - 1 -- slight hack to not double count the initial buff
		end
		if modDB:Flag(nil, "Elusive") then
			local effect = 1 + modDB:Sum("INC", nil, "ElusiveEffect", "BuffEffectOnSelf") / 100
			-- Override elusive effect if set.			
			if modDB:Override(nil, "ElusiveEffect") then 
				effect = m_min(modDB:Override(nil, "ElusiveEffect") / 100, effect)
			end
			condList["Elusive"] = true
			modDB:NewMod("AvoidPhysicalDamageChance", "BASE", m_floor(15 * effect), "Elusive")
			modDB:NewMod("AvoidLightningDamageChance", "BASE", m_floor(15 * effect), "Elusive")
			modDB:NewMod("AvoidColdDamageChance", "BASE", m_floor(15 * effect), "Elusive")
			modDB:NewMod("AvoidFireDamageChance", "BASE", m_floor(15 * effect), "Elusive")
			modDB:NewMod("AvoidChaosDamageChance", "BASE", m_floor(15 * effect), "Elusive")
			modDB:NewMod("MovementSpeed", "INC", m_floor(30 * effect), "Elusive")

			modDB.multipliers["BuffOnSelf"] = (modDB.multipliers["BuffOnSelf"] or 0) + 1
		end
		if modDB:Flag(nil, "LesserBrutalShrine") then
			local effect = (1 + modDB:Sum("INC", nil, "ShrineEffect", "BuffEffectOnSelf") / 100)
			local effectDamage = m_floor(20 * effect)
			local effectDuration  = m_floor(20 * effect)
			modDB:NewMod("Damage", "INC", effectDamage, "次级狂击神龛")
			modDB:NewMod("EnemyKnockbackChance", "BASE", 100, "次级狂击神龛")
			modDB:NewMod("EnemyStunDuration", "INC", effectDuration, "次级狂击神龛")			
		end
		if modDB:Flag(nil, "LesserMassiveShrine") then
			local effect = (1 + modDB:Sum("INC", nil, "ShrineEffect", "BuffEffectOnSelf") / 100)
			local effectAreaOfEffect = m_floor(20 * effect)
			local effectLife  = m_floor(20 * effect)
			modDB:NewMod("AreaOfEffect", "INC", effectAreaOfEffect, "次级威猛神龛")
			--生命在其他地方处理
		end
		if modDB:Flag(nil, "Onslaught") then
			local effect = m_floor(20 * (1 + modDB:Sum("INC", nil, "OnslaughtEffect", "BuffEffectOnSelf") / 100))
modDB:NewMod("Speed", "INC", effect, "猛攻")
modDB:NewMod("MovementSpeed", "INC", effect, "猛攻")
		end		 
		if modDB:Flag(nil, "Fanaticism") and actor.mainSkill and actor.mainSkill.skillFlags.selfCast then
			local effect = m_floor(75 * (1 + modDB:Sum("INC", nil, "BuffEffectOnSelf") / 100))
			modDB:NewMod("Speed", "MORE", effect, "狂热", ModFlag.Cast)
			modDB:NewMod("Cost", "INC", -effect, "狂热", ModFlag.Cast)
			modDB:NewMod("AreaOfEffect", "INC", effect, "狂热", ModFlag.Cast)
		end
		if modDB:Flag(nil, "UnholyMight") then
			local effect = m_floor(30 * (1 + modDB:Sum("INC", nil, "BuffEffectOnSelf") / 100))
modDB:NewMod("PhysicalDamageGainAsChaos", "BASE", effect, "不洁之力")
		end
		if modDB:Flag(nil, "Tailwind") then
			local effect = m_floor(8 * (1 + modDB:Sum("INC", nil, "TailwindEffectOnSelf", "BuffEffectOnSelf") / 100))
modDB:NewMod("ActionSpeed", "INC", effect, "提速尾流")
		end
		if modDB:Flag(nil, "Adrenaline") then
			local effectMod = 1 + modDB:Sum("INC", nil, "BuffEffectOnSelf") / 100
modDB:NewMod("Damage", "INC", m_floor(100 * effectMod), "肾上腺素")
modDB:NewMod("Speed", "INC", m_floor(25 * effectMod), "肾上腺素")
modDB:NewMod("MovementSpeed", "INC", m_floor(25 * effectMod), "肾上腺素")
modDB:NewMod("PhysicalDamageReduction", "BASE", m_floor(10 * effectMod), "肾上腺素")
		end
		if modDB:Flag(nil, "Convergence") then
			local effect = m_floor(30 * (1 + modDB:Sum("INC", nil, "BuffEffectOnSelf") / 100))
			modDB:NewMod("ElementalDamage", "MORE", effect, "汇聚")
		end
		if modDB:Flag(nil, "HerEmbrace") then
			condList["HerEmbrace"] = true
modDB:NewMod("AvoidStun", "BASE", 100, "女神之拥")
	modDB:NewMod("PhysicalDamageGainAsFire", "BASE", 123, "女神之拥", ModFlag.Sword)
modDB:NewMod("AvoidFreeze", "BASE", 100, "女神之拥")
modDB:NewMod("AvoidChill", "BASE", 100, "女神之拥")
modDB:NewMod("AvoidIgnite", "BASE", 100, "女神之拥")
modDB:NewMod("Speed", "INC", 20, "女神之拥")
modDB:NewMod("MovementSpeed", "INC", 20, "女神之拥")
		end
		if modDB:Flag(nil, "Blind") then
			if not modDB:Flag(nil, "IgnoreBlindHitChance") then
				local effect = 1 + modDB:Sum("INC", nil, "BlindEffect", "BuffEffectOnSelf") / 100
				-- Override Blind effect if set.			
				if modDB:Override(nil, "BlindEffect") then 
					effect = m_min(modDB:Override(nil, "BlindEffect") / 100, effect)
				end
				modDB:NewMod("Accuracy", "MORE", m_floor(-20 * effect), "致盲")
				modDB:NewMod("Evasion", "MORE", m_floor(-20 * effect), "致盲")
			end
		end
		if modDB:Flag(nil, "Chill") then
			local effect = m_max(m_floor(30 * calcLib.mod(modDB, nil, "SelfChillEffect")), 0)
modDB:NewMod("ActionSpeed", "INC", effect * (modDB:Flag(nil, "SelfChillEffectIsReversed") and 1 or -1), "冰缓")
		end
		if modDB:Flag(nil, "Freeze") then
			local effect = m_max(m_floor(70 * calcLib.mod(modDB, nil, "SelfChillEffect")), 0)
modDB:NewMod("ActionSpeed", "INC", -effect, "冰冻")
		end
		if modDB:Flag(nil, "CanLeechLifeOnFullLife") then
			condList["Leeching"] = true
			condList["LeechingLife"] = true
			env.configInput.conditionLeeching = true
		end
		if modDB:Flag(nil, "CanLeechLifeOnFullEnergyShield") then
			condList["Leeching"] = true
			condList["LeechingEnergyShield"] = true
			env.configInput.conditionLeeching = true
		end
		if modDB:Flag(nil, "Condition:InfusionActive") then
			local effect = 1 + modDB:Sum("INC", nil, "InfusionEffect", "BuffEffectOnSelf") / 100
			if modDB:Flag(nil, "Condition:HavePhysicalInfusion") then
				condList["PhysicalInfusion"] = true
				condList["Infusion"] = true
				modDB:NewMod("PhysicalDamage", "MORE", 10 * effect, "Infusion")
			end
			if modDB:Flag(nil, "Condition:HaveFireInfusion") then
				condList["FireInfusion"] = true
				condList["Infusion"] = true
				modDB:NewMod("FireDamage", "MORE", 10 * effect, "Infusion")
			end
			if modDB:Flag(nil, "Condition:HaveColdInfusion") then
				condList["ColdInfusion"] = true
				condList["Infusion"] = true
				modDB:NewMod("ColdDamage", "MORE", 10 * effect, "Infusion")
			end
			if modDB:Flag(nil, "Condition:HaveLightningInfusion") then
				condList["LightningInfusion"] = true
				condList["Infusion"] = true
				modDB:NewMod("LightningDamage", "MORE", 10 * effect, "Infusion")
			end
			if modDB:Flag(nil, "Condition:HaveChaosInfusion") then
				condList["ChaosInfusion"] = true
				condList["Infusion"] = true
				modDB:NewMod("ChaosDamage", "MORE", 10 * effect, "Infusion")
			end
		end
		if modDB:Flag(nil, "Condition:CanGainRage") or modDB:Sum("BASE", nil, "RageRegen") > 0 then
			output.MaximumRage = modDB:Sum("BASE", skillCfg, "MaximumRage")
			
			modDB:NewMod("Multiplier:Rage", "BASE", 1, "Base", { type = "Multiplier", var = "RageStack", limit = output.MaximumRage })
		end
		if modDB:Sum("BASE", nil, "CoveredInAshEffect") > 0 then
			local effect = modDB:Sum("BASE", nil, "CoveredInAshEffect")
			enemyDB:NewMod("FireDamageTaken", "INC", m_min(effect, 20), "灰烬缠身")
		end
		if modDB:Flag(nil, "HasMalediction") then
			modDB:NewMod("DamageTaken", "INC", 10, "恶语术")
			modDB:NewMod("Damage", "INC", -10, "恶语术")
		end
		if modDB:Sum("INC", nil, "VastPowerAoE") > 0 then
			local incVal = modDB:Sum("INC", nil, "VastPowerAoE")
			local maxVal = data.misc.VastPowerMaxAoEPercent
			modDB:NewMod("AreaOfEffect", "INC", incVal, "Vast Power", { type = "Multiplier", var = "PowerCharge", limit = maxVal, limitTotal = true })
		end
		if modDB:Sum("INC", nil, "MurderousEyeJewelCritChance") > 0 then
			local incVal = modDB:Sum("INC", nil, "MurderousEyeJewelCritChance")
			local maxVal = data.misc.MurderousEyeJewelMaxCritChancePercent
			modDB:NewMod("CritChance", "INC", incVal,"Tecrod's Gaze", { type = "Multiplier", var = "凶残之凝珠宝", limit = tonumber(maxVal), limitTotal = true } , { type = "Condition", var = "MainHandAttack" } ,{ type = "SkillType", skillType = SkillType.Attack }) 
		end
		if modDB:Sum("BASE", nil, "MurderousEyeJewelCritMultiplier") > 0 then
			local baseVal = modDB:Sum("BASE", nil, "MurderousEyeJewelCritMultiplier")
			local maxVal = data.misc.MurderousEyeJewelMaxCritCritMultiplierPercent
			modDB:NewMod("CritMultiplier", "BASE", baseVal,"Tecrod's Gaze", { type = "Multiplier", var = "凶残之凝珠宝", limit = tonumber(maxVal), limitTotal = true } , { type = "Condition", var = "OffHandAttack" } ,{ type = "SkillType", skillType = SkillType.Attack }) 
		end
		if modDB:Sum("BASE", nil, "GhastlyEyeJewelMinionsDOTMultiplier") > 0 then
			local baseVal = modDB:Sum("BASE", nil, "GhastlyEyeJewelMinionsDOTMultiplier")
			local maxVal = data.misc.GhastlyEyeJewelMaxMinionsDOTMultiplierPercent		
			modDB:NewMod("DotMultiplier", "BASE", baseVal,"Amanamu's Gaze", { type = "Multiplier", var = "苍白之凝珠宝", limit = tonumber(maxVal), limitTotal = true , actor = "parent" } ) 
			
		end
		
		
		
	end	
end

-- Finalises the environment and performs the stat calculations:
-- 1. Merges keystone modifiers
-- 2. Initialises minion skills
-- 3. Initialises the main skill's minion, if present
-- 4. Merges flask effects
-- 5. Sets conditions and calculates attributes and life/mana pools (doActorAttribsPoolsConditions)
-- 6. Calculates reservations
-- 7. Sets life/mana reservation (doActorLifeManaReservation)
-- 8. Processes buffs and debuffs
-- 9. Processes charges and misc buffs (doActorMisc)
-- 10. Calculates defence and offence stats (calcs.defence, calcs.offence)
function calcs.perform(env, avoidCache)
	local avoidCache = avoidCache or false
	
	local modDB = env.modDB
	local enemyDB = env.enemyDB

	-- Merge keystone modifiers
	env.keystonesAdded = { }
	env.notableAdded = { }
	mergeKeystones(env)
	--mergeNotable(env)

	-- Build minion skills
	for _, activeSkill in ipairs(env.player.activeSkillList) do
		activeSkill.skillModList = new("ModList", activeSkill.baseSkillModList)
		if activeSkill.minion then
			if activeSkill.minion then
				if cacheSkillUUID(activeSkill) == cacheSkillUUID(env.player.mainSkill) then
					activeSkill = env.player.mainSkill
				end
				activeSkill.minion.modDB = new("ModDB")
				activeSkill.minion.modDB.actor = activeSkill.minion
				calcs.createMinionSkills(env, activeSkill)
				activeSkill.skillPartName = activeSkill.minion.mainSkill.activeEffect.grantedEffect.name
			end
		end
	end

	env.player.output = { }
	env.enemy.output = { }
	local output = env.player.output

	env.minion = env.player.mainSkill.minion
	if env.minion and env.minion.modDB then
		-- Initialise minion modifier database
		output.Minion = { }
		env.minion.output = output.Minion
		env.minion.modDB.multipliers["Level"] = env.minion.level
		calcs.initModDB(env, env.minion.modDB)
		env.minion.modDB:NewMod("Life", "BASE", m_floor(env.minion.lifeTable[env.minion.level] * env.minion.minionData.life), "Base")
		if env.minion.minionData.energyShield then
			env.minion.modDB:NewMod("EnergyShield", "BASE", m_floor(env.data.monsterAllyLifeTable[env.minion.level] * env.minion.minionData.life * env.minion.minionData.energyShield), "Base")
		end
		if env.minion.minionData.armour then
			env.minion.modDB:NewMod("Armour", "BASE", m_floor((10 + env.minion.level * 2) * env.minion.minionData.armour * 1.038 ^ env.minion.level), "Base")
		end
		env.minion.modDB:NewMod("Evasion", "BASE", round((30 + env.minion.level * 5) * 1.03 ^ env.minion.level), "Base")
		env.minion.modDB:NewMod("Accuracy", "BASE", round((17 + env.minion.level / 2) * (env.minion.minionData.accuracy or 1) * 1.03 ^ env.minion.level), "Base")
		env.minion.modDB:NewMod("CritMultiplier", "BASE", 30, "Base")
		env.minion.modDB:NewMod("CritDegenMultiplier", "BASE", 30, "Base")
		env.minion.modDB:NewMod("FireResist", "BASE", env.minion.minionData.fireResist, "Base")
		env.minion.modDB:NewMod("ColdResist", "BASE", env.minion.minionData.coldResist, "Base")
		env.minion.modDB:NewMod("LightningResist", "BASE", env.minion.minionData.lightningResist, "Base")
		env.minion.modDB:NewMod("ChaosResist", "BASE", env.minion.minionData.chaosResist, "Base")
		env.minion.modDB:NewMod("CritChance", "INC", 200, "Base", { type = "Multiplier", var = "PowerCharge" })
		env.minion.modDB:NewMod("Speed", "INC", 15, "Base", { type = "Multiplier", var = "FrenzyCharge" })
		env.minion.modDB:NewMod("Damage", "MORE", 4, "Base", { type = "Multiplier", var = "FrenzyCharge" })
		env.minion.modDB:NewMod("MovementSpeed", "INC", 5, "Base", { type = "Multiplier", var = "FrenzyCharge" })
		env.minion.modDB:NewMod("PhysicalDamageReduction", "BASE", 15, "Base", { type = "Multiplier", var = "EnduranceCharge" })
		env.minion.modDB:NewMod("ElementalResist", "BASE", 15, "Base", { type = "Multiplier", var = "EnduranceCharge" })
		env.minion.modDB:NewMod("ProjectileCount", "BASE", 1, "Base")
		env.minion.modDB:NewMod("Damage", "MORE", -50, "Base", 0, KeywordFlag.Poison)
		env.minion.modDB:NewMod("Damage", "MORE", -50, "Base", 0, KeywordFlag.Ignite)
		env.minion.modDB:NewMod("SkillData", "LIST", { key = "bleedBasePercent", value = 70/6 }, "Base")
		env.minion.modDB:NewMod("Damage", "MORE", 500, "Base", 0, KeywordFlag.Bleed, { type = "ActorCondition", actor = "enemy", var = "Moving" })
		for _, mod in ipairs(env.minion.minionData.modList) do
			env.minion.modDB:AddMod(mod)
		end
		for _, mod in ipairs(env.player.mainSkill.extraSkillModList) do
			env.minion.modDB:AddMod(mod)
		end
		if env.aegisModList then
			env.minion.itemList["Weapon 3"] = env.player.itemList["Weapon 2"]
			env.minion.modDB:AddList(env.aegisModList)
		end 
		if env.player.mainSkill.skillData.minionUseBowAndQuiver then
			if env.player.weaponData1.type == "Bow" then
				env.minion.modDB:AddList(env.player.itemList["Weapon 1"].slotModList[1])
			end
			if env.player.itemList["Weapon 2"] and env.player.itemList["Weapon 2"].type == "Quiver" then
				env.minion.modDB:AddList(env.player.itemList["Weapon 2"].modList)
			end
		end
		if env.minion.itemSet or env.minion.uses then
			for slotName, slot in pairs(env.build.itemsTab.slots) do
				if env.minion.uses[slotName] then
					local item
					if env.minion.itemSet then
						if slot.weaponSet == 1 and env.minion.itemSet.useSecondWeaponSet then
							slotName = slotName .. " Swap"
						end
						item = env.build.itemsTab.items[env.minion.itemSet[slotName].selItemId]
					else
						item = env.player.itemList[slotName]
					end
					if item then
						env.minion.itemList[slotName] = item
						env.minion.modDB:AddList(item.modList or item.slotModList[slot.slotNum])
					end
				end
			end
		end
		if modDB:Flag(nil, "StrengthAddedToMinions") then
			env.minion.modDB:NewMod("Str", "BASE", round(calcLib.val(modDB, "Str")), "Player")
		end
		if modDB:Flag(nil, "HalfStrengthAddedToMinions") then
			env.minion.modDB:NewMod("Str", "BASE", round(calcLib.val(modDB, "Str") * 0.5), "Player")
		end
	end
	if env.aegisModList then
		env.player.itemList["Weapon 2"] = nil
	end
	if modDB:Flag(nil, "AlchemistsGenius") then
		local effectMod = 1 + modDB:Sum("INC", nil, "BuffEffectOnSelf") / 100
		modDB:NewMod("FlaskEffect", "INC", m_floor(20 * effectMod), "炼金术天才")
		modDB:NewMod("FlaskChargesGained", "INC", m_floor(20 * effectMod), "炼金术天才")
	end
	for _, activeSkill in ipairs(env.player.activeSkillList) do
		
		
		if activeSkill.skillFlags.brand then
			local attachLimit = activeSkill.skillModList:Sum("BASE", activeSkill.skillCfg, "BrandsAttachedLimit")
			 
			local attached = modDB:Sum("BASE", nil, "Multiplier:ConfigBrandsAttachedToEnemy")
			local activeBrands = modDB:Sum("BASE", nil, "Multiplier:ConfigActiveBrands")
			local actual = m_min(attachLimit, attached)
			 
			-- Cap the number of active brands by the limit, which is 3 by default
			modDB.multipliers["ActiveBrand"] = m_min(activeBrands, modDB:Sum("BASE", nil, "ActiveBrandLimit"))
			modDB.multipliers["BrandsAttachedToEnemy"] = m_max(actual, modDB.multipliers["BrandsAttachedToEnemy"] or 0)
			enemyDB.multipliers["BrandsAttached"] = m_max(actual, enemyDB.multipliers["BrandsAttached"] or 0)
			
			 
		end
		
		-- The actual hexes as opposed to hex related skills all have the curse flag. DamageCannotBeReflected is to remove blasphemy
		-- Note that this doesn't work for triggers yet, insufficient support
		if activeSkill.skillFlags.hex and activeSkill.skillFlags.curse and not activeSkill.skillTypes[SkillType.DamageCannotBeReflected] then
			local hexDoom = modDB:Sum("BASE", nil, "Multiplier:HexDoomStack")
			local maxDoom = activeSkill.skillModList:Sum("BASE", nil, "MaxDoom") or 30
			local doomEffect = activeSkill.skillModList:More(nil, "DoomEffect")
			-- Update the max doom limit
			output.HexDoomLimit = m_max(maxDoom, output.HexDoomLimit or 0)
			-- Update the Hex Doom to apply
			activeSkill.skillModList:NewMod("CurseEffect", "INC", m_min(hexDoom, maxDoom) * doomEffect, "Doom")
			modDB.multipliers["HexDoom"] =  m_min(m_max(hexDoom, modDB.multipliers["HexDoom"] or 0), output.HexDoomLimit)
		end
		if activeSkill.skillData.supportBonechill then
			if activeSkill.skillTypes[SkillType.ChillingArea] or (activeSkill.skillTypes[SkillType.NonHitChill] and not activeSkill.skillModList:Flag(nil, "CannotChill")) and not (activeSkill.activeEffect.grantedEffect.name == "Summon Skitterbots" and activeSkill.skillModList:Flag(nil, "SkitterbotsCannotChill")) then
				output.BonechillDotEffect = m_floor(10 * (1 + activeSkill.skillModList:Sum("INC", nil, "EnemyChillEffect") / 100))
			end
			output.BonechillEffect = m_max(output.BonechillEffect or 0, modDB:Override(nil, "BonechillEffect") or output.BonechillDotEffect or 0)
		end
		if (activeSkill.activeEffect.grantedEffect.name == "瓦尔.闪电陷阱"  or activeSkill.activeEffect.grantedEffect.name == "电击地面") then
			modDB:NewMod("ShockOverride", "BASE", activeSkill.skillModList:Sum("BASE", nil, "ShockedGroundEffect"), "Shocked Ground",
			{ type = "ActorCondition", actor = "enemy", var = "OnShockedGround" } )
		end
		
		if activeSkill.activeEffect.grantedEffect.name == "召唤飞掠者" then
			if not activeSkill.skillModList:Flag(nil, "SkitterbotsCannotShock") then
				local effect = activeSkill.skillModList:Sum("INC", { source = "Skill" }, "EnemyShockEffect")
				modDB:NewMod("ShockOverride", "BASE", 15 * (1 + effect / 100), "召唤飞掠者")
				enemyDB:NewMod("Condition:Shocked", "FLAG", true, "召唤飞掠者")
			end
			if not activeSkill.skillModList:Flag(nil, "SkitterbotsCannotChill") then
				enemyDB:NewMod("Condition:Chilled", "FLAG", true, "召唤飞掠者")
			end
		end
		
		
			-- lucifer 各个守护翻译可能不一致 Elemental Aegis
		if activeSkill.activeEffect.grantedEffect.name == "元素守护" or activeSkill.activeEffect.grantedEffect.name == "元素神盾"  then
			modDB:NewMod("FireAegisValue", "BASE", 1000, "Config")
			modDB:NewMod("ColdAegisValue", "BASE", 1000, "Config")
			modDB:NewMod("LightningAegisValue", "BASE", 1000, "Config")
		elseif activeSkill.activeEffect.grantedEffect.name == "烈焰守护" or activeSkill.activeEffect.grantedEffect.name == "火焰神盾" then
				modDB:NewMod("FireAegisValue", "BASE", 1000, "Config")		
		elseif activeSkill.activeEffect.grantedEffect.name == "凝冰守护" or activeSkill.activeEffect.grantedEffect.name == "寒冰神盾" then
				modDB:NewMod("ColdAegisValue", "BASE", 1000, "Config")				
		elseif activeSkill.activeEffect.grantedEffect.name == "闪电守护" or activeSkill.activeEffect.grantedEffect.name == "闪电神盾" then
		--？
				modDB:NewMod("LightningAegisValue", "BASE", 1000, "Config")
		end
			
		if activeSkill.activeEffect.grantedEffect.name == "Elemental Aegis" then
			modDB:NewMod("FireAegisValue", "BASE", 1000, "Config")
			modDB:NewMod("ColdAegisValue", "BASE", 1000, "Config")
			modDB:NewMod("LightningAegisValue", "BASE", 1000, "Config")
		end
		if activeSkill.skillModList:Flag(nil, "CanHaveAdditionalCurse") then
			output.GemCurseLimit = activeSkill.skillModList:Sum("BASE", nil, "AdditionalCurse")
		end
		if activeSkill.skillModList:Flag(nil, "Condition:CanWither") and not modDB:Flag(nil, "AlreadyWithered") then
			modDB:NewMod("Condition:CanWither", "FLAG", true, "Config")
			modDB:NewMod("Dummy", "DUMMY", 1, "Config", { type = "Condition", var = "CanWither" })
			local effect = m_floor(6 * (1 + modDB:Sum("INC", nil, "WitherEffect") / 100))
			enemyDB:NewMod("ChaosDamageTaken", "INC", effect, "Withered", { type = "Multiplier", var = "WitheredStack", limit = 15 } )
			if modDB:Flag(nil, "Condition:CanElementalWithered") then
				enemyDB:NewMod("ElementalDamageTaken", "INC", 4, "Withered", ModFlag.Hit, { type = "Multiplier", var = "WitheredStack", limit = 15 } )
			end
			modDB:NewMod("AlreadyWithered", "FLAG", true, "Config") -- Prevents effect from applying multiple times
		end
		if activeSkill.skillFlags.warcry and not modDB:Flag(nil, "AlreadyGlobalWarcryCooldown") then
			local cooldown = calcSkillCooldown(activeSkill.skillModList, activeSkill.skillCfg, activeSkill.skillData)
			local warcryList = { }
			local numWarcries, sumWarcryCooldown = 0
			for _, activeSkill in ipairs(env.player.activeSkillList) do
				if activeSkill.skillTypes[SkillType.Warcry] then
					warcryList[activeSkill.skillCfg.skillName] = true
				end
			end
			for _, warcry in pairs(warcryList) do
				numWarcries = numWarcries + 1
				sumWarcryCooldown = (sumWarcryCooldown or 0) + cooldown
			end
			env.player.modDB:NewMod("GlobalWarcryCooldown", "BASE", sumWarcryCooldown)
			env.player.modDB:NewMod("GlobalWarcryCount", "BASE", numWarcries)
			modDB:NewMod("AlreadyGlobalWarcryCooldown", "FLAG", true, "Config") -- Prevents effect from applying multiple times
		end
		if activeSkill.minion and activeSkill.minion.minionData and activeSkill.minion.minionData.limit then
			local limit = activeSkill.skillModList:Sum("BASE", nil, activeSkill.minion.minionData.limit)
			output[activeSkill.minion.minionData.limit] = m_max(limit, output[activeSkill.minion.minionData.limit] or 0)
		
		end
		
		if env.mode_buffs and activeSkill.skillFlags.warcry then
			local extraExertions = activeSkill.skillModList:Sum("BASE", nil, "ExtraExertedAttacks") or 0
			
			--灵体的战吼没有持续时间数据？
			local full_duration = (activeSkill.activeEffect.grantedEffectLevel.duration or  0) * calcLib.mod(activeSkill.skillModList, activeSkill.skillCfg, "Duration", "PrimaryDuration", "SkillAndDamagingAilmentDuration", activeSkill.skillData.mineDurationAppliesToSkill and "MineDuration" or nil)
			local cooldownOverride = activeSkill.skillModList:Override(activeSkill.skillCfg, "CooldownRecovery")
			local actual_cooldown = cooldownOverride or (activeSkill.skillData.cooldown  + activeSkill.skillModList:Sum("BASE", activeSkill.skillCfg, "CooldownRecovery")) / calcLib.mod(activeSkill.skillModList, activeSkill.skillCfg, "CooldownRecovery")
			local globalCooldown = modDB:Sum("BASE", nil, "GlobalWarcryCooldown")
			local globalCount = modDB:Sum("BASE", nil, "GlobalWarcryCount")
			local uptime = m_min(full_duration / actual_cooldown, 1)			
			local buff_inc = 1 + activeSkill.skillModList:Sum("INC", activeSkill.skillCfg, "BuffEffect") / 100
			local warcryPowerBonus = m_floor((modDB:Override(nil, "WarcryPower") or modDB:Sum("BASE", nil, "WarcryPower") or 0) / 5)
			if modDB:Flag(nil, "WarcryShareCooldown") then
				uptime = m_min(full_duration / (actual_cooldown + (globalCooldown - actual_cooldown) / globalCount), 1)
			end
			if modDB:Flag(nil, "Condition:WarcryMaxHit") then
				uptime = 1;
			end
			if activeSkill.activeEffect.grantedEffect.name == "先祖战吼" and not modDB:Flag(nil, "AncestralActive") then
				local ancestralArmour = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "AncestralArmourPer5MP")
				local ancestralArmourMax = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "AncestralArmourMax")
				local ancestralArmourIncrease = activeSkill.skillModList:Sum("INC", env.player.mainSkill.skillCfg, "AncestralArmourMax")
				local ancestralStrikeRange = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "AncestralMeleeWeaponRangePer5MP")
				local ancestralStrikeRangeMax = m_floor(6 * buff_inc)
				env.player.modDB:NewMod("NumAncestralExerts", "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "AncestralExertedAttacks") + extraExertions)
				ancestralArmourMax = m_floor(ancestralArmourMax * buff_inc)
				if warcryPowerBonus ~= 0 then
					ancestralArmour = m_floor(ancestralArmour * warcryPowerBonus * buff_inc) / warcryPowerBonus
					ancestralStrikeRange = m_floor(ancestralStrikeRange * warcryPowerBonus * buff_inc) / warcryPowerBonus
				else
					-- Since no buff happens, you don't get the divergent increase.
					ancestralArmourIncrease = 0
				end
				env.player.modDB:NewMod("Armour", "BASE", ancestralArmour * uptime, "先祖战吼", { type = "Multiplier", var = "WarcryPower", div = 5, limit = ancestralArmourMax, limitTotal = true })
				env.player.modDB:NewMod("Armour", "INC", ancestralArmourIncrease * uptime, "先祖战吼")
							
				env.player.modDB:NewMod("MeleeWeaponRange", "BASE", ancestralStrikeRange * uptime, "先祖战吼", { type = "Multiplier", var = "WarcryPower", div = 5, limit = ancestralStrikeRangeMax, limitTotal = true })
				modDB:NewMod("AncestralActive", "FLAG", true) -- Prevents effect from applying multiple times
			elseif activeSkill.activeEffect.grantedEffect.name == "坚决战吼" and not modDB:Flag(nil, "EnduringActive") then
				local heal_over_1_sec = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "EnduringCryLifeRegen")
				local resist_all_per_endurance = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "EnduringCryElementalResist")
				local pdr_per_endurance = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "EnduringCryPhysicalDamageReduction")
				env.player.modDB:NewMod("LifeRegen", "BASE", heal_over_1_sec , "坚决战吼", { type = "Condition", var = "LifeRegenBurstFull" })
				env.player.modDB:NewMod("LifeRegen", "BASE", heal_over_1_sec / actual_cooldown, "坚决战吼", { type = "Condition", var = "LifeRegenBurstAvg" })
				env.player.modDB:NewMod("ElementalResist", "BASE", m_floor(resist_all_per_endurance * buff_inc) * uptime, "坚决战吼", { type = "Multiplier", var = "EnduranceCharge" })
				env.player.modDB:NewMod("PhysicalDamageReduction", "BASE", m_floor(pdr_per_endurance * buff_inc) * uptime, "坚决战吼", { type = "Multiplier", var = "EnduranceCharge" })
				modDB:NewMod("EnduringActive", "FLAG", true) -- Prevents effect from applying multiple times
			elseif activeSkill.activeEffect.grantedEffect.name == "炼狱呼嚎" and not modDB:Flag(nil, "InfernalActive") then
				local infernalAshEffect = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "InfernalFireTakenPer5MP")
				env.player.modDB:NewMod("NumInfernalExerts", "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "InfernalExertedAttacks") + extraExertions)
				if env.mode_effective then
					env.player.modDB:NewMod("CoveredInAshEffect", "BASE", infernalAshEffect * uptime, { type = "Multiplier", var = "WarcryPower", div = 5 })
				end
				modDB:NewMod("InfernalActive", "FLAG", true) -- Prevents effect from applying multiple times
			elseif activeSkill.activeEffect.grantedEffect.name == "威吓战吼" and not modDB:Flag(nil, "IntimidatingActive") then
				local intimidatingOverwhelmEffect = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "IntimidatingPDRPer5MP")
				if warcryPowerBonus ~= 0 then
					intimidatingOverwhelmEffect = m_floor(intimidatingOverwhelmEffect * warcryPowerBonus * buff_inc) / warcryPowerBonus
				end
				env.player.modDB:NewMod("NumIntimidatingExerts", "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "IntimidatingExertedAttacks") + extraExertions)
				env.player.modDB:NewMod("EnemyPhysicalDamageReduction", "BASE", -intimidatingOverwhelmEffect * uptime, "威吓战吼增益", { type = "Multiplier", var = "WarcryPower", div = 5, limit = 6 })
				modDB:NewMod("IntimidatingActive", "FLAG", true) -- Prevents effect from applying multiple times
			elseif activeSkill.activeEffect.grantedEffect.name == "激励战吼" and not modDB:Flag(nil, "RallyingActive") then
				
				env.player.modDB:NewMod("NumRallyingExerts", "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "RallyingExertedAttacks") + extraExertions)
				env.player.modDB:NewMod("RallyingExertMoreDamagePerAlly",  "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "RallyingCryExertDamageBonus"))
				local rallyingWeaponEffect = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "RallyingCryAllyDamageBonusPer5Power")
				-- Rallying cry divergant more effect of buff
				local rallyingBonusMoreMultiplier = 1 + (activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "RallyingCryMinionDamageBonusMultiplier") or 0)
				
				if warcryPowerBonus ~= 0 then
					rallyingWeaponEffect = m_floor(rallyingWeaponEffect * warcryPowerBonus * buff_inc) / warcryPowerBonus
				end
				
				-- Special handling for the minion side to add the flat damage bonus
				if env.minion then
					-- Add all damage types
					local dmgTypeList = {"Physical", "Lightning", "Cold", "Fire", "Chaos"}
					for _, damageType in ipairs(dmgTypeList) do
						env.minion.modDB:NewMod(damageType.."Min", "BASE", m_floor((env.player.weaponData1[damageType.."Min"] or 0) * rallyingBonusMoreMultiplier * rallyingWeaponEffect / 100) * uptime, "Rallying Cry", { type = "Multiplier", actor = "parent", var = "WarcryPower", div = 5, limit = 6.6667})
						env.minion.modDB:NewMod(damageType.."Max", "BASE", m_floor((env.player.weaponData1[damageType.."Max"] or 0) * rallyingBonusMoreMultiplier * rallyingWeaponEffect / 100) * uptime, "Rallying Cry", { type = "Multiplier", actor = "parent", var = "WarcryPower", div = 5, limit = 6.6667})
					end
				end
				modDB:NewMod("RallyingActive", "FLAG", true) -- Prevents effect from applying multiple times
			elseif activeSkill.activeEffect.grantedEffect.name == "震地战吼" and not modDB:Flag(nil, "SeismicActive") then
				local seismicStunEffect = activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "SeismicStunThresholdPer5MP")
				if warcryPowerBonus ~= 0 then
					seismicStunEffect = m_floor(seismicStunEffect * warcryPowerBonus * buff_inc) / warcryPowerBonus
				end
				env.player.modDB:NewMod("NumSeismicExerts", "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "SeismicExertedAttacks") + extraExertions)
				env.player.modDB:NewMod("SeismicMoreDmgPerExert",  "BASE", activeSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "SeismicHitMultiplier"))
				if env.mode_effective then
					env.player.modDB:NewMod("EnemyStunThreshold", "INC", -seismicStunEffect * uptime, "震地战吼增益", { type = "Multiplier", var = "WarcryPower", div = 5, limit = 6 })
				end
				modDB:NewMod("SeismicActive", "FLAG", true) -- Prevents effect from applying multiple times
				
			
			end
		end
		
		
		 
		if activeSkill.skillData.triggeredByBrand and not activeSkill.skillFlags.minion then
			activeSkill.skillData.triggered = true
			local spellCount, quality = 0
			for _, skill in ipairs(env.player.activeSkillList) do
				local match1 = skill.activeEffect.grantedEffect.fromItem and skill.socketGroup.slot == activeSkill.socketGroup.slot
				local match2 = not skill.activeEffect.grantedEffect.fromItem and skill.socketGroup == activeSkill.socketGroup
				if skill.skillData.triggeredByBrand and (match1 or match2) then
					spellCount = spellCount + 1
				end
				if skill.activeEffect.grantedEffect.name == "奥法烙印" and (match1 or match2) then				
					quality = skill.activeEffect.quality / 2
				end
			end
			addTriggerIncMoreMods(activeSkill, env.player.mainSkill)
			activeSkill.skillModList:NewMod("ArcanistSpellsLinked", "BASE", spellCount, "Skill")
			activeSkill.skillModList:NewMod("BrandActivationFrequency", "INC", quality, "Skill")
			
			
		end
		
		
		
		if activeSkill.skillData.triggeredOnDeath and not activeSkill.skillFlags.minion then
			activeSkill.skillData.triggered = true
			activeSkill.skillData.triggerCostMultiplier = 0
			for _, value in ipairs(activeSkill.skillModList:Tabulate("INC", env.player.mainSkill.skillCfg, "TriggeredDamage")) do
				activeSkill.skillModList:NewMod("Damage", "INC", value.mod.value, value.mod.source, value.mod.flags, value.mod.keywordFlags, unpack(value.mod))
			end
			for _, value in ipairs(activeSkill.skillModList:Tabulate("MORE", env.player.mainSkill.skillCfg, "TriggeredDamage")) do
				activeSkill.skillModList:NewMod("Damage", "MORE", value.mod.value, value.mod.source, value.mod.flags, value.mod.keywordFlags, unpack(value.mod))
			end
			-- Set trigger time to 1 min in ms ( == 6000 ). Technically any large value would do.
			activeSkill.skillData.triggerTime = 60 * 1000
		end
		-- The Saviour
		if activeSkill.activeEffect.grantedEffect.name == "反射" or activeSkill.skillData.triggeredBySaviour then
			activeSkill.infoMessage = "【救世者】暴击时触发"
			activeSkill.infoTrigger = "【救世者】"
		end
	end
	
	
	local breakdown = nil
	if env.mode == "CALCS" then
		-- Initialise breakdown module
		breakdown = LoadModule(calcs.breakdownModule, modDB, output, env.player)
		env.player.breakdown = breakdown
		if env.minion then
			env.minion.breakdown = LoadModule(calcs.breakdownModule, env.minion.modDB, env.minion.output, env.minion)
		end
	end

	-- Merge flask modifiers
	if env.mode_combat then
		local effectInc = modDB:Sum("INC", nil, "FlaskEffect")
		local flaskBuffs = { }
		local usingFlask = false
		local usingLifeFlask = false
		local usingManaFlask = false
		for item in pairs(env.flasks) do
			usingFlask = true
			if item.baseName:match("生命药剂") then
				usingLifeFlask = true
			end
			if item.baseName:match("魔力药剂") then
				usingManaFlask = true
			end
			if item.baseName:match("复合药剂") then
				usingLifeFlask = true
				usingManaFlask = true
			end

			-- Avert thine eyes, lest they be forever scarred
			-- I have no idea how to determine which buff is applied by a given flask, 
			-- so utility flasks are grouped by base, unique flasks are grouped by name, and magic flasks by their modifiers
			local effectMod = 1 + (effectInc + item.flaskData.effectInc) / 100
			if item.buffModList[1] then
				local srcList = new("ModList")
				srcList:ScaleAddList(item.buffModList, effectMod)
				mergeBuff(srcList, flaskBuffs, item.baseName)
			end
			if item.modList[1] then
				local srcList = new("ModList")
				srcList:ScaleAddList(item.modList, effectMod)
				local key
				if item.rarity == "UNIQUE" then
					key = item.title
				else
					key = ""
					for _, mod in ipairs(item.modList) do
						key = key .. modLib.formatModParams(mod) .. "&"
					end
				end
				mergeBuff(srcList, flaskBuffs, key)
			end
		end
		if not modDB:Flag(nil, "FlasksDoNotApplyToPlayer") then
			modDB.conditions["UsingFlask"] = usingFlask
			modDB.conditions["UsingLifeFlask"] = usingLifeFlask
			modDB.conditions["UsingManaFlask"] = usingManaFlask
			for _, buffModList in pairs(flaskBuffs) do
				modDB.conditions["UsingFlask"] = true
				modDB:AddList(buffModList)
			end
		end
		if env.minion and modDB:Flag(env.player.mainSkill.skillCfg, "FlasksApplyToMinion") then
			local minionModDB = env.minion.modDB
			minionModDB.conditions["UsingFlask"] = usingFlask
			minionModDB.conditions["UsingLifeFlask"] = usingLifeFlask
			minionModDB.conditions["UsingManaFlask"] = usingManaFlask
			for _, buffModList in pairs(flaskBuffs) do				 
				minionModDB:AddList(buffModList)
			end
		end
	end

	-- Merge keystones again to catch any that were added by flasks
	mergeKeystones(env)
	--mergeNotable(env)
	
	-- Calculate attributes and life/mana pools
	
	doActorAttribsPoolsConditions(env, env.player)
	if env.minion then
	
		for _, value in ipairs(env.player.mainSkill.skillModList:List(env.player.mainSkill.skillCfg, "MinionModifier")) do
			if not value.type or env.minion.type == value.type then
			
				env.minion.modDB:AddMod(value.mod)
			end
		end
		for _, name in ipairs(env.minion.modDB:List(nil, "Keystone")) do
			env.minion.modDB:AddList(env.spec.tree.keystoneMap[name].modList)
		end
		
		doActorAttribsPoolsConditions(env, env.minion)
	end
	-- Calculate skill life and mana reservations
	env.player.reserved_LifeBase = 0
	env.player.reserved_LifePercent = modDB:Sum("BASE", nil, "ExtraLifeReserved") 
	env.player.reserved_ManaBase = 0
	env.player.reserved_ManaPercent = 0
	if breakdown then
		breakdown.LifeReserved = { reservations = { } }
		breakdown.ManaReserved = { reservations = { } }
	end
	for _, activeSkill in ipairs(env.player.activeSkillList) do
		if activeSkill.skillTypes[SkillType.ManaCostReserved] and not activeSkill.skillFlags.totem then
			local skillModList = activeSkill.skillModList
			local skillCfg = activeSkill.skillCfg
			local mult = skillModList:More(skillCfg, "SupportManaMultiplier")
			local pool = { ["Mana"] = { }, ["Life"] = { } }
			pool.Mana.baseFlat = activeSkill.skillData.manaReservationFlat or activeSkill.activeEffect.grantedEffectLevel.manaReservationFlat or 0
			if skillModList:Flag(skillCfg, "ManaCostGainAsReservation") then
				pool.Mana.baseFlat = skillModList:Sum("BASE", skillCfg, "ManaCostBase") + (activeSkill.activeEffect.grantedEffectLevel.cost.Mana or 0)
			end
			pool.Mana.basePercent = activeSkill.skillData.manaReservationPercent or activeSkill.activeEffect.grantedEffectLevel.manaReservationPercent or 0
			pool.Life.baseFlat = activeSkill.skillData.lifeReservationFlat or activeSkill.activeEffect.grantedEffectLevel.lifeReservationFlat or 0
			if skillModList:Flag(skillCfg, "LifeCostGainAsReservation") then
				pool.Life.baseFlat = skillModList:Sum("BASE", skillCfg, "LifeCostBase") + (activeSkill.activeEffect.grantedEffectLevel.cost.Life or 0)
			end
			pool.Life.basePercent = activeSkill.skillData.lifeReservationPercent or activeSkill.activeEffect.grantedEffectLevel.lifeReservationPercent or 0
			if skillModList:Flag(skillCfg, "BloodMagicReserved") then
				pool.Life.baseFlat = pool.Life.baseFlat + pool.Mana.baseFlat
				pool.Mana.baseFlat = 0
				activeSkill.skillData["LifeReservationFlatForced"] = activeSkill.skillData["ManaReservationFlatForced"]
				activeSkill.skillData["ManaReservationFlatForced"] = nil
				pool.Life.basePercent = pool.Life.basePercent + pool.Mana.basePercent
				pool.Mana.basePercent = 0
				activeSkill.skillData["LifeReservationPercentForced"] = activeSkill.skillData["ManaReservationPercentForced"]
				activeSkill.skillData["ManaReservationPercentForced"] = nil
			end
			for name, values in pairs(pool) do
				values.more = skillModList:More(skillCfg, name.."Reserved", "Reserved")
				values.inc = skillModList:Sum("INC", skillCfg, name.."Reserved", "Reserved")
				values.efficiency = skillModList:Sum("INC", skillCfg, name.."ReservationEfficiency", "ReservationEfficiency")
				if activeSkill.skillData[name.."ReservationFlatForced"] then
					values.reservedFlat = activeSkill.skillData[name.."ReservationFlatForced"]
				else
					local baseFlatVal = m_floor(values.baseFlat * mult)
					values.reservedFlat = m_max(m_modf((baseFlatVal - m_modf(baseFlatVal * -m_floor((100 + values.inc) * values.more - 100) / 100)) / (1 + values.efficiency / 100)), 0)
				end
				if activeSkill.skillData[name.."ReservationPercentForced"] then
					values.reservedPercent = activeSkill.skillData[name.."ReservationPercentForced"]
				else
					local basePercentVal = values.basePercent * mult
					values.reservedPercent = m_max(m_modf((basePercentVal - m_modf(basePercentVal * -m_floor((100 + values.inc) * values.more - 100)) / 100) / (1 + values.efficiency / 100)), 0)
				end
				if activeSkill.activeMineCount then
					values.reservedFlat = values.reservedFlat * activeSkill.activeMineCount
					values.reservedPercent = values.reservedPercent * activeSkill.activeMineCount
				end
				if values.reservedFlat ~= 0 then
					activeSkill.skillData[name.."ReservedBase"] = values.reservedFlat
					env.player["reserved_"..name.."Base"] = env.player["reserved_"..name.."Base"] + values.reservedFlat
					if breakdown then
						t_insert(breakdown[name.."Reserved"].reservations, {
							skillName = activeSkill.activeEffect.grantedEffect.name,
							base = values.baseFlat,
							mult = mult ~= 1 and ("x "..mult),
							more = values.more ~= 1 and ("x "..values.more),
							inc = values.inc ~= 0 and ("x "..(1 + values.inc / 100)),
							efficiency = values.efficiency ~= 0 and ("x " .. 1 / (1 + values.efficiency / 100)),
							total = values.reservedFlat,
						})
					end
				end
				if values.reservedPercent ~= 0 then
					activeSkill.skillData[name.."ReservedPercent"] = values.reservedPercent
					activeSkill.skillData[name.."ReservedBase"] = (activeSkill.skillData[name.."ReservedBase"] or 0) + m_ceil(output[name] * values.reservedPercent / 100)
					env.player["reserved_"..name.."Percent"] = env.player["reserved_"..name.."Percent"] + values.reservedPercent
					if breakdown then
						t_insert(breakdown[name.."Reserved"].reservations, {
							skillName = activeSkill.activeEffect.grantedEffect.name,
							base = values.basePercent .. "%",
							mult = mult ~= 1 and ("x "..mult),
							more = values.more ~= 1 and ("x "..values.more),
							inc = values.inc ~= 0 and ("x "..(1 + values.inc / 100)),
							efficiency = values.efficiency ~= 0 and ("x " .. 1 / (1 + values.efficiency / 100)),
							total = values.reservedPercent .. "%",
						})
					end
				end
			end
		end
	end
	
	-- Set the life/mana reservations
	doActorLifeManaReservation(env.player)
	if env.minion then
		doActorLifeManaReservation(env.minion)
	end

	-- Process attribute requirements
	do
	
		if modDB:Flag(nil, "GlobalNoAttributeRequirements") then
			for _, attr in ipairs({"Str","Dex","Int"}) do
				if breakdown then
					breakdown["Req"..attr] = {
						rowList = { },
						colList = {
							{ label = attr, key = "req" },
							{ label = "Source", key = "source" },
							{ label = "Source Name", key = "sourceName" },
						}
					}
					output["Req"..attr.."String"] = "无视属性需求"
				end
				
				output["Req"..attr] = 0
				
			end
		else 
			local reqMult = calcLib.mod(modDB, nil, "GlobalAttributeRequirements")
			for _, attr in ipairs({"Str","Dex","Int"}) do
				if breakdown then
					breakdown["Req"..attr] = {
						rowList = { },
						colList = {
							{ label = attr, key = "req" },
							{ label = "Source", key = "source" },
							{ label = "Source Name", key = "sourceName" },
						}
					}
				end
				local out = 0
				for _, reqSource in ipairs(env.requirementsTable) do
					if reqSource[attr] and reqSource[attr] > 0 then
						local req = m_floor(reqSource[attr] * reqMult)
						out = m_max(out, req)
						if breakdown then
							local row = {
								req = req > output[attr] and colorCodes.NEGATIVE..req or req,
								reqNum = req,
								source = reqSource.source,
							}
							if reqSource.source == "Item" then
								local item = reqSource.sourceItem
								row.sourceName = colorCodes[item.rarity]..item.name
								row.sourceNameTooltip = function(tooltip)
									env.build.itemsTab:AddItemTooltip(tooltip, item, reqSource.sourceSlot)
								end
							elseif reqSource.source == "Gem" then
								row.sourceName = s_format("%s%s ^7%d/%d", reqSource.sourceGem.color, reqSource.sourceGem.nameSpec, reqSource.sourceGem.level, reqSource.sourceGem.quality)
							end
							t_insert(breakdown["Req"..attr].rowList, row)
						end
					end
				end
				output["Req"..attr] = out
				if breakdown then
					output["Req"..attr.."String"] = out > output[attr] and colorCodes.NEGATIVE..out or out
					table.sort(breakdown["Req"..attr].rowList, function(a, b)
						if a.reqNum ~= b.reqNum then
							return a.reqNum > b.reqNum
						elseif a.source ~= b.source then
							return a.source < b.source 
						else
							return a.sourceName < b.sourceName
						end
					end)
				end
			end
		end
		
	end

	-- Check for extra modifiers to apply to aura skills
	local extraAuraModList = { }
	
	for _, value in ipairs(modDB:List(nil, "ExtraAuraEffect")) do 
		
		--t_insert(extraAuraModList, value.mod)
		local add = true
		for _, mod in ipairs(extraAuraModList) do
			if modLib.compareModParams(mod, value.mod) then
				mod.value = mod.value + value.mod.value
				add = false
				break
			end
		end
		if add then
			t_insert(extraAuraModList, copyTable(value.mod, true))
		end
		
	end
	local heraldList = { }
	for _, activeSkill in ipairs(env.player.activeSkillList) do
		if activeSkill.skillTypes[SkillType.Herald] then
			heraldList[activeSkill.skillCfg.skillName] = true
		end
	end
	for _, herald in pairs(heraldList) do
		modDB.multipliers["Herald"] = (modDB.multipliers["Herald"] or 0) + 1
		modDB.conditions["AffectedByHerald"] = true
	end
	-- Apply effect of Bonechill support
	if env.mode_effective and output.BonechillEffect then 
		enemyDB:NewMod("ColdDamageTaken", "INC", output.BonechillEffect, 
		"彻骨", { type = "GlobalEffect", effectType = "Debuff", effectName = "彻骨承受冰持续伤" }, { type = "Limit", limit = 30 },
		{ type = "Condition", var = "Chilled" } )
	end

	-- Deal with Consecrated Ground
	if modDB:Flag(nil, "Condition:OnConsecratedGround") then
		local effect = 1 + modDB:Sum("INC", nil, "ConsecratedGroundEffect") / 100
		modDB:NewMod("LifeRegenPercent", "BASE", 5 * effect, "Consecrated Ground")
		modDB:NewMod("CurseEffectOnSelf", "INC", -50 * effect, "Consecrated Ground")
	end

	-- Combine buffs/debuffs 
		if env.mode_combat then
			if modDB:Sum("INC", nil, "HypnoticEyeJewelArcaneSurgeEffect") > 0 then
				local incVal = modDB:Sum("INC", nil, "HypnoticEyeJewelArcaneSurgeEffect")
				local maxVal = data.misc.HypnoticEyeJewelMaxArcaneSurgeEffect				
				modDB:NewMod("秘术增强Effect", "INC", incVal,"库加尔的凝视", { type = "Multiplier", var = "安睡之凝珠宝", limit = tonumber(maxVal), limitTotal = true } ) 
				 
			end
		end
	
	output.EnemyCurseLimit = modDB:Sum("BASE", nil, "EnemyCurseLimit") + (output.GemCurseLimit or 0)

	local buffs = { }
	env.buffs = buffs
	local guards = { }
	local minionBuffs = { }
	env.minionBuffs = minionBuffs
	local debuffs = { }
	env.debuffs = debuffs
	local curses = { 
		limit = output.EnemyCurseLimit,
	}
	local minionCurses = { 
		limit = 1,
	}
	local affectedByAura = { }
	for _, activeSkill in ipairs(env.player.activeSkillList) do
		local skillModList = activeSkill.skillModList
		local skillCfg = activeSkill.skillCfg
		for _, buff in ipairs(activeSkill.buffList) do
			if buff.cond and not skillModList:GetCondition(buff.cond, skillCfg) then
				-- Nothing!
			elseif buff.enemyCond and not enemyDB:GetCondition(buff.enemyCond) then
				-- Also nothing :/
			elseif buff.type == "Buff" then
				
				if env.mode_buffs and (not activeSkill.skillFlags.totem or buff.allowTotemBuff) then
					local skillCfg = buff.activeSkillBuff and skillCfg
					local modStore = buff.activeSkillBuff and skillModList or modDB
				 	if not buff.applyNotPlayer then						
						activeSkill.buffSkill = true
						modDB.conditions["AffectedBy"..buff.name:gsub(" ","")] = true
						modDB.conditions["UsedBy"..buff.name:gsub(" ","")] = true
						local srcList = new("ModList")
						-- 秘术增强Effect
						local inc = modStore:Sum("INC", skillCfg, "BuffEffect", "BuffEffectOnSelf", "BuffEffectOnPlayer", buff.name:gsub(" ", "").."Effect")
						
						local more = modStore:More(skillCfg, "BuffEffect", "BuffEffectOnSelf")
						srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						mergeBuff(srcList, buffs, buff.name)
						mergeBuff(buff.unscalableModList, buffs, buff.name)
						if activeSkill.skillData.thisIsNotABuff then
							buffs[buff.name].notBuff = true
						end
					else 
						modDB.conditions["UsedBy"..buff.name:gsub(" ","")] = true
					end
					if env.minion and (buff.applyMinions or buff.applyAllies) then
						activeSkill.minionBuffSkill = true
						env.minion.modDB.conditions["AffectedBy"..buff.name] = true
						env.minion.modDB.conditions["UsedBy"..buff.name] = true
						local srcList = new("ModList")
						local inc = modStore:Sum("INC", skillCfg, "BuffEffect") + env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf")
						local more = modStore:More(skillCfg, "BuffEffect") * env.minion.modDB:More(nil, "BuffEffectOnSelf")
						srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						mergeBuff(srcList, minionBuffs, buff.name)					 
					end
				end
			elseif buff.type == "Guard" then
				if env.mode_buffs and (not activeSkill.skillFlags.totem or buff.allowTotemBuff) then
					local skillCfg = buff.activeSkillBuff and skillCfg
					local modStore = buff.activeSkillBuff and skillModList or modDB
				 	if not buff.applyNotPlayer then
						activeSkill.buffSkill = true
						local srcList = new("ModList")
						local inc = modStore:Sum("INC", skillCfg, "BuffEffect", "BuffEffectOnSelf", "BuffEffectOnPlayer")
						local more = modStore:More(skillCfg, "BuffEffect", "BuffEffectOnSelf")
						srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						mergeBuff(srcList, guards, buff.name)
						mergeBuff(buff.unscalableModList, guards, buff.name)
					end
				end
			elseif buff.type == "Aura" then
				if env.mode_buffs then
					if not activeSkill.skillData.auraCannotAffectSelf then
						activeSkill.buffSkill = true
						affectedByAura[env.player] = true
						modDB.conditions["AffectedBy"..buff.name:gsub(" ","")] = true
						local srcList = new("ModList")
						local inc = skillModList:Sum("INC", skillCfg, "AuraEffect", "BuffEffect", "BuffEffectOnSelf", "AuraEffectOnSelf", "AuraBuffEffect", "SkillAuraEffectOnSelf")

						-- Take the Purposeful Harbinger buffs into account.
						-- These are capped to 40% increased buff effect, no matter the amount allocated
						local incFromPurposefulHarbinger = math.min(
							skillModList:Sum("INC", skillCfg, "PurpHarbAuraBuffEffect"),
							data.misc.PurposefulHarbingerMaxBuffPercent)
						inc = inc + incFromPurposefulHarbinger

						local more = skillModList:More(skillCfg, "AuraEffect", "BuffEffect", "BuffEffectOnSelf", "AuraEffectOnSelf", "AuraBuffEffect", "SkillAuraEffectOnSelf")
						srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						srcList:ScaleAddList(extraAuraModList, (1 + inc / 100) * more)
						mergeBuff(srcList, buffs, buff.name)
						mergeBuff(buff.unscalableModList, buffs, buff.name)
					else 
						modDB.conditions["UsedBy"..buff.name:gsub(" ","")] = true
					end
					
					if env.minion and not (modDB:Flag(nil, "SelfAurasCannotAffectAllies") or modDB:Flag(nil, "SelfAuraSkillsCannotAffectAllies")) then
						activeSkill.minionBuffSkill = true
						affectedByAura[env.minion] = true
						env.minion.modDB.conditions["AffectedBy"..buff.name] = true
						env.minion.modDB.conditions["UsedBy"..buff.name] = true
						local srcList = new("ModList")
						local inc = skillModList:Sum("INC", skillCfg, "AuraEffect", "BuffEffect") + env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
						local more = skillModList:More(skillCfg, "AuraEffect", "BuffEffect") * env.minion.modDB:More(nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
						srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						srcList:ScaleAddList(extraAuraModList, (1 + inc / 100) * more)
						mergeBuff(srcList, minionBuffs, buff.name)
					 
					end
				end
			elseif buff.type == "Debuff" or buff.type == "AuraDebuff" then
			--尊严 三相
				if buff.name then 
					modDB.conditions["UsedBy"..buff.name:gsub(" ","")] = true
				end 
				local stackCount
				if buff.stackVar then
					stackCount = skillModList:Sum("BASE", skillCfg, "Multiplier:"..buff.stackVar)
					if buff.stackLimit then
						stackCount = m_min(stackCount, buff.stackLimit)
					elseif buff.stackLimitVar then
						stackCount = m_min(stackCount, skillModList:Sum("BASE", skillCfg, "Multiplier:"..buff.stackLimitVar))
					end
				else
					stackCount = activeSkill.skillData.stackCount or 1
				end
				if env.mode_effective and stackCount > 0 then
					activeSkill.debuffSkill = true
					local srcList = new("ModList")
					local mult = 1
					if buff.type == "AuraDebuff" then
						local inc = skillModList:Sum("INC", skillCfg, "AuraEffect", "BuffEffect", "DebuffEffect")
						local more = skillModList:More(skillCfg, "AuraEffect", "BuffEffect", "DebuffEffect")
						mult = (1 + inc / 100) * more
					end
					srcList:ScaleAddList(buff.modList, mult * stackCount)
					if activeSkill.skillData.stackCount or buff.stackVar then
						srcList:NewMod("Multiplier:"..buff.name.."Stack", "BASE", stackCount, buff.name)
					end
					mergeBuff(srcList, debuffs, buff.name)
				end
			elseif buff.type == "Curse" or buff.type == "CurseBuff" then
				local mark = activeSkill.skillTypes[SkillType.Mark]
				if env.mode_effective and (not enemyDB:Flag(nil, "Hexproof") or modDB:Flag(nil, "CursesIgnoreHexproof")) or mark then
					local curse = {
						name = buff.name,
						fromPlayer = true,
						priority = activeSkill.skillTypes[SkillType.Aura] and 3 or 1,
						isMark = mark,
						ignoreHexLimit = modDB:Flag(activeSkill.skillCfg, "CursesIgnoreHexLimit") and not mark or false
					}
					local inc = skillModList:Sum("INC", skillCfg, "CurseEffect") + enemyDB:Sum("INC", nil, "CurseEffectOnSelf")
					local more = skillModList:More(skillCfg, "CurseEffect")
					-- This is non-ideal, but the only More for enemy is the boss effect
					if not curse.isMark then
						more = more * enemyDB:More(nil, "CurseEffectOnSelf")
					end
					if buff.type == "Curse" then
						curse.modList = new("ModList")
						curse.modList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
					else
						-- Curse applies a buff; scale by curse effect, then buff effect
						local temp = new("ModList")
						temp:ScaleAddList(buff.modList, (1 + inc / 100) * more)
						curse.buffModList = new("ModList")
						local buffInc = modDB:Sum("INC", skillCfg, "BuffEffectOnSelf")
						local buffMore = modDB:More(skillCfg, "BuffEffectOnSelf")
						curse.buffModList:ScaleAddList(temp, (1 + buffInc / 100) * buffMore)
						if env.minion then
							curse.minionBuffModList = new("ModList")
							local buffInc = env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf")
							local buffMore = env.minion.modDB:More(nil, "BuffEffectOnSelf")
							curse.minionBuffModList:ScaleAddList(temp, (1 + buffInc / 100) * buffMore)
						end
					end
					t_insert(curses, curse)	
				end
			end
		end
		if activeSkill.minion and activeSkill.minion.activeSkillList then
			local castingMinion = activeSkill.minion
			for _, activeSkill in ipairs(activeSkill.minion.activeSkillList) do
				local skillModList = activeSkill.skillModList
				local skillCfg = activeSkill.skillCfg
				for _, buff in ipairs(activeSkill.buffList) do
					if buff.type == "Buff" then
						if env.mode_buffs and activeSkill.skillData.enable then
							local skillCfg = buff.activeSkillBuff and skillCfg
							local modStore = buff.activeSkillBuff and skillModList or castingMinion.modDB
							if buff.applyAllies then
								modDB.conditions["AffectedBy"..buff.name] = true
								modDB.conditions["UsedBy"..buff.name] = true
								local srcList = new("ModList")
								local inc = modStore:Sum("INC", skillCfg, "BuffEffect") + modDB:Sum("INC", nil, "BuffEffectOnSelf")
								local more = modStore:More(skillCfg, "BuffEffect") * modDB:More(nil, "BuffEffectOnSelf")
								srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
								mergeBuff(srcList, buffs, buff.name)
								mergeBuff(buff.unscalableModList, buffs, buff.name)
							else
								modDB.conditions["UsedBy"..buff.name] = true
							end
							if env.minion and (env.minion == castingMinion or buff.applyAllies) then
				 				env.minion.modDB.conditions["AffectedBy"..buff.name:gsub(" ","")] = true
								env.minion.modDB.conditions["UsedBy"..buff.name:gsub(" ","")] = true
								local srcList = new("ModList")
								local inc = modStore:Sum("INC", skillCfg, "BuffEffect", "BuffEffectOnMinion") + env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf")
								local more = modStore:More(skillCfg, "BuffEffect", "BuffEffectOnMinion") * env.minion.modDB:More(nil, "BuffEffectOnSelf")
								srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
								mergeBuff(srcList, minionBuffs, buff.name)
								mergeBuff(buff.unscalableModList, minionBuffs, buff.name)
							 
							end
						end
					elseif buff.type == "Aura" then
						if env.mode_buffs and activeSkill.skillData.enable then
							if not modDB:Flag(nil, "AlliesAurasCannotAffectSelf") then
								local srcList = new("ModList")
								local inc = skillModList:Sum("INC", skillCfg, "AuraEffect", "BuffEffect") + modDB:Sum("INC", nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
								local more = skillModList:More(skillCfg, "AuraEffect", "BuffEffect") * modDB:More(nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
								srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
								mergeBuff(srcList, buffs, buff.name)
								mergeBuff(buff.unscalableModList, buffs, buff.name)
							end
							if env.minion and (env.minion ~= activeSkill.minion or not activeSkill.skillData.auraCannotAffectSelf) then
								local srcList = new("ModList")
								local inc = skillModList:Sum("INC", skillCfg, "AuraEffect", "BuffEffect") + env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
								local more = skillModList:More(skillCfg, "AuraEffect", "BuffEffect") * env.minion.modDB:More(nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
								srcList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
								mergeBuff(srcList, minionBuffs, buff.name)
							end
						end
					elseif buff.type == "Curse" then
					 
						if env.mode_effective and activeSkill.skillData.enable and (not enemyDB:Flag(nil, "Hexproof") or activeSkill.skillTypes[SkillType.Mark]) then
							local curse = {
								name = buff.name,
								priority = 1,
							}
							local inc = skillModList:Sum("INC", skillCfg, "CurseEffect") + enemyDB:Sum("INC", nil, "CurseEffectOnSelf")
							 
							local more = skillModList:More(skillCfg, "CurseEffect") * enemyDB:More(nil, "CurseEffectOnSelf")
							curse.modList = new("ModList")
							 
							curse.modList:ScaleAddList(buff.modList, (1 + inc / 100) * more)
							 
							t_insert(minionCurses, curse)
						end
					elseif buff.type == "Debuff" then
						local stackCount
						if buff.stackVar then
							stackCount = modDB:Sum("BASE", skillCfg, "Multiplier:"..buff.stackVar)
							if buff.stackLimit then
								stackCount = m_min(stackCount, buff.stackLimit)
							elseif buff.stackLimitVar then
								stackCount = m_min(stackCount, modDB:Sum("BASE", skillCfg, "Multiplier:"..buff.stackLimitVar))
							end
						else
							stackCount = activeSkill.skillData.stackCount or 1
						end
						if env.mode_effective and stackCount > 0 then
							activeSkill.debuffSkill = true
							local srcList = new("ModList")
							srcList:ScaleAddList(buff.modList, stackCount)
							if activeSkill.skillData.stackCount then
								srcList:NewMod("Multiplier:"..buff.name.."Stack", "BASE", activeSkill.skillData.stackCount, buff.name)
							end
							mergeBuff(srcList, debuffs, buff.name)
						end
					end
				end
			end
		end
	end

	-- Check for extra curses
	for dest, modDB in pairs({[curses] = modDB, [minionCurses] = env.minion and env.minion.modDB}) do
		for _, value in ipairs(modDB:List(nil, "ExtraCurse")) do
			local gemModList = new("ModList")
			local grantedEffect = env.data.skills[value.skillId]
			if grantedEffect then
				calcs.mergeSkillInstanceMods(env, gemModList, {
					grantedEffect = grantedEffect,
					level = value.level,
					quality = 0,
				})
				local curseModList = { }
				for _, mod in ipairs(gemModList) do
					for _, tag in ipairs(mod) do
						if tag.type == "GlobalEffect" and tag.effectType == "Curse" then
							t_insert(curseModList, mod)
							break
						end
					end
				end
				if value.applyToPlayer then
					-- Sources for curses on the player don't usually respect any kind of limit, so there's little point bothering with slots
					if modDB:Sum("BASE", nil, "AvoidCurse") < 100 then
						modDB.conditions["Cursed"] = true
						modDB.multipliers["CurseOnSelf"] = (modDB.multipliers["CurseOnSelf"] or 0) + 1
						modDB.conditions["AffectedBy"..grantedEffect.name:gsub(" ","")] = true						
						local cfg = { skillName = grantedEffect.name }
						local inc = modDB:Sum("INC", cfg, "CurseEffectOnSelf") + gemModList:Sum("INC", nil, "CurseEffectAgainstPlayer")
						local more = modDB:More(cfg, "CurseEffectOnSelf")
						modDB:ScaleAddList(curseModList, (1 + inc / 100) * more)
					end
				elseif not enemyDB:Flag(nil, "Hexproof") or modDB:Flag(nil, "CursesIgnoreHexproof") then
					local curse = {
						name = grantedEffect.name,
						fromPlayer = (dest == curses),
						priority = 2,
					}
					curse.modList = new("ModList")
					curse.modList:ScaleAddList(curseModList, (1 + enemyDB:Sum("INC", nil, "CurseEffectOnSelf") / 100) * enemyDB:More(nil, "CurseEffectOnSelf"))
					t_insert(dest, curse)
				end
			end
		end
	end
	
	-- Assign curses to slots
	local curseSlots = { }
	env.curseSlots = curseSlots
	-- Currently assume only 1 mark is possible
	local markSlotted = false
	for _, source in ipairs({curses, minionCurses}) do
		for _, curse in ipairs(source) do
			-- calculate curses that ignore hex limit after
			if not curse.ignoreHexLimit then 
				local slot
				for i = 1, source.limit do
					--Prevent multiple marks from being considered
					if curse.isMark then
						if markSlotted then
							slot = nil
							break
						end
					end
					if not curseSlots[i] then
						slot = i
						break
					elseif curseSlots[i].name == curse.name then
						if curseSlots[i].priority < curse.priority then
							slot = i
						else
							slot = nil
						end
						break
					elseif curseSlots[i].priority < curse.priority then
						slot = i
					end
				end
				if slot then
					if curseSlots[slot] and curseSlots[slot].isMark then
						markSlotted = false
					end
					curseSlots[slot] = curse
					if curse.isMark then
						markSlotted = true
					end
				end
			end
		end
	end

	for _, source in ipairs({curses, minionCurses}) do
		for _, curse in ipairs(source) do
			if curse.ignoreHexLimit then 	
				local skipAddingCurse = false
				for i = 1, #curseSlots do
					if curseSlots[i].name == curse.name then
						-- if curse is higher priority, replace current curse with it, otherwise if same or lower priority skip it entirely
						if curseSlots[i].priority < curse.priority then
							curseSlots[i] = curse
						end
						skipAddingCurse = true
						break
					end
				end
				if not skipAddingCurse then
					curseSlots[#curseSlots + 1] = curse
				end
			end
		end
	end


-- Process guard buffs
	local guardSlots = { }
	local nonVaal = false
	for name, modList in pairs(guards) do
		if name == "瓦尔.熔岩护盾" then
			wipeTable(guardSlots)
			nonVaal = false
			t_insert(guardSlots, { name = name, modList = modList })
			break
		elseif name:match("^瓦尔") then
			t_insert(guardSlots, { name = name, modList = modList })
		elseif not nonVaal then
			t_insert(guardSlots, { name = name, modList = modList })
			nonVaal = true
		end
	end
	if nonVaal then
		modDB.conditions["AffectedByNonVaalGuardSkill"] = true
	end
	for _, guard in ipairs(guardSlots) do
		modDB.conditions["AffectedByGuardSkill"] = true
		modDB.conditions["AffectedBy"..guard.name:gsub(" ","")] = true
		mergeBuff(guard.modList, buffs, guard.name)
	end
	-- Apply buff/debuff modifiers
	for _, modList in pairs(buffs) do
		modDB:AddList(modList)
		if not modList.notBuff then
			modDB.multipliers["BuffOnSelf"] = (modDB.multipliers["BuffOnSelf"] or 0) + 1
		end
		if env.minion then
			for _, value in ipairs(modList:List(env.player.mainSkill.skillCfg, "MinionModifier")) do
				if not value.type or env.minion.type == value.type then
					env.minion.modDB:AddMod(value.mod)
				end
			end
		end
	end
	if env.minion then
		for _, modList in pairs(minionBuffs) do
			env.minion.modDB:AddList(modList)
		end
	end
	for _, modList in pairs(debuffs) do
		enemyDB:AddList(modList)
	end
	modDB.multipliers["CurseOnEnemy"] = #curseSlots
	local affectedByCurse = { }
	for _, slot in ipairs(curseSlots) do
		enemyDB.conditions["Cursed"] = true
		if slot.isMark then
			enemyDB.conditions["Marked"] = true
		end
		if slot.fromPlayer then
			affectedByCurse[env.enemy] = true
		end
		if slot.modList then
			enemyDB:AddList(slot.modList)
		end
		if slot.buffModList then
			modDB:AddList(slot.buffModList)
		end
		if slot.minionBuffModList then
			env.minion.modDB:AddList(slot.minionBuffModList)
		end
	end
	
	
	
	for _, activeSkill in ipairs(env.player.activeSkillList) do -- Do another pass on the SkillList to catch effects of buffs, if needed
		if activeSkill.activeEffect.grantedEffect.name == "枯萎" and activeSkill.skillPart == 2 then
			local rate = (1 / 0.3) * calcLib.mod(activeSkill.skillModList, activeSkill.skillCfg, "Speed")
			local duration = calcSkillDuration(activeSkill.skillModList, activeSkill.skillCfg, activeSkill.skillData, env, enemyDB)
			local maximum = m_min((m_floor(rate * duration) - 1), 19)
			activeSkill.skillModList:NewMod("Multiplier:枯萎MaxStagesAfterFirst", "BASE", maximum, "Base")
			activeSkill.skillModList:NewMod("Multiplier:枯萎StageAfterFirst", "BASE", maximum, "Base")
		end
		if activeSkill.activeEffect.grantedEffect.name == "忏悔烙印" and activeSkill.skillPart == 2 then
			local rate = 1 / (activeSkill.skillData.repeatFrequency / (1 + env.player.mainSkill.skillModList:Sum("INC", env.player.mainSkill.skillCfg, "Speed", "BrandActivationFrequency") / 100) / activeSkill.skillModList:More(activeSkill.skillCfg, "BrandActivationFrequency"))
			local duration = calcSkillDuration(activeSkill.skillModList, activeSkill.skillCfg, activeSkill.skillData, env, enemyDB)
			local ticks = m_min((m_floor(rate * duration) - 1), 19)
			activeSkill.skillModList:NewMod("Multiplier:忏悔烙印MaxStagesAfterFirst", "BASE", ticks, "Base")
			activeSkill.skillModList:NewMod("Multiplier:忏悔烙印StageAfterFirst", "BASE", ticks, "Base")
		end
		if activeSkill.activeEffect.grantedEffect.name == "灼热光线" and activeSkill.skillPart == 2 then
			local rate = (1 / 0.5) * calcLib.mod(activeSkill.skillModList, activeSkill.skillCfg, "Speed")
			local duration = calcSkillDuration(activeSkill.skillModList, activeSkill.skillCfg, activeSkill.skillData, env, enemyDB)
			local maximum = m_min((m_floor(rate * duration) - 1), 7)
			activeSkill.skillModList:NewMod("Multiplier:灼热光线MaxStagesAfterFirst", "BASE", maximum, "Base")
			activeSkill.skillModList:NewMod("Multiplier:灼热光线StageAfterFirst", "BASE", maximum, "Base")
			if maximum >= 7 then
				activeSkill.skillModList:NewMod("Condition:灼热光线MaxStages", "FLAG", true, "Config")
				enemyDB:NewMod("FireResist", "BASE", -25, "灼热光线", { type = "GlobalEffect", effectType = "Debuff" } )
			end
		end
	end
	-- Process Triggered Skill and Set Trigger Conditions
	--if env.mode ~= "CACHE" then
		-- Cospri's Malice
		if env.player.mainSkill.skillData.triggeredByCospris and not env.player.mainSkill.skillFlags.minion then
			local spellCount = {}
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				if skill.skillTypes[SkillType.Melee] and band(skill.skillCfg.flags, bor(ModFlag.Sword, ModFlag.Weapon1H)) > 0 and skill ~= env.player.mainSkill then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate)
				end
				if skill.skillData.triggeredByCospris and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot then
					t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByCospris = nil
				env.player.mainSkill.infoMessage = "未发现 【卡斯普里怨恨】 的触发技能"
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true
				local uuid = cacheSkillUUID(source)
				local sourceAPS = GlobalCache.cachedData["CACHE"][uuid].Speed
				local dualWield = false

				sourceAPS, dualWield = calcDualWieldImpact(env, sourceAPS, source.skillData.doubleHitsWhenDualWielding)

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown, dualWield)

				-- Account for chance to hit/crit
				local sourceCritChance = GlobalCache.cachedData["CACHE"][uuid].CritChance
				trigRate = trigRate * sourceCritChance / 100
				if breakdown then
					breakdown.Speed = {
						s_format("%.2fs ^8(调整后触发速率)", output.ServerTriggerRate),
						s_format("x %.2f%% ^8(【%s】的有效暴击几率)", sourceCritChance, source.activeEffect.grantedEffect.name),
						s_format("= %.2f ^8每秒", trigRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "【卡斯普里怨恨】 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = "【卡斯普里怨恨】"
			end
		end
		
		-- Mjolner
		if env.player.mainSkill.skillData.triggeredByMjolner and not env.player.mainSkill.skillFlags.minion then
			local spellCount = {}
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				if (skill.skillTypes[SkillType.Hit] or skill.skillTypes[SkillType.Attack]) and band(skill.skillCfg.flags, bor(ModFlag.Mace, ModFlag.Weapon1H)) > 0 and skill ~= env.player.mainSkill then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate)
				end
				if skill.skillData.triggeredByMjolner and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot then
					t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByMjolner = nil
				env.player.mainSkill.infoMessage = "未发现【沉默之雷】的触发技能"
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true
				env.player.mainSkill.skillData.triggerCostMultiplier = 0
				local uuid = cacheSkillUUID(source)
				local sourceAPS = GlobalCache.cachedData["CACHE"][uuid].Speed
				local dualWield = false

				sourceAPS, dualWield = calcDualWieldImpact(env, sourceAPS, source.skillData.doubleHitsWhenDualWielding)

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown, dualWield)

				-- Account for chance to hit/crit
				local sourceHitChance = GlobalCache.cachedData["CACHE"][uuid].HitChance
				trigRate = trigRate * sourceHitChance / 100
				if breakdown then
					breakdown.Speed = {
						s_format("%.2fs ^8(调整后触发速率)", output.ServerTriggerRate),
						s_format("x %.0f%% ^8(【%s】 的命中率)", sourceHitChance, source.activeEffect.grantedEffect.name),
						s_format("= %.2f ^8每秒", trigRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "【沉默之雷】 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = "【沉默之雷】"
			end
		end
	-- Mirage Archer Support
	-- This creates a new skill group for the Mirage Archer DPS over-write called 'Mirage Archer'
	if env.player.mainSkill.skillData.triggeredByMirageArcher and not env.player.mainSkill.skillFlags.minion and not env.player.mainSkill.marked and env.player.mainSkill.socketGroup.label ~= "幻影射手" then
			local usedSkill = nil
			local uuid = cacheSkillUUID(env.player.mainSkill)
			local calcMode = env.mode == "CALCS" and "CALCS" or "MAIN"

		-- cache a new copy of this skill that's affected by Mirage Archer
		if avoidCache then
			usedSkill = env.player.mainSkill
			env.dontCache = true
		else
			if not GlobalCache.cachedData[calcMode][uuid] then
				calcs.buildActiveSkill(env, calcMode, env.player.mainSkill, true)
			end

			if GlobalCache.cachedData[calcMode][uuid] and not avoidCache then
				usedSkill = GlobalCache.cachedData[calcMode][uuid].ActiveSkill
			end
		end

		if usedSkill then
			local moreDamage =  usedSkill.skillModList:Sum("BASE", usedSkill.skillCfg, "MirageArcherLessDamage")
			local moreAttackSpeed = usedSkill.skillModList:Sum("BASE", usedSkill.skillCfg, "MirageArcherLessAttackSpeed")
			local mirageCount =  usedSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "MirageArcherMaxCount")

			-- Make a copy of this skill so we can add new modifiers to the copy affected by Mirage Archers
			local newSkill, newEnv = calcs.copyActiveSkill(env, calcMode, usedSkill)

			-- Add new modifiers to new skill (which already has all the old skill's modifiers)
			newSkill.skillModList:NewMod("Damage", "MORE", moreDamage, "幻影射手", env.player.mainSkill.ModFlags, env.player.mainSkill.KeywordFlags)
			newSkill.skillModList:NewMod("Speed", "MORE", moreAttackSpeed, "幻影射手", env.player.mainSkill.ModFlags, env.player.mainSkill.KeywordFlags)

			env.player.mainSkill.mirage = { }
			env.player.mainSkill.mirage.count = mirageCount
			env.player.mainSkill.mirage.name = usedSkill.activeEffect.grantedEffect.name

			if usedSkill.skillPartName then
				env.player.mainSkill.mirage.skillPart = usedSkill.skillPart
				env.player.mainSkill.mirage.skillPartName = usedSkill.skillPartName
				env.player.mainSkill.mirage.infoMessage2 = usedSkill.activeEffect.grantedEffect.name
			else
				env.player.mainSkill.mirage.skillPartName = nil
			end
			env.player.mainSkill.mirage.infoTrigger = "幻影射手"

			-- Recalculate the offensive/defensive aspects of the Mirage Archer influence on skill
			newEnv.player.mainSkill = newSkill
			-- mark it so we don't recurse infinitely
			newSkill.marked = true
			newEnv.dontCache = true
			calcs.perform(newEnv)

			env.player.mainSkill.infoMessage = tostring(mirageCount) .. " 幻影射手使用 " .. usedSkill.activeEffect.grantedEffect.name

			-- Re-link over the output
			env.player.mainSkill.mirage.output = newEnv.player.output

			if newSkill.minion then
				env.player.mainSkill.mirage.minion = {}
				env.player.mainSkill.mirage.minion.output = newEnv.minion.output
			end

			-- Make any necessary corrections to output
			env.player.mainSkill.mirage.output.ManaCost = 0

			if newEnv.player.breakdown then
				env.player.mainSkill.mirage.breakdown = newEnv.player.breakdown
				-- Make any necessary corrections to breakdown
				env.player.mainSkill.mirage.breakdown.ManaCost = nil
				if newSkill.minion then
					env.player.mainSkill.mirage.minion.breakdown = newEnv.minion.breakdown
				end
			end
		else
			env.player.mainSkill.infoMessage2 = "未发现幻影射手可用技能"
		end
 	end
-- Kitava's Thirst
		if env.player.mainSkill.skillData.triggeredByManaSpent and not env.player.mainSkill.skillFlags.minion then
			local triggerName = "奇塔弗之渴望"
			local spellCount = 0
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local reqManaCost = env.player.modDB:Sum("BASE", nil, "KitavaRequiredManaCost")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				if not skill.skillTypes[SkillType.Triggered] and skill ~= env.player.mainSkill and not skill.skillData.triggeredByManaSpent then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate, reqManaCost)
				end
				if skill.skillData.triggeredByManaSpent and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot then
					spellCount = spellCount + 1
				end
			end

			if not source or spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByManaSpent = nil
				env.player.mainSkill.infoMessage = s_format("未发现【%s】的触发技能", triggerName)
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true

				output.ActionTriggerRate = getTriggerActionTriggerRate(env.player.mainSkill.skillData.cooldown, env, breakdown)

				-- Get action trigger rate
				local kitavaCD = getTriggerDefaultCooldown(env.player.mainSkill.supportList, "SupportCastOnManaSpent")

				trigRate = icdr / kitavaCD
				output.SourceTriggerRate = trigRate
				output.ServerTriggerRate = m_min(output.SourceTriggerRate, output.ActionTriggerRate)
				if breakdown then
					local modActionCooldown = kitavaCD / icdr
					local rateCapAdjusted = m_ceil(modActionCooldown * data.misc.ServerTickRate) / data.misc.ServerTickRate
					local extraICDRNeeded = m_ceil((modActionCooldown - rateCapAdjusted + data.misc.ServerTickTime) * icdr * 1000)
					breakdown.SimData = {
						s_format("%.2f ^8(奇塔弗之渴望的基础冷却时间)", kitavaCD),
						s_format("/ %.2f ^8(提高/降低 冷却回复速度)", icdr),
						s_format("= %.4f ^8(最终冷却时间)", modActionCooldown),
						s_format(""),
						s_format("%.3f ^8(调整为服务器触发速率)", rateCapAdjusted),
						s_format("^8(额外需要 %d%% 冷却速度将达到下个触发点)", extraICDRNeeded),
						s_format(""),
						s_format("触发速率:"),
						s_format("1 / %.3f", rateCapAdjusted),
						s_format("= %.2f ^8每秒", 1 / rateCapAdjusted),
					}
					breakdown.ServerTriggerRate = {
						s_format("%.2f ^8('触发速率上限' 和 '技能触发速率' 之间的较小值)", output.ServerTriggerRate),
					}
				end

				-- Account for chance to trigger
				local kitavaTriggerChance = env.player.modDB:Sum("BASE", nil, "KitavaTriggerChance")
				trigRate = output.ServerTriggerRate * kitavaTriggerChance / 100
				if breakdown then
					breakdown.Speed = {
						s_format("%.2fs ^8(调整触发速率)", output.ServerTriggerRate),
						s_format("x %.2f%% ^8(奇塔弗之渴望的触发几率)", kitavaTriggerChance),
						s_format("= %.2f ^8每秒", trigRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "【奇塔弗之渴望】 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = triggerName
			end
		end
		-- Crafted Trigger
		if env.player.mainSkill.skillData.triggeredByCraft and not env.player.mainSkill.skillFlags.minion then
			local triggerName = "工艺"
			local spellCount = 0
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				if (skill.skillTypes[SkillType.Hit] or skill.skillTypes[SkillType.Attack] or skill.skillTypes[SkillType.Spell]) and skill ~= env.player.mainSkill and not skill.skillData.triggeredByCraft then
					source, trigRate = skill, 0
				end
				if skill.skillData.triggeredByCraft and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot then
					spellCount = spellCount + 1
				end
				-- we just need one source and one linked spell
				if source and spellCount > 0 then
					break
				end
			end			
			if not source or spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByCraft = nil
				env.player.mainSkill.infoMessage = s_format("未发现 %s 的触发技能", triggerName)
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true							
				env.player.mainSkill.skillData.triggerCostMultiplier = 2.5
				output.ActionTriggerRate = getTriggerActionTriggerRate(env.player.mainSkill.skillData.cooldown, env, breakdown)
				-- Get action trigger rate
				local craftedCD = getTriggerDefaultCooldown(env.player.mainSkill.supportList, "SupportTriggerSpellOnSkillUse")

				trigRate = icdr / craftedCD
				output.SourceTriggerRate = trigRate
				output.ServerTriggerRate = m_min(output.SourceTriggerRate, output.ActionTriggerRate)
				if breakdown then
					local modActionCooldown = craftedCD / icdr
					local rateCapAdjusted = m_ceil(modActionCooldown * data.misc.ServerTickRate) / data.misc.ServerTickRate
					local extraICDRNeeded = m_ceil((modActionCooldown - rateCapAdjusted + data.misc.ServerTickTime) * icdr * 1000)
					breakdown.SimData = {
						s_format("%.2f ^8(工艺词缀触发的基础冷却时间)", craftedCD),
						s_format("/ %.2f ^8(提高/降低 冷却回复速度)", icdr),
						s_format("= %.4f ^8(最终冷却时间)", modActionCooldown),
						s_format(""),
						s_format("%.3f ^8(调整为服务器触发速率)", rateCapAdjusted),
						s_format("^8(额外需要 %d%% 冷却速度将达到下个触发点)", extraICDRNeeded),
						s_format(""),
						s_format("触发速率:"),
						s_format("1 / %.3f", rateCapAdjusted),
						s_format("= %.2f ^8每秒", 1 / rateCapAdjusted),
					}				
					breakdown.ServerTriggerRate = {
						s_format("%.2f ^8('触发速率上限' 和 '技能触发速率' 之间的较小值)", output.ServerTriggerRate),
					}
				end

				

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = output.ServerTriggerRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "存在 武器-工艺 的触发技能"
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = triggerName
				env.player.mainSkill.skillFlags.dontDisplay = true
			end
		end
		-- Helmet Focus Trigger
		if env.player.mainSkill.skillData.triggeredByFocus and not env.player.mainSkill.skillFlags.minion then
			local triggerName = "专注"
			local spellCount = 0
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "FocusCooldownRecovery")
			local trigRate = 0
			local source = env.player.modDB:Flag(nil, "Condition:Focused")
			for _, skill in ipairs(env.player.activeSkillList) do
				if skill.skillData.triggeredByFocus and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot then
					spellCount = spellCount + 1
				end
			end
			if not source or spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByFocus = nil
				env.player.mainSkill.infoMessage = s_format("未发现 %s 的触发技能", triggerName)
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true

				output.ActionTriggerRate = getTriggerActionTriggerRate(env.player.mainSkill.skillData.cooldown, env, breakdown, true)

				-- Get action trigger rate
				local skillFocus = env.data.skills["Focus"]
				local focusCD = skillFocus.levels[1].cooldown

				trigRate = icdr / focusCD
				output.SourceTriggerRate = trigRate
				output.ServerTriggerRate = m_min(output.SourceTriggerRate, output.ActionTriggerRate)
				if breakdown then
					local modActionCooldown = focusCD / icdr
					local rateCapAdjusted = m_ceil(modActionCooldown * data.misc.ServerTickRate) / data.misc.ServerTickRate
					breakdown.SimData = {
						s_format("%.2f ^8(专注触发的冷却时间)", focusCD),
						s_format("/ %.2f ^8(提高/降低 冷却速度)", icdr),
						s_format("= %.4f ^8(最终冷却时间)", modActionCooldown),
						s_format(""),
						s_format("%.3f ^8(调整为服务器触发速率)", rateCapAdjusted),
						s_format(""),
						s_format("触发速率:"),
						s_format("1 / %.3f", rateCapAdjusted),
						s_format("= %.2f ^8每秒", 1 / rateCapAdjusted),
					}
					breakdown.ServerTriggerRate = {
						s_format("%.2f ^8('触发速率上限' 和 '技能触发速率' 之间的较小值)", output.ServerTriggerRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = output.ServerTriggerRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "存在 专注 触发技能"
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = triggerName
				env.player.mainSkill.skillFlags.dontDisplay = true
			end
		end
		-- Unique Item Trigger
		if env.player.mainSkill.skillData.triggeredByUnique and not env.player.mainSkill.skillFlags.minion then
			local uniqueTriggerName = getUniqueItemTriggerName(env.player.mainSkill)
			local triggerName = ""
			local spellCount = {}
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				if uniqueTriggerName == "诗人之笔" then
					triggerName = "诗人之笔"
					if (skill.skillTypes[SkillType.Hit] or skill.skillTypes[SkillType.Attack]) and band(skill.skillCfg.flags, ModFlag.Wand) > 0 and skill ~= env.player.mainSkill and not skill.skillData.triggeredByUnique then
						source, trigRate = findTriggerSkill(env, skill, source, trigRate)
					end
					if skill.skillData.triggeredByUnique and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot and skill.skillTypes[SkillType.Spell] then
						t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
					end
				elseif uniqueTriggerName == "马洛尼的技巧" then
					triggerName = "马洛尼的技巧"
					if skill.skillTypes[SkillType.Attack] and band(skill.skillCfg.flags, ModFlag.Bow) > 0 and skill ~= env.player.mainSkill and not skill.skillData.triggeredByUnique then
						source, trigRate = findTriggerSkill(env, skill, source, trigRate)
					end
					if skill.skillData.triggeredByUnique and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot and skill.skillTypes[SkillType.ProjectileAttack] then
						t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
					end
				elseif uniqueTriggerName == "安赛娜丝的优雅之歌" then
					triggerName = "安赛娜丝的优雅之歌"
					if (skill.skillTypes[SkillType.Hit] or skill.skillTypes[SkillType.Attack]) and band(skill.skillCfg.flags, ModFlag.Bow) > 0 and skill ~= env.player.mainSkill and not skill.skillData.triggeredByUnique then
						source, trigRate = findTriggerSkill(env, skill, source, trigRate)
					end
					if skill.skillData.triggeredByUnique and env.player.mainSkill.socketGroup.slot == skill.socketGroup.slot and skill.skillTypes[SkillType.Spell] then
						t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
					end
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByUnique = nil
				env.player.mainSkill.infoMessage = s_format("未发现 %s 的触发技能", triggerName)
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true
				local uuid = cacheSkillUUID(source)
				local sourceAPS = GlobalCache.cachedData["CACHE"][uuid].Speed
				local dualWield = false

				sourceAPS, dualWield = calcDualWieldImpact(env, sourceAPS, source.skillData.doubleHitsWhenDualWielding)

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown, dualWield)

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = triggerName .. " 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoTrigger = triggerName
			end
			if env.player.mainSkill.activeEffect.grantedEffect.name == "审判风暴" then
			env.player.mainSkill.skillData.triggered = true
			env.player.mainSkill.skillData.triggerRate = 2.0
			env.player.mainSkill.skillData.triggerSource = nil
			elseif env.player.mainSkill.activeEffect.grantedEffect.name == "审判烈焰" then
				env.player.mainSkill.skillData.triggered = true
				env.player.mainSkill.skillData.triggerRate = 2.0
				env.player.mainSkill.skillData.triggerSource = nil
			end
		end

		-- Cast On Critical Strike Support (CoC)
		if env.player.mainSkill.skillData.triggeredByCoC and not env.player.mainSkill.skillFlags.minion then
			local spellCount = {}
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				local match1 = (skill.activeEffect.grantedEffect.fromItem or 0) and skill.socketGroup.slot == env.player.mainSkill.socketGroup.slot
				local match2 = (not skill.activeEffect.grantedEffect.fromItem) and skill.socketGroup == env.player.mainSkill.socketGroup
				if skill.skillTypes[SkillType.Attack] and skill ~= env.player.mainSkill and (match1 or match2) then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate)
				end
				if skill.skillData.triggeredByCoC and (match1 or match2) then
					t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByCoC = nil
				env.player.mainSkill.infoMessage = "未发现 CoC 的触发技能"
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true
				local uuid = cacheSkillUUID(source)
				local sourceAPS = GlobalCache.cachedData["CACHE"][uuid].Speed

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown)

				-- Account for chance to hit/crit
				local sourceCritChance = GlobalCache.cachedData["CACHE"][uuid].CritChance
				trigRate = trigRate * sourceCritChance / 100
				trigRate = trigRate * (source.skillData.chanceToTriggerOnCrit or 100) / 100
				if breakdown then
					breakdown.Speed = {
						s_format("%.2fs ^8(调整后触发速率)", output.ServerTriggerRate),
						s_format("x %.2f%% ^8(【%s】的暴击率)", sourceCritChance, source.activeEffect.grantedEffect.name),
						s_format("x %.2f%% ^8(暴击时触发的几率)", source.skillData.chanceToTriggerOnCrit or 100),
						s_format("= %.2f ^8每秒", trigRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "CoC 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = "CoC"
			end
		end

		-- Cast On Melee Kill Support (CoMK)
		if env.player.mainSkill.skillData.triggeredByMeleeKill and not env.player.mainSkill.skillFlags.minion and modDB:Flag(nil, "Condition:KilledRecently") then
			local spellCount = {}
			local icdr = calcLib.mod(env.player.mainSkill.skillModList, env.player.mainSkill.skillCfg, "CooldownRecovery")
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				local match1 = (skill.activeEffect.grantedEffect.fromItem or 0) and skill.socketGroup.slot == env.player.mainSkill.socketGroup.slot
				local match2 = (not skill.activeEffect.grantedEffect.fromItem) and skill.socketGroup == env.player.mainSkill.socketGroup
				if skill.skillTypes[SkillType.Attack] and skill.skillTypes[SkillType.Melee] and skill ~= env.player.mainSkill and (match1 or match2) then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate)
				end
				if skill.skillData.triggeredByMeleeKill and (match1 or match2) then
					t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown / icdr, next_trig = 0, count = 0 })
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredByMeleeKill = nil
				env.player.mainSkill.infoMessage = "未发现 CoMK 的触发技能"
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true
				local uuid = cacheSkillUUID(source)
				local sourceAPS = GlobalCache.cachedData["CACHE"][uuid].Speed

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, sourceAPS, spellCount, output, breakdown)

				-- Account for chance to tigger on Melee Kill
				trigRate = trigRate * source.skillData.chanceToTriggerOnMeleeKill / 100

				if breakdown then
					breakdown.Speed = {
						s_format("%.2fs ^8(调整后触发速率)", output.ServerTriggerRate),
						s_format("x %.2f%% ^8(近战击败时触发的几率)", source.skillData.chanceToTriggerOnMeleeKill),
						s_format("= %.2f ^8每秒", trigRate),
					}
				end

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "CoMK 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = "CoMK"
			end
		end

		-- Cast While Channelling
		if env.player.mainSkill.skillData.triggeredWhileChannelling and not env.player.mainSkill.skillFlags.minion then
			local spellCount = {}
			local trigRate = 0
			local source = nil
			for _, skill in ipairs(env.player.activeSkillList) do
				local match1 = (skill.activeEffect.grantedEffect.fromItem or 0) and skill.socketGroup.slot == env.player.mainSkill.socketGroup.slot
				local match2 = (not skill.activeEffect.grantedEffect.fromItem) and skill.socketGroup == env.player.mainSkill.socketGroup
				if skill.skillTypes[SkillType.Channelled] and skill ~= env.player.mainSkill and (match1 or match2) then
					source, trigRate = findTriggerSkill(env, skill, source, trigRate)
				end
				if skill.skillData.triggeredWhileChannelling and (match1 or match2) then
					t_insert(spellCount, { uuid = cacheSkillUUID(skill), cd = skill.skillData.cooldown, next_trig = 0, count = 0 })
				end
			end
			if not source or #spellCount < 1 then
				env.player.mainSkill.skillData.triggeredWhileChannelling = nil
				env.player.mainSkill.infoMessage = "未发现 CwC 的触发技能"
				env.player.mainSkill.infoMessage2 = "DPS 报表信息-假设为自施法"
				env.player.mainSkill.infoTrigger = ""
			else
				env.player.mainSkill.skillData.triggered = true

				-- Get action trigger rate
				trigRate = calcActualTriggerRate(env, source, nil, spellCount, output, breakdown)

				-- Account for Trigger-related INC/MORE modifiers
				addTriggerIncMoreMods(env.player.mainSkill, env.player.mainSkill)
				env.player.mainSkill.skillData.triggerRate = trigRate
				env.player.mainSkill.skillData.triggerSource = source
				env.player.mainSkill.infoMessage = "CwC 触发技能: " .. source.activeEffect.grantedEffect.name
				env.player.mainSkill.infoMessage2 = ""
				env.player.mainSkill.infoTrigger = "CwC"

				env.player.mainSkill.skillFlags.dontDisplay = true
			end
		end
	--end
	
	
	-- Fix the configured impale stacks on the enemy
	-- 		If the config is missing (blank), then use the maximum number of stacks
	--		If the config is larger than the maximum number of stacks, replace it with the correct maximum
	local maxImpaleStacks = modDB:Sum("BASE", nil, "ImpaleStacksMax")
	if not enemyDB:HasMod("BASE", nil, "Multiplier:ImpaleStacks") then
		enemyDB:NewMod("Multiplier:ImpaleStacks", "BASE", maxImpaleStacks, "Config", { type = "Condition", var = "Combat" })
	elseif enemyDB:Sum("BASE", nil, "Multiplier:ImpaleStacks") > maxImpaleStacks then
		enemyDB:ReplaceMod("Multiplier:ImpaleStacks", "BASE", maxImpaleStacks, "Config", { type = "Condition", var = "Combat" })
	end
	
	
	
	output.MaximumShock = modDB:Override(nil, "ShockMax") or 50
-- Calculates maximum Shock, then applies the strongest Shock effect to the enemy
	if (enemyDB:Sum("BASE", nil, "ShockVal") > 0 or modDB:Sum(nil, "ShockBase", "ShockOverride")) and not enemyDB:Flag(nil, "Condition:AlreadyShocked") then
		local overrideShock = 0
		for i, value in ipairs(modDB:Tabulate("BASE", { }, "ShockBase", "ShockOverride")) do
			local mod = value.mod
			local inc = 1 + modDB:Sum("INC", nil, "EnemyShockEffect") / 100
			local effect = mod.value
			if mod.name == "ShockOverride" then
				enemyDB:NewMod("Condition:Shocked", "FLAG", true, mod.source)
			end
			if mod.name == "ShockBase" then
				effect = effect * inc
				modDB:NewMod("ShockOverride", "BASE", effect, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
			end
			overrideShock = m_max(overrideShock or 0, effect or 0)
		end
		output.MaximumShock = modDB:Override(nil, "ShockMax") or 50
		output.CurrentShock = m_floor(m_min(m_max(overrideShock, enemyDB:Sum("BASE", nil, "ShockVal")), output.MaximumShock))
		enemyDB:NewMod("DamageTaken", "INC", m_floor(output.CurrentShock), "Shock", { type = "Condition", var = "Shocked"} )
		enemyDB:NewMod("Condition:AlreadyShocked", "FLAG", true, { type = "Condition", var = "Shocked"} ) -- Prevents Shock from applying doubly for minions
	end
	
	-- Calculates maximum Scorch, then applies the strongest Scorch effect to the enemy
	if (enemyDB:Sum("BASE", nil, "ScorchVal") > 0 or modDB:Sum(nil, "ScorchBase", "ScorchOverride")) and not enemyDB:Flag(nil, "Condition:AlreadyScorched") then
		local overrideScorch = 0
		for i, value in ipairs(modDB:Tabulate("BASE", { }, "ScorchBase", "ScorchOverride")) do
			local mod = value.mod
			local inc = 1 + modDB:Sum("INC", nil, "EnemyScorchEffect") / 100
			local effect = mod.value
			if mod.name == "ScorchOverride" then
				enemyDB:NewMod("Condition:Scorched", "FLAG", true, mod.source)
			end
			if mod.name == "ScorchBase" then
				effect = effect * inc
				modDB:NewMod("ScorchOverride", "BASE", effect, mod.source, mod.flags, mod.keywordFlags, unpack(mod))
			end
			overrideScorch = m_max(overrideScorch or 0, effect or 0)
		end
		output.MaximumScorch = modDB:Override(nil, "ScorchMax") or 50
		output.CurrentScorch = m_floor(m_min(m_max(overrideScorch, enemyDB:Sum("BASE", nil, "ScorchVal")), output.MaximumScorch))
		enemyDB:NewMod("ElementalResist", "BASE",  -m_floor(output.CurrentScorch), "Scorch", { type = "Condition", var = "Scorched"} )
		enemyDB:NewMod("Condition:AlreadyScorched", "FLAG", true, { type = "Condition", var = "Scorched"} ) -- Prevents Scorch from applying doubly for minions
	end


	-- Check for extra auras
	for _, value in ipairs(modDB:List(nil, "ExtraAura")) do
		local modList = { value.mod }
		if not value.onlyAllies then
			local inc = modDB:Sum("INC", nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
			local more = modDB:More(nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
			modDB:ScaleAddList(modList, (1 + inc / 100) * more)
			if not value.notBuff then
				modDB.multipliers["BuffOnSelf"] = (modDB.multipliers["BuffOnSelf"] or 0) + 1
			end
		end
		if env.minion and not modDB:Flag(nil, "SelfAurasCannotAffectAllies") then
			local inc = env.minion.modDB:Sum("INC", nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
			local more = env.minion.modDB:More(nil, "BuffEffectOnSelf", "AuraEffectOnSelf")
			env.minion.modDB:ScaleAddList(modList, (1 + inc / 100) * more)
		end
	end

	-- Check for modifiers to apply to actors affected by player auras or curses
	for _, value in ipairs(modDB:List(nil, "AffectedByAuraMod")) do
		for actor in pairs(affectedByAura) do
			actor.modDB:AddMod(value.mod)
		end
	end
	for _, value in ipairs(modDB:List(nil, "AffectedByCurseMod")) do
		for actor in pairs(affectedByCurse) do
			actor.modDB:AddMod(value.mod)
		end
	end

	-- Merge keystones again to catch any that were added by buffs
	mergeKeystones(env)
	--mergeNotable(env)
	-- Special handling for Dancing Dervish
	if modDB:Flag(nil, "DisableWeapons") then
		env.player.weaponData1 = copyTable(env.data.unarmedWeaponData[env.classId])
		modDB.conditions["Unarmed"] = true
	elseif env.weaponModList1 then
		modDB:AddList(env.weaponModList1)
	end

	-- Process misc buffs/modifiers
	doActorMisc(env, env.player)
	if env.minion then
		doActorMisc(env, env.minion)
	end
	doActorMisc(env, env.enemy)

	for _, activeSkill in ipairs(env.player.activeSkillList) do
		if activeSkill.skillFlags.totem then
			local limit = env.player.mainSkill.skillModList:Sum("BASE", env.player.mainSkill.skillCfg, "ActiveTotemLimit", "ActiveBallistaLimit" )
			output.ActiveTotemLimit = m_max(limit, output.ActiveTotemLimit or 0)
			output.TotemsSummoned = modDB:Override(nil, "TotemsSummoned") or output.ActiveTotemLimit
		end
	end

-- Apply exposures
	for _, element in ipairs({"Fire", "Cold", "Lightning"}) do
		local min = math.huge
		local source = ""
		for _, mod in ipairs(enemyDB:Tabulate("BASE", nil, element.."Exposure")) do
			if mod.value < min then
				min = mod.value
				source = mod.mod.source
			end
		end
		if min ~= math.huge then
			-- Modify the magnitude of all exposures
			for _, mod in ipairs(modDB:Tabulate("BASE", nil, "ExtraExposure", "Extra"..element.."Exposure")) do
				min = min + mod.value
			end
			enemyDB:NewMod(element.."Resist", "BASE", m_min(min, modDB:Override(nil, "ExposureMin")), source)
			modDB:NewMod("Condition:AppliedExposureRecently", "FLAG", true, "")
			
		end
	end

	
	-- Handle consecrated ground effects on enemies
	if enemyDB:Flag(nil, "Condition:OnConsecratedGround") then
		local effect = 1 + modDB:Sum("INC", nil, "ConsecratedGroundEffect") / 100
		enemyDB:NewMod("DamageTaken", "INC", enemyDB:Sum("INC", nil, "DamageTakenConsecratedGround") * effect, "Consecrated Ground")
	end


	-- Defence/offence calculations
	calcs.defence(env, env.player)
	calcs.offence(env, env.player, env.player.mainSkill)
	
	
	
	if env.minion then
		calcs.defence(env, env.minion)
		calcs.offence(env, env.minion, env.minion.mainSkill)
		--重新计算抗性
		doActorAttribsPoolsConditions(env, env.minion)
		
	end

	local uuid = cacheSkillUUID(env.player.mainSkill)
	if not env.dontCache then
		cacheData(uuid, env)
	end
	
	
end
