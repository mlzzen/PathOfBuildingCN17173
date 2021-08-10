-- Path of Building
--
-- Module: Stat Describer
-- Manages stat description files, and provides stat descriptions
--


local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local s_format = string.format

local scopes = { }

local hideText ={
"trap_override_pvp_scaling_time_ms",
"base_deal_no_damage",
"display_",
"skill_cannot_",
"is_area_damage",
"base_skill_show_average_damage_instead_of_dps",
"consolw_skill_dont_chase",
"skill_can_add_multiple_charges_per_action",
"skill_override_pvp_scaling_time_ms",
"base_skill_is_mined",
"base_skill_is_",
"projectile_speed_variation_",
"skill_visual_scale_",
"spell_maximum_base_",
"attack_maximum_added",
"base_is_",
"secondary_maximum_base_",
"base_totem_range",
"modifiers_to_totem_duration_also_affect_soul_prevention_duration",
"ancestor_totem_parent_activiation_range",
"cannot_cancel_skill_before_contact_point",
"totem_ignores_vaal_skill_cost",
"shock_art_variation",
"ignite_art_variation",
"visual_hit_effect",
"arc_chain_distance",
		"arc_enhanced_behaviour",
		"disable_visual_hit_effect",
		"skill_can_",
		"override_turn_duration_ms",
		"projectile_remove_default_spread",
		"additional_projectiles_fired_with_distance_offset",
		"projectile_spread_radius",
}
local function getScope(scopeName)
	if scopeName == nil then 
		return nil
	end 
	if not scopes[scopeName] then
		local scope = LoadModule("Data/StatDescriptions/"..scopeName)
		scope.name = scopeName
		if scope.parent then
			local parentScope = getScope(scope.parent)
			scope.scopeList = copyTable(parentScope.scopeList, true)
		else
			scope.scopeList = { }
		end
		t_insert(scope.scopeList, 1, scope)
		scopes[scopeName] = scope
		return scope
	else
		return scopes[scopeName]
	end
end

local function matchLimit(lang, val) 
	for _, desc in ipairs(lang) do
		local match = true
		for i, limit in ipairs(desc.limit) do
			if limit[1] == "!" then
				if val[i].min == limit[2] then
					match = false
					break
				end
			elseif (limit[2] ~= "#" and val[i].min > limit[2]) or (limit[1] ~= "#" and val[i].min < limit[1]) then
				match = false
				break
			end
		end
		if match then
			return desc
		end
	end
end

