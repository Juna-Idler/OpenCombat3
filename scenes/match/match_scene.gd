# warning-ignore-all:return_value_discarded

extends Node

class_name MatchScene

signal ended(situation,msg)

signal performed()

var performing : bool


const COMBAT_RESULT_DELAY = 5.0
const COMBAT_SKILL_DELAY = 1.0
const RECOVER_RESULT_DELAY = 1.0


onready var combat_overlap := $"%CombatOverlap"

onready var exit_button : Button = $"%SettingsScene".get_node("ExitButton")


var game_server : IGameServer = null


var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : MatchPlayer
var rival : MatchPlayer

var combat_director : CombatDirector = CombatDirector.new()


var delay_time : float

func _ready():
	pass

func _process(_delta):
	if not $LimitTimer.is_stopped():
		var elapsed =  $LimitTimer.wait_time - $LimitTimer.time_left
		if elapsed < delay_time:
			myself.player_field._set_time($LimitTimer.wait_time - delay_time,delay_time - elapsed)
		else:
			myself.player_field._set_time($LimitTimer.time_left - delay_time,-1)

func is_valid() -> bool:
	return game_server != null

func initialize(server : IGameServer,
		my_catalog : I_CardCatalog,rival_catalog : I_CardCatalog,
		my_skill : MatchEffect.ISkillFactory,rival_skill : MatchEffect.ISkillFactory,
		my_field : I_PlayerField,rival_field : I_PlayerField):
	game_server = server
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.connect("recieved_end",self,"_on_GameServer_recieved_end")
	game_server.connect("recieved_complete_board",self,"_on_GameServer_recieved_complete_board")

	my_field.connect("card_clicked",self,"_on_MyHandArea_card_clicked")
	my_field.connect("card_held",self,"_on_MyHandArea_card_held")
	my_field.connect("card_decided",self,"_on_MyHandArea_card_decided")
	my_field.connect("card_order_changed",self,"_on_MyHandArea_card_order_changed")
	my_field.connect("stock_clicked",self,"_on_MyStock_clicked")
	my_field.connect("stock_held",self,"_on_MyStock_held")
	my_field.connect("played_clicked",self,"_on_MyPlayed_clicked")
	my_field.connect("played_held",self,"_on_MyPlayed_clicked")
	my_field.connect("discard_clicked",self,"_on_MyDiscard_clicked")
	my_field.connect("discard_held",self,"_on_MyDiscard_clicked")
	my_field.connect("states_clicked",self,"_on_MyStatesPanel_pressed")
	rival_field.connect("card_clicked",self,"_on_RivalHandArea_card_clicked")
	rival_field.connect("card_held",self,"_on_RivalHandArea_card_held")
	rival_field.connect("stock_clicked",self,"_on_RivalStock_clicked")
	rival_field.connect("stock_held",self,"_on_RivalStock_held")
	rival_field.connect("played_clicked",self,"_on_RivalPlayed_clicked")
	rival_field.connect("played_held",self,"_on_RivalPlayed_clicked")
	rival_field.connect("discard_clicked",self,"_on_RivalDiscard_clicked")
	rival_field.connect("discard_held",self,"_on_RivalDiscard_clicked")
	rival_field.connect("states_clicked",self,"_on_RivalStatesPanel_pressed")

	
	for c in $CardLayer.get_children():
		$CardLayer.remove_child(c)
		c.queue_free()
	
	var pd := game_server._get_primary_data()
	deck_regulation = pd.deck_regulation
	match_regulation = pd.match_regulation
	myself = MatchPlayer.new(pd.my_name,pd.my_deck_list,
			my_catalog,my_skill,false,$CardLayer,my_field,
			combat_overlap.p1_avatar,
			CombatPowerBalance.Interface.new($BGLayer/PowerBalance,false))
	rival = MatchPlayer.new(pd.rival_name,pd.rival_deck_list,
			rival_catalog,rival_skill,true,$CardLayer,rival_field,
			combat_overlap.p2_avatar,
			CombatPowerBalance.Interface.new($BGLayer/PowerBalance,true))

	combat_director.initialize(myself,rival,
			combat_overlap,$BGLayer/PowerBalance)
	combat_overlap.visible = false
	
	my_field._set_states(myself.states)
	rival_field._set_states(rival.states)

	$TopUILayer/SettingButton.disabled = false
	$"%SettingsScene".hide()
	performing = false


func send_ready():
	game_server._send_ready()

func decide_card(index:int):
	$LimitTimer.stop()
	myself.player_field._disable_play(true)
	if phase == IGameServer.Phase.COMBAT:
		game_server._send_combat_select(round_count,index,myself.hand)
	elif phase == IGameServer.Phase.RECOVERY:
		game_server._send_recovery_select(round_count,index,myself.hand)
		

