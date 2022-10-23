extends Control

class_name SelectUseDeckScene

const Banner = preload("clickable_banner.tscn")

var scene_changer : ISceneChanger

var select : Control

func initialize(changer : ISceneChanger):
	scene_changer = changer
	var selected = Global.deck_list.selected
	
	var s := Global.deck_list.list.size()
	selected = 0 if selected < 0 else selected
	selected = s - 1 if selected >= s else selected
	
	for i in Global.deck_list.list.size():
		var b = Banner.instance()
		var db = b.get_node("DeckBanner").initialize(Global.deck_list.list[i])
		b.connect("clicked",self,"_on_Banner_clicked",[db])
		$"%BannerContainer".add_child(b)
		if i == selected:
			select = b
			db.set_frame_color(Color.red)
			b.grab_focus()


func _ready():
	if scene_changer == null:
		initialize(null)


func _on_Banner_clicked(click_db : DeckBanner):
	for c in $"%BannerContainer".get_children():
		var db = c.get_node("DeckBanner")
		if db == click_db:
			click_db.set_frame_color(Color.red)
			select = c
		else:
			db.set_frame_color(Color.white)

func _on_ButtonDecide_pressed():
	if select:
		var db := select.get_node("DeckBanner") as DeckBanner



func _on_ReturnButton_pressed():
	scene_changer._goto_title_scene()



