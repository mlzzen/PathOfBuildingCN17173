-- This file is automatically generated, do not edit!
-- Item data (c) Grinding Gear Games

return {
	["FlaskIncreasedRecoverySpeed1"] = { type = "Prefix", affix = "催化的", "回复速度提高 50%", statOrderKey = "509", statOrder = { 509 }, level = 1, group = "FlaskRecoverySpeed", weightKey = { "utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskIncreasedRecoveryAmount1"] = { type = "Prefix", affix = "饱和的", "回复量提高 50%", "回复速度降低 33%", statOrderKey = "508,509", statOrder = { 508, 509 }, level = 1, group = "FlaskRecoveryAmount", weightKey = { "utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskIncreasedRecoveryOnLowLife1"] = { type = "Prefix", affix = "谨慎的", "低血时回复量提高 100%", statOrderKey = "511", statOrder = { 511 }, level = 6, group = "FlaskRecoveryAmount", weightKey = { "utility_flask", "mana_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskInstantRecoveryOnLowLife1"] = { type = "Prefix", affix = "恐慌的", "回复量降低 25%", "低血时立即回复", statOrderKey = "508,512", statOrder = { 508, 512 }, level = 9, group = "FlaskRecoverySpeed", weightKey = { "utility_flask", "mana_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskPartialInstantRecovery1"] = { type = "Prefix", affix = "起泡的", "回复量降低 50%", "回复速度提高 135%", "立即回复50% 回复量", statOrderKey = "508,509,513", statOrder = { 508, 509, 513 }, level = 3, group = "FlaskRecoverySpeed", weightKey = { "utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskFullInstantRecovery1"] = { type = "Prefix", affix = "沸腾的", "回复量降低 66%", "立即回复", statOrderKey = "508,515", statOrder = { 508, 515 }, level = 7, group = "FlaskBuffWhileHealing", weightKey = { "utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskExtraManaCostsLife1"] = { type = "Prefix", affix = "腐蚀性的", "魔力回复提高 60%", "使用时会扣除生命，等同于魔力回复值的 15%", statOrderKey = "507,516", statOrder = { 507, 516 }, level = 11, group = "FlaskRecoveryAmount", weightKey = { "utility_flask", "life_flask", "hybrid_flask", "default", }, weightVal = { 0, 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "mana" }, },
	["FlaskExtraLifeCostsMana1"] = { type = "Prefix", affix = "削弱的", "生命回复提高 40%", "使用时会扣除魔力，等同于生命回复值的 10%", statOrderKey = "505,518", statOrder = { 505, 518 }, level = 13, group = "FlaskRecoveryAmount", weightKey = { "utility_flask", "mana_flask", "hybrid_flask", "default", }, weightVal = { 0, 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "mana" }, },
	["FlaskDispellsChill1"] = { type = "Suffix", affix = "热火之", "药剂持续期间免疫冰冻和冰缓", "使用时移除身上的冰冻和冰缓效果", statOrderKey = "565,565.1", statOrder = { 565, 565.1 }, level = 4, group = "FlaskDispellChill", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "elemental", "cold", "ailment" }, },
	["FlaskDispellsBurning1"] = { type = "Suffix", affix = "浇熄之", "药剂持续期间免疫点燃", "使用时移除自身燃烧状态", statOrderKey = "563,563.1", statOrder = { 563, 563.1 }, level = 6, group = "FlaskDispellBurning", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "elemental", "fire", "ailment" }, },
	["FlaskRemovesBleeding1"] = { type = "Suffix", affix = "止血之", "药剂持续期间免疫流血和腐化之血", "使用时移除流血和腐化之血", statOrderKey = "567,567.1", statOrder = { 567, 567.1 }, level = 8, group = "FlaskRemovesBleeding", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "bleed", "physical", "attack", "ailment" }, },
	["FlaskRemovesShock1"] = { type = "Suffix", affix = "接地之", "药剂持续期间免疫感电效果", "使用时移除身上的感电效果", statOrderKey = "566,566.1", statOrder = { 566, 566.1 }, level = 10, group = "FlaskRemovesShock", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "elemental", "lightning", "ailment" }, },
	["FlaskExtraCharges1"] = { type = "Prefix", affix = "充足的", "+(10-20) 充能上限", statOrderKey = "523", statOrder = { 523 }, level = 2, group = "FlaskNumCharges", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskChargesAddedIncreasePercent1"] = { type = "Prefix", affix = "永久的", "提高 (20-40)% 充能回复", statOrderKey = "524", statOrder = { 524 }, level = 3, group = "FlaskRechargeRate", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskBuffArmourWhileHealing1"] = { type = "Suffix", affix = "铁皮之", "药剂持续期间，护甲提高 (60-100)%", statOrderKey = "531", statOrder = { 531 }, level = 6, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "armour", "flask", "defences" }, },
	["FlaskBuffEvasionWhileHealing"] = { type = "Suffix", affix = "反射之", "药剂持续期间，闪避值提高 (60-100)%", statOrderKey = "532", statOrder = { 532 }, level = 8, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "evasion", "flask", "defences" }, },
	["FlaskBuffMovementSpeedWhileHealing"] = { type = "Suffix", affix = "肾上腺素之", "药剂持续期间，移动速度提高 (20-30)%", statOrderKey = "536", statOrder = { 536 }, level = 5, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "speed" }, },
	["FlaskBuffStunRecoveryWhileHealing"] = { type = "Suffix", affix = "稳健之", "药剂持续期间，格挡和晕眩回复提高 (40-60)%", statOrderKey = "537", statOrder = { 537 }, level = 1, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskBuffResistancesWhileHealing"] = { type = "Suffix", affix = "抗性之", "药剂持续期间，附加 (20-30)% 元素抗性", statOrderKey = "538", statOrder = { 538 }, level = 1, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "elemental", "resistance" }, },
	["FlaskBuffLifeLeechWhileHealing"] = { type = "Suffix", affix = "暴食之", "药剂持续期间，物理攻击伤害的 2% 作为生命偷取", statOrderKey = "539", statOrder = { 539 }, level = 10, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "physical", "attack" }, },
	["FlaskBuffLifeLeechPermyriadWhileHealing"] = { type = "Suffix", affix = "暴食之", "药剂持续期间，物理攻击伤害的 0.4% 作为生命偷取", statOrderKey = "542", statOrder = { 542 }, level = 10, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "physical", "attack" }, },
	["FlaskBuffManaLeechPermyriadWhileHealing"] = { type = "Suffix", affix = "渴求之", "药剂持续期间，物理攻击伤害的 0.4% 作为魔力偷取", statOrderKey = "544", statOrder = { 544 }, level = 12, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "mana", "physical", "attack" }, },
	["FlaskBuffKnockbackWhileHealing"] = { type = "Suffix", affix = "抵御之", "药剂持续期间，近战攻击会击退敌人", statOrderKey = "545", statOrder = { 545 }, level = 9, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "attack" }, },
	["FlaskHealsMinions1"] = { type = "Suffix", affix = "活泼之", "召唤生物获得 (40-60)% 生命回复", statOrderKey = "560", statOrder = { 560 }, level = 10, group = "FlaskHealsOthers", weightKey = { "utility_flask", "mana_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "minion" }, },
	["FlaskFullRechargeOnCrit1"] = { type = "Prefix", affix = "外科医生的", "攻击或法术暴击时获得 1 充能", statOrderKey = "527", statOrder = { 527 }, level = 8, group = "FlaskRechargeRate", weightKey = { "critical_utility_flask", "default", }, weightVal = { 0, 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "critical" }, },
	["FlaskChanceRechargeOnCrit1"] = { type = "Prefix", affix = "外科医生的", "暴击时有 20% 的几率获得 1 充能", statOrderKey = "528", statOrder = { 528 }, level = 8, group = "FlaskRechargeRate", weightKey = { "critical_utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "critical" }, },
	["FlaskFullRechargeOnTakeCrit1"] = { type = "Prefix", affix = "复仇者的", "当你被攻击或法术暴击时补充 5 充能次数", statOrderKey = "530", statOrder = { 530 }, level = 12, group = "FlaskRechargeRate", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "critical" }, },
	["FlaskDispellsPoison1"] = { type = "Suffix", affix = "治愈之", "药剂持续期间免疫中毒", "使用时移除身上的中毒效果", statOrderKey = "2923,2923.1", statOrder = { 2923, 2923.1 }, level = 16, group = "FlaskDispellPoison", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "poison", "chaos", "ailment" }, },
	["FlaskEffectReducedDuration1"] = { type = "Prefix", affix = "炼金的", "效果提高 25%", "持续时间缩短 33%", statOrderKey = "2922,2937", statOrder = { 2922, 2937 }, level = 20, group = "FlaskRecoverySpeed", weightKey = { "no_effect_flask_mod", "utility_flask", "default", }, weightVal = { 0, 1000, 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskChargesUsed1"] = { type = "Prefix", affix = "化学家的", "充能次数减少 (20-25)%", statOrderKey = "525", statOrder = { 525 }, level = 14, group = "FlaskChargesUsed", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskIncreasedDuration2"] = { type = "Prefix", affix = "实验家的", "持续时间延长 (30-40)%", statOrderKey = "2937", statOrder = { 2937 }, level = 20, group = "FlaskRecoverySpeed", weightKey = { "utility_flask", "critical_utility_flask", "default", }, weightVal = { 1000, 1000, 0 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskFullRechargeOnHit1"] = { type = "Prefix", affix = "鞭笞的", "被敌人击中时，获得 1 充能", statOrderKey = "529", statOrder = { 529 }, level = 12, group = "FlaskFullRechargeOnHit", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskIncreasedHealingCharges1"] = { type = "Prefix", affix = "专注的", "回复量提高 30%", "充能次数增加 (20-25)%", statOrderKey = "508,525", statOrder = { 508, 525 }, level = 10, group = "FlaskIncreasedHealingCharges", weightKey = { "utility_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask" }, },
	["FlaskManaRecoveryAtEnd1_"] = { type = "Prefix", affix = "预兆的", "回复量提高 66%", "药剂效果结束时，立刻触发魔力回复", statOrderKey = "508,514", statOrder = { 508, 514 }, level = 16, group = "FlaskManaRecoveryAtEnd", weightKey = { "utility_flask", "life_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "mana" }, },
	["FlaskEffectNotRemovedOnFullMana1"] = { type = "Prefix", affix = "持久的", "回复量降低 30%", "持续时间缩短 30%", "魔力全满时不会移除药剂效果", "药剂效果不会进入等待序列", statOrderKey = "508,2937,5802,5802.1", statOrder = { 508, 2937, 5802, 5802.1 }, level = 16, group = "FlaskEffectNotRemovedOnFullMana", weightKey = { "utility_flask", "life_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "mana" }, },
	["FlaskBuffAttackLifeLeechWhileHealing1"] = { type = "Suffix", affix = "有血之", "药剂持续期间，攻击伤害的 0.4% 作为生命偷取", statOrderKey = "541", statOrder = { 541 }, level = 10, group = "FlaskBuffWhileHealing", weightKey = { "mana_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "life", "attack" }, },
	["FlaskBuffSpellEnergyShieldLeechWhileHealing1"] = { type = "Suffix", affix = "流失之", "药剂持续期间，法术伤害的 0.4% 转化为能量护盾偷取", statOrderKey = "540", statOrder = { 540 }, level = 10, group = "FlaskBuffWhileHealing", weightKey = { "life_flask", "default", }, weightVal = { 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "energy_shield", "flask", "defences", "caster" }, },
	["FlaskBuffAttackSpeedWhileHealing1"] = { type = "Suffix", affix = "加速之", "药剂持续期间，攻击速度提高 (8-12)%", statOrderKey = "534", statOrder = { 534 }, level = 12, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "attack", "speed" }, },
	["FlaskBuffCastSpeedWhileHealing1"] = { type = "Suffix", affix = "迅速之", "药剂持续期间，施法速度提高 (8-12)%", statOrderKey = "535", statOrder = { 535 }, level = 12, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "caster", "speed" }, },
	["FlaskBuffFreezeShockIgniteChanceWhileHealing1_"] = { type = "Suffix", affix = "施罚之", "药剂持续期间，冰冻、感电和点燃几率提高 (20-25)%", statOrderKey = "552", statOrder = { 552 }, level = 12, group = "FlaskBuffWhileHealing", weightKey = { "default", }, weightVal = { 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "elemental", "fire", "cold", "lightning", "ailment" }, },
	["FlaskBuffReducedManaCostWhileHealing1_"] = { type = "Suffix", affix = "动能之", "药剂持续期间，技能魔力消耗降低 (10-15)%", statOrderKey = "554", statOrder = { 554 }, level = 12, group = "LocalFlaskSkillManaCostDuringFlaskEffect", weightKey = { "utility_flask", "life_flask", "default", }, weightVal = { 0, 0, 1000 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "resource", "mana" }, },
	["FlaskCurseImmunity1"] = { type = "Suffix", affix = "守护之", "药剂持续期间免疫诅咒", "使用时移除身上的诅咒效果", statOrderKey = "568,568.1", statOrder = { 568, 568.1 }, level = 18, group = "FlaskCurseImmunity", weightKey = { "default", }, weightVal = { 500 }, weightMultiplierKey = { }, weightMultiplierVal = {  }, modTags = { "flask", "caster", "curse" }, },
}