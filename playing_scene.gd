extends Node



var game_server : IGameServer = null
var commander

func _ready():
	var cc := Global.card_catalog
	
	if game_server == null:
		game_server = OfflineServer.new("Tester",cc)
		
	game_server.connect("data_recieved",self,"_on_GameServer_data_recieved")
	pass # Replace with function body.

func _on_GameServer_data_recieved(data:IGameServer.UpdateData):
	pass


func initialize(server:IGameServer):
	var data = server._get_initial_data()
	data.myname
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
