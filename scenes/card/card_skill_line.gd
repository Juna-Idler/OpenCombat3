extends Node

class_name CardSkillLine


func _ready():
	pass

func initialize(skill : CatalogData.CardSkill,rotate:bool):
	$Label.text = skill.get_short_string()

	if skill.condition & CatalogData.ColorCondition.VS_FLAG:
		$ColorRectRight.visible = false
		$ColorRectLeft.visible = true
		$ColorRectLeft.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_RIGHT if rotate else Label.ALIGN_LEFT
	elif skill.condition & CatalogData.ColorCondition.LINK_FLAG:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = true
		$ColorRectRight.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
		$Label.align = Label.ALIGN_LEFT if rotate else Label.ALIGN_RIGHT
	else:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = false
		$Label.align = Label.ALIGN_CENTER
		
	if rotate:
		$Label.rect_rotation = 180
