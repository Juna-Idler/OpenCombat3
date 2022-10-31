
class_name DeckData

var name : String
var cards : PoolIntArray #of int (card id)
var key_cards : PoolIntArray #of int (card id)

func _init(d_name : String, d_cards : PoolIntArray, k_cards : PoolIntArray):
	cards = d_cards
	name = d_name
	key_cards = k_cards
	

class DeckFace:
	var name : String
	var key_cards : PoolIntArray #of int (card id)
	var cards_count : int
	var total_cost : int
	var level : PoolIntArray
	var color : PoolIntArray
	
	func _init(n:String,kc : PoolIntArray,
			count:int,cost:int,
			l:PoolIntArray,c:PoolIntArray):
		name = n
		key_cards = kc
		cards_count = count
		total_cost = cost
		level = l
		color = c
