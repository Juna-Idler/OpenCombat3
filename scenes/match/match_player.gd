# warning-ignore-all:return_value_discarded

extends Reference

class_name MatchPlayer

const CardScene = preload("card.tscn")

const CARD_MOVE_DURATION : float = 1.0

const ALWAYS_CARD_VISIBLE = false

var deck_list : Array # of MatchCard

var hand : Array = [] # of int
var played : Array = [] # of int
var discard : Array = [] # of int
var stock_count : int
var life : int = 0
var damage : int = 0
var draw : Array = [] # of int
var effect_logs : Array = [] # of IGameServer.UpdateData.EffectLog

var states : Array = [] # of MatchEffect.IState


var playing_card_id : int = -1
var playing_card : MatchCard = null

var player_name : String


var player_field : I_PlayerField

var combat_avatar : CombatAvatar


var power_balance : CombatPowerBalance.Interface


func get_link_color() -> int:
	if played.empty():
		return 0
	return (deck_list[played.back()] as MatchCard).front.data.color



func _init(name : String,
		dl:Array,
		catalog : I_CardCatalog,
		skill_factory : MatchEffect.ISkillFactory,
		reverse : bool,
		card_layer:Node,
		player_field_ : I_PlayerField,
		avatar : CombatAvatar,
		pb_interface : CombatPowerBalance.Interface):
	
	player_name = name
	player_field = player_field_
	combat_avatar = avatar
	power_balance = pb_interface
	
	deck_list = []
	for i in dl.size():
		var c := CardScene.instance().initialize_card(i,
				catalog._get_card_data(dl[i]),skill_factory,reverse) as MatchCard
		deck_list.append(c)
		c.position = player_field._get_stock_pos()
		c.visible = ALWAYS_CARD_VISIBLE
		card_layer.add_child(c)
			
	stock_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as MatchCard
		i.location = MatchCard.Location.STOCK
	player_field._set_name(player_name)

func standby(l: int,start_hand : Array):
	life = l
	player_field._set_damage(0)
	player_field._set_life(life)
	draw = start_hand
	draw_all_card()


func set_hand(new_hand_indexes:Array):
	hand = new_hand_indexes
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as MatchCard
		c.visible = true
		c.z_index = i + 100
		c.location = MatchCard.Location.HAND
		cards.append(c)
	player_field._set_hand(cards)
	player_field._move_hand(CARD_MOVE_DURATION)


