# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name BuildMenuScene

var scene_changer : ISceneChanger


func initialize(changer : ISceneChanger):
	scene_changer = changer
	$RegulationSelect.initialize()

func _terminalize():
	pass

func _ready():
	pass


func _on_RegulationSelect_regulation_button_pressed(name):
	if name == "newbie":
		$Cover.show()
		$BuildSelectScene.initialize_build(Global.deck_regulation_list[0])
		$BuildSelectScene.show()
		var tween := create_tween()
		tween.tween_property($RegulationSelect,"modulate:a",0.0,0.5)
		tween.tween_callback($RegulationSelect,"hide")
		tween.tween_callback($Cover,"hide")


func _on_RegulationSelect_return_button_pressed():
	$Cover.show()
	scene_changer._goto_title_scene()


func _on_BuildSelectScene_return_button_pressed():
	$Cover.show()
	$RegulationSelect.show()
	var tween := create_tween()
	tween.tween_property($RegulationSelect,"modulate:a",1.0,0.5)
	tween.tween_callback($BuildSelectScene,"hide")
	tween.tween_callback($Cover,"hide")

