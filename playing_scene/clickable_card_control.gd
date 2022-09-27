extends Control


signal clicked_card(card)
signal held_card(card)


var card : Card
var hold_timer : Timer = null

var _holding := false

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			if not hold_timer.is_stopped():
				hold_timer.stop()
				hold_timer.disconnect("timeout",self,"_on_timer_timeout")
			_holding = false
			emit_signal("clicked_card",card)
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_holding = true
			hold_timer.start()
			hold_timer.connect("timeout",self,"_on_timer_timeout")

func _on_timer_timeout():
	_holding = false
	emit_signal("held_card",card)
	hold_timer.disconnect("timeout",self,"_on_timer_timeout")