func play(hand_select : int,new_hand : Array,d : int,draw_indexes : Array,s_log : Array,tween : SceneTreeTween):
	hand = new_hand
	damage = d
	draw = draw_indexes
	effect_logs = s_log
	playing_card_id = hand[hand_select]
	playing_card = deck_list[playing_card_id]
	hand.remove(hand_select)
	life -= playing_card.get_card_data().level
	player_field._set_life_provisional(life)
	tween.parallel()
	tween.tween_property(playing_card,"global_position",player_field._get_playing_pos(),0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func play_end(new_life : int):
	life = new_life
	player_field._set_life(life)
	played.append(playing_card_id)
	playing_card.z_index = played.size() + 0
	playing_card.location = MatchCard.Location.PLAYED
	var tween := playing_card.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(playing_card,"global_position",player_field._get_played_pos(),0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	tween.tween_callback(self,"_set_played_visible")
	draw_all_card()
	player_field._set_damage(damage)

	playing_card_id = -1
	playing_card = null

func _set_played_visible():
	if played.size() >= 2:
		deck_list[played[played.size()-2]].visible = ALWAYS_CARD_VISIBLE
	

func recover(hand_select : int,new_hand : Array,draw_indexes : Array,now_damage : int,new_life : int):
	hand = new_hand
	draw = draw_indexes
	if hand_select >= 0:
		discard_card(hand_select,CARD_MOVE_DURATION)
	damage = now_damage
	life = new_life
	player_field._set_damage(now_damage)
	player_field._set_life(life)
	draw_all_card()

func draw_card():
	if not draw.empty():
		stock_count -= 1
		player_field._set_stock(stock_count)
		var c = draw.pop_front()
		hand.append(c)
	set_hand(hand)

func draw_all_card():
	if not draw.empty():
		stock_count -= draw.size()
		player_field._set_stock(stock_count)
		hand.append_array(draw)
		draw.clear()
	set_hand(hand)

func discard_card(hand_index : int,duration : float):
	var select_id = hand[hand_index]
	hand.remove(hand_index)
	discard.append(select_id)
	var card := deck_list[select_id] as MatchCard
	life -= card.get_card_data().level
	player_field._set_life_provisional(life)
	card.z_index = discard.size() + 200
	card.location = MatchCard.Location.DISCARD
	var tween := card.create_tween()
	tween.tween_property(card,"global_position",player_field._get_discard_pos(),duration)
	tween.tween_callback(self,"_set_discard_visible")

func send_to_deck(hand_index : int,duration : float):
	if hand.empty():
		return
	var id = hand[hand_index]
	hand.remove(hand_index)
	stock_count += 1
	player_field._set_stock(stock_count)
	var card := deck_list[id] as MatchCard
	card.location = MatchCard.Location.STOCK
	var tween := card.create_tween()
	tween.tween_property(card,"global_position",player_field._get_stock_pos(),duration)
	tween.tween_callback(card,"hide")


func _set_discard_visible():
	if discard.size() >= 2:
		deck_list[discard[discard.size()-2]].visible = ALWAYS_CARD_VISIBLE


func get_current_power() -> int:
	return playing_card.get_current_power()
func get_current_hit() -> int:
	return playing_card.get_current_hit()
func get_current_block() -> int:
	return playing_card.get_current_block()

func add_attribute(power :int,hit : int,block : int):
	playing_card.affected.power += power
	playing_card.affected.hit += hit
	playing_card.affected.block += block
	combat_avatar.set_power(playing_card.get_current_power())
	combat_avatar.set_hit(playing_card.get_current_hit())
	combat_avatar.set_block(playing_card.get_current_block())
	if power != 0:
		power_balance.set_my_power_tween_step_by_step(playing_card.get_current_power(),0.5)



func reset_board(h_card:PoolIntArray,p_card:PoolIntArray,d_card:PoolIntArray,
		s_count:int,l_count:int,d_count:int,
		st:Array,a_list:Array,state_deserializer:MatchEffect.IStateDeserializer):
	hand = Array(h_card)
	played = Array(p_card)
	discard = Array(d_card)
	stock_count  = s_count
	life = l_count
	damage = d_count
	states.clear()
	for i in st:
		state_deserializer._deserialize(i[0],i[1],states)
	
	for i in a_list.size():
		deck_list[i].affected = a_list[i]

	for c_ in deck_list:
		var c := c_ as MatchCard
		if c.location != MatchCard.Location.STOCK:
			c.show()
		c.location = MatchCard.Location.STOCK
#		c.position = stock_pos
#		c.rotation = 0

	var tween := (deck_list[0] as Node).create_tween()
	tween.set_parallel(true)

	for i in played.size():
		var c := deck_list[played[i]] as MatchCard
		c.visible = ALWAYS_CARD_VISIBLE or i >= played.size() - 1
		c.z_index = i + 0
		c.location = MatchCard.Location.PLAYED
		tween.tween_property(c,"global_position",player_field._get_played_pos(),CARD_MOVE_DURATION)
		tween.tween_property(c,"rotation",PI/2.0,CARD_MOVE_DURATION)
	
	for i in discard.size():
		var c := deck_list[discard[i]] as MatchCard
		c.visible = ALWAYS_CARD_VISIBLE or i >= discard.size() - 1
		c.z_index = i + 200
		c.location = MatchCard.Location.DISCARD
		tween.tween_property(c,"global_position",player_field._get_discard_pos(),CARD_MOVE_DURATION)
		tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)
	
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as MatchCard
		c.visible = true
		c.z_index = i + 100
		c.location = MatchCard.Location.HAND
		tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)
		cards.append(c)
	player_field._set_hand(cards)
	player_field._move_hand(CARD_MOVE_DURATION)
	
	for c_ in deck_list:
		var c := c_ as MatchCard
		if c.location == MatchCard.Location.STOCK:
			tween.tween_property(c,"global_position",player_field._get_stock_pos(),CARD_MOVE_DURATION)
			tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)

	tween.set_parallel(false)
	for c_ in deck_list:
		var c := c_ as MatchCard
		if c.location == MatchCard.Location.STOCK:
			if not ALWAYS_CARD_VISIBLE:
				tween.tween_callback(c,"hide")
		elif c.location == MatchCard.Location.PLAYED:
			if c.id_in_deck != played.back():
				if not ALWAYS_CARD_VISIBLE:
					tween.tween_callback(c,"hide")
		elif c.location == MatchCard.Location.DISCARD:
			if c.id_in_deck != discard.back():
				if not ALWAYS_CARD_VISIBLE:
					tween.tween_callback(c,"hide")

	player_field._set_life(life)
	player_field._set_stock(stock_count)
	player_field._set_damage(damage)
	player_field._set_states(states)


