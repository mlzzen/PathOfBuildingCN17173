-- Dat View
--
-- Class: GGPK Data
-- GGPK Data
--
local ipairs = ipairs
local t_insert = table.insert

local function scanDir(directory, extension)
	local i = 0
	local t = { }
	local pFile = io.popen('dir "'..directory..'" /b')
	for filename in pFile:lines() do
		--ConPrintf("%s\n", filename)
		if extension then
			if filename:match(extension) then
				i = i + 1
				t[i] = filename
			else
				--ConPrintf("No Files Found matching extension '%s'", extension)
			end
		else
			i = i + 1
			t[i] = filename
		end
	end
	pFile:close()
	return t
end

-- Path can be in any format recognized by the extractor at oozPath, ie,
-- a .ggpk file or a Steam Path of Exile directory
local GGPKClass = newClass("GGPKData", function(self, path)
	self.path = path
	self.temp = io.popen("cd"):read('*l')
	self.oozPath = self.temp .. "\\ggpk\\"

	self.dat = { }
	self.txt = { }
	
	self:ExtractFiles()
	
	if USE_DAT64 then
		self:AddDat64Files()
	else
		self:AddDatFiles()
	end
end)

function GGPKClass:ExtractFiles()
	local datList, txtList, otList = self:GetNeededFiles()
	
	local fileList = ''
	for _, fname in ipairs(datList) do
		if USE_DAT64 then
			fileList = fileList .. '"' .. fname .. '64" '
		else
			fileList = fileList .. '"' .. fname .. '" '
		end
	end
	for _, fname in ipairs(txtList) do
		fileList = fileList .. '"' .. fname .. '" '
	end
	for _, fname in ipairs(otList) do
		fileList = fileList .. '"' .. fname .. '" '
	end
	
	local cmd = 'cd ' .. self.oozPath .. ' && bun_extract_file.exe extract-files "' .. self.path .. '" . ' .. fileList
	ConPrintf(cmd)
	os.execute(cmd)
end

function GGPKClass:AddDatFiles()
	-- local datFiles = scanDir(self.oozPath .. "Data\\", '%w+%.dat$')
	local datFiles = scanDir(self.oozPath .. "Data\\Simplified Chinese\\", '%w+%.dat$')
	for _, f in ipairs(datFiles) do
		local record = { }
		record.name = f
		-- local rawFile = io.open(self.oozPath .. "Data\\" .. f, 'rb')
		local rawFile = io.open(self.oozPath .. "Data\\Simplified Chinese\\" .. f, 'rb')
		record.data = rawFile:read("*all")
		rawFile:close()
		--ConPrintf("FILENAME: %s", fname)
		t_insert(self.dat, record)
	end
end

function GGPKClass:AddDat64Files()
	--local datFiles = scanDir(self.oozPath .. "Data\\", '%w+%.dat64$')
	local datFiles = scanDir(self.oozPath .. "Data\\Simplified Chinese\\", '%w+%.dat64$')
	for _, f in ipairs(datFiles) do
		local record = { }
		record.name = f
		-- local rawFile = io.open(self.oozPath .. "Data\\" .. f, 'rb')
		local rawFile = io.open(self.oozPath .. "Data\\Simplified Chinese\\" .. f, 'rb')
		record.data = rawFile:read("*all")
		rawFile:close()
		--ConPrintf("FILENAME: %s", fname)
		t_insert(self.dat, record)
	end
end

