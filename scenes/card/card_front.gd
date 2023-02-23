extends Control


class_name CardFront

var data : CatalogData.CardData = null


const CardSkillLine = preload("card_skill_line.tscn")


func initialize_card(cd : CatalogData.CardData,rotate := false) -> CardFront:
	for c in $Skills.get_children():
		$Skills.remove_child(c)
		c.queue_free()

	data = cd
	if cd == null:
		$SpritePower.frame = 0
		$SpriteHit.frame = 0
		$SpriteBlock.frame = 0
		$SpriteLevel.frame = 0
		$Name.text = ""
		$Picture.texture = null
		$Frame.self_modulate = Color.white
		$Power.self_modulate = Color.white
		$Hit.self_modulate = Color.white
		$Block.self_modulate = Color.white
		return self

	$SpritePower.frame = data.power
	$SpriteHit.frame = data.hit
	$SpriteBlock.frame = data.block
	$SpriteLevel.frame = data.level
	$Name.text = data.name
#	ResourceLoader.load_interactive
	var texture := load(data.image)
	$Picture.texture = texture if texture else null
	$Frame.self_modulate = CatalogData.RGB[data.color]
	$Power.self_modulate = CatalogData.RGB[data.color].darkened(0.5)
	$Hit.self_modulate = CatalogData.RGB[data.color].lightened(0.5)
	$Block.self_modulate = CatalogData.RGB[data.color].lightened(0.5)

	for skill in data.skills:
		var line = CardSkillLine.instance()
		line.initialize(skill,rotate)
		$Skills.add_child(line)
	if rotate:
		rect_rotation = 180
		$Name.rect_rotation = 180
		$SpritePower.rotation_degrees = 180
		$SpriteHit.rotation_degrees = 180
		$SpriteBlock.rotation_degrees = 180
		$SpriteLevel.rotation_degrees = 180

	return self


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


