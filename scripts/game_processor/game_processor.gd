extends Reference

class_name GameProcessor

enum  Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}

var round_count : int
var phase : int
var player1 : ProcessorData.Player
var player2 : ProcessorData.Player

var situation : int

var _named_skills := NamedSkillProcessor.new()


class SkillOrder:
	var priority : int
	var skill_index : int
	var myself : ProcessorData.Player
	var rival : ProcessorData.Player
	var situation : int
	var situation_sign : int

	func _init(p:int,i:int,
			m:ProcessorData.Player,r:ProcessorData.Player,s : int = 0,s_sign : int = 0):
		priority = p
		skill_index = i
		myself = m
		rival = r
		situation = s
		situation_sign = s_sign
		
	static func custom_compare(a : SkillOrder, b : SkillOrder):
		return a.priority < b.priority


func _init():
	pass


func standby(p1 : ProcessorData.Player,p2 : ProcessorData.Player) -> bool:
	round_count = 1
	phase = Phase.COMBAT;
	player1 = p1
	player2 = p2
	return true

#hand is deck_in_id Array
func reorder_hand1(hand:Array):
	if hand.size() != player1.hand.size():
		return
	for i in player1.hand:
		if not hand.has(i):
			return
	player1.hand = hand.duplicate()

func reorder_hand2(hand:Array):
	if hand.size() != player2.hand.size():
		return
	for i in player2.hand:
		if not hand.has(i):
			return
	player2.hand = hand.duplicate()


func combat(index1 : int,index2 : int) -> void:
	if phase != Phase.COMBAT:
		return
# warning-ignore:narrowing_conversion
	index1 = min(max(0, index1), player1.hand.size() - 1);
# warning-ignore:narrowing_conversion
	index2 = min(max(0, index2), player2.hand.size() - 1);

	var link1 = player1.get_lastplayed_card()
	var link2 = player2.get_lastplayed_card()
	var p1_link_color = 0 if link1 == null else link1.data.color
	var p2_link_color = 0 if link2 == null else link2.data.color
	player1.combat_start(index1)
	player2.combat_start(index2)


	_before_process(p1_link_color,p2_link_color)

	situation = player1.get_current_power() - player2.get_current_power();

	_engaged_process(p1_link_color,p2_link_color)

	if (situation > 0):
		player2.add_damage(player1.get_current_hit())
	elif (situation < 0):
		player1.add_damage(player2.get_current_hit())

	_after_process(p1_link_color,p2_link_color)

	var p1fatal := player1.damage_is_fatal()
	var p2fatal := player2.damage_is_fatal()

	if p1fatal or p2fatal:
		phase = Phase.GAME_END
		return

	_end_process(p1_link_color,p2_link_color)

	player1.combat_end()
	player2.combat_end()


	player1.supply()
	player2.supply()
	if player1.is_recovery() and player2.is_recovery():
		round_count += 1
	else:
		phase = Phase.RECOVERY

func recover(index1:int,index2:int):
	if player1.is_recovery():
		player1.no_recover()
	else:
		player1.recover(index1)
	if player2.is_recovery():
		player2.no_recover()
	else:
		player2.recover(index2)
		
	if player1.is_recovery() and player2.is_recovery():
		round_count += 1
		phase = Phase.COMBAT
	elif (((not player1.is_recovery()) and
			player1.hand.size() + player1.stock.size() <= 1)
			or
			((not player2.is_recovery()) and
			player2.hand.size() + player2.stock.size() <= 1)):
		phase = Phase.GAME_END

func reset_select():
	player1.reset_select()
	player2.reset_select()


func _before_process(p1_link_color : int, p2_link_color):
	var skill_order := []
	for i in player1.select_card.data.skills.size():
		var s := player1.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player1,player2))
	for i in player2.select_card.data.skills.size():
		var s := player2.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player2,player1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.select_card.data.skills[s.skill_index] as SkillData.NamedSkill
		_named_skills.get_skill(skill.data.id)._process_before(s.skill_index,s.myself,s.rival)


func _engaged_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1.select_card.data.skills.size():
		var s := player1.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player1,player2,situation,1))
	for i in player2.select_card.data.skills.size():
		var s := player2.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.select_card.data.skills[s.skill_index] as SkillData.NamedSkill
		situation = _named_skills.get_skill(skill.data.id)._process_engaged(s.skill_index,s.situation,s.myself,s.rival) * s.situation_sign


func _after_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1.select_card.data.skills.size():
		var s := player1.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player1,player2,situation,1))
	for i in player2.select_card.data.skills.size():
		var s := player2.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.select_card.data.skills[s.skill_index] as SkillData.NamedSkill
		_named_skills.get_skill(skill.data.id)._process_after(s.skill_index,s.situation,s.myself,s.rival)


func _end_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1.select_card.data.skills.size():
		var s := player1.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player1,player2,situation,1))
	for i in player2.select_card.data.skills.size():
		var s := player2.select_card.data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself.select_card.data.skills[s.skill_index] as SkillData.NamedSkill
		_named_skills.get_skill(skill.data.id)._process_end(s.skill_index,s.situation,s.myself,s.rival)

