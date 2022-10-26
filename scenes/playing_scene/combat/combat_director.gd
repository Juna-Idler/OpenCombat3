class_name CombatDirector



var player1 : PlayingPlayer
var player2 : PlayingPlayer
var overlay : CombatOverlay
var power_balance : CombatPowerBalance

var p1_objects : CombatObjects 
var p2_objects : CombatObjects

var p1_next_buf_label : Label
var p2_next_buf_label : Label

func set_next_buf_label(p1_text : String,p2_text : String):
	p1_next_buf_label.text = p1_text
	p2_next_buf_label.text = p2_text
	

func initialize(p1 : PlayingPlayer,p2 : PlayingPlayer,
		ol : CombatOverlay,pb : CombatPowerBalance,
		p1_nbl : Label,p2_nbl : Label):
	player1 = p1
	player2 = p2
	overlay = ol
	power_balance = pb
	p1_objects = overlay.my_objects
	p2_objects = overlay.rival_objects
	p1_next_buf_label = p1_nbl
	p2_next_buf_label = p2_nbl
	
	overlay.change_timing_label(CombatOverlay.CombatTiming.NoTiming)


func perform(node : Node):
	overlay.initialize(player1,player2)
	var p1_card := player1.deck_list[player1.playing_card_id] as Card
	var p2_card := player2.deck_list[player2.playing_card_id] as Card
	var p1_link_color := 0 if player1.played.empty() else\
			 player1.deck_list[player1.played.back()].front.data.color
	var p2_link_color := 0 if player2.played.empty() else\
			 player2.deck_list[player2.played.back()].front.data.color

	overlay.modulate = Color(1,1,1,0)
	overlay.visible = true
	power_balance.modulate = Color(1,1,1,0)
	power_balance.visible = true
	var tween := node.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_property(power_balance,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_callback(power_balance,"initial_tween",[p1_card.get_current_power(),p2_card.get_current_power(),0.5])
	tween.tween_interval(0.5)


	tween.tween_callback(player1,"change_col_power",[player1.next_effect.power])
	tween.tween_callback(player1,"change_col_hit",[player1.next_effect.hit])
	tween.tween_callback(player1,"change_col_block",[player1.next_effect.block])
	if player1.next_effect.power != 0:
		tween.tween_interval(0.5)
	tween.tween_callback(player2,"change_col_power",[player2.next_effect.power])
	tween.tween_callback(player2,"change_col_hit",[player2.next_effect.hit])
	tween.tween_callback(player2,"change_col_block",[player2.next_effect.block])
	if player2.next_effect.power != 0:
		tween.tween_interval(0.5)
	tween.tween_interval(0.5)
	
	tween.tween_callback(self,"set_next_buf_label",["",""])
	


 # 交戦前タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.Before])
	before_skills_effect(tween,p1_card.front.data.skills,
			overlay.my_objects,overlay.rival_objects,
			p2_card.front.data.color,p1_link_color,player1,player2)
	before_skills_effect(tween,p2_card.front.data.skills,
			overlay.rival_objects,overlay.my_objects,
			p1_card.front.data.color,p2_link_color,player2,player1)

	tween.tween_interval(0.3)
	yield(tween,"finished")
	tween = node.create_tween()

 # 交戦タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.Engagement])
	var situation := (player1.playing_card.get_current_power()
			- player2.playing_card.get_current_power())
			
	if situation > 0:
		var hit = player1.playing_card.get_current_hit()
		for i in hit:
			player1.combat_avatar.attack(player2,tween)
	elif situation < 0:
		var hit = player2.playing_card.get_current_hit()
		for i in hit:
			player2.combat_avatar.attack(player1,tween)
	
	tween.tween_interval(0.3)

 # 交戦後タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.After])
	after_skills_effect(tween,p1_card.front.data.skills,
			overlay.my_objects,overlay.rival_objects,
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	after_skills_effect(tween,p2_card.front.data.skills,
			overlay.rival_objects,overlay.my_objects,
			p1_card.front.data.color,p2_link_color,-situation,player2,player1)

	tween.tween_interval(0.3)

 # ダメージ確定タイミング
	
 # 終了時タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.End])
	end_skills_effect(tween,p1_card.front.data.skills,
			overlay.my_objects,overlay.rival_objects,
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	end_skills_effect(tween,p2_card.front.data.skills,
			overlay.rival_objects,overlay.my_objects,
			p1_card.front.data.color,p2_link_color,-situation,player2,player1)

	
	tween.tween_property(overlay,"modulate:a",0.0,0.5)
	tween.parallel()
	tween.tween_property(power_balance,"modulate:a",0.0,0.5)

	yield(tween,"finished")
	
	overlay.hide()
	power_balance.hide()


var named_skills := NamedSkillPerformer.new()

func before_skills_effect(tween : SceneTreeTween,skills : Array,
		my_objects : CombatObjects,rival_objects : CombatObjects,
		vs_color : int,link_color : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_objects.skills[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var result := skill._test_before(s,vs_color,link_color,myself,rival)
		if result == NamedSkillPerformer.SkillTestResult.SUCCESSFUL:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(csl.global_position.x,360)
			tween.tween_callback(csl,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._before(tween,s,vs_color,link_color,myself,rival)
		elif result == NamedSkillPerformer.SkillTestResult.FAILED:
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)
			


func after_skills_effect(tween : SceneTreeTween,skills : Array,
		my_objects : CombatObjects,rival_objects : CombatObjects,
		vs_color : int,link_color : int,situation : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_objects.skills[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var result := skill._test_after(s,vs_color,link_color,situation,myself,rival)
		if result == NamedSkillPerformer.SkillTestResult.SUCCESSFUL:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(csl.global_position.x,360)
			tween.tween_callback(csl,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._after(tween,s,vs_color,link_color,situation,myself,rival)
		elif result == NamedSkillPerformer.SkillTestResult.FAILED:
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)


func end_skills_effect(tween : SceneTreeTween,skills : Array,
		my_objects : CombatObjects,rival_objects : CombatObjects,
		vs_color : int,link_color : int,situation : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_objects.skills[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var result := skill._test_end(s,vs_color,link_color,situation,myself,rival)
		if result == NamedSkillPerformer.SkillTestResult.SUCCESSFUL:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(csl.global_position.x,360)
			tween.tween_callback(csl,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._end(tween,s,vs_color,link_color,situation,myself,rival)
		elif result == NamedSkillPerformer.SkillTestResult.FAILED:
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)

