extends Control

signal pressed_surrender

func _ready():
	pass




func _on_BackButton_pressed():
	hide()
	
func _on_SurrenderButton_pressed():
	hide()
	emit_signal("pressed_surrender")


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