local function applySpecial(val, spec)
	if spec.k == "negate" then
		val[spec.v].max, val[spec.v].min = -val[spec.v].min, -val[spec.v].max
	elseif spec.k == "divide_by_two_0dp" then
		val[spec.v].min = val[spec.v].min / 2
		val[spec.v].max = val[spec.v].max / 2
	elseif spec.k == "divide_by_ten_0dp" then
		val[spec.v].min = val[spec.v].min / 10
		val[spec.v].max = val[spec.v].max / 10
	elseif spec.k == "divide_by_fifteen_0dp" then
		val[spec.v].min = val[spec.v].min / 15
		val[spec.v].max = val[spec.v].max / 15
	elseif spec.k == "divide_by_twelve" then
		val[spec.v].min = round(val[spec.v].min / 12, 1)
		val[spec.v].max = round(val[spec.v].max / 12, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "divide_by_one_hundred" then
		val[spec.v].min = round(val[spec.v].min / 100, 1)
		val[spec.v].max = round(val[spec.v].max / 100, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "divide_by_one_hundred_2dp" then
		val[spec.v].min = round(val[spec.v].min / 100, 2)
		val[spec.v].max = round(val[spec.v].max / 100, 2)
		val[spec.v].fmt = "g"
	elseif spec.k == "divide_by_one_hundred_and_negate" then
		val[spec.v].min = -round(val[spec.v].min / 100, 1)
		val[spec.v].max = -round(val[spec.v].max / 100, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "divide_by_twenty_then_double_0dp" then -- O_O
		val[spec.v].min = round(val[spec.v].min / 20) * 2
		val[spec.v].max = round(val[spec.v].max / 20) * 2
	elseif spec.k == "per_minute_to_per_second" then
		val[spec.v].min = round(val[spec.v].min / 60, 1)
		val[spec.v].max = round(val[spec.v].max / 60, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "per_minute_to_per_second_0dp" then
		val[spec.v].min = val[spec.v].min / 60
		val[spec.v].max = val[spec.v].max / 60
	elseif spec.k == "per_minute_to_per_second_1dp" then
		val[spec.v].min = round(val[spec.v].min / 60, 1)
		val[spec.v].max = round(val[spec.v].max / 60, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "per_minute_to_per_second_2dp" then
		val[spec.v].min = round(val[spec.v].min / 60, 2)
		val[spec.v].max = round(val[spec.v].max / 60, 2)
		val[spec.v].fmt = "g"
	elseif spec.k == "per_minute_to_per_second_2dp_if_required" then
		val[spec.v].min = round(val[spec.v].min / 60, 2)
		val[spec.v].max = round(val[spec.v].max / 60, 2)
		val[spec.v].fmt = "g"
	elseif spec.k == "milliseconds_to_seconds" then
		val[spec.v].min = val[spec.v].min / 1000
		val[spec.v].max = val[spec.v].max / 1000
		val[spec.v].fmt = "g"
	elseif spec.k == "milliseconds_to_seconds_0dp" then
		val[spec.v].min = val[spec.v].min / 1000
		val[spec.v].max = val[spec.v].max / 1000
	elseif spec.k == "milliseconds_to_seconds_1dp" then
		val[spec.v].min = round(val[spec.v].min / 1000, 1)
		val[spec.v].max = round(val[spec.v].max / 1000, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "milliseconds_to_seconds_2dp" then
		val[spec.v].min = round(val[spec.v].min / 1000, 2)
		val[spec.v].max = round(val[spec.v].max / 1000, 2)
		val[spec.v].fmt = "g"					
	elseif spec.k == "milliseconds_to_seconds_2dp_if_required" then
		val[spec.v].min = round(val[spec.v].min / 1000, 2)
		val[spec.v].max = round(val[spec.v].max / 1000, 2)
		val[spec.v].fmt = "g"					
	elseif spec.k == "deciseconds_to_seconds" then
		val[spec.v].min = val[spec.v].min / 10
		val[spec.v].max = val[spec.v].max / 10
		val[spec.v].fmt = ".2f"
	elseif spec.k == "30%_of_value" then
		val[spec.v].min = val[spec.v].min * 0.3
		val[spec.v].max = val[spec.v].max * 0.3
	elseif spec.k == "60%_of_value" then
		val[spec.v].min = val[spec.v].min * 0.6
		val[spec.v].max = val[spec.v].max * 0.6
	elseif spec.k == "multiplicative_damage_modifier" then
		val[spec.v].min = 100 + val[spec.v].min
		val[spec.v].max = 100 + val[spec.v].max
	elseif spec.k == "multiplicative_permyriad_damage_modifier" then
		val[spec.v].min = 100 + round(val[spec.v].min / 100, 1)
		val[spec.v].max = 100 + round(val[spec.v].max / 100, 1)
		val[spec.v].fmt = "g"
	elseif spec.k == "multiply_by_four" then
		val[spec.v].min = val[spec.v].min * 4
		val[spec.v].max = val[spec.v].max * 4
	elseif spec.k == "times_twenty" then
		val[spec.v].min = val[spec.v].min * 20
		val[spec.v].max = val[spec.v].max * 20
	elseif spec.k == "reminderstring" or spec.k == "canonical_line" or spec.k == "_stat" then
	elseif spec.k then
		ConPrintf("Unknown description function: %s", spec.k)
	end
end
function ishideText(lineInfo)

	for index,text in pairs(hideText) do
		
		if  string.starts(lineInfo,text) then 
			return true
		end
	end 	
	return false
   
end


return function(stats, scopeName)
	local rootScope = getScope(scopeName)
		if rootScope then  
		-- Figure out which descriptions we need, and identify them by the first stat that they describe
		local describeStats = { }
		for s, v in pairs(stats) do
			if (type(v) == "number" and v ~= 0) or (type(v) == "table" and (v.min ~= 0 or v.max ~= 0)) then	
				for depth, scope in ipairs(rootScope.scopeList) do
					local isgemquality = false 
					
					local strline = s
					if  string.starts(strline ,"[GEM_Q]")  then 			
						isgemquality = true
						strline = string.sub(strline,8);
						
					end
					if scope[strline] then
						local descriptor = scope[scope[strline]]
						if descriptor and  descriptor.lang then							
							if isgemquality then  
								
								
								local scopeval =scope[scope[strline]]								
								scopeval.isgemquality = true								
								describeStats[descriptor.stats[1]] = { depth = depth, order = scope[strline], description = scopeval ,isgemquality = isgemquality}
							else 
								describeStats[descriptor.stats[1]] = { depth = depth, order = scope[strline], description = scope[scope[strline]] ,isgemquality = isgemquality}
							end 
							
							
						else 
							
							describeStats[strline] = { depth = -9999, order = 9999, description = strline ,isgemquality = isgemquality}
						end
						break
					else 						
						describeStats[strline] = { depth = -9999, order = 9999, description = strline ,isgemquality = isgemquality}
						
					end
				end
			end
		end

		-- Sort them by depth/order
		local descOrdered = { }
		for s, descriptor in pairs(describeStats) do
			t_insert(descOrdered, descriptor)
		end
		table.sort(descOrdered, function(a, b) if a.depth ~= b.depth then return a.depth > b.depth else return a.order < b.order end end)

		-- Describe the stats
		local out = { }
		for _, descriptor in ipairs(descOrdered) do
			local val = { }
			if descriptor.description.stats then 
				for i, s in ipairs(descriptor.description.stats) do
				 
				if stats[s] and stats["[GEM_Q]"..s] then
					 
					if descriptor.description.isgemquality then 
						
						if type(stats["[GEM_Q]"..s]) == "number" then
							val[i] = { min = stats["[GEM_Q]"..s]+stats[s], max = stats["[GEM_Q]"..s]+stats[s] }
						else
							val[i] = stats["[GEM_Q]"..s]+stats[s]
						end
					else 
						if type(stats[s]) == "number" then
							val[i] = { min = stats[s], max = stats[s] }
						else
							val[i] = stats[s]
						end
					end
					
				elseif stats[s] then
				
					if type(stats[s]) == "number" then
						val[i] = { min = stats[s], max = stats[s] }
					else
						val[i] = stats[s]
					end
					 
					
				elseif  stats["[GEM_Q]"..s] then
					
					if type(stats["[GEM_Q]"..s]) == "number" then
						val[i] = { min = stats["[GEM_Q]"..s], max = stats["[GEM_Q]"..s] }
					else
						val[i] = stats["[GEM_Q]"..s]
					end
					
				else
					val[i] = { min = 0, max = 0 }
				end
				if not val[i] then 
					val[i] = { min = 0, max = 0 }
				end 
				val[i].fmt = "d"
				end
				
				
				local desc = matchLimit(descriptor.description.lang["Simplified Chinese"], val)
				
				
				if desc then
					for _, spec in ipairs(desc) do
						applySpecial(val, spec)
					end
					local statDesc = desc.text:gsub("{(%d)}", function(n) 
						local v = val[tonumber(n)+1]
						if v.min == v.max then
							return s_format("%"..v.fmt, v.min)
						else
							return s_format("(%"..v.fmt.."-%"..v.fmt..")", v.min, v.max)
						end
					end):gsub("{}", function() 
						local v = val[1]
						if v.min == v.max then
							return s_format("%"..v.fmt, v.min)
						else
							return s_format("(%"..v.fmt.."-%"..v.fmt..")", v.min, v.max)
						end
					end):gsub("{:%+?d}", function() 
						local v = val[1]
						if v.min == v.max then
							return s_format("%"..v.fmt, v.min)
						else
							return s_format("(%"..v.fmt.."-%"..v.fmt..")", v.min, v.max)
						end
					end):gsub("{(%d):(%+?)d}", function(n, fmt)
						local v = val[tonumber(n)+1]
						if v.min == v.max then
							return s_format("%"..fmt..v.fmt, v.min)
						elseif fmt == "+" then
							if v.max < 0 then
								return s_format("-(%d-%d)", -v.min, -v.max)
							else
								return s_format("+(%d-%d)", v.min, v.max)
							end
						else
							return s_format("(%"..fmt..v.fmt.."-%"..fmt..v.fmt..")", v.min, v.max)
						end
					end):gsub("%%%%","%%")
					for line in (statDesc.."\\n"):gmatch("([^\\]+)\\n") do
						if descriptor.isgemquality then 
							
							t_insert(out, colorCodes.NORMAL..line)
						else 
							t_insert(out,colorCodes.MAGIC..line)
						end 
						
					end
				else 
					--print("不显示")
					 --不显示
				end
			else 
			
				if not ishideText(descriptor.description)				
				then
					if descriptor.isgemquality then 			
						
						t_insert(out, colorCodes.NORMAL..descriptor.description)
					else 
						t_insert(out, colorCodes.MAGIC..descriptor.description)
					end 
				end 
				
				
			end 
			
			
		end
		return out
	end 
	
	return {}
	
end
