extends Reference

class_name GameProcessor


var phase : int
var player1 : ProcessorPlayerData
var player2 : ProcessorPlayerData

var situation : int

var _card_catalog : CardCatalog
var _named_skills := NamedSkillProcessor.new()


class MomentSkill:
	var priority : int
	var skill : SkillData.NamedSkill
	var myself : ProcessorPlayerData
	var rival : ProcessorPlayerData
	var my_affected : ProcessorData.MomentAffected
	var rival_affected : ProcessorData.MomentAffected

	func _init(p:int,s:SkillData.NamedSkill,m:ProcessorPlayerData,r:ProcessorPlayerData,
			ma:ProcessorData.MomentAffected,ra:ProcessorData.MomentAffected):
		priority = p
		skill = s
		myself = m
		rival = r
		my_affected = ma
		rival_affected = ra
		
	static func custom_compare(a : MomentSkill, b : MomentSkill):
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

#hand_indexes is deck_in_id Array
func reorder_hand1(hand_indexes:Array):
	if hand_indexes.size() != player1.hand_indexes.size():
		return
	for i in player1.hand_indexes:
		if not hand_indexes.has(i):
			return
	player1.hand_indexes = hand_indexes.duplicate()

func reorder_hand2(hand_indexes:Array):
	if hand_indexes.size() != player2.hand_indexes.size():
		return
	for i in player2.hand_indexes:
		if not hand_indexes.has(i):
			return
	player2.hand_indexes = hand_indexes.duplicate()


func combat(index1 : int,index2 : int) -> void:
	if phase & 1 != 0:
		return
# warning-ignore:narrowing_conversion
	index1 = min(max(0, index1), player1.hand_indexes.size() - 1);
# warning-ignore:narrowing_conversion
	index2 = min(max(0, index2), player2.hand_indexes.size() - 1);

	var link1 = player1.get_lastplayed_card()
	var link2 = player2.get_lastplayed_card()
	var link1color = 0 if link1 == null else link1.data.color
	var link2color = 0 if link2 == null else link2.data.color
	var combatant1 = player1.combat_start(index1)
	var combatant2 = player2.combat_start(index2)

	_process_before(combatant1.data.skills,
			combatant2.data.color,link1color,player1,player2)
	_process_before(combatant2.data.skills,
			combatant1.data.color,link2color,player2,player1)

	
	var moment_affected1 := ProcessorData.MomentAffected.new()
	var moment_affected2 := ProcessorData.MomentAffected.new()
	var moment_order := []
	var change_situation_order := []

	for s in combatant1.data.skills:
		if s.test_condition(combatant2.data.color,link1color):
			var priority = _named_skills.get_skill(s.data.id)._get_moment_priority()
			if priority > 0:
				moment_order.append(MomentSkill.new(priority,s,player1,player2,moment_affected1,moment_affected2))
			elif priority < 0:
				change_situation_order.append(MomentSkill.new(-priority,s,player1,player2,moment_affected1,moment_affected2))
	for s in combatant2.data.skills:
		if s.test_condition(combatant1.data.color,link2color):
			var priority = _named_skills.get_skill(s.data.id)._get_moment_priority()
			if priority > 0:
				moment_order.append(MomentSkill.new(priority,s,player2,player1,moment_affected2,moment_affected1))
			elif priority < 0:
				change_situation_order.append(MomentSkill.new(-priority,s,player2,player1,moment_affected2,moment_affected1))
	moment_order.sort_custom(MomentSkill,"custom_compare")
	for m in moment_order:
		_named_skills.get_skill(m.skill.data.id)._process_moment(m.skill,
				m.myself,m.rival,m.my_affected,m.rival_affected)
	
	situation = combatant1.get_current_power() - combatant2.get_current_power();

	change_situation_order.sort_custom(MomentSkill,"custom_compare")
	for m in change_situation_order:
		situation = _named_skills.get_skill(m.skill.data.id)._process_moment_change_situation(m.skill,
				m.myself,m.rival,m.my_affected,m.rival_affected,situation)
	
	if (situation > 0):
		player2.combat_damage = combatant1.get_current_hit() - combatant2.get_current_block()
		player1.combat_damage = -combatant1.get_current_block()
	elif (situation < 0):
		player1.combat_damage = combatant2.get_current_hit() - combatant1.get_current_block()
		player2.combat_damage = -combatant2.get_current_block()
	else:
		player1.combat_damage = -combatant1.get_current_block()
		player2.combat_damage = -combatant2.get_current_block()
		

	_process_after(combatant1.data.skills,
			combatant2.data.color,link1color,situation,player1,player2)
	_process_after(combatant2.data.skills,
			combatant1.data.color,link2color,-situation,player2,player1)

	player1.combat_fix_damage()
	player2.combat_fix_damage()

	if player1.is_fatal() or player2.is_fatal():
		phase = -phase
		return

	_process_end(combatant1.data.skills,
			combatant2.data.color,link1color,situation,player1,player2)
	_process_end(combatant2.data.skills,
			combatant1.data.color,link2color,-situation,player2,player1)

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
			player1.hand_indexes.size() + player1.stack_indexes.size() <= 1)
			or
			((not player2.is_recovery()) and
			player2.hand_indexes.size() + player2.stack_indexes.size() <= 1)):
		phase = -phase

func reset_select():
	player1.reset_select()
	player2.reset_select()





func _process_before(skills : Array,
		vs_color : int,link_color : int,
		myself : ProcessorPlayerData,
		rival : ProcessorPlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			_named_skills.get_skill(s.data.id)._process_before(s,myself,rival)


func _process_after(skills : Array,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorPlayerData,
		rival : ProcessorPlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			_named_skills.get_skill(s.data.id)._process_after(s,situation,myself,rival)

func _process_end(skills : Array,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorPlayerData,
		rival : ProcessorPlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			_named_skills.get_skill(s.data.id)._process_end(s,situation,myself,rival)

