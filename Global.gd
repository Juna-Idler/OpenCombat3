extends Node


var card_catalog := CardCatalog.new()

var deck_list := DeckList.new()

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
