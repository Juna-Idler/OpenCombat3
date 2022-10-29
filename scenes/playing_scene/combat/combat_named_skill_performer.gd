
class_name NamedSkillPerformer

var skills : Array = [
	Reinforce.new(),
	Rush.new(),
	Charge.new(),
	Isolate.new(),
]

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _before_priority() -> int:
		return 0
	func _test_before(_skill : SkillData.NamedSkill,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _before(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _engaged_priority() -> int:
		return 0
	func _test_engaged(_skill : SkillData.NamedSkill,
			situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _engaged(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		return situation
		
	func _after_priority() -> int:
		return 0
	func _test_after(_skill : SkillData.NamedSkill,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _after(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return
		
	func _end_priority() -> int:
		return 0
	func _test_end(_skill : SkillData.NamedSkill,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _end(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
		return

class Reinforce extends Skill:
	func _before_priority() -> int:
		return 1
	func _test_before(_skill : SkillData.NamedSkill,
			_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		var playing_card := myself.playing_card
		var a := [0,0,0]
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			a[e.data.id - 1] += e.parameter
		tween.tween_callback(myself,"add_attribute",[a[0],a[1],a[2]])
		tween.tween_callback(myself.combat_avatar,"play_sound",["res://sound/ステータス上昇魔法2.mp3"])
		tween.chain()
		tween.tween_interval(1.0)
		tween.chain()


class Rush extends Skill:
	func _after_priority() -> int:
		return 1
	func _test_after(skill : SkillData.NamedSkill,
			situation : int,myself : PlayingPlayer,rival : PlayingPlayer) -> bool:
		if situation > 0:
			if (rival.get_current_block() + 1) / 2 > 0:
				return true
		return false
		
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			situation : int,myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if situation > 0:
			myself.combat_avatar.attack_close((rival.get_current_block() + 1) / 2,rival.combat_avatar,tween)
			return


class Charge extends Skill:
	func _end_priority() -> int:
		return 1
	func _test_end(_skill : SkillData.NamedSkill,
			_situation : int,myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		if myself.damage == 0:
			return true
		return false
	
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			_situation : int,myself : PlayingPlayer,_rival : PlayingPlayer) -> void:
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

class Isolate extends Skill:
	
	func _engaged_priority() -> int:
		return 255
	func _test_engaged(_skill : SkillData.NamedSkill,
			situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer) -> bool:
		return true
	func _engaged(tween : SceneTreeTween,_skill : SkillData.NamedSkill,
			_situation : int,myself : PlayingPlayer,_rival : PlayingPlayer) -> int:
		tween.tween_callback(myself.combat_avatar,"add_damage",[1])
		return 0


