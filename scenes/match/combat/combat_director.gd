# warning-ignore-all:return_value_discarded

class_name CombatDirector


class SkillOrder:
	var priority : int
	var index : int
	var data
	var myself : MatchPlayer
	var rival : MatchPlayer
	var situation : int
	var situation_sign : int

	func _init(l: IGameServer.UpdateData.EffectLog,
			m:MatchPlayer,r:MatchPlayer,s : int = 0,s_sign : int = 0):
		priority = l.priority
		index = l.index
		data = l.data
		myself = m
		rival = r
		situation = s
		situation_sign = s_sign
		
	static func custom_compare(a : SkillOrder, b : SkillOrder):
		return a.priority < b.priority


var player1 : MatchPlayer
var player2 : MatchPlayer
var overlay : CombatOverlap
var power_balance : CombatPowerBalance

var named_skills := NamedSkillPerformer.new()


func initialize(p1 : MatchPlayer,p2 : MatchPlayer,
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

	overlay.modulate = Color(1,1,1,0)
	overlay.visible = true
	power_balance.modulate = Color(1,1,1,0)
	power_balance.visible = true
	var tween := node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(overlay,"modulate:a",1.0,0.5)
	tween.tween_property(power_balance,"modulate:a",1.0,0.5)
	tween.tween_callback(power_balance,"initial_tween",
			[p1_card.get_current_power(),p2_card.get_current_power(),0.5])
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
	tween.tween_callback(player1.next_effect,"reset")
	tween.tween_callback(player2.next_effect,"reset")
	

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
	tween.tween_callback(overlay,"change_timing_label",[CombatOverlap.CombatTiming.NoTiming])

	if lethal:
		Engine.time_scale = 1.0
		return
	yield(tween,"finished")
	

func _before_skills_effect(tween : SceneTreeTween):
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.BEFORE:
			skill_order.append(SkillOrder.new(l,player1,player2))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.BEFORE:
			skill_order.append(SkillOrder.new(l,player2,player1))

	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.playing_card.front.data.skills[s.index] as SkillData.NamedSkill
		var csl := s.myself.combat_avatar.skills[s.index] as CombatSkillLine
		named_skills.get_skill(skill.data.id)._before(tween,
				skill,csl,s.myself,s.rival,s.data)

func _engaged_skills_effect(tween : SceneTreeTween,situation : int) -> int:
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.ENGAGED:
			skill_order.append(SkillOrder.new(l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.ENGAGED:
			skill_order.append(SkillOrder.new(l,player2,player1,-situation,-1))

	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.playing_card.front.data.skills[s.index] as SkillData.NamedSkill
		var csl := s.myself.combat_avatar.skills[s.index] as CombatSkillLine
		situation = named_skills.get_skill(skill.data.id)._engaged(tween,
				skill,csl,s.situation,s.myself,s.rival,s.data) * s.situation_sign
	return situation

func _after_skills_effect(tween : SceneTreeTween,situation : int):
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.AFTER:
			skill_order.append(SkillOrder.new(l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.AFTER:
			skill_order.append(SkillOrder.new(l,player2,player1,-situation,-1))

	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.playing_card.front.data.skills[s.index] as SkillData.NamedSkill
		var csl := s.myself.combat_avatar.skills[s.index] as CombatSkillLine
		named_skills.get_skill(skill.data.id)._after(tween,
				skill,csl,s.situation,s.myself,s.rival,s.data)

func _end_skills_effect(tween : SceneTreeTween,situation : int):
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.END:
			skill_order.append(SkillOrder.new(l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.END:
			skill_order.append(SkillOrder.new(l,player2,player1,-situation,-1))

	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.playing_card.front.data.skills[s.index] as SkillData.NamedSkill
		var csl := s.myself.combat_avatar.skills[s.index] as CombatSkillLine
		named_skills.get_skill(skill.data.id)._end(tween,
				skill,csl,s.situation,s.myself,s.rival,s.data)

