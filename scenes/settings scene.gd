extends Control

signal pressed_surrender

func _ready():
	pass




func _on_BackButton_pressed():
	hide()
	
func _on_SurrenderButton_pressed():
	hide()
	emit_signal("pressed_surrender")
