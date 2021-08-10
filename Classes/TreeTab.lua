﻿-- Path of Building
--
-- Module: Tree Tab
-- Passive skill tree tab for the current build.
--
--local launch, main = ...

local ipairs = ipairs
local t_insert = table.insert
local t_sort = table.sort
local m_max = math.max
local m_min = math.min
local m_floor = math.floor
local s_format = string.format

local TreeTabClass = newClass("TreeTab", "ControlHost", function(self, build)
	self.ControlHost()

	self.build = build
	self.isComparing = false;

	self.viewer = new("PassiveTreeView")

	self.specList = { }
	self.specList[1] = new("PassiveSpec", build, latestTreeVersion)
	self:SetActiveSpec(1)
	self:SetCompareSpec(1)

	self.anchorControls = new("Control", nil, 0, 0, 0, 20)
	self.controls.specSelect = new("DropDownControl", {"LEFT",self.anchorControls,"RIGHT"}, 0, 0, 190, 20, nil, function(index, value)
		if self.specList[index] then
			self.build.modFlag = true
			self:SetActiveSpec(index)
		else
			self:OpenSpecManagePopup()
		end
	end)
	self.controls.specSelect.tooltipFunc = function(tooltip, mode, selIndex, selVal)
		tooltip:Clear()
		if mode ~= "OUT" then
			local spec = self.specList[selIndex]
			if spec then
				local used, ascUsed, sockets = spec:CountAllocNodes()
tooltip:AddLine(16, "职业: "..spec.curClassName)
tooltip:AddLine(16, "升华: "..spec.curAscendClassName)
tooltip:AddLine(16, "已使用: "..used)
				if sockets > 0 then
tooltip:AddLine(16, "珠宝插槽: "..sockets)
				end
				if selIndex ~= self.activeSpec then
					local calcFunc, calcBase = self.build.calcsTab:GetMiscCalculator()
					if calcFunc then
						local output = calcFunc({ spec = spec }, {})
self.build:AddStatComparesToTooltip(tooltip, calcBase, output, "^7切换到这个天赋树会带给你:")
					end
					if spec.curClassId == self.build.spec.curClassId then
						local respec = 0
						for nodeId, node in pairs(self.build.spec.allocNodes) do
							if node.type ~= "ClassStart" and node.type ~= "AscendClassStart" and not spec.allocNodes[nodeId] then
								if node.ascendancyName then
									respec = respec + 5
								else
									respec = respec + 1
								end
							end
						end
						if respec > 0 then
tooltip:AddLine(16, "^7切换到这个天赋树需要 "..respec.." 后悔点.")
						end
					end
				end
				tooltip:AddLine(16, "游戏版本: "..treeVersions[spec.treeVersion].display)
			end
		end
	end
self.controls.compareCheck = new("CheckBoxControl", {"LEFT",self.controls.specSelect,"RIGHT"}, 74, 0, 20, "比对:", function(state)
		self.isComparing = state
		self:SetCompareSpec(self.activeCompareSpec)
		self.controls.compareSelect.shown = state
		if state then
			self.controls.reset:SetAnchor("LEFT",self.controls.compareSelect,"RIGHT",nil,nil,nil)
		else
			self.controls.reset:SetAnchor("LEFT",self.controls.compareCheck,"RIGHT",nil,nil,nil)
		end
	end)
	self.controls.compareSelect = new("DropDownControl", {"LEFT",self.controls.compareCheck,"RIGHT"}, 8, 0, 190, 20, nil, function(index, value)
		if self.specList[index] then
			self:SetCompareSpec(index)
		end
	end)
	self.controls.compareSelect.shown = false
	self.controls.reset = new("ButtonControl", {"LEFT",self.controls.compareCheck,"RIGHT"}, 8, 0, 60, 20, "重置", function()
main:OpenConfirmPopup("Reset Tree", "确定要重置天赋树吗?", "重置", function()			
			
			self.build.spec:ResetNodes()
			--self.build.spec:resetAllocTimeJew(); 
			self.build.spec:AddUndoState()
			self.build.buildFlag = true
		end)
	end)
self.controls.import = new("ButtonControl", {"LEFT",self.controls.reset,"RIGHT"}, 8, 0, 90, 20, "导入天赋树", function()
		self:OpenImportPopup()
	end)
self.controls.export = new("ButtonControl", {"LEFT",self.controls.import,"RIGHT"}, 8, 0, 90, 20, "导出天赋树", function()
		self:OpenExportPopup()
	end)
self.controls.treeSearch = new("EditControl", {"LEFT",self.controls.export,"RIGHT"}, 8, 0, main.portraitMode and 200 or 300, 20, "", "搜索", "%c%(%)", 100, function(buf)
		self.viewer.searchStr = buf
	end)

	self.controls.treeSearch.tooltipText = "可以使用 Lua 支持的正则表达式进行复杂搜索"
	self.controls.treeHeatMap = new("CheckBoxControl", {"LEFT",self.controls.treeSearch,"RIGHT"}, 130, 0, 20, "显示高亮节点:", function(state)
		self.viewer.showHeatMap = state
		self.controls.treeHeatMapStatSelect.shown = state
	end)
	self.controls.treeHeatMapStatSelect = new("DropDownControl", {"LEFT",self.controls.treeHeatMap,"RIGHT"}, 8, 0, 150, 20, nil, function(index, value)
		self:SetPowerCalc(value)
	end)
	self.controls.treeHeatMap.tooltipText = function()
		local offCol, defCol = main.nodePowerTheme:match("(%a+)/(%a+)")
		return "启用后, 可以直观地显示每个未配置的天赋节点提供攻击或防御加成\n攻击报表显示为 "..offCol:lower()..", 防御报表显示为 "..defCol:lower().."."
	end

	self.powerStatList = { }
	for _, stat in ipairs(data.powerStatList) do
		if not stat.ignoreForNodes then
			t_insert(self.powerStatList, stat)
		end
	end

	self.controls.powerReport = new("ButtonControl", {"LEFT", self.controls.treeHeatMapStatSelect, "RIGHT"}, 8, 0, 150, 20, self.showPowerReport and "Hide Power Report" or "Show Power Report", function()
		self.showPowerReport = not self.showPowerReport
		self:TogglePowerReport()
	end)
	
	self.showPowerReport = false
	 
self.controls.specConvertText = new("LabelControl", {"BOTTOMLEFT",self.controls.specSelect,"TOPLEFT"}, 0, -14, 0, 16, "^7这是一个旧版本的天赋树，也许无法完整地转换为当前游戏版本.")
	self.controls.specConvertText.shown = function()
		return self.showConvert
	end
self.controls.specConvert = new("ButtonControl", {"LEFT",self.controls.specConvertText,"RIGHT"}, 8, 0, 120, 20, "^2转化为  "..treeVersions[latestTreeVersion].display, function()
		local newSpec = new("PassiveSpec", self.build, latestTreeVersion)
		newSpec.title = self.build.spec.title
		newSpec.jewels = copyTable(self.build.spec.jewels)
		--newSpec:DecodeURL(self.build.spec:EncodeURL())
		newSpec:RestoreUndoState(self.build.spec:CreateUndoState())
		newSpec:BuildClusterJewelGraphs()
		
		t_insert(self.specList, self.activeSpec + 1, newSpec)
		self:SetActiveSpec(self.activeSpec + 1)
		self.modFlag = true
main:OpenMessagePopup("天赋树转换完成", "天赋树转化为 "..treeVersions[latestTreeVersion].display..".\n注意，游戏天赋树的版本变动可能回导致一些天赋点在转化后会被取消.\n\n你可以使用左下方的天赋树切换来切换到旧版本的.")
	end)
end)

