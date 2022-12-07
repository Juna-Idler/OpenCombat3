extends Control

signal returned()

onready var list := $ItemList

func _ready():
	for i in Global.game_settings.online_servers:
		list.add_item(i)
	list.select(Global.game_settings.server_index)


func _on_ItemList_item_selected(index):
	Global.game_settings.server_index = index


func _on_ButtonAdd_pressed():
	var add = $LineEdit.text
	list.add_item(add)
	Global.game_settings.online_servers.append(add)

func _on_ButtonDelete_pressed():
	var count = list.get_item_count()
	if count <= 1:
		return
	var items = list.get_selected_items()
	if items.empty():
		return
	var index = items[0]
	list.remove_item(index)
	Global.game_settings.online_servers.pop_at(index)
	
	if items[0] == count - 1:
		index -= 1
	list.select(index)
	Global.game_settings.server_index = index


func _on_BackButton_pressed():
	emit_signal("returned")

