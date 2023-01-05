# warning-ignore-all:return_value_discarded

extends Reference

class_name MatchPlayer

const CardScene = preload("card.tscn")

const CARD_MOVE_DURATION : float = 1.0

const ALWAYS_CARD_VISIBLE = false

var deck_list : Array # of Card

var hand : Array = [] # of int
var played : Array = [] # of int
var discard : Array = [] # of int
var stock_count : int
var life : int = 0
var damage : int = 0
var draw : Array = [] # of int
var effect_logs : Array = [] # of IGameServer.UpdateData.EffectLog

var next_effect := Card.Affected.new(0,0,0)

var multiply_power = 1
var multiply_hit = 1
var multiply_block = 1


var playing_card_id : int = -1
var playing_card : Card = null

var player_name : String


var hand_area
var stock_pos : Vector2
var combat_pos : Vector2
var played_pos : Vector2
var discard_pos : Vector2

var name_lable : Label
var life_label : Label
var next_effect_label: NextEffectLabel

var combat_avatar : CombatAvatar

var damage_label : Label

var power_balance : CombatPowerBalance.Interface

func get_link_color() -> int:
	if played.empty():
		return 0
	return (deck_list[played.back()] as Card).front.data.color



func _init(name : String,
		dl:Array,
		reverse : bool,
		card_layer:Node,
		s_pos : Vector2,
		hand_area_node,
		c_pos : Vector2,
		p_pos : Vector2,
		d_pos : Vector2,
		n_label : Label,
		l_label : Label,
		next_label : NextEffectLabel,
		avatar : CombatAvatar,
		d_label : Label,
		pb_interface : CombatPowerBalance.Interface):
	deck_list = []
	for i in dl.size():
		var c := CardScene.instance().initialize_card(i,
				Global.card_catalog.get_card_data(dl[i]),reverse) as Card
		deck_list.append(c)
		c.position = s_pos
		c.visible = ALWAYS_CARD_VISIBLE
		card_layer.add_child(c)
			
	player_name = name
	hand_area = hand_area_node
	stock_pos = s_pos
	combat_pos = c_pos
	played_pos = p_pos
	discard_pos = d_pos
	name_lable = n_label
	life_label = l_label
	next_effect_label = next_label
	combat_avatar = avatar
	damage_label = d_label
	power_balance = pb_interface
	
	stock_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as Card
		i.location = Card.Location.STOCK
	name_lable.set_message_translation(false)
	name_lable.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)
	name_lable.text = player_name

func standby(l: int,start_hand : Array):
	life = l
	damage_label.text = ""
	draw = start_hand
	draw_all_card()


func set_hand(new_hand_indexes:Array):
	hand = new_hand_indexes
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as Card
		c.visible = true
		c.z_index = i + 100
		c.location = Card.Location.HAND
		cards.append(c)
	hand_area.set_hand_card(cards)
	hand_area.move_card(CARD_MOVE_DURATION)


