extends I_PlayerField



func _ready():
	$Name.set_message_translation(false)
	$Name.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)


func _get_stock_pos() -> Vector2:
	return $Stock.rect_global_position + $Stock.rect_size / 2

func _get_playing_pos() -> Vector2:
	return $Playing.rect_global_position + $Playing.rect_size / 2
	
func _get_played_pos() -> Vector2:
	return $Played.rect_global_position + $Played.rect_size / 2

func _get_discard_pos() -> Vector2:
	return $Discard.rect_global_position + $Discard.rect_size / 2

func _set_name(name : String):
	$Name.text = name

func _set_damage(damage : int):
	$Damage.text = str(damage) if damage > 0 else ""

func _set_life(life : int):
	$Life.text = str(life)
	
func _set_time(time : float,delay : float):
	if time < 0:
		$Timer.text = "∞"
	elif delay < 0:
		$Timer.text = "%.1f" % time
	else:
		$Timer.text = "%s +%.1f" % [int(time),delay]

func _set_states(states : Array):
	$States.set_states(states)



func _on_Stock_clicked():
	emit_signal("stock_clicked")

func _on_Stock_held():
	emit_signal("stock_held")


func _on_Played_clicked():
	emit_signal("played_clicked")

func _on_Played_held():
	emit_signal("played_held")


func _on_Discard_clicked():
	emit_signal("discard_clicked")

func _on_Discard_held():
	emit_signal("discard_held")


func _on_States_pressed():
	emit_signal("states_clicked")
