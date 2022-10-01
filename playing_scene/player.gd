extends Reference

class_name Player


var deck_list : Array# of Card

var hand : Array = []# of int
var played : Array = []# of int
var discard : Array = []# of int
var stack_count : int
var life : int = 0

var next_effect := Card.Affected.new()

#var damage : int = 0
#var playing_card : int = -1

var player_name : String


var hand_area
var combat_pos : Vector2
var played_pos : Vector2
var discard_pos : Vector2


func _init(dl:Array,
		name : String,
		hand_area_node,
		c_pos : Vector2,
		p_pos : Vector2,
		d_pos : Vector2):
	player_name = name
	deck_list = dl
	hand_area = hand_area_node
	combat_pos = c_pos
	played_pos = p_pos
	discard_pos = d_pos
	stack_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as Card
		life += i.data.level
		i.place = Card.Place.STACK

func draw(cards_indexes:Array):
	hand.append_array(cards_indexes)
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

var _playing_id

func play(hand_select : int,new_hand : Array,tween : SceneTreeTween):
	hand = new_hand
	_playing_id = hand[hand_select]
	hand.remove(hand_select)
	var playing_card := deck_list[_playing_id] as Card
	tween.parallel()
	tween.tween_property(playing_card,"global_position",combat_pos,0.5)

func play_end(draw_indexes : Array,tween : SceneTreeTween):
	played.append(_playing_id)
	var playing_card := deck_list[_playing_id] as Card
	playing_card.z_index = played.size()
	playing_card.place = Card.Place.PLAYED
	tween.parallel()
	tween.tween_property(playing_card,"global_position",played_pos,0.5)
	tween.parallel()
	tween.tween_property(playing_card,"rotation",PI/2,0.5)
	
	draw(draw_indexes)
	

func recover(hand_select : int,new_hand : Array,tween : SceneTreeTween):
	hand = new_hand
	if hand_select >= 0:
		var select_id = hand[hand_select]
		hand.remove(hand_select)
		var playing_card := deck_list[select_id] as Card
		life -= playing_card.data.level
		playing_card.z_index = discard.size()
		playing_card.place = Card.Place.DISCARD
		discard.append(select_id)
		
		tween.parallel()
		tween.tween_property(playing_card,"global_position",discard_pos,1)
		set_hand(hand)

