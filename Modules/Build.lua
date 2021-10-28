-- Path of Building
--
-- Module: Build
-- Loads and manages the current build.
--
--local launch, main = ...

local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local m_min = math.min
local m_max = math.max
local m_floor = math.floor
local m_abs = math.abs
local s_format = string.format

local fooBanditDropList = {
{ label = "全杀（2点天赋点）", banditId = "None" },
{ label = "欧克 (生命回复，物理伤害，物理减伤)", banditId = "Oak" },
{ label = "克雷顿 (攻击/施法速度，攻击躲避，移动速度)", banditId = "Kraityn" },
{ label = "阿莉亚 (魔力回复，暴击伤害，抗性)", banditId = "Alira" },
}


local PantheonMajorGodDropList = {
	{ label = "无", id = "None" },
	{ label = "惊海之王 索亚格斯之魂", id = "TheBrineKing" },
	{ label = "月影女神之魂", id = "Lunaris" },
	{ label = "日耀女神之魂", id = "Solaris" },
	{ label = "暗影女皇 阿拉卡力之魂", id = "Arakaali" },
}

local PantheonMinorGodDropList = {
	{ label = "无", id = "None" },
	{ label = "绝望之母 格鲁丝克之魂", id = "Gruthkul" },
	{ label = "恐惧之源 尤格尔之魂", id = "Yugul" },
	{ label = "割裂者 艾贝拉斯之魂", id = "Abberath" },
	{ label = "战争之父 图克哈玛之魂", id = "Tukohama" },
	{ label = "风暴女神 格鲁坎之魂", id = "Garukhan" },
	{ label = "万面之主 拉克斯之魂", id = "Ralakesh" },
	{ label = "傀儡女王 瑞斯拉萨之魂", id = "Ryslatha" },
	{ label = "沙之女神 沙卡丽之魂", id = "Shakari" },
}


local buildMode = new("ControlHost")

