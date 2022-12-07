extends Control


func _ready():
	$LineEditSave.text =  OS.get_user_data_dir()
	$LineEditName.text = Global.game_settings.player_name
	$ButtonOnlineServer.text = Global.game_settings.online_servers[Global.game_settings.server_index]
	
	set_sound("Master")
	set_sound("BGM")
	set_sound("SE")
	
func set_sound(bus_name:String):
	var idx = AudioServer.get_bus_index(bus_name)
	var volume = from_db(AudioServer.get_bus_volume_db(idx))
	var mute = AudioServer.is_bus_mute(idx)
	var slider = get_node("HSlider" + bus_name) as HSlider
	slider.value = volume
	(slider.get_node("CheckBox" + bus_name) as CheckBox).pressed = not mute

func _on_BackButton_pressed():
	hide()
	
func _on_ExitButton_pressed():
	hide()


static func to_db(v : float) -> float:
	return log(clamp(v / 100.0, 0.0001, 1)) / log(10) * 20
static func from_db(db : float) -> float:
	return pow(10,clamp(db, -80, 0) / 20) * 100.0

func _on_HSliderMaster_value_changed(value):
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx,to_db(value))

func _on_HSliderBGM_value_changed(value):
	var idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(idx,to_db(value))

func _on_HSliderSE_value_changed(value):
	var idx = AudioServer.get_bus_index("SE")
	AudioServer.set_bus_volume_db(idx,to_db(value))


func _on_CheckBoxMaster_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(idx,not button_pressed)

func _on_CheckBoxBGM_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_mute(idx,not button_pressed)

func _on_CheckBoxSE_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("SE")
	AudioServer.set_bus_mute(idx,not button_pressed)


func _on_LineEditName_text_changed(new_text):
	Global.game_settings.player_name = new_text


func _on_ButtonSave_pressed():
	Global.game_settings.save_config()



var o_s_settings : Node
func _on_ButtonOnlineServer_pressed():
	o_s_settings = preload("res://scenes/settings/online_server.tscn").instance()
# warning-ignore:return_value_discarded
	o_s_settings.connect("returned",self,"_on_OnlineServer_returned")
	add_child(o_s_settings)

func _on_OnlineServer_returned():
	$ButtonOnlineServer.text = Global.game_settings.online_servers[Global.game_settings.server_index]
	remove_child(o_s_settings)
	o_s_settings.queue_free()
	
