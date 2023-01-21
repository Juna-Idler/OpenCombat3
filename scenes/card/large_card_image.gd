extends Control

const SkillText := preload("large_card_skill_text.tscn")


func _ready():
	pass
	
func initialize_card(cd : CatalogData.CardData):
	var color = CatalogData.RGB[cd.color]
	$Name/Name.text_input = cd.name if cd.ruby_name.empty() else cd.ruby_name
	self_modulate = color
	$Power.self_modulate = color.darkened(0.2)
	$Hit.self_modulate = color.lightened(0.4)
	$Block.self_modulate = color.lightened(0.4)
	$Level.self_modulate = color.lightened(0.6)

	$PowerLabel.text = str(cd.power)
	$HitLabel.text = str(cd.hit)
	$BlockLabel.text = str(cd.block)
	$LevelLabel.text = str(cd.level)
	$Picture.texture = load("res://card_images/"+ cd.image +".png")
	
	var skill_node = $Skills
	for n in skill_node.get_children():
		skill_node.remove_child(n)
		n.queue_free()
	for s_ in cd.skills:
		var line = SkillText.instance()
		line.initialize(s_,skill_node.rect_size.x)
		skill_node.add_child(line)
	return self

