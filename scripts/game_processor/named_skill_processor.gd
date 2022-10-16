
class_name NamedSkillProcessor

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
	func _process_before(_skill : SkillData.NamedSkill,
			_myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		pass
	func _process_after(_skill : SkillData.NamedSkill,_situation : int,
			_myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		pass
	func _process_end(_skill : SkillData.NamedSkill,_situation : int,
			_myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		pass

class Reinforce extends Skill:
	func _process_before(skill : SkillData.NamedSkill,
			myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		var affected := myself.select_card.affected
		for p in (skill.parameter as SkillEffects).effects:
			var e := p as SkillEffects.Effect
			match e.attribute:
				SkillEffects.Attribute.POWER:
					affected.power += e.parameter
				SkillEffects.Attribute.HIT:
					affected.hit += e.parameter
				SkillEffects.Attribute.BLOCK:
					affected.block += e.parameter
				SkillEffects.Attribute.RUSH:
					affected.rush += e.parameter


class Rush extends Skill:
	func _process_after(skill : SkillData.NamedSkill,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		if situation > 0:
			rival.add_damage((rival.select_card.get_current_block() + 1) / 2)
			return
		var playing_card = myself.select_card
		if situation < 0:
			var stability = skill.parameter + playing_card.affected.rush
			if stability < myself.combat_damage:
				return
		var damage := int((playing_card.get_current_hit() + 1) / 2);
		rival.add_damage(damage)

class Charge extends Skill:
	func _process_end(skill : SkillData.NamedSkill,_situation : int,
			myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		if myself.combat_damage == 0:
			var affected := myself.next_effect
			for p in (skill.parameter as SkillEffects).effects:
				var e := p as SkillEffects.Effect
				match e.attribute:
					SkillEffects.Attribute.POWER:
						affected.power += e.parameter
					SkillEffects.Attribute.HIT:
						affected.hit += e.parameter
					SkillEffects.Attribute.BLOCK:
						affected.block += e.parameter
					SkillEffects.Attribute.RUSH:
						affected.rush += e.parameter
					

	
