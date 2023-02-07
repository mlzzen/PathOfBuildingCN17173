-- Path of Building
--
-- Module: Import Tab
-- Import/Export tab for the current build.
--
--local launch, main = ...

local ipairs = ipairs
local t_insert = table.insert
local b_rshift = bit.rshift
local band = bit.band
local realmList = {
	{ label = "PC", id = "PC", realmCode = "pc", profileURL = "https://poe.game.qq.com/account/view-profile/" },
	{ label = "Xbox(未开放)", id = "XBOX", realmCode = "xbox", profileURL = "https://poe.game.qq.com/account/xbox/view-profile/" },
	{ label = "PS4(未开放)", id = "SONY", realmCode = "sony", profileURL = "https://poe.game.qq.com/account/sony/view-profile/" },
}
local rarityMap = { [0] = "普通", "魔法", "稀有", "传奇", [9] = "遗产" }
local slotMap = { ["Weapon"] = "Weapon 1", ["Offhand"] = "Weapon 2", ["Weapon2"] = "Weapon 1 Swap", ["Offhand2"] = "Weapon 2 Swap", ["Helm"] = "Helmet", ["BodyArmour"] = "Body Armour", ["Gloves"] = "Gloves", ["Boots"] = "Boots", ["Amulet"] = "Amulet", ["Ring"] = "Ring 1", ["Ring2"] = "Ring 2", ["Belt"] = "Belt" }
local classesCn = {
	Duelist = "决斗者", Slayer = "处刑者", Gladiator = "卫士", Champion = "冠军",
	Marauder = "野蛮人", Juggernaut = "勇士", Berserker = "暴徒", Chieftain = "酋长",
	Ranger = "游侠", Deadeye = "锐眼", Raider = "侠客", Pathfinder = "追猎者",
	Shadow = "暗影刺客", Assassin = "刺客", Saboteur = "破坏者", Trickster = "欺诈师",
	Witch = "女巫", Necromancer = "召唤师", Occultist = "秘术家", Elementalist = "元素使",
	Templar = "圣堂武僧", Inquisitor = "判官", Hierophant = "圣宗", Guardian = "守护者",
	Scion = "贵族", Ascendant = "升华使徒"
}

local influenceInfo = itemLib.influenceInfo

