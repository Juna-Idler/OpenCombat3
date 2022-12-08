# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name OnlineScene

var scene_changer : ISceneChanger

var server : OnlineServer

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var match_logger : MatchLogger


func initialize(s : OnlineServer,changer : ISceneChanger):
	server = s
	deck_regulation = Global.regulation_newbie
	scene_changer = changer
	$CanvasLayer/Panel/DeckBanner.set_deck_data(Global.deck_list["newbie"].get_select_deck())
	
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")

	var url : String = Global.game_settings.online_servers[Global.game_settings.server_index]
	$CanvasLayer/Panel/LabelUrl.text = url
	if not server.is_ws_connected:
		server.initialize(url,Global.card_catalog.version)
	else:
		$CanvasLayer/Panel/Matching.disabled = false
		
	$MatchScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$MatchScene.exit_button.text = "SURRENDER"
	

func _terminalize():
	server.disconnect("connected",self,"_on_Server_connected")
	server.disconnect("matched",self,"_on_Server_matched")
	server.disconnect("disconnected",self,"_on_Server_disconnected")

	$MatchScene.terminalize()
	if match_logger:
		match_logger.terminalize()


func _ready():
	pass


func _on_Matching_pressed():
	var deck = $CanvasLayer/Panel/DeckBanner.get_deck_data()
	var failed := deck_regulation.check_regulation(deck.cards,Global.card_catalog)
	if failed.empty():
		server.send_match(Global.game_settings.player_name,deck.cards,"newbie")
		$CanvasLayer/Panel/Matching.text = "マッチング待機中"
		$CanvasLayer/Panel/Matching.disabled = true
	else:
		pass


func _on_ButtonDeckChange_pressed():
	$CanvasLayer/BuildSelectScene.initialize_select(Global.regulation_newbie)
	$CanvasLayer/BuildSelectScene.show()

func _on_BuildSelectScene_decided(index):
	if index >= 0 and index < Global.deck_list["newbie"].list.size():
		Global.deck_list["newbie"].select = index
		Global.deck_list["newbie"].save_deck_list()
		$CanvasLayer/Panel/DeckBanner.set_deck_data(Global.deck_list["newbie"].get_select_deck())
		$CanvasLayer/BuildSelectScene.hide()
		
func _on_BuildSelectScene_return_button_pressed():
	$CanvasLayer/BuildSelectScene.hide()


func _on_ButtonRegulation_pressed():
	$CanvasLayer/RegulationSelect.initialize()
	$CanvasLayer/RegulationSelect.show()

func _on_RegulationSelect_regulation_button_pressed(name):
	if name == "newbie":
		$CanvasLayer/Panel/ButtonRegulation.text = "初級レギュレーション"
		deck_regulation = Global.regulation_newbie
		$CanvasLayer/Panel/DeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$CanvasLayer/RegulationSelect.hide()

func _on_RegulationSelect_return_button_pressed():
	$CanvasLayer/RegulationSelect.hide()



func _on_ButtonBack_pressed():
	server.terminalize()
	scene_changer._goto_title_scene()


func _on_Server_connected():
	$CanvasLayer/Panel/Matching.disabled = false
	pass
	
func _on_Server_matched():
	if match_logger:
		match_logger.terminalize()
	if $CanvasLayer/Panel/CheckButtonSaveLog.pressed:
		match_logger = MatchLogger.new()
		match_logger.initialize(server)
	else:
		match_logger = null
	
	$MatchScene.initialize(match_logger if match_logger else server as IGameServer)

	$MatchScene.send_ready()
	$"%ResultOverlap".hide()
	$CanvasLayer/Panel.hide()
	pass
	
func _on_Server_disconnected():
	$CanvasLayer/Panel/Matching.disabled = true
	pass


func _on_ExitButton_pressed():
	$MatchScene.game_server._send_surrender()


func _on_MatchScene_ended(situation, msg):
	$"%ResultOverlap".show()
	match situation:
		1:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("ResultLabel").text = "Win"
		0:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("ResultLabel").text = "Draw"
		-1:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("ResultLabel").text = "Lose"
		-2:
			$"%ResultOverlap".get_node("ResultLabel").text = msg

	$MatchScene.terminalize()
	if match_logger:
		Global.replay_log_list.append(match_logger.match_log)
		Global.replay_log_list.save_list()
		match_logger.terminalize()
		match_logger = null


func _on_ButtonReturn_pressed():
	$"%ResultOverlap".hide()
	$CanvasLayer/Panel.show()


