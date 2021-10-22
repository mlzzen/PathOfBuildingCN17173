-- Path of Building
--
-- Class: Item list
-- Shared item list control.
--
--local launch, main = ...

local pairs = pairs
local t_insert = table.insert
local t_remove = table.remove

local SharedItemListClass = newClass("SharedItemListControl", "ListControl", function(self, anchor, x, y, width, height, itemsTab)
	self.ListControl(anchor, x, y, width, height, 16, "VERTICAL", true, main.sharedItemList)
	self.itemsTab = itemsTab
self.label = "^7Build之间分享装备:"
self.defaultText = "^x7F7F7F这是一个装备列表，\n可以在你的所有Build之间分享你的装备。\n你可以从其他装备列表中拖放装备到\n这里列表中来."
	self.dragTargetList = { }
self.controls.delete = new("ButtonControl", {"BOTTOMRIGHT",self,"TOPRIGHT"}, 0, -2, 60, 18, "删除", function()
		self:OnSelDelete(self.selIndex, self.selValue)
	end)
	self.controls.delete.enabled = function()
		return self.selValue ~= nil
	end
end)

function SharedItemListClass:GetRowValue(column, index, item)
	if column == 1 then
		return colorCodes[item.rarity] .. item.name
	end
end


function SharedItemListClass:AddValueTooltip(tooltip, index, item)
	if main.popups[1] then
		tooltip:Clear()
		return
	end
	if tooltip:CheckForUpdate(item, IsKeyDown("SHIFT"), launch.devModeAlt, self.itemsTab.build.outputRevision) then
		self.itemsTab:AddItemTooltip(tooltip, item)
	end
end

function SharedItemListClass:GetDragValue(index, item)
	return "Item", item
end


function SharedItemListClass:ReceiveDrag(type, value, source)
	if type == "Item" then
		local rawItem = { raw = value:BuildRaw() }
		local newItem = new("Item", rawItem.raw)
		if not value.id then
			newItem:NormaliseQuality()
		end
		t_insert(self.list, self.selDragIndex or #self.list, newItem)
	end
end


function SharedItemListClass:OnSelClick(index, item, doubleClick)
	if doubleClick then
		self.itemsTab:CreateDisplayItemFromRaw(item.raw, true)
		self.selDragging = false
	end
end

function SharedItemListClass:OnSelCopy(index, item)
	Copy(item:BuildRaw():gsub("\n","\r\n"))
end

function SharedItemListClass:OnSelDelete(index, item)	
	main:OpenConfirmPopup("删除物品", "确定要从共享物品栏删除 '"..item.name.."' 吗?", "删除", function()
		t_remove(self.list, index)
		self.selIndex = nil
		self.selValue = nil
	end)
end
