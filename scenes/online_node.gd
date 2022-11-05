extends Node


signal connected()
signal matched()

var server := OnlineServer.new()


func _init():
	server.connect("connecting",self,"_on_Server_connecting")
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")

func _ready():
	set_process(false)
	


func initialize(url : String) -> bool:
	return server.initialize(url,Global.card_catalog.version)


func terminalize():
	server.terminalize()


func is_ws_connected():
	return server.is_ws_connected
	

func _on_Server_connecting():
	print("connecting")
	set_process(true)
	emit_signal("connecting")

func _on_Server_connected():
	print("connected")
	emit_signal("connected")
	
func _on_Server_matched():
	print("matched")
	emit_signal("matched")
	
func _on_Server_disconnected():
	print("disconnected")
	emit_signal("disconnected")
	set_process(false)
	

func _process(_delta):
	server._client.poll()
	
