extends Control


signal clicked_card(card)
signal held_card(card)

export var timer_path: NodePath
onready var _timer := (get_node(timer_path) if timer_path else _timer) as Timer

var card : MatchCard

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
			emit_signal("clicked_card",card)
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
	emit_signal("held_card",card)
	_timer.disconnect("timeout",self,"_on_timer_timeout")

