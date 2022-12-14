extends ISceneChanger.IScene

class_name OfflineScene

var scene_changer : ISceneChanger

var offline_server : OfflineServer

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var select_cpu_deck : bool

var match_logger : MatchLogger


class ZeroCommander extends ICpuCommander:
	func _get_commander_name()-> String:
		return "ZeroCommander"


class RandomCommander extends ICpuCommander:
	var generator : RandomNumberGenerator
	func _get_commander_name()-> String:
		return "RandomCommander"
	func _set_deck_list(_mydeck : PoolIntArray,_rivaldeck : PoolIntArray):
		return

	func _first_select(myhand : PoolIntArray, _rivalhand : PoolIntArray)-> int:
		generator = RandomNumberGenerator.new()
		generator.randomize()
		return generator.randi_range(0,myhand.size() - 1)

	func _combat_select(myself : ICpuCommander.Player,_rival : ICpuCommander.Player)-> int:
		return generator.randi_range(0,myself.hand.size() - 1)

	func _recover_select(myself : ICpuCommander.Player,_rival : ICpuCommander.Player)-> int:
		return generator.randi_range(0,myself.hand.size() - 1)


var commanders : Array = [
	ZeroCommander.new(),
	RandomCommander.new()
]



func _ready():
	$MatchScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$MatchScene.exit_button.text = "SURRENDER"

func _on_ExitButton_pressed():
	$MatchScene.game_server._send_surrender()



func initialize(changer : ISceneChanger):
	scene_changer = changer
	
	offline_server = OfflineServer.new()

	deck_regulation = Global.deck_regulation_list[0]
	var deck_list = Global.deck_list[deck_regulation.name]
	$MenuLayer/Menu/CPUDeckBanner.set_deck_data(deck_list.get_select_deck())
	$MenuLayer/Menu/DeckBanner.set_deck_data(deck_list.get_select_deck())
	
	match_regulation = Global.match_regulation_list[0]

	$MenuLayer/Menu/CheckBoxLog.pressed = Global.game_settings.offline_logging


func _terminalize():
	$MatchScene.terminalize()
	if match_logger:
		match_logger.terminalize()


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

	if match_logger:
		Global.replay_log_list.append(match_logger.match_log)
		Global.replay_log_list.save_list()
	$MatchScene.terminalize()


func _on_ReturnButton_pressed():
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.show()



func _on_ButtonBack_pressed():
	scene_changer._goto_title_scene()



func _on_ButtonStart_pressed():
	var deck = $MenuLayer/Menu/DeckBanner.get_deck_data()
	var cpu_deck = $MenuLayer/Menu/CPUDeckBanner.get_deck_data()
	
	if !deck_regulation.check_regulation(deck.cards,Global.card_catalog).empty() or \
			!deck_regulation.check_regulation(cpu_deck.cards,Global.card_catalog).empty():
		return
	
	var commander = commanders[$MenuLayer/Menu/OptionCommander.selected]
	offline_server.initialize(Global.game_settings.player_name,deck.cards,commander,cpu_deck.cards,
			deck_regulation,match_regulation,Global.card_catalog)

	if match_logger:
		match_logger.terminalize()
	if $MenuLayer/Menu/CheckBoxLog.pressed:
		match_logger = MatchLogger.new()
		match_logger.initialize(offline_server)
	else:
		match_logger = null
	
	$MatchScene.initialize(match_logger as IGameServer if match_logger else offline_server as IGameServer)
	$MatchScene.send_ready()

	Bgm.stream = load("res://sound/魔王魂  ファンタジー11.ogg")
	Bgm.play()
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.hide()



func _on_BuildSelectScene_decided(index):
	var deck_list = Global.deck_list["newbie"]
	if index >= 0 and index < deck_list.list.size():
		if select_cpu_deck:
			$MenuLayer/Menu/CPUDeckBanner.set_deck_data(deck_list.list[index])
		else:
			deck_list.select = index
			deck_list.save_deck_list()
			$MenuLayer/Menu/DeckBanner.set_deck_data(deck_list.get_select_deck())
		$MenuLayer/BuildSelectScene.hide()

func _on_BuildSelectScene_return_button_pressed():
	$MenuLayer/BuildSelectScene.hide()

func _on_ButtonDeckChange_pressed():
	select_cpu_deck = false
	$MenuLayer/BuildSelectScene.initialize_select(deck_regulation)
	$MenuLayer/BuildSelectScene.show()

func _on_ButtonCPUDeckChange_pressed():
	select_cpu_deck = true
	$MenuLayer/BuildSelectScene.initialize_select(deck_regulation)
	$MenuLayer/BuildSelectScene.show()



func _on_ButtonRegulation_pressed():
	$MenuLayer/RegulationSelect.initialize()
	$MenuLayer/RegulationSelect.show()


func _on_RegulationSelect_regulation_button_pressed(name):
	if name == "newbie":
		$MenuLayer/Menu/ButtonRegulation/Label.text = "初級レギュレーション"
		deck_regulation = Global.deck_regulation_list[0]
		$MenuLayer/Menu/DeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$MenuLayer/Menu/CPUDeckBanner.set_deck_data(Global.deck_list[name].get_select_deck())
		$MenuLayer/RegulationSelect.hide()


func _on_RegulationSelect_return_button_pressed():
	$MenuLayer/RegulationSelect.hide()


func _on_OptionCommander_item_selected(_index):
	pass # Replace with function body.




func _on_ButtonMatchRegulation_pressed():
	$MenuLayer/MatchRegulationSelect.show()


func _on_MatchRegulationSelect_decided(m_regulation):
	match_regulation = m_regulation
	$MenuLayer/Menu/ButtonMatchRegulation/Label.text =\
			 "%s\n%s" % [match_regulation.name,match_regulation.to_regulation_string()]
