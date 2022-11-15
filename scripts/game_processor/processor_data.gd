
class_name ProcessorData


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
	var index : int # select card skill index
	var timing : int
	var priority : int
	var data # skill proper data
	
	func _init(i,t,p,d):
		index = i
		timing = t
		priority = p
		data = d


class Player:
	
	var deck_list : Array = []

	var hand : Array = []
	var stock : Array = []
	var played : Array = []
	var discard : Array = []
	var _life : int = 0

	var next_effect := Affected.new()

	var playing_hand : Array = []
	var select : int = -1
	var damage : int = 0
	var draw_indexes : Array = []
	var select_card : PlayerCard = null
	var skill_log : Array = [] # of SkillLog

	var multiply_power : float = 1.0
	var multiply_hit : float = 1.0
	var multiply_block : float = 1.0


	func _init(deck : Array,hand_count : int,
			card_catalog : CardCatalog,shuffle : bool = true) -> void:
		for i in range(deck.size()):
			var c := PlayerCard.new(card_catalog.new_card_data(deck[i]),i)
			deck_list.append(c);
			stock.append(i);
			_life += c.data.level
		if shuffle:
			stock.shuffle()
	# warning-ignore:unused_variable
		for i in range(hand_count):
	# warning-ignore:return_value_discarded
			_draw_card()

	func get_hand_card(index : int) -> PlayerCard:
		return deck_list[hand[index]]
	func get_lastplayed_card() -> PlayerCard:
		return null if played.empty() else deck_list[played.back()]

		
	func get_life() -> int:
		return _life
		
	func combat_start(i : int):
		playing_hand = hand.duplicate()
		select = i
		draw_indexes.clear()
		skill_log.clear()
		select_card = deck_list[hand.pop_at(i)]
		_life -= select_card.data.level
		select_card.affected.add_other(next_effect)
		next_effect.reset()
		multiply_power = 1.0
		multiply_hit = 1.0
		multiply_block = 1.0
		return
		
	func get_current_power() -> int:
		return int(select_card.get_current_power() * multiply_power)
	func get_current_hit() -> int:
		return int(select_card.get_current_hit() * multiply_hit)
	func get_current_block() -> int:
		return int(select_card.get_current_block() * multiply_block)

	func damage_is_fatal() -> bool:
		var total_damage := damage - get_current_block()
		damage = 0 if total_damage < 0 else total_damage
		if _life <= damage:
			return true
		return false
		
	func combat_end() -> void:
		played.push_back(select_card.id_in_deck)


	func add_damage(d: int):
		damage += d
		
		
	func supply() -> void:
		_draw_card()
		if damage > 0:
			_draw_card()
		
	func recover(index : int) -> void:
		playing_hand = hand.duplicate()
		select = index
		draw_indexes.clear()
		skill_log.clear()
		select_card = deck_list[hand[index]]
		_discard_card(index)
		if damage <= select_card.data.level:
			damage = 0
			return
		damage -= select_card.data.level
		_draw_card()

	func no_recover() -> void:
		playing_hand = hand
		select = -1
		draw_indexes.clear()
		skill_log.clear()
		
	func is_recovery() -> bool:
		return damage == 0

	func change_order(new_indexies : Array) -> bool:
		if new_indexies.size() != hand.size():
			return false
		for i in hand:
			if not new_indexies.has(i):
				return false
		for i in range(hand.size()):
			hand[i] = new_indexies[i]
		return true


	func reset_select():
		select = -1

	func _draw_card():
		if stock.empty():
			return -1
		var i := stock.pop_back() as int
		hand.push_back(i)
		draw_indexes.push_back(i)

	func _discard_card(i : int):
		var id := hand.pop_at(i) as int
		_life -= deck_list[id].data.level
		discard.push_back(id)

	func hand_to_deck_bottom(i : int):
		var id := hand.pop_at(i) as int
		stock.push_front(id)


