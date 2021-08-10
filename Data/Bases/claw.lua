-- This file is automatically generated, do not edit!
-- Item data (c) Grinding Gear Games
local itemBases = ...

itemBases["拳钉"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +3 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 4, PhysicalMax = 11, CritChanceBase = 6.2, AttackRateBase = 1.6, Range = 11, },
	req = { dex = 11, int = 11, },
}
itemBases["鲨颚爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +6 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 6, PhysicalMax = 17, CritChanceBase = 6.5, AttackRateBase = 1.5, Range = 11, },
	req = { level = 7, dex = 14, int = 20, },
}
itemBases["凿钉"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +7 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 7, PhysicalMax = 23, CritChanceBase = 6.3, AttackRateBase = 1.55, Range = 11, },
	req = { level = 12, dex = 25, int = 25, },
}
itemBases["猫爪刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +8 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 12, PhysicalMax = 22, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 17, dex = 39, int = 27, },
}
itemBases["袭眼钩"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +12 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 12, PhysicalMax = 31, CritChanceBase = 6.3, AttackRateBase = 1.55, Range = 11, },
	req = { level = 22, dex = 41, int = 41, },
}
itemBases["远古战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +19 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 16, PhysicalMax = 43, CritChanceBase = 6.5, AttackRateBase = 1.3, Range = 11, },
	req = { level = 26, dex = 39, int = 56, },
}
itemBases["眩目爪刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +15 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 14, PhysicalMax = 38, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 30, dex = 64, int = 44, },
}
itemBases["恐惧之爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +20 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 12, PhysicalMax = 46, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 34, dex = 61, int = 61, },
}
itemBases["双刃爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { maraketh = true, onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +15 生命\n攻击击中每个敌人会回复 +6 魔力",
	implicitModTypes = { { "resource", "life", "mana", "attack" }, { "resource", "life", "mana", "attack" }, },
	weapon = { PhysicalMin = 15, PhysicalMax = 44, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 36, dex = 67, int = 67, },
}
itemBases["撕裂尖爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +25 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 20, PhysicalMax = 53, CritChanceBase = 6.5, AttackRateBase = 1.3, Range = 11, },
	req = { level = 37, dex = 53, int = 77, },
}
itemBases["穿体凿"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +24 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 15, PhysicalMax = 51, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 40, dex = 70, int = 70, },
}
itemBases["虎爪刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 1.6% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 23, PhysicalMax = 43, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 43, dex = 88, int = 61, },
}
itemBases["裂脏钩"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +44 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 20, PhysicalMax = 53, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 46, dex = 80, int = 80, },
}
itemBases["史前战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 2% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 26, PhysicalMax = 68, CritChanceBase = 6.5, AttackRateBase = 1.3, Range = 11, },
	req = { level = 49, dex = 69, int = 100, },
}
itemBases["贵族战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +40 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 21, PhysicalMax = 56, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 52, dex = 105, int = 73, },
}
itemBases["鹰爪刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 2% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 17, PhysicalMax = 69, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 55, dex = 94, int = 94, },
}
itemBases["重刃爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { maraketh = true, onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +28 生命\n攻击击中每个敌人会回复 +10 魔力",
	implicitModTypes = { { "resource", "life", "mana", "attack" }, { "resource", "life", "mana", "attack" }, },
	weapon = { PhysicalMin = 21, PhysicalMax = 64, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 57, dex = 103, int = 103, },
}
itemBases["白灵之爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +46 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 30, PhysicalMax = 78, CritChanceBase = 6.5, AttackRateBase = 1.3, Range = 11, },
	req = { level = 58, dex = 81, int = 117, },
}
itemBases["刺喉刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +40 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 21, PhysicalMax = 73, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 60, dex = 113, int = 113, },
}
itemBases["魔爪刃"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 1.6% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 29, PhysicalMax = 55, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 62, dex = 131, int = 95, },
}
itemBases["刺眼钩"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +50 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 26, PhysicalMax = 68, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 64, dex = 113, int = 113, },
}
itemBases["瓦尔战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 2% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 29, PhysicalMax = 76, CritChanceBase = 6.5, AttackRateBase = 1.3, Range = 11, },
	req = { level = 66, dex = 95, int = 131, },
}
itemBases["帝国战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +46 生命",
	implicitModTypes = { { "resource", "life", "attack" }, },
	weapon = { PhysicalMin = 25, PhysicalMax = 65, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 68, dex = 131, int = 95, },
}
itemBases["恐惧之牙"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "物理攻击伤害的 2% 会转化为生命偷取",
	implicitModTypes = { { "resource", "life", "physical", "attack" }, },
	weapon = { PhysicalMin = 18, PhysicalMax = 71, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 70, dex = 113, int = 113, },
}
itemBases["双子战爪"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { maraketh = true, onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "攻击击中每个敌人会回复 +38 生命\n攻击击中每个敌人会回复 +14 魔力",
	implicitModTypes = { { "resource", "life", "mana", "attack" }, { "resource", "life", "mana", "attack" }, },
	weapon = { PhysicalMin = 23, PhysicalMax = 68, CritChanceBase = 6.3, AttackRateBase = 1.5, Range = 11, },
	req = { level = 72, dex = 121, int = 121, },
}
itemBases["暗影之牙"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "附加 (23-33) - (45-60) 基础混沌伤害",
	implicitModTypes = { { "chaos_damage", "damage", "chaos", "attack" }, },
	weapon = { PhysicalMin = 13, PhysicalMax = 24, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 30, dex = 54, int = 54, },
}
itemBases["恶毒之牙"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "附加 (38-48) - (70-90) 基础混沌伤害",
	implicitModTypes = { { "chaos_damage", "damage", "chaos", "attack" }, },
	weapon = { PhysicalMin = 20, PhysicalMax = 37, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 50, dex = 86, int = 86, },
}
itemBases["虚空之牙"] = {
	type = "Claw",
	socketLimit = 3,
	tags = { onehand = true, not_for_sale = true, default = true, weapon = true, one_hand_weapon = true, claw = true, },
	implicit = "附加 (40-55) - (80-98) 基础混沌伤害",
	implicitModTypes = { { "chaos_damage", "damage", "chaos", "attack" }, },
	weapon = { PhysicalMin = 22, PhysicalMax = 41, CritChanceBase = 6, AttackRateBase = 1.6, Range = 11, },
	req = { level = 70, dex = 113, int = 113, },
}
