extends Node

const Card = preload("res://playing_scene/card/card.tscn")

onready var my_combat_pos : Vector2 = $UILayer/MyField/Playing.rect_global_position + $UILayer/MyField/Playing.rect_size / 2
onready var rival_combat_pos : Vector2 = $UILayer/RivalField/Playing.rect_global_position + $UILayer/RivalField/Playing.rect_size / 2

onready var my_stack_pos : Vector2 = $UILayer/MyField/Stack.rect_global_position + $UILayer/MyField/Stack.rect_size / 2
onready var rival_stack_pos : Vector2 = $UILayer/RivalField/Stack.rect_global_position + $UILayer/RivalField/Stack.rect_size / 2

onready var my_played_pos : Vector2 = $UILayer/MyField/Played.rect_global_position + Vector2(-$UILayer/MyField/Played.rect_size.y / 2,$UILayer/MyField/Played.rect_size.x / 2)
onready var rival_played_pos : Vector2 = $UILayer/RivalField/Played.rect_global_position + Vector2($UILayer/RivalField/Played.rect_size.y / 2,-$UILayer/RivalField/Played.rect_size.x / 2)

onready var my_discard_pos : Vector2 = $UILayer/MyField/Discard.rect_global_position + $UILayer/MyField/Discard.rect_size / 2
onready var rival_discard_pos : Vector2 = $UILayer/RivalField/Discard.rect_global_position + $UILayer/RivalField/Discard.rect_size / 2

var game_server : IGameServer = null
var commander : ICpuCommander = null

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var myself : Player
var rival : Player

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
	for i in range(pd.my_deck_list.size()):
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.my_deck_list[i])) as Card
		cdeck.append(c)
		c.position = my_stack_pos
		$CardLayer.add_child(c)	
	var rcdeck := []
	for i in range(pd.rival_deck_list.size()):
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.rival_deck_list[i]),true) as Card
		rcdeck.append(c)
		c.position = rival_stack_pos
		$CardLayer.add_child(c)	
	
	myself = Player.new(cdeck,pd.my_name,$UILayer/MyField/HandArea)
	rival = Player.new(rcdeck,pd.rival_name,$UILayer/RivalField/HandArea)
	
	game_server._send_ready()
	

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	myself.set_hand(data.myself.hand_indexes)
	rival.set_hand(data.rival.hand_indexes)


func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData,_situation:int):
 # 状態を更新しつつ演出も見せる
	var my_select_id : int = data.myself.hand_indexes[data.myself.hand_select]
	var rival_select_id : int = data.rival.hand_indexes[data.rival.hand_select]

 # 戦闘時のスキル効果を再現するの大変そう
	var my_playing_card := myself.deck_list[my_select_id] as Card
	var rival_playing_card := rival.deck_list[rival_select_id] as Card
	var tween := create_tween()
	tween.tween_property(my_playing_card,"global_position",my_combat_pos,0.5)
	tween.parallel()
	tween.tween_property(rival_playing_card,"global_position",rival_combat_pos,0.5)
	tween.chain().tween_interval(2)
	tween.tween_property(my_playing_card,"global_position",my_played_pos,0.5)
	tween.parallel()
	tween.tween_property(my_playing_card,"rotation",PI/2,0.5)
	tween.parallel()
	tween.tween_property(rival_playing_card,"global_position",rival_played_pos,0.5)
	tween.parallel()
	tween.tween_property(rival_playing_card,"rotation",PI + PI/2,0.5)

	var new_my_hand := data.myself.hand_indexes
	var new_rival_hand := data.rival.hand_indexes
	new_my_hand.remove(data.myself.hand_select)
	new_rival_hand.remove(data.rival.hand_select)
	new_my_hand.append_array(data.myself.draw_indexes)
	new_rival_hand.append_array(data.rival.draw_indexes)
	for i in data.myself.draw_indexes:
		var c := myself.deck_list[i] as Card
		c.visible = true
	for i in data.rival.draw_indexes:
		var c := rival.deck_list[i] as Card
		c.visible = true

	myself.set_hand(new_my_hand)
	rival.set_hand(new_rival_hand)
	
	round_count = data.round_count
	phase = data.next_phase
	
	if (data.next_phase == IGameServer.Phase.RECOVERY and
			data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		$UILayer/MyField/HandArea.ban_drag(false)



func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	var my_select_id : int = -1
	var rival_select_id : int = -1
	
	var new_my_hand := data.myself.hand_indexes.duplicate()
	var new_rival_hand := data.rival.hand_indexes.duplicate()
	
	if data.myself.hand_select >= 0:
		my_select_id = data.myself.hand_indexes[data.myself.hand_select]
		new_my_hand.remove(data.myself.hand_select)
		new_my_hand.append_array(data.myself.draw_indexes)
		for i in data.myself.draw_indexes:
			var c := myself.deck_list[i] as Card
			c.visible = true
	if data.rival.hand_select >= 0:
		rival_select_id = data.rival.hand_indexes[data.rival.hand_select]
		new_rival_hand.remove(data.rival.hand_select)
		new_rival_hand.append_array(data.rival.draw_indexes)
		for i in data.rival.draw_indexes:
			var c := rival.deck_list[i] as Card
			c.visible = true

	myself.set_hand(new_my_hand)
	rival.set_hand(new_rival_hand)

	var tween := create_tween()
	if my_select_id >= 0:
		var my_playing_card := myself.deck_list[my_select_id] as Card
		tween.tween_property(my_playing_card,"global_position",my_discard_pos,0.5)
	if rival_select_id >= 0:
		var rival_playing_card := rival.deck_list[rival_select_id] as Card
		tween.parallel()
		tween.tween_property(rival_playing_card,"global_position",rival_discard_pos,0.5)

#
	round_count = data.round_count
	phase = data.next_phase

	if (data.next_phase == IGameServer.Phase.RECOVERY and
			data.myself.damage == 0):
		game_server._send_recovery_select(data.round_count,-1)
	else:
		$UILayer/MyField/HandArea.ban_drag(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



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
		$LargeCardLayer/LargeCardView.show_layer(card.data)

func _on_RivalHandArea_held_card(_index:int,card:Card):
	if card != null:
		$LargeCardLayer/LargeCardView.show_layer(card.data)

func _on_held_card(card:Card):
	if card != null:
		$LargeCardLayer/LargeCardView.show_layer(card.data)


func _on_MyPlayed_clicked_card(_card):
	pass # Replace with function body.


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


