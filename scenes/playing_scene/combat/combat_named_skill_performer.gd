
class_name NamedSkillPerformer

var skills : Array = [
	Reinforce.new(),
	Rush.new(),
	Charge.new(),
]

enum SkillTestResult {FAILED = -1,UNCONNECTED = 0,SUCCESSFUL = 1}

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _test_before(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		return SkillTestResult.UNCONNECTED
	func _before(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _test_after(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		return SkillTestResult.UNCONNECTED
	func _after(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _test_end(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		return SkillTestResult.UNCONNECTED
	func _end(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return

class Reinforce extends Skill:
	func _test_before(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		return SkillTestResult.SUCCESSFUL
		
	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		var playing_card := myself.playing_card
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					tween.tween_callback(myself,"change_power",[e.parameter])
				EffectData.Attribute.HIT:
					tween.tween_callback(myself,"change_hit",[e.parameter])
				EffectData.Attribute.BLOCK:
					tween.tween_callback(myself,"change_block",[e.parameter])
		tween.tween_callback(myself.combat_avatar,"play_sound",["res://sound/ステータス上昇魔法2.mp3"])
		tween.chain()
		tween.tween_interval(1.0)
		tween.chain()


class Rush extends Skill:
	func _test_after(skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> int:
		if situation > 0:
			if (rival.playing_card.get_current_block() + 1) / 2 > 0:
				return SkillTestResult.SUCCESSFUL
			return SkillTestResult.FAILED
		return SkillTestResult.FAILED
		
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if situation > 0:
			myself.combat_avatar.attack_close((rival.playing_card.get_current_block() + 1) / 2,rival.combat_avatar,tween)
			return


class Charge extends Skill:
	func _test_end(_skill : SkillData.NamedSkill,
			_vs_color : int,_link_color : int,_situation : int,
			myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		if myself.damage == 0:
			return SkillTestResult.SUCCESSFUL
		return SkillTestResult.FAILED
	
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
			tween.tween_callback(myself.combat_avatar,"play_sound",["res://sound/オーラ2.mp3"])
			tween.tween_interval(1.0)
			return
		return

	
