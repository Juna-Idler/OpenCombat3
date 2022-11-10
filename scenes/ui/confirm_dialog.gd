extends PopupDialog

signal ok_pressed()

export var message : String
export var ok_text : String

func set_message(value):
	message = value
	$Label.text = value

func set_ok_text(value):
	ok_text = value
	$ButtonOK.text = value

func _ready():
	$Label.text = message
	$ButtonOK.text = ok_text

func _on_ButtonCancel_pressed():
	hide()

func _on_ButtonOK_pressed():
	emit_signal("ok_pressed")
	hide()