function GGPKClass:GetNeededFiles()
	local datFiles = {
		"Data/Stats.dat",
		"Data/BaseItemTypes.dat",
		"Data/WeaponTypes.dat",
		"Data/ArmourTypes.dat",
		"Data/ShieldTypes.dat",
		"Data/Flasks.dat",
		"Data/ComponentCharges.dat",
		"Data/ComponentAttributeRequirements.dat",
		"Data/PassiveSkills.dat",
		"Data/PassiveSkillBuffs.dat",
		"Data/PassiveTreeExpansionJewelSizes.dat",
		"Data/PassiveTreeExpansionJewels.dat",
		"Data/PassiveJewelSlots.dat",
		"Data/PassiveTreeExpansionSkills.dat",
		"Data/PassiveTreeExpansionSpecialSkills.dat",
		"Data/Mods.dat",
		"Data/ModType.dat",
		"Data/ModDomains.dat",
		"Data/ModGenerationType.dat",
		"Data/ModFamily.dat",
		"Data/ModAuraFlags.dat",
		"Data/ActiveSkills.dat",
		"Data/ActiveSkillTargetTypes.dat",
		"Data/ActiveSkillType.dat",
		"Data/Ascendancy.dat",
		"Data/ClientStrings.dat",
		"Data/ItemClasses.dat",
		"Data/SkillTotems.dat",
		"Data/SkillTotemVariations.dat",
		"Data/SkillMines.dat",
		"Data/Essences.dat",
		"Data/EssenceType.dat",
		"Data/Characters.dat",
		"Data/BuffDefinitions.dat",
		"Data/BuffCategories.dat",
		"Data/BuffVisuals.dat",
		"Data/HideoutNPCs.dat",
		"Data/NPCs.dat",
		"Data/CraftingBenchOptions.dat",
		"Data/CraftingItemClassCategories.dat",
		"Data/CraftingBenchUnlockCategories.dat",
		"Data/MonsterVarieties.dat",
		"Data/MonsterResistances.dat",
		"Data/MonsterTypes.dat",
		"Data/DefaultMonsterStats.dat",
		"Data/SkillGems.dat",
		"Data/GrantedEffects.dat",
		"Data/GrantedEffectsPerLevel.dat",
		"Data/ItemExperiencePerLevel.dat",
		"Data/EffectivenessCostConstants.dat",
		"Data/StatInterpolationTypes.dat",
		"Data/Tags.dat",
		"Data/GemTags.dat",
		"Data/ItemVisualIdentity.dat",
		"Data/AchievementItems.dat",
		"Data/MultiPartAchievements.dat",
		"Data/PantheonPanelLayout.dat",
		"Data/AlternatePassiveAdditions.dat",
		"Data/AlternatePassiveSkills.dat",
		"Data/AlternateTreeVersions.dat",
		"Data/GrantedEffectQualityTypes.dat",
		"Data/GrantedEffectQualityStats.dat",
		"Data/GrantedEffectGroups.dat",
		"Data/AegisVariations.dat",
		"Data/CostTypes.dat"
	}
	local datFilesCn = {
		"Data/Simplified Chinese/Stats.dat",
		"Data/Simplified Chinese/BaseItemTypes.dat",
		"Data/Simplified Chinese/WeaponTypes.dat",
		"Data/Simplified Chinese/ArmourTypes.dat",
		"Data/Simplified Chinese/ShieldTypes.dat",
		"Data/Simplified Chinese/Flasks.dat",
		"Data/Simplified Chinese/ComponentCharges.dat",
		"Data/Simplified Chinese/ComponentAttributeRequirements.dat",
		"Data/Simplified Chinese/PassiveSkills.dat",
		"Data/Simplified Chinese/PassiveSkillBuffs.dat",
		"Data/Simplified Chinese/PassiveTreeExpansionJewelSizes.dat",
		"Data/Simplified Chinese/PassiveTreeExpansionJewels.dat",
		"Data/Simplified Chinese/PassiveJewelSlots.dat",
		"Data/Simplified Chinese/PassiveTreeExpansionSkills.dat",
		"Data/Simplified Chinese/PassiveTreeExpansionSpecialSkills.dat",
		"Data/Simplified Chinese/Mods.dat",
		"Data/Simplified Chinese/ModType.dat",
		"Data/Simplified Chinese/ModDomains.dat",
		"Data/Simplified Chinese/ModGenerationType.dat",
		"Data/Simplified Chinese/ModFamily.dat",
		"Data/Simplified Chinese/ModAuraFlags.dat",
		"Data/Simplified Chinese/ActiveSkills.dat",
		"Data/Simplified Chinese/ActiveSkillTargetTypes.dat",
		"Data/Simplified Chinese/ActiveSkillType.dat",
		"Data/Simplified Chinese/Ascendancy.dat",
		"Data/Simplified Chinese/ClientStrings.dat",
		"Data/Simplified Chinese/ItemClasses.dat",
		"Data/Simplified Chinese/SkillTotems.dat",
		"Data/Simplified Chinese/SkillTotemVariations.dat",
		"Data/Simplified Chinese/SkillMines.dat",
		"Data/Simplified Chinese/Essences.dat",
		"Data/Simplified Chinese/EssenceType.dat",
		"Data/Simplified Chinese/Characters.dat",
		"Data/Simplified Chinese/BuffDefinitions.dat",
		"Data/Simplified Chinese/BuffCategories.dat",
		"Data/Simplified Chinese/BuffVisuals.dat",
		"Data/Simplified Chinese/HideoutNPCs.dat",
		"Data/Simplified Chinese/NPCs.dat",
		"Data/Simplified Chinese/CraftingBenchOptions.dat",
		"Data/Simplified Chinese/CraftingItemClassCategories.dat",
		"Data/Simplified Chinese/CraftingBenchUnlockCategories.dat",
		"Data/Simplified Chinese/MonsterVarieties.dat",
		"Data/Simplified Chinese/MonsterResistances.dat",
		"Data/Simplified Chinese/MonsterTypes.dat",
		"Data/Simplified Chinese/DefaultMonsterStats.dat",
		"Data/Simplified Chinese/SkillGems.dat",
		"Data/Simplified Chinese/GrantedEffects.dat",
		"Data/Simplified Chinese/GrantedEffectsPerLevel.dat",
		"Data/Simplified Chinese/ItemExperiencePerLevel.dat",
		"Data/Simplified Chinese/EffectivenessCostConstants.dat",
		"Data/Simplified Chinese/StatInterpolationTypes.dat",
		"Data/Simplified Chinese/Tags.dat",
		"Data/Simplified Chinese/GemTags.dat",
		"Data/Simplified Chinese/ItemVisualIdentity.dat",
		"Data/Simplified Chinese/AchievementItems.dat",
		"Data/Simplified Chinese/MultiPartAchievements.dat",
		"Data/Simplified Chinese/PantheonPanelLayout.dat",
		"Data/Simplified Chinese/AlternatePassiveAdditions.dat",
		"Data/Simplified Chinese/AlternatePassiveSkills.dat",
		"Data/Simplified Chinese/AlternateTreeVersions.dat",
		"Data/Simplified Chinese/GrantedEffectQualityTypes.dat",
		"Data/Simplified Chinese/GrantedEffectQualityStats.dat",
		"Data/Simplified Chinese/GrantedEffectGroups.dat",
		"Data/Simplified Chinese/AegisVariations.dat",
		"Data/Simplified Chinese/CostTypes.dat"
	}
	local txtFiles = {
		"Metadata/StatDescriptions/passive_skill_aura_stat_descriptions.txt",
		"Metadata/StatDescriptions/passive_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/active_skill_gem_stat_descriptions.txt",
		"Metadata/StatDescriptions/advanced_mod_stat_descriptions.txt",
		"Metadata/StatDescriptions/aura_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/banner_aura_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/beam_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/brand_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/buff_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/curse_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/debuff_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/secondary_debuff_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/gem_stat_descriptions.txt",
		"Metadata/StatDescriptions/minion_attack_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/minion_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/minion_spell_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/minion_spell_damage_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/monster_stat_descriptions.txt",
		"Metadata/StatDescriptions/offering_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/single_minion_spell_skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/skillpopup_stat_filters.txt",
		"Metadata/StatDescriptions/skill_stat_descriptions.txt",
		"Metadata/StatDescriptions/stat_descriptions.txt",
		"Metadata/StatDescriptions/variable_duration_skill_stat_descriptions.txt",
	}
	local otFiles = {
		"Metadata/Items/Quivers/AbstractQuiver.ot",
		"Metadata/Items/Rings/AbstractRing.ot",
		"Metadata/Items/Belts/AbstractBelt.ot",
		"Metadata/Items/Flasks/AbstractUtilityFlask.ot",
		"Metadata/Items/Jewels/AbstractJewel.ot",
		"Metadata/Items/Flasks/CriticalUtilityFlask.ot",
		"Metadata/Items/Flasks/AbstractHybridFlask.ot",
		"Metadata/Items/Flasks/AbstractManaFlask.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/Staves/AbstractWarstaff.ot",
		"Metadata/Items/Weapons/OneHandWeapons/OneHandMaces/AbstractSceptre.ot",
		"Metadata/Items/Weapons/OneHandWeapons/OneHandSwords/AbstractOneHandSwordThrusting.ot",
		"Metadata/Items/Weapons/OneHandWeapons/Claws/AbstractClaw.ot",
		"Metadata/Items/Armours/Shields/AbstractShield.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/Bows/AbstractBow.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/FishingRods/AbstractFishingRod.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/TwoHandMaces/AbstractTwoHandMace.ot",
		"Metadata/Items/Armours/Boots/AbstractBoots.ot",
		"Metadata/Items/Jewels/AbstractAbyssJewel.ot",
		"Metadata/Items/Armours/BodyArmours/AbstractBodyArmour.ot",
		"Metadata/Items/Armours/AbstractArmour.ot",
		"Metadata/Items/Weapons/OneHandWeapons/Daggers/AbstractRuneDagger.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/Staves/AbstractStaff.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/TwoHandAxes/AbstractTwoHandAxe.ot",
		"Metadata/Items/Weapons/OneHandWeapons/OneHandAxes/AbstractOneHandAxe.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/TwoHandSwords/AbstractTwoHandSword.ot",
		"Metadata/Items/Weapons/OneHandWeapons/OneHandMaces/AbstractOneHandMace.ot",
		"Metadata/Items/Armours/Gloves/AbstractGloves.ot",
		"Metadata/Items/Weapons/OneHandWeapons/Daggers/AbstractDagger.ot",
		"Metadata/Items/Weapons/OneHandWeapons/OneHandSwords/AbstractOneHandSword.ot",
		"Metadata/Items/Amulets/AbstractAmulet.ot",
		"Metadata/Items/Flasks/AbstractLifeFlask.ot",
		"Metadata/Items/Weapons/OneHandWeapons/Wands/AbstractWand.ot",
		"Metadata/Items/Armours/Helmets/AbstractHelmet.ot",
		"Metadata/Items/Flasks/AbstractFlask.ot",
		"Metadata/Items/Weapons/TwoHandWeapons/AbstractTwoHandWeapon.ot",
		"Metadata/Items/Item.ot",
		"Metadata/Items/Weapons/OneHandWeapons/AbstractOneHandWeapon.ot",
		"Metadata/Items/Equipment.ot",
		"Metadata/Items/Weapons/AbstractWeapon.ot",
	}
	-- return datFiles, txtFiles, otFiles
	return datFilesCn, txtFiles, otFiles
end
