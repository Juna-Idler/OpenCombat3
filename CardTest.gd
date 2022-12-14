extends Node


const Card := preload("res://scenes/card/card.tscn")

func _ready():
	var card = Global.card_catalog.get_card_data(4)
	$Card.initialize_card(0,card)
	


func _on_Button_pressed():


	print("button")
	pass # Replace with function body.
