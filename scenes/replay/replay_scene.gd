# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene


class_name ReplayScene

var scene_changer : ISceneChanger

var replay_server : ReplayServer = ReplayServer.new()

var selected : ReplayBanner

func _ready():
	$Timer.connect("timeout",self,"_on_Timer_timeout")
	pass

func initialize(changer : ISceneChanger):
	scene_changer = changer
	
	for i in Global.test_replay_logs:
		var banner := preload("res://scenes/replay/banner.tscn").instance() as ReplayBanner
		banner.initialize(i)
		banner.connect("clicked",self,"_on_Banner_clicked",[banner])
		$Panel/Panel/BannerContainer/Container.add_child(banner)
		
	$Panel/Panel.show()
	$"%ResultOverlap".hide()

func _terminalize():
	$PlayingScene.terminalize()


func _on_ButtonBack_pressed():
	scene_changer._goto_title_scene()


func _on_ButtonStart_pressed():
	if selected == null:
		return
		
	replay_server.initialize(selected.match_log)
	$PlayingScene.initialize(replay_server)
	$"%HSliderSpeed".editable = true
	$"%ResultOverlap".hide()
	$Panel/Panel.hide()
	$PlayingScene.send_ready()
	$Timer.start(replay_server.match_log.update_data[0].time / 1000.0)

func _on_Timer_timeout():
	var step = replay_server.play_one_step()
	if step < replay_server.match_log.update_data.size():
		var duration = replay_server.match_log.update_data[step].time - replay_server.match_log.update_data[step-1].time
		$Timer.start(duration / 1000.0)
	else:
		if replay_server.match_log.end_time > 0:
			var duration = replay_server.match_log.end_time - replay_server.match_log.update_data.back().time
			yield(get_tree().create_timer(duration / 1000.0), "timeout")
			replay_server.emit_end_signal()


func _on_Banner_clicked(banner : ReplayBanner):
	selected = banner
	for i in $"%Container".get_child_count():
		var c = $"%Container".get_child(i)
		if c == banner:
			c.set_frame_color(Color.red)
		else:
			c.set_frame_color(Color.white)
	

func _on_PlayingScene_ended(situation, msg):
	$"%ResultOverlap".show()
	match situation:
		1:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("ResultLabel").text = "Win"
		0:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("ResultLabel").text = "Draw"
		-1:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("ResultLabel").text = "Lose"
		-2:
			$"%ResultOverlap".get_node("ResultLabel").text = msg
	$"%HSliderSpeed".value = 1
	$"%HSliderSpeed".editable = false

func _on_ReturnButton_pressed():
	$"%ResultOverlap".hide()
	$Panel/Panel.show()


func _on_HSliderSpeed_value_changed(value):
	Engine.time_scale = value
