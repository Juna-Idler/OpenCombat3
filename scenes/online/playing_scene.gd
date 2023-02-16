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
	deck_regulation = Global.deck_regulation_list[0]
	match_regulation = Global.match_regulation_list[0]
	scene_changer = changer

	$MenuLayer/Menu/ButtonRegulation.text = deck_regulation.name
	$MenuLayer/Menu/DeckBanner.set_deck_data(Global.deck_list[deck_regulation.name].get_select_deck())
	
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")
	server.connect("recieved_end",self,"_on_Server_recieved_end")

	var url : String = Global.game_settings.online_servers[Global.game_settings.server_index]
	$MenuLayer/Menu/LabelUrl.text = url
	if not server.is_ws_connected:
		server.initialize(url,Global.card_catalog.version)
	else:
		$MenuLayer/Menu/Matching.disabled = false

	$MenuLayer/Menu/CheckButtonSaveLog.pressed = Global.game_settings.online_logging

	$MatchScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$MatchScene.exit_button.text = "SURRENDER"

	$"%ResultOverlap".hide()
	$MenuLayer/Menu.show()


func _terminalize():
	server.disconnect("connected",self,"_on_Server_connected")
	server.disconnect("matched",self,"_on_Server_matched")
	server.disconnect("disconnected",self,"_on_Server_disconnected")
	server.disconnect("recieved_end",self,"_on_Server_recieved_end")

	$MatchScene.terminalize()
	if match_logger:
		match_logger.terminalize()


func _ready():
	pass


func _on_Matching_pressed():
	var deck = $MenuLayer/Menu/DeckBanner.get_deck_data()
	var failed := deck_regulation.check_regulation(deck.cards,Global.card_catalog)
	if failed.empty():
		server.send_match(Global.game_settings.player_name,deck.cards,
				deck_regulation.to_regulation_string(),match_regulation.to_regulation_string())
		$MenuLayer/Menu/Matching.disabled = true
		$MenuLayer/Menu/ButtonRegulation.disabled = true
		$MenuLayer/Menu/DeckBanner/ButtonDeckChange.disabled = true
	else:
		pass


func _on_ButtonDeckChange_pressed():
	$MenuLayer/BuildSelectScene.initialize_select(Global.deck_regulation_list[0])
	$MenuLayer/BuildSelectScene.show()

func _on_BuildSelectScene_decided(index):
	if index >= 0 and index < Global.deck_list[deck_regulation.name].list.size():
		Global.deck_list[deck_regulation.name].select = index
		Global.deck_list[deck_regulation.name].save_deck_list()
		$MenuLayer/Menu/DeckBanner.set_deck_data(Global.deck_list[deck_regulation.name].get_select_deck())
		$MenuLayer/BuildSelectScene.hide()
		
func _on_BuildSelectScene_return_button_pressed():
	$MenuLayer/BuildSelectScene.hide()


func _on_ButtonRegulation_pressed():
	$MenuLayer/RegulationSelect.initialize(0)
	$MenuLayer/RegulationSelect.show()


func _on_RegulationSelect_decide_button_pressed():
	var dr = $MenuLayer/RegulationSelect.deck_regulation
	if dr:
		$MenuLayer/Menu/ButtonRegulation.text = dr.name
		deck_regulation = dr
		$MenuLayer/Menu/DeckBanner.set_deck_data(Global.deck_list[dr.name].get_select_deck())
		$MenuLayer/RegulationSelect.hide()


func _on_RegulationSelect_return_button_pressed():
	$MenuLayer/RegulationSelect.hide()



func _on_ButtonBack_pressed():
	server.terminalize()
	scene_changer._goto_title_scene()


func _on_Server_connected():
	$MenuLayer/Menu/Matching.disabled = false
	pass
	
func _on_Server_matched():
	if match_logger:
		match_logger.terminalize()
	if $MenuLayer/Menu/CheckButtonSaveLog.pressed:
		match_logger = MatchLogger.new()
		match_logger.initialize(server)
	else:
		match_logger = null
	
	$MatchScene.initialize(match_logger if match_logger else server as IGameServer,
			$MatchScene/UILayer/MyField/MyHandArea,$MatchScene/UILayer/RivalField/RivalHandArea)

	Bgm.stream = load("res://sound/魔王魂  ファンタジー11.ogg")
	Bgm.play()
	$MatchScene.send_ready()
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.hide()
	$MenuLayer/Menu/ButtonRegulation.disabled = false
	$MenuLayer/Menu/DeckBanner/ButtonDeckChange.disabled = false
	

func _on_Server_disconnected():
	$MenuLayer/Menu/Matching.disabled = true
	pass

func _on_Server_recieved_end(_msg:String):
	if not $MatchScene.is_valid():
		$MenuLayer/Menu/Matching.disabled = false
		$MenuLayer/Menu/ButtonRegulation.disabled = false
		$MenuLayer/Menu/DeckBanner/ButtonDeckChange.disabled = false

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
	Bgm.stop()

	$MatchScene.terminalize()
	if match_logger:
		Global.replay_log_list.append(match_logger.match_log)
		Global.replay_log_list.save_list()
		match_logger.terminalize()
		match_logger = null


func _on_ButtonReturn_pressed():
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.show()
	if not server.is_ws_connected:
		var url : String = Global.game_settings.online_servers[Global.game_settings.server_index]
		server.initialize(url,Global.card_catalog.version)
	else:
		$MenuLayer/Menu/Matching.disabled = false


