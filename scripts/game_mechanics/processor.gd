extends Reference

class_name GameProcessor

enum  Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}

var round_count : int
var phase : int
var player1 : MechanicsData.IPlayer
var player2 : MechanicsData.IPlayer

var situation : int

var _skill_processor := SkillProcessor.new()


class SkillOrder:
	var priority : int
	var skill_index : int
	var myself : MechanicsData.IPlayer
	var rival : MechanicsData.IPlayer
	var situation : int
	var situation_sign : int

	func _init(p:int,i:int,
			m:MechanicsData.IPlayer,r:MechanicsData.IPlayer,s : int = 0,s_sign : int = 0):
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


func standby(p1 : MechanicsData.IPlayer,p2 : MechanicsData.IPlayer):
	round_count = 1
	phase = Phase.COMBAT;
	player1 = p1
	player2 = p2


func reorder_hand1(hand:PoolIntArray):
	player1._change_order(hand)

func reorder_hand2(hand:PoolIntArray):
	player2._change_order(hand)


func combat(index1 : int,index2 : int) -> void:
	if phase != Phase.COMBAT:
		return
# warning-ignore:narrowing_conversion
	index1 = min(max(0, index1), player1._get_hand().size() - 1);
# warning-ignore:narrowing_conversion
	index2 = min(max(0, index2), player2._get_hand().size() - 1);

	var p1_link_color = player1._get_link_color()
	var p2_link_color = player2._get_link_color()
	player1._combat_start(index1)
	player2._combat_start(index2)


	_before_process(p1_link_color,p2_link_color)

	situation = player1._get_current_power() - player2._get_current_power();

	_engaged_process(p1_link_color,p2_link_color)

	if (situation > 0):
		player2._add_damage(player1._get_current_hit())
	elif (situation < 0):
		player1._add_damage(player2._get_current_hit())

	_after_process(p1_link_color,p2_link_color)

	var p1fatal := player1._damage_is_fatal()
	var p2fatal := player2._damage_is_fatal()

	if p1fatal or p2fatal:
		phase = Phase.GAME_END
		return

	_end_process(p1_link_color,p2_link_color)

	player1._combat_end()
	player2._combat_end()


	player1._supply()
	player2._supply()
	if player1._is_recovery() and player2._is_recovery():
		round_count += 1
	else:
		phase = Phase.RECOVERY

func recover(index1:int,index2:int):
	if player1._is_recovery():
		player1._no_recover()
	else:
		player1._recover(index1)
	if player2._is_recovery():
		player2._no_recover()
	else:
		player2._recover(index2)
		
	if player1._is_recovery() and player2._is_recovery():
		round_count += 1
		phase = Phase.COMBAT
	elif (((not player1._is_recovery()) and
			player1._get_hand().size() + player1._get_stock_count() <= 1)
			or
			((not player2._is_recovery()) and
			player2._get_hand().size() + player2._get_stock_count() <= 1)):
		phase = Phase.GAME_END

func reset_select():
	player1._reset_select()
	player2._reset_select()


func _before_process(p1_link_color : int, p2_link_color):
	var skill_order := []
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._before_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player1,player2))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._before_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player2,player1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself._get_playing_card().data.skills[s.skill_index] as SkillData.NamedSkill
		_skill_processor.get_skill(skill.data.id)._process_before(s.skill_index,s.priority,s.myself,s.rival)


func _engaged_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._engaged_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player1,player2,situation,1))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._engaged_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself._get_playing_card().data.skills[s.skill_index] as SkillData.NamedSkill
		situation = _skill_processor.get_skill(skill.data.id)._process_engaged(
				s.skill_index,s.priority,s.situation,s.myself,s.rival) * s.situation_sign


func _after_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._after_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player1,player2,situation,1))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._after_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself._get_playing_card().data.skills[s.skill_index] as SkillData.NamedSkill
		_skill_processor.get_skill(skill.data.id)._process_after(s.skill_index,s.priority,s.situation,s.myself,s.rival)


func _end_process(p1_link_color : int, p2_link_color: int):
	var skill_order := []
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._end_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player1,player2,situation,1))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().data.skills[i] as SkillData.NamedSkill
		if s.test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = _skill_processor.get_skill(s.data.id)._end_priority()
			for p in priority:
				skill_order.append(SkillOrder.new(p,i,player2,player1,-situation,-1))
	skill_order.sort_custom(SkillOrder,"custom_compare")
	for s in skill_order:
		var skill := s.myself._get_playing_card().data.skills[s.skill_index] as SkillData.NamedSkill
		_skill_processor.get_skill(skill.data.id)._process_end(s.skill_index,s.priority,s.situation,s.myself,s.rival)

