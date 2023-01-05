
extends MechanicsData.IPlayer


class_name OfflinePlayer


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
var skill_log : Array = [] # of EffectLog

var multiply_power : float = 1.0
var multiply_hit : float = 1.0
var multiply_block : float = 1.0


func _init(deck : Array,hand_count : int,
		card_catalog : CardCatalog,shuffle : bool = true) -> void:
	var s_factory = SkillFactory.new()
	for i in range(deck.size()):
		var c := MechanicsData.PlayerCard.new(card_catalog.new_card_data(deck[i]),i,s_factory)
		deck_list.append(c);
		stock.append(i);
		_life += c.data.level
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
	
func _get_effect_log() -> Array:
	return skill_log

	
func _combat_start(i : int) -> void:
	playing_hand = hand.duplicate()
	select = i
	draw_indexes.resize(0)
	skill_log.clear()
	select_card = deck_list[hand.pop_at(i)]
	_life -= select_card.data.level
	select_card.affected.add_other(next_effect)
	next_effect.reset()
	multiply_power = 1.0
	multiply_hit = 1.0
	multiply_block = 1.0
	return
	

func _get_playing_card() -> MechanicsData.PlayerCard:
	return select_card
func _get_link_color() -> int:
	return 0 if played.empty() else deck_list[played[played.size()-1]].data.color

	
func _get_current_power() -> int:
	return int(select_card.get_current_power() * multiply_power)
func _get_current_hit() -> int:
	return int(select_card.get_current_hit() * multiply_hit)
func _get_current_block() -> int:
	return int(select_card.get_current_block() * multiply_block)

func _damage_is_fatal() -> bool:
	var total_damage := damage - _get_current_block()
	damage = 0 if total_damage < 0 else total_damage
	if _life <= damage:
		return true
	return false
	
func _add_damage(d: int) -> void:
	damage += d
	
func _append_effect_log(index : int,timing : int,priority : int,data) -> void:
	skill_log.append(MechanicsData.EffectLog.new(index,timing,priority,data))
	
func _combat_end() -> void:
	played.push_back(select_card.id_in_deck)


func _supply() -> void:
	_draw_card()
	if damage > 0:
		_draw_card()
	
func _recover(index : int) -> void:
	playing_hand = hand.duplicate()
	select = index
	draw_indexes.resize(0)
	skill_log.clear()
	select_card = deck_list[hand[index]]
	_discard_card(index)
	if damage <= select_card.data.level:
		damage = 0
		return
	damage -= select_card.data.level
	_draw_card()

func _no_recover() -> void:
	playing_hand = hand
	select = -1
	draw_indexes.resize(0)
	skill_log.clear()
	
func _is_recovery() -> bool:
	return damage == 0

func _change_order(new_indexies : PoolIntArray) -> void:
	if new_indexies.size() != hand.size():
		return
	for i in hand:
		if not new_indexies.has(i):
			return
	for i in range(hand.size()):
		hand[i] = new_indexies[i]
	return


func _reset_select() -> void:
	select = -1

func _draw_card() -> void:
	if stock.empty():
		return
	var i := stock.pop_back() as int
	hand.push_back(i)
	draw_indexes.push_back(i)

func _discard_card(i : int) -> void:
	var id := hand.pop_at(i) as int
	_life -= deck_list[id].data.level
	discard.push_back(id)


func _hand_to_deck_bottom(i : int) -> void:
	var id := hand.pop_at(i) as int
	stock.push_front(id)




