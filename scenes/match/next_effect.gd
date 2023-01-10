tool

class_name NextEffectLabel

extends Label

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout



func set_effect(effect : CardData.Stats):
	text = Global.card_catalog.stats_names.get_short_effect_string(effect)

func set_opponent_layout(value):
	opponent_layout = value
	if value:
		align = Label.ALIGN_RIGHT
		valign = Label.VALIGN_TOP
	else:
		align = Label.ALIGN_LEFT
		valign = Label.VALIGN_BOTTOM

func _ready():
	text = ""
	pass