function TreeTabClass:Draw(viewPort, inputEvents)
	self.anchorControls.x = viewPort.x + 4
	self.anchorControls.y = viewPort.y + viewPort.height - 24

	for id, event in ipairs(inputEvents) do
		if event.type == "KeyDown" then
			if event.key == "z" and IsKeyDown("CTRL") then
				self.build.spec:Undo()
				self.build.buildFlag = true
				inputEvents[id] = nil
			elseif event.key == "y" and IsKeyDown("CTRL") then
				self.build.spec:Redo()
				self.build.buildFlag = true
				inputEvents[id] = nil
			elseif event.key == "f" and IsKeyDown("CTRL") then
				self:SelectControl(self.controls.treeSearch)
			end
		end
	end
	self:ProcessControlsInput(inputEvents, viewPort)

-- Determine positions if one line of controls doesn't fit in the screen width

	local twoLineHeight = self.controls.treeHeatMap.y == 24 and 26 or 0
	if(select(1, self.controls.powerReport:GetPos()) + select(1, self.controls.powerReport:GetSize()) > viewPort.x + viewPort.width) then
		twoLineHeight = 26
		self.controls.treeHeatMap:SetAnchor("BOTTOMLEFT",self.controls.specSelect,"BOTTOMLEFT",nil,nil,nil)
		self.controls.treeHeatMap.y = 24
		self.controls.treeHeatMap.x = 125

		self.controls.specSelect.y = -24
		self.controls.specConvertText.y = -16
		if self.controls.powerReportList then			
			self.controls.powerReportList:SetAnchor("TOPLEFT",self.controls.specSelect,"BOTTOMLEFT",0,self.controls.treeHeatMap.y + self.controls.treeHeatMap.height)
			self.controls.allocatedNodeToggle:SetAnchor("TOPLEFT",self.controls.powerReportList,"BOTTOMLEFT", 0, 4)
		end
	elseif viewPort.x + viewPort.width - (select(1, self.controls.treeSearch:GetPos()) + select(1, self.controls.treeSearch:GetSize())) > (select(1, self.controls.powerReport:GetPos()) + select(1, self.controls.powerReport:GetSize())) - viewPort.x  then
		twoLineHeight = 0
		self.controls.treeHeatMap:SetAnchor("LEFT",self.controls.treeSearch,"RIGHT",nil,nil,nil)
		self.controls.treeHeatMap.y = 0
		self.controls.treeHeatMap.x = 130
		if self.controls.powerReportList then
			self.controls.powerReportList:SetAnchor("TOPLEFT",self.controls.specSelect,"BOTTOMLEFT",0,self.controls.specSelect.height + 4)
			self.controls.allocatedNodeToggle:SetAnchor("TOPLEFT",self.controls.powerReportList,"TOPRIGHT", 8, 4)
		end
	end

	local bottomDrawerHeight = self.showPowerReport and 200 or 0
	self.controls.specSelect.y = -bottomDrawerHeight - twoLineHeight

	local treeViewPort = { x = viewPort.x, y = viewPort.y, width = viewPort.width, height = viewPort.height - (self.showConvert and 64 + bottomDrawerHeight + twoLineHeight or 32 + bottomDrawerHeight + twoLineHeight)}
		
	if self.jumpToNode then
		self.viewer:Focus(self.jumpToX, self.jumpToY, treeViewPort, self.build)
		self.jumpToNode = false
	end
	self.viewer.compareSpec = self.isComparing and self.specList[self.activeCompareSpec] or nil
	self.viewer:Draw(self.build, treeViewPort, inputEvents)

	self.controls.compareSelect.selIndex = self.activeCompareSpec
	wipeTable(self.controls.compareSelect.list)
	for id, spec in ipairs(self.specList) do
		t_insert(self.controls.compareSelect.list, (spec.treeVersion ~= latestTreeVersion and ("["..treeVersions[spec.treeVersion].display.."] ") or "")..(spec.title or "Default"))
	end

	self.controls.specSelect.selIndex = self.activeSpec
	wipeTable(self.controls.specSelect.list)
	for id, spec in ipairs(self.specList) do
		t_insert(self.controls.specSelect.list, (spec.treeVersion ~= latestTreeVersion and ("["..treeVersions[spec.treeVersion].display.."] ") or "")..(spec.title or "Default"))

	end
	t_insert(self.controls.specSelect.list, "管理天赋树...")
	
	if not self.controls.treeSearch.hasFocus then
		self.controls.treeSearch:SetText(self.viewer.searchStr)
	end
	
	self.controls.treeHeatMapStatSelect.list = self.powerStatList
	self.controls.treeHeatMapStatSelect.selIndex = 1
	if self.build.calcsTab.powerStat then
		self.controls.treeHeatMapStatSelect:SelByValue(self.build.calcsTab.powerStat.stat, "stat")
	end
	
	
	if self.controls.powerReportList then
		if self.build.calcsTab.powerStat and self.build.calcsTab.powerStat.stat then
			self.controls.powerReportList.label = self.build.calcsTab.powerBuilder and "构建报表中..." or "点击可以在天赋树查看"
		else
			self.controls.powerReportList.label = "^7\"伤害/防御\" 选项不支持.  请选择一个其它状态进行查看."
		end
	end
	
	 
	SetDrawLayer(1)

	SetDrawColor(0.05, 0.05, 0.05)
	DrawImage(nil, viewPort.x, viewPort.y + viewPort.height - (28 + bottomDrawerHeight + twoLineHeight), viewPort.width, 28 + bottomDrawerHeight + twoLineHeight)
	SetDrawColor(0.85, 0.85, 0.85)
	DrawImage(nil, viewPort.x, viewPort.y + viewPort.height - (32 + bottomDrawerHeight + twoLineHeight), viewPort.width, 4)

	if self.showConvert then
		SetDrawColor(0.05, 0.05, 0.05)
		DrawImage(nil, viewPort.x, viewPort.y + viewPort.height - (60 + bottomDrawerHeight + twoLineHeight), viewPort.width, 28)
		SetDrawColor(0.85, 0.85, 0.85)
		DrawImage(nil, viewPort.x, viewPort.y + viewPort.height - (64 + bottomDrawerHeight + twoLineHeight), viewPort.width, 4)
	end

	self:DrawControls(viewPort)
