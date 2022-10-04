extends Control

const RawCard := preload( "../card/raw_card.tscn")
const DeckItem := preload("control_in_deck.tscn")
const PoolItem := preload("control_in_pool.tscn")

onready var deck_container := $ScrollContainer/HBoxContainer
const deck_item_width := 144
const deck_item_height := 216
const deck_item_space := 8

const pool_item_start := Vector2(68,16)
const pool_item_width := 120
const pool_item_height := 180
const pool_item_space := 8
const pool_item_x_count := 9
const pool_item_x_step := pool_item_width + pool_item_space
const pool_item_y_step := pool_item_height + pool_item_space

onready var deck_area : Rect2 = $ScrollContainer.get_global_rect()


var pool_controls :Array

var deck_controls := []

var _deck_cards := []

func _ready():
	pool_controls = [[],[]]
	for i in 2:
		for j in pool_item_x_count:
			var p := PoolItem.instance()
			p.rect_position.x = pool_item_start.x + pool_item_x_step * j
			p.rect_position.y = pool_item_start.y + pool_item_y_step * i
			pool_controls[i].append(p)
			$PoolList.add_child(p)
	var deck := []
	for i in 27:
		deck.append(i+1)
	set_deck(deck)


func set_deck(deck : Array):
	var old_count := _deck_cards.size()
	var new_count := deck.size()
	_deck_cards = deck
	if new_count > deck_controls.size():
		for i in range(new_count - deck_controls.size()):
			var c := DeckItem.instance()
			c.connect("dragged",self,"_on_dragged")
			c.connect("dragging",self,"_on_dragging")
			c.connect("dropped",self,"_on_dropped")
#			c.connect("slid_card",self,"_on_slid_card")
#			c.connect("decided_card",self,"_on_decided_card")
#			c.connect("held_card",self,"_on_held_card")
#			c.connect("clicked_card",self,"_on_clicked_card")
			deck_controls.append(c)

	if new_count > old_count:
		for i in range(old_count,new_count):
			deck_container.add_child(deck_controls[i])
	elif new_count < old_count:
		for i in range(new_count,old_count):
			deck_container.remove_child(deck_controls[i])
	

	for i in deck.size():
		deck_controls[i].get_node("CardFront").initialize_card(Global.card_catalog.get_card_data(deck[i]))
		
		
func _on_dragged(_self,pos):
	_self.modulate.a = 0.5
	var mover = $CardFront
	mover.initialize_card(_self.get_node("CardFront").data)
	var gp = _self.rect_global_position
	mover.rect_global_position = gp
	mover.visible = true
	
func _on_dragging(_self,relative_pos,start_pos):
	var mover = $CardFront
	var gp = _self.rect_global_position
	mover.rect_global_position = gp + relative_pos

func _on_dropped(_self,relative_pos,start_pos):
	var g_drop_pos = _self.rect_global_position + relative_pos + start_pos
	if deck_area.has_point(g_drop_pos):
		var skip : int = relative_pos.x / (deck_item_width + deck_item_space)
		if skip != 0:
			var old_index : int = deck_controls.find(_self)
			var new_index : int = old_index + skip
			if new_index >= 0 and new_index < _deck_cards.size():
				var v = deck_controls.pop_at(old_index)
				deck_controls.insert(new_index,v)
				for i in range(_deck_cards.size()):
					deck_container.move_child(deck_controls[i],i)
	else:
		deck_container.remove_child(_self)
	
	_self.modulate.a = 1
	var mover = $CardFront
	mover.visible = false
	
