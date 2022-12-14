extends Control


var data : CardData = null


const CardSkillLine = preload("res://scenes/card/card_skill_line.tscn")


func initialize_card(cd : CardData,rotate := false):
	for c in $Skills.get_children():
		$Skills.remove_child(c)
		c.queue_free()

	data = cd
	if cd == null:
		$PowerLabel.text = ""
		$HitLabel.text = ""
		$BlockLabel.text = ""
		$LevelLabel.text = ""
		$Name.text = ""
		$Picture.texture = null
		$Frame.self_modulate = Color.white
		$Power.self_modulate = Color.white
		$Hit.self_modulate = Color.white
		$Block.self_modulate = Color.white
		return self

	$PowerLabel.text = str(data.power)
	$HitLabel.text = str(data.hit)
	$BlockLabel.text = str(data.block)
	$LevelLabel.text = str(data.level)
	$Name.text = data.name
#	ResourceLoader.load_interactive
	$Picture.texture = load("res://card_images/"+ data.image +".png")
	$Frame.self_modulate = CardData.RGB[data.color]
	$Power.self_modulate = CardData.RGB[data.color].darkened(0.5)
	$Hit.self_modulate = CardData.RGB[data.color].lightened(0.5)
	$Block.self_modulate = CardData.RGB[data.color].lightened(0.5)

	for skill in data.skills:
		var line = CardSkillLine.instance()
		line.initialize(skill,rotate)
		$Skills.add_child(line)
	if rotate:
		rect_rotation = 180
		$Name.rect_rotation = 180
		$PowerLabel.rect_rotation = 180
		$HitLabel.rect_rotation = 180
		$HitLabel.rect_position += Vector2(0,0)
		$BlockLabel.rect_rotation = 180
		$BlockLabel.rect_position += Vector2(0,0)
		$LevelLabel.rect_rotation = 180



func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


