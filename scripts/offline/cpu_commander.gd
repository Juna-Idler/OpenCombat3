
class_name ICpuCommander

class Player:
	var hand : PoolIntArray
	var played : PoolIntArray
	var discard : PoolIntArray
	
	var stock_count : int
	var life : int
	var next_effect : MechanicsData.Affected
	
	func _init(h,p,d,s,l,n):
		hand = h
		played = p
		discard = d
		stock_count = s
		life = l
		next_effect = n


func _get_commander_name()-> String:
	return ""

func _set_deck_list(_mydeck : PoolIntArray,_rivaldeck : PoolIntArray):
	return

func _first_select(_myhand : PoolIntArray, _rivalhand : PoolIntArray)-> int:
	return 0

func _combat_select(_myself : Player,_rival : Player)-> int:
	return 0

func _recover_select(_myself : Player,_rival : Player)-> int:
	return 0

