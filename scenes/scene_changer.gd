class_name ISceneChanger

func _goto_offline_playing_scene():
	pass

func _goto_title_scene():
	pass

func _goto_build_scene():
	pass

func _goto_online_entrance_scene():
	pass

func _goto_online_playing_scene(_server : IGameServer):
	pass

func _goto_replay_scene():
	pass


class IScene extends Node:
	func _teminalize():
		pass
