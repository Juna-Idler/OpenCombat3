extends ISceneChanger.IScene

class_name OnlinePlayingScene

var scene_changer : ISceneChanger


func initialize(server : IGameServer,changer : ISceneChanger):
	
	scene_changer = changer
	$PlayingScene.initialize(server)
	$PlayingScene.send_ready()
	$"%ResultOverlap".hide()

func _terminalize():
	$PlayingScene.terminalize()


func _ready():
	pass


func _on_PlayingScene_ended(situation,msg):
	$"%ResultOverlap".show()
	match situation:
		1:
			pass
		0:
			pass
		-1:
			pass
		-2:
			pass
	pass # Replace with function body.


func _on_ButtonBack_pressed():
	scene_changer._goto_online_entrance_scene()
