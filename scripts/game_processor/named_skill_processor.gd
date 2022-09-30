
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
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		pass
	func _process_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		pass
	func _process_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		pass


class Rush extends Skill:
	func _process_after(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		if situation > 0:
			return
		var playing_card = myself.select_card
		if situation < 0:
			var stability = skill.parameter + playing_card.affected.rush
			if stability < rival.select_card.get_current_hit():
				return
		var damage = (playing_card.get_current_hit()) + 1 / 2;
		rival.add_damage(damage)

class Charge extends Skill:
	func _process_end(skill : SkillData.NamedSkill,
			vs_color : int,link_color : int,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		if myself.battle_damage == 0:
			var affected := myself.next_effect
			for p in (skill.parameter as NormalSkillEffects).effects:
				var e := p as NormalSkillEffects.Effect
				match e.attribute:
					NormalSkillEffects.Attribute.POWER:
						affected.power += e.parameter
					NormalSkillEffects.Attribute.HIT:
						affected.hit += e.parameter
					NormalSkillEffects.Attribute.DAMAGE:
						affected.damage += e.parameter
					NormalSkillEffects.Attribute.RUSH:
						affected.rush += e.parameter				

	
