# warning-ignore-all:return_value_discarded

extends Node

class_name MatchScene

signal ended(situation,msg)

signal performed()

var performing : bool


onready var my_combat_pos : Vector2 = $UILayer/MyField/Playing.rect_global_position + $UILayer/MyField/Playing.rect_size / 2
onready var rival_combat_pos : Vector2 = $UILayer/RivalField/Playing.rect_global_position + $UILayer/RivalField/Playing.rect_size / 2

onready var my_stock_pos : Vector2 = $UILayer/MyField/Stock.rect_global_position + $UILayer/MyField/Stock.rect_size / 2
onready var rival_stock_pos : Vector2 = $UILayer/RivalField/Stock.rect_global_position + $UILayer/RivalField/Stock.rect_size / 2

onready var my_played_pos : Vector2 = $UILayer/MyField/Played.rect_global_position + $UILayer/MyField/Played.rect_size / 2
onready var rival_played_pos : Vector2 = $UILayer/RivalField/Played.rect_global_position + $UILayer/RivalField/Played.rect_size / 2

onready var my_discard_pos : Vector2 = $UILayer/MyField/Discard.rect_global_position + $UILayer/MyField/Discard.rect_size / 2
onready var rival_discard_pos : Vector2 = $UILayer/RivalField/Discard.rect_global_position + $UILayer/RivalField/Discard.rect_size / 2

onready var my_life := $TopUILayer/Control/MyLife
onready var rival_life := $TopUILayer/Control/RivalLife

onready var combat_overlap := $"%CombatOverlap"

onready var exit_button : Button = $"%SettingsScene".get_node("ExitButton")

var game_server : IGameServer = null

var card_manipulation : bool

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : MatchPlayer
var rival : MatchPlayer

var combat_director : CombatDirector = CombatDirector.new()

func _ready():
	$"%CardList".large_card_view = $"%LargeCardView"
	pass

func _process(delta):
	if not $LimitTimer.is_stopped():
		$TopUILayer/Control/MyTimer.text = str(int($LimitTimer.time_left))


func initialize(server : IGameServer,manipulation : bool = true):
	game_server = server
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.connect("recieved_end",self,"_on_GameServer_recieved_end")
	game_server.connect("recieved_complete_board",self,"_on_GameServer_recieved_complete_board")

	card_manipulation = manipulation
	if not card_manipulation:
		$UILayer/MyField/HandArea.ban_drag(true)
	
	for c in $CardLayer.get_children():
		$CardLayer.remove_child(c)
		c.queue_free()
	
	var pd := game_server._get_primary_data()
	myself = MatchPlayer.new(pd.my_name,
			pd.my_deck_list,false,$CardLayer,my_stock_pos,
			$UILayer/MyField/HandArea,
			my_combat_pos,
			my_played_pos,
			my_discard_pos,
			$TopUILayer/Control/MyName,
			my_life,
			$"%MyNextEffect",
			combat_overlap.p1_avatar,
			$TopUILayer/Control/MyDamage,
			CombatPowerBalance.Interface.new($BGLayer/PowerBalance,false))
	rival = MatchPlayer.new(pd.rival_name,
			pd.rival_deck_list,true,$CardLayer,rival_stock_pos,
			$UILayer/RivalField/HandArea,
			rival_combat_pos,
			rival_played_pos,
			rival_discard_pos,
			$TopUILayer/Control/RivalName,
			rival_life,
			$"%RivalNextEffect",
			combat_overlap.p2_avatar,
			$TopUILayer/Control/RivalDamage,
			CombatPowerBalance.Interface.new($BGLayer/PowerBalance,true))

	combat_director.initialize(myself,rival,
			combat_overlap,$BGLayer/PowerBalance)
	combat_overlap.visible = false

	$TopUILayer/Control/SettingButton.disabled = false
	$"%SettingsScene".hide()
	performing = false


func send_ready():
	game_server._send_ready()

func decide_card(index:int,hand:Array):
	$LimitTimer.stop()
	$UILayer/MyField/HandArea.ban_drag(true)
	if phase == IGameServer.Phase.COMBAT:
		game_server._send_combat_select(round_count,index,hand)
	elif phase == IGameServer.Phase.RECOVERY:
		game_server._send_recovery_select(round_count,index,hand)
		

