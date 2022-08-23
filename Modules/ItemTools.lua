-- Path of Building
--
-- Module: Item Tools
-- Various functions for dealing with items.
--
--local launch = ...

local t_insert = table.insert
local t_remove = table.remove
local m_min = math.min
local m_max = math.max
local m_floor = math.floor

itemLib = { }

-- Info table for all types of item influence
itemLib.influenceInfo = {
	{ key="shaper", display="塑界之器", color=colorCodes.SHAPER },
	{ key="elder", display="裂界之器", color=colorCodes.ELDER },
	{ key="warlord", display="督军物品", color=colorCodes.WARLORD },
	{ key="hunter", display="狩猎者物品", color=colorCodes.HUNTER },
	{ key="crusader", display="圣战者物品", color=colorCodes.CRUSADER },
	{ key="redeemer", display="救赎者物品", color=colorCodes.REDEEMER },
	
	{ key="synthesised", display="忆境物品", color=colorCodes.REDEEMER },
	{ key="cleansing", display="焚界者物品", color=colorCodes.CLEANSING },
	{ key="tangle", display="灭界者物品", color=colorCodes.TANGLE },
	 
	
}

-- Apply a value scalar to any numbers present
function itemLib.applyValueScalar(line, valueScalar)
	if valueScalar and type(valueScalar) == "number" and valueScalar ~= 1 then
		if line:match("(%d+%.%d*)") then
			return line:gsub("(%d+%.%d*)", function(num)
				local numVal = (m_floor(tonumber(num) * valueScalar * 100 + 0.001) / 100)
				return tostring(numVal)
			end)
		else
			return line:gsub("(%d+)([^%.])", function(num, suffix)
				local numVal = m_floor(num * valueScalar + 0.001)
				return tostring(numVal)..suffix
			end)
		end
	end
	return line
end
-- Get the min and max of a mod line
function itemLib.getLineRangeMinMax(line)
	local rangeMin, rangeMax
	line:gsub("%((%d+)%-(%d+) to (%d+)%-(%d+)%)", "(%1-%2) to (%3-%4)")
:gsub("(%+?)%((%-?%d+) %- (%d+)%)", "%1(%2-%3)")
		:gsub("(%+?)%((%-?%d+)%-(%d+)%)", 
		function(plus, min, max)
			rangeMin = min
			rangeMax = max
			-- Don't need to return anything here
			return ""
		end)
		--Fixing range parsing to include the decimal case
		:gsub("%((%d+%.?%d*)%-(%d+%.?%d*)%)",
		function(min, max) 
			rangeMin = min
			rangeMax = max
			return "" 
		end)
	-- may be returning nil, nil due to not being a range
	-- will be strings if successful
	return rangeMin, rangeMax
end

-- Apply range value (0 to 1) to a modifier that has a range: (x to x) or (x-x to x-x)
function itemLib.applyRange(line, range, valueScalar)
line = line:gsub("%((%d+)%-(%d+) to (%d+)%-(%d+)%)", "(%1-%2) %- (%3-%4)")
:gsub("(%+?)%((%-?%d+) %- (%d+)%)", "%1(%2-%3)")
:gsub("(%+?)%((%-?%d+)%-(%d+)%)", 
function(plus, min, max)
			local numVal = m_floor(tonumber(min) + range * (tonumber(max) - tonumber(min)) + 0.5)
			if numVal < 0 then
				if plus == "+" then
					plus = ""
				end
			end
			return plus .. tostring(numVal)
		end)
		:gsub("%((%d+%.?%d*)%-(%d+%.?%d*)%)",
		function(min, max) 
			local numVal = m_floor((tonumber(min) + range * (tonumber(max) - tonumber(min))) * 10 + 0.5) / 10
			return tostring(numVal) 
		end)
:gsub("提高 %-(%d+%%)", function(num) return "降低 "..num end)
:gsub("%-(%d+%%) increased", function(num) return num.."%% reduced" end)
	return itemLib.applyValueScalar(line, valueScalar)

end

--- Clean item text by removing or replacing unsupported or redundant characters or sequences
---@param text string
---@return string
--lucifer  注意会出现基底消失的bug
function itemLib.sanitiseItemText(text)

 
	
	return text:gsub("^%s+",""):gsub("%s+$",""):gsub("\r\n","\n"):gsub("%b<>",""):gsub("^%s*(.-)%s*$", "%1")
	
	
	--:gsub("?,"-")
	--:gsub("?,"o")
	--:gsub("\195\182","o"):gsub("[\128-\255]","?"):gsub("\226\128\147","-"):gsub("\226\136\146","-")
end

function itemLib.formatModLine(modLine, dbMode)
	local line = (not dbMode and modLine.range and itemLib.applyRange(modLine.line, modLine.range, modLine.valueScalar)) or modLine.line
	if line:match("^%+?0%%? ") or (line:match(" %+?0%%? ") and not line:match("0 to [1-9]")) or line:match(" 0%-0 ") or line:match(" 0 to 0 ") then -- Hack to hide 0-value modifiers
		return
	end
	local colorCode
	if modLine.extra then
		colorCode = colorCodes.UNSUPPORTED
		if launch.devModeAlt then
			line = line .. "   ^1'" .. modLine.extra .. "'"
		end
	else
		colorCode = (modLine.crafted and colorCodes.CRAFTED) or (modLine.custom and colorCodes.CUSTOM) or (modLine.fractured and colorCodes.FRACTURED) or colorCodes.MAGIC
	end
	return colorCode..line
end
