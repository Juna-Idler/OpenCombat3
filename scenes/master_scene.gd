extends Node

class_name MasterScene

class SceneChanger extends ISceneChanger:
	var node : Node
	var fade : ColorRect
	var current_scene : Node
	
	var fade_in_duration : float = 1.0
	var fade_out_duration : float = 1.0
	
	func _init(n : Node,f : ColorRect,c : Node):
		node = n
		fade = f
		current_scene = c
		
		randomize()
		
		
	func fade_out():
		fade.color.a = 0.0
		fade.show()
		var tween := node.create_tween()
		tween.tween_property(fade,"color:a",1.0,fade_out_duration)
		yield(tween,"finished")
		
	func fade_in():
		var tween = node.create_tween()
		tween.tween_property(fade,"color:a",0.0,fade_in_duration)
		yield(tween,"finished")
		fade.hide()
	
	
	func _goto_scene_before(tscn_path : String):
		yield(fade_out(),"completed")
		if current_scene != null:
			node.remove_child(current_scene)
			current_scene.free()
		current_scene = load(tscn_path).instance()
	
	func _goto_scene_after():
		node.add_child(current_scene)
		yield(fade_in(),"completed")
		
	
	func _goto_playing_scene(server : IGameServer):
		yield(_goto_scene_before("res://scenes/playing_scene/playing_scene.tscn"),"completed")
		(current_scene as PlayingScene).initialize(server,self)
		yield(_goto_scene_after(),"completed")

	func _goto_title_scene():
		yield(_goto_scene_before("res://scenes/title_scene.tscn"),"completed")
		(current_scene as TitleScene).initialize(self)
		yield(_goto_scene_after(),"completed")

	func _goto_build_scene():
		yield(_goto_scene_before("res://scenes/deck_scene/select_edit_scene.tscn"),"completed")
		(current_scene as SelectEditDeckScene).initialize(self)
		yield(_goto_scene_after(),"completed")

		
	func _goto_online_entrance_scene():
		yield(_goto_scene_before("res://scenes/online/entrance_scene.tscn"),"completed")
		(current_scene as OnlineEntranceScene).initialize(self)
		yield(_goto_scene_after(),"completed")



var scene_changer : SceneChanger


func _ready():
	scene_changer = SceneChanger.new(self,$"%SceneFade",$TitleScene)
	$TitleScene.scene_changer = scene_changer
	$"%SceneFade".hide()
	pass


