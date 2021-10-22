-- Path of Building
--
-- Module: Calcs Tab
-- Calculations breakdown tab for the current build.
--
--local launch, main = ...

local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local t_remove = table.remove
local m_max = math.max
local m_min = math.min
local m_floor = math.floor
local band = bit.band





local buffModeDropList = {
{ label = "无buff", buffMode = "UNBUFFED" },
{ label = "Buff", buffMode = "BUFFED" },
{ label = "战斗模式", buffMode = "COMBAT" },
{ label = "有效 DPS", buffMode = "EFFECTIVE" } 
}

local SkillTypeCNMap = { 

[1] = "攻击", 
[2] = "法术", 
[3] = "投射物", 
[4] = "双持",
[5] = "增益",
[6] = "可双持",
[7] = "仅主手",
[9] = "召唤生物",
[10] = "击中",
[11] = "范围效果",
[12] = "持续时间",
[13] = "需持盾",
[14] = "有投射物伤害",
[15] = "魔力保留",
[16] = "魔力百分比消耗",
[17] = "可陷阱化",
[18] = "可图腾化",
[19] = "可地雷化",
[20] = "可元素异常",
[21] = "可召唤",
[23] = "连锁",
[24] = "近战",
[25] = "单体近战",
[26] = "法术可回响",
[28] = "攻击可重复",
[29] = "造成燃烧",
[30] = "图腾",
[32] = "诅咒",
[33] = "火焰",
[34] = "冰霜",
[35] = "闪电",
[36] = "可触发",
[37] = "陷阱",
[38] = "位移", 
[40] = "持续伤害",
[41] = "地雷",
[42] = "被触发",
[43] = "瓦尔",
[44] = "光环",
[48] = "投射物攻击", 
[50] = "混沌",
[58] = "持续吟唱",
[61] = "装备触发",
[62] = "魔像",
[63] = "捷光环",
[64] = "光环减益",
[67] = "法术可多重范围",
[68] = "可齐射",
[69] = "可幻影射手",
[74] = "战吼",
[75] = "瞬发",
[76] = "烙印",
[77] = "可摧毁灵枢",
[78] = "非击中冰缓",
[79] = "冰缓区域",
[80] = "释放诅咒",
[82] = "持续时间光环",
[83] = "范围法术",
[84] = "物理",
[85] = "瘫痪",
[89] = "创建召唤物",
[90] = "护卫",
[91] = "旅行",
[92] = "闪现",
[93] = "可祝福",
[94] = "新星法术",
 }
 
