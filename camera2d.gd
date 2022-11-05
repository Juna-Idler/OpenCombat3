extends Camera2D


func _ready():
	pass


func shake():
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	var duration := 0.04
	for i in 8:
		var f = Vector2(rand_range(-32, 32),rand_range(-32, 32))
		tween.tween_property(self,"offset",f,duration)
	
	tween.tween_property(self,"offset",Vector2.ZERO,duration)
	
