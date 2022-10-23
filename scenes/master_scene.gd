extends Node

class_name MasterScene

class SceneChanger extends ISceneChanger:
	var node : Node
	var fade : ColorRect
	var current_scene : Node
	
	func _init(n : Node,f : ColorRect,c : Node):
		node = n
		fade = f
		current_scene = c
		
		randomize()
		
		
	func fade_out(duration : float):
		fade.color.a = 0.0
		fade.show()
		var tween := node.create_tween()
		tween.tween_property(fade,"color:a",1.0,duration)
		yield(tween,"finished")
		
	func fade_in(duration : float):
		var tween = node.create_tween()
		tween.tween_property(fade,"color:a",0.0,duration)
		yield(tween,"finished")
		fade.hide()
	
	
	func _goto_playing_scene(server : IGameServer):
		yield(fade_out(1.0),"completed")

		if current_scene != null:
			node.remove_child(current_scene)
			current_scene.free()
		var Scene := load("res://scenes/playing_scene/playing_scene.tscn") as PackedScene
		current_scene = Scene.instance() as PlayingScene
		current_scene.initialize(server,self)
		node.add_child(current_scene)
		
		yield(fade_in(1.0),"completed")

	func _goto_title_scene():
		yield(fade_out(1.0),"completed")

		if current_scene != null:
			node.remove_child(current_scene)
			current_scene.free()
		var Scene := load("res://scenes/title_scene.tscn") as PackedScene
		current_scene = Scene.instance() as TitleScene
		current_scene.initialize(self)
		node.add_child(current_scene)
		
		yield(fade_in(1.0),"completed")

	func _goto_build_scene():
		yield(fade_out(1.0),"completed")

		if current_scene != null:
			node.remove_child(current_scene)
			current_scene.free()
		var Scene := load("res://scenes/deck_scene/deck_select_scene.tscn") as PackedScene
		current_scene = Scene.instance() as DeckSelectScene
		current_scene.initialize(self)
		node.add_child(current_scene)
		
		yield(fade_in(1.0),"completed")

var scene_changer : SceneChanger


func _ready():
	scene_changer = SceneChanger.new(self,$"%SceneFade",$TitleScene)
	$TitleScene.scene_changer = scene_changer
	$"%SceneFade".hide()
	pass