local CalcsTabClass = newClass("CalcsTab", "UndoHandler", "ControlHost", "Control", function(self, build)
	self.UndoHandler()
	self.ControlHost()
	self.Control()

	self.build = build

	self.calcs = LoadModule("Modules/Calcs")

	self.input = { }
	self.input.skill_number = 1
	self.input.misc_buffMode = "EFFECTIVE"

	self.colWidth = 230
	self.sectionList = { }

	-- Special section for skill/mode selection


self:NewSection(3, "SkillSelect", 1, colorCodes.NORMAL, {{ defaultCollapsed = false, label = "查看技能详情", data = {
		{ label = "技能组", { controlName = "mainSocketGroup", 
			control = new("DropDownControl", nil, 0, 0, 300, 16, nil, function(index, value) 
				self.input.skill_number = index 
				self:AddUndoState()
				self.build.buildFlag = true
			end) {
				tooltipFunc = function(tooltip, mode, index, value)
					local socketGroup = self.build.skillsTab.socketGroupList[index]
					if socketGroup and tooltip:CheckForUpdate(socketGroup, self.build.outputRevision) then
						self.build.skillsTab:AddSocketGroupTooltip(tooltip, socketGroup)
					end
				end
			}
		}, },
{ label = "主动技能", { controlName = "mainSkill", 
			control = new("DropDownControl", nil, 0, 0, 300, 16, nil, function(index, value)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				mainSocketGroup.mainActiveSkillCalcs = index
				self.build.buildFlag = true
			end)
		}, },
{ label = "技能 分段", playerFlag = "multiPart", { controlName = "mainSkillPart", 
			control = new("DropDownControl", nil, 0, 0, 150, 16, nil, function(index, value)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				local srcInstance = mainSocketGroup.displaySkillListCalcs[mainSocketGroup.mainActiveSkillCalcs].activeEffect.srcInstance
				srcInstance.skillPartCalcs = index
				self:AddUndoState()
				self.build.buildFlag = true
			end)
}, },{ label = "技能 层数", playerFlag = "multiStage", { controlName = "mainSkillStageCount",
			control = new("EditControl", nil, 0, 0, 52, 16, nil, nil, "%D", nil, function(buf)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				local srcInstance = mainSocketGroup.displaySkillListCalcs[mainSocketGroup.mainActiveSkillCalcs].activeEffect.srcInstance
				srcInstance.skillStageCountCalcs = tonumber(buf)
				self:AddUndoState()
				self.build.buildFlag = true
			end)
		}, },
{ label = "启用的地雷", playerFlag = "mine", { controlName = "mainSkillMineCount",
			control = new("EditControl", nil, 0, 0, 52, 16, nil, nil, "%D", nil, function(buf)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				local srcInstance = mainSocketGroup.displaySkillListCalcs[mainSocketGroup.mainActiveSkillCalcs].activeEffect.srcInstance
				srcInstance.skillMineCountCalcs = tonumber(buf)
				self:AddUndoState()
				self.build.buildFlag = true
			end)
		}, },
{ label = "显示召唤生物状态", flag = "haveMinion", { controlName = "showMinion", 
			control = new("CheckBoxControl", nil, 0, 0, 18, nil, function(state)
				self.input.showMinion = state
				self:AddUndoState()
end, "显示召唤物计算面板而非玩家的.")
		}, },
{ label = "召唤生物", flag = "minion", { controlName = "mainSkillMinion",
			control = new("DropDownControl", nil, 0, 0, 160, 16, nil, function(index, value)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				local srcInstance = mainSocketGroup.displaySkillListCalcs[mainSocketGroup.mainActiveSkillCalcs].activeEffect.srcInstance
				if value.itemSetId then
					srcInstance.skillMinionItemSetCalcs = value.itemSetId
				else
					srcInstance.skillMinionCalcs = value.minionId
				end
				self:AddUndoState()
				self.build.buildFlag = true
			end){
				tooltipFunc = function(tooltip, mode, index, value)
				
				if self.calcsEnv and self.calcsEnv.minion then 
					local mainMinionData=self.calcsEnv.minion.minionData
						
						if mainMinionData then 
							if tooltip:CheckForUpdate(mainMinionData.name, self.build.outputRevision)  then 
								 tooltip.center = false
								 tooltip.color = colorCodes.UNIQUE
								
								 tooltip:AddLine(20, colorCodes.UNIQUE.. mainMinionData.name.."                        ")
								 tooltip:AddLine(5, colorCodes.UNIQUE.."")
								--[[   
								local cnList= minionModList2CN(mainMinionData.modList)
								
								 
								for _, modcn in ipairs(cnList) do
									if modcn then
									tooltip:AddLine(16, colorCodes.RARE..modcn)
									end
								end
								]]--
									
								 if mainMinionData.modListSP then 
									 for _, modtext in ipairs(mainMinionData.modListSP) do
										if modtext then
										tooltip:AddLine(16, colorCodes.RARE..modtext)
										end
									end
								end
								
								tooltip:AddSeparator(10)
								for _, skillId in ipairs(mainMinionData.skillList) do
									if self.calcsEnv.data.skills[skillId] then
									tooltip:AddLine(16, colorCodes.GEM..self.calcsEnv.data.skills[skillId].name)
									end
								end
								 
								 
								 tooltip:AddSeparator(10)
								 if mainMinionData.damage   then 
									tooltip:AddLine(16, "^x7F7F7F".."伤害："..(mainMinionData.damage*100) .."%")
								 end
								 if mainMinionData.damageSpread    then 
									tooltip:AddLine(16, "^x7F7F7F".."大小伤区间："..mainMinionData.damageSpread*100 .."%")
								 end
								  if mainMinionData.attackTime    then 
									tooltip:AddLine(16, "^x7F7F7F".."基础攻速："..mainMinionData.attackTime)
								 end
								  if mainMinionData.attackRange    then 
									tooltip:AddLine(16, "^x7F7F7F".."基础攻击范围："..mainMinionData.attackRange)
								 end
								  if mainMinionData.accuracy     then 
									tooltip:AddLine(16, "^x7F7F7F".."命中："..mainMinionData.accuracy *100 .."%" )
								 end
								  tooltip:AddSeparator(10)
								 if mainMinionData.life and mainMinionData.life>0 then 
									tooltip:AddLine(16, "^x7F7F7F".."生命："..mainMinionData.life*100 .."%")
								 end
								 if mainMinionData.energyShield and mainMinionData.energyShield>0 then 
									tooltip:AddLine(16, "^x7F7F7F".."能量护盾："..mainMinionData.energyShield*100 .."%")
								 end
								 if mainMinionData.armour and mainMinionData.armour>0 then 
									tooltip:AddLine(16, "^x7F7F7F".."护甲："..mainMinionData.armour*100 .."%")
								 end
								  tooltip:AddSeparator(10)
								 
								 if mainMinionData.fireResist  then 
									tooltip:AddLine(16, "^x7F7F7F".."火焰抗性："..mainMinionData.fireResist .."%")
								 end
								 if mainMinionData.coldResist  then 
									tooltip:AddLine(16, "^x7F7F7F".."冰霜抗性："..mainMinionData.coldResist .."%")
								 end
								 if mainMinionData.lightningResist  then 
									tooltip:AddLine(16, "^x7F7F7F".."闪电抗性："..mainMinionData.lightningResist .."%")
								 end
								 if mainMinionData.chaosResist  then 
									tooltip:AddLine(16, "^x7F7F7F".."混沌抗性："..mainMinionData.chaosResist .."%")
								 end
								
								 
								 
							end
						
						end 
						
				
				end 
					
				end
			}
		} },
{ label = "内置灵体数据", flag = "spectre", { controlName = "mainSkillMinionLibrary",
control = new("ButtonControl", nil, 0, 0, 100, 16, "灵体管理...", function()
				self.build:OpenSpectreLibrary()
			end)
		} },
{ label = "召唤生物技能", flag = "haveMinion", { controlName = "mainSkillMinionSkill",
			control = new("DropDownControl", nil, 0, 0, 200, 16, nil, function(index, value)
				local mainSocketGroup = self.build.skillsTab.socketGroupList[self.input.skill_number]
				local srcInstance = mainSocketGroup.displaySkillListCalcs[mainSocketGroup.mainActiveSkillCalcs].activeEffect.srcInstance				
				srcInstance.skillMinionSkillCalcs = index
				self:AddUndoState()
				self.build.buildFlag = true
			end){
				tooltipFunc = function(tooltip, mode, index, value)
				 
				local mainSkill=self.calcsEnv.minion.mainSkill
					
					 
				
				if mainSkill and mainSkill.skillCfg and  mainSkill.skillCfg.skillGrantedEffect then  
				
					local grantedEffect= mainSkill.skillCfg.skillGrantedEffect
					  
						if grantedEffect and  tooltip:CheckForUpdate(grantedEffect.id, self.build.outputRevision)  then 
						
						
						 tooltip.center = true
						 tooltip.color = colorCodes.GEM
						
						 tooltip:AddLine(20, colorCodes.GEM..grantedEffect.name)
						 tooltip:AddSeparator(10)
						 tooltip:AddLine(16, "^x7F7F7F"..grantedEffect.id)
						 
						 if grantedEffect.skillTypes then 
							local skillTypeText = ''
							for stat, val in pairs(grantedEffect.skillTypes) do
							
								if val and stat and SkillTypeCNMap[stat] then 									 
									skillTypeText = skillTypeText ..SkillTypeCNMap[stat] ..","
								end 
							end
							
							tooltip:AddLine(16, "^x7F7F7F"..skillTypeText)
							tooltip:AddSeparator(10)
						 end
						 
						 local  curSkillLevel=0;
						 local curlevelRequirement=0;
							local curManaCost=0;
							local curCooldown=0;
							local actorLevel=self.calcsEnv.minion.level;
							local curCritChance=0.0;
							local curDamageEffectiveness=0.0;
							local curBaseMultiplier=0.0;
						 tooltip:AddLine(16, "^x7F7F7F".."召唤生物等级: "..actorLevel)
						 
						 if grantedEffect.levels then 
							
							
							 
							for levelitem=1, #grantedEffect.levels do
								 
								if  grantedEffect.levels[levelitem].levelRequirement						 
								then 
									if grantedEffect.levels[levelitem].levelRequirement  > self.calcsEnv.minion.level then
										break;
									else
										curSkillLevel=levelitem
										curlevelRequirement=grantedEffect.levels[levelitem].levelRequirement
										curManaCost=grantedEffect.levels[levelitem].manaCost
										curCooldown=grantedEffect.levels[levelitem].cooldown
										curCritChance=grantedEffect.levels[levelitem].critChance
										curDamageEffectiveness=grantedEffect.levels[levelitem].damageEffectiveness
										curBaseMultiplier=grantedEffect.levels[levelitem].baseMultiplier
										
									end 
								
								end 
							end
							tooltip:AddLine(16, "^x7F7F7F".."技能等级: "..curSkillLevel)
							--tooltip:AddLine(16, "^x7F7F7F".."需求等级: "..curlevelRequirement)
							if curManaCost and  curManaCost >0 then 
								tooltip:AddLine(16, "^x7F7F7F".."魔力消耗: "..curManaCost)
							end 
							if curCooldown and curCooldown >0 then 
								tooltip:AddLine(16, "^x7F7F7F".."冷却时间: "..curCooldown.." 秒")
							end 
							
						 
						 end 
						 if grantedEffect.castTime and grantedEffect.castTime > 0 then
							tooltip:AddLine(16, string.format("^x7F7F7F施放时间: ^7%.2f 秒", grantedEffect.castTime))
						 else
							tooltip:AddLine(16, "^x7F7F7F施放时间: ^7瞬发")
						 end
						 if curCritChance and  curCritChance>0 then 
							tooltip:AddLine(16, "^x7F7F7F".."暴击几率: "..curCritChance.."%")
						 end 
						 if curDamageEffectiveness and curDamageEffectiveness>0 then 
							tooltip:AddLine(16, "^x7F7F7F".."伤害效用: "..curDamageEffectiveness*100 .."%")
						 end 
						 if curBaseMultiplier and curBaseMultiplier>0 then 
							tooltip:AddLine(16, "^x7F7F7F".."基础加成: "..curBaseMultiplier*100 .."%")
						 end 
						 
						 tooltip:AddSeparator(10)
						 tooltip:AddLine(16, "^x7F7F7F需求 Level "..curlevelRequirement)
						 tooltip:AddSeparator(10)
						 if grantedEffect.description then
							local wrap = main:WrapString(grantedEffect.description:gsub("。\n","。"):gsub("。","。\n"), 16, m_max(DrawStringWidth(16, "VAR", grantedEffect.id), 400))
							for _, line in ipairs(wrap) do
								tooltip:AddLine(16, colorCodes.GEM..line)
							end
						end
						if self.build.data.describeStats then
							tooltip:AddSeparator(10)
							local stats =calcLib.buildSkillInstanceStatsOnly(curSkillLevel,actorLevel, grantedEffect) 
							if grantedEffect.levels[curSkillLevel] and grantedEffect.levels[curSkillLevel].baseMultiplier then
								stats["active_skill_attack_damage_final_permyriad"] = (grantedEffect.levels[curSkillLevel].baseMultiplier - 1) * 10000
							end
							local mergeStatsFrom=false
							if mergeStatsFrom then
								for stat, val in pairs(calcLib.buildSkillInstanceStatsOnly(curSkillLevel,actorLevel, mergeStatsFrom)) do
									stats[stat] = (stats[stat] or 0) + val
								end
								
							end
							  
							local descriptions = self.build.data.describeStats(stats, grantedEffect.statDescriptionScope )
							 
							for _, line in ipairs(descriptions) do
								tooltip:AddLine(16, line)
							end
						end
						
			
						 
					end 
				end 
				
				
				
					
				end
			}
		} },
{ label = "计算模式", { 
			controlName = "mode", 
			control = new("DropDownControl", nil, 0, 0, 100, 16, buffModeDropList, function(index, value)  
				self.input.misc_buffMode = value.buffMode 
				self:AddUndoState()
				self.build.buildFlag = true
			end, [[
切换这个来让下面面板显示不同状态下的计算数据。
不管你这里切换的模式，左边侧边栏显示的都是【有效 DPS】模式。

无Buff：没有光环、buff或者其他技能影响的情况下，相当于站在城里的数值。
Buff：光环和buff会生效，相当于你在藏身处的数值。
战斗模式：会计算充能球，猛攻之类的buff，相当于角色在进行战斗的数值。
有效 DPS：还会计算诅咒和敌人状态（比如敌人的抗性和一些特殊状态），这显示了你的真正DPS。]]) 
		}, },
{ label = "光环和Buff技能", flag = "buffs", textSize = 12, { format = "{output:BuffList}", { breakdown = "SkillBuffs" } }, },
{ label = "战斗Buffs", flag = "combat", textSize = 12, { format = "{output:CombatList}" }, },
{ label = "诅咒和Debuff", flag = "effective", textSize = 12, { format = "{output:CurseList}", { breakdown = "SkillDebuffs" } }, },
	}}}, function(section)
		self.build:RefreshSkillSelectControls(section.controls, self.input.skill_number, "Calcs")
		section.controls.showMinion.state = self.input.showMinion
		section.controls.mode:SelByValue(self.input.misc_buffMode, "buffMode")
	end)
	 

	-- Add sections from the CalcSections module
	local sectionData = LoadModule("Modules/CalcSections")
	for _, section in ipairs(sectionData) do
		self:NewSection(unpack(section))
	end

	self.controls.breakdown = new("CalcBreakdownControl", self)

	self.controls.scrollBar = new("ScrollBarControl", {"TOPRIGHT",self,"TOPRIGHT"}, 0, 0, 18, 0, 50, "VERTICAL", true)
end)

