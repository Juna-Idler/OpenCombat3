extends Control

class_name I_HandArea

# warning-ignore-all:unused_signal
signal card_clicked(index)
signal card_held(index)

signal card_order_changed(indexes) # PoolIntArray
signal card_decided(index)


func _set_card(_cards : Array):
	pass

func _move_card(_sec : float):
	pass

func _disable_play(_b:bool):
	pass