end

function TreeTabClass:Load(xml, dbFileName)
	self.specList = { }
	if xml.elem == "Spec" then
		-- Import single spec from old build
		self.specList[1] = new("PassiveSpec", self.build, defaultTreeVersion)
		self.specList[1]:Load(xml, dbFileName)
		self.activeSpec = 1
		self.build.spec = self.specList[1]
		return
	end
	for _, node in pairs(xml) do
		if type(node) == "table" then
			if node.elem == "Spec" then
				if node.attrib.treeVersion and not treeVersions[node.attrib.treeVersion] then
					main:OpenMessagePopup("未知天赋树版本", "The build you are trying to load uses an unrecognised version of the passive skill tree.\nYou may need to update the program before loading this build.")
					return true
				end
				local newSpec = new("PassiveSpec", self.build, node.attrib.treeVersion or defaultTreeVersion)			
				newSpec:Load(node, dbFileName)
				t_insert(self.specList, newSpec)
			end
		end
	end
	if not self.specList[1] then
		self.specList[1] = new("PassiveSpec", self.build, latestTreeVersion)
	end
	self:SetActiveSpec(tonumber(xml.attrib.activeSpec) or 1)
end


function TreeTabClass:PostLoad()
	for _, spec in ipairs(self.specList) do
		spec:PostLoad()
	end
