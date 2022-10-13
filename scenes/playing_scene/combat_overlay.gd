extends Control

class_name CombatOverlay

const CombatSkill = preload("./combat_skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

onready var my_skills_list := $MyControl/SkillContainer
onready var rival_skills_list := $RivalControl/SkillContainer

func _ready():
	pass

func initialize(myself : PlayingPlayer,rival : PlayingPlayer):
	var my_card := myself.deck_list[myself.playing_card_id] as Card
	var rival_card := rival.deck_list[rival.playing_card_id] as Card
	$MyControl/TotalPower.text = str(my_card.get_current_power())
	$MyControl/TotalHit.text = str(my_card.get_current_hit())
	$MyControl/CardFront/Picture.texture = load("res://card_images/"+ my_card.front.data.image +".png")
	$MyControl/CardFront/Name.text = my_card.front.data.name
	$MyControl/CardFront/Frame.self_modulate = RGB[my_card.front.data.color]

	$RivalControl/TotalPower.text = str(rival_card.get_current_power())
	$RivalControl/TotalHit.text = str(rival_card.get_current_hit())
	$RivalControl/CardFront/Picture.texture = load("res://card_images/"+ rival_card.front.data.image +".png")
	$RivalControl/CardFront/Name.text = rival_card.front.data.name
	$RivalControl/CardFront/Frame.self_modulate = RGB[rival_card.front.data.color]

	$MyControl/NextBuf.text = "力+" + str(myself.next_effect.power) if myself.next_effect.power != 0 else ""
	$RivalControl/NextBuf.text = "力+" + str(rival.next_effect.power) if rival.next_effect.power != 0 else ""

	$MyControl/TotalPower.rect_scale = Vector2(1.0,1.0)
	$RivalControl/TotalPower.rect_scale = Vector2(1.0,1.0)


	if my_card.front.data.skills.empty():
		my_skills_list.visible = false
	else:
		my_skills_list.visible = true
		for i in my_card.front.data.skills.size():
			var cs := my_skills_list.get_children()[i] as CombatSkillLine
			cs.initialize(my_card.front.data.skills[i],false)
			cs.show()
		for i in range(my_card.front.data.skills.size(),4):
			var cs := my_skills_list.get_children()[i] as CombatSkillLine
			cs.hide()
		my_skills_list.layout()
	
	if rival_card.front.data.skills.empty():
		rival_skills_list.visible = false
	else:
		rival_skills_list.visible = true
		for i in rival_card.front.data.skills.size():
			var cs = rival_skills_list.get_children()[i] as CombatSkillLine
			cs.initialize(rival_card.front.data.skills[i],true)
			cs.show()
		for i in range(rival_card.front.data.skills.size(),4):
			var cs := rival_skills_list.get_children()[i] as CombatSkillLine
			cs.hide()
		rival_skills_list.layout()

func set_label_text(node : Label,text : String):
	node.text =  text


func clear_next_buf():
	$MyControl/NextBuf.text =  ""
	$RivalControl/NextBuf.text = ""
	

