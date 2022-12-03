extends "res://scenes/ui/clickable_control.gd"

class_name ReplayBanner


var match_log : MatchLog

func initialize(m_log : MatchLog):
	match_log = m_log
	
	$LabelPlayer1.text = match_log.primary_data.my_name
	$LabelPlayer2.text = match_log.primary_data.rival_name
	$LabelRegulation.text = match_log.primary_data.regulation

	if match_log.update_data.empty():
		$LabelRound.text = "Round 0"
	else:
		$LabelRound.text = "Round %s" % (match_log.update_data.back() as MatchLog.TimedUpdateData).data.round_count
	$LabelDateTime.text = match_log.datetime

func _ready():
	pass

func set_frame_color(color : Color):
	$Frame.self_modulate = color
	
