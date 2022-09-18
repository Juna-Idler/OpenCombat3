extends Reference

class_name GameProcessor


enum PhaseName {GAMEFINISH = -1,COMBAT,RECOVERY}

var round_count : int
var phase : int
var player1 : ProcessorData.Player
var player2 : ProcessorData.Player

var situation : int

var _card_catalog : CardCatalog
var _skill_processor : SkillProcessor = SkillProcessor.new()

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog
	pass


func standby(deck1 : Array,deck2 : Array) -> bool:
	round_count = 1;
	phase = 0;
	player1 = ProcessorData.Player.new(deck1,4,_card_catalog)
	player2 = ProcessorData.Player.new(deck2,4,_card_catalog)
	return true


func combat(index1 : int,index2 : int) -> void:
	if (phase != PhaseName.COMBAT):
		return
# warning-ignore:narrowing_conversion
	index1 = min(max(0, index1), player1.hand_indexes.size() - 1);
# warning-ignore:narrowing_conversion
	index2 = min(max(0, index2), player2.hand_indexes.size() - 1);

	var link1 = player1.get_lastplayed_card()
	var link2 = player2.get_lastplayed_card()
	var link1color = 0 if link1 == null else link1.color
	var link2color = 0 if link2 == null else link2.color
	var combatant1 = player1.play_combat_card(index1)
	var combatant2 = player2.play_combat_card(index2)

	_skill_processor.process_before(combatant1.skills,
			combatant2.color,link1color,player1,player2)
	_skill_processor.process_before(combatant2.skills,
			combatant1.color,link2color,player2,player1)
	
	var current_power1 : int = combatant1.get_current_power()
	var current_power2 : int = combatant2.get_current_power()
	
	situation = current_power1 - current_power2;
	if (situation > 0):
		player2.add_damage(combatant1.get_current_hit())
	elif (situation < 0):
		player1.add_damage(combatant2.get_current_hit())
	else:
		pass

	_skill_processor.process_after(combatant1.skills,
			combatant2.color,link1color,situation,player1,player2)
	_skill_processor.process_after(combatant2.skills,
			combatant1.color,link2color,situation,player2,player1)

	player1.combat_end()
	player2.combat_end()

	_skill_processor.process_end(combatant1.skills,
			combatant2.color,link1color,situation,player1,player2)
	_skill_processor.process_end(combatant2.skills,
			combatant1.color,link2color,situation,player2,player1)

	if player1.is_fatal() or player2.is_fatal():
		phase = PhaseName.GAMEFINISH


func recover1(index : int) -> bool:
	if phase != PhaseName.RECOVERY or player1.is_recovery():
		return true
	var recovery := player1.recover(index)
	if recovery and player2.is_recovery():
		phase = PhaseName.BATTLE
	return recovery

func recover2(index : int) -> bool:
	if phase != PhaseName.RECOVERY or player2.is_recovery():
		return true
	var recovery = player2.recover(index)
	if recovery and player1.is_recovery():
		phase = PhaseName.BATTLE
	return recovery