func play(hand_select : int,new_hand : Array,d : int,draw_indexes : Array,s_log : Array,tween : SceneTreeTween):
	hand = new_hand
	damage = d
	draw = draw_indexes
	effect_logs = s_log
	playing_card_id = hand[hand_select]
	playing_card = deck_list[playing_card_id]
	hand.remove(hand_select)
	life -= playing_card.get_card_data().level
	life_label.text = "%d / %d" % [life,stock_count]
	tween.parallel()
	tween.tween_property(playing_card,"global_position",combat_pos,0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	multiply_power = 1
	multiply_hit = 1
	multiply_block = 1

func play_end():
	played.append(playing_card_id)
	playing_card.z_index = played.size() + 0
	playing_card.location = Card.Location.PLAYED
	var tween := playing_card.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(playing_card,"global_position",played_pos,0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	tween.tween_callback(self,"_set_played_visible")
	draw_all_card()
	life_label.text = "%d / %d" % [life,stock_count]
	damage_label.text = str(damage) if damage > 0 else ""

	playing_card_id = -1
	playing_card = null

func _set_played_visible():
	if played.size() >= 2:
		deck_list[played[played.size()-2]].visible = ALWAYS_CARD_VISIBLE
	

func recover(hand_select : int,new_hand : Array,draw_indexes : Array):
	hand = new_hand
	draw = draw_indexes
	if hand_select >= 0:
		var select_id = hand[hand_select]
		var recovery_card := deck_list[select_id] as Card
		discard_card(hand_select,CARD_MOVE_DURATION)
		damage -= recovery_card.front.data.level
		damage_label.text = str(damage) if damage > 0 else ""
		life_label.text = "%d / %d" % [life,stock_count]
	draw_all_card()

func draw_card():
	if not draw.empty():
		stock_count -= 1
		life_label.text = "%d / %d" % [life,stock_count]
		var c = draw.pop_front()
		hand.append(c)
	set_hand(hand)

func draw_all_card():
	if not draw.empty():
		stock_count -= draw.size()
		life_label.text = "%d / %d" % [life,stock_count]
		hand.append_array(draw)
		draw.clear()
	set_hand(hand)

func discard_card(hand_index : int,duration : float):
	var select_id = hand[hand_index]
	hand.remove(hand_index)
	discard.append(select_id)
	var card := deck_list[select_id] as Card
	life -= card.get_card_data().level
	card.z_index = discard.size() + 200
	card.location = Card.Location.DISCARD
	var tween := card.create_tween()
	tween.tween_property(card,"global_position",discard_pos,duration)
	tween.tween_callback(self,"_set_discard_visible")

func _set_discard_visible():
	if discard.size() >= 2:
		deck_list[discard[discard.size()-2]].visible = ALWAYS_CARD_VISIBLE


func set_next_effect_label():
	next_effect_label.set_effect(next_effect)


func get_current_power() -> int:
	return int(playing_card.get_current_power() * multiply_power)
func get_current_hit() -> int:
	return int(playing_card.get_current_hit() * multiply_hit)
func get_current_block() -> int:
	return int(playing_card.get_current_block() * multiply_block)

func add_attribute(power :int,hit : int,block : int):
	playing_card.affected.power += power
	playing_card.affected.hit += hit
	playing_card.affected.block += block
	combat_avatar.set_power(playing_card.get_current_power())
	combat_avatar.set_hit(playing_card.get_current_hit())
	combat_avatar.set_block(playing_card.get_current_block())
	if power != 0:
		power_balance.set_my_power_tween_step_by_step(playing_card.get_current_power() * multiply_power,0.5)



func reset_board(h_card:PoolIntArray,p_card:PoolIntArray,d_card:PoolIntArray,
		s_count:int,l_count:int,d_count:int,
		n_effect:IGameServer.CompleteData.Affected,a_list:Array):
	hand = Array(h_card)
	played = Array(p_card)
	discard = Array(d_card)
	stock_count  = s_count
	life = l_count
	damage = d_count
	next_effect.power = n_effect.power
	next_effect.hit = n_effect.hit
	next_effect.block = n_effect.block
	
	for i in a_list.size():
		deck_list[i].affected.power = a_list[i].power
		deck_list[i].affected.hit = a_list[i].hit
		deck_list[i].affected.block = a_list[i].block

	for c_ in deck_list:
		var c := c_ as Card
		if c.location != Card.Location.STOCK:
			c.show()
		c.location = Card.Location.STOCK
#		c.position = stock_pos
#		c.rotation = 0

	var tween := (deck_list[0] as Node).create_tween()
	tween.set_parallel(true)

	for i in played.size():
		var c := deck_list[played[i]] as Card
		c.visible = ALWAYS_CARD_VISIBLE or i >= played.size() - 1
		c.z_index = i + 0
		c.location = Card.Location.PLAYED
		tween.tween_property(c,"global_position",played_pos,CARD_MOVE_DURATION)
		tween.tween_property(c,"rotation",PI/2.0,CARD_MOVE_DURATION)
	
	for i in discard.size():
		var c := deck_list[discard[i]] as Card
		c.visible = ALWAYS_CARD_VISIBLE or i >= discard.size() - 1
		c.z_index = i + 200
		c.location = Card.Location.DISCARD
		tween.tween_property(c,"global_position",discard_pos,CARD_MOVE_DURATION)
		tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)
	
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as Card
		c.visible = true
		c.z_index = i + 100
		c.location = Card.Location.HAND
		tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)
		cards.append(c)
	hand_area.set_hand_card(cards)
	hand_area.move_card(CARD_MOVE_DURATION)
	
	for c_ in deck_list:
		var c := c_ as Card
		if c.location == Card.Location.STOCK:
			tween.tween_property(c,"position",stock_pos,CARD_MOVE_DURATION)
			tween.tween_property(c,"rotation",0.0,CARD_MOVE_DURATION)

	tween.set_parallel(false)
	for c_ in deck_list:
		var c := c_ as Card
		if c.location == Card.Location.STOCK:
			if not ALWAYS_CARD_VISIBLE:
				tween.tween_callback(c,"hide")
		elif c.location == Card.Location.PLAYED:
			if c.id_in_deck != played.back():
				if not ALWAYS_CARD_VISIBLE:
					tween.tween_callback(c,"hide")
		elif c.location == Card.Location.DISCARD:
			if c.id_in_deck != discard.back():
				if not ALWAYS_CARD_VISIBLE:
					tween.tween_callback(c,"hide")

	life_label.text = "%d / %d" % [life,stock_count]
	damage_label.text = str(damage) if damage > 0 else ""
	set_next_effect_label()


