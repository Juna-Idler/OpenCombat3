# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name ReplayScene


var scene_changer : ISceneChanger

var replay_server : ReplayServer = ReplayServer.new()

enum ReplayMode {AUTO,NO_WAIT,STEP}
var replay_mode : int

var performing : bool
var time_start_perform : int
var duration_last_performing : int


func _ready():
	$Timer.connect("timeout",self,"_on_Timer_timeout")
	$PlayingScene.exit_button.connect("pressed",self,"_on_ExitButton_pressed")
	$PlayingScene.exit_button.text = "EXIT"

func _on_ExitButton_pressed():
	$Timer.stop()
	Bgm.stop()
	$PlayingScene.terminalize()
	$Panel/ReplayMenu.show()


func initialize(changer : ISceneChanger):
	scene_changer = changer

	$Panel/ReplayMenu.initialize()
	$Panel/ReplayMenu.show()
	$"%ResultOverlap".hide()

func _terminalize():
	$PlayingScene.terminalize()

func _on_ReplayMenu_back_pressed():
	scene_changer._goto_title_scene()

func _on_ReplayMenu_start_pressed(selected):
	$"%HSliderSpeed".value = 1
	$"%HSliderSpeed".editable = true
	$"%ButtonNoWait".pressed = false
	$"%ButtonPause".pressed = false
	replay_mode = ReplayMode.AUTO
	duration_last_performing = 0

	replay_server.initialize(selected.match_log)
	$PlayingScene.initialize(replay_server)
	$"%ResultOverlap".hide()
	$Panel/ReplayMenu.hide()
	performing = true
	$PlayingScene.send_ready()
	Bgm.stream = load("res://sound/魔王魂  ファンタジー11.ogg")
	Bgm.play()
	
	if replay_server.match_log.update_data.empty():
		yield(get_tree().create_timer(replay_server.match_log.end_time / 1000.0), "timeout")
		replay_server.emit_end_signal()
	else:
		$Timer.start(replay_server.match_log.update_data[0].time / 1000.0)

func _on_Timer_timeout():
	if replay_mode != ReplayMode.AUTO:
		return
	if replay_server.step < replay_server.match_log.update_data.size():
		performing = true
		time_start_perform = Time.get_ticks_msec()
		replay_server.step_forward()
	else:
		replay_server.emit_end_signal()

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
	Bgm.stop()
	$"%HSliderSpeed".value = 1
	$"%HSliderSpeed".editable = false
	$PlayingScene.terminalize()

func _on_PlayingScene_performed():
	duration_last_performing = Time.get_ticks_msec() - time_start_perform
	performing = false

	var step = replay_server.step

	match replay_mode:
		ReplayMode.AUTO:
			if step < replay_server.match_log.update_data.size():
				var duration = replay_server.match_log.update_data[step].time - replay_server.match_log.update_data[step-1].time
				duration -= duration_last_performing
				$Timer.start(0.01 if duration <= 0 else duration / 1000.0)
			else:
				if replay_server.match_log.end_time > 0:
					var duration = replay_server.match_log.end_time - replay_server.match_log.update_data.back().time
					duration -= duration_last_performing
					$Timer.start(0.01 if duration <= 0 else duration / 1000.0)
		ReplayMode.NO_WAIT:
			if step < replay_server.match_log.update_data.size():
				performing = true
				time_start_perform = Time.get_ticks_msec()
				replay_server.step_forward()
			else:
				replay_server.emit_end_signal()


func _on_ButtonNoWait_toggled(button_pressed:bool):
	if not $PlayingScene.game_server:
		return

	match replay_mode:
		ReplayMode.AUTO:
			$Timer.stop()
		ReplayMode.NO_WAIT:
			pass

	replay_mode = ReplayMode.NO_WAIT if button_pressed else ReplayMode.AUTO

	if not performing:
		var step = replay_server.step
		match replay_mode:
			ReplayMode.AUTO:
				if step < replay_server.match_log.update_data.size():
					var duration = replay_server.match_log.update_data[step].time - replay_server.match_log.update_data[step-1].time
					duration -= duration_last_performing
					$Timer.start(0.01 if duration <= 0 else duration / 1000.0)
				else:
					if replay_server.match_log.end_time > 0:
						var duration = replay_server.match_log.end_time - replay_server.match_log.update_data.back().time
						duration -= duration_last_performing
						$Timer.start(0.01 if duration <= 0 else duration / 1000.0)
			ReplayMode.NO_WAIT:
				performing = true
				time_start_perform = Time.get_ticks_msec()
				replay_server.step_forward()


func _on_ReturnButton_pressed():
	$"%ResultOverlap".hide()
	$Panel/ReplayMenu.show()


func _on_HSliderSpeed_value_changed(value):
	Engine.time_scale = value


func _on_ButtonPause_toggled(button_pressed):
	if button_pressed:
		$Timer.stop()
		$CanvasLayer/Panel/TabContainer.current_tab = 1
	else:
		$Timer.start(1)
		$CanvasLayer/Panel/TabContainer.current_tab = 0


func _on_SettingButton_pressed():
	$PlayingScene.get_node("SettingsLayer/SettingsScene").show()


func _on_ButtonStep_pressed():
	if performing:
		return
	performing = true
	time_start_perform = Time.get_ticks_msec()
	replay_server.step_forward()


func _on_ButtonStepBack_pressed():
	if performing:
		return
	replay_server.step_backward()





