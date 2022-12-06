# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name OnlineEntranceScene

var scene_changer : ISceneChanger

var server : OnlineServer

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

func initialize(s : OnlineServer,changer : ISceneChanger):
	server = s
	deck_regulation = Global.regulation_newbie
	scene_changer = changer
	$Panel/DeckBanner.set_deck_data(Global.deck_list["newbie"].get_select_deck())
	
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")

	var url : String = Global.game_settings.match_servers[Global.game_settings.server_index]
	$Panel/LabelUrl.text = url
	if not server.is_ws_connected:
		server.initialize(url,Global.card_catalog.version)
	else:
		$Panel/Matching.disabled = false
		

func _terminalize():
	server.disconnect("connected",self,"_on_Server_connected")
	server.disconnect("matched",self,"_on_Server_matched")
	server.disconnect("disconnected",self,"_on_Server_disconnected")
	

func _ready():
	pass


func _on_Matching_pressed():
	var deck = $Panel/DeckBanner.get_deck_data()
	var failed := deck_regulation.check_regulation(deck.cards,Global.card_catalog)
	if failed.empty():
		server.send_match(Global.game_settings.player_name,deck.cards,"newbie")
		$Panel/Matching.text = "マッチング待機中"
		$Panel/Matching.disabled = true
	else:
		pass


func _on_ButtonDeckChange_pressed():
	$BuildSelectScene.initialize_select(Global.regulation_newbie)
	$BuildSelectScene.show()

func _on_BuildSelectScene_decided(index):
	if index >= 0 and index < Global.deck_list["newbie"].list.size():
		Global.deck_list["newbie"].select = index
		Global.deck_list["newbie"].save_deck_list()
		$Panel/DeckBanner.set_deck_data(Global.deck_list["newbie"].get_select_deck())
		$BuildSelectScene.hide()
		
func _on_BuildSelectScene_return_button_pressed():
	$BuildSelectScene.hide()


func _on_ButtonRegulation_pressed():
	$RegulationSelect.initialize()
	$RegulationSelect.show()

func _on_RegulationSelect_regulation_button_pressed(name):
	if name == "newbie":
		$Panel/ButtonRegulation.text = "初級レギュレーション"
		deck_regulation = Global.regulation_newbie
		$Panel/DeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$RegulationSelect.hide()

func _on_RegulationSelect_return_button_pressed():
	$RegulationSelect.hide()



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




