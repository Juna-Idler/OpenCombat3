
class_name NamedSkillProcessor

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
	func _process_before(_skill : SkillData.NamedSkill,
			_myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> void:
		pass
		
	func _engaged_priority() -> int:
		return 0
	func _process_engaged(_skill : SkillData.NamedSkill,situation : int,
			_myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> int:
		return situation
		
	func _after_priority() -> int:
		return 0
	func _process_after(_skill : SkillData.NamedSkill,_situation : int,
			_myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> void:
		pass
		
	func _end_priority() -> int:
		return 0
	func _process_end(_skill : SkillData.NamedSkill,_situation : int,
			_myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> void:
		pass

class Reinforce extends Skill:
	func _before_priority() -> int:
		return 1
	func _process_before(skill : SkillData.NamedSkill,
			myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> void:
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
	func _after_priority() -> int:
		return 1
	func _process_after(_skill : SkillData.NamedSkill,situation : int,
			_myself : ProcessorPlayerData,rival : ProcessorPlayerData) -> void:
		if situation > 0:
# warning-ignore:integer_division
			rival.add_damage((rival.get_current_block() + 1) / 2)


class Charge extends Skill:
	func _end_priority() -> int:
		return 1
	func _process_end(skill : SkillData.NamedSkill,_situation : int,
			myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> void:
		if myself.damage == 0:
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


class Isolate extends Skill:
	func _engaged_priority() -> int:
		return 255
	func _process_engaged(_skill : SkillData.NamedSkill,_situation : int,
			myself : ProcessorPlayerData,_rival : ProcessorPlayerData) -> int:
		myself.add_damage(1)
		return 0
