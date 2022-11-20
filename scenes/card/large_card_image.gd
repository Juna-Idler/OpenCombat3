extends Control

const SkillText := preload("large_card_skill_text.tscn")

const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]

func _ready():
	pass
	
func initialize_card(cd : CardData):
	var color = RGB[cd.color]
	$Name/Name.text = cd.name
	self_modulate = color
	$Power.self_modulate = color.darkened(0.2)
	$Hit.self_modulate = color.lightened(0.4)
	$Block.self_modulate = color.lightened(0.4)
	$Level.self_modulate = color.lightened(0.6)

	$Power/Label.text = str(cd.power)
	$Level/Label.text = str(cd.level)
	$Hit/Label.text = str(cd.hit)
	$Block/Label.text = str(cd.block)
	$Picture.texture = load("res://card_images/"+ cd.image +".png")
	
	var skill_node = $Skills
	for n in skill_node.get_children():
		skill_node.remove_child(n)
		n.queue_free()
	for s_ in cd.skills:
		var line = SkillText.instance()
		var skill_text : String = ""
		
		var s := s_ as SkillData.NamedSkill
		skill_text = s.get_string() + ":" + s.text
		
		var richlabel = line.get_node("RichTextLabel")
		richlabel.rect_min_size.x = skill_node.rect_size.x - 32
		var bbc_text := skill_text.replace("{","[color=red]").replace("}","[/color]")
		richlabel.bbcode_text = bbc_text
		var label = line.get_node("Label")
		label.text = skill_text
		label.rect_min_size.x = skill_node.rect_size.x - 32
#		label.text = richlabel.text
		var minsize = label.get_minimum_size()
		line.rect_min_size = minsize
		var left = line.get_node("Left")
		var right = line.get_node("Right")
		
		if s.condition & SkillData.ColorCondition.VS_FLAG:
			right.visible = false
			left.visible = true
			left.self_modulate = RGB[s.condition & SkillData.ColorCondition.COLOR_BITS]
		elif s.condition & SkillData.ColorCondition.LINK_FLAG:
			left.visible = false
			right.visible = true
			right.self_modulate = RGB[s.condition & SkillData.ColorCondition.COLOR_BITS]
		else:
			left.visible = false
			right.visible = false
		
		skill_node.add_child(line)
	return self

