class_name CombatDirector



var player1 : PlayingPlayer
var player2 : PlayingPlayer
var combat_overlay : CombatOverlay
var combat_power_balance : CombatPowerBalance

func initialize(p1 : PlayingPlayer,p2 : PlayingPlayer,
		overlay : CombatOverlay,power_balance : CombatPowerBalance):
	player1 = p1
	player2 = p2
	combat_overlay = overlay
	combat_power_balance = power_balance


func perform(node : Node):
	combat_overlay.initialize(player1,player2)
	var p1_card := player1.deck_list[player1.playing_card_id] as Card
	var p2_card := player2.deck_list[player2.playing_card_id] as Card
	
	combat_overlay.modulate = Color(1,1,1,0)
	combat_overlay.visible = true
	combat_power_balance.modulate = Color(1,1,1,0)
	combat_power_balance.visible = true
	var tween := node.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(combat_overlay,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_property(combat_power_balance,"modulate:a",1.0,0.5)
	
	var p1_power = p1_card.get_current_power()
	var p2_power = p2_card.get_current_power()
	
	tween.parallel()
	combat_power_balance.initial_tween(p1_power,p2_power,tween,0.5)
	
	if player1.next_effect.power != 0 or player2.next_effect.power != 0:
		p1_power += player1.next_effect.power
		p2_power += player2.next_effect.power
		combat_overlay.get_node("MyControl/TotalPower").text = str(p1_power)
		combat_overlay.get_node("RivalControl/TotalPower").text = str(p2_power)
		combat_power_balance.set_power_tween(p1_power,p2_power,tween,0.3)

	combat_overlay.get_node("MyControl/NextBuf").text = ""
	combat_overlay.get_node("RivalControl/NextBuf").text = ""

	
	
#	for i in p1_card.front.data.skills.size():
#		p1_card.front.data.skills[i]
#		var csl := p1_skills_list.get_children()[i] as CombatSkillLine
#		tween.tween_callback(csl,"highlight_flash")

#	for i in p2_card.front.data.skills.size():
#		p2_card.front.data.skills[i]
#		var csl := p2_skills_list.get_children()[i] as CombatSkillLine
#		tween.tween_callback(csl,"highlight_flash")

	
	tween.tween_interval(1)
	tween.tween_property(combat_overlay,"modulate:a",0.0,0.5)
	tween.parallel()
	tween.tween_property(combat_power_balance,"modulate:a",0.0,0.5)

	yield(tween,"finished")
	
	combat_overlay.visible = false
	combat_power_balance.hide()
