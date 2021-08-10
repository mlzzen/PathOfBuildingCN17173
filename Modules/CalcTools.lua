-- Path of Building
--
-- Module: Calc Tools
-- Various functions used by the calculation modules
--

local pairs = pairs
local t_insert = table.insert
local t_remove = table.remove
local m_floor = math.floor
local m_min = math.min
local m_max = math.max

calcLib = { }

-- Calculate and combine INC/MORE modifiers for the given modifier names
function calcLib.mod(modStore, cfg, ...)
	return (1 + (modStore:Sum("INC", cfg, ...)) / 100) * modStore:More(cfg, ...)
end

---Calculates additive and multiplicative modifiers for specified modifier names
---@param modStore table
---@param cfg table
---@param ... string @Mod name(s)
---@return number, number @increased, more
function calcLib.mods(modStore, cfg, ...)
	local inc = 1 + modStore:Sum("INC", cfg, ...) / 100
	local more = modStore:More(cfg, ...)
	return inc, more
end

-- Calculate value
function calcLib.val(modStore, name, cfg)
	local baseVal = modStore:Sum("BASE", cfg, name)
	if baseVal ~= 0 then
		return baseVal * calcLib.mod(modStore, cfg, name)
	else
		return 0
	end
end


-- Validate the level of the given gem
function calcLib.validateGemLevel(gemInstance)

	local grantedEffect = gemInstance.grantedEffect or gemInstance.gemData.grantedEffect
	if not grantedEffect.levels[gemInstance.level] then
		if gemInstance.gemData and gemInstance.gemData.defaultLevel then
			gemInstance.level = gemInstance.gemData.defaultLevel
		else
			-- Try limiting to the level range of the skill
