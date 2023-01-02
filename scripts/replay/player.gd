
extends MechanicsData.IPlayer


class_name ReplayPlayer


var deck_list : Array

var hand : Array
var stock_count : int
var played : PoolIntArray = []
var discard : PoolIntArray = []

var next_effect := MechanicsData.Affected.new()

var select_card : MechanicsData.PlayerCard = null

var multiply_power : float = 1.0
var multiply_hit : float = 1.0
var multiply_block : float = 1.0


var rival_side : bool
var update_data : Array
var step_data : IGameServer.UpdateData.PlayerData
var step_draw : Array
var first_data : IGameServer.UpdateData.PlayerData

func _init(match_log :MatchLog,rival : bool,card_catalog : CardCatalog) -> void:
	var s_factory = SkillFactory.new()
	
	rival_side = rival
	var deck = match_log.primary_data.rival_deck_list if rival_side else match_log.primary_data.my_deck_list
	for i in range(deck.size()):
		var c := MechanicsData.PlayerCard.new(card_catalog.new_card_data(deck[i]),i,s_factory)
		deck_list.append(c);
	var fd = match_log.first_data.rival if rival_side else match_log.first_data.myself
	first_data = IGameServer.UpdateData.PlayerData.new(fd.hand,0,[],[],0,fd.life,
			match_log.primary_data.match_regulation.thinking_time * 1000)
	hand = Array(fd.hand)
	stock_count = deck_list.size() - hand.size()
	update_data = match_log.update_data
	set_step(0)


func set_step(step : int):
	if step == 0:
		step_data = first_data
		return
	var data = (update_data[step-1] as MatchLog.TimedUpdateData).data
	step_data = data.rival if rival_side else data.myself
	step_draw = Array(step_data.draw)


func _get_deck_list() -> Array:
	return deck_list
func _get_hand() -> PoolIntArray:
	return PoolIntArray(hand)
func _get_played() -> PoolIntArray:
	return played
func _get_discard() -> PoolIntArray:
	return discard

func _get_stock_count() -> int:
	return stock_count
	
func _get_life() -> int:
	return step_data.life

func _get_next_effect() -> MechanicsData.Affected:
	return next_effect
func _add_next_effect(add : MechanicsData.Affected):
	next_effect.add_other(add)

func _get_playing_hand() -> PoolIntArray:
	return step_data.hand
	
func _get_select() -> int:
	return step_data.select

func _get_damage() -> int:
	return step_data.damage

func _get_draw() -> PoolIntArray:
	return step_data.draw
	
func _get_skill_log() -> Array:
	return step_data.skill_logs

	
func _combat_start(i : int) -> void:
	select_card = deck_list[hand.pop_at(i)]
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
	return false
	
func _add_damage(_d: int) -> void:
	return

func _append_skill_log(_index : int,_timing : int,_priority : int,_data) -> void:
	return

func _combat_end() -> void:
	played.push_back(select_card.id_in_deck)


func _supply() -> void:
	_draw_card()
	if step_data.damage > 0:
		_draw_card()
	
func _recover(index : int) -> void:
	select_card = deck_list[hand[index]]
	_discard_card(index)
	if step_data.damage > 0:
		_draw_card()

func _no_recover() -> void:
	return
	
func _is_recovery() -> bool:
	return step_data.damage == 0

func _change_order(new_indexies : PoolIntArray) -> void:
	hand = Array(new_indexies)
	return


func _reset_select() -> void:
	return

func _draw_card() -> void:
	if not step_draw.empty():
		hand.push_back(step_draw.pop_front())
		stock_count -= 1


func _discard_card(i : int) -> void:
	var id := hand.pop_at(i) as int
	discard.push_back(id)


func _hand_to_deck_bottom(i : int) -> void:
	var _id := hand.pop_at(i) as int
	stock_count += 1



