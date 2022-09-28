extends Node


const Card := preload( "res://playing_scene/card/card.tscn")


onready var my_hand_area := $UILayer/MyField/HandArea
onready var my_playing := $UILayer/MyField/Playing
onready var my_played := $UILayer/MyField/Played
onready var my_stack := $UILayer/MyField/Stack
onready var my_discard := $UILayer/MyField/Discard

var cards := []

onready var rival_hand_area := $UILayer/RivalField/HandArea
onready var rival_playing := $UILayer/RivalField/Playing
onready var rival_played := $UILayer/RivalField/Played
onready var rival_stack := $UILayer/RivalField/Stack
onready var rival_discard := $UILayer/RivalField/Discard

var rcards := []

onready var card_layer := $CardLayer


func _ready():
	for i in range(27):
		var card := Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1)) as Card
		card.position = my_stack.rect_position + my_stack.rect_size / 2
		card_layer.add_child(card)
		cards.append(card)
		
		card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1),true) as Card
		card.position = rival_stack.rect_position + rival_stack.rect_size / 2
		card_layer.add_child(card)
		rcards.append(card)
 
	var hand := cards.slice(9,9 + 3)
	my_hand_area.set_hand_card(hand)

	var rhand := rcards.slice(18,18 + 3)
	rival_hand_area.set_hand_card(rhand)
	
	my_hand_area.move_card(3)
	rival_hand_area.move_card(3)

# warning-ignore:return_value_discarded
	rival_hand_area.connect("clicked_card",self,"_on_RivalHandArea_clicked_card")
	pass
	
func _on_RivalHandArea_clicked_card(index,_card):
	print(index)
	pass


func _on_UILayer_held_card(card : Card):
	if card != null:
		$LargeCardLayer.show(card.data)

