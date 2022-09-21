extends Node


const Card := preload("res://card/card.tscn")

func _ready():
	for i in range(9):
		var card = Card.instance().initialize_scene(i,Global.card_catalog.get_card_data(i+1))
		(card as Card).position.x = (i % 6) * 200 + 100
		(card as Card).position.y = (i / 6) * 300 + 150
		add_child(card)
	
	pass
	
	
