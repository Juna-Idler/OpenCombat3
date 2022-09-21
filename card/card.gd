extends Node2D

class_name Card

var id_in_deck:int

var data : CardData = null

var affected := Affected.new()
class Affected:
	var power : int = 0
	var hit : int = 0
	var damage : int = 0
	var rush : int = 0



const skillline = preload("res://card/skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

func initialize_scene(id:int,cd : CardData):
	id_in_deck = id
	data = cd
	get_node("CardBase/Power/Label").text = str(cd.power)
	get_node("CardBase/Hit/Label").text = str(cd.hit)
	get_node("CardBase/NameBack/Level/Label").text = str(cd.level)
	get_node("CardBase").self_modulate = RGB[cd.color]
	$CardBase/NameBack/Name.text = cd.name
	$CardBase/Picture.hint_tooltip = cd.text
	var skill_node = get_node("CardBase/Picture/Skills")
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
		var format : String = ""
		match condition:
			SkillData.ColorCondition.VS_RED:
				line.left_color = SkillLine.Color3.RED
				format = "  %s"
			SkillData.ColorCondition.VS_GREEN:
				line.left_color = SkillLine.Color3.GREEN
				format = "  %s"
			SkillData.ColorCondition.VS_BLUE:
				line.left_color = SkillLine.Color3.BLUE
				format = "  %s"
			SkillData.ColorCondition.LINK_RED:
				line.right_color = SkillLine.Color3.RED
				format = "[right]%s  [/right]"
			SkillData.ColorCondition.LINK_GREEN:
				line.right_color = SkillLine.Color3.GREEN
				format = "[right]%s  [/right]"
			SkillData.ColorCondition.LINK_BLUE:
				line.right_color = SkillLine.Color3.BLUE
				format = "[right]%s  [/right]"
			SkillData.ColorCondition.NOCONDITION:
				format = "[center]%s[/center]"
		line.bbc_text = format % skill_text
		skill_node.add_child(line)
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
	
