# warning-ignore-all:return_value_discarded

extends Node


var server := OnlineServer.new()


func _init():
	server.connect("connecting",self,"_on_Server_connecting")
	server.connect("disconnected",self,"_on_Server_disconnected")

func _ready():
	set_process(false)
	

func terminalize():
	server.terminalize()


func is_ws_connected():
	return server.is_ws_connected
	

func _on_Server_connecting():
	print("connecting")
	set_process(true)

	
func _on_Server_disconnected():
	print("disconnected")
	set_process(false)
	

func _process(_delta):
	server._client.poll()
	
