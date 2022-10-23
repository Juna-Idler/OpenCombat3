
class_name DeckData

var cards : PoolIntArray #of int (card id)
var name : String
var key_cards : PoolIntArray #of int (card id)


func _init(d_name : String, d_cards : PoolIntArray, k_cards : PoolIntArray):
	cards = d_cards
	name = d_name
	key_cards = k_cards
