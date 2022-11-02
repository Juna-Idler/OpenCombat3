
class_name DeckData

var name : String
var cards : PoolIntArray #of int (card id)
var key_cards : PoolIntArray #of int (card id)

func _init(d_name : String, d_cards : PoolIntArray, k_cards : PoolIntArray):
	cards = d_cards
	name = d_name
	key_cards = k_cards

func equal(other : DeckData) -> bool:
	if name != other.name or cards.size() != other.cards.size()\
			or key_cards.size() != other.key_cards.size():
		return false
	for i in cards.size():
		if cards[i] != other.cards[i]:
			return false
	for i in key_cards.size():
		if key_cards[i] != other.key_cards[i]:
			return false
	return true

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
