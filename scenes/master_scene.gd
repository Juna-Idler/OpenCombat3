extends Node

class_name MasterScene

class SceneChanger extends ISceneChanger:
	var master_scene : MasterScene
	var fade : TransitionFade
	var current_scene : ISceneChanger.IScene
	
	var fade_in_duration : float = 0.5
	var fade_out_duration : float = 0.5
	
	func _init(n : Node,f : TransitionFade,c : Node):
		master_scene = n
		fade = f
		current_scene = c
		
		randomize()
		
	
	func _goto_scene_before(tscn_path : String):
		fade.show()
#		fade.invert = false
		fade.fade_out(fade_out_duration)
		yield(fade,"fade_finished")
		if current_scene != null:
			current_scene._terminalize()
			master_scene.remove_child(current_scene)
			current_scene.free()
		current_scene = load(tscn_path).instance()
		master_scene.add_child(current_scene)
		master_scene.move_child(current_scene,0)
	
	func _goto_scene_after():
#		fade.invert = true
		fade.fade_in(fade_in_duration)
		yield(fade,"fade_finished")
		fade.hide()
		
	
	func _goto_offline_scene():
		yield(_goto_scene_before("res://scenes/offline/playing_scene.tscn"),"completed")
		(current_scene as OfflineScene).initialize(self)
		yield(_goto_scene_after(),"completed")

	func _goto_title_scene():
		yield(_goto_scene_before("res://scenes/title_scene.tscn"),"completed")
		(current_scene as TitleScene).initialize(self)
		yield(_goto_scene_after(),"completed")

	func _goto_build_scene():
		yield(_goto_scene_before("res://scenes/deck/build_menu_scene.tscn"),"completed")
		(current_scene as BuildMenuScene).initialize(self)
		yield(_goto_scene_after(),"completed")

	func _goto_online_scene():
		yield(_goto_scene_before("res://scenes/online/playing_scene.tscn"),"completed")
		(current_scene as OnlineScene).initialize(master_scene.online_server,self)
		yield(_goto_scene_after(),"completed")

	func _goto_replay_scene():
		yield(_goto_scene_before("res://scenes/replay/replay_scene.tscn"),"completed")
		(current_scene as ReplayScene).initialize(self)
		yield(_goto_scene_after(),"completed")
		

var scene_changer : SceneChanger
onready var online_server : OnlineServer = $OnlineNode.server

func _ready():
	scene_changer = SceneChanger.new(self,$"%SceneFade",$"%TitleScene")
	$"%TitleScene".scene_changer = scene_changer
	$"%SceneFade".hide()
	pass

func _unhandled_input(event):
	var key := event as InputEventKey
	if key and key.scancode == KEY_S and key.pressed:
		$"%Camera2D".shake()

