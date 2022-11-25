extends "res://scenes/ui/clickable_control.gd"

class_name ReplayBanner


var match_log : MatchLog

func initialize(m_log : MatchLog):
	match_log = m_log
	
	$LabelPlayer1.text = match_log.primary_data.my_name
	$LabelPlayer2.text = match_log.primary_data.rival_name
	$LabelRegulation.text = match_log.primary_data.regulation

func _ready():
	pass

func set_frame_color(color : Color):
	$Frame.self_modulate = color
	
	
