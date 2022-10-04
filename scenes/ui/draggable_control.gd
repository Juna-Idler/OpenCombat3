extends Control


signal clicked(_self)
signal held(_self)
signal dragged(_self,pos)
signal dragging(_self,relative_pos,start_pos)
signal dropped(_self,relative_pos,start_pos)

export var timer_path: NodePath
onready var _timer := get_node(timer_path) as Timer if timer_path  else _timer

var _holding := false

var _dragging := false
var _drag_point : Vector2

const drag_amount := 10 * 10

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			if _dragging:
				var point := (event as InputEventMouseButton).global_position
				var relative := point - (_drag_point + get_global_rect().position)
				_dragging = false
				emit_signal("dropped",self,relative,_drag_point)
			else:
				if _timer != null and not _timer.is_stopped():
					_timer.stop()
					_timer.disconnect("timeout",self,"_on_timer_timeout")
				emit_signal("clicked",self)
			_holding = false
			
		elif event is InputEventMouseMotion:
			var point := (event as InputEventMouseMotion).global_position
			var relative := point - (_drag_point + get_global_rect().position)
			if not _dragging and relative.length_squared() >= drag_amount:
				_dragging = true
				emit_signal("dragged",self,_drag_point)
				if _timer != null and not _timer.is_stopped():
					_timer.stop()
					_timer.disconnect("timeout",self,"_on_timer_timeout")
			if _dragging:
				emit_signal("dragging",self,relative,_drag_point)
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_holding = true
			_drag_point = (event as InputEventMouseButton).position
			if _timer != null:
				_timer.start()
# warning-ignore:return_value_discarded
				_timer.connect("timeout",self,"_on_timer_timeout")

func _on_timer_timeout():
	_holding = false
	emit_signal("held",self)
	_timer.disconnect("timeout",self,"_on_timer_timeout")

func cancel():
	if _timer != null and not _timer.is_stopped():
		_timer.stop()
		_timer.disconnect("timeout",self,"_on_timer_timeout")
	_dragging = false
	_holding = false
