extends Control


signal pressed_save_button(deck_data)

const RawCard := preload( "../card/card_front.tscn")
const DeckItem := preload("deck_card.tscn")
const PoolItem := preload("small_card.tscn")

onready var deck_container : HTweenBoxContainer = $"%HTweenBoxContainer"
const deck_item_width := 144
const deck_item_height := 216
const deck_item_space := 8

const pool_item_start := Vector2(72,24)
const pool_item_width := 112
const pool_item_height := 168
const pool_item_space := 16
const pool_item_x_count := 9
const pool_item_x_step := pool_item_width + pool_item_space
const pool_item_y_step := pool_item_height + pool_item_space


const slide_duration := 0.5
var banner_mode := false

var pool_controls :Array

var pool_start_id : int = 1

var deck_cards_count : int
var deck_cost : int = 0

var key_cards : PoolIntArray

func initialize(deck : DeckData):
	key_cards = deck.key_cards
	set_deck(deck.cards)
	$Header/DeckName.text = deck.name


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
			p.connect("mouse_entered",self,"_on_PoolItem_mouse_entered",[p])
			p.connect("mouse_exited",self,"_on_PoolItem_mouse_exited",[p])
			$"%PoolList".add_child(p)
			
	$"%PoolList".move_child($"%Zoom",$"%PoolList".get_child_count()-1)
	$"%PoolList".move_child($"%Invalid",$"%PoolList".get_child_count()-1)
	$"%Zoom".hide()
	$"%Invalid".hide()

	var deck := []
	for i in 27:
		deck.append(i+1)
	var data = DeckData.new("名前はない",deck,[])
	initialize(data)


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
		var c := DeckItem.instance() as Control
		c.connect("dragged",self,"_on_DeckItem_dragged")
		c.connect("dragging",self,"_on_DeckItem_dragging")
		c.connect("dropped",self,"_on_DeckItem_dropped")
		c.connect("held",self,"_on_DeckItem_held")
		c._timer = $Timer
		deck_container.add_child(c)
		var cd := Global.card_catalog.get_card_data(deck[i])
		c.get_node("CardFront").initialize_card(cd)
		deck_cost += cd.level
	deck_container.layout()
		
	$Header/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]


func add_card(id : int,g_position : Vector2):
	var sc = $"%ScrollContainer"
	var rate : float = sc.scroll_horizontal / (deck_container.rect_size.x - sc.rect_size.x)
	g_position -= sc.rect_global_position + deck_container.rect_position

	var index : int = (g_position.x + deck_item_width/2) / (deck_item_width + deck_item_space)
	index = max(min(index,deck_container.get_child_count()),0)
	
	var c := DeckItem.instance() as Control
	c.connect("dragged",self,"_on_DeckItem_dragged")
	c.connect("dragging",self,"_on_DeckItem_dragging")
	c.connect("dropped",self,"_on_DeckItem_dropped")
	c.connect("held",self,"_on_DeckItem_held")
	c._timer = $Timer
	c.rect_position = g_position - Vector2(deck_item_width,deck_item_height)/2
	deck_container.add_child(c)
	deck_container.move_child(c,index)
	deck_container.layout_tween()
	var cd := Global.card_catalog.get_card_data(id)
	c.get_node("CardFront").initialize_card(cd)
	deck_cards_count += 1
	deck_cost += cd.level
	$Header/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]

	var tween := create_tween()
	var target : int = (deck_container.rect_min_size.x - sc.rect_size.x) * rate
 # intを明示しないと型違いでtween_propertyが失敗する
	var t: = tween.tween_property(sc,"scroll_horizontal",target,0.5)
	t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

 # こっちのTweenならintとfloatの型の違いを吸収してくれる？
#	$Tween.interpolate_property(sc,"scroll_horizontal",null,(deck_container.rect_min_size.x - sc.rect_size.x) * rate,
#			0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
#	yield(get_tree(),"idle_frame")
#	sc.scroll_horizontal = (deck_container.rect_min_size.x - sc.rect_size.x) * rate

func remove_card(cd : CardData):
	deck_cost -= cd.level
	deck_cards_count -= 1
	$Header/Infomation.text = "デッキ枚数：%s    総コスト：%s" % [deck_cards_count,deck_cost]


