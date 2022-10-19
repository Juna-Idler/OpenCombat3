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
	
	func _goto_playing_scene(server : IGameServer):
		fade.color.a = 0.0
		fade.show()
		var tween := node.create_tween()
		tween.tween_property(fade,"color:a",1.0,1.0)
		yield(tween,"finished")

		if current_scene != null:
			node.remove_child(current_scene)
			current_scene.free()
		var Scene := load("res://scenes/playing_scene/playing_scene.tscn") as PackedScene
		current_scene = Scene.instance() as PlayingScene
		current_scene.initialize(server,self)
		node.add_child(current_scene)
		
		tween = node.create_tween()
		tween.tween_property(fade,"color:a",0.0,1.0)
		yield(tween,"finished")
		fade.hide()


var scene_changer : SceneChanger


func _ready():
	scene_changer = SceneChanger.new(self,$"%SceneFade",$TitleScene)
	$TitleScene.scene_changer = scene_changer
	$"%SceneFade".hide()
	pass


