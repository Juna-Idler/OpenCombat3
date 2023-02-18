extends "res://scenes/match/base_player_field.gd"


func _ready():
	pass

func _set_hand(cards : Array):
	$RivalHandArea._set_card(cards)

func _move_hand(sec : float):
	$RivalHandArea._move_card(sec)


func _on_RivalHandArea_card_clicked(index):
	emit_signal("card_clicked",index)
	pass # Replace with function body.


func _on_RivalHandArea_card_held(index):
	emit_signal("card_held",index)
	pass # Replace with function body.
