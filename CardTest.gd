extends Node


const Card := preload("res://scenes/card/card.tscn")

func _ready():
	var card = Global.card_catalog.get_card_data(4)
	$CardFront.initialize_card(card)

	$CardFront2.initialize_card(card)

func _on_Button_pressed():


	print("button")
	pass # Replace with function body.
