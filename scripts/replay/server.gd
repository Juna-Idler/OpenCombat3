extends IGameServer

class_name ReplayServer


var match_log : MatchLog

var step : int

var complete_board : Array # of IGameServer.CompleteData

var processor := GameProcessor.new()
var player1 : ReplayPlayer
var player2 : ReplayPlayer


func _init():
	pass

func initialize(m_log : MatchLog):
	step = -1
	match_log = m_log

	player1 = ReplayPlayer.new(match_log,false,Global.card_catalog)
	player2 = ReplayPlayer.new(match_log,true,Global.card_catalog)

	processor.standby(player1,player2)
	complete_board = []
	var cb = create_complete_board(processor)
	complete_board.append(cb)


func step_forward() -> int:
	if step < 0 or step >= match_log.update_data.size():
		return -1
	var data := match_log.update_data[step] as MatchLog.TimedUpdateData
	if data.phase == Phase.COMBAT:
		emit_signal("recieved_combat_result",data.data)
	elif data.phase == Phase.RECOVERY:
		emit_signal("recieved_recovery_result",data.data)
	step += 1
	if step >= complete_board.size():
		player1.set_step(step)
		player2.set_step(step)
		processor.reorder_hand1(data.data.myself.hand)
		processor.reorder_hand2(data.data.rival.hand)
		if data.phase == Phase.COMBAT:
			processor.combat(data.data.myself.select,data.data.rival.select)
		elif data.phase == Phase.RECOVERY:
			processor.recover(data.data.myself.select,data.data.rival.select)
		var cb = create_complete_board(processor)
		complete_board.append(cb)
	return step

func step_backward() -> int:
	if step <= 0:
		return step
	step -= 1
	emit_signal("recieved_complete_board",complete_board[step])
	return step

func emit_end_signal():
	emit_signal("recieved_end",match_log.end_msg)

func _get_primary_data() -> PrimaryData:
	return match_log.primary_data

func _send_ready():
	emit_signal("recieved_first_data",match_log.first_data)
	step = 0
func _send_combat_select(_round_count:int,_index:int,_hands_order:PoolIntArray = []):
	pass
func _send_recovery_select(_round_count:int,_index:int,_hands_order:PoolIntArray = []):
	pass
func _send_surrender():
	pass


static func create_complete_board(p : GameProcessor) -> IGameServer.CompleteData:
	return IGameServer.CompleteData.new(p.round_count,p.phase,
			create_complete_player_data(p.player1),
			create_complete_player_data(p.player2))

static func create_complete_player_data(player : MechanicsData.IPlayer) -> IGameServer.CompleteData.PlayerData:
	var al = []
	for i in player._get_deck_list():
		var a = (i as MechanicsData.PlayerCard).affected
		al.append(IGameServer.CompleteData.Affected.new(a.power,a.hit,a.block))
	
	var ne = player._get_next_effect()
	return IGameServer.CompleteData.PlayerData.new(player._get_hand(),player._get_played(),player._get_discard(),
			player._get_stock_count(),player._get_life(),player._get_damage(),
			IGameServer.CompleteData.Affected.new(ne.power,ne.hit,ne.block),
			al,player._get_additional_deck())

