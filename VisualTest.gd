extends Node


const HandArea = preload("res://hand_area.tscn")
const Card := preload("res://card/card.tscn")

var my_hand_area
var cards := []




func _ready():
	for i in range(9):
		var card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1))
		(card as Card).position.x = (i % 9) * 150 + 100
		(card as Card).position.y = (i / 9) * 300 + 150
		add_child(card)
		cards.append(card)
 
	var hand := cards.slice(0,4)
	my_hand_area = HandArea.instance()
	my_hand_area.set_hand_card(hand)
	$CanvasLayer.add_child(my_hand_area)
	my_hand_area.set_position(Vector2(100,400))
	my_hand_area.move_card()

	pass
