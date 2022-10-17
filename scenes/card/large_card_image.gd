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
	$Level.self_modulate = color.lightened(0.6)

	$Power/Label.text = str(cd.power)
	$Level/Label.text = str(cd.level)
	$Hit/Label.text = str(cd.hit)
	$Picture.texture = load("res://card_images/"+ cd.image +".png")
	
	var skill_node = $Skills
	for n in skill_node.get_children():
		skill_node.remove_child(n)
		n.queue_free()
	for s_ in cd.skills:
		var line = SkillText.instance()
		var skill_text : String = ""
		
		var s := s_ as SkillData.NamedSkill
		skill_text = Global.card_catalog.get_condition_detailed_string(s.condition)
		skill_text += s.data.name + " (" + Global.card_catalog.get_parameter_string(s) + ")"
		skill_text += ":" + s.text
		
		var richlabel = line.get_node("RichTextLabel")
		richlabel.rect_min_size.x = skill_node.rect_size.x
		var bbc_text := skill_text.replace("{","[color=red]").replace("}","[/color]")
		richlabel.bbcode_text = bbc_text
		var label = line.get_node("Label")
		label.text = skill_text
		label.rect_min_size.x = skill_node.rect_size.x
#		label.text = richlabel.text
		var minsize = label.get_minimum_size()
		line.rect_min_size = minsize
		skill_node.add_child(line)
	return self

