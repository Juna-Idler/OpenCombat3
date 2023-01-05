extends Control


signal slid_card(index,x)
signal decided_card(index)
signal held_card(index)
signal clicked_card(index)

var index : int
var card : MatchCard

var _draging := false
var _drag_point : Vector2
var _drag_card_pos : Vector2

enum DragMode {NOT_SET,X,Y}
var _drag_mode : int

var drag_limit_left : float = 150
var drag_limit_right : float = 150
const drag_limit_top : float = 50.0

const drag_mode_amount := 10

var ban_drag : bool = false

var hold_timer : Timer = null


func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _draging:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			if not hold_timer.is_stopped():
				hold_timer.stop()
				hold_timer.disconnect("timeout",self,"_on_timer_timeout")
			_draging = false
			var point := (event as InputEventMouseButton).global_position
			var relative := drag_limit(point - _drag_point)
			if _drag_mode == DragMode.X:
				if not ban_drag:
					emit_signal("slid_card",index,relative.x)
			elif _drag_mode == DragMode.Y and relative.y == -drag_limit_top:
				if not ban_drag:
					emit_signal("decided_card",index)
			else:
				emit_signal("clicked_card",index)
				card.position = _drag_card_pos

			
		elif event is InputEventMouseMotion:
			if ban_drag:
				return
			var point := (event as InputEventMouseMotion).global_position
			var relative := point - _drag_point
			relative = drag_limit(relative)
			card.position = _drag_card_pos + relative
			if _drag_mode != DragMode.NOT_SET:
				if not hold_timer.is_stopped():
					hold_timer.stop()
					hold_timer.disconnect("timeout",self,"_on_timer_timeout")
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_drag_point = (event as InputEventMouseButton).global_position
			_drag_card_pos = card.position
			card.z_index += 10
			_drag_mode = DragMode.NOT_SET
			_draging = true
			hold_timer.start()
# warning-ignore:return_value_discarded
			hold_timer.connect("timeout",self,"_on_timer_timeout")

func _on_timer_timeout():
	_draging = false
	card.position = _drag_card_pos
	emit_signal("held_card",index)
	hold_timer.disconnect("timeout",self,"_on_timer_timeout")


func drag_limit(relative : Vector2) -> Vector2:
	var x_sign := -1 if relative.x < 0 else 1
	var x := 0.0 if _drag_mode == DragMode.Y else relative.x
	x = -drag_limit_left if x < -drag_limit_left else x
	x = drag_limit_right if x > drag_limit_right else x
	x = abs(x)
	var y:= 0.0 if _drag_mode == DragMode.X or relative.y > 0 else relative.y
	y = drag_limit_top if -y > drag_limit_top else -y
	
	if _drag_mode == DragMode.NOT_SET:
		if y > x and y > drag_mode_amount:
			_drag_mode = DragMode.Y
			x = 0
		elif x > y and x > drag_mode_amount:
			_drag_mode = DragMode.X
			y = 0
		
	return Vector2(x * x_sign,-y)
