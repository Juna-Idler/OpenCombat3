extends CanvasLayer


signal decided_card(index,hands)
signal held_card(card)
signal clicked_my_hand_card(index)
signal clicked_rival_hand_card(index)

var my_data : PlayingSceneData.Player
var rival_data : PlayingSceneData.Player

func _ready():
#	$MyField/Stack.hold_timer = $Timer
#	$MyField/Played.hold_timer = $Timer
#	$MyField/Discard.hold_timer = $Timer
#	$RivalField/Stack.hold_timer = $Timer
#	$RivalField/Played.hold_timer = $Timer
#	$RivalField/Discard.hold_timer = $Timer
	pass


func _on_HandArea_decided_card(index, hands):
	emit_signal("decided_card",index,hands)


func _on_held_card(card):
	emit_signal("held_card",card)


func _on_MyHandArea_held_card(_index, card):
	emit_signal("held_card",card)
	
func _on_RivalHandArea_held_card(_index, card):
	emit_signal("held_card",card)


func _on_MyHandArea_clicked_card(index, _card):
	emit_signal("clicked_my_hand_card",index)

func _on_RivalHandArea_clicked_card(index, _card):
	emit_signal("clicked_rival_hand_card",index)

