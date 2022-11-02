extends IGameServer

class_name OnlineServer


signal connected()
signal matched()


var _primary_data :IGameServer.PrimaryData = null


var _client := WebSocketClient.new()
var version_string : String
var is_connecting := false

func _init():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")


func initialize(url : String,ver : String, protocols = PoolStringArray()) -> bool:
	is_connecting = false
	version_string = ver
	_primary_data = null
	var err = _client.connect_to_url(url,protocols)
	if err != OK:
		return false
	return true


func send_match(name :String, deck :Array, regulation :String):
	if not is_connecting:
		return
	var send := """{"type":"Match","data":{"regulation":"%s","name":"%s","deck":[%s]}}"""\
			% [regulation,name,PoolStringArray(deck).join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())


func _closed(was_clean = false):
	is_connecting = false
	_primary_data = null

func _connected(proto = ""):
	var send := """{"type":"Version","data":{"version":"%s"}}""" % version_string
	_client.get_peer(1).put_packet(send.to_utf8())



func _on_data():
	var j := JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8())
	if j.error != OK or not j.result is Dictionary:
		return
	var type = (j.result as Dictionary).get("type")
	var data = (j.result as Dictionary).get("data")
	if type == null or data == null:
		return
		
	match (type):
		"Version":
			if data["result"]:
				is_connecting = true
				emit_signal("connected")
			else:
				_terminalize()
			
		"Primary":
			_primary_data = IGameServer.PrimaryData.new(data["name"],data["deck"],
					data["rname"],data["rdeck"],data["regulation"])
			emit_signal("matched")

		"First":
			var myself = IGameServer.FirstData.PlayerData.new(data["you"]["hand"],data["you"]["life"])
			var rival = IGameServer.FirstData.PlayerData.new(data["rival"]["hand"],data["rival"]["life"])
			var first = IGameServer.FirstData.new(myself,rival)
			emit_signal("recieved_first_data",first)
			
		"Recovery","Combat":
			var y := data["y"] as Dictionary
			var r := data["r"] as Dictionary
			var yu := []
			var ru := []
			for ua in (y["u"] as Array):
				yu.append(IGameServer.UpdateData.Updated.new(ua))
			for ua in (r["u"] as Array):
				ru.append(IGameServer.UpdateData.Updated.new(ua))
			var myself := IGameServer.UpdateData.PlayerData.new(y["h"],y["s"],
					yu,y["np"],y["nh"],y["nb"],y["dc"],y["d"],y["l"])
			var rival := IGameServer.UpdateData.PlayerData.new(r["h"],r["s"],
					ru,r["np"],r["nh"],r["nb"],r["dc"],r["d"],r["l"])
			var update = IGameServer.UpdateData.new(data["r"],data["n"],data["s"],myself,rival)
			if type == "Combat":
				emit_signal("recieved_combat_result",update)
			else:
				emit_signal("recieved_recovery_result",update)



func _get_primary_data() -> PrimaryData:
	return _primary_data

func _send_ready():
	var send := """{"type":"Ready","data":{}}"""
	_client.get_peer(1).put_packet(send.to_utf8())


func _send_combat_select(round_count:int,index:int,hands_order:Array = []):
	var phase = round_count * 2
	var hand := PoolStringArray(hands_order)
	var send := """{"type":"Select","data":{"p":%s,"i":%s,"h":[%s]}}"""\
			% [phase,index,hand.join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())

func _send_recovery_select(round_count:int,index:int,hands_order:Array = []):
	var phase = round_count * 2 + 1
	var hand := PoolStringArray(hands_order)
	var send := """{"type":"Select","data":{"p":%s,"i":%s,"h":[%s]}}"""\
			% [phase,index,hand.join(",")]
	_client.get_peer(1).put_packet(send.to_utf8())


func _send_surrender():
	var send := """{"type":"Surrender","data":{}}"""
	_client.get_peer(1).put_packet(send.to_utf8())

# このインターフェイスの破棄
func _terminalize():
	_client.disconnect_from_host()
