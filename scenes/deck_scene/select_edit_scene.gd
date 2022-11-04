extends ISceneChanger.IScene

class_name SelectEditDeckScene

var scene_changer : ISceneChanger

onready var banner_container := $BannerContainer

func initialize(changer : ISceneChanger):
	scene_changer = changer

func _terminalize():
	pass

func _ready():
	pass

func save_deck_list():
	Global.deck_list.list = banner_container.get_deck_list()
	Global.deck_list.save_deck_list()
	$Panel/ButtonMoveSave.disabled = true



func _on_ButtonEdit_pressed():
	if banner_container.select:
		var db = banner_container.get_select_banner()
		$BuildScene.initialize(db.get_deck_data())
		$BuildScene.show()


func _on_BuildScene_pressed_save_button(deck_data):
	if banner_container.select:
		var db = banner_container.get_select_banner()
		db.initialize(deck_data)
		db.reset_visual()
		save_deck_list()



func _on_ButtonNew_pressed():
	banner_container.append(DeckData.new("",[],[]))


func _on_ButtonCopy_pressed():
	if banner_container.select:
		banner_container.append(banner_container.get_select_banner().get_deck_data())
		save_deck_list()


func _on_ButtonDelete_pressed():
	if banner_container.select:
		banner_container.select.grab_focus()
		$PopupDialog/DeckBanner.set_deck_Data(banner_container.get_select_banner().get_deck_data())
		$PopupDialog.popup_centered()


func _on_ButtonOK_pressed():
	if banner_container.select:
		banner_container.delete_select()
		save_deck_list()
		$PopupDialog.hide()

func _on_ButtonCancel_pressed():
	$PopupDialog.hide()


func _on_ReturnButton_pressed():
	scene_changer._goto_title_scene()


func _on_ButtonUP_pressed():
	if banner_container.move_up_select():
		$Panel/ButtonMoveSave.disabled = false


func _on_ButtonDown_pressed():
	if banner_container.move_down_select():
		$Panel/ButtonMoveSave.disabled = false

func _on_ButtonMoveSave_pressed():
		save_deck_list()
