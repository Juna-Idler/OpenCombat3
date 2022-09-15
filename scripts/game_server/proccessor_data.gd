
class_name ProccessorData

class Card:
	var data := CardData.new()
	var id_in_deck : int = 0

	var variation := Variation.new()
	class Variation:
		var power : int = 0
		var hit : int = 0
		var damage : int = 0
		var rush : int = 0
		func rest():
			power = 0
			hit = 0
			damage = 0
			rush = 0;
		func add(v : Variation):
			power += v.power
			hit += v.hit
			damage += v.damage
			rush += v.rush
#	var additional_skills : Array
#	var addtional_changes : Dictionary = {}

	func get_current_power() -> int:
		return data.power + variation.power if (data.power + variation.power) > 0 else 0;
	func get_current_hit() -> int:
		return data.hit + variation.hit if (data.hit + variation.hit) > 0 else 0;


class PlayerData:
	var deck_list : Array = []
	
	var hand_indexes : Array = []
	var stack_indexes : Array = []
	var played_indexes : Array = []
	var discard_indexes : Array = []
	var _hit_point : int = 0
	
	var next_effect : Card.Variation = Card.Variation.new()
	
	var select : int = -1
	var battle_damage : int = 0
	var draw_indexes : Array = []
	var playing_card_id : int = -1
	
	func _init(deck : Array,card_catalog : CardCatalog) -> void:
		for i in deck.size():
			var c = Card.new()
			card_catalog.set_card_data(c.data,deck[i])
			c.id_in_deck = i
			deck_list.append(c);
			stack_indexes.append(i);
			_hit_point += c.data.level
# シャッフル
		stack_indexes.sort()

	func get_hand_card(index : int) -> Card:
		return deck_list[hand_indexes[index]]
	func get_lastplayed_card() -> Card:
		return null if played_indexes.empty() else deck_list[played_indexes.back()]
	func get_playing_card() -> Card:
		return null if playing_card_id < 0 else deck_list[playing_card_id]
		
	func get_hit_point() -> int:
		return _hit_point
		
	func draw_card() -> bool:
		if stack_indexes.empty():
			return false
		var i : int = stack_indexes.pop_back()
		hand_indexes.push_back(i)
		draw_indexes.push_back(i)
		return true
		
	func play_combat_card(i : int) -> Card:
		playing_card_id = hand_indexes.pop_at(i);
		_hit_point -= deck_list[playing_card_id].data.level
		return deck_list[playing_card_id]

	func combat_end() -> void:
		played_indexes.push_back(playing_card_id)
		playing_card_id = -1;
		
	func discard_card(i : int):
		var id : int = hand_indexes.pop_at(i);
		_hit_point -= deck_list[id].data.level
		discard_indexes.push_back(id)

