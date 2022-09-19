extends Object

class_name NormalSkillProcessor

static func process_before(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player) -> void:
	if skill.test_condition_before(vs_color,link_color):
		_activate_normal_skill(skill,myself,rival)

static func process_after(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player) -> void:
	if skill.test_condition_after(vs_color,link_color,situation):
		_activate_normal_skill(skill,myself,rival)

static func process_end(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player) -> void:
	if skill.test_condition_end(vs_color,link_color):
		_activate_normal_skill(skill,myself,rival)

static func _activate_normal_skill(skill : SkillData.NormalSkill,
		myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
	for t_ in skill.targets:
		var t := t_ as SkillData.NormalSkill.Target
		match t.target_card:
			SkillData.NormalSkill.TargetCard.PLAYED_CARD:
				match t.target_player:
					SkillData.NormalSkill.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.get_playing_card().affected)
					SkillData.NormalSkill.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.get_playing_card().affected)
					SkillData.NormalSkill.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.get_playing_card().affected)
						_skill_effect(t.effects,rival.get_playing_card().affected)
			SkillData.NormalSkill.TargetCard.NEXT_CARD:
				match t.target_player:
					SkillData.NormalSkill.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.next_effect)
					SkillData.NormalSkill.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.next_effect)
					SkillData.NormalSkill.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.next_effect)
						_skill_effect(t.effects,rival.next_effect)
			SkillData.NormalSkill.TargetCard.HAND_ONE,SkillData.NormalSkill.TargetCard.HAND_ALL:
				match t.target_player:
					SkillData.NormalSkill.TargetPlayer.MYSELF:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == SkillData.NormalSkill.TargetCard.HAND_ONE:
									break
					SkillData.NormalSkill.TargetPlayer.RIVAL:
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == SkillData.NormalSkill.TargetCard.HAND_ONE:
									break
					SkillData.NormalSkill.TargetPlayer.BOTH:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == SkillData.NormalSkill.TargetCard.HAND_ONE:
									break
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == SkillData.NormalSkill.TargetCard.HAND_ONE:
									break
		pass

static func _skill_effect(effects : Array,affected : ProcessorData.Card.Affected) -> void:
	for e_ in effects:
		var e := e_ as SkillData.NormalSkill.Target.Effect
		match e.effect_attribute:
			SkillData.NormalSkill.EffectAttribute.POWER:
				affected.power += e.effect_parameter
			SkillData.NormalSkill.EffectAttribute.HIT:
				affected.hit += e.effect_parameter
			SkillData.NormalSkill.EffectAttribute.DAMAGE:
				affected.damage += e.effect_parameter
			SkillData.NormalSkill.EffectAttribute.RUSH:
				affected.rush += e.effect_parameter
