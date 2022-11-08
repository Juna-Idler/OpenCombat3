extends Control


signal name_changed(new_name)


var drop_rects : Array = []

func initialize(data : DeckData):
	$Banner.initialize(data,true)
	$Banner.reset_visual()
	$NameEdit.text = $Banner.deck_data.name

func _ready():
	pass

func get_deck_data() -> DeckData:
	return $Banner.get_deck_data()

func drop_card(id : int):
	var tmp = $Banner.deck_data.key_cards
	tmp.append(id)
	$Banner.set_key_cards(tmp)
	$Banner.reset_visual()


func _on_NameEdit_text_changed(new_text):
	$Banner.set_name(new_text)
	emit_signal("name_changed",new_text)



func _on_Banner_card_clicked(dbcard):
	$Banner.remove_card(dbcard)
