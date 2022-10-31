extends Node

export var websocket_url := "wss://"

var _server := OnlineServer.new()
var parent_node : Node

func _init():
	_server.connect("connected",self,"_on_Server_connected")
	_server.connect("matched",self,"_on_Server_matched")
	pass


func initialize(url : String,parent : Node):
	parent.add_child(self)
	parent_node = parent
	_server.initialize(url)

func terminalize():
	_server._terminalize()
	parent_node.remove_child(self)
	
func is_connecting():
	return _server.is_connecting
	

func _on_Server_connected():
	pass
func _on_Server_matched():
	pass

func _process(_delta):
	_server._client.poll()
	
