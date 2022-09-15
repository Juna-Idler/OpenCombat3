extends Control


const HandSelectControl = preload("res://hand_select_control.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var controls = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(4):
		var c = HandSelectControl.instance()
		controls.append(c)
		add_child(c)
	align()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func align():
	var hand_count = controls.size()
	var step = rect_size.x / (hand_count + 1)
	var start = step - 128 / 2
	if step < 128 + 10:
		start = 0
		step = (rect_size.x - 128) / (hand_count - 1);
	for i in range(hand_count):
		controls[i].rect_position.x = start + step * i
