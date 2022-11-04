class_name CombatDirector


class SkillOrder:
	var priority : int
	var skill : SkillData.NamedSkill
	var skill_line : CombatSkillLine
	var myself : PlayingPlayer
	var rival : PlayingPlayer
	var situation : int

	func _init(p:int,s:SkillData.NamedSkill,csl:CombatSkillLine,
			m:PlayingPlayer,r:PlayingPlayer,situ : int = 0):
		priority = p
		skill = s
		skill_line = csl
		myself = m
		rival = r
		situation = situ
		
	static func custom_compare(a : SkillOrder, b : SkillOrder):
		return a.priority < b.priority


var player1 : PlayingPlayer
var player2 : PlayingPlayer
var overlay : CombatOverlap
var power_balance : CombatPowerBalance

var named_skills := NamedSkillPerformer.new()


func initialize(p1 : PlayingPlayer,p2 : PlayingPlayer,
		ol : CombatOverlap,pb : CombatPowerBalance):
	player1 = p1
	player2 = p2
	overlay = ol
	power_balance = pb
	
	overlay.change_timing_label(CombatOverlap.CombatTiming.NoTiming)


func perform(node : Node,lethal : bool):
	if lethal:
		Engine.time_scale = 0.75
	
	overlay.initialize(player1,player2)
	power_balance.initialize()
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
	var tween := node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(overlay,"modulate:a",1.0,0.5)
	tween.tween_property(power_balance,"modulate:a",1.0,0.5)
	tween.tween_callback(power_balance,"initial_tween",[p1_card.get_current_power(),p2_card.get_current_power(),0.5])
	tween.tween_property(p1_card,"modulate:a",0.0,0.5)
	tween.tween_property(p2_card,"modulate:a",0.0,0.5)
	tween.tween_property(player1.next_effect_label,"modulate:a",0.0,0.5)
	tween.tween_property(player2.next_effect_label,"modulate:a",0.0,0.5)
	tween.set_parallel(false)

	tween.tween_callback(player1,"add_attribute",
			[player1.next_effect.power,player1.next_effect.hit,player1.next_effect.block])
	if player1.next_effect.power != 0:
		tween.tween_interval(0.5)
	tween.tween_callback(player2,"add_attribute",
			[player2.next_effect.power,player2.next_effect.hit,player2.next_effect.block])
	if player2.next_effect.power != 0:
		tween.tween_interval(0.5)
	tween.tween_interval(0.5)
	

 # 交戦前タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlap.CombatTiming.Before])
	
	_before_skills_effect(tween)

 # 演出の為に間を取る
	var p1_start_pos_x = overlay.p1_avatar.avatar.global_position.x
	var p2_start_pos_x = overlay.p2_avatar.avatar.global_position.x
	tween.tween_property(overlay.p1_avatar.avatar,"global_position:x",96.0,0.3).as_relative()
	tween.parallel()
	tween.tween_property(overlay.p2_avatar.avatar,"global_position:x",-96.0,0.3).as_relative()
	
	yield(tween,"finished")
	tween = node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

 # 交戦タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlap.CombatTiming.Engagement])
	
	var situation := (player1.get_current_power() - player2.get_current_power())
	situation = _engaged_skills_effect(tween,situation)
	
	if situation > 0:
		var hit = player1.get_current_hit()
		if hit > 0:
			player1.combat_avatar.attack(hit,player2.combat_avatar,tween)
	elif situation < 0:
		var hit = player2.get_current_hit()
		if hit > 0:
			player2.combat_avatar.attack(hit,player1.combat_avatar,tween)
	else:
		pass
	
	tween.tween_interval(0.3)
	yield(tween,"finished")
	tween = node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

 # 交戦後タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlap.CombatTiming.After])
	_after_skills_effect(tween,situation)
	
	yield(tween,"finished")


	tween = node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.3)

 # 終了時タイミング
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlap.CombatTiming.End])
	_end_skills_effect(tween,situation)

	tween.tween_property(overlay.p1_avatar.avatar,"global_position:x",p1_start_pos_x,0.5)
	tween.parallel()
	tween.tween_property(overlay.p2_avatar.avatar,"global_position:x",p2_start_pos_x,0.5)
	
	tween.tween_property(p1_card,"modulate:a",1.0,0.5)
	tween.set_parallel(true)
	tween.tween_property(p2_card,"modulate:a",1.0,0.5)
	tween.tween_property(overlay,"modulate:a",0.0,0.5)
	tween.tween_property(power_balance,"modulate:a",0.0,0.5)
	tween.set_parallel(false)
	tween.tween_callback(overlay,"hide")
	tween.tween_callback(power_balance,"hide")

	if lethal:
		Engine.time_scale = 1.0
		return
	yield(tween,"finished")
	

