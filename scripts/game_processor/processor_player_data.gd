
class_name ProcessorPlayerData
	
var deck_list : Array = []

var hand : Array = []
var stock : Array = []
var played : Array = []
var discard : Array = []
var _life : int = 0

var next_effect := ProcessorData.Affected.new()

var select : int = -1
var damage : int = 0
var draw_indexes : Array = []
var select_card : ProcessorData.PlayerCard = null

var multiply_power : float = 1.0
var multiply_hit : float = 1.0
var multiply_block : float = 1.0


func _init(deck : Array,hand_count : int,
		card_catalog : CardCatalog,shuffle : bool = true) -> void:
	for i in range(deck.size()):
		var c := ProcessorData.PlayerCard.new(card_catalog.new_card_data(deck[i]),i)
		deck_list.append(c);
		stock.append(i);
		_life += c.data.level
	if shuffle:
		stock.shuffle()
# warning-ignore:unused_variable
	for i in range(hand_count):
# warning-ignore:return_value_discarded
		_draw_card()

func get_hand_card(index : int) -> ProcessorData.PlayerCard:
	return deck_list[hand[index]]
func get_lastplayed_card() -> ProcessorData.PlayerCard:
	return null if played.empty() else deck_list[played.back()]

	
func get_life() -> int:
	return _life
	
func combat_start(i : int):
	select = i
	draw_indexes.clear()
	for c in deck_list:
		(c as ProcessorData.PlayerCard).affected.reset_update()
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

func combat_fix_damage() -> void:
	var total_damage := damage - get_current_block()
	damage = 0 if total_damage < 0 else total_damage

func combat_end() -> void:
	played.push_back(select_card.id_in_deck)
	

func add_damage(d: int):
	damage += d
	
func is_fatal() -> bool:
	if _life <= damage:
		return true
	return false
	
func supply() -> void:
# warning-ignore:return_value_discarded
	_draw_card()
	if damage > 0:
# warning-ignore:return_value_discarded
		_draw_card()
	
func recover(index : int) -> void:
	select = index
	draw_indexes.clear()
	select_card = deck_list[hand[index]]
	var id := _discard_card(index)
	var card := deck_list[id] as ProcessorData.PlayerCard
	if damage <= card.data.level:
		damage = 0
		return
	damage -= card.data.level
	# warning-ignore:return_value_discarded
	_draw_card()

func no_recover() -> void:
	select = -1
	draw_indexes.clear()
	
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

func _draw_card() -> int:
	if stock.empty():
		return -1
	var i := stock.pop_back() as int
	hand.push_back(i)
	draw_indexes.push_back(i)
	return i
func _discard_card(i : int) -> int:
	var id := hand.pop_at(i) as int
	_life -= deck_list[id].data.level
	discard.push_back(id)
	return id

