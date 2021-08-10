-- Path of Building
--
-- Class: Item list
-- Build item list control.
--
--local launch, main = ...

local pairs = pairs
local t_insert = table.insert

local ItemListClass = newClass("ItemListControl", "ListControl", function(self, anchor, x, y, width, height, itemsTab)
	self.ListControl(anchor, x, y, width, height, 16, false, true, itemsTab.itemOrderList)
	self.itemsTab = itemsTab
self.label = "^7所有装备:"
self.defaultText = "^x7F7F7F这里显示的是所有加入build的装备物品.\n你可以从下面的预设装备列表中拖拽装备到这里\n或者在查看装备的时候点击【加入Build】按钮放入这里"
	self.dragTargetList = { }
self.controls.delete = new("ButtonControl", {"BOTTOMRIGHT",self,"TOPRIGHT"}, 0, -2, 60, 18, "删除", function()
		self:OnSelDelete(self.selIndex, self.selValue)
	end)
	self.controls.delete.enabled = function()
		return self.selValue ~= nil
	end
self.controls.deleteAll = new("ButtonControl", {"RIGHT",self.controls.delete,"LEFT"}, -4, 0, 70, 18, "删除所有", function()
main:OpenConfirmPopup("Delete All", "你确定要删除这个build的所有装备?", "Delete", function()
			for _, slot in pairs(itemsTab.slots) do
				slot:SetSelItemId(0)
			end
			for _, spec in pairs(itemsTab.build.treeTab.specList) do
				for nodeId, itemId in pairs(spec.jewels) do
					spec.jewels[nodeId] = 0
				end
			end
			wipeTable(self.list)
			wipeTable(self.itemsTab.items)
			itemsTab:PopulateSlots()
			itemsTab:AddUndoState()
			itemsTab.build.buildFlag = true
			self.selIndex = nil
			self.selValue = nil
		end)
	end)
	self.controls.deleteAll.enabled = function()
		return #self.list > 0
	end
self.controls.sort = new("ButtonControl", {"RIGHT",self.controls.deleteAll,"LEFT"}, -4, 0, 60, 18, "排序", function()
		itemsTab:SortItemList()
	end)
end)

function ItemListClass:GetRowValue(column, index, itemId)
	local item = self.itemsTab.items[itemId]
	if column == 1 then
		local used = ""
		local slot, itemSet = self.itemsTab:GetEquippedSlotForItem(item)
		if not slot then
used = "  ^9(未使用)"
		elseif itemSet then
used = "  ^9(装备在 '" .. (itemSet.title or "Default") .. "')"
		end
		return colorCodes[item.rarity] .. item.name .. used
	end
end

function ItemListClass:AddValueTooltip(tooltip, index, itemId)
	if main.popups[1] then
		tooltip:Clear()
		return
	end
	local item = self.itemsTab.items[itemId]
	if tooltip:CheckForUpdate(item, IsKeyDown("SHIFT"), launch.devModeAlt, self.itemsTab.build.outputRevision) then
		self.itemsTab:AddItemTooltip(tooltip, item)
	end
end

function ItemListClass:GetDragValue(index, itemId)
	return "Item", self.itemsTab.items[itemId]
end

function ItemListClass:ReceiveDrag(type, value, source)
	if type == "Item" then
		local newItem = new("Item",  value.raw)
		newItem:NormaliseQuality()
		self.itemsTab:AddItem(newItem, true, self.selDragIndex)
		self.itemsTab:PopulateSlots()
		self.itemsTab:AddUndoState()
		self.itemsTab.build.buildFlag = true
	end
end

function ItemListClass:OnOrderChange()
	self.itemsTab:AddUndoState()
end

function ItemListClass:OnSelClick(index, itemId, doubleClick)
	local item = self.itemsTab.items[itemId]
	if IsKeyDown("CTRL") then
		local slotName = item:GetPrimarySlot()
		if slotName and self.itemsTab.slots[slotName] then
			if self.itemsTab.slots[slotName].weaponSet == 1 and self.itemsTab.activeItemSet.useSecondWeaponSet then
				-- Redirect to second weapon set
				slotName = slotName .. " Swap"
			end
			if IsKeyDown("SHIFT") then
				-- Redirect to second slot if possible
				local altSlot = slotName:gsub("1","2")
				if self.itemsTab:IsItemValidForSlot(item, altSlot) then
					slotName = altSlot
				end
			end
			if self.itemsTab.slots[slotName].selItemId == item.id then
				self.itemsTab.slots[slotName]:SetSelItemId(0)
			else
				self.itemsTab.slots[slotName]:SetSelItemId(item.id)
			end
			self.itemsTab:PopulateSlots()
			self.itemsTab:AddUndoState()
			self.itemsTab.build.buildFlag = true
		end
	elseif doubleClick then
		local newItem = new("Item",  item:BuildRaw())
		newItem.id = item.id
		self.itemsTab:SetDisplayItem(newItem)
	end
end

function ItemListClass:OnSelCopy(index, itemId)
	local item = self.itemsTab.items[itemId]
	Copy(item:BuildRaw():gsub("\n","\r\n"))
end

function ItemListClass:OnSelDelete(index, itemId)
	local item = self.itemsTab.items[itemId]
	local equipSlot, equipSet = self.itemsTab:GetEquippedSlotForItem(item)
	if equipSlot then
		local inSet = equipSet and (" in set '"..(equipSet.title or "Default").."'") or ""
main:OpenConfirmPopup("Delete Item", item.name.." 已经装备在了 "..equipSlot.label..inSet..".\n你确定要删除吗?", "删除", function()
			self.itemsTab:DeleteItem(item)
			self.selIndex = nil
			self.selValue = nil
		end)
	else
		self.itemsTab:DeleteItem(item)
		self.selIndex = nil
		self.selValue = nil
	end
end