local ImportTabClass = newClass("ImportTab", "ControlHost", "Control", function(self, build)
	self.ControlHost()
	self.Control()

	self.build = build

	self.charImportMode = "GETACCOUNTNAME"
	self.charImportStatus = "未导入"
self.controls.sectionCharImport = new("SectionControl", {"TOPLEFT",self,"TOPLEFT"}, 10, 18, 600, 250, "【导入国服角色】")
	
	self.controls.charImportStatusLabel = new("LabelControl", {"TOPLEFT",self.controls.sectionCharImport,"TOPLEFT"}, 6, 14, 200, 16, function()
return "^7角色导入状态: "..self.charImportStatus
	end)
	

	-- Stage: input account name
	self.controls.accountNameHeader = new("LabelControl", {"TOPLEFT",self.controls.sectionCharImport,"TOPLEFT"}, 6, 40, 200, 16, "^7请输入你的论坛名（登录官网论坛头像下的那个）:")
	self.controls.accountNameHeader.shown = function()
		return self.charImportMode == "GETACCOUNTNAME"
	end
	self.controls.accountRealm = new("DropDownControl", {"TOPLEFT",self.controls.accountNameHeader,"BOTTOMLEFT"}, 0, 4, 100, 20, realmList )
	self.controls.accountRealm:SelByValue( main.lastRealm or "PC", "id" )
	local lastName = main.lastAccountName or ""
	self.controls.accountName = new("EditControl", {"LEFT",self.controls.accountRealm,"RIGHT"}, 8, 0, 200, 20, lastName, nil, "%c")
	
 
	self.controls.accountName.pasteFilter = function(text)
		return text
		--return text:gsub("[\128-\255]",function(c)
		--	return codePointToUTF8(c:byte(1)):gsub(".",function(c)
		--		return string.format("%%%X", c:byte(1))
		--	end)
		--end)
	end

	-- accountHistory Control
	if not historyList then
		historyList = { }
		for accountName, account in pairs(main.gameAccounts) do
			t_insert(historyList, urlDecode(accountName))
			historyList[accountName] = true
		end
		table.sort(historyList)
	end -- don't load the list many times

	self.controls.accountNameGo = new("ButtonControl", {"LEFT",self.controls.accountName,"RIGHT"}, 8, 0, 60, 20, "开始", function()
		self.controls.sessionInput.buf = ""
		self:DownloadCharacterList()
	end)
	self.controls.accountNameGo.enabled = function()
		return self.controls.accountName.buf:match("%S")
	end

	self.controls.accountHistory = new("DropDownControl", {"LEFT",self.controls.accountNameGo,"RIGHT"}, 8, 0, 200, 20, historyList, function()
		self.controls.accountName.buf = urlDecode(self.controls.accountHistory.list[self.controls.accountHistory.selIndex])
	end)
	self.controls.accountHistory:SelByValue(urlDecode(main.lastAccountName))

	self.controls.accountNameUnicode = new("LabelControl", {"TOPLEFT",self.controls.accountRealm,"BOTTOMLEFT"}, 0, 16, 0, 14, "^7注意！你需要先去官网公开你的角色.")
	self.controls.accountNameURLEncoder = new("ButtonControl", {"TOPLEFT",self.controls.accountNameUnicode,"BOTTOMLEFT"}, 0, 4, 170, 18, "不能快速安全登录的都是假官网", function()
		OpenURL("https://poe.game.qq.com/login/tencent")
	end)

	-- Stage: input POESESSID
	self.controls.sessionHeader = new("LabelControl", {"TOPLEFT",self.controls.sectionCharImport,"TOPLEFT"}, 6, 40, 200, 14)
	self.controls.sessionHeader.label = function()
		local name = urlDecode(self.controls.accountName.buf)
		return [[
			^7无法获取账户“]]..name..[[”的角色列表，可能的原因有 :
			1. 账户名输入错误
			2、没有公开自己的角色
			3、国服网页接口需要登录
			如果这是你的账户，你可以考虑
			到官网的个人中心 --隐私设定 -取消勾选“隐藏角色标签”
			或者在下面输入你的 POESESSID。
			你可以在登录官网后浏览器的cookies中拿到。
		]]
	end
	self.controls.sessionHeader.shown = function()
		return self.charImportMode == "GETSESSIONID"
	end
	self.controls.sessionRetry = new("ButtonControl", {"TOPLEFT",self.controls.sessionHeader,"TOPLEFT"}, 0, 118, 60, 20, "重试", function()
		self.controls.sessionInput.buf = ""
		self:DownloadCharacterList()
	end)
self.controls.sessionCancel = new("ButtonControl", {"LEFT",self.controls.sessionRetry,"RIGHT"}, 8, 0, 60, 20, "取消", function()
		self.charImportMode = "GETACCOUNTNAME"
		self.charImportStatus = "未导入"
	end)
	self.controls.sessionInput = new("EditControl", {"TOPLEFT",self.controls.sessionRetry,"BOTTOMLEFT"}, 0, 8, 350, 20, "", "POESESSID", "%X", 32)
	self.controls.sessionGo = new("ButtonControl", {"LEFT",self.controls.sessionInput,"RIGHT"}, 8, 0, 60, 20, "继续", function()
		self:DownloadCharacterList()
	end)
	self.controls.sessionGo.enabled = function()
		return #self.controls.sessionInput.buf == 32
	end
	self.controls.sessionTutorialURL = new("ButtonControl", {"TOPLEFT",self.controls.sessionInput,"BOTTOMLEFT"}, 0, 10, 184, 18, "POESESSID的获取方式参考帖子", function()
		OpenURL("http://bbs.17173.com/thread-11316406-1-1.html")
			end)

	-- Stage: select character and import data
self.controls.charSelectHeader = new("LabelControl", {"TOPLEFT",self.controls.sectionCharImport,"TOPLEFT"}, 6, 40, 200, 16, "^7选择要导入的角色:")
	self.controls.charSelectHeader.shown = function()
		return self.charImportMode == "SELECTCHAR" or self.charImportMode == "IMPORTING"
	end
self.controls.charSelectLeagueLabel = new("LabelControl", {"TOPLEFT",self.controls.charSelectHeader,"BOTTOMLEFT"}, 0, 6, 0, 14, "^7联盟:")
	self.controls.charSelectLeague = new("DropDownControl", {"LEFT",self.controls.charSelectLeagueLabel,"RIGHT"}, 4, 0, 150, 18, nil, function(index, value)
		self:BuildCharacterList(value.league)
	end)
	self.controls.charSelect = new("DropDownControl", {"TOPLEFT",self.controls.charSelectHeader,"BOTTOMLEFT"}, 0, 24, 400, 18)
	self.controls.charSelect.enabled = function()
		return self.charImportMode == "SELECTCHAR"
	end
self.controls.charImportHeader = new("LabelControl", {"TOPLEFT",self.controls.charSelect,"BOTTOMLEFT"}, 0, 16, 200, 16, "导入:")
self.controls.charImportTree = new("ButtonControl", {"LEFT",self.controls.charImportHeader, "RIGHT"}, 8, 0, 170, 20, "天赋树和珠宝", function()
		if self.build.spec:CountAllocNodes() > 0 then
main:OpenConfirmPopup("角色导入", "导入天赋树会覆盖你当前的天赋树.", "导入", function()
				self:DownloadPassiveTree()
			end)
		else
			self:DownloadPassiveTree()
		end
	end)
	self.controls.charImportTree.enabled = function()
		return self.charImportMode == "SELECTCHAR"
	end
self.controls.charImportTreeClearJewels = new("CheckBoxControl", {"LEFT",self.controls.charImportTree,"RIGHT"}, 90, 0, 18, "不导入珠宝:")
self.controls.charImportTreeClearJewels.tooltipText = "导入时不导入珠宝信息."
self.controls.charImportItems = new("ButtonControl", {"LEFT",self.controls.charImportTree, "LEFT"}, 0, 36, 110, 20, "装备和技能", function()
		self:DownloadItems()
	end)
	self.controls.charImportItems.enabled = function()
		return self.charImportMode == "SELECTCHAR"
	end
self.controls.charImportItemsClearSkills = new("CheckBoxControl", {"LEFT",self.controls.charImportItems,"RIGHT"}, 85, 0, 18, "不导入技能:")
self.controls.charImportItemsClearSkills.tooltipText = "导入时不导入技能信息."
self.controls.charImportItemsClearItems = new("CheckBoxControl", {"LEFT",self.controls.charImportItems,"RIGHT"}, 220, 0, 18, "不导入装备:")
self.controls.charImportItemsClearItems.tooltipText = "导入时不导入装备"
self.controls.charBanditNote = new("LabelControl", {"TOPLEFT",self.controls.charImportHeader,"BOTTOMLEFT"}, 0, 50, 200, 14, "^7提示: 导入完成后要手动配置好盗贼任务和手动点亮星团珠宝的天赋,\n因为这些是不能导入的.")
self.controls.charClose = new("ButtonControl", {"TOPLEFT",self.controls.charImportHeader,"BOTTOMLEFT"}, 0, 90, 60, 20, "关闭", function()
		self.charImportMode = "GETACCOUNTNAME"
		self.charImportStatus = "未导入"
	end)

	-- Build import/export
self.controls.sectionBuild = new("SectionControl", {"TOPLEFT",self.controls.sectionCharImport,"BOTTOMLEFT"}, 0, 18, 600, 200, "Build分享")
self.controls.generateCodeLabel = new("LabelControl", {"TOPLEFT",self.controls.sectionBuild,"TOPLEFT"}, 6, 14, 0, 16, "^7生成代码给其他POB用户（仅限POB国服版）:")
self.controls.generateCode = new("ButtonControl", {"LEFT",self.controls.generateCodeLabel,"RIGHT"}, 4, 0, 80, 20, "生成", function()
		self.controls.generateCodeOut:SetText(common.base64.encode(Deflate(self.build:SaveDB("code"))):gsub("+","-"):gsub("/","_"))
	end)
self.controls.generateCodeOut = new("EditControl", {"TOPLEFT",self.controls.generateCodeLabel,"BOTTOMLEFT"}, 0, 8, 250, 20, "", "代码", "%Z")
	self.controls.generateCodeOut.enabled = function()
		return #self.controls.generateCodeOut.buf > 0
	end
self.controls.generateCodeCopy = new("ButtonControl", {"LEFT",self.controls.generateCodeOut,"RIGHT"}, 8, 0, 60, 20, "复制", function()
		Copy(self.controls.generateCodeOut.buf)
		self.controls.generateCodeOut:SetText("")
	end)
	self.controls.generateCodeCopy.enabled = function()
		return #self.controls.generateCodeOut.buf > 0
	end
self.controls.generateCodePastebin = new("ButtonControl", {"LEFT",self.controls.generateCodeCopy,"RIGHT"}, 8, 0, 140, 20, "生成Pastebin链接", function()
		local id = LaunchSubScript([[
			local code, proxyURL = ...
			local curl = require("lcurl.safe")
			local page = ""
			local easy = curl.easy()
			easy:setopt_url("https://pastebin.com/api/api_post.php")
			easy:setopt(curl.OPT_POST, true)
			easy:setopt(curl.OPT_POSTFIELDS, "api_dev_key=c4757f22e50e65e21c53892fd8e0a9ff&api_paste_private=1&api_option=paste&api_paste_code="..code)
			easy:setopt(curl.OPT_ACCEPT_ENCODING, "")
			if proxyURL then
				easy:setopt(curl.OPT_PROXY, proxyURL)
			end
			easy:setopt_writefunction(function(data)
				page = page..data
				return true
			end)
			easy:perform()
			easy:close()
			if page:match("pastebin.com") then
				return page
			else
				return nil, page
			end
		]], "", "", self.controls.generateCodeOut.buf, launch.proxyURL)
		if id then
			self.controls.generateCodeOut:SetText("")
self.controls.generateCodePastebin.label = "生成中..."
			launch:RegisterSubScript(id, function(pasteLink, errMsg)
self.controls.generateCodePastebin.label = "生成Pastebin地址"
				if errMsg then
					main:OpenMessagePopup("Pastebin.com", "Error creating paste:\n"..errMsg)
				else
					pasteLink=pasteLink.."?pob=cn"
					self.controls.generateCodeOut:SetText(pasteLink)
				end
			end)
		end
	end)
	self.controls.generateCodePastebin.enabled = function()
		return #self.controls.generateCodeOut.buf > 0 and not self.controls.generateCodeOut.buf:match("pastebin%.com")
	end
self.controls.generateCodeNote = new("LabelControl", {"TOPLEFT",self.controls.generateCodeOut,"BOTTOMLEFT"}, 0, 4, 0, 14, "^7注意: 这个代码很长，你可以用【生成Pastebin链接】来简化.")
self.controls.importCodeHeader = new("LabelControl", {"TOPLEFT",self.controls.generateCodeNote,"BOTTOMLEFT"}, 0, 26, 0, 16, "^7从代码中导入（仅限POB国服版代码）:")
self.controls.importCodeIn = new("EditControl", {"TOPLEFT",self.controls.importCodeHeader,"BOTTOMLEFT"}, 0, 4, 250, 20, "", nil, nil, nil, function(buf)
		if #buf == 0 then
			self.importCodeState = nil
			return
		end
		self.importCodeState = "INVALID"
		local xmlText = Inflate(common.base64.decode(buf:gsub("-","+"):gsub("_","/")))
		if not xmlText then
			return
		end
		if launch.devMode and IsKeyDown("SHIFT") then
			Copy(xmlText)
		end
		self.importCodeState = "VALID"
		self.importCodeXML = xmlText
		if not self.build.dbFileName then
			self.controls.importCodeMode.selIndex = 2
		end
	end)
	self.controls.importCodeState = new("LabelControl", {"LEFT",self.controls.importCodeIn,"RIGHT"}, 4, 0, 0, 16)
	self.controls.importCodeState.label = function()
return (self.importCodeState == "VALID" and colorCodes.POSITIVE.."代码正确") or (self.importCodeState == "INVALID" and colorCodes.NEGATIVE.."代码错误") or ""
	end
self.controls.importCodePastebin = new("ButtonControl", {"LEFT",self.controls.importCodeIn,"RIGHT"}, 90, 0, 160, 20, "从Pastebin导入...", function()
		self:OpenPastebinImportPopup()
	end)
self.controls.importCodeMode = new("DropDownControl", {"TOPLEFT",self.controls.importCodeIn,"BOTTOMLEFT"}, 0, 4, 160, 20, {"导入到当前build", "导入到新build"  })
	self.controls.importCodeMode.enabled = function()
		return self.importCodeState == "VALID" and self.build.dbFileName
	end
self.controls.importCodeGo = new("ButtonControl", {"TOPLEFT",self.controls.importCodeMode,"BOTTOMLEFT"}, 0, 8, 60, 20, "导入", function()
		if self.controls.importCodeMode.selIndex == 1 then
main:OpenConfirmPopup("Build Import", colorCodes.WARNING.."警告:^7 导入到当前build会删除原有build信息", "导入", function()
				self.build:Shutdown()
				self.build:Init(self.build.dbFileName, self.build.buildName, self.importCodeXML)
				self.build.viewMode = "TREE"
			end)
		else
			self.build:Shutdown()
			self.build:Init(false, "Imported build", self.importCodeXML)
			self.build.viewMode = "TREE"
		end
	end)
	self.controls.importCodeGo.enabled = function()
		return self.importCodeState == "VALID"
	end
end)

