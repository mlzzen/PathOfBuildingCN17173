-- Path of Building
--
-- Class: Timeless Jewel List Control
-- Specialized UI element for listing and generating Timeless Jewels with specific seeds.
--

local m_random = math.random
local m_min = math.min
local m_max = math.max
local t_concat = table.concat

local TimelessJewelListControlClass = newClass("TimelessJewelListControl", "ListControl", function(self, anchor, x, y, width, height, build)
	self.build = build
	self.sharedList = self.build.timelessData.sharedResults or { }
	self.list = self.build.timelessData.searchResults or { }
	self.ListControl(anchor, x, y, width, height, 16, true, false, self.list)
	self.selIndex = nil
end)

function TimelessJewelListControlClass:Draw(viewPort, noTooltip)
	self.noTooltip = noTooltip
	self.ListControl.Draw(self, viewPort)
end

function TimelessJewelListControlClass:SetHighlightColor(index, value)
	if not self.highlightIndex or not self.selIndex then
		return false
	end
	local isHighlighted = m_min(self.selIndex, self.highlightIndex) <= index and m_max(self.selIndex, self.highlightIndex) >= index

	if isHighlighted then
		if self.selIndex == index or self.highlightIndex == index then
			SetDrawColor(1, 0.5, 0)
		else
			SetDrawColor(1, 1, 0)
		end

		return true
	end

	return false
end

function TimelessJewelListControlClass:OverrideSelectIndex(index)
	if IsKeyDown("SHIFT") and self.selIndex then
		self.highlightIndex = index
		return true
	else
		self.highlightIndex = nil
	end

	return false
end

function TimelessJewelListControlClass:GetRowValue(column, index, data)
	if column == 1 then
		return data.label
	end
end

function TimelessJewelListControlClass:AddValueTooltip(tooltip, index, data)
	tooltip:Clear()
	if not self.noTooltip then
		if self.list[index].label:match("B2B2B2") == nil then
			tooltip:AddLine(16, "^7双击将该珠宝加入BD中.")
		else
			tooltip:AddLine(16, "^7" .. self.sharedList.type.label .. " " .. data.seed .. " 成功加入了你的BD中.")
		end
		local treeData = self.build.spec.tree
		local sortedNodeLists = { }
		for legionId, desiredNode in pairs(self.sharedList.desiredNodes) do
			if self.list[index][legionId] then
				if self.list[index][legionId].targetNodeNames and #self.list[index][legionId].targetNodeNames > 0 then
					sortedNodeLists[desiredNode.desiredIdx] = "^7        " .. desiredNode.displayName .. ":\n^8                " .. t_concat(self.list[index][legionId].targetNodeNames, "\n                ")
				else
					sortedNodeLists[desiredNode.desiredIdx] = "^7        " .. desiredNode.displayName .. ":\n^8                None"
				end
			end
		end
		if next(sortedNodeLists) then
			tooltip:AddLine(16, "^7天赋点列表:")
			for _, sortedNodeList in pairs(sortedNodeLists) do
				tooltip:AddLine(16, sortedNodeList)
			end
		end
		if data.total > 0 then
			tooltip:AddLine(16, "^7合计节点权重: " .. data.total)
		end
	end
end

