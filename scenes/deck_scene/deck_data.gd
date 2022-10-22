
class_name DeckData

var cards : Array #of int (card id)
var name : String
var key_card_indexes : Array #of int (cards Array index)


func _init(deck_cards : Array, deck_name : String, kci : Array):
	cards = deck_cards
	name = deck_name
	key_card_indexes = kci
