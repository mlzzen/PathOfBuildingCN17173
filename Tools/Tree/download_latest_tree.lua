
local treeVersion = "3_16"
-- Retrieve the file at the given URL
local function getFile(URL)
	local file1 = io.input("./Tools/Tree/fullscreen-passive-skill-tree")
	local data = io.read("*a");
	return data
end

local function codePointToUTF8(codePoint)
	if codePoint >= 0xD800 and codePoint <= 0xDFFF then
		return "?"
	elseif codePoint <= 0x7F then
		return s_char(codePoint)
	elseif codePoint <= 0x07FF then
		return s_char(0xC0 + b_rshift(codePoint, 6), 0x80 + b_and(codePoint, 0x3F))
	elseif codePoint <= 0xFFFF then
		return s_char(0xE0 + b_rshift(codePoint, 12), 0x80 + b_and(b_rshift(codePoint, 6), 0x3F), 0x80 + b_and(codePoint, 0x3F))
	elseif codePoint <= 0x10FFFF then
		return s_char(0xF0 + b_rshift(codePoint, 18), 0x80 + b_and(b_rshift(codePoint, 12), 0x3F), 0x80 + b_and(b_rshift(codePoint, 6), 0x3F), 0x80 + b_and(codePoint, 0x3F))
	else
		return "?"
	end
end

-- Quick hack to convert JSON to valid lua
local function jsonToLua(json)
	return json:gsub("%[","{"):gsub("%]","}"):gsub('"(%d[%d%.]*)":','[%1]='):gsub('"([^"]+)":','["%1"]='):gsub("\\/","/"):gsub("{(%w+)}","{[0]=%1}")
		:gsub("\\u(%x%x%x%x)",function(hex) return codePointToUTF8(tonumber(hex,16)) end)
end

local page = getFile("https://poe.game.qq.com/passive-skill-tree/")
local treeData = page:match("var passiveSkillTreeData = (%b{})")
local treeText
local treeFile
if treeData then
	treeText = "local tree=" .. jsonToLua(page:match("var passiveSkillTreeData = (%b{})"))
	treeText = treeText .. "return tree"
else
	treeText = "return " .. jsonToLua(page)
end

treeFile = io.open("./Tools/Tree/"..treeVersion..".lua", "w")
treeFile:write(treeText)
treeFile:close()
