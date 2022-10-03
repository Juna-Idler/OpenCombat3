extends Control

const Card := preload( "../card/card.tscn")
const Item := preload("res://scenes/deck_scene/control_in_deck.tscn")

onready var deck_container := $ScrollContainer/HBoxContainer

func _ready():
	for i in range(27):
		var item = Item.instance()
#		var card = Card.instance().initialize_card(i,Global.card_catalog.get_card_data(i+1),true)
		deck_container.add_child(item)
	pass
