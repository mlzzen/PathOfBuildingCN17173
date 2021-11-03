﻿local version = "3_16"
local treeFilePathCn = "D:/Projects/POE/PathOfBuildingCN17173-Dev-1/TreeData/"
local treeFilePathEn = "D:/Projects/POE/PathOfBuilding/src/TreeData/"

local treeDataCn = dofile(treeFilePathCn..version.."/tree.lua")
local treeDataEn = dofile(treeFilePathEn..version.."/tree.lua")
local translation = {}

local nodesCn = treeDataCn['nodes']
local nodesEn = treeDataEn['nodes']
for key, value in pairs(nodesCn) do
    local nodeCn = value
    local nodeEn = nodesEn[key]
    if nodeCn["isMastery"] and nodeCn["masteryEffects"] and nodeEn["masteryEffects"] then
        local masteriesCn = nodeCn["masteryEffects"]
        local masteriesEn = nodeEn["masteryEffects"]
        for key, value in pairs(masteriesCn) do
            local statCn = value["stats"][1]
            local statEn = masteriesEn[key]["stats"][1]
            translation[statCn] = statEn
        end
    else
        if nodeCn["stats"] then
            local statsEn = nodeEn["stats"]
            for i, line in pairs(nodeCn["stats"]) do
                if not string.find(line, "\n") and not string.find(statsEn[i], "\n") then
                    translation[line] = statsEn[i]
                end
            end
        end
    end
end

local out = io.open(treeFilePathCn..version.."/translation.lua", "w")
out:write('-- This file is automatically generated, do not edit!\n')
out:write('return {\n')
for key, value in pairs(translation) do
    out:write('\t["', key, '"] = "', value, '", \n')
end
out:write('}')
out:close()