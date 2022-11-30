
class_name MechanicsData


class Affected:
	var power : int = 0
	var hit : int = 0
	var block : int = 0

	func add(p:int,h:int,b:int):
		power += p
		hit += h
		block += b
	func add_other(v : Affected):
		add(v.power,v.hit,v.block)
		
	func reset():
		power = 0
		hit = 0
		block = 0


class PlayerCard:
	var data : CardData = null
	var id_in_deck : int = 0

	var affected := Affected.new()

	func _init(cd : CardData,iid : int):
		data = cd
		id_in_deck = iid
#	var additional_skills : Array
#	var addtional_changes : Dictionary = {}


	static func int_max(a : int, b : int) -> int:
		return a if a > b else b

	func get_current_power() -> int:
		return int_max(data.power + affected.power,0)
	func get_current_hit() -> int:
		return int_max(data.hit + affected.hit,0)
	func get_current_block() -> int:
		return int_max(data.block + affected.block,0)


enum SkillTiming {BEFORE = 0,ENGAGED = 1,AFTER = 2,END = 3}

class SkillLog:
	var index : int # skill index of playing card 
	var timing : int
	var priority : int
	var data # skill proper data
	
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

	func _get_next_effect() -> Affected:
		return null

	func _get_playing_hand() -> PoolIntArray:
		return PoolIntArray()

	func _get_select() -> int:
		return 0

	func _get_damage() -> int:
		return 0

	func _get_draw() -> PoolIntArray:
		return PoolIntArray()

	func _get_skill_log() -> Array:
		return []


	func _combat_start(_index : int):
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

	func _add_damage(_d: int):
		return
		
	func _append_skill_log(_log : SkillLog):
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


	func _change_order(_new_hand : PoolIntArray) -> bool:
		return true


	func _reset_select():
		return


	func _draw_card():
		return

	func _discard_card(_index : int):
		return

	func _skill_draw_card() -> int:
		return -1

	func _hand_to_deck_bottom(_index : int):
		return
