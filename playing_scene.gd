extends Node



var game_server : IGameServer = null
var commander : ICpuCommander = null

func _ready():
	var cc := Global.card_catalog
	
	if game_server == null:
		game_server = OfflineServer.new("Tester",cc)
		
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.connect("recieved_update_data",self,"_on_GameServer_recieved_update_data")
	
	var deck = [1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9]
	game_server.standby_single(deck,0)
	pass

func _on_GameServer_recieved_first_data(data:IGameServer.FirstData)->void:
	pass
	
func _on_GameServer_recieved_update_data(data:IGameServer.UpdateData)->void:
	pass


func initialize(server:IGameServer):
	var data = server._get_initial_data()
	data.myname
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