func terminalize():
	if game_server:
		game_server.disconnect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
		game_server.disconnect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
		game_server.disconnect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
		game_server.disconnect("recieved_end",self,"_on_GameServer_recieved_end")
		game_server.disconnect("recieved_complete_board",self,"_on_GameServer_recieved_complete_board")
		game_server = null


func _on_GameServer_recieved_end(msg:String)->void:
	emit_signal("ended",-2,msg)
	$TopUILayer/Control/SettingButton.disabled = true
	return

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	var pd := game_server._get_primary_data()
	$TopUILayer/Control/MyTimer.text = str(pd.match_regulation.thinking_time)
	$TopUILayer/Control/RivalTimer.text = str(pd.match_regulation.thinking_time)
	$LimitTimer.start(pd.match_regulation.thinking_time)
	performing = true
	myself.standby(data.myself.life,Array(data.myself.hand))
	rival.standby(data.rival.life,Array(data.rival.hand))
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
	performing = false
	emit_signal("performed")

func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData):
	$TopUILayer/Control/MyTimer.text = str(data.myself.time/1000)
	$TopUILayer/Control/RivalTimer.text = str(data.rival.time/1000)
	if (not (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0)) and\
			(not data.next_phase == IGameServer.Phase.GAME_END):
		$LimitTimer.start(data.myself.time / 1000.0)
	performing = true
	var tween := create_tween()
	myself.play(data.myself.select,data.myself.hand,data.myself.damage,
			Array(data.myself.draw),data.myself.skill_logs,tween)
	rival.play(data.rival.select,data.rival.hand,data.rival.damage,
			Array(data.rival.draw),data.rival.skill_logs,tween)
	yield(tween,"finished")

	yield(combat_director.perform(self,data.next_phase == IGameServer.Phase.GAME_END),"completed")

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
		$TopUILayer/Control/SettingButton.disabled = true
		return

	tween = create_tween()
	myself.play_end(tween)
	rival.play_end(tween)
	
	myself.set_next_effect_label()
	rival.set_next_effect_label()
	tween.parallel()
	tween.tween_property(myself.next_effect_label,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_property(rival.next_effect_label,"modulate:a",1.0,0.5)

	
	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
	performing = false
	emit_signal("performed")


func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	$TopUILayer/Control/MyTimer.text = str(data.myself.time/1000)
	$TopUILayer/Control/RivalTimer.text = str(data.rival.time/1000)
	if (not (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0)) and\
			(not data.next_phase == IGameServer.Phase.GAME_END):
		$LimitTimer.start(data.myself.time / 1000.0)
	performing = true
	myself.recover(data.myself.select,data.myself.hand,data.myself.draw)
	rival.recover(data.rival.select,data.rival.hand,data.rival.draw)

	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")

	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
	performing = false
	emit_signal("performed")


func _on_LimitTimer_timeout():
	if not card_manipulation:
		return
	var hand = $UILayer/MyField/HandArea.get_reorder_hand()
	decide_card(0,hand)


func _on_GameServer_recieved_complete_board(data:IGameServer.CompleteData)->void:
	performing = true
	var tween = create_tween()
	tween.set_parallel(true)
	myself.reset_board(data.myself.hand,data.myself.played,data.myself.discard,
			data.myself.stock,data.myself.life,data.myself.damage,
			data.myself.next_effect,data.myself.affected_list,tween)
	rival.reset_board(data.rival.hand,data.rival.played,data.rival.discard,
			data.rival.stock,data.rival.life,data.rival.damage,
			data.rival.next_effect,data.rival.affected_list,tween)
	round_count = data.round_count
	phase = data.next_phase
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(true)
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
	yield(tween,"finished")
	performing = false
	emit_signal("performed")


func _on_MyHandArea_decided_card(index:int,hand:Array):
	decide_card(index,hand)


func _on_MyHandArea_clicked_card(_index:int,_card:Card):
	pass # Replace with function body.


func _on_RivalHandArea_clicked_card(_index:int,_card:Card):
	pass # Replace with function body.


func _on_MyHandArea_held_card(_index:int,card:Card):
	if card != null:
		$"%LargeCardView".show_layer(card.get_card_data())

func _on_RivalHandArea_held_card(_index:int,card:Card):
	if card != null:
		$"%LargeCardView".show_layer(card.get_card_data())

func _on_held_card(card:Card):
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



