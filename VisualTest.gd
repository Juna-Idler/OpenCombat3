extends Node


const MyHandArea = preload( "res://playing_scene/my_hand_area.tscn")
const Card := preload( "res://playing_scene/card/card.tscn")

const HandArea = preload("res://playing_scene/hand_area.tscn")

onready var my_hand_area = $CanvasLayer/MyField/HandArea
var cards := []

onready var rival_hand_area = $CanvasLayer/RivalField/HandArea
var rcards := []



func _ready():
	for i in range(9):
		var card := Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1)) as Card
		card.position.x = 1000 + i * 10
		card.position.y = 600
		add_child(card)
		cards.append(card)
		card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1),true)
		card.position.x = 80 + i * 10
		card.position.y = 80
		add_child(card)
		rcards.append(card)
 
	var hand := cards.slice(0,3)
	my_hand_area.set_hand_card(hand)

	var rhand := rcards.slice(4,7)
	rival_hand_area.set_hand_card(rhand)
	
	my_hand_area.move_card(1)
	rival_hand_area.move_card(1)



	pass
