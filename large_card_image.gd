extends Node2D

const SkillText := preload("res://large_card_skill_text.tscn")

const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]

func _ready():
	var cd := Global.card_catalog.get_card_data(17)
	initialize_card(cd)
	pass
	
func initialize_card(cd : CardData):
	var color = RGB[cd.color]
	$CardBase/Name/Name.text = cd.name
	$CardBase.self_modulate = color
	$CardBase/Power.self_modulate = color.darkened(0.2)
	$CardBase/Hit.self_modulate = color.lightened(0.4)
	$CardBase/Level.self_modulate = color.lightened(0.6)

	$CardBase/Power/Label.text = str(cd.power)
	$CardBase/Level/Label.text = str(cd.level)
	$CardBase/Hit/Label.text = str(cd.hit)
	$CardBase/Picture.texture = load("res://card_images/"+ cd.image +".png")
	
	var skill_node = $CardBase/Skills
	for skill in cd.skills:
		var line = SkillText.instance()
		var skill_text : String = ""
		if skill is SkillData.NormalSkill:
			var n := skill as SkillData.NormalSkill
			skill_text = _get_condition_string(n.condition)
			skill_text += _get_normal_skill_string(n)
		elif skill is SkillData.NamedSkill:
			var n := skill as SkillData.NamedSkill
			skill_text = _get_condition_string(n.condition)
			skill_text += n.name + " (" + _get_parameter_string(n.param_type,n.parameter) + ")"
			skill_text += ":" + n.text
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

static func _get_condition_string(condition : int) -> String:
	return ["","赤と対決 ","緑と対決 ","青と対決 ","赤と連携 ","緑と連携 ","青と連携 "][condition]

static func _get_normal_skill_string(skill:SkillData.NormalSkill) -> String:
	var string : String = ""
	string += ["","判定前","判定後","優勢後","劣勢後","互角後","終了時"][skill.timing]
	for t_ in skill.targets:
		string += " "
		var t := t_ as SkillData.NormalSkill.Target
		if (t.target_player == SkillData.TargetPlayer.MYSELF and
				t.target_card == SkillData.TargetCard.PLAYED_CARD):
			string += "このカードに"
		else:
			string += ["","自分の","相手の","両者の"][t.target_player]
			string += ["","赤の","緑の","青の"][t.target_color]
			string += ["","戦闘カードに","次に出すカードに","手札一枚に","手札全てに"][t.target_card]
		
		var effects : PoolStringArray = []
		for e_ in t.effects.effects:
			var e := e_ as NormalSkillEffects.Effect
			var attribute_string = Global.card_catalog.get_effect_attribute_string(e.attribute)
			effects.append(attribute_string + "%+d" % e.parameter)
		string += "[" + effects.join(" ") + "]"
	return string
