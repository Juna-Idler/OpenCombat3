extends ScrollContainer

const Banner = preload("clickable_banner.tscn")

var select : Control


func _ready():
	var selected = Global.deck_list.selected
	
	var s := Global.deck_list.list.size()
	selected = 0 if selected < 0 else selected
	selected = s - 1 if selected >= s else selected
	
	for i in Global.deck_list.list.size():
		var b = Banner.instance()
		var db = b.get_node("DeckBanner").initialize(Global.deck_list.list[i])
		b.connect("clicked",self,"_on_Banner_clicked",[db])
		$Container.add_child(b)
		if i == selected:
			select = b
			db.set_frame_color(Color.red)
			b.grab_focus()


func _on_Banner_clicked(click_db : DeckBanner):
	for i in $Container.get_child_count():
		var c = $Container.get_child(i)
		var db = c.get_node("DeckBanner")
		if db == click_db:
			click_db.set_frame_color(Color.red)
			select = c
			Global.deck_list.selected = i
		else:
			db.set_frame_color(Color.white)

func get_select_banner() -> DeckBanner:
	return select.get_node("DeckBanner") as DeckBanner

func get_deck_list() -> Array:
	var deck_list = []
	for c in $Container.get_children():
		var db = c.get_node("DeckBanner").get_deck_data()
		deck_list.append(db)
	return deck_list

func append(deck_data : DeckData):
	if select:
		var db = get_select_banner()
		db.set_frame_color(Color.white)
	
	var b = Banner.instance()
	var db = b.get_node("DeckBanner").initialize(deck_data)
	b.connect("clicked",self,"_on_Banner_clicked",[db])
	$Container.add_child(b)
	select = b
	db.set_frame_color(Color.red)
	b.grab_focus()

func delete_select():
	$Container.remove_child(select)
	select.queue_free()
	select = null

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
