extends "res://scenes/ui/clickable_control.gd"


const CardListItem = preload("./card_list_item.tscn")

onready var container := $ListContainer

var large_card_view : Node

const item_x_count := 7
const x_start := 112

var wait : bool = false

func _ready():
	pass


func set_card_list(list : Array,deck_list : Array):
	if wait:
		return
	show()
	if container.get_child_count() < list.size():
		for i in list.size() - container.get_child_count():
			var ci = CardListItem.instance()
			ci.connect("clicked",self,"_on_ListItem_clicked",[ci])
			ci._timer = $Timer
			container.add_child(ci)
	
	for i in list.size():
		var c := deck_list[list[i]] as Card
		var ci = container.get_child(i)
		ci.visible = true
		ci.initialize(c,c.global_position,c.z_index,c.scale,c.rotation,c.visible,c.get_parent())
	for i in range(list.size(),container.get_child_count()):
		var ci = container.get_child(i)
		ci.visible = false
		
	var y_count := int((list.size() - 1) / item_x_count) + 1
	var y_step := 216 + 8
	var height := y_step * y_count - 8
	var y_start := (720 - height) / 2
	if y_start < 8:
		y_start = 8
		y_step = (container.rect_size.y - 216 - y_start*2) / (y_count - 1);
	for i in range(list.size()):
		var x := x_start + (144 + 8) * (i % item_x_count)
		var y := y_start + y_step * int(i / item_x_count)
		var ci := container.get_child(i)
		ci.rect_position = Vector2(x,y)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	for i in range(list.size()):
		var ci := container.get_child(i)
		var pos : Vector2 = ci.rect_global_position - Vector2(-72,-108)
		var c := ci.card as Card
		ci.o_parent_node.remove_child(c)
		add_child(c)
		tween.set_parallel(true)
		tween.tween_property(c,"rotation",0.0,0.5)
		tween.tween_property(c,"global_position",pos,0.5)
		c.visible = true
		c.z_index = 1000 + i

func restore_card():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	for ci in container.get_children():
		if not ci.visible:
			break
		var c := ci.card as Card
		remove_child(c)
		ci.o_parent_node.add_child(c)
		tween.tween_property(c,"rotation",ci.o_rotation,0.5)
		tween.tween_property(c,"global_position",ci.o_position,0.5)
		
	tween.set_parallel(false)
	for ci in container.get_children():
		if not ci.visible:
			break
		tween.tween_callback(self,"reset_card",[ci])
	yield(tween,"finished")

func reset_card(ci):
	ci.card.z_index = ci.o_z_index
	ci.visible = ci.o_visible


func _on_ListItem_clicked(_self):
	large_card_view.show_layer(_self.card.front.data)


func _on_CardList_clicked():
	wait = true
	hide()
	yield(restore_card(),"completed")
	wait = false
