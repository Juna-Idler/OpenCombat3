extends Control

signal closed(deck)
#_on_DeckList_closed(deck : Array)

const DeckItem := preload("small_card.tscn")

onready var deck_container := $DeckContainer
onready var mover = $"%DragMover"

const deck_item_width := 112
const deck_item_height := 168
const deck_item_x_space := 8
const deck_item_x_count := 10
const deck_item_x_step := deck_item_width + deck_item_x_space
const deck_item_x_start := 16

const deck_item_y_space := 16

var y_step : int
var y_start : int

var moving : bool = false

func _ready():
	var deck := []
	for i in 30:
		deck.append(i % 27 + 1)
	set_deck(deck)


func set_deck(deck : Array):
	for c in deck_container.get_children():
		deck_container.remove_child(c)
		c.queue_free()
	var y_count := int((deck.size() - 1) / deck_item_x_count) + 1
	y_step = deck_item_height + deck_item_y_space
	var height = y_step * y_count - deck_item_y_space
	y_start = (720 - height) / 2
	if y_start < 8:
		y_start = 8
		y_step = (deck_container.rect_size.y - deck_item_height - y_start*2) / (y_count - 1);
	for i in range(deck.size()):
		var x := deck_item_x_start + deck_item_x_step * (i % deck_item_x_count)
		var y := y_start + y_step * int(i / deck_item_x_count)
		var c := DeckItem.instance()
		c.connect("dragged",self,"_on_DeckItem_dragged")
		c.connect("dragging",self,"_on_DeckItem_dragging")
		c.connect("dropped",self,"_on_DeckItem_dropped")
		c.connect("held",self,"_on_DeckItem_held")
		c._timer = $Timer
		c.connect("mouse_entered",self,"_on_DeckItem_mouse_entered",[c])
		c.connect("mouse_exited",self,"_on_DeckItem_mouse_exited",[c])
		c.rect_position = Vector2(x,y)
		deck_container.add_child(c)
		var cd = Global.card_catalog.get_card_data(deck[i])
		c.get_node("CardFront").initialize_card(cd)


func get_deck() -> Array:
	var r := []
	for i in deck_container.get_children():
		var cd := i.get_node("CardFront").data as CardData
		r.append(cd.id)
	return r

func align_move():
	moving = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	for i in range(deck_container.get_child_count()):
		var x := deck_item_x_start + deck_item_x_step * (i % deck_item_x_count)
		var y := y_start + y_step * int(i / deck_item_x_count)
		tween.parallel()
		tween.tween_property(deck_container.get_child(i),"rect_position",Vector2(x,y),0.5)
	tween.chain()
	tween.connect("finished",self,"_on_tween_finished")
func _on_tween_finished():
	moving = false
		
func _on_DeckItem_dragged(_self,pos):
	_self.modulate.a = 0.25
	mover.initialize_card(_self.get_node("CardFront").data)
	var gp = _self.rect_global_position
	mover.rect_global_position = gp + Vector2(deck_item_width - 144,deck_item_height - 216)/2
	mover.visible = true
	
func _on_DeckItem_dragging(_self,relative_pos,start_pos):
	var gp = _self.rect_global_position
	mover.rect_global_position = gp + relative_pos + Vector2(deck_item_width - 144,deck_item_height - 216)/2

func _on_DeckItem_dropped(_self,relative_pos,start_pos):
	var g_drop_pos = _self.rect_global_position + relative_pos
	var x_skip : int = relative_pos.x / (deck_item_width + deck_item_x_space)
	var y_skip : int = floor((relative_pos.y + deck_item_height/2) / float(y_step))

	var old_index : int = deck_container.get_children().find(_self)
	var new_index : int = old_index + x_skip + y_skip * deck_item_x_count
	new_index = max(min(new_index,deck_container.get_child_count()-1),0)

	if old_index != new_index:
		deck_container.move_child(_self,new_index)
		_self.rect_position += relative_pos
		align_move()
	
	_self.modulate.a = 1
	mover.visible = false
	
func _on_DeckItem_held(_self):
	$LargeCardView.show_layer(_self.get_node("CardFront").data)

func _on_DeckItem_mouse_entered(item):
	if moving:
		return
	mover.initialize_card(item.get_node("CardFront").data)
	var gp : Vector2 = item.rect_global_position + (item.rect_size - Vector2(144,216)) / 2
	gp.x = max(gp.x,0)
	gp.y = max(gp.y,0)
	if gp.x + 144 > 1280:
		gp.x = 1280 - 144
	if gp.y + 216 > 720:
		gp.y = 720 - 216
	mover.rect_global_position = gp
	mover.visible = true
	
func _on_DeckItem_mouse_exited(item):
	mover.visible = false


func _on_Hide_pressed():
	visible = false
	emit_signal("closed",get_deck())
