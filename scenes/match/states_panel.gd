tool
extends Control

class_name StatesPanel

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout

func set_opponent_layout(value):
	opponent_layout = value
	if opponent_layout:
		$Label.align = Label.ALIGN_RIGHT
		$Label.valign = Label.VALIGN_TOP
		$Label.grow_vertical = Control.GROW_DIRECTION_END
	else:
		$Label.align = Label.ALIGN_LEFT
		$Label.valign = Label.VALIGN_BOTTOM
		$Label.grow_vertical = Control.GROW_DIRECTION_BEGIN


func _ready():
	pass

func set_states(states : Array):
	var size := states.size()
	var pool : PoolStringArray = []
	if size > 6:
		pool.resize(6)
		pool[0] = "..."
		for i in range(size - 5,size):
			var state := states[i] as MatchEffect.IState
			pool[i - (size-5) + 1] = state._get_short_caption()
	else:
		pool.resize(size)
		for i in size:
			var state := states[i] as MatchEffect.IState
			pool[i] = state._get_short_caption()
	if opponent_layout:
		pool.invert()
	$Label.text = pool.join("\n")
	