gemInstance.level = m_max(1, gemInstance.level or 1)
			if #grantedEffect.levels > 0 then
				gemInstance.level = m_min(#grantedEffect.levels, gemInstance.level)
			end
			if not grantedEffect.levels[gemInstance.level] then
				-- That failed, so just grab any level
				gemInstance.level = next(grantedEffect.levels)
			end
		end
	end	
end
 

-- Evaluate a skill type postfix expression
function calcLib.doesTypeExpressionMatch(checkTypes, skillTypes, minionTypes)
if checkTypes ==nil then return false end --lucifer 不知道是引爆地雷还是时空之门的问题，遙控地雷也是
	local stack = { }
	for _, skillType in pairs(checkTypes) do
		if skillType == SkillType.OR then
			local other = t_remove(stack)
			stack[#stack] = stack[#stack] or other
		elseif skillType == SkillType.AND then
			local other = t_remove(stack)
			stack[#stack] = stack[#stack] and other
		elseif skillType == SkillType.NOT then
			stack[#stack] = not stack[#stack]
		else
			t_insert(stack, skillTypes[skillType] or (minionTypes and minionTypes[skillType]) or false)
		end
	end
	for _, val in ipairs(stack) do
		if val then
			return true
		end
	end
	return false
end

-- Check if given support skill can support the given active skill
function calcLib.canGrantedEffectSupportActiveSkill(grantedEffect, activeSkill)
	 
	if grantedEffect.unsupported or activeSkill.activeEffect.grantedEffect.cannotBeSupported then
		return false
	end
	if grantedEffect.supportGemsOnly and not activeSkill.activeEffect.gemData then
		return false
	end
	if activeSkill.summonSkill then
		return calcLib.canGrantedEffectSupportActiveSkill(grantedEffect, activeSkill.summonSkill)
	end
	if grantedEffect.excludeSkillTypes and grantedEffect.excludeSkillTypes[1] and calcLib.doesTypeExpressionMatch(grantedEffect.excludeSkillTypes, activeSkill.skillTypes) then
		return false
	end
	if grantedEffect.requireSkillTypes == nil then 
		return false
	end 
	return not grantedEffect.requireSkillTypes[1] or calcLib.doesTypeExpressionMatch(grantedEffect.requireSkillTypes, activeSkill.skillTypes, not grantedEffect.ignoreMinionTypes and activeSkill.minionSkillTypes)
end

-- Check if given gem is of the given type ("all", "strength", "melee", etc)
function calcLib.gemIsType(gem, type)
	return (type == "all" or 
			(type == "elemental" and (gem.tags.fire or gem.tags.cold or gem.tags.lightning)) 
			or (type == "aoe" and gem.tags.area) 
			or (type == "physical_spell" and (gem.tags.physical and gem.tags.spell)) 
			or (type == "chaos_spell" and (gem.tags.chaos and gem.tags.spell)) 		
			
			or (type == "warcry" and (gem.tags.warcry)) 		
			
			or (type == "trap or mine" and (gem.tags.trap or gem.tags.mine)) 
			or (type == gem.name:lower()) 
			or gem.tags[type])
end

-- From PyPoE's formula.py
function calcLib.getGemStatRequirement(level, isSupport, multi)
	if multi == 0 then
		return 0
	end
	local a, b
	if isSupport then
		b = 6 * multi / 100
		if multi == 100 then
			a = 1.495
		elseif multi == 60 then
			a = 0.945
		elseif multi == 40 then
			a = 0.6575
		else
			return 0
		end
	else
		b = 8 * multi / 100
		if multi == 100 then
			a = 2.1
			b = 7.75
		elseif multi == 75 then
			a = 1.619
		elseif multi == 60 then
			a = 1.325
		elseif multi == 40 then
			a = 0.924
		else
			return 0
		end
	end
	local req = round(level * a + b)
	return req < 14 and 0 or req
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
						if type(pos)=="table" then 
						 print(indent.."[<table>] => "..tostring(val))
						 else 
						  print(indent.."["..pos.."] => "..tostring(val))
						end 
                       
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
       sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
-- Build table of stats for the given skill instance
function calcLib.buildSkillInstanceStats(skillInstance, grantedEffect, spGemQuality)

	
	local stats = { }
	if skillInstance.quality > 0 then
		local qualityId = skillInstance.qualityId or "Default"
		local qualityStats = grantedEffect.qualityStats[qualityId]
		if not qualityStats then
			qualityStats = grantedEffect.qualityStats
		end
		for _, stat in ipairs(qualityStats) do
			if spGemQuality then 
				stats["[GEM_Q]"..stat[1]] = (stats[stat[1]] or 0) + math.modf(stat[2] * skillInstance.quality)
			else
				stats[stat[1]] = (stats[stat[1]] or 0) + math.modf(stat[2] * skillInstance.quality)
			end 
		end
	end
	local level = grantedEffect.levels[skillInstance.level]
	local availableEffectiveness
	local actorLevel = skillInstance.actorLevel or level.levelRequirement
	
	for index, stat in ipairs(grantedEffect.stats) do
				
		local statValue
	--	print_r(skillInstance)
		if level.statInterpolation and level.statInterpolation[index] == 3 then
			-- Effectiveness interpolation
			if not availableEffectiveness then
				availableEffectiveness = 
					(3.885209 + 0.360246 * (actorLevel - 1)) * (grantedEffect.baseEffectiveness or 1)
					* (1 + (grantedEffect.incrementalEffectiveness or 0)) ^ (actorLevel - 1)
			end
			statValue = round(availableEffectiveness * level[index])
		elseif level.statInterpolation and level.statInterpolation[index] == 2 then
			-- Linear interpolation; I'm actually just guessing how this works
			local nextLevel = m_min(skillInstance.level + 1, #grantedEffect.levels)
			local nextReq = grantedEffect.levels[nextLevel].levelRequirement
			local prevReq = grantedEffect.levels[nextLevel - 1].levelRequirement
			local nextStat = grantedEffect.levels[nextLevel][index]
			local prevStat = grantedEffect.levels[nextLevel - 1][index]
			statValue = round(prevStat + (nextStat - prevStat) * (actorLevel - prevReq) / (nextReq - prevReq))
		else
			-- Static value
			--print('【】》》'..stat)
			
			defaultValue=1
			if grantedEffect.statMap and grantedEffect.statMap[stat] and grantedEffect.statMap[stat][1] 
 and grantedEffect.statMap[stat][1].value~=nil   and 
 type(grantedEffect.statMap[stat][1].value) == "table" and
 grantedEffect.statMap[stat][1].value.mod~=nil and  grantedEffect.statMap[stat][1].value.mod.value
			then 
				defaultValue=grantedEffect.statMap[stat][1].value.mod.value				
			end 
			if defaultValue==1 and grantedEffect.statMap and grantedEffect.statMap[stat] and grantedEffect.statMap[stat][1] 
and grantedEffect.statMap[stat][1].value~=nil  
and type(grantedEffect.statMap[stat][1].value) ~= "table" and type(grantedEffect.statMap[stat][1].value) ~= "boolean" 
			then 
				 defaultValue=grantedEffect.statMap[stat][1].value
				 --print("Found>:"..grantedEffect.statMap[stat][1].value)		
			end 
			
			
			statValue = level[index] or defaultValue
		end
		stats[stat] = (stats[stat] or 0) + statValue
	end
	return stats
end 


-- 慎用 会根据角色/召唤生物等级来调整
function calcLib.buildSkillInstanceStatsOnly(curLevel,actorLevel,grantedEffect)

	 
	local stats = { }
	 local level = grantedEffect.levels[curLevel]
	 
	local availableEffectiveness
	 
	if level then 
		for index, stat in ipairs(grantedEffect.stats) do
		local statValue 
		if level.statInterpolation[index] == 3 then
			-- Effectiveness interpolation
			if not availableEffectiveness then
				availableEffectiveness = 
					(3.885209 + 0.360246 * (actorLevel - 1)) * (grantedEffect.baseEffectiveness or 1)
					* (1 + (grantedEffect.incrementalEffectiveness or 0)) ^ (actorLevel - 1)
			end
			statValue = round(availableEffectiveness * level[index])
		elseif level.statInterpolation[index] == 2 then
			-- Linear interpolation; I'm actually just guessing how this works
			local nextLevel = m_min(curLevel + 1, #grantedEffect.levels)
			local nextReq = grantedEffect.levels[nextLevel].levelRequirement
			local prevReq = grantedEffect.levels[nextLevel - 1].levelRequirement
			local nextStat = grantedEffect.levels[nextLevel][index]
			local prevStat = grantedEffect.levels[nextLevel - 1][index]
			statValue = round(prevStat + (nextStat - prevStat) * (actorLevel - prevReq) / (nextReq - prevReq))
		else
			-- Static value
			--print('【】》》'..stat)
			
			defaultValue=1
			if grantedEffect.statMap and grantedEffect.statMap[stat] and grantedEffect.statMap[stat][1] 
 and grantedEffect.statMap[stat][1].value~=nil   and 
 type(grantedEffect.statMap[stat][1].value) == "table" and
 grantedEffect.statMap[stat][1].value.mod~=nil and  grantedEffect.statMap[stat][1].value.mod.value
			then 
				defaultValue=grantedEffect.statMap[stat][1].value.mod.value				
			end 
			if defaultValue==1 and grantedEffect.statMap and grantedEffect.statMap[stat] and grantedEffect.statMap[stat][1] 
and grantedEffect.statMap[stat][1].value~=nil  
and type(grantedEffect.statMap[stat][1].value) ~= "table" and type(grantedEffect.statMap[stat][1].value) ~= "boolean" 
			then 
				 defaultValue=grantedEffect.statMap[stat][1].value
				 --print("Found>:"..grantedEffect.statMap[stat][1].value)		
			end 
			
			
			statValue = level[index] or defaultValue
		end
		stats[stat] = (stats[stat] or 0) + statValue
	end
	
	end 
	
	return stats
end 


--[[
function minionModList2CN(modList)
local cnList={}

for k, v in pairs(modList) do
		print_r(v)
	if v and v.name then 
		local pre=""
		local last=""
		local typestr=""
		local from=""
		local value=""
		local valindex=0
		local valendStr=""
		local valStartStr=""
		
		if v.name == 'Speed' then 
			pre='攻击和施法速度'
			last=''
			valindex=3
			valendStr=""
			if v.flags==ModFlag.Cast then 
				pre='施法速度'
				last=''
			elseif   v.flags==ModFlag.Attack then
				pre='攻击速度'
				last=''
			end 
			valendStr="%"
		elseif v.name == 'PhysicalMin' then 
			valendStr=""
			valindex=0
			valStartStr="附加 "
			if v.flags==ModFlag.Cast then 
				pre='最小法术物理伤害'
				last=''
			elseif   v.flags==ModFlag.Attack then
				pre='最小攻击物理伤害'
				last=''
			end 
		elseif v.name == 'PhysicalMax' then 
			valendStr=""
			valindex=0
			valStartStr="附加 "
			if v.flags==ModFlag.Cast then 
				pre='最大法术物理伤害'
				last=''
			elseif   v.flags==ModFlag.Attack then
				pre='最大攻击物理伤害'
				last=''
			end 
		elseif v.name == 'PhysicalDamageConvertToCold' then 
			pre='物理伤害转化为冰霜'
			valindex=0
			valendStr="%"
		elseif v.name == 'PhysicalDamageConvertToFire' then 
			pre='物理伤害转化为火焰'
			valindex=0
			valendStr="%"
		elseif v.name == 'PhysicalDamageConvertToLightning' then 
			pre='物理伤害转化为闪电'
			valindex=0
			valendStr="%"
		elseif v.name == 'PhysicalDamageConvertToChaos' then 
			pre='物理伤害转化为混沌'
			valindex=0	
			valendStr="%"	
		elseif v.name == 'BlockChance' then 
			pre='攻击格挡几率'
			valindex=0	
			valendStr="%"	
			
		elseif v.name == 'PhysicalDamageGainAsCold' then 
			last='获得额外冰霜伤害， 其数值等同于物理伤害的'
			valindex=3	
			valendStr="%"
		elseif v.name == 'PhysicalDamageGainAsFire' then 
			last='获得额外火焰伤害， 其数值等同于物理伤害的'
			valindex=3
			valendStr="%"
		elseif v.name == 'PhysicalDamageGainAsLightning' then 
			last='获得额外闪电伤害， 其数值等同于物理伤害的'
			valindex=3
			valendStr="%"
		elseif v.name == 'PhysicalDamageGainAsChaos' then 
			last='获得额外混沌伤害， 其数值等同于物理伤害的'
			valindex=3
			valendStr="%"
		elseif v.name == 'ProjectileCount' then 
			pre='投射物数量 +'
			valindex=3
			valendStr=""
		elseif v.name == 'Armour' then 
			pre='护甲'
			valindex=3
			valendStr="%"
		elseif v.name == 'EnergyShield' then 
			pre='能量护盾'
			valindex=0
			valendStr=""	
			valStartStr="+"
		elseif	v.name =="Condition:FullLife" then
			pre='满血'
			valindex=0
			valendStr=""
		else
			pre=v.name
			valindex=3
			valendStr="%"
		end 
		
		
		if v.type =='INC' then 
			if v.value <=0 then 
				typestr="降低"
				value=-v.value
			else 
				typestr="提高"
				value=v.value
			end 
		elseif v.type=='MORE' then 
			if v.value <=0 then 
				typestr="额外降低"
				value=-v.value
				pre='总'..pre
			else 
				typestr="额外提高"
				value=v.value
				pre='总'..pre
			end 
		else 
			value=v.value .. ""			
		end 
		if v.keywordFlags == KeywordFlag.Curse then 
			from="诅咒的"
		end 
		if valindex==0 then
			t_insert(cnList,valStartStr..value..valendStr.." "..from..pre..last..typestr)
		elseif valindex==3 then 
			t_insert(cnList,from..pre..last..typestr.." "..valStartStr..value..valendStr)
		end 
		
	end 
end
print_r(cnList)
return cnList
end
]]--
