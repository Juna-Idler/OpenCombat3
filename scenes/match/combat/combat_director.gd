# warning-ignore-all:return_value_discarded

class_name CombatDirector


class EffectOrder:
	var effect : MatchEffect.IEffect
	var priority : int
	var index : int
	var data
	var myself : MatchPlayer
	var rival : MatchPlayer
	var situation : int
	var situation_sign : int

	func _init(e : MatchEffect.IEffect,l: IGameServer.UpdateData.EffectLog,
			m:MatchPlayer,r:MatchPlayer,s : int = 0,s_sign : int = 0):
		effect = e
		priority = l.priority
		index = l.index
		data = l.data
		myself = m
		rival = r
		situation = s
		situation_sign = s_sign
		
	static func custom_compare(a : EffectOrder, b : EffectOrder):
		return a.priority < b.priority


var player1 : MatchPlayer
var player2 : MatchPlayer
var overlay : CombatOverlap
var power_balance : CombatPowerBalance



func initialize(p1 : MatchPlayer,p2 : MatchPlayer,
		ol : CombatOverlap,pb : CombatPowerBalance):
	player1 = p1
	player2 = p2
	overlay = ol
	power_balance = pb
	
	overlay.change_timing_label(CombatOverlap.CombatTiming.NoTiming)


func perform(lethal : bool):
	
	overlay.initialize(player1,player2)
	power_balance.initialize()
	var p1_card := player1.deck_list[player1.playing_card_id] as MatchCard
	var p2_card := player2.deck_list[player2.playing_card_id] as MatchCard

	overlay.modulate = Color(1,1,1,0)
	overlay.visible = true
	power_balance.modulate = Color(1,1,1,0)
	power_balance.visible = true
	var tween := overlay.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
	tween.tween_callback(player1.next_effect,"set_stats",[0,0,0])
	tween.tween_callback(player2.next_effect,"set_stats",[0,0,0])
	yield(tween,"finished")

 # 交戦前タイミング
	overlay.change_timing_label(CombatOverlap.CombatTiming.Before)
	yield(_before_skills_effect(),"completed")

 # 演出の為に間を取る
	var p1_start_pos_x = overlay.p1_avatar.avatar.global_position.x
	var p2_start_pos_x = overlay.p2_avatar.avatar.global_position.x
	tween = overlay.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay.p1_avatar.avatar,"global_position:x",96.0,0.3).as_relative()
	tween.parallel()
	tween.tween_property(overlay.p2_avatar.avatar,"global_position:x",-96.0,0.3).as_relative()
	yield(tween,"finished")

 # 交戦タイミング
	overlay.change_timing_label(CombatOverlap.CombatTiming.Engagement)
	var situation := (player1.get_current_power() - player2.get_current_power())
	situation = yield(_engaged_skills_effect(situation),"completed")
	
	tween = overlay.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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

 # 交戦後タイミング
	overlay.change_timing_label(CombatOverlap.CombatTiming.After)
	yield(_after_skills_effect(situation),"completed")
	
	tween = overlay.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.3)
	yield(tween,"finished")

 # 終了時タイミング
	overlay.change_timing_label(CombatOverlap.CombatTiming.End)
	yield(_end_skills_effect(situation),"completed")

	tween = overlay.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
		return
	yield(tween,"finished")
	

func _before_skills_effect():
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.BEFORE:
			var effect = player1.playing_card.skills[l.index] if l.index >= 0 else player1.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player1,player2))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.BEFORE:
			var effect = player2.playing_card.skills[l.index] if l.index >= 0 else player2.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player2,player1))

	if skill_order.empty():
		yield(overlay.get_tree(),"idle_frame")
		return
	skill_order.sort_custom(EffectOrder,"custom_compare")
	for s in skill_order:
		s.myself.combat_avatar.set_effect_line(s.index)
		yield(s.effect._before(s.priority,s.myself,s.rival,s.data),"completed")

func _engaged_skills_effect(situation : int) -> int:
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.ENGAGED:
			var effect = player1.playing_card.skills[l.index] if l.index >= 0 else player1.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.ENGAGED:
			var effect = player2.playing_card.skills[l.index] if l.index >= 0 else player2.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player2,player1,-situation,-1))

	if skill_order.empty():
		yield(overlay.get_tree(),"idle_frame")
		return situation
	skill_order.sort_custom(EffectOrder,"custom_compare")
	for s in skill_order:
		s.myself.combat_avatar.set_effect_line(s.index)
		situation = yield(s.effect._engaged(s.priority,s.situation,s.myself,s.rival,s.data),"completed") * s.situation_sign
	return situation

func _after_skills_effect(situation : int):
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.AFTER:
			var effect = player1.playing_card.skills[l.index] if l.index >= 0 else player1.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.AFTER:
			var effect = player2.playing_card.skills[l.index] if l.index >= 0 else player2.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player2,player1,-situation,-1))

	if skill_order.empty():
		yield(overlay.get_tree(),"idle_frame")
		return
	skill_order.sort_custom(EffectOrder,"custom_compare")
	for s in skill_order:
		s.myself.combat_avatar.set_effect_line(s.index)
		yield(s.effect._after(s.priority,s.situation,s.myself,s.rival,s.data),"completed")

func _end_skills_effect(situation : int):
	var skill_order := []
	for _l in player1.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.END:
			var effect = player1.playing_card.skills[l.index] if l.index >= 0 else player1.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player1,player2,situation,1))
	for _l in player2.effect_logs:
		var l := _l as IGameServer.UpdateData.EffectLog
		if l.timing == IGameServer.EffectTiming.END:
			var effect = player2.playing_card.skills[l.index] if l.index >= 0 else player2.states[-l.index-1]
			skill_order.append(EffectOrder.new(effect,l,player2,player1,-situation,-1))

	if skill_order.empty():
		yield(overlay.get_tree(),"idle_frame")
		return
	skill_order.sort_custom(EffectOrder,"custom_compare")
	for s in skill_order:
		s.myself.combat_avatar.set_effect_line(s.index)
		yield(s.effect._end(s.priority,s.situation,s.myself,s.rival,s.data),"completed")

