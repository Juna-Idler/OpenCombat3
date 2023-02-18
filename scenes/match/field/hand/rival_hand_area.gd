# warning-ignore-all:return_value_discarded

extends I_HandArea

const ClickableControl = preload("clickable_control.tscn")


const control_width := 144
const control_height := 216
const control_space := 10

var controls : Array = []
var hands : Array # of MatchCard


onready var _timer := $Timer


func _init():
	pass

func _ready():
	align()
	pass


func _set_card(cards : Array):
	var old_count := hands.size()
	var new_count := cards.size()
	hands = cards
	if new_count > controls.size():
		for _i in range(new_count - controls.size()):
			var c := ClickableControl.instance()
# warning-ignore:return_value_discarded
			c.connect("clicked_card",self,"_on_clicked_card")
# warning-ignore:return_value_discarded
			c.connect("held_card",self,"_on_held_card")
			c._timer = _timer
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
		controls[i].rect_position.x = start + step * (hand_count - 1 - i)
		controls[i].rect_position.y = y


func _move_card(sec : float):
	var tween := create_tween()
	for i in range(hands.size()):
		var c := controls[i] as Control
		var h := hands[i] as MatchCard
		var pos := c.rect_global_position + c.rect_size / 2
		tween.parallel()
		tween.tween_property(h,"global_position",pos,sec)

func _on_clicked_card(card : MatchCard):
	var i := hands.find(card)
	emit_signal("card_clicked",i)

func _on_held_card(card : MatchCard):
	var i := hands.find(card)
	emit_signal("card_held",i)

	
