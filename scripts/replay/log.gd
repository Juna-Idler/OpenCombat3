
class_name MatchLog


class TimedUpdateData:
	var time : int
	var phase : int
	var data : IGameServer.UpdateData
	func _init(t,p,d):
		time = t
		phase = p
		data = d
	
	func to_json_string() -> String:
		var m_json = _update_player_to_json(data.myself)
		var r_json = _update_player_to_json(data.rival)
		return """{"t":%s,"p":%s,"d":{"rc":%s,"np":%s,"ls":%s,"m":%s,"r":%s}}"""\
				% [time,phase,data.round_count,data.next_phase,data.situation,m_json,r_json]

	static func from_json_string(json : String) -> TimedUpdateData:
		var r := JSON.parse(json)
		if r.error != OK:
			return null
		var d : Dictionary = r.result["d"]
		var m_player = _update_player_from_json(d["m"])
		var r_player = _update_player_from_json(d["r"])
		var ud = IGameServer.UpdateData.new(d["rc"],d["np"],d["ls"],m_player,r_player)
		return TimedUpdateData.new(r.result["t"],r.result["p"],ud)

	static func _update_player_to_json(player : IGameServer.UpdateData.PlayerData) -> String:
		var logs : PoolStringArray = []
		for _i in player.skill_logs:
			var i = _i as IGameServer.UpdateData.SkillLog
			logs.append("""{"i":%s,"t":%s,"p":%s,"d":%s}""" % [i.index,i.timing,i.priority,JSON.print(i.data)])
		return """{"h":%s,"i":%s,"s":[%s],"dc":%s,"d":%s,"l":%s}"""\
				% [JSON.print(player.hand),player.select,logs.join(","),JSON.print(player.draw),player.damage,player.life]
		
	static func _update_player_from_json(json : Dictionary) -> IGameServer.UpdateData.PlayerData:
		var logs := []
		for l in (json["s"] as Array):
			logs.append(IGameServer.UpdateData.SkillLog.new(l["i"],l["t"],l["p"],l["d"]))
		return IGameServer.UpdateData.PlayerData.new(json["h"],json["i"],logs,json["dc"],json["d"],json["l"])


class TimedSendSelect:
	var time : int
	var round_count:int
	var index:int
	var hands_order:PoolIntArray
	func _init(t,rc,i,h):
		time = t
		round_count = rc
		index = i
		hands_order = h


var end_msg : String
var end_time : int
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
	end_time = -1

func set_end_msg(msg:String):
	if _first_time >= 0:
		end_time = Time.get_ticks_msec() - _first_time
		_first_time = -1
	end_msg = msg

func set_primary_data(data:IGameServer.PrimaryData):
	primary_data = data

func set_first_data(data:IGameServer.FirstData):
	first_data = data
	_first_time = Time.get_ticks_msec()

func add_update_data(data:IGameServer.UpdateData,phase : int):
	update_data.append(TimedUpdateData.new(Time.get_ticks_msec() - _first_time,phase,data))
	if data.next_phase == IGameServer.Phase.GAME_END:
		_first_time = -1

func add_send_select(rc,i,ho):
	send_select.append(TimedSendSelect.new(Time.get_ticks_msec() - _first_time,rc,i,ho))

