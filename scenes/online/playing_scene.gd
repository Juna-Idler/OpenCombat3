extends ISceneChanger.IScene

var scene_changer : ISceneChanger


func initialize(server : IGameServer,changer : ISceneChanger):
	
	scene_changer = changer

	game_server = server
	game_server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.connect("recieved_end",self,"_on_GameServer_recieved_end")

func _terminalize():
	game_server.disconnect("recieved_first_data",self,"_on_GameServer_recieved_first_data")
	game_server.disconnect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
	game_server.disconnect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")
	game_server.disconnect("recieved_end",self,"_on_GameServer_recieved_end")


func _ready():
	pass
