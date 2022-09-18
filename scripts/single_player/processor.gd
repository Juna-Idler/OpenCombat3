extends Reference

class EnemyData extends ProcessorData.PlayerData:
	var hit_point
	


enum PhaseName {GAMEFINISH = -1,COMBAT,RECOVERY}

var round_count : int
var phase : int
var player : ProcessorData.PlayerData
var enemy : EnemyData

var situation : int

var _card_catalog : CardCatalog

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog
	pass


func standby(deck1 : Array,deck2 : Array) -> bool:
	round_count = 1;
	phase = 0;
	player = ProcessorData.PlayerData.new(deck1,_card_catalog)
	enemy = ProcessorData.PlayerData.new(deck2,_card_catalog)
	return true


func combat(index1 : int,index2 : int) -> void:
	if (phase != PhaseName.COMBAT):
		return
# warning-ignore:narrowing_conversion
	index1 = min(max(0, index1), player.hand_indexes.size() - 1);
# warning-ignore:narrowing_conversion
	index2 = min(max(0, index2), enemy.hand_indexes.size() - 1);

	var link1 = player.get_lastplayed_card()
	var link2 = enemy.get_lastplayed_card()
	var link1color = 0 if link1 == null else link1.color
	var link2color = 0 if link2 == null else link2.color
	var combatant1 = player.play_combat_card(index1)
	var combatant2 = enemy.play_combat_card(index2)
	
	combatant1.affected.add(player.next_effect);
	combatant2.affected.add(enemy.next_effect);
	player.next_effect.rest()
	enemy.next_effect.rest()

	for s in combatant1.skills:
		if s is NormalSkill:
			if s.test_condition_before(combatant2.color,link1color):
				_activate_normal_skill(s,player,enemy)
		elif s is CardData.NamedSkill:
			NamedSkillProcessor.Process(s,player,enemy,true,0)

	for s in combatant2.skills:
		if s is NormalSkill:
			if s.test_condition_before(combatant1.color,link2color):
				_activate_normal_skill(s,enemy,player)
		elif s is CardData.NamedSkill:
			NamedSkillProcessor.Process(s,enemy,player,true,0)
	
	var current_power1 : int = combatant1.get_current_power()
	var current_power2 : int = combatant2.get_current_power()
	
	situation = current_power1 - current_power2;
	if (situation > 0):
		enemy.battle_damage = combatant1.get_current_hit()
	elif (situation < 0):
		player.battle_damage = combatant2.get_current_hit()
	else:
		pass

	for s in combatant1.skills:
		if s is NormalSkill:
			if s.test_condition_after(combatant2.color,link1color,situation):
				_activate_normal_skill(s,player,enemy)
		elif s is CardData.NamedSkill:
			NamedSkillProcessor.Process(s,player,enemy,false,situation)
	for s in combatant2.skills:
		if s is NormalSkill:
			if s.test_condition_after(combatant1.color,link2color,-situation):
				_activate_normal_skill(s,enemy,player)
		elif s is CardData.NamedSkill:
			NamedSkillProcessor.Process(s,enemy,player,false,-situation)

	var damage = player.battle_damage + combatant1.affected.damage
	player.battle_damage = 0 if damage < 0 else damage
	damage = enemy.battle_damage + combatant2.affected.damage
	enemy.battle_damage = 0 if damage < 0 else damage

	if (player.get_hit_point() < player.battle_damage or
			 enemy.hit_point < enemy.battle_damage):
		phase = PhaseName.GAMEFINISH


	player.combat_end()
	enemy.combat_end()
	


func _activate_normal_skill(skill : NormalSkill,
		myself : ProcessorData.PlayerData,rival : ProcessorData.PlayerData) -> void:
	for t_ in skill.targets:
		var t := t_ as NormalSkill.Target
		match t.target_card:
			NormalSkill.TargetCard.PLAYED_CARD:
				match t.target_player:
					NormalSkill.TargetPlayer.MYSELF:
						_skill_effect(t.effects,myself.get_playing_card().affected)
					NormalSkill.TargetPlayer.RIVAL:
						_skill_effect(t.effects,rival.get_playing_card().affected)
					NormalSkill.TargetPlayer.BOTH:
						_skill_effect(t.effects,myself.get_playing_card().affected)
						_skill_effect(t.effects,rival.get_playing_card().affected)
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
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
					NormalSkill.TargetPlayer.RIVAL:
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
					NormalSkill.TargetPlayer.BOTH:
						for i in myself.hand_indexes:
							if (myself.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,myself.deck_list[i].affected)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
						for i in rival.hand_indexes:
							if (rival.deck_list[i].color == t.target_color):
								_skill_effect(t.effects,rival.deck_list[i].affected)
								if t.target_card == NormalSkill.TargetCard.HAND_ONE:
									break
		pass

func _skill_effect(effects : Array,affected : ProcessorData.Card.Affected) -> void:
	for e_ in effects:
		var e := e_ as NormalSkill.Target.Effect
		match e.effect_attribute:
			NormalSkill.EffectAttribute.POWER:
				affected.power += e.effect_parameter
			NormalSkill.EffectAttribute.HIT:
				affected.hit += e.effect_parameter
			NormalSkill.EffectAttribute.DAMAGE:
				affected.damage += e.effect_parameter
			NormalSkill.EffectAttribute.RUSH:
				affected.rush += e.effect_parameter

func recover1(index : int) -> bool:
	if phase != PhaseName.RECOVERY or player.battle_damage == 0:
		return true
	var recovery = _recover(player,index)
	if recovery and enemy.battle_damage == 0:
		phase = PhaseName.BATTLE
	return recovery

func recover2(index : int) -> bool:
	if phase != PhaseName.RECOVERY or enemy.battle_damage == 0:
		return true
	var recovery = _recover(enemy,index)
	if recovery and player.battle_damage == 0:
		phase = PhaseName.BATTLE
	return recovery

static func _recover(player : ProcessorData.PlayerData,index : int) -> bool:
	var id : int = player.hand_indexes[index]
	player.discard_indexes.append(id)
	player.hand_indexes.remove(index)
	var card := player.deck_list[id] as ProcessorData.Card
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
