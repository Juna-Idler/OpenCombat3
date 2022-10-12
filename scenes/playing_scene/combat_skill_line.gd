extends Control

class_name CombatSkillLine

const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]



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

func initialize(skill,rotate:bool):
	$Highlight.modulate.a = 0
	var condition : int = 0
	if skill is SkillData.NormalSkill:
		var n := skill as SkillData.NormalSkill
		condition = n.condition
		$Label.text = Global.card_catalog.get_normal_skill_string(n)
	elif skill is SkillData.NamedSkill:
		var n := skill as SkillData.NamedSkill
		condition = n.condition
		$Label.text = n.name + " (" + Global.card_catalog.get_parameter_string(n.param_type,n.parameter) + ")"

	if condition & SkillData.ColorCondition.VS_FLAG:
		$ColorRectRight.visible = false
		$ColorRectLeft.visible = true
		$ColorRectLeft.color = RGB[condition & SkillData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_RIGHT if rotate else Label.ALIGN_LEFT
	elif condition & SkillData.ColorCondition.LINK_FLAG:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = true
		$ColorRectRight.color = RGB[condition & SkillData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_LEFT if rotate else Label.ALIGN_RIGHT
	else:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = false
		$Label.align = Label.ALIGN_CENTER
		
	if rotate:
		$Label.rect_rotation = 180


