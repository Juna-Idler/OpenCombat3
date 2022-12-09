# warning-ignore-all:return_value_discarded

extends IGameServer

class_name OnlineServer

signal connecting()
signal connected()
signal matched()
signal disconnected()

var _primary_data :IGameServer.PrimaryData = null


var _client := WebSocketClient.new()
var version_string : String
var is_ws_connected := false

func _init():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")


func initialize(url : String,ver : String, protocols = PoolStringArray()) -> bool:
	is_ws_connected = false
	version_string = ver
	_primary_data = null
	var err = _client.connect_to_url(url,protocols)
	if err != OK:
		return false
	emit_signal("connecting")
	return true

func terminalize():
	_client.disconnect_from_host()

func send_match(name :String, deck :Array, regulation :String):
	if not is_ws_connected:
		emit_signal("recieved_end","disconnected")
	var send := """{"type":"Match","data":{"regulation":"%s","name":"%s","deck":[%s]}}"""\
			% [regulation,name,PoolStringArray(deck).join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())


func _closed(_was_clean = false):
	is_ws_connected = false
	_primary_data = null
	emit_signal("disconnected")
	emit_signal("recieved_end","disconnected")
	

func _connected(_proto = ""):
	var send := """{"type":"Version","data":{"version":"%s"}}""" % version_string
	_client.get_peer(1).put_packet(send.to_utf8())


func _on_data():
	var json_string = _client.get_peer(1).get_packet().get_string_from_utf8()
	var j := JSON.parse(json_string)
	if j.error != OK or not j.result is Dictionary:
		return
	var type = (j.result as Dictionary).get("type")
	var data = (j.result as Dictionary).get("data")
	if type == null or data == null:
		return
		
	match (type):
		"Version":
			if data["result"]:
				is_ws_connected = true
				emit_signal("connected")
			else:
				terminalize()
			
		"Primary":
#			var dr = RegulationData.DeckRegulation.new()
			_primary_data = IGameServer.PrimaryData.new(data["name"],data["deck"],
					data["rname"],data["rdeck"],
					RegulationData.DeckRegulation.create(data["deck_regulation"]),
					RegulationData.MatchRegulation.create(data["match_regulation"]))
			emit_signal("matched")

		"First":
			var myself = IGameServer.FirstData.PlayerData.new(data["you"]["hand"],data["you"]["life"])
			var rival = IGameServer.FirstData.PlayerData.new(data["rival"]["hand"],data["rival"]["life"])
			var first = IGameServer.FirstData.new(myself,rival)
			emit_signal("recieved_first_data",first)
		
		"Combat":
			var y := data["y"] as Dictionary
			var r := data["r"] as Dictionary
			var ys_logs := []
			var rs_logs := []
			for sl in (y["s"] as Array):
				ys_logs.append(IGameServer.UpdateData.SkillLog.new(sl["i"],sl["t"],sl["p"],sl["d"]))
			for sl in (r["s"] as Array):
				rs_logs.append(IGameServer.UpdateData.SkillLog.new(sl["i"],sl["t"],sl["p"],sl["d"]))
			var myself := IGameServer.UpdateData.PlayerData.new(y["h"],y["i"],ys_logs,y["dc"],y["d"],y["l"],y["t"])
			var rival := IGameServer.UpdateData.PlayerData.new(r["h"],r["i"],rs_logs,r["dc"],r["d"],r["l"],r["t"])
			var update := IGameServer.UpdateData.new(data["rc"],data["np"],data["ls"],myself,rival)
			emit_signal("recieved_combat_result",update)
				
		"Recovery":
			var y := data["y"] as Dictionary
			var r := data["r"] as Dictionary
			var myself := IGameServer.UpdateData.PlayerData.new(y["h"],y["i"],[],y["dc"],y["d"],y["l"],y["t"])
			var rival := IGameServer.UpdateData.PlayerData.new(r["h"],r["i"],[],r["dc"],r["d"],r["l"],r["t"])
			var update := IGameServer.UpdateData.new(data["rc"],data["np"],0,myself,rival)
			emit_signal("recieved_recovery_result",update)
				
		"End":
			var msg := data["msg"] as String
			emit_signal("recieved_end",msg)
			



func _get_primary_data() -> PrimaryData:
	return _primary_data

func _send_ready():
	if not is_ws_connected:
		return
	var send := """{"type":"Ready","data":{}}"""
	_client.get_peer(1).put_packet(send.to_utf8())


func _send_combat_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	if not is_ws_connected:
		return
	var phase = round_count * 2
	var hand := PoolStringArray(Array(hands_order))
	var send := """{"type":"Select","data":{"p":%s,"i":%s,"h":[%s]}}"""\
			% [phase,index,hand.join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())

func _send_recovery_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	if not is_ws_connected:
		return
	if index < 0:
		return
	var phase = round_count * 2 + 1
	var hand := PoolStringArray(Array(hands_order))
	var send := """{"type":"Select","data":{"p":%s,"i":%s,"h":[%s]}}"""\
			% [phase,index,hand.join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())


func _send_surrender():
	if not is_ws_connected:
		return
	var send := """{"type":"End","data":{"msg":"Surrender"}}"""
	_client.get_peer(1).put_packet(send.to_utf8())