function CalcsTabClass:Load(xml, dbFileName)
	for _, node in ipairs(xml) do
		if type(node) == "table" then
			if node.elem == "Input" then
				if not node.attrib.name then
					launch:ShowErrMsg("^1Error parsing '%s': 'Input' element missing name attribute", fileName)
					return true
				end
				if node.attrib.number then
					self.input[node.attrib.name] = tonumber(node.attrib.number)
				elseif node.attrib.string then
					self.input[node.attrib.name] = node.attrib.string
				elseif node.attrib.boolean then
					self.input[node.attrib.name] = node.attrib.boolean == "true"
				else
					launch:ShowErrMsg("^1Error parsing '%s': 'Input' element missing number, string or boolean attribute", fileName)
					return true
				end
			elseif node.elem == "Section" then
				if not node.attrib.id then
					launch:ShowErrMsg("^1Error parsing '%s': 'Section' element missing id attribute", fileName)
					return true
				end
				for _, section in ipairs(self.sectionList) do
					if section.id == node.attrib.id then
						section.collapsed = (node.attrib.collapsed == "true")
						break
					end
				end
			end
		end
	end
	self:ResetUndo()
end

function CalcsTabClass:Save(xml)
	for k, v in pairs(self.input) do
		local child = { elem = "Input", attrib = {name = k} }
		if type(v) == "number" then
			child.attrib.number = tostring(v)
		elseif type(v) == "boolean" then
			child.attrib.boolean = tostring(v)
		else
			child.attrib.string = tostring(v)
		end
		t_insert(xml, child)
	end
	for _, section in ipairs(self.sectionList) do
		t_insert(xml, { elem = "Section", attrib = {
			id = section.id,
			collapsed = tostring(section.collapsed),
		} })
	end
	self.modFlag = false
