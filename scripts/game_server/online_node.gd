extends Node


signal connected()
signal matched()

var _server := OnlineServer.new()


func _init():
	_server.connect("connected",self,"_on_Server_connected")
	_server.connect("matched",self,"_on_Server_matched")
	pass


func initialize(url : String) -> bool:
	return _server.initialize(url,Global.card_catalog.version)


func terminalize():
	_server.terminalize()
	
func is_connecting():
	return _server.is_connecting
	

func _on_Server_connected():
	print("connected")
	emit_signal("connected")
	
func _on_Server_matched():
	print("matched")
	emit_signal("matched")


func _process(_delta):
	_server._client.poll()
	
