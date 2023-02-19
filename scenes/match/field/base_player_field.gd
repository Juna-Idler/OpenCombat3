extends I_PlayerField



func _ready():
	$Name.set_message_translation(false)
	$Name.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)
# warning-ignore-all:return_value_discarded
	$Stock.connect("clicked",self,"emit_signal",["stock_clicked"])
	$Stock.connect("held",self,"emit_signal",["stock_held"])
	$Played.connect("clicked",self,"emit_signal",["played_clicked"])
	$Played.connect("held",self,"emit_signal",["played_held"])
	$Discard.connect("clicked",self,"emit_signal",["discard_clicked"])
	$Discard.connect("held",self,"emit_signal",["discard_held"])
	$States.connect("pressed",self,"emit_signal",["states_clicked"])

	$HandArea.connect("card_clicked",self,"_on_HandArea_card_clicked")
	$HandArea.connect("card_held",self,"_on_HandArea_card_held")
	$HandArea.connect("card_decided",self,"_on_HandArea_card_decided")
	$HandArea.connect("card_order_changed",self,"_on_HandArea_card_order_changed")


func _get_stock_pos() -> Vector2:
	return $Stock.rect_global_position + $Stock.rect_size / 2

func _get_playing_pos() -> Vector2:
	return $Playing.rect_global_position + $Playing.rect_size / 2
	
func _get_played_pos() -> Vector2:
	return $Played.rect_global_position + $Played.rect_size / 2

func _get_discard_pos() -> Vector2:
	return $Discard.rect_global_position + $Discard.rect_size / 2


func _disable_play(b:bool):
	$HandArea._disable_play(b)

func _set_hand(cards : Array):
	$HandArea._set_card(cards)

func _move_hand(sec : float):
	$HandArea._move_card(sec)


func _set_name(name : String):
	$Name.text = name

func _set_damage(damage : int):
	$Damage.text = str(damage) if damage > 0 else ""

func _set_life(life : int):
	$Life.text = str(life)
func _set_life_provisional(life : int):
	$Life.text = str(life)

func _set_stock(stock : int):
	$StockCount.text = str(stock)

func _set_time(time : float,delay : float):
	if time < 0:
		$Timer.text = "∞"
	elif delay < 0:
		$Timer.text = "%.1f" % time
	else:
		$Timer.text = "%s +%.1f" % [int(time),delay]

func _set_states(states : Array):
	$States.set_states(states)


func _on_HandArea_card_clicked(index):
	emit_signal("card_clicked",index)

func _on_HandArea_card_held(index):
	emit_signal("card_held",index)

func _on_HandArea_card_decided(index):
	emit_signal("card_decided",index)

func _on_HandArea_card_order_changed(indexes):
	emit_signal("card_order_changed",indexes)

