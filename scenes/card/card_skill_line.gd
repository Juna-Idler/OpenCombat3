extends Node

class_name CardSkillLine


const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]


func _ready():
	pass

func initialize(skill : SkillData.NamedSkill,rotate:bool):
	$Label.text = skill.data.name + "(" + Global.card_catalog.get_parameter_string(skill) + ")"

	if skill.condition & SkillData.ColorCondition.VS_FLAG:
		$ColorRectRight.visible = false
		$ColorRectLeft.visible = true
		$ColorRectLeft.color = RGB[skill.condition & SkillData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_RIGHT if rotate else Label.ALIGN_LEFT
	elif skill.condition & SkillData.ColorCondition.LINK_FLAG:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = true
		$ColorRectRight.color = RGB[skill.condition & SkillData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_LEFT if rotate else Label.ALIGN_RIGHT
	else:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = false
		$Label.align = Label.ALIGN_CENTER
		
	if rotate:
		$Label.rect_rotation = 180
