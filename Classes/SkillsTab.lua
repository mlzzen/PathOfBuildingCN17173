-- Path of Building
--
-- Module: Skills Tab
-- Skills tab for the current build.
--
--local launch, main = ...

local pairs = pairs
local ipairs = ipairs
local t_insert = table.insert
local t_remove = table.remove
local m_min = math.min
local m_max = math.max

local groupSlotDropList = {
{ label = "无" },
{ label = "主手", slotName = "Weapon 1" },
{ label = "副手", slotName = "Weapon 2" },
{ label = "第二武器栏主手", slotName = "Weapon 1 Swap" },
{ label = "第二武器栏副手", slotName = "Weapon 2 Swap" },
{ label = "头盔", slotName = "Helmet" },
{ label = "胸甲", slotName = "Body Armour" },
{ label = "手套", slotName = "Gloves" },
{ label = "鞋子", slotName = "Boots" }, 
{ label = "项链", slotName = "Amulet" },
{ label = "戒指 1", slotName = "Ring 1" },
{ label = "戒指 2", slotName = "Ring 2" },
}


local showSupportGemTypeList = {
	{ label = "所有", show = "ALL" },
	{ label = "辅助", show = "NORMAL" },
	{ label = "强辅", show = "AWAKENED" },
}
local sortGemTypeList ={
	{label = "全部 DPS", type = "FullDPS"},
	{label = "包含所有的 DPS", type = "CombinedDPS"},
	{label = "总 DPS", type = "TotalDPS"},
	{label = "平均击中伤害", type = "AverageDamage"},
	{label = "持续伤害 DPS", type = "TotalDot"},
	{label = "流血 DPS", type = "BleedDPS"},
	{label = "点燃 DPS", type = "IgniteDPS"},
	{label = "中毒 DPS", type = "TotalPoisonDPS"},
}
local alternateGemQualityList ={
	{label = "精良的", type = "Default"},
	{label = "异常", type = "Alternate1"},
	{label = "分歧", type = "Alternate2"},
	{label = "魅影", type = "Alternate3"},
}


