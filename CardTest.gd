extends Node


const Card := preload("res://scenes/card/card.tscn")

func _ready():
	var card = Global.card_catalog.get_card_data(1)
	var card_str = var2bytes(card)
	
	print(card_str)
	
	
	var pd := IGameServer.PrimaryData.new("name",[1,2,3,4,5],"rname",[1,2,3,4,5],"reg")
	print(JSON.print(pd))
	
	var card2 = bytes2var(card_str)
	
	print(var2str(card2))
	pass
	
	


func _on_Button_pressed():


	print("button")
	pass # Replace with function body.
