extends Node


signal connected()
signal matched()

var server := OnlineServer.new()


func _init():
	server.connect("connected",self,"_on_Server_connected")
	server.connect("matched",self,"_on_Server_matched")
	server.connect("disconnected",self,"_on_Server_disconnected")

	set_process(false)


func initialize(url : String) -> bool:
	return server.initialize(url,Global.card_catalog.version)


func terminalize():
	server.terminalize()
	set_process(false)
	
func is_connecting():
	return server.is_connecting
	

func _on_Server_connected():
	print("connected")
	emit_signal("connected")
	set_process(true)
	
func _on_Server_matched():
	print("matched")
	emit_signal("matched")
	
func _on_Server_disconnected():
	print("disconnected")
	emit_signal("disconnected")
	set_process(false)
	

func _process(_delta):
	server._client.poll()
	
