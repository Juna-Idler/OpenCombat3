extends Node


onready var server : OnlineServer = $Node._server

func _ready():
	$Node.initialize()
	$Panel/DeckBanner.initialize(Global.deck_list.list[Global.deck_list.online_deck])
	pass


func _on_Matching_pressed():
	server.send_match("name",[1,2,3,4,5,6,7,8,9],"")
	
	pass # Replace with function body.


func _on_ButtonDeckChange_pressed():
	$DeckSelectScene.show()


func _on_DeckSelectScene_decided(index):
	if index >= 0 and index < Global.deck_list.list.size():
		Global.deck_list.online_deck = index
		$Panel/DeckBanner.set_deck_data(Global.deck_list.list[index])
