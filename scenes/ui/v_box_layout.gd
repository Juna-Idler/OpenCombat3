extends Control

class_name VBoxLayout


export var top_margin : int = 8
export var bottom_margin : int = 8
export var space : int = 8
export var left_margin : int = 8
export var right_margin : int = 8

export var reverse : bool = false

func _ready():
	layout()
	pass

func layout():
	if not reverse:
		var size_y := top_margin
		for c in get_children():
			if c is Control and c.visible:
				c.rect_position = Vector2(left_margin,size_y)
				size_y += c.rect_size.y + space
		if size_y == top_margin:
			rect_min_size.y = top_margin + bottom_margin
		else:
			rect_min_size.y = size_y - space + bottom_margin
	else:
		var size_y := top_margin
		for i in range(get_child_count(),0,-1):
			var c := get_child(i-1) as Control
			if c is Control and c.visible:
				c.rect_position = Vector2(left_margin,size_y)
				size_y += c.rect_size.y + space
		if size_y == top_margin:
			rect_min_size.y = top_margin + bottom_margin
		else:
			rect_min_size.y = size_y - space + bottom_margin
		


