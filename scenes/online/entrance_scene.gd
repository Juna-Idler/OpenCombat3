extends Node

class_name OnlineEntranceScene

var scene_changer : ISceneChanger

export var websocket_url := "https://127.0.0.1:8080"

onready var server : OnlineServer = $OnlineServer._server

func initialize(changer : ISceneChanger):
	scene_changer = changer

func _ready():
	$OnlineServer.initialize(websocket_url)
	$Panel/DeckBanner.set_deck_data(Global.deck_list.list[Global.deck_list.online_deck])


func _on_Matching_pressed():
	var deck = $Panel/DeckBanner.get_deck_data()
	server.send_match("name",deck.cards,"")


func _on_ButtonDeckChange_pressed():
	$DeckSelectScene.show()


func _on_DeckSelectScene_decided(index):
	if index >= 0 and index < Global.deck_list.list.size():
		Global.deck_list.online_deck = index
		$Panel/DeckBanner.set_deck_data(Global.deck_list.list[index])


func _on_ButtonBack_pressed():
	$OnlineServer.terminalize()
	scene_changer._goto_title_scene()


func _on_OnlineServer_connected():
	$Panel/Matching.disabled = false


func _on_OnlineServer_matched():
	pass # Replace with function body.