end

function TreeTabClass:Save(xml)
	xml.attrib = { 
		activeSpec = tostring(self.activeSpec)
	}
	for specId, spec in ipairs(self.specList) do
		if specId == self.activeSpec then
			-- Update this spec's jewels from the socket slots
			for _, slot in pairs(self.build.itemsTab.slots) do
				if slot.nodeId then
					spec.jewels[slot.nodeId] = slot.selItemId
				end
			end
		end
		local child = {
			elem = "Spec"
		}
		spec:Save(child)
		t_insert(xml, child)
	end
	self.modFlag = false
end

function TreeTabClass:SetActiveSpec(specId)
	local prevSpec = self.build.spec
	self.activeSpec = m_min(specId, #self.specList)
	local curSpec = self.specList[self.activeSpec]
	self.build.spec = curSpec
	self.build.buildFlag = true
	self.build.spec:SetWindowTitleWithBuildClass()
	for _, slot in pairs(self.build.itemsTab.slots) do
		if slot.nodeId then
			if prevSpec then
				-- Update the previous spec's jewel for this slot
				prevSpec.jewels[slot.nodeId] = slot.selItemId
			end
			if curSpec.jewels[slot.nodeId] then
				-- Socket the jewel for the new spec
				slot.selItemId = curSpec.jewels[slot.nodeId]
			end
		end
	end
	self.showConvert = curSpec.treeVersion ~= latestTreeVersion
	if self.build.itemsTab.itemOrderList[1] then
		-- Update item slots if items have been loaded already
		self.build.itemsTab:PopulateSlots()
	end
end

function TreeTabClass:SetCompareSpec(specId)
	
	self.activeCompareSpec = m_min(specId, #self.specList)
	local curSpec = self.specList[self.activeCompareSpec]

	self.compareSpec = curSpec
end


function TreeTabClass:OpenSpecManagePopup()
main:OpenPopup(370, 290, "天赋树管理", {
		new("PassiveSpecListControl", nil, 0, 50, 350, 200, self),
		new("ButtonControl", nil, 0, 260, 90, 20, "Done", function()
			main:ClosePopup()
		end),
	})
end

function TreeTabClass:OpenImportPopup()
	local controls = { }
	local function decodeTreeLink(treeLink)
		local errMsg = self.build.spec:DecodeURL(treeLink)
		if errMsg then
			controls.msg.label = "^1"..errMsg
		else
			self.build.spec:AddUndoState()
			--self.build.spec:resetAllocTimeJew(); 
		--	self.build.spec:allocTimeJew(); 
			self.build.buildFlag = true
			main:ClosePopup()
		end
	end
controls.editLabel = new("LabelControl", nil, 0, 20, 0, 16, "天赋树链接:")
	controls.edit = new("EditControl", nil, 0, 40, 350, 18, "", nil, nil, nil, function(buf)
		controls.msg.label = ""
	end)
	controls.msg = new("LabelControl", nil, 0, 58, 0, 16, "")
controls.import = new("ButtonControl", nil, -45, 80, 80, 20, "导入", function()
		local treeLink = controls.edit.buf
		if #treeLink == 0 then
			return
		end
		if treeLink:match("poeurl%.com/") then
			controls.import.enabled = false
controls.msg.label = "解析PoEURL链接..."
			local id = LaunchSubScript([[
				local treeLink = ...
				local curl = require("lcurl.safe")
				local easy = curl.easy()
				easy:setopt_url(treeLink)
				easy:setopt_writefunction(function(data)
					return true
				end)
				easy:perform()
				local redirect = easy:getinfo(curl.INFO_REDIRECT_URL)
				easy:close()
				if not redirect or redirect:match("poeurl%.com/") then
					return nil, "Failed to resolve PoEURL link"
				end
				return redirect
			]], "", "", treeLink)
			if id then
				launch:RegisterSubScript(id, function(treeLink, errMsg)
					if errMsg then
						controls.msg.label = "^1"..errMsg
						controls.import.enabled = true
					else
						decodeTreeLink(treeLink)
					end
				end)
			end
		else
			decodeTreeLink(treeLink)
		end
	end)
controls.cancel = new("ButtonControl", nil, 45, 80, 80, 20, "取消", function()
		main:ClosePopup()
	end)
main:OpenPopup(380, 110, "导入天赋树", controls, "import", "edit")
end

function TreeTabClass:OpenExportPopup()
	local treeLink = self.build.spec:EncodeURL(treeVersions[self.build.spec.treeVersion].export)
	local popup
	local controls = { }
controls.label = new("LabelControl", nil, 0, 20, 0, 16, "天赋树链接:")
	controls.edit = new("EditControl", nil, 0, 40, 350, 18, treeLink, nil, "%Z")
	controls.shrink = new("ButtonControl", nil, -90, 70, 140, 20, "Shrink with PoEURL", function()
		controls.shrink.enabled = false
		controls.shrink.label = "Shrinking..."
		launch:DownloadPage("http://poeurl.com/shrink.php?url="..treeLink, function(page, errMsg)
			controls.shrink.label = "Done"
			if errMsg or not page:match("%S") then
main:OpenMessagePopup("PoEURL Shortener", "分享PoEURL链接失败（可能被墙了？）. 可以考虑稍后重试.")
			else
				treeLink = "http://poeurl.com/"..page
				controls.edit:SetText(treeLink)
				popup:SelectControl(controls.edit)
			end
		end)
	end)
controls.copy = new("ButtonControl", nil, 30, 70, 80, 20, "复制", function()
		Copy(treeLink)
	end)
controls.done = new("ButtonControl", nil, 120, 70, 80, 20, "关闭", function()
		main:ClosePopup()
	end)
popup = main:OpenPopup(380, 100, "导出天赋树链接", controls, "done", "edit")
end



function TreeTabClass:ModifyNodePopup(selectedNode)
	local controls = { }
	local modGroups = { }
	local smallAdditions = {"力量", "敏捷", "奉献"}
	if not self.build.spec.tree.legion.editedNodes then
		self.build.spec.tree.legion.editedNodes = { }
	end
	
	local function buildMods(selectedNode)
		wipeTable(modGroups)
		for _, node in pairs(self.build.spec.tree.legion.nodes) do
			if node.id:match("^"..selectedNode.conqueredBy.conqueror.type.."_.+") and node["not"] == (selectedNode.isNotable or false) and not node.ks then
				t_insert(modGroups, {
					label = node.dn,
					descriptions = copyTable(node.sd),
					type = selectedNode.conqueredBy.conqueror.type,
					id = node.id,
				})
			end
		end
		for _, addition in pairs(self.build.spec.tree.legion.additions) do
			-- exclude passives that are already added (vaal, attributes, devotion)
			if addition.id:match("^"..selectedNode.conqueredBy.conqueror.type.."_.+") and not isValueInArray(smallAdditions, addition.dn) and selectedNode.conqueredBy.conqueror.type ~= "vaal" then
				t_insert(modGroups, {
					label = addition.dn,
					descriptions = copyTable(addition.sd),
					type = selectedNode.conqueredBy.conqueror.type,
					id = addition.id,
				})
			end
		end
	end
	local function addModifier(selectedNode)
		local newLegionNode = self.build.spec.tree.legion.nodes[modGroups[controls.modSelect.selIndex].id]
		-- most nodes only replace or add 1 mod, so we need to just get the first control
		local modDesc = string.gsub(controls[1].label, "%^7", "")
		if  selectedNode.conqueredBy.conqueror.type == "eternal" or selectedNode.conqueredBy.conqueror.type == "templar" then
			self.build.spec:NodeAdditionOrReplacementFromString(selectedNode, modDesc, true)
			selectedNode.dn = newLegionNode.dn
			selectedNode.sprites = newLegionNode.sprites
			selectedNode.icon = newLegionNode.icon
			selectedNode.spriteId = newLegionNode.id
		elseif selectedNode.conqueredBy.conqueror.type == "vaal" then
			selectedNode.dn = newLegionNode.dn
			selectedNode.sprites = newLegionNode.sprites
			selectedNode.icon = newLegionNode.icon
			selectedNode.spriteId = newLegionNode.id
			
			if modDesc ~= "" then
				self.specList[1]:NodeAdditionOrReplacementFromString(selectedNode, modDesc, true)
			end
			

			-- Vaal is the exception
			local i = 2
			while controls[i] do
				modDesc = string.gsub(controls[i].label, "%^7", "")
				if modDesc ~= "" then
					self.specList[1]:NodeAdditionOrReplacementFromString(selectedNode, modDesc, false)
				end
				i = i + 1
			end
		else
			-- Replace the node first before adding the new line so we don't get multiple lines
			if self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id] and self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id][selectedNode.id] then
				self.build.spec:ReplaceNode(selectedNode, self.build.spec.tree.nodes[selectedNode.id])
			end
			self.build.spec:NodeAdditionOrReplacementFromString(selectedNode, modDesc, false)
		end
		self.build.spec:ReconnectNodeToClassStart(selectedNode)
		if not self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id] then		
			--lucifer
			self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id]= {}
			t_insert(self.build.spec.tree.legion.editedNodes, selectedNode.conqueredBy.id, {})
		end 
		
		t_insert(self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id], selectedNode.id, copyTable(selectedNode, true))
	end

	local function constructUI(modGroup)
		local totalHeight = 43
		local i = 1
		while controls[i] or controls["slider"..i] do
			controls[i] = nil
			controls["slider"..i] = nil
			i = i + 1
		end
		-- special handling for custom vaal notables (Might of the Vaal and Legacy of the Vaal)
		if next(modGroup.descriptions) == nil then
			for idx=1,4 do
				controls[idx] = new("EditControl", {"TOPLEFT", controls["slider"..idx-1] or controls[idx-1] or controls.modSelect,"TOPLEFT"}, 0, 20, 600, 16, "", "词缀 "..idx, "%c%(%)", 100, function(buf)
					controls[idx].label = buf
				end)
				controls[idx].label = ""
				totalHeight = totalHeight + 20
			end
		else
			for idx, desc in ipairs(modGroup.descriptions) do
				controls[idx] = new("LabelControl", {"TOPLEFT", controls["slider"..idx-1] or controls[idx-1] or controls.modSelect,"TOPLEFT"}, 0, 20, 600, 16, "^7"..desc)
				totalHeight = totalHeight + 20
				if desc:match("%(%-?[%d%.]+%-[%d%.]+%)") then
					controls["slider"..idx] = new("SliderControl", {"TOPLEFT",controls[idx],"BOTTOMLEFT"}, 0, 2, 300, 16, function(val)
						controls[idx].label = itemLib.applyRange(modGroup.descriptions[idx], val)
					end)
					controls["slider"..idx]:SetVal(.5)
					controls["slider"..idx].width = function()
						return controls["slider"..idx].divCount and 300 or 100
					end
					totalHeight = totalHeight + 20
				end
			end
		end
		main.popups[1].height = totalHeight + 30
		controls.save.y = totalHeight
		controls.reset.y = totalHeight
		controls.close.y = totalHeight
	end

	buildMods(selectedNode)
	controls.modSelectLabel = new("LabelControl", {"TOPRIGHT",nil,"TOPLEFT"}, 150, 25, 0, 16, "^7词缀:")
	controls.modSelect = new("DropDownControl", {"TOPLEFT",nil,"TOPLEFT"}, 155, 25, 579, 18, modGroups, function(idx) constructUI(modGroups[idx]) end)
	controls.modSelect.tooltipFunc = function(tooltip, mode, index, value)
		tooltip:Clear()
		if mode ~= "OUT" and value then
			for _, line in ipairs(value.descriptions) do
				tooltip:AddLine(16, "^7"..line)
			end
		end
	end
	controls.save = new("ButtonControl", nil, -90, 75, 80, 20, "添加", function()
		addModifier(selectedNode)
		self.build.buildFlag = true
		main:ClosePopup()
	end)
	controls.reset = new("ButtonControl", nil, 0, 75, 80, 20, "重置词缀", function()
		if self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id] then
			self.build.spec.tree.legion.editedNodes[selectedNode.conqueredBy.id][selectedNode.id] = nil
		end
		if selectedNode.conqueredBy.conqueror.type == "vaal" and selectedNode.type == "Normal" then
			local legionNode = self.build.spec.tree.legion.nodes["vaal_small_fire_resistance"]
			selectedNode.dn = "瓦尔小天赋"
			selectedNode.sd = {"右键设置词缀"}
			selectedNode.sprites = legionNode.sprites
			selectedNode.mods = {""}
			selectedNode.modList = new("ModList")
			selectedNode.modKey = ""
		elseif selectedNode.conqueredBy.conqueror.type == "vaal" and selectedNode.type == "Notable" then
			local legionNode = self.build.spec.tree.legion.nodes["vaal_notable_curse_1"]
			selectedNode.dn = "瓦尔核心天赋"
			selectedNode.sd = {"右键设置词缀"}
			selectedNode.sprites = legionNode.sprites
			selectedNode.mods = {""}
			selectedNode.modList = new("ModList")
			selectedNode.modKey = ""
		else
			self.build.spec:ReplaceNode(selectedNode, self.build.spec.tree.nodes[selectedNode.id])
			if selectedNode.conqueredBy.conqueror.type == "templar" then
				self.build.spec:NodeAdditionOrReplacementFromString(selectedNode,"+5 奉献")
			end
		end
		self.build.buildFlag = true
		main:ClosePopup()
	end)
	controls.close = new("ButtonControl", nil, 90, 75, 80, 20, "取消", function()
		main:ClosePopup()
	end)
	main:OpenPopup(800, 105, "替换天赋点词缀", controls, "save")
	constructUI(modGroups[1])
