tool

class_name NextEffectLabel

extends Label

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout



func set_effect(effect : MatchCard.Affected):
	var output : PoolStringArray = []
	if opponent_layout:
		if effect.block != 0:
			output.append(Global.card_catalog.stats_names.short_block + "%+d" % effect.block)
		if effect.hit != 0:
			output.append(Global.card_catalog.stats_names.short_hit + "%+d" % effect.hit)
		if effect.power != 0:
			output.append(Global.card_catalog.stats_names.short_power + "%+d" % effect.power)
	else:
		if effect.power != 0:
			output.append(Global.card_catalog.stats_names.short_power + "%+d" % effect.power)
		if effect.hit != 0:
			output.append(Global.card_catalog.stats_names.short_hit + "%+d" % effect.hit)
		if effect.block != 0:
			output.append(Global.card_catalog.stats_names.short_block + "%+d" % effect.block)
	text = output.join("\n")

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
