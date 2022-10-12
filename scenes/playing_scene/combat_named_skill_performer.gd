
class_name NamedSkillPerformer

var skills : Array = [
	Rush.new(),
	Charge.new(),
]

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _test_before(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		return 0.0
	func _before(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		return
		
	func _test_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		return 0.0
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		return
		
	func _test_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		return 0.0
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		return


class Rush extends Skill:
	func _test_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		if situation > 0:
			return 0.0
		var playing_card = myself.get_playing_card()
		if situation < 0:
			var stability = skill.parameter + playing_card.affected.rush
			if stability < rival.get_playing_card().get_current_hit():
				return -0.5
		return 1.0
		
	func _after(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if situation > 0:
			return
		var playing_card = myself.get_playing_card()
		if situation < 0:
			var stability = skill.parameter + playing_card.affected.rush
			if stability < rival.get_playing_card().get_current_hit():
				return
		var damage := int(playing_card.get_current_hit() + 1) / 2;
#		rival.add_damage(damage)


class Charge extends Skill:
	func _test_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> float:
		if myself.damage == 0:
			return 1.0
		return -0.5
	
	func _end(tween : SceneTreeTween,skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : PlayingPlayer,rival : PlayingPlayer) -> void:
		if myself.damage == 0:
			for p in (skill.parameter as NormalSkillEffects).effects:
				var e := p as NormalSkillEffects.Effect
#				match e.attribute:
#					NormalSkillEffects.Attribute.POWER:
#						myself.next_effect.power += e.parameter
#					NormalSkillEffects.Attribute.HIT:
#						myself.next_effect.hit += e.parameter
#					NormalSkillEffects.Attribute.DAMAGE:
#						myself.next_effect.damage += e.parameter
#					NormalSkillEffects.Attribute.RUSH:
#						myself.next_effect.rush += e.parameter
			return
		return

	