end

function TreeTabClass:SetPowerCalc(selection)
	self.viewer.showHeatMap = true
	self.build.buildFlag = true
	self.build.calcsTab.powerBuildFlag = true
	self.build.calcsTab.powerStat = selection
	if self.showPowerReport then
		self.controls.allocatedNodeToggle.enabled = false
		self.controls.allocatedNodeDistance.enabled = false
		self.controls.powerReportList.label = "正在计算中..."
		self.build.calcsTab:BuildPower({ func = self.TogglePowerReport, caller = self })
	
		
	end
end
function TreeTabClass:BuildPowerReportUI()
	self.controls.powerReport.tooltipText = "一个基于当前热力图统计的天赋树节点加成报表"

	self.controls.allocatedNodeToggle = new("ButtonControl", {"TOPLEFT",self.controls.powerReportList,"TOPRIGHT"}, 8, 4, 160, 20, "显示已点亮节点", function()
		self.controls.powerReportList.allocated = not self.controls.powerReportList.allocated
		self.controls.allocatedNodeDistance.shown = self.controls.powerReportList.allocated
		self.controls.allocatedNodeDistance.enabled = self.controls.powerReportList.allocated
		self.controls.allocatedNodeToggle.label = self.controls.powerReportList.allocated and "显示未点亮节点" or "显示已点亮节点"
		self.controls.powerReportList.pathLength = tonumber(self.controls.allocatedNodeDistance.buf or 1)
		self.controls.powerReportList:ReList()
	end)

	self.controls.allocatedNodeDistance = new("EditControl", {"TOPLEFT",self.controls.allocatedNodeToggle,"BOTTOMLEFT"}, 0, 4, 125, 20, 1, "最大路径", "%D", 100, function(buf)
		self.controls.powerReportList.pathLength = tonumber(buf)
		self.controls.powerReportList:ReList()
	end)
