extends ISceneChanger.IScene


class_name ReplayScene

var scene_changer : ISceneChanger

var replay_server : ReplayServer


func _ready():
	pass

func initialize(changer : ISceneChanger):
	scene_changer = changer
	




func _terminalize():
	$PlayingScene.terminalize()



func _on_ButtonBack_pressed():
	scene_changer._goto_title_scene()
