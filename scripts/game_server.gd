# warning-ignore-all:unused_signal

extends Reference
class_name IGameServer

# 何らかの事情でゲームを強制終了する時のシグナル
signal recieved_end(msg)
# func _on_GameServer_recieved_end(msg:String)->void:

# 1ターン目の情報を受信した時のシグナル
signal recieved_first_data(first_data)
# func _on_GameServer_recieved_first_data(data:FirstData)->void:

signal recieved_combat_result(data)
# func _on_GameServer_recieved_combat_result(data:UpdateData)->void:
signal recieved_recovery_result(data)
# func _on_GameServer_recieved_recovery_result(data:UpdateData)->void:

signal recieved_complete_board(data)
# func _on_GameServer_recieved_complete_board(data:CompleteData)->void:


enum  Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}
enum  Situation {INFERIOR = -1,EVEN = 0,SUPERIOR = 1}

enum SkillTiming {BEFORE = 0,ENGAGED = 1,AFTER = 2,END = 3}


class PrimaryData:
	var my_deck_list : PoolIntArray# of int
	var rival_deck_list : PoolIntArray# of int
	var my_name:String
	var rival_name:String
	var deck_regulation : RegulationData.DeckRegulation
	var match_regulation : RegulationData.MatchRegulation

	func _init(name:String,deck:PoolIntArray,rname:String,rdeck:PoolIntArray,
			dr:RegulationData.DeckRegulation,mr:RegulationData.MatchRegulation):
		my_deck_list = deck
		rival_deck_list = rdeck
		my_name = name
		rival_name = rname
		deck_regulation = dr
		match_regulation = mr


class FirstData:
	class PlayerData:
		var hand : PoolIntArray # of int
		var life : int
		
		func _init(h : PoolIntArray,l : int):
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
		var index : int # select card skill index
		var timing : int
		var priority : int
		var data # skill proper data
		
		func _init(i,t,p,d):
			index = i
			timing = t
			priority = p
			data = d

	class PlayerData:
		var hand:PoolIntArray # of int
		var select:int
		var skill_logs:Array # of SkillLog
		var draw:PoolIntArray # of int
		var damage:int
		var life:int
		var time:int
		
		func _init(h,s,sl,dc,d,l,t):
			hand = h
			select = s
			skill_logs = sl
			draw = dc
			damage = d
			life = l
			time = t

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
func _send_combat_select(_round_count:int,_index:int,_hands_order:PoolIntArray = []):
	pass
#
func _send_recovery_select(_round_count:int,_index:int,_hands_order:PoolIntArray = []):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass



class CompleteData:
	var round_count : int
	var next_phase : int

	class Affected:
		var power : int
		var hit : int
		var block : int
		func _init(p,h,b):
			power = p
			hit = h
			block = b

	class PlayerData:
		var hand:PoolIntArray
		var played:PoolIntArray
		var discard:PoolIntArray
		var stock:int
		var life:int
		var damage:int
		var next_effect:Affected
		var affected_list:Array
		var additional_deck:PoolIntArray
		
		func _init(hc,pc,dc,s,l,d,ne,al,ad):
			hand = hc
			played = pc
			discard = dc
			stock = s
			life = l
			damage = d
			next_effect = ne
			affected_list = al
			additional_deck = ad

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc,np,m,r):
		round_count = rc
		next_phase = np
		myself = m
		rival = r
