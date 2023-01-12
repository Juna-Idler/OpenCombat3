# warning-ignore-all:return_value_discarded

tool
extends CombatEffectLine

class_name CombatStateLine


export(Vector2) var target_position : Vector2 = Vector2(640,360)

func _ready():
	pass
	
func succeeded():
	var in_time = 0.3
	var duration = 0.5
	var end_time = 0.2
	var origin = global_position
	var color = Color.blue
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"global_position",target_position,in_time)
	tween.parallel().tween_property($Highlight,"modulate",color,in_time)
	tween.tween_interval(duration)
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(self,"modulate:a",0.0,end_time)
	tween.parallel().tween_property($Highlight,"modulate",Color.black,end_time)
	tween.tween_property(self,"global_position",origin,0)
	tween.tween_property(self,"modulate:a",1.0,0.5)

func failed():
	var color = Color.red
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Highlight,"modulate",color,0.2)
	tween.tween_interval(0.6)
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property($Highlight,"modulate",Color.black,0.2)


func set_state(state : MatchEffect.IState):
	$Highlight.modulate = Color.black
	$Background/Label.text = state._get_caption()
	$Background/Label.align = Label.ALIGN_CENTER
	$Background/Invalid.visible = false