function buildMode:Init(dbFileName, buildName, buildXML, convertBuild)
	self.dbFileName = dbFileName
	self.buildName = buildName
	if dbFileName then
		self.dbFileSubPath = self.dbFileName:sub(#main.buildPath + 1, -#self.buildName - 5)
	else
		self.dbFileSubPath = main.modes.LIST.subPath or ""
	end
	if not buildName then
		main:SetMode("LIST")
	end

	-- Load build file
	self.xmlSectionList = { }
	self.spectreList = { }
	self.viewMode = "TREE"	
	self.characterLevel = 1
	self.targetVersion = liveTargetVersion
	self.bandit = "None"
	self.pantheonMajorGod = "None"
	self.pantheonMinorGod = "None"

			
	if buildXML then
		if self:LoadDB(buildXML, "Unnamed build") then
			self:CloseBuild()
			return
		end
		self.modFlag = true
	else
		if self:LoadDBFile() then
			self:CloseBuild()
			return
		end
		self.modFlag = false
	end

	if convertBuild then
		self.targetVersion = liveTargetVersion
	end

	if self.targetVersion ~= liveTargetVersion then
		self.targetVersion = nil
		self:OpenConversionPopup()
		return		
	end

	self.abortSave = true

	wipeTable(self.controls)

	local miscTooltip = new("Tooltip")

	-- Controls: top bar, left side
	self.anchorTopBarLeft = new("Control", nil, 4, 4, 0, 20)
self.controls.back = new("ButtonControl", {"LEFT",self.anchorTopBarLeft,"RIGHT"}, 0, 0, 60, 20, "<< 返回", function()
		if self.unsaved then
			self:OpenSavePopup("LIST")
		else
			 
		
			self:CloseBuild()
			--self.spec:resetAll(); 
		end
	end)
	self.controls.buildName = new("Control", {"LEFT",self.controls.back,"RIGHT"}, 8, 0, 0, 20)
	self.controls.buildName.width = function(control)
		local limit = self.anchorTopBarRight:GetPos() - 98 - 40 - self.controls.back:GetSize() - self.controls.save:GetSize() - self.controls.saveAs:GetSize()
		local bnw = DrawStringWidth(16, "VAR", self.buildName)
		self.strWidth = m_min(bnw, limit)
		self.strLimited = bnw > limit
		return self.strWidth + 98
	end
	self.controls.buildName.Draw = function(control)
		local x, y = control:GetPos()
		local width, height = control:GetSize()
		SetDrawColor(0.5, 0.5, 0.5)
		DrawImage(nil, x + 91, y, self.strWidth + 6, 20)
		SetDrawColor(0, 0, 0)
		DrawImage(nil, x + 92, y + 1, self.strWidth + 4, 18)
		SetDrawColor(1, 1, 1)
		SetViewport(x, y + 2, self.strWidth + 94, 16)
DrawString(0, 0, "LEFT", 16, "VAR", "当前的 build :  "..self.buildName)
		SetViewport()
		if control:IsMouseInBounds() then
			SetDrawLayer(nil, 10)
			miscTooltip:Clear()
			if self.dbFileSubPath and self.dbFileSubPath ~= "" then
				miscTooltip:AddLine(16, self.dbFileSubPath..self.buildName)
			elseif self.strLimited then
				miscTooltip:AddLine(16, self.buildName)
			end
			miscTooltip:Draw(x, y, width, height, main.viewPort)
			SetDrawLayer(nil, 0)
		end
	end
self.controls.save = new("ButtonControl", {"LEFT",self.controls.buildName,"RIGHT"}, 8, 0, 50, 20, "保存", function()
		self:SaveDBFile()
	end)
	self.controls.save.enabled = function()
		return not self.dbFileName or self.unsaved
	end
self.controls.saveAs = new("ButtonControl", {"LEFT",self.controls.save,"RIGHT"}, 8, 0, 70, 20, "另存为", function()
		self:OpenSaveAsPopup()
	end)
	self.controls.saveAs.enabled = function()
		return self.dbFileName
	end

	-- Controls: top bar, right side
	self.anchorTopBarRight = new("Control", nil, function() return main.screenW / 2 + 6 end, 4, 0, 20)
	self.controls.pointDisplay = new("Control", {"LEFT",self.anchorTopBarRight,"RIGHT"}, -12, 0, 0, 20)
	self.controls.pointDisplay.x = function(control)
		local width, height = control:GetSize()
		if self.controls.saveAs:GetPos() + self.controls.saveAs:GetSize() < self.anchorTopBarRight:GetPos() - width - 16 then
			return -12 - width
		else
			return 0
		end
	end
	self.controls.pointDisplay.width = function(control)
		local PointsUsed, AscUsed = self.spec:CountAllocNodes()
		local bandit = self.calcsTab.mainOutput.ExtraPoints or 0 
		local usedMax, ascMax, levelreq, currentAct, banditStr, labSuggest = 99 + 22 + bandit, 8, 1, 1, "", ""
		local acts = { 
			[1] = { level = 1, questPoints = 0 }, 
			[2] = { level = 12, questPoints = 2 }, 
			[3] = { level = 22, questPoints = 3 + bandit }, 
			[4] = { level = 32, questPoints = 5 + bandit },
			[5] = { level = 40, questPoints = 6 + bandit },
			[6] = { level = 44, questPoints = 8 + bandit },
			[7] = { level = 50, questPoints = 11 + bandit },
			[8] = { level = 54, questPoints = 14 + bandit },
			[9] = { level = 60, questPoints = 17 + bandit },
			[10] = { level = 64, questPoints = 19 + bandit },
			[11] = { level = 67, questPoints = 22 + bandit }
		}
				
		-- loop for how much quest skillpoints are used with the progress
		while currentAct < 11 and PointsUsed + 1 - acts[currentAct].questPoints > acts[currentAct + 1].level do
			currentAct = currentAct + 1
		end

		-- bandits notification; when considered and in calculation after act 2
		if currentAct <= 2 and bandit ~= 0 then
			bandit = 0
		end
		
		-- to prevent a negative level at a blank sheet the level requirement will be set dependent on points invested until catched up with quest skillpoints 
		levelreq = math.max(PointsUsed - acts[currentAct].questPoints + 1, acts[currentAct].level)
		
		-- Ascendency points for lab
		-- this is a recommendation for beginners who are using Path of Building for the first time and trying to map out progress in PoB
		local labstr = {"\n帝王试炼迷宫 : 帝王迷宫", "\n帝王试炼迷宫: 残酷帝王迷宫", "\n帝王试炼迷宫: 无情帝王迷宫", "\n帝王试炼迷宫: 终极帝王迷宫"}
		local strAct = "终章"
		if levelreq >= 33 and levelreq < 55 then labSuggest = labstr[1]
		elseif levelreq >= 55 and levelreq < 68 then labSuggest = labstr[2]
		elseif levelreq >= 68 and levelreq < 75 then labSuggest = labstr[3]
		elseif levelreq >= 75 and levelreq < 90 then labSuggest = labstr[4]
		elseif levelreq < 90 and currentAct <= 10 then strAct = currentAct end
		
		control.str = string.format("%s%3d / %3d   %s%d / %d", PointsUsed > usedMax and "^1" or "^7", PointsUsed, usedMax, AscUsed > ascMax and "^1" or "^7", AscUsed, ascMax)
		control.req = "需求等级: ".. levelreq .. "\n预估进度:\n章节: ".. strAct .. "\n任务点数: " .. acts[currentAct].questPoints - bandit .. "\n盗贼任务: " .. bandit .. labSuggest
		
		return DrawStringWidth(16, "FIXED", control.str) + 8
	end
	self.controls.pointDisplay.Draw = function(control)
		local x, y = control:GetPos()
		local width, height = control:GetSize()
		SetDrawColor(1, 1, 1)
		DrawImage(nil, x, y, width, height)
		SetDrawColor(0, 0, 0)
		DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
		SetDrawColor(1, 1, 1)
		DrawString(x + 4, y + 2, "LEFT", 16, "FIXED", control.str)
		if control:IsMouseInBounds() then
			SetDrawLayer(nil, 10)
			miscTooltip:Clear()
			miscTooltip:AddLine(16, control.req)
			miscTooltip:Draw(x, y, width, height, main.viewPort)
			SetDrawLayer(nil, 0)
		end
	end
self.controls.characterLevel = new("EditControl", {"LEFT",self.controls.pointDisplay,"RIGHT"}, 12, 0, 106, 20, "", "等级", "%D", 3, function(buf)
		self.characterLevel = m_min(tonumber(buf) or 1, 100)
		self.modFlag = true
		self.buildFlag = true
	end)
	
	self.controls.characterLevel:SetText(tostring(self.characterLevel))
	self.controls.characterLevel.tooltipFunc = function(tooltip)
		if tooltip:CheckForUpdate(self.characterLevel) then
			tooltip:AddLine(16, "经验加成:")
			local playerLevel = self.characterLevel
			local safeZone = 3 + m_floor(playerLevel / 16)
			for level, expLevel in ipairs(self.data.monsterExperienceLevelMap) do
				local diff = m_abs(playerLevel - expLevel) - safeZone
				local mult
				if diff <= 0 then
					mult = 1
				else
					mult = ((playerLevel + 5) / (playerLevel + 5 + diff ^ 2.5)) ^ 1.5
				end
				if playerLevel >= 95 then
					mult = mult * (1 / (1 + 0.1 * (playerLevel - 94)))
				end
				if mult > 0.01 then
					local line = level
					if level >= 68 then 
						line = line .. string.format(" (Tier %d)", level - 67)
					end
					line = line .. string.format(": %.1f%%", mult * 100)
					tooltip:AddLine(14, line)
				end
			end
		end
	end
	self.controls.classDrop = new("DropDownControl", {"LEFT",self.controls.characterLevel,"RIGHT"}, 8, 0, 100, 20, nil, function(index, value)
		if value.classId ~= self.spec.curClassId then
			if self.spec:CountAllocNodes() == 0 or self.spec:IsClassConnected(value.classId) then
				self.spec:SelectClass(value.classId)
				self.spec:AddUndoState()
				self.spec:SetWindowTitleWithBuildClass()
				self.buildFlag = true
			else
main:OpenConfirmPopup("职业更改", "更改职业为 "..value.label.." 将会重置你目前的天赋树.\n你可以考虑连接当前的天赋点到 "..value.label.."\n这样出门点就不会被重置了。", "继续", function()
					self.spec:SelectClass(value.classId)
					self.spec:AddUndoState()
					self.spec:SetWindowTitleWithBuildClass()
					self.buildFlag = true					
				end)
			end
		end
	end)
	self.controls.ascendDrop = new("DropDownControl", {"LEFT",self.controls.classDrop,"RIGHT"}, 8, 0, 120, 20, nil, function(index, value)
		self.spec:SelectAscendClass(value.ascendClassId)
		self.spec:AddUndoState()
		self.spec:SetWindowTitleWithBuildClass()
		self.buildFlag = true
	end)

	-- List of display stats
	-- This defines the stats in the side bar, and also which stats show in node/item comparisons
	-- This may be user-customisable in the future
	self.displayStats = {
	
	{ stat = "ActiveMinionLimit", label = "召唤生物数量", fmt = "d" },
		{ stat = "AverageHit", label = "平均击中", fmt = ".1f", compPercent = true },
		{ stat = "AverageDamage", label = "平均伤害", fmt = ".1f", compPercent = true, flag = "attack" },
		
		{ stat = "Speed", label = "攻击速率", fmt = ".2f", compPercent = true, flag = "attack", condFunc = function(v,o) return v > 0 and (o.TriggerTime or 0) == 0 end },
		{ stat = "Speed", label = "施法速率", fmt = ".2f", compPercent = true, flag = "spell", condFunc = function(v,o) return v > 0 and (o.TriggerTime or 0) == 0 end },
		
		{ stat = "ServerTriggerRate", label = "触发速率", fmt = ".2f", compPercent = true, condFunc = function(v,o) return (o.TriggerTime or 0) ~= 0 end },
		{ stat = "Speed", label = "有效触发速率", fmt = ".2f", compPercent = true, condFunc = function(v,o) return (o.TriggerTime or 0) ~= 0 and o.ServerTriggerRate ~= o.Speed end },
		{ stat = "WarcryCastTime", label = "施放时间", fmt = ".2fs", compPercent = true, lowerIsBetter = true, flag = "warcry" },
		{ stat = "HitSpeed", label = "击中速率", fmt = ".2f", compPercent = true, condFunc = function(v,o) return not o.TriggerTime end },
		{ stat = "TrapThrowingTime", label = "陷阱投掷时间", fmt = ".2fs", compPercent = true, lowerIsBetter = true, },
		{ stat = "TrapCooldown", label = "陷阱冷却时间", fmt = ".2fs", lowerIsBetter = true },
		{ stat = "MineLayingTime", label = "地雷放置时间", fmt = ".2fs", compPercent = true, lowerIsBetter = true, },
		{ stat = "TotemPlacementTime", label = "图腾放置时间", fmt = ".2fs", compPercent = true, lowerIsBetter = true, },
		{ stat = "PreEffectiveCritChance", label = "暴击几率", fmt = ".2f%%" },
		{ stat = "CritChance", label = "有效暴击几率", fmt = ".2f%%", condFunc = function(v,o) return v ~= o.PreEffectiveCritChance end },
		{ stat = "CritMultiplier", label = "暴击伤害加成", fmt = "d%%", pc = true, condFunc = function(v,o) return (o.CritChance or 0) > 0 end },
		{ stat = "HitChance", label = "命中率", fmt = ".0f%%", flag = "attack" },
		{ stat = "TotalDPS", label = "总 DPS", fmt = ".1f", compPercent = true, flag = "notAverage" },
		{ stat = "TotalDPS", label = "总 DPS", fmt = ".1f", compPercent = true, flag = "showAverage", condFunc = function(v,o) return (o.TriggerTime or 0) ~= 0 end },
		{ stat = "TotalDot", label = "持续伤害 DPS", fmt = ".1f", compPercent = true },
		{ stat = "WithDotDPS", label = "总 DPS（包含持续伤害）", fmt = ".1f", compPercent = true, flag = "notAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.PoisonDPS or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
		{ stat = "BleedDPS", label = "流血 DPS", fmt = ".1f", compPercent = true },
		{ stat = "BleedDamage", label = "总伤害（每个流血）", fmt = ".1f", compPercent = true, flag = "showAverage" },
		{ stat = "WithBleedDPS", label = "总 DPS（包含流血伤害）", fmt = ".1f", compPercent = true, flag = "notAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.IgniteDPS or 0) == 0 end },
		{ stat = "IgniteDPS", label = "点燃 DPS", fmt = ".1f", compPercent = true },
		{ stat = "IgniteDamage", label = "总伤害（每个点燃）", fmt = ".1f", compPercent = true, flag = "showAverage" },
		{ stat = "WithIgniteDPS", label = "总 DPS（包含点燃伤害）", fmt = ".1f", compPercent = true, flag = "notAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
		{ stat = "WithIgniteAverageDamage", label = "平均伤害（包含点燃伤害）", fmt = ".1f", compPercent = true },
		{ stat = "PoisonDPS", label = "中毒 DPS", fmt = ".1f", compPercent = true },
		{ stat = "PoisonDamage", label = "总伤害（每个中毒）", fmt = ".1f", compPercent = true },
		{ stat = "WithPoisonDPS", label = "总 DPS（包含中毒伤害）", fmt = ".1f", compPercent = true, flag = "poison", flag = "notAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
		{ stat = "DecayDPS", label = "腐化 DPS", fmt = ".1f", compPercent = true },
		{ stat = "TotalDotDPS", label = "总持续伤害 DPS", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDot and v ~= o.ImpaleDPS and v ~= o.TotalPoisonDPS and v ~= (o.TotalIgniteDPS or o.IgniteDPS) and v ~= o.BleedDPS end }, 
		{ stat = "ImpaleDPS", label = "穿刺伤害", fmt = ".1f", compPercent = true, flag = "impale", flag = "showAverage" },
		{ stat = "WithImpaleDPS", label = "平均伤害（包含穿刺伤害）", fmt = ".1f", compPercent = true, flag = "impale", flag = "showAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end  },
		{ stat = "ImpaleDPS", label = "穿刺 DPS", fmt = ".1f", compPercent = true, flag = "impale", flag = "notAverage" },
		{ stat = "WithImpaleDPS", label = "总 DPS（包含穿刺伤害）", fmt = ".1f", compPercent = true, flag = "impale", flag = "notAverage", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
		{ stat = "MirageDPS", label = "总 幻影 DPS", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "CullingDPS", label = "终结 DPS", fmt = ".1f", compPercent = true, condFunc = function(v,o) return o.CullingDPS or 0 > 0 end },
		{ stat = "CombinedDPS", label = "合计 DPS", fmt = ".1f", compPercent = true, flag = "notAverage", condFunc = function(v,o) return v ~= ((o.TotalDPS or 0) + (o.TotalDot or 0)) and v ~= o.WithImpaleDPS and v ~= o.WithPoisonDPS and v ~= o.WithIgniteDPS and v ~= o.WithBleedDPS end },
		{ stat = "CombinedAvg", label = "合计 总伤害", fmt = ".1f", compPercent = true, flag = "showAverage", condFunc = function(v,o) return (v ~= o.AverageDamage and (o.TotalDot or 0) == 0) and (v ~= o.WithImpaleDPS or v ~= o.WithPoisonDPS or v ~= o.WithIgniteDPS or v ~= o.WithBleedDPS) end },
		{ stat = "Cooldown", label = "技能冷却时间", fmt = ".2fs", lowerIsBetter = true },
		{ stat = "AreaOfEffectRadius", label = "范围半径", fmt = "d" },
		{ stat = "BrandTicks", label = "烙印激活频率", fmt = "d", flag = "brand" },
		{ stat = "ManaCost", label = "魔力消耗", fmt = "d", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "LifeCost", label = "生命消耗", fmt = "d", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "ESCost", label = "能量护盾消耗", fmt = "d", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "RageCost", label = "怒火消耗", fmt = "d", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "ManaPercentCost", label = "魔力消耗", fmt = "d%%", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
		{ stat = "LifePercentCost", label = "生命消耗", fmt = "d%%", compPercent = true, lowerIsBetter = true, condFunc = function(v,o) return v > 0 end },
	
		
		{ },
		{ stat = "Str", label = "力量", color = colorCodes.STRENGTH, fmt = "d" },
		{ stat = "ReqStr", label = "力量需求", color = colorCodes.STRENGTH, fmt = "d", lowerIsBetter = true, condFunc = function(v,o) return v > o.Str end },
		{ stat = "Dex", label = "敏捷", color = colorCodes.DEXTERITY, fmt = "d" },
		{ stat = "ReqDex", label = "敏捷需求", color = colorCodes.DEXTERITY, fmt = "d", lowerIsBetter = true, condFunc = function(v,o) return v > o.Dex end },
		{ stat = "Int", label = "智慧", color = colorCodes.INTELLIGENCE, fmt = "d" },
		{ stat = "ReqInt", label = "智慧需求", color = colorCodes.INTELLIGENCE, fmt = "d", lowerIsBetter = true, condFunc = function(v,o) return v > o.Int end },
		{ },
		{ stat = "Devotion", label = "奉献", color = colorCodes.RARE, fmt = "d" },
		{ },
		{ stat = "Life", label = "总 生命", fmt = "d", compPercent = true },
		{ stat = "Spec:LifeInc", label = "天赋树·生命提高", fmt = "d%%", condFunc = function(v,o) return v > 0 and o.Life > 1 end },
		{ stat = "LifeUnreserved", label = "未保留生命", fmt = "d", condFunc = function(v,o) return v < o.Life end, compPercent = true },
		{ stat = "LifeUnreservedPercent", label = "未保留生命百分比", fmt = "d%%", condFunc = function(v,o) return v < 100 end },
		{ stat = "LifeRegen", label = "生命回复", fmt = ".1f" },
		{ stat = "LifeLeechGainRate", label = "生命偷取/击中回复速率", fmt = ".1f", compPercent = true },
		{ stat = "LifeLeechGainPerHit", label = "每次击中生命偷取/击中回复", fmt = ".1f", compPercent = true },
		{ },
		{ stat = "Mana", label = "总魔力", fmt = "d", compPercent = true },
		{ stat = "Spec:ManaInc", label = "天赋树·魔力提高", fmt = "d%%" },
		{ stat = "ManaUnreserved", label = "未保留魔力", fmt = "d", condFunc = function(v,o) return v < o.Mana end, compPercent = true },
		{ stat = "ManaUnreservedPercent", label = "未保留魔力百分比", fmt = "d%%", condFunc = function(v,o) return v < 100 end },
		{ stat = "ManaRegen", label = "魔力回复", fmt = ".1f" },
		{ stat = "ManaLeechGainRate", label = "魔力偷取/击中回复速率", fmt = ".1f", compPercent = true },
		{ stat = "ManaLeechGainPerHit", label = "每次击中魔力偷取/击中回复", fmt = ".1f", compPercent = true },
		{ },
		{ stat = "TotalDegen", label = "总消减回复", fmt = ".1f", lowerIsBetter = true },
		{ stat = "TotalNetRegen", label = "总降低回复", fmt = "+.1f" },
		{ stat = "NetLifeRegen", label = "消减生命回复", fmt = "+.1f" },
		{ stat = "NetManaRegen", label = "消减魔力回复", fmt = "+.1f" },
		{ stat = "NetEnergyShieldRegen", label = "消减魔力回复", fmt = "+.1f" },
		{ },
		{ stat = "Ward", label = "结界", color = colorCodes.WARD, fmt = "d", compPercent = true },
		{ stat = "EnergyShield", label = "能量护盾", fmt = "d", compPercent = true },
		{ stat = "EnergyShieldRecoveryCap", label = "可回复的能量护盾", fmt = "d", condFunc = function(v,o) return v ~= nil end },
		{ stat = "Spec:EnergyShieldInc", label = "天赋树·能量护盾提高", fmt = "d%%" },
		{ stat = "EnergyShieldRegen", label = "能量护盾回复", fmt = ".1f" },
		{ stat = "EnergyShieldLeechGainRate", label = "能量护盾偷取/击中回复速率", fmt = ".1f", compPercent = true },
		{ stat = "EnergyShieldLeechGainPerHit", label = "每次击中能量护盾偷取/击中回复", fmt = ".1f", compPercent = true },


		{ },		
		{ stat = "Evasion", label = "闪避值", fmt = "d", compPercent = true },
		{ stat = "Spec:EvasionInc", label = "天赋树·闪避值提高", fmt = "d%%" },
		{ stat = "MeleeEvadeChance", label = "闪避几率", fmt = "d%%", condFunc = function(v,o) return v > 0 and o.MeleeEvadeChance == o.ProjectileEvadeChance end },
		{ stat = "MeleeEvadeChance", label = "近战闪避几率", fmt = "d%%", condFunc = function(v,o) return v > 0 and o.MeleeEvadeChance ~= o.ProjectileEvadeChance end },
		{ stat = "ProjectileEvadeChance", label = "投射物闪避几率", fmt = "d%%", condFunc = function(v,o) return v > 0 and o.MeleeEvadeChance ~= o.ProjectileEvadeChance end },
		{ },
		{ stat = "Armour", label = "护甲", fmt = "d", compPercent = true },
		{ stat = "Spec:ArmourInc", label = "天赋树·护甲提高", fmt = "d%%" },
		{ stat = "PhysicalDamageReduction", label = "物理伤害减伤", fmt = "d%%", condFunc = function() return true end },
		{ },
		{ stat = "EffectiveMovementSpeedMod", label = "移动速度加成", fmt = "+d%%", mod = true, condFunc = function() return true end },
		{ stat = "BlockChance", label = "攻击格挡几率", fmt = "d%%", overCapStat = "BlockChanceOverCap" },
		{ stat = "SpellBlockChance", label = "法术格挡几率", fmt = "d%%", overCapStat = "SpellBlockChanceOverCap" },
		{ stat = "AttackDodgeChance", label = "攻击躲避几率", fmt = "d%%", overCapStat = "AttackDodgeChanceOverCap" },
		{ stat = "SpellDodgeChance", label = "法术躲避几率", fmt = "d%%", overCapStat = "SpellDodgeChanceOverCap" },
		{ stat = "SpellSuppressionChance", label = "法术伤害压制率", fmt = "d%%", overCapStat = "SpellSuppressionChanceOverCap" },
		{ },
		{ stat = "FireResist", label = "火焰抗性", fmt = "d%%", color = colorCodes.FIRE, condFunc = function() return true end, overCapStat = "FireResistOverCap"},
		{ stat = "FireResistOverCap", label = "火焰抗性溢出", fmt = "d%%", hideStat = true },
		{ stat = "ColdResist", label = "冰霜抗性", fmt = "d%%", color = colorCodes.COLD, condFunc = function() return true end, overCapStat = "ColdResistOverCap" },
		{ stat = "ColdResistOverCap", label = "冰霜抗性溢出", fmt = "d%%", hideStat = true },
		{ stat = "LightningResist", label = "闪电抗性", fmt = "d%%", color = colorCodes.LIGHTNING, condFunc = function() return true end, overCapStat = "LightningResistOverCap" },
		{ stat = "LightningResistOverCap", label = "闪电抗性溢出", fmt = "d%%", hideStat = true },
		{ stat = "ChaosResist", label = "混沌抗性", fmt = "d%%", color = colorCodes.CHAOS, condFunc = function(v,o) return not o.ChaosInoculation end, overCapStat = "ChaosResistOverCap" },
		{ stat = "ChaosResistOverCap", label = "混沌抗性溢出", fmt = "d%%", hideStat = true },
		{ },
		{ stat = "FullDPS", label = "综合所有 DPS", fmt = ".1f", color = colorCodes.CURRENCY, compPercent = true },
		{ },
		{ stat = "SkillDPS", label = "技能 DPS", condFunc = function() return true end },
	 

	}
	self.minionDisplayStats = {
{ stat = "AverageDamage", label = "平均伤害", fmt = ".1f", compPercent = true },
{ stat = "Speed", label = "攻击/施法速度", fmt = ".2f", compPercent = true },
{ stat = "PreEffectiveCritChance", label = "暴击几率", fmt = ".2f%%" },
{ stat = "CritChance", label = "有效暴击几率", fmt = ".2f%%", condFunc = function(v,o) return v ~= o.PreEffectiveCritChance end },
{ stat = "CritMultiplier", label = "暴击伤害加成", fmt = "d%%", pc = true, condFunc = function(v,o) return (o.CritChance or 0) > 0 end },
{ stat = "HitSpeed", label = "击中速率", fmt = ".2f" },
{ stat = "TotalDPS", label = "总 DPS", fmt = ".1f", compPercent = true },
{ stat = "TotalDot", label = "持续伤害 DPS", fmt = ".1f", compPercent = true },
{ stat = "WithDotDPS", label = "总DPS（包含持续伤害）",   fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDPS and (o.PoisonDPS or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
{ stat = "BleedDPS", label = "流血 DPS", fmt = ".1f", compPercent = true },
{ stat = "WithBleedDPS", label = "总DPS（包含流血伤害", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.IgniteDPS or 0) == 0 end },
{ stat = "IgniteDPS", label = "点燃 DPS", fmt = ".1f", compPercent = true },
{ stat = "WithIgniteDPS", label = "总DPS（包含点燃伤害）", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
{ stat = "PoisonDPS", label = "中毒 DPS", fmt = ".1f", compPercent = true },
{ stat = "PoisonDamage", label = "每个中毒总伤害", fmt = ".1f", compPercent = true },
{ stat = "WithPoisonDPS", label = "总DPS（包含中毒伤害）", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.ImpaleDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
{ stat = "DecayDPS", label = "腐化 DPS", fmt = ".1f", compPercent = true },
{ stat = "TotalDotDPS", label = "总持续伤害 DPS", fmt = ".1f", compPercent = true, condFunc = function(v,o) return v ~= o.TotalDot and v ~= o.ImpaleDPS and v ~= o.TotalPoisonDPS and v ~= (o.TotalIgniteDPS or o.IgniteDPS) and v ~= o.BleedDPS end },
{ stat = "ImpaleDPS", label = "穿刺 DPS", fmt = ".1f", compPercent = true, flag = "impale" },
{ stat = "WithImpaleDPS", label = "总DPS（包含穿刺伤害）", fmt = ".1f", compPercent = true, flag = "impale", condFunc = function(v,o) return v ~= o.TotalDPS and (o.TotalDot or 0) == 0 and (o.IgniteDPS or 0) == 0 and (o.PoisonDPS or 0) == 0 and (o.BleedDPS or 0) == 0 end },
	
{ stat = "Cooldown", label = "技能冷却", fmt = ".2fs", lowerIsBetter = true },
{ stat = "Life", label = "总生命", fmt = ".1f", compPercent = true },
{ stat = "LifeRegen", label = "生命回复", fmt = ".1f" },
{ stat = "LifeLeechGainRate", label = "生命偷取/击中回复速率", fmt = ".1f", compPercent = true },
{ stat = "EnergyShield", label = "能量护盾", fmt = "d", compPercent = true },
{ stat = "EnergyShieldRegen", label = "能量护盾回复", fmt = ".1f" },
{ stat = "EnergyShieldLeechGainRate", label = "能量护盾偷取/击中回复速率", fmt = ".1f", compPercent = true },
	}
	self.extraSaveStats = {
		"PowerCharges",
		"PowerChargesMax",
		"FrenzyCharges",
		"FrenzyChargesMax",
		"EnduranceCharges",
		"EnduranceChargesMax",
		"ActiveTotemLimit",
		"ActiveMinionLimit",
	}
 

	if buildName == "~~temp~~" then
		-- Remove temporary build file
		os.remove(self.dbFileName)
		self.buildName = "Unnamed build"
		self.dbFileName = false
		self.dbFileSubPath = nil
		self.modFlag = true
	end

	-- Controls: Side bar
	self.anchorSideBar = new("Control", nil, 4, 36, 0, 0)
self.controls.modeImport = new("ButtonControl", {"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 0, 72, 20,"导入/导出", function()
		self.viewMode = "IMPORT"
	end)
	self.controls.modeImport.locked = function() return self.viewMode == "IMPORT" end
--self.controls.modeNotes = new("ButtonControl", {"LEFT",self.controls.modeImport,"RIGHT"}, 4, 0, 58, 20, "BD备注", function()
self.controls.modeNotes =new("ButtonControl", {"LEFT",self.controls.modeImport,"RIGHT"},  4, 0, 72, 20, "BD备注", function()
	
		self.viewMode = "NOTES"
	end)
	self.controls.modeNotes.locked = function() return self.viewMode == "NOTES" end
--self.controls.modeConfig = new("ButtonControl", {"TOPRIGHT",self.anchorSideBar,"TOPLEFT"}, 300, 0, 100, 20, "配置", function()
self.controls.modeConfig = new("ButtonControl", {"TOPRIGHT",self.anchorSideBar,"TOPLEFT"}, 225, 0, 72, 20, "配置", function()


		self.viewMode = "CONFIG"
	end)
	
	-- lucifer
self.controls.aboutTab = new("ButtonControl",  {"TOPRIGHT",self.anchorSideBar,"TOPLEFT"}, 300, 0, 72, 20, "国服版", function()
		self.viewMode = "ABOUT"
	end)
	self.controls.aboutTab.locked = function() return self.viewMode == "ABOUT" end
	--
	self.controls.modeConfig.locked = function() return self.viewMode == "CONFIG" end
self.controls.modeTree = new("ButtonControl",{"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 26, 72, 20, "天赋树", function()
		self.viewMode = "TREE"
	end)
	self.controls.modeTree.locked = function() return self.viewMode == "TREE" end
self.controls.modeSkills = new("ButtonControl",{"LEFT",self.controls.modeTree,"RIGHT"}, 4, 0, 72, 20, "技能组", function()
		self.viewMode = "SKILLS"
	end)
	self.controls.modeSkills.locked = function() return self.viewMode == "SKILLS" end
self.controls.modeItems =new("ButtonControl", {"LEFT",self.controls.modeSkills,"RIGHT"}, 4, 0, 72, 20, "装备物品", function()
		self.viewMode = "ITEMS"
	end)
	self.controls.modeItems.locked = function() return self.viewMode == "ITEMS" end
self.controls.modeCalcs = new("ButtonControl", {"LEFT",self.controls.modeItems,"RIGHT"}, 4, 0, 72, 20, "计算", function()
		self.viewMode = "CALCS"
	end)
	self.controls.modeCalcs.locked = function() return self.viewMode == "CALCS" end
	
	self.controls.bandit = new("DropDownControl", {"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 70, 300, 16, fooBanditDropList, function(index, value)
			self.bandit = value.banditId
			self.modFlag = true
			self.buildFlag = true
		end)
self.controls.banditLabel = new("LabelControl", {"BOTTOMLEFT",self.controls.bandit,"TOPLEFT"}, 0, 0, 0, 14, "^7盗贼:")

-- The Pantheon
	local function applyPantheonDescription(tooltip, mode, index, value)
		tooltip:Clear()
		if value.id == "None" then
			return
		end
		local applyModes = { BODY = true, HOVER = true }
		if applyModes[mode] then
			local god = self.data.pantheons[value.id]
			for _, soul in ipairs(god.souls) do
				local name = soul.name
				local lines = { }
				for _, mod in ipairs(soul.mods) do
					t_insert(lines, mod.line)
				end
				tooltip:AddLine(20, '^8'..name)
				tooltip:AddLine(14, '^6'..table.concat(lines, '\n'))
				tooltip:AddSeparator(10)
			end
		end
	end
	self.controls.pantheonMajorGod = new("DropDownControl", {"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 110, 300, 16, PantheonMajorGodDropList, function(index, value)
		self.pantheonMajorGod = value.id
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.pantheonMajorGod.tooltipFunc = applyPantheonDescription
	self.controls.pantheonMinorGod = new("DropDownControl", {"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 130, 300, 16, PantheonMinorGodDropList, function(index, value)
		self.pantheonMinorGod = value.id
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.pantheonMinorGod.tooltipFunc = applyPantheonDescription
	self.controls.pantheonLabel = new("LabelControl", {"BOTTOMLEFT",self.controls.pantheonMajorGod,"TOPLEFT"}, 0, 0, 0, 14, "^7万神殿 :")
	
self.controls.mainSkillLabel = new("LabelControl", {"TOPLEFT",self.anchorSideBar,"TOPLEFT"}, 0, 155, 300, 16, "^7主要技能：")
	self.controls.mainSocketGroup = new("DropDownControl", {"TOPLEFT",self.controls.mainSkillLabel,"BOTTOMLEFT"},  0, 2, 300, 16, nil, function(index, value)
		self.mainSocketGroup = index
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.mainSocketGroup.tooltipFunc = function(tooltip, mode, index, value)
		local socketGroup = self.skillsTab.socketGroupList[index]
		if socketGroup and tooltip:CheckForUpdate(socketGroup, self.outputRevision) then
			self.skillsTab:AddSocketGroupTooltip(tooltip, socketGroup)
		end
	end
	self.controls.mainSkill = new("DropDownControl", {"TOPLEFT",self.controls.mainSocketGroup,"BOTTOMLEFT"}, 0, 2, 300, 16, nil, function(index, value)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		mainSocketGroup.mainActiveSkill = index
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.mainSkillPart = new("DropDownControl", {"TOPLEFT",self.controls.mainSkill,"BOTTOMLEFT",true}, 0, 2, 200, 18, nil, function(index, value)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		local srcInstance = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.srcInstance
		srcInstance.skillPart = index
		self.modFlag = true
		self.buildFlag = true
	end)
self.controls.mainSkillStageCountLabel = new("LabelControl", {"TOPLEFT",self.controls.mainSkillPart,"BOTTOMLEFT",true}, 0, 3, 0, 16, "^7层数:") {
		shown = function()
			return self.controls.mainSkillStageCount:IsShown()
		end,
	}
	self.controls.mainSkillStageCount = new("EditControl", {"LEFT",self.controls.mainSkillStageCountLabel,"RIGHT",true}, 2, 0, 60, 18, nil, nil, "%D", nil, function(buf)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		local srcInstance = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.srcInstance
		srcInstance.skillStageCount = tonumber(buf)
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.mainSkillMineCountLabel = new("LabelControl", {"TOPLEFT",self.controls.mainSkillStageCountLabel,"BOTTOMLEFT",true}, 0, 3, 0, 16, "^7激活的地雷:") {
		shown = function()
			return self.controls.mainSkillMineCount:IsShown()
		end,
	}
	self.controls.mainSkillMineCount = new("EditControl", {"LEFT",self.controls.mainSkillMineCountLabel,"RIGHT",true}, 2, 0, 60, 18, nil, nil, "%D", nil, function(buf)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		local srcInstance = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.srcInstance
		srcInstance.skillMineCount = tonumber(buf)
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.mainSkillMinion = new("DropDownControl", {"TOPLEFT",self.controls.mainSkillMineCountLabel,"BOTTOMLEFT",true}, 0, 3, 178, 18, nil, function(index, value)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		local srcInstance = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.srcInstance
		if value.itemSetId then
			srcInstance.skillMinionItemSet = value.itemSetId
		else
			srcInstance.skillMinion = value.minionId
		end
		self.modFlag = true
		self.buildFlag = true
	end)
	function self.controls.mainSkillMinion.CanReceiveDrag(control, type, value)
		if type == "Item" and control.list[control.selIndex] and control.list[control.selIndex].itemSetId then
			local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
			local minionUses = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.grantedEffect.minionUses
			return minionUses and minionUses[value:GetPrimarySlot()] -- O_O
		end
	end
	function self.controls.mainSkillMinion.ReceiveDrag(control, type, value, source)
		self.itemsTab:EquipItemInSet(value, control.list[control.selIndex].itemSetId)
	end
	function self.controls.mainSkillMinion.tooltipFunc(tooltip, mode, index, value)
		tooltip:Clear()
		if value.itemSetId then
			self.itemsTab:AddItemSetTooltip(tooltip, self.itemsTab.itemSets[value.itemSetId])
			tooltip:AddSeparator(14)
tooltip:AddLine(14, colorCodes.TIP.."提示: 你可以拖放装备到这里来装备到召唤物身上.")
		end
	end
self.controls.mainSkillMinionLibrary = new("ButtonControl", {"LEFT",self.controls.mainSkillMinion,"RIGHT"}, 2, 0, 120, 18, "灵体管理...", function()
		self:OpenSpectreLibrary()
	end)
	self.controls.mainSkillMinionSkill = new("DropDownControl", {"TOPLEFT",self.controls.mainSkillMinion,"BOTTOMLEFT",true}, 0, 2, 200, 16, nil, function(index, value)
		local mainSocketGroup = self.skillsTab.socketGroupList[self.mainSocketGroup]
		local srcInstance = mainSocketGroup.displaySkillList[mainSocketGroup.mainActiveSkill].activeEffect.srcInstance
		srcInstance.skillMinionSkill = index
		self.modFlag = true
		self.buildFlag = true
	end)
	self.controls.statBoxAnchor = new("Control", {"TOPLEFT",self.controls.mainSkillMinionSkill,"BOTTOMLEFT",true}, 0, 2, 0, 0)
	self.controls.statBox = new("TextListControl", {"TOPLEFT",self.controls.statBoxAnchor,"BOTTOMLEFT"}, 0, 2, 300, 0, {{x=170,align="RIGHT_X"},{x=174,align="LEFT"}})
	self.controls.statBox.height = function(control)
		local x, y = control:GetPos()
		return main.screenH - main.mainBarHeight - 4 - y
	end

	-- Initialise build components
	self.latestTree = main.tree[latestTreeVersion]
	data.setJewelRadiiGlobally(latestTreeVersion)
	self.data = data
	self.importTab = new("ImportTab", self)
	self.notesTab = new("NotesTab", self)
	self.configTab = new("ConfigTab", self)
	self.itemsTab = new("ItemsTab", self)
	self.treeTab = new("TreeTab", self)
	self.skillsTab = new("SkillsTab", self)
	self.calcsTab = new("CalcsTab", self)
self.aboutTab = new("AboutTab", self)--lucifer
	-- Load sections from the build file
	self.savers = {
		["Config"] = self.configTab,
		["Notes"] = self.notesTab,
		["Tree"] = self.treeTab,
		["TreeView"] = self.treeTab.viewer,
		["Items"] = self.itemsTab,
		["Skills"] = self.skillsTab,
		["Calcs"] = self.calcsTab,
		["Import"] = self.importTab,
			["AboutTab"]=self.aboutTab ,--
	}
	self.legacyLoaders = { -- Special loaders for legacy sections
		["Spec"] = self.treeTab,
	}
	-- so we ran into problems with converted trees, trying to check passive tree routes and also consider thread jewels
	-- but we cant check jewel info because items have not been loaded yet, and they come after passives in the xml.
	-- the simplest solution seems to be making sure passive trees (which contain jewel sockets) are loaded last.
	local deferredPassiveTrees = { }
	for _, node in ipairs(self.xmlSectionList) do
		-- Check if there is a saver that can load this section
		local saver = self.savers[node.elem] or self.legacyLoaders[node.elem]
		if saver then
			-- if the saver is treetab, defer it until everything is is loaded
			if saver == self.treeTab  then
				t_insert( deferredPassiveTrees, node )
			else
				if saver:Load(node, self.dbFileName) then
					self:CloseBuild()
					return
				end
			end
		end
	end
	for _, node in ipairs(deferredPassiveTrees) do
		-- Check if there is a saver that can load this section
		if self.treeTab:Load(node, self.dbFileName) then
			self:CloseBuild()
			return
		end
	end
	for _, saver in pairs(self.savers) do
		if saver.PostLoad then
			saver:PostLoad()
		end
	end

	if next(self.configTab.input) == nil then
		-- Check for old calcs tab settings
		self.configTab:ImportCalcSettings()
	end
	
	-- Initialise class dropdown
	for classId, class in pairs(self.latestTree.classes) do
		local ascendancies = {}
		-- Initialise ascendancy dropdown
		for i = 0, #class.classes do
			local ascendClass = class.classes[i]
			t_insert(ascendancies, {
				label = ascendClass.name,
				ascendClassId = i,
			})
		end
		t_insert(self.controls.classDrop.list, {
			label = class.name,
			classId = classId,
			ascendencies = ascendancies,
		})
	end
	table.sort(self.controls.classDrop.list, function(a, b) return a.label < b.label end)

	-- Build calculation output tables
	self.outputRevision = 1
	self.calcsTab:BuildOutput()
	self:RefreshStatList()
	self.buildFlag = false

	--[[
	local testTooltip = new("Tooltip")
	for _, item in pairs(main.uniqueDB.list) do
		ConPrintf("%s", item.name)
		self.itemsTab:AddItemTooltip(testTooltip, item)
		testTooltip:Clear()
	end
	for _, item in pairs(main.rareDB.list) do
		ConPrintf("%s", item.name)
		self.itemsTab:AddItemTooltip(testTooltip, item)
		testTooltip:Clear()
	end
	--]]

	--[[
	local start = GetTime()
	SetProfiling(true)
	for i = 1, 10  do
		self.calcsTab:PowerBuilder()
	end
	SetProfiling(false)
	ConPrintf("Power build time: %d msec", GetTime() - start)
	--]]

	self.abortSave = false
end

function buildMode:CanExit(mode)
	if not self.unsaved then
		return true
	end
	self:OpenSavePopup(mode)
	return false
end

function buildMode:Shutdown()
	if launch.devMode and self.targetVersion and not self.abortSave then
		if self.dbFileName then
			self:SaveDBFile()
		elseif self.unsaved then		
			self.dbFileName = main.buildPath.."~~temp~~.xml"
			self.buildName = "~~temp~~"
			self.dbFileSubPath = ""
			self:SaveDBFile()
		end
	end
	self.abortSave = nil

	self.savers = nil
end

function buildMode:GetArgs()
	return self.dbFileName, self.buildName
end

function buildMode:CloseBuild()
	main:SetWindowTitleSubtext()
	main:SetMode("LIST", self.dbFileName and self.buildName, self.dbFileSubPath)
end

function buildMode:Load(xml, fileName)
	self.targetVersion = xml.attrib.targetVersion or legacyTargetVersion
	if xml.attrib.viewMode then
		self.viewMode = xml.attrib.viewMode
	end
	self.characterLevel = tonumber(xml.attrib.level) or 1
	
	for _, diff in pairs({"bandit", "pantheonMajorGod", "pantheonMinorGod"}) do
		self[diff] = xml.attrib[diff] or "None"
	end
	self.mainSocketGroup = tonumber(xml.attrib.mainSkillIndex) or tonumber(xml.attrib.mainSocketGroup) or 1
	wipeTable(self.spectreList)
	for _, child in ipairs(xml) do
		if child.elem == "Spectre" then
			if child.attrib.id and data.minions[child.attrib.id] then
				t_insert(self.spectreList, child.attrib.id)
			end
		end
	end
end

function buildMode:Save(xml)
	xml.attrib = {
		targetVersion = self.targetVersion,
		viewMode = self.viewMode,
		level = tostring(self.characterLevel),
		className = self.spec.curClassName,
		ascendClassName = self.spec.curAscendClassName,
		bandit = self.bandit,		
		pantheonMajorGod = self.pantheonMajorGod,
		pantheonMinorGod = self.pantheonMinorGod,
		mainSocketGroup = tostring(self.mainSocketGroup),
	}
	for _, id in ipairs(self.spectreList) do
		t_insert(xml, { elem = "Spectre", attrib = { id = id } })
	end
	for index, statData in ipairs(self.displayStats) do
		if statData.stat then
			local statVal = self.calcsTab.mainOutput[statData.stat]
			if statVal then
				t_insert(xml, { elem = "PlayerStat", attrib = { stat = statData.stat, value = tostring(statVal) } })
			end
		end
	end
	for index, stat in ipairs(self.extraSaveStats) do
		local statVal = self.calcsTab.mainOutput[stat]
		if statVal then
			t_insert(xml, { elem = "PlayerStat", attrib = { stat = stat, value = tostring(statVal) } })
		end
	end
	if self.calcsTab.mainEnv.minion then
		for index, statData in ipairs(self.minionDisplayStats) do
			if statData.stat then
				local statVal = self.calcsTab.mainOutput.Minion[statData.stat]
				if statVal then
					t_insert(xml, { elem = "MinionStat", attrib = { stat = statData.stat, value = tostring(statVal) } })
				end
			end
		end
	end
	self.modFlag = false
end

function buildMode:OnFrame(inputEvents)
-- Stop at drawing the background if the loaded build needs to be converted
	if not self.targetVersion then
		main:DrawBackground(main.viewPort)
		return
	end

	if self.abortSave and not launch.devMode then
		self:CloseBuild()
	end

	for id, event in ipairs(inputEvents) do
		if event.type == "KeyDown" then
			if event.key == "MOUSE4" then
				if self.unsaved then
					self:OpenSavePopup("LIST")
				else
					self:CloseBuild()
				end
		elseif IsKeyDown("CTRL") then
				if event.key == "s" then
					self:SaveDBFile()
					inputEvents[id] = nil
				elseif event.key == "w" then
					if self.unsaved then
						self:OpenSavePopup("LIST")
					else
						self:CloseBuild()
					end
				elseif event.key == "1" then
					self.viewMode = "TREE"
				elseif event.key == "2" then
					self.viewMode = "SKILLS"
				elseif event.key == "3" then
					self.viewMode = "ITEMS"
				elseif event.key == "4" then
					self.viewMode = "CALCS"
				elseif event.key == "5" then
					self.viewMode = "CONFIG"
				end
			end
		end
	end
	self:ProcessControlsInput(inputEvents, main.viewPort)	

	self.controls.classDrop:SelByValue(self.spec.curClassId, "classId")
	self.controls.ascendDrop.list = self.controls.classDrop:GetSelValue("ascendencies")
	self.controls.ascendDrop:SelByValue(self.spec.curAscendClassId, "ascendClassId")

	for _, diff in pairs({"bandit", "pantheonMajorGod", "pantheonMinorGod"}) do
		if self.controls[diff] then
			self.controls[diff]:SelByValue(self[diff], "id")
		end
	end
	local checkFabricatedGroups = self.buildFlag
	if self.buildFlag then
		-- Wipe Global Cache
		wipeGlobalCache()

		-- Rebuild calculation output tables
		self.outputRevision = self.outputRevision + 1
		self.buildFlag = false
		self.calcsTab:BuildOutput()
		self:RefreshStatList()
	end
	if main.showThousandsSeparators ~= self.lastShowThousandsSeparators then
		self:RefreshStatList()
	end
	if main.thousandsSeparator ~= self.lastShowThousandsSeparator then
		self:RefreshStatList()
	end
	if main.decimalSeparator ~= self.lastShowDecimalSeparator then
		self:RefreshStatList()
	end
	if main.showTitlebarName ~= self.lastShowTitlebarName then
		self.spec:SetWindowTitleWithBuildClass()
	end

	-- Update contents of main skill dropdowns
	self:RefreshSkillSelectControls(self.controls, self.mainSocketGroup, "")
	-- Delete any possible fabricated groups
	if checkFabricatedGroups then
		deleteFabricatedGroup(self.skillsTab)
		checkFabricatedGroups = false
	end
	-- Draw contents of current tab
	local sideBarWidth = 312
	local tabViewPort = {
		x = sideBarWidth,
		y = 32,
		width = main.screenW - sideBarWidth,
		height = main.screenH - 32
	}
	if self.viewMode == "IMPORT" then
		self.importTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "NOTES" then
		self.notesTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "CONFIG" then
		self.configTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "TREE" then
		self.treeTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "SKILLS" then
		self.skillsTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "ITEMS" then
		self.itemsTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "CALCS" then
		self.calcsTab:Draw(tabViewPort, inputEvents)
	elseif self.viewMode == "ABOUT" then
		self.aboutTab:Draw(tabViewPort, inputEvents)
	end

	self.unsaved = self.modFlag or self.notesTab.modFlag or self.configTab.modFlag or self.treeTab.modFlag or self.spec.modFlag or self.skillsTab.modFlag or self.itemsTab.modFlag or self.calcsTab.modFlag

	SetDrawLayer(5)

	-- Draw top bar background
	SetDrawColor(0.2, 0.2, 0.2)
	DrawImage(nil, 0, 0, main.screenW, 28)
	SetDrawColor(0.85, 0.85, 0.85)
	DrawImage(nil, 0, 28, main.screenW, 4)
	DrawImage(nil, main.screenW/2 - 2, 0, 4, 28)

	-- Draw side bar background
	SetDrawColor(0.1, 0.1, 0.1)
	DrawImage(nil, 0, 32, sideBarWidth - 4, main.screenH - 32)
	SetDrawColor(0.85, 0.85, 0.85)
	DrawImage(nil, sideBarWidth - 4, 32, 4, main.screenH - 32)

	self:DrawControls(main.viewPort)
end

-- Opens the game version conversion popup
function buildMode:OpenConversionPopup()
	local controls = { }
	local currentVersion = treeVersions[latestTreeVersion].display
	controls.note = new("LabelControl", nil, 0, 20, 0, 16, colorCodes.TIP..[[
信息:^7 你正在尝试加载一个旧版本POB的bd信息，你可以转化为当前版本。
如果想转化为新版本，那么点击转化。
如果想查看旧版本的bd，
可以尝试使用旧版本的pob进行加载。
]])
	controls.label = new("LabelControl", nil, 0, 110, 0, 16, colorCodes.WARNING..[[
提醒:^7 转化为新版会出现有部分无法转化的情况，例如天赋树的变更。
建议先存一份旧版的bd信息在进行转化。
]])
	controls.convert = new("ButtonControl", nil, -80, 170, 180, 20, "转化为 ".. currentVersion, function()
		main:ClosePopup()
		self:Shutdown()
		self:Init(self.dbFileName, self.buildName, nil, true)
	end)
	controls.cancel = new("ButtonControl", nil, 80, 170, 70, 20, "取消", function()
		main:ClosePopup()
		self:CloseBuild()
	end)
	main:OpenPopup(580, 200, "游戏版本", controls, "convert", nil, "cancel")
end


function buildMode:OpenSavePopup(mode)
	local modeDesc = {
		["LIST"] = "现在，",
		["EXIT"] = "退出前,",
		["UPDATE"] = "更新前,",
		
	}
	local controls = { }
controls.label = new("LabelControl", nil, 0, 20, 0, 16, modeDesc[mode].."^7这个Build有修改的地方还没有保存.\n你想要保存它们吗? ")
	controls.save = new("ButtonControl", nil, -90, 70, 80, 20, "Save", function()
		main:ClosePopup()
		self.actionOnSave = mode		
		self:SaveDBFile()		
	end)
controls.noSave = new("ButtonControl", nil, 0, 70, 80, 20, "不保存", function()
		main:ClosePopup()
		if mode == "LIST" then
			self:CloseBuild()
		elseif mode == "EXIT" then
			Exit()
		elseif mode == "UPDATE" then
			launch:ApplyUpdate(launch.updateAvailable)		
		end
	end)
controls.close = new("ButtonControl", nil, 90, 70, 80, 20, "取消", function()
		main:ClosePopup()
	end)
main:OpenPopup(300, 100, "保存修改", controls)
end

function buildMode:OpenSaveAsPopup()
	local newFileName, newBuildName
	local controls = { }
	local function updateBuildName()
		local buf = controls.edit.buf
		newFileName = main.buildPath..controls.folder.subPath..buf..".xml"
		newBuildName = buf
		controls.save.enabled = false
		if buf:match("%S") then
			local out = io.open(newFileName, "r")
			if out then
				out:close()
			else
				controls.save.enabled = true
			end
		end
	end
controls.label = new("LabelControl", nil, 0, 20, 0, 16, "^7Enter new build name:")
	controls.edit = new("EditControl", nil, 0, 40, 450, 20, self.dbFileName and self.buildName, nil, "\\/:%*%?\"<>|%c", 100, function(buf)
		updateBuildName()
	end)
controls.folderLabel = new("LabelControl", {"TOPLEFT",nil,"TOPLEFT"}, 10, 70, 0, 16, "^7文件夹:")
controls.newFolder = new("ButtonControl", {"TOPLEFT",nil,"TOPLEFT"}, 100, 67, 94, 20, "新建文件夹...", function()
		main:OpenNewFolderPopup(main.buildPath..controls.folder.subPath, function(newFolderName)
			if newFolderName then
				controls.folder:OpenFolder(newFolderName)
			end
		end)
	end)
	controls.folder = new("FolderListControl", nil, 0, 115, 450, 100, self.dbFileSubPath, function(subPath)
		updateBuildName()
	end)
controls.save = new("ButtonControl", nil, -45, 225, 80, 20, "保存", function()
		main:ClosePopup()
		self.dbFileName = newFileName
		self.buildName = newBuildName
		self.dbFileSubPath = controls.folder.subPath
		self:SaveDBFile()
	end)
	controls.save.enabled = false
controls.close = new("ButtonControl", nil, 45, 225, 80, 20, "取消", function()
		main:ClosePopup()
		self.actionOnSave = nil
		
	end)
main:OpenPopup(470, 255, self.dbFileName and "另存为" or "保存", controls, "save", "edit", "close")
end

-- Open the spectre library popup
function buildMode:OpenSpectreLibrary()
	local destList = copyTable(self.spectreList)
	local sourceList = { }
	for id in pairs(self.data.spectres) do
		t_insert(sourceList, id)
	end
	table.sort(sourceList, function(a,b) 
		if self.data.minions[a].name == self.data.minions[b].name then
			return a < b
		else
			return self.data.minions[a].name < self.data.minions[b].name
		end
	end)
	local controls = { }
	controls.list = new("MinionListControl", nil, -100, 40, 190, 250, self.data, destList)
	controls.source = new("MinionListControl", nil, 100, 40, 190, 250, self.data, sourceList, controls.list)
	controls.save = new("ButtonControl", nil, -45, 300, 80, 20, "Save", function()
		self.spectreList = destList
		self.modFlag = true
		self.buildFlag = true
		main:ClosePopup()
	end)
controls.cancel = new("ButtonControl", nil, 45, 300, 80, 20, "取消", function()
		main:ClosePopup()
	end)
main:OpenPopup(410, 330, "【灵体列表】", controls)
end

-- Refresh the set of controls used to select main group/skill/minion
function buildMode:RefreshSkillSelectControls(controls, mainGroup, suffix)
	controls.mainSocketGroup.selIndex = mainGroup
	wipeTable(controls.mainSocketGroup.list)
	for i, socketGroup in pairs(self.skillsTab.socketGroupList) do
		controls.mainSocketGroup.list[i] = { val = i, label = socketGroup.displayLabel }
	end
	if #controls.mainSocketGroup.list == 0 then
controls.mainSocketGroup.list[1] = { val = 1, label = "<未添加技能>" }
		controls.mainSkill.shown = false
		controls.mainSkillPart.shown = false
		controls.mainSkillMineCount.shown = false
		controls.mainSkillStageCount.shown = false
		controls.mainSkillMinion.shown = false
		controls.mainSkillMinionSkill.shown = false
	else
		local mainSocketGroup = self.skillsTab.socketGroupList[mainGroup]
		local displaySkillList = mainSocketGroup["displaySkillList"..suffix]
		local mainActiveSkill = mainSocketGroup["mainActiveSkill"..suffix] or 1
		wipeTable(controls.mainSkill.list)
		for i, activeSkill in ipairs(displaySkillList) do
			t_insert(controls.mainSkill.list, { val = i, label = activeSkill.activeEffect.grantedEffect.name })
		end
		controls.mainSkill.enabled = #displaySkillList > 1
		controls.mainSkill.selIndex = mainActiveSkill
		controls.mainSkill.shown = true
		controls.mainSkillPart.shown = false
		controls.mainSkillMineCount.shown = false
		controls.mainSkillStageCount.shown = false
		controls.mainSkillMinion.shown = false
		controls.mainSkillMinionLibrary.shown = false
		controls.mainSkillMinionSkill.shown = false
		if displaySkillList[1] then
			local activeSkill = displaySkillList[mainActiveSkill]
			local activeEffect = activeSkill.activeEffect
			if activeEffect then
				if activeEffect.grantedEffect.parts and #activeEffect.grantedEffect.parts > 1 then
					controls.mainSkillPart.shown = true
					wipeTable(controls.mainSkillPart.list)
					for i, part in ipairs(activeEffect.grantedEffect.parts) do
						t_insert(controls.mainSkillPart.list, { val = i, label = part.name })
					end
					controls.mainSkillPart.selIndex = activeEffect.srcInstance["skillPart"..suffix] or 1
				end
				if activeSkill.skillFlags.mine then
					controls.mainSkillMineCount.shown = true
					controls.mainSkillMineCount.buf = tostring(activeEffect.srcInstance["skillMineCount"..suffix] or "")
				end
				if activeSkill.skillFlags.multiStage then
					controls.mainSkillStageCount.shown = true
					controls.mainSkillStageCount.buf = tostring(activeEffect.srcInstance["skillStageCount"..suffix] or "")
				end
				if not activeSkill.skillFlags.disable and (activeEffect.grantedEffect.minionList or activeSkill.minionList[1]) then
					wipeTable(controls.mainSkillMinion.list)
					if activeEffect.grantedEffect.minionHasItemSet then
						for _, itemSetId in ipairs(self.itemsTab.itemSetOrderList) do
							local itemSet = self.itemsTab.itemSets[itemSetId]
							t_insert(controls.mainSkillMinion.list, {
								label = itemSet.title or "Default Item Set",
								itemSetId = itemSetId,
							})
						end
						controls.mainSkillMinion:SelByValue(activeEffect.srcInstance["skillMinionItemSet"..suffix] or 1, "itemSetId")
					else
						controls.mainSkillMinionLibrary.shown = (activeEffect.grantedEffect.minionList and not activeEffect.grantedEffect.minionList[1])
						for _, minionId in ipairs(activeSkill.minionList) do
							t_insert(controls.mainSkillMinion.list, {
								label = self.data.minions[minionId].name,
								minionId = minionId,
							})
						end
						controls.mainSkillMinion:SelByValue(activeEffect.srcInstance["skillMinion"..suffix] or controls.mainSkillMinion.list[1], "minionId")
					end
					controls.mainSkillMinion.enabled = #controls.mainSkillMinion.list > 1
					controls.mainSkillMinion.shown = true
					wipeTable(controls.mainSkillMinionSkill.list)
					if activeSkill.minion then
						for _, minionSkill in ipairs(activeSkill.minion.activeSkillList) do
							t_insert(controls.mainSkillMinionSkill.list, minionSkill.activeEffect.grantedEffect.name)
						end
						controls.mainSkillMinionSkill.selIndex = activeEffect.srcInstance["skillMinionSkill"..suffix] or 1
						controls.mainSkillMinionSkill.shown = true
						controls.mainSkillMinionSkill.enabled = #controls.mainSkillMinionSkill.list > 1
					else
t_insert(controls.mainSkillMinion.list, "<未选择灵体类型>")
					end
				end
			end
		end
	end
end

function buildMode:FormatStat(statData, statVal, overCapStatVal)
	if type(statVal) == "table" then return "" end
	local val = statVal * ((statData.pc or statData.mod) and 100 or 1) - (statData.mod and 100 or 0)
	local color = (statVal >= 0 and "^7" or statData.chaosInoc and "^8" or colorCodes.NEGATIVE)
	local valStr = s_format("%"..statData.fmt, val)
	valStr:gsub("%.", main.decimalSeparator)
	valStr = color .. formatNumSep(valStr)

	if overCapStatVal and overCapStatVal > 0 then
		valStr = valStr .. "^x808080" .. " (+" .. s_format("%"..statData.fmt, overCapStatVal) .. ")"
	end

	self.lastShowThousandsSeparators = main.showThousandsSeparators
	self.lastShowThousandsSeparator = main.thousandsSeparator
	self.lastShowDecimalSeparator = main.decimalSeparator
	self.lastShowTitlebarName = main.showTitlebarName	
	return valStr
end


-- Add stat list for given actor
function buildMode:AddDisplayStatList(statList, actor)
	local statBoxList = self.controls.statBox.list
	for index, statData in ipairs(statList) do
		if not statData.flag or actor.mainSkill.skillFlags[statData.flag] then
			local labelColor = "^7"
				if statData.color then
					labelColor = statData.color
				end
			if statData.stat then
				local statVal = actor.output[statData.stat]
				if statVal and ((statData.condFunc and statData.condFunc(statVal,actor.output)) or (not statData.condFunc and statVal ~= 0)) then
					local overCapStatVal = actor.output[statData.overCapStat] or nil
					if statData.stat == "SkillDPS" then
						labelColor = colorCodes.CUSTOM
						table.sort(actor.output.SkillDPS, function(a,b) return (a.dps * a.count) > (b.dps * b.count) end)
						for _, skillData in ipairs(actor.output.SkillDPS) do
							local triggerStr = ""
							if skillData.trigger and skillData.trigger ~= "" then
								triggerStr = colorCodes.WARNING.." ("..skillData.trigger..")"..labelColor
							end
							local lhsString = labelColor..skillData.name..triggerStr..":"
							if skillData.count >= 2 then
								lhsString = labelColor..tostring(skillData.count).."x "..skillData.name..triggerStr..":"
							end
							t_insert(statBoxList, {
								height = 16,
								lhsString,
								self:FormatStat({fmt = "1.f"}, skillData.dps * skillData.count, overCapStatVal),
							})
							if skillData.skillPart then
								t_insert(statBoxList, {
									height = 14,
									align = "CENTER_X", x = 140,
									"^8"..skillData.skillPart,
								})
							end
							if skillData.source then
								t_insert(statBoxList, {
									height = 14,
									align = "CENTER_X", x = 140,
									colorCodes.WARNING.."来自 " ..skillData.source,
								})
							end
						end
					elseif not (statData.hideStat) then
						t_insert(statBoxList, {
							height = 16,
							labelColor..statData.label..":",
							self:FormatStat(statData, statVal, overCapStatVal),
						})
					end
				end
			elseif statData.label and statData.condFunc and statData.condFunc(actor.output) then
				t_insert(statBoxList, { 
					height = 16, labelColor..statData.label..":", 
					"^7"..actor.output[statData.labelStat].."%^x808080" .. " (" .. statData.val  .. ")",})
			elseif not statBoxList[#statBoxList] or statBoxList[#statBoxList][1] then
				t_insert(statBoxList, { height = 10 })
			end
		end
	end
end


-- Build list of side bar stats
function buildMode:RefreshStatList()
	local statBoxList = wipeTable(self.controls.statBox.list)
	if self.calcsTab.mainEnv.player.mainSkill.infoMessage then		
		t_insert(statBoxList, { height = 14, align = "CENTER_X", x = 140, colorCodes.CUSTOM .. self.calcsTab.mainEnv.player.mainSkill.infoMessage})
		if self.calcsTab.mainEnv.player.mainSkill.infoMessage2 then
			t_insert(statBoxList, { height = 14, align = "CENTER_X", x = 140, "^8" .. self.calcsTab.mainEnv.player.mainSkill.infoMessage2})
		end
	end
	if self.calcsTab.mainEnv.minion then
t_insert(statBoxList, { height = 18, "^7召唤生物:" })
		self:AddDisplayStatList(self.minionDisplayStats, self.calcsTab.mainEnv.minion)
		t_insert(statBoxList, { height = 10 })
t_insert(statBoxList, { height = 18, "^7玩家:" })
	end
	if self.calcsTab.mainEnv.player.mainSkill.skillFlags.disable then
t_insert(statBoxList, { height = 16, "^7技能不起作用:" })
		t_insert(statBoxList, { height = 14, align = "CENTER_X", x = 140, self.calcsTab.mainEnv.player.mainSkill.disableReason })
	end
	self:AddDisplayStatList(self.displayStats, self.calcsTab.mainEnv.player)
end

function buildMode:CompareStatList(tooltip, statList, actor, baseOutput, compareOutput, header, nodeCount)
	local count = 0
	for _, statData in ipairs(statList) do
		if statData.stat and (not statData.flag or actor.mainSkill.skillFlags[statData.flag]) and statData.stat ~= "SkillDPS" then
			local statVal1 = compareOutput[statData.stat] or 0
			local statVal2 = baseOutput[statData.stat] or 0
			local diff = statVal1 - statVal2
			if statData.stat == "FullDPS" and not GlobalCache.useFullDPS and not self.viewMode == "TREE" then
				diff = 0
			end
			if (diff > 0.001 or diff < -0.001) and (not statData.condFunc or statData.condFunc(statVal1,compareOutput) or statData.condFunc(statVal2,baseOutput)) then
				if count == 0 then
					tooltip:AddLine(14, header)
				end
				local color = ((statData.lowerIsBetter and diff < 0) or (not statData.lowerIsBetter and diff > 0)) and colorCodes.POSITIVE or colorCodes.NEGATIVE
				local val = diff * ((statData.pc or statData.mod) and 100 or 1)
				local valStr = s_format("%+"..statData.fmt, val) -- Can't use self:FormatStat, because it doesn't have %+. Adding that would have complicated a simple function
				valStr = formatNumSep(valStr)
				local line = s_format("%s%s %s", color, valStr, statData.label)
				local pcPerPt = ""
				if statData.compPercent and statVal1 ~= 0 and statVal2 ~= 0 then
					local pc = statVal1 / statVal2 * 100 - 100
					line = line .. s_format(" (%+.1f%%)", pc)
					if nodeCount then
						pcPerPt = s_format(" (%+.1f%%)", pc / nodeCount)
					end
				end
				if nodeCount then
					line = line .. s_format(" ^8[%+"..statData.fmt.."%s 每点]", diff * ((statData.pc or statData.mod) and 100 or 1) / nodeCount, pcPerPt)
				end
				tooltip:AddLine(14, line)
				count = count + 1
			end
		end
	end
	return count
end

-- Compare values of all display stats between the two output tables, and add any changed stats to the tooltip
-- Adds the provided header line before the first stat line, if any are added
-- Returns the number of stat lines added
function buildMode:AddStatComparesToTooltip(tooltip, baseOutput, compareOutput, header, nodeCount)
	local count = 0
	if baseOutput.Minion and compareOutput.Minion then
		count = count + self:CompareStatList(tooltip, self.minionDisplayStats, self.calcsTab.mainEnv.minion, baseOutput.Minion, compareOutput.Minion, header.."\n^7召唤生物:", nodeCount)
		if count > 0 then
			header = "^7玩家:"
		else
			header = header.."\n^7玩家:"
		end	 
	end
	count = count + self:CompareStatList(tooltip, self.displayStats, self.calcsTab.mainEnv.player, baseOutput, compareOutput, header, nodeCount)
	return count
end

-- Add requirements to tooltip
do
	local req = { }
	function buildMode:AddRequirementsToTooltip(tooltip, level, str, dex, int, strBase, dexBase, intBase)
		if level and level > 0 then
t_insert(req, s_format("^x7F7F7FLevel %s%d", main:StatColor(level, nil, self.characterLevel), level))
		end		
		if str and (str >= 14 or str > self.calcsTab.mainOutput.Str) then
t_insert(req, s_format("%s%d ^x7F7F7F力量", main:StatColor(str, strBase, self.calcsTab.mainOutput.Str), str))
		end
		if dex and (dex >= 14 or dex > self.calcsTab.mainOutput.Dex) then
t_insert(req, s_format("%s%d ^x7F7F7F敏捷", main:StatColor(dex, dexBase, self.calcsTab.mainOutput.Dex), dex))
		end
		if int and (int >= 14 or int > self.calcsTab.mainOutput.Int) then
t_insert(req, s_format("%s%d ^x7F7F7F智慧", main:StatColor(int, intBase, self.calcsTab.mainOutput.Int), int))
		end
		if req[1] then
tooltip:AddLine(16, "^x7F7F7F需求 "..table.concat(req, "^x7F7F7F, "))
			tooltip:AddSeparator(10)
		end	
		wipeTable(req)
	end
end

function buildMode:LoadDB(xmlText, fileName)
	-- Parse the XML
	local dbXML, errMsg = common.xml.ParseXML(xmlText)
	if not dbXML then
launch:ShowErrMsg("^1加载错误 '%s': %s", fileName, errMsg)
		return true
	elseif dbXML[1].elem ~= "PathOfBuilding" then
launch:ShowErrMsg("^1解析错误 '%s': 'PathOfBuilding' 节点不存在", fileName)
		return true
	end

	-- Load Build section first
	for _, node in ipairs(dbXML[1]) do
		if type(node) == "table" and node.elem == "Build" then
			self:Load(node, self.dbFileName)
			break
		end
	end

	-- Store other sections for later processing
	for _, node in ipairs(dbXML[1]) do
		if type(node) == "table" then
			t_insert(self.xmlSectionList, node)
		end
	end
end

function buildMode:LoadDBFile()
	if not self.dbFileName then
		return
	end
	ConPrintf("Loading '%s'...", self.dbFileName)
	local file = io.open(self.dbFileName, "r")
	if not file then
		self.dbFileName = nil
		return true
	end
	local xmlText = file:read("*a")
	file:close()
	return self:LoadDB(xmlText, self.dbFileName)
end

function buildMode:SaveDB(fileName)
	local dbXML = { elem = "PathOfBuilding" }

	-- Save Build section first
	do
		local node = { elem = "Build" }
		self:Save(node)
		t_insert(dbXML, node)
	end

	-- Call on all savers to save their data in their respective sections
	for elem, saver in pairs(self.savers) do
		local node = { elem = elem }
		saver:Save(node)
		t_insert(dbXML, node)
	end

	-- Compose the XML
	local xmlText, errMsg = common.xml.ComposeXML(dbXML)
	if not xmlText then
		launch:ShowErrMsg("Error saving '%s': %s", fileName, errMsg)
	else
		return xmlText
	end
end

function buildMode:SaveDBFile()
	if not self.dbFileName then
		self:OpenSaveAsPopup()
		return
	end
	
	local xmlText = self:SaveDB(self.dbFileName)
	if not xmlText then
		return true
	end
	local file = io.open(self.dbFileName, "w+")
	if not file then
main:OpenMessagePopup("错误", "不能保存当前bd文件:\n"..self.dbFileName.."\n可能是保存目录不存在、不可写、没有权限或者路径带有中文字符.")
		return true
	end
	file:write(xmlText)
	file:close()
	local action = self.actionOnSave
	self.actionOnSave = nil
	if action == "LIST" then
		self:CloseBuild()
	elseif action == "EXIT" then
		Exit()
	elseif action == "UPDATE" then
		launch:ApplyUpdate(launch.updateAvailable)	
	end
end



return buildMode
