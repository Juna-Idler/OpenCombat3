extends Reference

class_name PlayingPlayer


var deck_list : Array# of Card

var hand : Array = []# of int
var played : Array = []# of int
var discard : Array = []# of int
var stack_count : int
var life : int = 0
var damage : int = 0

var next_effect := Card.Affected.new()

var playing_card_id : int = -1
var playing_card : Card = null
var combat_damage : int = 0

var player_name : String


var hand_area
var combat_pos : Vector2
var played_pos : Vector2
var discard_pos : Vector2

var name_lable : Label
var life_label : Label

var col_power : Label
var col_hit : Label
var col_block : Label
var col_skill_list : VBoxLayout

var damage_label : Label

var combat_avatar : Node2D


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
		col_control : Control,
		d_label : Label,
		avatar : Node2D):
	player_name = name
	deck_list = dl
	hand_area = hand_area_node
	combat_pos = c_pos
	played_pos = p_pos
	discard_pos = d_pos
	name_lable = n_label
	life_label = l_label
	col_power = col_control.get_node("Power")
	col_hit = col_control.get_node("Hit")
	col_block = col_control.get_node("Block")
	col_skill_list = col_control.get_node("SkillContainer")
	damage_label = d_label
	combat_avatar = avatar
	
	stack_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as Card
		life += i.get_card_data().level
		i.place = Card.Place.STACK
	name_lable.set_message_translation(false)
	name_lable.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)
	name_lable.text = player_name
	life_label.text = "%d / %d" % [life,stack_count]
	damage_label.text = ""

func draw(draw_indexes:Array):
	stack_count -= draw_indexes.size()
	life_label.text = "%d / %d" % [life,stack_count]
	hand.append_array(draw_indexes)
	set_hand(hand)

func set_hand(new_hand_indexes:Array):
	hand = new_hand_indexes
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as Card
		c.visible = true
		c.z_index = i + 100
		c.place = Card.Place.HAND
		cards.append(c)
	hand_area.set_hand_card(cards)
	hand_area.move_card(1)


func play(hand_select : int,new_hand : Array,d : int,tween : SceneTreeTween):
	hand = new_hand
	damage = d
	combat_damage = 0
	playing_card_id = hand[hand_select]
	playing_card = deck_list[playing_card_id]
	hand.remove(hand_select)
	life -= playing_card.get_card_data().level
	life_label.text = "%d / %d" % [life,stack_count]
	tween.parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(playing_card,"global_position",combat_pos,0.5)

func play_end(draw_indexes : Array,tween : SceneTreeTween):
	played.append(playing_card_id)
	playing_card.z_index = played.size() + 0
	playing_card.place = Card.Place.PLAYED
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(playing_card,"global_position",played_pos,0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	draw(draw_indexes)
	life_label.text = "%d / %d" % [life,stack_count]
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
		life_label.text = "%d / %d" % [life,stack_count]
		recovery_card.z_index = discard.size() + 200
		recovery_card.place = Card.Place.DISCARD
		discard.append(select_id)
		tween.tween_property(recovery_card,"global_position",discard_pos,1)
	draw(draw_indexes)

func update_affected(updates : Array):#of IGameServer.UpdateData.Affected
	for a_ in updates:
		var a = a_# as IGameServer.UpdateData.Affected
		var c := deck_list[a.id] as Card
		c.affected.power = a.power
		c.affected.hit = a.hit
		c.affected.block = a.block

func set_next_effect(e):# : IGameServer.UpdateData.Affected):
	next_effect.power = e.power
	next_effect.hit = e.hit
	next_effect.block = e.block

func change_col_power():
	col_power.text = str(playing_card.get_current_power())
func change_col_hit():
	col_hit.text = str(playing_card.get_current_hit())
func change_col_block():
	col_block.text = str(playing_card.get_current_block())


func add_damage(add_d : int):
	combat_damage += add_d
	var block = playing_card.get_current_block()
	var d = combat_damage - block
	damage_label.text = str(d if d > 0 else 0)
