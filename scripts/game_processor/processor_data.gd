
class_name ProcessorData

class Affected:
	var updated : bool = false
	var power : int = 0 setget set_p
	var hit : int = 0 setget set_h
	var damage : int = 0 setget set_d
	var rush : int = 0 setget set_r

	func set_p(v):
		power = v
		updated = true
	func set_h(v):
		hit = v
		updated = true
	func set_d(v):
		damage = v
		updated = true
	func set_r(v):
		rush = v
		updated = true

	func add(p:int,h:int,d:int,r:int):
		power += p
		hit += h
		damage += d
		rush += r
		updated = true;
	func add_other(v : Affected):
		add(v.power,v.hit,v.damage,v.rush)
		
	func reset_update():
		updated = false;
	func reset():
		power = 0
		hit = 0
		damage = 0
		rush = 0
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


		

	func get_current_power() -> int:
		return data.power + affected.power if (data.power + affected.power) > 0 else 0;
	func get_current_hit() -> int:
		return data.hit + affected.hit if (data.hit + affected.hit) > 0 else 0;


class PlayerData:
	var deck_list : Array = []
	
	var hand_indexes : Array = []
	var stack_indexes : Array = []
	var played_indexes : Array = []
	var discard_indexes : Array = []
	var _life : int = 0
	
	var next_effect := Affected.new()
	
	var select : int = -1
	var battle_damage : int = 0
	var draw_indexes : Array = []
	var playing_card_id : int = -1
	var playing_card : PlayerCard = null

	func _init(deck : Array,hand_count : int,
			card_catalog : CardCatalog,shuffle : bool = true) -> void:
		for i in range(deck.size()):
			var c := PlayerCard.new(card_catalog.new_card_data(deck[i]),i)
			deck_list.append(c);
			stack_indexes.append(i);
			_life += c.data.level
		if shuffle:
			stack_indexes.shuffle()
# warning-ignore:unused_variable
		for i in range(hand_count):
# warning-ignore:return_value_discarded
			_draw_card()

	func get_hand_card(index : int) -> PlayerCard:
		return deck_list[hand_indexes[index]]
	func get_lastplayed_card() -> PlayerCard:
		return null if played_indexes.empty() else deck_list[played_indexes.back()]

		
	func get_life() -> int:
		return _life
		
	func play_combat_card(i : int) -> PlayerCard:
		select = i
		draw_indexes.clear()
		for c in deck_list:
			(c as PlayerCard).affected.reset_update()
		playing_card_id = hand_indexes.pop_at(i)
		playing_card = deck_list[playing_card_id]
		_life -= playing_card.data.level
		playing_card.affected.add_other(next_effect)
		next_effect.reset()
		return playing_card

	func combat_end() -> void:
		var damage := battle_damage + playing_card.affected.damage
		battle_damage = 0 if damage < 0 else damage
		played_indexes.push_back(playing_card_id)

		
	func add_damage(damage : int):
		battle_damage += damage
		
	func is_fatal() -> bool:
		if _life < battle_damage:
			return true
		return false
		
	func supply() -> void:
# warning-ignore:return_value_discarded
		_draw_card()
		if battle_damage > 0:
# warning-ignore:return_value_discarded
			_draw_card()
		
	func recover(index : int) -> void:
		select = index
		draw_indexes.clear()
		var id := _discard_card(index)
		var card := deck_list[id] as PlayerCard
		if battle_damage <= card.data.level:
			battle_damage = 0
			return
		battle_damage -= card.data.level
		# warning-ignore:return_value_discarded
		_draw_card()
	
	func no_recover() -> void:
		select = -1
		draw_indexes.clear()
		
	func is_recovery() -> bool:
		return battle_damage == 0

	func change_order(new_indexies : Array) -> bool:
		if new_indexies.size() != hand_indexes.size():
			return false
		for i in hand_indexes:
			if not new_indexies.has(i):
				return false
		for i in range(hand_indexes.size()):
			hand_indexes[i] = new_indexies[i]
		return true

	
	func reset_select():
		select = -1
	
	func _draw_card() -> int:
		if stack_indexes.empty():
			return -1
		var i := stack_indexes.pop_back() as int
		hand_indexes.push_back(i)
		draw_indexes.push_back(i)
		return i
	func _discard_card(i : int) -> int:
		var id := hand_indexes.pop_at(i) as int
		_life -= deck_list[id].data.level
		discard_indexes.push_back(id)
		return id
