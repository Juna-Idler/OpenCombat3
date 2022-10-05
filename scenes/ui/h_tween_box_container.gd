extends Control


export var left_margin : int = 8
export var right_margin : int = 8
export var space : int = 8
export var top_margin : int = 8

export var duration : float = 0.5

enum TransitionType {
	TRANS_LINEAR = 0,
	TRANS_SINE = 1,
	TRANS_QUINT = 2,
	TRANS_QUART = 3,
	TRANS_QUAD = 4,
	TRANS_EXPO = 5,
	TRANS_ELASTIC = 6,
	TRANS_CUBIC = 7,
	TRANS_CIRC = 8,
	TRANS_BOUNCE = 9,
	TRANS_BACK = 10,
}
export(TransitionType) var trans_type : int = TransitionType.TRANS_QUAD

enum EaseType {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3,
}
export(EaseType) var ease_type : int = EaseType.EASE_OUT

export var tween_path: NodePath
onready var tween : Tween = get_node(tween_path)

func _ready():
	pass

func layout():
	var size_x := left_margin
	for c in get_children():
		if c is Control:
			c.rect_position = Vector2(size_x,top_margin)
			size_x += c.rect_size.x + space
	if size_x == left_margin:
		rect_min_size.x = left_margin + right_margin
	else:
		rect_min_size.x = size_x - space + right_margin

func layout_tween():
	tween.remove_all()
	var size_x := left_margin
	for c in get_children():
		if c is Control:
			tween.interpolate_property(c,"rect_position",null,Vector2(size_x,top_margin),
					duration,trans_type,ease_type)
			size_x += c.rect_size.x + space
	tween.start()
	if size_x == left_margin:
		rect_min_size.x = left_margin + right_margin
	else:
		rect_min_size.x = size_x - space + right_margin

func add_child_tween(child : Control):
	add_child(child)
	layout_tween()

func add_children_tween(children : Array):
	for c in children:
		add_child(c)
	layout_tween()

