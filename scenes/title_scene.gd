extends ISceneChanger.IScene

class_name TitleScene

var scene_changer : ISceneChanger

func _ready():
	if Global.card_catalog.translation == "en":
		$Panel/LanguageOptionButton.selected = 1
	
func initialize(changer : ISceneChanger):
	scene_changer = changer
	pass
	
func _terminalize():
	pass


func _on_CpuButton_pressed():
	scene_changer._goto_offline_playing_scene()

func _on_ButtonVSOnline_pressed():
	scene_changer._goto_online_entrance_scene()

func _on_BuildButton_pressed():
	scene_changer._goto_build_scene()



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


