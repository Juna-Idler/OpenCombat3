extends ScrollContainer

const Banner = preload("clickable_banner.tscn")

var select : Control

var deck_list : DeckList

func initialize(list : DeckList):
	deck_list = list
	var select_index = list.select
	
	var s := list.list.size()
	select_index = 0 if select_index < 0 else select_index
	select_index = s - 1 if select_index >= s else select_index
	
	for i in list.list.size():
		var b = Banner.instance()
		b.focus_mode = Control.FOCUS_ALL
		var db = b.get_node("DeckBanner").initialize(list.list[i])
		b.connect("clicked",self,"_on_Banner_clicked",[db])
		$Container.add_child(b)
		if i == select_index:
			select = b
			db.set_frame_color(Color.red)
			b.grab_focus()

func _ready():
	pass


func _on_Banner_clicked(click_db : DeckBanner):
	for i in $Container.get_child_count():
		var c = $Container.get_child(i)
		var db = c.get_node("DeckBanner")
		if db == click_db:
			click_db.set_frame_color(Color.red)
			select = c
			deck_list.select = i
		else:
			db.set_frame_color(Color.white)

func get_select_banner() -> DeckBanner:
	return select.get_node("DeckBanner") as DeckBanner

func save_deck_list():
	var list = []
	for c in $Container.get_children():
		var db = c.get_node("DeckBanner").get_deck_data()
		list.append(db)
	deck_list.list = list
	deck_list.save_deck_list()

func append(deck_data : DeckData):
	if select:
		var db = get_select_banner()
		db.set_frame_color(Color.white)
	
	var b = Banner.instance()
	b.focus_mode = Control.FOCUS_ALL
	var db = b.get_node("DeckBanner").initialize(deck_data)
	b.connect("clicked",self,"_on_Banner_clicked",[db])
	$Container.add_child(b)
	select = b
	db.set_frame_color(Color.red)
	b.grab_focus()
	save_deck_list()

func delete_select():
	$Container.remove_child(select)
	select.queue_free()
	select = null
	save_deck_list()

func move_up_select() -> bool:
	var i := get_select_index()
	if i > 0:
		$Container.move_child(select,i - 1)
		return true
	return false

func move_down_select() -> bool:
	var i := get_select_index()
	if i >= 0 and i < $Container.get_child_count() - 1:
		$Container.move_child(select,i + 1)
		return true
	return false

func get_select_index() -> int:
	if select:
		return $Container.get_children().find(select)
	return -1
