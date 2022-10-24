extends Control

class_name CombatPowerBalance

const MAGNIFICATION := 128
const BAR_ALPHA := 0.5
const CENTER_WIDTH2 := 4

const width_table = [sqrt(2)-1,sqrt(3)-1,sqrt(4)-1,sqrt(5)-1,sqrt(6)-1,
		sqrt(7)-1,sqrt(8)-1,sqrt(9)-1,sqrt(10)-1,sqrt(11)-1]

var last_situation : int


class Interface:
	var handle : CombatPowerBalance
	var reverse : bool
	
	func _init(cpb : CombatPowerBalance,r : bool):
		handle = cpb
		reverse = r

	func set_power_tween_step_by_step(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
		if reverse:
			handle.set_power_tween_step_by_step(rival_power,my_power,tween,duration)
		else:
			handle.set_power_tween_step_by_step(my_power,rival_power,tween,duration)
	


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
	var situation = my_power - rival_power
	var border : float = 0.0
	var my_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
	var rival_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
	
	if situation > 0:
		my_color = Color(1,1,1,BAR_ALPHA)
		rival_color = Color(0,0,0,BAR_ALPHA)
		var index = 10 if situation > 10 else situation
		border = width_table[index] * MAGNIFICATION
	elif situation < 0:
		my_color = Color(0,0,0,BAR_ALPHA)
		rival_color = Color(1,1,1,BAR_ALPHA)
		var index = 10 if situation < -10 else -situation
		border = -width_table[index] * MAGNIFICATION
	
	tween.tween_property($MyPower,"margin_left",-640 - border,duration)
	tween.parallel()
	tween.tween_property($RivalPower,"margin_right",640 - border,duration)
	tween.parallel()
	tween.tween_property($MyPower,"color",my_color,duration)
	tween.parallel()
	tween.tween_property($RivalPower,"color",rival_color,duration)
	tween.parallel()
	tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,duration)
	last_situation = situation
	

func set_power_tween_step_by_step(my_power : int,rival_power : int,tween : SceneTreeTween,duration : float):
	var situation = my_power - rival_power
	if situation == last_situation:
#		tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,duration)
		return
	var count = int(abs(situation - last_situation))
	if count == 1:
		set_power_tween(my_power,rival_power,tween,duration)
		return
	var step = sign(situation - last_situation)

	var step_duration = duration / (count + 1)
	var step_interval = (duration - step_duration * count) / (count - 1)
	var now_situation = last_situation
	for i in count:
		now_situation += step
		var border : float = 0.0
		var my_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
		var rival_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
		
		if now_situation > 0:
			my_color = Color(1,1,1,BAR_ALPHA)
			rival_color = Color(0,0,0,BAR_ALPHA)
			var index = 10 if now_situation > 10 else now_situation
			border = width_table[index] * MAGNIFICATION
		elif now_situation < 0:
			my_color = Color(0,0,0,BAR_ALPHA)
			rival_color = Color(1,1,1,BAR_ALPHA)
			var index = 10 if now_situation < -10 else -now_situation
			border = -width_table[index] * MAGNIFICATION
		
		tween.tween_property($MyPower,"margin_left",-640 - border,duration)
		tween.parallel()
		tween.tween_property($RivalPower,"margin_right",640 - border,duration)
		tween.parallel()
		tween.tween_property($MyPower,"color",my_color,duration)
		tween.parallel()
		tween.tween_property($RivalPower,"color",rival_color,duration)
		tween.parallel()
		tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,duration)
		
		if i + 1 < count:
			tween.chain()
			tween.tween_interval(step_interval)
		
	last_situation = situation
