---
--- Programmatically generated uniques live here.
--- Some uniques have to be generated because the amount of variable mods makes it infeasible to implement them manually.
--- As a result, they are forward compatible to some extent as changes to the variable mods are picked up automatically.
---

data.uniques.generated = { }

function buildTreeDependentUniques(tree)
	buildForbidden(tree.classNotables)
end

function buildForbidden(classNotables)
	local forbidden = { }
	for _, name in pairs({"之火", "之肉"}) do
		forbidden[name] = { }
		table.insert(forbidden[name], "禁断" .. name)
		table.insert(forbidden[name], "三相珠宝")
		local index = 1
		for className, notableTable in pairs(classNotables) do
			for _, notableName in ipairs(notableTable) do
				table.insert(forbidden[name], "版本: (" .. className .. ") " .. notableName)
				index = index + 1
			end
		end
		table.insert(forbidden[name], "仅限: 1")
		table.insert(forbidden[name], "等级需求: 83")
		index = 1
		for className, notableTable in pairs(classNotables) do
			for _, notableName in ipairs(notableTable) do
				table.insert(forbidden[name], "{variant:" .. index .. "}" .. "需求 职业: " .. className)
				table.insert(forbidden[name], "{variant:" .. index .. "}" .. "禁断" .. (name == "之火" and "之肉" or "之火") .. "上有匹配的词缀则配置 ".. notableName)
				index = index + 1
			end
		end
		table.insert(forbidden[name], "已腐化")
	end
	table.insert(data.uniques.generated, table.concat(forbidden["之火"], "\n"))
	table.insert(data.uniques.generated, table.concat(forbidden["之肉"], "\n"))
end