extends Control


signal clicked()
signal held()

export var timer_path: NodePath
onready var _timer := get_node(timer_path) as Timer if timer_path else null


var _holding := false

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			if _timer != null and not _timer.is_stopped():
				_timer.stop()
				_timer.disconnect("timeout",self,"_on_timer_timeout")
			_holding = false
			var rect := Rect2(Vector2.ZERO,rect_size)
			if rect.has_point((event as InputEventMouseButton).position):
				emit_signal("clicked")
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_holding = true
			if _timer != null:
				_timer.start()
# warning-ignore:return_value_discarded
				_timer.connect("timeout",self,"_on_timer_timeout")

func _on_timer_timeout():
	_holding = false
	emit_signal("held")
	_timer.disconnect("timeout",self,"_on_timer_timeout")

