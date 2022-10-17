extends Control

class_name CombatPowerBalance

const ZERO_OFFSET := 320
const BAR_ALPHA := 0.75

func _ready():
	pass

func initial_tween(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
	$MyPower.margin_left = 0
	$MyPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	$RivalPower.margin_right = 0
	$RivalPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	set_power_tween(my_power,rival_power,tween,duration)


func set_power_tween(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
	var rate := (rival_power + 1) / float(my_power + rival_power + 2)
	var rpoint := (rect_size.x - ZERO_OFFSET * 2) * rate
	var ppoint := (rect_size.x - ZERO_OFFSET * 2) - rpoint
	
	tween.tween_property($MyPower,"margin_left",-ZERO_OFFSET - ppoint,duration)
	tween.parallel()
	tween.tween_property($RivalPower,"margin_right",ZERO_OFFSET + rpoint,duration)
	tween.parallel()
	tween.tween_property($MyPower,"color",Color(1 - rate,1 - rate,1 - rate,BAR_ALPHA),duration)
	tween.parallel()
	tween.tween_property($RivalPower,"color",Color(rate,rate,rate,BAR_ALPHA),duration)


