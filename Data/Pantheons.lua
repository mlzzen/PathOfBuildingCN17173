-- This file is automatically generated, do not edit!
-- The Pantheon data (c) Grinding Gear Games

return {
	["TheBrineKing"] = {
		isMajorGod = true,
		souls = {
			[1] = { name = "惊海之王 索亚格斯之魂",
				mods = {
					-- cannot_be_stunned_if_have_been_stunned_or_blocked_stunning_hit_in_past_2_seconds
					[1] = { line = "若过去的 2 秒内你被晕眩或是格挡晕眩，你将无法再被晕眩", value = { 1 }, },
				},
			},
			[2] = { name = "冻灵",
				mods = {
					-- base_stun_recovery_+%
					[1] = { line = "晕眩回复和格挡回复提高 30%", value = { 30 }, },
				},
			},
			[3] = { name = "腐化者艾达尔克",
				mods = {
					-- cannot_be_frozen_if_you_have_been_frozen_recently
					[1] = { line = "你被冰冻后的短时间内免疫冰冻", value = { 100 }, },
				},
			},
			[4] = { name = "海之雄狮娜萨",
				mods = {
					-- chill_effectiveness_on_self_+%
					[1] = { line = "你受到的冰缓效果降低 50%", value = { -50 }, },
				},
			},
		},
	},
	["Arakaali"] = {
		isMajorGod = true,
		souls = {
			[1] = { name = "暗影女皇 阿拉卡力之魂",
				mods = {
					-- degen_effect_+%
					[1] = { line = "受到的持续性伤害降低 5%", value = { -5 }, },
					-- avoid_lightning_damage_%
					[2] = { line = "被击中时有 10% 的几率避免闪电伤害", value = { 10 }, },
				},
			},
			[2] = { name = "绿影之后",
				mods = {
					-- life_and_energy_shield_recovery_rate_+%_if_stopped_taking_damage_over_time_recently
					[1] = { line = "近期内若你停止受到持续伤害，则生命和能量护盾回复速度提高 50%", value = { 50 }, },
				},
			},
			[3] = { name = "思想窃贼吉塞尔",
				mods = {
					-- shocked_effect_on_self_+%
					[1] = { line = "你受到的感电效果降低 30%", value = { -30 }, },
					-- base_self_shock_duration_-%
					[2] = { line = "你被感电的持续时间缩短 30%", value = { 30 }, },
				},
			},
			[4] = { name = "冥缶之巫",
				mods = {
					-- additional_chaos_resistance_against_damage_over_time_%
					[1] = { line = "对持续伤害有 +25% 混沌抗性", value = { 25 }, },
				},
			},
		},
	},
	["Solaris"] = {
		isMajorGod = true,
		souls = {
			[1] = { name = "日耀女神之魂",
				mods = {
					-- physical_damage_reduction_%_if_only_one_enemy_nearby
					[1] = { line = "若附近只有 1 个敌人，则受到的物理伤害降低 6%", value = { 6 }, },
					-- take_half_area_damage_from_hit_%_chance
					[2] = { line = "有 20% 的几率使受到的范围总伤害额外降低 50%", value = { 20 }, },
				},
			},
			[2] = { name = "正义之视",
				mods = {
					-- elemental_damage_taken_+%_if_not_hit_recently
					[1] = { line = "若你近期内没有被击中，则受到的元素伤害降低 8%", value = { -8 }, },
				},
			},
			[3] = { name = "梦魇之兆",
				mods = {
					-- self_take_no_extra_damage_from_critical_strikes_if_have_been_crit_recently
					[1] = { line = "近期你若受到过暴击伤害，则不再受到暴击的额外伤害", value = { 1 }, },
				},
			},
			[4] = { name = "疯狂男爵帕斯科",
				mods = {
					-- avoid_ailments_%_from_crit
					[1] = { line = "被暴击时有 50% 的几率免疫异常状态", value = { 50 }, },
				},
			},
		},
	},
	["Lunaris"] = {
		isMajorGod = true,
		souls = {
			[1] = { name = "月影女神之魂",
				mods = {
					-- physical_damage_reduction_%_per_nearby_enemy
					[1] = { line = "身边每存在 1 个敌人，受到的物理伤害便降低 1%，最多 8%", value = { 1 }, },
					-- movement_speed_+%_per_nearby_enemy
					[2] = { line = "身边每有 1 个敌人，自己的移动速度提高 1%，最多 8%", value = { 1 }, },
				},
			},
			[2] = { name = "隧道陷阱",
				mods = {
					-- base_avoid_projectiles_%_chance
					[1] = { line = "10% 的几率免疫投射物", value = { 10 }, },
				},
			},
			[3] = { name = "神主之灵",
				mods = {
					-- dodge_attacks_and_spells_%_chance_if_have_been_hit_recently
					[1] = { line = "若你近期内受到伤害，则有 5% 的几率躲避攻击和法术击中", value = { 5 }, },
				},
			},
			[4] = { name = "暗影炼金师赛尔甘",
				mods = {
					-- avoid_chained_projectile_%_chance
					[1] = { line = "避免被连锁弹射的投射物击中", value = { 100 }, },
				},
			},
		},
	},
	["Abberath"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "割裂者 艾贝拉斯之魂",
				mods = {
					-- fire_damage_taken_+%_while_moving
					[1] = { line = "移动时受到的火焰伤害降低 5%", value = { -5 }, },
					-- unaffected_by_burning_ground
					[2] = { line = "不受燃烧地面影响", value = { 1 }, },
				},
			},
			[2] = { name = "撼地者米福德",
				mods = {
					-- base_self_ignite_duration_-%
					[1] = { line = "你被点燃的持续时间缩短 50%", value = { 50 }, },
					-- movement_speed_+%_while_on_burning_ground
					[2] = { line = "在燃烧地面上时，移动速度提高 10%", value = { 10 }, },
				},
			},
		},
	},
	["Gruthkul"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "绝望之母 格鲁丝克之魂",
				mods = {
					-- physical_damage_reduction_%_per_hit_you_have_taken_recently
					[1] = { line = "近期每受到 1 次伤害，下次承受的物理伤害減少 1%，最多 5%", value = { 1 }, },
				},
			},
			[2] = { name = "光明克星阿尔碧斯",
				mods = {
					-- enemies_that_hit_you_with_attack_recently_attack_speed_+%
					[1] = { line = "若近期敌人用攻击击中过你，则它们的攻击速度降低 8%", value = { -8 }, },
				},
			},
		},
	},
	["Yugul"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "恐惧之源 尤格尔之魂",
				mods = {
					-- reflect_damage_taken_and_minion_reflect_damage_taken_+%
					[1] = { line = "你和你的召唤生物受到的反射伤害降低 25%", value = { -25 }, },
					-- reflect_chill_and_freeze_%_chance
					[2] = { line = "有 50% 的几率反射敌人的冰缓和冰冻", value = { 50 }, },
				},
			},
			[2] = { name = "微光巨侍法赫西",
				mods = {
					-- curse_effect_on_self_+%
					[1] = { line = "你受到的诅咒效果降低 20%", value = { -20 }, },
				},
			},
		},
	},
	["Shakari"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "沙之女神 沙卡丽之魂",
				mods = {
					-- chaos_damage_taken_+%
					[1] = { line = "受到的混沌伤害降低 5%", value = { -5 }, },
					-- chaos_damage_taken_over_time_+%_while_in_caustic_cloud
					[2] = { line = "当在腐蚀地面上时，受到的混沌持续伤害降低 25%", value = { -25 }, },
				},
			},
			[2] = { name = "漂泊畏灵",
				mods = {
					-- pantheon_shakari_self_poison_duration_+%_final
					[1] = { line = "你身上的总中毒持续时间额外缩短 50%", value = { -50 }, },
					-- cannot_be_poisoned_if_x_poisons_on_you
					[2] = { line = "你身上至少有 5 层中毒状态时，你无法中毒", value = { 5 }, },
				},
			},
		},
	},
	["Tukohama"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "战争之父 图克哈玛之魂",
				mods = {
					-- while_stationary_gain_additional_physical_damage_reduction_%
					[1] = { line = "静止时，每秒获得 2% 额外物理减伤，最多 8%", value = { 2 }, },
				},
			},
			[2] = { name = "起乱者塔辛",
				mods = {
					-- while_stationary_gain_life_regeneration_rate_per_minute_%
					[1] = { line = "静止时，每秒获得 0.5% 每秒生命回复，最多 2%", value = { 30 }, },
				},
			},
		},
	},
	["Ralakesh"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "万面之主 拉克斯之魂",
				mods = {
					-- physical_damage_over_time_taken_+%_while_moving
					[1] = { line = "移动时受到的物理持续伤害降低 25%", value = { -25 }, },
					-- base_avoid_bleed_%
					[2] = { line = "25% 的几率免疫流血", value = { 25 }, },
				},
			},
			[2] = { name = "权利猎人德里克",
				mods = {
					-- cannot_gain_corrupted_blood_while_you_have_at_least_5_stacks
					[1] = { line = "若你身上至少有 5 层腐化之血，则腐化之血不能再施加给你", value = { 1 }, },
				},
			},
		},
	},
	["Garukhan"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "风暴女神 格鲁坎之魂",
				mods = {
					-- additional_%_chance_to_evade_attacks_if_you_have_taken_a_savage_hit_recently
					[1] = { line = "若你近期内受到【残暴打击】 则 +5% 闪避攻击击中率", value = { 5 }, },
				},
			},
			[2] = { name = "无边沙丘潜行者",
				mods = {
					-- cannot_be_blinded
					[1] = { line = "免疫致盲", value = { 1 }, },
					-- avoid_maim_%_chance
					[2] = { line = "你无法被瘫痪", value = { 100 }, },
				},
			},
		},
	},
	["Ryslatha"] = {
		isMajorGod = false,
		souls = {
			[1] = { name = "傀儡女王 瑞斯拉萨之魂",
				mods = {
					-- life_flasks_gain_X_charges_every_3_seconds_if_you_have_not_used_a_life_flask_recently
					[1] = { line = "若你近期内没使用生命药剂，则生命药剂每 3 秒获得 3 充能", value = { 3 }, },
				},
			},
			[2] = { name = "传奇神盗罗格斯",
				mods = {
					-- life_recovery_+%_from_flasks_while_on_low_life
					[1] = { line = "低血时，使用药剂会提高 60% 生命回复量", value = { 60 }, },
				},
			},
		},
	},
}
