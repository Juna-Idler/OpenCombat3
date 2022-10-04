extends Panel


class_name RawCard

var data : CardData = null


const skillline = preload("skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

const format_pattern := ["  %s","[center]%s[/center]","[right]%s    [/right]"]
const rotate_format_pattern := ["[right]%s   [/right]","[center]%s[/center]","   %s"]

func initialize_card(cd : CardData,rotate := false) -> RawCard:
	data = cd
	$Power/Label.text = str(cd.power)
	$Hit/Label.text = str(cd.hit)
	$Level/Label.text = str(cd.level)
	$Name/Label.text = cd.name
	$Picture.hint_tooltip = cd.text
#	ResourceLoader.load_interactive
	$Picture.texture = load("res://card_images/"+ cd.image +".png")
	self_modulate = RGB[cd.color]
	$Power.self_modulate = RGB[cd.color].darkened(0.5)
	$Hit.self_modulate = RGB[cd.color].lightened(0.5)

	var skill_node = $Picture/Skills
	for c in skill_node.get_children():
		skill_node.remove_child(c)
		c.queue_free()
	for skill in cd.skills:
		var line = skillline.instance()
		var condition : int = 0
		var skill_text : String = ""
		if skill is SkillData.NormalSkill:
			var n := skill as SkillData.NormalSkill
			condition = n.condition
			skill_text = _get_normal_skill_string(n)
		elif skill is SkillData.NamedSkill:
			var n := skill as SkillData.NamedSkill
			condition = n.condition
			skill_text = n.name + " (" + _get_parameter_string(n.param_type,n.parameter) + ")"
		line.left_color = SkillLine.Color3.NOCOLOR
		line.right_color = SkillLine.Color3.NOCOLOR
		var align : int
		match condition:
			SkillData.ColorCondition.VS_RED:
				line.left_color = SkillLine.Color3.RED
				align = 0
			SkillData.ColorCondition.VS_GREEN:
				line.left_color = SkillLine.Color3.GREEN
				align = 0
			SkillData.ColorCondition.VS_BLUE:
				line.left_color = SkillLine.Color3.BLUE
				align = 0
			SkillData.ColorCondition.LINK_RED:
				line.right_color = SkillLine.Color3.RED
				align = 2
			SkillData.ColorCondition.LINK_GREEN:
				line.right_color = SkillLine.Color3.GREEN
				align = 2
			SkillData.ColorCondition.LINK_BLUE:
				line.right_color = SkillLine.Color3.BLUE
				align = 2
			SkillData.ColorCondition.NOCONDITION:
				align = 1
		var format : String = (rotate_format_pattern if rotate else format_pattern)[align]
		line.bbc_text = format % skill_text
		if rotate:
			line.get_node("RichTextLabel").rect_rotation = 180		
		skill_node.add_child(line)
	if rotate:
		rect_rotation = 180
		$Name/.rect_rotation = 180
		$Power.rect_rotation = 180
		$Hit/Label.rect_rotation = 180
		$Hit/Label.rect_position += Vector2(4,8)
		$Level.rect_rotation = 180

	return self


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


static func _get_parameter_string(param_type : int,parameter) -> String:
	match param_type:
		SkillData.NamedSkill.ParamType.INTEGER:
			return String(parameter)
		SkillData.NamedSkill.ParamType.EFFECTS:
			var result : PoolStringArray = []
			for e_ in (parameter as NormalSkillEffects).effects:
				var e := e_ as NormalSkillEffects.Effect
				var attribute_string = Global.card_catalog.get_effect_attribute_string(e.attribute)
				result.append(attribute_string + "%+d" % e.parameter)
			return result.join(" ")
		SkillData.NamedSkill.ParamType.VOID:
			pass
	return ""

static func _get_normal_skill_string(skill:SkillData.NormalSkill) -> String:
	var string : String = ""
	string += ["","","後","優","劣","互","終"][skill.timing]
	for t_ in skill.targets:
		string += " "
		var t := t_ as SkillData.NormalSkill.Target
		string += ["","","敵","両"][t.target_player]
		string += ["","","次","一","全"][t.target_card]
		string += ["","赤","緑","青"][t.target_color]
		
		var effects : PoolStringArray = []
		for e_ in t.effects.effects:
			var e := e_ as NormalSkillEffects.Effect
			var attribute_string = Global.card_catalog.get_effect_attribute_string(e.attribute)
			effects.append(attribute_string + "%+d" % e.parameter)
		string += "[" + effects.join(" ") + "]"
	return string
	
