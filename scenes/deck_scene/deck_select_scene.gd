extends Control

class_name DeckSelectScene

const Banner = preload("clickable_banner.tscn")

var deck_list = null
var select : Control

func initialize(select_index : int):
	deck_list = Global.deck_list.list
	
	var cc := Global.deck_list.list.size()
	select_index = 0 if select_index < 0 else select_index
	select_index = cc - 1 if select_index >= cc else select_index
	
	for i in Global.deck_list.list.size():
		var b = Banner.instance()
		var db = b.get_node("DeckBanner").initialize(Global.deck_list.list[i])
		b.connect("clicked",self,"_on_Banner_clicked",[db])
		$"%BannerContainer".add_child(b)
		if i == select_index:
			select = b
			db.set_frame_color(Color.red)
			b.grab_focus()


func _ready():
	if deck_list == null:
		initialize(0)

func save_deck_list():
	deck_list = []
	for c in $"%BannerContainer".get_children():
		var dd = c.get_node("DeckBanner").get_deck_data()
		deck_list.append(dd)
	Global.deck_list.list = deck_list
	Global.deck_list.save_deck_list()

func _on_Banner_clicked(click_db : DeckBanner):
	for c in $"%BannerContainer".get_children():
		var db = c.get_node("DeckBanner")
		if db == click_db:
			click_db.set_frame_color(Color.red)
			select = c
		else:
			db.set_frame_color(Color.white)



func _on_ButtonEdit_pressed():
	if select:
		var db := select.get_node("DeckBanner") as DeckBanner
		$BuildScene.initialize(db.get_deck_data())
		$BuildScene.show()


func _on_BuildScene_pressed_save_button(deck_data):
	if select:
		var db := select.get_node("DeckBanner") as DeckBanner
		db.initialize(deck_data)
		db.reset_visual()
		save_deck_list()



func _on_ButtonNew_pressed():
	if select:
		var db := select.get_node("DeckBanner") as DeckBanner
		db.set_frame_color(Color.white)

	var b = Banner.instance()
	var db = b.get_node("DeckBanner").initialize(DeckData.new("",[],[]))
	b.connect("clicked",self,"_on_Banner_clicked",[db])
	$"%BannerContainer".add_child(b)
	select = b
	db.set_frame_color(Color.red)
	b.grab_focus()


func _on_ButtonCopy_pressed():
	if select:
		var db := select.get_node("DeckBanner") as DeckBanner
		db.set_frame_color(Color.white)
		var new_b = Banner.instance()
		var new_db = new_b.get_node("DeckBanner").initialize(db.get_deck_data())
		new_b.connect("clicked",self,"_on_Banner_clicked",[new_db])
		$"%BannerContainer".add_child(new_b)
		select = new_b
		new_db.set_frame_color(Color.red)
		new_b.grab_focus()
		save_deck_list()


func _on_ButtonDelete_pressed():
	if select:
		select.grab_focus()
		var db := select.get_node("DeckBanner") as DeckBanner
		$PopupDialog/DeckBanner.set_deck_Data(db.get_deck_data())
		$PopupDialog.popup_centered()


func _on_ButtonOK_pressed():
	$"%BannerContainer".remove_child(select)
	select.queue_free()
	select = null
	save_deck_list()
	$PopupDialog.hide()

func _on_ButtonCancel_pressed():
	$PopupDialog.hide()
