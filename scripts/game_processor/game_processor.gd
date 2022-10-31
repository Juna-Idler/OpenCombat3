extends Reference

class_name GameProcessor


var phase : int
var player1 : ProcessorPlayerData
var player2 : ProcessorPlayerData

var situation : int

var _card_catalog : CardCatalog
var _named_skills := NamedSkillProcessor.new()


class SkillOrder:
	var priority : int
	var skill : SkillData.NamedSkill
	var myself : ProcessorPlayerData
	var rival : ProcessorPlayerData
	var situation : int

	func _init(p:int,s:SkillData.NamedSkill,
			m:ProcessorPlayerData,r:ProcessorPlayerData,situ : int = 0):
		priority = p
		skill = s
		myself = m
		rival = r
		situation = situ
		
	static func custom_compare(a : SkillOrder, b : SkillOrder):
		return a.priority < b.priority


func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog
	pass


func standby(p1_deck : Array,p1_hands:int,p1_shuffle:bool,
		p2_deck : Array,p2_hands:int,p2_shuffle:bool) -> bool:
	phase = 0;
	player1 = ProcessorPlayerData.new(p1_deck,p1_hands,_card_catalog,p1_shuffle)
	player2 = ProcessorPlayerData.new(p2_deck,p2_hands,_card_catalog,p2_shuffle)
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
	if phase & 1 != 0:
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

	situation = _engaged_process(p1_link_color,p2_link_color,situation)

	if (situation > 0):
		player2.combat_damage = player1.get_current_hit() - player2.get_current_block()
		player1.combat_damage = -player1.get_current_block()
	elif (situation < 0):
		player1.combat_damage = player2.get_current_hit() - player1.get_current_block()
		player2.combat_damage = -player2.get_current_block()
	else:
		player1.combat_damage = -player1.get_current_block()
		player2.combat_damage = -player2.get_current_block()

	_after_process(p1_link_color,p2_link_color,situation)

	player1.combat_fix_damage()
	player2.combat_fix_damage()

	if player1.is_fatal() or player2.is_fatal():
		phase = -phase
		return

	_end_process(p1_link_color,p2_link_color,situation)

	player1.combat_end()
	player2.combat_end()


	player1.supply()
	player2.supply()
	if player1.combat_damage == 0 and player2.combat_damage == 0:
		phase += 1
	phase += 1

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
		phase += 1
	elif (((not player1.is_recovery()) and
			player1.hand.size() + player1.stock.size() <= 1)
			or
			((not player2.is_recovery()) and
			player2.hand.size() + player2.stock.size() <= 1)):
		phase = -phase

func reset_select():
	player1.reset_select()
	player2.reset_select()


func _before_process(p1_link_color : int, p2_link_color):
	var skill_order := []
	for s in player1.select_card.data.skills:
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player1,player2))
	for s in player2.select_card.data.skills:
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._before_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player2,player1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		_named_skills.get_skill(s.skill.data.id)._process_before(s.skill,s.myself,s.rival)


func _engaged_process(p1_link_color : int, p2_link_color: int, situation: int):
	var skill_order := []
	for s in player1.select_card.data.skills:
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player1,player2,situation))
	for s in player2.select_card.data.skills:
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._engaged_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		situation = _named_skills.get_skill(s.skill.data.id)._process_engaged(s.skill,s.situation,s.myself,s.rival)
	return situation


func _after_process(p1_link_color : int, p2_link_color: int, situation: int):
	var skill_order := []
	for s in player1.select_card.data.skills:
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player1,player2,situation))
	for s in player2.select_card.data.skills:
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._after_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		_named_skills.get_skill(s.skill.data.id)._process_after(s.skill,s.situation,s.myself,s.rival)


func _end_process(p1_link_color : int, p2_link_color: int, situation: int):
	var skill_order := []
	for s in player1.select_card.data.skills:
		if s.test_condition(player2.select_card.data.color,p1_link_color):
			var priority = _named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player1,player2,situation))
	for s in player2.select_card.data.skills:
		if s.test_condition(player1.select_card.data.color,p2_link_color):
			var priority = _named_skills.get_skill(s.data.id)._end_priority()
			if priority != 0:
				skill_order.append(SkillOrder.new(priority,s,player2,player1,-situation))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		_named_skills.get_skill(s.skill.data.id)._process_end(s.skill,s.situation,s.myself,s.rival)

