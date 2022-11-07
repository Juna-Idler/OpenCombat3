extends ISceneChanger.IScene

class_name OfflinePlayingScene

var scene_changer : ISceneChanger

var offline_server : OfflineServer


func _ready():
	pass

func initialize(changer : ISceneChanger):
	
	offline_server = OfflineServer.new("Tester",Global.card_catalog)

	var deck = Global.deck_list_newbie.get_select_deck()
# warning-ignore:return_value_discarded
	offline_server.standby_single(deck.cards,0)
	
	scene_changer = changer
	$PlayingScene.initialize(offline_server)
	
	$PlayingScene.send_ready()
	$"%ResultOverlap".hide()


func _terminalize():
	$PlayingScene.terminalize()


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


func _on_ReturnButton_pressed():
	if scene_changer:
		scene_changer._goto_title_scene()
	else:
		print("return title")
		$PlayingScene.terminalize()
		$PlayingScene.initialize(offline_server)


