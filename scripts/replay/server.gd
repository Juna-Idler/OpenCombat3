extends IGameServer

class_name ReplayServer


var match_log : MatchLog

var step : int

func _init():
	pass

func initialize(log_data : MatchLog):
	step = -1
	pass

func play_one_step():
	if step < 0:
		emit_signal("recieved_first_data",match_log.first_data)
		step = 0
	else:
		if step < match_log.update_data.size():
			var data := match_log.update_data[step] as MatchLog.TimedUpdateData
			if data.phase == Phase.COMBAT:
				emit_signal("recieved_combat_result",data.data)
			elif data.phase == Phase.RECOVERY:
				emit_signal("recieved_recovery_result",data.data)
			step += 1


func _get_primary_data() -> PrimaryData:
	return match_log.primary_data

func _send_ready():
	pass
func _send_combat_select(round_count:int,index:int,hands_order:Array = []):
	pass
func _send_recovery_select(round_count:int,index:int,hands_order:Array = []):
	pass
func _send_surrender():
	pass


