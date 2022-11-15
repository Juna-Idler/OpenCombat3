
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
	func _process_before(_index : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass
		
	func _engaged_priority() -> int:
		return 0
	func _process_engaged(_index : int,situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> int:
		return situation
		
	func _after_priority() -> int:
		return 0
	func _process_after(_index : int,_situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass
		
	func _end_priority() -> int:
		return 0
	func _process_end(_index : int,_situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass


class Reinforce extends Skill:
	func _before_priority() -> int:
		return 1
	func _process_before(index : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		var skill := myself.select_card.data.skills[index] as SkillData.NamedSkill
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
		myself.skill_log.append(ProcessorData.SkillLog.new(ProcessorData.SkillTiming.BEFORE,index,true))


class Rush extends Skill:
	func _after_priority() -> int:
		return 1
	func _process_after(index : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		var damage := 0
		if situation > 0:
# warning-ignore:integer_division
			damage = (rival.get_current_block() + 1) / 2
			rival.add_damage(damage)
		myself.skill_log.append(ProcessorData.SkillLog.new(ProcessorData.SkillTiming.AFTER,index,damage))


class Charge extends Skill:
	func _end_priority() -> int:
		return 1
	func _process_end(index : int,_situation : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		if myself.damage == 0:
			var skill := myself.select_card.data.skills[index] as SkillData.NamedSkill
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
			myself.skill_log.append(ProcessorData.SkillLog.new(ProcessorData.SkillTiming.END,index,true))
		else:
			myself.skill_log.append(ProcessorData.SkillLog.new(ProcessorData.SkillTiming.END,index,false))


class Isolate extends Skill:
	func _engaged_priority() -> int:
		return 255
	func _process_engaged(index : int,_situation : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> int:
		myself.add_damage(1)
		myself.skill_log.append(ProcessorData.SkillLog.new(ProcessorData.SkillTiming.END,index,true))
		return 0