func terminalize():
	if game_server:
		game_server.disconnect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
		game_server.disconnect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
		game_server.disconnect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
		game_server.disconnect("recieved_end",self,"_on_GameServer_recieved_end")
		game_server.disconnect("recieved_complete_board",self,"_on_GameServer_recieved_complete_board")
		game_server = null
	if myself:
		myself.player_field.disconnect("card_clicked",self,"_on_MyHandArea_card_clicked")
		myself.player_field.disconnect("card_held",self,"_on_MyHandArea_card_held")
		myself.player_field.disconnect("card_decided",self,"_on_MyHandArea_card_decided")
		myself.player_field.disconnect("card_order_changed",self,"_on_MyHandArea_card_order_changed")
		myself.player_field.disconnect("stock_clicked",self,"_on_MyStock_clicked")
		myself.player_field.disconnect("stock_held",self,"_on_MyStock_held")
		myself.player_field.disconnect("played_clicked",self,"_on_MyPlayed_clicked")
		myself.player_field.disconnect("played_held",self,"_on_MyPlayed_clicked")
		myself.player_field.disconnect("discard_clicked",self,"_on_MyDiscard_clicked")
		myself.player_field.disconnect("discard_held",self,"_on_MyDiscard_clicked")
		myself.player_field.disconnect("states_clicked",self,"_on_MyStatesPanel_pressed")
		myself = null
	if rival:
		rival.player_field.disconnect("card_clicked",self,"_on_RivalHandArea_card_clicked")
		rival.player_field.disconnect("card_held",self,"_on_RivalHandArea_card_held")
		rival.player_field.disconnect("stock_clicked",self,"_on_RivalStock_clicked")
		rival.player_field.disconnect("stock_held",self,"_on_RivalStock_held")
		rival.player_field.disconnect("played_clicked",self,"_on_RivalPlayed_clicked")
		rival.player_field.disconnect("played_held",self,"_on_RivalPlayed_clicked")
		rival.player_field.disconnect("discard_clicked",self,"_on_RivalDiscard_clicked")
		rival.player_field.disconnect("discard_held",self,"_on_RivalDiscard_clicked")
		rival.player_field.disconnect("states_clicked",self,"_on_RivalStatesPanel_pressed")
		rival = null


func restore_overlap():
	$"%CardList".restore_now()
	$TopUILayer/StatesDetailView.hide()
	$"%LargeCardView".hide()

func _on_GameServer_recieved_end(msg:String)->void:
	restore_overlap()
	$LimitTimer.stop()
	emit_signal("ended",-2,msg)
	$TopUILayer/SettingButton.disabled = true
	return

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	if data.myself.time >= 0:
		delay_time = match_regulation.combat_time + 1
		myself.player_field._set_time(data.myself.time,delay_time)
		$LimitTimer.start(data.myself.time + delay_time)
	else:
		myself.player_field._set_time(-1,-1)
	rival.player_field._set_time(data.rival.time,-1)
	
	performing = true
	myself.standby(data.myself.life,Array(data.myself.hand))
	rival.standby(data.rival.life,Array(data.rival.hand))
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
	myself.player_field._disable_play(false)
	performing = false
	emit_signal("performed")

func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData):
	restore_overlap()
	if data.myself.time >= 0:
		var skill_count := data.myself.effect_logs.size() + data.rival.effect_logs.size()
		var result_delay := skill_count * COMBAT_SKILL_DELAY + COMBAT_RESULT_DELAY
		if data.next_phase == IGameServer.Phase.COMBAT:
			delay_time = match_regulation.combat_time + result_delay
			$LimitTimer.start(data.myself.time + delay_time)
		elif data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage > 0:
			delay_time = match_regulation.recovery_time + result_delay
			$LimitTimer.start(data.myself.time + delay_time)
		else:
			myself.player_field._set_time(data.myself.time,delay_time)
	if data.rival.time >= 0:
		rival.player_field._set_time(data.rival.time,-1)
	performing = true
	var tween := create_tween()
	myself.play(data.myself.select,data.myself.hand,data.myself.damage,
			Array(data.myself.draw),data.myself.effect_logs,tween)
	rival.play(data.rival.select,data.rival.hand,data.rival.damage,
			Array(data.rival.draw),data.rival.effect_logs,tween)
	yield(tween,"finished")

	yield(combat_director.perform(data.next_phase == IGameServer.Phase.GAME_END),"completed")

	myself.player_field._set_states(myself.states)
	rival.player_field._set_states(rival.states)
	
	if data.next_phase == IGameServer.Phase.GAME_END:
		$LimitTimer.stop()
		performing = false
		emit_signal("performed")
		round_count = data.round_count
		phase = data.next_phase
		
		var mlife = data.myself.life - data.myself.damage
		var rlife = data.rival.life - data.rival.damage
		if mlife > rlife:
			emit_signal("ended",1,"win")
		elif mlife < rlife:
			emit_signal("ended",-1,"lose")
		else:
			emit_signal("ended",0,"draw")
		$TopUILayer/SettingButton.disabled = true
		return

	myself.play_end(data.myself.life)
	rival.play_end(data.rival.life)
	
	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")

# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		myself.player_field._disable_play(false)
	performing = false
	emit_signal("performed")


func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	restore_overlap()
	if data.myself.time >= 0:
		if data.next_phase == IGameServer.Phase.COMBAT:
			delay_time = match_regulation.combat_time + RECOVER_RESULT_DELAY
			$LimitTimer.start(data.myself.time + delay_time)
		elif data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage > 0:
			delay_time = match_regulation.recovery_time + RECOVER_RESULT_DELAY
			$LimitTimer.start(data.myself.time + delay_time)
		else:
			myself.player_field._set_time(data.myself.time,delay_time)
	if data.rival.time >= 0:
		rival.player_field._set_time(data.rival.time,-1)
			
	performing = true
	myself.recover(data.myself.select,data.myself.hand,data.myself.draw,data.myself.damage,data.myself.life)
	rival.recover(data.rival.select,data.rival.hand,data.rival.draw,data.rival.damage,data.rival.life)

	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return

	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		myself.player_field._disable_play(false)
	performing = false
	emit_signal("performed")


func _on_LimitTimer_timeout():
	if not is_valid():
		return
	restore_overlap()
	decide_card(0)


func _on_GameServer_recieved_complete_board(data:IGameServer.CompleteData)->void:
	restore_overlap()
	performing = true
	
	var state_deserializer := StateDeserializer.new()
	myself.reset_board(data.myself.hand,data.myself.played,data.myself.discard,
			data.myself.stock,data.myself.life,data.myself.damage,
			data.myself.states,data.myself.affected_list,state_deserializer)
	rival.reset_board(data.rival.hand,data.rival.played,data.rival.discard,
			data.rival.stock,data.rival.life,data.rival.damage,
			data.rival.states,data.rival.affected_list,state_deserializer)

	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return
			
	round_count = data.round_count
	phase = data.next_phase
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		myself.player_field._disable_play(true)
		game_server._send_recovery_select(data.round_count,-1)
	else:
		myself.player_field._disable_play(false)
	performing = false
	emit_signal("performed")


func _on_MyHandArea_card_decided(index:int):
	decide_card(index)

func _on_MyHandArea_card_order_changed(indexes : PoolIntArray):
	myself.set_hand(indexes)

func _on_MyHandArea_card_clicked(_index:int):
	pass # Replace with function body.


func _on_RivalHandArea_card_clicked(_index:int):
	pass # Replace with function body.


func _on_MyHandArea_card_held(index:int):
	if index < myself.hand.size():
		$"%LargeCardView".show_layer(myself.deck_list[myself.hand[index]].get_card_data())

func _on_RivalHandArea_card_held(index:int):
	if index < rival.hand.size():
		$"%LargeCardView".show_layer(rival.deck_list[rival.hand[index]].get_card_data())

func _on_held_card(card:MatchCard):
	if card != null:
		$"%LargeCardView".show_layer(card.get_card_data())

func _on_MyPlayed_clicked():
	if not myself.played.empty():
		$"%CardList".set_card_list(myself.played,myself.deck_list)


func _on_MyPlayed_held():
	if not myself.played.empty():
		$"%LargeCardView".show_layer(myself.deck_list[myself.played.back()].get_card_data())

func _on_RivalPlayed_clicked():
	if not rival.played.empty():
		$"%CardList".set_card_list(rival.played,rival.deck_list)


func _on_RivalPlayed_held():
	if not rival.played.empty():
		$"%LargeCardView".show_layer(rival.deck_list[rival.played.back()].get_card_data())


func _on_RivalPlayed_clicked_card(_card):
	pass # Replace with function body.


func _on_MyStock_clicked():
	pass # Replace with function body.


func _on_RivalStock_clicked():
	pass # Replace with function body.


func _on_MyDiscard_clicked():
	if not myself.discard.empty():
		$"%CardList".set_card_list(myself.discard,myself.deck_list)


func _on_RivalDiscard_clicked():
	if not rival.discard.empty():
		$"%CardList".set_card_list(rival.discard,rival.deck_list)



func _on_SettingButton_pressed():
	$"%SettingsScene".show()




func _on_MyStatesPanel_pressed():
	if myself.states.empty():
		return
	$TopUILayer/StatesDetailView.set_states(myself.states)
	$TopUILayer/StatesDetailView.show()


func _on_RivalStatesPanel_pressed():
	if rival.states.empty():
		return
	$TopUILayer/StatesDetailView.set_states(rival.states)
	$TopUILayer/StatesDetailView.show()
