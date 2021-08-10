return {
	[1]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="milliseconds_to_seconds",
						v=1
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="诅咒持续 {0} 秒"
				}
			}
		},
		name="buff_duration",
		stats={
			[1]="buff_effect_duration"
		}
	},
	[2]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的普通和魔法敌人的行动速度提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的普通和魔法敌人的行动速度降低 {0}%"
				},
				[3]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="저주받은 일반 및 마법 등급 적의 동작 속도 {0}% 증폭"
				},
				[4]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="저주받은 일반 및 마법 등급 적의 동작 속도 {0}% 감폭"
				}
			}
		},
		name="action_speed_reduction",
		stats={
			[1]="temporal_chains_action_speed_+%_final"
		}
	},
	[3]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人身上的增益与减益持续时间缩短 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextSlowTimeEffects"
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人身上的增益与减益持续时间延长 {0}%"
				}
			}
		},
		name="buff_time_passed_reduction",
		stats={
			[1]="buff_time_passed_+%_other_than_temporal_chains"
		}
	},
	[4]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人的元素抗性提高 {0:+d}%"
				}
			}
		},
		name="elemental_resist",
		stats={
			[1]="base_resist_all_elements_%"
		}
	},
	[5]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人的火焰抗性提高 {0:+d}%"
				}
			}
		},
		name="fire_resist",
		stats={
			[1]="base_fire_damage_resistance_%"
		}
	},
	[6]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人的冰霜抗性提高 {0:+d}%"
				}
			}
		},
		name="cold_resist",
		stats={
			[1]="base_cold_damage_resistance_%"
		}
	},
	[7]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人的闪电抗性提高 {0:+d}%"
				}
			}
		},
		name="lightning_resist",
		stats={
			[1]="base_lightning_damage_resistance_%"
		}
	},
	[8]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒的敌人获得 {0:+d}% 混沌抗性"
				}
			}
		},
		name="chaos_res",
		stats={
			[1]="base_chaos_damage_resistance_%"
		}
	},
	[9]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextFreeze"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中的冻结几率 {0:+d}%"
				}
			}
		},
		name="chance_to_be_frozen",
		stats={
			[1]="chance_to_be_frozen_%"
		}
	},
	[10]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextIgnite"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中的点燃几率 {0:+d}%"
				}
			}
		},
		name="chance_to_be_ignited",
		stats={
			[1]="chance_to_be_ignited_%"
		}
	},
	[11]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextShock"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中的感电几率 {0:+d}%"
				}
			}
		},
		name="chance_to_be_shocked",
		stats={
			[1]="chance_to_be_shocked_%"
		}
	},
	[12]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="击败被诅咒敌人后药剂使用次数额外增加 {0}%"
				}
			}
		},
		name="monster_flask_charges_incr",
		stats={
			[1]="monster_slain_flask_charges_granted_+%"
		}
	},
	[13]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextLifeLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人被攻击击中时获得 {0}% 生命偷取"
				}
			}
		},
		name="life_leeched_when_hit_by_attack",
		stats={
			[1]="life_leech_on_any_damage_when_hit_by_attack_permyriad"
		}
	},
	[14]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextLifeLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人被击中时获得 {0}% 生命偷取"
				}
			}
		},
		name="life_leeched_when_hit",
		stats={
			[1]="life_leech_on_any_damage_when_hit_permyriad"
		}
	},
	[15]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextManaLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人被攻击击中时获得 {0}% 魔力偷取"
				}
			}
		},
		name="mana_leeched_when_hit_by_attack",
		stats={
			[1]="mana_leech_on_any_damage_when_hit_by_attack_permyriad"
		}
	},
	[16]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextManaLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人被击中时获得 {0}% 魔力偷取"
				}
			}
		},
		name="mana_leeched_when_hit",
		stats={
			[1]="mana_leech_on_any_damage_when_hit_permyriad"
		}
	},
	[17]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="击败被诅咒敌人有 {0}% 的几率获得耐力球"
				}
			}
		},
		name="chance_to_grant_endurance_charge_on_death",
		stats={
			[1]="chance_to_grant_endurance_charge_on_death_%"
		}
	},
	[18]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="击败被诅咒敌人有 {0}% 的几率获得狂怒球"
				}
			}
		},
		name="chance_to_grant_frenzy_charge_on_death",
		stats={
			[1]="chance_to_grant_frenzy_charge_on_death_%"
		}
	},
	[19]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="击败被诅咒敌人有 {0}% 的几率获得暴击球"
				}
			}
		},
		name="chance_to_grant_power_charge_on_death",
		stats={
			[1]="chance_to_grant_power_charge_on_death_%"
		}
	},
	[20]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人命中值提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人命中值降低 {0}%"
				}
			}
		},
		name="accuracy_rating_incr",
		stats={
			[1]="accuracy_rating_+%"
		}
	},
	[21]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的暴击率提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的暴击率降低 {0}%"
				}
			}
		},
		name="critical_strike_chance_incr",
		stats={
			[1]="critical_strike_chance_+%"
		}
	},
	[22]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人额外获得 {0:+d}% 攻击和法术基础暴击伤害加成"
				}
			}
		},
		name="critical_strike_multiplier_incr",
		stats={
			[1]="base_critical_strike_multiplier_+"
		}
	},
	[23]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的普通和魔法敌人造成的伤害总增 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的普通和魔法敌人造成的伤害总降 {0}%"
				},
				[3]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="저주받은 일반 및 마법 적이 주는 피해 {0}% 증폭"
				},
				[4]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="저주받은 일반 및 마법 적이 주는 피해 {0}% 감폭"
				}
			}
		},
		name="enfeeble_damage_scale",
		stats={
			[1]="enfeeble_damage_+%_final"
		}
	},
	[24]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="对被诅咒敌人的击中获得 {0:+d}% 基础暴击几率"
				},
				[2]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="저주받은 적 명중 시 치명타 확률 {0:+d}%"
				}
			}
		},
		name="chance_to_take_critical_strike",
		stats={
			[1]="enemy_additional_critical_strike_chance_against_self"
		}
	},
	[25]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中的暴击伤害加成 {0:+d}%"
				}
			}
		},
		name="enemy_critical_strike_multiplier_against_self",
		stats={
			[1]="enemy_additional_critical_strike_multiplier_against_self"
		}
	},
	[26]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人受到的暴击伤害总降 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人受到的暴击伤害总增 {0}%"
				}
			}
		},
		name="self_critical_strike_multiplier_reduction",
		stats={
			[1]="base_self_critical_strike_multiplier_-%"
		}
	},
	[27]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="投射物会贯穿被诅咒的敌人"
				}
			}
		},
		name="be_pierced",
		stats={
			[1]="projectiles_always_pierce_you"
		}
	},
	[28]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextKnockback"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="击中被诅咒敌人时有额外 {0}% 的几率将其击退"
				}
			}
		},
		name="chance_to_be_knocked_back",
		stats={
			[1]="chance_to_be_knocked_back_%"
		}
	},
	[29]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的总闪避值总增 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的总闪避值总降 {0}%"
				}
			}
		},
		name="evasion_rating_poachers_mark",
		stats={
			[1]="evasion_rating_+%_final_from_poachers_mark"
		}
	},
	[30]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人受到的投射物伤害提高 {0}%"
				}
			}
		},
		name="projectile_damage_taken_incr",
		stats={
			[1]="projectile_damage_taken_+%"
		}
	},
	[31]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人的眩晕几率总增 {0}%"
				}
			}
		},
		name="chance_to_be_stunned",
		stats={
			[1]="chance_to_be_stunned_%"
		}
	},
	[32]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的晕眩和格挡回复提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的晕眩和格挡回复降低 {0}%"
				}
			}
		},
		name="stun_recovery_incr",
		stats={
			[1]="base_stun_recovery_+%"
		}
	},
	[33]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人受到的物理伤害总增 {0}%"
				}
			}
		},
		name="physical_damage_taken_incr",
		stats={
			[1]="physical_damage_taken_+%"
		}
	},
	[34]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人受到的持续伤害提高 {0}%"
				}
			}
		},
		name="degen_effect_incr",
		stats={
			[1]="degen_effect_+%"
		}
	},
	[35]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的点燃持续时间缩短 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的点燃持续时间延长 {0}%"
				}
			}
		},
		name="self_burn_duration",
		stats={
			[1]="base_self_ignite_duration_-%"
		}
	},
	[36]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的冰冻持续时间缩短 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的冰冻持续时间延长 {0}%"
				}
			}
		},
		name="self_freeze_duration",
		stats={
			[1]="base_self_freeze_duration_-%"
		}
	},
	[37]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒敌人的感电持续时间缩短 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒敌人的感电持续时间延长 {0}%"
				}
			}
		},
		name="self_shock_duration",
		stats={
			[1]="base_self_shock_duration_-%"
		}
	},
	[38]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="你不能直接施放该法术"
				}
			}
		},
		name="cannot_cast_curses",
		stats={
			[1]="cannot_cast_curses"
		}
	},
	[39]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒的敌人被攻击击中时获得 {0} 生命"
				}
			}
		},
		name="life_granted_when_hit",
		stats={
			[1]="life_granted_when_hit_by_attacks"
		}
	},
	[40]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒的敌人被攻击击中时获得 {0} 魔力"
				}
			}
		},
		name="mana_granted_when_hit",
		stats={
			[1]="mana_granted_when_hit_by_attacks"
		}
	},
	[41]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="击败被诅咒敌人时会给予玩家 {0} 生命"
				}
			}
		},
		name="life_granted_when_killed",
		stats={
			[1]="life_granted_when_killed"
		}
	},
	[42]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="击败被诅咒敌人时会给予玩家 {0} 魔力"
				}
			}
		},
		name="mana_granted_when_killed",
		stats={
			[1]="mana_granted_when_killed"
		}
	},
	[43]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="效果区域扩大 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="效果区域缩小 {0}%"
				}
			}
		},
		name="curse_area",
		stats={
			[1]="curse_area_of_effect_+%"
		}
	},
	[44]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="诅咒技能以光环形式对周围敌人施放"
				}
			}
		},
		name="curse_aura",
		stats={
			[1]="curse_apply_as_aura"
		}
	},
	[45]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒敌人 {0:+d}% 物理伤害减免"
				}
			}
		},
		name="phys_reduction",
		stats={
			[1]="base_additional_physical_damage_reduction_%"
		}
	},
	[46]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人承受的伤害提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的敌人承受的伤害降低 {0}%"
				}
			}
		},
		name="damage_taken_incr",
		stats={
			[1]="base_damage_taken_+%"
		}
	},
	[47]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextHinder"
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="法术击中有 {0}% 的几率使被诅咒的敌人缓速，移动速度减慢 30%，持续 4 秒"
				}
			}
		},
		name="hinder_when_hit_chance",
		stats={
			[1]="chance_to_be_hindered_when_hit_by_spells_%"
		}
	},
	[48]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextMaim"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="攻击击中有 {0}% 的几率使被诅咒的敌人【瘫痪】，持续 4 秒"
				}
			}
		},
		name="maim_when_hit_chance",
		stats={
			[1]="chance_to_be_maimed_when_hit_%"
		}
	},
	[49]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="产生一片魔蛊区域\n魔蛊区域里的诅咒不会消减\n魔蛊区域结束时，其中的诅咒获得最大灭能"
				}
			}
		},
		name="curse_zone",
		stats={
			[1]="curse_apply_as_curse_zone"
		}
	},
	[50]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="该技能施加的诅咒使最大灭能 {0:+d}"
				}
			}
		},
		name="max_doom",
		stats={
			[1]="curse_maximum_doom"
		}
	},
	[51]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="per_minute_to_per_second",
						v=1
					},
					[2]={
						k="per_minute_to_per_second",
						v=1
					},
					[3]={
						k="reminderstring",
						v="ReminderTextDoom"
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="诅咒每秒获得 {0} 点灭能"
				}
			}
		},
		name="curse_skill_doom",
		stats={
			[1]="curse_skill_doom_gain_per_minute"
		}
	},
	[52]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextLowLife"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人在低血时承受的伤害提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextLowLife"
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的敌人在低血时承受的伤害降低 {0}%"
				}
			}
		},
		name="low_life_damage_taken",
		stats={
			[1]="damage_taken_+%_on_low_life"
		}
	},
	[53]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="milliseconds_to_seconds_2dp",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextDebilitate"
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒的敌人被击中时疲惫 {0} 秒"
				}
			}
		},
		name="debilitated_when_hit",
		stats={
			[1]="debilitate_self_for_x_milliseconds_on_hit"
		}
	},
	[54]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中有 {0}% 的几率使晕眩持续时间翻倍"
				}
			}
		},
		name="double_stun_duration_curse",
		stats={
			[1]="enemy_chance_to_double_stun_duration_%_vs_self"
		}
	},
	[55]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextDamagingAilments"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="对被诅咒的敌人施加的异常状态伤害生效速度加快 {0}%"
				}
			}
		},
		name="vuln_curse_ailment_faster_damage",
		stats={
			[1]="enemy_damaging_ailments_deal_damage_+%_faster_against_self"
		}
	},
	[56]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="被诅咒的敌人被眩晕时，在 1 秒内再生 {0} 点怒火"
				}
			}
		},
		name="rage_regeneration_on_stun_curse",
		stats={
			[1]="enemy_rage_regeneration_on_stun"
		}
	},
	[57]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextEnergyShieldLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人被击中时获得 {0}% 能量护盾偷取"
				},
				[2]={
					[1]={
						k="divide_by_one_hundred",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextEnergyShieldLeech"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="저주받은 적에게 피격 시 {0}% 에너지 보호막 흡수"
				}
			}
		},
		name="energy_shield_leeched_when_hit",
		stats={
			[1]="energy_shield_leech_on_any_damage_when_hit_permyriad"
		}
	},
	[58]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的稀有或传奇敌人造成的伤害总增 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的稀有或传奇敌人造成的伤害总降 {0}%"
				},
				[3]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="저주받은 희귀 또는 고유 적이 주는 피해 {0}% 증폭"
				},
				[4]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="저주받은 희귀 또는 고유 적이 주는 피해 {0}% 감폭"
				}
			}
		},
		name="enfeeble_damage_scale_rare_or_unique",
		stats={
			[1]="enfeeble_damage_+%_vs_rare_or_unique_final"
		}
	},
	[59]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=100,
							[2]=100
						}
					},
					text="被诅咒的敌人被击中时提供一个耐力球"
				},
				[2]={
					limit={
						[1]={
							[1]="#",
							[2]=99
						}
					},
					text="被诅咒的敌人被击中时有 {0}% 的几率提供一个耐力球"
				}
			}
		},
		name="curse_endurance_on_hit",
		stats={
			[1]="grant_attacker_endurance_charge_when_hit_%_chance"
		}
	},
	[60]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=100,
							[2]=100
						}
					},
					text="被诅咒的敌人被击中时提供一个狂怒球"
				},
				[2]={
					limit={
						[1]={
							[1]="#",
							[2]=99
						}
					},
					text="被诅咒的敌人被击中时有 {0}% 的几率提供一个狂怒球"
				}
			}
		},
		name="curse_frenzy_on_hit",
		stats={
			[1]="grant_attacker_frenzy_charge_when_hit_%_chance"
		}
	},
	[61]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=100,
							[2]=100
						}
					},
					text="被诅咒的敌人被击中时提供一个暴击球"
				},
				[2]={
					limit={
						[1]={
							[1]="#",
							[2]=99
						}
					},
					text="被诅咒的敌人被击中时有 {0}% 的几率提供一个暴击球"
				}
			}
		},
		name="curse_power_on_hit",
		stats={
			[1]="grant_attacker_power_charge_when_hit_%_chance"
		}
	},
	[62]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]=1
						}
					},
					text="你击中被诅咒的敌人时，获得一次生命药剂充能\n每 0.5 秒只发生一次"
				},
				[2]={
					limit={
						[1]={
							[1]=2,
							[2]="#"
						}
					},
					text="你击中被诅咒的敌人时，获得 {0}  次生命药剂充能，每 0.5 秒只发生一次"
				}
			}
		},
		name="projectile_weakness_life_flask_on_hit",
		stats={
			[1]="grant_attacker_x_life_flask_charges_when_hit_once_per_500ms"
		}
	},
	[63]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]=1
						}
					},
					text="你击中被诅咒的敌人时，获得一次魔力药剂充能，每 0.5 秒只发生一次"
				},
				[2]={
					limit={
						[1]={
							[1]=2,
							[2]="#"
						}
					},
					text="你击中被诅咒的敌人时，获得 {0} 次魔力药剂充能，每 0.5 秒只发生一次"
				}
			}
		},
		name="projectile_weakness_mana_flask_on_hit",
		stats={
			[1]="grant_attacker_x_mana_flask_charges_when_hit_once_per_500ms"
		}
	},
	[64]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						},
						[2]={
							[1]="#",
							[2]="#"
						}
					},
					text="击中被诅咒敌人时，附加 {0} - {1} 基础混沌伤害"
				}
			}
		},
		name="chaos_weakness_damage",
		stats={
			[1]="minimum_added_chaos_damage_taken",
			[2]="maximum_added_chaos_damage_taken"
		}
	},
	[65]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						},
						[2]={
							[1]="#",
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，击中附加 {0} 到 {1} 点物理伤害"
				}
			}
		},
		name="physical_damage_enemies_cursed",
		stats={
			[1]="minimum_added_physical_damage_taken",
			[2]="maximum_added_physical_damage_taken"
		}
	},
	[66]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人受到的物理持续伤害提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的敌人受到的物理持续伤害 {0}%"
				}
			}
		},
		name="physical_dot_taken_incr",
		stats={
			[1]="base_physical_damage_over_time_taken_+%"
		}
	},
	[67]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="击中被诅咒的敌人的投射物发生分裂，飞向 {0} 个额外目标"
				}
			}
		},
		name="projectiles_split_against_self",
		stats={
			[1]="projectiles_hitting_self_split_into_x"
		}
	},
	[68]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextBleeding"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="对抗被诅咒的敌人时，攻击击中有 {0}% 的几率施加流血"
				}
			}
		},
		name="bleed_when_hit_chance",
		stats={
			[1]="receive_bleeding_chance_%_when_hit_by_attack"
		}
	},
	[69]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextOverkill"
					},
					limit={
						[1]={
							[1]="#",
							[2]="#"
						}
					},
					text="对被诅咒的敌人施加致命一击时，将 {0}% 溢出伤害以物理伤害的形式反射给其它敌人"
				}
			}
		},
		name="reflect_overkill_damage_on_death",
		stats={
			[1]="reflect_%_overkill_damage_to_nearby_allies_on_death"
		}
	},
	[70]={
		lang={
			["Simplified Chinese"]={
				[1]={
					[1]={
						k="reminderstring",
						v="ReminderTextElementalStatusAilments"
					},
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的敌人身上的元素异常状态持续时间缩短 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					[2]={
						k="reminderstring",
						v="ReminderTextElementalStatusAilments"
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的敌人身上的元素异常状态持续时间延长 {0}%"
				}
			}
		},
		name="self_elemental_status_duration",
		stats={
			[1]="self_elemental_status_duration_-%"
		}
	},
	[71]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="被诅咒的稀有或传奇敌人的行动速度提高 {0}%"
				},
				[2]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="被诅咒的稀有或传奇敌人的行动速度降低 {0}%"
				},
				[3]={
					limit={
						[1]={
							[1]=1,
							[2]="#"
						}
					},
					text="저주받은 희귀 및 고유 적의 동작 속도 {0}% 증폭"
				},
				[4]={
					[1]={
						k="negate",
						v=1
					},
					limit={
						[1]={
							[1]="#",
							[2]=-1
						}
					},
					text="저주받은 희귀 및 고유 적의 동작 속도 {0}% 감폭"
				}
			}
		},
		name="action_speed_reduction_rare_or_unique",
		stats={
			[1]="temporal_chains_action_speed_+%_vs_rare_or_unique_final"
		}
	},
	[72]={
		lang={
			["Simplified Chinese"]={
				[1]={
					limit={
						[1]={
							[1]=1,
							[2]=99
						}
					},
					text="诅咒结束时触发末日爆炸"
				},
				[2]={
					limit={
						[1]={
							[1]=100,
							[2]="#"
						}
					},
					text="诅咒结束时触发末日爆炸末日爆炸"
				}
			}
		},
		stats={
			[1]="trigger_vicious_hex_explosion_when_curse_ends"
		}
	},
	["accuracy_rating_+%"]=20,
	["base_additional_physical_damage_reduction_%"]=45,
	["base_chaos_damage_resistance_%"]=8,
	["base_cold_damage_resistance_%"]=6,
	["base_critical_strike_multiplier_+"]=22,
	["base_damage_taken_+%"]=46,
	["base_fire_damage_resistance_%"]=5,
	["base_lightning_damage_resistance_%"]=7,
	["base_physical_damage_over_time_taken_+%"]=66,
	["base_resist_all_elements_%"]=4,
	["base_self_critical_strike_multiplier_-%"]=26,
	["base_self_freeze_duration_-%"]=36,
	["base_self_ignite_duration_-%"]=35,
	["base_self_shock_duration_-%"]=37,
	["base_stun_recovery_+%"]=32,
	["buff_effect_duration"]=1,
	["buff_time_passed_+%_other_than_temporal_chains"]=3,
	["cannot_cast_curses"]=38,
	["chance_to_be_frozen_%"]=9,
	["chance_to_be_hindered_when_hit_by_spells_%"]=47,
	["chance_to_be_ignited_%"]=10,
	["chance_to_be_knocked_back_%"]=28,
	["chance_to_be_maimed_when_hit_%"]=48,
	["chance_to_be_shocked_%"]=11,
	["chance_to_be_stunned_%"]=31,
	["chance_to_grant_endurance_charge_on_death_%"]=17,
	["chance_to_grant_frenzy_charge_on_death_%"]=18,
	["chance_to_grant_power_charge_on_death_%"]=19,
	["critical_strike_chance_+%"]=21,
	["curse_apply_as_aura"]=44,
	["curse_apply_as_curse_zone"]=49,
	["curse_area_of_effect_+%"]=43,
	["curse_maximum_doom"]=50,
	["curse_skill_doom_gain_per_minute"]=51,
	["damage_taken_+%_on_low_life"]=52,
	["debilitate_self_for_x_milliseconds_on_hit"]=53,
	["degen_effect_+%"]=34,
	["enemy_additional_critical_strike_chance_against_self"]=24,
	["enemy_additional_critical_strike_multiplier_against_self"]=25,
	["enemy_chance_to_double_stun_duration_%_vs_self"]=54,
	["enemy_damaging_ailments_deal_damage_+%_faster_against_self"]=55,
	["enemy_rage_regeneration_on_stun"]=56,
	["energy_shield_leech_on_any_damage_when_hit_permyriad"]=57,
	["enfeeble_damage_+%_final"]=23,
	["enfeeble_damage_+%_vs_rare_or_unique_final"]=58,
	["evasion_rating_+%_final_from_poachers_mark"]=29,
	["grant_attacker_endurance_charge_when_hit_%_chance"]=59,
	["grant_attacker_frenzy_charge_when_hit_%_chance"]=60,
	["grant_attacker_power_charge_when_hit_%_chance"]=61,
	["grant_attacker_x_life_flask_charges_when_hit_once_per_500ms"]=62,
	["grant_attacker_x_mana_flask_charges_when_hit_once_per_500ms"]=63,
	["life_granted_when_hit_by_attacks"]=39,
	["life_granted_when_killed"]=41,
	["life_leech_on_any_damage_when_hit_by_attack_permyriad"]=13,
	["life_leech_on_any_damage_when_hit_permyriad"]=14,
	["mana_granted_when_hit_by_attacks"]=40,
	["mana_granted_when_killed"]=42,
	["mana_leech_on_any_damage_when_hit_by_attack_permyriad"]=15,
	["mana_leech_on_any_damage_when_hit_permyriad"]=16,
	["maximum_added_chaos_damage_taken"]=64,
	["maximum_added_physical_damage_taken"]=65,
	["minimum_added_chaos_damage_taken"]=64,
	["minimum_added_physical_damage_taken"]=65,
	["monster_slain_flask_charges_granted_+%"]=12,
	parent="skill_stat_descriptions",
	["physical_damage_taken_+%"]=33,
	["projectile_damage_taken_+%"]=30,
	["projectiles_always_pierce_you"]=27,
	["projectiles_hitting_self_split_into_x"]=67,
	["receive_bleeding_chance_%_when_hit_by_attack"]=68,
	["reflect_%_overkill_damage_to_nearby_allies_on_death"]=69,
	["self_elemental_status_duration_-%"]=70,
	["temporal_chains_action_speed_+%_final"]=2,
	["temporal_chains_action_speed_+%_vs_rare_or_unique_final"]=71,
	["trigger_vicious_hex_explosion_when_curse_ends"]=72
}