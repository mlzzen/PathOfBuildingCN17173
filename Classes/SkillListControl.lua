-- Path of Building
--
-- Class: Skill List
-- Skill list control.
--
--local launch, main = ...

local ipairs = ipairs
local t_insert = table.insert
local t_remove = table.remove

local SkillListClass = newClass("SkillListControl", "ListControl", function(self, anchor, x, y, width, height, skillsTab)
	self.ListControl(anchor, x, y, width, height, 16, false, true, skillsTab.socketGroupList)
	self.skillsTab = skillsTab
self.label = "^7技能组:"
self.controls.delete = new("ButtonControl", {"BOTTOMRIGHT",self,"TOPRIGHT"}, 0, -2, 60, 18, "删除", function()
		self:OnSelDelete(self.selIndex, self.selValue)
	end)
	self.controls.delete.enabled = function()
		return self.selValue ~= nil and self.selValue.source == nil
	end
self.controls.deleteAll = new("ButtonControl", {"RIGHT",self.controls.delete,"LEFT"}, -4, 0, 70, 18, "全部删除", function()
main:OpenConfirmPopup("Delete All", "你确定删除这个build的所有技能组吗?", "删除", function()
			wipeTable(self.list)
			skillsTab:SetDisplayGroup()
			skillsTab:AddUndoState()
			skillsTab.build.buildFlag = true
			self.selIndex = nil
			self.selValue = nil
		end)
	end)
	self.controls.deleteAll.enabled = function()
		return #self.list > 0 
	end
self.controls.new = new("ButtonControl", {"RIGHT",self.controls.deleteAll,"LEFT"}, -4, 0, 60, 18, "新建", function()
		local newGroup = { 
			label = "", 
			enabled = true, 
			gemList = { } 
		}
		t_insert(self.list, newGroup)
		self.selIndex = #self.list
		self.selValue = newGroup
		skillsTab:SetDisplayGroup(newGroup)
		skillsTab:AddUndoState()
		skillsTab.build.buildFlag = true
		return skillsTab.gemSlots[1].nameSpec
	end)
end)

function SkillListClass:GetRowValue(column, index, socketGroup)
	if column == 1 then
		local label = socketGroup.displayLabel or "?"
		if not socketGroup.enabled or not socketGroup.slotEnabled then
label = "^x7F7F7F" .. label .. " (已禁用)"
		end
		return label
	end
end

function SkillListClass:AddValueTooltip(tooltip, index, socketGroup)
	if not socketGroup.displaySkillList then
		tooltip:Clear()
		return
	end
	if tooltip:CheckForUpdate(socketGroup, self.skillsTab.build.outputRevision) then
		self.skillsTab:AddSocketGroupTooltip(tooltip, socketGroup)
	end
end

function SkillListClass:OnOrderChange()
	self.skillsTab:AddUndoState()
	self.skillsTab.build.buildFlag = true
end

function SkillListClass:OnSelect(index, socketGroup)
	self.skillsTab:SetDisplayGroup(socketGroup)
end

function SkillListClass:OnSelCopy(index, socketGroup)
	if not socketGroup.source then	
		self.skillsTab:CopySocketGroup(socketGroup)
	end
end

function SkillListClass:OnSelDelete(index, socketGroup)
	if socketGroup.source then
main:OpenMessagePopup("【删除技能组】", "装备自带的技能不能删除")
	elseif not socketGroup.gemList[1] then
		t_remove(self.list, index)
		if self.skillsTab.displayGroup == socketGroup then
			self.skillsTab.displayGroup = nil
		end
		self.skillsTab:AddUndoState()
		self.skillsTab.build.buildFlag = true
		self.selValue = nil
	else
main:OpenConfirmPopup("【删除技能组】", "确定要删除这组技能： '"..socketGroup.displayLabel.."'?", "删除", function()
			t_remove(self.list, index)
			if self.skillsTab.displayGroup == socketGroup then
				self.skillsTab:SetDisplayGroup()
			end
			self.skillsTab:AddUndoState()
			self.skillsTab.build.buildFlag = true
			self.selValue = nil
		end)
	end
end
