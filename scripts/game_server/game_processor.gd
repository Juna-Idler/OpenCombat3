extends Reference

class_name GameProcessor


enum PhaseName {GAMEFINISH = -1,COMBAT,RECOVERY}

var round_count : int
var phase : int
var player1 : ProccessorData.PlayerData
var player2 : ProccessorData.PlayerData

var situation : int

var _card_catalog : CardCatalog

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog
	pass


func standby(deck1 : Array,deck2 : Array) -> bool:
	round_count = 1;
	phase = 0;
	player1 = ProccessorData.PlayerData.new(deck1,_card_catalog)
	player2 = ProccessorData.PlayerData.new(deck2,_card_catalog)
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
	
	combatant1.variation.add(player1.next_effect);
	combatant2.variation.add(player2.next_effect);
	player1.next_effect.rest()
	player2.next_effect.rest()

	for s in combatant1.skills:
		if s is NormalSkill:
			if s.test_condition_before(combatant2.color,link1color):
				_activate_normal_skill(s,player1,player2)
		elif s is CardData.NamedSkill:
			NamedSkillProccessor.Proccess(s,player1,player2,true,0)

	for s in combatant2.skills:
		if s is NormalSkill:
			if s.test_condition_before(combatant1.color,link2color):
				_activate_normal_skill(s,player2,player1)
		elif s is CardData.NamedSkill:
			NamedSkillProccessor.Proccess(s,player2,player1,true,0)
	
	var current_power1 : int = combatant1.get_current_power()
	var current_power2 : int = combatant2.get_current_power()
	
	situation = current_power1 - current_power2;
	if (situation > 0):
		player2.battle_damage = combatant1.get_current_hit()
	elif (situation < 0):
		player1.battle_damage = combatant2.get_current_hit()
	else:
		pass

	for s in combatant1.skills:
		if s is NormalSkill:
			if s.test_condition_after(combatant2.color,link1color,situation):
				_activate_normal_skill(s,player1,player2)
		elif s is CardData.NamedSkill:
			NamedSkillProccessor.Proccess(s,player1,player2,false,situation)
	for s in combatant2.skills:
		if s is NormalSkill:
			if s.test_condition_after(combatant1.color,link2color,-situation):
				_activate_normal_skill(s,player2,player1)
		elif s is CardData.NamedSkill:
			NamedSkillProccessor.Proccess(s,player2,player1,false,-situation)

	var damage = player1.battle_damage + combatant1.variation.damage
	player1.battle_damage = 0 if damage < 0 else damage
	damage = player2.battle_damage + combatant2.variation.damage
	player2.battle_damage = 0 if damage < 0 else damage

	if (player1.get_hit_point() < player1.battle_damage or
			 player2.get_hit_point() < player2.battle_damage):
		phase = PhaseName.GAMEFINISH


	player1.combat_end()
	player2.combat_end()
	


func _activate_normal_skill(skill : NormalSkill,
		myself : ProccessorData.PlayerData,rival : ProccessorData.PlayerData) -> void:
	for t_ in skill.targets:
		var t := t_ as NormalSkill.Target
		match t.target_card:
			NormalSkill.TargetCard.PLAYED_CARD:
				match t.target_player:
					NormalSkill.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.get_playing_card().variation)
					NormalSkill.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.get_playing_card().variation)
					NormalSkill.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.get_playing_card().variation)
						_skill_effect(t.effects,rival.get_playing_card().variation)
			NormalSkill.TargetCard.NEXT_CARD:
				match t.target_player:
					NormalSkill.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.next_effect)
					NormalSkill.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.next_effect)
					NormalSkill.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.next_effect)
						_skill_effect(t.effects,rival.next_effect)
			NormalSkill.TargetCard.HAND_ONE,NormalSkill.TargetCard.HAND_ALL:
				match t.target_player:
					NormalSkill.TargetPlayer.MYSELF:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].variation)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
					NormalSkill.TargetPlayer.RIVAL:
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].variation)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
					NormalSkill.TargetPlayer.BOTH:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].variation)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].variation)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
		pass

func _skill_effect(effects : Array,variation : ProccessorData.Card.Variation) -> void:
	for e_ in effects:
		var e := e_ as NormalSkill.Target.Effect
		match e.effect_attribute:
			NormalSkill.EffectAttribute.POWER:
				variation.power += e.effect_parameter
			NormalSkill.EffectAttribute.HIT:
				variation.hit += e.effect_parameter
			NormalSkill.EffectAttribute.DAMAGE:
				variation.damage += e.effect_parameter
			NormalSkill.EffectAttribute.RUSH:
				variation.rush += e.effect_parameter

func recover1(index : int) -> bool:
	if phase != PhaseName.RECOVERY or player1.battle_damage == 0:
		return true
	var recovery = _recover(player1,index)
	if recovery and player2.battle_damage == 0:
		phase = PhaseName.BATTLE
	return recovery

func recover2(index : int) -> bool:
	if phase != PhaseName.RECOVERY or player2.battle_damage == 0:
		return true
	var recovery = _recover(player2,index)
	if recovery and player1.battle_damage == 0:
		phase = PhaseName.BATTLE
	return recovery

static func _recover(player : ProccessorData.PlayerData,index : int) -> bool:
	var id : int = player.hand_indexes[index]
	player.discard_indexes.append(id)
	player.hand_indexes.remove(index)
	var card := player.deck_list[id] as ProccessorData.Card
	if player.battle_damage <= card.level:
		player.battle_damage = 0
		return true
	player.battle_damage -= card.data.level
# warning-ignore:return_value_discarded
	player.draw_card()
	return false


static func _sort(hand_cards : Array,sort_indexies : Array) -> void:
	var new_hands : Array = []
	for x in sort_indexies:
		new_hands.append(hand_cards[x])
