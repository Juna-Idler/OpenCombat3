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

var front : RawCard = null

var affected := Affected.new()
class Affected:
	var power : int = 0
	var hit : int = 0
	var damage : int = 0
	var rush : int = 0


const skillline = preload("skill_line.tscn")
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

const format_pattern := ["  %s","[center]%s[/center]","[right]%s    [/right]"]
const rotate_format_pattern := ["[right]%s   [/right]","[center]%s[/center]","   %s"]

func initialize_card(id:int,cd : CardData,rotate := false) -> Card:
	id_in_deck = id
	place = Place.STACK
	front = $CardFront.initialize_card(cd,rotate)

	return self

func get_card_data() -> CardData:
	return front.data


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

