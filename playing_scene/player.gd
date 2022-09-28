extends Reference

class_name Player


var deck_list : Array# of Card

var hand : Array = []# of int
var played : Array = []# of int
var discard : Array = []# of int
var stack_count : int
var life : int = 0

var next_effect := Card.Affected.new()

var damage : int = 0
var playing_card : int = -1

var player_name : String


var hand_area



func _init(dl:Array,
		name : String,
		hand_area_node):
	player_name = name
	deck_list = dl
	hand_area = hand_area_node
	stack_count = deck_list.size()
	for i_ in deck_list:
		var i := i_ as Card
		life += i.data.level

func draw(cards_indexes:Array):
	hand.append_array(cards_indexes)
	var cards := []
	for i in hand:
		cards.append(deck_list[i])
	hand_area.set_hand_card(cards)
	hand_area.move_card(1)

func set_hand(new_hand_indexes:Array):
	hand.clear()
	hand.append_array(new_hand_indexes)
	var cards := []
	for i in hand:
		cards.append(deck_list[i])
	hand_area.set_hand_card(cards)
	hand_area.move_card(1)
