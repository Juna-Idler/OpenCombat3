extends Reference

class_name PlayingPlayer


var deck_list : Array# of Card

var hand : Array = []# of int
var played : Array = []# of int
var discard : Array = []# of int
var stack_count : int
var life : int = 0

var next_effect := Card.Affected.new()

var playing_card_id : int = -1
var damage : int = 0

var player_name : String


var hand_area
var combat_pos : Vector2
var played_pos : Vector2
var discard_pos : Vector2
var stack_count_label : Label
var life_label : Label

func get_playing_card() -> Card:
	return deck_list[playing_card_id]


func _init(dl:Array,
		name : String,
		hand_area_node,
		c_pos : Vector2,
		p_pos : Vector2,
		d_pos : Vector2,
		sc_label : Label,
		l_label : Label):
	player_name = name
	deck_list = dl
	hand_area = hand_area_node
	combat_pos = c_pos
	played_pos = p_pos
	discard_pos = d_pos
	stack_count_label = sc_label
	life_label = l_label
	
	stack_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as Card
		life += i.get_card_data().level
		i.place = Card.Place.STACK
	stack_count_label.text = str(stack_count)
	life_label.text = str(life)

func draw(draw_indexes:Array):
	stack_count -= draw_indexes.size()
	stack_count_label.text = str(stack_count)
	hand.append_array(draw_indexes)
	set_hand(hand)

func set_hand(new_hand_indexes:Array):
	hand = new_hand_indexes
	var cards := []
	for i in hand.size():
		var c := deck_list[hand[i]] as Card
		c.visible = true
		c.z_index = i
		c.place = Card.Place.HAND
		cards.append(c)
	hand_area.set_hand_card(cards)
	hand_area.move_card(1)


func play(hand_select : int,new_hand : Array,d : int,tween : SceneTreeTween):
	hand = new_hand
	playing_card_id = hand[hand_select]
	hand.remove(hand_select)
	var playing_card := deck_list[playing_card_id] as Card
	life -= playing_card.get_card_data().level
	life_label.text = str(life)
	damage = d
	tween.parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(playing_card,"global_position",combat_pos,0.5)

func play_end(draw_indexes : Array,tween : SceneTreeTween):
	played.append(playing_card_id)
	var playing_card := deck_list[playing_card_id] as Card
	playing_card.z_index = played.size()
	playing_card.place = Card.Place.PLAYED
	tween.parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(playing_card,"global_position",played_pos,0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	draw(draw_indexes)
	life_label.text = str(life)
	

func recover(hand_select : int,new_hand : Array,draw_indexes : Array,tween : SceneTreeTween):
	hand = new_hand
	if hand_select >= 0:
		var select_id = hand[hand_select]
		hand.remove(hand_select)
		var playing_card := deck_list[select_id] as Card
		life -= playing_card.get_card_data().level
		life_label.text = str(life)
		playing_card.z_index = discard.size()
		playing_card.place = Card.Place.DISCARD
		discard.append(select_id)
		
		tween.parallel()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(playing_card,"global_position",discard_pos,1)
	draw(draw_indexes)

func update_affected(updates : Array):#of IGameServer.UpdateData.Affected
	for a_ in updates:
		var a = a_# as IGameServer.UpdateData.Affected
		var c := deck_list[a.id] as Card
		c.affected.power = a.power
		c.affected.hit = a.hit
		c.affected.damage = a.damage
		c.affected.rush = a.rush
	
