# warning-ignore-all:return_value_discarded

extends Node

class_name MatchScene

signal ended(situation,msg)

signal performed()

var performing : bool


const COMBAT_RESULT_DELAY = 5.0
const COMBAT_SKILL_DELAY = 1.0
const RECOVER_RESULT_DELAY = 1.0


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
var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var card_manipulation : bool

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : MatchPlayer
var rival : MatchPlayer

var combat_director : CombatDirector = CombatDirector.new()


var delay_time : float

func _ready():
	$"%CardList".large_card_view = $"%LargeCardView"
	pass

func _process(_delta):
	if not $LimitTimer.is_stopped():
		var elapsed =  $LimitTimer.wait_time - $LimitTimer.time_left
		if elapsed < delay_time:
			$TopUILayer/Control/MyTimer.text = "%s +%.1f" % [int($LimitTimer.wait_time - delay_time),delay_time - elapsed]
		else:
			$TopUILayer/Control/MyTimer.text = "%.1f" % $LimitTimer.time_left

func is_valid() -> bool:
	return game_server != null

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
	deck_regulation = pd.deck_regulation
	match_regulation = pd.match_regulation
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
	$LimitTimer.stop()
	emit_signal("ended",-2,msg)
	$TopUILayer/Control/SettingButton.disabled = true
	return

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	if data.myself.time >= 0:
		$TopUILayer/Control/MyTimer.text = str(data.myself.time)
		delay_time = match_regulation.combat_time + 1
		$LimitTimer.start(data.myself.time + delay_time)
	else:
		$TopUILayer/Control/MyTimer.text = "∞"
	if data.rival.time >= 0:
		$TopUILayer/Control/RivalTimer.text = str(data.rival.time)
	else:
		$TopUILayer/Control/RivalTimer.text = "∞"
	
	performing = true
	myself.standby(data.myself.life,Array(data.myself.hand))
	rival.standby(data.rival.life,Array(data.rival.hand))
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
	if card_manipulation:
		$UILayer/MyField/HandArea.ban_drag(false)
	performing = false
	emit_signal("performed")

func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData):
	if data.myself.time >= 0:
		var skill_count := data.myself.skill_logs.size() + data.rival.skill_logs.size()
		var result_delay := skill_count * COMBAT_SKILL_DELAY + COMBAT_RESULT_DELAY
		if data.next_phase == IGameServer.Phase.COMBAT:
			delay_time = match_regulation.combat_time + result_delay
			$LimitTimer.start(data.myself.time + delay_time)
		elif data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage > 0:
			delay_time = match_regulation.recovery_time + result_delay
			$LimitTimer.start(data.myself.time + delay_time)
		else:
			$TopUILayer/Control/MyTimer.text = "%.1f" % data.myself.time
	if data.rival.time >= 0:
		$TopUILayer/Control/RivalTimer.text = "%.1f" % data.rival.time
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

	myself.play_end()
	rival.play_end()
	
	myself.set_next_effect_label()
	rival.set_next_effect_label()
	tween = create_tween()
	tween.parallel()
	tween.tween_property(myself.next_effect_label,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_property(rival.next_effect_label,"modulate:a",1.0,0.5)
	
	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")

# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
	performing = false
	emit_signal("performed")


func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	if data.myself.time >= 0:
		if data.next_phase == IGameServer.Phase.COMBAT:
			delay_time = match_regulation.combat_time + RECOVER_RESULT_DELAY
			$LimitTimer.start(data.myself.time + delay_time)
		elif data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage > 0:
			delay_time = match_regulation.recovery_time + RECOVER_RESULT_DELAY
			$LimitTimer.start(data.myself.time + delay_time)
		else:
			$TopUILayer/Control/MyTimer.text = "%.1f" % data.myself.time
	if data.rival.time >= 0:
		$TopUILayer/Control/RivalTimer.text = "%.1f" % data.rival.time

	performing = true
	myself.recover(data.myself.select,data.myself.hand,data.myself.draw)
	rival.recover(data.rival.select,data.rival.hand,data.rival.draw)

	round_count = data.round_count
	phase = data.next_phase
	
	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return

	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
	performing = false
	emit_signal("performed")


func _on_LimitTimer_timeout():
	if not is_valid() or not card_manipulation:
		return
	var hand = $UILayer/MyField/HandArea.get_reorder_hand()
	decide_card(0,hand)


func _on_GameServer_recieved_complete_board(data:IGameServer.CompleteData)->void:
	performing = true
	myself.reset_board(data.myself.hand,data.myself.played,data.myself.discard,
			data.myself.stock,data.myself.life,data.myself.damage,
			data.myself.next_effect,data.myself.affected_list)
	rival.reset_board(data.rival.hand,data.rival.played,data.rival.discard,
			data.rival.stock,data.rival.life,data.rival.damage,
			data.rival.next_effect,data.rival.affected_list)

	yield(get_tree().create_timer(MatchPlayer.CARD_MOVE_DURATION), "timeout")
# yield中にgame_serverが消えた場合。（もうちょっとやりようがありそうだがとりあえず暫定措置）
	if not is_valid():
		return
			
	round_count = data.round_count
	phase = data.next_phase
	if (data.next_phase == IGameServer.Phase.RECOVERY and data.myself.damage == 0):
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(true)
		game_server._send_recovery_select(data.round_count,-1)
	else:
		if card_manipulation:
			$UILayer/MyField/HandArea.ban_drag(false)
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