function ImportTabClass:Load(xml, fileName)
	self.lastRealm = xml.attrib.lastRealm
	self.controls.accountRealm:SelByValue( self.lastRealm or main.lastRealm or "PC", "id" )
	
	self.lastAccountHash = xml.attrib.lastAccountHash
	if self.lastAccountHash then
		for accountName in pairs(main.gameAccounts) do
			if common.sha1(accountName) == self.lastAccountHash then
				self.controls.accountName:SetText(accountName)
			end
		end
	end
	self.lastCharacterHash = xml.attrib.lastCharacterHash
end

function ImportTabClass:Save(xml)
	xml.attrib = {
		lastRealm = self.lastRealm,
		lastAccountHash = self.lastAccountHash,
		lastCharacterHash = self.lastCharacterHash,
	}
end

function ImportTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	self:ProcessControlsInput(inputEvents, viewPort)

	main:DrawBackground(viewPort)

	self:DrawControls(viewPort)
end

function ImportTabClass:DownloadCharacterList()
	self.charImportMode = "DOWNLOADCHARLIST"
	self.charImportStatus = "正在获取角色列表..."
	local accountName = urlEncode(self.controls.accountName.buf)
	local realm = realmList[self.controls.accountRealm.selIndex]
	local sessionID = #self.controls.sessionInput.buf == 32 and self.controls.sessionInput.buf or (main.gameAccounts[accountName] and main.gameAccounts[accountName].sessionID)
	launch:DownloadPage("https://poe.game.qq.com/character-window/get-characters?accountName="..accountName.."&realm="..realm.realmCode, function(page, errMsg)
		if errMsg == "Response code: 403" then
			self.charImportStatus = colorCodes.NEGATIVE.."角色没有公开."
			self.charImportMode = "GETSESSIONID"
			return
		elseif errMsg == "Response code: 401" then
			self.charImportStatus = colorCodes.NEGATIVE.."获取角色信息失败，国服网页接口需要登录."
			self.charImportMode = "GETSESSIONID"
			return
		elseif errMsg == "Response code: 404" then
			self.charImportStatus = colorCodes.NEGATIVE.."论坛名错误."
			self.charImportMode = "GETACCOUNTNAME"
			return
		elseif errMsg == "Response code: 404" then
			self.charImportStatus = colorCodes.NEGATIVE.."论坛名错误."
			self.charImportMode = "GETACCOUNTNAME"
			return
		elseif errMsg then
			self.charImportStatus = colorCodes.NEGATIVE.."获取角色列表失败，请重试 ("..errMsg:gsub("\n"," ")..")"
			self.charImportMode = "GETACCOUNTNAME"
			return
		end
		local charList, errMsg = self:ProcessJSON(page)
		if errMsg then
			self.charImportStatus = colorCodes.NEGATIVE.."获取角色列表失败，请稍后重试"
			self.charImportMode = "GETACCOUNTNAME"
			return
		end
		--ConPrintTable(charList)
		if #charList == 0 then
			self.charImportStatus = colorCodes.NEGATIVE.."这个账户没有角色."
			self.charImportMode = "GETACCOUNTNAME"
			return
		end
		-- GGG's character API has an issue where for /get-characters the account name is not case-sensitive, but for /get-passive-skills and /get-items it is.
		-- This workaround grabs the profile page and extracts the correct account name from one of the URLs.
		launch:DownloadPage(realm.profileURL..accountName, function(page, errMsg)
			if errMsg then
				self.charImportStatus = colorCodes.NEGATIVE.."获取角色列表失败，请重试 ("..errMsg:gsub("\n"," ")..")"
				self.charImportMode = "GETACCOUNTNAME"
				return
			end
			local realAccountName = page:match("/view%-profile/([^/]+)/characters"):gsub(".", function(c) if c:byte(1) > 127 then return string.format("%%%2X",c:byte(1)) else return c end end)
			if not realAccountName then
				self.charImportStatus = colorCodes.NEGATIVE.."接收角色列表失败."
				self.charImportMode = "GETSESSIONID"
				return
			end
			self.controls.accountName:SetText(realAccountName)
			accountName = realAccountName
			self.charImportStatus = "接收角色列表成功."
			self.charImportMode = "SELECTCHAR"
			self.lastRealm = realm.id
			main.lastRealm = realm.id
			self.lastAccountHash = common.sha1(accountName)
			main.lastAccountName = accountName
			main.gameAccounts[accountName] = main.gameAccounts[accountName] or { }
			main.gameAccounts[accountName].sessionID = sessionID
			local leagueList = { }
			for i, char in ipairs(charList) do
				if not isValueInArray(leagueList, char.league) then
					t_insert(leagueList, char.league)
				end
			end
			table.sort(leagueList)
			wipeTable(self.controls.charSelectLeague.list)
			t_insert(self.controls.charSelectLeague.list, {
				label = "全部",
			})
			for _, league in ipairs(leagueList) do
				t_insert(self.controls.charSelectLeague.list, {
					label = league,
					league = league,
				})
			end				
			self.lastCharList = charList
			self:BuildCharacterList(self.controls.charSelectLeague:GetSelValue("league"))

			-- We only get here if the accountname was correct, found, and not private, so add it to the account history.
			self:SaveAccountHistory()
		end, sessionID and "POESESSID="..sessionID)
	end, sessionID and "POESESSID="..sessionID)
