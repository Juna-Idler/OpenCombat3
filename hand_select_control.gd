extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var draging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _gui_input(event):
	if draging:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			draging = false
			
		elif event is InputEventMouseMotion:
			print(event.relative)
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			draging = true


func _on_Control_mouse_entered():
	pass


func _on_Control_mouse_exited():
	pass

