extends Reference
class_name IGameServer

# 何らかの事情でゲームを強制終了する時のシグナル
signal recieved_abort(winlose,message)
# func _on_GameServer_recieved_abort(winlose:int,message:String)->void:
# 
# server.connect("recieved_abort",self,"_on_GameServer_recieved_abort")

# 1ターン目の情報を受信した時のシグナル
signal recieved_first_data(first_data)
# func _on_GameServer_recieved_first_data(data:FirstData)->void:
# 
# server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")

class FirstData:
	class PlayerData:
		var hand_indexes : Array# of int
		var life : int
		
		func _init(hi : Array,l : int):
			hand_indexes = hi
			life = l
	var myself:PlayerData
	var rival:PlayerData

	func _init(p1:PlayerData,p2:PlayerData):
		myself = p1
		rival = p2


# 
signal recieved_combat_result(data,situation)
# func _on_GameServer_recieved_combat_result(data:UpdateData,situation:int)->void:
# server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
signal recieved_recovery_result(data)
# func _on_GameServer_recieved_recovery_result(data:UpdateData)->void:
# server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

enum  Phase {GAMEFINISH = -1,COMBAT = 0,RECOVERY = 1}
enum  Situation {INFERIOR = -1,EVEN = 0,SUPERIOR = 1}

class UpdateData:
	var round_count : int
	var next_phase : int

	class Affected:
		var id : int
		var power : int = 0
		var hit : int = 0
		var damage : int = 0
		var rush : int = 0
	
	class PlayerData:
		var hand_indexes : Array# of int
		var hand_select:int
		var cards_update : Array# of Affected
		var next_effect : Affected
		var draw_indexes:Array# of int
		var damage : int
		var life : int
	
	var myself:PlayerData
	var rival:PlayerData



# 初期データ（このゲームのルールパラメータとかマッチング時に提出したお互いのデータ）
func _get_primary_data() -> PrimaryData:
	return null
	
class PrimaryData:
	var my_deck_list : Array# of int
	var rival_deck_list : Array# of int
	var my_name:String
	var rival_name:String

	func _init(name:String,deck:Array,rname:String,rdeck:Array):
		my_deck_list = deck
		rival_deck_list = rdeck
		my_name = name
		rival_name = rname


# ゲーム開始準備完了を送信
# これ以後、サーバからrecieved_first_data,recieved_update_dataが発生する
func _send_ready():
	pass

#
func _send_combat_select(round_count:int,index:int,hands_order:Array = []):
	pass
#
func _send_recovery_select(round_count:int,index:int,hands_order:Array = []):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass

# このインターフェイスの破棄
func _terminalize():
	pass

