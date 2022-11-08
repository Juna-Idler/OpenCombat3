# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name BuildMenuScene

var scene_changer : ISceneChanger


func initialize(changer : ISceneChanger):
	scene_changer = changer

func _terminalize():
	pass

func _ready():
	pass


func _on_ReturnButton_pressed():
	scene_changer._goto_title_scene()

func _on_ButtonNewbie_pressed():
	$BuildSelectScene.initialize(Global.regulation_newbie)
	$Panel/Cover.show()
	$BuildSelectScene.show()
	var tween := create_tween()
	tween.tween_property($Panel,"modulate:a",0.0,0.5)
	tween.tween_callback($Panel,"hide")
	


func _on_BuildSelectScene_return_button_pressed():
	$Panel.show()
	var tween := create_tween()
	tween.tween_property($Panel,"modulate:a",1.0,0.5)
	tween.tween_callback($BuildSelectScene,"hide")
	tween.tween_callback($Panel/Cover,"hide")



