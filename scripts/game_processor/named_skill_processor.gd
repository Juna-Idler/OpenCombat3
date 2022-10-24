
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
		for p in skill.parameter as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					affected.power += e.parameter
				EffectData.Attribute.HIT:
					affected.hit += e.parameter
				EffectData.Attribute.BLOCK:
					affected.block += e.parameter


class Rush extends Skill:
	func _process_after(skill : SkillData.NamedSkill,situation : int,
			myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
		if situation > 0:
			rival.add_damage((rival.select_card.get_current_block() + 1) / 2)


class Charge extends Skill:
	func _process_end(skill : SkillData.NamedSkill,_situation : int,
			myself : ProcessorData.PlayerData,_rival : ProcessorData.PlayerData) -> void:
		if myself.combat_damage == 0:
			var affected := myself.next_effect
			for p in skill.parameter as Array:
				var e := p as EffectData.SkillEffect
				match e.data.id:
					EffectData.Attribute.POWER:
						affected.power += e.parameter
					EffectData.Attribute.HIT:
						affected.hit += e.parameter
					EffectData.Attribute.BLOCK:
						affected.block += e.parameter
					

	