func _before_skills_effect(tween : SceneTreeTween):
	var skill_order := []
	for i in player1.playing_card.front.data.skills.size():
		var s := player1.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.playing_card.front.data.color,player1.get_link_color()):
			var csl := player1.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player1,player2))
	for i in player2.playing_card.front.data.skills.size():
		var s := player2.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.playing_card.front.data.color,player2.get_link_color()):
			var csl := player2.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player2,player1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := named_skills.get_skill(s.skill.data.id)
		if skill._test_before(s.skill,s.myself,s.rival):
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(s.skill_line.global_position.x,360)
			tween.tween_callback(s.skill_line,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._before(tween,s.skill,s.myself,s.rival)
		else:
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)

func _engaged_skills_effect(tween : SceneTreeTween,situation : int) -> int:
	var skill_order := []
	for i in player1.playing_card.front.data.skills.size():
		var s := player1.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.playing_card.front.data.color,player1.get_link_color()):
			var csl := player1.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player1,player2,situation))
	for i in player2.playing_card.front.data.skills.size():
		var s := player2.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.playing_card.front.data.color,player2.get_link_color()):
			var csl := player2.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := named_skills.get_skill(s.skill.data.id)
		if skill._test_engaged(s.skill,s.situation,s.myself,s.rival):
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(s.skill_line.global_position.x,360)
			tween.tween_callback(s.skill_line,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			situation = skill._engaged(tween,s.skill,s.situation,s.myself,s.rival)
		else:
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)
	return situation

func _after_skills_effect(tween : SceneTreeTween,situation : int):
	var skill_order := []
	for i in player1.playing_card.front.data.skills.size():
		var s := player1.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.playing_card.front.data.color,player1.get_link_color()):
			var csl := player1.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player1,player2,situation))
	for i in player2.playing_card.front.data.skills.size():
		var s := player2.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.playing_card.front.data.color,player2.get_link_color()):
			var csl := player2.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := named_skills.get_skill(s.skill.data.id)
		if skill._test_after(s.skill,s.situation,s.myself,s.rival):
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(s.skill_line.global_position.x,360)
			tween.tween_callback(s.skill_line,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._after(tween,s.skill,s.situation,s.myself,s.rival)
		else:
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)

func _end_skills_effect(tween : SceneTreeTween,situation : int):
	var skill_order := []
	for i in player1.playing_card.front.data.skills.size():
		var s := player1.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.playing_card.front.data.color,player1.get_link_color()):
			var csl := player1.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player1,player2,situation))
	for i in player2.playing_card.front.data.skills.size():
		var s := player2.playing_card.front.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.playing_card.front.data.color,player2.get_link_color()):
			var csl := player2.combat_avatar.skills[i] as CombatSkillLine
			var priority = named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,csl,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := named_skills.get_skill(s.skill.data.id)
		if skill._test_end(s.skill,s.situation,s.myself,s.rival):
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.blue,0.2,0.6,0.2])
			var move_pos = Vector2(s.skill_line.global_position.x,360)
			tween.tween_callback(s.skill_line,"move_and_remove",[0.3,0.5,0.2])
			tween.tween_interval(0.4)
			skill._end(tween,s.skill,s.situation,s.myself,s.rival)
		else:
			tween.tween_callback(s.skill_line,"highlight_flash",[Color.red,0.2,0.6,0.2])
			tween.tween_interval(0.3)

