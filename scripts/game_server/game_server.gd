extends Reference
class_name IGameServer

# サーバからの通信を受信するコールバック
signal data_recieved

# func _on_data_recieved(data:UpdateData)

class UpdateData:
	var phase:int
	var damage:int
	class PlayerData:
		var draw:Array
		var select:int
		var deckcount:int
	var myself:PlayerData
	var rival:PlayerData

class InitialData:
	var battleSelectTimeLimitSecond:int
	var damageSelectTimeLimitSecond:int
	var myname:String
	var rivalname:String

# 初期データ（このゲームのルールパラメータとマッチング時に提出したお互いのデータ）
func _get_initial_data() -> InitialData:
	return InitialData.new()
	pass
	
# ゲーム開始準備完了を送信
# これ以後、サーバからゲーム進行のUpdateCallbackが呼び出される
func _send_ready():
	pass

# ゲームでの選択を送信
func _send_select(phase:int,index:int):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass

# このインターフェイスの破棄
func _terminalize():
	pass
