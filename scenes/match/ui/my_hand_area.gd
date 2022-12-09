# warning-ignore-all:return_value_discarded

extends Control


const HandSelectControl = preload("hand_select_control.tscn")

const control_width := 144
const control_height := 216
const control_space := 10
const control_drag_play := 50
const slide_change_duration := 0.5
const slide_nochange_duration := 0.1

signal decided_card(index,hands)
signal held_card(index,card)
signal clicked_card(index,card)

export var timer_path: NodePath
onready var timer := get_node(timer_path) as Timer


var controls : Array = []
var hands : Array# of Card
var distance : int
var reorder : bool = false
var drag_banned : bool = false


func _init():
	pass

func _ready():
	align()
	pass

func ban_drag(b:bool):
	for c in controls:
		c.ban_drag = b
	drag_banned = b

func get_reorder_hand() -> Array:
	var reorder_hand := []
	if reorder:
		for c in hands:
			reorder_hand.append(c.id_in_deck)
	return reorder_hand


func set_hand_card(cards : Array):
	var old_count := hands.size()
	var new_count := cards.size()
	hands = cards
	if new_count > controls.size():
		for _i in range(new_count - controls.size()):
			var c := HandSelectControl.instance()
			c.index = controls.size()
			c.connect("slid_card",self,"_on_slid_card")
			c.connect("decided_card",self,"_on_decided_card")
			c.connect("held_card",self,"_on_held_card")
			c.connect("clicked_card",self,"_on_clicked_card")
			c.hold_timer = timer
			c.ban_drag = drag_banned
			controls.append(c)

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
	var y = (rect_size.y - control_height) / 2
	var hand_count := hands.size()
	var step := rect_size.x / (hand_count + 1)
# warning-ignore:integer_division
	var start := step - control_width / 2
	if step < control_width + control_space:
		start = step / 10
		step = (rect_size.x - control_width - start*2) / (hand_count - 1);
	for i in range(hand_count):
		controls[i].rect_position.x = start + step * i
		controls[i].rect_position.y = y
		controls[i].drag_limit_left = i * step + control_drag_play
		controls[i].drag_limit_right = (hand_count - 1 - i) * step + control_drag_play
	distance = int(step)

func move_card(sec : float):
	var tween := create_tween()
	for i in range(hands.size()):
		var c := controls[i] as Control
		var h := hands[i] as Card
		var pos := c.rect_global_position + c.rect_size / 2
		tween.parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(h,"global_position",pos,sec)
		
	tween.chain()
	tween.tween_callback(self,"_on_tween_end")


func _on_tween_end():
	for i in hands.size():
		controls[i].card.z_index =  i
	pass

func _on_slid_card(index,x):
	var skip : int = x / distance
	if skip == 0:
		move_card(slide_nochange_duration)
		return
	var old_index : int = index
	var new_index : int = index + skip
	var v = hands.pop_at(old_index)
	hands.insert(new_index,v)

	for i in range(hands.size()):
		controls[i].card = hands[i]
	align()
	move_card(slide_change_duration)
	reorder = true
	
	
func _on_decided_card(index):
	var reorder_hand := []
	if reorder:
		for c in hands:
			reorder_hand.append(c.id_in_deck)
	emit_signal("decided_card",index,reorder_hand)
	reorder = false

func _on_held_card(index):
	emit_signal("held_card",index,hands[index])

func _on_clicked_card(index):
	emit_signal("clicked_card",index,hands[index])