local SkillsTabClass = newClass("SkillsTab", "UndoHandler", "ControlHost", "Control", function(self, build)
	self.UndoHandler()
	self.ControlHost()
	self.Control()

	self.build = build

	self.socketGroupList = { }

	self.sortGemsByDPS = true
	self.sortGemsByDPSField = "CombinedDPS"
	self.showSupportGemTypes = "ALL"
	self.showAltQualityGems = false

	-- Socket group list
	self.controls.groupList = new("SkillListControl", {"TOPLEFT",self,"TOPLEFT"}, 20, 24, 360, 300, self)
self.controls.groupTip = new("LabelControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, 0, 8, 0, 14, "^7提示: 可以使用 Ctrl+C 和 Ctrl+V 来复制和粘贴技能组.")

	-- Gem options
	local optionInputsX = 204
self.controls.optionSection = new("SectionControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"},  0, 50, 374, 154, "技能选项")
self.controls.sortGemsByDPS = new("CheckBoxControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, 150, 70, 20, "根据 DPS排序:", function(state)
		self.sortGemsByDPS = state
	end)
	self.controls.sortGemsByDPS.state = true
	self.controls.sortGemsByDPSFieldControl = new("DropDownControl", {"LEFT", self.controls.sortGemsByDPS, "RIGHT"}, 10, 0, 120, 20, sortGemTypeList, function(index, value)
		self.sortGemsByDPSField = value.type
	end)
	
	
	self.controls.defaultLevel = new("EditControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, optionInputsX, 94, 60, 20, nil, nil, "%D", 2, function(buf)
		self.defaultGemLevel = m_max(m_min(tonumber(buf) or 20, 21), 1)
	end)
self.controls.defaultLevelLabel = new("LabelControl", {"RIGHT",self.controls.defaultLevel,"LEFT"}, -4, 0, 0, 16, "^7技能默认等级:")
	self.controls.defaultQuality = new("EditControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, optionInputsX, 118, 60, 20, nil, nil, "%D", 2, function(buf)
		self.defaultGemQuality = m_min(tonumber(buf) or 0, 23)
	end)
self.controls.defaultQualityLabel = new("LabelControl", {"RIGHT",self.controls.defaultQuality,"LEFT"}, -4, 0, 0, 16, "^7技能默认品质:")

self.controls.showSupportGemTypes = new("DropDownControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, optionInputsX, 142, 120, 20, showSupportGemTypeList, function(index, value)
		self.showSupportGemTypes = value.show
	end)
	self.controls.showSupportGemTypesLabel = new("LabelControl", {"RIGHT",self.controls.showSupportGemTypes,"LEFT"}, -4, 0, 0, 16, "^7显示辅助技能:")
	
	self.controls.showAltQualityGems = new("CheckBoxControl", {"TOPLEFT",self.controls.groupList,"BOTTOMLEFT"}, optionInputsX, 166, 20, "^7显示技能特殊品质:", function(state)
		self.showAltQualityGems = state
	end)
	-- Socket group details
	if main.portraitMode then
		self.anchorGroupDetail = new("Control", {"TOPLEFT",self.controls.optionSection,"BOTTOMLEFT"}, 0, 20, 0, 0)
	else
		self.anchorGroupDetail = new("Control", {"TOPLEFT",self.controls.groupList,"TOPRIGHT"}, 20, 0, 0, 0)
	end
	self.anchorGroupDetail.shown = function()
		return self.displayGroup ~= nil
	end
	self.controls.groupLabel = new("EditControl", {"TOPLEFT",self.anchorGroupDetail,"TOPLEFT"}, 0, 0, 380, 20, nil, "Label", "%c", 50, function(buf)
		self.displayGroup.label = buf
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
self.controls.groupSlotLabel = new("LabelControl", {"TOPLEFT",self.anchorGroupDetail,"TOPLEFT"}, 0, 30, 0, 16, "^7装备部位:")
	self.controls.groupSlot = new("DropDownControl", {"TOPLEFT",self.anchorGroupDetail,"TOPLEFT"}, 85, 28, 130, 20, groupSlotDropList, function(index, value)
		self.displayGroup.slot = value.slotName
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	self.controls.groupSlot.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if mode == "OUT" or index == 1 then
tooltip:AddLine(16, "选择装备部位来插放这个技能组.")
tooltip:AddLine(16, "这样可以让技能组受到装备上面某些词缀的加成.")
		else
			local slot = self.build.itemsTab.slots[value.slotName]
			local ttItem = self.build.itemsTab.items[slot.selItemId]
			if ttItem then
				self.build.itemsTab:AddItemTooltip(tooltip, ttItem, slot)
			else
tooltip:AddLine(16, "这个部位没有装备.")
			end
		end
	end
	self.controls.groupSlot.enabled = function()
		return self.displayGroup.source == nil
	end
self.controls.groupEnabled = new("CheckBoxControl", {"LEFT",self.controls.groupSlot,"RIGHT"}, 70, 0, 20, "启用:", function(state)
		self.displayGroup.enabled = state
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	
	self.controls.sourceNoteSkillName = new("EditControl", {"TOPLEFT",self.controls.groupSlotLabel,"TOPLEFT"}, 0, 30, 380, 20, "123", "", "%c", 50, function(buf)
		 
	end)
	
	self.controls.sourceNoteSkillName.enabled=false;
	self.controls.sourceNoteSkillName.tooltipFunc = function(tooltip, mode, index, value)
	 
		
	if self.displayGroup and self.displayGroup.gemList[1] then 
			
					
			local gemInstance = self.displayGroup.gemList[1]
			
			
				if gemInstance  and  (gemInstance.grantedEffect or (gemInstance.gemData and gemInstance.gemData.grantedEffect) ) then
				local displayInstance = gemInstance.displayEffect or gemInstance
				local grantedEffect=gemInstance.grantedEffect  or (gemInstance.gemData and gemInstance.gemData.grantedEffect);
				local grantedEffectLevel = grantedEffect.levels[displayInstance.level]
						
						 if tooltip:CheckForUpdate(grantedEffect.id, self.displayGroup)  then 
						
							 tooltip.center = true
							 tooltip.color = colorCodes.GEM
							
							 tooltip:AddLine(20, colorCodes.GEM..grantedEffect.name)
							 tooltip:AddSeparator(10)
							  local  curSkillLevel=gemInstance.level;
						 local curlevelRequirement=0;
							local curManaCost=0;
							local curCooldown=0;
							local actorLevel=self.build.characterLevel;
							local curCritChance=0.0;
							local curDamageEffectiveness=0.0;
							local curBaseMultiplier=0.0;							
							 
							 if grantedEffect.levels and grantedEffect.levels[curSkillLevel] then 							 
							 curlevelRequirement=grantedEffect.levels[curSkillLevel].levelRequirement
							 curManaCost=grantedEffect.levels[curSkillLevel].manaCost
							 curCooldown=grantedEffect.levels[curSkillLevel].cooldown
							 curCritChance=grantedEffect.levels[curSkillLevel].critChance
							 curDamageEffectiveness=grantedEffect.levels[curSkillLevel].damageEffectiveness
							 curBaseMultiplier=grantedEffect.levels[curSkillLevel].baseMultiplier
							 
							tooltip:AddLine(16, "^x7F7F7F".."技能等级: "..curSkillLevel)
							 
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
							 
							
							--local stats =calcLib.buildSkillInstanceStatsOnly(curSkillLevel,actorLevel, grantedEffect) 
							local stats = calcLib.buildSkillInstanceStats(displayInstance, grantedEffect,true)
							if grantedEffectLevel.baseMultiplier then
								stats["active_skill_attack_damage_final_permyriad"] = (grantedEffectLevel.baseMultiplier - 1) * 10000
							end
							
							if mergeStatsFrom then
								for stat, val in pairs(calcLib.buildSkillInstanceStats(displayInstance, mergeStatsFrom,true)) do
									stats[stat] = (stats[stat] or 0) + val
								end
							end
							
							
							local descriptions = self.build.data.describeStats(stats, grantedEffect.statDescriptionScope)
							for _, line in ipairs(descriptions) do
								tooltip:AddLine(16, line)
							end
						end
							 
						 end
				end
			end 
				end
	
	self.controls.sourceNoteSkillName.shown = function()
		return self.displayGroup.source ~= nil
	end
 
	self.controls.includeInFullDPS = new("CheckBoxControl", {"LEFT",self.controls.groupEnabled,"RIGHT"}, 145, 0, 20, "包含在全部 DPS:", function(state)
		self.displayGroup.includeInFullDPS = state
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	self.controls.groupCountLabel = new("LabelControl", {"LEFT",self.controls.includeInFullDPS,"RIGHT"}, 16, 0, 0, 16, "数量:")
	self.controls.groupCountLabel.shown = function()
		return self.displayGroup.source ~= nil
	end
	self.controls.groupCount = new("EditControl", {"LEFT",self.controls.groupCountLabel,"RIGHT"}, 4, 0, 60, 20, nil, nil, "%D", 2, function(buf)
		self.displayGroup.groupCount = tonumber(buf) or 1
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	self.controls.groupCount.shown = function()
		return self.displayGroup.source ~= nil
	end
	self.controls.sourceNote = new("LabelControl", {"TOPLEFT",self.controls.sourceNoteSkillName,"TOPLEFT"}, 0, 50, 0, 16)
	self.controls.sourceNote.shown = function()
		return self.displayGroup.source ~= nil
	end
	self.controls.sourceNote.label = function()
		
		local source = self.displayGroup.sourceItem or (self.displayGroup.sourceNode and { rarity = "NORMAL", name = self.displayGroup.sourceNode.name }) or { rarity = "NORMAL", name = "?" }
		local sourceName = colorCodes[source.rarity]..source.name.."^7"
		
		
		local activeGem = self.displayGroup.gemList[1]
		
		self.controls.sourceNoteSkillName:SetText(activeGem.color..(activeGem.grantedEffect and activeGem.grantedEffect.name or activeGem.nameSpec))
local label = [[^7这个特殊的技能组: ']]..activeGem.color..(activeGem.grantedEffect and activeGem.grantedEffect.name or activeGem.nameSpec)..[[^7'
 是由物品【']]..sourceName..[['】自带的。
你不能手动删除它.但是你可以取消该装备，它就会自动消失]]
		if not self.displayGroup.noSupports then
label = label .. "\n\n" .. [[你不能为这组技能增加辅助技能，
但是其他任意插入这个物品：【 ']]..sourceName..[['】
的辅助技能都会自动辅助这一组.]]
		end
		return label
	end
	-- Scroll bar
	self.controls.scrollBarH = new("ScrollBarControl", nil, 0, 0, 0, 18, 100, "HORIZONTAL", true)

	-- Skill gem slots
	self.anchorGemSlots = new("Control", {"TOPLEFT",self.anchorGroupDetail,"TOPLEFT"}, 0, 28 + 28 + 16, 0, 0)
	self.gemSlots = { }
	self:CreateGemSlot(1)
self.controls.gemNameHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].nameSpec,"TOPLEFT"}, 0, -2, 0, 16, "^7技能名称:")
self.controls.gemLevelHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].level,"TOPLEFT"}, 0, -2, 0, 16, "^7等级:")
self.controls.gemQualityIdHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].qualityId,"TOPLEFT"}, 0, -2, 0, 16, "^7品质类型:")
self.controls.gemQualityHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].quality,"TOPLEFT"}, 0, -2, 0, 16, "^7品质:")
self.controls.gemEnableHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].enabled,"TOPLEFT"}, -16, -2, 0, 16, "^7启用:")
self.controls.gemCountHeader = new("LabelControl", {"BOTTOMLEFT",self.gemSlots[1].count,"TOPLEFT"}, 8, -2, 0, 16, "^7数量:")
end)

