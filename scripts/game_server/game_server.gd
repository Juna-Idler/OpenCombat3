extends Reference
class_name IGameServer

# サーバからの通信を受信するコールバック
signal data_recieved

# func _on_data_recieved(data:UpdateData)



class UpdateData:
	var phase : int
	
	class Affected:
		var id : int
		var power : int = 0
		var hit : int = 0
		var damage : int = 0
		var rush : int = 0
	
	class PlayerData:
		var new_hand_indexes : Array# of int
		var hand_select:int
		var cards_update : Array# of Affected
		var next_effect : Affected
		var draw_indexes:Array# of int
		var damage : int
		var hitpoint : int
	
	var myself:PlayerData
	var rival:PlayerData

class InitialData:
	var my_deck_list : Array# of int
	var rival_deck_list : Array# of int
	
	var my_name:String
	var rival_name:String
	
#	var battleSelectTimeLimitSecond:int
#	var damageSelectTimeLimitSecond:int

# 初期データ（このゲームのルールパラメータとマッチング時に提出したお互いのデータ）
func _get_initial_data() -> InitialData:
	return null
	
# ゲーム開始準備完了を送信
# これ以後、サーバからゲーム進行のUpdateCallbackが呼び出される
func _send_ready():
	pass

# ゲームでの選択を送信
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
	var InitialData : InitialData
	var phase : int

	class PlayerData:
		var hand_indexes : Array# of int
		var played_indexes : Array# of int
		var discard_indexes : Array# of int
		var stack_count : int
		var cards_affected : Array# of Affected
		var next_effect : UpdateData.Affected
		var damage : int
		var hitpoint : int
		
	var myself:PlayerData
	var rival:PlayerData