func get_deck() -> Array:
	var r := []
	for i in deck_container.get_children():
		var cd := i.get_node("CardFront").data as CardData
		r.append(cd.id)
	return r

		
onready var mover = $"%DragMover"
		
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
	if banner_mode:
		if $"%BannerEditor".get_global_rect().has_point(g_drop_pos):
			var cd : CardData = _self.get_node("CardFront").data
			$"%BannerEditor".drop_card(cd.id)
	else:
		if $"%ScrollContainer".get_global_rect().has_point(g_drop_pos):
			var skip : int = relative_pos.x / (deck_item_width + deck_item_space)
			if skip != 0:
				var old_index : int = deck_container.get_children().find(_self)
				var new_index : int = old_index + skip
				if new_index >= 0 and new_index < deck_cards_count:
					var v = deck_container.move_child(_self,new_index)
					_self.rect_position += relative_pos
					deck_container.layout_tween()
		else:
			var cd : CardData = _self.get_node("CardFront").data
			deck_container.remove_child(_self)
			deck_container.layout_tween()
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
	$"%Zoom".visible = false
	
func _on_PoolItem_dragging(_self,relative_pos,start_pos):
	var gp = _self.rect_global_position
	var diff : Vector2 = (_self.rect_size - Vector2(144,216)) / 2
	mover.rect_global_position = gp + relative_pos + diff

func _on_PoolItem_dropped(_self,relative_pos,start_pos):
	var g_drop_pos = _self.rect_global_position + relative_pos + Vector2(pool_item_width,pool_item_height)/2
	if $"%ScrollContainer".get_global_rect().has_point(g_drop_pos):
		add_card(_self.get_node("CardFront").data.id,g_drop_pos)
	_self.modulate.a = 1
	mover.visible = false
	
func _on_PoolItem_held(_self):
	$LargeCardView.show_layer(_self.get_node("CardFront").data)


func _on_PoolItem_mouse_entered(pool_item):
	$"%Zoom".initialize_card(pool_item.get_node("CardFront").data)
	var gp = pool_item.rect_global_position
	var diff : Vector2 = (pool_item.rect_size - Vector2(144,216)) / 2
	$"%Zoom".rect_global_position = gp + diff
	$"%Zoom".visible = true
	
func _on_PoolItem_mouse_exited(pool_item):
	$"%Zoom".visible = false


func _on_Next_pressed():
	pool_start_id += 18
	set_pool(pool_start_id)
	if pool_start_id + 18 > Global.card_catalog.get_max_card_id():
		$"%Next".disabled = true
	$"%Prev".disabled = false
	$"%Zoom".visible = false


func _on_Prev_pressed():
	pool_start_id -= 18
	set_pool(pool_start_id)
	if pool_start_id <= 1:
		$"%Prev".disabled = true
	$"%Next".disabled = false
	$"%Zoom".visible = false
	

func _on_PoolList_gui_input(event):
	if mover.visible == true:
		return
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if not $"%Prev".disabled:
					_on_Prev_pressed()
			if event.button_index == BUTTON_WHEEL_DOWN:
				if not $"%Next".disabled:
					_on_Next_pressed()


func _on_ListOpen_pressed():
	$DeckList.visible = true
	$DeckList.set_deck(get_deck())


func _on_DeckList_closed(deck):
	set_deck(deck)


func _on_DeckName_clicked():
	var pos: float = 56 if banner_mode else 56 + 320
	banner_mode = not banner_mode
	if banner_mode:
		var deck_data := DeckData.new($Header/DeckName.text,get_deck(),key_cards)
		$"%BannerEditor".initialize(deck_data)
	else:
		key_cards = $"%BannerEditor".get_deck_data().key_cards
	$"%Invalid".visible = banner_mode
	var tween := create_tween()
	tween.tween_property($Container,"rect_position:y",pos,slide_duration)



func _on_BannerEditor_name_changed(new_name):
	$Header/DeckName.text = new_name


func _on_ReturnButton_pressed():
	hide()


func _on_SaveButton_pressed():
	if banner_mode:
		emit_signal("pressed_save_button",$"%BannerEditor".get_deck_data())
	else:
		emit_signal("pressed_save_button",DeckData.new($Header/DeckName.text,get_deck(),key_cards))
