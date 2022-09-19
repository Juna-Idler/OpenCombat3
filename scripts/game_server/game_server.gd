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


# 2ターン目以降の情報を受信した時のシグナル
signal recieved_update_data(update_data)
# func _on_GameServer_recieved_update_data(data:UpdateData)->void:
# 
# server.connect("recieved_update_data",self,"_on_GameServer_recieved_update_data")

class UpdateData:
	var phase : int
	
	class Affected:
		var id : int
		var power : int = 0
		var hit : int = 0
		var damage : int = 0
		var rush : int = 0
		
		func _init(pid:int,ppower:int,phit:int,pdamage:int,prush:int):
			id = pid
			power= ppower
			hit = phit
			damage = pdamage
			rush = prush
	
	class PlayerData:
		var hand_indexes : Array# of int
		var hand_select:int
		var cards_update : Array# of Affected
		var next_effect : Affected
		var draw_indexes:Array# of int
		var damage : int
		var life : int
		
		func _init(hi,hs,cu,ne,di,d,l):
			hand_indexes = hi
			hand_select = hs
			cards_update = cu
			next_effect = ne
			draw_indexes = di
			damage = d
			life = l
	
	var myself:PlayerData
	var rival:PlayerData
	
	func _init(p:int,p1:PlayerData,p2:PlayerData):
		phase = p
		myself = p1
		rival = p2


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

# 選択した手札を送信。手札の位置を入れ替えた場合はそれも
func _send_select(phase:int,index:int,hands_order:Array):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass

# このインターフェイスの破棄
func _terminalize():
	pass


# 現状の（差分ではない）完全データを要求する
func _get_complete_data() -> CompleteData:
	return null


class CompleteData:
	var InitialData : PrimaryData
	var phase : int

	class PlayerData:
		var hand_indexes : Array# of int
		var played_indexes : Array# of int
		var discard_indexes : Array# of int
		var stack_count : int
		var cards_affected : Array# of Affected
		var next_effect : UpdateData.Affected
		var damage : int
		var life : int
		
	var myself:PlayerData
	var rival:PlayerData
