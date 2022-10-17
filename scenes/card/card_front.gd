extends Control


class_name CardFront

var data : CardData = null


const CardSkillLine = preload("card_skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

const format_pattern := ["  %s","[center]%s[/center]","[right]%s    [/right]"]
const rotate_format_pattern := ["[right]%s   [/right]","[center]%s[/center]","   %s"]

func initialize_card(cd : CardData,rotate := false) -> CardFront:
	data = cd
	$Power/Label.text = str(cd.power)
	$Hit/Label.text = str(cd.hit)
	$Block/Label.text = str(cd.block)
	$Level/Label.text = str(cd.level)
	$Name.text = cd.name
	$Picture.hint_tooltip = cd.text
#	ResourceLoader.load_interactive
	$Picture.texture = load("res://card_images/"+ cd.image +".png")
	$Frame.self_modulate = RGB[cd.color]
	$Power.self_modulate = RGB[cd.color].darkened(0.5)
	$Hit.self_modulate = RGB[cd.color].lightened(0.5)
	$Block.self_modulate = RGB[cd.color].lightened(0.5)

	var skill_node = $Skills
	for c in skill_node.get_children():
		skill_node.remove_child(c)
		c.queue_free()
	for skill in cd.skills:
		var line = CardSkillLine.instance()
		line.initialize(skill,rotate)
		skill_node.add_child(line)
	if rotate:
		rect_rotation = 180
		$Name/.rect_rotation = 180
		$Power/Label.rect_rotation = 180
		$Hit/Label.rect_rotation = 180
		$Hit/Label.rect_position += Vector2(0,6)
		$Block/Label.rect_rotation = 180
		$Block/Label.rect_position += Vector2(0,6)
		$Level/Label.rect_rotation = 180

	return self


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


