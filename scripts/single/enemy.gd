extends MechanicsData.IPlayer


class_name SinglePlayerEnemy


var deck_list : Array = []

var hand : Array = []
var stock : Array = []
var played : PoolIntArray = []
var discard : PoolIntArray = []
var _life : int = 0

var next_effect := MechanicsData.Affected.new()

var playing_hand : PoolIntArray = []
var select : int = -1
var damage : int = 0
var draw_indexes : PoolIntArray = []
var select_card : MechanicsData.PlayerCard = null
var skill_log : Array = [] # of SkillLog



func _init(deck : Array,hand_count : int,hp : int,
		card_catalog : CardCatalog,shuffle : bool = true) -> void:
	for i in range(deck.size()):
		var c := MechanicsData.PlayerCard.new(card_catalog.new_card_data(deck[i]),i)
		deck_list.append(c);
		stock.append(i);
	_life = hp
	if shuffle:
		stock.shuffle()
	for _i in range(hand_count):
		_draw_card()


func _get_deck_list() -> Array:
	return deck_list
func _get_hand() -> PoolIntArray:
	return PoolIntArray(hand)
func _get_played() -> PoolIntArray:
	return played
func _get_discard() -> PoolIntArray:
	return discard

func _get_stock_count() -> int:
	return stock.size()
	
func _get_life() -> int:
	return _life

func _get_next_effect() -> MechanicsData.Affected:
	return next_effect
func _add_next_effect(add : MechanicsData.Affected):
	next_effect.add_other(add)

func _get_playing_hand() -> PoolIntArray:
	return playing_hand
	
func _get_select() -> int:
	return select

func _get_damage() -> int:
	return damage

func _get_draw() -> PoolIntArray:
	return draw_indexes
	
func _get_skill_log() -> Array:
	return skill_log

	
func _combat_start(i : int):
	playing_hand = hand.duplicate()
	select = i
	draw_indexes.resize(0)
	skill_log.clear()
	select_card = deck_list[hand.pop_at(i)]
	_life -= select_card.data.level
	select_card.affected.add_other(next_effect)
	next_effect.reset()
	return
	

func _get_playing_card() -> MechanicsData.PlayerCard:
	return select_card
func _get_link_color() -> int:
	return 0 if played.empty() else deck_list[played[played.size()-1]].data.color

	
func _get_current_power() -> int:
	return int(select_card.get_current_power())
func _get_current_hit() -> int:
	return int(select_card.get_current_hit())
func _get_current_block() -> int:
	return int(select_card.get_current_block())

func _damage_is_fatal() -> bool:
	var total_damage := damage - _get_current_block()
	damage = 0 if total_damage < 0 else total_damage
	if _life <= damage or stock.size() + hand.size() == 0:
		return true
	_life -= damage
	return false
	
func _add_damage(d: int):
	damage += d
	
func _append_skill_log(s_log : MechanicsData.SkillLog):
	skill_log.append(s_log)
	
func _combat_end() -> void:
	played.push_back(select_card.id_in_deck)


func _supply() -> void:
	_draw_card()
	
func _recover(_index : int) -> void:
	playing_hand = hand
	select = -1
	draw_indexes.resize(0)
	skill_log.clear()

func _no_recover() -> void:
	playing_hand = hand
	select = -1
	draw_indexes.resize(0)
	skill_log.clear()
	
func _is_recovery() -> bool:
	return true

func _change_order(new_hand : PoolIntArray) -> void:
	if new_hand.size() != hand.size():
		return
	for i in hand:
		if not new_hand.has(i):
			return
	for i in range(hand.size()):
		hand[i] = new_hand[i]

func _reset_select():
	select = -1

func _draw_card():
	if stock.empty():
		return
	var i := stock.pop_back() as int
	hand.push_back(i)
	draw_indexes.push_back(i)

func _discard_card(i : int):
	var id := hand.pop_at(i) as int
	discard.push_back(id)

func _hand_to_deck_bottom(i : int):
	var id := hand.pop_at(i) as int
	stock.push_front(id)

