extends ISceneChanger.IScene

class_name OfflinePlayingScene

var scene_changer : ISceneChanger

var offline_server : OfflineServer

var deck_regulation : RegulationData.DeckRegulation

var select_cpu_deck : bool

var match_logger : MatchLogger


class ZeroCommander extends ICpuCommander:
	func _get_commander_name()-> String:
		return "ZeroCommander"


class RandomCommander extends ICpuCommander:
	var generator : RandomNumberGenerator
	func _get_commander_name()-> String:
		return "RandomCommander"

	func _first_select(myhand : Array, _rivalhand : Array)-> int:
		generator = RandomNumberGenerator.new()
		generator.randomize()
		return generator.randi_range(0,myhand.size() - 1)

	func _combat_select(data : IGameServer.UpdateData)-> int:
		var hand := PoolIntArray(data.myself.hand)
		if data.myself.select >= 0:
			hand.remove(data.myself.select)
		hand.append_array(data.myself.draw)
		return generator.randi_range(0,hand.size() - 1)

	func _recover_select(data : IGameServer.UpdateData)-> int:
		var hand := PoolIntArray(data.myself.hand)
		if data.myself.select >= 0:
			hand.remove(data.myself.select)
		hand.append_array(data.myself.draw)
		return generator.randi_range(0,hand.size() - 1)


var commanders : Array = [
	ZeroCommander.new(),
	RandomCommander.new()
]



func _ready():
	$PlayingScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$PlayingScene.exit_button.text = "SURRENDER"

func _on_ExitButton_pressed():
	$PlayingScene.game_server._send_surrender()


func initialize(changer : ISceneChanger):
	scene_changer = changer
	
	offline_server = OfflineServer.new()

	deck_regulation = Global.regulation_newbie
	var deck_list = Global.deck_list[deck_regulation.name]
	$Panel/Panel/CPUDeckBanner.set_deck_data(deck_list.get_select_deck())
	$Panel/Panel/DeckBanner.set_deck_data(deck_list.get_select_deck())



func _terminalize():
	$PlayingScene.terminalize()
	if match_logger:
		match_logger.terminalize()


func _on_PlayingScene_ended(situation,msg):
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

	if match_logger:
		Global.replay_log_list.append(match_logger.match_log)
		Global.replay_log_list.save_list()


func _on_ReturnButton_pressed():
	$"%ResultOverlap".hide()
	$Panel/Panel.show()



func _on_ButtonBack_pressed():
	scene_changer._goto_title_scene()



func _on_ButtonStart_pressed():
	var deck = $Panel/Panel/DeckBanner.get_deck_data()
	var cpu_deck = $Panel/Panel/CPUDeckBanner.get_deck_data()
	
	if !deck_regulation.check_regulation(deck.cards,Global.card_catalog).empty() or \
			!deck_regulation.check_regulation(cpu_deck.cards,Global.card_catalog).empty():
		return
	
	var regulation = RegulationData.MatchRegulation.new(3,180,10,5)
	var commander = commanders[$Panel/Panel/OptionCommander.selected]
	offline_server.initialize(Global.player_name,deck.cards,commander,cpu_deck.cards,regulation,Global.card_catalog)

	if match_logger:
		match_logger.terminalize()
	if $Panel/Panel/CheckBoxLog.pressed:
		match_logger = MatchLogger.new()
		match_logger.initialize(offline_server)
	else:
		match_logger = null
	
	$PlayingScene.initialize(match_logger as IGameServer if match_logger else offline_server as IGameServer)
	$PlayingScene.send_ready()

	Bgm.stream = load("res://sound/魔王魂  ファンタジー11.ogg")
	Bgm.play()
	$"%ResultOverlap".hide()
	$Panel/Panel.hide()



func _on_BuildSelectScene_decided(index):
	var deck_list = Global.deck_list[deck_regulation.name]
	if index >= 0 and index < deck_list.list.size():
		if select_cpu_deck:
			$Panel/Panel/CPUDeckBanner.set_deck_data(deck_list.list[index])
		else:
			deck_list.select = index
			deck_list.save_deck_list()
			$Panel/Panel/DeckBanner.set_deck_data(deck_list.get_select_deck())
		$Panel/Panel/BuildSelectScene.hide()

func _on_BuildSelectScene_return_button_pressed():
	$Panel/Panel/BuildSelectScene.hide()

func _on_ButtonDeckChange_pressed():
	select_cpu_deck = false
	$Panel/Panel/BuildSelectScene.initialize_select(deck_regulation)
	$Panel/Panel/BuildSelectScene.show()

func _on_ButtonCPUDeckChange_pressed():
	select_cpu_deck = true
	$Panel/Panel/BuildSelectScene.initialize_select(deck_regulation)
	$Panel/Panel/BuildSelectScene.show()



func _on_ButtonRegulation_pressed():
	$Panel/Panel/RegulationSelect.initialize()
	$Panel/Panel/RegulationSelect.show()


func _on_RegulationSelect_regulation_button_pressed(name):
	if name == "newbie" and deck_regulation.name != name:
		$Panel/Panel/ButtonRegulation/Label.text = "初級レギュレーション"
		deck_regulation = Global.regulation_newbie
		$Panel/Panel/DeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$Panel/Panel/CPUDeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$Panel/Panel/RegulationSelect.hide()


func _on_RegulationSelect_return_button_pressed():
	$Panel/Panel/RegulationSelect.hide()


func _on_OptionCommander_item_selected(_index):
	pass # Replace with function body.

