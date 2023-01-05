
class_name MatchLog


class TimedUpdateData:
	var time : int
	var phase : int
	var data : IGameServer.UpdateData
	func _init(t,p,d):
		time = t
		phase = p
		data = d
	
	func to_json_dictionary() -> Dictionary:
		var m = _update_player_to_json(data.myself)
		var r = _update_player_to_json(data.rival)
		return {"t":time,"p":phase,"d":{"rc":data.round_count,
				"np":data.next_phase,"ls":data.situation,"m":m,"r":r}}

	static func from_json_dictionary(json : Dictionary) -> TimedUpdateData:
		var d : Dictionary = json["d"]
		var m = _update_player_from_json(d["m"])
		var r = _update_player_from_json(d["r"])
		var ud = IGameServer.UpdateData.new(d["rc"],d["np"],d["ls"],m,r)
		return TimedUpdateData.new(json["t"],json["p"],ud)

	static func _update_player_to_json(player ) -> Dictionary:
		var logs : Array = []
		for i in player.effect_logs:
			logs.append({"i":i.index,"t":i.timing,"p":i.priority,"d":i.data})
		return {"h":player.hand,"i":player.select,"s":logs,"dc":player.draw,
				"d":player.damage,"l":player.life,"t":player.time}
	
	static func _update_player_from_json(json : Dictionary):# -> IGameServer.UpdateData.PlayerData:
		var logs := []
		for l in (json["s"] as Array):
			logs.append(IGameServer.UpdateData.EffectLog.new(l["i"],l["t"],l["p"],l["d"]))
		return IGameServer.UpdateData.PlayerData.new(json["h"],json["i"],logs,
				json["dc"],json["d"],json["l"],json["t"])


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

var datetime : String
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
	datetime = Time.get_datetime_string_from_system(false,true)
	first_data = data
	_first_time = Time.get_ticks_msec()

func add_update_data(data:IGameServer.UpdateData,phase : int):
	update_data.append(TimedUpdateData.new(Time.get_ticks_msec() - _first_time,phase,data))
	if data.next_phase == IGameServer.Phase.GAME_END:
		_first_time = -1

func add_send_select(rc,i,ho):
	send_select.append(TimedSendSelect.new(Time.get_ticks_msec() - _first_time,rc,i,ho))


func to_json_dictionary() -> Dictionary:
	var dic = {
		"date":datetime,
		"end":{"msg":end_msg,"time":end_time},
		"pd":{
			"name":primary_data.my_name,"deck":primary_data.my_deck_list,
			"rname":primary_data.rival_name,"rdeck":primary_data.rival_deck_list,
			"dreg":primary_data.deck_regulation.to_regulation_string(),
			"mreg":primary_data.match_regulation.to_regulation_string()
		},
		"fd":{
			"hand":first_data.myself.hand,"life":first_data.myself.life,"time":first_data.myself.time,
			"rhand":first_data.rival.hand,"rlife":first_data.rival.life,"rtime":first_data.rival.time
		},
		"ud":[]
	}
	var ud = []
	for u_ in update_data:
		var u = u_ as TimedUpdateData
		ud.append(u.to_json_dictionary())
	dic["ud"] = ud
	return dic
	
func from_json_dictionary(json : Dictionary) -> void:
	if json.has("date"):
		datetime = json["date"]
	end_msg = json["end"]["msg"]
	end_time = json["end"]["time"]
	primary_data = IGameServer.PrimaryData.new(json["pd"]["name"],json["pd"]["deck"],
			json["pd"]["rname"],json["pd"]["rdeck"],
			RegulationData.DeckRegulation.create(json["pd"]["dreg"]),
			RegulationData.MatchRegulation.create(json["pd"]["mreg"]))
	first_data = IGameServer.FirstData.new(
			IGameServer.FirstData.PlayerData.new(json["fd"]["hand"],json["fd"]["life"],json["fd"]["time"]),
			IGameServer.FirstData.PlayerData.new(json["fd"]["rhand"],json["fd"]["rlife"],json["fd"]["rtime"]))
	update_data = []
	for u in json["ud"]:
		update_data.append(TimedUpdateData.from_json_dictionary(u))

