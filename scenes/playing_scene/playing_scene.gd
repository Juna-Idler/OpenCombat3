# warning-ignore-all:return_value_discarded

extends ISceneChanger.IScene

class_name PlayingScene

var scene_changer : ISceneChanger

const Card = preload("../card/card.tscn")

onready var my_combat_pos : Vector2 = $UILayer/MyField/Playing.rect_global_position + $UILayer/MyField/Playing.rect_size / 2
onready var rival_combat_pos : Vector2 = $UILayer/RivalField/Playing.rect_global_position + $UILayer/RivalField/Playing.rect_size / 2

onready var my_stock_pos : Vector2 = $UILayer/MyField/Stock.rect_global_position + $UILayer/MyField/Stock.rect_size / 2
onready var rival_stock_pos : Vector2 = $UILayer/RivalField/Stock.rect_global_position + $UILayer/RivalField/Stock.rect_size / 2

onready var my_played_pos : Vector2 = $UILayer/MyField/Played.rect_global_position + Vector2(-$UILayer/MyField/Played.rect_size.y / 2,$UILayer/MyField/Played.rect_size.x / 2)
onready var rival_played_pos : Vector2 = $UILayer/RivalField/Played.rect_global_position + Vector2($UILayer/RivalField/Played.rect_size.y / 2,-$UILayer/RivalField/Played.rect_size.x / 2)

onready var my_discard_pos : Vector2 = $UILayer/MyField/Discard.rect_global_position + $UILayer/MyField/Discard.rect_size / 2
onready var rival_discard_pos : Vector2 = $UILayer/RivalField/Discard.rect_global_position + $UILayer/RivalField/Discard.rect_size / 2

onready var my_life := $TopUILayer/Control/MyLife
onready var rival_life := $TopUILayer/Control/RivalLife

onready var combat_overlap := $"%CombatOverlap"

var game_server : IGameServer = null


var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : PlayingPlayer
var rival : PlayingPlayer

var combat_director : CombatDirector = CombatDirector.new()

func _ready():
	if game_server == null:
		var offline := OfflineServer.new("Tester",Global.card_catalog)
		var deck = []
		for i in range(27):
			deck.append(i+1)
		offline.standby_single(deck,0)
		initialize(offline,null)

	var pd := game_server._get_primary_data()
	var my_deck := []
	for i in pd.my_deck_list.size():
		var c := Card.instance().initialize_card(i,Global.card_catalog.get_card_data(pd.my_deck_list[i])) as Card
		my_deck.append(c)
		c.position = my_stock_pos
		c.visible = false
		$CardLayer.add_child(c)
	var rival_deck := []
	for i in pd.rival_deck_list.size():
		var c := Card.instance().initialize_card(i,Global.card_catalog.get_card_data(pd.rival_deck_list[i]),true) as Card
		rival_deck.append(c)
		c.position = rival_stock_pos
		c.visible = false
		$CardLayer.add_child(c)	

	myself = PlayingPlayer.new(my_deck,pd.my_name,
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
	rival = PlayingPlayer.new(rival_deck,pd.rival_name,
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
	$"%CardList".large_card_view = $"%LargeCardView"
	$"%ResultOverlap".hide()
	
	game_server._send_ready()
	

func initialize(server : IGameServer,changer : ISceneChanger):
	
	scene_changer = changer

	game_server = server
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.connect("recieved_end",self,"_on_GameServer_recieved_end")

func _terminalize():
	game_server.disconnect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.disconnect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.disconnect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.disconnect("recieved_end",self,"_on_GameServer_recieved_end")


func _on_GameServer_recieved_end(msg:String)->void:
	$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.gray
	$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.gray
	$"%ResultOverlap".get_node("ResultLabel").text = msg
	$"%ResultOverlap".show()
	$TopUILayer/Control/SettingButton.disabled = true
	return

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	myself.standby(data.myself.life)
	rival.standby(data.rival.life)
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	myself.draw(data.myself.hand)
	rival.draw(data.rival.hand)


func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData,_situation:int):
	var tween := create_tween()
	myself.play(data.myself.select,data.myself.hand,data.myself.damage,tween)
	rival.play(data.rival.select,data.rival.hand,data.rival.damage,tween)
	yield(tween,"finished")

	yield(combat_director.perform(self,data.next_phase == IGameServer.Phase.GAMEFINISH),"completed")

	if data.next_phase == IGameServer.Phase.GAMEFINISH:
		round_count = data.round_count
		phase = data.next_phase
		
		var mlife = data.myself.life - data.myself.damage
		var rlife = data.rival.life - data.rival.damage
		if mlife > rlife:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("ResultLabel").text = "Win"
		elif mlife < rlife:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.white
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.black
			$"%ResultOverlap".get_node("ResultLabel").text = "Lose"
		else:
			$"%ResultOverlap".get_node("RivalVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("MyVeil").self_modulate = Color.gray
			$"%ResultOverlap".get_node("ResultLabel").text = "Draw"
		$"%ResultOverlap".show()
		$TopUILayer/Control/SettingButton.disabled = true
		return

	tween = create_tween()
	myself.play_end(data.myself.draw,tween)
	rival.play_end(data.rival.draw,tween)
	
	myself.set_next_effect(data.myself.next_power,data.myself.next_hit,data.myself.next_block)
	rival.set_next_effect(data.rival.next_power,data.rival.next_hit,data.rival.next_block)
	tween.parallel()
	tween.tween_property(myself.next_effect_label,"modulate:a",1.0,0.5)
	tween.parallel()
	tween.tween_property(rival.next_effect_label,"modulate:a",1.0,0.5)

	myself.update_affected(data.myself.updates)
	rival.update_affected(data.rival.updates)
	
	round_count = data.round_count
	phase = data.next_phase
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and
			data.myself.damage == 0):
		yield(get_tree().create_timer(1), "timeout")
		game_server._send_recovery_select(data.round_count,-1)
	else:
		$UILayer/MyField/HandArea.ban_drag(false)



func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	myself.recover(data.myself.select,data.myself.hand,data.myself.draw,tween)
	tween.parallel()
	rival.recover(data.rival.select,data.rival.hand,data.rival.draw,tween)
	tween.tween_callback(myself,"change_damage",[true])
	tween.tween_callback(rival,"change_damage",[true])

#
	round_count = data.round_count
	phase = data.next_phase

	if (data.next_phase == IGameServer.Phase.RECOVERY and
			data.myself.damage == 0):
		yield(get_tree().create_timer(1), "timeout")
		game_server._send_recovery_select(data.round_count,-1)
	else:
		$UILayer/MyField/HandArea.ban_drag(false)



func _on_MyHandArea_decided_card(index:int,hands:Array):
	$UILayer/MyField/HandArea.ban_drag(true)
	
	if phase == IGameServer.Phase.COMBAT:
		game_server._send_combat_select(round_count,index,hands)
	elif phase == IGameServer.Phase.RECOVERY:
		game_server._send_recovery_select(round_count,index,hands)




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


func _on_SettingsScene_pressed_surrender():
	game_server._send_surrender()


func _on_ReturnButton_pressed():
	scene_changer._goto_title_scene()

