extends Node2D

class_name Card


enum Place{
	STACK,
	HAND,
	PLAYED,
	DISCARD,
}

var id_in_deck:int
var place : int

var front : CardFront = null

var affected := Affected.new()
class Affected:
	var power : int = 0
	var hit : int = 0
	var damage : int = 0
	var rush : int = 0
	
	func add(other : Affected):
		power += other.power
		hit += other.hit
		damage += other.damage
		rush += other.rush


func initialize_card(id:int,cd : CardData,rotate := false) -> Card:
	id_in_deck = id
	place = Place.STACK
	front = $CardFront.initialize_card(cd,rotate)

	return self

func get_card_data() -> CardData:
	return front.data

func get_current_power() -> int:
	return front.data.power + affected.power
	
func get_current_hit() -> int:
	return front.data.hit + affected.hit

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

