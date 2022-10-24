extends Node2D


func initialize(cd : CardData):
	$CardFront/Picture.texture = load("res://card_images/"+ cd.image +".png")
	$CardFront/Frame.self_modulate = CardData.RGB[cd.color]
	pass

func _ready():
	pass
