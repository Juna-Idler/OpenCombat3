extends Node

const Card = preload("../card/card.tscn")

onready var my_combat_pos : Vector2 = $UILayer/MyField/Playing.rect_global_position + $UILayer/MyField/Playing.rect_size / 2
onready var rival_combat_pos : Vector2 = $UILayer/RivalField/Playing.rect_global_position + $UILayer/RivalField/Playing.rect_size / 2

onready var my_stack_pos : Vector2 = $UILayer/MyField/Stack.rect_global_position + $UILayer/MyField/Stack.rect_size / 2
onready var rival_stack_pos : Vector2 = $UILayer/RivalField/Stack.rect_global_position + $UILayer/RivalField/Stack.rect_size / 2

onready var my_played_pos : Vector2 = $UILayer/MyField/Played.rect_global_position + Vector2(-$UILayer/MyField/Played.rect_size.y / 2,$UILayer/MyField/Played.rect_size.x / 2)
onready var rival_played_pos : Vector2 = $UILayer/RivalField/Played.rect_global_position + Vector2($UILayer/RivalField/Played.rect_size.y / 2,-$UILayer/RivalField/Played.rect_size.x / 2)

onready var my_discard_pos : Vector2 = $UILayer/MyField/Discard.rect_global_position + $UILayer/MyField/Discard.rect_size / 2
onready var rival_discard_pos : Vector2 = $UILayer/RivalField/Discard.rect_global_position + $UILayer/RivalField/Discard.rect_size / 2

onready var my_stack_count := $TopUILayer/Control/MyStackCount
onready var rival_stack_count := $TopUILayer/Control/RivalStackCount
onready var my_life := $TopUILayer/Control/MyLife
onready var rival_life := $TopUILayer/Control/RivalLife

onready var combat_overlay := $CombatLayer/CombatOverlay

var game_server : IGameServer = null
var commander : ICpuCommander = null

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : PlayingPlayer
var rival : PlayingPlayer

var combat_director : CombatDirector = CombatDirector.new()

func _ready():
	
	var cc := Global.card_catalog
	
#	if game_server == null:
	var offline := OfflineServer.new("Tester",cc)
	game_server = offline
# warning-ignore:return_value_discarded
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
# warning-ignore:return_value_discarded
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
# warning-ignore:return_value_discarded
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

	var deck = []
	for i in range(27):
		deck.append(i+1)
# warning-ignore:return_value_discarded
	offline.standby_single(deck,0)

# warning-ignore:unused_variable
	var pd := game_server._get_primary_data()
	var cdeck := []
	for i in pd.my_deck_list.size():
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.my_deck_list[i])) as Card
		cdeck.append(c)
		c.position = my_stack_pos
		c.visible = false
		$CardLayer.add_child(c)
	var rcdeck := []
	for i in pd.rival_deck_list.size():
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.rival_deck_list[i]),true) as Card
		rcdeck.append(c)
		c.position = rival_stack_pos
		c.visible = false
		$CardLayer.add_child(c)	
	
	myself = PlayingPlayer.new(cdeck,pd.my_name,
			$UILayer/MyField/HandArea,
			my_combat_pos,
			my_played_pos,
			my_discard_pos,
			my_stack_count,
			my_life)
	rival = PlayingPlayer.new(rcdeck,pd.rival_name,
			$UILayer/RivalField/HandArea,
			rival_combat_pos,
			rival_played_pos,
			rival_discard_pos,
			rival_stack_count,
			rival_life)
	
	combat_director.initialize(myself,rival,
			combat_overlay.my_skills_list,
			combat_overlay.rival_skills_list,
			$CombatLayer/CombatOverlay,$BGLayer/PowerBalance)
	$CombatLayer/CombatOverlay.visible = false
	
	game_server._send_ready()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	myself.draw(data.myself.hand_indexes)
	rival.draw(data.rival.hand_indexes)


func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData,_situation:int):
	var my_select_id : int = data.myself.hand_indexes[data.myself.hand_select]
	var rival_select_id : int = data.rival.hand_indexes[data.rival.hand_select]
	var my_playing_card := myself.deck_list[my_select_id] as Card
	var rival_playing_card := rival.deck_list[rival_select_id] as Card

	var tween := create_tween()
	myself.play(data.myself.hand_select,data.myself.hand_indexes,data.myself.damage,tween)
	rival.play(data.rival.hand_select,data.rival.hand_indexes,data.rival.damage,tween)
	yield(tween,"finished")

	yield(combat_director.perform(self),"completed")

	tween = create_tween()
	myself.play_end(data.myself.draw_indexes,tween)
	rival.play_end(data.rival.draw_indexes,tween)

	myself.update_affected(data.myself.cards_update)
	rival.update_affected(data.rival.cards_update)
	
	myself.next_effect.power = data.myself.next_effect.power
	myself.next_effect.hit = data.myself.next_effect.hit
	myself.next_effect.rush = data.myself.next_effect.rush
	myself.next_effect.damage = data.myself.next_effect.damage
	
	rival.next_effect.power = data.rival.next_effect.power
	rival.next_effect.hit = data.rival.next_effect.hit
	rival.next_effect.rush = data.rival.next_effect.rush
	rival.next_effect.damage = data.rival.next_effect.damage
	
	if myself.next_effect.power != 0:
		$TopUILayer/Control/MyNextBuf.text = "力+" + str(myself.next_effect.power)
	else:
		$TopUILayer/Control/MyNextBuf.text = ""
	if rival.next_effect.power != 0:
		$TopUILayer/Control/RivalNextBuf.text = "力+" + str(rival.next_effect.power)
	else:
		$TopUILayer/Control/RivalNextBuf.text = ""
	
	round_count = data.round_count
	phase = data.next_phase
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and
			data.myself.damage == 0):
		yield(get_tree().create_timer(1), "timeout")
		game_server._send_recovery_select(data.round_count,-1)
	else:
		$UILayer/MyField/HandArea.ban_drag(false)



func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	var my_select_id : int = -1
	var rival_select_id : int = -1
	
	var tween := create_tween()
	myself.recover(data.myself.hand_select,data.myself.hand_indexes,data.myself.draw_indexes,tween)
	rival.recover(data.rival.hand_select,data.rival.hand_indexes,data.rival.draw_indexes,tween)

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
		$LargeCardLayer/LargeCardView.show_layer(card.get_card_data())

func _on_RivalHandArea_held_card(_index:int,card:Card):
	if card != null:
		$LargeCardLayer/LargeCardView.show_layer(card.get_card_data())

func _on_held_card(card:Card):
	if card != null:
		$LargeCardLayer/LargeCardView.show_layer(card.get_card_data())

func _on_MyPlayed_clicked():
	pass # Replace with function body.


func _on_MyPlayed_held():
	if not myself.played.empty():
		$LargeCardLayer/LargeCardView.show_layer(myself.deck_list[myself.played.back()].get_card_data())

func _on_RivalPlayed_clicked():
	pass # Replace with function body.


func _on_RivalPlayed_held():
	if not rival.played.empty():
		$LargeCardLayer/LargeCardView.show_layer(rival.deck_list[rival.played.back()].get_card_data())


func _on_RivalPlayed_clicked_card(_card):
	pass # Replace with function body.


func _on_MyStack_clicked():
	pass # Replace with function body.


func _on_RivalStack_clicked():
	pass # Replace with function body.


func _on_MyDiscard_clicked():
	pass # Replace with function body.


func _on_RivalDiscard_clicked():
	pass # Replace with function body.
