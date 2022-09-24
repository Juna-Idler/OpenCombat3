extends Node


const Card := preload( "res://playing_scene/card/card.tscn")

func _ready():
	for i in range(9):
		var card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1),true)
		(card as Card).position.x = (i % 9) * 150 + 100
		(card as Card).position.y = (i / 9) * 300 + 150
		add_child(card)
		card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1))
		(card as Card).position.x = (i % 9) * 150 + 100
		(card as Card).position.y = 300 + 150
		add_child(card)
	pass
	
	
