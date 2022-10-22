extends Control


signal name_changed(new_name)


var drop_rects : Array = []

func initialize(data : DeckData):
	$Banner.initialize(data)
	$Banner.reset_visual()
	$NameEdit.text = $Banner.data.name
	for i in $HTweenBox.get_child_count():
		$HTweenBox.get_child(i).get_child(0).initialize_card($Banner.get_key_card_data(i))

func _ready():
	$HTweenBox.layout()
	for c in $HTweenBox.get_children():
		drop_rects.append(c.get_rect())

func get_deck_data() -> DeckData:
	return $Banner.data

func drop_card(point : Vector2,cd : CardData,index : int):
	for i in $HTweenBox.get_child_count():
		var c := $HTweenBox.get_child(i)
		if c.get_global_rect().has_point(point):
			c.get_child(0).initialize_card(cd)
			$Banner.set_key_card_index(i,index)
			return


func _on_NameEdit_text_changed(new_text):
	$Banner.set_name(new_text)
	emit_signal("name_changed",new_text)


var original_point : Vector2
var original_order : int

func _on_Card_dragged(_self : Control, pos : Vector2):
	original_point = _self.rect_position
	original_order = $HTweenBox.get_children().find(_self)
	$HTweenBox.move_child(_self,$HTweenBox.get_child_count()-1)
	pass # Replace with function body.


func _on_Card_dragging(_self : Control, relative_pos : Vector2, start_pos : Vector2):
	_self.rect_position += relative_pos
	pass # Replace with function body.


func _on_Card_dropped(_self : Control, relative_pos : Vector2, start_pos : Vector2):
	var pos = _self.rect_position + relative_pos + start_pos
	var rect := Rect2(original_point,_self.rect_size)
	var cards := $HTweenBox.get_children()

	for i in 3:
		if drop_rects[i].has_point(pos):
			$HTweenBox.move_child(_self,i)
			if original_order == i:
				_self.rect_position = original_point
				return
			var tmp = $Banner.data.key_card_indexes[original_order]
			$Banner.data.key_card_indexes.remove(original_order)
			$Banner.data.key_card_indexes.insert(i,tmp)
			$Banner.reset_visual()
			$HTweenBox.layout_tween()
			return
	
	$HTweenBox.move_child(_self,original_order)
	_self.rect_position = original_point
	_self.get_child(0).initialize_card(null)
	$Banner.set_key_card_index(original_order,-1)

	
