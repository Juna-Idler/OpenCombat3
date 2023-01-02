# warning-ignore-all:return_value_discarded

class_name NamedSkillPerformer

var skills : Array = [
	Reinforce.new(),
	Pierce.new(),
	Charge.new(),
	Isolate.new(),
	Absorb.new(),
]

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _before(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		return

	func _engaged(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			situation : int,_myself : MatchPlayer,_rival : MatchPlayer,_data) -> int:
		return situation
		
	func _after(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_situation : int,_myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		return
		
	func _end(_tween : SceneTreeTween,_skill : SkillData.NamedSkill,_csl : CombatSkillLine,
			_situation : int,_myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		return

class Reinforce extends Skill:

	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,csl : CombatSkillLine,
			myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		tween.tween_callback(csl,"succeeded")
		var a := [0,0,0]
		for p in skill.parameter[0].data as Array:
			var e := p as AttributeData.CardAttribute
			a[e.data.id - 1] += e.parameter
		tween.tween_callback(myself,"add_attribute",[a[0],a[1],a[2]])
		tween.tween_callback(myself.combat_avatar,"play_sound",[load("res://sound/ステータス上昇魔法2.mp3")])
		tween.chain()
		tween.tween_interval(1.0)
		tween.chain()


class Pierce extends Skill:
	func _after(tween : SceneTreeTween,_skill : SkillData.NamedSkill,csl : CombatSkillLine,
			_situation : int,myself : MatchPlayer,rival : MatchPlayer,data) -> void:
		if data > 0:
			tween.tween_callback(csl,"succeeded")
			myself.combat_avatar.attack_close(data,rival.combat_avatar,tween)
			return
		tween.tween_callback(csl,"failed")


class Charge extends Skill:
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,csl : CombatSkillLine,
			_situation : int,myself : MatchPlayer,_rival : MatchPlayer,data) -> void:
		if data:
			for p in skill.parameter[0].data as Array:
				var e := p as AttributeData.CardAttribute
				match e.data.id:
					AttributeData.AttributeType.POWER:
						myself.next_effect.power += e.parameter
						pass
					AttributeData.AttributeType.HIT:
						myself.next_effect.hit += e.parameter
						pass
					AttributeData.AttributeType.BLOCK:
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
			_situation : int,myself : MatchPlayer,_rival : MatchPlayer,_data) -> int:
		tween.tween_callback(csl,"succeeded")
		tween.tween_callback(myself.combat_avatar,"add_damage",[1])
		return 0

class Absorb extends Skill:
	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,csl : CombatSkillLine,
			myself : MatchPlayer,_rival : MatchPlayer,data) -> void:
		if data < 0:
			tween.tween_callback(csl,"failed")
			return

		tween.tween_callback(csl,"succeeded")
		var hand_index := data as int
#		var draw := data[1] as int
		var card := myself.deck_list[myself.hand[hand_index]] as Card
		var a := [0,0,0]
		for p in skill.parameter[1].data as Array:
			var e := p as AttributeData.CardAttribute
			a[e.data.id - 1] += e.parameter * card.front.data.level
		
		tween.tween_callback(myself,"discard_card",[hand_index,0.5])
		tween.tween_callback(myself,"add_attribute",[a[0],a[1],a[2]])
		tween.tween_callback(myself,"draw_card")
		tween.tween_callback(myself.combat_avatar,"play_sound",[load("res://sound/ステータス上昇魔法2.mp3")])
		tween.tween_interval(1.0)




