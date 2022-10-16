extends Control

class_name CombatSkillLine

const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]

const left_margin_left = 8
const left_margin_right = 288

const right_margin_left = 284
const right_margin_right = 4


func _ready():
	pass

func highlight_flash(color : Color,in_time : float,duration : float,end_time : float):
	$Highlight.modulate = color
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Highlight,"modulate:a",1.0,in_time)
	tween.tween_interval(duration)
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property($Highlight,"modulate:a",0.0,end_time)

func move_center(in_time : float,duration : float,end_time : float):
	var origin_y = rect_global_position.y
	var tween := create_tween()
	tween.tween_property(self,"rect_global_position:y",360.0-16.0,in_time)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(duration)
	tween.tween_property(self,"modulate:a",0.0,end_time)
	tween.tween_property(self,"rect_global_position:y",origin_y,0)
	tween.tween_property(self,"modulate:a",1.0,0.5)
	

func initialize(skill : SkillData.NamedSkill,vs_color:int,link_color:int,rotate:bool):
	$Highlight.modulate.a = 0
	$Label.text = skill.data.name + " (" + Global.card_catalog.get_parameter_string(skill) + ")"

	if skill.condition & SkillData.ColorCondition.VS_FLAG:
		$ColorRectRight.visible = false
		$ColorRectLeft.visible = true
		var color : int = skill.condition & SkillData.ColorCondition.COLOR_BITS
		$ColorRectLeft.color = RGB[color]
		$Label.align = Label.ALIGN_RIGHT if rotate else Label.ALIGN_LEFT
		$Invalid.visible = (color != vs_color)
	elif skill.condition & SkillData.ColorCondition.LINK_FLAG:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = true
		var color : int = skill.condition & SkillData.ColorCondition.COLOR_BITS
		$ColorRectRight.color = RGB[color]
		$Label.align = Label.ALIGN_LEFT if rotate else Label.ALIGN_RIGHT
		$Invalid.visible = (color != link_color)
	else:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = false
		$Label.align = Label.ALIGN_CENTER
		$Invalid.visible = false
		
	if rotate:
		$ColorRectLeft.margin_left = left_margin_right
		$ColorRectLeft.margin_right = -left_margin_left
		$ColorRectRight.margin_left = right_margin_right
		$ColorRectRight.margin_right = -right_margin_left
	else:
		$ColorRectLeft.margin_left = left_margin_left
		$ColorRectLeft.margin_right = -left_margin_right
		$ColorRectRight.margin_left = right_margin_left
		$ColorRectRight.margin_right = -right_margin_right




