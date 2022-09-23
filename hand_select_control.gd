extends Control


var card : Card

var _draging := false
var _drag_point : Vector2
var _drag_card_pos : Vector2

enum DragMode {NOT_SET,X,Y}
var _drag_mode : int

var drag_limit_left : int = 150
var drag_limit_right : int = 150
const drag_limit_top : int = 50

func _ready():
	pass # Replace with function body.




func _gui_input(event: InputEvent):
	if _draging:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and not event.pressed):
			card.position = _drag_card_pos
			card.z_index -= 1
			_draging = false
			
		elif event is InputEventMouseMotion:
			var point := (event as InputEventMouseMotion).global_position
			var relative := point - _drag_point
			relative = drag_limit(relative)
			card.position = _drag_card_pos + relative
	else:
		if (event is InputEventMouseButton
				and event.button_index == BUTTON_LEFT
				and event.pressed):
			_drag_point = (event as InputEventMouseButton).global_position
			_drag_card_pos = card.position
			card.z_index += 1
			_drag_mode = DragMode.NOT_SET
			_draging = true


func drag_limit(relative : Vector2) -> Vector2:
	var x_sign := -1 if relative.x < 0 else 1
	var x := 0.0 if _drag_mode == DragMode.Y else relative.x
	x = -drag_limit_left if x < -drag_limit_left else x
	x = drag_limit_right if x > drag_limit_right else x
	x = abs(x)
	var y:= 0.0 if _drag_mode == DragMode.X or relative.y > 0 else relative.y
	y = drag_limit_top if -y > drag_limit_top else -y
	
	if _drag_mode == DragMode.NOT_SET:
		if y > x and y > 10:
			_drag_mode = DragMode.Y
			x = 0
		elif x > y and x > 10:
			_drag_mode = DragMode.X
			y = 0
		
	return Vector2(x * x_sign,-y)
