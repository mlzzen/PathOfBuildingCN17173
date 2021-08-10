-- Path of Building
--
-- Class: Item Slot
-- Item Slot control, extends the basic dropdown control.
--
--local launch, main = ...

local pairs = pairs
local t_insert = table.insert
local m_min = math.min

local typeLabel = {

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
{ label = "腰带", slotName = "Belt" },
{ label = "药剂 1", slotName = "Flask 1" },
{ label = "药剂 2", slotName = "Flask 2" },
{ label = "药剂 3", slotName = "Flask 3" },
{ label = "药剂 4", slotName = "Flask 4" },
{ label = "药剂 5", slotName = "Flask 5" },
{ label = "珠宝 1", slotName = "Socket #1" },
{ label = "珠宝 2", slotName = "Socket #2" },
{ label = "珠宝 3", slotName = "Socket #3" },
{ label = "珠宝 4", slotName = "Socket #4" },
{ label = "珠宝 5", slotName = "Socket #5" },
{ label = "珠宝 6", slotName = "Socket #6" },
{ label = "珠宝 7", slotName = "Socket #7" },
{ label = "珠宝 8", slotName = "Socket #8" },
{ label = "珠宝 9", slotName = "Socket #9" },
{ label = "珠宝 10", slotName = "Socket #10" },
{ label = "珠宝 11", slotName = "Socket #11" },
{ label = "珠宝 12", slotName = "Socket #12" },
{ label = "珠宝 13", slotName = "Socket #13" },
{ label = "珠宝 14", slotName = "Socket #14" },
{ label = "珠宝 15", slotName = "Socket #15" },
{ label = "深渊珠宝#1", slotName = "Abyssal #1" },
{ label = "深渊珠宝#2", slotName = "Abyssal #2" },
{ label = "深渊珠宝#3", slotName = "Abyssal #3" },
{ label = "深渊珠宝#4", slotName = "Abyssal #4" },
{ label = "深渊珠宝#5", slotName = "Abyssal #5" },
{ label = "深渊珠宝#6", slotName = "Abyssal #6" },
{ label = "深渊珠宝#7", slotName = "Abyssal #7" },
{ label = "深渊珠宝#8", slotName = "Abyssal #8" },
{ label = "深渊珠宝#9", slotName = "Abyssal #9" },
{ label = "深渊珠宝#10", slotName = "Abyssal #10" },
{ label = "深渊珠宝#11", slotName = "Abyssal #11" },
{ label = "深渊珠宝#12", slotName = "Abyssal #12" },
{ label = "深渊珠宝#13", slotName = "Abyssal #13" },
{ label = "深渊珠宝#14", slotName = "Abyssal #14" },
{ label = "深渊珠宝#15", slotName = "Abyssal #15" },

{ label = "深渊珠宝#16", slotName = "Abyssal #16" },
{ label = "深渊珠宝#17", slotName = "Abyssal #17" },
{ label = "深渊珠宝#18", slotName = "Abyssal #18" },
{ label = "深渊珠宝#19", slotName = "Abyssal #19" },
{ label = "深渊珠宝#20", slotName = "Abyssal #20" },
{ label = "深渊珠宝#21", slotName = "Abyssal #21" },

}
local ItemSlotClass = newClass("ItemSlotControl", "DropDownControl", function(self, anchor, x, y, itemsTab, slotName, slotLabel, nodeId)
	self.DropDownControl(anchor, x, y, 310, 20, { }, function(index, value)
		if self.items[index] ~= self.selItemId then
			self:SetSelItemId(self.items[index])
			itemsTab:PopulateSlots()
			itemsTab:AddUndoState()
			itemsTab.build.buildFlag = true
		end
	end)
	self.anchor.collapse = true
	self.enabled = function()
		return #self.items > 1
	end
	self.shown = function()
		return not self.inactive
	end
	self.itemsTab = itemsTab
	self.items = { }
	self.selItemId = 0
	self.slotName = slotName
	--Slots with names like "Weapon 2 Abyssal Socket #1" will match the first group of digits as the slotNum for abyssal sockets, which is checked against the abyssal socket count on the parent item when considering whether an abyssal socket is active or not.
--This fix ensures that we if possible match against the end of the string by anchoring the match, falling back on matching anywhere if that's not possible. This ensures that the match for items like "Weapon 2Swap" is still correct.
	self.slotNum = tonumber(slotName:match("%d+$") or slotName:match("%d+"))
	if slotName:match("Flask") then
self.controls.activate = new("CheckBoxControl", {"RIGHT",self,"LEFT"}, -2, 0, 20, nil, function(state)
			self.active = state
			itemsTab.activeItemSet[self.slotName].active = state
			itemsTab:AddUndoState()
			itemsTab.build.buildFlag = true
		end)
		self.controls.activate.enabled = function()
			return self.selItemId ~= 0
		end
self.controls.activate.tooltipText = "启用这瓶药剂."
		self.labelOffset = -24
	else
		self.labelOffset = -2
	end
	self.abyssalSocketList = { }
	self.tooltipFunc = function(tooltip, mode, index, itemId)
		local item = itemsTab.items[self.items[index]]
		if main.popups[1] or mode == "OUT" or not item or (not self.dropped and itemsTab.selControl and itemsTab.selControl ~= self.controls.activate) then
			tooltip:Clear()
		elseif tooltip:CheckForUpdate(item, launch.devModeAlt, itemsTab.build.outputRevision) then
			itemsTab:AddItemTooltip(tooltip, item, self)
		end
	end
	self.label = slotLabel or slotName
	
	
		for index in pairs(typeLabel) do
				if self.label==typeLabel[index].slotName then
					self.label=typeLabel[index].label
				end
			end
			
			
	self.nodeId = nodeId
	 
end)


