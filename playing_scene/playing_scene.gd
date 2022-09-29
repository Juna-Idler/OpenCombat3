extends Node

const Card = preload("res://playing_scene/card/card.tscn")

var game_server : IGameServer = null
var commander : ICpuCommander = null

var round_count = 0
var phase : int = IGameServer.Phase.COMBAT
var player : Player
var rival : Player

func _ready():
	var cc := Global.card_catalog
	
#	if game_server == null:
	var offline := OfflineServer.new("Tester",cc)
	game_server = offline
	var e = game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
# warning-ignore:return_value_discarded
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

	var deck = []
	for i in range(27):
		deck.append(i+1)
	offline.standby_single(deck,0)
	
	
# warning-ignore:return_value_discarded

# warning-ignore:unused_variable
	var pd := game_server._get_primary_data()
	var cdeck := []
	for i in range(pd.my_deck_list.size()):
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.my_deck_list[i])) as Card
		cdeck.append(c)
		c.position = $UILayer/MyField/Stack.rect_global_position
		$CardLayer.add_child(c)	
	var rcdeck := []
	for i in range(pd.rival_deck_list.size()):
		var c := Card.instance().initialize_card(i,cc.get_card_data(pd.rival_deck_list[i]),true) as Card
		rcdeck.append(c)
		c.position = $UILayer/RivalField/Stack.rect_global_position
		$CardLayer.add_child(c)	
	
	player = Player.new(cdeck,pd.my_name,$UILayer/MyField/HandArea)
	rival = Player.new(rcdeck,pd.rival_name,$UILayer/RivalField/HandArea)
	
	game_server._send_ready()
	

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData):
	phase = IGameServer.Phase.COMBAT
	round_count = 1
	player.set_hand(data.myself.hand_indexes)
	rival.set_hand(data.rival.hand_indexes)
	
func _on_GameServer_recieved_combat_result(data:IGameServer.UpdateData,_situation:int):
	var my_select_id : int = data.myself.hand_indexes[data.myself.hand_select]
	data.myself.hand_indexes.remove(data.myself.hand_select)
	var rival_select_id : int = data.rival.hand_indexes[data.rival.hand_select]
	data.rival.hand_indexes.remove(data.rival.hand_select)
	player.set_hand(data.myself.hand_indexes)
	rival.set_hand(data.rival.hand_indexes)
	
	$UILayer/MyField/HandArea.ban_drag(false)
	round_count = data.round_count
	phase = data.next_phase



func _on_GameServer_recieved_recovery_result(data:IGameServer.UpdateData):
	var my_select_id : int = data.myself.hand_indexes[data.myself.hand_select]
	data.myself.hand_indexes.remove(data.myself.hand_select)
	var rival_select_id : int = data.rival.hand_indexes[data.rival.hand_select]
	data.rival.hand_indexes.remove(data.rival.hand_select)
	player.set_hand(data.myself.hand_indexes)
	rival.set_hand(data.rival.hand_indexes)
	
	$UILayer/MyField/HandArea.ban_drag(false)
	round_count = data.round_count
	phase = data.next_phase


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
