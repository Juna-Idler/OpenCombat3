
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
#		tween.tween_interval(1.0)
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					tween.tween_callback(myself,"change_col_power",[e.parameter])
				EffectData.Attribute.HIT:
					tween.tween_callback(myself,"change_col_hit",[e.parameter])
				EffectData.Attribute.BLOCK:
					tween.tween_callback(myself,"change_col_block",[e.parameter])


class Rush extends Skill:
	func _test_after(skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		if situation > 0:
			if (rival.playing_card.get_current_block() + 1) / 2 > 0:
				return 1.0
			return 0.0
		return -0.5
		
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if situation > 0:
			for i in (rival.playing_card.get_current_block() + 1) / 2:
				myself.combat_avatar.attack(rival,tween)
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

	
