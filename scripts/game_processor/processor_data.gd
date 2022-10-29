
class_name ProcessorData

class Affected:
	var updated : bool = false
	var power : int = 0 setget set_p
	var hit : int = 0 setget set_h
	var block : int = 0 setget set_b

	func set_p(v):
		power = v
		updated = true
	func set_h(v):
		hit = v
		updated = true
	func set_b(v):
		block = v
		updated = true

	func add(p:int,h:int,b:int):
		power += p
		hit += h
		block += b
		updated = true;
	func add_other(v : Affected):
		add(v.power,v.hit,v.block)
		
	func reset_update():
		updated = false;
	func reset():
		power = 0
		hit = 0
		block = 0
		updated = true;


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


