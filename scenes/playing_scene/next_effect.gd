tool

class_name NextEffectLabel

extends Label

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout


static func _get_effect_short_name(id : int)->String:
	return Global.card_catalog.get_effect_data(id).short_name

func set_effect(effect : Card.Affected):
	var output : PoolStringArray = []
	if opponent_layout:
		if effect.block != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.BLOCK) + "%+d" % effect.block)
		if effect.hit != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.HIT) + "%+d" % effect.hit)
		if effect.power != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.POWER) + "%+d" % effect.power)
	else:
		if effect.power != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.POWER) + "%+d" % effect.power)
		if effect.hit != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.HIT) + "%+d" % effect.hit)
		if effect.block != 0:
			output.append(_get_effect_short_name(EffectData.Attribute.BLOCK) + "%+d" % effect.block)
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
