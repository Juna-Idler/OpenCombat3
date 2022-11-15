# warning-ignore-all:unused_signal

extends Reference
class_name IGameServer

# 何らかの事情でゲームを強制終了する時のシグナル
signal recieved_end(msg)
# func _on_GameServer_recieved_end(msg:String)->void:
# 
# server.connect("recieved_end",self,"_on_GameServer_recieved_end")

# 1ターン目の情報を受信した時のシグナル
signal recieved_first_data(first_data)
# func _on_GameServer_recieved_first_data(data:FirstData)->void:
# 
# server.connect("recieved_first_data",self,"_on_GameServer_recieved_first_data")

signal recieved_combat_result(data)
# func _on_GameServer_recieved_combat_result(data:UpdateData)->void:
# server.connect("recieved_combat_result",self,"_on_GameServer_recieved_combat_result")
signal recieved_recovery_result(data)
# func _on_GameServer_recieved_recovery_result(data:UpdateData)->void:
# server.connect("recieved_recovery_result",self,"_on_GameServer_recieved_recovery_result")

enum  Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}
enum  Situation {INFERIOR = -1,EVEN = 0,SUPERIOR = 1}

enum SkillTiming {BEFORE = 0,ENGAGEMENT = 1,AFTER = 2,END = 3}


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
		var hand : Array # of int
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

	class SkillLog:
		var timing : int
		var index : int # select card skill index
		var data # skill proper data
		
		func _init(t,i,d):
			timing = t
			index = i
			data = d

	class PlayerData:
		var hand : Array # of int
		var select:int
		var skill_logs : Array # of SkillLog
		var draw:Array # of int
		var damage : int
		var life : int
		
		func _init(h,s,sl,dc,d,l):
			hand = h
			select = s
			skill_logs = sl
			draw = dc
			damage = d
			life = l

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc:int,np:int,ls:int,p1:PlayerData,p2:PlayerData):
		round_count = rc
		next_phase = np
		situation = ls
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
func _send_combat_select(_round_count:int,_index:int,_hands_order:Array = []):
	pass
#
func _send_recovery_select(_round_count:int,_index:int,_hands_order:Array = []):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass


