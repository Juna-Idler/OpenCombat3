extends "res://scripts/clickable_control.gd"


func _ready():
	pass

func show_layer(cd : CardData):
	$LargeCard.initialize_card(cd)
	visible = true
	
func hide_layer():
	visible = false

func _on_Panel_clicked():
	hide_layer()


func _on_LargeCardView_clicked():
	hide_layer()
