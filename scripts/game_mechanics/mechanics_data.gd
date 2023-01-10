
class_name MechanicsData



class PlayerCard:
	var data : CardData = null
	var id_in_deck : int = 0
	var skills : Array # of ISkill

	var affected := CardData.Stats.new(0,0,0)

	func _init(cd : CardData,iid : int,factory : ISkillFactory):
		data = cd
		id_in_deck = iid
		for s in cd.skills:
			skills.append(factory._create(s))
#	var additional_skills : Array
#	var addtional_changes : Dictionary = {}


	static func int_max(a : int, b : int) -> int:
		return a if a > b else b

	func get_current_power() -> int:
		return int_max(data.stats.power + affected.power,0)
	func get_current_hit() -> int:
		return int_max(data.stats.hit + affected.hit,0)
	func get_current_block() -> int:
		return int_max(data.stats.block + affected.block,0)


enum EffectTiming {BEFORE = 0,ENGAGED = 1,AFTER = 2,END = 3}

class EffectLog:
	var index : int # (plus) select card skill index  or (minus) state index in this timing
	var timing : int
	var priority : int
	var data # fit data
	
	func _init(i,t,p,d):
		index = i
		timing = t
		priority = p
		data = d


class IPlayer:
	func _get_deck_list() -> Array:
		return []
	func _get_hand() -> PoolIntArray:
		return PoolIntArray()
	func _get_played() -> PoolIntArray:
		return PoolIntArray()
	func _get_discard() -> PoolIntArray:
		return PoolIntArray()

	func _get_stock_count() -> int:
		return 0

	func _get_life() -> int:
		return 0

	func _get_states() -> Array:
		return []

	func _get_next_effect() -> CardData.Stats:
		return null
	func _add_next_effect(_add : CardData.Stats):
		return

	func _get_playing_hand() -> PoolIntArray:
		return PoolIntArray()

	func _get_select() -> int:
		return 0

	func _get_damage() -> int:
		return 0

	func _get_draw() -> PoolIntArray:
		return PoolIntArray()

	func _get_effect_log() -> Array:
		return []


	func _combat_start(_index : int) -> void:
		return

	func _get_playing_card() -> PlayerCard:
		return null
	func _get_link_color() -> int:
		return 0
		
	func _get_current_power() -> int:
		return 0
	func _get_current_hit() -> int:
		return 0
	func _get_current_block() -> int:
		return 0

	func _damage_is_fatal() -> bool:
		return false

	func _add_damage(_d: int) -> void:
		return
		
	func _append_effect_log(_index : int,_timing : int,_priority : int,_data) -> void:
		return

	func _combat_end() -> void:
		return
		
	func _supply() -> void:
		return


	func _recover(_index : int) -> void:
		return

	func _no_recover() -> void:
		return
		
	func _is_recovery() -> bool:
		return true


	func _change_order(_new_hand : PoolIntArray) -> void:
		return


	func _reset_select() -> void:
		return


	func _draw_card() -> void:
		return

	func _discard_card(_index : int) -> void:
		return

	func _hand_to_deck_bottom(_index : int) -> void:
		return

	func _get_additional_deck() -> PoolIntArray:
		return PoolIntArray()




class IEffect:
	func _before_priority() -> Array:
		return []
	func _process_before(_index : int,_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> void:
		pass
		
	func _engaged_priority() -> Array:
		return []
	func _process_engaged(_index : int,_priority : int,situation : int,
			_myself : IPlayer,_rival : IPlayer) -> int:
		return situation
		
	func _after_priority() -> Array:
		return []
	func _process_after(_index : int,_priority : int,_situation : int,
			_myself : IPlayer,_rival : IPlayer) -> void:
		pass
		
	func _end_priority() -> Array:
		return []
	func _process_end(_index : int,_priority : int,_situation : int,
			_myself : IPlayer,_rival : IPlayer) -> void:
		pass



class ISkill extends IEffect:
	func _get_skill() -> SkillData.NamedSkill:
		return null

class BasicSkill extends ISkill:
	var _skill : SkillData.NamedSkill
	func _init(skill : SkillData.NamedSkill):
		_skill = skill
		
	func _get_skill() -> SkillData.NamedSkill:
		return _skill


class ISkillFactory:
	func _create(_skill : SkillData.NamedSkill) -> ISkill:
		return null



class IState extends IEffect:
	func _serialize() -> Array: # [id,fit_data]
		return [0,null]

class BasicState extends IState:
	var _container : Array
	func _init(container : Array):
		_container = container
		_container.append(self)

	func remove_self() -> void:
		_container.erase(self)