end
function CalcsTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	-- Arrange the sections
	local baseX = viewPort.x + 4
	local baseY = viewPort.y + 4
	local maxCol = m_floor(viewPort.width / (self.colWidth + 8))
	if main.portraitMode then maxCol = 3 end
	local colY = { }
	local maxY = 0
	for _, section in ipairs(self.sectionList) do
		section:UpdateSize()
		if section.enabled then
			local col
			if section.group == 1 then
				-- Group 1: Offense or 3 wide sections
				-- This group is put into the first 3 columns, with each section placed into the highest available location
				col = 1
				if section.width == self.colWidth then -- if 1 col wide
					local minY = colY[col] or baseY
					for c = 2, 3 do
						if (colY[c] or baseY) < minY then
							col = c
							minY = colY[c] or baseY
						end
					end
				else
					for c = 2, 3 do
						colY[col] = m_max(colY[col] or baseY, colY[c] or baseY)
					end
				end
			elseif section.group == 2 then
				-- Group 2: Defense (the first 4 sections)
				-- This group is put entirely into the 4th column
				if maxCol >= 4 then
					col = 4
				end
			elseif section.group == 3 then
				-- Group 3: Defense (the remaining sections)
				-- This group is put into a 5th column if there's room for one, otherwise they are handled separately
				if maxCol >= 5 then
					col = 5
				end
			end
			if col then
				section.x = baseX + (self.colWidth + 8) * (col - 1)
				section.y = colY[col] or baseY
				for c = col, col + section.widthCols - 1 do
					colY[c] = section.y + section.height + 8
				end
				maxY = m_max(maxY, colY[col])
			end
		end
	end
	if maxCol < 5 then
		-- There's no room for a 5th column
		-- Each section from group 3 will instead be placed into column 4 if there's room, otherwise they'll be put in columns 1-3
		for c = 1, 3 do
			colY[c] = m_max(colY[1], colY[2], colY[3])
		end
		for _, section in ipairs(self.sectionList) do
			if section.enabled and (main.portraitMode and section.group == 2 or section.group == 3) then
				local col = 3
				if colY[col] + section.height + 4 >= m_max(viewPort.y + viewPort.height, maxY) then
					-- No room in the 4th column, find the highest available location in columns 1-4
					local minY = colY[col]
					for c = 3, 1, -1 do
						if colY[c] < minY then
							col = c
							minY = colY[c]
						end
					end
				end
				section.x = baseX + (self.colWidth + 8) * (col - 1)
				section.y = colY[col]
				colY[col] = section.y + section.height + 8
				maxY = m_max(maxY, colY[col])
			end
		end
	end
	self.controls.scrollBar.height = viewPort.height
	self.controls.scrollBar:SetContentDimension(maxY - baseY, viewPort.height)
	for _, section in ipairs(self.sectionList) do
		-- Give sections their actual Y position and let them update
		section.y = section.y - self.controls.scrollBar.offset
		section:UpdatePos()
	end

	for id, event in ipairs(inputEvents) do
		if event.type == "KeyDown" then
			if event.key == "z" and IsKeyDown("CTRL") then
				self:Undo()
				self.build.buildFlag = true
			elseif event.key == "y" and IsKeyDown("CTRL") then
				self:Redo()
				self.build.buildFlag = true
			end
		end
	end
	self:ProcessControlsInput(inputEvents, viewPort)
	for id, event in ipairs(inputEvents) do
		if event.type == "KeyUp" then
			if event.key == "WHEELDOWN" then
				self.controls.scrollBar:Scroll(1)
			elseif event.key == "WHEELUP" then
				self.controls.scrollBar:Scroll(-1)
			end
		end
	end

	main:DrawBackground(viewPort)

	if not self.displayPinned then
		self.displayData = nil
	end

	self:DrawControls(viewPort)

	if self.displayData then
		if self.displayPinned and not self.selControl then
			self:SelectControl(self.controls.breakdown)
		end
	else
		self.controls.breakdown:SetBreakdownData()
	end
