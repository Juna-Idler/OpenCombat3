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

var pool_start_id : int = 1

var deck_cards_count : int
var deck_cost : int = 0

func _ready():
	pool_controls = [[],[]]
	for i in 2:
		for j in pool_item_x_count:
			var p := PoolItem.instance()
			p.rect_position.x = pool_item_start.x + pool_item_x_step * j
			p.rect_position.y = pool_item_start.y + pool_item_y_step * i
			pool_controls[i].append(p)
			var cd := Global.card_catalog.get_card_data(j + i * pool_item_x_count + 1)
			p.get_node("CardFront").initialize_card(cd)
			p.connect("dragged",self,"_on_PoolItem_dragged")
			p.connect("dragging",self,"_on_PoolItem_dragging")
			p.connect("dropped",self,"_on_PoolItem_dropped")
			p.connect("held",self,"_on_PoolItem_held")
			p._timer = $Timer
			$PoolList.add_child(p)
			
	var deck := []
	for i in 27:
		deck.append(i+1)
	set_deck(deck)

func set_pool(start_id : int):
	pool_start_id = start_id
	for i in 2:
		for j in pool_item_x_count:
			var id = start_id + j + i * pool_item_x_count
			if id >= 1 and id <= Global.card_catalog.get_max_card_id():
				var cd := Global.card_catalog.get_card_data(id)
				pool_controls[i][j].get_node("CardFront").initialize_card(cd)
				pool_controls[i][j].visible = true
			else:
				pool_controls[i][j].visible = false

func set_deck(deck : Array):
	deck_cards_count = deck.size()
	deck_cost = 0
	for c in deck_container.get_children():
		deck_container.remove_child(c)
		c.queue_free()
	for i in range(deck.size()):
		var c := DeckItem.instance()
		c.connect("dragged",self,"_on_DeckItem_dragged")
		c.connect("dragging",self,"_on_DeckItem_dragging")
		c.connect("dropped",self,"_on_DeckItem_dropped")
		c.connect("held",self,"_on_DeckItem_held")
		c._timer = $Timer
		deck_container.add_child(c)
		var cd := Global.card_catalog.get_card_data(deck[i])
		c.get_node("CardFront").initialize_card(cd)
		deck_cost += cd.level
		
	$Panel/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]


func add_card(id : int,index : int):
	var sc = $ScrollContainer
	var rate = sc.scroll_horizontal / (deck_container.rect_size.x - sc.rect_size.x)
	
	var c := DeckItem.instance()
	c.connect("dragged",self,"_on_DeckItem_dragged")
	c.connect("dragging",self,"_on_DeckItem_dragging")
	c.connect("dropped",self,"_on_DeckItem_dropped")
	c.connect("held",self,"_on_DeckItem_held")
	c._timer = $Timer
	deck_container.add_child(c)
	deck_container.move_child(c,index)
	var cd := Global.card_catalog.get_card_data(id)
	c.get_node("CardFront").initialize_card(cd)
	deck_cards_count += 1
	deck_cost += cd.level
	$Panel/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]
	
	yield(get_tree(),"idle_frame")
	sc.scroll_horizontal = (deck_container.rect_size.x - sc.rect_size.x) * rate

func remove_card(cd : CardData):
	deck_cost -= cd.level
	deck_cards_count -= 1
	$Panel/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]


func get_deck() -> Array:
	var r := []
	for i in deck_container.get_children():
		var cd := i.get_node("CardFront").data as CardData
		r.append(cd.id)
	return r

		
onready var mover = $DragMover
		
func _on_DeckItem_dragged(_self,pos):
	_self.modulate.a = 0.5
	mover.initialize_card(_self.get_node("CardFront").data)
	var gp = _self.rect_global_position
	mover.rect_global_position = gp
	mover.visible = true
	
func _on_DeckItem_dragging(_self,relative_pos,start_pos):
	var gp = _self.rect_global_position
	mover.rect_global_position = gp + relative_pos

func _on_DeckItem_dropped(_self,relative_pos,start_pos):
	var g_drop_pos = _self.rect_global_position + relative_pos + start_pos
	if deck_area.has_point(g_drop_pos):
		var skip : int = relative_pos.x / (deck_item_width + deck_item_space)
		if skip != 0:
			var old_index : int = deck_container.get_children().find(_self)
			var new_index : int = old_index + skip
			if new_index >= 0 and new_index < deck_cards_count:
				var v = deck_container.move_child(_self,new_index)
	else:
		var cd : CardData = _self.get_node("CardFront").data
		deck_container.remove_child(_self)
		_self.queue_free()
		remove_card(cd)
		

	
	_self.modulate.a = 1
	mover.visible = false
	
func _on_DeckItem_held(_self):
	$LargeCardView.show_layer(_self.get_node("CardFront").data)


func _on_PoolItem_dragged(_self,pos):
	_self.modulate.a = 0.5
	mover.initialize_card(_self.get_node("CardFront").data)
	var gp = _self.rect_global_position
	var diff : Vector2 = (_self.rect_size - Vector2(144,216)) / 2
	mover.rect_global_position = gp + diff
	mover.visible = true
	
func _on_PoolItem_dragging(_self,relative_pos,start_pos):
	var gp = _self.rect_global_position
	var diff : Vector2 = (_self.rect_size - Vector2(144,216)) / 2
	mover.rect_global_position = gp + relative_pos + diff

func _on_PoolItem_dropped(_self,relative_pos,start_pos):
	var g_drop_pos = _self.rect_global_position + relative_pos + start_pos
	if deck_area.has_point(g_drop_pos):
		var pos : Vector2 = deck_container.rect_position
		g_drop_pos -= pos
		var index : int = g_drop_pos.x / (deck_item_width + deck_item_space)
		index = max(min(index,deck_cards_count),0)
		add_card(_self.get_node("CardFront").data.id,index)
	_self.modulate.a = 1
	mover.visible = false
	
func _on_PoolItem_held(_self):
	$LargeCardView.show_layer(_self.get_node("CardFront").data)



func _on_Next_pressed():
	pool_start_id += 18
	set_pool(pool_start_id)
	if pool_start_id + 18 > Global.card_catalog.get_max_card_id():
		$PoolList/Next.disabled = true
	$PoolList/Prev.disabled = false


func _on_Prev_pressed():
	pool_start_id -= 18
	set_pool(pool_start_id)
	if pool_start_id <= 1:
		$PoolList/Prev.disabled = true
	$PoolList/Next.disabled = false
	
	
