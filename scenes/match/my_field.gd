extends "res://scenes/match/base_player_field.gd"


func _ready():
	pass


func _disable_play(b:bool):
	$MyHandArea._disable_play(b)

func _set_hand(cards : Array):
	$MyHandArea._set_card(cards)

func _move_hand(sec : float):
	$MyHandArea._move_card(sec)


func _on_MyHandArea_card_clicked(index):
	emit_signal("card_clicked",index)

func _on_MyHandArea_card_decided(index):
	emit_signal("card_decided",index)

func _on_MyHandArea_card_held(index):
	emit_signal("card_held",index)

func _on_MyHandArea_card_order_changed(indexes):
	emit_signal("card_order_changed",indexes)
