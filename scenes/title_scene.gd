extends Node

var scene_changer : ISceneChanger

func _ready():
	pass
	
func initialize(changer : ISceneChanger):
	scene_changer = changer
	pass


func _on_CpuButton_pressed():
	var offline := OfflineServer.new("Tester",Global.card_catalog)
	var deck = []
	for i in range(27):
		deck.append(i+1)
	offline.standby_single(deck,0)
	
	scene_changer._goto_playing_scene(offline)
	pass # Replace with function body.
