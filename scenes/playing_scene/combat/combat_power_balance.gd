extends Control

class_name CombatPowerBalance

const MAGNIFICATION := 10.0
const BAR_ALPHA := 0.5
const CENTER_WIDTH2 := 4

const border_table = [10,19,27,34,40,45,49,52,54,55]


var last_p1_power : int
var last_p2_power : int

class Interface:
	var handle : CombatPowerBalance
	var reverse : bool
	
	func _init(cpb : CombatPowerBalance,r : bool):
		handle = cpb
		reverse = r

	func set_power_tween_step_by_step(my_power : int,rival_power : int,duration : float):
		if reverse:
			handle.set_power_tween_step_by_step(rival_power,my_power,duration)
		else:
			handle.set_power_tween_step_by_step(my_power,rival_power,duration)

	func set_my_power_tween_step_by_step(my_power : int,duration : float):
		if reverse:
			handle.set_power_tween_step_by_step_p2(my_power,duration)
		else:
			handle.set_power_tween_step_by_step_p1(my_power,duration)
	


func _ready():
	pass

func initial_tween(p1_power : int,p2_power : int,duration : float):
	$MyPower.margin_left = 0
	$MyPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	$RivalPower.margin_right = 0
	$RivalPower.color = Color(0.5,0.5,0.5,BAR_ALPHA)
	$Center.rect_position.x = 640 - CENTER_WIDTH2
	$Center.self_modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($Center,"self_modulate:a",1.0,duration)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	set_power_tween(p1_power,p2_power,duration)


func set_power_tween(p1_power : int,p2_power : int,duration : float):
	var situation = p1_power - p2_power
	var border : float = 0.0
	var my_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
	var rival_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
	
	if situation > 0:
		my_color = Color(1,1,1,BAR_ALPHA)
		rival_color = Color(0,0,0,BAR_ALPHA)
		var index = 10 if situation > 10 else situation
		border = border_table[index-1] * MAGNIFICATION
	elif situation < 0:
		my_color = Color(0,0,0,BAR_ALPHA)
		rival_color = Color(1,1,1,BAR_ALPHA)
		var index = 10 if situation < -10 else -situation
		border = -border_table[index-1] * MAGNIFICATION
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($MyPower,"margin_left",-640 - border,duration)
	tween.tween_property($RivalPower,"margin_right",640 - border,duration)
	tween.tween_property($MyPower,"color",my_color,duration)
	tween.tween_property($RivalPower,"color",rival_color,duration)
	tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,duration)
	last_p1_power = p1_power
	last_p2_power = p2_power
	

func set_power_tween_step_by_step_p1(p1_power : int,duration : float):
	set_power_tween_step_by_step(p1_power,last_p2_power,duration)

func set_power_tween_step_by_step_p2(p2_power : int,duration : float):
	set_power_tween_step_by_step(last_p1_power,p2_power,duration)


func set_power_tween_step_by_step(p1_power : int,p2_power : int,duration : float):
	var last_situation = last_p1_power - last_p2_power
	last_p1_power = p1_power
	last_p2_power = p2_power
	var situation = p1_power - p2_power
	if situation == last_situation:
#		tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,duration)
		return
	var count = int(abs(situation - last_situation))
	if count == 1:
		set_power_tween(p1_power,p2_power,duration)
		return
	var step = sign(situation - last_situation)

	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var step_duration : float = duration / (count + 1)
	var step_interval : float = (duration - step_duration * count) / (count - 1)
	for i in count:
		last_situation += step
		var border : float = 0.0
		var my_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
		var rival_color : Color = Color(0.5,0.5,0.5,BAR_ALPHA)
		
		if last_situation > 0:
			my_color = Color(1,1,1,BAR_ALPHA)
			rival_color = Color(0,0,0,BAR_ALPHA)
			var index = 10 if last_situation > 10 else last_situation
			border = border_table[index-1] * MAGNIFICATION
		elif last_situation < 0:
			my_color = Color(0,0,0,BAR_ALPHA)
			rival_color = Color(1,1,1,BAR_ALPHA)
			var index = 10 if last_situation < -10 else -last_situation
			border = -border_table[index-1] * MAGNIFICATION
		
		tween.tween_property($MyPower,"margin_left",-640 - border,step_duration)
		tween.tween_property($RivalPower,"margin_right",640 - border,step_duration)
		tween.tween_property($MyPower,"color",my_color,step_duration)
		tween.tween_property($RivalPower,"color",rival_color,step_duration)
		tween.tween_property($Center,"rect_position:x",640 - CENTER_WIDTH2 - border,step_duration)
		if i + 1 < count:
			tween.chain()
			tween.tween_interval(step_interval)
			tween.chain()

