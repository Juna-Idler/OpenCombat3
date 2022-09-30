extends Reference

class_name GameProcessor


var phase : int
var player1 : ProcessorData.PlayerData
var player2 : ProcessorData.PlayerData

var situation : int

var _card_catalog : CardCatalog
var _skill_processor := SkillProcessor.new()

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog
	pass


func standby(p1_deck : Array,p1_hands:int,p1_shuffle:bool,
		p2_deck : Array,p2_hands:int,p2_shuffle:bool) -> bool:
	phase = 0;
	player1 = ProcessorData.PlayerData.new(p1_deck,p1_hands,_card_catalog,p1_shuffle)
	player2 = ProcessorData.PlayerData.new(p2_deck,p2_hands,_card_catalog,p2_shuffle)
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
	var combatant1 = player1.play_combat_card(index1)
	var combatant2 = player2.play_combat_card(index2)

	_skill_processor.process_before(combatant1.data.skills,
			combatant2.data.color,link1color,player1,player2)
	_skill_processor.process_before(combatant2.data.skills,
			combatant1.data.color,link2color,player2,player1)
	
	var current_power1 : int = combatant1.get_current_power()
	var current_power2 : int = combatant2.get_current_power()
	
	situation = current_power1 - current_power2;
	if (situation > 0):
		player2.add_damage(combatant1.get_current_hit())
	elif (situation < 0):
		player1.add_damage(combatant2.get_current_hit())
	else:
		pass

	_skill_processor.process_after(combatant1.data.skills,
			combatant2.data.color,link1color,situation,player1,player2)
	_skill_processor.process_after(combatant2.data.skills,
			combatant1.data.color,link2color,-situation,player2,player1)

	player1.combat_end()
	player2.combat_end()

	_skill_processor.process_end(combatant1.data.skills,
			combatant2.data.color,link1color,situation,player1,player2)
	_skill_processor.process_end(combatant2.data.skills,
			combatant1.data.color,link2color,-situation,player2,player1)

	if player1.is_fatal() or player2.is_fatal():
		phase = -phase

	player1.supply()
	player2.supply()
	if player1.battle_damage == 0 and player2.battle_damage == 0:
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
