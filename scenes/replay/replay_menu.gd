extends Panel

signal start_pressed(selected)
signal back_pressed()

var selected : ReplayBanner

func _ready():
	pass


func initialize():
	var inv = Global.replay_log_list.list.duplicate()
	inv.invert()
	for i in inv:
		var banner := preload("res://scenes/replay/banner.tscn").instance() as ReplayBanner
		banner.initialize(i)
# warning-ignore:return_value_discarded
		banner.connect("clicked",self,"_on_Banner_clicked",[banner])
		$"%Container".add_child(banner)

func _on_Banner_clicked(banner : ReplayBanner):
	selected = banner
	for i in $"%Container".get_child_count():
		var c = $"%Container".get_child(i)
		if c == banner:
			c.set_frame_color(Color.red)
		else:
			c.set_frame_color(Color.white)
	

func _on_ButtonBack_pressed():
	emit_signal("back_pressed")


func _on_ButtonStart_pressed():
	if selected == null:
		return
	emit_signal("start_pressed",selected)


func _on_ButtonDelete_pressed():
	if selected:
		$PopupDialog/ReplayBanner.initialize(selected.match_log)
		$PopupDialog.show()

func _on_PopupButtonOK_pressed():
	$"%Container".remove_child(selected)
	selected.queue_free()
	selected = null

	var list = []
	for i in $"%Container".get_children():
		list.append(i.match_log)
	list.invert()
	Global.replay_log_list.list = list
	Global.replay_log_list.save_list()
	$PopupDialog.hide()

func _on_PopupButtonCancel_pressed():
	$PopupDialog.hide()
