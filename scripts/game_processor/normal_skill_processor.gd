extends Object

class_name NormalSkillProcessor

static func process_before(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData) -> void:
	if skill.test_condition_before(vs_color,link_color):
		_activate_normal_skill(skill,myself,rival)

static func process_after(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData) -> void:
	if skill.test_condition_after(vs_color,link_color,situation):
		_activate_normal_skill(skill,myself,rival)

static func process_end(skill : SkillData.NormalSkill,
		vs_color : int,link_color : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData) -> void:
	if skill.test_condition_end(vs_color,link_color):
		_activate_normal_skill(skill,myself,rival)

static func _activate_normal_skill(skill : SkillData.NormalSkill,
		myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
	for t_ in skill.targets:
		var t := t_ as SkillData.NormalSkill.Target
		match t.target_card:
			SkillData.TargetCard.PLAYED_CARD:
				match t.target_player:
					SkillData.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.playing_card.affected)
					SkillData.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.playing_card.affected)
					SkillData.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.playing_card.affected)
						_skill_effect(t.effects,rival.playing_card.affected)
			SkillData.TargetCard.NEXT_CARD:
				match t.target_player:
					SkillData.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.next_effect)
					SkillData.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.next_effect)
					SkillData.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.next_effect)
						_skill_effect(t.effects,rival.next_effect)
			SkillData.TargetCard.HAND_ONE,SkillData.TargetCard.HAND_ALL:
				match t.target_player:
					SkillData.TargetPlayer.MYSELF:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == SkillData.TargetCard.HAND_ONE:
									break
					SkillData.TargetPlayer.RIVAL:
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == SkillData.TargetCard.HAND_ONE:
									break
					SkillData.TargetPlayer.BOTH:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == SkillData.TargetCard.HAND_ONE:
									break
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == SkillData.TargetCard.HAND_ONE:
									break
		pass

static func _skill_effect(effects : NormalSkillEffects,affected : ProcessorData.Affected) -> void:
	for e_ in effects.effects:
		var e := e_ as NormalSkillEffects.Effect
		match e.attribute:
			NormalSkillEffects.Attribute.POWER:
				affected.power += e.parameter
			NormalSkillEffects.Attribute.HIT:
				affected.hit += e.parameter
			NormalSkillEffects.Attribute.DAMAGE:
				affected.damage += e.parameter
			NormalSkillEffects.Attribute.RUSH:
				affected.rush += e.parameter