end

function ImportTabClass:BuildCharacterList(league)
	wipeTable(self.controls.charSelect.list)
	for i, char in ipairs(self.lastCharList) do
		if not league or char.league == league then
			t_insert(self.controls.charSelect.list, {
			label = string.format("%s: 等级 %d %s 在 %s", char.name or "?", char.level or 0, classesCn[char.class] or "?", char.league or "?"),
				char = char,
			})
		end
	end
	table.sort(self.controls.charSelect.list, function(a,b)
		return a.char.name:lower() < b.char.name:lower()
	end)
	self.controls.charSelect.selIndex = 1
	if self.lastCharacterHash then
		for i, char in ipairs(self.controls.charSelect.list) do
			if common.sha1(char.char.name) == self.lastCharacterHash then
				self.controls.charSelect.selIndex = i
				break
			end
		end
	end
end

function ImportTabClass:SaveAccountHistory()
	if not historyList[self.controls.accountName.buf] then
		t_insert(historyList, urlDecode(self.controls.accountName.buf))
		historyList[self.controls.accountName.buf] = true
		self.controls.accountHistory:SelByValue(urlDecode(self.controls.accountName.buf))
		table.sort(historyList, function(a,b)
			return a:lower() < b:lower()
		end)
		self.controls.accountHistory:CheckDroppedWidth(true)
	end
end