end

function CalcsTabClass:NewSection(width, ...)
	local section = new("CalcSectionControl", self, width * self.colWidth + 8 * (width - 1), ...)
	section.widthCols = width
	t_insert(self.controls, section)
	t_insert(self.sectionList, section)
end

function CalcsTabClass:ClearDisplayStat()
	self.displayData = nil
	self.displayPinned = nil
	self.controls.breakdown:SetBreakdownData()
end

function CalcsTabClass:SetDisplayStat(displayData, pin)
	if not displayData or (not pin and self.displayPinned) then
		return
	end
	self.displayData = displayData
	self.displayPinned = pin
	self.controls.breakdown:SetBreakdownData(displayData, pin)
end

function CalcsTabClass:CheckFlag(obj)
	local actor = self.input.showMinion and self.calcsEnv.minion or self.calcsEnv.player
	local skillFlags = actor.mainSkill.skillFlags
	if obj.flag and not skillFlags[obj.flag] then
		return
	end
	if obj.flagList then
		for _, flag in ipairs(obj.flagList) do
			if not skillFlags[flag] then
				return
			end
		end
	end
	if obj.playerFlag and not self.calcsEnv.player.mainSkill.skillFlags[obj.playerFlag] then
		return
	end
	if obj.notFlag and skillFlags[obj.notFlag] then
		return
	end
	if obj.notFlagList then
		for _, flag in ipairs(obj.notFlagList) do
			if skillFlags[flag] then
				return
			end
		end
	end
	if obj.haveOutput then
		local ns, var = obj.haveOutput:match("^(%a+)%.(%a+)$")
		if ns then
			if not actor.output[ns] or not actor.output[ns][var] or actor.output[ns][var] == 0 then
				return
			end
		elseif not actor.output[obj.haveOutput] or actor.output[obj.haveOutput] == 0 then
			return
		end
	end
	return true