function TimelessJewelListControlClass:OnSelClick(index, data, doubleClick)
	if doubleClick and self.list[index].label:match("B2B2B2") == nil then
		local label = "[" .. data.seed .. "; " .. data.total.. "; " .. self.sharedList.socket.keystone .. "]\n"
		local variant = self.sharedList.conqueror.id == 1 and 1 or (self.sharedList.conqueror.id - 1) .. "\n"
		local itemData = [[
优雅的狂妄 ]] .. label .. [[
永恒珠宝
联盟: 战乱之殇
等级需求: 20
仅限: 1
版本: 卡迪罗 (无上衰败)
版本: 维多里奥 (无上之秀)
版本: 卡斯皮罗 (无上宣示)
Selected Variant:  ]] .. variant .. "\n" .. [[
范围: 大
固定基底词缀: 0
{variant:1}用 ]] .. data.seed .. [[ 枚金币纪念卡迪罗
{variant:2}用 ]] .. data.seed .. [[ 枚金币纪念维多里奥
{variant:3}用 ]] .. data.seed .. [[ 枚金币纪念卡斯皮罗
范围内的天赋被永恒帝国抑制
史实
]]
		if self.sharedList.type.id == 1 then
			itemData = [[
光彩夺目 ]] .. label .. [[
永恒珠宝
联盟: 战乱之殇
等级需求: 20
仅限: 1
版本: 多里亚尼 (腐化的灵魂)
版本: 夏巴夸亚 (神圣血肉)
版本: 阿华纳 (不朽野望)
Selected Variant: ]] .. variant .. "\n" ..[[
范围: 大
固定基底词缀: 0
{variant:1}以多里亚尼的名义用 ]] .. data.seed .. [[ 名祭品之血浸染
{variant:2}以夏巴夸亚的名义用 ]] .. data.seed .. [[ 名祭品之血浸染
{variant:3}以阿华纳的名义用 ]] .. data.seed .. [[ 名祭品之血浸染
范围内的天赋被瓦尔抑制
史实
]]
		elseif self.sharedList.type.id == 2 then
			itemData = [[
致命的骄傲 ]] .. label .. [[
永恒珠宝
联盟: 战乱之殇
等级需求: 20
仅限: 1
版本: 冈姆 (鲜血之力)
版本: 拉凯尔塔 (战争锤炼)
版本: 阿克雅 (破枷除锁)
Selected Variant: ]] .. variant .. "\n" .. [[
范围: 大
固定基底词缀: 0
{variant:1}获得冈姆麾下 ]] .. data.seed .. [[ 名武士的领导权
{variant:2}获得拉凯尔塔麾下 ]] .. data.seed .. [[ 名武士的领导权
{variant:3}获得阿克雅麾下 ]] .. data.seed .. [[ 名武士的领导权
范围内的天赋被卡鲁抑制
史实
]]
		elseif self.sharedList.type.id == 3 then
			itemData = [[
残酷的约束 ]] .. label .. [[
永恒珠宝
联盟: 战乱之殇
等级需求: 20
仅限: 1
版本: 安赛娜丝 (与亡共舞)
版本: 娜斯玛 (慧眼)
版本: 巴巴拉 (叛徒)
Selected Variant: ]] .. variant .. "\n" .. [[
范围: 大
仅限: 1
{variant:1}在安赛娜丝的阿卡拉中指派 ]] .. data.seed .. [[ 名德卡拉的服务
{variant:2}在娜斯玛的阿卡拉中指派 ]] .. data.seed .. [[ 名德卡拉的服务
{variant:3}在巴巴拉的阿卡拉中指派 ]] .. data.seed .. [[ 名德卡拉的服务
范围中的天赋被马拉克斯抑制
史实
]]
		elseif self.sharedList.type.id == 4 then
			local altVariant = m_random(4, 17)
			local altVariant2 = m_random(4, 17)
			if altVariant == altVariant2 then
				altVariant = altVariant + 1
			end
			itemData = [[
好战的信仰 ]] .. label .. [[
永恒珠宝
联盟: 战乱之殇
等级需求: 20
仅限: 1
Has Alt Variant: true
Has Alt Variant Two: true
版本: 阿瓦留斯 (决心之力)
版本: 多米纳斯 (内在信念)
版本: 玛萨留斯 (超然飞升)
版本: 图腾伤害
版本: 烙印伤害
版本: 吟唱技能伤害
版本: 范围伤害
版本: 元素伤害
版本: 元素抗性
版本: 非伤害异常效果
版本: 自身异常时间缩短
版本: 自身诅咒时间缩短
版本: 召唤物速度
版本: 召唤物命中
版本: 魔力回复
版本: 魔力消耗
版本: 光环效果
版本: 盾牌防御
Selected Variant: ]] .. variant .. "\n" .. [[
Selected Alt Variant: ]] .. altVariant .. "\n" .. [[
Selected Alt Variant Two: ]] .. altVariant2 .. "\n" .. [[
范围: 大
固定基底词缀: 0
{variant:1}赞美 ]] .. data.seed .. [[ 名被神主阿瓦留斯转化的新信徒
{variant:2}赞美 ]] .. data.seed .. [[ 名被神主多米纳斯转化的新信徒
{variant:3}赞美 ]] .. data.seed .. [[ 名被神主玛萨留斯转化的新信徒
{variant:4}每 10 点奉献使图腾伤害提高 4%
{variant:5}每 10 点奉献使烙印技能伤害提高 4%
{variant:6}每 10 点奉献使持续吟唱技能的伤害提高 4%
{variant:7}每 10 点奉献可使范围伤害提高 4%
{variant:8}每 10 点奉献使元素伤害提高 4%
{variant:9}每 10 点奉献 +2% 点所有元素抗性
{variant:10}每 10 点奉献使对敌人施加的非伤害异常状态效果提高 3%
{variant:11}每 10 点奉献使自身受到的元素异常时间缩短 4%
{variant:12}每 10 点奉献使自身受到诅咒的持续时间缩短 4%
{variant:13}每 10 点奉献使召唤生物攻击和施法速度提高 1%
{variant:14}每 10 点奉献使召唤生物的命中值 +60
{variant:15}每 10 点奉献 使魔力回复 0.6
{variant:16}每 10 点奉献使技能魔力消耗降低 1%
{variant:17}每 10 点奉献使非诅咒类光环效果提高 1%
{variant:18}每 10 点奉献使盾牌获取的防御提高 3%
范围内的天赋被圣堂抑制
史实
]]
		end
		local item = new("Item", itemData)
		self.build.itemsTab:AddItem(item, true)
		self.build.itemsTab:PopulateSlots()
		self.list[index].label = "^xB2B2B2" .. self.list[index].label
	end
end
