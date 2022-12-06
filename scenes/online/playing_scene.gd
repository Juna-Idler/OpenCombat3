extends ISceneChanger.IScene

class_name OnlinePlayingScene

var scene_changer : ISceneChanger


func initialize(server : IGameServer,changer : ISceneChanger):
	
	scene_changer = changer
	$MatchScene.initialize(server)
	$MatchScene.send_ready()
	$"%ResultOverlap".hide()

func _terminalize():
	$MatchScene.terminalize()


func _ready():
	$MatchScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$MatchScene.exit_button.text = "SURRENDER"

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


func _on_ButtonBack_pressed():
	scene_changer._goto_online_entrance_scene()


