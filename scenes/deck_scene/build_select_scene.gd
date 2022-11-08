extends Node

class_name BuildSelectScene

signal return_button_pressed()

onready var banner_container := $BannerContainer

var deck_regulation : RegulationData.DeckRegulation
var card_pool : Array

func initialize(regulation : RegulationData.DeckRegulation):
	banner_container.initialize(Global.deck_list[regulation.name])
	deck_regulation = regulation
	card_pool = []
	for i in range(0,regulation.card_pool.size(),2):
		for id in range(regulation.card_pool[i],regulation.card_pool[i + 1] + 1):
			card_pool.append(Global.card_catalog.get_card_data(id))

func _terminalize():
	pass

func _ready():
	pass


func _on_ButtonEdit_pressed():
	if banner_container.select:
		var db = banner_container.get_select_banner()
		$BuildScene.show()
		$BuildScene.initialize(db.get_deck_data(),deck_regulation,card_pool)


func _on_BuildScene_pressed_save_button(deck_data):
	if banner_container.select:
		var db = banner_container.get_select_banner()
		db.initialize(deck_data)
		db.reset_visual()
		banner_container.save_deck_list()
		$Panel/ButtonMoveSave.disabled = true



func _on_ButtonNew_pressed():
	banner_container.append(DeckData.new("",[],[]))
	$Panel/ButtonMoveSave.disabled = true


func _on_ButtonCopy_pressed():
	if banner_container.select:
		banner_container.append(banner_container.get_select_banner().get_deck_data())
		$Panel/ButtonMoveSave.disabled = true


func _on_ButtonDelete_pressed():
	if banner_container.select:
		banner_container.select.grab_focus()
		$PopupDialog/DeckBanner.set_deck_data(banner_container.get_select_banner().get_deck_data())
		$PopupDialog.popup_centered()
#		$PopupDialog.modulate.a = 0
#		var tween := create_tween()
#		tween.tween_property($PopupDialog,"modulate:a",1.0,1)


func _on_ButtonOK_pressed():
	if banner_container.select:
		banner_container.delete_select()
		$Panel/ButtonMoveSave.disabled = true
		$PopupDialog.hide()

func _on_ButtonCancel_pressed():
	$PopupDialog.hide()


func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")


func _on_ButtonUP_pressed():
	if banner_container.move_up_select():
		$Panel/ButtonMoveSave.disabled = false


func _on_ButtonDown_pressed():
	if banner_container.move_down_select():
		$Panel/ButtonMoveSave.disabled = false

func _on_ButtonMoveSave_pressed():
		banner_container.save_deck_list()
		$Panel/ButtonMoveSave.disabled = true