function ImportTabClass:DownloadPassiveTree()
	self.charImportMode = "IMPORTING"
	self.charImportStatus = "获取角色天赋树信息中..."
	local realm = realmList[self.controls.accountRealm.selIndex]
	local accountName = self.controls.accountName.buf
	local encodeName = urlEncode(accountName)
	local sessionID = #self.controls.sessionInput.buf == 32 and self.controls.sessionInput.buf or (main.gameAccounts[encodeName] and main.gameAccounts[encodeName].sessionID)
	local charSelect = self.controls.charSelect
	local charData = charSelect.list[charSelect.selIndex].char
	launch:DownloadPage("https://poe.game.qq.com/character-window/get-passive-skills?accountName="..accountName.."&character="..charData.name.."&realm="..realm.realmCode, function(page, errMsg)
		self.charImportMode = "SELECTCHAR"
		if errMsg then
			if errMsg == "Response code: 401" then
				self.charImportStatus = colorCodes.NEGATIVE.."导入角色天赋树失败，国服网页接口需要登录"
				self.charImportMode = "GETSESSIONID"
			else
				self.charImportStatus = colorCodes.NEGATIVE.."导入角色天赋树失败，请重试 ("..errMsg:gsub("\n"," ")..")"
			end
			return
		elseif page == "false" then
			self.charImportStatus = colorCodes.NEGATIVE.."导入角色天赋树失败，请重试."
			return
		end
		self.lastCharacterHash = common.sha1(charData.name)
		self:ImportPassiveTreeAndJewels(page, charData)
	end, sessionID and "POESESSID="..sessionID)
end

function ImportTabClass:DownloadItems()
	self.charImportMode = "IMPORTING"
	self.charImportStatus = "获取角色装备中..."
	local realm = realmList[self.controls.accountRealm.selIndex]
	local accountName = self.controls.accountName.buf
	local encodeName = urlEncode(accountName)
	local sessionID = #self.controls.sessionInput.buf == 32 and self.controls.sessionInput.buf or (main.gameAccounts[encodeName] and main.gameAccounts[encodeName].sessionID)
	local charSelect = self.controls.charSelect
	local charData = charSelect.list[charSelect.selIndex].char
	launch:DownloadPage("https://poe.game.qq.com/character-window/get-items?accountName="..accountName.."&character="..charData.name.."&realm="..realm.realmCode, function(page, errMsg)
		self.charImportMode = "SELECTCHAR"
		if errMsg then
			if errMsg == "Response code: 401" then
				self.charImportStatus = colorCodes.NEGATIVE.."导入角色装备失败，国服网页接口需要登录"
				self.charImportMode = "GETSESSIONID"
			else
				self.charImportStatus = colorCodes.NEGATIVE.."导入角色装备失败，请重试 ("..errMsg:gsub("\n"," ")..")"
			end
			return
		elseif page == "false" then
			self.charImportStatus = colorCodes.NEGATIVE.."导入角色装备失败，请重试."
			return
		end
		self.lastCharacterHash = common.sha1(charData.name)
		self:ImportItemsAndSkills(page)
	end, sessionID and "POESESSID="..sessionID)
end

function ImportTabClass:ImportPassiveTreeAndJewels(json, charData)
	--local out = io.open("get-passive-skills.json", "w")
	--out:write(json)
	--out:close()
	local charPassiveData, errMsg = self:ProcessJSON(json)
	--local out = io.open("get-passive-skills.json", "w")
	--writeLuaTable(out, charPassiveData, 1)
	--out:close()
	
	-- 3.16+
	if charPassiveData.mastery_effects then
		local mastery, effect = 0, 0
		for key, value in pairs(charPassiveData.mastery_effects) do
			if type(value) ~= "string" then
				break
			end
			mastery = band(tonumber(value), 65535)
			effect = b_rshift(tonumber(value), 16)
			t_insert(charPassiveData.mastery_effects, mastery, effect)
		end
	end
	if errMsg then
self.charImportStatus = colorCodes.NEGATIVE.."处理角色物品和技能错误，请重试."
		return
	end
self.charImportStatus = colorCodes.POSITIVE.."天赋树和珠宝导入成功."
	if charPassiveData.jewel_data then 
		self.build.spec.jewel_data = copyTable(charPassiveData.jewel_data)
	end
	if charPassiveData.hashes_ex then 
		self.build.spec.extended_hashes = copyTable(charPassiveData.hashes_ex)
	end
	--ConPrintTable(charPassiveData)
	
	if  not self.controls.charImportTreeClearJewels.state then
		for _, itemData in pairs(charPassiveData.items) do
				self:ImportItem(itemData)
		end
	end
	self.build.itemsTab:PopulateSlots()
	self.build.itemsTab:AddUndoState()
	self.build.spec:ImportFromNodeList(charData.classId, charData.ascendancyClass, charPassiveData.hashes, charPassiveData.mastery_effects or {})
	self.build.spec:AddUndoState()
	--self.build.spec:resetAllocTimeJew(); 
	self.build.characterLevel = charData.level
	self.build.controls.characterLevel:SetText(charData.level)
	self.build.buildFlag = true
end

function ImportTabClass:ImportItemsAndSkills(json)
	--local out = io.open("get-items.json", "w")
	--out:write(json)
	--out:close()
	local charItemData, errMsg = self:ProcessJSON(json)
	if errMsg then
self.charImportStatus = colorCodes.NEGATIVE.."处理角色物品和技能错误，请重试."
		return
	end
	 
	local mainSkillEmpty = #self.build.skillsTab.socketGroupList == 0
	local skillOrder
	if self.controls.charImportItemsClearSkills.state then
		skillOrder = { }
		for _, socketGroup in ipairs(self.build.skillsTab.socketGroupList) do
			for _, gem in ipairs(socketGroup.gemList) do
				if gem.grantedEffect and not gem.grantedEffect.support then
					t_insert(skillOrder, gem.grantedEffect.name)
				end
			end
		end
		wipeTable(self.build.skillsTab.socketGroupList)
	end
	self.charImportStatus = colorCodes.POSITIVE.."物品和技能导入成功."
	--ConPrintTable(charItemData)
	if not self.controls.charImportItemsClearItems.state then
		for _, itemData in pairs(charItemData.items) do	
		
				self:ImportItem(itemData)
		end
	else 