end

function TreeTabClass:TogglePowerReport(caller)
	self = self or caller
	
	self.controls.powerReport.label = self.showPowerReport and "隐藏高亮节点报表" or "显示高亮节点报表"
	local currentStat = self.build.calcsTab and self.build.calcsTab.powerStat or nil
	local report = {}
	if not self.showPowerReport and self.controls.powerReportList then
		self.controls.powerReportList.shown = false
		return
	end

	report = self:BuildPowerReportList(currentStat)
	local yPos = self.controls.treeHeatMap.y == 0 and self.controls.specSelect.height + 4 or self.controls.specSelect.height * 2 + 8
	self.controls.powerReportList = new("PowerReportListControl", {"TOPLEFT",self.controls.specSelect,"BOTTOMLEFT"}, 0, yPos, 700, 220, report, currentStat and currentStat.label or "", function(selectedNode)
		-- this code is called by the list control when the user "selects" one of the passives in the list.
		-- we use this to set a flag which causes the next Draw() to recenter the passive tree on the desired node.
		if(selectedNode.x) then
			self.jumpToNode = true
			self.jumpToX = selectedNode.x
			self.jumpToY = selectedNode.y
		end
	end)

	if not self.controls.allocatedNodeToggle then
		self:BuildPowerReportUI()
	end
	self.controls.allocatedNodeToggle:SetAnchor("TOPLEFT",self.controls.powerReportList, main.portraitMode and "BOTTOMLEFT" or"TOPRIGHT")
	self.controls.powerReportList.shown = self.showPowerReport

	-- the report doesn't support listing the "offense/defense" hybrid heatmap, as it is not a single scalar and im unsure how to quantify numerically
	-- especially given the heatmap's current approach of using the sqrt() of both components. that number is cryptic to users, i suspect.
	if currentStat and currentStat.stat then
		self.controls.powerReportList.label = "点击可以在天赋树查看"
		self.controls.powerReportList.enabled = true
	else
		self.controls.powerReportList.label = "^7\"伤害/防御\" 选项不支持.  请选择一个其它状态进行查看."
		self.controls.powerReportList.enabled = false
	end

	self.controls.allocatedNodeToggle.enabled = self.controls.powerReportList.enabled
	self.controls.allocatedNodeDistance.shown = self.controls.powerReportList.allocated
	self.controls.allocatedNodeToggle.label = self.controls.powerReportList.allocated and "显示未点亮节点" or "显示已点亮节点"
	
