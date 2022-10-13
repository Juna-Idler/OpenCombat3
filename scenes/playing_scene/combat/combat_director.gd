class_name CombatDirector



var player1 : PlayingPlayer
var player2 : PlayingPlayer
var overlay : CombatOverlay
var power_balance : CombatPowerBalance

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
	p1_skills_list = overlay.get_node("MyControl/SkillContainer")
	p2_skills_list = overlay.get_node("RivalControl/SkillContainer")
	p1_next_buf_label = p1_nbl
	p2_next_buf_label = p2_nbl


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
	power_balance.initial_tween(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.5)

	if player1.next_effect.power != 0 or player2.next_effect.power != 0:
		p1_card.affected.add(player1.next_effect)
		p2_card.affected.add(player2.next_effect)
		tween.tween_callback(overlay,"set_label_text",
				[overlay.get_node("MyControl/TotalPower"),str(p1_card.get_current_power())])
		tween.tween_callback(overlay,"set_label_text",
				[overlay.get_node("RivalControl/TotalPower"),str(p2_card.get_current_power())])
		power_balance.set_power_tween(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.3)

	tween.tween_callback(self,"set_next_buf_label",["",""])

 # 判定前タイミング
	before_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,player1,player2)
	before_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,player2,player1)
	power_balance.set_power_tween(p1_card.get_current_power(),p2_card.get_current_power(),tween,0.3)

	var situation := (player1.get_playing_card().get_current_power()
			- player2.get_playing_card().get_current_power())
	tween.tween_interval(1)

 # 判定後タイミング
	after_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	after_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,situation,player2,player1)
	
 # 終了時タイミング
	end_skills_effect(tween,p1_card.front.data.skills,
			overlay.get_node("MyControl"),overlay.get_node("RivalControl"),
			p2_card.front.data.color,p1_link_color,situation,player1,player2)
	end_skills_effect(tween,p2_card.front.data.skills,
			overlay.get_node("RivalControl"),overlay.get_node("MyControl"),
			p1_card.front.data.color,p2_link_color,situation,player2,player1)

	
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
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s = skills[i]
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		if s is SkillData.NormalSkill:
			var p1 = myself.get_playing_card().get_current_power()
			var p2 = rival.get_playing_card().get_current_power()
			if NormalSkillPerformer.before(tween,s,vs_color,link_color,myself,rival):
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,0.3,0.3])
				tween.tween_callback(csl,"move_center",[0.3,0.3,0.3])
				var np1 = myself.get_playing_card().get_current_power()
				var np2 = rival.get_playing_card().get_current_power()
				if p1 != np1 or p2 != np2:
					var my_tp = my_control.get_node("TotalPower")
					var rival_tp = rival_control.get_node("TotalPower")
					tween.tween_callback(overlay,"set_label_text",[my_tp,str(myself.get_playing_card().get_current_power())])
					tween.tween_callback(overlay,"set_label_text",[rival_tp,str(rival.get_playing_card().get_current_power())])
				tween.tween_interval(1.0)
		elif s is SkillData.NamedSkill:
			var skill := named_skills.get_skill(s.id)
			var time := skill._test_before(s,vs_color,link_color,myself,rival)
			if time > 0.0:
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,time - 0.4,0.3])
				tween.tween_callback(csl,"move_center",[0.1,time - 0.4,0.3])
				skill._before(tween,s,vs_color,link_color,myself,rival)
			elif time < 0.0:
				time = 0.3 if -time < 0.3 else -time
				tween.tween_callback(csl,"highlight_flash",[Color.red,0.1,time - 0.2,0.1])
				tween.tween_interval(time)
			


func after_skills_effect(tween : SceneTreeTween,skills : Array,
		my_control : Node,rival_control : Node,
		vs_color : int,link_color : int,situation : int,
		myself : PlayingPlayer,rival : PlayingPlayer):
	for i in skills.size():
		var s = skills[i]
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		if s is SkillData.NormalSkill:
			if NormalSkillPerformer.after(tween,s,vs_color,link_color,situation,myself,rival):
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,0.6,0.3])
				tween.tween_callback(csl,"move_center",[0.3,0.3,0.3])
				tween.tween_interval(1.0)
		elif s is SkillData.NamedSkill:
			var skill := named_skills.get_skill(s.id)
			var time := skill._test_after(s,vs_color,link_color,situation,myself,rival)
			if time > 0.0:
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,time - 0.4,0.3])
				tween.tween_callback(csl,"move_center",[0.3,time - 0.6,0.3])
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
		var s = skills[i]
		var csl := my_control.get_node("SkillContainer").get_children()[i] as CombatSkillLine
		if s is SkillData.NormalSkill:
			if NormalSkillPerformer.end(tween,s,vs_color,link_color,myself,rival):
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,0.6,0.3])
				tween.tween_callback(csl,"move_center",[0.3,0.3,0.3])
				tween.tween_interval(1.0)
		elif s is SkillData.NamedSkill:
			var skill := named_skills.get_skill(s.id)
			var time := skill._test_end(s,vs_color,link_color,situation,myself,rival)
			if time > 0.0:
				tween.tween_callback(csl,"highlight_flash",[Color.blue,0.1,time - 0.4,0.3])
				tween.tween_callback(csl,"move_center",[0.3,time - 0.6,0.3])
				skill._end(tween,s,vs_color,link_color,situation,myself,rival)
			elif time < 0.0:
				time = 0.3 if -time < 0.3 else -time
				tween.tween_callback(csl,"highlight_flash",[Color.red,0.1,time - 0.2,0.1])
				tween.tween_interval(time)

