
class_name MatchLog


class TimedUpdateData:
	var data : IGameServer.UpdateData
	var phase : int
	var time : int
	func _init(d,p,t):
		data = d
		phase = p
		time = t

class TimedSendSelect:
	var round_count:int
	var index:int
	var hands_order:Array
	var time : int
	func _init(rc,i,h,t):
		round_count = rc
		index = i
		hands_order = h
		time = t


var end_msg : String
var primary_data : IGameServer.PrimaryData
var first_data : IGameServer.FirstData
var update_data : Array # of TimedUpdateData
var send_select : Array # of TimedSendSelect

var _first_time : int

func _init():
	primary_data = null
	first_data = null
	update_data = []
	send_select = []
	_first_time = 0

func set_end_msg(msg:String):
	_first_time = -1
	end_msg = msg

func set_primary_data(data:IGameServer.PrimaryData):
	primary_data = data

func set_first_data(data:IGameServer.FirstData):
	first_data = data
	_first_time = Time.get_ticks_msec()

func add_update_data(data:IGameServer.UpdateData,phase : int):
	if data.next_phase == IGameServer.Phase.GAME_END:
		_first_time = -1
	update_data.append(TimedUpdateData.new(data,phase,Time.get_ticks_msec() - _first_time))

func add_send_select(rc,i,ho):
	send_select.append(TimedSendSelect.new(rc,i,ho,Time.get_ticks_msec() - _first_time))

