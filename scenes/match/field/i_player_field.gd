extends Node

class_name I_PlayerField


# warning-ignore-all:unused_signal
signal card_clicked(index)
signal card_held(index)
signal card_decided(index)
signal card_order_changed(indexes)

signal stock_clicked()
signal stock_held()

signal played_clicked()
signal played_held()

signal discard_clicked()
signal discard_held()

signal states_clicked()


func _get_stock_pos() -> Vector2:
	return Vector2.ZERO

func _get_playing_pos() -> Vector2:
	return Vector2.ZERO

func _get_played_pos() -> Vector2:
	return Vector2.ZERO

func _get_discard_pos() -> Vector2:
	return Vector2.ZERO


func _disable_play(_b:bool):
	pass

func _set_hand(_cards : Array):
	pass

func _move_hand(_sec : float):
	pass


func _set_name(_name : String):
	pass

func _set_damage(_damage : int):
	pass

func _set_life(_life : int):
	pass

func _set_stock(_stock : int):
	pass

func _set_time(_time : float,_delay : float):
	pass

func _set_states(_states : Array):
	pass

				 
