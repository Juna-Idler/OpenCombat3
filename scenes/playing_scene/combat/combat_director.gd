class_name CombatDirector



var player1 : PlayingPlayer
var player2 : PlayingPlayer
var overlay : CombatOverlay
var power_balance : CombatPowerBalance
var pb_interface1 : CombatPowerBalance.Interface
var pb_interface2 : CombatPowerBalance.Interface

var p1_skills_list : Node 
var p2_skills_list : Node

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
	pb_interface1 = CombatPowerBalance.Interface.new(power_balance,false)
	pb_interface2 = CombatPowerBalance.Interface.new(power_balance,true)
	p1_skills_list = overlay.get_node("MyControl/SkillContainer")
	p2_skills_list = overlay.get_node("RivalControl/SkillContainer")
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
	

#	tween.parallel()
	power_balance.initial_tween(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.5)


	tween.tween_callback(player1,"change_col_power",[player1.next_effect.power])
	tween.tween_callback(player1,"change_col_hit",[player1.next_effect.hit])
	tween.tween_callback(player1,"change_col_block",[player1.next_effect.block])
	power_balance.set_power_tween_step_by_step(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.3)
	tween.tween_callback(player2,"change_col_power",[player2.next_effect.power])
	tween.tween_callback(player2,"change_col_hit",[player2.next_effect.hit])
	tween.tween_callback(player2,"change_col_block",[player2.next_effect.block])
	power_balance.set_power_tween_step_by_step(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.3)

	tween.tween_callback(self,"set_next_buf_label",["",""])

 # 交戦前タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.Before])
	before_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,player1,player2,pb_interface1)
	before_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,player2,player1,pb_interface2)

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
	
#	tween.tween_interval(0.5)
#	yield(tween,"finished")
#	tween = node.create_tween()

 # 交戦後タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.After])
	after_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	after_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,-situation,player2,player1)

 # ダメージ確定タイミング
	
 # 終了時タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlay.CombatTiming.End])
	end_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	end_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,-situation,player2,player1)

	
	tween.tween_property(overlay,"modulate:a",0.0,0.5)
	tween.parallel()
	tween.tween_property(power_balance,"modulate:a",0.0,0.5)

	yield(tween,"finished")
	
	overlay.visible = false
	power_balance.hide()


var named_skills := NamedSkillPerformer.new()

func before_skills_effect(tween : SceneTreeTween,skills : Array,
		my_control : Node,rival_control : Node,
		vs_color : int,link_color : int,
		myself : PlayingPlayer,rival : PlayingPlayer,
		pb_interface : CombatPowerBalance.Interface):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var time := skill._test_before(s,vs_color,link_color,myself,rival)
		if time > 0.0:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.3,time - 0.6,0.3])
			tween.tween_callback(csl,"move_center",[0.3,time - 0.6,0.3])
			tween.tween_interval(0.3)
			skill._before(tween,s,vs_color,link_color,myself,rival)
			pb_interface.set_power_tween_step_by_step(myself.playing_card.get_current_power(),
					rival.playing_card.get_current_power(),tween,0.3)
		elif time < 0.0:
			time = 0.3 if -time < 0.3 else -time
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.1,time - 0.2,0.1])
			tween.tween_interval(time)
			


func after_skills_effect(tween : SceneTreeTween,skills : Array,
		my_control : Node,rival_control : Node,
		vs_color : int,link_color : int,situation : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var time := skill._test_after(s,vs_color,link_color,situation,myself,rival)
		if time > 0.0:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.3,time - 0.6,0.3])
			tween.tween_callback(csl,"move_center",[0.3,time - 0.6,0.3])
			tween.tween_interval(0.3)
			skill._after(tween,s,vs_color,link_color,situation,myself,rival)
		elif time < 0.0:
			time = 0.3 if -time < 0.3 else -time
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.1,time - 0.2,0.1])
			tween.tween_interval(time)


func end_skills_effect(tween : SceneTreeTween,skills : Array,
		my_control : Node,rival_control : Node,
		vs_color : int,link_color : int,situation : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s := skills[i] as SkillData.NamedSkill
		if not s.test_condition(vs_color,link_color):
			continue
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		var skill := named_skills.get_skill(s.data.id)
		var time := skill._test_end(s,vs_color,link_color,situation,myself,rival)
		if time > 0.0:
			tween.tween_callback(csl,"highlight_flash",[Color.blue,0.3,time - 0.6,0.3])
			tween.tween_callback(csl,"move_center",[0.3,time - 0.6,0.3])
			tween.tween_interval(0.3)
			skill._end(tween,s,vs_color,link_color,situation,myself,rival)
		elif time < 0.0:
			time = 0.3 if -time < 0.3 else -time
			tween.tween_callback(csl,"highlight_flash",[Color.red,0.1,time - 0.2,0.1])
			tween.tween_interval(time)

