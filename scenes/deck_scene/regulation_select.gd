extends Panel

signal return_button_pressed()
signal regulation_button_pressed(name)


func initialize():
	pass

func _ready():
# warning-ignore:return_value_discarded
	$ButtonNewbie.connect("pressed",self,"_on_ButtonRegulation_pressed",["newbie"])
	pass


func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")


func _on_ButtonRegulation_pressed(name : String):
	emit_signal("regulation_button_pressed",name)
