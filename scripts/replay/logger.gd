extends IGameServer

class_name MatchLogger

var server : IGameServer

var match_log : MatchLog



func _init():
	pass

func initialize(target_server : IGameServer):
	server = target_server
	server.connect("recieved_end",self,"_on_GameServer_recieved_end")
	server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

	match_log = MatchLog.new()



func _get_primary_data() -> PrimaryData:
	match_log.set_primary_data(server._get_primary_data())
	return match_log.primary_data


func _send_ready():
	server._send_ready()

func _send_combat_select(round_count:int,index:int,hands_order:Array = []):
	match_log.add_send_select(round_count,index,hands_order)
	server._send_combat_select(round_count,index,hands_order)

func _send_recovery_select(round_count:int,index:int,hands_order:Array = []):
	match_log.add_send_select(round_count,index,hands_order)
	server._send_recovery_select(round_count,index,hands_order)

func _send_surrender():
	server._send_surrender()
	

func _on_GameServer_recieved_end(msg:String)->void:
	match_log.set_end_msg(msg)
	emit_signal("recieved_end",msg)

func _on_GameServer_recieved_first_data(data:FirstData)->void:
	match_log.set_first_data(data)
	emit_signal("recieved_first_data",data)

func _on_GameServer_recieved_combat_result(data:UpdateData)->void:
	match_log.add_update_data(data,Phase.COMBAT)
	emit_signal("recieved_combat_result",data)
	
func _on_GameServer_recieved_recovery_result(data:UpdateData)->void:
	match_log.add_update_data(data,Phase.RECOVERY)
	emit_signal("recieved_recovery_result",data)

