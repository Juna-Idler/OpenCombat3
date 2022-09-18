
class_name NamedSkillProcessor

var skills : Array = [
	Rush.new(),
	Charge.new(),
]

func _init():
	pass

func get_skill(id : int) -> Skill:
	return skills[id-1]

class Skill:
	func _process_before(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		pass
	func _process_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		pass
	func _process_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		pass


class Rush extends Skill:
	func _process_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		if situation > 0:
			return
		var playing_card = myself.get_playing_card()
		if situation < 0:
			var stability = int(skill.parameter) + playing_card.affected.rush
			if stability < rival.get_playing_card().get_current_hit():
				return
		var damage = (playing_card.get_current_hit()) + 1 / 2;
		rival.add_damage(damage)

class Charge extends Skill:
	func _process_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		if myself.battle_damage == 0:
			var affected := myself.next_effect
			for p in skill.parameter.split(" "):
				var e := SkillData.NormalSkill.Target.Effect.new(p)
				match e.effect_attribute:
					SkillData.NormalSkill.EffectAttribute.POWER:
						affected.power += e.effect_parameter
					SkillData.NormalSkill.EffectAttribute.HIT:
						affected.hit += e.effect_parameter
					SkillData.NormalSkill.EffectAttribute.DAMAGE:
						affected.damage += e.effect_parameter
					SkillData.NormalSkill.EffectAttribute.RUSH:
						affected.rush += e.effect_parameter				

	