--删除物品的话

			for _, itemData in pairs(charItemData.items) do			
				if itemData.socketedItems then
				local slotName
				if itemData.inventoryId == "PassiveJewels" and sockets then
						slotName = "Jewel "..sockets[itemData.x + 1]
					elseif itemData.inventoryId == "Flask" then
						slotName = "Flask "..(itemData.x + 1)
					else
					
						slotName = slotMap[itemData.inventoryId]
					end
				if  slotName then
					self:ImportSocketedItems(itemData, itemData.socketedItems, slotName)
				end	
				
				end
			 end
			 
	end
	if skillOrder   then
		local groupOrder = { }
		for index, socketGroup in ipairs(self.build.skillsTab.socketGroupList) do
			groupOrder[socketGroup] = index
		end
		table.sort(self.build.skillsTab.socketGroupList, function(a, b)
			local orderA
			for _, gem in ipairs(a.gemList) do
				if gem.grantedEffect and not gem.grantedEffect.support then
					local i = isValueInArray(skillOrder, gem.grantedEffect.name)
					if i and (not orderA or i < orderA) then
						orderA = i
					end
				end
			end
			local orderB
			for _, gem in ipairs(b.gemList) do
				if gem.grantedEffect and not gem.grantedEffect.support then
					local i = isValueInArray(skillOrder, gem.grantedEffect.name)
					if i and (not orderB or i < orderB) then
						orderB = i
					end
				end
			end
			if orderA and orderB then
				if orderA ~= orderB then
					return orderA < orderB
				else
					return groupOrder[a] < groupOrder[b]
				end
			elseif not orderA and not orderB then
				return groupOrder[a] < groupOrder[b]
			else
				return orderA
			end
		end)
	end
	if mainSkillEmpty then
		self.build.mainSocketGroup = self:GuessMainSocketGroup()
	end
	self.build.itemsTab:PopulateSlots()
	self.build.itemsTab:AddUndoState()
	self.build.skillsTab:AddUndoState()
	self.build.characterLevel = charItemData.character.level
	self.build.controls.characterLevel:SetText(charItemData.character.level)
	self.build.buildFlag = true
	return charItemData.character -- For the wrapper
end


