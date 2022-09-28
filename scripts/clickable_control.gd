extends Control


signal clicked()
signal held()


var hold_timer : Timer = null
var hold_time : float = 1

var _holding := false

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			if hold_timer != null and not hold_timer.is_stopped():
				hold_timer.stop()
				hold_timer.disconnect("timeout",self,"_on_timer_timeout")
			_holding = false
			emit_signal("clicked")
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_holding = true
			if hold_timer != null:
				hold_timer.start(hold_time)
# warning-ignore:return_value_discarded
				hold_timer.connect("timeout",self,"_on_timer_timeout")

func _on_timer_timeout():
	_holding = false
	emit_signal("held")
	hold_timer.disconnect("timeout",self,"_on_timer_timeout")

