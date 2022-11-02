extends Control

class_name SelectUseDeckScene


signal decided(index)

onready var banner_container := $BannerContainer


func _ready():
	pass


func _on_ButtonDecide_pressed():
	if banner_container.select:
		banner_container.get_select_index()
		emit_signal("decided",banner_container.get_select_index())
		hide()



func _on_ReturnButton_pressed():
	hide()


func _on_ButtonViewList_pressed():
	if banner_container.select:
		$DeckList.set_deck(banner_container.get_select_banner().get_deck_data().cards,false)
		$DeckList.show()
