extends Control


signal clicked_card(index)


var index : int
var card : Card




func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked_card",index)
			else:
				pass

	if event is InputEventMouseMotion:
		pass