function ItemSlotClass:SetSelItemId(selItemId)
	
	if self.nodeId then
		if self.itemsTab.build.spec then
			self.itemsTab.build.spec.jewels[self.nodeId] = selItemId
			if selItemId ~= self.selItemId then
				self.itemsTab.build.spec:BuildClusterJewelGraphs()
				self.itemsTab.build.spec:BuildAllDependsAndPaths()
			end
		end
	else
		self.itemsTab.activeItemSet[self.slotName].selItemId = selItemId
	end
	self.selItemId = selItemId
end

function ItemSlotClass:Populate()
	wipeTable(self.items)
	wipeTable(self.list)
	self.items[1] = 0
	self.list[1] = "None"
	self.selIndex = 1
	for _, item in pairs(self.itemsTab.items) do
		if self.itemsTab:IsItemValidForSlot(item, self.slotName) then
			t_insert(self.items, item.id)
			t_insert(self.list, colorCodes[item.rarity]..item.name)
			if item.id == self.selItemId then
				self.selIndex = #self.list
			end
		end
	end
	if not self.selItemId or not self.itemsTab.items[self.selItemId] or not self.itemsTab:IsItemValidForSlot(self.itemsTab.items[self.selItemId], self.slotName) then
		self:SetSelItemId(0)
	end

	-- Update Abyssal Sockets
	local abyssalSocketCount = 0
	if self.selItemId > 0 then
		local selItem = self.itemsTab.items[self.selItemId]
		abyssalSocketCount = selItem.abyssalSocketCount or 0
	end
	for i, abyssalSocket in ipairs(self.abyssalSocketList) do
		abyssalSocket.inactive = i > abyssalSocketCount
	end
	
end

function ItemSlotClass:CanReceiveDrag(type, value)
	return type == "Item" and self.itemsTab:IsItemValidForSlot(value, self.slotName)
end

function ItemSlotClass:ReceiveDrag(type, value, source)
	if value.id and self.itemsTab.items[value.id] then
		self:SetSelItemId(value.id)
	else
		local newItem = new("Item",  value.raw)
		newItem:NormaliseQuality()
		self.itemsTab:AddItem(newItem, true)
		self:SetSelItemId(newItem.id)
	end
	self.itemsTab:PopulateSlots()
	self.itemsTab:AddUndoState()
	self.itemsTab.build.buildFlag = true
end

function ItemSlotClass:Draw(viewPort)
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	DrawString(x + self.labelOffset, y + 2, "RIGHT_X", height - 4, "VAR", "^7"..self.label..":")
	self.DropDownControl:Draw(viewPort)
	self:DrawControls(viewPort)
	if not main.popups[1] and self.nodeId and not self.dropped and ( (self:IsMouseOver() and (self.otherDragSource or not self.itemsTab.selControl))) then
		SetDrawLayer(nil, 15)
		-- x + width + 5
		local viewerY
		if self.DropDownControl.dropUp and self.DropDownControl.dropped then
			viewerY = y + 20
		else
			viewerY = m_min(y - 300 - 5, viewPort.y + viewPort.height - 304)
		end
		local viewerX =x 
		--m_min(y, viewPort.y + viewPort.height - 304)
		--local viewerY = m_min(y - 300 - 5, viewPort.y + viewPort.height - 304)
		 
		SetDrawColor(1, 1, 1)
		DrawImage(nil, viewerX, viewerY, 304, 304)
		local viewer = self.itemsTab.socketViewer
		local node = self.itemsTab.build.spec.nodes[self.nodeId]
		viewer.zoom = 5
		local scale = self.itemsTab.build.spec.tree.size / 1500
		viewer.zoomX = -node.x / scale
		viewer.zoomY = -node.y / scale
		SetViewport(viewerX + 2, viewerY + 2, 300, 300)
		viewer:Draw(self.itemsTab.build, { x = 0, y = 0, width = 300, height = 300 }, { })
		SetDrawLayer(nil, 30)
		SetDrawColor(1, 1, 1, 0.2)
		DrawImage(nil, 149, 0, 2, 300)
		DrawImage(nil, 0, 149, 300, 2)
		SetViewport()
		SetDrawLayer(nil, 0)
	end
end

function ItemSlotClass:OnKeyDown(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	local mOverControl = self:GetMouseOverControl()
	if mOverControl and mOverControl == self.controls.activate then
		return mOverControl:OnKeyDown(key)
	end
	return self.DropDownControl:OnKeyDown(key)
end
