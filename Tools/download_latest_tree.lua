local treeVersion = "3_16"
-- Retrieve the file at the given URL
local function getFile(URL)
	local file1 = io.input("./Tools/fullscreen-passive-skill-tree")
	local data = io.read("*a");
	return data
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

treeFile = io.open("./Tools/"..treeVersion..".lua", "w")
treeFile:write(treeText)
treeFile:close()
