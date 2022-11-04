extends ISceneChanger.IScene

class_name OfflinePlayingScene

var scene_changer : ISceneChanger

var offline_server : OfflineServer


func _ready():
	pass

func initialize(changer : ISceneChanger):
	
	offline_server = OfflineServer.new("Tester",Global.card_catalog)

	var deck = Global.deck_list.get_online_deck()
	offline_server.standby_single(deck.cards,0)
	
	scene_changer = changer
	$PlayingScene.initialize(offline_server)
	
	$PlayingScene.send_ready()
	

func _terminalize():
	$PlayingScene.terminalize()


func _on_PlayingScene_ended(situation,msg):
	$"%ResultOverlap".show()
	match situation:
		1:
			$Panel/ResultOverlap/ResultLabel.text = "Win"
		0:
			$Panel/ResultOverlap/ResultLabel.text = "Draw"
		-1:
			$Panel/ResultOverlap/ResultLabel.text = "Lose"
		-2:
			$Panel/ResultOverlap/ResultLabel.text = msg
	pass # Replace with function body.


func _on_ReturnButton_pressed():
	if scene_changer:
		scene_changer._goto_title_scene()
	else:
		print("return title")
		$PlayingScene.terminalize()
		$PlayingScene.initialize(offline_server)