end

-- Build the calculation output tables
function CalcsTabClass:BuildOutput()
	self.powerBuildFlag = true

	--[[
	local start = GetTime()
	SetProfiling(true)
	for i = 1, 1000  do
		self.calcs.buildOutput(self.build, "MAIN")
	end
	SetProfiling(false)
	ConPrintf("Calc time: %d msec", GetTime() - start)
	--]]
	
	
	for _, node in pairs(self.build.spec.nodes) do
		-- Set default final mod list for all nodes; some may not be set during the main pass
		node.finalModList = node.modList
	end

	self.mainEnv = self.calcs.buildOutput(self.build, "MAIN")
	self.mainOutput = self.mainEnv.player.output
	self.calcsEnv = self.calcs.buildOutput(self.build, "CALCS")
	self.calcsOutput = self.calcsEnv.player.output

	if self.displayData then
		self.controls.breakdown:SetBreakdownData()
		self.controls.breakdown:SetBreakdownData(self.displayData, self.displayPinned)
	end
	
	-- Retrieve calculator functions
	self.nodeCalculator = { self.calcs.getNodeCalculator(self.build) }
	self.miscCalculator = { self.calcs.getMiscCalculator(self.build) }
end

-- Controls the coroutine that calculations node power
function CalcsTabClass:BuildPower(callbackContext)
	if self.powerBuildFlag then
		self.powerBuildFlag = false
		self.powerBuilderCallback = callbackContext or self.powerBuilderCallback
		self.powerBuilder = coroutine.create(self.PowerBuilder)
	end
	if self.powerBuilder then
		
		local res, errMsg = coroutine.resume(self.powerBuilder, self)
		if launch.devMode and not res then
			error(errMsg)
		end
		if coroutine.status(self.powerBuilder) == "dead" then
			self.powerBuilder = nil
			if self.powerBuilderCallback then
				self.powerBuilderCallback.func(self.powerBuilderCallback.caller)
			end
		end
		
	end
