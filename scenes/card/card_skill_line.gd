extends Node

class_name CardSkillLine


const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]


func _ready():
	pass

func initialize(skill,rotate:bool):
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
