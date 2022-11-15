# warning-ignore-all:return_value_discarded

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
	func _before(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_myself : PlayingPlayer,_rival : PlayingPlayer,data) -> void:
		return

	func _engaged(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer,data) -> int:
		return situation
		
	func _after(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer,data) -> void:
		return
		
	func _end(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_situation : int,_myself : PlayingPlayer,_rival : PlayingPlayer,data) -> void:
		return

class Reinforce extends Skill:

	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,csl : CombatSkillLine,
			myself : PlayingPlayer,_rival : PlayingPlayer,_data) -> void:
		tween.tween_callback(csl,"succeeded")
		var a := [0,0,0]
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			a[e.data.id - 1] += e.parameter
		tween.tween_callback(myself,"add_attribute",[a[0],a[1],a[2]])
		tween.tween_callback(myself.combat_avatar,"play_sound",[load("res://sound/ステータス上昇魔法2.mp3")])
		tween.chain()
		tween.tween_interval(1.0)
		tween.chain()


class Rush extends Skill:
	func _after(tween : SceneTreeTween,_skill : SkillData.NamedSkill,csl : CombatSkillLine,
			situation : int,myself : PlayingPlayer,rival : PlayingPlayer,_data) -> void:
		if situation > 0:
# warning-ignore:integer_division
			var  damage := (rival.get_current_block() + 1) / 2
			if damage > 0:
				tween.tween_callback(csl,"succeeded")
			myself.combat_avatar.attack_close(damage,rival.combat_avatar,tween)
			return
		tween.tween_callback(csl,"failed")


class Charge extends Skill:
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,csl : CombatSkillLine,
			_situation : int,myself : PlayingPlayer,_rival : PlayingPlayer,_data) -> void:
		if myself.damage == 0:
			for p in skill.parameter as Array:
				var e := p as EffectData.SkillEffect
				match e.data.id:
					EffectData.Attribute.POWER:
						myself.next_effect.power += e.parameter
						pass
					EffectData.Attribute.HIT:
						myself.next_effect.hit += e.parameter
						pass
					EffectData.Attribute.BLOCK:
						myself.next_effect.block += e.parameter
						pass
				pass
			tween.tween_callback(csl,"succeeded")
			tween.tween_callback(myself.combat_avatar,"play_sound",[load("res://sound/オーラ2.mp3")])
			tween.tween_interval(1.0)
			return
		tween.tween_callback(csl,"failed")

class Isolate extends Skill:
	func _engaged(tween : SceneTreeTween,_skill : SkillData.NamedSkill,csl : CombatSkillLine,
			_situation : int,myself : PlayingPlayer,_rival : PlayingPlayer,_data) -> int:
		tween.tween_callback(csl,"succeeded")
		tween.tween_callback(myself.combat_avatar,"add_damage",[1])
		return 0


