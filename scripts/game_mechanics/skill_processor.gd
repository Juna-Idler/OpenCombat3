
class_name SkillProcessor

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
			_myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		pass
		
	func _engaged_priority() -> Array:
		return []
	func _process_engaged(_index : int,_priority : int,situation : int,
			_myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> int:
		return situation
		
	func _after_priority() -> Array:
		return []
	func _process_after(_index : int,_priority : int,_situation : int,
			_myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		pass
		
	func _end_priority() -> Array:
		return []
	func _process_end(_index : int,_priority : int,_situation : int,
			_myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		pass


class Reinforce extends Skill:
	func _before_priority() -> Array:
		return [1]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var skill := myself._get_playing_card().data.skills[index] as SkillData.NamedSkill
		var affected := myself._get_playing_card().affected
		for p in skill.parameter[0].data as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					affected.power += e.parameter
				EffectData.Attribute.HIT:
					affected.hit += e.parameter
				EffectData.Attribute.BLOCK:
					affected.block += e.parameter
		myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.BEFORE,1,true))


class Pierce extends Skill:
	func _after_priority() -> Array:
		return [1]
	func _process_after(index : int,_priority : int,situation : int,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> void:
		var damage := 0
		if situation > 0:
# warning-ignore:integer_division
			damage = (rival._get_current_block() + 1) / 2
			rival._add_damage(damage)
		myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.AFTER,1,damage))


class Charge extends Skill:
	func _end_priority() -> Array:
		return [1]
	func _process_end(index : int,_priority : int,_situation : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		if myself._is_recovery():
			var skill := myself._get_playing_card().data.skills[index] as SkillData.NamedSkill
			var affected := MechanicsData.Affected.new()
			for p in skill.parameter[0].data as Array:
				var e := p as EffectData.SkillEffect
				match e.data.id:
					EffectData.Attribute.POWER:
						affected.power += e.parameter
					EffectData.Attribute.HIT:
						affected.hit += e.parameter
					EffectData.Attribute.BLOCK:
						affected.block += e.parameter
			myself._add_next_effect(affected)
			myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.END,1,true))
		else:
			myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.END,1,false))


class Isolate extends Skill:
	func _engaged_priority() -> Array:
		return [255]
	func _process_engaged(index : int,_priority : int,_situation : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> int:
		myself._add_damage(1)
		myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.ENGAGED,255,true))
		return 0

class Absorb extends Skill:
	func _before_priority() -> Array:
		return [1]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var skill := myself._get_playing_card().data.skills[index] as SkillData.NamedSkill
		var level := 0
		var data := -1
		for i in myself._get_hand().size():
			var card := myself._get_deck_list()[myself._get_hand()[i]] as MechanicsData.PlayerCard
			if card.data.color == skill.parameter[0].data:
				level = card.data.level
				myself._discard_card(i)
				myself._draw_card()
				data = i
				break
		var affected := myself._get_playing_card().affected
		for p in skill.parameter[1].data as Array:
			var e := p as EffectData.SkillEffect
			match e.data.id:
				EffectData.Attribute.POWER:
					affected.power += e.parameter * level
				EffectData.Attribute.HIT:
					affected.hit += e.parameter * level
				EffectData.Attribute.BLOCK:
					affected.block += e.parameter * level
		myself._append_skill_log(MechanicsData.SkillLog.new(index,MechanicsData.SkillTiming.BEFORE,1,data))
	
