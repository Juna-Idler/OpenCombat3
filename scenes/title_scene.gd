extends Node

class_name TitleScene

var scene_changer : ISceneChanger

func _ready():
	if Global.card_catalog.translation == "en":
		$Panel/LanguageOptionButton.selected = 1
	
func initialize(changer : ISceneChanger):
	scene_changer = changer
	pass


func _on_CpuButton_pressed():
	var offline := OfflineServer.new("Tester",Global.card_catalog)
	var deck = []
	for i in range(30):
		deck.append(i+1)
	offline.standby_single(deck,0)
	
	scene_changer._goto_playing_scene(offline)


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
