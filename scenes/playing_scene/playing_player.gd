# warning-ignore-all:return_value_discarded

extends Reference

class_name PlayingPlayer


var deck_list : Array # of Card

var hand : Array = [] # of int
var played : Array = [] # of int
var discard : Array = [] # of int
var stock_count : int
var life : int = 0
var damage : int = 0
var skill_logs : Array = [] # of IGameServer.UpdateData.SkillLog

var next_effect := Card.Affected.new()

var multiply_power = 1
var multiply_hit = 1
var multiply_block = 1


var playing_card_id : int = -1
var playing_card : Card = null

var player_name : String


var hand_area
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


func _init(dl:Array,
		name : String,
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
	player_name = name
	deck_list = dl
	hand_area = hand_area_node
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

func standby(l: int):
	life = l
	life_label.text = "%d / %d" % [life,stock_count]
	damage_label.text = ""
	pass

func draw(draw_indexes:Array):
	stock_count -= draw_indexes.size()
	life_label.text = "%d / %d" % [life,stock_count]
	hand.append_array(draw_indexes)
	set_hand(hand)

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
	hand_area.move_card(1)


func play(hand_select : int,new_hand : Array,d : int,s_log : Array,tween : SceneTreeTween):
	hand = new_hand
	damage = d
	skill_logs = s_log
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

func play_end(draw_indexes : Array,tween : SceneTreeTween):
	played.append(playing_card_id)
	playing_card.z_index = played.size() + 0
	playing_card.location = Card.Location.PLAYED
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(playing_card,"global_position",played_pos,0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	draw(draw_indexes)
	life_label.text = "%d / %d" % [life,stock_count]
	damage_label.text = str(damage) if damage > 0 else ""

	playing_card_id = -1
	playing_card = null
	

func recover(hand_select : int,new_hand : Array,draw_indexes : Array,tween : SceneTreeTween):
	hand = new_hand
	if hand_select >= 0:
		var select_id = hand[hand_select]
		hand.remove(hand_select)
		var recovery_card := deck_list[select_id] as Card
		life -= recovery_card.get_card_data().level
		damage -= recovery_card.front.data.level
		damage_label.text = str(damage) if damage > 0 else ""
		life_label.text = "%d / %d" % [life,stock_count]
		recovery_card.z_index = discard.size() + 200
		recovery_card.location = Card.Location.DISCARD
		discard.append(select_id)
		tween.tween_property(recovery_card,"global_position",discard_pos,1)
	draw(draw_indexes)


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

func multiply_attribute(power : float, hit : float, block : float):
	multiply_power *= power
	multiply_hit *= hit
	multiply_block *= block
	combat_avatar.set_power(int(playing_card.get_current_power() * multiply_power))
	combat_avatar.set_hit(int(playing_card.get_current_hit() * multiply_hit))
	combat_avatar.set_block(int(playing_card.get_current_block() * multiply_block))
	if power != 1:
		power_balance.set_my_power_tween_step_by_step(playing_card.get_current_power() * multiply_power,0.5)
