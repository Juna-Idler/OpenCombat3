extends Node

export var websocket_url := "https://127.0.0.1:8080"

var _server := OnlineServer.new()

func _init():
	_server.connect("connected",self,"_on_Server_connected")
	_server.connect("matched",self,"_on_Server_matched")
	pass


func initialize():
	_server.initialize(websocket_url,Global.card_catalog.version)


func terminalize():
	_server._terminalize()
	
func is_connecting():
	return _server.is_connecting
	

func _on_Server_connected():
	print("connected")
	pass
	
func _on_Server_matched():
	print("matched")
	pass

func _process(_delta):
	_server._client.poll()
	
