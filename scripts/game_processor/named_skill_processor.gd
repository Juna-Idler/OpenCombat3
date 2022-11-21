
class_name NamedSkillProcessor

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
	func _before_priority() -> Array:
		return []
	func _process_before(_index : int,_priority : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass
		
	func _engaged_priority() -> Array:
		return []
	func _process_engaged(_index : int,_priority : int,situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> int:
		return situation
		
	func _after_priority() -> Array:
		return []
	func _process_after(_index : int,_priority : int,_situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass
		
	func _end_priority() -> Array:
		return []
	func _process_end(_index : int,_priority : int,_situation : int,
			_myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		pass


class Reinforce extends Skill:
	func _before_priority() -> Array:
		return [1]
	func _process_before(index : int,_priority : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		var skill := myself.select_card.data.skills[index] as SkillData.NamedSkill
		var affected := myself.select_card.affected
		for p in skill.parameter[0].data as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					affected.power += e.parameter
				EffectData.Attribute.HIT:
					affected.hit += e.parameter
				EffectData.Attribute.BLOCK:
					affected.block += e.parameter
		myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.BEFORE,1,true))


class Pierce extends Skill:
	func _after_priority() -> Array:
		return [1]
	func _process_after(index : int,_priority : int,situation : int,
			myself : ProcessorData.Player,rival : ProcessorData.Player) -> void:
		var damage := 0
		if situation > 0:
# warning-ignore:integer_division
			damage = (rival.get_current_block() + 1) / 2
			rival.add_damage(damage)
		myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.AFTER,1,damage))


class Charge extends Skill:
	func _end_priority() -> Array:
		return [1]
	func _process_end(index : int,_priority : int,_situation : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		if myself.damage == 0:
			var skill := myself.select_card.data.skills[index] as SkillData.NamedSkill
			var affected := myself.next_effect
			for p in skill.parameter[0].data as Array:
				var e := p as EffectData.SkillEffect
				match e.data.id:
					EffectData.Attribute.POWER:
						affected.power += e.parameter
					EffectData.Attribute.HIT:
						affected.hit += e.parameter
					EffectData.Attribute.BLOCK:
						affected.block += e.parameter
			myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.END,1,true))
		else:
			myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.END,1,false))


class Isolate extends Skill:
	func _engaged_priority() -> Array:
		return [255]
	func _process_engaged(index : int,_priority : int,_situation : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> int:
		myself.add_damage(1)
		myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.ENGAGED,255,true))
		return 0

class Absorb extends Skill:
	func _before_priority() -> Array:
		return [1]
	func _process_before(index : int,_priority : int,
			myself : ProcessorData.Player,_rival : ProcessorData.Player) -> void:
		var skill := myself.select_card.data.skills[index] as SkillData.NamedSkill
		var level := 0
		var data := []
		for i in myself.hand.size():
			var card := myself.deck_list[myself.hand[i]] as ProcessorData.PlayerCard
			if card.data.color == skill.parameter[0].data:
				level = card.data.level
				myself.discard_card(i)
				var draw_index := myself.skill_draw_card()
				data = [i,draw_index]
				break
		var affected := myself.select_card.affected
		for p in skill.parameter[1].data as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					affected.power += e.parameter * level
				EffectData.Attribute.HIT:
					affected.hit += e.parameter * level
				EffectData.Attribute.BLOCK:
					affected.block += e.parameter * level
		myself.skill_log.append(ProcessorData.SkillLog.new(index,ProcessorData.SkillTiming.BEFORE,1,data))
	
