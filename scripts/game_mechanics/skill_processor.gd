
class_name SkillProcessor


class Reinforce extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : SkillData.NamedSkill).(data):
		pass
	
	func _before_priority() -> Array:
		return [PRIORITY]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var affected := myself._get_playing_card().affected
		var effect := _skill.parameter[0].data as CardData.Stats
		affected.power += effect.power
		affected.hit += effect.hit
		affected.block += effect.block
		myself._append_effect_log(index,MechanicsData.EffectTiming.BEFORE,PRIORITY,true)


class Pierce extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : SkillData.NamedSkill).(data):
		pass
	
	func _after_priority() -> Array:
		return [PRIORITY]
	func _process_after(index : int,_priority : int,situation : int,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> void:
		var damage := 0
		if situation > 0:
# warning-ignore:integer_division
			damage = (rival._get_current_block() + 1) / 2
			rival._add_damage(damage)
		myself._append_effect_log(index,MechanicsData.EffectTiming.AFTER,PRIORITY,damage)


class Charge extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : SkillData.NamedSkill).(data):
		pass
	
	func _end_priority() -> Array:
		return [PRIORITY]
	func _process_end(index : int,_priority : int,_situation : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		if myself._is_recovery():
			var effect := _skill.parameter[0].data as CardData.Stats
			var _state = StateProcessor.Reinforce.new(effect,myself._get_states())
			myself._append_effect_log(index,MechanicsData.EffectTiming.END,PRIORITY,true)
		else:
			myself._append_effect_log(index,MechanicsData.EffectTiming.END,PRIORITY,false)


class Isolate extends MechanicsData.BasicSkill:
	const PRIORITY = 255
	func _init(data : SkillData.NamedSkill).(data):
		pass
	
	func _engaged_priority() -> Array:
		return [PRIORITY]
	func _process_engaged(index : int,_priority : int,_situation : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> int:
		myself._add_damage(1)
		myself._append_effect_log(index,MechanicsData.EffectTiming.ENGAGED,PRIORITY,true)
		return 0

class Absorb extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : SkillData.NamedSkill).(data):
		pass
	
	func _before_priority() -> Array:
		return [PRIORITY]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var level := 0
		var data := -1
		for i in myself._get_hand().size():
			var card := myself._get_deck_list()[myself._get_hand()[i]] as MechanicsData.PlayerCard
			if card.data.color == _skill.parameter[0].data:
				level = card.data.level
				myself._discard_card(i)
				myself._draw_card()
				data = i
				break
		var affected := myself._get_playing_card().affected
		var effect := _skill.parameter[1].data as CardData.Stats
		affected.power += effect.power * level
		affected.hit += effect.hit * level
		affected.block += effect.block * level
		myself._append_effect_log(index,MechanicsData.EffectTiming.BEFORE,PRIORITY,data)
	
