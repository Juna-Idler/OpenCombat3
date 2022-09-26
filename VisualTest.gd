extends Node


const Card := preload( "res://playing_scene/card/card.tscn")


onready var my_hand_area := $CanvasLayer/MyField/HandArea
onready var my_playing := $CanvasLayer/MyField/PlayingArea
onready var my_played := $CanvasLayer/MyField/PlayedArea
onready var my_stack := $CanvasLayer/MyField/StackArea
onready var my_discard := $CanvasLayer/MyField/DiscardArea

var cards := []

onready var rival_hand_area := $CanvasLayer/RivalField/HandArea
onready var rival_playing := $CanvasLayer/RivalField/PlayingArea
onready var rival_played := $CanvasLayer/RivalField/PlayedArea
onready var rival_stack := $CanvasLayer/RivalField/StackArea
onready var rival_discard := $CanvasLayer/RivalField/DiscardArea

var rcards := []



func _ready():
	for i in range(9):
		var card := Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1)) as Card
		card.position = my_stack.rect_position + my_stack.rect_size / 2
		add_child(card)
		cards.append(card)
		card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1),true)
		card.position = rival_stack.rect_position + rival_stack.rect_size / 2
		add_child(card)
		rcards.append(card)
 
	var hand := cards.slice(0,3)
	my_hand_area.set_hand_card(hand)

	var rhand := rcards.slice(4,7)
	rival_hand_area.set_hand_card(rhand)
	
	my_hand_area.move_card(1)
	rival_hand_area.move_card(1)

	rival_hand_area.connect("clicked_card",self,"_on_RivalHandArea_clicked_card")
	pass
	
func _on_RivalHandArea_clicked_card(index,card):
	print(index)
	print(card)
	pass
