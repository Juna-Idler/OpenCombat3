extends Node


var card_catalog := CardCatalog.new()


var deck_list_newbie := DeckList.new("user://deck_newbie.tsv")
var deck_list_hotdogger

func _init():
	if deck_list_newbie.list.empty():
		deck_list_newbie.list.append(DeckData.new("デフォルトデッキ",[1,2,3,4,5,6,7,8,9,10,11,12,19,20,21],[]))

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	pass

func _unhandled_input(event):
	var key := event as InputEventKey
	if key and key.scancode == KEY_P and key.pressed:
		get_tree().paused = !get_tree().paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
