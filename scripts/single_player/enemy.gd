extends ProcessorData.Player


class_name SinglePlayerEnemy
	

func _init(deck : Array,hand_count : int,life : int,card_catalog : CardCatalog)\
		.(deck,hand_count,card_catalog) -> void:
	stock.invert()
	_life = life



func combat_start(i : int):
	select = i
	draw_indexes.clear()
	for c in deck_list:
		(c as ProcessorData.PlayerCard).affected.reset_update()
	select_card = deck_list[hand.pop_at(i)]
#	_life -= select_card.data.level
	select_card.affected.add_other(next_effect)
	next_effect.reset()
	multiply_power = 1.0
	multiply_hit = 1.0
	multiply_block = 1.0
	
func damage_is_fatal() -> bool:
	var total_damage := damage - get_current_block()
	damage = 0 if total_damage < 0 else total_damage
	_life -= damage
	if _life <= 0:
		return true
	return false
	
func add_damage(d: int):
	damage += d
	

	
func supply() -> void:
	_draw_card()

	
func recover(index : int) -> void:
	pass

func no_recover() -> void:
	select = -1
	draw_indexes.clear()
	
func is_recovery() -> bool:
	return true

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

func _draw_card() -> int:
	if stock.empty():
		for i in range(deck_list.size() -1,-1,-1):
			stock.append(i)
	var i := stock.pop_back() as int
	hand.push_back(i)
	draw_indexes.push_back(i)
	(deck_list[i] as ProcessorData.PlayerCard).affected.reset()
	return i
	
func _discard_card(i : int) -> int:
	return -1

