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

signal recieved_combat_result(data,situation)
# func _on_GameServer_recieved_combat_result(data:UpdateData,situation:int)->void:
# server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
signal recieved_recovery_result(data)
# func _on_GameServer_recieved_recovery_result(data:UpdateData)->void:
# server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

enum  Phase {GAMEFINISH = -1,COMBAT = 0,RECOVERY = 1}
enum  Situation {INFERIOR = -1,EVEN = 0,SUPERIOR = 1}


class PrimaryData:
	var my_deck_list : Array# of int
	var rival_deck_list : Array# of int
	var my_name:String
	var rival_name:String
	var regulation :String

	func _init(name:String,deck:Array,rname:String,rdeck:Array,reg):
		my_deck_list = deck
		rival_deck_list = rdeck
		my_name = name
		rival_name = rname
		regulation = reg


class FirstData:
	class PlayerData:
		var hand : Array# of int
		var life : int
		
		func _init(h : Array,l : int):
			hand = h
			life = l
	var myself:PlayerData
	var rival:PlayerData

	func _init(p1:PlayerData,p2:PlayerData):
		myself = p1
		rival = p2


class UpdateData:
	var round_count : int
	var next_phase : int
	var situation : int

	class Updated:
		var index : int
		var card : int
		var power : int = 0
		var hit : int = 0
		var block : int = 0
		
		func _init(a : Array):
			index = a[0]
			card = a[1]
			power = a[2]
			hit = a[3]
			block = a[4]
	
	class PlayerData:
		var hand : Array# of int
		var select:int
		var updates : Array# of Updated
		var next_power : int
		var next_hit : int
		var next_block : int
		var draw:Array# of int
		var damage : int
		var life : int
		
		func _init(h,s,u,np,nh,nb,d,da,l):
			hand = h
			select = s
			updates = u
			next_power = np
			next_hit = nh
			next_block = nb
			draw = d
			damage = da
			life = l

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(c:int,p:int,s:int,p1:PlayerData,p2:PlayerData):
		round_count = c
		next_phase = p
		situation = s
		myself = p1
		rival = p2


 # 初期データ（このゲームのルールパラメータとかマッチング時に提出したお互いのデータ）
 # インターフェイスを利用する側はこれが有効になった状態（マッチングが完了した状態）で渡される
func _get_primary_data() -> PrimaryData:
	return null
	

# ゲーム開始準備完了を送信
# これ以後、サーバからrecieved_first_data,recieved_XXX_resultが発生する
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

