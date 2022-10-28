
class_name ProcessorPlayerData
	
var deck_list : Array = []

var hand_indexes : Array = []
var stack_indexes : Array = []
var played_indexes : Array = []
var discard_indexes : Array = []
var _life : int = 0

var next_effect := ProcessorData.Affected.new()

var select : int = -1
var combat_damage : int = 0
var additional_damage : int = 0
var draw_indexes : Array = []
var select_card : ProcessorData.PlayerCard = null

func _init(deck : Array,hand_count : int,
		card_catalog : CardCatalog,shuffle : bool = true) -> void:
	for i in range(deck.size()):
		var c := ProcessorData.PlayerCard.new(card_catalog.new_card_data(deck[i]),i)
		deck_list.append(c);
		stack_indexes.append(i);
		_life += c.data.level
	if shuffle:
		stack_indexes.shuffle()
# warning-ignore:unused_variable
	for i in range(hand_count):
# warning-ignore:return_value_discarded
		_draw_card()

func get_hand_card(index : int) -> ProcessorData.PlayerCard:
	return deck_list[hand_indexes[index]]
func get_lastplayed_card() -> ProcessorData.PlayerCard:
	return null if played_indexes.empty() else deck_list[played_indexes.back()]

	
func get_life() -> int:
	return _life
	
func combat_start(i : int) -> ProcessorData.PlayerCard:
	select = i
	draw_indexes.clear()
	for c in deck_list:
		(c as ProcessorData.PlayerCard).affected.reset_update()
	select_card = deck_list[hand_indexes.pop_at(i)]
	_life -= select_card.data.level
	select_card.affected.add_other(next_effect)
	next_effect.reset()
	return select_card
	
func combat_fix_damage() -> void:
	var damage := combat_damage + additional_damage
	additional_damage = 0
	combat_damage = 0 if damage < 0 else damage

func combat_end() -> void:
	played_indexes.push_back(select_card.id_in_deck)
	

func add_damage(d: int):
	additional_damage += d
	
func is_fatal() -> bool:
	if _life <= combat_damage:
		return true
	return false
	
func supply() -> void:
# warning-ignore:return_value_discarded
	_draw_card()
	if combat_damage > 0:
# warning-ignore:return_value_discarded
		_draw_card()
	
func recover(index : int) -> void:
	select = index
	draw_indexes.clear()
	select_card = deck_list[hand_indexes[index]]
	var id := _discard_card(index)
	var card := deck_list[id] as ProcessorData.PlayerCard
	if combat_damage <= card.data.level:
		combat_damage = 0
		return
	combat_damage -= card.data.level
	# warning-ignore:return_value_discarded
	_draw_card()

func no_recover() -> void:
	select = -1
	draw_indexes.clear()
	
func is_recovery() -> bool:
	return combat_damage == 0

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

