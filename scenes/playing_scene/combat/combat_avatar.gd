extends Node2D

class_name CombatAvatar

func initialize(cd : CardData):
	$CardFront/Picture.texture = load("res://card_images/"+ cd.image +".png")
	$CardFront/Frame.self_modulate = CardData.RGB[cd.color]
	pass

func _ready():
	pass

func attack(rival,# : PlayingPlayer,
		tween : SceneTreeTween):
	var original_x = position.x
	tween.tween_property(self,"position:x",0.0,0.1)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(rival,"add_damage",[1])
	tween.tween_property(self,"position:x",original_x,0.2)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)	
	
	
