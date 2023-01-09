# warning-ignore-all:return_value_discarded

tool
extends Node2D

class_name CombatSkillLine


const LONG_MARGIN = 4
const SHORT_MARGIN = 8

const LONG_SIZE = 24
const SHORT_SIZE = 16

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout

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


func highlight_flash(color : Color,in_time : float,duration : float,end_time : float):
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Highlight,"modulate",color,in_time)
	tween.tween_interval(duration)
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property($Highlight,"modulate",Color.black,end_time)

func move_and_remove(in_time : float,duration : float,end_time : float):
	var origin = global_position
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"global_position",target_position,in_time)
	tween.tween_interval(duration)
	tween.tween_property(self,"modulate:a",0.0,end_time)
	tween.tween_property(self,"global_position",origin,0)
	tween.tween_property(self,"modulate:a",1.0,0.5)


func set_skill(skill : SkillData.NamedSkill,vs_color:int,link_color:int):
	$Highlight.modulate = Color.black
	$Background/Label.text = skill.get_short_string()

	if skill.condition & SkillData.ColorCondition.VS_FLAG:
		$Background/ColorRectRight.visible = false
		$Background/ColorRectLeft.visible = true
		var color : int = skill.condition & SkillData.ColorCondition.COLOR_BITS
		$Background/ColorRectLeft.color = CardData.RGB[color]
		$Background/Label.align = Label.ALIGN_RIGHT if opponent_layout else Label.ALIGN_LEFT
		$Background/Invalid.visible = (color != vs_color)
	elif skill.condition & SkillData.ColorCondition.LINK_FLAG:
		$Background/ColorRectLeft.visible = false
		$Background/ColorRectRight.visible = true
		var color : int = skill.condition & SkillData.ColorCondition.COLOR_BITS
		$Background/ColorRectRight.color = CardData.RGB[color]
		$Background/Label.align = Label.ALIGN_LEFT if opponent_layout else Label.ALIGN_RIGHT
		$Background/Invalid.visible = (color != link_color)
	else:
		$Background/ColorRectLeft.visible = false
		$Background/ColorRectRight.visible = false
		$Background/Label.align = Label.ALIGN_CENTER
		$Background/Invalid.visible = false


func set_opponent_layout(value):
	opponent_layout = value
	var left = $Background/ColorRectLeft
	var right = $Background/ColorRectRight
	if opponent_layout:
		left.anchor_left = 1.0
		left.anchor_right = 1.0
		left.anchor_top = 1.0
		left.anchor_bottom = 1.0
		left.margin_left = -(SHORT_MARGIN + SHORT_SIZE)
		left.margin_top = -(LONG_MARGIN + LONG_SIZE)
		left.margin_right = -SHORT_MARGIN
		left.margin_bottom = -LONG_MARGIN

		right.anchor_left = 0
		right.anchor_right = 0
		right.anchor_top = 0
		right.anchor_bottom = 0
		right.margin_left = LONG_MARGIN
		right.margin_top = SHORT_MARGIN
		right.margin_right = LONG_MARGIN + LONG_SIZE
		right.margin_bottom = SHORT_MARGIN + SHORT_SIZE
	else:
		left.anchor_left = 0.0
		left.anchor_right = 0.0
		left.anchor_top = 0.0
		left.anchor_bottom = 0.0
		left.margin_left = SHORT_MARGIN
		left.margin_top = LONG_MARGIN
		left.margin_right = SHORT_MARGIN + SHORT_SIZE
		left.margin_bottom = LONG_MARGIN + LONG_SIZE

		right.anchor_left = 1.0
		right.anchor_right = 1.0
		right.anchor_top = 1.0
		right.anchor_bottom = 1.0
		right.margin_left = -(LONG_MARGIN + LONG_SIZE)
		right.margin_top = -(SHORT_MARGIN + SHORT_SIZE)
		right.margin_right = -LONG_MARGIN
		right.margin_bottom = -SHORT_MARGIN
