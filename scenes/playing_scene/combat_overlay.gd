extends Control


const CombatSkill = preload("./combat_skill_line.tscn")

onready var my_skills_list := $MyControl/SkillContainer/SkillList
onready var rival_skills_list := $RivalControl/SkillContainer/SkillList

func _ready():
	$RivalControl/SkillContainer/SkillList.rect_rotation = 180
	pass


func perform(myself : PlayingPlayer,rival : PlayingPlayer):
	var my_card := myself.deck_list[myself.playing_card_id] as Card
	var rival_card := rival.deck_list[rival.playing_card_id] as Card
	$MyControl/TotalPower.text = str(my_card.get_current_power())
	$MyControl/TotalHit.text = str(my_card.get_current_hit())
	$MyControl/Picture.texture = load("res://card_images/"+ my_card.front.data.image +".png")
	
	$RivalControl/TotalPower.text = str(rival_card.get_current_power())
	$RivalControl/TotalHit.text = str(rival_card.get_current_hit())
	$RivalControl/Picture.texture = load("res://card_images/"+ rival_card.front.data.image +".png")
	

	for c in my_skills_list.get_children():
		my_skills_list.remove_child(c)
		c.queue_free()

	
	if my_card.front.data.skills.empty():
		$MyControl/SkillContainer.visible = false
	else:
		$MyControl/SkillContainer.visible = true
		for s in my_card.front.data.skills:
			var cs = CombatSkill.instance()
			cs.initialize(s,false)
			my_skills_list.add_child(cs)
	
	for c in rival_skills_list.get_children():
		rival_skills_list.remove_child(c)
		c.queue_free()

	if rival_card.front.data.skills.empty():
		$RivalControl/SkillContainer.visible = false
	else:
		$RivalControl/SkillContainer.visible = true
		for s in rival_card.front.data.skills:
			var cs = CombatSkill.instance()
			cs.initialize(s,true)
			rival_skills_list.add_child(cs)
	
	
	modulate = Color(1,1,1,0)
	visible = true
	var tween := create_tween()
	tween.chain()
	tween.tween_property(self,"modulate:a",1.0,0.5)
	
	
	for i in my_card.front.data.skills.size():
		my_card.front.data.skills[i]
		var csl := my_skills_list.get_children()[i] as CombatSkillLine
		tween.tween_callback(csl,"highlight_flash")

	for i in rival_card.front.data.skills.size():
		rival_card.front.data.skills[i]
		var csl := rival_skills_list.get_children()[i] as CombatSkillLine
		tween.tween_callback(csl,"highlight_flash")

#	tween.tween_callback()
	
	tween.tween_interval(1)
	tween.tween_property(self,"modulate:a",0.0,0.5)

	yield(tween,"finished")
	
	visible = false

