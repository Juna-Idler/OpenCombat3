
class_name NamedSkillPerformer

var skills : Array = [
	Reinforce.new(),
	Rush.new(),
	Charge.new(),
]

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _test_before(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> float:
		return 0.0
	func _before(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _test_after(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> float:
		return 0.0
	func _after(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _test_end(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> float:
		return 0.0
	func _end(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return

class Reinforce extends Skill:
	func _test_before(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> float:
		return 1.0
		
	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		var playing_card := myself.playing_card
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					playing_card.affected.power += e.parameter
					tween.tween_callback(myself,"change_col_power")
				EffectData.Attribute.HIT:
					playing_card.affected.hit += e.parameter
					tween.tween_callback(myself,"change_col_hit")
				EffectData.Attribute.BLOCK:
					playing_card.affected.block += e.parameter
					tween.tween_callback(myself,"change_col_block")
		tween.tween_interval(1.0)


class Rush extends Skill:
	func _test_after(skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		if situation > 0:
			return 1.0
		return -0.5
		
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if situation > 0:
			tween.tween_interval(1.0)
			tween.tween_callback(rival,"add_damage",[(rival.playing_card.get_current_block() + 1) / 2])
			return


class Charge extends Skill:
	func _test_end(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			myself : PlayingPlayer,_rival : PlayingPlayer) -> float:
		if myself.damage == 0:
			return 1.0
		return -0.5
	
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		if myself.damage == 0:
			for p in skill.parameter as Array:
				var e := p as EffectData.SkillEffect
				match e.data.id:
					EffectData.Attribute.POWER:
						pass
					EffectData.Attribute.HIT:
						pass
					EffectData.Attribute.BLOCK:
						pass
				pass
			tween.tween_interval(1.0)
			return
		return

	
