extends Control


const ATTENTION_COLOR_CODE := "#B00"

const ATTENTION_BBC := "[color=" + ATTENTION_COLOR_CODE + "]%s[/color]"
const BRACKETS_PARAMETER_BBC := "(" + ATTENTION_BBC + ")"

func _ready():
	pass


func initialize(skill : CatalogData.CardSkill,width : int):
	
	var skill_name := skill.data.name + ("" if skill.parameter.empty()
			else BRACKETS_PARAMETER_BBC % skill.get_parameter_string())
	var skill_text := skill.text
	for i in skill.parameter:
		var param_text = i.name
		skill_text = skill_text.replace("{%s}" % param_text,ATTENTION_BBC % param_text)
	for i in skill.data.states:
		var state := Global.card_catalog.get_state_data(i)
		skill_text = skill_text.replace("{%s}" % state.name,"[url]%s[/url]" % state.name)
	
	var skill_label = $SkillLabel
	skill_label.rect_min_size.x = width - 32
	skill_label.bbcode_text = skill_name + " : " + skill_text
	var left = $SkillLabel/Left
	var right = $SkillLabel/Right
	
	if skill.condition & CatalogData.ColorCondition.VS_FLAG:
		right.visible = false
		left.visible = true
		left.self_modulate = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	elif skill.condition & CatalogData.ColorCondition.LINK_FLAG:
		left.visible = false
		right.visible = true
		right.self_modulate = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	else:
		left.visible = false
		right.visible = false

	var state_label = $StateLabel
	state_label.hide()
	if not skill.data.states.empty():
		state_label.rect_min_size.x = width - 32
		var state_text : PoolStringArray = []
		for i in skill.data.states:
			var state := Global.card_catalog.get_state_data(i)
			var param := "" if state.parameter.empty() else\
					 BRACKETS_PARAMETER_BBC % state.parameter.join(",")
			state_text.append(state.name + param + " : " +
					state.text.replace("{","[color=" + ATTENTION_COLOR_CODE + "]").replace("}","[/color]"))
		state_label.bbcode_text = state_text.join("\n")


func _on_SkillLabel_meta_clicked(_meta : String):
	var state_label = $StateLabel
	if not state_label.text.empty():
		state_label.visible = not state_label.visible
