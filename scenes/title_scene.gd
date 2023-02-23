extends ISceneChanger.IScene

class_name TitleScene

var scene_changer : ISceneChanger

func _ready():
	if TranslationServer.get_locale() == "en":
		$Panel/LanguageOptionButton.selected = 1
	
	$SettingsScene.self_modulate.a = 0.9
	$SettingsScene.get_node("ExitButton").hide()


func initialize(changer : ISceneChanger):
	scene_changer = changer
	pass
	
func _terminalize():
	pass


func _on_CpuButton_pressed():
	scene_changer._goto_offline_scene()

func _on_ButtonVSOnline_pressed():
	scene_changer._goto_online_scene()

func _on_BuildButton_pressed():
	scene_changer._goto_build_scene()


func _on_ButtonReplay_pressed():
	scene_changer._goto_replay_scene()


func _on_LanguageOptionButton_item_selected(index):
	match index:
		0:
			if Global.card_catalog.translation != "ja":
				TranslationServer.set_locale("ja")
				Global.card_catalog.translation = "ja"
		1:
			if Global.card_catalog.translation != "en":
				TranslationServer.set_locale("en")
				Global.card_catalog.translation = "en"
	Global.card_catalog.load_catalog()





func _on_ButtonSettings_pressed():
	$SettingsScene.modulate.a = 0
	$SettingsScene.show()
	var tween = create_tween()
	tween.tween_property($SettingsScene,"modulate:a",1.0,0.5)