function ImportTabClass:ImportItem(itemData, slotName)
	if not slotName then
		if itemData.inventoryId == "PassiveJewels" then
			slotName = "Jewel "..self.build.latestTree.jewelSlots[itemData.x + 1]
		elseif itemData.inventoryId == "Flask" then
			slotName = "Flask "..(itemData.x + 1)
		else
			
			slotName = slotMap[itemData.inventoryId]
		end
	end
	if not slotName then
		-- Ignore any items that won't go into known slots
		return
	end

	local item = new("Item")
	-- Determine rarity, display name and base type of the item
	item.rarity = rarityMap[itemData.frameType]
	if #itemData.name > 0 then
		item.title = itemLib.sanitiseItemText(itemData.name)
		-- 基底
		item.baseName = itemLib.sanitiseItemText(itemData.typeLine):gsub("忆境 ",""):gsub("漫游之弓","游侠弓")
		item.name = item.title .. ", " .. item.baseName
		if item.baseName == "Two-Toned Boots" then
			-- Hack for Two-Toned Boots
			item.baseName = "Two-Toned Boots (Armour/Energy Shield)"
		end
		item.base = self.build.data.itemBases[item.baseName]
		if item.base then
			item.type = item.base.type
		else
			ConPrintf("Unrecognised base in imported item: %s", item.baseName)
		end
	else
		item.name = itemLib.sanitiseItemText(itemData.typeLine)
		if item.name:match("能量之刃") then
			local oneHanded = false
			local weaponTypeCn = { 单手剑 = "One Handed Sword", 双手剑 = "Two Handed Sword"}
			for _, p in ipairs(itemData.properties) do
				if weaponTypeCn[p.name] and self.build.data.weaponTypeInfo[weaponTypeCn[p.name]]
					and self.build.data.weaponTypeInfo[weaponTypeCn[p.name]].oneHand then
					oneHanded = true
					break
				end
			end
			item.name = oneHanded and "能量之刃单手剑" or "能量之刃双手剑"
			itemData.implicitMods = nil
			itemData.explicitMods = nil
		end
		for baseName, baseData in pairs(self.build.data.itemBases) do
			local s, e = item.name:find(baseName, 1, true)
			if s then
				item.baseName = baseName
				item.namePrefix = item.name:sub(1, s - 1)
				item.nameSuffix = item.name:sub(e + 1)
				item.type = baseData.type
				break
			end
		end
		if not item.baseName then
			local s, e = item.name:find("Two-Toned Boots", 1, true)
			if s then
				-- Hack for Two-Toned Boots
				item.baseName = "Two-Toned Boots (Armour/Energy Shield)"
				item.namePrefix = item.name:sub(1, s - 1)
				item.nameSuffix = item.name:sub(e + 1)
				item.type = "Boots"
			end
		end
		item.base = self.build.data.itemBases[item.baseName]
	end
	if not item.base or not item.rarity then
		return
	end

	-- Import item data
	item.uniqueID = itemData.id
	 
	for _, curInfluenceInfo in ipairs(influenceInfo) do
		item[curInfluenceInfo.key] = itemData[curInfluenceInfo.key]
		
		if itemData["influences"] and itemData["influences"][curInfluenceInfo.key] then 
			item[curInfluenceInfo.key] =itemData["influences"][curInfluenceInfo.key]
		end 
		 
	end
	--[[
	item.shaper = itemData.shaper
	item.elder = itemData.elder
	if itemData.influences and itemData.influences.crusader then 
		item.crusader= itemData.influences.crusader
	end
	if itemData.influences and itemData.influences.redeemer then 
		item.redeemer= itemData.influences.redeemer
	end
	if itemData.influences and itemData.influences.hunter then 
		item.hunter= itemData.influences.hunter
	end
	if itemData.influences and itemData.influences.warlord then 
		item.warlord= itemData.influences.warlord
	end]]--
	 
	
	if itemData.ilvl > 0 then
		item.itemLevel = itemData.ilvl
	end
	if item.base.weapon or item.base.armour or item.base.flask then
		item.quality = 0
	end
	if itemData.properties then
		for _, property in pairs(itemData.properties) do
			if property.name == "品质" then
				item.quality = tonumber(property.values[1][1]:match("%d+"))
			elseif  property.name:find("品质（", 1, true)  then
				item.qualityTitle = property.name
				item.quality = tonumber(property.values[1][1]:match("%d+"))
				--print(item.qualityTitle)
			elseif property.name == "范围" then
				item.jewelRadiusLabel = property.values[1][1]
			elseif property.name == "仅限" then
				item.limit = tonumber(property.values[1][1])
			elseif property.name == "Evasion Rating" then
				if item.baseName == "Two-Toned Boots (Armour/Energy Shield)" then
					-- Another hack for Two-Toned Boots
					item.baseName = "Two-Toned Boots (Armour/Evasion)"
					item.base = self.build.data.itemBases[item.baseName]
				end
			elseif property.name == "Energy Shield" then
				if item.baseName == "Two-Toned Boots (Armour/Evasion)" then
					-- Yet another hack for Two-Toned Boots
					item.baseName = "Two-Toned Boots (Evasion/Energy Shield)"
					item.base = self.build.data.itemBases[item.baseName]
				end
			end
			if property.name == "Energy Shield" or property.name == "Ward" or property.name == "Armour" or property.name == "Evasion" then
				item.armourData = item.armourData or { }
				for _, value in ipairs(property.values) do
					item.armourData[property.name:gsub(" ", "")] = (item.armourData[property.name:gsub(" ", "")] or 0) + tonumber(value[1])
				end
			end
		end
	end
	item.corrupted = itemData.corrupted
	item.fractured = itemData.fractured
	item.synthesised = itemData.synthesised	
	if itemData.sockets and itemData.sockets[1] then
		item.sockets = { }
		for i, socket in pairs(itemData.sockets) do
			item.sockets[i] = { group = socket.group, color = socket.sColour }
		end
	end
	if itemData.socketedItems then
		self:ImportSocketedItems(item, itemData.socketedItems, slotName)
	end
	if itemData.requirements and (not itemData.socketedItems or not itemData.socketedItems[1]) then
		-- Requirements cannot be trusted if there are socketed gems, as they may override the item's natural requirements
		item.requirements = { }
		for _, req in ipairs(itemData.requirements) do
			if req.name == "Level" then
				item.requirements.level = req.values[1][1]
			end
		end
	end
	item.enchantModLines = { }
	item.scourgeModLines = { }
	item.classRequirementModLines = { }
	item.implicitModLines = { }
	item.explicitModLines = { }
	if itemData.enchantMods then
		
		for _, line in ipairs(itemData.enchantMods) do
		
			for line in line:gmatch("[^\n]+") do
				local modList, extra = modLib.parseMod(line)				
				t_insert(item.enchantModLines, { line = line, extra = extra, mods = modList or { }, crafted = true })
			end
			
		end
	end
	if itemData.scourgeMods then
		for _, line in ipairs(itemData.scourgeMods) do
			for line in line:gmatch("[^\n]+") do
				local modList, extra = modLib.parseMod(line)
				t_insert(item.scourgeModLines, { line = line, extra = extra, mods = modList or { }, scourge = true })
			end
		end
	end
	if itemData.implicitMods then
		
		for _, line in ipairs(itemData.implicitMods) do
			for line in line:gmatch("[^\n]+") do
				local modList, extra = modLib.parseMod(line)
				t_insert(item.implicitModLines, { line = line, extra = extra, mods = modList or { } })
			end
		end
	end
	if itemData.fracturedMods then
		for _, line in ipairs(itemData.fracturedMods) do
			for line in line:gmatch("[^\n]+") do
				local modList, extra = modLib.parseMod(line)
				t_insert(item.explicitModLines, { line = line, extra = extra, mods = modList or { }, fractured = true })
			end
		end
	end
	if itemData.explicitMods then
		for _, line in ipairs(itemData.explicitMods) do
				if line ~= nil then --lucifer 修复换行珠宝的问题					
					line=string.gsub(line,"\n","")
				end
			for line in line:gmatch("[^\n]+") do
				
				local modList, extra = modLib.parseMod(line)
				t_insert(item.explicitModLines, { line = line, extra = extra, mods = modList or { } })
			end
		end
	end
	if itemData.craftedMods then
		for _, line in ipairs(itemData.craftedMods) do
			for line in line:gmatch("[^\n]+") do
				local modList, extra = modLib.parseMod(line)
				t_insert(item.explicitModLines, { line = line, extra = extra, mods = modList or { }, crafted = true })
			end
		end
	end

	-- Add and equip the new item
	item:BuildAndParseRaw()
	--ConPrintf("%s", item.raw)
	if item.base then
		local repIndex, repItem
		for index, item in pairs(self.build.itemsTab.items) do
			if item.uniqueID == itemData.id then
				repIndex = index
				repItem = item
				break
			end
		end
		if repIndex then
			-- Item already exists in the build, overwrite it
			item.id = repItem.id
			self.build.itemsTab.items[item.id] = item
			item:BuildModList()
		else
			self.build.itemsTab:AddItem(item, true)
		end
		self.build.itemsTab.slots[slotName]:SetSelItemId(item.id)
	end
end



