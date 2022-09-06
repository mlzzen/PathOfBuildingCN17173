uniqueDirectory = "D:/Projects/PathOfBuilding/src/Data/Uniques/"
uniqueCollections = { 
    "amulet", "axe", "belt", "body", "boots", "bow", "claw", "dagger",
    "flask", "gloves", "helmet", "jewel", "mace", "quiver", "ring",
    "shield", "staff", "sword", "wand"
}
uniqueModTranslations = {}

local l_require = require
function require(name)
	-- Hack to stop it looking for lcurl, which we don't really need
	if name == "lcurl.safe" then
		return
	end
	return l_require(name)
end

-- 访问POEDB，获得词条中英文对照
local function Curl(url)
	local curl = require("lcurl.safe")
	for i = 1, 5 do
		if i > 1 then
			ConPrintf("Retrying... (%d of 5)", i)
		end
		local text = ""
		local easy = curl.easy()
		easy:setopt_url(url)
		easy:setopt_httpheader({ "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:33.0) Gecko/20100101 Firefox/33.0"  })
		
		easy:setopt(curl.OPT_ACCEPT_ENCODING, "")
		easy:setopt_writefunction(function(data)
			text = text..data 
			return true
		end)
		local _, error = easy:perform()
		easy:close()
		if not error then
			return text
		end
		ConPrintf("Curl failed (%s)", error:msg())
	end
end

local function ParseUniqueFromPoedbHtml(content)
    if not content then
        return {}
    end
    modLines = {}
    local mat = content:match("<meta property=\"og:description\" content=\"(.-)\" />")
    for line in string.gmatch(mat .. "\r\n", "([^\r\n]*)\r?\n") do
        line = line:gsub("^%s+",""):gsub("%s+$","")
        if #line > 0 then
            table.insert(modLines, line)
        end
    end
    return modLines
end

local function Run()
    -- 遍历所有传奇
    local uniques = {}
    for _, uniqueCollection in ipairs(uniqueCollections) do
        local localUniques = dofile(uniqueDirectory .. uniqueCollection .. ".lua")
        for _, unique in ipairs(localUniques) do
            for line in string.gmatch(unique .. "\r\n", "([^\r\n]*)\r?\n") do
                line = line:gsub("^%s+",""):gsub("%s+$","")
                if #line > 0 then
                    table.insert(uniques, line)
                end
                break
            end
        end
    end
    local outStr = ""
    for _, unique in ipairs(uniques) do
        outStr = outStr .. unique .. "\n"
    end
    local outFile = io.open("uniques.txt", "w")
    outFile:write(outStr)
    outFile:close()
    -- 访问POEDB，获得词条中英文对照
    -- for _, uniqueName in ipairs(uniques) do
    --     local urlName = string.gsub(uniqueName, "'", ""):gsub(" ", "_")
    --     local urlCN = "https://poedb.tw/cn/" .. urlName
    --     local urlEN = "https://poedb.tw/us/" .. urlName
    --     local contentCN = Curl(urlCN)
    --     local contentEN = Curl(urlEN)
    --     local modLinesCN = ParseUniqueFromPoedbHtml(contentCN)
    --     local modLinesEN = ParseUniqueFromPoedbHtml(contentEN)
    --     for i = 1, #modLinesCN do
    --         local modCN = modLinesCN[i]
    --         local modEN = modLinesEN[i]
    --         local trans = { cn = modCN, en = modEN}
    --         table.insert(uniqueModTranslations, trans)
    --     end
    -- end
end

Run()