end

function TreeTabClass:BuildPowerReportList(currentStat)
	local report = {}
	if not (currentStat and currentStat.stat) then
		return report
	end

	-- locate formatting information for the type of heat map being used.
	-- maybe a better place to find this? At the moment, it is the only place
	-- in the code that has this information in a tidy place.
	
	local displayStat = nil

	for index, ds in ipairs(self.build.displayStats) do
		if ds.stat == currentStat.stat then
			displayStat = ds
			break
		end
	end

	-- not every heat map has an associated "stat" in the displayStats table
	-- this is due to not every stat being displayed in the sidebar, I believe.
	-- But, we do want to use the formatting knowledge stored in that table rather than duplicating it here.
	-- If no corresponding stat is found, just default to a generic stat display (>0=good, one digit of precision).
	if not displayStat then
		displayStat = {
			fmt = ".1f"
		}
	end

	-- search all nodes, ignoring ascendcies, sockets, etc.
	for nodeId, node in pairs(self.build.spec.nodes) do
		local isAlloc = node.alloc or self.build.calcsTab.mainEnv.grantedPassives[nodeId]
		if (node.type == "Normal" or node.type == "Keystone" or node.type == "Notable") and not node.ascendancyName then
			local pathDist
			if isAlloc then
				pathDist = #(node.depends or { }) == 0 and 1 or #node.depends
			else
				pathDist = #(node.path or { }) == 0 and 1 or #node.path
			end
			local nodePower = (node.power.singleStat or 0) * ((displayStat.pc or displayStat.mod) and 100 or 1)
			local pathPower = (node.power.pathPower or 0) / pathDist * ((displayStat.pc or displayStat.mod) and 100 or 1)
			
			local nodePowerStr = s_format("%"..displayStat.fmt, nodePower)
			local pathPowerStr = s_format("%"..displayStat.fmt, pathPower)

			nodePowerStr = formatNumSep(nodePowerStr)
			pathPowerStr = formatNumSep(pathPowerStr)

			
			if (nodePower > 0 and not displayStat.lowerIsBetter) or (nodePower < 0 and displayStat.lowerIsBetter) then
				nodePowerStr = colorCodes.POSITIVE .. nodePowerStr
			elseif (nodePower < 0 and not displayStat.lowerIsBetter) or (nodePower > 0 and displayStat.lowerIsBetter) then
				nodePowerStr = colorCodes.NEGATIVE .. nodePowerStr
			end
			if (pathPower > 0 and not displayStat.lowerIsBetter) or (pathPower < 0 and displayStat.lowerIsBetter) then
				pathPowerStr = colorCodes.POSITIVE .. pathPowerStr
			elseif (pathPower < 0 and not displayStat.lowerIsBetter) or (pathPower > 0 and displayStat.lowerIsBetter) then
				pathPowerStr = colorCodes.NEGATIVE .. pathPowerStr
			end
			
			t_insert(report, {
				name = node.dn,
				power = nodePower,
				powerStr = nodePowerStr,
				pathPower = pathPower,
				pathPowerStr = pathPowerStr,
				allocated = isAlloc,
				id = node.id,
				x = node.x,
				y = node.y,
				type = node.type,
				pathDist = pathDist
			})
		end
	end

	-- search all cluster notables and add to the list
	for nodeName, node in pairs(self.build.spec.tree.clusterNodeMap) do
		local isAlloc = node.alloc
		if not isAlloc then			
			local nodePower = (node.power.singleStat or 0) * ((displayStat.pc or displayStat.mod) and 100 or 1)
			local nodePowerStr = s_format("%"..displayStat.fmt, nodePower)

			nodePowerStr = formatNumSep(nodePowerStr)
			
			if (nodePower > 0 and not displayStat.lowerIsBetter) or (nodePower < 0 and displayStat.lowerIsBetter) then
				nodePowerStr = colorCodes.POSITIVE .. nodePowerStr
			elseif (nodePower < 0 and not displayStat.lowerIsBetter) or (nodePower > 0 and displayStat.lowerIsBetter) then
				nodePowerStr = colorCodes.NEGATIVE .. nodePowerStr
			end
			
			t_insert(report, {
				name = node.dn,
				power = nodePower,
				powerStr = nodePowerStr,
				pathPower = 0,
				pathPowerStr = "--",
				id = node.id,
				type = node.type,
				pathDist = "星团"
			})
		end
	end

	-- sort it
	if displayStat.lowerIsBetter then
		t_sort(report, function (a,b)
			return a.power < b.power
		end)
	else
		t_sort(report, function (a,b)
			return a.power > b.power
		end)
	end

	return report
end
