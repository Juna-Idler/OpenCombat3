extends Control


signal name_changed(new_name)


var drop_rects : Array = []

func initialize(data : DeckData):
	$Banner.initialize(data,true)
	$Banner.reset_visual()
	$NameEdit.text = $Banner.data.name

func _ready():
	pass

func get_deck_data() -> DeckData:
	return $Banner.data

func drop_card(index : int):
	$Banner.data.key_card_indexes.append(index)
	$Banner.reset_visual()


func _on_NameEdit_text_changed(new_text):
	$Banner.set_name(new_text)
	emit_signal("name_changed",new_text)



func _on_Banner_card_clicked(dbcard):
	$Banner.remove_card(dbcard)
