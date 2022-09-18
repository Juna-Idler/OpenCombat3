
class_name ProcessorData

class Card:
	var data := CardData.new()
	var id_in_deck : int = 0

	var affected := Affected.new()
	class Affected:
		var power : int = 0
		var hit : int = 0
		var damage : int = 0
		var rush : int = 0
		func rest():
			power = 0
			hit = 0
			damage = 0
			rush = 0;
		func add(v : Affected):
			power += v.power
			hit += v.hit
			damage += v.damage
			rush += v.rush
#	var additional_skills : Array
#	var addtional_changes : Dictionary = {}

	func get_current_power() -> int:
		return data.power + affected.power if (data.power + affected.power) > 0 else 0;
	func get_current_hit() -> int:
		return data.hit + affected.hit if (data.hit + affected.hit) > 0 else 0;


class Player:
	var deck_list : Array = []
	
	var hand_indexes : Array = []
	var stack_indexes : Array = []
	var played_indexes : Array = []
	var discard_indexes : Array = []
	var _hit_point : int = 0
	
	var next_effect := Card.Affected.new()
	
	var select : int = -1
	var battle_damage : int = 0
	var draw_indexes : Array = []
	var playing_card_id : int = -1
	var playing_card : Card = null

	func _init(deck : Array,hand_count : int,
			card_catalog : CardCatalog,shuffle : bool = true) -> void:
		for i in deck.size():
			var c := Card.new()
			card_catalog.set_card_data(c.data,deck[i])
			c.id_in_deck = i
			deck_list.append(c);
			stack_indexes.append(i);
			_hit_point += c.data.level
# シャッフル
		if shuffle:
			stack_indexes.sort()
		
		for i in range(hand_count):
			_draw_card()

	func get_hand_card(index : int) -> Card:
		return deck_list[hand_indexes[index]]
	func get_lastplayed_card() -> Card:
		return null if played_indexes.empty() else deck_list[played_indexes.back()]
	func get_playing_card() -> Card:
		return playing_card
		
	func get_hit_point() -> int:
		return _hit_point
		
	func play_combat_card(i : int) -> Card:
		playing_card_id = hand_indexes.pop_at(i)
		playing_card = deck_list[playing_card_id]
		_hit_point -= playing_card.data.level
		playing_card.affected.add(next_effect)
		next_effect.rest()
		return playing_card

	func combat_end() -> void:
		var damage := battle_damage + playing_card.affected.damage
		battle_damage = 0 if damage < 0 else damage
		played_indexes.push_back(playing_card_id)
		playing_card_id = -1;
		playing_card = null
		
	func add_damage(damage : int):
		battle_damage += damage
		
	func is_fatal() -> bool:
		if _hit_point < battle_damage:
			return true
		return false
	
	
	func _draw_card() -> int:
		if stack_indexes.empty():
			return -1
		var i := stack_indexes.pop_back() as int
		hand_indexes.push_back(i)
		draw_indexes.push_back(i)
		return i
	func _discard_card(i : int) -> int:
		var id := hand_indexes.pop_at(i) as int
		_hit_point -= deck_list[id].data.level
		discard_indexes.push_back(id)
		return id
		
	func recover(index : int) -> bool:
		var id := _discard_card(index)
		var card := deck_list[id] as Card
		if battle_damage <= card.level:
			battle_damage = 0
			return true
		battle_damage -= card.data.level
		# warning-ignore:return_value_discarded
		_draw_card()
		return false
		
	func is_recovery() -> bool:
		return battle_damage == 0

	func change_order(sort_indexies : Array) -> void:
		var new_hands : Array = []
		for x in sort_indexies:
			new_hands.append(hand_indexes[x])
		hand_indexes = new_hands
	