-- parse alt qual from existing quality list
function SkillsTabClass:ParseGemAltQuality(gemName, qualityId)
	if qualityId then
		return qualityId
	end if gemName then
		for indx, entry in ipairs(alternateGemQualityList) do
			if gemName:sub(1, #entry.label) == entry.label then
				return entry.type
			end
		end
	end
	return "Default"
end

-- parse real gem name and quality by ommiting the first word if alt qual is set
function SkillsTabClass:GetBaseNameAndQuality(gemTypeLine, quality)
	-- if quality is default or nil check the gem type line if we have alt qual by comparing to the existing list	
	if gemTypeLine and (quality == nil or quality == '' or quality == 'Default') then
		local firstword, otherwords = gemTypeLine:match("(.+) (.+)")
		if firstword and otherwords then
			for _, entry in ipairs(alternateGemQualityList) do
				if firstword == entry.label then
					-- return the gem name minus <altqual> without a leading space and the new resolved type
					if entry.type == nil or entry.type == "" then
						entry.type = "Default"
					end
					return otherwords, entry.type
				end
			end
		end
	end
	-- no alt qual found, return gemTypeLine as is and either existing quality or Default if none is set
    return gemTypeLine, quality or 'Default'
end



function SkillsTabClass:Load(xml, fileName)
	self.defaultGemLevel = tonumber(xml.attrib.defaultGemLevel)
	self.defaultGemQuality = tonumber(xml.attrib.defaultGemQuality)
	self.controls.defaultLevel:SetText(self.defaultGemLevel or "")
	self.controls.defaultQuality:SetText(self.defaultGemQuality or "")
	if xml.attrib.sortGemsByDPS then
		self.sortGemsByDPS = xml.attrib.sortGemsByDPS == "true"
	end
	self.controls.sortGemsByDPS.state = self.sortGemsByDPS
	if xml.attrib.showAltQualityGems then
		self.showAltQualityGems = xml.attrib.showAltQualityGems == "true"
	end
	self.controls.showAltQualityGems.state = self.showAltQualityGems
	self.controls.showSupportGemTypes:SelByValue(xml.attrib.showSupportGemTypes or "ALL", "show")
	self.controls.sortGemsByDPSFieldControl:SelByValue(xml.attrib.sortGemsByDPSField or "CombinedDPS", "type") 
	self.showSupportGemTypes = self.controls.showSupportGemTypes:GetSelValue("show")
	self.sortGemsByDPSField = self.controls.sortGemsByDPSFieldControl:GetSelValue("type")
	for _, node in ipairs(xml) do
		if node.elem == "Skill" then
			local socketGroup = { }
			socketGroup.enabled = node.attrib.active == "true" or node.attrib.enabled == "true"
			socketGroup.includeInFullDPS = node.attrib.includeInFullDPS and node.attrib.includeInFullDPS == "true"
			socketGroup.groupCount = tonumber(node.attrib.groupCount)
			socketGroup.label = node.attrib.label
			socketGroup.slot = node.attrib.slot
			socketGroup.source = node.attrib.source
			socketGroup.mainActiveSkill = tonumber(node.attrib.mainActiveSkill) or 1
			socketGroup.mainActiveSkillCalcs = tonumber(node.attrib.mainActiveSkillCalcs) or 1
			socketGroup.gemList = { }
			for _, child in ipairs(node) do
				local gemInstance = { }
				gemInstance.nameSpec = child.attrib.nameSpec or ""
				if child.attrib.gemId then
					local gemData = self.build.data.gems[child.attrib.gemId]
					if gemData then
						gemInstance.gemId = gemData.id
						gemInstance.skillId = gemData.grantedEffectId
						gemInstance.nameSpec = gemData.nameSpec
					end
				elseif child.attrib.skillId then
					local grantedEffect = self.build.data.skills[child.attrib.skillId]
					if grantedEffect then
						gemInstance.gemId = self.build.data.gemForSkill[grantedEffect]
						gemInstance.skillId = grantedEffect.id
						gemInstance.nameSpec = grantedEffect.name
					end
				end
				gemInstance.level = tonumber(child.attrib.level)
				gemInstance.quality = tonumber(child.attrib.quality)
				local nameSpecOverride, qualityOverrideId = SkillsTabClass:GetBaseNameAndQuality(gemInstance.nameSpec, child.attrib.qualityId)
                gemInstance.nameSpec = nameSpecOverride
                gemInstance.qualityId = qualityOverrideId
 
				if gemInstance.gemData then
					gemInstance.qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
				end
				gemInstance.enabled = not child.attrib.enabled and true or child.attrib.enabled == "true"
				gemInstance.enableGlobal1 = not child.attrib.enableGlobal1 or child.attrib.enableGlobal1 == "true"
				gemInstance.enableGlobal2 = child.attrib.enableGlobal2 == "true"
				gemInstance.count = tonumber(child.attrib.count) or 1
				gemInstance.skillPart = tonumber(child.attrib.skillPart)
				gemInstance.skillPartCalcs = tonumber(child.attrib.skillPartCalcs)
				gemInstance.skillStageCount = tonumber(child.attrib.skillStageCount)
				gemInstance.skillStageCountCalcs = tonumber(child.attrib.skillStageCountCalcs)
				gemInstance.skillMineCount = tonumber(child.attrib.skillMineCount)
				gemInstance.skillMineCountCalcs = tonumber(child.attrib.skillMineCountCalcs)
				gemInstance.skillMinion = child.attrib.skillMinion
				gemInstance.skillMinionCalcs = child.attrib.skillMinionCalcs
				gemInstance.skillMinionItemSet = tonumber(child.attrib.skillMinionItemSet)
				gemInstance.skillMinionItemSetCalcs = tonumber(child.attrib.skillMinionItemSetCalcs)
				gemInstance.skillMinionSkill = tonumber(child.attrib.skillMinionSkill)
				gemInstance.skillMinionSkillCalcs = tonumber(child.attrib.skillMinionSkillCalcs)
				t_insert(socketGroup.gemList, gemInstance)
			end
			if node.attrib.skillPart and socketGroup.gemList[1] then
				socketGroup.gemList[1].skillPart = tonumber(node.attrib.skillPart)
			end
			self:ProcessSocketGroup(socketGroup)
			t_insert(self.socketGroupList, socketGroup)
		end
	end
	self:SetDisplayGroup(self.socketGroupList[1])
	self:ResetUndo()
end

function SkillsTabClass:Save(xml)
	xml.attrib = {
		defaultGemLevel = tostring(self.defaultGemLevel),
		defaultGemQuality = tostring(self.defaultGemQuality),
		sortGemsByDPS = tostring(self.sortGemsByDPS),
		showSupportGemTypes = self.showSupportGemTypes,
		sortGemsByDPSField = self.sortGemsByDPSField,
		showAltQualityGems = tostring(self.showAltQualityGems)
	}
	for _, socketGroup in ipairs(self.socketGroupList) do
		local node = { elem = "Skill", attrib = {
			enabled = tostring(socketGroup.enabled),
			includeInFullDPS = tostring(socketGroup.includeInFullDPS),
			groupCount = tostring(socketGroup.groupCount),
			label = socketGroup.label,
			slot = socketGroup.slot,
			source = socketGroup.source,
			mainActiveSkill = tostring(socketGroup.mainActiveSkill),
			mainActiveSkillCalcs = tostring(socketGroup.mainActiveSkillCalcs),
		} }
		for _, gemInstance in ipairs(socketGroup.gemList) do
			t_insert(node, { elem = "Gem", attrib = {
				nameSpec = gemInstance.nameSpec,
				skillId = gemInstance.skillId,
				gemId = gemInstance.gemId,
				level = tostring(gemInstance.level),
				quality = tostring(gemInstance.quality),
				qualityId = gemInstance.qualityId,
				enabled = tostring(gemInstance.enabled),
				enableGlobal1 = tostring(gemInstance.enableGlobal1),
				enableGlobal2 = tostring(gemInstance.enableGlobal2),
				count = tostring(gemInstance.count),
				skillPart = gemInstance.skillPart and tostring(gemInstance.skillPart),
				skillPartCalcs = gemInstance.skillPartCalcs and tostring(gemInstance.skillPartCalcs),
				skillStageCount = gemInstance.skillStageCount and tostring(gemInstance.skillStageCount),
				skillStageCountCalcs = gemInstance.skillStageCountCalcs and tostring(gemInstance.skillStageCountCalcs),
				skillMineCount = gemInstance.skillMineCount and tostring(gemInstance.skillMineCount),
				skillMineCountCalcs = gemInstance.skillMineCountCalcs and tostring(gemInstance.skillMineCountCalcs),
				skillMinion = gemInstance.skillMinion,
				skillMinionCalcs = gemInstance.skillMinionCalcs,
				skillMinionItemSet = gemInstance.skillMinionItemSet and tostring(gemInstance.skillMinionItemSet),
				skillMinionItemSetCalcs = gemInstance.skillMinionItemSetCalcs and tostring(gemInstance.skillMinionItemSetCalcs),
				skillMinionSkill = gemInstance.skillMinionSkill and tostring(gemInstance.skillMinionSkill),
				skillMinionSkillCalcs = gemInstance.skillMinionSkillCalcs and tostring(gemInstance.skillMinionSkillCalcs),
			} })
		end
		t_insert(xml, node)
	end
	self.modFlag = false
end

function SkillsTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height
	self.controls.scrollBarH.width = viewPort.width
	self.controls.scrollBarH.x = viewPort.x
	self.controls.scrollBarH.y = viewPort.y + viewPort.height - 18

	do
		local maxX = self.controls.gemCountHeader:GetPos() + self.controls.gemCountHeader:GetSize() + 15
		local contentWidth = maxX - self.x
		self.controls.scrollBarH:SetContentDimension(contentWidth, viewPort.width)
	end
	self.x = self.x - self.controls.scrollBarH.offset
	for id, event in ipairs(inputEvents) do
		if event.type == "KeyDown" then
			if event.key == "z" and IsKeyDown("CTRL") then
				self:Undo()
				self.build.buildFlag = true
			elseif event.key == "y" and IsKeyDown("CTRL") then
				self:Redo()
				self.build.buildFlag = true
			elseif event.key == "v" and IsKeyDown("CTRL") then
				self:PasteSocketGroup()
			end
		end
	end
	self:ProcessControlsInput(inputEvents, viewPort)
	for id, event in ipairs(inputEvents) do
		if event.type == "KeyUp" then
			if event.key == "WHEELDOWN" or event.key == "PAGEDOWN" then
				self.controls.scrollBarH:Scroll(1)
			elseif event.key == "WHEELUP" or event.key == "PAGEUP" then
				self.controls.scrollBarH:Scroll(-1)
			end
		end
	end
	main:DrawBackground(viewPort)
	if main.portraitMode then
		self.anchorGroupDetail:SetAnchor("TOPLEFT",self.controls.optionSection,"BOTTOMLEFT", 0, 20)
	else
		self.anchorGroupDetail:SetAnchor("TOPLEFT",self.controls.groupList,"TOPRIGHT", 20, 0)
	end
	self:UpdateGemSlots()

	self:DrawControls(viewPort)
end

function SkillsTabClass:CopySocketGroup(socketGroup)
	local skillText = ""
	if socketGroup.label:match("%S") then
		skillText = skillText .. "Label: "..socketGroup.label.."\r\n"
	end
	if socketGroup.slot then
		skillText = skillText .. "Slot: "..socketGroup.slot.."\r\n"
	end
	for _, gemInstance in ipairs(socketGroup.gemList) do
skillText = skillText .. string.format("@%s %d/%d %s %s %d\r\n", gemInstance.nameSpec, gemInstance.level, gemInstance.quality, gemInstance.qualityId, gemInstance.enabled and "" or "DISABLED", gemInstance.count or 1)
	end
	Copy(skillText)
end

function SkillsTabClass:PasteSocketGroup()
	local skillText = Paste()
	if skillText then
		local newGroup = { label = "", enabled = true, gemList = { } }
		local label = skillText:match("Label: (%C+)")
		if label then
			newGroup.label = label
		end
		local slot = skillText:match("Slot: (%C+)")
		if slot then
			newGroup.slot = slot
		end
for nameSpec, level, quality, qualityId, state, count in skillText:gmatch("@([^\\x00-\\xff]*) (%d+)/(%d+) (%a+%d?) ?(%a*) (%d+)") do			
			t_insert(newGroup.gemList, { nameSpec = nameSpec, level = tonumber(level) or 20, quality = tonumber(quality) or 0, qualityId = qualityId, enabled = state ~= "DISABLED", count = tonumber(count) or 1 })

		end
		if #newGroup.gemList > 0 then
			t_insert(self.socketGroupList, newGroup)
			self.controls.groupList.selIndex = #self.socketGroupList
			self.controls.groupList.selValue = newGroup
			self:SetDisplayGroup(newGroup)
			self:AddUndoState()
			self.build.buildFlag = true
		end
	end
end

-- Create the controls for editing the gem at a given index
function SkillsTabClass:CreateGemSlot(index)
	local slot = { }
	self.gemSlots[index] = slot

	-- Delete gem
	slot.delete = new("ButtonControl", nil, 0, 0, 20, 20, "x", function()
	 
	
		 
	
		t_remove(self.displayGroup.gemList, index)
		for index2 = index, #self.displayGroup.gemList do
			-- Update the other gem slot controls
			local gemInstance = self.displayGroup.gemList[index2]
			self.gemSlots[index2].nameSpec:SetText(gemInstance.nameSpec)
			self.gemSlots[index2].level:SetText(gemInstance.level)
			self.gemSlots[index2].quality:SetText(gemInstance.quality)
			self.gemSlots[index2].qualityId:SelByValue(gemInstance.qualityId, "type")
			self.gemSlots[index2].enabled.state = gemInstance.enabled
			self.gemSlots[index2].count:SetText(gemInstance.count or 1)
		end
	 
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	if index == 1 then
		slot.delete:SetAnchor("TOPLEFT", self.anchorGemSlots, "TOPLEFT", 0, 0)
	else
		local prevSlot = self.gemSlots[index-1]
		slot.delete:SetAnchor("TOPLEFT", prevSlot.delete, "BOTTOMLEFT", 0, function()
			return (prevSlot.enableGlobal1:IsShown() or prevSlot.enableGlobal2:IsShown()) and 24 or 2
		end)
	end
	slot.delete.shown = function()
		return index <= #self.displayGroup.gemList + 1 and self.displayGroup.source == nil
	end
	slot.delete.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	slot.delete.tooltipText = "移除这颗技能石."
	self.controls["gemSlot"..index.."Delete"] = slot.delete

	-- Gem name specification
	slot.nameSpec = new("GemSelectControl", {"LEFT",slot.delete,"RIGHT"}, 2, 0, 300, 20, self, index, function(gemId, addUndo)
		if not self.displayGroup then
			return
		end
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			if not gemId then
				return
			end	
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.level:SetText(gemInstance.level)
			slot.quality:SetText(gemInstance.quality)
			slot.qualityId:SelByValue(gemInstance.qualityId)
			slot.enabled.state = true
			slot.enableGlobal1.state = true
			slot.count:SetText(gemInstance.count)
		elseif gemId == gemInstance.gemId then
			return
		end		
		gemInstance.gemId = gemId
		gemInstance.skillId = nil
		self:ProcessSocketGroup(self.displayGroup)
		-- Gem changed, update the list and default the quality id
		slot.qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
		slot.qualityId:SelByValue("Default", "type")
		slot.level:SetText(tostring(gemInstance.level))
		slot.count:SetText(tostring(gemInstance.count))
		if addUndo then
			self:AddUndoState()
		end
		self.build.buildFlag = true
	end)
	slot.nameSpec:AddToTabGroup(self.controls.groupLabel)
	self.controls["gemSlot"..index.."Name"] = slot.nameSpec

	-- Gem level
	slot.level = new("EditControl", {"LEFT",slot.nameSpec,"RIGHT"}, 2, 0, 60, 20, nil, nil, "%D", 2, function(buf)
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
			slot.quality:SetText(gemInstance.quality)			
			slot.qualityId:SelByValue(gemInstance.qualityId, "type")
			slot.enabled.state = true
			slot.enableGlobal1.state = true
			slot.count:SetText(gemInstance.count)
		end
		gemInstance.level = tonumber(buf) or self.displayGroup.gemList[index].defaultLevel or self.defaultGemLevel or 20	
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.level:AddToTabGroup(self.controls.groupLabel)
	slot.level.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	self.controls["gemSlot"..index.."Level"] = slot.level

-- Gem quality id
	slot.qualityId = new("DropDownControl",  {"LEFT",slot.level,"RIGHT"}, 2, 0, 90, 20, alternateGemQualityList, function(dropDownIndex, value)
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.level:SetText(gemInstance.level)
			slot.enabled.state = true
			slot.enableGlobal1.state = true
			slot.count:SetText(gemInstance.count)
		end
		
		gemInstance.qualityId = value.type
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.qualityId.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	slot.qualityId.tooltipFunc = function(tooltip)
		--Reset the tooltip
		tooltip:Clear()
		--Get the gem instance from the skills
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			return
		end
		local gemData = gemInstance.gemData
		-- Get the hovered quality item
		local hoveredQuality = alternateGemQualityList[slot.qualityId.hoverSel]
		-- gem data may not be initialized yet, or the quality may be nil, which happens when just floating over the dropdown
		if not gemData or not hoveredQuality then
			return
		end
		-- Function for both granted effect and secondary such as vaal
		local addQualityLines = function(qualityList, grantedEffect)
			tooltip:AddLine(18, colorCodes.GEM..grantedEffect.name)
			-- Hardcoded to use 20% quality instead of grabbing from gem
			tooltip:AddLine(16, colorCodes.NORMAL.."+20% 品质时:")
			for k, qual in pairs(qualityList) do
				-- Do the stats one at a time because we're not guaranteed to get the descriptions in the same order we look at them here
				local stats = { }
				-- Modify by the quality of the gem
				stats[qual[1]] = qual[2] * 20
				local descriptions = self.build.data.describeStats(stats, grantedEffect.statDescriptionScope)
				-- line may be nil if the value results in no line due to not being enough quality
				for _, line in ipairs(descriptions) do
					if line then
						-- Check if we have a handler for the mod in the gem's statMap or in the shared stat map for skills
						if grantedEffect.statMap[qual[1]] or self.build.data.skillStatMap[qual[1]] then
							tooltip:AddLine(16, colorCodes.MAGIC..line)
						else
							tooltip:AddLine(16, colorCodes.UNSUPPORTED..line)
						end
					end
				end
			end
		end
		-- Check if there is a quality of this type for the effect
		if gemData and gemData.grantedEffect.qualityStats[hoveredQuality.type] then
			local qualityTable = gemData.grantedEffect.qualityStats[hoveredQuality.type]
			addQualityLines(qualityTable, gemData.grantedEffect)
		end
		if gemData and gemData.secondaryGrantedEffect and gemData.secondaryGrantedEffect.qualityStats[hoveredQuality.type] then
			local qualityTable = gemData.secondaryGrantedEffect.qualityStats[hoveredQuality.type]
			tooltip:AddSeparator(10)
			addQualityLines(qualityTable, gemData.secondaryGrantedEffect)
		end
		-- Add stat comparisons for hovered quality (based on set quality)
		if self.displayGroup.gemList[index] then
			local calcFunc, calcBase = self.build.calcsTab:GetMiscCalculator(self.build)
			if calcFunc then
				local tempQual = self.displayGroup.gemList[index].qualityId
				self.displayGroup.gemList[index].qualityId = hoveredQuality.type
				self:ProcessSocketGroup(self.displayGroup)
				local output = calcFunc({}, {})
				self.displayGroup.gemList[index].qualityId = tempQual
				tooltip:AddSeparator(10)
				self.build:AddStatComparesToTooltip(tooltip, calcBase, output, "^7选择这个技能品质可以让你获得:")
			end
		end
	end
	
	self.controls["gemSlot"..index.."QualityId"] = slot.qualityId


	-- Gem quality
	slot.quality = new("EditControl", {"LEFT",slot.qualityId,"RIGHT"}, 2, 0, 60, 20, nil, nil, "%D", 2, function(buf)
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.level:SetText(gemInstance.level)
			slot.enabled.state = true
			slot.enableGlobal1.state = true
			slot.count:SetText(gemInstance.count)
		end
		gemInstance.quality = tonumber(buf) or self.defaultGemQuality or 0
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.quality:AddToTabGroup(self.controls.groupLabel)
	slot.quality.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	self.controls["gemSlot"..index.."Quality"] = slot.quality

	-- Enable gem
	slot.enabled = new("CheckBoxControl", {"LEFT",slot.quality,"RIGHT"}, 18, 0, 20, nil, function(state)
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.level:SetText(gemInstance.level)
			slot.quality:SetText(gemInstance.quality)
			slot.qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
			slot.qualityId:SelByValue(gemInstance.qualityId, "type")
			slot.enableGlobal1.state = true
			slot.count:SetText(getmInstance.count)
		end
		gemInstance.enabled = state
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.enabled.tooltipFunc = function(tooltip)
		if tooltip:CheckForUpdate(self.build.outputRevision, self.displayGroup) then
			if self.displayGroup.gemList[index] then
				local calcFunc, calcBase = self.build.calcsTab:GetMiscCalculator(self.build)
				if calcFunc then
					self.displayGroup.gemList[index].enabled = not self.displayGroup.gemList[index].enabled
					local storedGlobalCacheDPSView = GlobalCache.useFullDPS
					GlobalCache.useFullDPS = calcBase.FullDPS ~= nil
					local output = calcFunc({}, {})
					GlobalCache.useFullDPS = storedGlobalCacheDPSView
					self.displayGroup.gemList[index].enabled = not self.displayGroup.gemList[index].enabled
self.build:AddStatComparesToTooltip(tooltip, calcBase, output, self.displayGroup.gemList[index].enabled and "^7禁用本技能会给你:" or "^7启用本技能会让你:")
				end
			end
		end
	end
	slot.enabled.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	self.controls["gemSlot"..index.."Enable"] = slot.enabled

-- Count gem
	slot.count = new("EditControl", {"LEFT",slot.enabled,"RIGHT"}, 18, 0, 60, 20, nil, nil, "%D", 2, function(buf)
		local gemInstance = self.displayGroup.gemList[index]
		if not gemInstance then
			gemInstance = { nameSpec = "", level = self.defaultGemLevel or 20, quality = self.defaultGemQuality or 0, qualityId = "Default", enabled = true, enableGlobal1 = true, count = 1, new = true }
			self.displayGroup.gemList[index] = gemInstance
			slot.level:SetText(gemInstance.level)
			slot.qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
			slot.quality:SetText(gemInstance.quality)
			slot.qualityId:SelByValue(gemInstance.qualityId, "type")
			slot.enabled.state = true
			slot.enableGlobal1.state = true
		end
		gemInstance.count = tonumber(buf) or 1
		self:ProcessSocketGroup(self.displayGroup)
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.count.shown = function()
		local gemInstance = self.displayGroup and self.displayGroup.gemList[index]
		if gemInstance then
			local grantedEffectList = gemInstance.gemData and gemInstance.gemData.grantedEffectList or { gemInstance.grantedEffect }
			for index, grantedEffect in ipairs(grantedEffectList) do
				if not grantedEffect.support and not grantedEffect.unsupported and (not grantedEffect.hasGlobalEffect or gemInstance["enableGlobal"..index]) then
					return true
				end
			end
		end
		return false
	end
	slot.count.tooltipFunc = function(tooltip)
		if tooltip:CheckForUpdate(self.build.outputRevision, self.displayGroup) then
			tooltip:AddLine(16, "^8注意: `数量合计` 直接以数量乘以该技能的dps.")
			tooltip:AddLine(16, "^8与图腾，召唤生物，散弹效用投射物等配合使用 (例如 灵体火球),")
			tooltip:AddLine(16, "^8多个hit的投射物(例如 天雷之珠), 陷阱, 地雷.")
		end
	end
	slot.count.enabled = function()
		return index <= #self.displayGroup.gemList
	end
	self.controls["gemSlot"..index.."Count"] = slot.count

	-- Parser/calculator error message
	slot.errMsg = new("LabelControl", {"LEFT",slot.count,"RIGHT"}, 2, 2, 0, 16, function()
		local gemInstance = self.displayGroup and self.displayGroup.gemList[index]
		return "^1"..(gemInstance and gemInstance.errMsg or "")
	end)
	self.controls["gemSlot"..index.."ErrMsg"] = slot.errMsg

	-- Enable global-effect skill 1
	slot.enableGlobal1 = new("CheckBoxControl", {"TOPLEFT",slot.delete,"BOTTOMLEFT"}, 0, 2, 20, "", function(state)
		local gemInstance = self.displayGroup.gemList[index]
		gemInstance.enableGlobal1 = state
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.enableGlobal1.shown = function()
		local gemInstance = self.displayGroup and self.displayGroup.gemList[index]
		return gemInstance and gemInstance.gemData and gemInstance.gemData.vaalGem and gemInstance.gemData.grantedEffectList[1] and not gemInstance.gemData.grantedEffectList[1].support
	end
	slot.enableGlobal1.x = function()
		return self:IsShown() and (DrawStringWidth(16, "VAR", slot.enableGlobal1:GetProperty("label")) + 5) or 0
	end
	slot.enableGlobal1.label = function()
		return "Enable "..self.displayGroup.gemList[index].gemData.grantedEffectList[1].name..":"
	end
	self.controls["gemSlot"..index.."EnableGlobal1"] = slot.enableGlobal1

	-- Enable global-effect skill 2
	slot.enableGlobal2 = new("CheckBoxControl", {"LEFT",slot.enableGlobal1,"RIGHT",true}, 0, 0, 20, "", function(state)
		local gemInstance = self.displayGroup.gemList[index]
		gemInstance.enableGlobal2 = state
		self:AddUndoState()
		self.build.buildFlag = true
	end)
	slot.enableGlobal2.shown = function()
		local gemInstance = self.displayGroup and self.displayGroup.gemList[index]
		return gemInstance and gemInstance.gemData and gemInstance.gemData.vaalGem and gemInstance.gemData.grantedEffectList[2] and not gemInstance.gemData.grantedEffectList[2].support
	end
	slot.enableGlobal2.x = function()
		return self:IsShown() and (DrawStringWidth(16, "VAR", slot.enableGlobal2:GetProperty("label")) + 12) or 0
	end
	slot.enableGlobal2.label = function()
		return "Enable "..self.displayGroup.gemList[index].gemData.grantedEffectList[2].name..":"
	end
	self.controls["gemSlot"..index.."EnableGlobal2"] = slot.enableGlobal2
end

function SkillsTabClass:getGemAltQualityList(gemData)
	local altQualList = { }
	for indx, entry in ipairs(alternateGemQualityList) do
		if gemData and (gemData.grantedEffect.qualityStats[entry.type] or (gemData.secondaryGrantedEffect and gemData.secondaryGrantedEffect.qualityStats[entry.type])) then
			t_insert(altQualList, entry)
		end
	end
	return altQualList
end

-- Update the gem slot controls to reflect the currently displayed socket group
function SkillsTabClass:UpdateGemSlots()
	if not self.displayGroup then
		return
	end
	for slotIndex = 1, #self.displayGroup.gemList + 1 do
		if not self.gemSlots[slotIndex] then
			self:CreateGemSlot(slotIndex)
		end
		local slot = self.gemSlots[slotIndex]
		if slotIndex == #self.displayGroup.gemList + 1 then
			slot.nameSpec:SetText("")
			slot.level:SetText("")
			slot.quality:SetText("")
			slot.qualityId:SelByValue("Default", "type")
			slot.enabled.state = false
			slot.count:SetText("")
		else
			slot.nameSpec.inactiveCol = self.displayGroup.gemList[slotIndex].color
		end
	end
end

-- Find the skill gem matching the given specification
function SkillsTabClass:FindSkillGem(nameSpec)
	-- Search for gem name using increasingly broad search patterns
	local patternList = {
		"^ "..nameSpec:gsub("[^\\x00-\\xff]", function(a) return "["..a:upper()..a:lower().."]" end).."$", -- Exact match (case-insensitive)
		"^"..nameSpec:gsub("[^\\x00-\\xff]", " %0%%l+").."$", -- Simple abbreviation ("CtF" -> "Cold to Fire")
		"^ "..nameSpec:gsub(" ",""):gsub("%l", "%%l*%0").."%l+$", -- Abbreviated words ("CldFr" -> "Cold to Fire")
		"^"..nameSpec:gsub(" ",""):gsub("[^\\x00-\\xff]", ".*%0"), -- Global abbreviation ("CtoF" -> "Cold to Fire")
		"^"..nameSpec:gsub(" ",""):gsub("[^\\x00-\\xff]", function(a) return ".*".."["..a:upper()..a:lower().."]" end), -- Case insensitive global abbreviation ("ctof" -> "Cold to Fire")
	}
	for i, pattern in ipairs(patternList) do
		local foundGemData
		for gemId, gemData in pairs(self.build.data.gems) do
			if (" "..gemData.name):match(pattern) then
				if foundGemData then
					return "Ambiguous gem name '"..nameSpec.."': matches '"..foundGemData.name.."', '"..gemData.name.."'"
				end
				foundGemData = gemData
			end
		end
		if foundGemData then
			return nil, foundGemData
		end
	end
	return "Unrecognised gem name '"..nameSpec.."'"
end

-- Processes the given socket group, filling in information that will be used for display or calculations
function SkillsTabClass:ProcessSocketGroup(socketGroup)
	-- Loop through the skill gem list
	local data = self.build.data
	for _, gemInstance in ipairs(socketGroup.gemList) do
		gemInstance.color = "^8"
		gemInstance.nameSpec = gemInstance.nameSpec or ""
		local prevDefaultLevel = gemInstance.gemData and gemInstance.gemData.defaultLevel or (gemInstance.new and (self.defaultGemLevel or 20))
		
		gemInstance.gemData, gemInstance.grantedEffect = nil
		if gemInstance.gemId then
			-- Specified by gem ID
			-- Used for skills granted by skill gems
			gemInstance.errMsg = nil
			gemInstance.gemData = data.gems[gemInstance.gemId]
			if gemInstance.gemData then
				gemInstance.nameSpec = gemInstance.gemData.name
				gemInstance.skillId = gemInstance.gemData.grantedEffectId
			end
		elseif gemInstance.skillId then
			-- Specified by skill ID
			-- Used for skills granted by items
			gemInstance.errMsg = nil
			local gemId = data.gemForSkill[gemInstance.skillId]
			if gemId then
				gemInstance.gemData = data.gems[gemId]
			else
				gemInstance.grantedEffect = data.skills[gemInstance.skillId]
			end
			if gemInstance.triggered then
				
				if gemInstance.grantedEffect.levels[gemInstance.level] then
					gemInstance.grantedEffect.levels[gemInstance.level].cost = {}
				end
				gemInstance.grantedEffect.triggered = gemInstance.triggered
			end
		elseif gemInstance.nameSpec:match("%S") then
			-- Specified by gem/skill name, try to match it
			-- Used to migrate pre-1.4.20 builds
			gemInstance.errMsg, gemInstance.gemData = self:FindSkillGem(gemInstance.nameSpec)
			gemInstance.gemId = gemInstance.gemData and gemInstance.gemData.id
			gemInstance.skillId = gemInstance.gemData and gemInstance.gemData.grantedEffectId
			if gemInstance.gemData then
				gemInstance.nameSpec = gemInstance.gemData.name
			end
		else
			gemInstance.errMsg, gemInstance.gemData, gemInstance.skillId = nil
		end
		if gemInstance.gemData and gemInstance.gemData.grantedEffect.unsupported then
			gemInstance.errMsg = gemInstance.nameSpec.." is not supported yet"
			gemInstance.gemData = nil
		end
		if gemInstance.gemData or gemInstance.grantedEffect then
			gemInstance.new = nil
			local grantedEffect = gemInstance.grantedEffect or gemInstance.gemData.grantedEffect
			if grantedEffect.color == 1 then
				gemInstance.color = colorCodes.STRENGTH
			elseif grantedEffect.color == 2 then
				gemInstance.color = colorCodes.DEXTERITY
			elseif grantedEffect.color == 3 then
				gemInstance.color = colorCodes.INTELLIGENCE
			else
				gemInstance.color = colorCodes.NORMAL
			end
			if prevDefaultLevel and gemInstance.gemData and gemInstance.gemData.defaultLevel ~= prevDefaultLevel then
				gemInstance.level = m_min(self.defaultGemLevel or gemInstance.gemData.defaultLevel, gemInstance.gemData.defaultLevel + 1)
				
				gemInstance.defaultLevel = gemInstance.level
			end
			
			calcLib.validateGemLevel(gemInstance)
			if gemInstance.gemData then
				gemInstance.reqLevel = grantedEffect.levels[gemInstance.level].levelRequirement
				gemInstance.reqStr = calcLib.getGemStatRequirement(gemInstance.reqLevel, grantedEffect.support, gemInstance.gemData.reqStr)
				gemInstance.reqDex = calcLib.getGemStatRequirement(gemInstance.reqLevel, grantedEffect.support, gemInstance.gemData.reqDex)
				gemInstance.reqInt = calcLib.getGemStatRequirement(gemInstance.reqLevel, grantedEffect.support, gemInstance.gemData.reqInt)
			end
		end
	end
end

-- Set the skill to be displayed/edited
function SkillsTabClass:SetDisplayGroup(socketGroup)
	self.displayGroup = socketGroup
	if socketGroup then
		self:ProcessSocketGroup(socketGroup)

		-- Update the main controls
		self.controls.groupLabel:SetText(socketGroup.label)
		self.controls.groupSlot:SelByValue(socketGroup.slot, "slotName")
		self.controls.groupEnabled.state = socketGroup.enabled
		self.controls.includeInFullDPS.state = socketGroup.includeInFullDPS and socketGroup.enabled
		self.controls.groupCount:SetText(socketGroup.groupCount or 1)

		-- Update the gem slot controls
		self:UpdateGemSlots()
		for index, gemInstance in pairs(socketGroup.gemList) do
			self.gemSlots[index].nameSpec:SetText(gemInstance.nameSpec)
			self.gemSlots[index].level:SetText(gemInstance.level)
			self.gemSlots[index].qualityId.list = self:getGemAltQualityList(gemInstance.gemData)
			self.gemSlots[index].quality:SetText(gemInstance.quality)
			self.gemSlots[index].qualityId:SelByValue(gemInstance.qualityId, "type")
			self.gemSlots[index].enabled.state = gemInstance.enabled
			self.gemSlots[index].enableGlobal1.state = gemInstance.enableGlobal1
			self.gemSlots[index].enableGlobal2.state = gemInstance.enableGlobal2
			self.gemSlots[index].count:SetText(gemInstance.count)
		end
	end
end

function SkillsTabClass:AddSocketGroupTooltip(tooltip, socketGroup)
	if socketGroup.enabled and not socketGroup.slotEnabled then
tooltip:AddLine(16, "^7注意: 这组技能已禁用，因为插在了不启用的武器上.")
	end
	local source = socketGroup.sourceItem or socketGroup.sourceNode
	
	if source then	
		tooltip:AddLine(18, colorCodes[source.rarity or "NORMAL"].."^7来自: "..source.name)	
		tooltip:AddSeparator(10)
	end
	local gemShown = { }
	for index, activeSkill in ipairs(socketGroup.displaySkillList) do
		if index > 1 then
			tooltip:AddSeparator(10)
		end
tooltip:AddLine(16, "^7主动技能 #"..index..":")
		for _, skillEffect in ipairs(activeSkill.effectList) do
			tooltip:AddLine(20, string.format("%s%s ^7%d%s/%d%s", 
				data.skillColorMap[skillEffect.grantedEffect.color], 
				skillEffect.grantedEffect.name,
				skillEffect.level, 
				(skillEffect.srcInstance and skillEffect.level > skillEffect.srcInstance.level) and colorCodes.MAGIC.."(+"..(skillEffect.level - skillEffect.srcInstance.level).."^7)" or "",
				skillEffect.quality,
				(skillEffect.srcInstance and skillEffect.quality > skillEffect.srcInstance.quality) and colorCodes.MAGIC.."(+"..(skillEffect.quality - skillEffect.srcInstance.quality).."^7)" or ""
			))
			if skillEffect.srcInstance then
				gemShown[skillEffect.srcInstance] = true
			end
		end
		if activeSkill.minion then
			tooltip:AddSeparator(10)
tooltip:AddLine(16, "^7主动技能 #"..index.."'的主要召唤生物技能:")
			local activeEffect = activeSkill.minion.mainSkill.effectList[1]
			tooltip:AddLine(20, string.format("%s%s ^7%d%s/%d%s", 
				data.skillColorMap[activeEffect.grantedEffect.color], 
				activeEffect.grantedEffect.name, 
				activeEffect.level, 
				(activeEffect.srcInstance and activeEffect.level > activeEffect.srcInstance.level) and colorCodes.MAGIC.."+"..(activeEffect.level - activeEffect.srcInstance.level).."^7" or "",
				activeEffect.quality,
				(activeEffect.srcInstance and activeEffect.quality > activeEffect.srcInstance.quality) and colorCodes.MAGIC.."+"..(activeEffect.quality - activeEffect.srcInstance.quality).."^7" or ""
			))
			if activeEffect.srcInstance then
				gemShown[activeEffect.srcInstance] = true
			end
		end
	end
	local showOtherHeader = true
	for _, gemInstance in ipairs(socketGroup.gemList) do
		if not gemShown[gemInstance] then
			if showOtherHeader then
				showOtherHeader = false
				tooltip:AddSeparator(10)
tooltip:AddLine(16, "^7不起作用的技能:")
			end
			local reason = ""
			local displayEffect = gemInstance.displayEffect or gemInstance
			local grantedEffect = gemInstance.gemData and gemInstance.gemData.grantedEffect or gemInstance.grantedEffect
			if not grantedEffect then
				reason = "(Unsupported)"
			elseif not gemInstance.enabled then
				reason = "(Disabled)"
			elseif not socketGroup.enabled or not socketGroup.slotEnabled then
			elseif grantedEffect.support then
				if displayEffect.superseded then
					reason = "(Superseded)"
				elseif (not displayEffect.isSupporting or not next(displayEffect.isSupporting)) and #socketGroup.displaySkillList > 0 then
reason = "(无法作用于这个技能)"
				end
			end
			tooltip:AddLine(20, string.format("%s%s ^7%d%s/%d%s %s", 
				gemInstance.color, 
				(gemInstance.grantedEffect and gemInstance.grantedEffect.name) or (gemInstance.gemData and gemInstance.gemData.name) or gemInstance.nameSpec, 
				displayEffect.level, 
				displayEffect.level > gemInstance.level and colorCodes.MAGIC.."+"..(displayEffect.level - gemInstance.level).."^7" or "",
				displayEffect.quality,
				displayEffect.quality > gemInstance.quality and colorCodes.MAGIC.."+"..(displayEffect.quality - gemInstance.quality).."^7" or "",
				reason
			))
		end
	end
end

function SkillsTabClass:CreateUndoState()
	local state = { }
	state.socketGroupList = { }
	for _, socketGroup in ipairs(self.socketGroupList) do
		local newGroup = copyTable(socketGroup, true)
		newGroup.gemList = { }
		for index, gemInstance in pairs(socketGroup.gemList) do
			newGroup.gemList[index] = copyTable(gemInstance, true)
		end
		t_insert(state.socketGroupList, newGroup)
	end
	return state
end

function SkillsTabClass:RestoreUndoState(state)
	local displayId = isValueInArray(self.socketGroupList, self.displayGroup)
	wipeTable(self.socketGroupList)
	for k, v in pairs(state.socketGroupList) do
		self.socketGroupList[k] = v
	end
	self:SetDisplayGroup(displayId and self.socketGroupList[displayId])
	if self.controls.groupList.selValue then
		self.controls.groupList.selValue = self.socketGroupList[self.controls.groupList.selIndex]
	end
end


