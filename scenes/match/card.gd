extends Node2D

class_name MatchCard


enum Location{
	STOCK,
	HAND,
	PLAYED,
	DISCARD,
}


var id_in_deck:int
var location : int

var skills : Array # of MatchEffect.IEffect

var front : CardFront = null

var affected := CardData.Stats.new(0,0,0)



func initialize_card(id:int,cd : CardData,skill_factory : MatchEffect.ISkillFactory,rotate := false) -> MatchCard:
	id_in_deck = id
	location = Location.STOCK
	front = $CardFront.initialize_card(cd,rotate)
	for i in front.data.skills:
		skills.append(skill_factory._create(i))

	return self

func get_card_data() -> CardData:
	return front.data

func get_current_power() -> int:
	return front.data.stats.power + affected.power
	
func get_current_hit() -> int:
	return front.data.stats.hit + affected.hit
	
func get_current_block() -> int:
	return front.data.stats.block + affected.block

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

