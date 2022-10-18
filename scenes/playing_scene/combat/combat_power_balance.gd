extends Control

class_name CombatPowerBalance

const MAGNIFICATION := 128
const BAR_ALPHA := 0.5
const CENTER_WIDTH2 := 4

func _ready():
	pass

func initial_tween(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
	$MyPower.margin_left = 0
	$MyPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	$RivalPower.margin_right = 0
	$RivalPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	$Center.rect_position.x = 640 - CENTER_WIDTH2
	$Center.self_modulate.a = 0.0
	tween.tween_property($Center,"self_modulate:a",1.0,duration)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.parallel()
	set_power_tween(my_power,rival_power,tween,duration)


func set_power_tween(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
	var sub : float = my_power - rival_power
	sub = sqrt(abs(sub)) * sign(sub)
	var my_color : Color
	var rival_color : Color
	if sub > 0:
		my_color = Color(1,1,1,BAR_ALPHA)
		rival_color = Color(0,0,0,BAR_ALPHA)
	elif sub < 0:
		my_color = Color(0,0,0,BAR_ALPHA)
		rival_color = Color(1,1,1,BAR_ALPHA)
	else:
		my_color = Color(0.5,0.5,0.5,BAR_ALPHA)
		rival_color = Color(0.5,0.5,0.5,BAR_ALPHA)
	
	tween.tween_property($MyPower,"margin_left",-640 - sub * MAGNIFICATION,duration)
	tween.parallel()
	tween.tween_property($RivalPower,"margin_right",640 - sub * MAGNIFICATION,duration)
	tween.parallel()
	tween.tween_property($MyPower,"color",my_color,duration)
	tween.parallel()
	tween.tween_property($RivalPower,"color",rival_color,duration)
	tween.parallel()
	tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - sub * MAGNIFICATION,duration)


