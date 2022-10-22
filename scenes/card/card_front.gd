extends Control


class_name CardFront

var data : CardData = null


const CardSkillLine = preload("card_skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

const format_pattern := ["  %s","[center]%s[/center]","[right]%s    [/right]"]
const rotate_format_pattern := ["[right]%s   [/right]","[center]%s[/center]","   %s"]

func initialize_card(cd : CardData,rotate := false) -> CardFront:
	for c in $Skills.get_children():
		$Skills.remove_child(c)
		c.queue_free()

	data = cd
	if cd == null:
		$Power/Label.text = ""
		$Hit/Label.text = ""
		$Block/Label.text = ""
		$Level/Label.text = ""
		$Name.text = ""
		$Picture.hint_tooltip = ""
		#	ResourceLoader.load_interactive
		$Picture.texture = null
		$Frame.self_modulate = Color.white
		$Power.self_modulate = Color.white
		$Hit.self_modulate = Color.white
		$Block.self_modulate = Color.white
		return self

	$Power/Label.text = str(data.power)
	$Hit/Label.text = str(data.hit)
	$Block/Label.text = str(data.block)
	$Level/Label.text = str(data.level)
	$Name.text = data.name
	$Picture.hint_tooltip = data.text
#	ResourceLoader.load_interactive
	$Picture.texture = load("res://card_images/"+ data.image +".png")
	$Frame.self_modulate = RGB[data.color]
	$Power.self_modulate = RGB[data.color].darkened(0.5)
	$Hit.self_modulate = RGB[data.color].lightened(0.5)
	$Block.self_modulate = RGB[data.color].lightened(0.5)

	for skill in data.skills:
		var line = CardSkillLine.instance()
		line.initialize(skill,rotate)
		$Skills.add_child(line)
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


