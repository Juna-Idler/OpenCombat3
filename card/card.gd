extends Node2D



var id_in_deck:int

var data := CardData.new()

var affected := Affected.new()
class Affected:
	var power : int = 0
	var hit : int = 0
	var damage : int = 0
	var rush : int = 0


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