function ImportTabClass:ImportSocketedItems(item, socketedItems, slotName)
	-- Build socket group list
	local itemSocketGroupList = { }
	local abyssalSocketId = 1
	for _, socketedItem in ipairs(socketedItems) do
	
		if socketedItem.abyssJewel then
			self:ImportItem(socketedItem, slotName .. " Abyssal Socket "..abyssalSocketId)
			abyssalSocketId = abyssalSocketId + 1
		elseif not self.controls.charImportItemsClearSkills.state then 
			local normalizedBasename, qualityType = self.build.skillsTab:GetBaseNameAndQuality(socketedItem.typeLine, nil)
			
			local gemId = self.build.data.gemForBaseName[normalizedBasename] 
			
			if not gemId and socketedItem.hybrid then
				-- Dual skill gems (currently just Stormbind) show the second skill as the typeLine, which won't match the actual gem
				-- Luckily the primary skill name is also there, so we can find the gem using that
				normalizedBasename, qualityType  = self.build.skillsTab:GetBaseNameAndQuality(socketedItem.hybrid.baseTypeName, nil)
				gemId = self.build.data.gemForBaseName[normalizedBasename]
			end
			
			
			if gemId then
				local gemInstance = { level = 20, quality = 0, enabled = true, enableGlobal1 = true, gemId = gemId }
				gemInstance.nameSpec = self.build.data.gems[gemId].name
				gemInstance.support = socketedItem.support
				gemInstance.qualityId = qualityType
				for _, property in pairs(socketedItem.properties) do
					if property.name == "等级" then
						gemInstance.level = tonumber(property.values[1][1]:match("%d+"))
					elseif property.name == "品质" then
						gemInstance.quality = tonumber(property.values[1][1]:match("%d+"))
					end
				end
				local groupID = item.sockets[socketedItem.socket + 1].group
				if not itemSocketGroupList[groupID] then
					itemSocketGroupList[groupID] = { label = "", enabled = true, gemList = { }, slot = slotName }
				end
				local socketGroup = itemSocketGroupList[groupID]
				if not socketedItem.support and socketGroup.gemList[1] and socketGroup.gemList[1].support then
					-- If the first gemInstance is a support gemInstance, put the first active gemInstance before it
					t_insert(socketGroup.gemList, 1, gemInstance)
				else
					t_insert(socketGroup.gemList, gemInstance)
				end
			end
		--[[
		local gemInstance = { level = 20, quality = 0, enabled = true, enableGlobal1 = true }
			gemInstance.nameSpec = self:SupportHybridSkillName(socketedItem.typeLine:gsub(" Support",""))
			gemInstance.support = socketedItem.support
			for _, property in pairs(socketedItem.properties) do
if property.name == "等级" then
					gemInstance.level = tonumber(property.values[1][1]:match("%d+"))
elseif property.name == "品质" then
					gemInstance.quality = tonumber(property.values[1][1]:match("%d+"))
				end
			end
			local groupID = item.sockets[socketedItem.socket + 1].group
			if not itemSocketGroupList[groupID] then
				itemSocketGroupList[groupID] = { label = "", enabled = true, gemList = { }, slot = slotName }
			end
			local socketGroup = itemSocketGroupList[groupID]
			if not socketedItem.support and socketGroup.gemList[1] and socketGroup.gemList[1].support then
				-- If the first gemInstance is a support gemInstance, put the first active gemInstance before it
				t_insert(socketGroup.gemList, 1, gemInstance)
			else
				t_insert(socketGroup.gemList, gemInstance)
			end
			]]--
			
		end
	end

	-- Import the socket groups
	for _, itemSocketGroup in pairs(itemSocketGroupList) do	
		-- Check if this socket group matches an existing one
		local repGroup
		for index, socketGroup in pairs(self.build.skillsTab.socketGroupList) do
			if #socketGroup.gemList == #itemSocketGroup.gemList and (not socketGroup.slot or socketGroup.slot == slotName) then
				local match = true
				for gemIndex, gem in pairs(socketGroup.gemList) do
					if gem.nameSpec:lower() ~= itemSocketGroup.gemList[gemIndex].nameSpec:lower() then
						match = false
						break
					end
				end
				if match then
					repGroup = socketGroup
					break
				end
			end
		end
		if repGroup then
			-- Update the existing one
			for gemIndex, gem in pairs(repGroup.gemList) do
				local itemGem = itemSocketGroup.gemList[gemIndex]
				gem.level = itemGem.level
				gem.quality = itemGem.quality
			end
		else
			t_insert(self.build.skillsTab.socketGroupList, itemSocketGroup)
		end
		
		self.build.skillsTab:ProcessSocketGroup(itemSocketGroup)
	end	
end

-- Return the index of the group with the most gems
function ImportTabClass:GuessMainSocketGroup()
	local largestGroupSize = 0
	local largestGroupIndex = 1
	for i, socketGroup in ipairs(self.build.skillsTab.socketGroupList) do
		if #socketGroup.gemList > largestGroupSize then
			largestGroupSize = #socketGroup.gemList
			largestGroupIndex = i
		end
	end
	return largestGroupIndex
end

function ImportTabClass:SupportHybridSkillName(typeLine)
	if typeLine == "震波" then 
	
	return "震波（辅）"
	
	else 
	
	return typeLine
	
	end
	
end
function ImportTabClass:OpenPastebinImportPopup()
	local controls = { }
controls.editLabel = new("LabelControl", nil, 0, 20, 0, 16, "输入Pastebin链接（由POB国服版分享的）:")
	controls.edit = new("EditControl", nil, 0, 40, 250, 18, "", nil, "^%w%p%s", nil, function(buf)
		controls.msg.label = ""
	end)
	controls.msg = new("LabelControl", nil, 0, 58, 0, 16, "")
controls.import = new("ButtonControl", nil, -45, 80, 80, 20, "导入", function()
		controls.import.enabled = false
controls.msg.label = "获取中..."
		controls.edit.buf = controls.edit.buf:gsub("^%s+", ""):gsub("%s+$", ""):gsub("?pob=cn", "") -- Quick Trim
		launch:DownloadPage(controls.edit.buf:gsub("pastebin%.com/(%w+)%s*$","pastebin.com/raw/%1"), function(page, errMsg)
			if errMsg then
				controls.msg.label = "^1"..errMsg
				controls.import.enabled = true
			else
				self.controls.importCodeIn:SetText(page, true)
				main:ClosePopup()
			end
		end)
	end)
	controls.import.enabled = function()
		return #controls.edit.buf > 0 and controls.edit.buf:match("pastebin%.com/%w+")
	end
controls.cancel = new("ButtonControl", nil, 45, 80, 80, 20, "取消", function()
		main:ClosePopup()
	end)
main:OpenPopup(380, 110, "从Pastebin导入", controls, "导入", "编辑")
end

function ImportTabClass:ProcessJSON(json)
	local func, errMsg = loadstring("return "..jsonToLua(json))
	if errMsg then
		return nil, errMsg
	end
	setfenv(func, { }) -- Sandbox the function just in case
	local data = func()
	if type(data) ~= "table" then
		return nil, "Return type is not a table"
	end
	return data
end
