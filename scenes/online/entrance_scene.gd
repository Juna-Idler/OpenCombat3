extends ISceneChanger.IScene

class_name OnlineEntranceScene

var scene_changer : ISceneChanger

export var websocket_url := "https://127.0.0.1:8080"

onready var server : OnlineServer

func initialize(s : OnlineServer,changer : ISceneChanger):
	server = s
	scene_changer = changer
	
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")

	if not server.is_ws_connected:
		server.initialize(websocket_url,Global.card_catalog.version)
	else:
		$Panel/Matching.disabled = false
		

func _terminalize():
	server.disconnect("connected",self,"_on_Server_connected")
	server.disconnect("matched",self,"_on_Server_matched")
	server.disconnect("disconnected",self,"_on_Server_disconnected")
	

func _ready():
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
	server.terminalize()
	scene_changer._goto_title_scene()


func _on_Server_connected():
	$Panel/Matching.disabled = false
	pass
	
func _on_Server_matched():
	scene_changer._goto_online_playing_scene(server)
	pass
	
func _on_Server_disconnected():
	$Panel/Matching.disabled = true
	pass
