extends ISceneChanger.IScene

class_name SinglePlayerScene

var scene_changer : ISceneChanger

var single_player_server : SinglePlayerServer



func _ready():
	$MatchScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$MatchScene.exit_button.text = "SURRENDER"
	if not single_player_server:
		single_player_server = SinglePlayerServer.new()
		

func _on_ExitButton_pressed():
	$MatchScene.game_server._send_surrender()



func initialize(changer : ISceneChanger):
	scene_changer = changer
	
	single_player_server = SinglePlayerServer.new()


	$"%ResultOverlap".hide()
	$MenuLayer/Menu.show()


func _terminalize():
	$MatchScene.terminalize()


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


func _on_ReturnButton_pressed():
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.show()



func _on_ButtonBack_pressed():
	scene_changer._goto_title_scene()



func _on_ButtonStart_pressed():
	var deck = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	var cpu_deck = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	
	
	single_player_server.initialize(Global.game_settings.player_name,deck,4,
			"Enemy",cpu_deck,4,30,
			Global.card_catalog)

	
	$MatchScene.initialize(single_player_server,
			$MatchScene/UILayer/MyField/MyHandArea,$MatchScene/UILayer/RivalField/RivalHandArea)
	$MatchScene.send_ready()

	Bgm.stream = load("res://sound/魔王魂  ファンタジー11.ogg")
	Bgm.play()
	$"%ResultOverlap".hide()
	$MenuLayer/Menu.hide()

