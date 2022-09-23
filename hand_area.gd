extends Control


const HandSelectControl = preload("res://hand_select_control.tscn")


var controls : Array = []
var hands : Array# of Card

func _init():
	pass

func _ready():
	align()
	pass


func set_hand_card(cards : Array):
	var old_count := hands.size()
	var new_count := cards.size()
	hands = cards
	if new_count > controls.size():
		for i in range(new_count - controls.size()):
			controls.append(HandSelectControl.instance())

	if new_count > old_count:
		for i in range(old_count,new_count):
			add_child(controls[i])
	elif new_count < old_count:
		for i in range(new_count,old_count):
			remove_child(controls[i])
	for i in range(new_count):
		controls[i].card = hands[i]
	align()

func align():
	var hand_count := hands.size()
	var step := rect_size.x / (hand_count + 1)
	var start := step - 128 / 2
	if step < 128 + 10:
		start = step / 10
		step = (rect_size.x - 128 - start*2) / (hand_count - 1);
	for i in range(hand_count):
		controls[i].rect_position.x = start + step * i
		controls[i].drag_limit_left = i * step + 50
		controls[i].drag_limit_right = (hand_count - 1 - i) * step + 50


func move_card():
	for i in range(hands.size()):
		var c := controls[i] as Control
		var h := hands[i] as Card
		var pos := c.rect_global_position + c.rect_size / 2
		h.global_position = pos
		
