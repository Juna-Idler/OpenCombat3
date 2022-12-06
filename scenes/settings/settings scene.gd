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
	var volume = -AudioServer.get_bus_volume_db(idx)
	var mute = AudioServer.is_bus_mute(idx)
	var slider = get_node("HSlider" + bus_name) as HSlider
	slider.value = volume
	(slider.get_node("CheckBox" + bus_name) as CheckBox).pressed = mute

func _on_BackButton_pressed():
	hide()
	
func _on_ExitButton_pressed():
	hide()

func _on_HSliderMaster_value_changed(value):
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx,-value)

func _on_HSliderBGM_value_changed(value):
	var idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(idx,-value)

func _on_HSliderSE_value_changed(value):
	var idx = AudioServer.get_bus_index("SE")
	AudioServer.set_bus_volume_db(idx,-value)


func _on_CheckBoxMaster_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(idx,button_pressed)

func _on_CheckBoxBGM_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_mute(idx,button_pressed)

func _on_CheckBoxSE_toggled(button_pressed):
	var idx = AudioServer.get_bus_index("SE")
	AudioServer.set_bus_mute(idx,button_pressed)


func _on_LineEditName_text_changed(new_text):
	Global.game_settings.player_name = new_text


func _on_ButtonSave_pressed():
	Global.game_settings.save_config()



var o_s_settings : Node
func _on_ButtonOnlineServer_pressed():
	o_s_settings = preload("res://scenes/settings/online_server.tscn").instance()
	o_s_settings.connect("returned",self,"_on_OnlineServer_returned")
	add_child(o_s_settings)

func _on_OnlineServer_returned():
	$ButtonOnlineServer.text = Global.game_settings.online_servers[Global.game_settings.server_index]
	remove_child(o_s_settings)
	o_s_settings.queue_free()
	