end


-- Estimate the offensive and defensive power of all unallocated nodes
function CalcsTabClass:PowerBuilder()
	--local timer_start = GetTime()
	GlobalCache.useFullDPS = self.powerStat and self.powerStat.stat == "FullDPS" or false
	local calcFunc, calcBase = self:GetMiscCalculator()
	local cache = { }
	local newPowerMax = {
		singleStat = 0,		
		offence = 0,
		offencePerPoint = 0,
		defence = 0,
		defencePerPoint = 0
	}
	if not self.powerMax then
		self.powerMax = newPowerMax
	end
	if coroutine.running() then
		coroutine.yield()
	end
	local start = GetTime()
	for nodeId, node in pairs(self.build.spec.nodes) do
		wipeTable(node.power)
		if not node.alloc and node.modKey ~= "" and not self.mainEnv.grantedPassives[nodeId] then
			if not cache[node.modKey] then
				cache[node.modKey] = calcFunc({ addNodes = { [node] = true } }, { requirementsItems = true, requirementsGems = true, skills = true })
			end
			local output = cache[node.modKey]
			if self.powerStat and self.powerStat.stat and not self.powerStat.ignoreForNodes then
				node.power.singleStat = self:CalculatePowerStat(self.powerStat, output, calcBase)
				if node.path and not node.ascendancyName then
					newPowerMax.singleStat = m_max(newPowerMax.singleStat, node.power.singleStat)
					node.power.pathPower = node.power.singleStat
					local pathNodes = { }
					for _, node in pairs(node.path) do
						pathNodes[node] = true
					end
					if node.pathDist > 1 then
						node.power.pathPower = self:CalculatePowerStat(self.powerStat, calcFunc({ addNodes = pathNodes }, { requirementsItems = true, requirementsGems = true, skills = true }), calcBase)
					end
				end
			else
				if calcBase.Minion then
					node.power.offence = (output.Minion.CombinedDPS - calcBase.Minion.CombinedDPS) / calcBase.Minion.CombinedDPS
				else
					node.power.offence = (output.CombinedDPS - calcBase.CombinedDPS) / calcBase.CombinedDPS
				end
				node.power.defence = (output.LifeUnreserved - calcBase.LifeUnreserved) / m_max(3000, calcBase.Life) +
								(output.Armour - calcBase.Armour) / m_max(10000, calcBase.Armour) +
								((output.EnergyShieldRecoveryCap or output.EnergyShield) - (calcBase.EnergyShieldRecoveryCap or calcBase.EnergyShield)) / m_max(3000, (calcBase.EnergyShieldRecoveryCap or calcBase.EnergyShield)) +								(output.Evasion - calcBase.Evasion) / m_max(10000, calcBase.Evasion) +
								(output.LifeRegen - calcBase.LifeRegen) / 500 +
								(output.EnergyShieldRegen - calcBase.EnergyShieldRegen) / 1000
				if node.path and not node.ascendancyName then
					newPowerMax.offence = m_max(newPowerMax.offence, node.power.offence)
					newPowerMax.defence = m_max(newPowerMax.defence, node.power.defence)
					newPowerMax.offencePerPoint = m_max(newPowerMax.offencePerPoint, node.power.offence / node.pathDist)
					newPowerMax.defencePerPoint = m_max(newPowerMax.defencePerPoint, node.power.defence / node.pathDist)

				end
			end
		elseif node.alloc and node.modKey ~= "" and not self.mainEnv.grantedPassives[nodeId] then
			local output = calcFunc({ removeNodes = { [node] = true } }, { requirementsItems = true, requirementsGems = true, skills = true })
			if self.powerStat and self.powerStat.stat and not self.powerStat.ignoreForNodes then
				node.power.singleStat = self:CalculatePowerStat(self.powerStat, output, calcBase)
				if node.depends and not node.ascendancyName then
					node.power.pathPower = node.power.singleStat
					local pathNodes = { }
					for _, node in pairs(node.depends) do
						pathNodes[node] = true
					end
					if #node.depends > 1 then
						node.power.pathPower = self:CalculatePowerStat(self.powerStat, calcFunc({ removeNodes = pathNodes }, { requirementsItems = true, requirementsGems = true, skills = true }), calcBase)
					end
				end
			end
		end
		if coroutine.running() and GetTime() - start > 100 then
			coroutine.yield()
			start = GetTime()
		end
	end

	-- Calculate the impact of every cluster notable
	-- used for the power report screen
	for nodeName, node in pairs(self.build.spec.tree.clusterNodeMap) do
		if not node.power then
			node.power = {}
		end
		wipeTable(node.power)
		if not node.alloc and node.modKey ~= "" and not self.mainEnv.grantedPassives[nodeId] then
			if not cache[node.modKey] then
				cache[node.modKey] = calcFunc({ addNodes = { [node] = true } }, { requirementsItems = true, requirementsGems = true, skills = true })
			end
			local output = cache[node.modKey]
			if self.powerStat and self.powerStat.stat and not self.powerStat.ignoreForNodes then
				node.power.singleStat = self:CalculatePowerStat(self.powerStat, output, calcBase)
			end
		end
		if coroutine.running() and GetTime() - start > 100 then
			coroutine.yield()
			start = GetTime()
		end
	end
	self.powerMax = newPowerMax
	--ConPrintf("Power Build time: %d ms", GetTime() - timer_start)
end



function CalcsTabClass:CalculatePowerStat(selection, original, modified)
	if modified.Minion then
		original = original.Minion
		modified = modified.Minion
	end
	local originalValue = original[selection.stat] or 0
	local modifiedValue = modified[selection.stat] or 0
	if selection.transform then
		originalValue = selection.transform(originalValue)
		modifiedValue = selection.transform(modifiedValue)
	end
	return originalValue - modifiedValue
end

function CalcsTabClass:GetNodeCalculator()
	return unpack(self.nodeCalculator)
end

function CalcsTabClass:GetMiscCalculator()
	return unpack(self.miscCalculator)
end

function CalcsTabClass:CreateUndoState()
	return copyTable(self.input)
end

function CalcsTabClass:RestoreUndoState(state)
	wipeTable(self.input)
	for k, v in pairs(state) do
		self.input[k] = v
	end
end


